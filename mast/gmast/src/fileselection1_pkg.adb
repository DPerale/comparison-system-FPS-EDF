with Glib; use Glib;
with Gtk; use Gtk;
with Gdk.Types;       use Gdk.Types;
with Gtk.Widget;      use Gtk.Widget;
with Gtk.Enums;       use Gtk.Enums;
with Gtkada.Handlers; use Gtkada.Handlers;
with Callbacks_Gmast_Analysis; use Callbacks_Gmast_Analysis;
with Gmast_Analysis_Intl; use Gmast_Analysis_Intl;
with Fileselection1_Pkg.Callbacks; use Fileselection1_Pkg.Callbacks;

package body Fileselection1_Pkg is

procedure Gtk_New (Fileselection1 : out Fileselection1_Access) is
begin
   Fileselection1 := new Fileselection1_Record;
   Fileselection1_Pkg.Initialize (Fileselection1);
end Gtk_New;

procedure Initialize (Fileselection1 : access Fileselection1_Record'Class) is
   pragma Suppress (All_Checks);
begin
   Gtk.File_Selection.Initialize (Fileselection1, -"Select File");
   Set_Show_File_Op_Buttons (Fileselection1, True);
   Set_Border_Width (Fileselection1, 10);
   Set_Title (Fileselection1, -"Select File");
   Set_Policy (Fileselection1, False, True, False);
   Set_Position (Fileselection1, Win_Pos_None);
   Set_Modal (Fileselection1, True);

   Fileselection1.Ok_Button1 := Get_Ok_Button (Fileselection1);
   Set_Relief (Fileselection1.Ok_Button1, Relief_Normal);
   Set_Flags (Fileselection1.Ok_Button1, Can_Default);
   Button_Callback.Connect
     (Fileselection1.Ok_Button1, "pressed",
      Button_Callback.To_Marshaller (On_Ok_Button1_Pressed'Access));

   Fileselection1.Cancel_Button1 := Get_Cancel_Button (Fileselection1);
   Set_Relief (Fileselection1.Cancel_Button1, Relief_Normal);
   Set_Flags (Fileselection1.Cancel_Button1, Can_Default);
   Button_Callback.Connect
     (Fileselection1.Cancel_Button1, "pressed",
      Button_Callback.To_Marshaller (Gtk_Widget_Hide'Access));

end Initialize;

end Fileselection1_Pkg;
