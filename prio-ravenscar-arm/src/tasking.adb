with Ada.Real_Time;
with System.IO;

package body Tasking is
   use Ada.Real_Time;
   type Cycle_Count is mod 10;

   task Periodic is
      pragma Priority (1);
   end Periodic;

   procedure Background is
      C : Cycle_Count := 0;
   begin
      loop
         C := C + 1;
      end loop;
   end Background;

   task body Periodic is
      Period : constant Time_Span := Milliseconds (1000);
      Next : Time := Clock;
      Cycle : Cycle_Count := 1;
      dead_main : constant System.BB.Deadlines.Relative_Deadline :=
        System.BB.Time.Milliseconds (2000);
      
   begin      
      System.Task_Primitives.Operations.Set_Relative_Deadline
        (System.Task_Primitives.Operations.Self, dead_main);
      loop
         delay  until Next;
         System.IO.Put_Line ("Helloperiodic");
         
         Cycle := Cycle + 1;
         Next := Next + Period;
      end loop;
   end Periodic;

end Tasking;
