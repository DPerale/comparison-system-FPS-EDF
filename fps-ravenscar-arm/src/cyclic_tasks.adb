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

   P1 : Print_Task.Print (240, -1, 1000, 0); -- period in milliseconds
   C1 : Cyclic (20, 10000, 10000, 1, 5478, 0);
   C2 : Cyclic (19, 12000, 12000, 2, 1496, 0);
   C3 : Cyclic (18, 15000, 15000, 3, 9724, 0);
   C4 : Cyclic (17, 16000, 16000, 4, 6314, 0);
   C5 : Cyclic (16, 17000, 17000, 5, 5584, 0);
   C6 : Cyclic (15, 21000, 21000, 6, 925, 0);
   C7 : Cyclic (14, 24000, 24000, 7, 15484, 0);
   C8 : Cyclic (13, 26000, 26000, 8, 16098, 0);
   C9 : Cyclic (12, 27000, 27000, 9, 33060, 0);
   C10 : Cyclic (11, 37000, 37000, 10, 10062, 0);
   C11 : Cyclic (10, 38000, 38000, 11, 20121, 0);
   C12 : Cyclic (9, 49000, 49000, 12, 17569, 0);
   C13 : Cyclic (8, 54000, 54000, 13, 20153, 0);
   C14 : Cyclic (7, 57000, 57000, 14, 12964, 0);
   C15 : Cyclic (6, 61000, 61000, 15, 31324, 0);
   C16 : Cyclic (5, 64000, 64000, 16, 72607, 0);
   C17 : Cyclic (4, 68000, 68000, 17, 5764, 0);
   C18 : Cyclic (3, 73000, 73000, 18, 51865, 0);
   C19 : Cyclic (2, 80000, 80000, 19, 10433, 0);
   C20 : Cyclic (1, 92000, 92000, 20, 26718, 0);
end Cyclic_Tasks;