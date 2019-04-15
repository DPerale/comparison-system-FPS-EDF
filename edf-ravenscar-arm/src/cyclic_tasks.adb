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

   P1 : Print_Task.Print (255, -1, 1200000000); -- period in milliseconds
   C1 : Cyclic (59, 10937, 10937, 1, 6300);
   C2 : Cyclic (58, 12250, 12250, 2, 4572);
   C3 : Cyclic (58, 12250, 12250, 3, 4608);
   C4 : Cyclic (57, 12500, 12500, 4, 4320);
   C5 : Cyclic (56, 15435, 15435, 5, 6228);
   C6 : Cyclic (55, 17500, 17500, 6, 2448);
   C7 : Cyclic (54, 19136, 19136, 7, 5976);
   C8 : Cyclic (53, 19600, 19600, 8, 5400);
   C9 : Cyclic (52, 22968, 22968, 9, 5580);
   C10 : Cyclic (51, 23152, 23152, 10, 6012);
   C11 : Cyclic (50, 24000, 24000, 11, 4824);
   C12 : Cyclic (49, 25920, 25920, 12, 5652);
   C13 : Cyclic (48, 28125, 28125, 13, 2916);
   C14 : Cyclic (48, 28125, 28125, 14, 2304);
   C15 : Cyclic (47, 30000, 30000, 15, 5688);
   C16 : Cyclic (46, 30870, 30870, 16, 4104);
   C17 : Cyclic (45, 33075, 33075, 17, 5220);
   C18 : Cyclic (44, 33600, 33600, 18, 2880);
   C19 : Cyclic (43, 37500, 37500, 19, 5148);
   C20 : Cyclic (42, 38880, 38880, 20, 3816);
   C21 : Cyclic (41, 41160, 41160, 21, 6300);
   C22 : Cyclic (40, 42875, 42875, 22, 4392);
   C23 : Cyclic (39, 153090, 153090, 23, 34416);
   C24 : Cyclic (38, 178605, 178605, 24, 38232);
   C25 : Cyclic (37, 194400, 194400, 25, 18180);
   C26 : Cyclic (36, 204120, 204120, 26, 17856);
   C27 : Cyclic (35, 225000, 225000, 27, 31356);
   C28 : Cyclic (34, 229687, 229687, 28, 20088);
   C29 : Cyclic (33, 233280, 233280, 29, 33408);
   C30 : Cyclic (32, 238140, 238140, 30, 20268);
   C31 : Cyclic (31, 262500, 262500, 31, 15156);
   C32 : Cyclic (30, 264600, 264600, 32, 22752);
   C33 : Cyclic (29, 272160, 272160, 33, 24480);
   C34 : Cyclic (28, 273375, 273375, 34, 27720);
   C35 : Cyclic (27, 280000, 280000, 35, 21744);
   C36 : Cyclic (26, 303750, 303750, 36, 21348);
   C37 : Cyclic (25, 306250, 306250, 37, 20412);
   C38 : Cyclic (24, 330750, 330750, 38, 15588);
   C39 : Cyclic (23, 340200, 340200, 39, 22680);
   C40 : Cyclic (22, 357210, 357210, 40, 37944);
   C41 : Cyclic (21, 364500, 364500, 41, 15156);
   C42 : Cyclic (20, 392000, 392000, 42, 24300);
   C43 : Cyclic (19, 1417500, 1417500, 43, 216504);
   C44 : Cyclic (18, 1428840, 1428840, 44, 118116);
   C45 : Cyclic (17, 1632960, 1632960, 45, 149580);
   C46 : Cyclic (16, 1666980, 1666980, 46, 136008);
   C47 : Cyclic (15, 1890000, 1890000, 47, 184932);
   C48 : Cyclic (14, 1960000, 1960000, 48, 98100);
   C49 : Cyclic (13, 2126250, 2126250, 49, 238860);
   C50 : Cyclic (12, 2362500, 2362500, 50, 196992);
   C51 : Cyclic (11, 2392031, 2392031, 51, 169812);
   C52 : Cyclic (10, 2733750, 2733750, 52, 112356);
   C53 : Cyclic (9, 2756250, 2756250, 53, 247824);
   C54 : Cyclic (8, 3215625, 3215625, 54, 244512);
   C55 : Cyclic (7, 3333960, 3333960, 55, 153144);
   C56 : Cyclic (6, 3645000, 3645000, 56, 226332);
   C57 : Cyclic (6, 3645000, 3645000, 57, 118476);
   C58 : Cyclic (5, 3675000, 3675000, 58, 122184);
   C59 : Cyclic (4, 3704400, 3704400, 59, 241632);
   C60 : Cyclic (3, 4167450, 4167450, 60, 190476);
   C61 : Cyclic (2, 4374000, 4374000, 61, 83520);
   C62 : Cyclic (1, 4410000, 4410000, 62, 174312);
end Cyclic_Tasks;
