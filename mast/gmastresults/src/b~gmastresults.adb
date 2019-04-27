pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b~gmastresults.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b~gmastresults.adb");

with System.Restrictions;

package body ada_main is
   pragma Warnings (Off);

   procedure Do_Finalize;
   pragma Import (C, Do_Finalize, "system__standard_library__adafinal");

   Local_Priority_Specific_Dispatching : constant String := "";
   Local_Interrupt_States : constant String := "";

   procedure adainit is
      E009 : Boolean; pragma Import (Ada, E009, "system__secondary_stack_E");
      E013 : Boolean; pragma Import (Ada, E013, "system__soft_links_E");
      E019 : Boolean; pragma Import (Ada, E019, "system__exception_table_E");
      E229 : Boolean; pragma Import (Ada, E229, "ada__calendar_E");
      E072 : Boolean; pragma Import (Ada, E072, "ada__io_exceptions_E");
      E449 : Boolean; pragma Import (Ada, E449, "ada__numerics_E");
      E214 : Boolean; pragma Import (Ada, E214, "ada__strings_E");
      E047 : Boolean; pragma Import (Ada, E047, "ada__tags_E");
      E056 : Boolean; pragma Import (Ada, E056, "ada__streams_E");
      E086 : Boolean; pragma Import (Ada, E086, "interfaces__c_E");
      E088 : Boolean; pragma Import (Ada, E088, "interfaces__c__strings_E");
      E065 : Boolean; pragma Import (Ada, E065, "system__finalization_root_E");
      E310 : Boolean; pragma Import (Ada, E310, "system__os_lib_E");
      E216 : Boolean; pragma Import (Ada, E216, "ada__strings__maps_E");
      E219 : Boolean; pragma Import (Ada, E219, "ada__strings__maps__constants_E");
      E067 : Boolean; pragma Import (Ada, E067, "system__finalization_implementation_E");
      E063 : Boolean; pragma Import (Ada, E063, "ada__finalization_E");
      E077 : Boolean; pragma Import (Ada, E077, "ada__finalization__list_controller_E");
      E458 : Boolean; pragma Import (Ada, E458, "ada__strings__unbounded_E");
      E075 : Boolean; pragma Import (Ada, E075, "system__file_control_block_E");
      E061 : Boolean; pragma Import (Ada, E061, "system__file_io_E");
      E055 : Boolean; pragma Import (Ada, E055, "ada__text_io_E");
      E258 : Boolean; pragma Import (Ada, E258, "binary_trees_E");
      E430 : Boolean; pragma Import (Ada, E430, "doubly_linked_lists_E");
      E466 : Boolean; pragma Import (Ada, E466, "dynamic_lists_E");
      E472 : Boolean; pragma Import (Ada, E472, "associations_E");
      E084 : Boolean; pragma Import (Ada, E084, "glib_E");
      E410 : Boolean; pragma Import (Ada, E410, "gdk__image_E");
      E136 : Boolean; pragma Import (Ada, E136, "gdk__rectangle_E");
      E113 : Boolean; pragma Import (Ada, E113, "glib__glist_E");
      E119 : Boolean; pragma Import (Ada, E119, "gdk__visual_E");
      E097 : Boolean; pragma Import (Ada, E097, "glib__gslist_E");
      E103 : Boolean; pragma Import (Ada, E103, "glib__values_E");
      E353 : Boolean; pragma Import (Ada, E353, "gmastresults_intl_E");
      E095 : Boolean; pragma Import (Ada, E095, "gtkada__types_E");
      E090 : Boolean; pragma Import (Ada, E090, "glib__object_E");
      E117 : Boolean; pragma Import (Ada, E117, "gdk__color_E");
      E146 : Boolean; pragma Import (Ada, E146, "gdk__cursor_E");
      E105 : Boolean; pragma Import (Ada, E105, "glib__generic_properties_E");
      E092 : Boolean; pragma Import (Ada, E092, "glib__type_conversion_hooks_E");
      E151 : Boolean; pragma Import (Ada, E151, "gdk__region_E");
      E148 : Boolean; pragma Import (Ada, E148, "gdk__event_E");
      E144 : Boolean; pragma Import (Ada, E144, "gdk__window_E");
      E142 : Boolean; pragma Import (Ada, E142, "gdk__bitmap_E");
      E161 : Boolean; pragma Import (Ada, E161, "gdk__pixmap_E");
      E101 : Boolean; pragma Import (Ada, E101, "glib__properties_E");
      E111 : Boolean; pragma Import (Ada, E111, "gtk__enums_E");
      E169 : Boolean; pragma Import (Ada, E169, "gtk__object_E");
      E167 : Boolean; pragma Import (Ada, E167, "gtk__accel_group_E");
      E171 : Boolean; pragma Import (Ada, E171, "gtk__adjustment_E");
      E402 : Boolean; pragma Import (Ada, E402, "gtkada__pixmaps_E");
      E401 : Boolean; pragma Import (Ada, E401, "gmastresults_pixmaps_E");
      E278 : Boolean; pragma Import (Ada, E278, "hash_lists_E");
      E272 : Boolean; pragma Import (Ada, E272, "indexed_lists_E");
      E204 : Boolean; pragma Import (Ada, E204, "list_exceptions_E");
      E206 : Boolean; pragma Import (Ada, E206, "mast_E");
      E456 : Boolean; pragma Import (Ada, E456, "mast__annealing_parameters_E");
      E464 : Boolean; pragma Import (Ada, E464, "mast__hopa_parameters_E");
      E280 : Boolean; pragma Import (Ada, E280, "mast__scheduling_parameters_E");
      E300 : Boolean; pragma Import (Ada, E300, "mast__scheduling_policies_E");
      E282 : Boolean; pragma Import (Ada, E282, "mast__synchronization_parameters_E");
      E321 : Boolean; pragma Import (Ada, E321, "mast__timers_E");
      E438 : Boolean; pragma Import (Ada, E438, "mast__tool_exceptions_E");
      E329 : Boolean; pragma Import (Ada, E329, "mast_lex_dfa_E");
      E331 : Boolean; pragma Import (Ada, E331, "mast_lex_io_E");
      E334 : Boolean; pragma Import (Ada, E334, "mast_parser_error_report_E");
      E341 : Boolean; pragma Import (Ada, E341, "mast_results_lex_dfa_E");
      E343 : Boolean; pragma Import (Ada, E343, "mast_results_lex_io_E");
      E346 : Boolean; pragma Import (Ada, E346, "mast_results_parser_error_report_E");
      E132 : Boolean; pragma Import (Ada, E132, "pango__enums_E");
      E138 : Boolean; pragma Import (Ada, E138, "pango__attributes_E");
      E124 : Boolean; pragma Import (Ada, E124, "pango__font_E");
      E159 : Boolean; pragma Import (Ada, E159, "gdk__font_E");
      E157 : Boolean; pragma Import (Ada, E157, "gdk__gc_E");
      E173 : Boolean; pragma Import (Ada, E173, "gtk__style_E");
      E122 : Boolean; pragma Import (Ada, E122, "pango__context_E");
      E140 : Boolean; pragma Import (Ada, E140, "pango__tabs_E");
      E134 : Boolean; pragma Import (Ada, E134, "pango__layout_E");
      E155 : Boolean; pragma Import (Ada, E155, "gdk__drawable_E");
      E163 : Boolean; pragma Import (Ada, E163, "gdk__rgb_E");
      E153 : Boolean; pragma Import (Ada, E153, "gdk__pixbuf_E");
      E412 : Boolean; pragma Import (Ada, E412, "gtk__icon_factory_E");
      E115 : Boolean; pragma Import (Ada, E115, "gtk__widget_E");
      E351 : Boolean; pragma Import (Ada, E351, "gtk__arguments_E");
      E109 : Boolean; pragma Import (Ada, E109, "gtk__container_E");
      E107 : Boolean; pragma Import (Ada, E107, "gtk__bin_E");
      E358 : Boolean; pragma Import (Ada, E358, "gtk__alignment_E");
      E360 : Boolean; pragma Import (Ada, E360, "gtk__box_E");
      E099 : Boolean; pragma Import (Ada, E099, "gtk__button_E");
      E175 : Boolean; pragma Import (Ada, E175, "gtk__clist_E");
      E179 : Boolean; pragma Import (Ada, E179, "gtk__editable_E");
      E368 : Boolean; pragma Import (Ada, E368, "gtk__frame_E");
      E177 : Boolean; pragma Import (Ada, E177, "gtk__gentry_E");
      E406 : Boolean; pragma Import (Ada, E406, "gtk__handle_box_E");
      E191 : Boolean; pragma Import (Ada, E191, "gtk__item_E");
      E364 : Boolean; pragma Import (Ada, E364, "gtk__list_E");
      E183 : Boolean; pragma Import (Ada, E183, "gtk__marshallers_E");
      E189 : Boolean; pragma Import (Ada, E189, "gtk__menu_item_E");
      E187 : Boolean; pragma Import (Ada, E187, "gtk__image_menu_item_E");
      E416 : Boolean; pragma Import (Ada, E416, "gtk__menu_shell_E");
      E414 : Boolean; pragma Import (Ada, E414, "gtk__menu_E");
      E418 : Boolean; pragma Import (Ada, E418, "gtk__menu_bar_E");
      E199 : Boolean; pragma Import (Ada, E199, "gtk__misc_E");
      E408 : Boolean; pragma Import (Ada, E408, "gtk__image_E");
      E370 : Boolean; pragma Import (Ada, E370, "gtk__label_E");
      E185 : Boolean; pragma Import (Ada, E185, "gtk__notebook_E");
      E080 : Boolean; pragma Import (Ada, E080, "callbacks_gmastresults_E");
      E424 : Boolean; pragma Import (Ada, E424, "gtk__old_editable_E");
      E203 : Boolean; pragma Import (Ada, E203, "gtk__scrolled_window_E");
      E420 : Boolean; pragma Import (Ada, E420, "gtk__table_E");
      E422 : Boolean; pragma Import (Ada, E422, "gtk__text_E");
      E201 : Boolean; pragma Import (Ada, E201, "gtk__window_E");
      E378 : Boolean; pragma Import (Ada, E378, "error_window_pkg_E");
      E380 : Boolean; pragma Import (Ada, E380, "error_window_pkg__callbacks_E");
      E362 : Boolean; pragma Import (Ada, E362, "gtk__combo_E");
      E366 : Boolean; pragma Import (Ada, E366, "gtk__dialog_E");
      E079 : Boolean; pragma Import (Ada, E079, "dialog_event_pkg_E");
      E193 : Boolean; pragma Import (Ada, E193, "dialog_event_pkg__callbacks_E");
      E386 : Boolean; pragma Import (Ada, E386, "gtk__file_selection_E");
      E382 : Boolean; pragma Import (Ada, E382, "fileselection_results_pkg_E");
      E384 : Boolean; pragma Import (Ada, E384, "fileselection_results_pkg__callbacks_E");
      E388 : Boolean; pragma Import (Ada, E388, "fileselection_saveresults_pkg_E");
      E390 : Boolean; pragma Import (Ada, E390, "fileselection_saveresults_pkg__callbacks_E");
      E392 : Boolean; pragma Import (Ada, E392, "fileselection_savesystem_pkg_E");
      E394 : Boolean; pragma Import (Ada, E394, "fileselection_savesystem_pkg__callbacks_E");
      E396 : Boolean; pragma Import (Ada, E396, "fileselection_system_pkg_E");
      E398 : Boolean; pragma Import (Ada, E398, "fileselection_system_pkg__callbacks_E");
      E197 : Boolean; pragma Import (Ada, E197, "gtk__pixmap_E");
      E374 : Boolean; pragma Import (Ada, E374, "gmast_results_pkg_E");
      E376 : Boolean; pragma Import (Ada, E376, "gmast_results_pkg__callbacks_E");
      E356 : Boolean; pragma Import (Ada, E356, "gtkada__handlers_E");
      E442 : Boolean; pragma Import (Ada, E442, "priority_queues_E");
      E209 : Boolean; pragma Import (Ada, E209, "var_strings_E");
      E227 : Boolean; pragma Import (Ada, E227, "mast__io_E");
      E263 : Boolean; pragma Import (Ada, E263, "named_lists_E");
      E225 : Boolean; pragma Import (Ada, E225, "mast__events_E");
      E270 : Boolean; pragma Import (Ada, E270, "mast__graphs_E");
      E276 : Boolean; pragma Import (Ada, E276, "mast__results_E");
      E298 : Boolean; pragma Import (Ada, E298, "mast__processing_resources_E");
      E319 : Boolean; pragma Import (Ada, E319, "mast__processing_resources__processor_E");
      E296 : Boolean; pragma Import (Ada, E296, "mast__schedulers_E");
      E302 : Boolean; pragma Import (Ada, E302, "mast__schedulers__primary_E");
      E294 : Boolean; pragma Import (Ada, E294, "mast__scheduling_servers_E");
      E325 : Boolean; pragma Import (Ada, E325, "mast__schedulers__adjustment_E");
      E304 : Boolean; pragma Import (Ada, E304, "mast__schedulers__secondary_E");
      E292 : Boolean; pragma Import (Ada, E292, "mast__shared_resources_E");
      E290 : Boolean; pragma Import (Ada, E290, "mast__operations_E");
      E315 : Boolean; pragma Import (Ada, E315, "mast__drivers_E");
      E288 : Boolean; pragma Import (Ada, E288, "mast__graphs__event_handlers_E");
      E317 : Boolean; pragma Import (Ada, E317, "mast__processing_resources__network_E");
      E284 : Boolean; pragma Import (Ada, E284, "mast__timing_requirements_E");
      E274 : Boolean; pragma Import (Ada, E274, "mast__graphs__links_E");
      E286 : Boolean; pragma Import (Ada, E286, "mast__transactions_E");
      E323 : Boolean; pragma Import (Ada, E323, "mast__systems_E");
      E428 : Boolean; pragma Import (Ada, E428, "mast__consistency_checks_E");
      E446 : Boolean; pragma Import (Ada, E446, "mast__linear_analysis_tools_E");
      E436 : Boolean; pragma Import (Ada, E436, "mast__linear_translation_E");
      E440 : Boolean; pragma Import (Ada, E440, "mast__max_numbers_E");
      E470 : Boolean; pragma Import (Ada, E470, "mast__miscelaneous_tools_E");
      E474 : Boolean; pragma Import (Ada, E474, "mast__restrictions_E");
      E426 : Boolean; pragma Import (Ada, E426, "mast__tools_E");
      E434 : Boolean; pragma Import (Ada, E434, "mast__edf_tools_E");
      E448 : Boolean; pragma Import (Ada, E448, "mast__linear_priority_assignment_tools_E");
      E476 : Boolean; pragma Import (Ada, E476, "mast__monoprocessor_tools_E");
      E468 : Boolean; pragma Import (Ada, E468, "mast__tools__schedulability_index_E");
      E432 : Boolean; pragma Import (Ada, E432, "mast__transaction_operations_E");
      E261 : Boolean; pragma Import (Ada, E261, "symbol_table_E");
      E259 : Boolean; pragma Import (Ada, E259, "mast_parser_tokens_E");
      E306 : Boolean; pragma Import (Ada, E306, "mast_actions_E");
      E327 : Boolean; pragma Import (Ada, E327, "mast_lex_E");
      E344 : Boolean; pragma Import (Ada, E344, "mast_results_parser_tokens_E");
      E339 : Boolean; pragma Import (Ada, E339, "mast_results_lex_E");

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
           True, False, True, True, True, True, True, True, 
           True, True, True, False, True, False, True, False, 
           False, True, False, True, False, True, True, True, 
           False, False, False, False, False, False, False, True, 
           True, True, False, False, False, True, True, False, 
           True, True, True, False, False, False, False, True, 
           False, False),
         Count => (0, 0, 0, 0, 1, 0, 0),
         Unknown => (False, False, False, False, True, False, False));
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
      E013 := True;
      System.Secondary_Stack'Elab_Body;
      E009 := True;
      System.Exception_Table'Elab_Body;
      E019 := True;
      Ada.Calendar'Elab_Spec;
      Ada.Calendar'Elab_Body;
      E229 := True;
      Ada.Io_Exceptions'Elab_Spec;
      E072 := True;
      Ada.Numerics'Elab_Spec;
      E449 := True;
      Ada.Strings'Elab_Spec;
      E214 := True;
      Ada.Tags'Elab_Spec;
      Ada.Streams'Elab_Spec;
      E056 := True;
      Interfaces.C'Elab_Spec;
      E086 := True;
      Interfaces.C.Strings'Elab_Spec;
      E088 := True;
      System.Finalization_Root'Elab_Spec;
      E065 := True;
      System.Os_Lib'Elab_Body;
      E310 := True;
      Ada.Strings.Maps'Elab_Spec;
      E216 := True;
      Ada.Strings.Maps.Constants'Elab_Spec;
      E219 := True;
      System.Finalization_Implementation'Elab_Spec;
      System.Finalization_Implementation'Elab_Body;
      E067 := True;
      Ada.Finalization'Elab_Spec;
      E063 := True;
      Ada.Finalization.List_Controller'Elab_Spec;
      E077 := True;
      Ada.Strings.Unbounded'Elab_Spec;
      E458 := True;
      System.File_Control_Block'Elab_Spec;
      E075 := True;
      System.File_Io'Elab_Body;
      E061 := True;
      Ada.Text_Io'Elab_Spec;
      Ada.Text_Io'Elab_Body;
      E055 := True;
      Ada.Tags'Elab_Body;
      E047 := True;
      E258 := True;
      E472 := True;
      Glib'Elab_Spec;
      E084 := True;
      E410 := True;
      E136 := True;
      E113 := True;
      Gdk.Visual'Elab_Body;
      E119 := True;
      E097 := True;
      Glib.Values'Elab_Body;
      E103 := True;
      E353 := True;
      Gtkada.Types'Elab_Spec;
      E095 := True;
      Glib.Object'Elab_Spec;
      Gdk.Color'Elab_Spec;
      E146 := True;
      Glib.Generic_Properties'Elab_Body;
      E105 := True;
      E092 := True;
      E090 := True;
      E117 := True;
      E151 := True;
      Gdk.Event'Elab_Spec;
      E148 := True;
      E142 := True;
      E161 := True;
      E101 := True;
      E111 := True;
      Gtk.Object'Elab_Spec;
      E169 := True;
      Gtk.Accel_Group'Elab_Spec;
      Gtk.Accel_Group'Elab_Body;
      E167 := True;
      Gtk.Adjustment'Elab_Spec;
      E171 := True;
      Gtkada.Pixmaps'Elab_Spec;
      E402 := True;
      Gmastresults_Pixmaps'Elab_Spec;
      E401 := True;
      List_Exceptions'Elab_Spec;
      E204 := True;
      E272 := True;
      E278 := True;
      E466 := True;
      E430 := True;
      Mast'Elab_Spec;
      Mast.Scheduling_Parameters'Elab_Spec;
      Mast.Scheduling_Policies'Elab_Spec;
      Mast.Synchronization_Parameters'Elab_Spec;
      Mast.Timers'Elab_Spec;
      MAST.TOOL_EXCEPTIONS'ELAB_SPEC;
      Mast.Hopa_Parameters'Elab_Body;
      E464 := True;
      Mast.Annealing_Parameters'Elab_Body;
      E456 := True;
      E329 := True;
      mast_lex_io'elab_spec;
      E331 := True;
      Mast_Parser_Error_Report'Elab_Spec;
      E334 := True;
      E341 := True;
      mast_results_lex_io'elab_spec;
      E343 := True;
      Mast_Results_Parser_Error_Report'Elab_Spec;
      E346 := True;
      E132 := True;
      E138 := True;
      Pango.Font'Elab_Spec;
      E124 := True;
      E159 := True;
      E157 := True;
      E173 := True;
      Pango.Context'Elab_Spec;
      E122 := True;
      E140 := True;
      Pango.Layout'Elab_Spec;
      E134 := True;
      E155 := True;
      E163 := True;
      E153 := True;
      Gtk.Icon_Factory'Elab_Spec;
      E412 := True;
      Gtk.Widget'Elab_Spec;
      E115 := True;
      E144 := True;
      E351 := True;
      Gtk.Container'Elab_Spec;
      E109 := True;
      Gtk.Bin'Elab_Spec;
      E107 := True;
      Gtk.Alignment'Elab_Spec;
      E358 := True;
      Gtk.Box'Elab_Spec;
      E360 := True;
      Gtk.Button'Elab_Spec;
      Gtk.Button'Elab_Body;
      E099 := True;
      Gtk.Clist'Elab_Spec;
      E175 := True;
      Gtk.Editable'Elab_Spec;
      E179 := True;
      Gtk.Frame'Elab_Spec;
      E368 := True;
      Gtk.Gentry'Elab_Spec;
      Gtk.Gentry'Elab_Body;
      E177 := True;
      Gtk.Handle_Box'Elab_Spec;
      E406 := True;
      Gtk.Item'Elab_Spec;
      Gtk.Item'Elab_Body;
      E191 := True;
      Gtk.List'Elab_Spec;
      E364 := True;
      E183 := True;
      Gtk.Menu_Item'Elab_Spec;
      Gtk.Menu_Item'Elab_Body;
      E189 := True;
      Gtk.Image_Menu_Item'Elab_Spec;
      Gtk.Image_Menu_Item'Elab_Body;
      E187 := True;
      Gtk.Menu_Shell'Elab_Spec;
      E416 := True;
      Gtk.Menu'Elab_Spec;
      Gtk.Menu'Elab_Body;
      E414 := True;
      Gtk.Menu_Bar'Elab_Spec;
      Gtk.Menu_Bar'Elab_Body;
      E418 := True;
      Gtk.Misc'Elab_Spec;
      E199 := True;
      Gtk.Image'Elab_Spec;
      E408 := True;
      Gtk.Label'Elab_Spec;
      Gtk.Label'Elab_Body;
      E370 := True;
      Gtk.Notebook'Elab_Spec;
      E185 := True;
      Callbacks_Gmastresults'Elab_Spec;
      E080 := True;
      Gtk.Old_Editable'Elab_Spec;
      E424 := True;
      Gtk.Scrolled_Window'Elab_Spec;
      E203 := True;
      Gtk.Table'Elab_Spec;
      E420 := True;
      Gtk.Text'Elab_Spec;
      E422 := True;
      Gtk.Window'Elab_Spec;
      Gtk.Window'Elab_Body;
      E201 := True;
      Error_Window_Pkg'Elab_Spec;
      E380 := True;
      Gtk.Combo'Elab_Spec;
      E362 := True;
      Gtk.Dialog'Elab_Spec;
      E366 := True;
      Dialog_Event_Pkg'Elab_Spec;
      Gtk.File_Selection'Elab_Spec;
      E386 := True;
      Fileselection_Results_Pkg'Elab_Spec;
      Fileselection_Saveresults_Pkg'Elab_Spec;
      Fileselection_Savesystem_Pkg'Elab_Spec;
      Fileselection_System_Pkg'Elab_Spec;
      Gtk.Pixmap'Elab_Spec;
      Gtk.Pixmap'Elab_Body;
      E197 := True;
      Gmast_Results_Pkg'Elab_Spec;
      Gtkada.Handlers'Elab_Spec;
      E356 := True;
      E374 := True;
      E396 := True;
      E392 := True;
      E388 := True;
      E382 := True;
      E079 := True;
      E378 := True;
      E442 := True;
      Var_Strings'Elab_Spec;
      E209 := True;
      MAST.TOOL_EXCEPTIONS'ELAB_BODY;
      E438 := True;
      Mast'Elab_Body;
      E206 := True;
      E321 := True;
      E282 := True;
      E300 := True;
      E280 := True;
      E263 := True;
      MAST.EVENTS'ELAB_SPEC;
      E225 := True;
      MAST.GRAPHS'ELAB_SPEC;
      E270 := True;
      MAST.RESULTS'ELAB_SPEC;
      Mast.Processing_Resources'Elab_Spec;
      E298 := True;
      Mast.Processing_Resources.Processor'Elab_Spec;
      E319 := True;
      Mast.Schedulers'Elab_Spec;
      E296 := True;
      Mast.Schedulers.Primary'Elab_Spec;
      E302 := True;
      MAST.SCHEDULING_SERVERS'ELAB_SPEC;
      Mast.Schedulers.Secondary'Elab_Spec;
      E304 := True;
      E325 := True;
      E294 := True;
      Mast.Shared_Resources'Elab_Spec;
      E292 := True;
      MAST.OPERATIONS'ELAB_SPEC;
      E290 := True;
      Mast.Drivers'Elab_Spec;
      E315 := True;
      MAST.GRAPHS.EVENT_HANDLERS'ELAB_SPEC;
      E288 := True;
      Mast.Processing_Resources.Network'Elab_Spec;
      E317 := True;
      MAST.TIMING_REQUIREMENTS'ELAB_SPEC;
      E284 := True;
      MAST.GRAPHS.LINKS'ELAB_SPEC;
      E274 := True;
      E276 := True;
      MAST.TRANSACTIONS'ELAB_SPEC;
      E286 := True;
      Mast.Systems'Elab_Spec;
      E323 := True;
      E440 := True;
      E446 := True;
      E426 := True;
      MAST.TOOLS.SCHEDULABILITY_INDEX'ELAB_SPEC;
      E468 := True;
      E476 := True;
      E448 := True;
      MAST.TRANSACTION_OPERATIONS'ELAB_SPEC;
      E432 := True;
      E434 := True;
      MAST.RESTRICTIONS'ELAB_BODY;
      E474 := True;
      MAST.MISCELANEOUS_TOOLS'ELAB_BODY;
      E470 := True;
      E436 := True;
      MAST.CONSISTENCY_CHECKS'ELAB_BODY;
      E428 := True;
      Symbol_Table'Elab_Spec;
      Symbol_Table'Elab_Body;
      E261 := True;
      Mast_Parser_Tokens'Elab_Spec;
      E259 := True;
      MAST.IO'ELAB_BODY;
      E227 := True;
      Mast_Actions'Elab_Spec;
      E398 := True;
      E394 := True;
      E390 := True;
      E384 := True;
      E376 := True;
      E193 := True;
      E327 := True;
      Mast_Results_Parser_Tokens'Elab_Spec;
      E344 := True;
      E339 := True;
      E306 := True;
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
      pragma Import (Ada, Ada_Main_Program, "_ada_gmastresults");

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
   --   ../../mast_analysis/binary_trees.o
   --   ../../mast_analysis/associations.o
   --   ./gmastresults_intl.o
   --   ./gmastresults_pixmaps.o
   --   ../../mast_analysis/list_exceptions.o
   --   ../../mast_analysis/indexed_lists.o
   --   ../../mast_analysis/hash_lists.o
   --   ../../mast_analysis/dynamic_lists.o
   --   ../../mast_analysis/doubly_linked_lists.o
   --   ../../mast_analysis/mast-hopa_parameters.o
   --   ../../mast_analysis/mast-annealing_parameters.o
   --   ../../mast_analysis/mast_lex_dfa.o
   --   ../../mast_analysis/mast_lex_io.o
   --   ../../mast_analysis/mast_parser_error_report.o
   --   ../../mast_analysis/mast_parser_goto.o
   --   ../../mast_analysis/mast_parser_shift_reduce.o
   --   ./mast_results_lex_dfa.o
   --   ./mast_results_lex_io.o
   --   ./mast_results_parser_error_report.o
   --   ./mast_results_parser_goto.o
   --   ./mast_results_parser_shift_reduce.o
   --   ./callbacks_gmastresults.o
   --   ./error_window_pkg-callbacks.o
   --   ./clear_timing_results.o
   --   ./resize_timing_results.o
   --   ./clear_results.o
   --   ./gmast_results_pkg.o
   --   ./fileselection_system_pkg.o
   --   ./fileselection_savesystem_pkg.o
   --   ./fileselection_saveresults_pkg.o
   --   ./fileselection_results_pkg.o
   --   ./dialog_event_pkg.o
   --   ./error_window_pkg.o
   --   ../../mast_analysis/priority_queues.o
   --   ../../mast_analysis/var_strings.o
   --   ../../mast_analysis/mast-tool_exceptions.o
   --   ../../mast_analysis/mast.o
   --   ../../mast_analysis/mast-timers.o
   --   ../../mast_analysis/mast-synchronization_parameters.o
   --   ../../mast_analysis/mast-scheduling_policies.o
   --   ../../mast_analysis/mast-scheduling_parameters.o
   --   ../../mast_analysis/named_lists.o
   --   ../../mast_analysis/mast-events.o
   --   ../../mast_analysis/mast-graphs.o
   --   ../../mast_analysis/mast-processing_resources.o
   --   ../../mast_analysis/mast-processing_resources-processor.o
   --   ../../mast_analysis/mast-schedulers.o
   --   ../../mast_analysis/mast-schedulers-primary.o
   --   ../../mast_analysis/mast-schedulers-secondary.o
   --   ../../mast_analysis/mast-schedulers-adjustment.o
   --   ../../mast_analysis/mast-scheduling_servers.o
   --   ../../mast_analysis/mast-shared_resources.o
   --   ../../mast_analysis/mast-operations.o
   --   ../../mast_analysis/mast-drivers.o
   --   ../../mast_analysis/mast-graphs-event_handlers.o
   --   ../../mast_analysis/mast-processing_resources-network.o
   --   ../../mast_analysis/mast-timing_requirements.o
   --   ../../mast_analysis/mast-graphs-links.o
   --   ../../mast_analysis/mast-results.o
   --   ../../mast_analysis/mast-transactions.o
   --   ../../mast_analysis/mast-systems.o
   --   ../../mast_analysis/mast-max_numbers.o
   --   ../../mast_analysis/mast-linear_analysis_tools.o
   --   ../../mast_analysis/mast-tools.o
   --   ../../mast_analysis/mast-tools-schedulability_index.o
   --   ../../mast_analysis/mast-monoprocessor_tools.o
   --   ../../mast_analysis/mast-linear_priority_assignment_tools.o
   --   ../../mast_analysis/mast-transaction_operations.o
   --   ../../mast_analysis/mast-edf_tools.o
   --   ../../mast_analysis/mast-restrictions.o
   --   ../../mast_analysis/mast-miscelaneous_tools.o
   --   ../../mast_analysis/mast-linear_translation.o
   --   ../../mast_analysis/mast-consistency_checks.o
   --   ../../mast_analysis/symbol_table.o
   --   ../../mast_analysis/mast_parser_tokens.o
   --   ../../mast_analysis/mast-io.o
   --   ./fileselection_system_pkg-callbacks.o
   --   ./fileselection_savesystem_pkg-callbacks.o
   --   ./fileselection_saveresults_pkg-callbacks.o
   --   ./draw_results.o
   --   ./fileselection_results_pkg-callbacks.o
   --   ./draw_timing_results.o
   --   ./gmast_results_pkg-callbacks.o
   --   ./dialog_event_pkg-callbacks.o
   --   ./gmastresults.o
   --   ../../mast_analysis/mast_lex.o
   --   ../../mast_analysis/mast_parser.o
   --   ./mast_results_parser_tokens.o
   --   ./mast_results_lex.o
   --   ./mast_results_parser.o
   --   ./mast_actions.o
   --   -L./
   --   -L../../mast_analysis/
   --   -L../../utils/
   --   -L/home/mgh/gnat/gtkada/lib/gtkada/
   --   -L/home/mgh/gnat2007/lib/gcc/i686-pc-linux-gnu/4.1.3/adalib/
   --   -static
   --   -lgnat
--  END Object file/option list   

end ada_main;
