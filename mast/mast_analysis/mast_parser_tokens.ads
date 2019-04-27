with  Symbol_Table;
use   Symbol_Table;
package Mast_Parser_Tokens is


  type Real_Number is digits 15;

  type YYstype is record
    num        : Integer;
    float_num  : Real_Number;
    Is_Float   : Boolean;
    name_index : Symbol_Table.Index;
    flag       : Boolean;
    date       : String(1..19);
  end record; 

    YYLVal, YYVal : YYSType; 
    type Token is
        (End_Of_Input, Error, Left_Paren, Right_Paren,
         Arrow, Comma, Semicolon,
         Identifier, Number, Yes_No,
         Date, Model_Name, Model_Date,
         Model, Processing_Resource, The_Type,
         Fixed_Priority_Processor, Fixed_Priority_Network, Name,
         Max_Priority, Min_Priority, Max_Interrupt_Priority,
         Min_Interrupt_Priority, Worst_Context_Switch, Avg_Context_Switch,
         Best_Context_Switch, Worst_Isr_Switch, Avg_Isr_Switch,
         Best_Isr_Switch, Worst_Overhead, Avg_Overhead,
         Best_Overhead, System_Timer, Alarm_Clock,
         Ticker, Speed_Factor, Packet_Worst_Overhead,
         Packet_Avg_Overhead, Packet_Best_Overhead, Transmission,
         Trans_Kind, List_Of_Drivers, Max_Blocking,
         Max_Packet_Transmission_Time, Min_Packet_Transmission_Time, Packet_Driver,
         Character_Packet_Driver, Packet_Server, Packet_Receive_Operation,
         Packet_Send_Operation, Character_Server, Character_Receive_Operation,
         Character_Send_Operation, Character_Transmission_Time, Shared_Resource,
         Immediate_Ceiling_Resource, Ceiling, Priority_Inheritance_Resource,
         Operation, Simple, Composite,
         Enclosing, Worst_Case_Execution_Time, Avg_Case_Execution_Time,
         Best_Case_Execution_Time, Shared_Resources_List, Shared_Resources_To_Lock,
         Shared_Resources_To_Unlock, Composite_Operation_List, External_Events,
         Periodic, Singular, Aperiodic,
         Sporadic, Unbounded_Ev, Bursty,
         Period, Max_Jitter, Phase,
         Avg_Interarrival, Distribution, Dist_Function,
         Min_Interarrival, Bound_Interval, Max_Arrivals,
         Referenced_Event, Transaction, Event_Handlers,
         Internal_Events, Scheduling_Server, Fixed_Priority,
         New_Sched_Parameters, Server_Sched_Parameters, Server_Processing_Resource,
         Hard_Global_Deadline, Soft_Global_Deadline, Deadline,
         Hard_Local_Deadline, Soft_Local_Deadline, Global_Max_Miss_Ratio,
         Local_Max_Miss_Ratio, Max_Output_Jitter_Req, Max_Output_Jitter,
         Requirements_List, Ratio, Fixed_Priority_Policy,
         Non_Preemptible_Fp_Policy, Interrupt_Fp_Policy, The_Priority,
         Polling_Policy, Polling_Period, Polling_Worst_Overhead,
         Polling_Best_Overhead, Polling_Avg_Overhead, Sporadic_Server_Policy,
         Normal_Priority, Background_Priority, Initial_Capacity,
         Replenishment_Period, Max_Pending_Replenishments, Preassigned,
         Overridden_Fixed_Priority, Overridden_Permanent_Fp, Activity_Operation,
         Input_Event, Output_Event, Timing_Requirements,
         Activity_Server, Activity, System_Timed_Activity,
         Concentrator, Input_Events_List, Barrier,
         Delivery_Server, Delivery_Policy, Request_Policy,
         Query_Server, Output_Events_List, Multicast,
         Rate_Divisor, Rate_Factor, The_Delay,
         Delay_Max_Interval, Delay_Min_Interval, Offset,
         Event, Regular, Link,
         Regular_Processor, Packet_Based_Network, Scheduler,
         Primary_Scheduler, Secondary_Scheduler, Policy,
         Host, Server, Edf,
         Fp_Packet_Based, Edf_Policy, Srp_Parameters,
         The_Preemption_Level, The_Synchronization_Parameters, Srp_Resource,
         Throughput, Max_Packet_Size, Min_Packet_Size,
         Message_Transmission, Max_Message_Size, Avg_Message_Size,
         Min_Message_Size, Packet_Overhead_Max_Size, Packet_Overhead_Avg_Size,
         Packet_Overhead_Min_Size, System_Pip_Behaviour, Pip_Behaviour,
         Rtep_Packet_Driver, Number_Of_Stations, Token_Delay,
         Failure_Timeout, Token_Transmission_Retries, Packet_Transmission_Retries,
         Packet_Interrupt_Server, Packet_Isr_Operation, Token_Check_Operation,
         Token_Manage_Operation, Packet_Discard_Operation, Token_Retransmission_Operation,
         Packet_Retransmission_Operation, Message_Partitioning, Rta_Overhead_Model,
         Rta_Overhead_Model_Value );

    Syntax_Error : exception;

end Mast_Parser_Tokens;
