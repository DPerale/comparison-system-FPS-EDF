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
   C1 : Cyclic (30, 11340, 11340, 1, 1116);
   C2 : Cyclic (29, 12150, 12150, 2, 3636);
   C3 : Cyclic (28, 14112, 14112, 3, 45360);
   C4 : Cyclic (27, 15120, 15120, 4, 9864);
   C5 : Cyclic (26, 18375, 18375, 5, 18972);
   C6 : Cyclic (25, 21168, 21168, 6, 5904);
   C7 : Cyclic (24, 39375, 39375, 7, 24516);
   C8 : Cyclic (23, 42000, 42000, 8, 88560);
   C9 : Cyclic (22, 52500, 52500, 9, 46584);
   C10 : Cyclic (21, 77760, 77760, 10, 59400);
   C11 : Cyclic (20, 194400, 194400, 11, 295164);
   C12 : Cyclic (19, 198450, 198450, 12, 104148);
   C13 : Cyclic (18, 201600, 201600, 13, 537552);
   C14 : Cyclic (17, 238140, 238140, 14, 31356);
   C15 : Cyclic (16, 252000, 252000, 15, 108);
   C16 : Cyclic (15, 264600, 264600, 16, 226044);
   C17 : Cyclic (14, 297675, 297675, 17, 471960);
   C18 : Cyclic (13, 302400, 302400, 18, 172980);
   C19 : Cyclic (12, 303750, 303750, 19, 341532);
   C20 : Cyclic (11, 330750, 330750, 20, 21456);
   C21 : Cyclic (10, 423360, 423360, 21, 110700);
   C22 : Cyclic (9, 508032, 508032, 22, 1453104);
   C23 : Cyclic (8, 529200, 529200, 23, 4009032);
   C24 : Cyclic (7, 544320, 544320, 24, 678132);
   C25 : Cyclic (6, 567000, 567000, 25, 43920);
   C26 : Cyclic (5, 588000, 588000, 26, 453960);
   C27 : Cyclic (4, 604800, 604800, 27, 678060);
   C28 : Cyclic (3, 630000, 630000, 28, 934740);
   C29 : Cyclic (2, 648000, 648000, 29, 1287648);
   C30 : Cyclic (1, 661500, 661500, 30, 217116);
end Cyclic_Tasks;
