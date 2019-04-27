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

with List_Exceptions;

package body Hash_Lists is

   ----------
   -- Find --
   ----------

   function Find
     (The_Index : Index;
      The_List : List)
     return Node_Ref
   is
      Pos : Node_Ref:=The_List.First;
   begin
      for I in 1..The_List.Num loop
         if The_Index=Pos.Ind then
            return Pos;
         end if;
         Pos:=Pos.Next;
      end loop;
      return Null_Node_Ref;
   end Find;

   ------------
   -- Exists --
   ------------

   function Exists
     (The_Index : Index;
      The_List  : List   )
     return Boolean
   is
   begin
      return Find(The_Index,The_List)/=Null_Node_Ref;
   end Exists;

   ---------
   -- Add --
   ---------

   procedure Add
     (The_Index : Index;
      Value     :        Element;
      The_List  : in out List)
   is
      Pos : Node_Ref:=Find(The_Index,The_List);
   begin
      if Pos=Null_Node_Ref then
         if The_List.First=null then
            The_List.First:=new Node'
              (Ind => The_Index, Value => Value, Next => null);
            The_List.Last:=The_List.First;
         else
            The_List.Last.Next:=new Node'
              (Ind => The_Index, Value => Value, Next => null);
            The_List.Last:=The_List.Last.Next;
         end if;
         The_List.Num:=The_List.Num+1;
      else
         raise List_Exceptions.Already_Exists;
      end if;
   end Add;

   -----------------
   -- Add_Or_Update --
   -----------------

   procedure Add_Or_Update
     (The_Index : in Index;
      Value     : Element;
      The_List  : in out List)
   is
      Pos : Node_Ref:=Find(The_Index,The_List);
   begin
      if Pos=Null_Node_Ref then
         if The_List.First=null then
            The_List.First:=new Node'
              (Ind => The_Index, Value => Value, Next => null);
            The_List.Last:=The_List.First;
         else
            The_List.Last.Next:=new Node'
              (Ind => The_Index, Value => Value, Next => null);
            The_List.Last:=The_List.Last.Next;
         end if;
         The_List.Num:=The_List.Num+1;
      else
         Pos.Value:=Value;
      end if;
   end Add_Or_Update;

   -------------------
   -- Get_Next_Item --
   -------------------

   procedure Get_Next_Item
     (The_Index : out Index;
      Value     :    out Element;
      The_List  : in List;
      Iterator : in out Iteration_Object)
   is
   begin
      if Iterator=null then
         raise List_Exceptions.No_More_Items;
      else
         Value:=Iterator.Value;
         The_Index:=Iterator.Ind;
         Iterator:=Iterator.Next;
      end if;
   end Get_Next_Item;

   ----------
   -- Item --
   ----------

   function Item
     (The_Index : Index;
      The_List  : List)
     return Element
   is
      Pos : Node_Ref:=Find(The_Index,The_List);
   begin

      if Pos=null then
         raise List_Exceptions.Invalid_Index;
      else
         return Pos.Value;
      end if;
   end Item;

   ----------------
   -- First_Item --
   ----------------

   function First_Item
     (The_List  : List)
     return Element
   is
   begin
      if The_List.First=null then
         raise List_Exceptions.Empty;
      else
         return The_List.First.Value;
      end if;
   end First_Item;

   ------------
   -- Rewind --
   ------------

   procedure Rewind
     (The_List : in List; Iterator : out Iteration_Object)
   is
   begin
      Iterator:=The_List.First;
   end Rewind;

   ----------
   -- Size --
   ----------

   function Size
     (The_List : List)
     return Natural
   is
   begin
      return The_List.Num;
   end Size;

   ------------
   -- Update --
   ------------

   procedure Update
     (The_Index :        Index;
      New_Value :        Element;
      The_List  : in out List)
   is
      Pos:Node_Ref:=Find(The_Index,The_List);
   begin
      if Pos=null then
         raise List_Exceptions.Invalid_Index;
      else
         Pos.Value:=New_Value;
      end if;
   end Update;

   ------------------
   -- Update First --
   ------------------

   procedure Update_First
     (New_Value :        Element;
      The_List  : in out List)
   is
   begin
      if The_List.First=null then
         raise List_Exceptions.Empty;
      else
         The_List.First.Value:=New_Value;
      end if;
   end Update_First;

end Hash_Lists;
