with  Var_Strings, Symbol_Table;
use   Var_Strings, Symbol_Table;
package Mast_Results_Parser_Tokens is


  type Real_Number is digits 15;

  Large_Number : constant Real_Number:=1.0E30;

  type YYstype is record
    num        : Integer;
    float_num  : Real_Number;
    Is_Float   : Boolean;
    name_index : Symbol_Table.Index;
    flag       : Boolean;
    date       : String(1..19);
    text       : Var_String;
  end record; 

    YYLVal, YYVal : YYSType; 
    type Token is
        (End_Of_Input, Error, Left_Paren, Right_Paren,
         Arrow, Comma, Semicolon,
         Identifier, Number, Yes_No,
         Date, Quoted_Text, Real_Time_Situation,
         Model_Name, Model_Date, Generation_Tool,
         Generation_Profile, Generation_Date, Results,
         The_Type, Slack, Value,
         Trace, Pathname, Path,
         Transaction, Name, Timing_Result,
         Event_Name, Worst_Local_Response_Time, Best_Local_Response_Time,
         Worst_Blocking_Time, Num_Of_Suspensions, Worst_Global_Response_Times,
         Best_Global_Response_Times, Jitters, Simulation_Timing_Result,
         Avg_Local_Response_Time, Avg_Blocking_Time, Max_Preemption_Time,
         Suspension_Time, Num_Of_Queued_Activations, Avg_Global_Response_Times,
         Local_Miss_Ratios, Global_Miss_Ratios, Referenced_Event,
         Time_Value, Deadline, Ratio,
         Miss_Ratios, Processing_Resource, Detailed_Utilization,
         Total, Application, Context_Switch,
         Timer, Driver, Ready_Queue_Size,
         Max_Num, Operation, Scheduling_Server,
         Scheduling_Parameters, Server_Sched_Parameters, Synchronization_Parameters,
         Server_Synch_Parameters, Shared_Resource, Priority_Ceiling,
         Ceiling, Level, Queue_Size,
         Utilization, Fixed_Priority_Policy, Non_Preemptible_Fp_Policy,
         Interrupt_Fp_Policy, The_Priority, Polling_Policy,
         Polling_Period, Polling_Worst_Overhead, Polling_Best_Overhead,
         Polling_Avg_Overhead, Sporadic_Server_Policy, Normal_Priority,
         Background_Priority, Initial_Capacity, Replenishment_Period,
         Max_Pending_Replenishments, Preassigned, Edf_Policy,
         Srp_Parameters, The_Preemption_Level );

    Syntax_Error : exception;

end Mast_Results_Parser_Tokens;
