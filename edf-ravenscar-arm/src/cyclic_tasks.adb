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
   C1 : Cyclic (20, 15750, 15750, 1, 776, 0);
   C2 : Cyclic (19, 26250, 26250, 2, 1952, 0);
   C3 : Cyclic (18, 33750, 33750, 3, 7828, 0);
   C4 : Cyclic (17, 35000, 35000, 4, 20841, 0);
   C5 : Cyclic (16, 37800, 37800, 5, 8199, 0);
   C6 : Cyclic (15, 40000, 40000, 6, 11418, 0);
   C7 : Cyclic (14, 47250, 47250, 7, 26146, 0);
   C8 : Cyclic (13, 50400, 50400, 8, 3731, 0);
   C9 : Cyclic (12, 64800, 64800, 9, 19211, 0);
   C10 : Cyclic (11, 75000, 75000, 10, 44284, 0);
   C11 : Cyclic (10, 75600, 75600, 11, 11492, 0);
   C12 : Cyclic (9, 90720, 90720, 12, 21085, 0);
   C13 : Cyclic (8, 100800, 100800, 13, 14605, 0);
   C14 : Cyclic (7, 105000, 105000, 14, 98061, 0);
   C15 : Cyclic (6, 126000, 126000, 15, 72766, 0);
   C16 : Cyclic (5, 141750, 141750, 16, 72596, 0);
   C17 : Cyclic (4, 180000, 180000, 17, 38079, 0);
   C18 : Cyclic (3, 200000, 200000, 18, 3212, 0);
   C19 : Cyclic (2, 506250, 506250, 19, 104065, 0);
   C20 : Cyclic (1, 810000, 810000, 20, 194954, 0);
end Cyclic_Tasks;