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
   C1 : Cyclic (30, 10000, 10000, 1, 72);
   C2 : Cyclic (29, 14112, 14112, 2, 8604);
   C3 : Cyclic (28, 15120, 15120, 3, 43920);
   C4 : Cyclic (27, 16000, 16000, 4, 13608);
   C5 : Cyclic (26, 17280, 17280, 5, 7668);
   C6 : Cyclic (25, 21168, 21168, 6, 55980);
   C7 : Cyclic (24, 39375, 39375, 7, 20016);
   C8 : Cyclic (23, 42000, 42000, 8, 3744);
   C9 : Cyclic (22, 52500, 52500, 9, 17208);
   C10 : Cyclic (21, 61250, 61250, 10, 113832);
   C11 : Cyclic (20, 194400, 194400, 11, 158292);
   C12 : Cyclic (19, 211680, 211680, 12, 431280);
   C13 : Cyclic (18, 212625, 212625, 13, 756216);
   C14 : Cyclic (17, 217728, 217728, 14, 130752);
   C15 : Cyclic (16, 220500, 220500, 15, 142992);
   C16 : Cyclic (15, 226800, 226800, 16, 156564);
   C17 : Cyclic (14, 272160, 272160, 17, 248292);
   C18 : Cyclic (13, 282240, 282240, 18, 53748);
   C19 : Cyclic (12, 302400, 302400, 19, 590472);
   C20 : Cyclic (11, 340200, 340200, 20, 388548);
   C21 : Cyclic (10, 486000, 486000, 21, 287928);
   C22 : Cyclic (9, 490000, 490000, 22, 119124);
   C23 : Cyclic (8, 508032, 508032, 23, 991044);
   C24 : Cyclic (7, 529200, 529200, 24, 556128);
   C25 : Cyclic (6, 540000, 540000, 25, 347184);
   C26 : Cyclic (5, 551250, 551250, 26, 645696);
   C27 : Cyclic (4, 567000, 567000, 27, 737748);
   C28 : Cyclic (3, 630000, 630000, 28, 756252);
   C29 : Cyclic (2, 648000, 648000, 29, 806508);
   C30 : Cyclic (1, 661500, 661500, 30, 1805256);
end Cyclic_Tasks;
