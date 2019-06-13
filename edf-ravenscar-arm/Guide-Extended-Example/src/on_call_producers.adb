with Request_Buffer;
with Activation_Manager;
with Ada.Text_IO;
with Ada.Exceptions; use Ada.Exceptions;
package body On_Call_Producers is

   --  to hide the implementation of the event buffer
   function Start (Load : Positive) return Boolean is
   begin
      return Request_Buffer.Deposit (Load);
   end Start;

   task body On_Call_Producer_T is
      Load : Positive;
   begin
      --  for tasks to achieve simultaneous activation
      Activation_Manager.Activation_Sporadic;
      loop
         --  suspending request for activation event with data exchange
         Load := Request_Buffer.Extract;
         --  non-suspending operation code
         On_Call_Producer_Parameters.On_Call_Producer_Operation (Load);
      end loop;
   exception
      when Error : others =>
         --  last rites: for example
         Ada.Text_IO.Put_Line
           ("Something has gone wrong here: " & Exception_Information (Error));
   end On_Call_Producer_T;

end On_Call_Producers;
