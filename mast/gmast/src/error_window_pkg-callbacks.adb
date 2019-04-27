with System; use System;
with Glib; use Glib;
with Gdk.Event; use Gdk.Event;
with Gdk.Types; use Gdk.Types;
with Gtk.Accel_Group; use Gtk.Accel_Group;
with Gtk.Object; use Gtk.Object;
with Gtk.Enums; use Gtk.Enums;
with Gtk.Style; use Gtk.Style;
with Gtk.Widget; use Gtk.Widget;

package body Error_Window_Pkg.Callbacks is

   use Gtk.Arguments;

   ------------------------
   -- On_Button1_Clicked --
   ------------------------

   procedure On_Button1_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Set_Modal(Error_Window,False);
      Destroy(Error_Window);
   end On_Button1_Clicked;

end Error_Window_Pkg.Callbacks;
