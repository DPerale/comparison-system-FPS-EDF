with System.IO;
with System;
with System.BB.Time;
-- with System.BB.Deadlines;
-- with Ada.Interrupts.Names;

package Sporadic_and_Protected_Procedure is

   -- Task and protected object declarations

   task type Periodic
     (Pri        : System.Priority;
      Dead       : Positive;
      Cycle_Time : Positive;
      T_Num      : Integer;
      Gauss_Num  : Integer) is
   end Periodic;

   task type Sporadic
     (Pri        : System.Priority;
      Dead       : Positive;
      Cycle_Time : Positive;
      T_Num      : Integer;
      Gauss_Num  : Integer) is
   end Sporadic;

   protected Event is
      pragma Priority (37500000);
      --> floor value has to be the lowest between the relative deadlines
      --> related to the tasks that contend for the resource. it have to
      --> guarantee control without preemption

      procedure Signal;
      entry Wait;
      procedure Busy_Procedure;
   private
      Occurred : Boolean := False;
      Cycle : Integer := 0;
   end Event;

  procedure Init;
  pragma No_Return (Init);

end Sporadic_and_Protected_Procedure;
