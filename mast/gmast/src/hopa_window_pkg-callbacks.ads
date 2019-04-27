with Gtk.Arguments;
with Gtk.Widget; use Gtk.Widget;

package Hopa_Window_Pkg.Callbacks is
   procedure On_Hset_Button_Clicked
     (Object : access Gtk_Button_Record'Class);

   procedure On_Hget_Defaults_Button_Clicked
     (Object : access Gtk_Button_Record'Class);

   procedure On_Hopa_Help_Button_Clicked
     (Object : access Gtk_Button_Record'Class);

   procedure On_Hcancel_Button_Clicked
     (Object : access Gtk_Button_Record'Class);

end Hopa_Window_Pkg.Callbacks;
