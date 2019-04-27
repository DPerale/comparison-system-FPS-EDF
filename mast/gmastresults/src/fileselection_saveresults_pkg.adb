with Glib; use Glib;
with Gtk; use Gtk;
with Gdk.Types;       use Gdk.Types;
with Gtk.Widget;      use Gtk.Widget;
with Gtk.Enums;       use Gtk.Enums;
with Gtkada.Handlers; use Gtkada.Handlers;
with Callbacks_Gmastresults; use Callbacks_Gmastresults;
with Gmastresults_Intl; use Gmastresults_Intl;
with Fileselection_Saveresults_Pkg.Callbacks; use Fileselection_Saveresults_Pkg.Callbacks;

package body Fileselection_Saveresults_Pkg is

procedure Gtk_New (Fileselection_Saveresults : out Fileselection_Saveresults_Access) is
begin
   Fileselection_Saveresults := new Fileselection_Saveresults_Record;
   Fileselection_Saveresults_Pkg.Initialize (Fileselection_Saveresults);
end Gtk_New;

procedure Initialize (Fileselection_Saveresults : access Fileselection_Saveresults_Record'Class) is
   pragma Suppress (All_Checks);
begin
   Gtk.File_Selection.Initialize (Fileselection_Saveresults, -"Save Results As");
   Set_Show_File_Op_Buttons (Fileselection_Saveresults, True);
   Set_Border_Width (Fileselection_Saveresults, 10);
   Set_Title (Fileselection_Saveresults, -"Save Results As");
   Set_Policy (Fileselection_Saveresults, False, True, False);
   Set_Position (Fileselection_Saveresults, Win_Pos_Mouse);
   Set_Modal (Fileselection_Saveresults, True);

   Fileselection_Saveresults.Ok_Button3 := Get_Ok_Button (Fileselection_Saveresults);
   Set_Relief (Fileselection_Saveresults.Ok_Button3, Relief_Normal);
   Set_Flags (Fileselection_Saveresults.Ok_Button3, Can_Default);
   Button_Callback.Connect
     (Fileselection_Saveresults.Ok_Button3, "clicked",
      Button_Callback.To_Marshaller (On_Ok_Button3_Clicked'Access));

   Fileselection_Saveresults.Cancel_Button3 := Get_Cancel_Button (Fileselection_Saveresults);
   Set_Relief (Fileselection_Saveresults.Cancel_Button3, Relief_Normal);
   Set_Flags (Fileselection_Saveresults.Cancel_Button3, Can_Default);
   Button_Callback.Connect
     (Fileselection_Saveresults.Cancel_Button3, "clicked",
      Button_Callback.To_Marshaller (On_Cancel_Button3_Clicked'Access));

end Initialize;

end Fileselection_Saveresults_Pkg;
