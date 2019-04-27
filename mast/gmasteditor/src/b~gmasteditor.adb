pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b~gmasteditor.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b~gmasteditor.adb");

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
      E049 : Boolean; pragma Import (Ada, E049, "ada__calendar_E");
      E057 : Boolean; pragma Import (Ada, E057, "ada__calendar__time_zones_E");
      E100 : Boolean; pragma Import (Ada, E100, "ada__io_exceptions_E");
      E131 : Boolean; pragma Import (Ada, E131, "ada__numerics_E");
      E077 : Boolean; pragma Import (Ada, E077, "ada__strings_E");
      E093 : Boolean; pragma Import (Ada, E093, "ada__tags_E");
      E091 : Boolean; pragma Import (Ada, E091, "ada__streams_E");
      E143 : Boolean; pragma Import (Ada, E143, "interfaces__c_E");
      E145 : Boolean; pragma Import (Ada, E145, "interfaces__c__strings_E");
      E090 : Boolean; pragma Import (Ada, E090, "system__finalization_root_E");
      E113 : Boolean; pragma Import (Ada, E113, "system__os_lib_E");
      E079 : Boolean; pragma Import (Ada, E079, "ada__strings__maps_E");
      E082 : Boolean; pragma Import (Ada, E082, "ada__strings__maps__constants_E");
      E095 : Boolean; pragma Import (Ada, E095, "system__finalization_implementation_E");
      E088 : Boolean; pragma Import (Ada, E088, "ada__finalization_E");
      E086 : Boolean; pragma Import (Ada, E086, "ada__finalization__list_controller_E");
      E106 : Boolean; pragma Import (Ada, E106, "ada__strings__unbounded_E");
      E047 : Boolean; pragma Import (Ada, E047, "ada__directories_E");
      E126 : Boolean; pragma Import (Ada, E126, "system__file_control_block_E");
      E123 : Boolean; pragma Import (Ada, E123, "system__file_io_E");
      E119 : Boolean; pragma Import (Ada, E119, "ada__text_io_E");
      E117 : Boolean; pragma Import (Ada, E117, "system__regexp_E");
      E283 : Boolean; pragma Import (Ada, E283, "binary_trees_E");
      E128 : Boolean; pragma Import (Ada, E128, "change_control_E");
      E141 : Boolean; pragma Import (Ada, E141, "glib_E");
      E533 : Boolean; pragma Import (Ada, E533, "gdk__image_E");
      E147 : Boolean; pragma Import (Ada, E147, "gdk__rectangle_E");
      E179 : Boolean; pragma Import (Ada, E179, "glib__glist_E");
      E185 : Boolean; pragma Import (Ada, E185, "gdk__visual_E");
      E250 : Boolean; pragma Import (Ada, E250, "glib__graphs_E");
      E159 : Boolean; pragma Import (Ada, E159, "glib__gslist_E");
      E167 : Boolean; pragma Import (Ada, E167, "glib__values_E");
      E157 : Boolean; pragma Import (Ada, E157, "gtkada__types_E");
      E152 : Boolean; pragma Import (Ada, E152, "glib__object_E");
      E183 : Boolean; pragma Import (Ada, E183, "gdk__color_E");
      E208 : Boolean; pragma Import (Ada, E208, "gdk__cursor_E");
      E169 : Boolean; pragma Import (Ada, E169, "glib__generic_properties_E");
      E154 : Boolean; pragma Import (Ada, E154, "glib__type_conversion_hooks_E");
      E213 : Boolean; pragma Import (Ada, E213, "gdk__region_E");
      E210 : Boolean; pragma Import (Ada, E210, "gdk__event_E");
      E206 : Boolean; pragma Import (Ada, E206, "gdk__window_E");
      E204 : Boolean; pragma Import (Ada, E204, "gdk__bitmap_E");
      E223 : Boolean; pragma Import (Ada, E223, "gdk__pixmap_E");
      E165 : Boolean; pragma Import (Ada, E165, "glib__properties_E");
      E585 : Boolean; pragma Import (Ada, E585, "gtk__clipboard_E");
      E177 : Boolean; pragma Import (Ada, E177, "gtk__enums_E");
      E163 : Boolean; pragma Import (Ada, E163, "gtk__object_E");
      E229 : Boolean; pragma Import (Ada, E229, "gtk__accel_group_E");
      E161 : Boolean; pragma Import (Ada, E161, "gtk__adjustment_E");
      E587 : Boolean; pragma Import (Ada, E587, "gtk__text_mark_E");
      E383 : Boolean; pragma Import (Ada, E383, "gtk__tree_model_E");
      E381 : Boolean; pragma Import (Ada, E381, "gtk__tree_store_E");
      E433 : Boolean; pragma Import (Ada, E433, "gtkada__pixmaps_E");
      E307 : Boolean; pragma Import (Ada, E307, "hash_lists_E");
      E295 : Boolean; pragma Import (Ada, E295, "indexed_lists_E");
      E260 : Boolean; pragma Import (Ada, E260, "list_exceptions_E");
      E262 : Boolean; pragma Import (Ada, E262, "mast_E");
      E309 : Boolean; pragma Import (Ada, E309, "mast__scheduling_parameters_E");
      E321 : Boolean; pragma Import (Ada, E321, "mast__scheduling_policies_E");
      E311 : Boolean; pragma Import (Ada, E311, "mast__synchronization_parameters_E");
      E333 : Boolean; pragma Import (Ada, E333, "mast__timers_E");
      E353 : Boolean; pragma Import (Ada, E353, "mast_editor_intl_E");
      E608 : Boolean; pragma Import (Ada, E608, "mast_lex_dfa_E");
      E610 : Boolean; pragma Import (Ada, E610, "mast_lex_io_E");
      E407 : Boolean; pragma Import (Ada, E407, "mast_parser_error_report_E");
      E196 : Boolean; pragma Import (Ada, E196, "pango__enums_E");
      E200 : Boolean; pragma Import (Ada, E200, "pango__attributes_E");
      E190 : Boolean; pragma Import (Ada, E190, "pango__font_E");
      E221 : Boolean; pragma Import (Ada, E221, "gdk__font_E");
      E219 : Boolean; pragma Import (Ada, E219, "gdk__gc_E");
      E231 : Boolean; pragma Import (Ada, E231, "gtk__style_E");
      E583 : Boolean; pragma Import (Ada, E583, "gtk__text_tag_E");
      E589 : Boolean; pragma Import (Ada, E589, "gtk__text_tag_table_E");
      E188 : Boolean; pragma Import (Ada, E188, "pango__context_E");
      E202 : Boolean; pragma Import (Ada, E202, "pango__tabs_E");
      E198 : Boolean; pragma Import (Ada, E198, "pango__layout_E");
      E217 : Boolean; pragma Import (Ada, E217, "gdk__drawable_E");
      E225 : Boolean; pragma Import (Ada, E225, "gdk__rgb_E");
      E215 : Boolean; pragma Import (Ada, E215, "gdk__pixbuf_E");
      E535 : Boolean; pragma Import (Ada, E535, "gtk__icon_factory_E");
      E181 : Boolean; pragma Import (Ada, E181, "gtk__widget_E");
      E254 : Boolean; pragma Import (Ada, E254, "gtk__arguments_E");
      E363 : Boolean; pragma Import (Ada, E363, "gtk__cell_renderer_E");
      E361 : Boolean; pragma Import (Ada, E361, "gtk__cell_renderer_text_E");
      E175 : Boolean; pragma Import (Ada, E175, "gtk__container_E");
      E173 : Boolean; pragma Import (Ada, E173, "gtk__bin_E");
      E477 : Boolean; pragma Import (Ada, E477, "gtk__alignment_E");
      E351 : Boolean; pragma Import (Ada, E351, "gtk__box_E");
      E359 : Boolean; pragma Import (Ada, E359, "gtk__button_E");
      E256 : Boolean; pragma Import (Ada, E256, "gtk__drawing_area_E");
      E369 : Boolean; pragma Import (Ada, E369, "gtk__editable_E");
      E171 : Boolean; pragma Import (Ada, E171, "gtk__frame_E");
      E367 : Boolean; pragma Import (Ada, E367, "gtk__gentry_E");
      E245 : Boolean; pragma Import (Ada, E245, "gtk__item_E");
      E371 : Boolean; pragma Import (Ada, E371, "gtk__list_E");
      E373 : Boolean; pragma Import (Ada, E373, "gtk__list_item_E");
      E235 : Boolean; pragma Import (Ada, E235, "gtk__marshallers_E");
      E243 : Boolean; pragma Import (Ada, E243, "gtk__menu_item_E");
      E457 : Boolean; pragma Import (Ada, E457, "gtk__menu_shell_E");
      E455 : Boolean; pragma Import (Ada, E455, "gtk__menu_E");
      E599 : Boolean; pragma Import (Ada, E599, "gtk__menu_bar_E");
      E241 : Boolean; pragma Import (Ada, E241, "gtk__misc_E");
      E531 : Boolean; pragma Import (Ada, E531, "gtk__image_E");
      E239 : Boolean; pragma Import (Ada, E239, "gtk__label_E");
      E237 : Boolean; pragma Import (Ada, E237, "gtk__notebook_E");
      E375 : Boolean; pragma Import (Ada, E375, "gtk__scrolled_window_E");
      E377 : Boolean; pragma Import (Ada, E377, "gtk__separator_E");
      E601 : Boolean; pragma Import (Ada, E601, "gtk__separator_menu_item_E");
      E379 : Boolean; pragma Import (Ada, E379, "gtk__table_E");
      E581 : Boolean; pragma Import (Ada, E581, "gtk__text_child_E");
      E579 : Boolean; pragma Import (Ada, E579, "gtk__text_iter_E");
      E577 : Boolean; pragma Import (Ada, E577, "gtk__text_buffer_E");
      E591 : Boolean; pragma Import (Ada, E591, "gtk__text_view_E");
      E545 : Boolean; pragma Import (Ada, E545, "gtk__toggle_button_E");
      E543 : Boolean; pragma Import (Ada, E543, "gtk__check_button_E");
      E603 : Boolean; pragma Import (Ada, E603, "gtk__tooltips_E");
      E389 : Boolean; pragma Import (Ada, E389, "gtk__tree_selection_E");
      E387 : Boolean; pragma Import (Ada, E387, "gtk__tree_view_column_E");
      E385 : Boolean; pragma Import (Ada, E385, "gtk__tree_view_E");
      E349 : Boolean; pragma Import (Ada, E349, "gtk__window_E");
      E365 : Boolean; pragma Import (Ada, E365, "gtk__combo_E");
      E347 : Boolean; pragma Import (Ada, E347, "gtk__dialog_E");
      E426 : Boolean; pragma Import (Ada, E426, "add_link_dialog_pkg_E");
      E428 : Boolean; pragma Import (Ada, E428, "add_link_dialog_pkg__callbacks_E");
      E539 : Boolean; pragma Import (Ada, E539, "add_new_op_to_driver_dialog_pkg_E");
      E541 : Boolean; pragma Import (Ada, E541, "add_new_op_to_driver_dialog_pkg__callbacks_E");
      E547 : Boolean; pragma Import (Ada, E547, "add_new_server_to_driver_dialog_pkg_E");
      E549 : Boolean; pragma Import (Ada, E549, "add_new_server_to_driver_dialog_pkg__callbacks_E");
      E553 : Boolean; pragma Import (Ada, E553, "add_operation_dialog_pkg_E");
      E555 : Boolean; pragma Import (Ada, E555, "add_operation_dialog_pkg__callbacks_E");
      E557 : Boolean; pragma Import (Ada, E557, "add_shared_dialog_pkg_E");
      E559 : Boolean; pragma Import (Ada, E559, "add_shared_dialog_pkg__callbacks_E");
      E343 : Boolean; pragma Import (Ada, E343, "cop_dialog_pkg_E");
      E345 : Boolean; pragma Import (Ada, E345, "cop_dialog_pkg__callbacks_E");
      E340 : Boolean; pragma Import (Ada, E340, "driver_dialog_pkg_E");
      E537 : Boolean; pragma Import (Ada, E537, "driver_dialog_pkg__callbacks_E");
      E399 : Boolean; pragma Import (Ada, E399, "editor_error_window_pkg_E");
      E401 : Boolean; pragma Import (Ada, E401, "editor_error_window_pkg__callbacks_E");
      E391 : Boolean; pragma Import (Ada, E391, "external_dialog_pkg_E");
      E393 : Boolean; pragma Import (Ada, E393, "external_dialog_pkg__callbacks_E");
      E410 : Boolean; pragma Import (Ada, E410, "gtk__file_selection_E");
      E432 : Boolean; pragma Import (Ada, E432, "gtk__pixmap_E");
      E247 : Boolean; pragma Import (Ada, E247, "gtkada__canvas_E");
      E561 : Boolean; pragma Import (Ada, E561, "aux_window_pkg_E");
      E259 : Boolean; pragma Import (Ada, E259, "gtkada__handlers_E");
      E395 : Boolean; pragma Import (Ada, E395, "import_file_selection_pkg_E");
      E397 : Boolean; pragma Import (Ada, E397, "import_file_selection_pkg__callbacks_E");
      E412 : Boolean; pragma Import (Ada, E412, "internal_dialog_pkg_E");
      E439 : Boolean; pragma Import (Ada, E439, "item_menu_pkg_E");
      E441 : Boolean; pragma Import (Ada, E441, "item_menu_pkg__callbacks_E");
      E567 : Boolean; pragma Import (Ada, E567, "mast_editor_window_pkg_E");
      E569 : Boolean; pragma Import (Ada, E569, "mast_editor_window_pkg__callbacks_E");
      E483 : Boolean; pragma Import (Ada, E483, "message_tx_dialog_pkg_E");
      E485 : Boolean; pragma Import (Ada, E485, "message_tx_dialog_pkg__callbacks_E");
      E461 : Boolean; pragma Import (Ada, E461, "mieh_dialog_pkg_E");
      E463 : Boolean; pragma Import (Ada, E463, "mieh_dialog_pkg__callbacks_E");
      E465 : Boolean; pragma Import (Ada, E465, "moeh_dialog_pkg_E");
      E467 : Boolean; pragma Import (Ada, E467, "moeh_dialog_pkg__callbacks_E");
      E487 : Boolean; pragma Import (Ada, E487, "network_dialog_pkg_E");
      E489 : Boolean; pragma Import (Ada, E489, "network_dialog_pkg__callbacks_E");
      E447 : Boolean; pragma Import (Ada, E447, "open_file_selection_pkg_E");
      E449 : Boolean; pragma Import (Ada, E449, "open_file_selection_pkg__callbacks_E");
      E505 : Boolean; pragma Import (Ada, E505, "prime_sched_dialog_pkg_E");
      E507 : Boolean; pragma Import (Ada, E507, "prime_sched_dialog_pkg__callbacks_E");
      E501 : Boolean; pragma Import (Ada, E501, "processor_dialog_pkg_E");
      E503 : Boolean; pragma Import (Ada, E503, "processor_dialog_pkg__callbacks_E");
      E443 : Boolean; pragma Import (Ada, E443, "save_changes_dialog_pkg_E");
      E445 : Boolean; pragma Import (Ada, E445, "save_changes_dialog_pkg__callbacks_E");
      E451 : Boolean; pragma Import (Ada, E451, "save_file_selection_pkg_E");
      E453 : Boolean; pragma Import (Ada, E453, "save_file_selection_pkg__callbacks_E");
      E511 : Boolean; pragma Import (Ada, E511, "sched_server_dialog_pkg_E");
      E513 : Boolean; pragma Import (Ada, E513, "sched_server_dialog_pkg__callbacks_E");
      E515 : Boolean; pragma Import (Ada, E515, "second_sched_dialog_pkg_E");
      E517 : Boolean; pragma Import (Ada, E517, "second_sched_dialog_pkg__callbacks_E");
      E469 : Boolean; pragma Import (Ada, E469, "seh_dialog_pkg_E");
      E471 : Boolean; pragma Import (Ada, E471, "seh_dialog_pkg__callbacks_E");
      E416 : Boolean; pragma Import (Ada, E416, "select_ref_event_dialog_pkg_E");
      E418 : Boolean; pragma Import (Ada, E418, "select_ref_event_dialog_pkg__callbacks_E");
      E420 : Boolean; pragma Import (Ada, E420, "select_req_type_dialog_pkg_E");
      E422 : Boolean; pragma Import (Ada, E422, "select_req_type_dialog_pkg__callbacks_E");
      E519 : Boolean; pragma Import (Ada, E519, "shared_resource_dialog_pkg_E");
      E521 : Boolean; pragma Import (Ada, E521, "shared_resource_dialog_pkg__callbacks_E");
      E523 : Boolean; pragma Import (Ada, E523, "sop_dialog_pkg_E");
      E525 : Boolean; pragma Import (Ada, E525, "sop_dialog_pkg__callbacks_E");
      E497 : Boolean; pragma Import (Ada, E497, "timer_dialog_pkg_E");
      E499 : Boolean; pragma Import (Ada, E499, "timer_dialog_pkg__callbacks_E");
      E479 : Boolean; pragma Import (Ada, E479, "trans_dialog_pkg_E");
      E481 : Boolean; pragma Import (Ada, E481, "trans_dialog_pkg__callbacks_E");
      E265 : Boolean; pragma Import (Ada, E265, "var_strings_E");
      E269 : Boolean; pragma Import (Ada, E269, "mast__io_E");
      E336 : Boolean; pragma Import (Ada, E336, "mast_editor_E");
      E288 : Boolean; pragma Import (Ada, E288, "named_lists_E");
      E301 : Boolean; pragma Import (Ada, E301, "mast__events_E");
      E299 : Boolean; pragma Import (Ada, E299, "mast__graphs_E");
      E297 : Boolean; pragma Import (Ada, E297, "mast__results_E");
      E319 : Boolean; pragma Import (Ada, E319, "mast__processing_resources_E");
      E331 : Boolean; pragma Import (Ada, E331, "mast__processing_resources__processor_E");
      E317 : Boolean; pragma Import (Ada, E317, "mast__schedulers_E");
      E323 : Boolean; pragma Import (Ada, E323, "mast__schedulers__primary_E");
      E315 : Boolean; pragma Import (Ada, E315, "mast__scheduling_servers_E");
      E405 : Boolean; pragma Import (Ada, E405, "mast__schedulers__adjustment_E");
      E325 : Boolean; pragma Import (Ada, E325, "mast__schedulers__secondary_E");
      E313 : Boolean; pragma Import (Ada, E313, "mast__shared_resources_E");
      E293 : Boolean; pragma Import (Ada, E293, "mast__operations_E");
      E267 : Boolean; pragma Import (Ada, E267, "mast__drivers_E");
      E327 : Boolean; pragma Import (Ada, E327, "mast__graphs__event_handlers_E");
      E329 : Boolean; pragma Import (Ada, E329, "mast__processing_resources__network_E");
      E305 : Boolean; pragma Import (Ada, E305, "mast__timing_requirements_E");
      E303 : Boolean; pragma Import (Ada, E303, "mast__graphs__links_E");
      E335 : Boolean; pragma Import (Ada, E335, "mast__transactions_E");
      E403 : Boolean; pragma Import (Ada, E403, "mast__systems_E");
      E565 : Boolean; pragma Import (Ada, E565, "mast__transaction_operations_E");
      E338 : Boolean; pragma Import (Ada, E338, "mast_editor__drivers_E");
      E551 : Boolean; pragma Import (Ada, E551, "mast_editor__operations_E");
      E493 : Boolean; pragma Import (Ada, E493, "mast_editor__processing_resources_E");
      E491 : Boolean; pragma Import (Ada, E491, "mast_editor__schedulers_E");
      E509 : Boolean; pragma Import (Ada, E509, "mast_editor__scheduling_servers_E");
      E563 : Boolean; pragma Import (Ada, E563, "mast_editor__shared_resources_E");
      E495 : Boolean; pragma Import (Ada, E495, "mast_editor__timers_E");
      E475 : Boolean; pragma Import (Ada, E475, "mast_editor__transactions_E");
      E459 : Boolean; pragma Import (Ada, E459, "mast_editor__event_handlers_E");
      E424 : Boolean; pragma Import (Ada, E424, "mast_editor__links_E");
      E414 : Boolean; pragma Import (Ada, E414, "internal_dialog_pkg__callbacks_E");
      E614 : Boolean; pragma Import (Ada, E614, "mast_editor__systems_E");
      E286 : Boolean; pragma Import (Ada, E286, "symbol_table_E");
      E284 : Boolean; pragma Import (Ada, E284, "mast_parser_tokens_E");
      E130 : Boolean; pragma Import (Ada, E130, "editor_actions_E");
      E606 : Boolean; pragma Import (Ada, E606, "mast_lex_E");
      E573 : Boolean; pragma Import (Ada, E573, "wizard_activity_dialog_pkg_E");
      E575 : Boolean; pragma Import (Ada, E575, "wizard_completed_dialog_pkg_E");
      E527 : Boolean; pragma Import (Ada, E527, "wizard_input_dialog_pkg_E");
      E341 : Boolean; pragma Import (Ada, E341, "callbacks_mast_editor_E");
      E529 : Boolean; pragma Import (Ada, E529, "wizard_input_dialog_pkg__callbacks_E");
      E593 : Boolean; pragma Import (Ada, E593, "wizard_output_dialog_pkg_E");
      E595 : Boolean; pragma Import (Ada, E595, "wizard_transaction_dialog_pkg_E");
      E597 : Boolean; pragma Import (Ada, E597, "wizard_welcome_dialog_pkg_E");
      E571 : Boolean; pragma Import (Ada, E571, "simple_transaction_wizard_control_E");

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
      E013 := True;
      System.Secondary_Stack'Elab_Body;
      E009 := True;
      System.Exception_Table'Elab_Body;
      E019 := True;
      Ada.Calendar'Elab_Spec;
      Ada.Calendar'Elab_Body;
      E049 := True;
      Ada.Calendar.Time_Zones'Elab_Spec;
      E057 := True;
      Ada.Io_Exceptions'Elab_Spec;
      E100 := True;
      Ada.Numerics'Elab_Spec;
      E131 := True;
      Ada.Strings'Elab_Spec;
      E077 := True;
      Ada.Tags'Elab_Spec;
      Ada.Streams'Elab_Spec;
      E091 := True;
      Interfaces.C'Elab_Spec;
      E143 := True;
      Interfaces.C.Strings'Elab_Spec;
      E145 := True;
      System.Finalization_Root'Elab_Spec;
      E090 := True;
      System.Os_Lib'Elab_Body;
      E113 := True;
      Ada.Strings.Maps'Elab_Spec;
      E079 := True;
      Ada.Strings.Maps.Constants'Elab_Spec;
      E082 := True;
      System.Finalization_Implementation'Elab_Spec;
      System.Finalization_Implementation'Elab_Body;
      E095 := True;
      Ada.Finalization'Elab_Spec;
      E088 := True;
      Ada.Finalization.List_Controller'Elab_Spec;
      E086 := True;
      Ada.Strings.Unbounded'Elab_Spec;
      E106 := True;
      Ada.Directories'Elab_Spec;
      System.File_Control_Block'Elab_Spec;
      E126 := True;
      System.File_Io'Elab_Body;
      E123 := True;
      Ada.Text_Io'Elab_Spec;
      Ada.Text_Io'Elab_Body;
      E119 := True;
      System.Regexp'Elab_Spec;
      E117 := True;
      Ada.Directories'Elab_Body;
      E047 := True;
      Ada.Tags'Elab_Body;
      E093 := True;
      E283 := True;
      E128 := True;
      Glib'Elab_Spec;
      E141 := True;
      E533 := True;
      E147 := True;
      E179 := True;
      Gdk.Visual'Elab_Body;
      E185 := True;
      Glib.Graphs'Elab_Spec;
      E250 := True;
      E159 := True;
      Glib.Values'Elab_Body;
      E167 := True;
      Gtkada.Types'Elab_Spec;
      E157 := True;
      Glib.Object'Elab_Spec;
      Gdk.Color'Elab_Spec;
      E208 := True;
      Glib.Generic_Properties'Elab_Body;
      E169 := True;
      E154 := True;
      E152 := True;
      E183 := True;
      E213 := True;
      Gdk.Event'Elab_Spec;
      E210 := True;
      E204 := True;
      E223 := True;
      E165 := True;
      E585 := True;
      E177 := True;
      Gtk.Object'Elab_Spec;
      E163 := True;
      Gtk.Accel_Group'Elab_Spec;
      Gtk.Accel_Group'Elab_Body;
      E229 := True;
      Gtk.Adjustment'Elab_Spec;
      E161 := True;
      Gtk.Text_Mark'Elab_Spec;
      E587 := True;
      Gtk.Tree_Model'Elab_Spec;
      E383 := True;
      Gtk.Tree_Store'Elab_Spec;
      E381 := True;
      Gtkada.Pixmaps'Elab_Spec;
      E433 := True;
      List_Exceptions'Elab_Spec;
      E260 := True;
      E295 := True;
      E307 := True;
      Mast'Elab_Spec;
      Mast.Scheduling_Parameters'Elab_Spec;
      Mast.Scheduling_Policies'Elab_Spec;
      Mast.Synchronization_Parameters'Elab_Spec;
      Mast.Timers'Elab_Spec;
      E353 := True;
      E608 := True;
      mast_lex_io'elab_spec;
      E610 := True;
      Mast_Parser_Error_Report'Elab_Spec;
      E407 := True;
      E196 := True;
      E200 := True;
      Pango.Font'Elab_Spec;
      E190 := True;
      E221 := True;
      E219 := True;
      E231 := True;
      Gtk.Text_Tag'Elab_Spec;
      E583 := True;
      Gtk.Text_Tag_Table'Elab_Spec;
      E589 := True;
      Pango.Context'Elab_Spec;
      E188 := True;
      E202 := True;
      Pango.Layout'Elab_Spec;
      E198 := True;
      E217 := True;
      E225 := True;
      E215 := True;
      Gtk.Icon_Factory'Elab_Spec;
      E535 := True;
      Gtk.Widget'Elab_Spec;
      E181 := True;
      E206 := True;
      E254 := True;
      Gtk.Cell_Renderer'Elab_Spec;
      E363 := True;
      Gtk.Cell_Renderer_Text'Elab_Spec;
      E361 := True;
      Gtk.Container'Elab_Spec;
      E175 := True;
      Gtk.Bin'Elab_Spec;
      E173 := True;
      Gtk.Alignment'Elab_Spec;
      E477 := True;
      Gtk.Box'Elab_Spec;
      E351 := True;
      Gtk.Button'Elab_Spec;
      Gtk.Button'Elab_Body;
      E359 := True;
      Gtk.Drawing_Area'Elab_Spec;
      E256 := True;
      Gtk.Editable'Elab_Spec;
      E369 := True;
      Gtk.Frame'Elab_Spec;
      E171 := True;
      Gtk.Gentry'Elab_Spec;
      Gtk.Gentry'Elab_Body;
      E367 := True;
      Gtk.Item'Elab_Spec;
      Gtk.Item'Elab_Body;
      E245 := True;
      Gtk.List'Elab_Spec;
      E371 := True;
      Gtk.List_Item'Elab_Spec;
      Gtk.List_Item'Elab_Body;
      E373 := True;
      E235 := True;
      Gtk.Menu_Item'Elab_Spec;
      Gtk.Menu_Item'Elab_Body;
      E243 := True;
      Gtk.Menu_Shell'Elab_Spec;
      E457 := True;
      Gtk.Menu'Elab_Spec;
      Gtk.Menu'Elab_Body;
      E455 := True;
      Gtk.Menu_Bar'Elab_Spec;
      Gtk.Menu_Bar'Elab_Body;
      E599 := True;
      Gtk.Misc'Elab_Spec;
      E241 := True;
      Gtk.Image'Elab_Spec;
      E531 := True;
      Gtk.Label'Elab_Spec;
      Gtk.Label'Elab_Body;
      E239 := True;
      Gtk.Notebook'Elab_Spec;
      E237 := True;
      Gtk.Scrolled_Window'Elab_Spec;
      E375 := True;
      Gtk.Separator'Elab_Spec;
      E377 := True;
      Gtk.Separator_Menu_Item'Elab_Spec;
      E601 := True;
      Gtk.Table'Elab_Spec;
      E379 := True;
      Gtk.Text_Child'Elab_Spec;
      E581 := True;
      Gtk.Text_Iter'Elab_Body;
      E579 := True;
      Gtk.Text_Buffer'Elab_Spec;
      E577 := True;
      Gtk.Text_View'Elab_Spec;
      E591 := True;
      Gtk.Toggle_Button'Elab_Spec;
      E545 := True;
      Gtk.Check_Button'Elab_Spec;
      E543 := True;
      Gtk.Tooltips'Elab_Spec;
      E603 := True;
      Gtk.Tree_Selection'Elab_Spec;
      E389 := True;
      Gtk.Tree_View_Column'Elab_Spec;
      E387 := True;
      Gtk.Tree_View'Elab_Spec;
      E385 := True;
      Gtk.Window'Elab_Spec;
      Gtk.Window'Elab_Body;
      E349 := True;
      Gtk.Combo'Elab_Spec;
      E365 := True;
      Gtk.Dialog'Elab_Spec;
      E347 := True;
      Add_Link_Dialog_Pkg'Elab_Spec;
      E428 := True;
      Add_New_Op_To_Driver_Dialog_Pkg'Elab_Spec;
      E541 := True;
      Add_New_Server_To_Driver_Dialog_Pkg'Elab_Spec;
      E549 := True;
      Add_Operation_Dialog_Pkg'Elab_Spec;
      E555 := True;
      Add_Shared_Dialog_Pkg'Elab_Spec;
      E559 := True;
      Cop_Dialog_Pkg'Elab_Spec;
      E345 := True;
      Driver_Dialog_Pkg'Elab_Spec;
      Editor_Error_Window_Pkg'Elab_Spec;
      E401 := True;
      External_Dialog_Pkg'Elab_Spec;
      E393 := True;
      Gtk.File_Selection'Elab_Spec;
      E410 := True;
      Gtk.Pixmap'Elab_Spec;
      Gtk.Pixmap'Elab_Body;
      E432 := True;
      Gtkada.Canvas'Elab_Spec;
      Aux_Window_Pkg'Elab_Spec;
      Gtkada.Handlers'Elab_Spec;
      E259 := True;
      Gtkada.Canvas'Elab_Body;
      E247 := True;
      Import_File_Selection_Pkg'Elab_Spec;
      Internal_Dialog_Pkg'Elab_Spec;
      Item_Menu_Pkg'Elab_Spec;
      Mast_Editor_Window_Pkg'Elab_Spec;
      Message_Tx_Dialog_Pkg'Elab_Spec;
      E485 := True;
      Mieh_Dialog_Pkg'Elab_Spec;
      E463 := True;
      Moeh_Dialog_Pkg'Elab_Spec;
      E467 := True;
      Network_Dialog_Pkg'Elab_Spec;
      Open_File_Selection_Pkg'Elab_Spec;
      Prime_Sched_Dialog_Pkg'Elab_Spec;
      E507 := True;
      Processor_Dialog_Pkg'Elab_Spec;
      Save_Changes_Dialog_Pkg'Elab_Spec;
      Save_File_Selection_Pkg'Elab_Spec;
      Sched_Server_Dialog_Pkg'Elab_Spec;
      E513 := True;
      Second_Sched_Dialog_Pkg'Elab_Spec;
      E517 := True;
      Seh_Dialog_Pkg'Elab_Spec;
      E471 := True;
      Select_Ref_Event_Dialog_Pkg'Elab_Spec;
      E418 := True;
      Select_Req_Type_Dialog_Pkg'Elab_Spec;
      E422 := True;
      Shared_Resource_Dialog_Pkg'Elab_Spec;
      E521 := True;
      Sop_Dialog_Pkg'Elab_Spec;
      E525 := True;
      Timer_Dialog_Pkg'Elab_Spec;
      E499 := True;
      Trans_Dialog_Pkg'Elab_Spec;
      E481 := True;
      Var_Strings'Elab_Spec;
      E265 := True;
      Mast'Elab_Body;
      E262 := True;
      E333 := True;
      E311 := True;
      E321 := True;
      E309 := True;
      Mast_Editor'Elab_Spec;
      E336 := True;
      E441 := True;
      E288 := True;
      MAST.EVENTS'ELAB_SPEC;
      E301 := True;
      MAST.GRAPHS'ELAB_SPEC;
      E299 := True;
      MAST.RESULTS'ELAB_SPEC;
      Mast.Processing_Resources'Elab_Spec;
      E319 := True;
      Mast.Processing_Resources.Processor'Elab_Spec;
      E331 := True;
      Mast.Schedulers'Elab_Spec;
      E317 := True;
      Mast.Schedulers.Primary'Elab_Spec;
      E323 := True;
      MAST.SCHEDULING_SERVERS'ELAB_SPEC;
      Mast.Schedulers.Secondary'Elab_Spec;
      E325 := True;
      E405 := True;
      E315 := True;
      Mast.Shared_Resources'Elab_Spec;
      E313 := True;
      MAST.OPERATIONS'ELAB_SPEC;
      E293 := True;
      Mast.Drivers'Elab_Spec;
      E267 := True;
      MAST.GRAPHS.EVENT_HANDLERS'ELAB_SPEC;
      E327 := True;
      Mast.Processing_Resources.Network'Elab_Spec;
      E329 := True;
      MAST.TIMING_REQUIREMENTS'ELAB_SPEC;
      E305 := True;
      MAST.GRAPHS.LINKS'ELAB_SPEC;
      E303 := True;
      E297 := True;
      MAST.TRANSACTIONS'ELAB_SPEC;
      E335 := True;
      Mast.Systems'Elab_Spec;
      E403 := True;
      MAST.TRANSACTION_OPERATIONS'ELAB_SPEC;
      E565 := True;
      Mast_Editor.Drivers'Elab_Spec;
      Mast_Editor.Operations'Elab_Spec;
      Mast_Editor.Processing_Resources'Elab_Spec;
      Mast_Editor.Schedulers'Elab_Spec;
      E503 := True;
      E489 := True;
      Mast_Editor.Scheduling_Servers'Elab_Spec;
      Mast_Editor.Shared_Resources'Elab_Spec;
      Mast_Editor.Timers'Elab_Spec;
      Mast_Editor.Transactions'Elab_Spec;
      Mast_Editor.Event_Handlers'Elab_Spec;
      Mast_Editor.Links'Elab_Spec;
      Mast_Editor.Systems'Elab_Spec;
      E614 := True;
      Symbol_Table'Elab_Spec;
      Symbol_Table'Elab_Body;
      E286 := True;
      Mast_Parser_Tokens'Elab_Spec;
      E284 := True;
      MAST.IO'ELAB_BODY;
      E269 := True;
      Editor_Actions'Elab_Spec;
      Mast_Editor.Links'Elab_Body;
      E424 := True;
      Mast_Editor.Event_Handlers'Elab_Body;
      E459 := True;
      Mast_Editor.Timers'Elab_Body;
      E495 := True;
      Mast_Editor.Drivers'Elab_Body;
      E338 := True;
      E453 := True;
      E445 := True;
      E449 := True;
      E397 := True;
      Driver_Dialog_Pkg.Callbacks'Elab_Body;
      E537 := True;
      E606 := True;
      Editor_Actions'Elab_Body;
      E130 := True;
      Wizard_Activity_Dialog_Pkg'Elab_Spec;
      Wizard_Completed_Dialog_Pkg'Elab_Spec;
      Wizard_Input_Dialog_Pkg'Elab_Spec;
      Callbacks_Mast_Editor'Elab_Spec;
      E341 := True;
      E575 := True;
      E573 := True;
      Internal_Dialog_Pkg.Callbacks'Elab_Body;
      E414 := True;
      Mast_Editor.Transactions'Elab_Body;
      E475 := True;
      Mast_Editor.Shared_Resources'Elab_Body;
      E563 := True;
      Mast_Editor.Scheduling_Servers'Elab_Body;
      E509 := True;
      Mast_Editor.Schedulers'Elab_Body;
      E491 := True;
      Mast_Editor.Processing_Resources'Elab_Body;
      E493 := True;
      Mast_Editor.Operations'Elab_Body;
      E551 := True;
      Trans_Dialog_Pkg'Elab_Body;
      E479 := True;
      E497 := True;
      E523 := True;
      E519 := True;
      E420 := True;
      Select_Ref_Event_Dialog_Pkg'Elab_Body;
      E416 := True;
      E469 := True;
      E515 := True;
      E511 := True;
      E451 := True;
      E443 := True;
      E501 := True;
      E505 := True;
      E447 := True;
      E487 := True;
      E465 := True;
      E461 := True;
      E483 := True;
      Mast_Editor_Window_Pkg'Elab_Body;
      E567 := True;
      E439 := True;
      Internal_Dialog_Pkg'Elab_Body;
      E412 := True;
      E395 := True;
      E561 := True;
      E391 := True;
      E399 := True;
      E340 := True;
      E343 := True;
      E557 := True;
      E553 := True;
      E547 := True;
      E539 := True;
      E426 := True;
      E529 := True;
      E527 := True;
      Wizard_Output_Dialog_Pkg'Elab_Spec;
      E593 := True;
      Wizard_Transaction_Dialog_Pkg'Elab_Spec;
      E595 := True;
      Wizard_Welcome_Dialog_Pkg'Elab_Spec;
      E597 := True;
      Simple_Transaction_Wizard_Control'Elab_Body;
      E571 := True;
      E569 := True;
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
      pragma Import (Ada, Ada_Main_Program, "_ada_gmasteditor");

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
   --   ./change_control.o
   --   ../../mast_analysis/list_exceptions.o
   --   ../../mast_analysis/indexed_lists.o
   --   ../../mast_analysis/hash_lists.o
   --   ./mast_editor_intl.o
   --   ../../mast_analysis/mast_lex_dfa.o
   --   ../../mast_analysis/mast_lex_io.o
   --   ../../mast_analysis/mast_parser_error_report.o
   --   ../../mast_analysis/mast_parser_goto.o
   --   ../../mast_analysis/mast_parser_shift_reduce.o
   --   ./add_link_dialog_pkg-callbacks.o
   --   ./add_new_op_to_driver_dialog_pkg-callbacks.o
   --   ./add_new_server_to_driver_dialog_pkg-callbacks.o
   --   ./add_operation_dialog_pkg-callbacks.o
   --   ./add_shared_dialog_pkg-callbacks.o
   --   ./cop_dialog_pkg-callbacks.o
   --   ./editor_error_window_pkg-callbacks.o
   --   ./external_dialog_pkg-callbacks.o
   --   ./message_tx_dialog_pkg-callbacks.o
   --   ./mieh_dialog_pkg-callbacks.o
   --   ./moeh_dialog_pkg-callbacks.o
   --   ./prime_sched_dialog_pkg-callbacks.o
   --   ./sched_server_dialog_pkg-callbacks.o
   --   ./second_sched_dialog_pkg-callbacks.o
   --   ./seh_dialog_pkg-callbacks.o
   --   ./select_ref_event_dialog_pkg-callbacks.o
   --   ./select_req_type_dialog_pkg-callbacks.o
   --   ./shared_resource_dialog_pkg-callbacks.o
   --   ./sop_dialog_pkg-callbacks.o
   --   ./timer_dialog_pkg-callbacks.o
   --   ./trans_dialog_pkg-callbacks.o
   --   ../../mast_analysis/var_strings.o
   --   ../../mast_analysis/mast.o
   --   ../../mast_analysis/mast-timers.o
   --   ../../mast_analysis/mast-synchronization_parameters.o
   --   ../../mast_analysis/mast-scheduling_policies.o
   --   ../../mast_analysis/mast-scheduling_parameters.o
   --   ./mast_editor.o
   --   ./item_menu_pkg-callbacks.o
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
   --   ../../mast_analysis/mast-transaction_operations.o
   --   ./processor_dialog_pkg-callbacks.o
   --   ./network_dialog_pkg-callbacks.o
   --   ./mast_editor-systems.o
   --   ../../mast_analysis/symbol_table.o
   --   ../../mast_analysis/mast_parser_tokens.o
   --   ../../mast_analysis/mast-io.o
   --   ./mast_editor-links.o
   --   ./mast_editor-event_handlers.o
   --   ./mast_editor-timers.o
   --   ./mast_editor-drivers.o
   --   ./save_file_selection_pkg-callbacks.o
   --   ./save_changes_dialog_pkg-callbacks.o
   --   ./open_file_selection_pkg-callbacks.o
   --   ./import_file_selection_pkg-callbacks.o
   --   ./driver_dialog_pkg-callbacks.o
   --   ./gmasteditor.o
   --   ../../mast_analysis/mast_lex.o
   --   ../../mast_analysis/mast_parser.o
   --   ./editor_actions.o
   --   ./callbacks_mast_editor.o
   --   ./wizard_completed_dialog_pkg.o
   --   ./wizard_activity_dialog_pkg.o
   --   ./internal_dialog_pkg-callbacks.o
   --   ./mast_editor-transactions.o
   --   ./mast_editor-shared_resources.o
   --   ./mast_editor-scheduling_servers.o
   --   ./mast_editor-schedulers.o
   --   ./mast_editor-processing_resources.o
   --   ./mast_editor-operations.o
   --   ./trans_dialog_pkg.o
   --   ./timer_dialog_pkg.o
   --   ./sop_dialog_pkg.o
   --   ./shared_resource_dialog_pkg.o
   --   ./select_req_type_dialog_pkg.o
   --   ./select_ref_event_dialog_pkg.o
   --   ./seh_dialog_pkg.o
   --   ./second_sched_dialog_pkg.o
   --   ./sched_server_dialog_pkg.o
   --   ./save_file_selection_pkg.o
   --   ./save_changes_dialog_pkg.o
   --   ./processor_dialog_pkg.o
   --   ./prime_sched_dialog_pkg.o
   --   ./open_file_selection_pkg.o
   --   ./network_dialog_pkg.o
   --   ./moeh_dialog_pkg.o
   --   ./mieh_dialog_pkg.o
   --   ./message_tx_dialog_pkg.o
   --   ./mast_editor_window_pkg.o
   --   ./item_menu_pkg.o
   --   ./internal_dialog_pkg.o
   --   ./import_file_selection_pkg.o
   --   ./aux_window_pkg.o
   --   ./external_dialog_pkg.o
   --   ./editor_error_window_pkg.o
   --   ./driver_dialog_pkg.o
   --   ./cop_dialog_pkg.o
   --   ./add_shared_dialog_pkg.o
   --   ./add_operation_dialog_pkg.o
   --   ./add_new_server_to_driver_dialog_pkg.o
   --   ./add_new_op_to_driver_dialog_pkg.o
   --   ./add_link_dialog_pkg.o
   --   ./wizard_input_dialog_pkg-callbacks.o
   --   ./wizard_input_dialog_pkg.o
   --   ./wizard_output_dialog_pkg.o
   --   ./wizard_transaction_dialog_pkg.o
   --   ./wizard_welcome_dialog_pkg.o
   --   ./simple_transaction_wizard_control.o
   --   ./mast_editor_window_pkg-callbacks.o
   --   -L./
   --   -L../../mast_analysis/
   --   -L../../utils/
   --   -L../../gmast/src/
   --   -L../../gmastresults/src/
   --   -L/home/mgh/gnat/gtkada/lib/gtkada/
   --   -L/home/mgh/gnat2007/lib/gcc/i686-pc-linux-gnu/4.1.3/adalib/
   --   -static
   --   -lgnat
--  END Object file/option list   

end ada_main;
