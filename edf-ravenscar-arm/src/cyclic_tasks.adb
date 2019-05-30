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
               Ada.Real_Time.Microseconds (500000);

      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
            + System_Time.Task_Activation_Delay + Task_Static_Offset;

      Period : constant Ada.Real_Time.Time_Span :=
               Ada.Real_Time.Microseconds (Cycle_Time);

      --  type Proc_Access is access procedure (X : in out Integer);

--    function Time_It (Action : Proc_Access; Arg : Integer) return Duration;
--    function Time_It (Action : Proc_Access; Arg : Integer) return Duration is
--         Start_Time : constant Time := Clock;
--         Finis_Time : Time;
--         Func_Arg : Integer := Arg;
--      begin
--         Action (Func_Arg);
--         Finis_Time := Clock;
--         return To_Duration (Finis_Time - Start_Time);
--      end Time_It;

      procedure Gauss (Times : Integer);
      procedure Gauss (Times : Integer) is
         Num : Integer := 0;
      begin
         for I in 1 .. Times loop
            Num := Num + I;
         end loop;
      end Gauss;
--    Gauss_Access : constant Proc_Access := Gauss'Access;
      Temp : Integer;

   begin
      System.Task_Primitives.Operations.Set_Relative_Deadline
         (System.Task_Primitives.Operations.Self,
          System.BB.Time.Microseconds (Dead));
      System.BB.Threads.Set_Fake_Number_ID (T_Num);
      System.BB.Threads.Queues.Initialize_Task_Table (T_Num);

      loop
         delay until Next_Period;

--       System.IO.Put_Line ("Gauss(" & Integer'Image (Gauss_Num) & ") takes"
--              & Duration'Image (Time_It (Gauss_Access, Gauss_Num))
--                    & " seconds");
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

   P1 : Print_Task.Print (240, -1, 5000); -- period in milliseconds
   C1 : Cyclic (36, 1000000, 1000000, 1, 10);
   C2 : Cyclic (35, 1000000, 1000000, 2, 10);
   C3 : Cyclic (36, 1000000, 1000000, 1, 10);
   C4 : Cyclic (35, 1000000, 1000000, 2, 10);
   C5 : Cyclic (36, 1000000, 1000000, 1, 10);
   C6 : Cyclic (35, 1000000, 1000000, 2, 10);
   C7 : Cyclic (36, 1000000, 1000000, 1, 10);
   C8 : Cyclic (35, 1000000, 1000000, 2, 10);
   C9 : Cyclic (36, 1000000, 1000000, 1, 10);
   C10 : Cyclic (35, 1000000, 1000000, 2, 10);
   C11 : Cyclic (36, 1000000, 1000000, 1, 10);
   C12 : Cyclic (35, 1000000, 1000000, 2, 10);
   C13 : Cyclic (36, 1000000, 1000000, 1, 10);
   C14 : Cyclic (35, 1000000, 1000000, 2, 10);
   C15 : Cyclic (36, 1000000, 1000000, 1, 10);
   C16 : Cyclic (35, 1000000, 1000000, 2, 10);
   C17 : Cyclic (36, 1000000, 1000000, 1, 10);
   C18 : Cyclic (35, 1000000, 1000000, 2, 10);
   C19 : Cyclic (36, 1000000, 1000000, 1, 10);
   C20 : Cyclic (35, 1000000, 1000000, 2, 10);
   C21 : Cyclic (36, 1000000, 1000000, 1, 10);
   C22 : Cyclic (35, 1000000, 1000000, 2, 10);
   C23 : Cyclic (36, 1000000, 1000000, 1, 10);
   C24 : Cyclic (35, 1000000, 1000000, 2, 10);
   C25 : Cyclic (36, 1000000, 1000000, 1, 10);
   C26 : Cyclic (35, 1000000, 1000000, 2, 10);
   C27 : Cyclic (36, 1000000, 1000000, 1, 10);
   C28 : Cyclic (35, 1000000, 1000000, 2, 10);
   C29 : Cyclic (36, 1000000, 1000000, 1, 10);
   C30 : Cyclic (35, 1000000, 1000000, 2, 10);
   C31 : Cyclic (36, 1000000, 1000000, 1, 10);
   C32 : Cyclic (35, 1000000, 1000000, 2, 10);
   C33 : Cyclic (36, 1000000, 1000000, 1, 10);
   C34 : Cyclic (35, 1000000, 1000000, 2, 10);
   C35 : Cyclic (36, 1000000, 1000000, 1, 10);
   C36 : Cyclic (35, 1000000, 1000000, 2, 10);
   C37 : Cyclic (36, 1000000, 1000000, 1, 10);
   C38 : Cyclic (35, 1000000, 1000000, 2, 10);
   C39 : Cyclic (36, 1000000, 1000000, 1, 10);
   C40 : Cyclic (35, 1000000, 1000000, 2, 10);
   C41 : Cyclic (36, 1000000, 1000000, 1, 10);
   C42 : Cyclic (35, 1000000, 1000000, 2, 10);
   C43 : Cyclic (36, 1000000, 1000000, 1, 10);
   C44 : Cyclic (35, 1000000, 1000000, 2, 10);
   C45 : Cyclic (36, 1000000, 1000000, 1, 10);
   C46 : Cyclic (35, 1000000, 1000000, 2, 10);
   C47 : Cyclic (36, 1000000, 1000000, 1, 10);
   C48 : Cyclic (35, 1000000, 1000000, 2, 10);
   C49 : Cyclic (36, 1000000, 1000000, 1, 10);
   C50 : Cyclic (35, 1000000, 1000000, 2, 10);
   C51 : Cyclic (36, 1000000, 1000000, 1, 10);
   C52 : Cyclic (35, 1000000, 1000000, 2, 10);
   C53 : Cyclic (36, 1000000, 1000000, 1, 10);
   C54 : Cyclic (35, 1000000, 1000000, 2, 10);
   C55 : Cyclic (36, 1000000, 1000000, 1, 10);
   C56 : Cyclic (35, 1000000, 1000000, 2, 10);
   C57 : Cyclic (36, 1000000, 1000000, 1, 10);
   C58 : Cyclic (35, 1000000, 1000000, 2, 10);
   C59 : Cyclic (36, 1000000, 1000000, 1, 10);
   C60 : Cyclic (35, 1000000, 1000000, 2, 10);
   C61 : Cyclic (36, 1000000, 1000000, 1, 10);
   C62 : Cyclic (35, 1000000, 1000000, 2, 10);
   C63 : Cyclic (36, 1000000, 1000000, 1, 10);
   C64 : Cyclic (35, 1000000, 1000000, 2, 10);

end Cyclic_Tasks;
