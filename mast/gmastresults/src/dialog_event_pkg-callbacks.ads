with Gtk.Arguments;
with Gtk.Widget; use Gtk.Widget;

package Dialog_Event_Pkg.Callbacks is
   procedure On_Button_Close_Tr_Clicked
     (Object : access Gtk_Button_Record'Class);

   procedure On_Entry_Tr_Transaction_Changed
     (Object : access Gtk_Entry_Record'Class);

   procedure On_Button_All_Clicked
     (Object : access Gtk_Button_Record'Class);

end Dialog_Event_Pkg.Callbacks;
