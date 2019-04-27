with Gtk.File_Selection; use Gtk.File_Selection;
with Gtk.Button; use Gtk.Button;
with Gtk.Object; use Gtk.Object;
with Gtk.Button; use Gtk.Button;
package Fileselection_Saveresults_Pkg is

   type Fileselection_Saveresults_Record is new Gtk_File_Selection_Record with record
      Ok_Button3 : Gtk_Button;
      Cancel_Button3 : Gtk_Button;
   end record;
   type Fileselection_Saveresults_Access is access all Fileselection_Saveresults_Record'Class;

   procedure Gtk_New (Fileselection_Saveresults : out Fileselection_Saveresults_Access);
   procedure Initialize (Fileselection_Saveresults : access Fileselection_Saveresults_Record'Class);

   Fileselection_Saveresults : Fileselection_Saveresults_Access;

end Fileselection_Saveresults_Pkg;
