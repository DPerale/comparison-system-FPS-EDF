with System;
package Activation_Log_Readers is

   task type Activation_Log_Reader
     (Pri        : System.Priority;
      Dead       : Positive;
      Cycle_Time : Positive;
      T_Num      : Integer;
       Gauss_Num  : Integer
      ) is
      pragma Priority (Pri);
   end Activation_Log_Reader;

   --  non-suspending parameterless operation
   --  +  with no queuing of activation requests
   procedure Signal;
   procedure Wait;

   --  task Activation_Log_Reader
   --  with Priority =>
   --    Activation_Log_Reader_Parameters.Activation_Log_Reader_Priority;
   --  assigned by deadline monotonic analysis
end Activation_Log_Readers;
