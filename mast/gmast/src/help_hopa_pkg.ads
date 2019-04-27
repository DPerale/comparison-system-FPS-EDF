with Gtk.Window; use Gtk.Window;
with Gtk.Box; use Gtk.Box;
with Gtk.Scrolled_Window; use Gtk.Scrolled_Window;
with Gtk.Text; use Gtk.Text;
with Gtk.Alignment; use Gtk.Alignment;
with Gtk.Button; use Gtk.Button;
package Help_Hopa_Pkg is

   type Help_Hopa_Record is new Gtk_Window_Record with record
      Vbox10 : Gtk_Vbox;
      Scrolledwindow2 : Gtk_Scrolled_Window;
      Text2 : Gtk_Text;
      Alignment11 : Gtk_Alignment;
      Help_Hopa_Ok_Button : Gtk_Button;
   end record;
   type Help_Hopa_Access is access all Help_Hopa_Record'Class;

   procedure Gtk_New (Help_Hopa : out Help_Hopa_Access);
   procedure Initialize (Help_Hopa : access Help_Hopa_Record'Class);

   Help_Hopa : Help_Hopa_Access;

end Help_Hopa_Pkg;
