with System;

package Cyclic_Tasks is

   task type Cyclic
     (Pri        : System.Priority;
      Dead       : Positive;
      Cycle_Time : Positive;
      T_Num      : Integer;
      Gauss_Num  : Integer) is
      pragma Priority (Pri);
   end Cyclic;

   procedure Init;
   pragma No_Return (Init);

end Cyclic_Tasks;
