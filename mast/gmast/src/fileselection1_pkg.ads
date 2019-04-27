with Gtk.File_Selection; use Gtk.File_Selection;
with Gtk.Button; use Gtk.Button;
with Gtk.Object; use Gtk.Object;
with Gtk.Button; use Gtk.Button;
package Fileselection1_Pkg is

   type Fileselection1_Record is new Gtk_File_Selection_Record with record
      Ok_Button1 : Gtk_Button;
      Cancel_Button1 : Gtk_Button;
   end record;
   type Fileselection1_Access is access all Fileselection1_Record'Class;

   procedure Gtk_New (Fileselection1 : out Fileselection1_Access);
   procedure Initialize (Fileselection1 : access Fileselection1_Record'Class);

   Fileselection1 : Fileselection1_Access;

end Fileselection1_Pkg;
