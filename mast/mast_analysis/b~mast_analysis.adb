pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b~mast_analysis.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b~mast_analysis.adb");
pragma Suppress (Overflow_Check);
with Ada.Exceptions;

package body ada_main is

   E064 : Short_Integer; pragma Import (Ada, E064, "system__os_lib_E");
   E014 : Short_Integer; pragma Import (Ada, E014, "system__soft_links_E");
   E012 : Short_Integer; pragma Import (Ada, E012, "system__exception_table_E");
   E059 : Short_Integer; pragma Import (Ada, E059, "ada__io_exceptions_E");
   E037 : Short_Integer; pragma Import (Ada, E037, "ada__containers_E");
   E022 : Short_Integer; pragma Import (Ada, E022, "system__exceptions_E");
   E009 : Short_Integer; pragma Import (Ada, E009, "ada__strings_E");
   E092 : Short_Integer; pragma Import (Ada, E092, "ada__strings__maps_E");
   E095 : Short_Integer; pragma Import (Ada, E095, "ada__strings__maps__constants_E");
   E042 : Short_Integer; pragma Import (Ada, E042, "interfaces__c_E");
   E088 : Short_Integer; pragma Import (Ada, E088, "system__soft_links__initialize_E");
   E070 : Short_Integer; pragma Import (Ada, E070, "system__object_reader_E");
   E049 : Short_Integer; pragma Import (Ada, E049, "system__dwarf_lines_E");
   E036 : Short_Integer; pragma Import (Ada, E036, "system__traceback__symbolic_E");
   E301 : Short_Integer; pragma Import (Ada, E301, "ada__numerics_E");
   E099 : Short_Integer; pragma Import (Ada, E099, "ada__tags_E");
   E107 : Short_Integer; pragma Import (Ada, E107, "ada__streams_E");
   E115 : Short_Integer; pragma Import (Ada, E115, "system__file_control_block_E");
   E114 : Short_Integer; pragma Import (Ada, E114, "system__finalization_root_E");
   E112 : Short_Integer; pragma Import (Ada, E112, "ada__finalization_E");
   E111 : Short_Integer; pragma Import (Ada, E111, "system__file_io_E");
   E230 : Short_Integer; pragma Import (Ada, E230, "ada__streams__stream_io_E");
   E143 : Short_Integer; pragma Import (Ada, E143, "system__storage_pools_E");
   E139 : Short_Integer; pragma Import (Ada, E139, "system__finalization_masters_E");
   E137 : Short_Integer; pragma Import (Ada, E137, "system__storage_pools__subpools_E");
   E133 : Short_Integer; pragma Import (Ada, E133, "ada__strings__unbounded_E");
   E179 : Short_Integer; pragma Import (Ada, E179, "ada__calendar_E");
   E105 : Short_Integer; pragma Import (Ada, E105, "ada__text_io_E");
   E203 : Short_Integer; pragma Import (Ada, E203, "system__pool_global_E");
   E310 : Short_Integer; pragma Import (Ada, E310, "system__random_seed_E");
   E196 : Short_Integer; pragma Import (Ada, E196, "binary_trees_E");
   E118 : Short_Integer; pragma Import (Ada, E118, "list_exceptions_E");
   E171 : Short_Integer; pragma Import (Ada, E171, "doubly_linked_lists_E");
   E274 : Short_Integer; pragma Import (Ada, E274, "dynamic_lists_E");
   E278 : Short_Integer; pragma Import (Ada, E278, "associations_E");
   E222 : Short_Integer; pragma Import (Ada, E222, "hash_lists_E");
   E175 : Short_Integer; pragma Import (Ada, E175, "indexed_lists_E");
   E320 : Short_Integer; pragma Import (Ada, E320, "mast_lex_dfa_E");
   E322 : Short_Integer; pragma Import (Ada, E322, "mast_lex_io_E");
   E325 : Short_Integer; pragma Import (Ada, E325, "mast_parser_error_report_E");
   E292 : Short_Integer; pragma Import (Ada, E292, "priority_queues_E");
   E123 : Short_Integer; pragma Import (Ada, E123, "var_strings_E");
   E120 : Short_Integer; pragma Import (Ada, E120, "mast_E");
   E151 : Short_Integer; pragma Import (Ada, E151, "mast__tool_exceptions_E");
   E131 : Short_Integer; pragma Import (Ada, E131, "mast__annealing_parameters_E");
   E272 : Short_Integer; pragma Import (Ada, E272, "mast__hopa_parameters_E");
   E201 : Short_Integer; pragma Import (Ada, E201, "named_lists_E");
   E199 : Short_Integer; pragma Import (Ada, E199, "symbol_table_E");
   E197 : Short_Integer; pragma Import (Ada, E197, "mast_parser_tokens_E");
   E177 : Short_Integer; pragma Import (Ada, E177, "mast__io_E");
   E226 : Short_Integer; pragma Import (Ada, E226, "mast__events_E");
   E224 : Short_Integer; pragma Import (Ada, E224, "mast__graphs_E");
   E238 : Short_Integer; pragma Import (Ada, E238, "mast__scheduling_parameters_E");
   E250 : Short_Integer; pragma Import (Ada, E250, "mast__scheduling_policies_E");
   E240 : Short_Integer; pragma Import (Ada, E240, "mast__synchronization_parameters_E");
   E220 : Short_Integer; pragma Import (Ada, E220, "mast__results_E");
   E236 : Short_Integer; pragma Import (Ada, E236, "mast__timing_requirements_E");
   E234 : Short_Integer; pragma Import (Ada, E234, "mast__graphs__links_E");
   E248 : Short_Integer; pragma Import (Ada, E248, "mast__processing_resources_E");
   E246 : Short_Integer; pragma Import (Ada, E246, "mast__schedulers_E");
   E252 : Short_Integer; pragma Import (Ada, E252, "mast__schedulers__primary_E");
   E244 : Short_Integer; pragma Import (Ada, E244, "mast__scheduling_servers_E");
   E254 : Short_Integer; pragma Import (Ada, E254, "mast__schedulers__secondary_E");
   E242 : Short_Integer; pragma Import (Ada, E242, "mast__shared_resources_E");
   E214 : Short_Integer; pragma Import (Ada, E214, "mast__operations_E");
   E173 : Short_Integer; pragma Import (Ada, E173, "mast__drivers_E");
   E256 : Short_Integer; pragma Import (Ada, E256, "mast__graphs__event_handlers_E");
   E258 : Short_Integer; pragma Import (Ada, E258, "mast__processing_resources__network_E");
   E262 : Short_Integer; pragma Import (Ada, E262, "mast__timers_E");
   E260 : Short_Integer; pragma Import (Ada, E260, "mast__processing_resources__processor_E");
   E270 : Short_Integer; pragma Import (Ada, E270, "mast__schedulers__adjustment_E");
   E266 : Short_Integer; pragma Import (Ada, E266, "mast__transactions_E");
   E268 : Short_Integer; pragma Import (Ada, E268, "mast__systems_E");
   E282 : Short_Integer; pragma Import (Ada, E282, "mast__max_numbers_E");
   E264 : Short_Integer; pragma Import (Ada, E264, "mast__transaction_operations_E");
   E169 : Short_Integer; pragma Import (Ada, E169, "mast__consistency_checks_E");
   E280 : Short_Integer; pragma Import (Ada, E280, "mast__linear_translation_E");
   E298 : Short_Integer; pragma Import (Ada, E298, "mast__linear_analysis_tools_E");
   E284 : Short_Integer; pragma Import (Ada, E284, "mast__restrictions_E");
   E276 : Short_Integer; pragma Import (Ada, E276, "mast__miscelaneous_tools_E");
   E294 : Short_Integer; pragma Import (Ada, E294, "mast__tools_E");
   E314 : Short_Integer; pragma Import (Ada, E314, "mast__monoprocessor_tools_E");
   E312 : Short_Integer; pragma Import (Ada, E312, "mast__tools__schedulability_index_E");
   E300 : Short_Integer; pragma Import (Ada, E300, "mast__linear_priority_assignment_tools_E");
   E296 : Short_Integer; pragma Import (Ada, E296, "mast__edf_tools_E");
   E318 : Short_Integer; pragma Import (Ada, E318, "mast_lex_E");

   Sec_Default_Sized_Stacks : array (1 .. 1) of aliased System.Secondary_Stack.SS_Stack (System.Parameters.Runtime_Default_Sec_Stack_Size);

   Local_Priority_Specific_Dispatching : constant String := "";
   Local_Interrupt_States : constant String := "";

   Is_Elaborated : Boolean := False;

   procedure finalize_library is
   begin
      E268 := E268 - 1;
      declare
         procedure F1;
         pragma Import (Ada, F1, "mast__systems__finalize_spec");
      begin
         F1;
      end;
      E266 := E266 - 1;
      declare
         procedure F2;
         pragma Import (Ada, F2, "mast__transactions__finalize_spec");
      begin
         F2;
      end;
      E260 := E260 - 1;
      declare
         procedure F3;
         pragma Import (Ada, F3, "mast__processing_resources__processor__finalize_spec");
      begin
         F3;
      end;
      E262 := E262 - 1;
      declare
         procedure F4;
         pragma Import (Ada, F4, "mast__timers__finalize_spec");
      begin
         F4;
      end;
      E258 := E258 - 1;
      declare
         procedure F5;
         pragma Import (Ada, F5, "mast__processing_resources__network__finalize_spec");
      begin
         F5;
      end;
      E256 := E256 - 1;
      declare
         procedure F6;
         pragma Import (Ada, F6, "mast__graphs__event_handlers__finalize_spec");
      begin
         F6;
      end;
      E173 := E173 - 1;
      declare
         procedure F7;
         pragma Import (Ada, F7, "mast__drivers__finalize_spec");
      begin
         F7;
      end;
      E214 := E214 - 1;
      declare
         procedure F8;
         pragma Import (Ada, F8, "mast__operations__finalize_spec");
      begin
         F8;
      end;
      E242 := E242 - 1;
      declare
         procedure F9;
         pragma Import (Ada, F9, "mast__shared_resources__finalize_spec");
      begin
         F9;
      end;
      E244 := E244 - 1;
      E254 := E254 - 1;
      declare
         procedure F10;
         pragma Import (Ada, F10, "mast__schedulers__secondary__finalize_spec");
      begin
         F10;
      end;
      declare
         procedure F11;
         pragma Import (Ada, F11, "mast__scheduling_servers__finalize_spec");
      begin
         F11;
      end;
      E252 := E252 - 1;
      declare
         procedure F12;
         pragma Import (Ada, F12, "mast__schedulers__primary__finalize_spec");
      begin
         F12;
      end;
      E246 := E246 - 1;
      declare
         procedure F13;
         pragma Import (Ada, F13, "mast__schedulers__finalize_spec");
      begin
         F13;
      end;
      E248 := E248 - 1;
      declare
         procedure F14;
         pragma Import (Ada, F14, "mast__processing_resources__finalize_spec");
      begin
         F14;
      end;
      E220 := E220 - 1;
      E234 := E234 - 1;
      declare
         procedure F15;
         pragma Import (Ada, F15, "mast__graphs__links__finalize_spec");
      begin
         F15;
      end;
      E236 := E236 - 1;
      declare
         procedure F16;
         pragma Import (Ada, F16, "mast__timing_requirements__finalize_spec");
      begin
         F16;
      end;
      declare
         procedure F17;
         pragma Import (Ada, F17, "mast__results__finalize_spec");
      begin
         F17;
      end;
      E240 := E240 - 1;
      declare
         procedure F18;
         pragma Import (Ada, F18, "mast__synchronization_parameters__finalize_spec");
      begin
         F18;
      end;
      E250 := E250 - 1;
      declare
         procedure F19;
         pragma Import (Ada, F19, "mast__scheduling_policies__finalize_spec");
      begin
         F19;
      end;
      E238 := E238 - 1;
      declare
         procedure F20;
         pragma Import (Ada, F20, "mast__scheduling_parameters__finalize_spec");
      begin
         F20;
      end;
      E224 := E224 - 1;
      declare
         procedure F21;
         pragma Import (Ada, F21, "mast__graphs__finalize_spec");
      begin
         F21;
      end;
      E226 := E226 - 1;
      declare
         procedure F22;
         pragma Import (Ada, F22, "mast__events__finalize_spec");
      begin
         F22;
      end;
      E203 := E203 - 1;
      declare
         procedure F23;
         pragma Import (Ada, F23, "system__pool_global__finalize_spec");
      begin
         F23;
      end;
      E105 := E105 - 1;
      declare
         procedure F24;
         pragma Import (Ada, F24, "ada__text_io__finalize_spec");
      begin
         F24;
      end;
      E133 := E133 - 1;
      declare
         procedure F25;
         pragma Import (Ada, F25, "ada__strings__unbounded__finalize_spec");
      begin
         F25;
      end;
      E137 := E137 - 1;
      declare
         procedure F26;
         pragma Import (Ada, F26, "system__storage_pools__subpools__finalize_spec");
      begin
         F26;
      end;
      E139 := E139 - 1;
      declare
         procedure F27;
         pragma Import (Ada, F27, "system__finalization_masters__finalize_spec");
      begin
         F27;
      end;
      E230 := E230 - 1;
      declare
         procedure F28;
         pragma Import (Ada, F28, "ada__streams__stream_io__finalize_spec");
      begin
         F28;
      end;
      declare
         procedure F29;
         pragma Import (Ada, F29, "system__file_io__finalize_body");
      begin
         E111 := E111 - 1;
         F29;
      end;
      declare
         procedure Reraise_Library_Exception_If_Any;
            pragma Import (Ada, Reraise_Library_Exception_If_Any, "__gnat_reraise_library_exception_if_any");
      begin
         Reraise_Library_Exception_If_Any;
      end;
   end finalize_library;

   procedure adafinal is
      procedure s_stalib_adafinal;
      pragma Import (C, s_stalib_adafinal, "system__standard_library__adafinal");

      procedure Runtime_Finalize;
      pragma Import (C, Runtime_Finalize, "__gnat_runtime_finalize");

   begin
      if not Is_Elaborated then
         return;
      end if;
      Is_Elaborated := False;
      Runtime_Finalize;
      s_stalib_adafinal;
   end adafinal;

   type No_Param_Proc is access procedure;

   procedure adainit is
      Main_Priority : Integer;
      pragma Import (C, Main_Priority, "__gl_main_priority");
      Time_Slice_Value : Integer;
      pragma Import (C, Time_Slice_Value, "__gl_time_slice_val");
      WC_Encoding : Character;
      pragma Import (C, WC_Encoding, "__gl_wc_encoding");
      Locking_Policy : Character;
      pragma Import (C, Locking_Policy, "__gl_locking_policy");
      Queuing_Policy : Character;
      pragma Import (C, Queuing_Policy, "__gl_queuing_policy");
      Task_Dispatching_Policy : Character;
      pragma Import (C, Task_Dispatching_Policy, "__gl_task_dispatching_policy");
      Priority_Specific_Dispatching : System.Address;
      pragma Import (C, Priority_Specific_Dispatching, "__gl_priority_specific_dispatching");
      Num_Specific_Dispatching : Integer;
      pragma Import (C, Num_Specific_Dispatching, "__gl_num_specific_dispatching");
      Main_CPU : Integer;
      pragma Import (C, Main_CPU, "__gl_main_cpu");
      Interrupt_States : System.Address;
      pragma Import (C, Interrupt_States, "__gl_interrupt_states");
      Num_Interrupt_States : Integer;
      pragma Import (C, Num_Interrupt_States, "__gl_num_interrupt_states");
      Unreserve_All_Interrupts : Integer;
      pragma Import (C, Unreserve_All_Interrupts, "__gl_unreserve_all_interrupts");
      Detect_Blocking : Integer;
      pragma Import (C, Detect_Blocking, "__gl_detect_blocking");
      Default_Stack_Size : Integer;
      pragma Import (C, Default_Stack_Size, "__gl_default_stack_size");
      Default_Secondary_Stack_Size : System.Parameters.Size_Type;
      pragma Import (C, Default_Secondary_Stack_Size, "__gnat_default_ss_size");
      Leap_Seconds_Support : Integer;
      pragma Import (C, Leap_Seconds_Support, "__gl_leap_seconds_support");
      Bind_Env_Addr : System.Address;
      pragma Import (C, Bind_Env_Addr, "__gl_bind_env_addr");

      procedure Runtime_Initialize (Install_Handler : Integer);
      pragma Import (C, Runtime_Initialize, "__gnat_runtime_initialize");

      Finalize_Library_Objects : No_Param_Proc;
      pragma Import (C, Finalize_Library_Objects, "__gnat_finalize_library_objects");
      Binder_Sec_Stacks_Count : Natural;
      pragma Import (Ada, Binder_Sec_Stacks_Count, "__gnat_binder_ss_count");
      Default_Sized_SS_Pool : System.Address;
      pragma Import (Ada, Default_Sized_SS_Pool, "__gnat_default_ss_pool");

   begin
      if Is_Elaborated then
         return;
      end if;
      Is_Elaborated := True;
      Main_Priority := -1;
      Time_Slice_Value := -1;
      WC_Encoding := 'b';
      Locking_Policy := ' ';
      Queuing_Policy := ' ';
      Task_Dispatching_Policy := ' ';
      Priority_Specific_Dispatching :=
        Local_Priority_Specific_Dispatching'Address;
      Num_Specific_Dispatching := 0;
      Main_CPU := -1;
      Interrupt_States := Local_Interrupt_States'Address;
      Num_Interrupt_States := 0;
      Unreserve_All_Interrupts := 0;
      Detect_Blocking := 0;
      Default_Stack_Size := -1;
      Leap_Seconds_Support := 0;

      ada_main'Elab_Body;
      Default_Secondary_Stack_Size := System.Parameters.Runtime_Default_Sec_Stack_Size;
      Binder_Sec_Stacks_Count := 1;
      Default_Sized_SS_Pool := Sec_Default_Sized_Stacks'Address;

      Runtime_Initialize (1);

      Finalize_Library_Objects := finalize_library'access;

      System.Soft_Links'Elab_Spec;
      System.Exception_Table'Elab_Body;
      E012 := E012 + 1;
      Ada.Io_Exceptions'Elab_Spec;
      E059 := E059 + 1;
      Ada.Containers'Elab_Spec;
      E037 := E037 + 1;
      System.Exceptions'Elab_Spec;
      E022 := E022 + 1;
      Ada.Strings'Elab_Spec;
      E009 := E009 + 1;
      Ada.Strings.Maps'Elab_Spec;
      Ada.Strings.Maps.Constants'Elab_Spec;
      E095 := E095 + 1;
      System.Os_Lib'Elab_Body;
      E064 := E064 + 1;
      Interfaces.C'Elab_Spec;
      System.Soft_Links.Initialize'Elab_Body;
      E088 := E088 + 1;
      E014 := E014 + 1;
      E092 := E092 + 1;
      E042 := E042 + 1;
      System.Object_Reader'Elab_Spec;
      System.Dwarf_Lines'Elab_Spec;
      E070 := E070 + 1;
      System.Traceback.Symbolic'Elab_Body;
      E036 := E036 + 1;
      E049 := E049 + 1;
      Ada.Numerics'Elab_Spec;
      E301 := E301 + 1;
      Ada.Tags'Elab_Spec;
      Ada.Tags'Elab_Body;
      E099 := E099 + 1;
      Ada.Streams'Elab_Spec;
      E107 := E107 + 1;
      System.File_Control_Block'Elab_Spec;
      E115 := E115 + 1;
      System.Finalization_Root'Elab_Spec;
      E114 := E114 + 1;
      Ada.Finalization'Elab_Spec;
      E112 := E112 + 1;
      System.File_Io'Elab_Body;
      E111 := E111 + 1;
      Ada.Streams.Stream_Io'Elab_Spec;
      E230 := E230 + 1;
      System.Storage_Pools'Elab_Spec;
      E143 := E143 + 1;
      System.Finalization_Masters'Elab_Spec;
      System.Finalization_Masters'Elab_Body;
      E139 := E139 + 1;
      System.Storage_Pools.Subpools'Elab_Spec;
      E137 := E137 + 1;
      Ada.Strings.Unbounded'Elab_Spec;
      E133 := E133 + 1;
      Ada.Calendar'Elab_Spec;
      Ada.Calendar'Elab_Body;
      E179 := E179 + 1;
      Ada.Text_Io'Elab_Spec;
      Ada.Text_Io'Elab_Body;
      E105 := E105 + 1;
      System.Pool_Global'Elab_Spec;
      E203 := E203 + 1;
      System.Random_Seed'Elab_Body;
      E310 := E310 + 1;
      E196 := E196 + 1;
      List_Exceptions'Elab_Spec;
      E118 := E118 + 1;
      E171 := E171 + 1;
      E274 := E274 + 1;
      E278 := E278 + 1;
      E222 := E222 + 1;
      E175 := E175 + 1;
      E320 := E320 + 1;
      mast_lex_io'elab_spec;
      E322 := E322 + 1;
      Mast_Parser_Error_Report'Elab_Spec;
      E325 := E325 + 1;
      E292 := E292 + 1;
      Var_Strings'Elab_Spec;
      E123 := E123 + 1;
      Mast'Elab_Spec;
      Mast'Elab_Body;
      E120 := E120 + 1;
      MAST.TOOL_EXCEPTIONS'ELAB_SPEC;
      MAST.TOOL_EXCEPTIONS'ELAB_BODY;
      E151 := E151 + 1;
      Mast.Annealing_Parameters'Elab_Body;
      E131 := E131 + 1;
      Mast.Hopa_Parameters'Elab_Body;
      E272 := E272 + 1;
      E201 := E201 + 1;
      Symbol_Table'Elab_Spec;
      Symbol_Table'Elab_Body;
      E199 := E199 + 1;
      Mast_Parser_Tokens'Elab_Spec;
      E197 := E197 + 1;
      MAST.IO'ELAB_BODY;
      E177 := E177 + 1;
      MAST.EVENTS'ELAB_SPEC;
      MAST.EVENTS'ELAB_BODY;
      E226 := E226 + 1;
      MAST.GRAPHS'ELAB_SPEC;
      MAST.GRAPHS'ELAB_BODY;
      E224 := E224 + 1;
      Mast.Scheduling_Parameters'Elab_Spec;
      Mast.Scheduling_Parameters'Elab_Body;
      E238 := E238 + 1;
      Mast.Scheduling_Policies'Elab_Spec;
      Mast.Scheduling_Policies'Elab_Body;
      E250 := E250 + 1;
      Mast.Synchronization_Parameters'Elab_Spec;
      Mast.Synchronization_Parameters'Elab_Body;
      E240 := E240 + 1;
      MAST.RESULTS'ELAB_SPEC;
      MAST.TIMING_REQUIREMENTS'ELAB_SPEC;
      MAST.TIMING_REQUIREMENTS'ELAB_BODY;
      E236 := E236 + 1;
      MAST.GRAPHS.LINKS'ELAB_SPEC;
      MAST.GRAPHS.LINKS'ELAB_BODY;
      E234 := E234 + 1;
      MAST.RESULTS'ELAB_BODY;
      E220 := E220 + 1;
      Mast.Processing_Resources'Elab_Spec;
      Mast.Processing_Resources'Elab_Body;
      E248 := E248 + 1;
      Mast.Schedulers'Elab_Spec;
      Mast.Schedulers'Elab_Body;
      E246 := E246 + 1;
      Mast.Schedulers.Primary'Elab_Spec;
      Mast.Schedulers.Primary'Elab_Body;
      E252 := E252 + 1;
      MAST.SCHEDULING_SERVERS'ELAB_SPEC;
      Mast.Schedulers.Secondary'Elab_Spec;
      Mast.Schedulers.Secondary'Elab_Body;
      E254 := E254 + 1;
      MAST.SCHEDULING_SERVERS'ELAB_BODY;
      E244 := E244 + 1;
      Mast.Shared_Resources'Elab_Spec;
      Mast.Shared_Resources'Elab_Body;
      E242 := E242 + 1;
      MAST.OPERATIONS'ELAB_SPEC;
      MAST.OPERATIONS'ELAB_BODY;
      E214 := E214 + 1;
      Mast.Drivers'Elab_Spec;
      Mast.Drivers'Elab_Body;
      E173 := E173 + 1;
      MAST.GRAPHS.EVENT_HANDLERS'ELAB_SPEC;
      MAST.GRAPHS.EVENT_HANDLERS'ELAB_BODY;
      E256 := E256 + 1;
      Mast.Processing_Resources.Network'Elab_Spec;
      Mast.Processing_Resources.Network'Elab_Body;
      E258 := E258 + 1;
      Mast.Timers'Elab_Spec;
      Mast.Timers'Elab_Body;
      E262 := E262 + 1;
      Mast.Processing_Resources.Processor'Elab_Spec;
      Mast.Processing_Resources.Processor'Elab_Body;
      E260 := E260 + 1;
      E270 := E270 + 1;
      MAST.TRANSACTIONS'ELAB_SPEC;
      MAST.TRANSACTIONS'ELAB_BODY;
      E266 := E266 + 1;
      Mast.Systems'Elab_Spec;
      Mast.Systems'Elab_Body;
      E268 := E268 + 1;
      E282 := E282 + 1;
      MAST.TRANSACTION_OPERATIONS'ELAB_SPEC;
      E264 := E264 + 1;
      MAST.CONSISTENCY_CHECKS'ELAB_BODY;
      E169 := E169 + 1;
      E280 := E280 + 1;
      E298 := E298 + 1;
      MAST.RESTRICTIONS'ELAB_BODY;
      E284 := E284 + 1;
      MAST.MISCELANEOUS_TOOLS'ELAB_BODY;
      E276 := E276 + 1;
      MAST.TOOLS.SCHEDULABILITY_INDEX'ELAB_SPEC;
      E312 := E312 + 1;
      E296 := E296 + 1;
      E314 := E314 + 1;
      E294 := E294 + 1;
      E300 := E300 + 1;
      E318 := E318 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_mast_analysis");

   function main
     (argc : Integer;
      argv : System.Address;
      envp : System.Address)
      return Integer
   is
      procedure Initialize (Addr : System.Address);
      pragma Import (C, Initialize, "__gnat_initialize");

      procedure Finalize;
      pragma Import (C, Finalize, "__gnat_finalize");
      SEH : aliased array (1 .. 2) of Integer;

      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      gnat_argc := argc;
      gnat_argv := argv;
      gnat_envp := envp;

      Initialize (SEH'Address);
      adainit;
      Ada_Main_Program;
      adafinal;
      Finalize;
      return (gnat_exit_status);
   end;

--  BEGIN Object file/option list
   --   ./mast_analysis_help.o
   --   ./binary_trees.o
   --   ./list_exceptions.o
   --   ./doubly_linked_lists.o
   --   ./dynamic_lists.o
   --   ./associations.o
   --   ./hash_lists.o
   --   ./indexed_lists.o
   --   ./mast_lex_dfa.o
   --   ./mast_lex_io.o
   --   ./mast_parser_error_report.o
   --   ./mast_parser_goto.o
   --   ./mast_parser_shift_reduce.o
   --   ./priority_queues.o
   --   ./var_strings.o
   --   ./mast.o
   --   ./mast-tool_exceptions.o
   --   ./mast-annealing_parameters.o
   --   ./mast-hopa_parameters.o
   --   ./named_lists.o
   --   ./symbol_table.o
   --   ./mast_parser_tokens.o
   --   ./mast-io.o
   --   ./mast-events.o
   --   ./mast-graphs.o
   --   ./mast-scheduling_parameters.o
   --   ./mast-scheduling_policies.o
   --   ./mast-synchronization_parameters.o
   --   ./mast-timing_requirements.o
   --   ./mast-graphs-links.o
   --   ./mast-results.o
   --   ./mast-processing_resources.o
   --   ./mast-schedulers.o
   --   ./mast-schedulers-primary.o
   --   ./mast-schedulers-secondary.o
   --   ./mast-scheduling_servers.o
   --   ./mast-shared_resources.o
   --   ./mast-operations.o
   --   ./mast-drivers.o
   --   ./mast-graphs-event_handlers.o
   --   ./mast-processing_resources-network.o
   --   ./mast-timers.o
   --   ./mast-processing_resources-processor.o
   --   ./mast-schedulers-adjustment.o
   --   ./mast-transactions.o
   --   ./mast-systems.o
   --   ./mast-max_numbers.o
   --   ./mast-transaction_operations.o
   --   ./mast-consistency_checks.o
   --   ./mast-linear_translation.o
   --   ./mast-linear_analysis_tools.o
   --   ./mast-restrictions.o
   --   ./mast-miscelaneous_tools.o
   --   ./mast-tools-schedulability_index.o
   --   ./mast-edf_tools.o
   --   ./mast-monoprocessor_tools.o
   --   ./mast-tools.o
   --   ./mast-linear_priority_assignment_tools.o
   --   ./mast_lex.o
   --   ./mast_parser.o
   --   ./mast_analysis.o
   --   -L./
   --   -L../utils/
   --   -L/home/aquox/opt/GNAT/2018/lib/gcc/x86_64-pc-linux-gnu/7.3.1/adalib/
   --   -static
   --   -lgnat
   --   -ldl
--  END Object file/option list   

end ada_main;
