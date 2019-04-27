with Gtk.File_Selection; use Gtk.File_Selection;
with Gtk.Button; use Gtk.Button;
with Gtk.Object; use Gtk.Object;
with Gtk.Button; use Gtk.Button;
package Fileselection_Results_Pkg is

   type Fileselection_Results_Record is new Gtk_File_Selection_Record with record
      Ok_Button_Results : Gtk_Button;
      Cancel_Button_Results : Gtk_Button;
   end record;
   type Fileselection_Results_Access is access all Fileselection_Results_Record'Class;

   procedure Gtk_New (Fileselection_Results : out Fileselection_Results_Access);
   procedure Initialize (Fileselection_Results : access Fileselection_Results_Record'Class);

   Fileselection_Results : Fileselection_Results_Access;

end Fileselection_Results_Pkg;
