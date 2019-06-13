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

      procedure Gauss (Times : Integer);
      procedure Gauss (Times : Integer) is
         Num : Integer := 0;
      begin
         for I in 1 .. Times loop
            Num := Num + I;
         end loop;
      end Gauss;
      Temp : Integer;

   begin
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

   P1 : Print_Task.Print (240, -1, 5000); -- period in milliseconds
   C1 : Cyclic (33, 10000, 10000, 1, 2439);
   C2 : Cyclic (32, 11340, 11340, 2, 9088);
   C3 : Cyclic (31, 13230, 13230, 3, 10327);
   C4 : Cyclic (30, 14112, 14112, 4, 967);
   C5 : Cyclic (29, 15120, 15120, 5, 2174);
   C6 : Cyclic (28, 17280, 17280, 6, 1475);
   C7 : Cyclic (27, 24192, 24192, 7, 353);
   C8 : Cyclic (26, 36288, 36288, 8, 9734);
   C9 : Cyclic (25, 39375, 39375, 9, 7765);
   C10 : Cyclic (24, 45000, 45000, 10, 8453);
   C11 : Cyclic (23, 61250, 61250, 11, 1359);
   C12 : Cyclic (22, 189000, 189000, 12, 28814);
   C13 : Cyclic (21, 212625, 212625, 13, 58715);
   C14 : Cyclic (20, 220500, 220500, 14, 50255);
   C15 : Cyclic (19, 240000, 240000, 15, 118645);
   C16 : Cyclic (18, 254016, 254016, 16, 13154);
   C17 : Cyclic (17, 264600, 264600, 17, 38132);
   C18 : Cyclic (16, 280000, 280000, 18, 306406);
   C19 : Cyclic (15, 282240, 282240, 19, 41245);
   C20 : Cyclic (14, 294000, 294000, 20, 87431);
   C21 : Cyclic (13, 297675, 297675, 21, 224580);
   C22 : Cyclic (12, 330750, 330750, 22, 80220);
   C23 : Cyclic (11, 441000, 441000, 23, 171035);
   C24 : Cyclic (10, 470400, 470400, 24, 122488);
   C25 : Cyclic (9, 472500, 472500, 25, 306226);
   C26 : Cyclic (8, 490000, 490000, 26, 226507);
   C27 : Cyclic (7, 496125, 496125, 27, 34627);
   C28 : Cyclic (6, 508032, 508032, 28, 220239);
   C29 : Cyclic (5, 551250, 551250, 29, 51187);
   C30 : Cyclic (4, 567000, 567000, 30, 85006);
   C31 : Cyclic (3, 588000, 588000, 31, 204441);
   C32 : Cyclic (2, 607500, 607500, 32, 798);
   C33 : Cyclic (1, 635040, 635040, 33, 274906);
end Cyclic_Tasks;