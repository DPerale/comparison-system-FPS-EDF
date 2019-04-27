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
with Gtk.Button; use Gtk.Button;
with Gtk.Object; use Gtk.Object;
with Gtk.Box;    use Gtk.Box;
with Gtk.Label;  use Gtk.Label;
package Save_Changes_Dialog_Pkg is

   type Save_Changes_Dialog_Record is new Gtk_Dialog_Record with record
      Save_Button    : Gtk_Button;
      Discard_Button : Gtk_Button;
      Label          : Gtk_Label;
      ------------
      New_File  : Boolean := False;
      Open_File : Boolean := False;
   end record;
   type Save_Changes_Dialog_Access is access all Save_Changes_Dialog_Record'
     Class;

   procedure Gtk_New (Save_Changes_Dialog : out Save_Changes_Dialog_Access);
   procedure Initialize
     (Save_Changes_Dialog : access Save_Changes_Dialog_Record'Class);

end Save_Changes_Dialog_Pkg;
