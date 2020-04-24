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

   P1 : Print_Task.Print (240, -1, 113430, 0); -- period in milliseconds
   C1 : Cyclic (20, 10000, 10000, 1, 4345, 0);
   C2 : Cyclic (19, 15750, 15750, 2, 6907, 0);
   C3 : Cyclic (18, 22500, 22500, 3, 50340, 0);
   C4 : Cyclic (17, 25200, 25200, 4, 7426, 0);
   C5 : Cyclic (16, 30240, 30240, 5, 9660, 0);
   C6 : Cyclic (15, 33750, 33750, 6, 11206, 0);
   C7 : Cyclic (14, 35000, 35000, 7, 6748, 0);
   C8 : Cyclic (13, 37800, 37800, 8, 6071, 0);
   C9 : Cyclic (12, 45000, 45000, 9, 2386, 0);
   C10 : Cyclic (11, 54000, 54000, 10, 9967, 0);
   C11 : Cyclic (10, 56700, 56700, 11, 61500, 0);
   C12 : Cyclic (9, 60000, 60000, 12, 7394, 0);
   C13 : Cyclic (8, 65625, 65625, 13, 96738, 0);
   C14 : Cyclic (7, 67500, 67500, 14, 54512, 0);
   C15 : Cyclic (6, 70000, 70000, 15, 3551, 0);
   C16 : Cyclic (5, 72000, 72000, 16, 128788, 0);
   C17 : Cyclic (4, 75000, 75000, 17, 2587, 0);
   C18 : Cyclic (3, 84000, 84000, 18, 14393, 0);
   C19 : Cyclic (2, 90720, 90720, 19, 2968, 0);
   C20 : Cyclic (1, 94500, 94500, 20, 18014, 0);
end Cyclic_Tasks;