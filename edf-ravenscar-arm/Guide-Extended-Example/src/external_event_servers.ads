with System;
package External_Event_Servers is

   task type External_Event_Server
     (Pri        : System.Priority;
      Dead       : Positive;
      Cycle_Time : Positive;
      T_Num      : Integer;
       Gauss_Num  : Integer
      ) is
      pragma Priority (Pri);
   end External_Event_Server;

   --  task External_Event_Server
   --  with Priority =>
   --    External_Event_Server_Parameters.External_Event_Server_Priority;
end External_Event_Servers;
