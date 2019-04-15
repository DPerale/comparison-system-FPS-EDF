--
with System.IO;
with System;
with System.BB.Time;
-- with Ada.Interrupts.Names;

package DFP_Test_Procedure is

   -- Task and protected object declarations

   protected Protected_Object is
		pragma Priority (29);

      --> floor value has to be the lowest between the relative deadlines
      --> related to the tasks that contend for the resource. it have to
      --> guarantee control without preemption

      procedure Long_Busy;
      procedure Short_Busy;
   end Protected_Object;

   task type Cyclic
      (Pri        : System.Priority;
      Dead       : Positive;
      Cycle_Time : Positive;
      T_Num      : Integer;
      Gauss_Num  : Integer) is
         pragma Priority(Pri);
   end Cyclic;

   task type Cyclic_Protection
      (Pri        : System.Priority;
      Dead       : Positive;
      Cycle_Time : Positive;
      T_Num      : Integer;
      Gauss_Num  : Integer) is
         pragma Priority(Pri);
   end Cyclic_Protection;

   procedure Init;
   pragma No_Return (Init);

end DFP_Test_Procedure;
