with Ada.Real_Time; use Ada.Real_Time;
with System_Time;
with System.Task_Primitives.Operations;
with System.BB.Time;
with System.BB.Threads;
with System.BB.Threads.Queues;
--  with Print_Task;

package body Cyclic_Tasks is

   task body Cyclic is
      Task_Static_Offset : constant Time_Span :=
               Ada.Real_Time.Microseconds (1000000);

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

   --  P1 : Print_Task.Print (240, -1, 1000); -- period in milliseconds
   C1 : Cyclic (30, 10000, 10000, 1, 90000);
--     C2 : Cyclic (29, 14112, 14112, 2, 2513);
--     C3 : Cyclic (28, 15120, 15120, 3, 12900);
--     C4 : Cyclic (27, 16000, 16000, 4, 3985);
--     C5 : Cyclic (26, 17280, 17280, 5, 2238);
--     C6 : Cyclic (25, 21168, 21168, 6, 16447);
--     C7 : Cyclic (24, 39375, 39375, 7, 5869);
--     C8 : Cyclic (23, 42000, 42000, 8, 1084);
--     C9 : Cyclic (22, 52500, 52500, 9, 5044);
--     C10 : Cyclic (21, 61250, 61250, 10, 33462);
--     C11 : Cyclic (20, 194400, 194400, 11, 46539);
--     C12 : Cyclic (19, 211680, 211680, 12, 126829);
--     C13 : Cyclic (18, 212625, 212625, 13, 222399);
--     C14 : Cyclic (17, 217728, 217728, 14, 38439);
--     C15 : Cyclic (16, 220500, 220500, 15, 42039);
--     C16 : Cyclic (15, 226800, 226800, 16, 46031);
--     C17 : Cyclic (14, 272160, 272160, 17, 73009);
--     C18 : Cyclic (13, 282240, 282240, 18, 15791);
--     C19 : Cyclic (12, 302400, 302400, 19, 173651);
--     C20 : Cyclic (11, 340200, 340200, 20, 114261);
--     C21 : Cyclic (10, 486000, 486000, 21, 84667);
--     C22 : Cyclic (9, 490000, 490000, 22, 35019);
--     C23 : Cyclic (8, 508032, 508032, 23, 291466);
--     C24 : Cyclic (7, 529200, 529200, 24, 163549);
--     C25 : Cyclic (6, 540000, 540000, 25, 102095);
--     C26 : Cyclic (5, 551250, 551250, 26, 189893);
--     C27 : Cyclic (4, 567000, 567000, 27, 216967);
--     C28 : Cyclic (3, 630000, 630000, 28, 222409);
--     C29 : Cyclic (2, 648000, 648000, 29, 237191);
--     C30 : Cyclic (1, 661500, 661500, 30, 530940);
   --  C2 : Cyclic (4, 10000, 10000, 1, 10000);
   --  C2 : Cyclic (3, 100000, 100000, 2, 10);
end Cyclic_Tasks;
