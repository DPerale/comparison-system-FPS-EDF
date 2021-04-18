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
--                     Copyright (C) 2003-2018, AdaCore                     --
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

-------------------------------------------------------------
-------------------------------------------------------------
--  Used for debug procedures
with System.IO;
-------------------------------------------------------------
-------------------------------------------------------------

package body System.BB.Threads.Queues is

   use System.Multiprocessors;
   use System.BB.Board_Support.Multiprocessors;
   use System.BB.Deadlines;
   use System.BB.Time;

   ----------------
   -- Local data --
   ----------------

   Alarms_Table : array (CPU) of Thread_Id := (others => Null_Thread_Id);
   pragma Volatile_Components (Alarms_Table);
   --  Identifier of the thread that is in the first place of the alarm queue

   --  Atomic record for the log table
   type Log_Record is
      record
         ID : Integer;
         DM : Integer;
         Runs : Integer;
         Preemption : Integer;
         Min_Response_Jitter :  System.BB.Time.Time_Span;
         Max_Response_Jitter :  System.BB.Time.Time_Span;
         Min_Release_Jitter :  System.BB.Time.Time_Span;
         Max_Release_Jitter :  System.BB.Time.Time_Span;
         Average_Response_Jitter : System.BB.Time.Time_Span;
      end record;

   --  Definition of log table, every element rapresent a task. 90 is a good
   --  number of our implementations because there can't be more tasks for
   --  the RAM limitation of the embedded board. If you need you can change it
   type Array_Log_Record is array (1 .. 90) of Log_Record;

   --  Declaration of log table
   Log_Table : Array_Log_Record;
   Max_ID_Table : Integer := 0;

   --  Before the tasks start we initialize the log table that will fill with
   --  the data when needed.
   procedure Initialize_Log_Table (ID : Integer) is
   begin
      if ID /= 0 then
         Log_Table (ID) := (ID, 0, -1, 0,
                             System.BB.Time.Time_Span_Last,
                             System.BB.Time.Time_Span_First,
                             System.BB.Time.Time_Span_Last,
                             System.BB.Time.Time_Span_First,
                             System.BB.Time.Time_Span_Zero);
         if Max_ID_Table < ID then
            Max_ID_Table := ID;
         end if;
      end if;
   end Initialize_Log_Table;

   procedure Add_DM (ID : Integer) is
   begin
      if ID /= 0 then
         Log_Table (ID).DM := Log_Table (ID).DM + 1;
      end if;
   end Add_DM;

   procedure Add_Runs (ID : Integer) is
   begin
      if ID /= 0 then
         Log_Table (ID).Runs :=
           Log_Table (ID).Runs + 1;
      end if;
   end Add_Runs;

   procedure Add_Preemption (ID : Integer) is
   begin
      if ID /= 0 then
         Log_Table (ID).Preemption := Log_Table (ID).Preemption + 1;
      end if;
   end Add_Preemption;

   --  Procedure to print to screen the log table (not supported in our
   --  embedded board).
   procedure Print_Log (First_Index : Integer) is
      i : Integer := First_Index;
   begin
      while i <= Max_ID_Table loop

         System.IO.Put ("Tab;");
         System.IO.Put (Integer'Image (i));
         System.IO.Put (Integer'Image (Log_Table (i).DM));
         System.IO.Put (Integer'Image (Log_Table (i).Runs));
         System.IO.Put (Integer'Image (Log_Table (i).Preemption));
         System.IO.Put_Line ("");
         i := i + 1;
      end loop;
   end Print_Log;

   ---------------------
   -- Change_Priority --
   ---------------------

   --  The priority is still used but is fixed and equal for all the tasks
   --  in EDF
   procedure Change_Priority (Thread : Thread_Id;
                              Priority : System.Any_Priority;
                              Flag : Boolean)
   is
      CPU_Id       : constant CPU := BOSUMU.Current_CPU;

   begin
      --  A CPU can only change the priority of its own tasks

      pragma Assert (CPU_Id = Current_CPU);

      --  We can only change the priority of the thread that is
      --  currently executing.

      pragma Assert (Thread = Running_Thread_Table (CPU_Id)
                     and then Thread = First_Thread_Table (CPU_Id));

      --  Change the active priority. The base priority does not change

      Thread.Active_Priority := Priority;

      Busy_For_Interrupts := Flag;

   end Change_Priority;

   --  Set the log reporter task priority
   procedure Set_Priority_For_Print (Thread : Thread_Id;
                                    Priority : System.Any_Priority) is
   begin
      Thread.Active_Priority := Priority;
      Thread.Base_Priority := Priority;
   end Set_Priority_For_Print;

   ---------------------------
   -- Change_Fake_Number_ID --
   ---------------------------

   procedure Change_Fake_Number_ID
     (Thread       : Thread_Id;
      Fake_Number_ID : Integer)
   is
   begin
      Thread.Fake_Number_ID := Fake_Number_ID;
   end Change_Fake_Number_ID;

   ------------------------
   -- Change_Is_Sporadic --
   ------------------------

   --  If you use sporadic tasks this procedure will set them as sporadic so
   --  the strumentation will work correctly (the sporadic part is not well
   --  tested).
   procedure Change_Is_Sporadic
     (Thread       : Thread_Id;
      Bool : Boolean)
   is
   begin
      Thread.Is_Sporadic := Bool;
   end Change_Is_Sporadic;

   ------------------------------
   -- Change_Relative_Deadline --
   ------------------------------

   --
   procedure Change_Relative_Deadline
     (Thread       : Thread_Id;
      Rel_Deadline : Relative_Deadline;
      Is_Floor     : Boolean)
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

      if Is_Floor then
         Change_Absolute_Deadline (Thread, Absolute_Deadline'Min (
                                   Now + Thread.Active_Relative_Deadline,
                                   Thread.Active_Absolute_Deadline));
      else

         if Thread.Active_Relative_Deadline <= Thread.Active_Period then
            Change_Absolute_Deadline (Thread, System.BB.Time.Time_First +
                                   Thread.Active_Starting_Time -
                     (Thread.Active_Period - Thread.Active_Relative_Deadline)
                                  + Global_Interrupt_Delay);
         else
            Change_Absolute_Deadline (Thread, System.BB.Time.Time_First +
                                   Thread.Active_Starting_Time +
                     (Thread.Active_Relative_Deadline - Thread.Active_Period)
                                    + Global_Interrupt_Delay);
         end if;
      end if;

      --  When lowering the relative deadline, we have to lower absolute
      --  deadline too because our considerations about enqueuing will be
      --  based on absolute deadline value. Furthermore it is not possible
      --  that there is another task with a lower absolute deadline (otherwise
      --  the other task would be running). Hence, there is no displacement
      --  required within the queue, because the thread is already in the
      --  first position.
      if Thread.Next /= Null_Thread_Id
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

      --  -180 is an impossible number for a deadline, for that we use it
      --  to recognize the log printer task
      if Thread.Active_Relative_Deadline = -180 then
         Thread.Active_Absolute_Deadline := 0;
      end if;
   end Change_Absolute_Deadline;

   -------------------
   -- Change_Period --
   -------------------

   procedure Change_Period
     (Thread       : Thread_Id;
      Period       : System.BB.Time.Time_Span)
   is
      CPU_Id      : constant CPU := Get_CPU (Thread);
   begin
      pragma Assert (CPU_Id = Current_CPU);
      pragma Assert (Thread = Running_Thread_Table (CPU_Id));
      Thread.Active_Period := Period;
   end Change_Period;

   --------------------------
   -- Change_Starting_Time --
   --------------------------

   procedure Change_Starting_Time
     (Thread        : Thread_Id;
      Starting_Time : System.BB.Time.Time_Span)
   is
      CPU_Id      : constant CPU := Get_CPU (Thread);
   begin
      pragma Assert (CPU_Id = Current_CPU);
      pragma Assert (Thread = Running_Thread_Table (CPU_Id));
      Thread.Active_Starting_Time := Starting_Time;
      Thread.Active_Next_Period := System.BB.Time.Time_First +
          (Starting_Time - Thread.Active_Period);
   end Change_Starting_Time;

   ---------------------------
   -- Change_Release_Jitter --
   ---------------------------

   procedure Change_Release_Jitter
     (Thread        : Thread_Id)
   is
      CPU_Id      : constant CPU := Get_CPU (Thread);
      Temp : System.BB.Time.Time_Span;
   begin
      pragma Assert (CPU_Id = Current_CPU);
      pragma Assert (Thread = Running_Thread_Table (CPU_Id));

      if Thread.Just_Wakeup then
         Temp := System.BB.Time.Clock - Thread.Active_Next_Period;
         Thread.Active_Release_Jitter := System.BB.Time.Time_First + (Temp);
         Thread.Just_Wakeup := False;
      end if;
   end Change_Release_Jitter;

   -----------------
   -- Set_Jitters --
   -----------------

   procedure Update_Jitters
     (Thread      : Thread_Id;
      Response_Jitter : System.BB.Time.Time_Span;
      Release_Jitter : System.BB.Time.Time_Span)
   is
      CPU_Id      : constant CPU := Get_CPU (Thread);
   begin
      pragma Assert (CPU_Id = Current_CPU);
      pragma Assert (Thread = Running_Thread_Table (CPU_Id));

      if Log_Table (Thread.Fake_Number_ID).Average_Response_Jitter
        = System.BB.Time.Time_Span_Zero
      then
         Log_Table (Thread.Fake_Number_ID).Average_Response_Jitter :=
           Response_Jitter;
      else
         Log_Table (Thread.Fake_Number_ID).Average_Response_Jitter :=
           ((Log_Table (Thread.Fake_Number_ID).Average_Response_Jitter *
              Log_Table (Thread.Fake_Number_ID).Runs) +
              Response_Jitter)
           / (Log_Table (Thread.Fake_Number_ID).Runs + 1);
      end if;

      if Response_Jitter <
        Log_Table (Thread.Fake_Number_ID).Min_Response_Jitter
      then
         Log_Table (Thread.Fake_Number_ID).Min_Response_Jitter :=
           Response_Jitter;
      end if;

      if Response_Jitter >
        Log_Table (Thread.Fake_Number_ID).Max_Response_Jitter
      then
         Log_Table (Thread.Fake_Number_ID).Max_Response_Jitter :=
           Response_Jitter;
      end if;

      if Release_Jitter <
        Log_Table (Thread.Fake_Number_ID).Min_Release_Jitter
      then
         Log_Table (Thread.Fake_Number_ID).Min_Release_Jitter :=
           Release_Jitter;
      end if;

      if Release_Jitter >
        Log_Table (Thread.Fake_Number_ID).Max_Release_Jitter
      then
         Log_Table (Thread.Fake_Number_ID).Max_Release_Jitter :=
           Release_Jitter;
      end if;

   end Update_Jitters;

   ---------------------------
   -- Context_Switch_Needed --
   ---------------------------

   function Context_Switch_Needed return Boolean is
   begin
      --  A context switch is needed when there is a higher priority task ready
      --  to execute. It means that First_Thread is not null and it is not
      --  equal to the task currently executing (Running_Thread).

      pragma Assert (First_Thread /= Null_Thread_Id
                     and then Running_Thread /= Null_Thread_Id);

      if not Busy_For_Interrupts and not Busy_For_Handlers then

         if First_Thread /= Running_Thread and
           Running_Thread.Preemption_Needed
         then
            Add_Preemption (Running_Thread.Fake_Number_ID);
         end if;

         return First_Thread /= Running_Thread;
      else
         return False;
      end if;
   end Context_Switch_Needed;

   ----------------------
   -- Current_Priority --
   ----------------------

   --  not needed in EDF

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

      pragma Assert
        (Thread = Running_Thread_Table (CPU_Id)
          and then Thread = First_Thread_Table (CPU_Id)
          and then Thread.State /= Runnable);

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
      --  packages. We have to find a better milestone for the end of
      --  tasks activation.

      --  --  A CPU can only insert alarm in its own queue, except during
      --  --  initialization.

      --  pragma Assert (CPU_Id = Current_CPU or else not Tasks_Activated);

      --  It may be the case that we try to insert a task that is already in
      --  the queue. This can only happen if the task was not runnable and its
      --  context was being used for handling an interrupt. Hence, if the task
      --  is already in the queue and we try to insert it, we need to check
      --  whether it is in the correct place.

      --  No insertion if the task is already at the head of the queue
      if First_Thread_Table (CPU_Id) = Thread then
         null;

      --  Insert at the head of queue if there is no other thread with a higher
      --  priority.

      elsif First_Thread_Table (CPU_Id) = Null_Thread_Id
        or else
          Thread.Active_Absolute_Deadline <
            First_Thread_Table (CPU_Id).Active_Absolute_Deadline
      then
         Thread.Next := First_Thread_Table (CPU_Id);
         First_Thread_Table (CPU_Id) := Thread;

      --  Middle or tail insertion

      else
         --  Look for the Aux_Pointer to insert the thread just after it

         Aux_Pointer := First_Thread_Table (CPU_Id);
         while Aux_Pointer.Next /= Null_Thread_Id
           and then Aux_Pointer.Next /= Thread
           and then Aux_Pointer.Next.Active_Absolute_Deadline <=
             Thread.Active_Absolute_Deadline
         loop
            Aux_Pointer := Aux_Pointer.Next;
         end loop;

         --  If we found the thread already in the queue, then we need to move
         --  it to its right place.

         if Aux_Pointer.Next = Thread then

            --  Extract it from its current location

            Aux_Pointer.Next := Thread.Next;

            --  Look for the Aux_Pointer to insert the thread just after it

            while Aux_Pointer.Next /= Null_Thread_Id
              and then
                Aux_Pointer.Next.Active_Absolute_Deadline <=
                  Thread.Active_Absolute_Deadline
            loop
               Aux_Pointer := Aux_Pointer.Next;
            end loop;
         end if;

         --  Insert the thread after the Aux_Pointer

         Thread.Next := Aux_Pointer.Next;
         Aux_Pointer.Next := Thread;
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

   procedure Wakeup_Expired_Alarms (Now : Time.Time) is

      CPU_Id        : constant CPU := Current_CPU;
      Next_Alarm    : System.BB.Time.Time := System.BB.Time.Time'Last;
      Wakeup_Thread : Thread_Id;

   begin
      --  Extract all the threads whose delay has expired
      while Get_Next_Alarm_Time (CPU_Id) <= Now loop

         --  Extract the task(s) that was waiting in the alarm queue and insert
         --  it in the ready queue.

         Wakeup_Thread := Extract_First_Alarm;

         --  We can only awake tasks that are delay statement

         pragma Assert (Wakeup_Thread.State = Delayed);

         Wakeup_Thread.State := Runnable;

         Wakeup_Thread.Preemption_Needed := True;

         Change_Absolute_Deadline (Wakeup_Thread,
                                   (Wakeup_Thread.Active_Period +
                                      Wakeup_Thread.Active_Absolute_Deadline));

         Wakeup_Thread.Just_Wakeup := True;
         Wakeup_Thread.Active_Next_Period := Wakeup_Thread.Active_Next_Period
           + Wakeup_Thread.Active_Period;

         Insert (Wakeup_Thread);

      end loop;

      Next_Alarm := Time.Get_Next_Timeout (CPU_Id);
      Update_Alarm (Next_Alarm);
      --  Note: the caller (BB.Time.Alarm_Handler) must set the next alarm
   end Wakeup_Expired_Alarms;

   -----------
   -- Yield --
   -----------

   procedure Yield (Thread : Thread_Id) is
      CPU_Id      : constant CPU     := Get_CPU (Thread);
      Abs_Dead    : constant System.BB.Deadlines.Absolute_Deadline
               := Thread.Active_Absolute_Deadline;
      Aux_Pointer : Thread_Id;
   begin
      --  A CPU can only modify its own tasks queues
      pragma Assert (CPU_Id = Current_CPU);

      Thread.Just_Wakeup := True;
      Thread.Active_Next_Period := Thread.Active_Next_Period +
        Thread.Active_Period;

      if Thread.Next /= Null_Thread_Id
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

   ------------------
   -- Queue_Length --
   ------------------

   function Queue_Length return Natural is
      Res : Natural   := 0;
      T   : Thread_Id := First_Thread_Table (Current_CPU);

   begin
      while T /= null loop
         Res := Res + 1;
         T := T.Next;
      end loop;

      return Res;
   end Queue_Length;

   -------------------
   -- Queue_Ordered --
   -------------------

   function Queue_Ordered return Boolean is
      T : Thread_Id := First_Thread_Table (Current_CPU);
      N : Thread_Id;

   begin
      if T = Null_Thread_Id then
         --  True if the queue is empty
         return True;
      end if;

      loop
         N := T.Next;
         if N = Null_Thread_Id then
            --  True if at end of the queue
            return True;
         end if;

         if T.Active_Relative_Deadline > N.Active_Relative_Deadline then
            return False;
         end if;

         T := N;
      end loop;
   end Queue_Ordered;

end System.BB.Threads.Queues;
