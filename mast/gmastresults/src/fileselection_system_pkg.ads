with Gtk.File_Selection; use Gtk.File_Selection;
with Gtk.Button; use Gtk.Button;
with Gtk.Object; use Gtk.Object;
with Gtk.Button; use Gtk.Button;
package Fileselection_System_Pkg is

   type Fileselection_System_Record is new Gtk_File_Selection_Record with record
      Ok_Button_System : Gtk_Button;
      Cancel_Button_System : Gtk_Button;
   end record;
   type Fileselection_System_Access is access all Fileselection_System_Record'Class;

   procedure Gtk_New (Fileselection_System : out Fileselection_System_Access);
   procedure Initialize (Fileselection_System : access Fileselection_System_Record'Class);

   Fileselection_System : Fileselection_System_Access;

end Fileselection_System_Pkg;
