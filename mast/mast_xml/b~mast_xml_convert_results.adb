pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b~mast_xml_convert_results.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b~mast_xml_convert_results.adb");

with System.Restrictions;

package body ada_main is
   pragma Warnings (Off);

   procedure Do_Finalize;
   pragma Import (C, Do_Finalize, "system__standard_library__adafinal");

   Local_Priority_Specific_Dispatching : constant String := "";
   Local_Interrupt_States : constant String := "";

   procedure adainit is
      E020 : Boolean; pragma Import (Ada, E020, "system__secondary_stack_E");
      E016 : Boolean; pragma Import (Ada, E016, "system__soft_links_E");
      E012 : Boolean; pragma Import (Ada, E012, "system__exception_table_E");
      E104 : Boolean; pragma Import (Ada, E104, "ada__calendar_E");
      E082 : Boolean; pragma Import (Ada, E082, "ada__io_exceptions_E");
      E009 : Boolean; pragma Import (Ada, E009, "ada__strings_E");
      E057 : Boolean; pragma Import (Ada, E057, "ada__tags_E");
      E066 : Boolean; pragma Import (Ada, E066, "ada__streams_E");
      E075 : Boolean; pragma Import (Ada, E075, "system__finalization_root_E");
      E050 : Boolean; pragma Import (Ada, E050, "ada__strings__maps_E");
      E053 : Boolean; pragma Import (Ada, E053, "ada__strings__maps__constants_E");
      E077 : Boolean; pragma Import (Ada, E077, "system__finalization_implementation_E");
      E073 : Boolean; pragma Import (Ada, E073, "ada__finalization_E");
      E087 : Boolean; pragma Import (Ada, E087, "ada__finalization__list_controller_E");
      E226 : Boolean; pragma Import (Ada, E226, "ada__strings__unbounded_E");
      E085 : Boolean; pragma Import (Ada, E085, "system__file_control_block_E");
      E298 : Boolean; pragma Import (Ada, E298, "system__direct_io_E");
      E071 : Boolean; pragma Import (Ada, E071, "system__file_io_E");
      E065 : Boolean; pragma Import (Ada, E065, "ada__text_io_E");
      E300 : Boolean; pragma Import (Ada, E300, "system__sequential_io_E");
      E133 : Boolean; pragma Import (Ada, E133, "binary_trees_E");
      E164 : Boolean; pragma Import (Ada, E164, "hash_lists_E");
      E156 : Boolean; pragma Import (Ada, E156, "indexed_lists_E");
      E139 : Boolean; pragma Import (Ada, E139, "list_exceptions_E");
      E089 : Boolean; pragma Import (Ada, E089, "mast_E");
      E166 : Boolean; pragma Import (Ada, E166, "mast__scheduling_parameters_E");
      E176 : Boolean; pragma Import (Ada, E176, "mast__scheduling_policies_E");
      E168 : Boolean; pragma Import (Ada, E168, "mast__synchronization_parameters_E");
      E192 : Boolean; pragma Import (Ada, E192, "mast__timers_E");
      E201 : Boolean; pragma Import (Ada, E201, "mast_lex_dfa_E");
      E203 : Boolean; pragma Import (Ada, E203, "mast_lex_io_E");
      E206 : Boolean; pragma Import (Ada, E206, "mast_parser_error_report_E");
      E213 : Boolean; pragma Import (Ada, E213, "mast_results_lex_dfa_E");
      E215 : Boolean; pragma Import (Ada, E215, "mast_results_lex_io_E");
      E218 : Boolean; pragma Import (Ada, E218, "mast_results_parser_error_report_E");
      E222 : Boolean; pragma Import (Ada, E222, "mast_xml_exceptions_E");
      E245 : Boolean; pragma Import (Ada, E245, "sax__htable_E");
      E233 : Boolean; pragma Import (Ada, E233, "unicode_E");
      E241 : Boolean; pragma Import (Ada, E241, "unicode__ccs_E");
      E253 : Boolean; pragma Import (Ada, E253, "unicode__ccs__iso_8859_1_E");
      E255 : Boolean; pragma Import (Ada, E255, "unicode__ccs__iso_8859_15_E");
      E260 : Boolean; pragma Import (Ada, E260, "unicode__ccs__iso_8859_2_E");
      E263 : Boolean; pragma Import (Ada, E263, "unicode__ccs__iso_8859_3_E");
      E265 : Boolean; pragma Import (Ada, E265, "unicode__ccs__iso_8859_4_E");
      E267 : Boolean; pragma Import (Ada, E267, "unicode__ccs__windows_1252_E");
      E237 : Boolean; pragma Import (Ada, E237, "unicode__ces_E");
      E229 : Boolean; pragma Import (Ada, E229, "dom__core_E");
      E276 : Boolean; pragma Import (Ada, E276, "dom__core__documents_E");
      E306 : Boolean; pragma Import (Ada, E306, "mast_xml_parser_extension_E");
      E290 : Boolean; pragma Import (Ada, E290, "sax__locators_E");
      E288 : Boolean; pragma Import (Ada, E288, "sax__exceptions_E");
      E286 : Boolean; pragma Import (Ada, E286, "sax__models_E");
      E284 : Boolean; pragma Import (Ada, E284, "sax__attributes_E");
      E304 : Boolean; pragma Import (Ada, E304, "sax__utils_E");
      E239 : Boolean; pragma Import (Ada, E239, "unicode__ces__utf32_E");
      E272 : Boolean; pragma Import (Ada, E272, "unicode__ces__basic_8bit_E");
      E294 : Boolean; pragma Import (Ada, E294, "input_sources_E");
      E296 : Boolean; pragma Import (Ada, E296, "input_sources__file_E");
      E302 : Boolean; pragma Import (Ada, E302, "input_sources__strings_E");
      E292 : Boolean; pragma Import (Ada, E292, "sax__readers_E");
      E280 : Boolean; pragma Import (Ada, E280, "dom__readers_E");
      E274 : Boolean; pragma Import (Ada, E274, "unicode__ces__utf16_E");
      E243 : Boolean; pragma Import (Ada, E243, "unicode__ces__utf8_E");
      E231 : Boolean; pragma Import (Ada, E231, "sax__encodings_E");
      E251 : Boolean; pragma Import (Ada, E251, "unicode__encodings_E");
      E249 : Boolean; pragma Import (Ada, E249, "dom__core__nodes_E");
      E247 : Boolean; pragma Import (Ada, E247, "dom__core__attrs_E");
      E282 : Boolean; pragma Import (Ada, E282, "dom__core__character_datas_E");
      E278 : Boolean; pragma Import (Ada, E278, "dom__core__elements_E");
      E092 : Boolean; pragma Import (Ada, E092, "var_strings_E");
      E102 : Boolean; pragma Import (Ada, E102, "mast__io_E");
      E138 : Boolean; pragma Import (Ada, E138, "named_lists_E");
      E158 : Boolean; pragma Import (Ada, E158, "mast__events_E");
      E154 : Boolean; pragma Import (Ada, E154, "mast__graphs_E");
      E152 : Boolean; pragma Import (Ada, E152, "mast__results_E");
      E100 : Boolean; pragma Import (Ada, E100, "mast__processing_resources_E");
      E190 : Boolean; pragma Import (Ada, E190, "mast__processing_resources__processor_E");
      E174 : Boolean; pragma Import (Ada, E174, "mast__schedulers_E");
      E178 : Boolean; pragma Import (Ada, E178, "mast__schedulers__primary_E");
      E172 : Boolean; pragma Import (Ada, E172, "mast__scheduling_servers_E");
      E188 : Boolean; pragma Import (Ada, E188, "mast__schedulers__adjustment_E");
      E180 : Boolean; pragma Import (Ada, E180, "mast__schedulers__secondary_E");
      E186 : Boolean; pragma Import (Ada, E186, "mast__shared_resources_E");
      E184 : Boolean; pragma Import (Ada, E184, "mast__operations_E");
      E182 : Boolean; pragma Import (Ada, E182, "mast__drivers_E");
      E196 : Boolean; pragma Import (Ada, E196, "mast__graphs__event_handlers_E");
      E170 : Boolean; pragma Import (Ada, E170, "mast__processing_resources__network_E");
      E162 : Boolean; pragma Import (Ada, E162, "mast__timing_requirements_E");
      E160 : Boolean; pragma Import (Ada, E160, "mast__graphs__links_E");
      E194 : Boolean; pragma Import (Ada, E194, "mast__transactions_E");
      E098 : Boolean; pragma Import (Ada, E098, "mast__systems_E");
      E224 : Boolean; pragma Import (Ada, E224, "mast_xml_parser_E");
      E311 : Boolean; pragma Import (Ada, E311, "mast_xml_results_parser_E");
      E136 : Boolean; pragma Import (Ada, E136, "symbol_table_E");
      E134 : Boolean; pragma Import (Ada, E134, "mast_parser_tokens_E");
      E199 : Boolean; pragma Import (Ada, E199, "mast_lex_E");
      E216 : Boolean; pragma Import (Ada, E216, "mast_results_parser_tokens_E");
      E211 : Boolean; pragma Import (Ada, E211, "mast_results_lex_E");

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
      Interrupt_States : System.Address;
      pragma Import (C, Interrupt_States, "__gl_interrupt_states");
      Num_Interrupt_States : Integer;
      pragma Import (C, Num_Interrupt_States, "__gl_num_interrupt_states");
      Unreserve_All_Interrupts : Integer;
      pragma Import (C, Unreserve_All_Interrupts, "__gl_unreserve_all_interrupts");
      Zero_Cost_Exceptions : Integer;
      pragma Import (C, Zero_Cost_Exceptions, "__gl_zero_cost_exceptions");
      Detect_Blocking : Integer;
      pragma Import (C, Detect_Blocking, "__gl_detect_blocking");
      Default_Stack_Size : Integer;
      pragma Import (C, Default_Stack_Size, "__gl_default_stack_size");

      procedure Install_Handler;
      pragma Import (C, Install_Handler, "__gnat_install_handler");

      Handler_Installed : Integer;
      pragma Import (C, Handler_Installed, "__gnat_handler_installed");
   begin
      Main_Priority := -1;
      Time_Slice_Value := -1;
      WC_Encoding := 'b';
      Locking_Policy := ' ';
      Queuing_Policy := ' ';
      Task_Dispatching_Policy := ' ';
      System.Restrictions.Run_Time_Restrictions :=
        (Set =>
          (False, False, False, False, False, False, False, False, 
           False, False, False, False, False, False, False, False, 
           False, False, False, False, False, False, False, False, 
           False, False, False, False, False, False, False, False, 
           False, False, False, False, False, False, False, False, 
           False, False, False, False, False, False, False, False, 
           False, False, False, False, False, False, False, False, 
           False, False, False, False, False, False, False, False, 
           False, False),
         Value => (0, 0, 0, 0, 0, 0, 0),
         Violated =>
          (False, False, True, True, False, True, True, True, 
           True, True, False, False, True, False, False, True, 
           True, True, True, True, True, True, True, True, 
           False, True, True, False, True, False, True, False, 
           False, True, False, False, False, True, False, True, 
           False, False, False, False, False, False, False, True, 
           True, True, False, False, False, True, True, False, 
           True, True, True, False, False, False, False, False, 
           False, False),
         Count => (0, 0, 0, 0, 0, 0, 0),
         Unknown => (False, False, False, False, False, False, False));
      Priority_Specific_Dispatching :=
        Local_Priority_Specific_Dispatching'Address;
      Num_Specific_Dispatching := 0;
      Interrupt_States := Local_Interrupt_States'Address;
      Num_Interrupt_States := 0;
      Unreserve_All_Interrupts := 0;
      Zero_Cost_Exceptions := 1;
      Detect_Blocking := 0;
      Default_Stack_Size := -1;

      if Handler_Installed = 0 then
         Install_Handler;
      end if;

      System.Soft_Links'Elab_Body;
      E016 := True;
      System.Secondary_Stack'Elab_Body;
      E020 := True;
      System.Exception_Table'Elab_Body;
      E012 := True;
      Ada.Calendar'Elab_Spec;
      Ada.Calendar'Elab_Body;
      E104 := True;
      Ada.Io_Exceptions'Elab_Spec;
      E082 := True;
      Ada.Strings'Elab_Spec;
      E009 := True;
      Ada.Tags'Elab_Spec;
      Ada.Streams'Elab_Spec;
      E066 := True;
      System.Finalization_Root'Elab_Spec;
      E075 := True;
      Ada.Strings.Maps'Elab_Spec;
      E050 := True;
      Ada.Strings.Maps.Constants'Elab_Spec;
      E053 := True;
      System.Finalization_Implementation'Elab_Spec;
      System.Finalization_Implementation'Elab_Body;
      E077 := True;
      Ada.Finalization'Elab_Spec;
      E073 := True;
      Ada.Finalization.List_Controller'Elab_Spec;
      E087 := True;
      Ada.Strings.Unbounded'Elab_Spec;
      E226 := True;
      System.File_Control_Block'Elab_Spec;
      E085 := True;
      System.Direct_Io'Elab_Spec;
      System.File_Io'Elab_Body;
      E071 := True;
      E298 := True;
      Ada.Text_Io'Elab_Spec;
      Ada.Text_Io'Elab_Body;
      E065 := True;
      System.Sequential_Io'Elab_Spec;
      E300 := True;
      Ada.Tags'Elab_Body;
      E057 := True;
      E133 := True;
      List_Exceptions'Elab_Spec;
      E139 := True;
      E156 := True;
      E164 := True;
      Mast'Elab_Spec;
      Mast.Scheduling_Parameters'Elab_Spec;
      Mast.Scheduling_Policies'Elab_Spec;
      Mast.Synchronization_Parameters'Elab_Spec;
      Mast.Timers'Elab_Spec;
      E201 := True;
      mast_lex_io'elab_spec;
      E203 := True;
      Mast_Parser_Error_Report'Elab_Spec;
      E206 := True;
      E213 := True;
      mast_results_lex_io'elab_spec;
      E215 := True;
      Mast_Results_Parser_Error_Report'Elab_Spec;
      E218 := True;
      Mast_Xml_Exceptions'Elab_Spec;
      E245 := True;
      Unicode.Ccs'Elab_Spec;
      E241 := True;
      E253 := True;
      Unicode.Ces'Elab_Spec;
      E237 := True;
      DOM.CORE'ELAB_SPEC;
      Sax.Locators'Elab_Spec;
      E290 := True;
      Sax.Exceptions'Elab_Spec;
      E288 := True;
      Sax.Models'Elab_Spec;
      Sax.Attributes'Elab_Spec;
      E284 := True;
      E239 := True;
      E272 := True;
      Input_Sources'Elab_Spec;
      Input_Sources.File'Elab_Spec;
      Input_Sources.Strings'Elab_Spec;
      Sax.Readers'Elab_Spec;
      DOM.READERS'ELAB_SPEC;
      E274 := True;
      E243 := True;
      E302 := True;
      E296 := True;
      Sax.Encodings'Elab_Spec;
      E231 := True;
      E286 := True;
      E251 := True;
      E294 := True;
      E306 := True;
      E247 := True;
      E282 := True;
      E278 := True;
      E280 := True;
      E276 := True;
      E249 := True;
      E292 := True;
      Sax.Utils'Elab_Body;
      E304 := True;
      E229 := True;
      Unicode'Elab_Body;
      E233 := True;
      E255 := True;
      E267 := True;
      E265 := True;
      E263 := True;
      E260 := True;
      Var_Strings'Elab_Spec;
      E092 := True;
      Mast_Xml_Exceptions'Elab_Body;
      E222 := True;
      Mast'Elab_Body;
      E089 := True;
      E192 := True;
      E168 := True;
      E176 := True;
      E166 := True;
      E138 := True;
      MAST.EVENTS'ELAB_SPEC;
      E158 := True;
      MAST.GRAPHS'ELAB_SPEC;
      E154 := True;
      MAST.RESULTS'ELAB_SPEC;
      Mast.Processing_Resources'Elab_Spec;
      E100 := True;
      Mast.Processing_Resources.Processor'Elab_Spec;
      E190 := True;
      Mast.Schedulers'Elab_Spec;
      E174 := True;
      Mast.Schedulers.Primary'Elab_Spec;
      E178 := True;
      MAST.SCHEDULING_SERVERS'ELAB_SPEC;
      Mast.Schedulers.Secondary'Elab_Spec;
      E180 := True;
      E188 := True;
      E172 := True;
      Mast.Shared_Resources'Elab_Spec;
      E186 := True;
      MAST.OPERATIONS'ELAB_SPEC;
      E184 := True;
      Mast.Drivers'Elab_Spec;
      E182 := True;
      MAST.GRAPHS.EVENT_HANDLERS'ELAB_SPEC;
      E196 := True;
      Mast.Processing_Resources.Network'Elab_Spec;
      E170 := True;
      MAST.TIMING_REQUIREMENTS'ELAB_SPEC;
      E162 := True;
      MAST.GRAPHS.LINKS'ELAB_SPEC;
      E160 := True;
      E152 := True;
      MAST.TRANSACTIONS'ELAB_SPEC;
      E194 := True;
      Mast.Systems'Elab_Spec;
      E098 := True;
      Mast_Xml_Parser'Elab_Spec;
      E224 := True;
      E311 := True;
      Symbol_Table'Elab_Spec;
      Symbol_Table'Elab_Body;
      E136 := True;
      Mast_Parser_Tokens'Elab_Spec;
      E134 := True;
      MAST.IO'ELAB_BODY;
      E102 := True;
      E199 := True;
      Mast_Results_Parser_Tokens'Elab_Spec;
      E216 := True;
      E211 := True;
   end adainit;

   procedure adafinal is
   begin
      Do_Finalize;
   end adafinal;

   function main
     (argc : Integer;
      argv : System.Address;
      envp : System.Address)
      return Integer
   is
      procedure initialize (Addr : System.Address);
      pragma Import (C, initialize, "__gnat_initialize");

      procedure finalize;
      pragma Import (C, finalize, "__gnat_finalize");

      procedure Ada_Main_Program;
      pragma Import (Ada, Ada_Main_Program, "_ada_mast_xml_convert_results");

      SEH : aliased array (1 .. 2) of Integer;

      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      gnat_argc := argc;
      gnat_argv := argv;
      gnat_envp := envp;

      Initialize (SEH'Address);
      adainit;
      Break_Start;
      Ada_Main_Program;
      Do_Finalize;
      Finalize;
      return (gnat_exit_status);
   end;

--  BEGIN Object file/option list
   --   ../mast_analysis/binary_trees.o
   --   ../mast_analysis/list_exceptions.o
   --   ../mast_analysis/indexed_lists.o
   --   ../mast_analysis/hash_lists.o
   --   ../mast_analysis/mast_lex_dfa.o
   --   ../mast_analysis/mast_lex_io.o
   --   ../mast_analysis/mast_parser_error_report.o
   --   ../mast_analysis/mast_parser_goto.o
   --   ../mast_analysis/mast_parser_shift_reduce.o
   --   ./mast_results_lex_dfa.o
   --   ./mast_results_lex_io.o
   --   ./mast_results_parser_error_report.o
   --   ./mast_results_parser_goto.o
   --   ./mast_results_parser_shift_reduce.o
   --   ./mast_xml_parser_extension.o
   --   ../mast_analysis/var_strings.o
   --   ./mast_xml_exceptions.o
   --   ../mast_analysis/mast.o
   --   ../mast_analysis/mast-timers.o
   --   ../mast_analysis/mast-synchronization_parameters.o
   --   ../mast_analysis/mast-scheduling_policies.o
   --   ../mast_analysis/mast-scheduling_parameters.o
   --   ../mast_analysis/named_lists.o
   --   ../mast_analysis/mast-events.o
   --   ../mast_analysis/mast-graphs.o
   --   ../mast_analysis/mast-processing_resources.o
   --   ../mast_analysis/mast-processing_resources-processor.o
   --   ../mast_analysis/mast-schedulers.o
   --   ../mast_analysis/mast-schedulers-primary.o
   --   ../mast_analysis/mast-schedulers-secondary.o
   --   ../mast_analysis/mast-schedulers-adjustment.o
   --   ../mast_analysis/mast-scheduling_servers.o
   --   ../mast_analysis/mast-shared_resources.o
   --   ../mast_analysis/mast-operations.o
   --   ../mast_analysis/mast-drivers.o
   --   ../mast_analysis/mast-graphs-event_handlers.o
   --   ../mast_analysis/mast-processing_resources-network.o
   --   ../mast_analysis/mast-timing_requirements.o
   --   ../mast_analysis/mast-graphs-links.o
   --   ../mast_analysis/mast-results.o
   --   ../mast_analysis/mast-transactions.o
   --   ../mast_analysis/mast-systems.o
   --   ./mast_xml_parser.o
   --   ./mast_xml_results_parser.o
   --   ../mast_analysis/symbol_table.o
   --   ../mast_analysis/mast_parser_tokens.o
   --   ../mast_analysis/mast-io.o
   --   ../mast_analysis/mast_lex.o
   --   ../mast_analysis/mast_parser.o
   --   ./mast_results_parser_tokens.o
   --   ./mast_results_lex.o
   --   ./mast_results_parser.o
   --   ./mast_xml_convert_results.o
   --   -L./
   --   -L../mast_analysis/
   --   -L../utils/
   --   -L/home/mgh/gnat/xmlada/lib/xmlada/
   --   -L/home/mgh/gnat2007/lib/gcc/i686-pc-linux-gnu/4.1.3/adalib/
   --   -static
   --   -lgnat
--  END Object file/option list   

end ada_main;
