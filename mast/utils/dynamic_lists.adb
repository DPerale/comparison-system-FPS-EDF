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
package body Dynamic_Lists is

   procedure Init (The_List : in out List) is
   begin
      The_List.First:= new Node;
      The_List.Num:=0;
   end Init;


   procedure Stack
     (Value : in Element;
      The_List : in out List)
   is
      Header : Index:=The_List.First;
      Temp: Index:=Header.Next;
   begin
      Header.Next:=new Node;
      Header.Next.Value := Value;
      Header.Next.Next:=Temp;
      The_List.Num:=The_List.Num+1;
   end Stack;


   procedure Add
     (Value : in Element;
      The_List : in out List)
   is
      Last : Index:=The_List.First;
   begin
      while Last.Next/=null loop

         Last:=Last.Next;
      end loop;
      Last.Next:=new Node;
      Last.Next.Value:=Value;
      The_List.Num:=The_List.Num+1;
   end Add;


   procedure Insert_Before
     (The_Index   : in Index;
      Value   : in Element;
      The_List      : in out List)
   is
      Temp:Index;
   begin
      if The_Index=null or else The_Index.Next=null
      then
         raise List_Exceptions.Invalid_Index;
      else
         Temp:=The_Index.Next;
         The_Index.Next:=new Node;
         The_Index.Next.Value := Value;
         The_Index.Next.Next:=Temp;
         The_List.Num:=The_List.Num+1;
      end if;
   end Insert_Before;

   procedure Update
     (The_Index   : in Index;
      New_Value   : in Element;
      The_List      : in out List)
   is
   begin
      if The_Index=null or else The_Index.Next=null
      then
         raise List_Exceptions.Invalid_Index;
      else
         The_Index.Next.Value:=New_Value;
      end if;
   end Update;


   procedure Delete (The_Index: in Index;
                     The_List   : in out List;
                     Value: out Element) is
   begin
      if The_Index=null or else The_Index.Next=null then
         raise List_Exceptions.Invalid_Index;
      else
         Value:=The_Index.Next.Value;
         The_Index.Next:=The_Index.Next.Next;
         The_List.Num:=The_List.Num-1;
      end if;
   end Delete;

   function Empty (The_List : in List) return Boolean is
   begin
      return The_List.First.Next=null;
   end Empty;


   function Last (The_List : in List) return Index is

      P : Index:= The_List.First;

   begin
      if P=null or else P.Next=null then
         return Null_Index;
      else
         while P.Next.Next/=null loop
            P:=P.Next;
         end loop;
         return P;
      end if;
   end Last;


   function Find (Value: in Element;
                  The_List   : in List)
                 return Index is

      P : Index:= The_List.First;

   begin
      if P/=null then
         while P.Next/=null loop
            if P.Next.Value = Value then
               return P;
            else
               P:=P.Next;
            end if;
         end loop;
      end if;
      return Null_Index; -- No encontrado
   end Find;


   function Item(The_Index : in Index;
                 The_List : in List)
                return Element is
   begin
      if The_Index=null or else The_Index.Next=null then
         raise List_Exceptions.Invalid_Index;
      else
         return The_Index.Next.Value;
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
                            Iterator : in out Index) is
   begin
      if Iterator=null or else Iterator.Next=null then
         raise List_Exceptions.No_More_Items;
      else
         Iterator:=Iterator.Next;
         Value:= Iterator.Value;
      end if;
   end Get_Next_Item;

end Dynamic_Lists;



