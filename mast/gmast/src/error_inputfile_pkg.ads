with Gtk.Window; use Gtk.Window;
with Gtk.Box; use Gtk.Box;
with Gtk.Label; use Gtk.Label;
with Gtk.Alignment; use Gtk.Alignment;
with Gtk.Button; use Gtk.Button;
package Error_Inputfile_Pkg is

   type Error_Inputfile_Record is new Gtk_Window_Record with record
      Vbox6 : Gtk_Vbox;
      Label13 : Gtk_Label;
      Alignment14 : Gtk_Alignment;
      Button_Ok : Gtk_Button;
   end record;
   type Error_Inputfile_Access is access all Error_Inputfile_Record'Class;

   procedure Gtk_New (Error_Inputfile : out Error_Inputfile_Access);
   procedure Initialize (Error_Inputfile : access Error_Inputfile_Record'Class);

   Error_Inputfile : Error_Inputfile_Access;

end Error_Inputfile_Pkg;
