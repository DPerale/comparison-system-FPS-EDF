with Ada.Real_Time; use Ada.Real_Time;
with System_Time;
with System.Task_Primitives.Operations;
with System.BB.Time;
with System.BB.Threads;
with System.BB.Threads.Queues;

package body Print_Task is

   task body Print is
      Task_Static_Offset : constant Ada.Real_Time.Time_Span :=
               Ada.Real_Time.Microseconds (500000);

      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
            + System_Time.Task_Activation_Delay + Task_Static_Offset;

      Period : constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds (Cycle_Time);

      i : Integer := 0;

   begin

      System.Task_Primitives.Operations.Set_Relative_Deadline
         (System.Task_Primitives.Operations.Self,
          System.BB.Time.Milliseconds (Dead));
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
