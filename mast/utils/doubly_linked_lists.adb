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
package body Doubly_Linked_Lists is

   procedure Init (The_List : in out List) is
   begin
      The_List.First:=null;
      The_List.Last:=null;
      The_List.Num:=0;
   end Init;

   procedure Stack
     (Value : in Element;
      The_List : in out List) is
      New_Node : Index:=new Node'(Value,null,null);
   begin
      if The_List.First/=null then
         The_List.First.Previous:=New_Node;
      else
         The_List.Last:=New_Node;
      end if;
      New_Node.Next:=The_List.First;
      The_List.First:=New_Node;
      The_List.Num:=The_LIst.Num+1;
   end Stack;


   procedure Add
     (Value : in Element;
      The_List : in out List) is
      New_Node : Index:=new Node'(Value,null,null);
   begin
      if The_List.Last/=null then
         The_List.Last.Next:=New_Node;
      else
         The_List.First:=New_Node;
      end if;
      New_Node.Previous:=The_List.Last;
      The_List.Last:=New_Node;
      The_List.Num:=The_List.Num+1;
   end Add;

   procedure Insert_Before
     (The_Index : in Index;
      Value : in Element;
      The_List    : in out List) is
      New_Node : Index:=new Node'(Value,null,null);
   begin
      if The_Index=null or The_List.First=null then
         raise List_Exceptions.Invalid_Index;
      elsif The_Index=The_List.First then -- insert at first
         The_List.First.Previous:=New_Node;
         New_Node.Next:=The_List.First;
         The_List.First:=New_Node;
      else
         New_Node.Next:=The_Index;
         New_Node.Previous:=The_Index.Previous;
         The_Index.Previous.Next:=New_Node;
         The_Index.Previous:=New_Node;
      end if;
      The_List.Num:=The_List.Num+1;
   end Insert_Before;

   procedure Update
     (The_Index   : in Index;
      New_Value   : in Element;
      The_List      : in out List)
   is
   begin
      if The_Index=null or else The_List.First=null
      then
         raise List_Exceptions.Invalid_Index;
      else
         The_Index.Value:=New_Value;
      end if;
   end Update;


   procedure Delete (The_Index: in Index;
                     The_List   : in out List;
                     Value: out Element) is
   begin
      if The_Index=null then raise List_Exceptions.Invalid_Index;
      else
         Value:=The_Index.Value;
         if The_Index.Previous /= null then --Is not the first
            The_Index.Previous.Next:=The_Index.Next;
         else
            The_List.First:=The_Index.Next;
         end if;
         if The_Index.Next /= null then --Is not the last
            The_Index.Next.Previous:=The_Index.Previous;
         else
            The_List.Last:=The_Index.Previous;
         end if;
      end if;
      The_List.Num:=The_List.Num-1;
   end Delete;


   function Empty (The_List : in List) return Boolean is
   begin
      return The_List.First=null;
   end Empty;

   function First (The_List : in List) return Index is
   begin
      return The_List.First;
   end First;

   function Last (The_List : in List) return Index  is
   begin
      return The_List.Last;
   end Last;


   function Find(Value : in Element;
                 The_List : in List) return Index is
      P : Index:=The_List.First;
   begin
      while P/=null loop
         if P.Value = Value then
            return P;
         else
            P:=P.Next;
         end if;
      end loop;
      return Null_Index; -- not found
   end Find;


   function Item(The_Index : in Index;
                 The_List : in List) return Element is
   begin
      if The_Index=null then
         raise List_Exceptions.Invalid_Index;
      else
         return The_Index.Value;
      end if;
   end Item;

   function Size(The_List : List) return Natural is
   begin
      return The_List.Num;
   end Size;

   procedure Rewind (The_List : in List; Iterator : out Index) is
   begin
      Iterator:=The_List.First;
   end Rewind;

   procedure Get_Next_Item (Value : out Element;
                            The_List : in List;
                            Iterator : in out Index)
   is
   begin
      if Iterator=null then
         raise List_Exceptions.No_More_Items;
      else
         Value:=Iterator.Value;
         Iterator:=Iterator.Next;
      end if;
   end Get_Next_Item;

   function Clon (The_List : List) return List is
      New_List : List;
      Current : Index;
   begin
      Init(New_List);
      Current:=The_List.First;
      for I in 1..The_List.Num loop
         Add(Current.Value,New_List);
         Current:=Current.Next;
      end loop;
      return New_List;
   end Clon;

end Doubly_Linked_Lists;
