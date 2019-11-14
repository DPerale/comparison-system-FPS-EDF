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

   P1 : Print_Task.Print (240, -1, 243600, 0); -- period in milliseconds
   C1 : Cyclic (20, 29000, 29000, 1, 15314, 0);
   C2 : Cyclic (19, 58000, 58000, 2, 14202, 0);
   C3 : Cyclic (18, 58000, 58000, 3, 15526, 0);
   C4 : Cyclic (17, 87000, 87000, 4, 142034, 0);
   C5 : Cyclic (16, 116000, 116000, 5, 38576, 0);
   C6 : Cyclic (15, 145000, 145000, 6, 40779, 0);
   C7 : Cyclic (14, 174000, 174000, 7, 67133, 0);
   C8 : Cyclic (13, 203000, 203000, 8, 133024, 0);
   C9 : Cyclic (12, 232000, 232000, 9, 125633, 0);
   C10 : Cyclic (11, 290000, 290000, 10, 38100, 0);
   C11 : Cyclic (10, 348000, 348000, 11, 207236, 0);
   C12 : Cyclic (9, 406000, 406000, 12, 29026, 0);
   C13 : Cyclic (8, 435000, 435000, 13, 395527, 0);
   C14 : Cyclic (7, 464000, 464000, 14, 25839, 0);
   C15 : Cyclic (6, 580000, 580000, 15, 90480, 0);
   C16 : Cyclic (5, 609000, 609000, 16, 584845, 0);
   C17 : Cyclic (4, 696000, 696000, 17, 185573, 0);
   C18 : Cyclic (3, 725000, 725000, 18, 182725, 0);
   C19 : Cyclic (2, 812000, 812000, 19, 379867, 0);
   C20 : Cyclic (1, 870000, 870000, 20, 638929, 0);
end Cyclic_Tasks;