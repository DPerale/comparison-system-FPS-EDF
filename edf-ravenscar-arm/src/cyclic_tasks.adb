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
      Temp2 : Ada.Real_Time.Time_Span;

   begin
      Temp2 := Next_Period - Ada.Real_Time.Time_First;
      Temp2 := (Temp2 / 180000) * 180000;
      Temp2 := Temp2 - Ada.Real_Time.Microseconds (73);
      Next_Period := Ada.Real_Time.Time_First + Temp2;
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

         Temp := Load_Num;
         Load (Temp);

         Next_Period := Next_Period + Period;
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

   P1 : Print_Task.Print (240, -1, 1000, 0); -- period in milliseconds
   C1 : Cyclic (20, 11000, 11000, 1, 13747, 0);
   C2 : Cyclic (19, 12000, 12000, 2, 9014, 0);
   C3 : Cyclic (18, 15000, 15000, 3, 840, 0);
   C4 : Cyclic (17, 17000, 17000, 4, 734, 0);
   C5 : Cyclic (16, 18000, 18000, 5, 5404, 0);
   C6 : Cyclic (15, 18000, 18000, 6, 2259, 0);
   C7 : Cyclic (14, 21000, 21000, 7, 15229, 0);
   C8 : Cyclic (13, 25000, 25000, 8, 1338, 0);
   C9 : Cyclic (12, 28000, 28000, 9, 21646, 0);
   C10 : Cyclic (11, 28000, 28000, 10, 10496, 0);
   C11 : Cyclic (10, 32000, 32000, 11, 8601, 0);
   C12 : Cyclic (9, 35000, 35000, 12, 6092, 0);
   C13 : Cyclic (8, 41000, 41000, 13, 6769, 0);
   C14 : Cyclic (7, 55000, 55000, 14, 29831, 0);
   C15 : Cyclic (6, 67000, 67000, 15, 3413, 0);
   C16 : Cyclic (5, 75000, 75000, 16, 107389, 0);
   C17 : Cyclic (4, 80000, 80000, 17, 84561, 0);
   C18 : Cyclic (3, 80000, 80000, 18, 37751, 0);
   C19 : Cyclic (2, 91000, 91000, 19, 39868, 0);
   C20 : Cyclic (1, 99000, 99000, 20, 22345, 0);
end Cyclic_Tasks;