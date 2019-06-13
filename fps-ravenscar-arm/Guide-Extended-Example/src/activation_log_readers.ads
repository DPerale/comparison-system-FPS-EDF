with Activation_Log_Reader_Parameters;
with System;
package Activation_Log_Readers is

   Initialized : Natural := 0;

   procedure Include (Initialized : out Natural);

   task type Activation_Log_Reader_T
     (Pri  : System.Priority;
      WCET : Positive;
      Deadline : Positive)
     with Priority => Pri;

   --  non-suspending parameterless operation
   --  +  with no queuing of activation requests
   procedure Signal;
   procedure Wait;

   --  approximately 1,250,250 processor cycles of Whetstone load
   --  on an ERC32 (a radiation-hardened SPARC for space use) at 10 Hz
   Load : constant Positive := 139;

   ALR : Activation_Log_Reader_T
     --  assigned by deadline monotonic analysis
     (Pri  => Activation_Log_Reader_Parameters.Activation_Log_Reader_Priority,
      WCET => Load,
      Deadline => 1);

end Activation_Log_Readers;
