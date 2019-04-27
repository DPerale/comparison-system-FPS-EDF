with Gtk.File_Selection; use Gtk.File_Selection;
with Gtk.Button; use Gtk.Button;
with Gtk.Object; use Gtk.Object;
with Gtk.Button; use Gtk.Button;
package Fileselection_Savesystem_Pkg is

   type Fileselection_Savesystem_Record is new Gtk_File_Selection_Record with record
      Ok_Button1 : Gtk_Button;
      Cancel_Button1 : Gtk_Button;
   end record;
   type Fileselection_Savesystem_Access is access all Fileselection_Savesystem_Record'Class;

   procedure Gtk_New (Fileselection_Savesystem : out Fileselection_Savesystem_Access);
   procedure Initialize (Fileselection_Savesystem : access Fileselection_Savesystem_Record'Class);

   Fileselection_Savesystem : Fileselection_Savesystem_Access;

end Fileselection_Savesystem_Pkg;
