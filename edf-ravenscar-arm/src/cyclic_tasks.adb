with Ada.Real_Time; use Ada.Real_Time;
with System_Time;
with System.Task_Primitives.Operations;
with System.BB.Time;
with System.BB.Threads;
with System.BB.Threads.Queues;
with Log_Reporter_Task;

package body Cyclic_Tasks is

   task body Cyclic is
      Task_Static_Offset : constant Time_Span :=
               Ada.Real_Time.Microseconds (Offset);

      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
            + System_Time.Task_Activation_Delay + Task_Static_Offset;

      Period_To_Add : constant Ada.Real_Time.Time_Span :=
               Ada.Real_Time.Microseconds (Period);

      procedure Job (Times : Integer);
      procedure Job (Times : Integer) is
         Num : Integer := 0;
      begin
         for I in 1 .. Times loop
            Num := Num + I;
         end loop;
      end Job;
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

      My_Workload : constant Integer := Workload;
      Synchronization : Ada.Real_Time.Time_Span;

   begin
      Synchronization := Next_Period - Ada.Real_Time.Time_First;
      Synchronization := (Synchronization / 180000) * 180000;
      Synchronization := Synchronization - Ada.Real_Time.Microseconds (73);
      Next_Period := Ada.Real_Time.Time_First + Synchronization;
      System.Task_Primitives.Operations.Set_Period
         (System.Task_Primitives.Operations.Self,
         System.BB.Time.Microseconds (Period));
      System.Task_Primitives.Operations.Set_Starting_Time
        (System.Task_Primitives.Operations.Self,
          Time_Conversion (Next_Period));
      System.Task_Primitives.Operations.Set_Relative_Deadline
         (System.Task_Primitives.Operations.Self,
          System.BB.Time.Microseconds (Deadline), False);
      System.BB.Threads.Set_Fake_Number_ID (T_Num);
      System.BB.Threads.Queues.Initialize_Log_Table (T_Num);

      loop
         delay until Next_Period;

         Job (My_Workload);

         Next_Period := Next_Period + Period_To_Add;
      end loop;
   end Cyclic;

   procedure Init is
   begin
      System.Task_Primitives.Operations.Set_Relative_Deadline
        (System.Task_Primitives.Operations.Self,
          System.BB.Time.Milliseconds (Integer'Last), False);
      loop
         null;
      end loop;
   end Init;

   P1 : Log_Reporter_Task.Log_Reporter (240, -1, 113400, 0); -- milliseconds
   C1 : Cyclic (20, 10000, 10000, 1, 3074, 0);
   C2 : Cyclic (19, 18900, 18900, 2, 13916, 0);
   C3 : Cyclic (18, 26250, 26250, 3, 3466, 0);
   C4 : Cyclic (17, 30240, 30240, 4, 5329, 0);
   C5 : Cyclic (16, 45360, 45360, 5, 66169, 0);
   C6 : Cyclic (15, 50000, 50000, 6, 2047, 0);
   C7 : Cyclic (14, 52500, 52500, 7, 1931, 0);
   C8 : Cyclic (13, 60480, 60480, 8, 12540, 0);
   C9 : Cyclic (12, 72000, 72000, 9, 85832, 0);
   C10 : Cyclic (11, 75000, 75000, 10, 29524, 0);
   C11 : Cyclic (10, 75600, 75600, 11, 30042, 0);
   C12 : Cyclic (9, 78750, 78750, 12, 9533, 0);
   C13 : Cyclic (8, 100000, 100000, 13, 11767, 0);
   C14 : Cyclic (7, 100800, 100800, 14, 27268, 0);
   C15 : Cyclic (6, 105000, 105000, 15, 90628, 0);
   C16 : Cyclic (5, 150000, 150000, 16, 15558, 0);
   C17 : Cyclic (4, 168750, 168750, 17, 151913, 0);
   C18 : Cyclic (3, 180000, 180000, 18, 125940, 0);
   C19 : Cyclic (2, 450000, 450000, 19, 452661, 0);
   C20 : Cyclic (1, 648000, 648000, 20, 150155, 0);
end Cyclic_Tasks;
