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

generic
   type Index is private;
   type Element is private;
   with function "=" (Ind, Ind2 : Index) return Boolean;
package Hash_Lists is

   type List is private;

   type Iteration_Object is private;

   procedure Add
     (The_Index : Index;
      Value     :        Element;
      The_List  : in out List);
   -- raises Already_Exists if The_Index Found

   procedure Add_Or_Update
     (The_Index : Index;
      Value     : Element;
      The_List  : in out List);

   procedure Update
     (The_Index : Index;
      New_Value :        Element;
      The_List  : in out List     );
   -- raises Invalid_Index if The_Index is not found

   procedure Update_First
     (New_Value :        Element;
      The_List  : in out List     );
   -- raises Empty if The_List is empty

   function Item
     (The_Index : Index;
      The_List  : List   )
     return Element;
   -- raises Invalid_Index if The_Index is not found

   function Exists
     (The_Index : Index;
      The_List  : List   )
     return Boolean;

   function First_Item
     (The_List  : List)
     return Element;
   -- raises Empty if The_List is empty

   function Size
     (The_List : List )
     return Natural;

   procedure Rewind
     (The_List : in List; Iterator : out Iteration_Object);

   procedure Get_Next_Item
     (The_Index : out Index;
      Value     : out Element;
      The_List  : in List;
      Iterator : in out Iteration_Object);

private

   type Node;

   type Iteration_Object is access Node;

   subtype Node_Ref is Iteration_Object;

   Null_Node_Ref : constant Node_Ref:=null;

   type Node is record
      Ind   : Index;
      Value : Element;
      Next  : Node_Ref;
   end record;

   type List is
      record
         First, Last : Node_Ref:=null;
         Num      : Natural:=0;
      end record;

end Hash_Lists;
