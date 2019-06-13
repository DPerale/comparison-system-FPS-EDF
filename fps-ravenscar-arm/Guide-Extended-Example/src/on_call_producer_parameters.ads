with System;
package On_Call_Producer_Parameters is

   --  approximately 2,500,500 processor cycles
   Load : constant Positive := 278;

   On_Call_Producer_Priority : constant System.Priority := 5;
   procedure On_Call_Producer_Operation (Load : Positive);

end On_Call_Producer_Parameters;
