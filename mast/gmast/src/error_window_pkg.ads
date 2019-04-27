with Gtk.Window; use Gtk.Window;
with Gtk.Box; use Gtk.Box;
with Gtk.Label; use Gtk.Label;
with Gtk.Alignment; use Gtk.Alignment;
with Gtk.Button; use Gtk.Button;
package Error_Window_Pkg is

   type Error_Window_Record is new Gtk_Window_Record with record
      Vbox4 : Gtk_Vbox;
      Label_Error : Gtk_Label;
      Alignment13 : Gtk_Alignment;
      Button1 : Gtk_Button;
   end record;
   type Error_Window_Access is access all Error_Window_Record'Class;

   procedure Gtk_New (Error_Window : out Error_Window_Access);
   procedure Initialize (Error_Window : access Error_Window_Record'Class);

   Error_Window : Error_Window_Access;

end Error_Window_Pkg;
