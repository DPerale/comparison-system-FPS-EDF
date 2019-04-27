with Gtk.Window; use Gtk.Window;
with Gtk.Box; use Gtk.Box;
with Gtk.Label; use Gtk.Label;
with Gtk.Frame; use Gtk.Frame;
with Gtk.Table; use Gtk.Table;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Alignment; use Gtk.Alignment;
with Gtk.Button; use Gtk.Button;
with Gtk.Image; use Gtk.Image;
package Hopa_Window_Pkg is

   type Hopa_Window_Record is new Gtk_Window_Record with record
      Vbox9 : Gtk_Vbox;
      Label27 : Gtk_Label;
      Frame3 : Gtk_Frame;
      Table4 : Gtk_Table;
      Ka_Entry : Gtk_Entry;
      Kr_Entry : Gtk_Entry;
      Alignment6 : Gtk_Alignment;
      Alignment10 : Gtk_Alignment;
      Label30 : Gtk_Label;
      Alignment7 : Gtk_Alignment;
      Label20 : Gtk_Label;
      Opiter_Entry : Gtk_Entry;
      Alignment8 : Gtk_Alignment;
      Label28 : Gtk_Label;
      Alignment9 : Gtk_Alignment;
      Label29 : Gtk_Label;
      Iter_List_Entry : Gtk_Entry;
      Label40 : Gtk_Label;
      Label41 : Gtk_Label;
      Entry_H_Stop_Analysis : Gtk_Entry;
      Entry_H_Stop_Audsley : Gtk_Entry;
      Hbox14 : Gtk_Hbox;
      Hset_Button : Gtk_Button;
      Alignment17 : Gtk_Alignment;
      Hbox17 : Gtk_Hbox;
      Image3 : Gtk_Image;
      Label33 : Gtk_Label;
      Hget_Defaults_Button : Gtk_Button;
      Alignment18 : Gtk_Alignment;
      Hbox18 : Gtk_Hbox;
      Image4 : Gtk_Image;
      Label34 : Gtk_Label;
      Hopa_Help_Button : Gtk_Button;
      Hcancel_Button : Gtk_Button;
   end record;
   type Hopa_Window_Access is access all Hopa_Window_Record'Class;

   procedure Gtk_New (Hopa_Window : out Hopa_Window_Access);
   procedure Initialize (Hopa_Window : access Hopa_Window_Record'Class);

   Hopa_Window : Hopa_Window_Access;

end Hopa_Window_Pkg;
