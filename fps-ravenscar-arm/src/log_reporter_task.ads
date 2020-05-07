with System;
package Log_Reporter_Task is

   task type Log_Reporter
     (Pri        : System.Priority;
      Deadline   : Integer;
      Period     : Positive;
      Offset     : Integer
      ) is
      pragma Priority (Pri);
      pragma Storage_Size (450);
   end Log_Reporter;

end Log_Reporter_Task;
