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
with System;                  use System;
with Glib;                    use Glib;
with Gdk.Event;               use Gdk.Event;
with Gdk.Types;               use Gdk.Types;
with Gtk.Accel_Group;         use Gtk.Accel_Group;
with Gtk.Object;              use Gtk.Object;
with Gtk.Enums;               use Gtk.Enums;
with Gtk.Style;               use Gtk.Style;
with Gtk.Widget;              use Gtk.Widget;
with Gtk.Main;                use Gtk.Main;
with Gtkada.Dialogs;          use Gtkada.Dialogs;
with Save_Changes_Dialog_Pkg; use Save_Changes_Dialog_Pkg;
with Change_Control;
with Mast_Editor;
with Mast;

package body Item_Menu_Pkg.Callbacks is

   use Gtk.Arguments;

   ------------------------
   -- On_Remove_Activate --
   ------------------------

   procedure On_Remove_Activate
     (Object : access Gtk_Menu_Item_Record'Class)
   is
   begin
      Destroy (Item_Menu);
   end On_Remove_Activate;

   ----------------------------
   -- On_Properties_Activate --
   ----------------------------

   procedure On_Properties_Activate
     (Object : access Gtk_Menu_Item_Record'Class)
   is
   begin
      Destroy (Item_Menu);
   end On_Properties_Activate;

   -----------------------
   -- On_About_Activate --
   -----------------------

   procedure On_About_Activate (Object : access Gtk_Menu_Item_Record'Class) is
      Button : Message_Dialog_Buttons;
   begin
      Button :=
         Message_Dialog
           ("Modeling and Analysis Suite for Real Time Applications (MAST) GUI"
            &
            ASCII.LF &
            ASCII.LF &
            "(gMAST version " &
            Mast_Editor.Gmasteditor_Version &
            ")" &
            ASCII.LF &
            ASCII.LF &
            "Designed for MAST version " &
            Mast.Version_String &
            ASCII.LF &
            ASCII.LF & 
"Created by: Pilar Del Rio Trueba, Universidad de Cantabria, Spain",
            Help_Msg => "Please see the gmasteditor documentation" &
                        ASCII.LF &
                        ASCII.LF &
                        "Click on the OK button to close this window.",
            Title    => " About gMAST version " &
                        Mast_Editor.Gmasteditor_Version);
      Destroy (Item_Menu);
   end On_About_Activate;

   ----------------------
   -- On_Quit_Activate --
   ----------------------

   procedure On_Quit_Activate (Object : access Gtk_Menu_Item_Record'Class) is
      Save_Changes_Dialog : Save_Changes_Dialog_Access;
   begin
      Destroy (Item_Menu);
      if Change_Control.Saved_Changes then
         Gtk.Main.Gtk_Exit (0);
      else
         Gtk_New (Save_Changes_Dialog);
         Show_All (Save_Changes_Dialog);
      end if;
   end On_Quit_Activate;

end Item_Menu_Pkg.Callbacks;
