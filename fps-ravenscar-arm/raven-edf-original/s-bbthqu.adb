------------------------------------------------------------------------------
--                                                                          --
--                  GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                --
--                                                                          --
--               S Y S T E M . B B . T H R E A D S . Q U E U E S            --
--                                                                          --
--                                  B o d y                                 --
--                                                                          --
--        Copyright (C) 1999-2002 Universidad Politecnica de Madrid         --
--             Copyright (C) 2003-2005 The European Space Agency            --
--                     Copyright (C) 2003-2011, AdaCore                     --
--                                                                          --
-- GNARL is free software; you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion. GNARL is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNARL was developed by the GNARL team at Florida State University.       --
-- Extensive contributions were provided by Ada Core Technologies, Inc.     --
--                                                                          --
-- The port of GNARL to bare board targets was initially developed by the   --
-- Real-Time Systems Group at the Technical University of Madrid.           --
--                                                                          --
------------------------------------------------------------------------------

pragma Restrictions (No_Elaboration_Code);

with System.BB.CPU_Primitives.Multiprocessors;

-------------------------------------------------------------
-------------------------------------------------------------
--  Used for debug procedures
with System.IO;
with System.BB.Debug; use System.BB.Debug;
with System.Address_Image;
with System.BB.Stats;
-------------------------------------------------------------
-------------------------------------------------------------

package body System.BB.Threads.Queues is

   use type System.BB.Time.Time;
   use System.Multiprocessors;
   use System.BB.CPU_Primitives.Multiprocessors;
   use System.BB.Deadlines;
   --  for deadline references

   use System.IO;
   use System.BB.Time;

   ----------------
   -- Local data --
   ----------------

   Alarms_Table : array (CPU) of Thread_Id := (others => Null_Thread_Id);
   pragma Volatile_Components (Alarms_Table);
   --  Identifier of the thread that is in the first place of the alarm queue

   ---------------------
   -- Change_Priority --
   ---------------------

   procedure Change_Priority
     (Thread   : Thread_Id;
      Priority : System.Any_Priority;
      Flag     : Boolean)
   is
      --  Aux_Pointer : Thread_Id;
      CPU_Id      : constant CPU := Get_CPU (Thread);
      --  Now         : constant System.BB.Time.Time := System.BB.Time.Clock;

   begin
      --  A CPU can only change the priority of its own tasks

      pragma Assert (CPU_Id = Current_CPU);

      --  We can only change the priority of the thread that is
      --  currently executing.

      pragma Assert (Thread = Running_Thread_Table (CPU_Id)
                     and then Thread = First_Thread_Table (CPU_Id));

      --  When raising priority to Int_Priority there is no need to modify
      --  the ready queue order: the thread changing its priority is the
      --  running thread (as checked in the Assert) so it needs no
      --  modification

      --  When we are lowering thread priority level we need to control
      --  the queue because some threads could be released by Interrupts so
      --  someone could have an absolute deadline lower than the current
      --  thread and it have to be enqueued before the current thread

      --  Change the active priority. The base priority does not change.
      --  The only case is changing priority levels because of
      --  Interrupt_Wrapper.

      --  We have to change priority after the control block. If we change
      --  priority before the control block, the check
      --  Priority < Thread.Active_Priority
      --  is always false and the condition can never be reach

      Thread.Active_Priority := Priority;

      --  Changing Busy_For_Interrupts flag value to reserve first queue
      --  position for interrupts
      Busy_For_Interrupts := Flag;

   end Change_Priority;

   ------------------------------
   -- Change_Relative_Deadline --
   ------------------------------

   procedure Change_Relative_Deadline
     (Thread       : Thread_Id;
      Rel_Deadline : Relative_Deadline)
   is
      Aux_Pointer : Thread_Id;
      CPU_Id      : constant CPU := Get_CPU (Thread);
      Now         : constant System.BB.Time.Time := System.BB.Time.Clock;
   begin
      --  A CPU can only change the relative deadline of its own tasks

      pragma Assert (CPU_Id = Current_CPU);

      --  We can only change the priority of the thread that is
      --  currently executing.

      pragma Assert (Thread = Running_Thread_Table (CPU_Id));

      --  Change the active relative deadline. The base relative deadline does
      --  not change
      Thread.Active_Relative_Deadline := Rel_Deadline;

      Thread.Active_Absolute_Deadline := (Rel_Deadline + Now);

      --  When lowering the relative deadline, we have to lower absolute
      --  deadline too because our considerations about enqueuing will be
      --  based on absolute deadline value. Furthermore it is not possible
      --  that there is another task with a lower absolute deadline (otherwise
      --  the other task would be running). Hence, there is no displacement
      --  required within the queue, because the thread is already in the
      --  first position.
      if Thread.Next /= Null_Thread_Id
        --  and then Priority < Thread.Next.Active_Priority
        and then Thread.Active_Absolute_Deadline >
                      Thread.Next.Active_Absolute_Deadline
      then
         --  Keep attention

         --  If we are here it is because the currently executing
         --  thread is raising its relative deadline, and there is a thread
         --  with a lower absolute deadline (because we compare between
         --  absolute deadlines) ready to execute.

         --  The running thread is no longer the lowest absolute deadline
         --  thread

         First_Thread_Table (CPU_Id) := Thread.Next;

         Aux_Pointer := First_Thread_Table (CPU_Id);

         --  FIFO_Within_Priorities dispatching policy. In ALRM D.2.2 it
         --  is said that when the active priority is lowered due to the
         --  loss of inherited priority (the only possible case within the
         --  Ravenscar profile) the task is added at the head of the ready
         --  queue for its new active priority. Next loop will look
         --  for the value of Aux_Pointer that contains the last thread with
         --  a higher priority (so that we insert the thread just after it).

         while Aux_Pointer.Next /= Null_Thread_Id
            and then Thread.Active_Absolute_Deadline >
                          Aux_Pointer.Next.Active_Absolute_Deadline
         loop
            Aux_Pointer := Aux_Pointer.Next;
         end loop;

         --  Insert the thread just after the Aux_Pointer

         Thread.Next := Aux_Pointer.Next;
         Aux_Pointer.Next := Thread;
      end if;
   end Change_Relative_Deadline;

   ------------------------------
   -- Change_Absolute_Deadline --
   ------------------------------

   procedure Change_Absolute_Deadline
     (Thread       : Thread_Id;
      Abs_Deadline : Absolute_Deadline)
   is
      --  Previous_Thread, Next_Thread : Thread_Id;
      CPU_Id      : constant CPU := Get_CPU (Thread);

   begin
      --  A CPU can only change the absolute deadline of its own tasks
      pragma Assert (CPU_Id = Current_CPU);

      pragma Assert (Thread = Running_Thread_Table (CPU_Id));

      --  Changing absolute deadline can be referred to 3 main events:
      --  1) Floor Deadline: task obtains floor deadline value caused by a PO.
      --          In this case Active_Absolute_Deadline attribute is changed
      --          inside the procedure Change_Relative_Deadline.
      --  2) Delayed task: in this case a delayed task that returns in the
      --          ready queue needs to change its Active_Absolute_Deadline
      --          attribute because the new position in the queue is referred
      --          to the time which task is released.
      --  3) Suspended task: this case is similar to the previous one. Also in
      --          in this case Active_Absolute_Deadline attribute needs to be
      --          updated when task is released.
      --  So we need to update Active_Absolute_Deadline and then insert the
      --  task in its correct position in the queue.

      --  Because Insert operation is performed immediatly after active
      --  absolute deadline update, there is no needs to insert thread
      --  directly from Change_Absolute_Deadline method. It's more useful to
      --  follow natural behaviour of the Runtime

      Thread.Active_Absolute_Deadline := Abs_Deadline;
   end Change_Absolute_Deadline;

   ---------------------------
   -- Context_Switch_Needed --
   ---------------------------

   function Context_Switch_Needed return Boolean is
      --  Self : constant Thread_Id := Running_Thread_Table (Current_CPU);
   begin
      --  A context switch is needed when there is a higher priority task ready
      --  to execute. It means that First_Thread is not null and it is not
      --  equal to the task currently executing (Running_Thread).

      pragma Assert (First_Thread /= Null_Thread_Id
                     and then Running_Thread /= Null_Thread_Id);

      --  System.IO.Put_Line (System.Address_Image (Self.ATCB));

      if not Busy_For_Interrupts
        and not Busy_For_Handlers then
         if Print_Preem then
            if First_Thread /= Running_Thread
              and Running_Thread.Preemption_Needed then
               System.BB.Stats.Preemptions := System.BB.Stats.Preemptions + 1;
               System.IO.Put_Line ("PREEMPTION; "
                 & Integer'Image (System.BB.Stats.Preemptions)
                 & "; " &
                 System.Address_Image (First_Thread_Table (Current_CPU).ATCB));

               if Running_Thread.ATCB /= Null_Address then
                  System.IO.Put_Line ("; "
                    & System.Address_Image (Running_Thread.ATCB));
                  --  & "; " & System.Address_Image (Running_Thread.ATCB));
               else
                  System.IO.Put_Line (";");
               end if;
            end if;
         end if;

         return First_Thread /= Running_Thread;
      else
         return False;
      end if;
   end Context_Switch_Needed;

   ----------------------
   -- Current_Priority --
   ----------------------

   --  function Current_Priority
   --    (CPU_Id : System.Multiprocessors.CPU) return System.Any_Priority
   --  is
   --     Thread : constant Thread_Id := Running_Thread_Table (CPU_Id);
   --  begin
   --     if Thread = null or else Thread.State /= Threads.Runnable then
   --        return System.Any_Priority'First;
   --     else
   --        return Thread.Active_Priority;
   --     end if;
   --  end Current_Priority;

   -------------------------------
   -- Current_Relative_Deadline --
   -------------------------------

   function Current_Relative_Deadline
     (CPU_Id : System.Multiprocessors.CPU) return Relative_Deadline
   is
      Thread : constant Thread_Id := Running_Thread_Table (CPU_Id);
   begin
      if Thread = null or else Thread.State /= Threads.Runnable then
         return System.BB.Deadlines.Relative_Deadline (0);
      else
         return Thread.Active_Relative_Deadline;
      end if;
   end Current_Relative_Deadline;

   -------------------------------
   -- Current_Absolute_Deadline --
   -------------------------------

   function Current_Absolute_Deadline
     (CPU_Id : System.Multiprocessors.CPU) return Absolute_Deadline
   is
      Thread : constant Thread_Id := Running_Thread_Table (CPU_Id);
   begin
      if Thread = null or else Thread.State /= Threads.Runnable then
         return System.BB.Deadlines.Absolute_Deadline'Last;
      else
         return Thread.Active_Absolute_Deadline;
      end if;
   end Current_Absolute_Deadline;

   -------------
   -- Extract --
   -------------

   procedure Extract (Thread : Thread_Id) is
      CPU_Id : constant CPU := Get_CPU (Thread);

   begin
      --  A CPU can only modify its own tasks queues
      pragma Assert (CPU_Id = Current_CPU);

      --  The only thread that can be extracted from the ready list is the one
      --  that is currently executing (as a result of a delay or a protected
      --  operation).

      pragma Assert
        (Thread = Running_Thread_Table (CPU_Id)
          and then Thread = First_Thread_Table (CPU_Id)
          and then Thread.State /= Runnable);

      --  We have to protect extract action to prevent the extraction during
      --  and Interrupt_Wrapper. The First_Thread_Table thread have to remain
      --  in its position while interrupts run their handlers

      First_Thread_Table (CPU_Id) := Thread.Next;
      Thread.Next := Null_Thread_Id;
   end Extract;

   -------------------------
   -- Extract_First_Alarm --
   -------------------------

   function Extract_First_Alarm return Thread_Id is
      CPU_Id : constant CPU       := Current_CPU;
      Result : constant Thread_Id := Alarms_Table (CPU_Id);

   begin
      --  A CPU can only modify its own tasks queues

      pragma Assert (CPU_Id = Current_CPU);
      pragma Assert (Result.State = Delayed);

      Alarms_Table (CPU_Id) := Result.Next_Alarm;
      Result.Alarm_Time := System.BB.Time.Time'Last;
      Result.Next_Alarm := Null_Thread_Id;

      return Result;
   end Extract_First_Alarm;

   ------------------
   -- First_Thread --
   ------------------

   function First_Thread return Thread_Id is
   begin
      return First_Thread_Table (Current_CPU);
   end First_Thread;

   -------------------------
   -- Get_Next_Alarm_Time --
   -------------------------

   function Get_Next_Alarm_Time (CPU_Id : CPU) return System.BB.Time.Time is
      Thread : Thread_Id;

   begin
      Thread := Alarms_Table (CPU_Id);

      if Thread = Null_Thread_Id then

         --  If alarm queue is empty then next alarm to raise will be Time'Last

         return System.BB.Time.Time'Last;

      else
         return Thread.Alarm_Time;
      end if;
   end Get_Next_Alarm_Time;

   ------------
   -- Insert --
   ------------

   procedure Insert (Thread : Thread_Id) is
      Aux_Pointer : Thread_Id;
      CPU_Id      : constant CPU := Get_CPU (Thread);

   begin
      --  ??? This pragma is disabled because the Tasks_Activated only
      --  represents the end of activation for one package not all the
      --  packages. We have to find a better milestone for the end of tasks
      --  activation.

      --  --  A CPU can only insert alarm in its own queue, except during
      --  --  initialization.

      --  pragma Assert (CPU_Id = Current_CPU or else not Tasks_Activated);

      --  It may be the case that we try to insert a task that is already in
      --  the queue. This can only happen if the task was not runnable and its
      --  context was being used for handling an interrupt. Hence, if the task
      --  is already in the queue we do nothing.

      --  Insert at the head of queue if there is no other thread with a higher
      --  priority.

      if First_Thread_Table (CPU_Id) = Null_Thread_Id
        or else
          Thread.Active_Absolute_Deadline <
                First_Thread_Table (CPU_Id).Active_Absolute_Deadline
      then
         Thread.Next := First_Thread_Table (CPU_Id);
         First_Thread_Table (CPU_Id) := Thread;

         --  Middle or tail insertion

      else
         --  Look for the Aux_Pointer to insert the thread just after it
         --  In case we are inside the Interrupt_Wrapper, the thread is insert
         --  in the correct position from the First_Thread_Table (CPU_Id).Next
         --  because first position is reserveed. When Busy_For_Interrupts
         --  will be released, first thread will be reinserted in the correct
         --  order

         Aux_Pointer := First_Thread_Table (CPU_Id);

         while Aux_Pointer /= Thread
           and then Aux_Pointer.Next /= Null_Thread_Id
           and then Aux_Pointer.Next.Active_Absolute_Deadline
                              <= Thread.Active_Absolute_Deadline
         loop
            Aux_Pointer := Aux_Pointer.Next;
         end loop;

         --  Insert the thread after the Aux_Pointer, if needed

         if Aux_Pointer /= Thread then
            Thread.Next := Aux_Pointer.Next;
            Aux_Pointer.Next := Thread;
         end if;

      end if;
   end Insert;

   ------------------
   -- Insert_Alarm --
   ------------------

   procedure Insert_Alarm
     (T        : System.BB.Time.Time;
      Thread   : Thread_Id;
      Is_First : out Boolean)
   is
      CPU_Id       : constant CPU := Get_CPU (Thread);
      Alarm_Id_Aux : Thread_Id;

   begin
      --  A CPU can only insert alarm in its own queue
      pragma Assert (CPU_Id = Current_CPU);

      --  We can only insert in the alarm queue threads whose state is Delayed

      pragma Assert (Thread.State = Delayed);

      --  Set the Alarm_Time within the thread descriptor

      Thread.Alarm_Time := T;

      --  Case of empty queue, or new alarm expires earlier, insert the thread
      --  as the first thread.

      if Alarms_Table (CPU_Id) = Null_Thread_Id
        or else T < Alarms_Table (CPU_Id).Alarm_Time
      then
         Thread.Next_Alarm := Alarms_Table (CPU_Id);
         Alarms_Table (CPU_Id) := Thread;
         Is_First := True;

      --  Otherwise, place in the middle

      else
         --  Find the minimum greater than T alarm within the alarm queue
         Alarm_Id_Aux := Alarms_Table (CPU_Id);
         while Alarm_Id_Aux.Next_Alarm /= Null_Thread_Id and then
           Alarm_Id_Aux.Next_Alarm.Alarm_Time < T
         loop
            Alarm_Id_Aux := Alarm_Id_Aux.Next_Alarm;
         end loop;

         Thread.Next_Alarm := Alarm_Id_Aux.Next_Alarm;
         Alarm_Id_Aux.Next_Alarm := Thread;

         Is_First := False;

      end if;
   end Insert_Alarm;

   --------------------
   -- Running_Thread --
   --------------------

   function Running_Thread return Thread_Id is
   begin
      return Running_Thread_Table (Current_CPU);
   end Running_Thread;

   ---------------------------
   -- Wakeup_Expired_Alarms --
   ---------------------------

   procedure Wakeup_Expired_Alarms is

      Now           : constant System.BB.Time.Time := Clock;
      Next_Alarm    : System.BB.Time.Time := System.BB.Time.Time'Last;
      Wakeup_Thread : Threads.Thread_Id;
      CPU_Id        : constant CPU        := Current_CPU;

   begin
      --  Extract all the threads whose delay has expired

      while Threads.Queues.Get_Next_Alarm_Time (CPU_Id) <= Now loop

         --  Extract the task(s) that was waiting in the alarm queue and insert
         --  it in the ready queue.

         Wakeup_Thread := Threads.Queues.Extract_First_Alarm;

         --  We can only awake tasks that are delay statement

         pragma Assert (Wakeup_Thread.State = Threads.Delayed);

         Wakeup_Thread.State := Threads.Runnable;

         Wakeup_Thread.Preemption_Needed := True;

         Threads.Queues.Change_Absolute_Deadline (Wakeup_Thread,
              (Wakeup_Thread.Active_Relative_Deadline + Now));

         Threads.Queues.Insert (Wakeup_Thread);

      end loop;

      --  Set the timer for the next alarm

      Next_Alarm := Time.Get_Next_Timeout (CPU_Id);
      Update_Alarm (Next_Alarm);
   end Wakeup_Expired_Alarms;

   -----------
   -- Yield --
   -----------

   procedure Yield (Thread : Thread_Id) is
      --  Prio        : constant Integer := Thread.Active_Priority;
      Abs_Dead    : constant System.BB.Deadlines.Absolute_Deadline
               := Thread.Active_Absolute_Deadline;
      Aux_Pointer : Thread_Id;
      CPU_Id      : constant CPU := Get_CPU (Thread);

   begin
      --  A CPU can only modify its own tasks queues
      pragma Assert (CPU_Id = Current_CPU);

      pragma Assert (Thread = Running_Thread_Table (CPU_Id)
                      and then Thread = First_Thread_Table (CPU_Id)
                      and then Thread.State = Runnable);

      if Thread.Next /= Null_Thread_Id
         --  and then Thread.Next.Active_Priority = Prio
         and then Thread.Next.Active_Absolute_Deadline < Abs_Dead
      then
         First_Thread_Table (CPU_Id) := Thread.Next;

         --  Look for the Aux_Pointer to insert the thread just after it

         Aux_Pointer  := First_Thread_Table (CPU_Id);
         while Aux_Pointer.Next /= Null_Thread_Id
           and then Abs_Dead >= Aux_Pointer.Next.Active_Absolute_Deadline
         loop
            Aux_Pointer := Aux_Pointer.Next;
         end loop;

         --  Insert the thread after the Aux_Pointer

         Thread.Next := Aux_Pointer.Next;
         Aux_Pointer.Next := Thread;
      end if;

   end Yield;

end System.BB.Threads.Queues;
