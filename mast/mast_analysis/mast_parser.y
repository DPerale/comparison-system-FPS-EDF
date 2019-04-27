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

%token    model_name
%token    model_date
%token    model
%token    processing_resource
%token    the_type
%token    fixed_priority_processor
%token    fixed_priority_network
%token    name
%token    max_priority
%token    min_priority
%token    max_interrupt_priority
%token    min_interrupt_priority
%token    worst_context_switch
%token    avg_context_switch
%token    best_context_switch
%token    worst_isr_switch
%token    avg_isr_switch
%token    best_isr_switch
%token    worst_overhead
%token    avg_overhead
%token    best_overhead
%token    system_timer
%token    alarm_clock
%token    ticker
%token    speed_factor
%token    packet_worst_overhead
%token    packet_avg_overhead
%token    packet_best_overhead
%token    transmission
%token    trans_kind
%token    list_of_drivers
%token    max_blocking
%token    max_packet_transmission_time
%token    min_packet_transmission_time
%token    packet_driver
%token    character_packet_driver
%token    packet_server
%token    packet_receive_operation
%token    packet_send_operation
%token    character_server
%token    character_receive_operation
%token    character_send_operation
%token    character_transmission_time

%token    shared_resource
%token    immediate_ceiling_resource
%token    ceiling
%token    priority_inheritance_resource

%token    operation
%token    simple
%token    composite
%token    enclosing
%token    worst_case_execution_time
%token    avg_case_execution_time
%token    best_case_execution_time
%token    shared_resources_list
%token    shared_resources_to_lock
%token    shared_resources_to_unlock
%token    composite_operation_list

%token    external_events
%token    periodic
%token    singular
%token    aperiodic
%token    sporadic
%token    unbounded_ev
%token    bursty
%token    period
%token    max_jitter
%token    phase
%token    avg_interarrival
%token    distribution
%token    dist_function
%token    min_interarrival
%token    bound_interval
%token    max_arrivals
%token    referenced_event
%token    transaction
%token    event_handlers
%token    internal_events

%token    scheduling_server
%token    fixed_priority
%token    new_sched_parameters
%token    server_sched_parameters
%token    server_processing_resource

%token    hard_global_deadline
%token    soft_global_deadline
%token    deadline
%token    hard_local_deadline
%token    soft_local_deadline
%token    global_max_miss_ratio
%token    local_max_miss_ratio
%token    max_output_jitter_req
%token    max_output_jitter
%token    requirements_list
%token    ratio

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
%token    overridden_fixed_priority
%token    overridden_permanent_fp
%token    activity_operation
%token    input_event
%token    output_event
%token    timing_requirements
%token    activity_server
%token    activity
%token    system_timed_activity
%token    concentrator
%token    input_events_list
%token    barrier
%token    delivery_server
%token    delivery_policy
%token    request_policy
%token    query_server
%token    output_events_list
%token    multicast
%token    rate_divisor
%token    rate_factor
%token    the_delay
%token    delay_max_interval
%token    delay_min_interval
%token    offset
%token    event

%token    regular
%token    link

-------------------
-- Mast 1.3 tokens
-------------------

%token    regular_processor
%token    packet_based_network

%token    scheduler
%token    primary_scheduler
%token    secondary_scheduler
%token    policy
%token    host
%token    server

%token    edf
%token    fp_packet_based

%token    edf_policy

%token    srp_parameters
%token    the_preemption_level

%token    the_synchronization_parameters

%token    srp_resource

%token    throughput
%token    max_packet_size
%token    min_packet_size
%token    message_transmission
%token    max_message_size
%token    avg_message_size
%token    min_message_size
%token    packet_overhead_max_size
%token    packet_overhead_avg_size
%token    packet_overhead_min_size
%token    system_pip_behaviour
%token    pip_behaviour

%token    rtep_packet_driver
%token    number_of_stations
%token    token_delay
%token    failure_timeout
%token    token_transmission_retries
%token    packet_transmission_retries
%token    packet_interrupt_server
%token    packet_isr_operation
%token    token_check_operation
%token    token_manage_operation
%token    packet_discard_operation
%token    token_retransmission_operation
%token    packet_retransmission_operation

%token    message_partitioning
%token    rta_overhead_model
%token    rta_overhead_model_value

--------------------------

%with          Symbol_Table;
%use           Symbol_Table;
{
  type Real_Number is digits 15;

  type YYstype is record
    num        : Integer;
    float_num  : Real_Number;
    Is_Float   : Boolean;
    name_index : Symbol_Table.Index;
    flag       : Boolean;
    date       : String(1..19);
  end record; 
}

%%

------------------------------------
--  MAST System
------------------------------------

mast_rt_situation :
    mast_system
    {
        begin
           Mast.Systems.Adjust(Mast_System);
        exception
           when Mast.Object_Not_Found =>
              User_Defined_Errors.Parser_Error(Mast.Get_Exception_Message);
        end;
    }  
    ;
mast_system :
      mast_system mast_object
    | mast_object
    ;
mast_object : 
      model_object
    | processing_resource_object 
    | scheduler_object
    | shared_resource_object
    | operation_object
    | transaction_object
    | scheduling_server_object
    ;

------------------------------------
--  Model
------------------------------------

model_object :
      model left_paren model_arguments right_paren semicolon
      ;
model_arguments :
        model_argument
      | model_arguments comma model_argument
      ;
model_argument :
        model_name_arg
      | model_date_arg
      | system_pip_behaviour_arg
      ;
model_name_arg :
      model_name arrow identifier
      {
	Mast_System.Model_Name:=symbol_table.item(YYVal.name_index);
      }
      ;
model_date_arg :
      model_date arrow date
      {
	Mast_System.Model_Date:=YYVal.date;
        if not Mast.IO.Is_Date_OK(Mast_System.Model_Date) then
	    User_Defined_Errors.Parser_Error
                 ("Error in date value");
        end if;
      }
      ;
system_pip_behaviour_arg :
      system_pip_behaviour arrow pip_behaviour
      {
	if YYVal.flag then
	    Mast_System.System_Pip_Behaviour:=(Mast.Systems.Strict);
	else
	    Mast_System.System_Pip_Behaviour:=(Mast.Systems.Posix);
	end if;
      }
      ;

------------------------------------
--  Processing resources
------------------------------------

processing_resource_object :
      fixed_priority_processor_object
    | fixed_priority_network_object
    | regular_processor_object
    | pb_network_object
    ;

------------------------------------
--  Fixed_Priority_Processor_Object
------------------------------------

fixed_priority_processor_object : 
      processing_resource left_paren fixed_priority_processor_type
      {
          processing_res_ref:=
             new Processing_resources.Processor.Regular_Processor;
          scheduler_ref:=
	     new Schedulers.Primary.Primary_Scheduler;
	  Schedulers.Primary.Set_Host
            (Schedulers.Primary.Primary_Scheduler(Scheduler_Ref.all),
             processing_res_ref);
          sched_policy_ref:=
	     new Scheduling_Policies.Fixed_Priority;
	  Schedulers.Set_Scheduling_Policy
	    (Scheduler_Ref.all,Sched_Policy_Ref);
      }
      fixed_priority_processor_arguments right_paren semicolon
      ;
fixed_priority_processor_type :
      the_type arrow fixed_priority_processor
      ;
fixed_priority_processor_arguments :
        fp_processing_resource_name
      | fixed_priority_processor_arguments fixed_priority_processor_argument
      ;
fixed_priority_processor_argument :
        processing_resource_max_priority
      | processing_resource_min_priority
      | fp_processor_max_interrupt_priority
      | fp_processor_min_interrupt_priority
      | fixed_priority_processor_wcs
      | fixed_priority_processor_acs
      | fixed_priority_processor_bcs
      | fixed_priority_processor_wisrs
      | fixed_priority_processor_aisrs
      | fixed_priority_processor_bisrs
      | fixed_priority_processor_systimer
      | fixed_priority_processor_sf
      ;
fp_processing_resource_name :
        comma name arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Processing_Resources.init(processing_res_ref.all,a_name);
          begin
             Processing_resources.lists.add
               (processing_res_ref,mast_system.processing_resources);
          exception
	    when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Processing resource already exists");                
          end;
          Schedulers.init(Scheduler_ref.all,a_name);
          begin
             Schedulers.lists.add
               (scheduler_ref,mast_system.schedulers);
          exception
	    when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Scheduler already exists");                
          end;
      }
      ;
fixed_priority_processor_wcs :
        comma worst_context_switch arrow number
      {
        Scheduling_Policies.set_worst_context_switch
             (Scheduling_Policies.fixed_priority'Class
              (sched_policy_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));
      }
      ;
processing_resource_max_priority :
        comma max_priority arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Scheduling_Policies.set_max_priority
             (Scheduling_Policies.Fixed_Priority_Policy'class
               (sched_policy_ref.all),MAST.Priority(YYval.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;
      }
      ;
processing_resource_min_priority :
        comma min_priority arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Scheduling_Policies.set_min_priority
             (Scheduling_Policies.Fixed_Priority_Policy'class
              (sched_policy_ref.all),MAST.Priority(YYval.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;
      }
      ;
fp_processor_max_interrupt_priority :
        comma max_interrupt_priority arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Processing_Resources.Processor.set_max_interrupt_priority
             (Processing_resources.Processor.Regular_Processor'Class
              (processing_res_ref.all),MAST.Priority(YYval.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;
      }
      ;
fp_processor_min_interrupt_priority :
        comma min_interrupt_priority arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Processing_Resources.Processor.set_min_interrupt_priority
             (Processing_resources.Processor.Regular_Processor'Class
              (processing_res_ref.all),MAST.Priority(YYval.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;
      }
      ;
fixed_priority_processor_acs :
        comma avg_context_switch arrow number
      {
        Scheduling_Policies.set_avg_context_switch
             (Scheduling_Policies.fixed_priority'Class
              (sched_policy_ref.all),
              MAST.Normalized_Execution_Time(YYVal.float_num));
      }
      ;
fixed_priority_processor_bcs :
        comma best_context_switch arrow number
      {
        Scheduling_Policies.set_best_context_switch
             (Scheduling_Policies.fixed_priority'Class
              (sched_policy_ref.all),
              MAST.Normalized_Execution_Time(YYVal.float_num));
      }
      ;
fixed_priority_processor_wisrs :
        comma worst_isr_switch arrow number
      {
        Processing_Resources.processor.set_worst_isr_switch
             (Processing_resources.Processor.Regular_Processor'Class
              (processing_res_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));
      }
      ;
fixed_priority_processor_aisrs :
        comma avg_isr_switch arrow number
      {
        Processing_Resources.processor.set_avg_isr_switch
             (Processing_resources.processor.regular_processor'class
              (processing_res_ref.all),
              MAST.Normalized_Execution_Time(YYVal.float_num));
      }
      ;
fixed_priority_processor_bisrs :
        comma best_isr_switch arrow number
      {
        Processing_Resources.processor.set_best_isr_switch
             (Processing_resources.processor.regular_processor'class
              (processing_res_ref.all),
              MAST.Normalized_Execution_Time(YYVal.float_num));
      }
      ;
fixed_priority_processor_systimer :
        comma system_timer arrow a_timer
      {
        Processing_Resources.Processor.set_system_timer
             (Processing_resources.Processor.Regular_Processor'Class
              (processing_res_ref.all),A_Timer_Ref);
      }
      ;
fixed_priority_processor_sf :
        comma speed_factor arrow number
      {
        Processing_Resources.set_speed_factor(processing_res_ref.all,
              Mast.Processor_Speed(YYVal.float_num));
      }
      ;

------------------------------------
--  Regular_Processor_Object
------------------------------------

regular_processor_object : 
      processing_resource left_paren regular_processor_type
      {
          processing_res_ref:=
             new Processing_resources.Processor.Regular_Processor;
      }
      processor_arguments right_paren semicolon
      ;
regular_processor_type :
      the_type arrow regular_processor
      ;
processor_arguments :
        processing_resource_name
      | processor_arguments processor_argument
      ;
processor_argument :
        fp_processor_max_interrupt_priority
      | fp_processor_min_interrupt_priority
      | fixed_priority_processor_wisrs
      | fixed_priority_processor_aisrs
      | fixed_priority_processor_bisrs
      | fixed_priority_processor_systimer
      | fixed_priority_processor_sf
      ;
processing_resource_name :
        comma name arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Processing_Resources.init(processing_res_ref.all,a_name);
          begin
             Processing_resources.lists.add
               (processing_res_ref,mast_system.processing_resources);
          exception
	    when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Processing resource already exists");                
          end;
      }
      ;

------------------------------------
--  System_Timer_Object
------------------------------------
a_timer : 
        ticker_timer
      | alarm_clock_timer
      ;
alarm_clock_timer :
      left_paren alarm_clock_type
      {
          A_Timer_Ref:=new Timers.Alarm_Clock;
      }
      alarm_clock_arguments right_paren
      ;
alarm_clock_type :
      the_type arrow alarm_clock
      ;
alarm_clock_arguments :
        alarm_clock_argument
      | alarm_clock_arguments alarm_clock_argument
      ;
alarm_clock_argument :
        timer_worst_overhead
      | timer_best_overhead
      | timer_avg_overhead
      ;
timer_worst_overhead :
        comma worst_overhead arrow number
      {
        Timers.set_worst_overhead
	  (A_Timer_Ref.all,MAST.Normalized_Execution_Time(YYVal.float_num));
      }
      ;
timer_best_overhead :
        comma best_overhead arrow number
      {
        Timers.set_best_overhead
	  (A_Timer_Ref.all,MAST.Normalized_Execution_Time(YYVal.float_num));
      }
      ;
timer_avg_overhead :
        comma avg_overhead arrow number
      {
        Timers.set_avg_overhead
	  (A_Timer_Ref.all,MAST.Normalized_Execution_Time(YYVal.float_num));
      }
      ;
ticker_timer :
      left_paren ticker_type
      {
          A_Timer_Ref:=new Timers.Ticker;
      }
      ticker_arguments right_paren
      ;
ticker_type :
      the_type arrow ticker
      ;
ticker_arguments :
        ticker_argument
      | ticker_arguments ticker_argument
      ;
ticker_argument :
        timer_worst_overhead
      | timer_best_overhead
      | timer_avg_overhead
      | ticker_period
      ;
ticker_period :
        comma period arrow number
      {
        Timers.set_period
	  (Timers.Ticker'Class(A_Timer_Ref.all),
           MAST.Time(YYVal.float_num));
      }
      ;

------------------------------------
--  Fixed_Priority_Network_Object
------------------------------------

fixed_priority_network_object : 
      processing_resource left_paren fixed_priority_network_type
      {
          processing_res_ref:=
              new Processing_resources.network.Packet_Based_Network;
          scheduler_ref:=
	     new Schedulers.Primary.Primary_Scheduler;
	  Schedulers.Primary.Set_Host
            (Schedulers.Primary.Primary_Scheduler(Scheduler_Ref.all),
             processing_res_ref);
          sched_policy_ref:=
	     new Scheduling_Policies.FP_Packet_Based;
	  Schedulers.Set_Scheduling_Policy
	    (Scheduler_Ref.all,Sched_Policy_Ref);
      }
      fixed_priority_network_arguments right_paren semicolon
      ;
fixed_priority_network_type :
      the_type arrow fixed_priority_network
      ;
fixed_priority_network_arguments :
        fp_processing_resource_name
      | fixed_priority_network_arguments fixed_priority_network_argument
      ;
fixed_priority_network_argument :
        processing_resource_max_priority
      | processing_resource_min_priority
      | fixed_priority_network_pwo
      | fixed_priority_network_pao
      | fixed_priority_network_pbo
      | fixed_priority_network_trans
      | fixed_priority_network_lod
      | fixed_priority_network_maxblk
      | fixed_priority_network_maxpt
      | fixed_priority_network_minpt
      | fixed_priority_network_sf
      ;
fixed_priority_network_pwo :
        comma packet_worst_overhead arrow number
      {
        Scheduling_Policies.set_packet_worst_overhead
             (Scheduling_Policies.FP_Packet_Based'Class
                   (Sched_Policy_ref.all),
                    MAST.Normalized_Execution_Time(YYVal.float_num));
      }
      ;
fixed_priority_network_pomax :
        comma packet_overhead_max_size arrow number
      {
        Scheduling_Policies.set_packet_overhead_max_size
             (Scheduling_Policies.FP_Packet_Based'Class
                   (Sched_Policy_ref.all),
                    MAST.Bit_Count(YYVal.float_num));
      }
      ;
fixed_priority_network_pao :
        comma packet_avg_overhead arrow number
      {
        Scheduling_Policies.set_packet_avg_overhead
             (Scheduling_Policies.FP_Packet_Based'Class
                   (Sched_Policy_ref.all),
                 MAST.Normalized_Execution_Time(YYVal.float_num));
      }
      ;
fixed_priority_network_poavg :
        comma packet_overhead_avg_size arrow number
      {
        Scheduling_Policies.set_packet_overhead_avg_size
             (Scheduling_Policies.FP_Packet_Based'Class
                   (Sched_Policy_ref.all),
                    MAST.Bit_Count(YYVal.float_num));
      }
      ;
fixed_priority_network_pbo :
        comma packet_best_overhead arrow number
      {
        Scheduling_Policies.set_packet_best_overhead
             (Scheduling_Policies.FP_Packet_Based'Class
                   (Sched_Policy_ref.all),
                 MAST.Normalized_Execution_Time(YYVal.float_num));
      }
      ;
fixed_priority_network_pomin :
        comma packet_overhead_min_size arrow number
      {
        Scheduling_Policies.set_packet_overhead_min_size
             (Scheduling_Policies.FP_Packet_Based'Class
                   (Sched_Policy_ref.all),
                    MAST.Bit_Count(YYVal.float_num));
      }
      ;
fixed_priority_network_trans :
        comma transmission arrow trans_kind
      {
        Processing_Resources.network.set_Transmission_Mode
             (Processing_resources.network.Packet_Based_Network'class
                (processing_res_ref.all),
                 MAST.Transmission_Kind'Val(YYVal.num));
      }
      ;
fixed_priority_network_lod :
        comma list_of_drivers arrow list_of_drivers_argument
      ;
fixed_priority_network_maxblk :
        comma max_blocking arrow number
      {
        Processing_Resources.network.set_max_blocking
             (Processing_resources.network.Packet_Based_Network'class
                  (processing_res_ref.all),
                   MAST.Normalized_Execution_Time(YYVal.float_num));
      }
      ;
fixed_priority_network_maxpt :
        comma max_packet_transmission_time arrow number
      {
        if YYVal.float_num<=0.0 then
             User_Defined_Errors.Parser_Error
                 ("Max_Packet_Transmission_Time must be greater than zero");
        else
           Processing_Resources.network.set_max_packet_transmission_time
             (Processing_resources.network.Packet_Based_Network'class
                  (processing_res_ref.all),
                   MAST.Normalized_Execution_Time(YYVal.float_num));
        end if;
      }
      ;
fixed_priority_network_minpt :
        comma min_packet_transmission_time arrow number
      {
        if YYVal.float_num<=0.0 then
             User_Defined_Errors.Parser_Error
                 ("Min_Packet_Transmission_Time must be greater than zero");
        else
           Processing_Resources.network.set_min_packet_transmission_time
             (Processing_resources.network.Packet_Based_Network'class
                  (processing_res_ref.all),
                   MAST.Normalized_Execution_Time(YYVal.float_num));
        end if;
      }
      ;
fixed_priority_network_sf :
        comma speed_factor arrow number
      {
        Processing_Resources.set_speed_factor (processing_res_ref.all,
                   MAST.Processor_Speed(YYVal.float_num));
      }
      ;
list_of_drivers_argument :
      left_paren a_list_of_drivers right_paren
      ;
a_list_of_drivers :
        a_list_of_drivers comma a_driver
      | a_driver
      ;

------------------------------------
--  PB_Network_Object
------------------------------------

pb_network_object : 
      processing_resource left_paren pb_network_type
      {
          processing_res_ref:=
              new Processing_resources.network.Packet_Based_Network;
      }
      network_arguments right_paren semicolon
      ;
pb_network_type :
      the_type arrow packet_based_network
      ;
network_arguments :
        processing_resource_name
      | network_arguments network_argument
      ;
network_argument :
        fixed_priority_network_trans
      | pb_network_throughput
      | pb_network_max_packet_arg
      | pb_network_min_packet_arg
      | fixed_priority_network_lod
      | fixed_priority_network_maxblk
      | fixed_priority_network_sf
      ;
pb_network_throughput :
        comma throughput arrow number
      {
        Processing_Resources.Network.set_throughput 
            (Processing_Resources.Network.Network'class
                 (processing_res_ref.all),
             MAST.Throughput_Value(YYVal.float_num));
      }
      ;
pb_network_max_packet_arg :
        pb_network_maxps
      | fixed_priority_network_maxpt
      ;
pb_network_min_packet_arg :
        pb_network_minps
      | fixed_priority_network_minpt
      ;
pb_network_maxps :
        comma max_packet_size arrow number
      {
        if YYVal.float_num<=0.0 then
             User_Defined_Errors.Parser_Error
                 ("Max_Packet_Size must be greater than zero");
        else
           Processing_Resources.network.set_max_packet_size
             (Processing_resources.network.Packet_Based_Network'class
                  (processing_res_ref.all),MAST.Bit_Count(YYVal.float_num));
        end if;
      }
      ;
pb_network_minps :
        comma min_packet_size arrow number
      {
        if YYVal.float_num<=0.0 then
             User_Defined_Errors.Parser_Error
                 ("Min_Packet_Size must be greater than zero");
        else
           Processing_Resources.network.set_min_packet_size
             (Processing_resources.network.Packet_Based_Network'class
                  (processing_res_ref.all),MAST.Bit_Count(YYVal.float_num));
        end if;
      }
      ;

------------------------------------
--  Drivers
------------------------------------

a_driver : 
        driver_item
      {
        Processing_Resources.network.Add_driver
          (Processing_Resources.network.Packet_Based_Network'Class
             (Processing_res_ref.all),
	      A_Driver_Ref);
      }
      ;
driver_item:
        packet_driver_item
      | character_packet_driver_item
      | rtep_packet_driver_item
      ;
packet_driver_item :
      left_paren packet_driver_type
      {
          A_Driver_Ref:=new Drivers.Packet_Driver;
      }
      packet_driver_arguments right_paren
      ;
packet_driver_type :
      the_type arrow packet_driver
      ;
packet_driver_arguments :
        packet_driver_argument
      | packet_driver_arguments packet_driver_argument
      ;
packet_driver_argument :
        packet_driver_server
      | packet_driver_send_op
      | packet_driver_receive_op
      | packet_driver_message_partitioning
      | packet_driver_rta_overhead_model
      ;
packet_driver_server :
        packet_driver_server_external
      | packet_driver_server_internal
      ;
packet_driver_server_external :
        comma packet_server arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Srvr_Index:=Scheduling_Servers.Lists.Find
              (a_name,MAST_System.Scheduling_Servers);
          if Srvr_Index=Scheduling_Servers.Lists.Null_Index then
             declare 
                 Srvr_Ref : Scheduling_Servers.Scheduling_Server_ref:=
                             new Scheduling_Servers.Scheduling_Server;
             begin
                 Scheduling_Servers.Init(Srvr_Ref.all,A_Name);
	         Drivers.Set_Packet_Server
	             (Drivers.Packet_Driver'Class(a_driver_ref.all),
                      Srvr_Ref);
             end;             
          else
             declare 
                 srvr_ref : Scheduling_Servers.Scheduling_Server_ref;
             begin
                 srvr_ref:=Scheduling_Servers.Lists.Item
                      (Srvr_Index,
                       MAST_System.Scheduling_Servers);
	         Drivers.Set_Packet_Server
	             (Drivers.Packet_Driver'Class(a_driver_ref.all),
                      Srvr_Ref);
             end;
          end if;
      }
      ;
packet_driver_server_internal :
        comma packet_server arrow server_internal_object
      {
         Drivers.Set_Packet_Server
           (Drivers.Packet_Driver'Class(a_driver_ref.all),
            Srvr_Ref);
      }
      ;
packet_driver_send_op :
        packet_driver_send_op_external
      | packet_driver_send_op_internal
      ;
packet_driver_send_op_internal :
        comma packet_send_operation arrow internal_simple_operation_object
      {
         Drivers.Set_Packet_Send_Operation
           (Drivers.Packet_Driver'Class(a_driver_ref.all),Op_Ref);
      }
      ;
packet_driver_send_op_external :
        comma packet_send_operation arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare 
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Packet_Send_Operation
                    (Drivers.Packet_Driver'Class(a_driver_ref.all),Op_Ref);
             end;             
          else
             declare 
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
	         Drivers.Set_Packet_Send_Operation
	             (Drivers.Packet_Driver'Class(a_driver_ref.all),Op_Ref);
             end;
          end if;
      }
      ;
packet_driver_receive_op :
        packet_driver_receive_op_external
      | packet_driver_receive_op_internal
      ;
packet_driver_receive_op_internal :
        comma packet_receive_operation arrow internal_simple_operation_object
      {
         Drivers.Set_Packet_Receive_Operation
           (Drivers.Packet_Driver'Class(a_driver_ref.all),Op_Ref);
      }
      ;
packet_driver_receive_op_external :
        comma packet_receive_operation arrow identifier
      {
          A_Name:=Symbol_Table.Item(YYVal.Name_Index);
          Op_Index:=Operations.Lists.Find
              (A_Name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare 
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Packet_Receive_Operation
                    (Drivers.Packet_Driver'Class(a_driver_ref.all),Op_Ref);
             end;             
          else
             declare 
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
	         Drivers.Set_Packet_Receive_Operation
	             (Drivers.Packet_Driver'Class(a_driver_ref.all),Op_Ref);
             end;
          end if;
      }
      ;
packet_driver_message_partitioning :
        comma message_partitioning arrow yes_no
      {
         Drivers.Set_Message_Partitioning
           (Drivers.Packet_Driver'Class(a_driver_ref.all),
            YYVal.Flag);
      }
      ;
packet_driver_rta_overhead_model :
        comma rta_overhead_model arrow rta_overhead_model_value
      {
         begin
	   Drivers.Set_Rta_Overhead_Model
           (Drivers.Packet_Driver'Class(a_driver_ref.all),
            Drivers.Rta_Overhead_Model_Type'Val(YYVal.Num));
	 exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Overhead Model is invalid");
	 end;
      }
      ;
character_packet_driver_item :
      left_paren character_packet_driver_type
      {
          A_Driver_Ref:=new Drivers.Character_Packet_Driver;
      }
      character_packet_driver_arguments right_paren
      ;
character_packet_driver_type :
      the_type arrow character_packet_driver
      ;
character_packet_driver_arguments :
        character_packet_driver_argument
      | character_packet_driver_arguments character_packet_driver_argument
      ;
character_packet_driver_argument :
        packet_driver_server
      | packet_driver_send_op
      | packet_driver_receive_op
      | packet_driver_message_partitioning
      | packet_driver_rta_overhead_model
      | character_packet_driver_server
      | character_packet_driver_send_op
      | character_packet_driver_receive_op
      | character_packet_driver_transmission
      ;
character_packet_driver_server :
        character_packet_driver_server_external
      | character_packet_driver_server_internal
      ;
character_packet_driver_server_external :
        comma character_server arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Srvr_Index:=Scheduling_Servers.Lists.Find
              (a_name,MAST_System.Scheduling_Servers);
          if Srvr_Index=Scheduling_Servers.Lists.Null_Index then
             declare 
                 Srvr_Ref : Scheduling_Servers.Scheduling_Server_ref:=
                             new Scheduling_Servers.Scheduling_Server;
             begin
                 Scheduling_Servers.Init(Srvr_Ref.all,A_Name);
	         Drivers.Set_Character_Server
	             (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
                      Srvr_Ref);
             end;             
          else
             declare 
                 srvr_ref : Scheduling_Servers.Scheduling_Server_ref;
             begin
                 srvr_ref:=Scheduling_Servers.Lists.Item
                      (Srvr_Index,
                       MAST_System.Scheduling_Servers);
	         Drivers.Set_Character_Server
	             (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
                      Srvr_Ref);
             end;
          end if;
      }
      ;
character_packet_driver_server_internal :
        comma character_server arrow server_internal_object
      {
         Drivers.Set_Character_Server
           (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
            Srvr_Ref);
      }
      ;
character_packet_driver_send_op :
        character_packet_driver_send_op_external
      | character_packet_driver_send_op_internal
      ;
character_packet_driver_send_op_internal :
        comma character_send_operation arrow internal_simple_operation_object
      {
         Drivers.Set_Character_Send_Operation
           (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),Op_Ref);
      }
      ;
character_packet_driver_send_op_external :
        comma character_send_operation arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare 
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Character_Send_Operation
                    (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;             
          else
             declare 
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
	         Drivers.Set_Character_Send_Operation
	             (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;
      }
      ;
character_packet_driver_receive_op :
        character_packet_driver_receive_op_external
      | character_packet_driver_receive_op_internal
      ;
character_packet_driver_receive_op_internal :
        comma character_receive_operation arrow 
        internal_simple_operation_object
      {
         Drivers.Set_Character_Receive_Operation
           (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),Op_Ref);
      }
      ;
character_packet_driver_receive_op_external :
        comma character_receive_operation arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare 
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Character_Receive_Operation
                    (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;             
          else
             declare 
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
	         Drivers.Set_Character_Receive_Operation
	             (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;
      }
      ;
character_packet_driver_transmission :
        comma character_transmission_time arrow 
        number
      {
         Drivers.Set_Character_Transmission_Time
           (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
            MAST.Time(YYVal.float_num));
      }
      ;

rtep_packet_driver_item :
      left_paren rtep_packet_driver_type
      {
          A_Driver_Ref:=new Drivers.RTEP_Packet_Driver;
      }
      rtep_packet_driver_arguments right_paren
      ;
rtep_packet_driver_type :
      the_type arrow rtep_packet_driver
      ;
rtep_packet_driver_arguments :
        rtep_packet_driver_argument
      | rtep_packet_driver_arguments rtep_packet_driver_argument
      ;
rtep_packet_driver_argument :
        packet_driver_server
      | packet_driver_send_op
      | packet_driver_receive_op
      | packet_driver_message_partitioning
      | packet_driver_rta_overhead_model
      | rtep_number_of_stations
      | rtep_token_delay
      | rtep_failure_timeout
      | rtep_token_transmission_retries
      | rtep_packet_transmission_retries
      | rtep_interrupt_server
      | rtep_packet_isr_op
      | rtep_token_check_op
      | rtep_token_manage_op
      | rtep_packet_discard_op
      | rtep_token_retransmission_op
      | rtep_packet_retransmission_op
      ;
rtep_number_of_stations :
        comma number_of_stations arrow 
        number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Number_Of_Stations should be integer value");
        end if;
        begin
           Drivers.Set_Number_Of_Stations
              (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
               Positive(YYVal.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Number_Of_Stations value out of range");
        end;
      }
      ;
rtep_token_delay :
        comma token_delay arrow 
        number
      {
         Drivers.Set_Token_Delay
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
            MAST.Time(YYVal.float_num));
      }
      ;
rtep_failure_timeout :
        comma failure_timeout arrow 
        number
      {
         Drivers.Set_Failure_Timeout
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
            MAST.Time(YYVal.float_num));
      }
      ;
rtep_token_transmission_retries :
        comma token_transmission_retries arrow 
        number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Token_Transmission_Retries should be integer value");
        end if;
        begin
           Drivers.Set_Token_Transmission_Retries
              (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
               Natural(YYVal.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Token_Transmission_Retries value out of range");
        end;
      }
      ;
rtep_packet_transmission_retries :
        comma packet_transmission_retries arrow 
        number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Packet_Transmission_Retries should be integer value");
        end if;
        begin
           Drivers.Set_Packet_Transmission_Retries
              (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
               Natural(YYVal.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Packet_Transmission_Retries value out of range");
        end;
      }
      ;
rtep_interrupt_server :
        rtep_interrupt_server_external
      | rtep_interrupt_server_internal
      ;
rtep_interrupt_server_external :
        comma packet_interrupt_server arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Srvr_Index:=Scheduling_Servers.Lists.Find
              (a_name,MAST_System.Scheduling_Servers);
          if Srvr_Index=Scheduling_Servers.Lists.Null_Index then
             declare 
                 Srvr_Ref : Scheduling_Servers.Scheduling_Server_ref:=
                             new Scheduling_Servers.Scheduling_Server;
             begin
                 Scheduling_Servers.Init(Srvr_Ref.all,A_Name);
	         Drivers.Set_Packet_Interrupt_Server
	             (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Srvr_Ref);
             end;             
          else
             declare 
                 srvr_ref : Scheduling_Servers.Scheduling_Server_ref;
             begin
                 srvr_ref:=Scheduling_Servers.Lists.Item
                      (Srvr_Index,
                       MAST_System.Scheduling_Servers);
	         Drivers.Set_Packet_Interrupt_Server
	             (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Srvr_Ref);
             end;
          end if;
      }
      ;
rtep_interrupt_server_internal :
        comma packet_interrupt_server arrow server_internal_object
      {
         Drivers.Set_Packet_Interrupt_Server
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
            Srvr_Ref);
      }
      ;
rtep_packet_isr_op :
        rtep_packet_isr_op_external
      | rtep_packet_isr_op_internal
      ;
rtep_packet_isr_op_internal :
        comma packet_isr_operation arrow internal_simple_operation_object
      {
         Drivers.Set_Packet_ISR_Operation
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),Op_Ref);
      }
      ;
rtep_packet_isr_op_external :
        comma packet_isr_operation arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare 
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Packet_ISR_Operation
                    (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;             
          else
             declare 
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
	         Drivers.Set_Packet_ISR_Operation
	             (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;
      }
      ;
rtep_token_check_op :
        rtep_token_check_op_external
      | rtep_token_check_op_internal
      ;
rtep_token_check_op_internal :
        comma token_check_operation arrow internal_simple_operation_object
      {
         Drivers.Set_Token_Check_Operation
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),Op_Ref);
      }
      ;
rtep_token_check_op_external :
        comma token_check_operation arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare 
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Token_Check_Operation
                    (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;             
          else
             declare 
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
	         Drivers.Set_Token_Check_Operation
	             (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;
      }
      ;
rtep_token_manage_op :
        rtep_token_manage_op_external
      | rtep_token_manage_op_internal
      ;
rtep_token_manage_op_internal :
        comma token_manage_operation arrow internal_simple_operation_object
      {
         Drivers.Set_Token_Manage_Operation
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),Op_Ref);
      }
      ;
rtep_token_manage_op_external :
        comma token_manage_operation arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare 
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Token_Manage_Operation
                    (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;             
          else
             declare 
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
	         Drivers.Set_Token_Manage_Operation
	             (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;
      }
      ;
rtep_packet_discard_op :
        rtep_packet_discard_op_external
      | rtep_packet_discard_op_internal
      ;
rtep_packet_discard_op_internal :
        comma packet_discard_operation arrow internal_simple_operation_object
      {
         Drivers.Set_Packet_Discard_Operation
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),Op_Ref);
      }
      ;
rtep_packet_discard_op_external :
        comma packet_discard_operation arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare 
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Packet_Discard_Operation
                    (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;             
          else
             declare 
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
	         Drivers.Set_Packet_Discard_Operation
	             (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;
      }
      ;
rtep_token_retransmission_op :
        rtep_token_retransmission_op_external
      | rtep_token_retransmission_op_internal
      ;
rtep_token_retransmission_op_internal :
        comma token_retransmission_operation arrow 
        internal_simple_operation_object
      {
         Drivers.Set_Token_Retransmission_Operation
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),Op_Ref);
      }
      ;
rtep_token_retransmission_op_external :
        comma token_retransmission_operation arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare 
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Token_Retransmission_Operation
                    (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;             
          else
             declare 
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
	         Drivers.Set_Token_Retransmission_Operation
	             (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;
      }
      ;
rtep_packet_retransmission_op :
        rtep_packet_retransmission_op_external
      | rtep_packet_retransmission_op_internal
      ;
rtep_packet_retransmission_op_internal :
        comma packet_retransmission_operation arrow 
        internal_simple_operation_object
      {
         Drivers.Set_Packet_Retransmission_Operation
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),Op_Ref);
      }
      ;
rtep_packet_retransmission_op_external :
        comma packet_retransmission_operation arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare 
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Packet_Retransmission_Operation
                    (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;             
          else
             declare 
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
	         Drivers.Set_Packet_Retransmission_Operation
	             (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;
      }
      ;

-----------------------
--  Scheduler_Object --
-----------------------

scheduler_object :
      primary_scheduler_object
    | secondary_scheduler_object
    ;

------------------------------------
--  Primary_Scheduler_Object
------------------------------------

primary_scheduler_object:
      scheduler left_paren primary_scheduler_type
      {
          scheduler_ref:=
	     new Schedulers.Primary.Primary_Scheduler;
      }
      primary_scheduler_arguments right_paren semicolon
      ;
primary_scheduler_type :
      the_type arrow primary_scheduler
      ;
primary_scheduler_arguments :
        scheduler_name
      | primary_scheduler_arguments primary_scheduler_argument
      ;
primary_scheduler_argument : 
        scheduler_policy
      | primary_scheduler_host
      ;
scheduler_name :
        comma name arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Schedulers.init(Scheduler_ref.all,a_name);
          begin
             Schedulers.lists.add
               (scheduler_ref,mast_system.schedulers);
          exception
	    when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Scheduler already exists");                
          end;
      }
      ;
scheduler_policy :
        comma policy arrow scheduling_policy_item
      {
        Schedulers.set_scheduling_policy
             (scheduler_ref.all,Sched_policy_Ref);
      }
      ;
primary_scheduler_host :
        comma host arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Proc_res_Index:=Processing_Resources.Lists.Find
              (a_name,MAST_System.Processing_Resources);
          if Proc_Res_Index=Processing_Resources.Lists.Null_Index then
             declare 
                 Proc_Ref : Processing_Resources.Processing_Resource_ref:=
                        new Processing_Resources.Processor.Regular_Processor;
             begin
                 Processing_Resources.Init(Proc_Ref.all,A_Name);
                 Schedulers.Primary.Set_Host
                   (Schedulers.Primary.Primary_Scheduler'class
                     (Scheduler_Ref.all),proc_ref);
             end;             
          else
             declare 
                 proc_ref : Processing_Resources.Processing_Resource_ref;
             begin
                 proc_ref:=Processing_Resources.Lists.Item
                      (Proc_Res_index,MAST_System.Processing_Resources);
                 Schedulers.Primary.Set_Host
                   (Schedulers.Primary.Primary_Scheduler'class
                     (Scheduler_Ref.all),proc_ref);
             end;
          end if;
      }
      ;

------------------------------------
--  Secondary_Scheduler_Object
------------------------------------

secondary_scheduler_object:
      scheduler left_paren secondary_scheduler_type
      {
          scheduler_ref:=
	     new Schedulers.Secondary.Secondary_Scheduler;
      }
      secondary_scheduler_arguments right_paren semicolon
      ;
secondary_scheduler_type :
      the_type arrow secondary_scheduler
      ;
secondary_scheduler_arguments :
        scheduler_name
      | secondary_scheduler_arguments secondary_scheduler_argument
      ;
secondary_scheduler_argument : 
        scheduler_policy
      | secondary_scheduler_server
      ;
secondary_scheduler_server :
        comma server arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Srvr_Index:=Scheduling_Servers.Lists.Find
              (a_name,MAST_System.Scheduling_Servers);
          if Srvr_Index=Scheduling_Servers.Lists.Null_Index then
             declare 
                 Srvr_Ref : Scheduling_Servers.Scheduling_Server_ref:=
                             new Scheduling_Servers.Scheduling_Server;
             begin
                 Scheduling_Servers.Init(Srvr_Ref.all,A_Name);
                 Schedulers.Secondary.Set_Server
                   (Schedulers.Secondary.Secondary_Scheduler'class
                     (Scheduler_Ref.all),Srvr_ref);
             end;             
          else
             declare 
                 ss_ref : Scheduling_Servers.Scheduling_Server_ref;
             begin
                 ss_ref:=Scheduling_Servers.Lists.Item
                      (Srvr_index,MAST_System.Scheduling_Servers);
                 Schedulers.Secondary.Set_Server
                   (Schedulers.Secondary.Secondary_Scheduler'class
                     (Scheduler_Ref.all),ss_ref);
             end;
          end if;
      }
      ;

------------------------------------
--  Scheduling Policies
------------------------------------

scheduling_policy_item :
        fixed_priority_item
      | edf_item
      | fp_packet_based_item
      ;
fixed_priority_item :
      left_paren fixed_priority_type
      {
          sched_policy_ref:=new Scheduling_Policies.fixed_priority;
      }
      fixed_priority_termination
      ;
fixed_priority_type :
      the_type arrow fixed_priority
      ;
fixed_priority_termination :
        right_paren
      | fixed_priority_arguments right_paren
      ;    
fixed_priority_arguments :
        fixed_priority_argument
      | fixed_priority_arguments fixed_priority_argument
      ;
fixed_priority_argument :
        processing_resource_max_priority
      | processing_resource_min_priority
      | fixed_priority_processor_wcs
      | fixed_priority_processor_acs
      | fixed_priority_processor_bcs
      ;

edf_item :
      left_paren edf_type
      {
          sched_policy_ref:=new Scheduling_Policies.edf;
      }
      edf_termination
      ;
edf_type :
      the_type arrow edf
      ;
edf_termination :
        right_paren
      | edf_arguments right_paren
      ;    
edf_arguments :
        edf_argument
      | edf_arguments edf_argument
      ;
edf_argument :
      | edf_wcs
      | edf_acs
      | edf_bcs
      ;
edf_wcs :
        comma worst_context_switch arrow number
      {
        Scheduling_Policies.set_worst_context_switch
             (Scheduling_Policies.edf'Class
              (sched_policy_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));
      }
      ;
edf_acs :
        comma avg_context_switch arrow number
      {
        Scheduling_Policies.set_avg_context_switch
             (Scheduling_Policies.edf'Class
              (sched_policy_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));
      }
      ;
edf_bcs :
        comma best_context_switch arrow number
      {
        Scheduling_Policies.set_best_context_switch
             (Scheduling_Policies.edf'Class
              (sched_policy_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));
      }
      ;

fp_packet_based_item :
      left_paren fp_packet_based_type
      {
          sched_policy_ref:=new Scheduling_Policies.fp_packet_based;
      }
      fp_packet_based_termination
      ;
fp_packet_based_type :
      the_type arrow fp_packet_based
      ;
fp_packet_based_termination :
        right_paren
      | fp_packet_based_arguments right_paren
      ;    
fp_packet_based_arguments :
        fp_packet_based_argument
      | fp_packet_based_arguments fp_packet_based_argument
      ;
fp_packet_based_argument :
        processing_resource_max_priority
      | processing_resource_min_priority
      | fp_packet_based_pwoarg
      | fp_packet_based_paoarg
      | fp_packet_based_pboarg
      ;
fp_packet_based_pwoarg :
        fixed_priority_network_pwo
      | fixed_priority_network_pomax
      ;
fp_packet_based_paoarg :
        fixed_priority_network_pao
      | fixed_priority_network_poavg
      ;
fp_packet_based_pboarg :
        fixed_priority_network_pbo
      | fixed_priority_network_pomin
      ;

------------------------------------
--  Shared resources
------------------------------------

shared_resource_object :
      priority_inheritance_res_object
    | pcp_resource
    | srp_resource_item
    ;

------------------------------------
--  Priority Inheritance Resource
------------------------------------

priority_inheritance_res_object :
      shared_resource left_paren priority_inheritance_type 
      {
          shared_res_ref:=new Shared_Resources.priority_inheritance_resource;
      }
      shared_resource_name right_paren semicolon
      ;
priority_inheritance_type :
      the_type arrow priority_inheritance_resource
      ;
shared_resource_name :
        comma name arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Shared_Resources.init(shared_res_ref.all,a_name);
          begin
             Shared_Resources.lists.add
                (shared_res_ref,mast_system.shared_resources);
          exception
	    when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Shared resource already exists");                
          end;
      }
      ;
------------------------------------
--  PCP Resource
------------------------------------

pcp_resource :
      shared_resource left_paren pcp_type 
      {
          shared_res_ref:=new Shared_Resources.immediate_ceiling_resource;
          preassigned_field_present:=False;
      }
      pcp_resource_arguments right_paren semicolon
      ;
pcp_type :
      the_type arrow immediate_ceiling_resource
      ;
pcp_resource_arguments :
        shared_resource_name
      | shared_resource_name pcp_arguments
      ;
pcp_arguments :
        pcp_arguments pcp_argument
      | pcp_argument
      ;
pcp_argument :
        pcp_argument_ceiling
      | pcp_argument_preassigned
      ;
pcp_argument_ceiling :
        comma ceiling arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Shared_Resources.set_ceiling
               (Shared_resources.immediate_ceiling_resource'Class
                (shared_res_ref.all),
                mast.priority(YYVal.num));
           if not Preassigned_Field_Present then
              Shared_Resources.set_preassigned
                  (Shared_resources.immediate_ceiling_resource'Class
		   (shared_res_ref.all),true);
           end if;
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;
      }
      ;
pcp_argument_preassigned :
        comma preassigned arrow yes_no
      {
        Preassigned_Field_Present:=True;
	Shared_Resources.set_preassigned
	  (Shared_resources.immediate_ceiling_resource'Class
	      (shared_res_ref.all),YYVal.flag);
      }
      ;

------------------------------------
--  SRP Resource
------------------------------------

srp_resource_item :
      shared_resource left_paren srp_type 
      {
          shared_res_ref:=new Shared_Resources.srp_resource;
          preassigned_field_present:=False;
      }
      srp_resource_arguments right_paren semicolon
      ;
srp_type :
      the_type arrow srp_resource
      ;
srp_resource_arguments :
        shared_resource_name
      | shared_resource_name srp_arguments
      ;
srp_arguments :
        srp_arguments srp_argument
      | srp_argument
      ;
srp_argument :
        srp_argument_plevel
      | srp_argument_preassigned
      ;
srp_argument_plevel :
        comma the_preemption_level arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Preemption level should be integer value");
        end if;
        begin
           Shared_Resources.set_level
               (Shared_resources.srp_resource'Class
                (shared_res_ref.all),
                mast.preemption_level(YYVal.num));
           if not Preassigned_Field_Present then
              Shared_Resources.set_preassigned
                  (Shared_resources.srp_resource'Class
		   (shared_res_ref.all),true);
           end if;
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Preemption level value out of range");
        end;
      }
      ;
srp_argument_preassigned :
        comma preassigned arrow yes_no
      {
        Preassigned_Field_Present:=True;
	Shared_Resources.set_preassigned
	  (Shared_resources.srp_resource'Class
	      (shared_res_ref.all),YYVal.flag);
      }
      ;

------------------------------------
--  Operations
------------------------------------

operation_object :
      simple_operation_object
    | composite_operation_object
    | enclosing_operation_object
    | message_operation_object
    ;

------------------------------------
--  Simple Operation
------------------------------------

simple_operation_object : 
      operation internal_simple_operation_object semicolon
      ;
internal_simple_operation_object:
      left_paren simple_operation_type
      {
          Op_Ref:=new Operations.Simple_Operation;
      }
      simple_operation_arguments right_paren
      ;
simple_operation_type :
      the_type arrow simple
      ;
simple_operation_arguments :
        operation_name
      | simple_operation_arguments simple_operation_argument
      ;
simple_operation_argument :
        operation_nsp
      | simple_operation_wcet
      | simple_operation_acet
      | simple_operation_bcet
      | simple_operation_srdesc
      ;
operation_name :
        comma name arrow identifier
      {
        a_name:=symbol_table.item(YYVal.name_index);
        Operations.init(Op_Ref.all,a_name);
        begin
             Operations.lists.add
                  (Op_Ref,mast_system.operations);
        exception
	    when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Operation already exists");                
        end;
      }
      ;
operation_nsp :
        comma new_sched_parameters arrow overridden_sched_parameters_item
      {
        Operations.set_new_sched_parameters
             (Op_Ref.all,
              overridden_sched_params_ref);
      }
      ;
simple_operation_wcet :
        comma worst_case_execution_time arrow number
      {
        Operations.set_worst_case_execution_time
             (Operations.Simple_Operation'Class(Op_Ref.all),
              MAST.Normalized_Execution_Time(YYval.float_Num));
      }
      ;
simple_operation_acet :
        comma avg_case_execution_time arrow number
      {
        Operations.set_avg_case_execution_time
             (Operations.Simple_Operation'Class(Op_Ref.all),
              MAST.Normalized_Execution_Time(YYval.float_Num));
      }
      ;
simple_operation_bcet :
        comma best_case_execution_time arrow number
      {
        Operations.set_best_case_execution_time
             (Operations.Simple_Operation'Class(Op_Ref.all),
              MAST.Normalized_Execution_Time(YYval.float_Num));
      }
      ;
simple_operation_srdesc :
        simple_operation_srlist
      | simple_operation_lusr
      ;
simple_operation_srlist :
        comma shared_resources_list arrow 
            left_paren list_of_shared_resources right_paren
      ;
list_of_shared_resources :
        list_of_shared_resources comma shared_resource_item
      | shared_resource_item
      ;
shared_resource_item :
        identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Shared_Res_Index:=Shared_Resources.Lists.Find
              (a_name,MAST_System.Shared_resources);
          if Shared_Res_Index=Shared_Resources.Lists.Null_Index then
             declare 
                 Sh_Res_Ref : Shared_Resources.Shared_Resource_ref:=
                          new Shared_Resources.Priority_Inheritance_Resource;
             begin
                 Shared_Resources.Init(Sh_Res_Ref.all,A_Name);
                 Operations.Add_Resource
                    (Operations.Simple_Operation(Op_Ref.all),Sh_Res_Ref);
             end;             
          else 
              Operations.Add_Resource
                  (Operations.Simple_Operation(Op_Ref.all),
                   Shared_Resources.Lists.Item
                      (Shared_Res_Index,MAST_System.Shared_resources));
          end if;
      }
      ;
simple_operation_lusr :
        simple_operation_lsr
      | simple_operation_usr
      ;
simple_operation_lsr :
        comma shared_resources_to_lock arrow 
            left_paren list_of_locked_shared_resources right_paren
      ;
list_of_locked_shared_resources :
        list_of_locked_shared_resources comma locked_shared_resource_item
      | locked_shared_resource_item
      ;
locked_shared_resource_item :
        identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Shared_Res_Index:=Shared_Resources.Lists.Find
              (a_name,MAST_System.Shared_resources);
          if Shared_Res_Index=Shared_Resources.Lists.Null_Index then
             declare 
                 Sh_Res_Ref : Shared_Resources.Shared_Resource_ref:=
                          new Shared_Resources.Priority_Inheritance_Resource;
             begin
                 Shared_Resources.Init(Sh_Res_Ref.all,A_Name);
                 Operations.Add_Locked_Resource
                    (Operations.Simple_Operation(Op_Ref.all),Sh_Res_Ref);
             end;             
          else 
              Operations.Add_Locked_Resource
                  (Operations.Simple_Operation(Op_Ref.all),
                   Shared_Resources.Lists.Item
                      (Shared_Res_Index,MAST_System.Shared_resources));
          end if;
      }
      ;
simple_operation_usr :
        comma shared_resources_to_unlock arrow 
            left_paren list_of_unlocked_shared_resources right_paren
      ;
list_of_unlocked_shared_resources :
        list_of_unlocked_shared_resources comma unlocked_shared_resource_item
      | unlocked_shared_resource_item
      ;
unlocked_shared_resource_item :
        identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Shared_Res_Index:=Shared_Resources.Lists.Find
              (a_name,MAST_System.Shared_resources);
          if Shared_Res_Index=Shared_Resources.Lists.Null_Index then
             declare 
                 Sh_Res_Ref : Shared_Resources.Shared_Resource_ref:=
                          new Shared_Resources.Priority_Inheritance_Resource;
             begin
                 Shared_Resources.Init(Sh_Res_Ref.all,A_Name);
                 Operations.Add_Unlocked_Resource
                    (Operations.Simple_Operation(Op_Ref.all),Sh_Res_Ref);
             end;             
          else 
              Operations.Add_Unlocked_Resource
                  (Operations.Simple_Operation(Op_Ref.all),
                   Shared_Resources.Lists.Item
                      (Shared_Res_Index,MAST_System.Shared_resources));
          end if;
      }
      ;
------------------------------------
--  Composite Operation
------------------------------------

composite_operation_object : 
      operation left_paren composite_operation_type
      {
          Op_Ref:=new Operations.Composite_Operation;
      }
      composite_operation_arguments right_paren semicolon
      ;
composite_operation_type :
      the_type arrow composite
      ;
composite_operation_arguments :
        operation_name 
      | composite_operation_arguments composite_operation_argument
      ;
composite_operation_argument :
        operation_nsp
      | composite_operation_list_argument
      ;
composite_operation_list_argument :
        comma composite_operation_list arrow
            left_paren list_of_operations right_paren
      ;
list_of_operations :
        list_of_operations comma operation_item
      | operation_item
      ;
operation_item :
        identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare 
                 New_Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(New_Op_Ref.all,A_Name);
                 Operations.Add_Operation
                     (Operations.Composite_Operation(Op_Ref.all),New_Op_Ref); 
             end;             
          else 
              Operations.Add_Operation
                  (Operations.Composite_Operation(Op_Ref.all),
                   Operations.Lists.Item(Op_Index,MAST_System.Operations));
          end if;
      }
      ;
------------------------------------
--  Enclosing Operation
------------------------------------

enclosing_operation_object : 
      operation left_paren enclosing_operation_type
      {
          Op_Ref:=new Operations.Enclosing_Operation;
      }
      enclosing_operation_arguments right_paren semicolon
      ;
enclosing_operation_type :
      the_type arrow enclosing
      ;
enclosing_operation_arguments :
        operation_name 
      | enclosing_operation_arguments enclosing_operation_argument
      ;
enclosing_operation_argument :
        operation_nsp
      | composite_operation_list_argument
      | enclosing_operation_wcet
      | enclosing_operation_acet
      | enclosing_operation_bcet
      ;
enclosing_operation_wcet :
        comma worst_case_execution_time arrow number
      {
        Operations.set_worst_case_execution_time
             (Operations.Enclosing_Operation'Class(Op_Ref.all),
              MAST.Normalized_Execution_Time(YYval.float_Num));
      }
      ;
enclosing_operation_acet :
        comma avg_case_execution_time arrow number
      {
        Operations.set_avg_case_execution_time
             (Operations.Enclosing_Operation'Class(Op_Ref.all),
              MAST.Normalized_Execution_Time(YYval.float_Num));
      }
      ;
enclosing_operation_bcet :
        comma best_case_execution_time arrow number
      {
        Operations.set_best_case_execution_time
             (Operations.Enclosing_Operation'Class(Op_Ref.all),
              MAST.Normalized_Execution_Time(YYval.float_Num));
      }
      ;

------------------------------------
--  Message Transmission Operation
------------------------------------

message_operation_object : 
      operation internal_message_operation_object semicolon
      ;
internal_message_operation_object:
      left_paren message_operation_type
      {
          Op_Ref:=new Operations.Message_Transmission_Operation;
      }
      message_operation_arguments right_paren
      ;
message_operation_type :
      the_type arrow message_transmission
      ;
message_operation_arguments :
        operation_name
      | message_operation_arguments message_operation_argument
      ;
message_operation_argument :
        operation_nsp
      | message_operation_maxsize
      | message_operation_avgsize
      | message_operation_minsize
      ;
message_operation_maxsize :
        comma max_message_size arrow number
      {
        Operations.set_max_message_size
             (Operations.Message_Transmission_Operation'Class(Op_Ref.all),
              MAST.Bit_Count(YYval.float_Num));
      }
      ;
message_operation_avgsize :
        comma avg_message_size arrow number
      {
        Operations.set_avg_message_size
             (Operations.Message_Transmission_Operation'Class(Op_Ref.all),
              MAST.Bit_Count(YYval.float_Num));
      }
      ;
message_operation_minsize :
        comma min_message_size arrow number
      {
        Operations.set_min_message_size
             (Operations.Message_Transmission_Operation'Class(Op_Ref.all),
              MAST.Bit_Count(YYval.float_Num));
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
          sched_params_ref:=new Scheduling_Parameters.fixed_priority_policy;
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
          if sched_params_ref.all in Scheduling_Parameters.interrupt_fp_policy
          then          
             Scheduling_Parameters.set_preassigned
               (Scheduling_Parameters.Fixed_Priority_Parameters'Class
                    (Sched_params_ref.all), True);
             if not YYVal.flag then
                User_Defined_Errors.Parser_Error
                  ("Preassigned field in Interrupt Scheduler cannot be 'No'");
	     end if;
          else
             Scheduling_Parameters.set_preassigned
               (Scheduling_Parameters.Fixed_Priority_Parameters'Class
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
           Scheduling_Parameters.set_the_priority
             (Scheduling_Parameters.Fixed_Priority_Parameters'Class
                    (Sched_params_ref.all),
              MAST.Priority(YYval.num));
           if not Preassigned_Field_Present then
              Scheduling_Parameters.set_preassigned
                (Scheduling_Parameters.Fixed_Priority_Parameters'Class
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
               new Scheduling_Parameters.non_preemptible_fp_policy;
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
               new Scheduling_Parameters.interrupt_fp_policy;
          Preassigned_Field_Present:=False;
          Scheduling_Parameters.set_preassigned
             (Scheduling_Parameters.Fixed_Priority_Parameters'Class
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
          sched_params_ref:=new scheduling_Parameters.polling_policy;
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
        Scheduling_Parameters.set_polling_period
             (Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Time(YYval.float_num));
      }
      ;
polling_policy_worst_overhead :
        comma polling_worst_overhead arrow number
      {
        Scheduling_Parameters.set_polling_worst_overhead
             (Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));
      }
      ;
polling_policy_best_overhead :
        comma polling_best_overhead arrow number
      {
        Scheduling_Parameters.set_polling_best_overhead
             (Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));
      }
      ;
polling_policy_avg_overhead :
        comma polling_avg_overhead arrow number
      {
        Scheduling_Parameters.set_polling_avg_overhead
             (Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));
      }
      ;
sporadic_server_policy_item :
      left_paren sporadic_server_policy_type
      {
          sched_params_ref:=new scheduling_parameters.sporadic_server_policy;
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
           Scheduling_Parameters.set_the_priority
             (Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              MAST.Priority(YYval.num));
           if not Preassigned_Field_Present then
              Scheduling_Parameters.set_preassigned
                (Scheduling_Parameters.Fixed_Priority_Parameters'Class
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
           Scheduling_Parameters.set_background_priority
             (Scheduling_Parameters.sporadic_server_policy'Class
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
        Scheduling_Parameters.set_initial_capacity
             (Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              MAST.Time(YYval.float_num));
      }
      ;
sporadic_server_replenishment_period :
        comma replenishment_period arrow number
      {
        Scheduling_Parameters.set_replenishment_period
             (Scheduling_Parameters.sporadic_server_policy'Class
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
        Scheduling_Parameters.set_max_pending_replenishments
             (Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              YYval.num);
      }
      ;
edf_policy_item :
      left_paren edf_policy_type
      {
          sched_params_ref:=new Scheduling_Parameters.edf_policy;
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
          Scheduling_Parameters.set_preassigned
               (Scheduling_Parameters.Edf_Policy'Class
                    (Sched_params_ref.all), YYVal.flag);
      }
      ;
edf_deadline :
        comma deadline arrow number
      {
           Scheduling_Parameters.set_deadline
             (Scheduling_Parameters.EDF_Policy'Class
                    (Sched_params_ref.all),
              MAST.Time(YYval.Float_num));
           if not Preassigned_Field_Present then
              Scheduling_Parameters.set_preassigned
                (Scheduling_Parameters.EDF_Policy'Class
                     (Sched_params_ref.all), True);
           end if;
      }
      ;

------------------------------------
--  Overridden_Scheduling Parameters
------------------------------------

overridden_sched_parameters_item :
        overridden_fp_parameters_item
      | overridden_permanent_fp_item
      ;

overridden_fp_parameters_item :
      left_paren overridden_sched_fp_type 
      {
          overridden_sched_params_ref:=
              new Scheduling_Parameters.Overridden_FP_Parameters;
      }
      overridden_sched_arguments right_paren
      ;
overridden_sched_fp_type :
        the_type arrow overridden_fixed_priority
      ;


overridden_permanent_fp_item :
      left_paren overridden_sched_perm_type 
      {
          overridden_sched_params_ref:=
              new Scheduling_Parameters.Overridden_Permanent_FP_Parameters;
      }
      overridden_sched_arguments right_paren
      ;
overridden_sched_perm_type :
        the_type arrow overridden_permanent_fp
      ;

overridden_sched_arguments :
        comma the_priority arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Scheduling_Parameters.set_the_priority
             (Scheduling_Parameters.Overridden_FP_Parameters'Class
                    (Overridden_Sched_params_ref.all),
              MAST.Priority(YYval.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;
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
          synch_params_ref:=new Synchronization_Parameters.SRP_Parameters;
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
          Synchronization_Parameters.set_preassigned
               (Synchronization_Parameters.SRP_Parameters'Class
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
           Synchronization_Parameters.set_preemption_level
             (Synchronization_Parameters.SRP_Parameters'Class
                    (Synch_params_ref.all),
              MAST.Preemption_Level(YYval.num));
           if not Preassigned_Field_Present then
              Synchronization_Parameters.set_preassigned
                (Synchronization_Parameters.SRP_Parameters'Class
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
--  External Events
------------------------------------

external_event_object : any_external_event_object
    {
          begin
             Transactions.Add_External_Event_Link(Trans_Ref.all,A_Link_Ref);
          exception
	    when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("External event already exists");                
          end;
    }
    ;
any_external_event_object :
      periodic_event_object
    | singular_event_object
    | sporadic_event_object
    | unbounded_event_object
    | bursty_event_object
    ;

------------------------------------
--  Periodic_Event_Object
------------------------------------

periodic_event_object : 
      left_paren periodic_event_type
      {
          evnt_ref:=new Events.Periodic_Event;
          A_Link_Ref:=new Graphs.Links.Regular_Link;
          Graphs.set_event(a_link_ref.all,evnt_ref);
      }
      periodic_event_arguments right_paren
      ;
periodic_event_type :
      the_type arrow periodic
      ;
periodic_event_arguments :
        event_name
      | periodic_event_arguments periodic_event_argument
      ;
periodic_event_argument :
        periodic_event_period
      | periodic_event_max_jitter
      | periodic_event_phase
      ;
event_name :
        comma name arrow identifier
      {
        a_name:=symbol_table.item(YYVal.name_index);
        Events.init(Evnt_ref.all,a_name);
      }
      ;
periodic_event_period:
        comma period arrow number
      {
        Events.set_period
             (Events.Periodic_Event'Class(Evnt_ref.all),
              MAST.Time(YYval.float_num));
      }
      ;
periodic_event_max_jitter:
        comma max_jitter arrow number
      {
        Events.set_max_jitter
             (Events.Periodic_Event'Class(Evnt_ref.all),
              MAST.Time(YYval.float_num));
      }
      ;
periodic_event_phase:
        comma phase arrow number
      {
        Events.set_phase
             (Events.Periodic_Event'Class(Evnt_ref.all),
              MAST.Absolute_Time(YYval.float_num));
      }
      ;
------------------------------------
--  Singular_Event_Object
------------------------------------

singular_event_object : 
      left_paren singular_event_type
      {
          evnt_ref:=new Events.Singular_Event;
          A_Link_Ref:=new Graphs.Links.Regular_Link;
          Graphs.set_event(a_link_ref.all,evnt_ref);
      }
      singular_event_arguments right_paren
      ;
singular_event_type :
      the_type arrow singular
      ;
singular_event_arguments :
        event_name
      | singular_event_arguments singular_event_argument
      ;
singular_event_argument :
        singular_event_phase
      ;
singular_event_phase:
        comma phase arrow number
      {
        Events.set_phase
             (Events.Singular_Event'Class(Evnt_ref.all),
              MAST.Absolute_Time(YYval.float_num));
      }
      ;
------------------------------------
--  Sporadic_Event_Object
------------------------------------

sporadic_event_object : 
      left_paren sporadic_event_type
      {
          evnt_ref:=new Events.Sporadic_Event;
          A_Link_Ref:=new Graphs.Links.Regular_Link;
          Graphs.set_event(a_link_ref.all,evnt_ref);
      }
      sporadic_event_arguments right_paren
      ;
sporadic_event_type :
      the_type arrow sporadic
      ;
sporadic_event_arguments :
        event_name
      | sporadic_event_arguments sporadic_event_argument
      ;
sporadic_event_argument :
        aperiodic_event_avg_interarrival
      | aperiodic_event_distribution
      | sporadic_event_min_interarrival
      ;
aperiodic_event_avg_interarrival:
        comma avg_interarrival arrow number
      {
        Events.set_avg_interarrival
             (Events.Aperiodic_Event'Class(Evnt_ref.all),
              MAST.Time(YYval.float_num));
      }
      ;
aperiodic_event_distribution:
        comma distribution arrow dist_function
      {
        Events.set_distribution
             (Events.Aperiodic_Event'Class(Evnt_ref.all),
              Distribution_Function'Val(YYval.Num));
      }
      ;
sporadic_event_min_interarrival:
        comma min_interarrival arrow number
      {
        Events.set_min_interarrival
             (Events.Sporadic_Event'Class(Evnt_ref.all),
              MAST.Time(YYval.float_num));
      }
      ;
------------------------------------
--  Unbounded_Event_Object
------------------------------------

unbounded_event_object : 
      left_paren unbounded_event_type
      {
          evnt_ref:=new Events.Unbounded_Event;
          A_Link_Ref:=new Graphs.Links.Regular_Link;
          Graphs.set_event(a_link_ref.all,evnt_ref);
      }
      unbounded_event_arguments right_paren
      ;
unbounded_event_type :
      the_type arrow unbounded_ev
      ;
unbounded_event_arguments :
        event_name
      | unbounded_event_arguments unbounded_event_argument
      ;
unbounded_event_argument :
        aperiodic_event_avg_interarrival
      | aperiodic_event_distribution
      ;
------------------------------------
--  Bursty_Event_Object
------------------------------------

bursty_event_object : 
      left_paren bursty_event_type
      {
          evnt_ref:=new Events.Bursty_Event;
          A_Link_Ref:=new Graphs.Links.Regular_Link;
          Graphs.set_event(a_link_ref.all,evnt_ref);
      }
      bursty_event_arguments right_paren
      ;
bursty_event_type :
      the_type arrow bursty
      ;
bursty_event_arguments :
        event_name
      | bursty_event_arguments bursty_event_argument
      ;
bursty_event_argument :
        aperiodic_event_avg_interarrival
      | aperiodic_event_distribution
      | bursty_event_bound_interval
      | bursty_event_max_arrivals      
      ;
bursty_event_bound_interval:
        comma bound_interval arrow number
      {
        Events.set_bound_interval
             (Events.Bursty_Event'Class(Evnt_ref.all),
              MAST.Time(YYval.float_num));
      }
      ;
bursty_event_max_arrivals:
        comma max_arrivals arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Max arrivals should be integer value");
        end if;
        Events.set_max_arrivals
             (Events.Bursty_Event'Class(Evnt_ref.all),
              YYval.num);
      }
      ;

------------------------------------
--  Transactions
------------------------------------

transaction_object : 
      transaction left_paren regular_transaction_type 
      {
          trans_ref:=new Transactions.Regular_Transaction;
      }
      transaction_arguments right_paren semicolon
      ;
regular_transaction_type :
      the_type arrow regular
      ;
transaction_arguments :
        transaction_name
      | transaction_arguments transaction_argument
      ;
transaction_argument :
        transaction_external_events_argument
      | transaction_internal_events_argument 
      | transaction_event_handlers_argument
      ;
transaction_name :
        comma name arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Transactions.init(trans_ref.all,a_name);
          begin
             Transactions.lists.add
               (trans_ref,mast_system.transactions);
          exception
	    when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Transaction already exists");                
          end;
      }   
      ;
transaction_external_events_argument :
        comma external_events arrow
            left_paren list_of_external_events right_paren
      ;
list_of_external_events :
        list_of_external_events comma external_event_object
      | external_event_object
      ;
transaction_internal_events_argument :
        comma internal_events arrow
            left_paren list_of_links right_paren
      ;
list_of_links :
        list_of_links comma link_item
      | link_item
      ;
transaction_event_handlers_argument :
        comma event_handlers arrow
            left_paren list_of_event_handlers right_paren
      ;
list_of_event_handlers :
        list_of_event_handlers comma event_handler_item
      | event_handler_item
      ;

-------------------------
-- Links
-------------------------
link_item :
      any_link_item
      {
          begin
             Transactions.Add_Internal_Event_Link(Trans_Ref.all,A_Link_Ref);
          exception
	    when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Internal event already exists");                
          end;
      }
      ;
any_link_item :
        regular_link_item
      ;
regular_link_item :
      left_paren regular_link_type link_args right_paren
      ;
regular_link_type :
      the_type arrow regular
      {
          A_Link_Ref:= new Graphs.Links.Regular_Link;
      }
      ;
link_name :
        comma name arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          evnt_ref:=new Events.Internal_Event;
          Events.Init(evnt_ref.all,a_name);
          Graphs.set_event(a_link_ref.all,evnt_ref);
      }
      ;
link_args :
        link_name
      | link_name link_timing
      ;
link_timing :
        comma timing_requirements arrow timing_requirements_object
      {
        Graphs.Links.set_link_timing_requirements
             (Graphs.Links.Regular_Link(a_link_ref.all),
              timing_reqs_ref);
      }
      ;
-------------------------
-- Event_Handlers
-------------------------

event_handler_item :
      any_event_handler_item
      {
          begin
            Transactions.Add_Event_Handler(Trans_Ref.all,An_Event_Handler_Ref);
          exception
	    when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Event handler already exists");                
          end;
      }
      ;
any_event_handler_item :
        activity_item
      | system_timed_activity_item
      | concentrator_item
      | barrier_item
      | delivery_server_item
      | query_server_item
      | multicast_item
      | rate_event_handler_item
      | delay_event_handler_item
      | offset_event_handler_item
      ;
-------------------------
-- Activity
-------------------------
activity_item :
      left_paren activity_type activity_arguments right_paren
      ;
activity_type :
      the_type arrow activity
      {
          An_Event_Handler_Ref:= new Graphs.event_handlers.Activity;
      }
      ;
activity_arguments :
        activity_argument
      | activity_arguments activity_argument
      ;
activity_argument:
        simple_action_event_handler_input_event
      | simple_action_event_handler_output_event
      | activity_operation_act
      | activity_server_act
      ;
simple_action_event_handler_input_event :
        comma input_event arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          begin
                  A_Link_Ref:=Transactions.Find_Any_Link 
                     (a_name,Trans_ref.all);
                  Graphs.Set_Output_Event_Handler
                      (a_link_ref.all, An_Event_Handler_Ref);
                  Graphs.Event_Handlers.Set_Input_Link
                      (Graphs.Event_Handlers.Simple_Event_Handler
                         (an_event_handler_ref.all),
                       A_Link_Ref);
          exception
                  when Transactions.Link_not_found =>
                     declare 
                        Lnk_Ref : Graphs.Link_Ref:=
                                 new Graphs.Links.Regular_Link;
                        Evnt_Ref : Events.Event_Ref:= 
                                 new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                        Graphs.Set_Output_Event_Handler
                          (Lnk_ref.all, An_Event_Handler_Ref);
                        Graphs.Event_Handlers.Set_Input_Link
                          (Graphs.Event_Handlers.Simple_Event_Handler
                             (an_event_handler_ref.all),Lnk_Ref);
                     end;             
                  when Graphs.Invalid_Link_Type =>
	             User_Defined_Errors.Parser_Error
                         ("Invalid event type for event_handler input");
          end;
      }
      ;
simple_action_event_handler_output_event :
        comma output_event arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          begin
                  A_link_ref:=Transactions.Find_Any_Link 
                     (a_name,Trans_ref.all);
                  Graphs.Set_Input_Event_Handler
                      (a_link_ref.all, An_Event_Handler_Ref);
                  Graphs.Event_Handlers.Set_Output_Link
                      (Graphs.Event_Handlers.Simple_Event_Handler
                          (an_event_handler_ref.all),
                       A_Link_Ref);
          exception
               when Transactions.Link_Not_Found =>
                     declare 
                        Lnk_Ref : Graphs.Link_Ref:=
                                 new Graphs.Links.Regular_Link;
                        Evnt_Ref : Events.Event_Ref:= 
                                 new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                        Graphs.Set_Input_Event_Handler
                          (Lnk_ref.all, An_Event_Handler_Ref);
                        Graphs.Event_Handlers.Set_Output_Link
                          (Graphs.Event_Handlers.Simple_Event_Handler
                             (an_event_handler_ref.all),Lnk_Ref);
                     end;             
               when Graphs.Invalid_Link_Type =>
	          User_Defined_Errors.Parser_Error
                     ("Invalid event type for event_handler output");
          end;
      }
      ;
activity_operation_act :
        comma activity_operation arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare 
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Graphs.Event_Handlers.Set_Activity_Operation
                     (Graphs.Event_Handlers.Activity(an_event_handler_ref.all),
                      Op_Ref);
             end;             
          else 
              Graphs.Event_Handlers.Set_Activity_Operation
                  (Graphs.Event_Handlers.Activity(an_event_handler_ref.all),
                   Operations.Lists.Item(Op_Index,MAST_System.Operations));
          end if;
      }
      ;
activity_server_act :
        comma activity_server arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Srvr_Index:=Scheduling_Servers.Lists.Find
              (a_name,MAST_System.scheduling_servers);
          if Srvr_Index=Scheduling_Servers.Lists.Null_Index then
             declare 
                 Srvr_Ref : Scheduling_Servers.Scheduling_Server_ref:=
                             new Scheduling_Servers.Scheduling_Server;
             begin
                 Scheduling_Servers.Init(Srvr_Ref.all,A_Name);
                 Graphs.Event_Handlers.Set_Activity_Server
                     (Graphs.Event_Handlers.Activity(an_event_handler_ref.all),
                      Srvr_Ref);
             end;             
          else 
              Graphs.Event_Handlers.Set_Activity_Server
                  (Graphs.Event_Handlers.Activity(an_event_handler_ref.all),
                   scheduling_servers.Lists.Item
                     (Srvr_Index,MAST_System.scheduling_Servers));
          end if;
      }
      ;
-------------------------
-- System_Timed_Activity
-------------------------
system_timed_activity_item :
      left_paren system_timed_activity_type 
      activity_arguments right_paren
      ;
system_timed_activity_type :
      the_type arrow system_timed_activity
      {
          An_Event_Handler_Ref:= 
              new Graphs.event_handlers.system_Timed_Activity;
      }
      ;
------------------------
-- concentrator
------------------------
concentrator_item :
      left_paren concentrator_type input_event_handler_arguments right_paren
      ;
concentrator_type :
      the_type arrow concentrator
      {
          An_Event_Handler_Ref:= new Graphs.Event_Handlers.concentrator;
      }
      ;
input_event_handler_arguments :
        input_event_handler_argument
      | input_event_handler_arguments input_event_handler_argument
      ;
input_event_handler_argument:
        input_event_handler_input_events_list_arg
      | input_event_handler_output_event
      ;
input_event_handler_input_events_list_arg :
      comma input_events_list arrow 
          left_paren input_event_handler_input_events_list right_paren
      ;
input_event_handler_input_events_list :
        input_event_handler_input_events_list comma input_events_list_item
      | input_events_list_item
      ;
input_events_list_item :
      identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          begin
                  A_link_Ref:=Transactions.Find_Any_Link 
                     (a_name,Trans_ref.all);
                  Graphs.Set_Output_Event_Handler
                      (a_link_ref.all, An_Event_Handler_Ref);
                  Graphs.Event_Handlers.Add_Input_Link
                      (Graphs.Event_Handlers.Input_Event_Handler
                         (an_event_handler_ref.all),
                       A_Link_Ref);
          exception
               when Transactions.Link_Not_Found =>
                  declare 
                        Lnk_Ref : Graphs.Link_Ref:=
                                 new Graphs.Links.Regular_Link;
                        Evnt_Ref : Events.Event_Ref:= 
                                 new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                        Graphs.Set_Output_Event_Handler
                          (Lnk_ref.all, An_Event_Handler_Ref);
                        Graphs.Event_Handlers.Add_Input_Link
                          (Graphs.Event_Handlers.Input_Event_Handler
                             (an_event_handler_ref.all),Lnk_Ref);
                     end;             
               when Graphs.Invalid_Link_Type =>
                  User_Defined_Errors.Parser_Error
                      ("Invalid event type for event_handler output");
               when List_Exceptions.Already_Exists =>
                  User_Defined_Errors.Parser_Error
                      ("Event already exists");                
          end;
      }
      ;
input_event_handler_output_event :
        comma output_event arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          begin
                  A_Link_Ref:=Transactions.Find_Any_Link 
                     (a_name,Trans_ref.all);
                  Graphs.Set_Input_Event_Handler
                      (a_link_ref.all, An_Event_Handler_Ref);
                  Graphs.Event_Handlers.Set_Output_Link
                      (Graphs.Event_Handlers.Input_Event_Handler
                           (an_event_handler_ref.all),
                       A_Link_Ref);
          exception
               when Transactions.Link_Not_Found =>
                  declare 
                        Lnk_Ref : Graphs.Link_Ref:=
                                 new Graphs.Links.Regular_Link;
                        Evnt_Ref : Events.Event_Ref:= 
                                 new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                        Graphs.Set_Input_Event_Handler
                          (Lnk_ref.all, An_Event_Handler_Ref);
                        Graphs.Event_Handlers.Set_Output_Link
                          (Graphs.Event_Handlers.Input_Event_Handler
                             (an_event_handler_ref.all),Lnk_Ref);
                     end;             
               when Graphs.Invalid_Link_Type =>
	          User_Defined_Errors.Parser_Error
                      ("Invalid event type for event_handler output");
          end;
      }
      ;
------------------------
-- barrier
------------------------
barrier_item :
      left_paren barrier_type input_event_handler_arguments right_paren
      ;
barrier_type :
      the_type arrow barrier
      {
          An_Event_Handler_Ref:= new Graphs.Event_Handlers.barrier;
      }
      ;
------------------------
-- delivery_server
------------------------
delivery_server_item :
      left_paren delivery_server_type delivery_server_arguments 
      right_paren
      ;
delivery_server_type :
      the_type arrow delivery_server
      {
          An_Event_Handler_Ref:= new Graphs.Event_Handlers.delivery_server;
      }
      ;
delivery_server_arguments :
        delivery_server_argument
      | delivery_server_arguments delivery_server_argument
      ;
delivery_server_argument :
        output_event_handler_argument
      | delivery_policy_arg
      ;
delivery_policy_arg :
      comma delivery_policy arrow policy
      {
        Graphs.Event_Handlers.set_policy
             (Graphs.Event_Handlers.delivery_server(An_Event_Handler_ref.all),
              mast.Delivery_policy'Val(YYval.Num));
      }
      ;
output_event_handler_arguments :
        output_event_handler_argument
      | output_event_handler_arguments output_event_handler_argument
      ;
output_event_handler_argument:
        output_event_handler_output_events_list_arg
      | output_event_handler_input_event
      ;
output_event_handler_output_events_list_arg :
      comma output_events_list arrow 
          left_paren output_event_handler_output_events_list right_paren
      ;
output_event_handler_output_events_list :
        output_event_handler_output_events_list comma output_events_list_item
      | output_events_list_item
      ;
output_events_list_item :
      identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          begin
                  A_Link_Ref:=Transactions.Find_Any_Link 
	             (a_name,Trans_ref.all);
                  Graphs.Set_input_Event_Handler
                      (a_link_ref.all, An_Event_Handler_Ref);
                  Graphs.Event_Handlers.Add_output_link
                      (Graphs.Event_Handlers.output_Event_Handler
                           (an_event_handler_ref.all),
                       A_Link_Ref);
          exception
               when Transactions.Link_Not_Found =>
                  declare 
                        Lnk_Ref : Graphs.Link_Ref:=
                                 new Graphs.Links.Regular_Link;
                        Evnt_Ref : Events.Event_Ref:= 
                                 new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                        Graphs.Set_Input_Event_Handler
                          (Lnk_ref.all, An_Event_Handler_Ref);
                        Graphs.Event_Handlers.Add_Output_Link
                          (Graphs.Event_Handlers.Output_Event_Handler
                             (an_event_handler_ref.all),Lnk_Ref);
                     end;             
               when Graphs.Invalid_Link_Type =>
	          User_Defined_Errors.Parser_Error
                      ("Invalid event type for event_handler output");
               when List_Exceptions.Already_Exists =>
                  User_Defined_Errors.Parser_Error
                      ("Event already exists");                
          end;
      }
      ;
output_event_handler_input_event :
        comma input_event arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          begin
                  A_Link_Ref:=Transactions.Find_Any_Link 
                      (a_name,Trans_ref.all);
                  Graphs.Set_output_Event_Handler
                      (a_link_ref.all, An_Event_Handler_Ref);
                  Graphs.Event_Handlers.Set_input_Link
                      (Graphs.Event_Handlers.output_Event_Handler
                          (an_event_handler_ref.all),
                       A_Link_Ref);
          exception
               when Transactions.Link_Not_Found =>
                  declare 
                        Lnk_Ref : Graphs.Link_Ref:=
                                 new Graphs.Links.Regular_Link;
                        Evnt_Ref : Events.Event_Ref:= 
                                 new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                        Graphs.Set_Output_Event_Handler
                          (Lnk_ref.all, An_Event_Handler_Ref);
                        Graphs.Event_Handlers.set_Input_Link
                          (Graphs.Event_Handlers.Output_Event_Handler
                             (an_event_handler_ref.all),Lnk_Ref);
                     end;             
               when Graphs.Invalid_Link_Type =>
	          User_Defined_Errors.Parser_Error
                      ("Invalid event type for event_handler output");
          end;
      }
      ;
------------------------
-- query_server
------------------------
query_server_item :
      left_paren query_server_type query_server_arguments 
      right_paren
      ;
query_server_type :
      the_type arrow query_server
      {
          An_Event_Handler_Ref:= new Graphs.Event_Handlers.query_server;
      }
      ;
query_server_arguments :
        query_server_argument
      | query_server_arguments query_server_argument
      ;
query_server_argument :
        output_event_handler_argument
      | query_policy_arg
      ;
query_policy_arg :
      comma request_policy arrow policy
      {
        Graphs.Event_Handlers.set_policy
             (Graphs.Event_Handlers.query_server(An_Event_Handler_ref.all),
              Mast.Request_policy'Val(YYval.Num));
      }
      ;
------------------------
-- multicast
------------------------
multicast_item :
      left_paren multicast_type output_event_handler_arguments right_paren
      ;
multicast_type :
      the_type arrow multicast
      {
          An_Event_Handler_Ref:= new Graphs.Event_Handlers.multicast;
      }
      ;
-------------------------
-- Rate_Divisor Event_Handler
-------------------------
rate_event_handler_item :
      left_paren rate_event_handler_type 
      rate_event_handler_arguments right_paren
      ;
rate_event_handler_type :
      the_type arrow rate_divisor
      {
          An_Event_Handler_Ref:= new Graphs.Event_Handlers.Rate_Divisor;
      }
      ;
rate_event_handler_arguments :
        rate_event_handler_argument
      | rate_event_handler_arguments rate_event_handler_argument
      ;
rate_event_handler_argument:
        simple_action_event_handler_input_event
      | simple_action_event_handler_output_event
      | rate_event_handler_factor
      ;
rate_event_handler_factor :
        comma rate_factor arrow number
      {
        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Rate factor should be integer value");
        end if;
        Graphs.Event_Handlers.set_rate_factor
             (Graphs.Event_Handlers.rate_divisor(an_event_handler_ref.all),
              YYVal.Num);
      }
      ;
-------------------------
-- Delay Event_Handler
-------------------------
delay_event_handler_item :
      left_paren delay_event_handler_type 
      delay_event_handler_arguments right_paren
      ;
delay_event_handler_type :
      the_type arrow the_delay
      {
          An_Event_Handler_Ref:= new Graphs.Event_Handlers.Delay_Event_Handler;
      }
      ;
delay_event_handler_arguments :
        delay_event_handler_argument
      | delay_event_handler_arguments delay_event_handler_argument
      ;
delay_event_handler_argument:
        simple_action_event_handler_input_event
      | simple_action_event_handler_output_event
      | delay_event_handler_max_interval
      | delay_event_handler_min_interval
      ;
delay_event_handler_max_interval :
        comma delay_max_interval arrow number
      {
        Graphs.Event_Handlers.set_delay_max_interval
             (Graphs.Event_Handlers.delay_Event_Handler
                  (an_event_handler_ref.all),
              MAST.Time(YYVal.float_Num));
      }
      ;
delay_event_handler_min_interval :
        comma delay_min_interval arrow number
      {
        Graphs.Event_Handlers.set_delay_min_interval
             (Graphs.Event_Handlers.delay_Event_Handler
                   (an_event_handler_ref.all),
              MAST.Time(YYVal.float_Num));
      }
      ;
-------------------------
-- Offset Event_Handler
-------------------------
offset_event_handler_item :
      left_paren offset_event_handler_type 
      offset_event_handler_arguments right_paren
      ;
offset_event_handler_type :
      the_type arrow offset
      {
          An_Event_Handler_Ref:= new 
               Graphs.Event_Handlers.Offset_Event_Handler;
      }
      ;
offset_event_handler_arguments :
        offset_event_handler_argument
      | offset_event_handler_arguments offset_event_handler_argument
      ;
offset_event_handler_argument:
        simple_action_event_handler_input_event
      | simple_action_event_handler_output_event
      | delay_event_handler_max_interval
      | delay_event_handler_min_interval
      | offset_event_handler_event
      ;
offset_event_handler_event :
        comma referenced_event arrow identifier
      {
         begin
              a_name:=symbol_table.item(YYVal.name_index);
              Evnt_Ref:=Transactions.Find_Any_Event (A_name,Trans_Ref.all);
              Graphs.Event_Handlers.Set_Referenced_Event
                  (Graphs.Event_Handlers.Offset_Event_Handler
                     (an_event_handler_ref.all),Evnt_Ref);
         exception
             when Transactions.Event_Not_Found =>
                User_Defined_Errors.Parser_Error
                    ("Event name "&To_String(a_name)&" not found");
         end;
      }
      ;

------------------------------------
--  Timing Requirements
------------------------------------

timing_requirements_object :
        hard_global_deadline_req
      | soft_global_deadline_req
      | hard_local_deadline_req
      | soft_local_deadline_req
      | global_max_miss_ratio_req
      | local_max_miss_ratio_req
      | max_jitter_req
      | composite_timing_req
      ;
hard_global_deadline_req :
      left_paren hard_global_deadline_req_type
      {
          timing_reqs_ref:=new Mast.Timing_requirements.hard_global_deadline;
      }
      global_deadline_req_arguments right_paren
      ;
hard_global_deadline_req_type :
      the_type arrow hard_global_deadline
      ;
global_deadline_req_arguments :
        global_deadline_req_argument
      | global_deadline_req_arguments global_deadline_req_argument
      ;
global_deadline_req_argument :
        deadline_req_deadline
      | global_deadline_req_event
      ;
deadline_req_deadline :
        comma deadline arrow number
      {
        Mast.Timing_requirements.set_the_deadline
             (Mast.Timing_requirements.deadline'Class
                    (Timing_reqs_ref.all),
              MAST.Time(YYval.float_num));
      }
      ;
global_deadline_req_event :
        comma referenced_event arrow identifier
      {
         begin
             a_name:=symbol_table.item(YYVal.name_index);
             Evnt_Ref:=Transactions.Find_Any_Event (A_name,Trans_Ref.all);
             Mast.Timing_requirements.set_event
                  (Mast.Timing_requirements.global_deadline
                         (Timing_reqs_ref.all),evnt_ref);
         exception
             when Transactions.Event_Not_Found =>
                  declare 
                        Evnt_Ref : Events.Event_Ref:= 
                                 new Events.Internal_Event;
                  begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Mast.Timing_requirements.set_event
                          (Mast.Timing_requirements.global_deadline
                             (Timing_reqs_ref.all),evnt_ref);
                  end;             
         end;
      }
      ;
soft_global_deadline_req :
      left_paren soft_global_deadline_req_type
      {
          timing_reqs_ref:=new Mast.Timing_requirements.soft_global_deadline;
      }
      global_deadline_req_arguments right_paren
      ;
soft_global_deadline_req_type :
      the_type arrow soft_global_deadline
      ;
hard_local_deadline_req :
      left_paren hard_local_deadline_req_type
      {
          timing_reqs_ref:=new Mast.Timing_requirements.hard_local_deadline;
      }
      deadline_req_deadline right_paren
      ;
hard_local_deadline_req_type :
      the_type arrow hard_local_deadline
      ;
soft_local_deadline_req :
      left_paren soft_local_deadline_req_type
      {
          timing_reqs_ref:=new Mast.Timing_requirements.soft_local_deadline;
      }
      deadline_req_deadline right_paren
      ;
soft_local_deadline_req_type :
      the_type arrow soft_local_deadline
      ;
global_max_miss_ratio_req :
      left_paren global_max_miss_ratio_req_type
      {
          timing_reqs_ref:=new Mast.Timing_requirements.global_max_miss_ratio;
      }
      global_max_miss_req_arguments right_paren
      ;
global_max_miss_ratio_req_type :
      the_type arrow global_max_miss_ratio
      ;
global_max_miss_req_arguments :
        global_max_miss_req_argument
      | global_max_miss_req_arguments global_max_miss_req_argument
      ;
global_max_miss_req_argument :
        deadline_req_deadline
      | global_deadline_req_event
      | global_max_miss_ratio_req_ratio
      ;
global_max_miss_ratio_req_ratio :
        comma ratio arrow number
      {
        begin
           Mast.Timing_requirements.set_ratio
                (Mast.Timing_requirements.global_max_miss_ratio'Class
                       (Timing_reqs_ref.all),
                 MAST.Percentage(YYval.float_num));
        exception
           when Constraint_Error =>
               User_Defined_Errors.Parser_Error
                    ("Bad Percentage");
        end;
      }
      ;
local_max_miss_ratio_req :
      left_paren local_max_miss_ratio_req_type
      {
          timing_reqs_ref:=new Mast.Timing_requirements.local_max_miss_ratio;
      }
      local_max_miss_req_arguments right_paren
      ;
local_max_miss_ratio_req_type :
      the_type arrow local_max_miss_ratio
      ;
local_max_miss_req_arguments :
        local_max_miss_req_argument
      | local_max_miss_req_arguments local_max_miss_req_argument
      ;
local_max_miss_req_argument :
        deadline_req_deadline
      | local_max_miss_ratio_req_ratio
      ;
local_max_miss_ratio_req_ratio :
        comma ratio arrow number
      {
        begin
           Mast.Timing_requirements.set_ratio
                (Mast.Timing_requirements.local_max_miss_ratio'Class
                       (Timing_reqs_ref.all),
                 MAST.Percentage(YYval.float_num));
        exception
           when Constraint_Error =>
               User_Defined_Errors.Parser_Error
                    ("Bad Percentage");
        end;
      }
      ;
max_jitter_req :
      left_paren max_jitter_req_type
      {
          timing_reqs_ref:=new Mast.Timing_requirements.
                                 max_output_jitter_req;
      }
      max_jitter_req_arguments right_paren
      ;
max_jitter_req_arguments :
        max_jitter_req_argument
      | max_jitter_req_arguments max_jitter_req_argument
      ;
max_jitter_req_argument :
        max_jitter_req_event
      | max_jitter_req_max_jitter
      ;
max_jitter_req_type :
      the_type arrow max_output_jitter_req
      ;
max_jitter_req_event :
        comma referenced_event arrow identifier
      {
         begin
             a_name:=symbol_table.item(YYVal.name_index);
             Evnt_Ref:=Transactions.Find_Any_Event (A_name,Trans_Ref.all);
             Mast.Timing_requirements.set_event
                  (Mast.Timing_requirements.max_output_jitter_req
                         (Timing_reqs_ref.all),evnt_ref);
         exception
             when Transactions.Event_Not_Found =>
                  declare 
                        Evnt_Ref : Events.Event_Ref:= 
                                 new Events.Internal_Event;
                  begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Mast.Timing_requirements.set_event
                          (Mast.Timing_requirements.max_output_jitter_req
                             (Timing_reqs_ref.all),evnt_ref);
                  end;             
         end;
      }
      ;
max_jitter_req_max_jitter :
        comma max_output_jitter arrow number
      {
        Mast.Timing_requirements.set_max_output_jitter
             (Mast.Timing_requirements.max_output_jitter_req'Class
                    (Timing_reqs_ref.all),
              MAST.Time(YYval.float_num));
      }
      ;
------------------------------------
--  Composite Timing requirement
------------------------------------

composite_timing_req : 
      left_paren composite_timing_req_type
      {
          sec_timing_reqs_ref:=new Mast.Timing_Requirements.
                                 Composite_Timing_Req;
      }
      composite_timing_req_list_argument right_paren
      {
           Timing_reqs_Ref:=Sec_Timing_Reqs_Ref;
      } 
      ;
composite_timing_req_type :
      the_type arrow composite
      ;
composite_timing_req_list_argument :
        comma requirements_list arrow
            left_paren list_of_timing_requirements right_paren
      ;
list_of_timing_requirements :
        list_of_timing_requirements comma timing_requirement_item
      | timing_requirement_item
      ;
timing_requirement_item : 
        any_timing_requirement_item
      {
          Mast.Timing_Requirements.Add_Requirement
                  (Mast.Timing_Requirements.Composite_Timing_Req
                        (Sec_Timing_Reqs_ref.all),
                   Mast.Timing_requirements.simple_timing_requirement_ref
                        (Timing_Reqs_Ref));
      }
      ;
any_timing_requirement_item :
        hard_global_deadline_req
      | soft_global_deadline_req
      | hard_local_deadline_req
      | soft_local_deadline_req
      | global_max_miss_ratio_req
      | local_max_miss_ratio_req
      | max_jitter_req
      ;
------------------------------------
--  Scheduling_Servers
------------------------------------

scheduling_server_object : 
      scheduling_server server_internal_object semicolon
      ;
server_internal_object :
        fp_server_internal_object
      | regular_server_internal_object
      ;
fp_server_internal_object :
      left_paren fp_server_type
      {
          srvr_ref:=new Scheduling_Servers.Scheduling_Server;
      }
      fp_server_arguments right_paren
      ;
regular_server_internal_object :
      left_paren regular_server_type
      {
          srvr_ref:=new Scheduling_Servers.Scheduling_Server;
      }
      regular_server_arguments right_paren
      ;
fp_server_type :
      the_type arrow fixed_priority
      ;
fp_server_arguments :
        server_name
      | fp_server_arguments fp_server_argument
      ;
fp_server_argument :
        server_processing_res
      | server_sched_params
      | server_synch_params 
      ;
server_name :
        comma name arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          scheduling_Servers.init(srvr_ref.all,a_name);
          begin
             Scheduling_Servers.lists.add
               (srvr_ref,mast_system.scheduling_servers);
          exception
	    when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Scheduling server already exists");                
          end;
      }
      ;
server_processing_res :
        comma server_processing_resource arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Scheduler_Index:=Schedulers.Lists.Find
              (a_name,MAST_System.Schedulers);
          if Scheduler_Index=Schedulers.Lists.Null_Index then
             declare 
                 sched_ref : Schedulers.Scheduler_ref:=
                    new Schedulers.Primary.Primary_scheduler;
             begin
                 Schedulers.Init(sched_ref.all,a_name);
                 Scheduling_servers.Set_server_scheduler
                    (srvr_ref.all,sched_ref);
	      end;
          else
             declare 
                 sched_ref : Schedulers.Scheduler_ref;
             begin
                 sched_ref:=Schedulers.Lists.Item
                      (Scheduler_index,
                       MAST_System.Schedulers);
                 if sched_ref.all in Schedulers.Primary.Primary_Scheduler'class
                 then
                     Scheduling_servers.Set_server_scheduler
	                (srvr_ref.all,sched_ref);
  	         else
                     User_Defined_Errors.Parser_Error
                        ("Processing resource name "&To_String(a_name)&
                          " does not correspond to a primary scheduler");
	         end if;
	      end;
          end if;
      }
      ;
server_sched_params :
        comma server_sched_parameters arrow scheduling_parameters_item
      {
          scheduling_servers.set_server_sched_parameters 
            (srvr_ref.all,Sched_params_ref);
      }
      ;
server_synch_params :
        comma the_synchronization_parameters arrow synchronization_parameters_item
      {
          scheduling_servers.set_server_synch_parameters 
            (srvr_ref.all,Synch_params_ref);
      }
      ;
regular_server_type :
      the_type arrow regular
      ;
regular_server_arguments :
        server_name
      | regular_server_arguments regular_server_argument
      ;
regular_server_argument :
        server_scheduler
      | server_sched_params
      | server_synch_params 
      ;
server_scheduler :
        comma scheduler arrow identifier
      {
          a_name:=symbol_table.item(YYVal.name_index);
          Scheduler_Index:=Schedulers.Lists.Find
              (a_name,MAST_System.Schedulers);
          if Scheduler_Index=Schedulers.Lists.Null_Index then
             declare 
                 sched_ref : Schedulers.Scheduler_ref:=
                    new Schedulers.Primary.Primary_scheduler;
             begin
                 Schedulers.Init(sched_ref.all,a_name);
                 Scheduling_servers.Set_server_scheduler
                    (srvr_ref.all,sched_ref);
	      end;
          else
             declare 
                 sched_ref : Schedulers.Scheduler_ref;
             begin
                 sched_ref:=Schedulers.Lists.Item
                      (Scheduler_index,
                       MAST_System.Schedulers);
                 Scheduling_servers.Set_server_scheduler
	                (srvr_ref.all,sched_ref);
	      end;
          end if;
      }
      ;

------------------------------------
--  Code sections
------------------------------------

%%
with MAST, MAST.Operations, MAST.Shared_Resources, 
  MAST.Processing_Resources, Mast.Processing_Resources.Processor,
  Mast.Processing_Resources.Network,
  Mast.Schedulers,Mast.Schedulers.Primary,Mast.Schedulers.Secondary,
  Mast.Scheduling_Policies,
  MAST.Events, MAST.Scheduling_Servers, MAST.IO,
  MAST.Transactions, MAST.Timing_Requirements, MAST.Graphs,
  MAST.Graphs.Links, MAST.Graphs.Event_Handlers, MAST.Systems, 
  MAST.Scheduling_Parameters, Mast.Synchronization_Parameters,
  Mast.Drivers,Mast.Timers,List_Exceptions;
use MAST;
with Symbol_Table; use Symbol_Table;
with MAST_lex; Use MAST_Lex;
with MAST_lex_dfa;
with MAST_lex_io;
with Var_Strings; use Var_Strings;
with MAST_Parser_Tokens, MAST_Parser_Shift_Reduce,
  MAST_Parser_Goto,MAST_Parser_Error_Report,MAST_Lex_IO;
use MAST_Parser_Tokens, MAST_Parser_Shift_Reduce,
  MAST_Parser_Goto,MAST_Lex_IO;
with Text_IO; use Text_IO;
procedure MAST_Parser (MAST_System : out MAST.Systems.System) is

      procedure YYError (S : in String) is  
      begin
          MAST_Parser_Error_Report.Report_Continuable_Error
                 (YY_Line_Number, YY_Begin_Column, YY_End_Column, S, True);
      end YYError;

      Processing_Res_Ref    : Processing_Resources.Processing_Resource_Ref;
      Proc_Res_Index        : Processing_Resources.Lists.Index;
      Scheduler_Ref         : Schedulers.Scheduler_Ref;
      Sched_Policy_Ref      : Scheduling_Policies.Scheduling_Policy_Ref;
      Shared_Res_Ref        : Shared_Resources.Shared_Resource_Ref; 
      Op_Ref                : Operations.Operation_Ref;
      Evnt_Ref              : Events.Event_Ref;
      Srvr_Ref              : Scheduling_Servers.Scheduling_Server_Ref;
      Timing_Reqs_Ref,
        Sec_Timing_reqs_ref : Mast.Timing_Requirements.Timing_Requirement_Ref;
      Sched_Params_Ref      : Scheduling_Parameters.Sched_Parameters_Ref;
      Synch_Params_Ref      : 
                    Synchronization_Parameters.Synch_Parameters_Ref;
      Overridden_Sched_Params_Ref : 
                    Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Trans_Ref             : Transactions.Transaction_Ref;
      An_Event_Handler_Ref  : Graphs.Event_Handler_Ref;
      A_Link_Ref           : Graphs.Link_Ref; 
      A_Driver_Ref         : Drivers.Driver_Ref;
      A_Timer_Ref          : Timers.System_Timer_Ref;      
      Op_Index : Operations.Lists.Index;
      Scheduler_Index      : Schedulers.Lists.Index;
      Shared_res_Index : Shared_resources.Lists.Index;
      Srvr_Index : Scheduling_Servers.Lists.Index;
      preassigned_field_present : Boolean:=False;
      Null_System : Mast.Systems.System;
      A_Name : Var_string;

      use type Operations.Lists.Index;
      use type Graphs.Link_Lists.Index;
      use type Processing_resources.Lists.Index;
      use type Schedulers.Lists.Index;
      use type Shared_resources.Lists.Index;
      use type Scheduling_Servers.Lists.Index;

##

begin 
     Mast_Lex_dfa.yy_init:=true;
     Mast_Lex_dfa.yy_start:=0;
     Mast_Lex_IO.Saved_Tok_Line1:=null;
     Mast_Lex_IO.Saved_Tok_Line2:=null;
     Mast_Lex_IO.Line_Number_Of_Saved_Tok_Line1:=0;
     Mast_Lex_IO.Line_Number_Of_Saved_Tok_Line2:=0;
     Mast_Lex_IO.tok_begin_line:=1;
     Mast_Lex_IO.tok_end_line:=1;
     Mast_Lex_IO.tok_begin_col:=0;
     Mast_Lex_IO.tok_end_col:=0;
     Mast_Lex_IO.token_at_end_of_line:=False;
     Mast_Parser_Error_Report.Total_Errors:=0;
     Mast_Parser_Error_Report.Total_Warnings:=0;
     Mast_System:=Null_System;
     YYparse;
end MAST_Parser;



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
       Text_IO.Put_Line("******************************************");
       Text_IO.Put_Line("Error list output in file: mast_parser.lis");
       Text_IO.Put_Line("******************************************");
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
