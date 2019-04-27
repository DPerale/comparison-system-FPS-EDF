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
with Mast_Parser_Error_Report;
with Error_Window_Pkg; use Error_Window_Pkg;
with Var_Strings; use Var_Strings;
with Ada.Text_IO;
with Clear_Results;

package body Fileselection_System_Pkg.Callbacks is

   use Gtk.Arguments;

   ---------------------------------
   -- On_Ok_Button_System_Clicked --
   ---------------------------------

   procedure On_Ok_Button_System_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
      Filename : String:=Get_Filename(Fileselection_System);
   begin
      Mast_Actions.Read_System(Filename);
      Clear_Results;
      Set_Sensitive(Gmast_Results.System_Save_As,True);
      Set_Sensitive(Gmast_Results.Results_Open,True);
      Set_Text(Gmast_Results.Entry_Current_System,
               To_String(The_System.Model_Name));
      Set_Text(Gmast_Results.Entry_Model_Name,
               To_String(The_System.Model_Name));
      Set_Text(Gmast_Results.Entry_Model_Date,The_System.Model_Date);
      Destroy(Fileselection_System);
   exception
      when Ada.Text_IO.Name_Error | Ada.Text_IO.Status_Error |
        Ada.Text_IO.Use_Error =>
         Destroy(Fileselection_System);
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,"System File "&Filename&
                  " not found");
         Set_Modal(Error_Window,True);
      when Mast_Parser_Error_Report.Syntax_Error =>
         Destroy(Fileselection_System);
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,
                  "Syntax Error. See mast_parser.lis");
         Set_Modal(Error_Window,True);
      when Mast_Actions.No_System =>
         Destroy(Fileselection_System);
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,
                  "No MAST system defined");
         Set_Modal(Error_Window,True);
      when Mast_Actions.Program_Not_Found =>
         Destroy(Fileselection_System);
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,
                  "mast_xml_convert program not found");
         Set_Modal(Error_Window,True);
      when Mast_Actions.Xml_Convert_Error =>
         Destroy(Fileselection_System);
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,
                  "Error detected while converting system from "&
                  "XML to text format");
         Set_Modal(Error_Window,True);
      when Constraint_Error =>
         Destroy(Fileselection_System);
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,
                  "Input file has unrecognizable format");
         Set_Modal(Error_Window,True);
   end On_Ok_Button_System_Clicked;

   -------------------------------------
   -- On_Cancel_Button_System_Clicked --
   -------------------------------------

   procedure On_Cancel_Button_System_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Destroy(Fileselection_System);
   end On_Cancel_Button_System_Clicked;

end Fileselection_System_Pkg.Callbacks;
