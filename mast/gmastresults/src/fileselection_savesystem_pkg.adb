with Glib; use Glib;
with Gtk; use Gtk;
with Gdk.Types;       use Gdk.Types;
with Gtk.Widget;      use Gtk.Widget;
with Gtk.Enums;       use Gtk.Enums;
with Gtkada.Handlers; use Gtkada.Handlers;
with Callbacks_Gmastresults; use Callbacks_Gmastresults;
with Gmastresults_Intl; use Gmastresults_Intl;
with Fileselection_Savesystem_Pkg.Callbacks; use Fileselection_Savesystem_Pkg.Callbacks;

package body Fileselection_Savesystem_Pkg is

procedure Gtk_New (Fileselection_Savesystem : out Fileselection_Savesystem_Access) is
begin
   Fileselection_Savesystem := new Fileselection_Savesystem_Record;
   Fileselection_Savesystem_Pkg.Initialize (Fileselection_Savesystem);
end Gtk_New;

procedure Initialize (Fileselection_Savesystem : access Fileselection_Savesystem_Record'Class) is
   pragma Suppress (All_Checks);
begin
   Gtk.File_Selection.Initialize (Fileselection_Savesystem, -"Save System As");
   Set_Show_File_Op_Buttons (Fileselection_Savesystem, True);
   Set_Border_Width (Fileselection_Savesystem, 10);
   Set_Title (Fileselection_Savesystem, -"Save System As");
   Set_Policy (Fileselection_Savesystem, False, True, False);
   Set_Position (Fileselection_Savesystem, Win_Pos_None);
   Set_Modal (Fileselection_Savesystem, True);

   Fileselection_Savesystem.Ok_Button1 := Get_Ok_Button (Fileselection_Savesystem);
   Set_Relief (Fileselection_Savesystem.Ok_Button1, Relief_Normal);
   Set_Flags (Fileselection_Savesystem.Ok_Button1, Can_Default);
   Button_Callback.Connect
     (Fileselection_Savesystem.Ok_Button1, "clicked",
      Button_Callback.To_Marshaller (On_Ok_Button1_Clicked'Access));

   Fileselection_Savesystem.Cancel_Button1 := Get_Cancel_Button (Fileselection_Savesystem);
   Set_Relief (Fileselection_Savesystem.Cancel_Button1, Relief_Normal);
   Set_Flags (Fileselection_Savesystem.Cancel_Button1, Can_Default);
   Button_Callback.Connect
     (Fileselection_Savesystem.Cancel_Button1, "clicked",
      Button_Callback.To_Marshaller (On_Cancel_Button1_Clicked'Access));

end Initialize;

end Fileselection_Savesystem_Pkg;
