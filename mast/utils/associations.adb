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

package body Associations is

   use type Relation_Sets.Index;

   ------------------
   -- Add_Relation --
   ------------------

   procedure Add_Relation (E1,E2 : Element; Assoc : in out Association)
   is

      procedure Add_Elements (From, To : Relation_Set_Ref)
      is
         E : Element;
         Iterator : Relation_Sets.Index;
      begin
         Relation_Sets.Rewind(From.all,Iterator);
         for I in 1..Relation_Sets.Size(From.all) loop
            Relation_Sets.Get_Next_Item(E,From.all,Iterator);
            if Relation_Sets.Find(E,To.all)=Relation_Sets.Null_Index then
               Relation_Sets.Add(E,To.all);
            end if;
         end loop;
      end Add_Elements;

      Set : Relation_Set_Ref;
      Found : Boolean:=False;
      Inserted_Element : Element;
      Set_Where_Inserted, Void : Relation_Set_Ref;
      Current : Assoc_Sets.Index;
      Iterator : Assoc_Sets.Iteration_Object;
   begin
      -- iterate over all relation sets
      Assoc_Sets.Rewind(Assoc.Relation_Sets,Iterator);
      for I in 1..Assoc_Sets.Size(Assoc.Relation_Sets) loop
         Current:=Iterator;
         Assoc_Sets.Get_Next_Item
           (Set,Assoc.Relation_Sets,Iterator);
         if not Found then
            if Relation_Sets.Find(E1,Set.all)/=Relation_Sets.Null_Index then
               if Relation_Sets.Find(E2,Set.all)/=Relation_Sets.Null_Index then
                  return;
               else
                  Relation_Sets.Add(E2,Set.all);
                  Found:=True;
                  Inserted_Element:=E2;
                  Set_Where_Inserted:=Set;
               end if;
            elsif Relation_Sets.Find(E2,Set.all)/=Relation_Sets.Null_Index then
               Relation_Sets.Add(E1,Set.all);
               Found:=True;
               Inserted_Element:=E1;
               Set_Where_Inserted:=Set;
            end if;
         else
            if Relation_Sets.Find(Inserted_Element,Set.all)/=
              Relation_Sets.Null_Index
            then
               Add_Elements(From => Set, To => Set_Where_Inserted);
               Assoc_Sets.Delete(Current,Assoc.Relation_Sets,Void);
               return;
            end if;
         end if;
      end loop;
      if not Found then
         Set:=new Relation_Sets.List;
         Relation_Sets.Init(Set.all);
         Relation_Sets.Add(E1,Set.all);
         Relation_Sets.Add(E2,Set.all);
         Assoc_Sets.Add(Set,Assoc.Relation_Sets);
      end if;
   end Add_Relation;

   ---------------------------
   -- Get_Next_Relation_Set --
   ---------------------------

   procedure Get_Next_Relation_Set
     (Assoc : in Association;
      Set : out Relation_Set_Ref;
      Iterator : in out Rel_Set_Iteration_Object)
   is
   begin
      Assoc_Sets.Get_Next_Item(Set,Assoc.Relation_Sets,
                               Assoc_Sets.Iteration_Object(Iterator));
   end Get_Next_Relation_Set;

   ----------
   -- Init --
   ----------

   procedure Init (Assoc : in out Association) is

   begin
      Assoc_Sets.Init(Assoc.Relation_Sets);
   end Init;

   --------------------------
   -- Num_Of_Relation_Sets --
   --------------------------

   function Num_Of_Relation_Sets (Assoc : Association) return Natural is
   begin
      return Assoc_Sets.Size (Assoc.Relation_Sets);
   end Num_Of_Relation_Sets;

   --------------------------
   -- Rewind_Relation_Sets --
   --------------------------

   procedure Rewind_Relation_Sets
     (Assoc : in Association;
      Iterator : out Rel_Set_Iteration_Object) is
   begin
      Assoc_Sets.Rewind(Assoc.Relation_Sets,
                        Assoc_Sets.Iteration_Object(Iterator));
   end Rewind_Relation_Sets;

end Associations;

