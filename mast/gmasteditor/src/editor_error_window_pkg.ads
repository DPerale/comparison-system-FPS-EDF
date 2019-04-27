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
with Gtk.Dialog; use Gtk.Dialog;
with Gtk.Box;    use Gtk.Box;
with Gtk.Button; use Gtk.Button;
with Gtk.Table;  use Gtk.Table;
with Gtk.Label;  use Gtk.Label;
package Editor_Error_Window_Pkg is

   type Editor_Error_Window_Record is new Gtk_Dialog_Record with record
      Hbox       : Gtk_Box;
      Ok_Button  : Gtk_Button;
      Table      : Gtk_Table;
      Down_Label : Gtk_Label;
      Up_Label   : Gtk_Label;
      Label      : Gtk_Label;
   end record;
   type Editor_Error_Window_Access is access Editor_Error_Window_Record'Class;

   procedure Gtk_New (Editor_Error_Window : out Editor_Error_Window_Access);
   procedure Initialize
     (Editor_Error_Window : access Editor_Error_Window_Record'Class);

   Editor_Error_Window : Editor_Error_Window_Access;

end Editor_Error_Window_Pkg;
