with Regular_Producer_Parameters;
with System;
package Regular_Producers is

   task type Regular_Producer_T
     (Pri  : System.Priority;
      WCET : Positive;
      Deadline : Positive)
     with Priority => Pri;

   --  approximately 5,001,000 processor cycles of Whetstone load
   --  on an ERC32 (a radiation-hardened SPARC for space use) at 10 Hz
   Load : constant Positive := 756;

   RP : Regular_Producer_T
     (Pri  => Regular_Producer_Parameters.Regular_Producer_Priority,
      WCET => Load,
      Deadline => 1);

   Initialized : Natural := 0;

   procedure Include (Initialized : out Natural);

end Regular_Producers;
