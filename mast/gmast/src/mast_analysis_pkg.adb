with Glib; use Glib;
with Gtk; use Gtk;
with Gdk.Types;       use Gdk.Types;
with Gtk.Widget;      use Gtk.Widget;
with Gtk.Enums;       use Gtk.Enums;
with Gtkada.Handlers; use Gtkada.Handlers;
with Callbacks_Gmast_Analysis; use Callbacks_Gmast_Analysis;
with Gmast_Analysis_Intl; use Gmast_Analysis_Intl;
with Mast_Analysis_Pkg.Callbacks; use Mast_Analysis_Pkg.Callbacks;
with Mast_Analysis_Pixmaps;

package body Mast_Analysis_Pkg is

procedure Gtk_New (Mast_Analysis : out Mast_Analysis_Access) is
begin
   Mast_Analysis := new Mast_Analysis_Record;
   Mast_Analysis_Pkg.Initialize (Mast_Analysis);
end Gtk_New;

procedure Initialize (Mast_Analysis : access Mast_Analysis_Record'Class) is
   pragma Suppress (All_Checks);
   Tool_Items : String_List.Glist;
   Prio_Assign_Technique_Items : String_List.Glist;
begin
   Gtk.Window.Initialize (Mast_Analysis, Window_Toplevel);
   Set_Title (Mast_Analysis, -"Mast_Analysis");
   Set_Policy (Mast_Analysis, False, True, False);
   Set_Position (Mast_Analysis, Win_Pos_None);
   Set_Modal (Mast_Analysis, False);
   Return_Callback.Connect
     (Mast_Analysis, "delete_event", On_Mast_Analysis_Delete_Event'Access);

   Gtk_New_Vbox (Mast_Analysis.Vbox1, False, 0);
   Add (Mast_Analysis, Mast_Analysis.Vbox1);

   Gtk_New_Hbox (Mast_Analysis.Hbox1, False, 0);
   Pack_Start (Mast_Analysis.Vbox1, Mast_Analysis.Hbox1, True, True, 0);

   Mast_Analysis.Pixmap1 := Create_Pixmap
      (Mast_Analysis_Pixmaps.Mast_Logo_str, Mast_Analysis);
   Set_Alignment (Mast_Analysis.Pixmap1, 0.5, 0.5);
   Set_Padding (Mast_Analysis.Pixmap1, 7, 0);
   Pack_Start (Mast_Analysis.Hbox1, Mast_Analysis.Pixmap1, False, False, 0);

   Gtk_New_Vbox (Mast_Analysis.Vbox2, False, 0);
   Pack_Start (Mast_Analysis.Hbox1, Mast_Analysis.Vbox2, True, True, 0);

   Mast_Analysis.Pixmap2 := Create_Pixmap (
         Mast_Analysis_Pixmaps.mast_name_str, Mast_Analysis);
   Set_Alignment (Mast_Analysis.Pixmap2, 0.5, 0.5);
   Set_Padding (Mast_Analysis.Pixmap2, 0, 0);
   Pack_Start (Mast_Analysis.Vbox2, Mast_Analysis.Pixmap2, True, False, 0);

   Gtk_New (Mast_Analysis.Title_2, -("Modelling and Analysis Suite for Real-Time Applications"));
   Set_Alignment (Mast_Analysis.Title_2, 0.5, 0.5);
   Set_Padding (Mast_Analysis.Title_2, 0, 0);
   Set_Justify (Mast_Analysis.Title_2, Justify_Center);
   Set_Line_Wrap (Mast_Analysis.Title_2, False);
   Pack_Start (Mast_Analysis.Vbox2, Mast_Analysis.Title_2, True, True, 0);

   Gtk_New_Hbox (Mast_Analysis.Hbox3, False, 0);
   Pack_Start (Mast_Analysis.Vbox1, Mast_Analysis.Hbox3, True, True, 0);

   Gtk_New (Mast_Analysis.Table1, 4, 3, False);
   Set_Border_Width (Mast_Analysis.Table1, 15);
   Set_Row_Spacings (Mast_Analysis.Table1, 0);
   Set_Col_Spacings (Mast_Analysis.Table1, 0);
   Pack_Start (Mast_Analysis.Hbox3, Mast_Analysis.Table1, True, True, 0);

   Gtk_New (Mast_Analysis.Label6, -("Tool"));
   Set_Alignment (Mast_Analysis.Label6, 0.78, 0.5);
   Set_Padding (Mast_Analysis.Label6, 0, 0);
   Set_Justify (Mast_Analysis.Label6, Justify_Right);
   Set_Line_Wrap (Mast_Analysis.Label6, False);
   Attach (Mast_Analysis.Table1, Mast_Analysis.Label6, 0, 1, 0, 1,
     Fill, 0,
     0, 0);

   Gtk_New (Mast_Analysis.Label8, -("Results File  "));
   Set_Alignment (Mast_Analysis.Label8, 0.8, 0.5);
   Set_Padding (Mast_Analysis.Label8, 0, 0);
   Set_Justify (Mast_Analysis.Label8, Justify_Right);
   Set_Line_Wrap (Mast_Analysis.Label8, False);
   Attach (Mast_Analysis.Table1, Mast_Analysis.Label8, 0, 1, 3, 4,
     0, 0,
     0, 0);

   Gtk_New (Mast_Analysis.Output_File);
   Set_Editable (Mast_Analysis.Output_File, True);
   Set_Max_Length (Mast_Analysis.Output_File, 0);
   Set_Text (Mast_Analysis.Output_File, -"");
   Set_Visibility (Mast_Analysis.Output_File, True);
   Attach (Mast_Analysis.Table1, Mast_Analysis.Output_File, 1, 2, 3, 4,
     Expand or Fill, 0,
     0, 0);
   Entry_Callback.Connect
     (Mast_Analysis.Output_File, "changed",
      Entry_Callback.To_Marshaller (On_Output_File_Changed'Access));

   Gtk_New (Mast_Analysis.Label7, -("Input File"));
   Set_Alignment (Mast_Analysis.Label7, 0.9, 0.5);
   Set_Padding (Mast_Analysis.Label7, 0, 0);
   Set_Justify (Mast_Analysis.Label7, Justify_Right);
   Set_Line_Wrap (Mast_Analysis.Label7, False);
   Attach (Mast_Analysis.Table1, Mast_Analysis.Label7, 0, 1, 2, 3,
     0, 0,
     0, 0);

   Gtk_New_Hbox (Mast_Analysis.Hbox6, False, 0);
   Attach (Mast_Analysis.Table1, Mast_Analysis.Hbox6, 1, 2, 2, 3,
     Fill, Fill,
     0, 0);

   Gtk_New_Vbox (Mast_Analysis.Vbox5, False, 0);
   Pack_Start (Mast_Analysis.Hbox6, Mast_Analysis.Vbox5, True, True, 0);

   Gtk_New (Mast_Analysis.Input_File);
   Set_Editable (Mast_Analysis.Input_File, True);
   Set_Max_Length (Mast_Analysis.Input_File, 0);
   Set_Text (Mast_Analysis.Input_File, -"");
   Set_Visibility (Mast_Analysis.Input_File, True);
   Pack_Start (Mast_Analysis.Vbox5, Mast_Analysis.Input_File, False, False, 0);

   Gtk_New (Mast_Analysis.Label12, -("Directory"));
   Set_Alignment (Mast_Analysis.Label12, 0.9, 0.5);
   Set_Padding (Mast_Analysis.Label12, 0, 0);
   Set_Justify (Mast_Analysis.Label12, Justify_Right);
   Set_Line_Wrap (Mast_Analysis.Label12, False);
   Attach (Mast_Analysis.Table1, Mast_Analysis.Label12, 0, 1, 1, 2,
     0, 0,
     0, 0);

   Gtk_New_Hbox (Mast_Analysis.Hbox8, False, 0);
   Attach (Mast_Analysis.Table1, Mast_Analysis.Hbox8, 2, 3, 3, 4,
     Fill, Fill,
     0, 0);

   Gtk_New (Mast_Analysis.Default, -"Default");
   Set_Relief (Mast_Analysis.Default, Relief_Normal);
   Pack_Start (Mast_Analysis.Hbox8, Mast_Analysis.Default, False, False, 0);
   Button_Callback.Connect
     (Mast_Analysis.Default, "clicked",
      Button_Callback.To_Marshaller (On_Default_Clicked'Access));

   Gtk_New (Mast_Analysis.Blank, -"Blank");
   Set_Relief (Mast_Analysis.Blank, Relief_Normal);
   Pack_Start (Mast_Analysis.Hbox8, Mast_Analysis.Blank, False, False, 0);
   Button_Callback.Connect
     (Mast_Analysis.Blank, "clicked",
      Button_Callback.To_Marshaller (On_Blank_Clicked'Access));

   Gtk_New (Mast_Analysis.Input_File_Selection, -"File...");
   Set_Relief (Mast_Analysis.Input_File_Selection, Relief_Normal);
   Attach (Mast_Analysis.Table1, Mast_Analysis.Input_File_Selection, 2, 3, 2, 3,
     Fill, 0,
     0, 0);
   Button_Callback.Connect
     (Mast_Analysis.Input_File_Selection, "clicked",
      Button_Callback.To_Marshaller (On_Input_File_Selection_Clicked'Access));

   Gtk_New (Mast_Analysis.Directory_Entry);
   Set_Editable (Mast_Analysis.Directory_Entry, True);
   Set_Max_Length (Mast_Analysis.Directory_Entry, 0);
   Set_Text (Mast_Analysis.Directory_Entry, -"");
   Set_Visibility (Mast_Analysis.Directory_Entry, True);
   Attach (Mast_Analysis.Table1, Mast_Analysis.Directory_Entry, 1, 2, 1, 2,
     Expand or Fill, 0,
     0, 0);

   Gtk_New (Mast_Analysis.Tool);
   Set_Value_In_List (Mast_Analysis.Tool, False);
   Set_Use_Arrows (Mast_Analysis.Tool, True);
   Set_Case_Sensitive (Mast_Analysis.Tool, False);
   Set_Editable (Get_Entry (Mast_Analysis.Tool), True);
   Set_Has_Frame (Get_Entry (Mast_Analysis.Tool), True);
   Set_Max_Length (Get_Entry (Mast_Analysis.Tool), 0);
   Set_Text (Get_Entry (Mast_Analysis.Tool), -(""));
   Set_Invisible_Char (Get_Entry (Mast_Analysis.Tool), UTF8_Get_Char ("*"));
   Set_Has_Frame (Get_Entry (Mast_Analysis.Tool), True);
   Entry_Callback.Connect
     (Get_Entry (Mast_Analysis.Tool), "changed",
      Entry_Callback.To_Marshaller (On_Tool_Entry_Changed'Access), False);
   String_List.Append (Tool_Items, -(""));
   String_List.Append (Tool_Items, -("Offset_Based_Optimized"));
   String_List.Append (Tool_Items, -("Offset_Based"));
   String_List.Append (Tool_Items, -("Holistic"));
   String_List.Append (Tool_Items, -("EDF_Within_Priorities"));
   String_List.Append (Tool_Items, -("EDF_Monoprocessor"));
   String_List.Append (Tool_Items, -("Varying_Priorities"));
   String_List.Append (Tool_Items, -("Classic_RM"));
   String_List.Append (Tool_Items, -("Parse"));
   Combo.Set_Popdown_Strings (Mast_Analysis.Tool, Tool_Items);
   Free_String_List (Tool_Items);
   Attach
     (Mast_Analysis.Table1,
       Mast_Analysis.Tool,      Left_Attach  => 1,
      Right_Attach  => 2,
      Top_Attach  => 0,
      Bottom_Attach  => 1,
      Xpadding  => 0,
      Ypadding  => 0);


   Gtk_New (Mast_Analysis.Frame1);
   Set_Border_Width (Mast_Analysis.Frame1, 3);
   Set_Shadow_Type (Mast_Analysis.Frame1, Shadow_Etched_In);
   Pack_Start (Mast_Analysis.Hbox3, Mast_Analysis.Frame1, True, True, 0);

   Gtk_New_Vbox (Mast_Analysis.Vbox3, False, 0);
   Add (Mast_Analysis.Frame1, Mast_Analysis.Vbox3);

   Gtk_New (Mast_Analysis.Label9, -("Options"));
   Set_Alignment (Mast_Analysis.Label9, 0.1, 0.5);
   Set_Padding (Mast_Analysis.Label9, 0, 0);
   Set_Justify (Mast_Analysis.Label9, Justify_Right);
   Set_Line_Wrap (Mast_Analysis.Label9, False);
   Pack_Start (Mast_Analysis.Vbox3, Mast_Analysis.Label9, False, False, 0);

   Gtk_New (Mast_Analysis.Table2, 7, 2, False);
   Set_Row_Spacings (Mast_Analysis.Table2, 0);
   Set_Col_Spacings (Mast_Analysis.Table2, 0);
   Pack_Start (Mast_Analysis.Vbox3, Mast_Analysis.Table2, True, True, 0);

   Gtk_New (Mast_Analysis.Verbose, -"Verbose");
   Set_Active (Mast_Analysis.Verbose, False);
   Attach (Mast_Analysis.Table2, Mast_Analysis.Verbose, 0, 1, 0, 1,
     Fill, 0,
     0, 0);

   Gtk_New (Mast_Analysis.Ceilings, -("Calc. Ceilings & Levels"));
   Set_Relief (Mast_Analysis.Ceilings, Relief_Normal);
   Set_Active (Mast_Analysis.Ceilings, False);
   Attach (Mast_Analysis.Table2, Mast_Analysis.Ceilings, 0, 1, 1, 2,
     Fill, 0,
     0, 0);
   Check_Button_Callback.Connect
     (Mast_Analysis.Ceilings, "toggled",
      Check_Button_Callback.To_Marshaller (On_Ceilings_Toggled'Access));

   Gtk_New (Mast_Analysis.Priorities, -("Assign Parameters"));
   Set_Relief (Mast_Analysis.Priorities, Relief_Normal);
   Set_Active (Mast_Analysis.Priorities, False);
   Attach (Mast_Analysis.Table2, Mast_Analysis.Priorities, 0, 1, 2, 3,
     Fill, 0,
     0, 0);
   Check_Button_Callback.Connect
     (Mast_Analysis.Priorities, "toggled",
      Check_Button_Callback.To_Marshaller (On_Priorities_Toggled'Access));

   Gtk_New_Hbox (Mast_Analysis.Hbox5, False, 0);
   Attach (Mast_Analysis.Table2, Mast_Analysis.Hbox5, 1, 2, 2, 3,
     Expand or Fill, Fill,
     0, 0);

   Gtk_New (Mast_Analysis.Label10, -("Technique"));
   Set_Alignment (Mast_Analysis.Label10, 0.5, 0.5);
   Set_Padding (Mast_Analysis.Label10, 0, 0);
   Set_Justify (Mast_Analysis.Label10, Justify_Center);
   Set_Line_Wrap (Mast_Analysis.Label10, False);
   Pack_Start (Mast_Analysis.Hbox5, Mast_Analysis.Label10, False, False, 0);

   Gtk_New (Mast_Analysis.Prio_Assign_Technique);
   Set_Case_Sensitive (Mast_Analysis.Prio_Assign_Technique, False);
   Set_Use_Arrows (Mast_Analysis.Prio_Assign_Technique, True);
   Set_Case_Sensitive (Mast_Analysis.Prio_Assign_Technique, False);
   Set_Editable (Get_Entry (Mast_Analysis.Prio_Assign_Technique), True);
   Set_Has_Frame (Get_Entry (Mast_Analysis.Prio_Assign_Technique), True);
   Set_Max_Length (Get_Entry (Mast_Analysis.Prio_Assign_Technique), 0);
   Set_Text (Get_Entry (Mast_Analysis.Prio_Assign_Technique), -(""));
   Set_Invisible_Char (Get_Entry (Mast_Analysis.Prio_Assign_Technique), UTF8_Get_Char ("*"));
   Set_Has_Frame (Get_Entry (Mast_Analysis.Prio_Assign_Technique), True);
   Entry_Callback.Connect
     (Get_Entry (Mast_Analysis.Prio_Assign_Technique), "changed",
      Entry_Callback.To_Marshaller (On_Technique_Entry_Changed'Access), False);
   String_List.Append (Prio_Assign_Technique_Items, -("Default"));
   String_List.Append (Prio_Assign_Technique_Items, -("Monoprocessor"));
   String_List.Append (Prio_Assign_Technique_Items, -("Deadline_Distribution"));
   String_List.Append (Prio_Assign_Technique_Items, -("HOPA"));
   String_List.Append (Prio_Assign_Technique_Items, -("Annealing"));
   Combo.Set_Popdown_Strings (Mast_Analysis.Prio_Assign_Technique, Prio_Assign_Technique_Items);
   Free_String_List (Prio_Assign_Technique_Items);

   Pack_Start
     (Mast_Analysis.Hbox5,
      Mast_Analysis.Prio_Assign_Technique,
      Expand  => True,
      Fill    => True,
      Padding => 0);

   Gtk_New (Mast_Analysis.Destination_File);
   Set_Editable (Mast_Analysis.Destination_File, True);
   Set_Max_Length (Mast_Analysis.Destination_File, 0);
   Set_Text (Mast_Analysis.Destination_File, -"");
   Set_Visibility (Mast_Analysis.Destination_File, True);
   Attach (Mast_Analysis.Table2, Mast_Analysis.Destination_File, 1, 2, 3, 4,
     Expand or Fill, 0,
     0, 0);
   Entry_Callback.Connect
     (Mast_Analysis.Destination_File, "changed",
      Entry_Callback.To_Marshaller (On_Destination_File_Changed'Access));

   Gtk_New (Mast_Analysis.Operation_Name);
   Set_Editable (Mast_Analysis.Operation_Name, True);
   Set_Max_Length (Mast_Analysis.Operation_Name, 0);
   Set_Text (Mast_Analysis.Operation_Name, -"");
   Set_Visibility (Mast_Analysis.Operation_Name, True);
   Attach (Mast_Analysis.Table2, Mast_Analysis.Operation_Name, 1, 2, 5, 6,
     Expand or Fill, 0,
     0, 0);
   Entry_Callback.Connect
     (Mast_Analysis.Operation_Name, "changed",
      Entry_Callback.To_Marshaller (On_Operation_Name_Changed'Access));

   Gtk_New (Mast_Analysis.Destination, -"Source Dest. File");
   Set_Active (Mast_Analysis.Destination, False);
   Attach (Mast_Analysis.Table2, Mast_Analysis.Destination, 0, 1, 3, 4,
     Fill, 0,
     0, 0);

   Gtk_New (Mast_Analysis.Slacks, -"Calculate Slacks");
   Set_Active (Mast_Analysis.Slacks, False);
   Attach (Mast_Analysis.Table2, Mast_Analysis.Slacks, 0, 1, 4, 5,
     Fill, 0,
     0, 0);

   Gtk_New (Mast_Analysis.Operation_Slack, -"Calc. Operation Slack");
   Set_Active (Mast_Analysis.Operation_Slack, False);
   Attach (Mast_Analysis.Table2, Mast_Analysis.Operation_Slack, 0, 1, 5, 6,
     Fill, 0,
     0, 0);

   Gtk_New (Mast_Analysis.View_Results, -"View Results");
   Set_Active (Mast_Analysis.View_Results, False);
   Attach (Mast_Analysis.Table2, Mast_Analysis.View_Results, 0, 1, 6, 7,
     Fill, 0,
     0, 0);

   Gtk_New
     (Mast_Analysis.Alignment3, 0.5, 0.5, 1.0,
      1.0);
   Add (Mast_Analysis.Vbox1, Mast_Analysis.Alignment3);

   Gtk_New_Hbox (Mast_Analysis.Hbox2, False, 220);
   Set_Border_Width (Mast_Analysis.Hbox2, 10);
   Add (Mast_Analysis.Alignment3, Mast_Analysis.Hbox2);

   Gtk_New
     (Mast_Analysis.Alignment1, 0.0, 0.5, 1.0,
      1.0);
   Pack_Start (Mast_Analysis.Hbox2, Mast_Analysis.Alignment1, False, False, 0);

   Gtk_New_Hbox (Mast_Analysis.Hbox12, False, 0);
   Add (Mast_Analysis.Alignment1, Mast_Analysis.Hbox12);

   Gtk_New (Mast_Analysis.Go_Button);
   Set_Border_Width (Mast_Analysis.Go_Button, 4);
   Set_Relief (Mast_Analysis.Go_Button, Relief_Normal);
   Pack_Start (Mast_Analysis.Hbox12, Mast_Analysis.Go_Button, False, False, 0);
   Button_Callback.Connect
     (Mast_Analysis.Go_Button, "clicked",
      Button_Callback.To_Marshaller (On_Go_Button_Clicked'Access));

   Gtk_New
     (Mast_Analysis.Alignment19, 0.5, 0.5, 0.0,
      0.0);
   Add (Mast_Analysis.Go_Button, Mast_Analysis.Alignment19);

   Gtk_New_Hbox (Mast_Analysis.Hbox19, False, 2);
   Add (Mast_Analysis.Alignment19, Mast_Analysis.Hbox19);

   Gtk_New (Mast_Analysis.Image5 , "gtk-apply", Gtk_Icon_Size'Val (4));
   Set_Alignment (Mast_Analysis.Image5, 0.5, 0.5);
   Set_Padding (Mast_Analysis.Image5, 0, 0);
   Pack_Start
     (Mast_Analysis.Hbox19,
      Mast_Analysis.Image5,
      Expand  => False,
      Fill    => False,
      Padding => 0);

   Gtk_New (Mast_Analysis.Label35, -("GO"));
   Set_Alignment (Mast_Analysis.Label35, 0.5, 0.5);
   Set_Padding (Mast_Analysis.Label35, 0, 0);
   Set_Justify (Mast_Analysis.Label35, Justify_Left);
   Set_Line_Wrap (Mast_Analysis.Label35, False);
   Set_Selectable (Mast_Analysis.Label35, False);
   Set_Use_Markup (Mast_Analysis.Label35, False);
   Set_Use_Underline (Mast_Analysis.Label35, True);
   Pack_Start
     (Mast_Analysis.Hbox19,
      Mast_Analysis.Label35,
      Expand  => False,
      Fill    => False,
      Padding => 0);

   Gtk_New_From_Stock (Mast_Analysis.Cancel_Button, "gtk-cancel");
   Set_Border_Width (Mast_Analysis.Cancel_Button, 4);
   Set_Relief (Mast_Analysis.Cancel_Button, Relief_Normal);
   Pack_Start (Mast_Analysis.Hbox12, Mast_Analysis.Cancel_Button, False, False, 0);
   Button_Callback.Connect
     (Mast_Analysis.Cancel_Button, "clicked",
      Button_Callback.To_Marshaller (Gtk_Main_Quit'Access));

   Gtk_New
     (Mast_Analysis.Alignment2, 1.0, 0.5, 1.0,
      1.0);
   Add (Mast_Analysis.Hbox2, Mast_Analysis.Alignment2);

   Gtk_New_Hbox (Mast_Analysis.Hbox11, False, 0);
   Add (Mast_Analysis.Alignment2, Mast_Analysis.Hbox11);

   Gtk_New (Mast_Analysis.Hopa_Params);
   Set_Border_Width (Mast_Analysis.Hopa_Params, 4);
   Set_Relief (Mast_Analysis.Hopa_Params, Relief_Normal);
   Pack_Start (Mast_Analysis.Hbox11, Mast_Analysis.Hopa_Params, False, False, 0);
   Button_Callback.Connect
     (Mast_Analysis.Hopa_Params, "clicked",
      Button_Callback.To_Marshaller (On_Hopa_Params_Clicked'Access));

   Gtk_New
     (Mast_Analysis.Alignment20, 0.5, 0.5, 0.0,
      0.0);
   Add (Mast_Analysis.Hopa_Params, Mast_Analysis.Alignment20);

   Gtk_New_Hbox (Mast_Analysis.Hbox20, False, 2);
   Add (Mast_Analysis.Alignment20, Mast_Analysis.Hbox20);

   Gtk_New (Mast_Analysis.Image6 , "gtk-justify-fill", Gtk_Icon_Size'Val (4));
   Set_Alignment (Mast_Analysis.Image6, 0.5, 0.5);
   Set_Padding (Mast_Analysis.Image6, 0, 0);
   Pack_Start
     (Mast_Analysis.Hbox20,
      Mast_Analysis.Image6,
      Expand  => False,
      Fill    => False,
      Padding => 0);

   Gtk_New (Mast_Analysis.Label36, -("HOPA Parameters"));
   Set_Alignment (Mast_Analysis.Label36, 0.5, 0.5);
   Set_Padding (Mast_Analysis.Label36, 0, 0);
   Set_Justify (Mast_Analysis.Label36, Justify_Left);
   Set_Line_Wrap (Mast_Analysis.Label36, False);
   Set_Selectable (Mast_Analysis.Label36, False);
   Set_Use_Markup (Mast_Analysis.Label36, False);
   Set_Use_Underline (Mast_Analysis.Label36, True);
   Pack_Start
     (Mast_Analysis.Hbox20,
      Mast_Analysis.Label36,
      Expand  => False,
      Fill    => False,
      Padding => 0);

   Gtk_New (Mast_Analysis.Annealing_Params);
   Set_Border_Width (Mast_Analysis.Annealing_Params, 4);
   Set_Relief (Mast_Analysis.Annealing_Params, Relief_Normal);
   Pack_Start (Mast_Analysis.Hbox11, Mast_Analysis.Annealing_Params, False, False, 0);
   Button_Callback.Connect
     (Mast_Analysis.Annealing_Params, "clicked",
      Button_Callback.To_Marshaller (On_Annealing_Params_Clicked'Access));

   Gtk_New
     (Mast_Analysis.Alignment21, 0.5, 0.5, 0.0,
      0.0);
   Add (Mast_Analysis.Annealing_Params, Mast_Analysis.Alignment21);

   Gtk_New_Hbox (Mast_Analysis.Hbox21, False, 2);
   Add (Mast_Analysis.Alignment21, Mast_Analysis.Hbox21);

   Gtk_New (Mast_Analysis.Image7 , "gtk-justify-fill", Gtk_Icon_Size'Val (4));
   Set_Alignment (Mast_Analysis.Image7, 0.5, 0.5);
   Set_Padding (Mast_Analysis.Image7, 0, 0);
   Pack_Start
     (Mast_Analysis.Hbox21,
      Mast_Analysis.Image7,
      Expand  => False,
      Fill    => False,
      Padding => 0);

   Gtk_New (Mast_Analysis.Label37, -("Annealing Parameters"));
   Set_Alignment (Mast_Analysis.Label37, 0.5, 0.5);
   Set_Padding (Mast_Analysis.Label37, 0, 0);
   Set_Justify (Mast_Analysis.Label37, Justify_Left);
   Set_Line_Wrap (Mast_Analysis.Label37, False);
   Set_Selectable (Mast_Analysis.Label37, False);
   Set_Use_Markup (Mast_Analysis.Label37, False);
   Set_Use_Underline (Mast_Analysis.Label37, True);
   Pack_Start
     (Mast_Analysis.Hbox21,
      Mast_Analysis.Label37,
      Expand  => False,
      Fill    => False,
      Padding => 0);

   Gtk_New_From_Stock (Mast_Analysis.Help_Button, "gtk-help");
   Set_Border_Width (Mast_Analysis.Help_Button, 4);
   Set_Relief (Mast_Analysis.Help_Button, Relief_Normal);
   Pack_Start (Mast_Analysis.Hbox11, Mast_Analysis.Help_Button, False, False, 0);
   Button_Callback.Connect
     (Mast_Analysis.Help_Button, "clicked",
      Button_Callback.To_Marshaller (On_Help_Button_Clicked'Access));

end Initialize;

end Mast_Analysis_Pkg;
