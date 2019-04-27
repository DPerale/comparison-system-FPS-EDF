with Glib; use Glib;
with Glib.Unicode; use Glib.Unicode;
with Gtk; use Gtk;
with Gdk.Types;       use Gdk.Types;
with Gtk.Widget;      use Gtk.Widget;
with Gtk.Enums;       use Gtk.Enums;
with Gtkada.Handlers; use Gtkada.Handlers;
with Callbacks_Gmast_Analysis; use Callbacks_Gmast_Analysis;
with Gmast_Analysis_Intl; use Gmast_Analysis_Intl;
with Annealing_Window_Pkg.Callbacks; use Annealing_Window_Pkg.Callbacks;

package body Annealing_Window_Pkg is

procedure Gtk_New (Annealing_Window : out Annealing_Window_Access) is
begin
   Annealing_Window := new Annealing_Window_Record;
   Annealing_Window_Pkg.Initialize (Annealing_Window);
end Gtk_New;

procedure Initialize (Annealing_Window : access Annealing_Window_Record'Class) is
   pragma Suppress (All_Checks);
begin
   Gtk.Window.Initialize (Annealing_Window,Window_TopLevel);
   Set_Title (Annealing_Window, -"Annealing Parameters");
   Set_Policy (Annealing_Window, False, True, False);
   Set_Position (Annealing_Window, Win_Pos_None);
   Set_Modal (Annealing_Window, True);

   Gtk_New_Vbox (Annealing_Window.Vbox8, False, 0);
   Add (Annealing_Window, Annealing_Window.Vbox8);

   Gtk_New (Annealing_Window.Label14, -("Simulated Annealing Parameters"));
   Set_Alignment (Annealing_Window.Label14, 0.5, 0.5);
   Set_Padding (Annealing_Window.Label14, 0, 0);
   Set_Justify (Annealing_Window.Label14, Justify_Center);
   Set_Line_Wrap (Annealing_Window.Label14, False);
   Pack_Start (Annealing_Window.Vbox8, Annealing_Window.Label14, False, False, 5);

   Gtk_New (Annealing_Window.Frame2);
   Set_Border_Width (Annealing_Window.Frame2, 15);
   Set_Shadow_Type (Annealing_Window.Frame2, Shadow_Etched_In);
   Pack_Start (Annealing_Window.Vbox8, Annealing_Window.Frame2, True, True, 0);

   Gtk_New (Annealing_Window.Table3, 4, 2, False);
   Set_Row_Spacings (Annealing_Window.Table3, 0);
   Set_Col_Spacings (Annealing_Window.Table3, 0);
   Add (Annealing_Window.Frame2, Annealing_Window.Table3);

   Gtk_New (Annealing_Window.Entry_Max_Iterations);
   Set_Editable (Annealing_Window.Entry_Max_Iterations, True);
   Set_Max_Length (Annealing_Window.Entry_Max_Iterations, 0);
   Set_Text (Annealing_Window.Entry_Max_Iterations, -"");
   Set_Visibility (Annealing_Window.Entry_Max_Iterations, True);
   Attach (Annealing_Window.Table3, Annealing_Window.Entry_Max_Iterations, 1, 2, 0, 1,
     Expand or Fill, 0,
     0, 0);

   Gtk_New (Annealing_Window.Entry_Iterations_To_Op);
   Set_Editable (Annealing_Window.Entry_Iterations_To_Op, True);
   Set_Max_Length (Annealing_Window.Entry_Iterations_To_Op, 0);
   Set_Text (Annealing_Window.Entry_Iterations_To_Op, -"");
   Set_Visibility (Annealing_Window.Entry_Iterations_To_Op, True);
   Attach (Annealing_Window.Table3, Annealing_Window.Entry_Iterations_To_Op, 1, 2, 1, 2,
     Expand or Fill, 0,
     0, 0);

   Gtk_New
     (Annealing_Window.Alignment5, 0.5, 0.5, 1.0,
      1.0);
   Attach (Annealing_Window.Table3, Annealing_Window.Alignment5, 0, 1, 0, 1,
     Fill, Fill,
     0, 0);

   Gtk_New (Annealing_Window.Label15, -("Max Iterations"));
   Set_Alignment (Annealing_Window.Label15, 1.0, 0.5);
   Set_Padding (Annealing_Window.Label15, 0, 0);
   Set_Justify (Annealing_Window.Label15, Justify_Right);
   Set_Line_Wrap (Annealing_Window.Label15, False);
   Add (Annealing_Window.Alignment5, Annealing_Window.Label15);

   Gtk_New (Annealing_Window.Label16, -("Optimization Iterations"));
   Set_Alignment (Annealing_Window.Label16, 1.0, 0.5);
   Set_Padding (Annealing_Window.Label16, 0, 0);
   Set_Justify (Annealing_Window.Label16, Justify_Right);
   Set_Line_Wrap (Annealing_Window.Label16, False);
   Set_Selectable (Annealing_Window.Label16, False);
   Set_Use_Markup (Annealing_Window.Label16, False);
   Set_Use_Underline (Annealing_Window.Label16, False);
   Attach
     (Annealing_Window.Table3,
       Annealing_Window.Label16,      Left_Attach  => 0,
      Right_Attach  => 1,
      Top_Attach  => 1,
      Bottom_Attach  => 2,
      Xoptions  => Fill,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Annealing_Window.Label38, -("Analysis Stop Time"));
   Set_Alignment (Annealing_Window.Label38, 1.0, 0.5);
   Set_Padding (Annealing_Window.Label38, 0, 0);
   Set_Justify (Annealing_Window.Label38, Justify_Right);
   Set_Line_Wrap (Annealing_Window.Label38, False);
   Set_Selectable (Annealing_Window.Label38, False);
   Set_Use_Markup (Annealing_Window.Label38, False);
   Set_Use_Underline (Annealing_Window.Label38, False);
   Attach
     (Annealing_Window.Table3,
       Annealing_Window.Label38,      Left_Attach  => 0,
      Right_Attach  => 1,
      Top_Attach  => 2,
      Bottom_Attach  => 3,
      Xoptions  => Fill,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Annealing_Window.Label39, -("Audsley Stop Time"));
   Set_Alignment (Annealing_Window.Label39, 1.0, 0.5);
   Set_Padding (Annealing_Window.Label39, 0, 0);
   Set_Justify (Annealing_Window.Label39, Justify_Left);
   Set_Line_Wrap (Annealing_Window.Label39, False);
   Set_Selectable (Annealing_Window.Label39, False);
   Set_Use_Markup (Annealing_Window.Label39, False);
   Set_Use_Underline (Annealing_Window.Label39, False);
   Attach
     (Annealing_Window.Table3,
       Annealing_Window.Label39,      Left_Attach  => 0,
      Right_Attach  => 1,
      Top_Attach  => 3,
      Bottom_Attach  => 4,
      Xoptions  => Fill,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Annealing_Window.Entry_Stop_Analysis);
   Set_Editable (Annealing_Window.Entry_Stop_Analysis, True);
   Set_Max_Length (Annealing_Window.Entry_Stop_Analysis, 0);
   Set_Text (Annealing_Window.Entry_Stop_Analysis, -(""));
   Set_Visibility (Annealing_Window.Entry_Stop_Analysis, True);
   Set_Invisible_Char (Annealing_Window.Entry_Stop_Analysis, UTF8_Get_Char ("*"));
   Attach
     (Annealing_Window.Table3,
       Annealing_Window.Entry_Stop_Analysis,      Left_Attach  => 1,
      Right_Attach  => 2,
      Top_Attach  => 2,
      Bottom_Attach  => 3,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Annealing_Window.Entry_Stop_Audsley);
   Set_Editable (Annealing_Window.Entry_Stop_Audsley, True);
   Set_Max_Length (Annealing_Window.Entry_Stop_Audsley, 0);
   Set_Text (Annealing_Window.Entry_Stop_Audsley, -(""));
   Set_Visibility (Annealing_Window.Entry_Stop_Audsley, True);
   Set_Invisible_Char (Annealing_Window.Entry_Stop_Audsley, UTF8_Get_Char ("*"));
   Attach
     (Annealing_Window.Table3,
       Annealing_Window.Entry_Stop_Audsley,      Left_Attach  => 1,
      Right_Attach  => 2,
      Top_Attach  => 3,
      Bottom_Attach  => 4,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New_Hbox (Annealing_Window.Hbox13, True, 0);
   Set_Border_Width (Annealing_Window.Hbox13, 14);
   Pack_Start (Annealing_Window.Vbox8, Annealing_Window.Hbox13, True, True, 0);

   Gtk_New (Annealing_Window.Set_Button);
   Set_Relief (Annealing_Window.Set_Button, Relief_Normal);
   Pack_Start (Annealing_Window.Hbox13, Annealing_Window.Set_Button, False, False, 0);
   Button_Callback.Connect
     (Annealing_Window.Set_Button, "clicked",
      Button_Callback.To_Marshaller (On_Set_Button_Clicked'Access));

   Gtk_New
     (Annealing_Window.Alignment15, 0.5, 0.5, 0.0,
      0.0);
   Add (Annealing_Window.Set_Button, Annealing_Window.Alignment15);

   Gtk_New_Hbox (Annealing_Window.Hbox15, False, 2);
   Add (Annealing_Window.Alignment15, Annealing_Window.Hbox15);

   Gtk_New (Annealing_Window.Image1 , "gtk-apply", Gtk_Icon_Size'Val (4));
   Set_Alignment (Annealing_Window.Image1, 0.5, 0.5);
   Set_Padding (Annealing_Window.Image1, 0, 0);
   Pack_Start
     (Annealing_Window.Hbox15,
      Annealing_Window.Image1,
      Expand  => False,
      Fill    => False,
      Padding => 0);

   Gtk_New (Annealing_Window.Label31, -("Set"));
   Set_Alignment (Annealing_Window.Label31, 0.5, 0.5);
   Set_Padding (Annealing_Window.Label31, 0, 0);
   Set_Justify (Annealing_Window.Label31, Justify_Left);
   Set_Line_Wrap (Annealing_Window.Label31, False);
   Set_Selectable (Annealing_Window.Label31, False);
   Set_Use_Markup (Annealing_Window.Label31, False);
   Set_Use_Underline (Annealing_Window.Label31, True);
   Pack_Start
     (Annealing_Window.Hbox15,
      Annealing_Window.Label31,
      Expand  => False,
      Fill    => False,
      Padding => 0);

   Gtk_New (Annealing_Window.Default_Button);
   Set_Relief (Annealing_Window.Default_Button, Relief_Normal);
   Pack_Start (Annealing_Window.Hbox13, Annealing_Window.Default_Button, False, False, 0);
   Button_Callback.Connect
     (Annealing_Window.Default_Button, "clicked",
      Button_Callback.To_Marshaller (On_Default_Button_Clicked'Access));

   Gtk_New
     (Annealing_Window.Alignment16, 0.5, 0.5, 0.0,
      0.0);
   Add (Annealing_Window.Default_Button, Annealing_Window.Alignment16);

   Gtk_New_Hbox (Annealing_Window.Hbox16, False, 2);
   Add (Annealing_Window.Alignment16, Annealing_Window.Hbox16);

   Gtk_New (Annealing_Window.Image2 , "gtk-refresh", Gtk_Icon_Size'Val (4));
   Set_Alignment (Annealing_Window.Image2, 0.5, 0.5);
   Set_Padding (Annealing_Window.Image2, 0, 0);
   Pack_Start
     (Annealing_Window.Hbox16,
      Annealing_Window.Image2,
      Expand  => False,
      Fill    => False,
      Padding => 0);

   Gtk_New (Annealing_Window.Label32, -("Get Defaults"));
   Set_Alignment (Annealing_Window.Label32, 0.5, 0.5);
   Set_Padding (Annealing_Window.Label32, 0, 0);
   Set_Justify (Annealing_Window.Label32, Justify_Left);
   Set_Line_Wrap (Annealing_Window.Label32, False);
   Set_Selectable (Annealing_Window.Label32, False);
   Set_Use_Markup (Annealing_Window.Label32, False);
   Set_Use_Underline (Annealing_Window.Label32, True);
   Pack_Start
     (Annealing_Window.Hbox16,
      Annealing_Window.Label32,
      Expand  => False,
      Fill    => False,
      Padding => 0);

   Gtk_New_From_Stock (Annealing_Window.Ann_Help_Button, "gtk-help");
   Set_Relief (Annealing_Window.Ann_Help_Button, Relief_Normal);
   Pack_Start (Annealing_Window.Hbox13, Annealing_Window.Ann_Help_Button, False, False, 0);
   Button_Callback.Connect
     (Annealing_Window.Ann_Help_Button, "clicked",
      Button_Callback.To_Marshaller (On_Ann_Help_Button_Clicked'Access));

   Gtk_New_From_Stock (Annealing_Window.Cancel_Button, "gtk-cancel");
   Set_Relief (Annealing_Window.Cancel_Button, Relief_Normal);
   Pack_Start (Annealing_Window.Hbox13, Annealing_Window.Cancel_Button, False, False, 0);
   Button_Callback.Connect
     (Annealing_Window.Cancel_Button, "clicked",
      Button_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access));

end Initialize;

end Annealing_Window_Pkg;
