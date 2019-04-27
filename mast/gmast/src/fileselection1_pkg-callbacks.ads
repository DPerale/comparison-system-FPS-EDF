with Gtk.Arguments;
with Gtk.Widget; use Gtk.Widget;

package Fileselection1_Pkg.Callbacks is
   procedure On_Ok_Button1_Pressed
     (Object : access Gtk_Button_Record'Class);

   procedure Gtk_Widget_Hide
     (Object : access Gtk_Button_Record'Class);

end Fileselection1_Pkg.Callbacks;
