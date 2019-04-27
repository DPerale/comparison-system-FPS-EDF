with Glib; use Glib;
with Gtk; use Gtk;
with Gdk.Types;       use Gdk.Types;
with Gtk.Widget;      use Gtk.Widget;
with Gtk.Enums;       use Gtk.Enums;
with Gtkada.Handlers; use Gtkada.Handlers;
with Callbacks_Gmast_Analysis; use Callbacks_Gmast_Analysis;
with Gmast_Analysis_Intl; use Gmast_Analysis_Intl;
with Error_Window_Pkg.Callbacks; use Error_Window_Pkg.Callbacks;

package body Error_Window_Pkg is

procedure Gtk_New (Error_Window : out Error_Window_Access) is
begin
   Error_Window := new Error_Window_Record;
   Error_Window_Pkg.Initialize (Error_Window);
end Gtk_New;

procedure Initialize (Error_Window : access Error_Window_Record'Class) is
   pragma Suppress (All_Checks);
begin
   Gtk.Window.Initialize (Error_Window, Window_TopLevel);
   Set_Title (Error_Window, -"Error");
   Set_Policy (Error_Window, False, True, False);
   Set_Position (Error_Window, Win_Pos_None);
   Set_Modal (Error_Window, True);

   Gtk_New_Vbox (Error_Window.Vbox4, False, 1);
   Add (Error_Window, Error_Window.Vbox4);

   Gtk_New (Error_Window.Label_Error, -("Error"));
   Set_Alignment (Error_Window.Label_Error, 0.5, 0.5);
   Set_Padding (Error_Window.Label_Error, 47, 0);
   Set_Justify (Error_Window.Label_Error, Justify_Center);
   Set_Line_Wrap (Error_Window.Label_Error, False);
   Pack_Start (Error_Window.Vbox4, Error_Window.Label_Error, False, False, 33);

   Gtk_New
     (Error_Window.Alignment13, 0.5, 0.5, 0.11,
      0.11);
   Pack_Start
     (Error_Window.Vbox4,
      Error_Window.Alignment13,
      Expand  => False,
      Fill    => False,
      Padding => 1);
   Gtk_New_From_Stock (Error_Window.Button1, "gtk-ok");
   Set_Relief (Error_Window.Button1, Relief_Normal);
   Button_Callback.Connect
     (Error_Window.Button1, "clicked",
      Button_Callback.To_Marshaller (On_Button1_Clicked'Access), False);
   Add (Error_Window.Alignment13, Error_Window.Button1);

end Initialize;

end Error_Window_Pkg;
