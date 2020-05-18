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
   C1 : Cyclic (20, 15750, 15750, 1, 8633, 0);
   C2 : Cyclic (19, 20000, 20000, 2, 48858, 0);
   C3 : Cyclic (18, 22500, 22500, 3, 6092, 0);
   C4 : Cyclic (17, 25200, 25200, 4, 4715, 0);
   C5 : Cyclic (16, 26250, 26250, 5, 9067, 0);
   C6 : Cyclic (15, 28350, 28350, 6, 16765, 0);
   C7 : Cyclic (14, 33750, 33750, 7, 2396, 0);
   C8 : Cyclic (13, 39375, 39375, 8, 10909, 0);
   C9 : Cyclic (12, 40000, 40000, 9, 55613, 0);
   C10 : Cyclic (11, 50400, 50400, 10, 20778, 0);
   C11 : Cyclic (10, 52500, 52500, 11, 3889, 0);
   C12 : Cyclic (9, 56250, 56250, 12, 24960, 0);
   C13 : Cyclic (8, 56700, 56700, 13, 2704, 0);
   C14 : Cyclic (7, 60480, 60480, 14, 10984, 0);
   C15 : Cyclic (6, 64800, 64800, 15, 9395, 0);
   C16 : Cyclic (5, 70000, 70000, 16, 27533, 0);
   C17 : Cyclic (4, 72000, 72000, 17, 109984, 0);
   C18 : Cyclic (3, 75600, 75600, 18, 11036, 0);
   C19 : Cyclic (2, 78750, 78750, 19, 71315, 0);
   C20 : Cyclic (1, 90720, 90720, 20, 1496, 0);
end Cyclic_Tasks;