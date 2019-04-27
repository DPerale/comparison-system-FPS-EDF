-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2008                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors: Michael Gonzalez       mgh@unican.es                     --
--          Jose Javier Gutierrez  gutierjj@unican.es                --
--          Jose Carlos Palencia   palencij@unican.es                --
--          Jose Maria Drake       drakej@unican.es                  --
--          Julio Luis Medina      medinajl@unican.es                --
--          Yago Pereiro                                             --
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

package body Mast.Schedulers is

   use type Processing_Resources.Processing_Resource_Ref;

   -----------
   -- Clone --
   -----------

   function Clone
     (The_List : in Lists.List)
     return Lists.List
   is
      The_Copy : Lists.List;
      Iterator : Lists.Iteration_Object;
      Res_Ref, Res_Ref_Copy : Scheduler_Ref;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Res_Ref_Copy:=Clone(Res_Ref.all);
         Lists.Add(Res_Ref_Copy,The_Copy);
      end loop;
      return The_Copy;
   end Clone;

   ----------
   -- Init --
   ----------

   procedure Init (Sch : in out Scheduler;
                   Name : Var_Strings.Var_String)
   is
   begin
      Sch.Name:=Name;
   end Init;

   ----------
   -- Name --
   ----------

   function Name (Sch : Scheduler )
                 return Var_Strings.Var_String
   is
   begin
      return Sch.Name;
   end Name;

   ----------
   -- Name --
   ----------

   function Name
     (Sch_Ref : Scheduler_Ref)
     return Var_Strings.Var_String
   is
   begin
      return Sch_Ref.Name;
   end Name;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Sch : in out Scheduler;
      Indentation : Positive;
      Finalize    : Boolean:=False) is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"Scheduler (");
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Sch_Ref : Scheduler_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Sch_Ref,The_List,Iterator);
         Print(File,Sch_Ref.all,Indentation,True);
         Ada.Text_IO.New_Line(File);
      end loop;
   end Print;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Sch_Ref : Scheduler_Ref;
      Iterator : LIsts.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Sch_Ref,The_List,Iterator);
         Print_XML(File,Sch_Ref.all,Indentation,True);
         Ada.Text_IO.New_Line(File);
      end loop;
   end Print_XML;

   ---------------------------
   -- Scheduling_Policy     --
   ---------------------------

   function Scheduling_Policy
     (Sch : Scheduler)
     return Mast.Scheduling_Policies.Scheduling_Policy_Ref
   is
   begin
      return Sch.Policy;
   end Scheduling_Policy;

   ---------------------------
   -- Set_Scheduling_Policy --
   ---------------------------

   procedure Set_Scheduling_Policy
     (Sch : in out Scheduler;
      The_Policy : Mast.Scheduling_Policies.Scheduling_Policy_Ref)
   is
   begin
      Sch.Policy:=The_Policy;
   end Set_Scheduling_Policy;

   ------------------------------------------
   -- List_References_Processing_Resource  --
   ------------------------------------------

   function List_References_Processing_Resource
     (Pr_Ref : Mast.Processing_Resources.Processing_Resource_Ref;
      The_List : Lists.List)
     return Boolean
   is
      Sched_Ref : Scheduler_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Sched_Ref,The_List,Iterator);
         if Host(Sched_Ref.all)=Pr_Ref then
            return True;
         end if;
      end loop;
      return False;
   end List_References_Processing_Resource;


end Mast.Schedulers;
