with Activation_Log_Reader;
with External_Event_Server;
with On_Call_Producer;
with Regular_Producer;
procedure Gee is

begin
   Activation_Log_Reader.Init;
   External_Event_Server.Init;
   On_Call_Producer.Init;
   Regular_Producer.Init;
end Gee;
