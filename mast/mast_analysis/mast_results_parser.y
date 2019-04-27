-----------------------------------
--         Tokens
-----------------------------------

%token    left_paren
%token    right_paren
%token    arrow
%token    comma
%token    semicolon

%token    identifier
%token    number
%token    yes_no
%token    date
%token    quoted_text

%token    real_time_situation
%token    model_name         
%token    model_date         
%token    generation_tool     
%token    generation_profile 
%token    generation_date    
%token    results            
%token    the_type           
%token    slack              
%token    value              
%token    trace              
%token    pathname           
%token    path

%token    transaction        
%token    name               
%token    timing_result            
%token    event_name               
%token    worst_local_response_time
%token    best_local_response_time 
%token    worst_blocking_time      
%token    num_of_suspensions       
%token    worst_global_response_times
%token    best_global_response_times 
%token    jitters                    

%token    simulation_timing_result   
%token    avg_local_response_time  
%token    avg_blocking_time        
%token    max_preemption_time      
%token    suspension_time          
%token    num_of_queued_activations
%token    avg_global_response_times 
%token    local_miss_ratios        
%token    global_miss_ratios       
%token    referenced_event         
%token    time_value               
%token    deadline                 
%token    ratio                    
%token    miss_ratios              

%token    processing_resource      
%token    detailed_utilization     
%token    total                    
%token    application              
%token    context_switch           
%token    timer                    
%token    driver                   
%token    ready_queue_size         
%token    max_num                  

%token    operation                

%token    scheduling_server        
%token    scheduling_parameters    
%token    server_sched_parameters  
%token    synchronization_parameters    
%token    server_synch_parameters  

%token    shared_resource          
%token    priority_ceiling         
%token    ceiling                  
%token    level                  
%token    queue_size               
%token    utilization              

%token    fixed_priority_policy
%token    non_preemptible_fp_policy
%token    interrupt_fp_policy
%token    the_priority
%token    polling_policy
%token    polling_period
%token    polling_worst_overhead
%token    polling_best_overhead
%token    polling_avg_overhead
%token    sporadic_server_policy
%token    normal_priority
%token    background_priority
%token    initial_capacity
%token    replenishment_period
%token    max_pending_replenishments
%token    preassigned

%token    edf_policy
%token    srp_parameters
%token    the_preemption_level


%with          Var_Strings,Symbol_Table;
%use           Var_Strings,Symbol_Table;
{
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
}

%%

------------------------------------
--  MAST Results
------------------------------------

mast_results :
      mast_results mast_object
    | mast_object
    ;
mast_object : 
      real_time_situation_object
    | processing_resource_object 
    | shared_resource_object
    | operation_object
    | transaction_object
    | server_object
    ;

------------------------------------
--  Real_Time_Situation
------------------------------------

real_time_situation_object :
      real_time_situation left_paren model_arguments right_paren semicolon
      ;
model_arguments :
        model_argument
      | model_arguments comma model_argument
      ;
model_argument :
        model_name_arg
      | model_date_arg
      | generation_tool_arg
      | generation_profile_arg
      | generation_date_arg
      | rts_results_arg
      ;
model_name_arg :
      model_name arrow identifier
      {
	null;
      }
      ;
model_date_arg :
      model_date arrow date
      {
        null;
      }
      ;
generation_tool_arg :
      generation_tool arrow quoted_text
      {
	Mast_System.Generation_Tool:=YYVal.text;
      }
      ;
generation_profile_arg :
      generation_profile arrow quoted_text
      {
	Mast_System.Generation_Profile:=YYVal.text;
      }
      ;
generation_date_arg :
      generation_date arrow date
      {
	Mast_System.Generation_Date:=YYVal.Date;
        if not Mast.IO.Is_Date_OK(Mast_System.Generation_Date) then
	    User_Defined_Errors.Parser_Error
                 ("Error in date value");
        end if;
      }
      ;
rts_results_arg :
      results arrow left_paren rts_results right_paren
      ;
rts_results :
        rts_results comma rts_result
      | rts_result
      ;
rts_result :
        rts_slack_result
      | rts_trace_result
      ;
rts_slack_result :
      left_paren the_type arrow slack comma
      {
        The_Slack_Res:=new Mast.Results.Slack_Result;
	Systems.Set_Slack_Result(Mast_System,The_Slack_Res);
      }
      value arrow number right_paren
      {
	Mast.Results.Set_Slack(The_Slack_Res.all,Float(YYVal.Float_Num));
      }   
      ;
rts_trace_result :
      left_paren the_type arrow trace comma
      {
        The_Trace_Res:=new Mast.Results.Trace_Result;
 	Systems.Set_Trace_Result(Mast_System,The_Trace_Res);
      }
          pathname arrow path right_paren
      {
	Mast.Results.Set_Pathname(The_Trace_Res.all,To_String(YYVal.Text));
      }   
      ;

------------------------------------
--  Processing resources
------------------------------------

processing_resource_object :
      processing_resource left_paren pr_arguments right_paren semicolon
      ;
pr_arguments :
        pr_argument
      | pr_arguments comma pr_argument
      ;
pr_argument :
        pr_name_arg
      | pr_results_arg
      ;
pr_name_arg :
      name arrow identifier
      {
	--find the processing resource
        declare
	  The_Index : Processing_Resources.Lists.Index;
        begin
	  The_Index:=Processing_Resources.Lists.Find
	    (Symbol_Table.Item(YYVal.Name_Index),
             Mast_System.Processing_Resources);
	     Pr_Ref:=Processing_Resources.Lists.Item
		    (The_Index,Mast_System.Processing_Resources);             
          exception
             when List_Exceptions.Invalid_Index =>
                -- create dummy processing resource
	        Pr_Ref:=new Processing_Resources.Processor.Regular_Processor;
                User_Defined_Errors.Parser_Error
                  (To_String("Processing Resource "&
                   Symbol_Table.Item(YYVal.Name_Index)&" not found"));
	  end;
      }
      ;
pr_results_arg :
      results arrow left_paren pr_results right_paren
      ;
pr_results :
        pr_results comma pr_result
      | pr_result
      ;
pr_result :
        pr_slack_result
      | pr_utilization_result
      | pr_queue_size_result
      ;
pr_slack_result :
      left_paren the_type arrow slack comma
      {
        The_Slack_res:=new Mast.Results.Slack_Result;
	Processing_Resources.Set_Slack_Result(Pr_Ref.all,The_Slack_Res);
      }
      value arrow number right_paren
      {
	Mast.Results.Set_Slack(The_Slack_Res.all,Float(YYVal.Float_Num));
      }   
      ;
pr_utilization_result :
      left_paren the_type arrow detailed_utilization comma
      {
          The_Utilization_Res:=new Mast.Results.Detailed_Utilization_Result;
          Processing_Resources.Set_Utilization_result
            (Pr_Ref.all,The_Utilization_Res);
      }
      pr_utilization_result_args right_paren
      ;
pr_utilization_result_args :
        pr_utilization_result_arg
      | pr_utilization_result_args comma pr_utilization_result_arg
      ;
pr_utilization_result_arg :
        pr_total_arg
      | pr_application_arg
      | pr_context_switch_arg
      | pr_timer_arg
      | pr_driver_arg
      ;
pr_total_arg :
      total arrow number
      {
	Mast.Results.Set_Total
          (Mast.Results.Detailed_Utilization_Result(The_Utilization_Res.all),
           Float(YYVal.Float_Num));
      }   
      ;
pr_application_arg :
      application arrow number
      {
	Mast.Results.Set_Application
          (Mast.Results.Detailed_Utilization_Result(The_Utilization_Res.all),
           Float(YYVal.Float_Num));
      }   
      ;
pr_context_switch_arg :
      context_switch arrow number
      {
	Mast.Results.Set_Context_Switch
          (Mast.Results.Detailed_Utilization_Result(The_Utilization_Res.all),
           Float(YYVal.Float_Num));
      }   
      ;
pr_timer_arg :
      timer arrow number
      {
	Mast.Results.Set_Timer
          (Mast.Results.Detailed_Utilization_Result(The_Utilization_Res.all),
           Float(YYVal.Float_Num));
      }   
      ;
pr_driver_arg :
      driver arrow number
      {
	Mast.Results.Set_Driver
          (Mast.Results.Detailed_Utilization_Result(The_Utilization_Res.all),
           Float(YYVal.Float_Num));
      }   
      ;

pr_queue_size_result :
      left_paren the_type arrow ready_queue_size comma
      {
        The_queue_size_res:=new Mast.Results.Ready_Queue_Size_Result;
	Processing_Resources.Set_Ready_Queue_Size_Result
           (Pr_Ref.all,
            Mast.results.ready_queue_size_result_ref(The_queue_size_Res));
      }
      max_num arrow number right_paren
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Max_Num should be integer value");
        end if;
	Mast.Results.Set_Max_Num
           (The_Queue_Size_Res.all,YYVal.Num);
      }   
      ;

------------------------------------
--  Shared resources
------------------------------------

shared_resource_object :
      shared_resource left_paren sr_arguments right_paren semicolon
      ;
sr_arguments :
        sr_argument
      | sr_arguments comma sr_argument
      ;
sr_argument :
        sr_name_arg
      | sr_results_arg
      ;
sr_name_arg :
      name arrow identifier
      {
	--find the shared resource
        declare
	  The_Index : Shared_Resources.Lists.Index;
        begin
	  The_Index:=Shared_Resources.Lists.Find
	    (Symbol_Table.Item(YYVal.Name_Index),
             Mast_System.Shared_Resources);
	     Sr_Ref:=Shared_Resources.Lists.Item
		    (The_Index,Mast_System.Shared_Resources);             
          exception
             when List_Exceptions.Invalid_Index =>
                -- create dummy shared resource
	        Sr_Ref:=new Shared_Resources.Immediate_Ceiling_Resource;
                User_Defined_Errors.Parser_Error
                  (To_String("Shared Resource "&
                   Symbol_Table.Item(YYVal.Name_Index)&" not found"));
	  end;
      }
      ;
sr_results_arg :
      results arrow left_paren sr_results right_paren
      ;
sr_results :
        sr_results comma sr_result
      | sr_result
      ;
sr_result :
        sr_ceiling_result
      | sr_level_result
      | sr_utilization_result
      | sr_queue_size_result
      ;
sr_ceiling_result :
      left_paren the_type arrow priority_ceiling comma
      {
        The_Ceiling_Res:=new Mast.Results.Ceiling_Result;
	Shared_Resources.Set_Ceiling_Result(Sr_Ref.all,The_Ceiling_Res);
      }
      ceiling arrow number right_paren
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Ceiling should be integer value");
        end if;
        begin
           Mast.Results.Set_Ceiling(The_Ceiling_Res.all,Priority(YYVal.Num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority ceiling value out of range");
        end;
      }   
      ;
sr_level_result :
      left_paren the_type arrow the_preemption_level comma
      {
        The_Preemption_Level_Res:=new Mast.Results.Preemption_Level_Result;
	Shared_Resources.Set_Preemption_Level_Result
          (Sr_Ref.all,The_Preemption_Level_Res);
      }
      level arrow number right_paren
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Preemption Level should be integer value");
        end if;
        begin
           Mast.Results.Set_Preemption_Level
              (The_Preemption_Level_Res.all,Mast.Preemption_Level(YYVal.Num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Preemption level value out of range");
        end;
      }   
      ;
sr_utilization_result :
      left_paren the_type arrow utilization comma
      {
          The_Utilization_Res:=new Mast.Results.Utilization_Result;
          Shared_Resources.Set_Utilization_result
            (Sr_Ref.all,The_Utilization_Res);
      }
      total arrow number right_paren
      {
	Mast.Results.Set_Total
          (The_Utilization_Res.all,Float(YYVal.Float_Num));
      }   
      ;
sr_queue_size_result :
      left_paren the_type arrow queue_size comma
      {
        The_queue_size_res:=new Mast.Results.Queue_Size_Result;
	Shared_Resources.Set_Queue_Size_Result
           (Sr_Ref.all,The_queue_size_Res);
      }
      max_num arrow number right_paren
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Max_Num should be integer value");
        end if;
	Mast.Results.Set_Max_Num
           (The_Queue_Size_Res.all,YYVal.Num);
      }   
      ;

------------------------------------
--  Operations
------------------------------------

operation_object :
      operation left_paren op_arguments right_paren semicolon
      ;
op_arguments :
        op_argument
      | op_arguments comma op_argument
      ;
op_argument :
        op_name_arg
      | op_results_arg
      ;
op_name_arg :
      name arrow identifier
      {
	--find the operation
        declare
	  The_Index : Operations.Lists.Index;
        begin
	  The_Index:=Operations.Lists.Find
	    (Symbol_Table.Item(YYVal.Name_Index),
             Mast_System.Operations);
	     Op_Ref:=Operations.Lists.Item
		    (The_Index,Mast_System.Operations);             
          exception
             when List_Exceptions.Invalid_Index =>
                -- create dummy operation
	        Op_Ref:=new Operations.Simple_Operation;
                User_Defined_Errors.Parser_Error
                  (To_String("Operation "&
                   Symbol_Table.Item(YYVal.Name_Index)&" not found"));
	  end;
      }
      ;
op_results_arg :
      results arrow left_paren op_results right_paren
      ;
op_results :
        op_results comma op_result
      | op_result
      ;
op_result :
        op_slack_result
      ;
op_slack_result :
      left_paren the_type arrow slack comma
      {
        The_Slack_Res:=new Mast.Results.Slack_Result;
	Operations.Set_Slack_Result(Op_Ref.all,The_Slack_Res);
      }
      value arrow number right_paren
      {
	Mast.Results.Set_Slack(The_Slack_Res.all,Float(YYVal.Float_Num));
      }   
      ;


------------------------------------
--  Scheduling Parameters
------------------------------------

scheduling_parameters_item :
        fixed_priority_policy_item
      | non_preemptible_policy_item
      | interrupt_policy_item
      | polling_policy_item
      | sporadic_server_policy_item
      | edf_policy_item
      ;
fixed_priority_policy_item :
      left_paren fixed_priority_policy_type
      {
          sched_params_ref:=
              new Mast.Scheduling_Parameters.fixed_priority_policy;
          Preassigned_Field_Present:=False;
      }
      fixed_priority_policy_termination
      ;
fixed_priority_policy_type :
      the_type arrow fixed_priority_policy
      ;
fixed_priority_policy_termination :
        right_paren
      | fixed_priority_policy_arguments right_paren
      ;    
fixed_priority_policy_arguments :
        fixed_priority_policy_argument
      | fixed_priority_policy_arguments fixed_priority_policy_argument
      ;
fixed_priority_policy_argument :
        fp_policy_priority
      | preassigned_param
      ;
preassigned_param :
        comma preassigned arrow yes_no
      {
          Preassigned_Field_Present:=True;
          if sched_params_ref.all in 
             Mast.Scheduling_Parameters.interrupt_fp_policy
          then          
             Mast.Scheduling_Parameters.set_preassigned
               (Mast.Scheduling_Parameters.Fixed_Priority_Parameters'Class
                    (Sched_params_ref.all), True);
             if not YYVal.flag then
                User_Defined_Errors.Parser_Error
                  ("Preassigned field in Interrupt Scheduler cannot be 'No'");
	     end if;
          else
             Mast.Scheduling_Parameters.set_preassigned
               (Mast.Scheduling_Parameters.Fixed_Priority_Parameters'Class
                    (Sched_params_ref.all), YYVal.flag);
          end if;
      }
      ;
fp_policy_priority :
        comma the_priority arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Mast.Scheduling_Parameters.set_the_priority
             (Mast.Scheduling_Parameters.Fixed_Priority_Parameters'Class
                    (Sched_params_ref.all),
              MAST.Priority(YYval.num));
           if not Preassigned_Field_Present then
              Mast.Scheduling_Parameters.set_preassigned
                (Mast.Scheduling_Parameters.Fixed_Priority_Parameters'Class
                     (Sched_params_ref.all), True);
           end if;
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;
      }
      ;
non_preemptible_policy_item :
      left_paren non_preemptible_policy_type
      {
          sched_params_ref:=
               new Mast.Scheduling_Parameters.non_preemptible_fp_policy;
          Preassigned_Field_Present:=False;
      }
      non_preemptible_policy_termination
      ;
non_preemptible_policy_type :
      the_type arrow non_preemptible_fp_policy
      ;
non_preemptible_policy_termination :
        right_paren
      | non_preemptible_policy_arguments right_paren
      ;
non_preemptible_policy_arguments :
        non_preemptible_policy_argument
      | non_preemptible_policy_arguments non_preemptible_policy_argument
      ;
non_preemptible_policy_argument :
        fp_policy_priority
      | preassigned_param
      ;
interrupt_policy_item :
      left_paren interrupt_policy_type
      {
          sched_params_ref:=
               new Mast.Scheduling_Parameters.interrupt_fp_policy;
          Preassigned_Field_Present:=False;
          Mast.Scheduling_Parameters.set_preassigned
             (Mast.Scheduling_Parameters.Fixed_Priority_Parameters'Class
                  (Sched_params_ref.all), True);
      }
      interrupt_policy_termination
      ;
interrupt_policy_type :
      the_type arrow interrupt_fp_policy
      ;
interrupt_policy_termination :
        right_paren
      | interrupt_policy_arguments right_paren
      ;
interrupt_policy_arguments :
        interrupt_policy_argument
      | interrupt_policy_arguments interrupt_policy_argument
      ;
interrupt_policy_argument :
        fp_policy_priority
      | preassigned_param
      ;
polling_policy_item :
      left_paren polling_policy_type
      {
          sched_params_ref:=new Mast.scheduling_Parameters.polling_policy;
          Preassigned_Field_Present:=False;
      }
      polling_policy_arguments right_paren
      ;
polling_policy_type :
      the_type arrow polling_policy
      ;
polling_policy_arguments :
        polling_policy_argument
      | polling_policy_arguments polling_policy_argument
      ;
polling_policy_argument :
        fp_policy_priority
      | preassigned_param
      | polling_policy_period
      | polling_policy_worst_overhead
      | polling_policy_best_overhead
      | polling_policy_avg_overhead
      ;
polling_policy_period :
        comma polling_period arrow number
      {
        Mast.Scheduling_Parameters.set_polling_period
             (Mast.Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Time(YYval.float_num));
      }
      ;
polling_policy_worst_overhead :
        comma polling_worst_overhead arrow number
      {
        Mast.Scheduling_Parameters.set_polling_worst_overhead
             (Mast.Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));
      }
      ;
polling_policy_best_overhead :
        comma polling_best_overhead arrow number
      {
        Mast.Scheduling_Parameters.set_polling_best_overhead
             (Mast.Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));
      }
      ;
polling_policy_avg_overhead :
        comma polling_avg_overhead arrow number
      {
        Mast.Scheduling_Parameters.set_polling_avg_overhead
             (Mast.Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));
      }
      ;
sporadic_server_policy_item :
      left_paren sporadic_server_policy_type
      {
          sched_params_ref:=
             new Mast.scheduling_parameters.sporadic_server_policy;
          Preassigned_Field_Present:=False;
      }
      sporadic_server_policy_arguments right_paren
      ;
sporadic_server_policy_type :
      the_type arrow sporadic_server_policy
      ;
sporadic_server_policy_arguments :
        sporadic_server_policy_argument
      | sporadic_server_policy_arguments sporadic_server_policy_argument
      ;
sporadic_server_policy_argument :
        sporadic_server_normal_priority
      | preassigned_param
      | sporadic_server_background_priority
      | sporadic_server_initial_capacity
      | sporadic_server_replenishment_period
      | sporadic_server_max_pending_replenishments
      ;

sporadic_server_normal_priority :
        comma normal_priority arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Mast.Scheduling_Parameters.set_the_priority
             (Mast.Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              MAST.Priority(YYval.num));
           if not Preassigned_Field_Present then
              Mast.Scheduling_Parameters.set_preassigned
                (Mast.Scheduling_Parameters.Fixed_Priority_Parameters'Class
                     (Sched_params_ref.all), True);
           end if;
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;
      }
      ;
sporadic_server_background_priority :
        comma background_priority arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Mast.Scheduling_Parameters.set_background_priority
             (Mast.Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              MAST.Priority(YYval.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;
      }
      ;
sporadic_server_initial_capacity :
        comma initial_capacity arrow number
      {
        Mast.Scheduling_Parameters.set_initial_capacity
             (Mast.Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              MAST.Time(YYval.float_num));
      }
      ;
sporadic_server_replenishment_period :
        comma replenishment_period arrow number
      {
        Mast.Scheduling_Parameters.set_replenishment_period
             (Mast.Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              MAST.Time(YYval.float_num));
      }
      ;
sporadic_server_max_pending_replenishments :
        comma max_pending_replenishments arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Max pending replenishments should be integer value");
        end if;
        Mast.Scheduling_Parameters.set_max_pending_replenishments
             (Mast.Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              YYval.num);
      }
      ;
edf_policy_item :
      left_paren edf_policy_type
      {
          sched_params_ref:=new Mast.Scheduling_Parameters.edf_policy;
          Preassigned_Field_Present:=False;
      }
      edf_policy_termination
      ;
edf_policy_type :
      the_type arrow edf_policy
      ;
edf_policy_termination :
        right_paren
      | edf_policy_arguments right_paren
      ;    
edf_policy_arguments :
        edf_policy_argument
      | edf_policy_arguments edf_policy_argument
      ;
edf_policy_argument :
        edf_deadline
      | edf_preassigned_param
      ;
edf_preassigned_param :
        comma preassigned arrow yes_no
      {
          Preassigned_Field_Present:=True;
          Mast.Scheduling_Parameters.set_preassigned
               (Mast.Scheduling_Parameters.Edf_Policy'Class
                    (Sched_params_ref.all), YYVal.flag);
      }
      ;
edf_deadline :
        comma deadline arrow number
      {
           Mast.Scheduling_Parameters.set_deadline
             (Mast.Scheduling_Parameters.EDF_Policy'Class
                    (Sched_params_ref.all),
              MAST.Time(YYval.Float_num));
           if not Preassigned_Field_Present then
              Mast.Scheduling_Parameters.set_preassigned
                (Mast.Scheduling_Parameters.EDF_Policy'Class
                     (Sched_params_ref.all), True);
           end if;
      }
      ;

------------------------------------
--  Synchronization Parameters
------------------------------------

synchronization_parameters_item :
        srp_parameters_item
      ;
srp_parameters_item :
      left_paren srp_parameters_type
      {
          synch_params_ref:=new Mast.Synchronization_Parameters.SRP_Parameters;
          Preassigned_Field_Present:=False;
      }
      srp_parameters_termination
      ;
srp_parameters_type :
      the_type arrow srp_parameters
      ;
srp_parameters_termination :
        right_paren
      | srp_parameters_arguments right_paren
      ;    
srp_parameters_arguments :
        srp_parameters_argument
      | srp_parameters_arguments srp_parameters_argument
      ;
srp_parameters_argument :
        preemption_level_arg
      | srp_preassigned_param
      ;
srp_preassigned_param :
        comma preassigned arrow yes_no
      {
          Preassigned_Field_Present:=True;
          Mast.Synchronization_Parameters.set_preassigned
               (Mast.Synchronization_Parameters.SRP_Parameters'Class
                    (Synch_params_ref.all), YYVal.flag);
      }
      ;
preemption_level_arg :
        comma the_preemption_level arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Preemption level should be integer value");
        end if;
        begin
           Mast.Synchronization_Parameters.set_preemption_level
             (Mast.Synchronization_Parameters.SRP_Parameters'Class
                    (Synch_params_ref.all),
              MAST.Preemption_Level(YYval.num));
           if not Preassigned_Field_Present then
              Mast.Synchronization_Parameters.set_preassigned
                (Mast.Synchronization_Parameters.SRP_Parameters'Class
                     (Synch_params_ref.all), True);
           end if;
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Preemption level value out of range");
        end;
      }
      ;

------------------------------------
--  Transactions
------------------------------------

transaction_object : 
      transaction left_paren tr_arguments right_paren semicolon
      ;
tr_arguments :
        tr_argument
      | tr_arguments comma tr_argument
      ;
tr_argument :
        tr_name_arg
      | tr_results_arg
      ;
tr_name_arg :
      name arrow identifier
      {
	--find the transaction
        declare
	  The_Index : Transactions.Lists.Index;
        begin
	  The_Index:=Transactions.Lists.Find
	    (Symbol_Table.Item(YYVal.Name_Index),
             Mast_System.Transactions);
	     Tr_Ref:=Transactions.Lists.Item
		    (The_Index,Mast_System.Transactions);
          exception
             when List_Exceptions.Invalid_Index =>
                -- create dummy transaction
	        Tr_Ref:=new Transactions.Regular_Transaction;
                User_Defined_Errors.Parser_Error
                  (To_String("Transaction "&
                   Symbol_Table.Item(YYVal.Name_Index)&" not found"));
	  end;
      }
      ;
tr_results_arg :
      results arrow left_paren tr_results right_paren
      ;
tr_results :
        tr_results comma tr_result
      | tr_result
      ;
tr_result :
        tr_slack_result
      | tr_timing_result
      | tr_simulation_timing_result
      ;
tr_slack_result :
      left_paren the_type arrow slack comma
      {
        The_Slack_res:=new Mast.Results.Slack_Result;
	Transactions.Set_Slack_Result(Tr_Ref.all,The_Slack_Res);
      }
      value arrow number right_paren
      {
	Mast.Results.Set_Slack(The_Slack_Res.all,Float(YYVal.Float_Num));
      }   
      ;
tr_timing_result :
      left_paren the_type arrow timing_result comma
      {
          The_Timing_Res:=new Mast.Results.Timing_Result;
      }
      tr_timing_result_args right_paren
      ;
tr_timing_result_args :
        tr_timing_result_arg
      | tr_timing_result_args comma tr_timing_result_arg
      ;
tr_timing_result_arg :
        tr_event_name_arg
      | tr_wlrt_arg
      | tr_blrt_arg
      | tr_wbt_arg
      | tr_ns_arg
      | tr_wgrt_arg
      | tr_bgrt_arg
      | tr_jit_arg
      ;
tr_event_name_arg :
      event_name arrow identifier
      {
        declare
           The_Link : MAST.Graphs.Link_Ref;
        begin
           --find the link
	  The_Link:=Transactions.Find_Internal_Event_Link
	    (Symbol_Table.Item(YYVal.Name_Index),
             Tr_Ref.all);
          MAST.Graphs.Links.Set_Link_Time_Results
              (Mast.Graphs.Links.Regular_Link(The_Link.all),
              The_Timing_Res);
          Mast.Results.Set_Link
             (The_Timing_Res.all,The_Link);
        exception
                -- create dummy link
             when Transactions.Link_Not_Found =>
                User_Defined_Errors.Parser_Error
                  (To_String("Event "&
                   Symbol_Table.Item(YYVal.Name_Index)&
                   " not found in transaction "&
                   Transactions.Name(Tr_Ref)));
        end;
      }   
      ;
tr_wlrt_arg :
      worst_local_response_time arrow number
      {
	Mast.Results.Set_Worst_Local_Response_Time
          (The_Timing_Res.all, Time(YYVal.Float_Num));
      }   
      ;
tr_blrt_arg :
      best_local_response_time arrow number
      {
	Mast.Results.Set_Best_Local_Response_Time
          (The_Timing_Res.all, Time(YYVal.Float_Num));
      }   
      ;
tr_wbt_arg :
      worst_blocking_time arrow number
      {
	Mast.Results.Set_Worst_Blocking_Time
          (The_Timing_Res.all, Time(YYVal.Float_Num));
      }   
      ;
tr_ns_arg :
      num_of_suspensions arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Num_Of_Suspensions should be integer value");
        end if;
	Mast.Results.Set_Num_Of_Suspensions
          (The_Timing_Res.all, YYVal.Num);
      }
      ;
tr_wgrt_arg :
      worst_global_response_times arrow 
      left_paren worst_global_response_time_list right_paren
      ;
worst_global_response_time_list :
        worst_global_response_time_item
      | worst_global_response_time_list comma worst_global_response_time_item
      ;
worst_global_response_time_item :
      left_paren worst_global_response_time_args right_paren
      ;
worst_global_response_time_args :
        referenced_event_arg comma wg_time_value_arg
      ;
wg_time_value_arg :
        time_value arrow number
      {
        Mast.Results.set_worst_global_response_time
          (The_Timing_Res.all, The_Event_Ref, MAST.Time(YYval.float_num));
      }
      ;
referenced_event_arg :
        referenced_event arrow identifier
      {
         declare
            a_name : Var_String;
         begin
             a_name:=symbol_table.item(YYVal.name_index);
             The_Event_Ref:=Transactions.Find_Any_Event (A_name,Tr_Ref.all);
         exception
             when Transactions.Event_Not_Found =>
                User_Defined_Errors.Parser_Error
                    ("Event name "&To_String(a_name)&" not found");
         end;
      }
      ;
tr_bgrt_arg :
      best_global_response_times arrow 
      left_paren best_global_response_time_list right_paren
      ;
best_global_response_time_list :
        best_global_response_time_item
      | best_global_response_time_list comma best_global_response_time_item
      ;
best_global_response_time_item :
      left_paren best_global_response_time_args right_paren
      ;
best_global_response_time_args :
        referenced_event_arg comma bg_time_value_arg
      ;
bg_time_value_arg :
        time_value arrow number
      {
        Mast.Results.set_best_global_response_time
          (The_Timing_Res.all, The_Event_Ref, MAST.Time(YYval.float_num));
      }
      ;
tr_jit_arg :
      jitters arrow left_paren jitter_list right_paren
      ;
jitter_list :
        jitter_item
      | jitter_list comma jitter_item
      ;
jitter_item :
      left_paren jitter_args right_paren
      ;
jitter_args :
        referenced_event_arg comma jit_time_value_arg
      ;
jit_time_value_arg :
        time_value arrow number
      {
        Mast.Results.set_jitter
          (The_Timing_Res.all, The_Event_Ref, MAST.Time(YYval.float_num));
      }
      ;

tr_simulation_timing_result :
      left_paren the_type arrow simulation_timing_result comma
      {
          The_Timing_Res:=new Mast.Results.Simulation_Timing_Result;
      }
      tr_sim_timing_result_args right_paren
      ;
tr_sim_timing_result_args :
        tr_sim_timing_result_arg
      | tr_sim_timing_result_args comma tr_sim_timing_result_arg
      ;
tr_sim_timing_result_arg :
        tr_event_name_arg
      | tr_wlrt_arg
      | trs_alrt_arg
      | tr_blrt_arg
      | tr_wbt_arg
      | trs_abt_arg
      | tr_ns_arg
      | trs_mpt_arg
      | trs_st_arg
      | trs_nqa_arg
      | tr_wgrt_arg
      | trs_agrt_arg
      | tr_bgrt_arg
      | tr_jit_arg
      | trs_lmr_arg
      | trs_gmr_arg
      ;
trs_alrt_arg :
      avg_local_response_time arrow number
      {
	Mast.Results.Set_Local_Simulation_Time
          (Mast.Results.Simulation_Timing_Result
            (The_Timing_Res.all), (Time(YYVal.Float_Num),1));
      }   
      ;
trs_abt_arg :
      avg_blocking_time arrow number
      {
	Mast.Results.Set_Avg_Blocking_Time
          (Mast.Results.Simulation_Timing_Result
            (The_Timing_Res.all), Time(YYVal.Float_Num));
      }   
      ;
trs_mpt_arg :
      max_preemption_time arrow number
      {
	Mast.Results.Set_Max_Preemption_Time
          (Mast.Results.Simulation_Timing_Result
            (The_Timing_Res.all), Time(YYVal.Float_Num));
      }
      ;
trs_st_arg :
      suspension_time arrow number
      {
	Mast.Results.Set_Suspension_Time
          (Mast.Results.Simulation_Timing_Result
            (The_Timing_Res.all), Time(YYVal.Float_Num));
      }
      ;
trs_nqa_arg :
      num_of_queued_activations arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Num_Of_Queued_Activations should be integer value");
        end if;
	Mast.Results.Set_Num_Of_Queued_Activations
          (Mast.Results.Simulation_Timing_Result
            (The_Timing_Res.all), YYVal.Num);
      }
      ;
trs_agrt_arg :
      avg_global_response_times arrow 
      left_paren avg_global_response_time_list right_paren
      ;
avg_global_response_time_list :
        avg_global_response_time_item
      | avg_global_response_time_list comma avg_global_response_time_item
      ;
avg_global_response_time_item :
      left_paren avg_global_response_time_args right_paren
      ;
avg_global_response_time_args :
        referenced_event_arg comma ag_time_value_arg
      ;
ag_time_value_arg :
        time_value arrow number
      {
        Mast.Results.Set_global_simulation_time
          (Mast.Results.Simulation_Timing_Result
            (The_Timing_Res.all), The_Event_Ref, 
            (MAST.Time(YYval.float_num),1));
      }
      ;

trs_lmr_arg :
      local_miss_ratios arrow left_paren local_mr_list right_paren
      ;
local_mr_list :
        local_mr_item
      | local_mr_list comma local_mr_item
      ;
local_mr_item :
      left_paren deadline_mr_arg comma ratio_mr_arg right_paren
      ;
deadline_mr_arg :
      deadline arrow number
      {
         A_Deadline:=MAST.Time(YYval.float_num);
      }
      ;
ratio_mr_arg :
      ratio arrow number
      {
         declare
            The_Ratio : Float;
         begin
            The_Ratio:=Float(YYval.float_num);
            Mast.results.set_local_miss_ratio
             (Mast.Results.Simulation_Timing_Result
               (The_Timing_Res.all), A_Deadline, 
                 (Integer(The_Ratio*1.0E6),1E8));
         end;
      }
      ;
trs_gmr_arg :
      global_miss_ratios arrow left_paren global_mr_list right_paren
      ;
global_mr_list :
        global_mr_item
      | global_mr_list comma global_mr_item
      ;
global_mr_item :
      left_paren referenced_event_arg comma miss_ratios_arg right_paren
      ;
miss_ratios_arg :
      miss_ratios arrow left_paren miss_ratios_list right_paren
      ;
miss_ratios_list :
        miss_ratios_item
      | miss_ratios_list comma miss_ratios_item
      ;
miss_ratios_item :
      left_paren deadline_mr_arg comma glob_ratio_mr_arg right_paren
      ;
glob_ratio_mr_arg :
      ratio arrow number
      {
         declare
            The_Ratio : Float;
         begin
            The_Ratio:=Float(YYval.float_num);
            Mast.results.set_global_miss_ratio
             (Mast.Results.Simulation_Timing_Result
               (The_Timing_Res.all), A_Deadline, The_Event_Ref,
                (Integer(The_Ratio*1.0E6),1E8));
         end;
      }
      ;

------------------------------------
--  Scheduling_Servers
------------------------------------

server_object : 
      scheduling_server left_paren ss_arguments right_paren semicolon
      ;
ss_arguments :
        ss_argument
      | ss_arguments comma ss_argument
      ;
ss_argument :
        ss_name_arg
      | ss_results_arg
      ;
ss_name_arg :
      name arrow identifier
      {
	--find the scheduling_server
        declare
	  The_Index : Mast.Scheduling_Servers.Lists.Index;
        begin
	  The_Index:=Mast.Scheduling_Servers.Lists.Find
	    (Symbol_Table.Item(YYVal.Name_Index),
             Mast_System.Scheduling_Servers);
	     SS_Ref:=Mast.Scheduling_Servers.Lists.Item
		    (The_Index,Mast_System.Scheduling_Servers);             
          exception
             when List_Exceptions.Invalid_Index =>
                -- create dummy scheduling_server
	        SS_Ref:=new Mast.Scheduling_Servers.Scheduling_Server;
                User_Defined_Errors.Parser_Error
                  (To_String("Scheduling Server "&
                   Symbol_Table.Item(YYVal.Name_Index)&" not found"));
	  end;
      }
      ;
ss_results_arg :
      results arrow left_paren ss_results right_paren
      ;
ss_results :
        ss_results comma ss_result
      | ss_result
      ;
ss_result :
        ss_sched_param_result
      | ss_synch_param_result
      ;
ss_sched_param_result :
      left_paren the_type arrow scheduling_parameters comma
      {
        The_SP_Res:=new Mast.Results.Sched_Params_Result;
	Mast.Scheduling_Servers.Set_Sched_Params_Result(SS_Ref.all,The_SP_Res);
      }
      server_sched_parameters arrow scheduling_parameters_item right_paren
      {
	Mast.Results.Set_Sched_Params(The_SP_Res.all,Sched_Params_Ref);
      }   
      ;
ss_synch_param_result :
      left_paren the_type arrow synchronization_parameters comma
      {
        The_SynchP_Res:=new Mast.Results.Synch_Params_Result;
	Mast.Scheduling_Servers.Set_Synch_Params_Result
           (SS_Ref.all,The_SynchP_Res);
      }
      server_synch_parameters arrow synchronization_parameters_item right_paren
      {
	Mast.Results.Set_Synch_Params(The_SynchP_Res.all,Synch_Params_Ref);
      }   
      ;


------------------------------------
--  Code sections
------------------------------------

%%
with MAST, MAST.Operations, MAST.Shared_Resources, 
  MAST.Processing_Resources, MAST.Processing_Resources.Processor,
  MAST.Scheduling_Servers, MAST.IO,
  MAST.Transactions, 
  MAST.Systems, 
  MAST.Scheduling_Parameters, MAST.Synchronization_Parameters,
  MAST.Results,
  MAST.Events, MAST.Graphs, MAST.Graphs.Links,
  List_Exceptions;
with Symbol_Table; use Symbol_Table;
with MAST_Results_lex; Use MAST_REsults_Lex;
with Var_Strings; use Var_Strings;
with MAST_Results_Parser_Tokens, MAST_Results_Parser_Shift_Reduce,
  MAST_Results_Parser_Goto,MAST_Results_Parser_Error_Report,
  MAST_Results_Lex_IO, MAST_Results_Lex_Dfa;
with Text_IO; use Text_IO;
use MAST_Results_Parser_Tokens, MAST_Results_Parser_Shift_Reduce,
  MAST_Results_Parser_Goto,MAST_Results_Lex_IO;
use MAST;
procedure MAST_Results_Parser (MAST_System : in out MAST.Systems.System) is

      procedure YYError (S : in String) is  
      begin
          MAST_Results_Parser_Error_Report.Report_Continuable_Error
                 (YY_Line_Number, YY_Begin_Column, YY_End_Column, S, True);
      end YYError;

      PR_Ref                : Processing_Resources.Processing_Resource_Ref;
      SR_Ref                : Shared_Resources.Shared_Resource_Ref; 
      Op_Ref                : Operations.Operation_Ref;
      SS_Ref                : Scheduling_Servers.Scheduling_Server_Ref;
      Sched_Params_Ref      : Mast.Scheduling_Parameters.Sched_Parameters_Ref;
      Synch_Params_Ref      : 
            Mast.Synchronization_Parameters.Synch_Parameters_Ref;
      Tr_Ref                : Transactions.Transaction_Ref;
      The_Event_Ref         : MAST.Events.Event_Ref;
      A_Deadline            : Time;
 
      The_trace_Res : Mast.Results.Trace_Result_Ref;
      The_Slack_Res : Mast.Results.Slack_Result_Ref;
      The_Utilization_res : Mast.Results.Utilization_Result_Ref;
      The_Queue_Size_Res : MAST.results.Queue_Size_Result_Ref;
      The_Ceiling_Res : Mast.results.Ceiling_Result_Ref;
      The_Preemption_Level_Res : Mast.results.Preemption_Level_Result_Ref;
      The_SP_Res : Mast.Results.Sched_Params_Result_Ref;
      The_SynchP_Res : Mast.Results.Synch_Params_Result_Ref;
      The_Timing_Res : Mast.Results.Timing_Result_Ref;
     
      preassigned_field_present : Boolean:=False;

      use type Operations.Lists.Index;
      use type Processing_resources.Lists.Index;
      use type Shared_resources.Lists.Index;
      use type Scheduling_Servers.Lists.Index;

##

begin 
     Mast_Results_Lex_dfa.yy_init:=true;
     Mast_Results_Lex_dfa.yy_start:=0;
     Mast_Results_Lex_IO.Saved_Tok_Line1:=null;
     Mast_Results_Lex_IO.Saved_Tok_Line2:=null;
     Mast_Results_Lex_IO.Line_Number_Of_Saved_Tok_Line1:=0;
     Mast_Results_Lex_IO.Line_Number_Of_Saved_Tok_Line2:=0;
     Mast_Results_Lex_IO.tok_begin_line:=1;
     Mast_Results_Lex_IO.tok_end_line:=1;
     Mast_Results_Lex_IO.tok_begin_col:=0;
     Mast_Results_Lex_IO.tok_end_col:=0;
     Mast_Results_Lex_IO.token_at_end_of_line:=False;
     Mast_Results_Parser_Error_Report.Total_Errors:=0;
     Mast_Results_Parser_Error_Report.Total_Warnings:=0;
     YYparse;
end MAST_Results_Parser;



%%

%with text_io;
%use text_io;

%initialize_error_report
begin
     put_line("Initializing error report...");
end;

%terminate_error_report
begin
    if Total_Errors > 0 then
       Text_IO.Put_Line("**************************************************");
       Text_IO.Put_Line("Error list output in file: mast_results_parser.lis");
       Text_IO.Put_Line("**************************************************");
    end if;
end;

%report_error
    Msg : String:="  Error at line"&Integer'Image(line_number)&
              " Col:"&Integer'Image(Offset)&"-"&Integer'Image(Finish)
              &": "&message;
begin
     Text_IO.put_line(Msg);
     Put_Line("");
     Put_Line(Msg);
end;
