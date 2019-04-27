-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                           GMastEditor                             --
--          Graphical Editor for Modelling and Analysis              --
--                    of Real-Time Applications                      --
--                                                                   --
--                       Copyright (C) 2005                          --
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

with Ada.Text_IO;
with Change_Control;
with Editor_Error_Window_Pkg; use Editor_Error_Window_Pkg;
with Editor_Actions;
with GNAT.OS_Lib;             use GNAT.OS_Lib;
with Gtkada.Dialogs;          use Gtkada.Dialogs;
with Gtk.Main;
with Open_File_Selection_Pkg; use Open_File_Selection_Pkg;
with Save_File_Selection_Pkg; use Save_File_Selection_Pkg;

package body Save_Changes_Dialog_Pkg.Callbacks is

   use Gtk.Arguments;

   ----------------------------
   -- On_Save_Button_Clicked --
   ----------------------------

   procedure On_Save_Button_Clicked
     (Object : access Gtk_Dialog_Record'Class)
   is
      Save_File_Selection : Save_File_Selection_Access;
   begin
      Destroy (Object);
      if Editor_Actions.Current_Filename /= null then
         Editor_Actions.Save_System (Editor_Actions.Current_Filename.all);
         Editor_Actions.Save_Editor_System
           (Editor_Actions.Current_Filename.all);
         Gtk.Main.Gtk_Exit (0);
      else
         Gtk_New (Save_File_Selection);
         Show_All (Save_File_Selection);
         Save_File_Selection.Save_And_Quit := True;
      end if;
   exception
      when Ada.Text_IO.Name_Error   |
           Ada.Text_IO.Status_Error |
           Ada.Text_IO.Use_Error    =>
         Gtk_New (Editor_Error_Window);
         Set_Position (Editor_Error_Window, Win_Pos_Mouse);
         Show_All (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Error while saving file " & Editor_Actions.Current_Filename.all);
   end On_Save_Button_Clicked;

   -------------------------------
   -- On_Discard_Button_Clicked --
   -------------------------------

   procedure On_Discard_Button_Clicked
     (Object : access Save_Changes_Dialog_Record'Class)
   is
      Open_File_Selection : Open_File_Selection_Access;
   begin
      Hide (Object);
      if Object.New_File then
         Change_Control.Saved;
         Editor_Actions.New_File;
      end if;
      if Object.Open_File then
         Change_Control.Saved;
         Gtk_New (Open_File_Selection);
         Show_All (Open_File_Selection);
      end if;
      if not Object.New_File and then not Object.Open_File then
         if Message_Dialog
               (" Do you really want to quit? ",
                Confirmation,
                Button_Yes or Button_No,
                Button_Yes) =
            Button_Yes
         then
            Gtk.Main.Gtk_Exit (0);
         end if;
      end if;
      Destroy (Object);
   end On_Discard_Button_Clicked;

end Save_Changes_Dialog_Pkg.Callbacks;
