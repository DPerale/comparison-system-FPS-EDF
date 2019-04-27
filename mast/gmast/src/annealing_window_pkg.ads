with Gtk.Window; use Gtk.Window;
with Gtk.Box; use Gtk.Box;
with Gtk.Label; use Gtk.Label;
with Gtk.Frame; use Gtk.Frame;
with Gtk.Table; use Gtk.Table;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Alignment; use Gtk.Alignment;
with Gtk.Button; use Gtk.Button;
with Gtk.Image; use Gtk.Image;
package Annealing_Window_Pkg is

   type Annealing_Window_Record is new Gtk_Window_Record with record
      Vbox8 : Gtk_Vbox;
      Label14 : Gtk_Label;
      Frame2 : Gtk_Frame;
      Table3 : Gtk_Table;
      Entry_Max_Iterations : Gtk_Entry;
      Entry_Iterations_To_Op : Gtk_Entry;
      Alignment5 : Gtk_Alignment;
      Label15 : Gtk_Label;
      Label16 : Gtk_Label;
      Label38 : Gtk_Label;
      Label39 : Gtk_Label;
      Entry_Stop_Analysis : Gtk_Entry;
      Entry_Stop_Audsley : Gtk_Entry;
      Hbox13 : Gtk_Hbox;
      Set_Button : Gtk_Button;
      Alignment15 : Gtk_Alignment;
      Hbox15 : Gtk_Hbox;
      Image1 : Gtk_Image;
      Label31 : Gtk_Label;
      Default_Button : Gtk_Button;
      Alignment16 : Gtk_Alignment;
      Hbox16 : Gtk_Hbox;
      Image2 : Gtk_Image;
      Label32 : Gtk_Label;
      Ann_Help_Button : Gtk_Button;
      Cancel_Button : Gtk_Button;
   end record;
   type Annealing_Window_Access is access all Annealing_Window_Record'Class;

   procedure Gtk_New (Annealing_Window : out Annealing_Window_Access);
   procedure Initialize (Annealing_Window : access Annealing_Window_Record'Class);

   Annealing_Window : Annealing_Window_Access;

end Annealing_Window_Pkg;
