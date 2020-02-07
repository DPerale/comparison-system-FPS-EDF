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
               Ada.Real_Time.Microseconds (Offset);

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
      function Time_Conversion (Time_in  : Ada.Real_Time.Time)
                                return System.BB.Time.Time_Span;
      function Time_Conversion (Time_in  : Ada.Real_Time.Time)
                                return System.BB.Time.Time_Span is
         Time_in_to_Time_Span : Ada.Real_Time.Time_Span;
         Time_out : System.BB.Time.Time_Span;
      begin
         Time_in_to_Time_Span := Time_in - Ada.Real_Time.Time_First;
         Time_out := System.BB.Time.To_Time_Span
           (Ada.Real_Time.To_Duration (Time_in_to_Time_Span));
         return Time_out;
      end Time_Conversion;

      Temp : Integer;
      Work_Jitter : Ada.Real_Time.Time;
      Release_Jitter : Ada.Real_Time.Time;

   begin
      System.Task_Primitives.Operations.Set_Period
         (System.Task_Primitives.Operations.Self,
         System.BB.Time.Microseconds (Cycle_Time));
      System.Task_Primitives.Operations.Set_Starting_Time
        (System.Task_Primitives.Operations.Self,
          Time_Conversion (Next_Period));
      System.Task_Primitives.Operations.Set_Relative_Deadline
         (System.Task_Primitives.Operations.Self,
          System.BB.Time.Microseconds (Dead));
      System.BB.Threads.Set_Fake_Number_ID (T_Num);
      System.BB.Threads.Queues.Initialize_Task_Table (T_Num);

      loop
         delay until Next_Period;

         Release_Jitter := Ada.Real_Time.Time_First +
           (Ada.Real_Time.Clock - Next_Period);

         Temp := Gauss_Num;
         Gauss (Temp);

         Work_Jitter := Ada.Real_Time.Time_First +
           (Ada.Real_Time.Clock - (Release_Jitter
            + (Next_Period - Ada.Real_Time.Time_First)));

         Next_Period := Next_Period + Period;
         System.Task_Primitives.Operations.Set_Jitters
           (System.Task_Primitives.Operations.Self,
           Time_Conversion (Work_Jitter), Time_Conversion (Release_Jitter));
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

   P1 : Print_Task.Print (240, -1, 113430, 0); -- period in milliseconds
   C1 : Cyclic (20, 18900, 18900, 1, 21466, 0);
   C2 : Cyclic (19, 22500, 22500, 2, 3794, 0);
   C3 : Cyclic (18, 25200, 25200, 3, 10835, 0);
   C4 : Cyclic (17, 26250, 26250, 4, 19719, 0);
   C5 : Cyclic (16, 28350, 28350, 5, 11545, 0);
   C6 : Cyclic (15, 30240, 30240, 6, 1359, 0);
   C7 : Cyclic (14, 39375, 39375, 7, 14774, 0);
   C8 : Cyclic (13, 40000, 40000, 8, 47502, 0);
   C9 : Cyclic (12, 47250, 47250, 9, 21942, 0);
   C10 : Cyclic (11, 50400, 50400, 10, 47767, 0);
   C11 : Cyclic (10, 52500, 52500, 11, 15409, 0);
   C12 : Cyclic (9, 54000, 54000, 12, 14795, 0);
   C13 : Cyclic (8, 56700, 56700, 13, 268, 0);
   C14 : Cyclic (7, 63000, 63000, 14, 109274, 0);
   C15 : Cyclic (6, 75000, 75000, 15, 108882, 0);
   C16 : Cyclic (5, 78750, 78750, 16, 11820, 0);
   C17 : Cyclic (4, 84000, 84000, 17, 7309, 0);
   C18 : Cyclic (3, 87500, 87500, 18, 27554, 0);
   C19 : Cyclic (2, 90720, 90720, 19, 1782, 0);
   C20 : Cyclic (1, 94500, 94500, 20, 4609, 0);
end Cyclic_Tasks;