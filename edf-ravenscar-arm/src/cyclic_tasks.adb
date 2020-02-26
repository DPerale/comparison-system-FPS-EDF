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

      procedure Load (Times : Integer);
      procedure Load (Times : Integer) is
         Num : Integer := 0;
      begin
         for I in 1 .. Times loop
            Num := Num + I;
         end loop;
      end Load;
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

         Temp := Load_Num;
         Load (Temp);

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
   C1 : Cyclic (20, 10000, 10000, 1, 5139, 0);
   C2 : Cyclic (19, 10000, 10000, 2, 2831, 0);
   C3 : Cyclic (18, 10000, 10000, 3, 9808, 0);
   C4 : Cyclic (17, 10000, 10000, 4, 67, 0);
   C5 : Cyclic (16, 11000, 11000, 5, 1772, 0);
   C6 : Cyclic (15, 13000, 13000, 6, 3731, 0);
   C7 : Cyclic (14, 14000, 14000, 7, 19825, 0);
   C8 : Cyclic (13, 14000, 14000, 8, 8273, 0);
   C9 : Cyclic (12, 16000, 16000, 9, 332, 0);
   C10 : Cyclic (11, 20000, 20000, 10, 3434, 0);
   C11 : Cyclic (10, 20000, 20000, 11, 1909, 0);
   C12 : Cyclic (9, 23000, 23000, 12, 1084, 0);
   C13 : Cyclic (8, 37000, 37000, 13, 84169, 0);
   C14 : Cyclic (7, 41000, 41000, 14, 4504, 0);
   C15 : Cyclic (6, 47000, 47000, 15, 11587, 0);
   C16 : Cyclic (5, 47000, 47000, 16, 16585, 0);
   C17 : Cyclic (4, 63000, 63000, 17, 45692, 0);
   C18 : Cyclic (3, 75000, 75000, 18, 24526, 0);
   C19 : Cyclic (2, 93000, 93000, 19, 28179, 0);
   C20 : Cyclic (1, 97000, 97000, 20, 13451, 0);
end Cyclic_Tasks;