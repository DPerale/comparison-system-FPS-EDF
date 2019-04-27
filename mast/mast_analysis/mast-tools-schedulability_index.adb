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

with Ada.Text_Io,Ada.Float_Text_Io,Mast.Timing_Requirements,
  Mast.Graphs,Mast.Results,Mast.Graphs.Links;
use Ada.Text_Io,Ada.Float_Text_Io;

package body MAST.Tools.Schedulability_Index is

   ----------
   -- "<=" --
   ----------

   function "<=" (Left, Rigth : Index) return Boolean is
   begin
      return Float(Left) <= Float(Rigth);
   end "<=";

   ---------
   -- ">" --
   ---------

   function ">" (Left, Rigth : Index) return Boolean is
   begin
      return Float(Left) > Float(Rigth);
   end ">";

   ------------------------------------------------
   -- Calculate_Transaction_Schedulability_Index --
   ------------------------------------------------

   procedure Calculate_Transaction_Schedulability_Index
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      The_Index : out Index;
      Verbose : in Boolean:=True)
   is
      A_Link_Ref : Graphs.Link_Ref;
      Link_Iterator : Transactions.Link_Iteration_Object;
      A_Timing_Req_Ref : Timing_Requirements.Timing_Requirement_Ref;
      A_Result_Ref : Results.Timing_Result_Ref;
      Acum_Index,Temp_Index : Index := Lower_Index;
      Counter : Integer := 0;
   begin
      -- Evaluate index for timing requirements of external event links
      Transactions.Rewind_External_Event_Links
        (Trans_Ref.all,Link_Iterator);
      for I in 1..Transactions.Num_Of_External_Event_Links
        (Trans_Ref.all)
      loop
         Transactions.Get_Next_External_Event_Link
           (Trans_Ref.all,A_Link_Ref,Link_Iterator);
         if Graphs.Has_Timing_Requirements(A_Link_Ref.all) and then
           Graphs.Has_Results(A_Link_Ref.all) then
            A_Timing_Req_Ref := Graphs.Links.Link_Timing_Requirements
              (Graphs.Links.Regular_Link(A_Link_Ref.all));
            A_Result_Ref := Graphs.Links.Link_Time_Results
              (Graphs.Links.Regular_Link(A_Link_Ref.all));
            Mast.Timing_Requirements.Schedulability_Index
              (A_Timing_Req_Ref.all,Results.Timing_Result(A_Result_Ref.all),
               Float(Temp_Index));
            Acum_Index := Acum_Index+Temp_Index;
            Counter := Counter+1;
         end if;
      end loop;

      -- Evaluate index for timing requirements of internal event links
      Transactions.Rewind_Internal_Event_Links
        (Trans_Ref.all,Link_Iterator);
      for I in 1..Transactions.Num_Of_Internal_Event_Links
        (Trans_Ref.all)
      loop
         Transactions.Get_Next_Internal_Event_Link
           (Trans_Ref.all,A_Link_Ref,Link_Iterator);
         if Graphs.Has_Timing_Requirements(A_Link_Ref.all) and then
           Graphs.Has_Results(A_Link_Ref.all) then
            A_Timing_Req_Ref := Graphs.Links.Link_Timing_Requirements
              (Graphs.Links.Regular_Link(A_Link_Ref.all));
            A_Result_Ref := Graphs.Links.Link_Time_Results
              (Graphs.Links.Regular_Link(A_Link_Ref.all));
            Mast.Timing_Requirements.Schedulability_Index
              (A_Timing_Req_Ref.all,Results.Timing_Result(A_Result_Ref.all),
               Float(Temp_Index));
            Acum_Index := Acum_Index+Temp_Index;
            Counter := Counter+1;
         end if;
      end loop;

      if Counter /= 0 then
         The_Index := Acum_Index/Index(Counter);
      else
         The_Index := Index'Last;
      end if;

   end Calculate_Transaction_Schedulability_Index;

   ------------------------------------
   -- Calculate_Schedulability_Index --
   ------------------------------------

   procedure Calculate_Schedulability_Index
     (The_System : in out MAST.Systems.System;
      The_Index : out Index;
      Verbose : in Boolean:=True)
   is
      A_Trans_Ref : Transactions.Transaction_Ref;
      Trans_Iterator : Transactions.Lists.Index;
      Acum_Index,Temp_Index : Index := Lower_Index;
      Counter : Integer := 0;
   begin
      -- loop for every transaction
      MAST.Transactions.Lists.Rewind
        (The_System.Transactions,Trans_Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (A_Trans_Ref,The_System.Transactions,Trans_Iterator);
         Calculate_Transaction_Schedulability_Index
           (A_Trans_Ref,Temp_Index,Verbose);
         if Temp_Index /= Index'Last then
            Acum_Index := Acum_Index+Temp_Index;
            Counter := Counter+1;
         end if;
      end loop;
      if Counter /= 0 then
         The_Index := Acum_Index/Index(Counter);
         if Verbose then
            Put("The schedulability index is: ");
            Print(The_Index);
         end if;
      else
         The_Index := Index'Last;
         if Verbose then
            Put("The schedulability index is: ");
            Print(The_Index);
         end if;
      end if;

   exception
      when Mast.Timing_Requirements.Inconclusive =>
         if Verbose then
            Put_Line("The schedulability index are not conclusive.");
         end if;
         raise Inconclusive;

   end Calculate_Schedulability_Index;

   -----------
   -- Print --
   -----------

   procedure Print (The_Index : Index) is
   begin
      Ada.Float_Text_Io.Put(Item=>Float(The_Index),Aft=>3,Exp=>0);
      New_Line;
   end Print;

   --------------
   -- To_Float --
   --------------

   function To_Float (Ind : Index) return Float is
   begin
      return Float(Ind);
   end;

end MAST.Tools.Schedulability_Index;

