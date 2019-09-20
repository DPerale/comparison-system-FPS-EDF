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

   P1 : Print_Task.Print (240, -1, 113400, 0); -- period in milliseconds
   C1 : Cyclic (20, 10000, 10000, 1, 7479, 0);
   C2 : Cyclic (19, 18900, 18900, 2, 7405, 0);
   C3 : Cyclic (18, 28350, 28350, 3, 1507, 0);
   C4 : Cyclic (17, 33750, 33750, 4, 1592, 0);
   C5 : Cyclic (16, 35000, 35000, 5, 2301, 0);
   C6 : Cyclic (15, 39375, 39375, 6, 2036, 0);
   C7 : Cyclic (14, 40000, 40000, 7, 42759, 0);
   C8 : Cyclic (13, 45360, 45360, 8, 2375, 0);
   C9 : Cyclic (12, 52500, 52500, 9, 5361, 0);
   C10 : Cyclic (11, 56250, 56250, 10, 11333, 0);
   C11 : Cyclic (10, 56700, 56700, 11, 1518, 0);
   C12 : Cyclic (9, 65625, 65625, 12, 131785, 0);
   C13 : Cyclic (8, 70875, 70875, 13, 21064, 0);
   C14 : Cyclic (7, 72000, 72000, 14, 37719, 0);
   C15 : Cyclic (6, 75000, 75000, 15, 39646, 0);
   C16 : Cyclic (5, 75600, 75600, 16, 53474, 0);
   C17 : Cyclic (4, 81000, 81000, 17, 5816, 0);
   C18 : Cyclic (3, 84000, 84000, 18, 138159, 0);
   C19 : Cyclic (2, 84375, 84375, 19, 32531, 0);
   C20 : Cyclic (1, 94500, 94500, 20, 31493, 0);
end Cyclic_Tasks;