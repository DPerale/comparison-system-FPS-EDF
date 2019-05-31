with Regular_Producer_Parameters;
package Regular_Producer is
   procedure Init;
   pragma No_Return (Init);
   task Regular_Producer
     with Priority =>
       Regular_Producer_Parameters.Regular_Producer_Priority;
end Regular_Producer;
