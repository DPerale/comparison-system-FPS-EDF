with On_Call_Producer_Parameters;
with System;
package On_Call_Producers is

   task type On_Call_Producer_T
     (Pri  : System.Priority;
      Deadline : Positive)
     with Priority => Pri;

   --  non-suspending operation with queuing of data
   function Start (Load : Positive) return Boolean;

   OCP : On_Call_Producer_T
         --  assigned by deadline monotonic analysis
     (Pri  => On_Call_Producer_Parameters.On_Call_Producer_Priority,
      Deadline => 1);

end On_Call_Producers;
