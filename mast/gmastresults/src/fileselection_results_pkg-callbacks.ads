with Gtk.Arguments;
with Gtk.Widget; use Gtk.Widget;

package Fileselection_Results_Pkg.Callbacks is
   procedure On_Ok_Button_Results_Clicked
     (Object : access Gtk_Button_Record'Class);

   procedure On_Cancel_Button_Results_Clicked
     (Object : access Gtk_Button_Record'Class);

end Fileselection_Results_Pkg.Callbacks;
