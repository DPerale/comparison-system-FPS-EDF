--  with External_Event_Server;
--  with On_Call_Producer;
with Regular_Producers;
procedure Gee is
   pragma Priority (0);
begin
   --  Activation_Log_Reader.Init;
   --  External_Event_Server.Init;
   --  On_Call_Producer.Init;
   Regular_Producers.Init;
end Gee;
