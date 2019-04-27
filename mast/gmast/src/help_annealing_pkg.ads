with Gtk.Window; use Gtk.Window;
with Gtk.Box; use Gtk.Box;
with Gtk.Scrolled_Window; use Gtk.Scrolled_Window;
with Gtk.Text; use Gtk.Text;
with Gtk.Alignment; use Gtk.Alignment;
with Gtk.Button; use Gtk.Button;
package Help_Annealing_Pkg is

   type Help_Annealing_Record is new Gtk_Window_Record with record
      Vbox11 : Gtk_Vbox;
      Scrolledwindow3 : Gtk_Scrolled_Window;
      Text3 : Gtk_Text;
      Alignment12 : Gtk_Alignment;
      Help_Ann_Ok_Button : Gtk_Button;
   end record;
   type Help_Annealing_Access is access all Help_Annealing_Record'Class;

   procedure Gtk_New (Help_Annealing : out Help_Annealing_Access);
   procedure Initialize (Help_Annealing : access Help_Annealing_Record'Class);

   Help_Annealing : Help_Annealing_Access;

end Help_Annealing_Pkg;
