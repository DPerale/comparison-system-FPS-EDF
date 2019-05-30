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
   C1 : Cyclic (36, 10584, 10584, 1, 24768);
   C2 : Cyclic (35, 12150, 12150, 2, 2484);
   C3 : Cyclic (34, 18375, 18375, 3, 15552);
   C4 : Cyclic (33, 22680, 22680, 4, 8100);
   C5 : Cyclic (32, 28224, 28224, 5, 2340);
   C6 : Cyclic (31, 31500, 31500, 6, 19620);
   C7 : Cyclic (30, 42000, 42000, 7, 9216);
   C8 : Cyclic (29, 45000, 45000, 8, 21276);
   C9 : Cyclic (28, 48000, 48000, 9, 129456);
   C10 : Cyclic (27, 59535, 59535, 10, 10908);
   C11 : Cyclic (26, 77760, 77760, 11, 77940);
   C12 : Cyclic (25, 79380, 79380, 12, 56268);
   C13 : Cyclic (24, 189000, 189000, 13, 31176);
   C14 : Cyclic (23, 190512, 190512, 14, 252648);
   C15 : Cyclic (22, 198450, 198450, 15, 187596);
   C16 : Cyclic (21, 202500, 202500, 16, 159696);
   C17 : Cyclic (20, 212625, 212625, 17, 328356);
   C18 : Cyclic (19, 220500, 220500, 18, 218592);
   C19 : Cyclic (18, 226800, 226800, 19, 923688);
   C20 : Cyclic (17, 254016, 254016, 20, 349668);
   C21 : Cyclic (16, 302400, 302400, 21, 92340);
   C22 : Cyclic (15, 317520, 317520, 22, 26928);
   C23 : Cyclic (14, 340200, 340200, 23, 154008);
   C24 : Cyclic (13, 352800, 352800, 24, 21168);
   C25 : Cyclic (12, 423360, 423360, 25, 640944);
   C26 : Cyclic (11, 472500, 472500, 26, 638820);
   C27 : Cyclic (10, 490000, 490000, 27, 24444);
   C28 : Cyclic (9, 504000, 504000, 28, 32904);
   C29 : Cyclic (8, 508032, 508032, 29, 1098540);
   C30 : Cyclic (7, 529200, 529200, 30, 1164456);
   C31 : Cyclic (6, 540000, 540000, 31, 194724);
   C32 : Cyclic (5, 560000, 560000, 32, 7740);
   C33 : Cyclic (4, 567000, 567000, 33, 761832);
   C34 : Cyclic (3, 604800, 604800, 34, 695124);
   C35 : Cyclic (2, 635040, 635040, 35, 104544);
   C36 : Cyclic (1, 680400, 680400, 36, 113544);
end Cyclic_Tasks;
