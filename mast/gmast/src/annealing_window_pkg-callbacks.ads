with Gtk.Arguments;
with Gtk.Widget; use Gtk.Widget;

package Annealing_Window_Pkg.Callbacks is
   procedure On_Set_Button_Clicked
     (Object : access Gtk_Button_Record'Class);

   procedure On_Default_Button_Clicked
     (Object : access Gtk_Button_Record'Class);

   procedure On_Ann_Help_Button_Clicked
     (Object : access Gtk_Button_Record'Class);

   procedure On_Cancel_Button_Clicked
     (Object : access Gtk_Button_Record'Class);

end Annealing_Window_Pkg.Callbacks;
