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
   C1 : Cyclic (30, 16000, 16000, 1, 7272);
   C2 : Cyclic (29, 18375, 18375, 2, 2556);
   C3 : Cyclic (28, 21168, 21168, 3, 82980);
   C4 : Cyclic (27, 28224, 28224, 4, 4392);
   C5 : Cyclic (26, 31500, 31500, 5, 39924);
   C6 : Cyclic (25, 33750, 33750, 6, 25128);
   C7 : Cyclic (24, 55125, 55125, 7, 29484);
   C8 : Cyclic (23, 61250, 61250, 8, 9432);
   C9 : Cyclic (22, 70875, 70875, 9, 180684);
   C10 : Cyclic (21, 77760, 77760, 10, 22536);
   C11 : Cyclic (20, 189000, 189000, 11, 223632);
   C12 : Cyclic (19, 194400, 194400, 12, 191052);
   C13 : Cyclic (18, 202500, 202500, 13, 428256);
   C14 : Cyclic (17, 211680, 211680, 14, 386388);
   C15 : Cyclic (16, 236250, 236250, 15, 148968);
   C16 : Cyclic (15, 240000, 240000, 16, 1764);
   C17 : Cyclic (14, 243000, 243000, 17, 67248);
   C18 : Cyclic (13, 252000, 252000, 18, 348444);
   C19 : Cyclic (12, 280000, 280000, 19, 752940);
   C20 : Cyclic (11, 317520, 317520, 20, 448308);
   C21 : Cyclic (10, 432000, 432000, 21, 2177532);
   C22 : Cyclic (9, 453600, 453600, 22, 410796);
   C23 : Cyclic (8, 470400, 470400, 23, 6732);
   C24 : Cyclic (7, 476280, 476280, 24, 667044);
   C25 : Cyclic (6, 486000, 486000, 25, 879120);
   C26 : Cyclic (5, 490000, 490000, 26, 68364);
   C27 : Cyclic (4, 496125, 496125, 27, 400320);
   C28 : Cyclic (3, 529200, 529200, 28, 82692);
   C29 : Cyclic (2, 544320, 544320, 29, 270252);
   C30 : Cyclic (1, 635040, 635040, 30, 371880);
end Cyclic_Tasks;
