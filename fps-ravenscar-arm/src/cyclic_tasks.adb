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
   C1 : Cyclic (20, 35000, 35000, 1, 914, 0);
   C2 : Cyclic (19, 37800, 37800, 2, 20365, 0);
   C3 : Cyclic (18, 54000, 54000, 3, 83428, 0);
   C4 : Cyclic (17, 63000, 63000, 4, 58207, 0);
   C5 : Cyclic (16, 70875, 70875, 5, 6822, 0);
   C6 : Cyclic (15, 72000, 72000, 6, 20344, 0);
   C7 : Cyclic (14, 84000, 84000, 7, 122308, 0);
   C8 : Cyclic (13, 94500, 94500, 8, 17961, 0);
   C9 : Cyclic (12, 100000, 100000, 9, 32996, 0);
   C10 : Cyclic (11, 100800, 100800, 10, 71347, 0);
   C11 : Cyclic (10, 101250, 101250, 11, 59689, 0);
   C12 : Cyclic (9, 112500, 112500, 12, 81025, 0);
   C13 : Cyclic (8, 118125, 118125, 13, 30985, 0);
   C14 : Cyclic (7, 135000, 135000, 14, 82602, 0);
   C15 : Cyclic (6, 162000, 162000, 15, 11725, 0);
   C16 : Cyclic (5, 168750, 168750, 16, 28454, 0);
   C17 : Cyclic (4, 175000, 175000, 17, 63787, 0);
   C18 : Cyclic (3, 180000, 180000, 18, 46158, 0);
   C19 : Cyclic (2, 181440, 181440, 19, 26591, 0);
   C20 : Cyclic (1, 525000, 525000, 20, 73052, 0);
end Cyclic_Tasks;