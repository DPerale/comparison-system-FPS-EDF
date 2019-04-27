-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                           GMastEditor                             --
--          Graphical Editor for Modelling and Analysis              --
--                    of Real-Time Applications                      --
--                                                                   --
--                       Copyright (C) 2005-2008                          --
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
with System;          use System;
with Glib;            use Glib;
with Gdk.Event;       use Gdk.Event;
with Gdk.Types;       use Gdk.Types;
with Gtk.Accel_Group; use Gtk.Accel_Group;
with Gtk.Object;      use Gtk.Object;
with Gtk.Enums;       use Gtk.Enums;
with Gtk.Style;       use Gtk.Style;
with Gtk.Widget;      use Gtk.Widget;

with Gtk.Label;                use Gtk.Label;
with Editor_Actions;           use Editor_Actions;
with Editor_Error_Window_Pkg;  use Editor_Error_Window_Pkg;
with Ada.Text_IO;              use Ada.Text_IO;
with Mast_Parser_Error_Report;
with Mast.Systems;
with Change_Control;

package body Import_File_Selection_Pkg.Callbacks is

   use Gtk.Arguments;

   ----------------------------------
   -- On_Import_Filesel_Delete_Event --
   ----------------------------------

   function On_Import_Filesel_Delete_Event
     (Object : access Gtk_Widget_Record'Class;
      Params : Gtk.Arguments.Gtk_Args)
      return   Boolean
   is
      Arg1 : Gdk_Event := To_Event (Params, 1);
   begin
      return False;
   end On_Import_Filesel_Delete_Event;

   ---------------------------------------
   -- On_Import_Filesel_Ok_Button_Clicked --
   ---------------------------------------

   procedure On_Import_Filesel_Ok_Button_Clicked
     (Object : access Import_File_Selection_Record'Class)
   is
      System_Imported      : Mast.Systems.System;
      Filename             : String  := (Get_Filename (Object));
      Error_Window_Created : Boolean := False;
   begin
      begin
      -- Imports a new system and adds its items to lists
         Editor_Actions.Import_System (Filename, System_Imported);
         Editor_Actions.Adjust_System_Lists (System_Imported);
      exception
         when Editor_Actions.Duplicates =>
            Gtk_New (Editor_Error_Window);
            Show_All (Editor_Error_Window);
            Set_Text
              (Editor_Error_Window.Label,
               "Some duplicate objects found and discarded");
            Error_Window_Created := True;
         when Ada.Text_IO.Name_Error =>
            Gtk_New (Editor_Error_Window);
            Show_All (Editor_Error_Window);
            Set_Text
              (Editor_Error_Window.Label,
               "System file " & Filename & " Not Found");
            Error_Window_Created := True;
         when Ada.Text_IO.Status_Error | Ada.Text_IO.Use_Error =>
            Gtk_New (Editor_Error_Window);
            Show_All (Editor_Error_Window);
            Set_Text
              (Editor_Error_Window.Label,
               "Error while importing system file " & Filename);
            Error_Window_Created := True;
         when Mast_Parser_Error_Report.Syntax_Error =>
            Gtk_New (Editor_Error_Window);
            Show_All (Editor_Error_Window);
            Set_Text
              (Editor_Error_Window.Label,
               "Syntax Error in system file " &
               Filename &
               ". " &
               "See mast_parser.lis");
            Error_Window_Created := True;
         when Constraint_Error =>
            Gtk_New (Editor_Error_Window);
            Show_All (Editor_Error_Window);
            Set_Text
              (Editor_Error_Window.Label,
               "System file " & Filename & " has unrecognizable format");
            Error_Window_Created := True;
      end;

      begin
      -- Importing := True
         Editor_Actions.Read_Editor_System (Filename, True);
         Change_Control.Changes_Made;

      exception
         when Ada.Text_IO.Name_Error =>
            if not Error_Window_Created then
               Gtk_New (Editor_Error_Window);
               Show_All (Editor_Error_Window);
            end if;
            Set_Text (Editor_Error_Window.Label, "Editor File Not Found");

            -- draws system imported using *.txt file only
            Editor_Actions.Draw_TXT_File_System (System_Imported);
            Change_Control.Changes_Made;

         when Ada.Text_IO.Status_Error | Ada.Text_IO.Use_Error =>
            if not Error_Window_Created then
               Gtk_New (Editor_Error_Window);
               Show_All (Editor_Error_Window);
            end if;
            Set_Text
              (Editor_Error_Window.Label,
               "Error while importing editor file");
         when Constraint_Error =>
            if not Error_Window_Created then
               Gtk_New (Editor_Error_Window);
               Show_All (Editor_Error_Window);
            end if;
            Set_Text
              (Editor_Error_Window.Label,
               "Editor file has unrecognizable format");

      end;
      Destroy (Object);
   end On_Import_Filesel_Ok_Button_Clicked;

   -------------------------------------------
   -- On_Import_Filesel_Cancel_Button_Clicked --
   -------------------------------------------

   procedure On_Import_Filesel_Cancel_Button_Clicked
     (Object : access Gtk_Dialog_Record'Class)
   is
   begin
      Destroy (Object);
   end On_Import_Filesel_Cancel_Button_Clicked;

end Import_File_Selection_Pkg.Callbacks;
