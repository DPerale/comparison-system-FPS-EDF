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
with System;                   use System;
with Glib;                     use Glib;
with Gdk.Event;                use Gdk.Event;
with Gdk.Types;                use Gdk.Types;
with Gtk.Accel_Group;          use Gtk.Accel_Group;
with Gtk.Object;               use Gtk.Object;
with Gtk.Enums;                use Gtk.Enums;
with Gtk.Style;                use Gtk.Style;
with Gtk.Widget;               use Gtk.Widget;
with Gtk.Label;                use Gtk.Label;
with Editor_Actions;           use Editor_Actions;
with Editor_Error_Window_Pkg;  use Editor_Error_Window_Pkg;
with Ada.Text_IO;              use Ada.Text_IO;
with Mast_Parser_Error_Report;
with Var_Strings;              use Var_Strings;

package body Open_File_Selection_Pkg.Callbacks is

   use Gtk.Arguments;

   ----------------------------------
   -- On_Open_Filesel_Delete_Event --
   ----------------------------------

   function On_Open_Filesel_Delete_Event
     (Object : access Gtk_Widget_Record'Class;
      Params : Gtk.Arguments.Gtk_Args)
      return   Boolean
   is
      Arg1 : Gdk_Event := To_Event (Params, 1);
   begin
      return False;
   end On_Open_Filesel_Delete_Event;

   ---------------------------------------
   -- On_Open_Filesel_Ok_Button_Clicked --
   ---------------------------------------

   procedure On_Open_Filesel_Ok_Button_Clicked
     (Object : access Open_File_Selection_Record'Class)
   is
      Filename                           : String     :=
         (Get_Filename (Object));
      Error_Window_Created               : Boolean    := False;
      Filename_Var_String                : Var_String :=
         To_Var_String (Filename);
      System_File_Name, Editor_File_Name : Var_String;
      Long                               : Natural;
   begin
      Long := Length (Filename_Var_String);
      if Long > 3
        and then Var_Strings.Element (Filename_Var_String, Long - 3) = '.'
        and then Slice (Filename_Var_String, Long - 2, Long) =
                 To_Var_String ("mss")
      then
         Gtk_New (Editor_Error_Window);
         Show_All (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Extension of file " & Filename & " not valid");
         Destroy (Object);
         return;
      else
         System_File_Name := To_Var_String (Filename);
         Editor_File_Name := To_Var_String (Filename);
         Long             := Length (Editor_File_Name);
         if Long > 3
           and then Element (Editor_File_Name, Long - 3) = '.'
         then
            Editor_File_Name := Slice (Editor_File_Name, 1, Long - 3) &
                                "mss";
         else
            Editor_File_Name := Editor_File_Name & ".mss";
         end if;
      end if;

      Editor_Actions.Clear_All_Canvas;
      Reset_Editor_System (Editor_System);
      Reset_Mast_System (The_System);
      begin
         Editor_Actions.Read_System (To_String (System_File_Name));
      exception
         when Ada.Text_IO.Name_Error   |
              Ada.Text_IO.Status_Error |
              Ada.Text_IO.Use_Error    =>
            Gtk_New (Editor_Error_Window);
            Show_All (Editor_Error_Window);
            Set_Text
              (Editor_Error_Window.Label,
               "File " & Filename & " Not Found");
            Error_Window_Created := True;
         when Mast_Parser_Error_Report.Syntax_Error =>
            Gtk_New (Editor_Error_Window);
            Show_All (Editor_Error_Window);
            Set_Text
              (Editor_Error_Window.Label,
               "Syntax Error in system description file." &
               " See mast_parser.lis");
            Error_Window_Created := True;
         when Constraint_Error =>
            Gtk_New (Editor_Error_Window);
            Show_All (Editor_Error_Window);
            Set_Text
              (Editor_Error_Window.Label,
               "File " & Filename & " has unrecognizable format");
            Error_Window_Created := True;
      end;

      begin
         Editor_Actions.Read_Editor_System (To_String (Editor_File_Name));
         -- draw *.txt items that do not appear in *.mss file
         Editor_Actions.Draw_TXT_File_System (The_System, True);
         Editor_Actions.Register_names
           (To_String (System_File_Name),
            To_String (Editor_File_Name));

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
               "The application will use default parameters");
            -- draws system using *.txt file only
            Editor_Actions.Draw_TXT_File_System;
            Editor_Actions.Register_names
              (To_String (System_File_Name),
               To_String (Editor_File_Name));
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
      Destroy (Object);
   end On_Open_Filesel_Ok_Button_Clicked;

   -------------------------------------------
   -- On_Open_Filesel_Cancel_Button_Clicked --
   -------------------------------------------

   procedure On_Open_Filesel_Cancel_Button_Clicked
     (Object : access Gtk_Dialog_Record'Class)
   is
   begin
      Destroy (Object);
   end On_Open_Filesel_Cancel_Button_Clicked;

end Open_File_Selection_Pkg.Callbacks;
