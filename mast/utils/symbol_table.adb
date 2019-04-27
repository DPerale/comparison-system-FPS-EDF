-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2002                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors: Michael Gonzalez       mgh@unican.es                     --
--          Jose Javier Gutierrez  gutierjj@unican.es                --
--          Jose Carlos Palencia   palencij@unican.es                --
--          Jose Maria Drake       drakej@unican.es                  --
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

package body Symbol_Table is

   The_List : Lists.List;

   --------------------
   -- Add_or_Convert --
   --------------------

   function Add_Or_Find (Name : Var_String) return Index is
      I : Lists.Index;
   begin
      Lists.Add_Or_Find (To_Lower(Name),I,The_List);
      return Index(I);
   end Add_Or_Find;

   ----------
   -- Find --
   ----------

   function Find (Name : Var_String) return Index is
   begin
      return Index(Lists.Find (To_Lower(Name),The_List));
   end Find;

   ----------
   -- Item --
   ----------

   function Item (I : Index) return Var_String is
   begin
      return Lists.Item (Lists.Index(I),The_List);
   end Item;

   ----------
   -- Name --
   ----------

   function Name (V : Var_String) return Var_String is
   begin
      return V;
   end Name;

end Symbol_Table;

