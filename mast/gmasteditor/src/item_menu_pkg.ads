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
with Gtk.Menu;      use Gtk.Menu;
with Gtk.Menu_Item; use Gtk.Menu_Item;
package Item_Menu_Pkg is

   type Item_Menu_Record is new Gtk_Menu_Record with record
      Remove     : Gtk_Menu_Item;
      Properties : Gtk_Menu_Item;
      Separador1 : Gtk_Menu_Item;
      About      : Gtk_Menu_Item;
      Separador2 : Gtk_Menu_Item;
      Quit       : Gtk_Menu_Item;
   end record;
   type Item_Menu_Access is access all Item_Menu_Record'Class;

   procedure Gtk_New (Item_Menu : out Item_Menu_Access);
   procedure Initialize (Item_Menu : access Item_Menu_Record'Class);

   Item_Menu : Item_Menu_Access;

end Item_Menu_Pkg;
