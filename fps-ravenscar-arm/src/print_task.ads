with System;
package Print_Task is

   task type Print
     ( --   Pri        : System.BB.Time.Time_Span;
      Pri        : System.Priority;
      Dead       : Integer;
      Cycle_Time : Positive
      ) is
      pragma Priority (Pri);
      pragma Storage_Size (450);
   end Print;

end Print_Task;
