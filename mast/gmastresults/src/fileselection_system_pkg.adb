with Glib; use Glib;
with Gtk; use Gtk;
with Gdk.Types;       use Gdk.Types;
with Gtk.Widget;      use Gtk.Widget;
with Gtk.Enums;       use Gtk.Enums;
with Gtkada.Handlers; use Gtkada.Handlers;
with Callbacks_Gmastresults; use Callbacks_Gmastresults;
with Gmastresults_Intl; use Gmastresults_Intl;
with Fileselection_System_Pkg.Callbacks; use Fileselection_System_Pkg.Callbacks;

package body Fileselection_System_Pkg is

procedure Gtk_New (Fileselection_System : out Fileselection_System_Access) is
begin
   Fileselection_System := new Fileselection_System_Record;
   Fileselection_System_Pkg.Initialize (Fileselection_System);
end Gtk_New;

procedure Initialize (Fileselection_System : access Fileselection_System_Record'Class) is
   pragma Suppress (All_Checks);
begin
   Gtk.File_Selection.Initialize (Fileselection_System, -"Select MAST System File");
   Set_Show_File_Op_Buttons (Fileselection_System, True);
   Set_Border_Width (Fileselection_System, 10);
   Set_Title (Fileselection_System, -"Select MAST System File");
   Set_Policy (Fileselection_System, False, True, False);
   Set_Position (Fileselection_System, Win_Pos_Mouse);
   Set_Modal (Fileselection_System, True);

   Fileselection_System.Ok_Button_System := Get_Ok_Button (Fileselection_System);
   Set_Relief (Fileselection_System.Ok_Button_System, Relief_Normal);
   Set_Flags (Fileselection_System.Ok_Button_System, Can_Default);
   Button_Callback.Connect
     (Fileselection_System.Ok_Button_System, "clicked",
      Button_Callback.To_Marshaller (On_Ok_Button_System_Clicked'Access));

   Fileselection_System.Cancel_Button_System := Get_Cancel_Button (Fileselection_System);
   Set_Relief (Fileselection_System.Cancel_Button_System, Relief_Normal);
   Set_Flags (Fileselection_System.Cancel_Button_System, Can_Default);
   Button_Callback.Connect
     (Fileselection_System.Cancel_Button_System, "clicked",
      Button_Callback.To_Marshaller (On_Cancel_Button_System_Clicked'Access));

end Initialize;

end Fileselection_System_Pkg;
