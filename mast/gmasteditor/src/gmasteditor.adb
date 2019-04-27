-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                           GMastEditor                             --
--          Graphical Editor for Modelling and Analysis              --
--                    of Real-Time Applications                      --
--                                                                   --
--                       Copyright (C) 2005-2008                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors : Pilar del Rio                                           --
--           Michael Gonzalez                                        --
-- Contact info: Michael Gonzalez       mgh@unican.es                --
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
with Ada.Command_Line;         use Ada.Command_Line;
with Glib;                     use Glib;
with Gtk;                      use Gtk;
with Gtk.Main;
with Gtk.Enums;                use Gtk.Enums;
with Gtk.Style;                use Gtk.Style;
with Gtk.Label;                use Gtk.Label;
with Gtk.Button;               use Gtk.Button;
with Gtk.Widget;               use Gtk.Widget;
with Mast_Editor_Window_Pkg;   use Mast_Editor_Window_Pkg;
with Change_Control;
with Editor_Actions;
with Editor_Error_Window_Pkg;  use Editor_Error_Window_Pkg;
with Ada.Text_IO;
with Mast_Parser_Error_Report;
with Ada.Exceptions;
with Var_Strings;              use Var_Strings;
with Ada.Directories;

procedure Gmasteditor is
   Long                               : Natural;
   Error_Window_Created               : Boolean := False;
   System_File_Name, Editor_File_Name : Var_String;
   Wrong_Extension : exception;
begin
   Gtk.Main.Set_Locale;
   Gtk.Main.Init;
   Gtk_New (Mast_Editor_Window);
   Show_All (Mast_Editor_Window);

   begin
      if Argument_Count >= 1 then
         Long := Length (To_Var_String (Argument (1)));
         if Long > 3
           and then Var_Strings.Element
                       (To_Var_String (Argument (1)),
                        Long - 3) =
                    '.'
           and then Slice (To_Var_String (Argument (1)), Long - 2, Long) =
                    To_Var_String ("mss")
         then
            raise Wrong_Extension;
         else
            System_File_Name := To_Var_String (Argument (1));
            if Long > 3
              and then Element (System_File_Name, Long - 3) = '.'
            then
               Editor_File_Name := Slice (System_File_Name, 1, Long - 3) &
                                   "mss";
            else
               Editor_File_Name := System_File_Name & ".mss";
            end if;
         end if;

         -- Check if filename exists
         if Ada.Directories.Exists (To_String (System_File_Name)) then

         -- Read the system file
            begin
               Editor_Actions.Read_System (To_String (System_File_Name));
            exception
               when Ada.Text_IO.Status_Error | Ada.Text_IO.Use_Error =>
                  Gtk_New (Editor_Error_Window);
                  Show_All (Editor_Error_Window);
                  Set_Text
                    (Editor_Error_Window.Up_Label,
                     "File " &
                     Argument (1) &
                     ". Status error while openning");
                  Error_Window_Created := True;
               when Mast_Parser_Error_Report.Syntax_Error =>
                  Gtk_New (Editor_Error_Window);
                  Show_All (Editor_Error_Window);
                  Set_Text
                    (Editor_Error_Window.Up_Label,
                     "Syntax Error in system description file." &
                     " See mast_parser.lis");
                  Error_Window_Created := True;
               when Constraint_Error =>
                  Gtk_New (Editor_Error_Window);
                  Set_Text
                    (Editor_Error_Window.Up_Label,
                     "File " & Argument (1) & " has unrecognizable format");
                  Show_All (Editor_Error_Window);
                  Error_Window_Created := True;
            end;

         -- Read the graphical editor information from the *.mss file
            begin
               Editor_Actions.Read_Editor_System
                 (To_String (Editor_File_Name));

               -- Draw model items that do not appear in *.mss file
               Editor_Actions.Draw_TXT_File_System (MSS_File_Exists => True);

            exception
               when Ada.Text_IO.Name_Error   |
                    Ada.Text_IO.Status_Error |
                    Ada.Text_IO.Use_Error    =>
                  if not Error_Window_Created then
                     Gtk_New (Editor_Error_Window);
                     Show_All (Editor_Error_Window);
                  end if;
                  Set_Text
                    (Editor_Error_Window.Label,
                     "File " & To_String (Editor_File_Name) & " Not Found");
                  Set_Text
                    (Editor_Error_Window.Down_Label,
                     "The application will use default parameters " &
                     "for drawing the system");
                  -- draw system using system file only
                  Editor_Actions.Draw_TXT_File_System;
               when Constraint_Error =>
                  if not Error_Window_Created then
                     Gtk_New (Editor_Error_Window);
                     Show_All (Editor_Error_Window);
                  end if;
                  Set_Text
                    (Editor_Error_Window.Label,
                     "File " &
                     To_String (Editor_File_Name) &
                     " has unrecognizable format");
                  Editor_Actions.Draw_TXT_File_System;
            end;
         else
            -- System filename does not exist
            if Ada.Directories.Exists (To_String (Editor_File_Name)) then
               Gtk_New (Editor_Error_Window);
               Show_All (Editor_Error_Window);
               Set_Text
                 (Editor_Error_Window.Label,
                  "Warning. File " &
                  To_String (Editor_File_Name) &
                  " exists and will be overritten");
               Error_Window_Created := True;
            end if;
            Editor_Actions.Register_names
              (To_String (System_File_Name),
               To_String (Editor_File_Name));
         end if;
      end if;

   exception
      when Wrong_Extension =>
         Gtk_New (Editor_Error_Window);
         Show_All (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Extension of file " & Argument (1) & " not valid");
      when The_Error : others =>
         Gtk_New (Editor_Error_Window);
         Set_USize (Editor_Error_Window, -1, -1);
         Set_USize (Editor_Error_Window.Ok_Button, 250, -1);
         Set_Title (Editor_Error_Window, "INTERNAL APPLICATION ERROR !");
         Set_Text (Editor_Error_Window.Up_Label, " Exception raised !!! ");
         Set_Text
           (Editor_Error_Window.Label,
            Ada.Exceptions.Exception_Information (The_Error));
         Set_Text
           (Editor_Error_Window.Down_Label,
            " Close all windows and restart the application.");
         Show_All (Editor_Error_Window);
   end;

   Gtk.Main.Main;

end Gmasteditor;
