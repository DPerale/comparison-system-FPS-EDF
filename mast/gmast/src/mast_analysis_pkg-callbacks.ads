with Gtk.Arguments;
with Gtk.Widget; use Gtk.Widget;

package Mast_Analysis_Pkg.Callbacks is
   function On_Mast_Analysis_Delete_Event
     (Object : access Gtk_Widget_Record'Class;
      Params : Gtk.Arguments.Gtk_Args) return Boolean;

   procedure On_Output_File_Changed
     (Object : access Gtk_Entry_Record'Class);

   procedure On_Default_Clicked
     (Object : access Gtk_Button_Record'Class);

   procedure On_Blank_Clicked
     (Object : access Gtk_Button_Record'Class);

   procedure On_Input_File_Selection_Clicked
     (Object : access Gtk_Button_Record'Class);

   procedure On_Tool_Entry_Changed
     (Object : access Gtk_Entry_Record'Class);

   procedure On_Ceilings_Toggled
     (Object : access Gtk_Check_Button_Record'Class);

   procedure On_Priorities_Toggled
     (Object : access Gtk_Check_Button_Record'Class);

   procedure On_Technique_Entry_Changed
     (Object : access Gtk_Entry_Record'Class);

   procedure On_Destination_File_Changed
     (Object : access Gtk_Entry_Record'Class);

   procedure On_Operation_Name_Changed
     (Object : access Gtk_Entry_Record'Class);

   procedure On_Go_Button_Clicked
     (Object : access Gtk_Button_Record'Class);

   procedure Gtk_Main_Quit
     (Object : access Gtk_Button_Record'Class);

   procedure On_Hopa_Params_Clicked
     (Object : access Gtk_Button_Record'Class);

   procedure On_Annealing_Params_Clicked
     (Object : access Gtk_Button_Record'Class);

   procedure On_Help_Button_Clicked
     (Object : access Gtk_Button_Record'Class);

end Mast_Analysis_Pkg.Callbacks;
