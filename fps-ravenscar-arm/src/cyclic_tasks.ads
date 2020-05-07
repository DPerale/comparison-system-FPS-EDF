with System;

package Cyclic_Tasks is

   task type Cyclic
     (Pri        : System.Priority;
      Deadline   : Positive;
      Period     : Positive;
      T_Num      : Integer;
      Workload   : Integer;
      Offset     : Integer
      ) is
      pragma Priority (Pri);
      pragma Storage_Size (450);
   end Cyclic;

   procedure Init;
   pragma No_Return (Init);

end Cyclic_Tasks;
