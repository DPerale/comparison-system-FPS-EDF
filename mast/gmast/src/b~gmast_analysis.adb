pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b~gmast_analysis.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b~gmast_analysis.adb");

with System.Restrictions;

package body ada_main is
   pragma Warnings (Off);

   procedure Do_Finalize;
   pragma Import (C, Do_Finalize, "system__standard_library__adafinal");

   Local_Priority_Specific_Dispatching : constant String := "";
   Local_Interrupt_States : constant String := "";

   procedure adainit is
      E017 : Boolean; pragma Import (Ada, E017, "system__secondary_stack_E");
      E013 : Boolean; pragma Import (Ada, E013, "system__soft_links_E");
      E023 : Boolean; pragma Import (Ada, E023, "system__exception_table_E");
      E072 : Boolean; pragma Import (Ada, E072, "ada__io_exceptions_E");
      E218 : Boolean; pragma Import (Ada, E218, "ada__strings_E");
      E005 : Boolean; pragma Import (Ada, E005, "ada__tags_E");
      E065 : Boolean; pragma Import (Ada, E065, "ada__streams_E");
      E078 : Boolean; pragma Import (Ada, E078, "interfaces__c_E");
      E080 : Boolean; pragma Import (Ada, E080, "interfaces__c__strings_E");
      E064 : Boolean; pragma Import (Ada, E064, "system__finalization_root_E");
      E220 : Boolean; pragma Import (Ada, E220, "ada__strings__maps_E");
      E223 : Boolean; pragma Import (Ada, E223, "ada__strings__maps__constants_E");
      E067 : Boolean; pragma Import (Ada, E067, "system__finalization_implementation_E");
      E062 : Boolean; pragma Import (Ada, E062, "ada__finalization_E");
      E060 : Boolean; pragma Import (Ada, E060, "ada__finalization__list_controller_E");
      E241 : Boolean; pragma Import (Ada, E241, "ada__strings__unbounded_E");
      E233 : Boolean; pragma Import (Ada, E233, "system__file_control_block_E");
      E230 : Boolean; pragma Import (Ada, E230, "system__file_io_E");
      E225 : Boolean; pragma Import (Ada, E225, "ada__text_io_E");
      E276 : Boolean; pragma Import (Ada, E276, "dynamic_lists_E");
      E076 : Boolean; pragma Import (Ada, E076, "glib_E");
      E297 : Boolean; pragma Import (Ada, E297, "gdk__image_E");
      E128 : Boolean; pragma Import (Ada, E128, "gdk__rectangle_E");
      E105 : Boolean; pragma Import (Ada, E105, "glib__glist_E");
      E111 : Boolean; pragma Import (Ada, E111, "gdk__visual_E");
      E089 : Boolean; pragma Import (Ada, E089, "glib__gslist_E");
      E095 : Boolean; pragma Import (Ada, E095, "glib__values_E");
      E185 : Boolean; pragma Import (Ada, E185, "gmast_analysis_intl_E");
      E087 : Boolean; pragma Import (Ada, E087, "gtkada__types_E");
      E082 : Boolean; pragma Import (Ada, E082, "glib__object_E");
      E109 : Boolean; pragma Import (Ada, E109, "gdk__color_E");
      E138 : Boolean; pragma Import (Ada, E138, "gdk__cursor_E");
      E097 : Boolean; pragma Import (Ada, E097, "glib__generic_properties_E");
      E084 : Boolean; pragma Import (Ada, E084, "glib__type_conversion_hooks_E");
      E143 : Boolean; pragma Import (Ada, E143, "gdk__region_E");
      E140 : Boolean; pragma Import (Ada, E140, "gdk__event_E");
      E136 : Boolean; pragma Import (Ada, E136, "gdk__window_E");
      E134 : Boolean; pragma Import (Ada, E134, "gdk__bitmap_E");
      E153 : Boolean; pragma Import (Ada, E153, "gdk__pixmap_E");
      E093 : Boolean; pragma Import (Ada, E093, "glib__properties_E");
      E103 : Boolean; pragma Import (Ada, E103, "gtk__enums_E");
      E161 : Boolean; pragma Import (Ada, E161, "gtk__object_E");
      E159 : Boolean; pragma Import (Ada, E159, "gtk__accel_group_E");
      E163 : Boolean; pragma Import (Ada, E163, "gtk__adjustment_E");
      E313 : Boolean; pragma Import (Ada, E313, "gtkada__pixmaps_E");
      E277 : Boolean; pragma Import (Ada, E277, "list_exceptions_E");
      E212 : Boolean; pragma Import (Ada, E212, "mast_E");
      E239 : Boolean; pragma Import (Ada, E239, "mast__annealing_parameters_E");
      E267 : Boolean; pragma Import (Ada, E267, "mast__hopa_parameters_E");
      E265 : Boolean; pragma Import (Ada, E265, "mast__priority_assignment_parameters_E");
      E247 : Boolean; pragma Import (Ada, E247, "mast__tool_exceptions_E");
      E312 : Boolean; pragma Import (Ada, E312, "mast_analysis_pixmaps_E");
      E124 : Boolean; pragma Import (Ada, E124, "pango__enums_E");
      E130 : Boolean; pragma Import (Ada, E130, "pango__attributes_E");
      E116 : Boolean; pragma Import (Ada, E116, "pango__font_E");
      E151 : Boolean; pragma Import (Ada, E151, "gdk__font_E");
      E149 : Boolean; pragma Import (Ada, E149, "gdk__gc_E");
      E165 : Boolean; pragma Import (Ada, E165, "gtk__style_E");
      E114 : Boolean; pragma Import (Ada, E114, "pango__context_E");
      E132 : Boolean; pragma Import (Ada, E132, "pango__tabs_E");
      E126 : Boolean; pragma Import (Ada, E126, "pango__layout_E");
      E147 : Boolean; pragma Import (Ada, E147, "gdk__drawable_E");
      E155 : Boolean; pragma Import (Ada, E155, "gdk__rgb_E");
      E145 : Boolean; pragma Import (Ada, E145, "gdk__pixbuf_E");
      E299 : Boolean; pragma Import (Ada, E299, "gtk__icon_factory_E");
      E107 : Boolean; pragma Import (Ada, E107, "gtk__widget_E");
      E183 : Boolean; pragma Import (Ada, E183, "gtk__arguments_E");
      E101 : Boolean; pragma Import (Ada, E101, "gtk__container_E");
      E099 : Boolean; pragma Import (Ada, E099, "gtk__bin_E");
      E190 : Boolean; pragma Import (Ada, E190, "gtk__alignment_E");
      E192 : Boolean; pragma Import (Ada, E192, "gtk__box_E");
      E091 : Boolean; pragma Import (Ada, E091, "gtk__button_E");
      E173 : Boolean; pragma Import (Ada, E173, "gtk__editable_E");
      E293 : Boolean; pragma Import (Ada, E293, "gtk__frame_E");
      E171 : Boolean; pragma Import (Ada, E171, "gtk__gentry_E");
      E326 : Boolean; pragma Import (Ada, E326, "gtk__item_E");
      E328 : Boolean; pragma Import (Ada, E328, "gtk__list_E");
      E330 : Boolean; pragma Import (Ada, E330, "gtk__list_item_E");
      E177 : Boolean; pragma Import (Ada, E177, "gtk__marshallers_E");
      E196 : Boolean; pragma Import (Ada, E196, "gtk__misc_E");
      E295 : Boolean; pragma Import (Ada, E295, "gtk__image_E");
      E194 : Boolean; pragma Import (Ada, E194, "gtk__label_E");
      E179 : Boolean; pragma Import (Ada, E179, "gtk__notebook_E");
      E210 : Boolean; pragma Import (Ada, E210, "gtk__old_editable_E");
      E206 : Boolean; pragma Import (Ada, E206, "gtk__scrolled_window_E");
      E301 : Boolean; pragma Import (Ada, E301, "gtk__table_E");
      E208 : Boolean; pragma Import (Ada, E208, "gtk__text_E");
      E169 : Boolean; pragma Import (Ada, E169, "gtk__toggle_button_E");
      E167 : Boolean; pragma Import (Ada, E167, "gtk__check_button_E");
      E058 : Boolean; pragma Import (Ada, E058, "callbacks_gmast_analysis_E");
      E198 : Boolean; pragma Import (Ada, E198, "gtk__window_E");
      E053 : Boolean; pragma Import (Ada, E053, "annealing_window_pkg_E");
      E055 : Boolean; pragma Import (Ada, E055, "annealing_window_pkg__callbacks_E");
      E303 : Boolean; pragma Import (Ada, E303, "error_inputfile_pkg_E");
      E305 : Boolean; pragma Import (Ada, E305, "error_inputfile_pkg__callbacks_E");
      E057 : Boolean; pragma Import (Ada, E057, "error_window_pkg_E");
      E181 : Boolean; pragma Import (Ada, E181, "error_window_pkg__callbacks_E");
      E324 : Boolean; pragma Import (Ada, E324, "gtk__combo_E");
      E336 : Boolean; pragma Import (Ada, E336, "gtk__dialog_E");
      E334 : Boolean; pragma Import (Ada, E334, "gtk__file_selection_E");
      E307 : Boolean; pragma Import (Ada, E307, "fileselection1_pkg_E");
      E309 : Boolean; pragma Import (Ada, E309, "fileselection1_pkg__callbacks_E");
      E332 : Boolean; pragma Import (Ada, E332, "gtk__pixmap_E");
      E188 : Boolean; pragma Import (Ada, E188, "gtkada__handlers_E");
      E200 : Boolean; pragma Import (Ada, E200, "help_annealing_pkg_E");
      E204 : Boolean; pragma Import (Ada, E204, "help_annealing_pkg__callbacks_E");
      E289 : Boolean; pragma Import (Ada, E289, "help_hopa_pkg_E");
      E291 : Boolean; pragma Import (Ada, E291, "help_hopa_pkg__callbacks_E");
      E320 : Boolean; pragma Import (Ada, E320, "help_pkg_E");
      E322 : Boolean; pragma Import (Ada, E322, "help_pkg__callbacks_E");
      E283 : Boolean; pragma Import (Ada, E283, "hopa_window_pkg_E");
      E287 : Boolean; pragma Import (Ada, E287, "hopa_window_pkg__callbacks_E");
      E311 : Boolean; pragma Import (Ada, E311, "mast_analysis_pkg_E");
      E315 : Boolean; pragma Import (Ada, E315, "mast_analysis_pkg__callbacks_E");
      E281 : Boolean; pragma Import (Ada, E281, "parameters_handling_E");
      E215 : Boolean; pragma Import (Ada, E215, "var_strings_E");

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
          (False, False, True, True, False, False, False, True, 
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
      E017 := True;
      System.Exception_Table'Elab_Body;
      E023 := True;
      Ada.Io_Exceptions'Elab_Spec;
      E072 := True;
      Ada.Strings'Elab_Spec;
      E218 := True;
      Ada.Tags'Elab_Spec;
      Ada.Streams'Elab_Spec;
      E065 := True;
      Interfaces.C'Elab_Spec;
      E078 := True;
      Interfaces.C.Strings'Elab_Spec;
      E080 := True;
      System.Finalization_Root'Elab_Spec;
      E064 := True;
      Ada.Strings.Maps'Elab_Spec;
      E220 := True;
      Ada.Strings.Maps.Constants'Elab_Spec;
      E223 := True;
      System.Finalization_Implementation'Elab_Spec;
      System.Finalization_Implementation'Elab_Body;
      E067 := True;
      Ada.Finalization'Elab_Spec;
      E062 := True;
      Ada.Finalization.List_Controller'Elab_Spec;
      E060 := True;
      Ada.Strings.Unbounded'Elab_Spec;
      E241 := True;
      System.File_Control_Block'Elab_Spec;
      E233 := True;
      System.File_Io'Elab_Body;
      E230 := True;
      Ada.Text_Io'Elab_Spec;
      Ada.Text_Io'Elab_Body;
      E225 := True;
      Ada.Tags'Elab_Body;
      E005 := True;
      Glib'Elab_Spec;
      E076 := True;
      E297 := True;
      E128 := True;
      E105 := True;
      Gdk.Visual'Elab_Body;
      E111 := True;
      E089 := True;
      Glib.Values'Elab_Body;
      E095 := True;
      E185 := True;
      Gtkada.Types'Elab_Spec;
      E087 := True;
      Glib.Object'Elab_Spec;
      Gdk.Color'Elab_Spec;
      E138 := True;
      Glib.Generic_Properties'Elab_Body;
      E097 := True;
      E084 := True;
      E082 := True;
      E109 := True;
      E143 := True;
      Gdk.Event'Elab_Spec;
      E140 := True;
      E134 := True;
      E153 := True;
      E093 := True;
      E103 := True;
      Gtk.Object'Elab_Spec;
      E161 := True;
      Gtk.Accel_Group'Elab_Spec;
      Gtk.Accel_Group'Elab_Body;
      E159 := True;
      Gtk.Adjustment'Elab_Spec;
      E163 := True;
      Gtkada.Pixmaps'Elab_Spec;
      E313 := True;
      List_Exceptions'Elab_Spec;
      E277 := True;
      E276 := True;
      Mast'Elab_Spec;
      MAST.TOOL_EXCEPTIONS'ELAB_SPEC;
      E265 := True;
      Mast.Hopa_Parameters'Elab_Body;
      E267 := True;
      Mast.Annealing_Parameters'Elab_Body;
      E239 := True;
      Mast_Analysis_Pixmaps'Elab_Spec;
      E312 := True;
      E124 := True;
      E130 := True;
      Pango.Font'Elab_Spec;
      E116 := True;
      E151 := True;
      E149 := True;
      E165 := True;
      Pango.Context'Elab_Spec;
      E114 := True;
      E132 := True;
      Pango.Layout'Elab_Spec;
      E126 := True;
      E147 := True;
      E155 := True;
      E145 := True;
      Gtk.Icon_Factory'Elab_Spec;
      E299 := True;
      Gtk.Widget'Elab_Spec;
      E107 := True;
      E136 := True;
      E183 := True;
      Gtk.Container'Elab_Spec;
      E101 := True;
      Gtk.Bin'Elab_Spec;
      E099 := True;
      Gtk.Alignment'Elab_Spec;
      E190 := True;
      Gtk.Box'Elab_Spec;
      E192 := True;
      Gtk.Button'Elab_Spec;
      Gtk.Button'Elab_Body;
      E091 := True;
      Gtk.Editable'Elab_Spec;
      E173 := True;
      Gtk.Frame'Elab_Spec;
      E293 := True;
      Gtk.Gentry'Elab_Spec;
      Gtk.Gentry'Elab_Body;
      E171 := True;
      Gtk.Item'Elab_Spec;
      Gtk.Item'Elab_Body;
      E326 := True;
      Gtk.List'Elab_Spec;
      E328 := True;
      Gtk.List_Item'Elab_Spec;
      Gtk.List_Item'Elab_Body;
      E330 := True;
      E177 := True;
      Gtk.Misc'Elab_Spec;
      E196 := True;
      Gtk.Image'Elab_Spec;
      E295 := True;
      Gtk.Label'Elab_Spec;
      Gtk.Label'Elab_Body;
      E194 := True;
      Gtk.Notebook'Elab_Spec;
      E179 := True;
      Gtk.Old_Editable'Elab_Spec;
      E210 := True;
      Gtk.Scrolled_Window'Elab_Spec;
      E206 := True;
      Gtk.Table'Elab_Spec;
      E301 := True;
      Gtk.Text'Elab_Spec;
      E208 := True;
      Gtk.Toggle_Button'Elab_Spec;
      E169 := True;
      Gtk.Check_Button'Elab_Spec;
      E167 := True;
      Callbacks_Gmast_Analysis'Elab_Spec;
      E058 := True;
      Gtk.Window'Elab_Spec;
      Gtk.Window'Elab_Body;
      E198 := True;
      Annealing_Window_Pkg'Elab_Spec;
      Error_Inputfile_Pkg'Elab_Spec;
      E305 := True;
      Error_Window_Pkg'Elab_Spec;
      E181 := True;
      Gtk.Combo'Elab_Spec;
      E324 := True;
      Gtk.Dialog'Elab_Spec;
      E336 := True;
      Gtk.File_Selection'Elab_Spec;
      E334 := True;
      Fileselection1_Pkg'Elab_Spec;
      Gtk.Pixmap'Elab_Spec;
      Gtk.Pixmap'Elab_Body;
      E332 := True;
      Gtkada.Handlers'Elab_Spec;
      E188 := True;
      E307 := True;
      E057 := True;
      E303 := True;
      E053 := True;
      Help_Annealing_Pkg'Elab_Spec;
      E204 := True;
      E200 := True;
      Help_Hopa_Pkg'Elab_Spec;
      E291 := True;
      E289 := True;
      Help_Pkg'Elab_Spec;
      E322 := True;
      E320 := True;
      Hopa_Window_Pkg'Elab_Spec;
      E283 := True;
      Mast_Analysis_Pkg'Elab_Spec;
      E309 := True;
      E311 := True;
      E287 := True;
      E055 := True;
      Var_Strings'Elab_Spec;
      E215 := True;
      E281 := True;
      MAST.TOOL_EXCEPTIONS'ELAB_BODY;
      E247 := True;
      Mast'Elab_Body;
      E212 := True;
      E315 := True;
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
      pragma Import (Ada, Ada_Main_Program, "_ada_gmast_analysis");

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
   --   ./gmast_analysis_intl.o
   --   ../../mast_analysis/list_exceptions.o
   --   ../../mast_analysis/dynamic_lists.o
   --   ./mast-priority_assignment_parameters.o
   --   ../../mast_analysis/mast-hopa_parameters.o
   --   ../../mast_analysis/mast-annealing_parameters.o
   --   ./mast_analysis_pixmaps.o
   --   ./callbacks_gmast_analysis.o
   --   ./error_inputfile_pkg-callbacks.o
   --   ./error_window_pkg-callbacks.o
   --   ./fileselection1_pkg.o
   --   ./error_window_pkg.o
   --   ./error_inputfile_pkg.o
   --   ./annealing_window_pkg.o
   --   ./help_annealing_pkg-callbacks.o
   --   ./help_annealing_pkg.o
   --   ./help_hopa_pkg-callbacks.o
   --   ./help_hopa_pkg.o
   --   ./help_pkg-callbacks.o
   --   ./help_pkg.o
   --   ./hopa_window_pkg.o
   --   ./fileselection1_pkg-callbacks.o
   --   ./mast_analysis_pkg.o
   --   ./hopa_window_pkg-callbacks.o
   --   ./annealing_window_pkg-callbacks.o
   --   ../../mast_analysis/var_strings.o
   --   ./parameters_handling.o
   --   ../../mast_analysis/mast-tool_exceptions.o
   --   ../../mast_analysis/mast.o
   --   ./check_spaces.o
   --   ./mast_analysis_pkg-callbacks.o
   --   ./read_past_values.o
   --   ./gmast_analysis.o
   --   -L./
   --   -L../../mast_analysis/
   --   -L../../utils/
   --   -L/home/mgh/gnat/gtkada/lib/gtkada/
   --   -L/home/mgh/gnat2007/lib/gcc/i686-pc-linux-gnu/4.1.3/adalib/
   --   -static
   --   -lgnat
--  END Object file/option list   

end ada_main;
