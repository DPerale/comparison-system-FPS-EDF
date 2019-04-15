------------------------------------------------------------------------------
--                                                                          --
--                  GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                --
--                                                                          --
--                   S Y S T E M . B B . I N T E R R U P T S                --
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

with System.Storage_Elements;
with System.BB.CPU_Primitives;
with System.BB.CPU_Primitives.Multiprocessors;
with System.BB.Threads;
with System.BB.Threads.Queues;
with System.BB.Board_Support;
with System.BB.Time;

package body System.BB.Interrupts is

   use type System.Storage_Elements.Storage_Offset;
   use System.Multiprocessors;
   use System.BB.CPU_Primitives.Multiprocessors;
   use System.BB.Threads;
   use System.BB.Time;

   --  Import System.BB.Execution_Time procedures as weak symbols to enable
   --  execution time computation only when needed. See s-bbexti.ads.

   procedure Scheduling_Event (Now : System.BB.Time.Time);
   pragma Import (Ada, Scheduling_Event, "__gnarl_scheduling_event");
   pragma Weak_External (Scheduling_Event);

   procedure Disable_Execution_Time;
   pragma Import (Ada, Disable_Execution_Time,
                    "__gnarl_disable_execution_time");
   pragma Weak_External (Disable_Execution_Time);

   ----------------
   -- Local data --
   ----------------

   type Stack_Space is new Storage_Elements.Storage_Array
     (1 .. Storage_Elements.Storage_Offset (Parameters.Interrupt_Stack_Size));
   for Stack_Space'Alignment use 8;
   --  Type used to represent the stack area for each interrupt. The stack must
   --  be aligned to 8 bytes to allow double word data movements.

   subtype Real_Interrupt_ID is
     Interrupt_ID range Interrupt_ID'First + 1 .. Interrupt_ID'Last;
   --  This subtype is the same as Interrupt_ID but excluding No_Interrupt,
   --  which is not a real interrupt.

   Interrupt_Stacks : array (Real_Interrupt_ID) of Stack_Space;
   --  Array that contains the stack used for each interrupt

   Interrupt_Stack_Table : array (Real_Interrupt_ID) of System.Address;
   pragma Export (Asm, Interrupt_Stack_Table, "interrupt_stack_table");
   --  Table that contains a pointer to the top of the stack for each interrupt

   Poke_Stacks : array (CPU) of Stack_Space;
   --  Array that contains the stack used for poke interrupt. Since the Poke
   --  interrupt is shared between CPUs, we must have a stack for each CPU.
   --  ??? Shouldn't allocate any storage on non-SMP system.

   Poke_Stack_Table : array (CPU) of System.Address;
   pragma Export (Asm, Poke_Stack_Table, "poke_stack_table");
   --  Table that contains a pointer to the top of the poke stack for each CPU

   type Handlers_Table is array (Interrupt_ID) of Interrupt_Handler;
   pragma Suppress_Initialization (Handlers_Table);
   --  Type used to represent the procedures used as interrupt handlers

   Interrupt_Handlers_Table : Handlers_Table;
   --  Table containing handlers attached to the different external interrupts

   Interrupt_Being_Handled : array (CPU) of Interrupt_ID :=
                               (others => No_Interrupt);
   pragma Atomic_Components (Interrupt_Being_Handled);
   --  Interrupt_Being_Handled contains the interrupt currently being handled
   --  by each CPU in the system, if any. It is equal to No_Interrupt when no
   --  interrupt is handled. Its value is updated by the trap handler.

   -----------------------
   -- Local subprograms --
   -----------------------

   procedure Interrupt_Wrapper (Vector : CPU_Primitives.Vector_Id);
   --  This wrapper procedure is in charge of setting the appropriate
   --  software priorities before calling the user-defined handler.

   --------------------
   -- Attach_Handler --
   --------------------

   procedure Attach_Handler (Handler : Interrupt_Handler; Id : Interrupt_ID) is
   begin
      --  Check that we are attaching to a real interrupt
      pragma Assert (Id /= No_Interrupt);

      --  Copy the user's handler to the appropriate place within the table
      Interrupt_Handlers_Table (Id) := Handler;

      --  Transform the interrupt level to the place in the interrupt vector
      --  table. Then insert the wrapper for the interrupt handlers in the
      --  underlying vector table.

      CPU_Primitives.Install_Handler
        (Interrupt_Wrapper'Address, Board_Support.Get_Vector (Id));
   end Attach_Handler;

   -----------------------
   -- Current_Interrupt --
   -----------------------

   function Current_Interrupt return Interrupt_ID is
   begin
      return Interrupt_Being_Handled (Current_CPU);
   end Current_Interrupt;

   -----------------------
   -- Interrupt_Wrapper --
   -----------------------

   procedure Interrupt_Wrapper (Vector : CPU_Primitives.Vector_Id) is
      Self_Id         : constant Threads.Thread_Id :=
                         Threads.Thread_Self;

      --  Removed from Ravenscar EDF version
      --  Caller_Priority : constant Any_Priority :=
      --                     Threads.Get_Priority (Self_Id);

      Interrupt       : constant Interrupt_ID :=
                         Board_Support.Get_Interrupt_Request (Vector);
      Int_Priority    : constant Any_Priority :=
                         Board_Support.Priority_Of_Interrupt (Interrupt);
      CPU_Id          : constant CPU          := Current_CPU;

      Previous_Interrupt_Level : constant Interrupt_ID :=
                                   Interrupt_Being_Handled (CPU_Id);

      Now : Time.Time;

   begin
      --  This must be an external interrupt

      pragma Assert (Interrupt /= No_Interrupt);

      --  Update Execution Time

      if Scheduling_Event'Address /= System.Null_Address then
         Now := System.BB.Time.Clock;
         Scheduling_Event (Now);
      end if;

      --  Store the interrupt being handled

      Interrupt_Being_Handled (CPU_Id) := Interrupt;

      --  Then, we must set the appropriate software priority corresponding
      --  to the interrupt being handled. It comprises also the appropriate
      --  interrupt masking.
      Threads.Queues.Change_Priority (Self_Id, Int_Priority, True);

      CPU_Primitives.Enable_Interrupts (Int_Priority);

      --  Call the user handler
      Interrupt_Handlers_Table (Interrupt).all (Interrupt);

      CPU_Primitives.Disable_Interrupts;

      --  Update Execution Time before changing priority (Scheduling_Event use
      --  priority to determine which task/interrupt will get the elapsed
      --  time).

      if Scheduling_Event'Address /= System.Null_Address then
         Scheduling_Event (Clock);
      end if;

      --  Restore the software priority to the state before the interrupt
      --  happened. Interrupt unmasking is not done here (it will be done
      --  later by the interrupt epilogue).
      Threads.Queues.Change_Priority (Self_Id, Self_Id.Base_Priority, False);

      --  Restore the interrupt that was being handled previously (if any)

      Interrupt_Being_Handled (CPU_Id) := Previous_Interrupt_Level;

      if Disable_Execution_Time'Address /= System.Null_Address
        and then Threads.Queues.First_Thread = Threads.Queues.Running_Thread
        and then Threads.Queues.Running_Thread.State /= Threads.Runnable
        and then Threads.Queues.Running_Thread.Next = Threads.Null_Thread_Id
      then
         --  No task to execute after this interrupt, therefore CPU goes to
         --  idle loop and we can disable the CPU clock.

         Disable_Execution_Time;
      end if;
   end Interrupt_Wrapper;

   ----------------------------
   -- Within_Interrupt_Stack --
   ----------------------------

   function Within_Interrupt_Stack
     (Stack_Address : System.Address) return Boolean
   is
      Interrupt_Handled : constant Interrupt_ID := Current_Interrupt;
      Stack_Start       : System.Address;
      Stack_End         : System.Address;

   begin
      --  Return False if no interrupt is being handled

      if Interrupt_Handled = No_Interrupt then
         return False;

      --  Otherwise, calculate stack boundaries for the interrupt being handled

      else
         if Parameters.Multiprocessor
           and then Interrupt_Handled = Board_Support.Poke_Interrupt_ID
         then
            --  Poke interrupts only available on multiprocessor targets

            Stack_Start :=
              Poke_Stacks (Current_CPU)(Stack_Space'First)'Address;
            Stack_End   :=
              Poke_Stacks (Current_CPU)(Stack_Space'Last)'Address;

         else
            Stack_Start :=
              Interrupt_Stacks (Interrupt_Handled)(Stack_Space'First)'Address;
            Stack_End   :=
              Interrupt_Stacks (Interrupt_Handled)(Stack_Space'Last)'Address;
         end if;

         --  Compare the Address passed as argument against the previously
         --  calculated stack boundaries.

         return Stack_Address >= Stack_Start
                  and then
                Stack_Address <= Stack_End;
      end if;

   end Within_Interrupt_Stack;

   ---------------------------
   -- Initialize_Interrupts --
   ---------------------------

   procedure Initialize_Interrupts is
   begin
      for Index in Real_Interrupt_ID loop

         --  Store the pointer in the last double word

         Interrupt_Stack_Table (Index) :=
           Interrupt_Stacks (Index)(Stack_Space'Last - 7)'Address;
      end loop;

      for Index in CPU loop

         --  Store the pointer in the last double word

         Poke_Stack_Table (Index) :=
           Poke_Stacks (Index)(Stack_Space'Last - 7)'Address;
      end loop;
   end Initialize_Interrupts;

end System.BB.Interrupts;
