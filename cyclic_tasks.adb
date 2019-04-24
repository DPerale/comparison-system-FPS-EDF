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
               Ada.Real_Time.Microseconds (500000);

      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
            + System_Time.Task_Activation_Delay + Task_Static_Offset;

      Period : constant Ada.Real_Time.Time_Span :=
               Ada.Real_Time.Microseconds (Cycle_Time);

--      type Proc_Access is access procedure (X : in out Integer);

--    function Time_It (Action : Proc_Access; Arg : Integer) return Duration;
--    function Time_It (Action : Proc_Access; Arg : Integer) return Duration is
--         Start_Time : constant Time := Clock;
--         Finis_Time : Time;
--         Func_Arg : Integer := Arg;
--      begin
--         Action (Func_Arg);
--         Finis_Time := Clock;
--         return To_Duration (Finis_Time - Start_Time);
--      end Time_It;

      procedure Gauss (Times : Integer);
      procedure Gauss (Times : Integer) is
         Num : Integer := 0;
      begin
         for I in 1 .. Times loop
            Num := Num + I;
         end loop;
      end Gauss;
--    Gauss_Access : constant Proc_Access := Gauss'Access;
      Temp : Integer;

   begin
      System.Task_Primitives.Operations.Set_Relative_Deadline
         (System.Task_Primitives.Operations.Self,
          System.BB.Time.Microseconds (Dead));
      System.BB.Threads.Set_Fake_Number_ID (T_Num);
      System.BB.Threads.Queues.Initialize_Task_Table (T_Num);

      loop
         delay until Next_Period;

--       System.IO.Put_Line ("Gauss(" & Integer'Image (Gauss_Num) & ") takes"
--              & Duration'Image (Time_It (Gauss_Access, Gauss_Num))
--                    & " seconds");
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

   P1 : Print_Task.Print (240, -1905120, 1905120); -- period in milliseconds
   C1 : Cyclic (60, 10125, 10125, 1, 324);
   C2 : Cyclic (59, 10800, 10800, 2, 1692);
   C3 : Cyclic (58, 12096, 12096, 3, 576);
   C4 : Cyclic (57, 13125, 13125, 4, 468);
   C5 : Cyclic (56, 13608, 13608, 5, 2484);
   C6 : Cyclic (55, 16128, 16128, 6, 432);
   C7 : Cyclic (54, 16200, 16200, 7, 252);
   C8 : Cyclic (53, 18000, 18000, 8, 216);
   C9 : Cyclic (52, 18375, 18375, 9, 504);
   C10 : Cyclic (51, 18900, 18900, 10, 360);
   C11 : Cyclic (50, 20000, 20000, 11, 288);
   C12 : Cyclic (49, 21600, 21600, 12, 216);
   C13 : Cyclic (48, 23814, 23814, 13, 288);
   C14 : Cyclic (47, 24300, 24300, 14, 540);
   C15 : Cyclic (46, 25200, 25200, 15, 504);
   C16 : Cyclic (45, 26460, 26460, 16, 360);
   C17 : Cyclic (44, 28000, 28000, 17, 396);
   C18 : Cyclic (43, 31500, 31500, 18, 540);
   C19 : Cyclic (42, 33075, 33075, 19, 3780);
   C20 : Cyclic (41, 38880, 38880, 20, 432);
   C21 : Cyclic (40, 48384, 48384, 21, 540);
   C22 : Cyclic (39, 62720, 62720, 22, 2448);
   C23 : Cyclic (38, 67500, 67500, 23, 216);
   C24 : Cyclic (37, 78400, 78400, 24, 504);
   C25 : Cyclic (36, 212625, 212625, 25, 3420);
   C26 : Cyclic (35, 216000, 216000, 26, 3132);
   C27 : Cyclic (34, 217728, 217728, 27, 3672);
   C28 : Cyclic (33, 224000, 224000, 28, 3132);
   C29 : Cyclic (32, 226800, 226800, 29, 2808);
   C30 : Cyclic (31, 236250, 236250, 30, 2628);
   C31 : Cyclic (30, 238140, 238140, 31, 2160);
   C32 : Cyclic (29, 259200, 259200, 32, 1944);
   C33 : Cyclic (28, 280000, 280000, 33, 2088);
   C34 : Cyclic (27, 283500, 283500, 34, 3348);
   C35 : Cyclic (26, 288000, 288000, 35, 3240);
   C36 : Cyclic (25, 317520, 317520, 36, 2412);
   C37 : Cyclic (24, 324000, 324000, 37, 3204);
   C38 : Cyclic (23, 336000, 336000, 38, 2844);
   C39 : Cyclic (22, 338688, 338688, 39, 2700);
   C40 : Cyclic (21, 352800, 352800, 40, 2772);
   C41 : Cyclic (20, 420000, 420000, 41, 22680);
   C42 : Cyclic (19, 432000, 432000, 42, 18864);
   C43 : Cyclic (18, 453600, 453600, 43, 24624);
   C44 : Cyclic (17, 470400, 470400, 44, 23004);
   C45 : Cyclic (16, 476280, 476280, 45, 16200);
   C46 : Cyclic (15, 480000, 480000, 46, 14904);
   C47 : Cyclic (14, 504000, 504000, 47, 10728);
   C48 : Cyclic (13, 518400, 518400, 48, 20592);
   C49 : Cyclic (12, 540000, 540000, 49, 24228);
   C50 : Cyclic (11, 544320, 544320, 50, 24336);
   C51 : Cyclic (10, 560000, 560000, 51, 14220);
   C52 : Cyclic (9, 564480, 564480, 52, 9576);
   C53 : Cyclic (8, 567000, 567000, 53, 19944);
   C54 : Cyclic (7, 588000, 588000, 54, 16740);
   C55 : Cyclic (6, 595350, 595350, 55, 15192);
   C56 : Cyclic (5, 604800, 604800, 56, 18396);
   C57 : Cyclic (4, 607500, 607500, 57, 21744);
   C58 : Cyclic (3, 630000, 630000, 58, 11664);
   C59 : Cyclic (2, 661500, 661500, 59, 21132);
   C60 : Cyclic (1, 672000, 672000, 60, 22464);
end Cyclic_Tasks;
