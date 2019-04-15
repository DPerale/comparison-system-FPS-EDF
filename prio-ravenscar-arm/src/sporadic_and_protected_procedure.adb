with System.IO; use System.IO;
with Ada.Real_Time; use Ada.Real_Time;
with System;

with System.Task_Primitives.Operations;
with System.BB.Time;

with System_Time;

package body Sporadic_and_Protected_Procedure is

   task body Periodic is
      Task_Static_Offset : constant Time_Span :=
               Ada.Real_Time.Milliseconds (0);

      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
            + System_Time.Task_Activation_Delay + Task_Static_Offset;

      Period : constant Ada.Real_Time.Time_Span :=
               Ada.Real_Time.Milliseconds (Cycle_Time);
      -- Other declarations
      type Proc_Access is access procedure(X : in out Integer);
      function Time_It(Action : Proc_Access; Arg : Integer) return Duration is
         Start_Time : Time := Clock;
         Finis_Time : Time;
         Func_Arg : Integer := Arg;
      begin
         Action(Func_Arg);
         Finis_Time := Clock;
         return To_Duration (Finis_Time - Start_Time);
      end Time_It;
      procedure Gauss(Times : in out Integer) is
         Num : Integer := 0;
      begin
         for I in 1..Times loop
            Num := Num + I;
         end loop;
         Event.Signal;
      end Gauss;
      Gauss_Access : Proc_Access := Gauss'access;

      Temp : Integer;
   begin
      -- Initialization code
      -- Setting artificial deadline: it forces system to read deadlines and use
      -- it as main ordering
      -- Put_Line ("---> Setting R_Dead "
      --     & Duration'Image (System.BB.Time.To_Duration
      --       (System.BB.Time.Milliseconds (Dead)))
      --     & " for Task " & Integer'Image(T_Num));

      System.Task_Primitives.Operations.Set_Relative_Deadline
            (System.Task_Primitives.Operations.Self,
             System.BB.Time.Milliseconds (Dead));

      loop
         delay until Next_Period;

--           Put_Line("Begin Calc for Task n. " & Integer'Image(T_Num));
--           Put("Gauss(" & Integer'Image(Gauss_Num) & ") takes"
--               & Duration'Image(Time_It(Gauss_Access, Gauss_Num))
--               & " seconds on Task n. " & Integer'Image(T_Num));
--           Put_Line("... Done.");
--           Put_Line("End Calc for Task n. " & Integer'Image(T_Num));

         Temp := Gauss_Num;
         Gauss (Temp);

         -- wait one whole period before executing
         -- Non-suspending periodic response code
         -- May include calls to protected procedures

         Next_Period := Next_Period + Period;
      end loop;
   end Periodic;

   task body Sporadic is
      Task_Static_Offset : constant Time_Span :=
               Ada.Real_Time.Milliseconds (0);

      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
            + System_Time.Task_Activation_Delay + Task_Static_Offset;

      Period : constant Ada.Real_Time.Time_Span :=
               Ada.Real_Time.Milliseconds (Cycle_Time);
      -- Other declarations
      type Proc_Access is access procedure(X : in out Integer);
      function Time_It(Action : Proc_Access; Arg : Integer) return Duration is
         Start_Time : Time := Clock;
         Finis_Time : Time;
         Func_Arg : Integer := Arg;
      begin
         Action(Func_Arg);
         Finis_Time := Clock;
         return To_Duration (Finis_Time - Start_Time);
      end Time_It;
      procedure Gauss(Times : in out Integer) is
         Num : Integer := 0;
      begin
         for I in 1..Times loop
            Num := Num + I;
         end loop;
      end Gauss;
      Gauss_Access : Proc_Access := Gauss'access;
   begin
      -- Initialization code
      -- Setting artificial deadline: it forces system to read deadlines and use
      -- it as main ordering
    -- Put_Line ("---> Setting R_Dead "
    --    & Duration'Image (System.BB.Time.To_Duration
    --      (System.BB.Time.Milliseconds (Dead)))
    --    & " for Task " & Integer'Image(T_Num));

    System.Task_Primitives.Operations.Set_Relative_Deadline
         (System.Task_Primitives.Operations.Self,
          System.BB.Time.Milliseconds (Dead));

    delay until Next_Period;

      loop
         Event.Wait;

         -- System.IO.Put_Line ("------->>>> Starting Elaboration Protected Procedure");

         Event.Busy_Procedure;

--           Put_Line("Begin Calc for Task n. " & Integer'Image(T_Num));
--           Put("Gauss(" & Integer'Image(Gauss_Num) & ") takes"
--               & Duration'Image(Time_It(Gauss_Access, Gauss_Num))
--               & " seconds on Task n. " & Integer'Image(T_Num));
--           Put_Line("... Done.");
--           Put_Line("End Calc for Task n. " & Integer'Image(T_Num));
      end loop;

   end Sporadic;

   protected body Event is
      procedure Signal is
      begin
         Cycle := Cycle + 1;
         System.IO.Put_Line ("--->>> Signaled: Cycle num. "
                             & Integer'Image (Integer (Cycle)));
         if Cycle = 3 then
            Cycle := 0;
            Occurred := True;
         end if;
      end Signal;

      entry Wait when Occurred is
      begin
         System.IO.Put_Line ("------->>>>>> Guard Unlocked!!!");
         Occurred := False;
      end Wait;

      procedure Busy_Procedure is
        -- Other declarations
        type Proc_Access is access procedure(X : in out Integer);
        function Time_It(Action : Proc_Access; Arg : Integer) return Duration is
           Start_Time : Time := Clock;
           Finis_Time : Time;
           Func_Arg : Integer := Arg;
        begin
           Action(Func_Arg);
           Finis_Time := Clock;
           return To_Duration (Finis_Time - Start_Time);
        end Time_It;
        procedure Gauss(Times : in out Integer) is
           Num : Integer := 0;
        begin
           for I in 1..Times loop
              Num := Num + I;
           end loop;
        end Gauss;
         Gauss_Access : Proc_Access := Gauss'access;

         Temp : Integer;
      begin
        -- 10 secs elaboration time
--          Put_Line("Begin Calc for Busy Procedure");
--          Put("Gauss(" & Integer'Image(5362928) & ") takes"
--              & Duration'Image(Time_It(Gauss_Access, 5362928))
--              & " seconds on Busy Procedure");
--          Put_Line("... Done.");
--             Put_Line("End Calc for Busy Procedure");


         Temp := 5362928;
         Gauss (Temp);

      end Busy_Procedure;
   end Event;

   procedure Init is
   begin
   System.Task_Primitives.Operations.Set_Relative_Deadline
        (System.Task_Primitives.Operations.Self,
         System.BB.Time.Milliseconds (900000));

   System.IO.Put_Line ("--->  Unit03 Start  -->  R_Dead "
        & Duration'Image (System.BB.Time.To_Duration
        (System.BB.Time.Milliseconds (900000))) & " ---|");
     loop
        null;
     end loop;
   end Init;

   ----------------------------------------
   -- TESTED SEQUENCE OF TASK SCHEDULING --
   --       Prio,  Dead,  Cycle,  Task,  Exec
   P1 : Periodic(0,  4000,  4000, 1, 1340732); -- Exec 2 sec
   -- P2 : Periodic(0,  9000,  9000, 2, 2011100); -- Exec 3 sec
   S3 : Sporadic(0, 3000, 3000, 3, 1340732); -- Exec 2 sec
   ----------------------------------------

end Sporadic_and_Protected_Procedure;
