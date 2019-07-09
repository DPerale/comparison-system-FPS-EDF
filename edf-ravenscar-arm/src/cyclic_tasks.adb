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
      Temp : Integer;
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
          System.BB.Time.Microseconds (Dead));
      System.BB.Threads.Set_Fake_Number_ID (T_Num);
      System.BB.Threads.Queues.Initialize_Task_Table (T_Num);

      loop
         delay until Next_Period;

         Temp := Gauss_Num;
         Gauss (Temp);

         Next_Period := Next_Period + Period;
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

   P1 : Print_Task.Print (240, -1, 1000, 0); -- period in milliseconds
   C1 : Cyclic (18, 10000, 10000, 1, 50000, 0);
   C2 : Cyclic (17, 11000, 11000, 2, 58000, 0);
--     C3 : Cyclic (16, 27000, 27000, 3, 1338);
--     C4 : Cyclic (15, 28000, 28000, 4, 15759);
--     C5 : Cyclic (14, 32000, 32000, 5, 2884);
--     C6 : Cyclic (13, 33000, 33000, 6, 7405);
--     C7 : Cyclic (12, 34000, 34000, 7, 46666);
--     C8 : Cyclic (11, 35000, 35000, 8, 8951);
--     C9 : Cyclic (10, 36000, 36000, 9, 9935);
--     C10 : Cyclic (9, 45000, 45000, 10, 17538);
--     C11 : Cyclic (8, 54000, 54000, 11, 13525);
--     C12 : Cyclic (7, 64000, 64000, 12, 5128);
--     C13 : Cyclic (6, 67000, 67000, 13, 104128);
--     C14 : Cyclic (5, 72000, 72000, 14, 14764);
--     C15 : Cyclic (4, 76000, 76000, 15, 14816);
--     C16 : Cyclic (3, 85000, 85000, 16, 17336);
--     C17 : Cyclic (2, 87000, 87000, 17, 124002);
--     C18 : Cyclic (1, 91000, 91000, 18, 52098);
end Cyclic_Tasks;
