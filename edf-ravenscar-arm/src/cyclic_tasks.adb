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

         Temp := Gauss_Num;
         Gauss (Temp);

         Next_Period := Next_Period + Period;
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

   P1 : Print_Task.Print (240, -1, 1200000, 0); -- period in milliseconds
   C1 : Cyclic (20, 30000, 30000, 1, 946, 0);
   C2 : Cyclic (19, 36000, 36000, 2, 23139, 0);
   C3 : Cyclic (18, 41000, 41000, 3, 7807, 0);
   C4 : Cyclic (17, 43000, 43000, 4, 55856, 0);
   C5 : Cyclic (16, 44000, 44000, 5, 16384, 0);
   C6 : Cyclic (15, 44000, 44000, 6, 13789, 0);
   C7 : Cyclic (14, 49000, 49000, 7, 24791, 0);
   C8 : Cyclic (13, 52000, 52000, 8, 4588, 0);
   C9 : Cyclic (12, 61000, 61000, 9, 3233, 0);
   C10 : Cyclic (11, 62000, 62000, 10, 24780, 0);
   C11 : Cyclic (10, 69000, 69000, 11, 1571, 0);
   C12 : Cyclic (9, 70000, 70000, 12, 39085, 0);
   C13 : Cyclic (8, 71000, 71000, 13, 512, 0);
   C14 : Cyclic (7, 72000, 72000, 14, 35485, 0);
   C15 : Cyclic (6, 73000, 73000, 15, 35601, 0);
   C16 : Cyclic (5, 73000, 73000, 16, 40620, 0);
   C17 : Cyclic (4, 78000, 78000, 17, 28729, 0);
   C18 : Cyclic (3, 79000, 79000, 18, 48244, 0);
   C19 : Cyclic (2, 98000, 98000, 19, 91465, 0);
   C20 : Cyclic (1, 98000, 98000, 20, 140689, 0);
end Cyclic_Tasks;