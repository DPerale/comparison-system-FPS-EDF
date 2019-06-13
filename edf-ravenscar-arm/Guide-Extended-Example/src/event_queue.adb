with System.Tasking.Protected_Objects;
package body Event_Queue is
   protected body Handler is
      procedure Signal is
      begin
         Barrier := True;
      end Signal;
      entry Wait when Barrier is
      begin
         Barrier := False;
      end Wait;
   end Handler;
begin
   System.Tasking.Protected_Objects.Initialize_Protection_Deadline
     (System.Tasking.Protected_Objects.Current_Object, 1100);
end Event_Queue;
