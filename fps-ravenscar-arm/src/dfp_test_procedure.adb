with Ada.Real_Time; use Ada.Real_Time;
with System;

with System_Time;

package body DFP_Test_Procedure is

   task body Cyclic is
      Task_Static_Offset : constant Time_Span :=
      Ada.Real_Time.Microseconds (0);

      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
      + System_Time.Task_Activation_Delay + Task_Static_Offset;

      Period : constant Ada.Real_Time.Time_Span :=
      Ada.Real_Time.Microseconds (Cycle_Time);
      --  Other declarations
      type Proc_Access is access procedure (X : in out Integer);
      function Time_It (Action : Proc_Access; Arg : Integer) return Duration is
         Start_Time : constant Time := Clock;
         Finis_Time : Time;
         Func_Arg : Integer := Arg;
      begin
         Action (Func_Arg);
         Finis_Time := Clock;
         return To_Duration (Finis_Time - Start_Time);
      end Time_It;
      procedure Gauss (Times : in out Integer) is
         Num : Integer := 0;
      begin
         for I in 1 .. Times loop
            Num := Num + I;
         end loop;
      end Gauss;
      Gauss_Access : constant Proc_Access := Gauss'Access;

      Temp : Integer;

   begin
      --  Initialization code
      --  Setting artificial deadline: it forces system to read deadlines and use
      --  it as main ordering
      Put_Line ("---> Setting R_Dead "
      & Duration'Image (System.BB.Time.To_Duration
      (System.BB.Time.Microseconds (Dead)))
      & " for Task " & Integer'Image (T_Num));

      System.Task_Primitives.Operations.Set_Relative_Deadline
         (System.Task_Primitives.Operations.Self,
         System.BB.Time.Microseconds (Dead));
      loop
         delay until Next_Period;

         --  Put_Line ("Gauss(" & Integer'Image (Gauss_Num) & ") takes"
         --   & Duration'Image (Time_It (Gauss_Access, Gauss_Num))
         --         & " seconds");

         Temp := Gauss_Num;
         Gauss (Temp);

         --  wait one whole period before executing
         --  Non-suspending periodic response code
         --  May include calls to protected procedures
         Next_Period := Next_Period + Period;
      end loop;
   end Cyclic;

   task body Cyclic_Protection is
      Task_Static_Offset : constant Time_Span :=
      Ada.Real_Time.Milliseconds (0);

      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
      + System_Time.Task_Activation_Delay + Task_Static_Offset;

      Period : constant Ada.Real_Time.Time_Span :=
      Ada.Real_Time.Milliseconds (Cycle_Time);
      -- Other declarations
   begin
      -- Initialization code
      -- Setting artificial deadline: it forces system to read deadlines and use
      -- it as main ordering
      -- it as main ordering
      Put_Line ("---> Setting R_Dead "
      & Duration'Image (System.BB.Time.To_Duration
      (System.BB.Time.Milliseconds (Dead)))
      & " for Task " & Integer'Image(T_Num));

      System.Task_Primitives.Operations.Set_Relative_Deadline
         (System.Task_Primitives.Operations.Self,
          System.BB.Time.Milliseconds (Dead));

      loop
         delay until Next_Period;

         Protected_Object.Short_Busy;

         -- wait one whole period before executing
         -- Non-suspending periodic response code
         -- May include calls to protected procedures

         Next_Period := Next_Period + Period;
      end loop;
   end Cyclic_Protection;

   protected body Protected_Object is
      procedure Short_Busy is
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
         Temp := 500;
         Gauss (Temp);
      end Short_Busy;
      procedure Long_Busy is
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
         Temp := 8782;
         Gauss (Temp);
      end Long_Busy;
   end Protected_Object;

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

end DFP_Test_Procedure;
