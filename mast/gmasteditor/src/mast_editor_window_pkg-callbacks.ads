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
--                                                                   --
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
with Gtk.Arguments;
with Gtk.Widget; use Gtk.Widget;

package Mast_Editor_Window_Pkg.Callbacks is
   procedure On_New_Activate (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_Open_Activate (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_Import_Activate
     (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_Save_Activate (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_Save_As_Activate
     (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_Quit_Activate (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_Create_Simple_Transaction_Activate
     (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_Create_Linear_Transaction_Activate
     (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_Analysis_Activate
     (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_Simulation_Activate
     (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_View_Results_Activate
     (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_About_Activate (Object : access Gtk_Menu_Item_Record'Class);

   function On_Main_Window_Delete_Event
     (Object : access Gtk_Widget_Record'Class;
      Params : Gtk.Arguments.Gtk_Args)
      return   Boolean;

end Mast_Editor_Window_Pkg.Callbacks;
