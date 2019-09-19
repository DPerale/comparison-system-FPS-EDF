with Ada.Real_Time; use Ada.Real_Time;
with System_Time;
with System.Task_Primitives.Operations;
with System.BB.Time;
with System.BB.Threads;
with System.BB.Threads.Queues;
with Print_Task;

package body Cyclic_Tasks is

   task body Cyclic is
      Task_Static_Offset : constant Time_Span :=
               Ada.Real_Time.Microseconds (Offset);

      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
            + System_Time.Task_Activation_Delay + Task_Static_Offset;

      Period : constant Ada.Real_Time.Time_Span :=
               Ada.Real_Time.Microseconds (Cycle_Time);

      procedure Gauss (Times : Integer);
      procedure Gauss (Times : Integer) is
         Num : Integer := 0;
      begin
         for I in 1 .. Times loop
            Num := Num + I;
         end loop;
      end Gauss;
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

      Temp : Integer;
      Work_Jitter : Ada.Real_Time.Time;
      Release_Jitter : Ada.Real_Time.Time;

   begin
      System.Task_Primitives.Operations.Set_Period
         (System.Task_Primitives.Operations.Self,
         System.BB.Time.Microseconds (Cycle_Time));
      System.Task_Primitives.Operations.Set_Starting_Time
        (System.Task_Primitives.Operations.Self,
          Time_Conversion (Next_Period));
      System.Task_Primitives.Operations.Set_Relative_Deadline
         (System.Task_Primitives.Operations.Self,
          System.BB.Time.Microseconds (Dead));
      System.BB.Threads.Set_Fake_Number_ID (T_Num);
      System.BB.Threads.Queues.Initialize_Task_Table (T_Num);

      loop
         delay until Next_Period;

         Release_Jitter := Ada.Real_Time.Time_First +
           (Ada.Real_Time.Clock - Next_Period);

         Temp := Gauss_Num;
         Gauss (Temp);

         Work_Jitter := Ada.Real_Time.Time_First +
           (Ada.Real_Time.Clock - (Release_Jitter
            + (Next_Period - Ada.Real_Time.Time_First)));

         Next_Period := Next_Period + Period;
         System.Task_Primitives.Operations.Set_Jitters
           (System.Task_Primitives.Operations.Self,
           Time_Conversion (Work_Jitter), Time_Conversion (Release_Jitter));
      end loop;
   end Cyclic;

   procedure Init is
   begin
      System.Task_Primitives.Operations.Set_Relative_Deadline
        (System.Task_Primitives.Operations.Self,
          System.BB.Time.Milliseconds (Integer'Last));
      loop
         null;
      end loop;
   end Init;

   P1 : Print_Task.Print (240, -1, 113400, 0); -- period in milliseconds
   C1 : Cyclic (20, 10000, 10000, 1, 4948, 0);
   C2 : Cyclic (19, 18900, 18900, 2, 1814, 0);
   C3 : Cyclic (18, 20000, 20000, 3, 162, 0);
   C4 : Cyclic (17, 25200, 25200, 4, 3921, 0);
   C5 : Cyclic (16, 28350, 28350, 5, 79680, 0);
   C6 : Cyclic (15, 42000, 42000, 6, 7172, 0);
   C7 : Cyclic (14, 47250, 47250, 7, 10444, 0);
   C8 : Cyclic (13, 52500, 52500, 8, 52511, 0);
   C9 : Cyclic (12, 56250, 56250, 9, 6272, 0);
   C10 : Cyclic (11, 60000, 60000, 10, 35675, 0);
   C11 : Cyclic (10, 60480, 60480, 11, 24071, 0);
   C12 : Cyclic (9, 65625, 65625, 12, 50806, 0);
   C13 : Cyclic (8, 67500, 67500, 13, 30847, 0);
   C14 : Cyclic (7, 70875, 70875, 14, 53559, 0);
   C15 : Cyclic (6, 72000, 72000, 15, 12678, 0);
   C16 : Cyclic (5, 75000, 75000, 16, 12826, 0);
   C17 : Cyclic (4, 81000, 81000, 17, 1147, 0);
   C18 : Cyclic (3, 90000, 90000, 18, 6039, 0);
   C19 : Cyclic (2, 90720, 90720, 19, 9639, 0);
   C20 : Cyclic (1, 100000, 100000, 20, 71834, 0);
end Cyclic_Tasks;