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
with Gtk.File_Selection; use Gtk.File_Selection;
with Gtk.Button;         use Gtk.Button;
with Gtk.Object;         use Gtk.Object;
with Gtk.Button;         use Gtk.Button;
package Save_File_Selection_Pkg is

   type Save_File_Selection_Record is new Gtk_File_Selection_Record with
      record
         Ok_Button3     : Gtk_Button;
         Cancel_Button3 : Gtk_Button;
         ---------------
         Save_And_Quit : Boolean := False;
      end record;
   type Save_File_Selection_Access is access all Save_File_Selection_Record'
     Class;

   procedure Gtk_New (Save_File_Selection : out Save_File_Selection_Access);
   procedure Initialize
     (Save_File_Selection : access Save_File_Selection_Record'Class);

end Save_File_Selection_Pkg;
