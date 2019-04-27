-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                           GMastEditor                             --
--          Graphical Editor for Modelling and Analysis              --
--                    of Real-Time Applications                      --
--                                                                   --
--                       Copyright (C) 2005-2008                     --
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
with Glib;          use Glib;
with Gtkada.Canvas; use Gtkada.Canvas;
with Var_Strings;   use Var_Strings;
with Ada.Text_IO;
with Mast;

package Mast_Editor is

   type ME_Object is abstract new Canvas_Item_Record with record
      Name                   : Var_Strings.Var_String;
      Canvas_Name            : Var_Strings.Var_String;
      Color_Name             : Var_Strings.Var_String;
      W, H, X_Coord, Y_Coord : Gint:=0;
   end record;

   function Name (Item : in ME_Object) return Var_String is abstract;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Object;
      Indentation : Positive;
      Finalize    : Boolean := False)
      is abstract;

   type ME_Object_Ref is access all ME_Object'Class;

   function Name (Item_Ref : in ME_Object_Ref) return Var_String is abstract;

   Gmasteditor_Version : constant String := Mast.Version_String;

end Mast_Editor;
