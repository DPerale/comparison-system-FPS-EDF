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
          System.BB.Time.Microseconds (Dead), False);
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
          System.BB.Time.Milliseconds (Integer'Last), False);
      loop
         null;
      end loop;
   end Init;

   P1 : Print_Task.Print (240, -1, 113400, 0); -- period in milliseconds
   C1 : Cyclic (20, 20000, 20000, 1, 13027, 0);
   C2 : Cyclic (19, 22500, 22500, 2, 13101, 0);
   C3 : Cyclic (18, 26250, 26250, 3, 16288, 0);
   C4 : Cyclic (17, 30240, 30240, 4, 18374, 0);
   C5 : Cyclic (16, 39375, 39375, 5, 24261, 0);
   C6 : Cyclic (15, 42000, 42000, 6, 10444, 0);
   C7 : Cyclic (14, 45000, 45000, 7, 9099, 0);
   C8 : Cyclic (13, 47250, 47250, 8, 21148, 0);
   C9 : Cyclic (12, 52500, 52500, 9, 1549, 0);
   C10 : Cyclic (11, 56250, 56250, 10, 10211, 0);
   C11 : Cyclic (10, 60480, 60480, 11, 9713, 0);
   C12 : Cyclic (9, 63000, 63000, 12, 41414, 0);
   C13 : Cyclic (8, 70000, 70000, 13, 74915, 0);
   C14 : Cyclic (7, 70875, 70875, 14, 1602, 0);
   C15 : Cyclic (6, 72000, 72000, 15, 84064, 0);
   C16 : Cyclic (5, 75600, 75600, 16, 3053, 0);
   C17 : Cyclic (4, 81000, 81000, 17, 116008, 0);
   C18 : Cyclic (3, 87500, 87500, 18, 13620, 0);
   C19 : Cyclic (2, 90000, 90000, 19, 44792, 0);
   C20 : Cyclic (1, 90720, 90720, 20, 84360, 0);
end Cyclic_Tasks;