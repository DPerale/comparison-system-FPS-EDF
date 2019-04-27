with Gtk.Window; use Gtk.Window;
with Gtk.Box; use Gtk.Box;
with Gtk.Scrolled_Window; use Gtk.Scrolled_Window;
with Gtk.Text; use Gtk.Text;
with Gtk.Alignment; use Gtk.Alignment;
with Gtk.Button; use Gtk.Button;
package Help_Pkg is

   type Help_Record is new Gtk_Window_Record with record
      Vbox7 : Gtk_Vbox;
      Scrolledwindow1 : Gtk_Scrolled_Window;
      Text1 : Gtk_Text;
      Alignment4 : Gtk_Alignment;
      Help_Ok : Gtk_Button;
   end record;
   type Help_Access is access all Help_Record'Class;

   procedure Gtk_New (Help : out Help_Access);
   procedure Initialize (Help : access Help_Record'Class);

   Help : Help_Access;

end Help_Pkg;
