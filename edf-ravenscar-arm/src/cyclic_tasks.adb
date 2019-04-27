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

   P1 : Print_Task.Print (240, -1, 952560); -- period in milliseconds
   C1 : Cyclic (52, 12250, 12250, 1, 6732);
   C2 : Cyclic (51, 14400, 14400, 2, 5508);
   C3 : Cyclic (50, 15680, 15680, 3, 6552);
   C4 : Cyclic (49, 16875, 16875, 4, 4572);
   C5 : Cyclic (48, 17010, 17010, 5, 6336);
   C6 : Cyclic (47, 17280, 17280, 6, 7524);
   C7 : Cyclic (46, 18900, 18900, 7, 7128);
   C8 : Cyclic (45, 22500, 22500, 8, 7164);
   C9 : Cyclic (44, 28224, 28224, 9, 6156);
   C10 : Cyclic (43, 28350, 28350, 10, 6120);
   C11 : Cyclic (42, 30375, 30375, 11, 4824);
   C12 : Cyclic (41, 33075, 33075, 12, 6444);
   C13 : Cyclic (40, 38880, 38880, 13, 7452);
   C14 : Cyclic (39, 44100, 44100, 14, 6444);
   C15 : Cyclic (38, 48600, 48600, 15, 4752);
   C16 : Cyclic (37, 56448, 56448, 16, 6048);
   C17 : Cyclic (36, 63504, 63504, 17, 5508);
   C18 : Cyclic (35, 78400, 78400, 18, 7128);
   C19 : Cyclic (34, 190512, 190512, 19, 112752);
   C20 : Cyclic (33, 216000, 216000, 20, 81648);
   C21 : Cyclic (32, 235200, 235200, 21, 116676);
   C22 : Cyclic (31, 236250, 236250, 22, 107100);
   C23 : Cyclic (30, 238140, 238140, 23, 83052);
   C24 : Cyclic (29, 245000, 245000, 24, 124308);
   C25 : Cyclic (28, 252000, 252000, 25, 109620);
   C26 : Cyclic (27, 254016, 254016, 26, 111024);
   C27 : Cyclic (26, 272160, 272160, 27, 134352);
   C28 : Cyclic (25, 275625, 275625, 28, 102456);
   C29 : Cyclic (24, 280000, 280000, 29, 116892);
   C30 : Cyclic (23, 297675, 297675, 30, 115308);
   C31 : Cyclic (22, 302400, 302400, 31, 117504);
   C32 : Cyclic (21, 317520, 317520, 32, 105660);
   C33 : Cyclic (20, 336000, 336000, 33, 137052);
   C34 : Cyclic (19, 340200, 340200, 34, 136512);
   C35 : Cyclic (18, 354375, 354375, 35, 135612);
   C36 : Cyclic (17, 423360, 423360, 36, 251316);
   C37 : Cyclic (16, 425250, 425250, 37, 233820);
   C38 : Cyclic (15, 432000, 432000, 38, 220140);
   C39 : Cyclic (14, 470400, 470400, 39, 209556);
   C40 : Cyclic (13, 472500, 472500, 40, 255312);
   C41 : Cyclic (12, 476280, 476280, 41, 224712);
   C42 : Cyclic (11, 486000, 486000, 42, 234828);
   C43 : Cyclic (10, 529200, 529200, 43, 232488);
   C44 : Cyclic (9, 540000, 540000, 44, 249480);
   C45 : Cyclic (8, 551250, 551250, 45, 228888);
   C46 : Cyclic (7, 560000, 560000, 46, 230832);
   C47 : Cyclic (6, 567000, 567000, 47, 211500);
   C48 : Cyclic (5, 595350, 595350, 48, 204984);
   C49 : Cyclic (4, 604800, 604800, 49, 215532);
   C50 : Cyclic (3, 607500, 607500, 50, 190764);
   C51 : Cyclic (2, 648000, 648000, 51, 204984);
   C52 : Cyclic (1, 661500, 661500, 52, 201816);
end Cyclic_Tasks;
