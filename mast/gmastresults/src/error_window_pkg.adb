with Glib; use Glib;
with Gtk; use Gtk;
with Gdk.Types;       use Gdk.Types;
with Gtk.Widget;      use Gtk.Widget;
with Gtk.Enums;       use Gtk.Enums;
with Gtkada.Handlers; use Gtkada.Handlers;
with Callbacks_Gmastresults; use Callbacks_Gmastresults;
with Gmastresults_Intl; use Gmastresults_Intl;
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
   Gtk.Window.Initialize (Error_Window, Window_Toplevel);
   Set_Title (Error_Window, -"Error");
   Set_Policy (Error_Window, False, True, False);
   Set_Position (Error_Window, Win_Pos_None);
   Set_Modal (Error_Window, True);

   Gtk_New_Vbox (Error_Window.Vbox3, False, 0);
   Add (Error_Window, Error_Window.Vbox3);

   Gtk_New (Error_Window.Label_Error, -("label31"));
   Set_Alignment (Error_Window.Label_Error, 0.5, 0.5);
   Set_Padding (Error_Window.Label_Error, 30, 30);
   Set_Justify (Error_Window.Label_Error, Justify_Center);
   Set_Line_Wrap (Error_Window.Label_Error, False);
   Pack_Start (Error_Window.Vbox3, Error_Window.Label_Error, False, False, 0);

   Gtk_New
     (Error_Window.Alignment4, 0.5, 0.5, 0.0, 
      0.0);
   Pack_Start (Error_Window.Vbox3, Error_Window.Alignment4, False, False, 0);

   Gtk_New_From_Stock (Error_Window.Ok_Button_Error, "gtk-ok");
   Set_Border_Width (Error_Window.Ok_Button_Error, 3);
   Set_Relief (Error_Window.Ok_Button_Error, Relief_Normal);
   Button_Callback.Connect
     (Error_Window.Ok_Button_Error, "clicked",
      Button_Callback.To_Marshaller (On_Ok_Button_Error_Clicked'Access));
   Add (Error_Window.Alignment4, Error_Window.Ok_Button_Error);

end Initialize;

end Error_Window_Pkg;
