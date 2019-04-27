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

with Dynamic_Lists;
generic
   type Element is private;
   with function "=" (E1,E2 : Element) return Boolean;
package Associations is

   type Association is private;

   type Rel_Set_Iteration_Object is private;

   package Relation_Sets is new Dynamic_Lists(Element,"=");
   type Relation_Set_Ref is access Relation_Sets.List;

   procedure Init (Assoc : in out Association);

   procedure Add_Relation (E1,E2 : Element; Assoc : in out Association);

   function Num_Of_Relation_Sets (Assoc : Association) return Natural;

   procedure Rewind_Relation_Sets
     (Assoc : in Association;
      Iterator : out Rel_Set_Iteration_Object);

   procedure Get_Next_Relation_Set
     (Assoc : in Association;
      Set : out Relation_Set_Ref;
      Iterator : in out Rel_Set_Iteration_Object);

private

   package Assoc_Sets is new Dynamic_Lists(Relation_Set_Ref,"=");

   type Rel_Set_Iteration_Object is new Assoc_Sets.Iteration_Object;

   type Association is record
      Relation_Sets : Assoc_Sets.List;
   end record;

end Associations;
