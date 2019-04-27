with Glib; use Glib;
with Gtk; use Gtk;
with Gdk.Types;       use Gdk.Types;
with Gtk.Widget;      use Gtk.Widget;
with Gtk.Enums;       use Gtk.Enums;
with Gtkada.Handlers; use Gtkada.Handlers;
with Callbacks_Gmastresults; use Callbacks_Gmastresults;
with Gmastresults_Intl; use Gmastresults_Intl;
with Fileselection_Results_Pkg.Callbacks; use Fileselection_Results_Pkg.Callbacks;

package body Fileselection_Results_Pkg is

procedure Gtk_New (Fileselection_Results : out Fileselection_Results_Access) is
begin
   Fileselection_Results := new Fileselection_Results_Record;
   Fileselection_Results_Pkg.Initialize (Fileselection_Results);
end Gtk_New;

procedure Initialize (Fileselection_Results : access Fileselection_Results_Record'Class) is
   pragma Suppress (All_Checks);
begin
   Gtk.File_Selection.Initialize (Fileselection_Results, -"Select MAST Results File");
   Set_Show_File_Op_Buttons (Fileselection_Results, True);
   Set_Border_Width (Fileselection_Results, 10);
   Set_Title (Fileselection_Results, -"Select MAST Results File");
   Set_Policy (Fileselection_Results, False, True, False);
   Set_Position (Fileselection_Results, Win_Pos_Mouse);
   Set_Modal (Fileselection_Results, True);

   Fileselection_Results.Ok_Button_Results := Get_Ok_Button (Fileselection_Results);
   Set_Relief (Fileselection_Results.Ok_Button_Results, Relief_Normal);
   Set_Flags (Fileselection_Results.Ok_Button_Results, Can_Default);
   Button_Callback.Connect
     (Fileselection_Results.Ok_Button_Results, "clicked",
      Button_Callback.To_Marshaller (On_Ok_Button_Results_Clicked'Access));

   Fileselection_Results.Cancel_Button_Results := Get_Cancel_Button (Fileselection_Results);
   Set_Relief (Fileselection_Results.Cancel_Button_Results, Relief_Normal);
   Set_Flags (Fileselection_Results.Cancel_Button_Results, Can_Default);
   Button_Callback.Connect
     (Fileselection_Results.Cancel_Button_Results, "clicked",
      Button_Callback.To_Marshaller (On_Cancel_Button_Results_Clicked'Access));

end Initialize;

end Fileselection_Results_Pkg;
