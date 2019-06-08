with System;
package On_Call_Producers is

   task type On_Call_Producer
     (Pri        : System.Priority;
      Dead       : Positive;
      Cycle_Time : Positive;
      T_Num      : Integer;
       Gauss_Num  : Integer
      ) is
      pragma Priority (Pri);
   end On_Call_Producer;

   --  non-suspending operation with queuing of data
   function Start (Activation_Parameter : Positive) return Boolean;
   --  task On_Call_Producer
   --  assigned by deadline monotonic analysis
   --  with Priority =>
   --   On_Call_Producer_Parameters.On_Call_Producer_Priority;
end On_Call_Producers;
