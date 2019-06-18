with System;

package Cyclic_Tasks is

   task type Cyclic
     (Pri        : System.Priority;
      Dead       : Positive;
      Cycle_Time : Positive;
      T_Num      : Integer;
      Gauss_Num  : Integer
      ) is
      pragma Priority (Pri);
      pragma Storage_Size (450);
   end Cyclic;

   procedure Init;
   pragma No_Return (Init);

end Cyclic_Tasks;
