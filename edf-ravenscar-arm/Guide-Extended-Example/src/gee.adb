with Activation_Log_Readers;
with Regular_Producers;
with External_Event_Servers;
with System;
procedure Gee is
   pragma Priority (System.Priority'First);
begin
   Activation_Log_Readers.Include (Activation_Log_Readers.Initialized);
   Regular_Producers.Include (Regular_Producers.Initialized);
   External_Event_Servers.Include (External_Event_Servers.Initialized);
   loop
      null;
   end loop;
end Gee;
