with Ada.Real_Time; use Ada.Real_Time;
with System_Time;
with System.Task_Primitives.Operations;
with System.BB.Time;
with System.BB.Threads;
with System.BB.Threads.Queues;

package body Log_Reporter_Task is

   task body Log_Reporter is
      Task_Static_Offset : constant Ada.Real_Time.Time_Span :=
               Ada.Real_Time.Microseconds (Offset);

      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
            + System_Time.Task_Activation_Delay + Task_Static_Offset;

      Period_To_Add : constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds (Period);

      function Time_Conversion (Time_in  : Ada.Real_Time.Time)
                                return System.BB.Time.Time_Span;
      function Time_Conversion (Time_in  : Ada.Real_Time.Time)
                                return System.BB.Time.Time_Span is
         Time_in_to_Time_Span : Ada.Real_Time.Time_Span;
         Time_out : System.BB.Time.Time_Span;
      begin
         Time_in_to_Time_Span := Time_in - Ada.Real_Time.Time_First;
         Time_out := System.BB.Time.To_Time_Span
           (Ada.Real_Time.To_Duration (Time_in_to_Time_Span));
         return Time_out;
      end Time_Conversion;

      Flag : Boolean := False;
      Synchronization : Ada.Real_Time.Time_Span;

   begin
      Synchronization := Next_Period - Ada.Real_Time.Time_First;
      Synchronization := (Synchronization / 180000) * 180000;
      Synchronization := Synchronization - Ada.Real_Time.Microseconds (73);
      Next_Period := Ada.Real_Time.Time_First + Synchronization;
      System.Task_Primitives.Operations.Set_Period
         (System.Task_Primitives.Operations.Self,
         System.BB.Time.Microseconds (Period));
      System.Task_Primitives.Operations.Set_Starting_Time
        (System.Task_Primitives.Operations.Self,
          Time_Conversion (Next_Period));
      System.Task_Primitives.Operations.Set_Relative_Deadline
         (System.Task_Primitives.Operations.Self,
          System.BB.Time.Milliseconds (Deadline), False);
      loop

         delay until Next_Period;

         if Flag then
            System.BB.Threads.Queues.Print_Log (1);
         end if;

         Flag := True;

         Next_Period := Next_Period + Period_To_Add;
      end loop;
   end Log_Reporter;

end Log_Reporter_Task;
