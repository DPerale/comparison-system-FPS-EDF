with System;
package Regular_Producers is

   task type Regular_Producer
     (Pri        : System.Priority;
      Dead       : Positive;
      Cycle_Time : Positive;
      T_Num      : Integer;
       Gauss_Num  : Integer
      ) is
      pragma Priority (Pri);
   end Regular_Producer;

   procedure Init;
   pragma No_Return (Init);
   --  task Regular_Producer
   --  with Priority =>
   --    Regular_Producer_Parameters.Regular_Producer_Priority;

end Regular_Producers;
