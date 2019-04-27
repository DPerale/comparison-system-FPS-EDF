with System; use System;
with Glib; use Glib;
with Gdk.Event; use Gdk.Event;
with Gdk.Types; use Gdk.Types;
with Gtk.Accel_Group; use Gtk.Accel_Group;
with Gtk.Object; use Gtk.Object;
with Gtk.Enums; use Gtk.Enums;
with Gtk.Style; use Gtk.Style;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Label; use Gtk.Label;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Image_Menu_Item; use Gtk.Image_Menu_Item;
with Gmast_Results_Pkg; use Gmast_Results_Pkg;
with Mast_Actions; use Mast_Actions;
with Mast_Results_Parser_Error_Report;
with Error_Window_Pkg; use Error_Window_Pkg;
with Var_Strings; use Var_Strings;
with Draw_Results;
with Ada.Text_IO;

package body Fileselection_Results_Pkg.Callbacks is

   use Gtk.Arguments;

   ----------------------------------
   -- On_Ok_Button_Results_Clicked --
   ----------------------------------

   procedure On_Ok_Button_Results_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
      Filename : String:=Get_Filename(Fileselection_Results);
   begin
      Mast_Actions.Read_Results(Filename);
      Set_Sensitive(Gmast_Results.Results_Save_As,True);
      Draw_Results;
      Destroy(Fileselection_Results);
   exception
      when Ada.Text_IO.Name_Error | Ada.Text_IO.Status_Error |
        Ada.Text_IO.Use_Error =>
         Destroy(Fileselection_Results);
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,"Results File "&Filename&
                  " not found");
         Set_Modal(Error_Window,True);
      when Mast_Results_Parser_Error_Report.Syntax_Error =>
         Destroy(Fileselection_Results);
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,
                  "Syntax Error. See mast_results_parser.lis");
         Set_Modal(Error_Window,True);
      when Mast_Actions.No_System =>
         Destroy(Fileselection_Results);
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,
                  "No MAST system defined");
         Set_Modal(Error_Window,True);
      when Mast_Actions.No_Results =>
         Destroy(Fileselection_Results);
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,
                  "No MAST results defined");
         Set_Modal(Error_Window,True);
      when Mast_Actions.Program_Not_Found =>
         Destroy(Fileselection_Results);
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,
                  "mast_xml_convert_results program not found");
         Set_Modal(Error_Window,True);
      when Mast_Actions.Xml_Convert_Error =>
         Destroy(Fileselection_Results);
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,
                  "Error detected while converting results from "&
                  "XML to text format");
         Set_Modal(Error_Window,True);
      when Constraint_Error =>
         Destroy(Fileselection_Results);
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,
                  "Results file has unrecognizable format");
         Set_Modal(Error_Window,True);
   end On_Ok_Button_Results_Clicked;

   --------------------------------------
   -- On_Cancel_Button_Results_Clicked --
   --------------------------------------

   procedure On_Cancel_Button_Results_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Destroy(Fileselection_Results);
   end On_Cancel_Button_Results_Clicked;

end Fileselection_Results_Pkg.Callbacks;
