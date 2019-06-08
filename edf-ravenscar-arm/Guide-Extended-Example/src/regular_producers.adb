with Ada.Real_Time;
with Activation_Manager;
with Ada.Text_IO;
with Ada.Exceptions; use Ada.Exceptions;
with System.Task_Primitives.Operations;
with System.BB.Time;
with Regular_Producer_Parameters;
with Activation_Log_Readers;
with Activation_Log_Reader_Parameters;
with External_Event_Servers;
with External_Event_Server_Parameters;
with On_Call_Producers;
with On_Call_Producer_Parameters;

package body Regular_Producers is
   Period : constant Ada.Real_Time.Time_Span :=
     Ada.Real_Time.Milliseconds
       (Regular_Producer_Parameters.Regular_Producer_Period);
   task body Regular_Producer is
      use Ada.Real_Time;
      --  for periodic suspension
      Next_Time : Ada.Real_Time.Time;
   begin
      --  for tasks to achieve simultaneous activation
      Activation_Manager.Activation_Cyclic (Next_Time);
      loop
         Next_Time := Next_Time + Period;
         --  non-suspending operation code
         Regular_Producer_Parameters.Regular_Producer_Operation;
         --  time-based activation event
         delay until Next_Time; --  delay statement at end of loop
      end loop;
   exception
      when Error : others =>
         --  last rites: for example
         Ada.Text_IO.Put_Line
           ("Something has gone wrong here: " & Exception_Information (Error));
   end Regular_Producer;

   procedure Init is
   begin
      System.Task_Primitives.Operations.Set_Relative_Deadline
        (System.Task_Primitives.Operations.Self,
          System.BB.Time.Milliseconds (Integer'Last));
      loop
         null;
      end loop;
   end Init;

   C1 : Regular_Producer (
               Regular_Producer_Parameters.Regular_Producer_Priority,
                                                      10937, 1000937, 1, 6300);
   C2 : Activation_Log_Readers.Activation_Log_Reader (
               Activation_Log_Reader_Parameters.Activation_Log_Reader_Priority,
                                                      10937, 1000937, 1, 6300);
   C3 : External_Event_Servers.External_Event_Server (
               External_Event_Server_Parameters.External_Event_Server_Priority,
                                                      10937, 1000937, 1, 6300);
   C4 : On_Call_Producers.On_Call_Producer (
               On_Call_Producer_Parameters.On_Call_Producer_Priority,
                                                      10937, 1000937, 1, 6300);

end Regular_Producers;
