-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2005                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors: Michael Gonzalez       mgh@unican.es                     --
--          Jose Javier Gutierrez  gutierjj@unican.es                --
--          Jose Carlos Palencia   palencij@unican.es                --
--          Jose Maria Drake       drakej@unican.es                  --
--          Yago Pereiro                                             --
--                                                                   --
-- This program is free software; you can redistribute it and/or     --
-- modify it under the terms of the GNU General Public               --
-- License as published by the Free Software Foundation; either      --
-- version 2 of the License, or (at your option) any later version.  --
--                                                                   --
-- This program is distributed in the hope that it will be useful,   --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of    --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU --
-- General Public License for more details.                          --
--                                                                   --
-- You should have received a copy of the GNU General Public         --
-- License along with this program; if not, write to the             --
-- Free Software Foundation, Inc., 59 Temple Place - Suite 330,      --
-- Boston, MA 02111-1307, USA.                                       --
--                                                                   --
-----------------------------------------------------------------------

with Gtk; use Gtk;
with Gtk.Main;
with Gtk.Widget; use Gtk.Widget;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Menu_Item; use Gtk.Menu_Item;
with Gmast_Results_Pkg; use Gmast_Results_Pkg;
with Fileselection_System_Pkg; use Fileselection_System_Pkg;
with Error_Window_Pkg; use Error_Window_Pkg;
with Fileselection_Savesystem_Pkg; use Fileselection_Savesystem_Pkg;
with Mast_Actions,Mast_Parser_Error_Report,Mast_Results_Parser_Error_Report;
with Ada.Command_Line; use Ada.Command_Line;
with Draw_Results;
with Ada.Text_IO;
with Var_Strings; use Var_Strings;
with Fileselection_Results_Pkg; use Fileselection_Results_Pkg;
with Fileselection_Saveresults_Pkg; use Fileselection_Saveresults_Pkg;
with Dialog_Event_Pkg; use Dialog_Event_Pkg;
with Gtk.Image_Menu_Item; use Gtk.Image_Menu_Item;

procedure Gmastresults is
   Has_System : Boolean:=False;
begin
   if Argument_Count>=1 then
      begin
         Mast_Actions.Read_System(Argument(1));
         Has_System:=True;
      exception
         when Ada.Text_IO.Name_Error | Ada.Text_IO.Status_Error |
           Ada.Text_IO.Use_Error =>
            Ada.Text_IO.Put_Line("System File "&Argument(1)&" not found");
            return;
         when Mast_Parser_Error_Report.Syntax_Error =>
            Ada.Text_IO.Put_Line("Syntax Error. See mast_parser.lis");
            return;
         when Constraint_Error =>
            Ada.Text_IO.Put_Line("System file has unrecognizable format");
            return;
         when Mast_Actions.No_System =>
            Ada.Text_IO.Put_Line("No System File defined");
            return;
         when Mast_Actions.Program_Not_found =>
            Ada.Text_IO.Put_Line
              ("Program ""mast_xml_convert"" not found");
            Ada.Text_IO.Put_Line
              ("Check that it is installed, and that its "&
               "directory is in the PATH");
            return;
         when Mast_Actions.Xml_Convert_Error =>
            Ada.Text_IO.Put_Line
              ("Error detected while converting system from "&
               "XML to text format");
            return;
      end;
   end if;
   if Argument_Count>=2 then
      begin
         Mast_Actions.Read_Results(Argument(2));
      exception
         when Ada.Text_IO.Name_Error | Ada.Text_IO.Status_Error |
           Ada.Text_IO.Use_Error =>
            Ada.Text_IO.Put_Line("Results File "&Argument(2)&" not found");
            return;
         when Mast_Results_Parser_Error_Report.Syntax_Error =>
            Ada.Text_IO.Put_Line("Syntax Error. See mast_results_parser.lis");
            return;
         when Constraint_Error =>
            Ada.Text_IO.Put_Line("Results file has unrecognizable format");
            return;
         when Mast_Actions.No_Results =>
            Ada.Text_IO.Put_Line("No results file defined");
            return;
         when Mast_Actions.Program_Not_found =>
            Ada.Text_IO.Put_Line
              ("Program ""mast_xml_convert_results"" not found");
            Ada.Text_IO.Put_Line
              ("Check that it is installed, and that its "&
               "directory is in the PATH");
            return;
         when Mast_Actions.Xml_Convert_Results_Error =>
            Ada.Text_IO.Put_Line
              ("Error detected while converting results from "&
               "XML to text format");
            return;
      end;
   end if;

   Gtk.Main.Set_Locale;
   Gtk.Main.Init;
   Gtk_New (Gmast_Results);
   Show_All (Gmast_Results);
   --    Gtk_New (Fileselection_System);
   --    Show_All (Fileselection_System);
   --    Gtk_New (Error_Window);
   --    Show_All (Error_Window);
   --    Gtk_New (Fileselection_Savesystem);
   --    Show_All (Fileselection_Savesystem);
   --    Gtk_New (Fileselection_Results);
   --    Show_All (Fileselection_Results);
   --    Gtk_New (Fileselection_Saveresults);
   --    Show_All (Fileselection_Saveresults);
   --    Gtk_New (Dialog_Event);
   --    Show_All (Dialog_Event);

   if Mast_Actions.Has_System then
      Set_Text(Gmast_Results.Entry_Current_System,
               To_String(Mast_Actions.The_System.Model_Name));
      Set_Text(Gmast_Results.Entry_Model_Name,
               To_String(Mast_Actions.The_System.Model_Name));
      Set_Text(Gmast_Results.Entry_Model_Date,
               Mast_Actions.The_System.Model_Date);
   else
      Set_Sensitive(Gmast_Results.System_Save_As, False);
      Set_Sensitive(Gmast_Results.Results_Open, False);
   end if;
   if Mast_Actions.Has_Results then
      Draw_Results;
   else
      Set_Sensitive(Gmast_Results.Results_Save_As,False);
   end if;
   Gtk.Main.Main;

end Gmastresults;
