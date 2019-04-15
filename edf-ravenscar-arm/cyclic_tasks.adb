with System.IO;
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

      type Proc_Access is access procedure (X : in out Integer);

      function Time_It (Action : Proc_Access; Arg : Integer) return Duration;
      function Time_It (Action : Proc_Access; Arg : Integer) return Duration is
         Start_Time : constant Time := Clock;
         Finis_Time : Time;
         Func_Arg : Integer := Arg;
      begin
         Action (Func_Arg);
         Finis_Time := Clock;
         return To_Duration (Finis_Time - Start_Time);
      end Time_It;

      procedure Gauss (Times : in out Integer);
      procedure Gauss (Times : in out Integer) is
         Num : Integer := 0;
      begin
         for I in 1 .. Times loop
            Num := Num + I;
         end loop;
      end Gauss;
      Gauss_Access : constant Proc_Access := Gauss'Access;
      Temp : Integer;
   begin
      System.Task_Primitives.Operations.Set_Relative_Deadline
         (System.Task_Primitives.Operations.Self,
          System.BB.Time.Microseconds (Dead));
      System.BB.Threads.Set_Fake_Number_ID (T_Num);
      System.BB.Threads.Queues.Initialize_Task_Table (T_Num);

      loop
         delay until Next_Period;

         System.IO.Put_Line ("Gauss(" & Integer'Image (Gauss_Num) & ") takes"
              & Duration'Image (Time_It (Gauss_Access, Gauss_Num))
                    & " seconds");
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
   P1 : Print_Task.Print (200, 0, 20000000);
   C1 : Cyclic (54, 36015, 36015, 1, 313);
   C2 : Cyclic (53, 36741, 36741, 2, 193);
   C3 : Cyclic (52, 55566, 55566, 3, 178);
   C4 : Cyclic (52, 55566, 55566, 4, 140);
   C5 : Cyclic (51, 58800, 58800, 5, 377);
   C6 : Cyclic (50, 59270, 59270, 6, 140);
   C7 : Cyclic (49, 63504, 63504, 7, 197);
   C8 : Cyclic (48, 64297, 64297, 8, 246);
   C9 : Cyclic (47, 68040, 68040, 9, 216);
   C10 : Cyclic (46, 70560, 70560, 10, 335);
   C11 : Cyclic (45, 76545, 76545, 11, 356);
   C12 : Cyclic (44, 77175, 77175, 12, 160);
   C13 : Cyclic (43, 79380, 79380, 13, 369);
   C14 : Cyclic (42, 81648, 81648, 14, 341);
   C15 : Cyclic (41, 86436, 86436, 15, 173);
   C16 : Cyclic (40, 94500, 94500, 16, 238);
   C17 : Cyclic (39, 102060, 102060, 17, 160);
   C18 : Cyclic (39, 102060, 102060, 18, 230);
   C19 : Cyclic (38, 112896, 112896, 19, 147);
   C20 : Cyclic (37, 126000, 126000, 20, 403);
   C21 : Cyclic (36, 130636, 130636, 21, 157);
   C22 : Cyclic (35, 134400, 134400, 22, 242);
   C23 : Cyclic (34, 138915, 138915, 23, 333);
   C24 : Cyclic (33, 518616, 518616, 24, 1175);
   C25 : Cyclic (32, 540225, 540225, 25, 1197);
   C26 : Cyclic (31, 587865, 587865, 26, 1117);
   C27 : Cyclic (30, 609638, 609638, 27, 1519);
   C28 : Cyclic (29, 694575, 694575, 28, 1776);
   C29 : Cyclic (28, 705600, 705600, 29, 925);
   C30 : Cyclic (27, 857304, 857304, 30, 2401);
   C31 : Cyclic (26, 979776, 979776, 31, 1588);
   C32 : Cyclic (25, 987840, 987840, 32, 1992);
   C33 : Cyclic (24, 1016064, 1016064, 33, 1590);
   C34 : Cyclic (23, 1111320, 1111320, 34, 1512);
   C35 : Cyclic (22, 1152480, 1152480, 35, 2039);
   C36 : Cyclic (21, 1200225, 1200225, 36, 1241);
   C37 : Cyclic (20, 1209600, 1209600, 37, 2019);
   C38 : Cyclic (19, 1224720, 1224720, 38, 1708);
   C39 : Cyclic (18, 1250235, 1250235, 39, 2250);
   C40 : Cyclic (17, 1524096, 1524096, 40, 1137);
   C41 : Cyclic (16, 4286520, 4286520, 41, 15596);
   C42 : Cyclic (15, 4500846, 4500846, 42, 10564);
   C43 : Cyclic (14, 4704000, 4704000, 43, 6574);
   C44 : Cyclic (13, 5103000, 5103000, 44, 15226);
   C45 : Cyclic (12, 5443200, 5443200, 45, 13148);
   C46 : Cyclic (11, 5740875, 5740875, 46, 7290);
   C47 : Cyclic (10, 6123600, 6123600, 47, 13499);
   C48 : Cyclic (9, 7201353, 7201353, 48, 7043);
   C49 : Cyclic (8, 7620480, 7620480, 49, 12024);
   C50 : Cyclic (8, 7620480, 7620480, 50, 11794);
   C51 : Cyclic (7, 8751645, 8751645, 51, 9809);
   C52 : Cyclic (6, 8930250, 8930250, 52, 15744);
   C53 : Cyclic (5, 9335088, 9335088, 53, 5228);
   C54 : Cyclic (4, 12446784, 12446784, 54, 9200);
   C55 : Cyclic (3, 14112000, 14112000, 55, 7127);
   C56 : Cyclic (2, 14402707, 14402707, 56, 8864);
   C57 : Cyclic (1, 14406000, 14406000, 57, 8812);
end Cyclic_Tasks;
