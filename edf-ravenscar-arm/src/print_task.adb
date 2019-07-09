with Ada.Real_Time; use Ada.Real_Time;
with System_Time;
with System.Task_Primitives.Operations;
with System.BB.Time;
with System.BB.Threads;
with System.BB.Threads.Queues;
with System.Tasking;

package body Print_Task is

   task body Print is
      Task_Static_Offset : constant Ada.Real_Time.Time_Span :=
               Ada.Real_Time.Microseconds (Offset);

      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
            + System_Time.Task_Activation_Delay + Task_Static_Offset;

      Period : constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds (Cycle_Time);

      i : Integer := 0;
      Starting_Time_Ada_Real_Time :
      constant Ada.Real_Time.Time_Span
        := Next_Period - Ada.Real_Time.Time_First;
      Starting_Time_BB_Time : System.BB.Time.Time_Span;
   begin
      Starting_Time_BB_Time := System.BB.Time.To_Time_Span
        (Ada.Real_Time.To_Duration (Starting_Time_Ada_Real_Time));
      System.Task_Primitives.Operations.Set_Period
         (System.Task_Primitives.Operations.Self,
         System.BB.Time.Microseconds (Cycle_Time));
      System.Task_Primitives.Operations.Set_Starting_Time
        (System.Task_Primitives.Operations.Self,
          Starting_Time_BB_Time);
      System.Task_Primitives.Operations.Set_Relative_Deadline
         (System.Task_Primitives.Operations.Self,
          System.BB.Time.Microseconds (-1));
      System.Tasking.Set_Priority (Pri);
      loop
         delay until Next_Period;

         if i /= 0 then
            System.BB.Threads.Queues.Print_Table (1);
         end if;
         i := i + 1;

         Next_Period := Next_Period + Period;
      end loop;
   end Print;

end Print_Task;
