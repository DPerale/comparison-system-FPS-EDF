with External_Event_Server_Parameters;
with System;
package External_Event_Servers is

   Initialized : Natural := 0;

   procedure Include (Initialized : out Natural);

   task type External_Event_Server_T
     (Pri        : System.Priority;
      Deadline : Positive)
     with Priority => Pri;

   EES : External_Event_Server_T
     (Pri => External_Event_Server_Parameters.External_Event_Server_Priority,
     Deadline => 1);

end External_Event_Servers;
