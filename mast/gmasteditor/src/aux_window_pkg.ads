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
with Gtk.Window;          use Gtk.Window;
with Gtk.Frame;           use Gtk.Frame;
with Gtk.Scrolled_Window; use Gtk.Scrolled_Window;
with Gtkada.Canvas;       use Gtkada.Canvas;

package Aux_Window_Pkg is

   type Aux_Window_Record is new Gtk_Window_Record with record
      Frame    : Gtk_Frame;
      Scrolled : Gtk_Scrolled_Window;
      -----
      Aux_Canvas : Gtkada.Canvas.Interactive_Canvas;
   end record;
   type Aux_Window_Access is access Aux_Window_Record'Class;

   procedure Gtk_New (Aux_Window : out Aux_Window_Access);
   procedure Initialize (Aux_Window : access Aux_Window_Record'Class);

end Aux_Window_Pkg;
