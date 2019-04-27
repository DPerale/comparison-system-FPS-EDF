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
with Gtk.Label;       use Gtk.Label;

with Ada.Text_IO;
with Editor_Error_Window_Pkg; use Editor_Error_Window_Pkg;
with Editor_Actions;
with Gtkada.Dialogs;          use Gtkada.Dialogs;
with Gtk.Main;

package body Save_File_Selection_Pkg.Callbacks is

   use Gtk.Arguments;

   ----------------------------------
   -- On_Save_Filesel_Delete_Event --
   ----------------------------------

   function On_Save_Filesel_Delete_Event
     (Object : access Gtk_Widget_Record'Class;
      Params : Gtk.Arguments.Gtk_Args)
      return   Boolean
   is
      Arg1 : Gdk_Event := To_Event (Params, 1);
   begin
      return False;
   end On_Save_Filesel_Delete_Event;

   ---------------------------------------
   -- On_Save_Filesel_Ok_Button_Clicked --
   ---------------------------------------

   procedure On_Save_Filesel_Ok_Button_Clicked
     (Object : access Save_File_Selection_Record'Class)
   is
      Filename : String := Get_Filename (Object);
   begin
      Editor_Actions.Save_System (Filename);
      Editor_Actions.Save_Editor_System (Filename, True); -- Saving_As = True
      if Object.Save_And_Quit then
         Hide (Object);
         Gtk.Main.Gtk_Exit (0);
      end if;
      Destroy (Object);
   exception
      when Ada.Text_IO.Name_Error   |
           Ada.Text_IO.Status_Error |
           Ada.Text_IO.Use_Error    =>
         Destroy (Object);
         Gtk_New (Editor_Error_Window);
         Set_Position (Editor_Error_Window, Win_Pos_Mouse);
         Show_All (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Error while saving file " & Filename);
   end On_Save_Filesel_Ok_Button_Clicked;

   -------------------------------------------
   -- On_Save_Filesel_Cancel_Button_Clicked --
   -------------------------------------------

   procedure On_Save_Filesel_Cancel_Button_Clicked
     (Object : access Gtk_Dialog_Record'Class)
   is
   begin
      Destroy (Object);
   end On_Save_Filesel_Cancel_Button_Clicked;

end Save_File_Selection_Pkg.Callbacks;
