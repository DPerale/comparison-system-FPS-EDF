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

   P1 : Log_Reporter_Task.Log_Reporter (240, -1, 1000, 0); -- milliseconds
   C1 : Cyclic (10, 15000, 15000, 1, 6092, 0);
   C2 : Cyclic (9, 18000, 18000, 2, 12085, 0);
   C3 : Cyclic (8, 27000, 27000, 3, 45512, 0);
   C4 : Cyclic (7, 27000, 27000, 4, 44315, 0);
   C5 : Cyclic (6, 33000, 33000, 5, 205, 0);
   C6 : Cyclic (5, 37000, 37000, 6, 13101, 0);
   C7 : Cyclic (4, 43000, 43000, 7, 74396, 0);
   C8 : Cyclic (3, 49000, 49000, 8, 82094, 0);
   C9 : Cyclic (2, 87000, 87000, 9, 52436, 0);
   C10 : Cyclic (1, 90000, 90000, 10, 153205, 0);
end Cyclic_Tasks;