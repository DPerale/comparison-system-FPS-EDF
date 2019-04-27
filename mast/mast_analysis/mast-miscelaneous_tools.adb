-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2005                     --
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

with Mast.Tool_Exceptions,Mast.Transactions,Mast.Shared_Resources,
  Mast.Graphs.Event_Handlers,Mast.Graphs.Links,Mast.Scheduling_Servers,
  Mast.Scheduling_Parameters,Mast.Operations,Mast.Transaction_Operations,
  Mast.Graphs,Mast.Results,Mast.Processing_Resources,
  Mast.Processing_Resources.Processor, Mast.Processing_Resources.Network,
  Mast.Schedulers, Mast.Scheduling_Policies,
  Mast.Synchronization_Parameters,
  Mast.Restrictions,
  Mast.Systems,
  Mast.IO, Mast.Linear_Translation, Mast.Max_Numbers,
  Mast.Timing_Requirements, Priority_Queues,
  Hash_Lists,Doubly_Linked_Lists,Associations,Indexed_Lists,
  Ada.Text_IO,Var_Strings;
use Ada.Text_IO,Var_Strings;
use type Mast.Shared_Resources.Shared_Resource_Ref;
use type Mast.Graphs.Link_Ref;
use type Mast.Graphs.Event_Handler_Ref;
use type Mast.Scheduling_Servers.Scheduling_Server_Ref;
use type Mast.Processing_Resources.Processing_Resource_Ref;
use type Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
use type Mast.Synchronization_Parameters.Synch_Parameters_Ref;
use type Mast.Systems.PIP_Behaviour;

package body MAST.Miscelaneous_Tools is

   Ceiling_Out_Of_Range : exception;

   type Ceiling_And_Level is record
      Ceiling : Priority;
      Level   : Preemption_Level;
   end record;

   package Ceiling_Lists is new Hash_Lists
     (Index   => Shared_Resources.Shared_Resource_Ref,
      Element => Ceiling_And_Level,
        "="     => "=");

   type Resource_Kind is (Global, Local);

   type Resource_Kind_Data is record
      Kind : Resource_Kind;
      First_Proc : Processing_Resources.Processing_Resource_Ref;
   end record;

   package Resource_Kind_Lists is new Hash_Lists
     (Index   => Shared_Resources.Shared_Resource_Ref,
      Element => Resource_Kind_Data,
        "="     => "=");

   package Resource_Associations is new Associations
     (Element => Shared_Resources.Shared_Resource_Ref,
        "="     => "=");

   package Resource_Lists is new Doubly_Linked_Lists
     (Element => MAST.Shared_Resources.Shared_Resource_Ref,
        "="     => "=");

   type Critical_Section is record
      Srvr : Scheduling_Servers.Scheduling_Server_Ref;
      Resource : Shared_Resources.Shared_Resource_Ref;
      Ceiling : Priority;
      Level : Preemption_Level;
      Kind : Resource_Kind;
      Length : Time;
   end record;

   function "=" (S1,S2 : Critical_Section) return Boolean is
   begin
      return S1.Resource=S2.Resource;
   end "=";

   package Critical_Section_Lists is new Doubly_Linked_Lists
     (Element => Critical_Section,
        "="     => "=");

   package Inheritance_Section_Task_Lists is new Hash_Lists
     (Index   => Scheduling_Servers.Scheduling_Server_Ref,
      Element => Time,
        "="     => "=");

   package Inheritance_Section_Resource_Lists is new Hash_Lists
     (Index   => Shared_Resources.Shared_Resource_Ref,
      Element => Time,
        "="     => "=");

   package Global_Res_Lists is new Indexed_Lists
     (Element => Shared_Resources.Shared_Resource_Ref,
        "=" => "=");

   use type Resource_Lists.Index;


   ------------------------------
   -- Null_Op                  --
   ------------------------------

   procedure Null_Op
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      The_Link_Ref : MAST.Graphs.Link_Ref) is
   begin
      null;
   end Null_Op;

   ------------------------------
   -- Consider_Overlaps       --
   ------------------------------

   procedure Consider_Overlaps
     (The_System :in Mast.Systems.System;
      Verbose : in Boolean:=True;
      Ceil_List : in out Ceiling_Lists.List)
   is

      procedure Process_Operation_Resources
        (The_Operation_Ref : MAST.Operations.Operation_Ref;
         Locked_Resources : in out Resource_Lists.List;
         Assoc : in out Resource_Associations.Association)
      is
         An_Act_Ref : MAST.Operations.Operation_Ref;
         Res_Ref,First_Res_Ref : MAST.Shared_Resources.Shared_Resource_Ref;
         The_Res_Index : Resource_Lists.Index;
         Res_Lock_Iterator : Operations.Resource_Iteration_Object;
         Op_Iterator : Operations.Operation_Iteration_Object;
         Res_List_Iterator : Resource_Lists.Index;
      begin
         if The_Operation_Ref.all in
           MAST.Operations.Simple_Operation'Class
         then
            -- check locked resources
            MAST.Operations.Rewind_Locked_Resources
              (MAST.Operations.Simple_Operation
               (The_Operation_Ref.all),Res_Lock_Iterator);
            for I in 1..MAST.Operations.Num_Of_Locked_Resources
              (MAST.Operations.Simple_Operation(The_Operation_Ref.all))
            loop
               MAST.Operations.Get_Next_Locked_Resource
                 (MAST.Operations.Simple_Operation
                  (The_Operation_Ref.all),
                  Res_Ref,Res_Lock_Iterator);
               if Res_Ref.all in
                 Shared_Resources.Priority_Inheritance_Resource'Class
               then
                  Resource_Lists.Add(Res_Ref,Locked_Resources);
                  if Resource_Lists.Size(Locked_Resources)>1 then
                     Resource_Lists.Rewind
                       (Locked_Resources,Res_List_Iterator);
                     Resource_Lists.Get_Next_Item
                       (First_Res_Ref,Locked_Resources,Res_List_Iterator);
                     Resource_Associations.Add_Relation
                       (First_Res_Ref,Res_Ref,Assoc);
                  end if;
               end if;
            end loop;
            -- check unlocked resources
            MAST.Operations.Rewind_Unlocked_Resources
              (MAST.Operations.Simple_Operation(The_Operation_Ref.all),
               Res_Lock_Iterator);
            for I in 1..MAST.Operations.Num_Of_Unlocked_Resources
              (MAST.Operations.Simple_Operation(The_Operation_Ref.all))
            loop
               MAST.Operations.Get_Next_Unlocked_Resource
                 (MAST.Operations.Simple_Operation(The_Operation_Ref.all),
                  Res_Ref,Res_Lock_Iterator);
               if Res_Ref.all in
                 Shared_Resources.Priority_Inheritance_Resource'Class
               then
                  The_Res_Index:= Resource_Lists.Find
                    (Res_Ref,Locked_Resources);
                  Resource_Lists.Delete
                    (The_Res_Index,Locked_Resources,Res_Ref);
               end if;
            end loop;

         elsif The_Operation_Ref.all in
           MAST.Operations.Composite_Operation'Class
         then
            -- Iterate over all Operations
            MAST.Operations.Rewind_Operations
              (MAST.Operations.Composite_Operation(The_Operation_Ref.all),
               Op_Iterator);
            for I in 1..MAST.Operations.Num_Of_Operations
              (MAST.Operations.Composite_Operation(The_Operation_Ref.all))
            loop
               MAST.Operations.Get_Next_Operation
                 (MAST.Operations.Composite_Operation
                  (The_Operation_Ref.all),
                  An_Act_Ref,Op_Iterator);
               Process_Operation_Resources
                 (An_Act_Ref,Locked_Resources,Assoc);
            end loop;
         elsif The_Operation_Ref.all in
           Operations.Message_Transmission_Operation'Class
         then
            null; -- message operations have no shared resources
         else
            raise Incorrect_Object;
         end if;
      end Process_Operation_Resources;

      procedure Traverse_Paths_From_Link
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Link_Ref : MAST.Graphs.Link_Ref;
         Locked_Resources : in out Resource_Lists.List;
         Assoc : in out Resource_Associations.Association)
      is
         An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
         Next_Link_Ref : MAST.Graphs.Link_Ref;
         Cloned_Locked_Resources : Resource_Lists.List;
         Iterator : Graphs.Event_Handlers.Iteration_Object;
      begin
         if The_Link_Ref=null then
            return;
         end if;
         An_Event_Handler_Ref:=MAST.Graphs.Output_Event_Handler
           (The_Link_Ref.all);
         if An_Event_Handler_Ref/=null then
            if An_Event_Handler_Ref.all in
              MAST.Graphs.Event_Handlers.Simple_Event_Handler'Class
            then
               if An_Event_Handler_Ref.all in
                 MAST.Graphs.Event_Handlers.Activity'Class
               then
                  Process_Operation_Resources
                    (MAST.Graphs.Event_Handlers.Activity_Operation
                     (MAST.Graphs.Event_Handlers.Activity
                      (An_Event_Handler_Ref.all)),
                     Locked_Resources,Assoc);
               end if;
               Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
                 (MAST.Graphs.Event_Handlers.Simple_Event_Handler
                  (An_Event_Handler_Ref.all));
               Traverse_Paths_From_Link
                 (Trans_Ref,Next_Link_Ref,Locked_Resources,Assoc);
            elsif An_Event_Handler_Ref.all in
              MAST.Graphs.Event_Handlers.Output_Event_Handler'Class
            then
               MAST.Graphs.Event_Handlers.Rewind_Output_Links
                 (MAST.Graphs.Event_Handlers.Output_Event_Handler
                  (An_Event_Handler_Ref.all),Iterator);
               for I in 1..MAST.Graphs.Event_Handlers.Num_Of_Output_Links
                 (MAST.Graphs.Event_Handlers.Output_Event_Handler
                  (An_Event_Handler_Ref.all))
               loop
                  MAST.Graphs.Event_Handlers.Get_Next_Output_Link
                    (MAST.Graphs.Event_Handlers.Output_Event_Handler
                     (An_Event_Handler_Ref.all),
                     Next_Link_Ref,Iterator);
                  Cloned_Locked_Resources:=Resource_Lists.Clon
                    (Locked_Resources);
                  Traverse_Paths_From_Link
                    (Trans_Ref,Next_Link_Ref,
                     Cloned_Locked_Resources,Assoc);
               end loop;
            else -- input Event_Handler
               Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
                 (MAST.Graphs.Event_Handlers.Input_Event_Handler
                  (An_Event_Handler_Ref.all));
               Traverse_Paths_From_Link
                 (Trans_Ref,Next_Link_Ref,Locked_Resources,Assoc);
            end if;
         end if;
      end Traverse_Paths_From_Link;

      Locked_Resources : Resource_Lists.List;
      A_Link_Ref : MAST.Graphs.Link_Ref;
      Assoc : Resource_Associations.Association;
      Set : Resource_Associations.Relation_Set_Ref;
      Trans_Ref : Transactions.Transaction_Ref;
      Res_Ref : Shared_Resources.Shared_Resource_Ref;
      Max_Ceil : Priority;
      Max_Level: Preemption_Level;
      Changed : Boolean:=False;
      Trans_Iterator : Transactions.Lists.Index;
      Link_Iterator : Transactions.Link_Iteration_Object;
      Set_Iterator : Resource_Associations.Relation_Sets.Index;
      Assoc_Iterator : Resource_Associations.Rel_Set_Iteration_Object;
      Current : Ceiling_And_Level;
      Do_Update : Boolean;
   begin
      Resource_Associations.Init(Assoc);
      -- Build resource associations
      -- loop for every transaction
      MAST.Transactions.Lists.Rewind(The_System.Transactions,Trans_Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Trans_Iterator);

         -- loop for each path in the transaction
         Transactions.Rewind_External_Event_Links(Trans_Ref.all,Link_Iterator);
         for I in 1..Transactions.Num_Of_External_Event_Links
           (Trans_Ref.all)
         loop
            Transactions.Get_Next_External_Event_Link
              (Trans_Ref.all,A_Link_Ref,Link_Iterator);
            Resource_Lists.Init(Locked_Resources);
            Traverse_Paths_From_Link
              (Trans_Ref,A_Link_Ref,Locked_Resources,Assoc);
         end loop;
      end loop;

      -- process associations
      Resource_Associations.Rewind_Relation_Sets(Assoc,Assoc_Iterator);
      for I in 1..Resource_Associations.Num_Of_Relation_Sets(Assoc) loop
         Resource_Associations.Get_Next_Relation_Set(Assoc,Set,Assoc_Iterator);
         -- find maximum ceiling and level in set
         Max_Ceil:=Priority'First;
         Max_Level:=Preemption_Level'First;
         -- loop for all elements in the relation set
         Resource_Associations.Relation_Sets.Rewind(Set.all,Set_Iterator);
         for J in 1..Resource_Associations.Relation_Sets.Size(Set.all) loop
            Resource_Associations.Relation_Sets.Get_Next_Item
              (Res_Ref,Set.all,Set_Iterator);
            if Max_Ceil < Ceiling_Lists.Item(Res_Ref,Ceil_List).Ceiling then
               Max_Ceil:=Ceiling_Lists.Item(Res_Ref,Ceil_List).Ceiling;
            end if;
            if Max_Level < Ceiling_Lists.Item(Res_Ref,Ceil_List).Level then
               Max_Level:=Ceiling_Lists.Item(Res_Ref,Ceil_List).Level;
            end if;
         end loop;
         -- set all ceilings in set to max ceiling
         -- ald all levels in set to max level
         -- loop for all elements in the relation set
         Resource_Associations.Relation_Sets.Rewind(Set.all,Set_Iterator);
         for J in 1..Resource_Associations.Relation_Sets.Size(Set.all) loop
            Resource_Associations.Relation_Sets.Get_Next_Item
              (Res_Ref,Set.all,Set_Iterator);
            Current:=Ceiling_Lists.Item(Res_Ref,Ceil_List);
            Do_Update:=False;
            if Max_Ceil > Current.Ceiling then
               Current.Ceiling:=Max_Ceil;
               Do_Update:=True;
            end if;
            if Max_Level > Current.Level then
               Current.Level:=Max_Level;
               Do_Update:=True;
            end if;
            if Do_Update then
               Ceiling_Lists.Update(Res_Ref,Current,Ceil_List);
               Changed:=True;
            end if;
         end loop;
      end loop;
      if Changed then
         Consider_Overlaps(The_System,Verbose,Ceil_List);
      else
         if Verbose then
            Resource_Associations.Rewind_Relation_Sets(Assoc,Assoc_Iterator);
            for I in 1..Resource_Associations.Num_Of_Relation_Sets(Assoc) loop
               if I=1 then
                  Put_Line("Resources whose ceilings are linked by "&
                           "transitive inheritance:");
               end if;
               Put("Resources: ");
               Resource_Associations.Get_Next_Relation_Set
                 (Assoc,Set,Assoc_Iterator);
               -- loop for all elements in the relation set
               Resource_Associations.Relation_Sets.Rewind
                 (Set.all,Set_Iterator);
               for J in 1..Resource_Associations.Relation_Sets.Size(Set.all)
               loop
                  Resource_Associations.Relation_Sets.Get_Next_Item
                    (Res_Ref,Set.all,Set_Iterator);
                  if J/=1 then
                     Put(',');
                  end if;
                  Put(Shared_Resources.Name(Res_Ref));
               end loop;
               New_Line;
            end loop;
         end if;
      end if;
   end Consider_Overlaps;

   ------------------------------
   -- Calculate_Ceilings       --
   ------------------------------

   procedure Calculate_Ceilings
     (The_System : in Mast.Systems.System;
      Verbose : in Boolean:=True;
      Ceil_List : out Ceiling_Lists.List;
      Res_Kind_List : in Resource_Kind_Lists.List)
   is

      procedure Calculate_Ceilings
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref)
      is

         procedure Calculate_Ceilings_For_Operation
           (Op_Ref : Operations.Operation_Ref;
            Prio_And_Level : Ceiling_And_Level;
            Max_Task_Prio : Priority)
         is
            An_Op_Ref : Operations.Operation_Ref;
            Res_Ref : Shared_Resources.Shared_Resource_Ref;
            Res_Iterator : Operations.Resource_Iteration_Object;
            Op_Iterator : Operations.Operation_Iteration_Object;
            Current : Ceiling_And_Level;
            Do_Update : Boolean;
         begin
            if Op_Ref.all in Operations.Simple_Operation'Class then
               Operations.Rewind_Locked_Resources
                 (Operations.Simple_Operation(Op_Ref.all),Res_Iterator);
               for I in 1..Operations.Num_Of_Locked_Resources
                 (Operations.Simple_Operation(Op_Ref.all))
               loop
                  Operations.Get_Next_Locked_Resource
                    (Operations.Simple_Operation(Op_Ref.all),
                     Res_Ref,Res_Iterator);
                  if Res_Ref.all in
                    Shared_Resources.Immediate_Ceiling_Resource'Class
                    and then
                    Resource_Kind_Lists.Item
                    (Res_Ref,Res_Kind_List).Kind=Global
                  then
                     Ceiling_Lists.Update
                       (Res_Ref,(Max_Task_Prio,Preemption_Level'Last),
                        Ceil_List);
                  else
                     Current:=Ceiling_Lists.Item(Res_Ref,Ceil_List);
                     Do_Update:=False;
                     if Prio_And_Level.Ceiling > Current.Ceiling then
                        Current.Ceiling:=Prio_And_Level.Ceiling;
                        Do_Update:=True;
                     end if;
                     if Prio_And_Level.Level > Current.Level then
                        Current.Level:=Prio_And_Level.Level;
                        Do_Update:=True;
                     end if;
                     if Do_Update then
                        Ceiling_Lists.Update(Res_Ref,Current,Ceil_List);
                     end if;
                  end if;
               end loop;
            elsif Op_Ref.all in Operations.Composite_Operation'Class then
               Operations.Rewind_Operations
                 (Operations.Composite_Operation(Op_Ref.all),Op_Iterator);
               for I in 1..Operations.Num_Of_Operations
                 (Operations.Composite_Operation(Op_Ref.all))
               loop
                  Operations.Get_Next_Operation
                    (Operations.Composite_Operation(Op_Ref.all),
                     An_Op_Ref,Op_Iterator);
                  Calculate_Ceilings_For_Operation
                    (An_Op_Ref,Prio_And_Level,Max_Task_Prio);
               end loop;
            elsif Op_Ref.all in Operations.Message_Transmission_Operation'Class
            then
               null; -- message operations have no shared resources
            else
               if Verbose then
                  Put_Line("Error in Calculate_Ceilings_For_Operation");
               end if;
               raise Incorrect_Object;
            end if;
         end Calculate_Ceilings_For_Operation ;

         Op_Ref : Operations.Operation_Ref;
         Sched_Params_Ref : Scheduling_Parameters.Sched_Parameters_Ref;
         Max_Task_Prio : Priority;
         Prio_And_Level : Ceiling_And_Level;
         SS_Ref : Scheduling_Servers.Scheduling_Server_Ref;
         Synch_P_Ref : Synchronization_Parameters.Synch_Parameters_Ref;
      begin
         if The_Event_Handler_Ref.all in Graphs.Event_Handlers.Activity'Class
         then
            Max_Task_Prio:=Schedulers.Max_Priority
                (Scheduling_Servers.Server_Scheduler
                 (Graphs.Event_Handlers.Activity_Server
                  (Graphs.Event_Handlers.Activity
                   (The_Event_Handler_Ref.all)).all).all);
            Op_Ref:=Graphs.Event_Handlers.Activity_Operation
              (Graphs.Event_Handlers.Activity(The_Event_Handler_Ref.all));
            SS_Ref:=Graphs.Event_Handlers.Activity_Server
              (Graphs.Event_Handlers.Activity
               (The_Event_Handler_Ref.all));
            Sched_Params_Ref:=Scheduling_Servers.Server_Sched_Parameters
              (SS_Ref.all);
            if Sched_Params_Ref.all not in
              Scheduling_Parameters.Fixed_Priority_Parameters'Class and then
              Sched_Params_Ref.all not in
              Scheduling_Parameters.EDF_Parameters'Class
            then
               if Verbose then
                  Put_Line("Error in Generic Calculate_Ceilings");
               end if;
               Tool_Exceptions.Set_Tool_Failure_Message
                 ("Found Incompatible Scheduling Parameters");
               raise Tool_Exceptions.Tool_Failure;
            end if;
            if Sched_Params_Ref.all in
              Scheduling_Parameters.Fixed_Priority_Parameters'Class
            then
               Prio_And_Level.Ceiling :=Scheduling_Parameters.The_Priority
                 (Scheduling_Parameters.Fixed_Priority_Parameters'Class
                  (Sched_Params_Ref.all));
            else
               Prio_And_Level.Ceiling:=Scheduling_Servers.Base_Priority
                 (SS_Ref.all);
            end if;
            Prio_And_Level.Level :=Preemption_Level'Last;
            Synch_P_Ref:=Scheduling_Servers.Server_Synch_Parameters
              (SS_Ref.all);
            if Synch_P_Ref/=null and then
              Synch_P_Ref.all in
              Synchronization_Parameters.SRP_Parameters'Class
            then
               Prio_And_Level.Level:=
                 Synchronization_Parameters.The_Preemption_Level
                 (Synchronization_Parameters.SRP_Parameters'Class
                  (Synch_P_Ref.all));
            end if;
            Calculate_Ceilings_For_Operation
              (Op_Ref,Prio_And_Level,Max_Task_Prio);
         end if;
      end Calculate_Ceilings;

      procedure Iterate_Transaction_Paths is new
        MAST.Transaction_Operations.Traverse_Paths_From_Link_Once
        (Operation_For_Links  => Null_Op,
         Operation_For_Event_Handlers => Calculate_Ceilings);

      A_Link_Ref : MAST.Graphs.Link_Ref;
      Trans_Ref : MAST.Transactions.Transaction_Ref;
      Res_Ref : Shared_Resources.Shared_Resource_Ref;
      Prio_And_Level : Ceiling_And_Level;
      Null_Ceil_List : Ceiling_Lists.List;
      Res_Iterator : Shared_Resources.Lists.Index;
      Trans_Iterator : Transactions.Lists.Index;
      Link_Iterator : Transactions.Link_Iteration_Object;
      Ceil_Iterator : Ceiling_Lists.Iteration_Object;
   begin
      Ceil_List:=Null_Ceil_List;

      -- Create resource list
      -- iterate over shared resources
      Shared_Resources.Lists.Rewind
        (The_System.Shared_Resources,Res_Iterator);
      for I in 1..Shared_Resources.Lists.Size(The_System.Shared_Resources)
      loop
         Shared_Resources.Lists.Get_Next_Item
           (Res_Ref,The_System.Shared_Resources,Res_Iterator);
         Ceiling_Lists.Add(Res_Ref,(Priority'First,Preemption_Level'First),
                           Ceil_List);
      end loop;

      -- Loop for every transaction
      MAST.Transactions.Lists.Rewind(The_System.Transactions,Trans_Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Trans_Iterator);
         -- loop for each path in the transaction
         Transactions.Rewind_External_Event_Links
           (Trans_Ref.all,Link_Iterator);
         for I in 1..Transactions.Num_Of_External_Event_Links
           (Trans_Ref.all)
         loop
            Transactions.Get_Next_External_Event_Link
              (Trans_Ref.all,A_Link_Ref,Link_Iterator);
            Iterate_Transaction_Paths(Trans_Ref,A_Link_Ref);
         end loop;
      end loop;

      -- Consider the effects of transitive priority inheritance
      Consider_Overlaps(The_System,Verbose,Ceil_List);

      if Verbose then
         -- Report all ceilings
         --iterate over resource list
         Put_Line("Optimum Resource Ceilings and Levels:");
         Ceiling_Lists.Rewind(Ceil_List,Ceil_Iterator);
         for I in 1..Ceiling_Lists.Size(Ceil_List)
         loop
            Ceiling_Lists.Get_Next_Item
              (Res_Ref,Prio_And_Level,Ceil_List,Ceil_Iterator);
            Put_Line(Shared_Resources.Name(Res_Ref)&" => "&
                     Priority'Image(Prio_And_Level.Ceiling)&
                     ","&Preemption_Level'Image(Prio_And_Level.Level));
         end loop;
      end if;
   end Calculate_Ceilings;

   -------------------------------
   -- Calculate_Resource_Kinds  --
   -------------------------------

   procedure Calculate_Resource_Kinds
     (The_System : in Mast.Systems.System;
      Verbose : in Boolean:=True;
      Res_Kind_List : out Resource_Kind_Lists.List;
      Check_Ceilings : Boolean:=False)
   is

      procedure Calculate_Kinds
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref)
      is

         procedure Calculate_Kind_For_Operation
           (Op_Ref : Operations.Operation_Ref;
            Proc_Ref : Processing_Resources.Processing_Resource_Ref;
            Sched_Ref : Schedulers.Scheduler_Ref)
         is
            An_Op_Ref : Operations.Operation_Ref;
            A_Res_Ref : Shared_Resources.Shared_Resource_Ref;
            Res_Iterator : Operations.Resource_Iteration_Object;
            Op_Iterator : Operations.Operation_Iteration_Object;
            Min_Prio, Max_Prio, Min_Int_Prio, Max_Int_Prio,Ceil : Priority;
         begin
            if Check_Ceilings then
               Max_Prio:=Schedulers.Max_Priority(Sched_Ref.all);
               Min_Prio:=Schedulers.Min_Priority(Sched_Ref.all);
               if Proc_Ref.all in
                 Processing_Resources.Processor.Regular_Processor'Class
               then
                  Max_Int_Prio:=
                    Processing_Resources.Processor.Max_Interrupt_Priority
                    (Processing_Resources.Processor.Regular_Processor'Class
                     (Proc_Ref.all));
                  Min_Int_Prio:=
                    Processing_Resources.Processor.Min_Interrupt_Priority
                    (Processing_Resources.Processor.Regular_Processor'Class
                     (Proc_Ref.all));
               else
                  Max_Int_Prio:=Priority'First;
                  Min_Int_Prio:=Priority'First;
               end if;
            end if;
            if Op_Ref.all in Operations.Simple_Operation'Class then
               Operations.Rewind_Locked_Resources
                 (Operations.Simple_Operation(Op_Ref.all),
                  Res_Iterator);
               for I in 1..Operations.Num_Of_Locked_Resources
                 (Operations.Simple_Operation(Op_Ref.all))
               loop
                  Operations.Get_Next_Locked_Resource
                    (Operations.Simple_Operation(Op_Ref.all),
                     A_Res_Ref,Res_Iterator);
                  -- check that ceiling is within range
                  if Check_Ceilings and then A_Res_Ref.all in
                    Shared_Resources.Immediate_Ceiling_Resource'Class
                  then
                     Ceil:=Shared_Resources.Ceiling
                       (Shared_Resources.Immediate_Ceiling_Resource'Class
                        (A_Res_Ref.all));
                     if Proc_Ref.all in
                       Processing_Resources.Processor.Processor'Class
                     then
                        if (Ceil not in Min_Int_Prio..Max_Int_Prio) and then
                          (Ceil not in Min_Prio..Max_Prio)
                        then
                           if Verbose then
                              Put_Line("Ceiling of shared resource "&
                                       Shared_Resources.Name(A_Res_Ref)&
                                       " is out of range");
                           end if;
                           raise Ceiling_Out_Of_Range;
                        end if;
                     else
                        if (Ceil not in Min_Prio..Max_Prio)
                        then
                           if Verbose then
                              Put_Line("Ceiling of shared resource "&
                                       Shared_Resources.Name(A_Res_Ref)&
                                       " is out of range");
                           end if;
                           raise Ceiling_Out_Of_Range;
                        end if;
                     end if;
                  end if;

                  -- add to list
                  if Resource_Kind_Lists.Item
                    (A_Res_Ref,Res_Kind_List).First_Proc=null
                  then
                     Resource_Kind_Lists.Update
                       (A_Res_Ref,(Local,Proc_Ref),Res_Kind_List);
                  else
                     if Resource_Kind_Lists.Item
                       (A_Res_Ref,Res_Kind_List).First_Proc/=Proc_Ref
                     then
                        Resource_Kind_Lists.Update
                          (A_Res_Ref,(Global,Proc_Ref),Res_Kind_List);
                     end if;
                  end if;
               end loop;
            elsif Op_Ref.all in Operations.Composite_Operation'Class then
               Operations.Rewind_Operations
                 (Operations.Composite_Operation(Op_Ref.all),Op_Iterator);
               for I in 1..Operations.Num_Of_Operations
                 (Operations.Composite_Operation(Op_Ref.all))
               loop
                  Operations.Get_Next_Operation
                    (Operations.Composite_Operation(Op_Ref.all),
                     An_Op_Ref,Op_Iterator);
                  Calculate_Kind_For_Operation
                    (An_Op_Ref,Proc_Ref,Sched_Ref);
               end loop;
            elsif Op_Ref.all in Operations.Message_Transmission_Operation'Class
            then
               null; -- message operations have no shared resources
            else
               if Verbose then
                  Put_Line("Error in Calculate_Kind_For_Operation");
               end if;
               raise Incorrect_Object;
            end if;
         end Calculate_Kind_For_Operation ;

         Op_Ref : Operations.Operation_Ref;
         Proc_Ref : Processing_Resources.Processing_Resource_Ref;
         Sched_Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
         Sched_Ref : Schedulers.Scheduler_Ref;
      begin
         if The_Event_Handler_Ref.all in Graphs.Event_Handlers.Activity'Class
         then
            Op_Ref:=Graphs.Event_Handlers.Activity_Operation
              (Graphs.Event_Handlers.Activity(The_Event_Handler_Ref.all));
            Sched_Srvr_Ref:=Graphs.Event_Handlers.Activity_Server
              (Graphs.Event_Handlers.Activity
               (The_Event_Handler_Ref.all));
            Proc_Ref:=Scheduling_Servers.Server_Processing_Resource
              (Sched_Srvr_Ref.all);
            Sched_Ref:=Scheduling_Servers.Server_Scheduler
              (Sched_Srvr_Ref.all);
            Calculate_Kind_For_Operation(Op_Ref,Proc_Ref,Sched_Ref);
         end if;
      end Calculate_Kinds;

      procedure Iterate_Transaction_Paths is new
        MAST.Transaction_Operations.Traverse_Paths_From_Link_Once
        (Operation_For_Links  => Null_Op,
         Operation_For_Event_Handlers => Calculate_Kinds);


      Res_Ref : Shared_Resources.Shared_Resource_Ref;
      A_Link_Ref : MAST.Graphs.Link_Ref;
      Trans_Ref : MAST.Transactions.Transaction_Ref;
      Res_Iterator : Shared_Resources.Lists.Index;
      Trans_Iterator : Transactions.Lists.Index;
      Link_Iterator : Transactions.Link_Iteration_Object;

   begin
      --iterate over shared resources
      Shared_Resources.Lists.Rewind
        (The_System.Shared_Resources,Res_Iterator);
      for I in 1..Shared_Resources.Lists.Size(The_System.Shared_Resources)
      loop
         Shared_Resources.Lists.Get_Next_Item
           (Res_Ref,The_System.Shared_Resources,Res_Iterator);
         Resource_Kind_Lists.Add(Res_Ref,(Local,null),Res_Kind_List);
      end loop;
      -- Loop for every transaction
      MAST.Transactions.Lists.Rewind
        (The_System.Transactions,Trans_Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Trans_Iterator);
         -- loop for each path in the transaction
         Transactions.Rewind_External_Event_Links
           (Trans_Ref.all,Link_Iterator);
         for I in 1..Transactions.Num_Of_External_Event_Links
           (Trans_Ref.all)
         loop
            Transactions.Get_Next_External_Event_Link
              (Trans_Ref.all,A_Link_Ref,Link_Iterator);
            Iterate_Transaction_Paths(Trans_Ref,A_Link_Ref);
         end loop;
      end loop;
   end Calculate_Resource_Kinds;

   ------------------------------------
   -- Calculate_Ceilings_And_Levels  --
   ------------------------------------

   procedure Calculate_Ceilings_And_Levels
     (The_System : in out Mast.Systems.System;
      Verbose : in Boolean:=True)
   is

      Res_Kind_List : Resource_Kind_Lists.List;

      procedure Calculate_Ceilings_And_Levels
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref)
      is

         procedure Calculate_Ceilings_And_Levels_For_Operation
           (Op_Ref : Operations.Operation_Ref;
            Prio_And_Level : Ceiling_And_Level;
            Max_Task_Prio : Priority)
         is
            An_Op_Ref : Operations.Operation_Ref;
            Res_Ref : Shared_Resources.Shared_Resource_Ref;
            Res_Iterator : Operations.Resource_Iteration_Object;
            Op_Iterator : Operations.Operation_Iteration_Object;
         begin
            if Op_Ref.all in Operations.Simple_Operation'Class then
               Operations.Rewind_Locked_Resources
                 (Operations.Simple_Operation(Op_Ref.all),
                  Res_Iterator);
               for I in 1..Operations.Num_Of_Locked_Resources
                 (Operations.Simple_Operation(Op_Ref.all))
               loop
                  Operations.Get_Next_Locked_Resource
                    (Operations.Simple_Operation(Op_Ref.all),
                     Res_Ref,Res_Iterator);
                  if Res_Ref.all in
                    Shared_Resources.Immediate_Ceiling_Resource'Class
                  then
                     if not Shared_Resources.Preassigned
                       (Shared_Resources.Immediate_Ceiling_Resource'Class
                        (Res_Ref.all))
                     then
                        if Resource_Kind_Lists.Item
                          (Res_Ref,Res_Kind_List).Kind=Global
                        then
                           Shared_Resources.Set_Ceiling
                             (Shared_Resources.Immediate_Ceiling_Resource'Class
                              (Res_Ref.all),Max_Task_Prio);
                        else -- local resource
                           if Prio_And_Level.Ceiling>Shared_Resources.Ceiling
                             (Shared_Resources.Immediate_Ceiling_Resource'Class
                              (Res_Ref.all))
                           then
                              Shared_Resources.Set_Ceiling
                                (Shared_Resources.
                                 Immediate_Ceiling_Resource'Class
                                 (Res_Ref.all),Prio_And_Level.Ceiling);
                           end if;
                        end if;
                     end if;
                  elsif Res_Ref.all in
                    Shared_Resources.SRP_Resource'Class
                  then
                     if not Shared_Resources.Preassigned
                       (Shared_Resources.SRP_Resource'Class
                        (Res_Ref.all))
                     then
                        if Prio_And_Level.Level>Shared_Resources.Level
                          (Shared_Resources.SRP_Resource'Class
                           (Res_Ref.all))
                        then
                           Shared_Resources.Set_Level
                             (Shared_Resources.SRP_Resource'Class
                              (Res_Ref.all),Prio_And_Level.Level);
                        end if;
                     end if;
                  end if;
               end loop;
            elsif Op_Ref.all in Operations.Composite_Operation'Class then
               Operations.Rewind_Operations
                 (Operations.Composite_Operation(Op_Ref.all),Op_Iterator);
               for I in 1..Operations.Num_Of_Operations
                 (Operations.Composite_Operation(Op_Ref.all))
               loop
                  Operations.Get_Next_Operation
                    (Operations.Composite_Operation(Op_Ref.all),
                     An_Op_Ref,Op_Iterator);
                  Calculate_Ceilings_And_Levels_For_Operation
                    (An_Op_Ref,Prio_And_Level,Max_Task_Prio);
               end loop;
            elsif Op_Ref.all in Operations.Message_Transmission_Operation'Class
            then
               null; -- message operations have no shared resources
            else
               if Verbose then
                  Put_Line
                    ("Error in Calculate_Ceilings_And_Levels_For_Operation");
               end if;
               raise Incorrect_Object;
            end if;
         end Calculate_Ceilings_And_Levels_For_Operation;

         Op_Ref : Operations.Operation_Ref;
         Sched_Params_Ref : Scheduling_Parameters.Sched_Parameters_Ref;
         SS_Ref : Scheduling_Servers.Scheduling_Server_Ref;
         Prio_And_Level : Ceiling_And_Level;
         Max_Task_Prio : Priority;
      begin
         if The_Event_Handler_Ref.all in Graphs.Event_Handlers.Activity'Class
         then
            Max_Task_Prio:=Schedulers.Max_Priority
                (Scheduling_Servers.Server_Scheduler
                 (Graphs.Event_Handlers.Activity_Server
                  (Graphs.Event_Handlers.Activity
                   (The_Event_Handler_Ref.all)).all).all);
            Op_Ref:=Graphs.Event_Handlers.Activity_Operation
              (Graphs.Event_Handlers.Activity(The_Event_Handler_Ref.all));
            SS_Ref:=Graphs.Event_Handlers.Activity_Server
              (Graphs.Event_Handlers.Activity
               (The_Event_Handler_Ref.all));
            Sched_Params_Ref:=Scheduling_Servers.Server_Sched_Parameters
              (SS_Ref.all);
            if Sched_Params_Ref.all not in
              Scheduling_Parameters.Fixed_Priority_Parameters'Class
              and then
              Sched_Params_Ref.all not in
              Scheduling_Parameters.EDF_Parameters'Class
            then
               if Verbose then
                  Put_Line("Error in Generic Calculate_Ceilings");
               end if;
               Tool_Exceptions.Set_Tool_Failure_Message
                 ("Found Incompatible Scheduling Parameters");
               raise Tool_Exceptions.Tool_Failure;
            end if;
            Prio_And_Level.Ceiling :=
              Scheduling_Servers.Base_Priority(SS_Ref.all);
            Prio_And_Level.Level :=
              Scheduling_Servers.Base_Level(SS_Ref.all);
            Calculate_Ceilings_And_Levels_For_Operation
              (Op_Ref,Prio_And_Level,Max_Task_Prio);
         end if;
      end Calculate_Ceilings_And_Levels;

      procedure Iterate_Transaction_Paths is new
        MAST.Transaction_Operations.Traverse_Paths_From_Link_Once
        (Operation_For_Links  => Null_Op,
         Operation_For_Event_Handlers => Calculate_Ceilings_And_Levels);


      A_Link_Ref : MAST.Graphs.Link_Ref;
      Trans_Ref : MAST.Transactions.Transaction_Ref;
      Res_Ref : Shared_Resources.Shared_Resource_Ref;
      Prio : Priority;
      Level : Preemption_Level;
      Res_Iterator : Shared_Resources.Lists.Index;
      Trans_Iterator : Transactions.Lists.Index;
      Link_Iterator : Transactions.Link_Iteration_Object;

   begin
      Calculate_Resource_Kinds (The_System,Verbose,Res_Kind_List);
      -- Clear all ceilings and levels that are not preassigned
      --iterate over shared resources
      Shared_Resources.Lists.Rewind
        (The_System.Shared_Resources,Res_Iterator);
      for I in 1..Shared_Resources.Lists.Size(The_System.Shared_Resources)
      loop
         Shared_Resources.Lists.Get_Next_Item
           (Res_Ref,The_System.Shared_Resources,Res_Iterator);
         if Res_Ref.all in Shared_Resources.Immediate_Ceiling_Resource'Class
         then
            if not Shared_Resources.Preassigned
              (Shared_Resources.Immediate_Ceiling_Resource'Class(Res_Ref.all))
            then
               Shared_Resources.Set_Ceiling
                 (Shared_Resources.Immediate_Ceiling_Resource'Class
                  (Res_Ref.all),
                  Priority'First);
            end if;
         elsif Res_Ref.all in Shared_Resources.SRP_Resource'Class
         then
            if not Shared_Resources.Preassigned
              (Shared_Resources.SRP_Resource'Class(Res_Ref.all))
            then
               Shared_Resources.Set_Level
                 (Shared_Resources.SRP_Resource'Class
                  (Res_Ref.all),
                  Preemption_Level'First);
            end if;
         end if;
      end loop;

      -- Loop for every transaction
      MAST.Transactions.Lists.Rewind
        (The_System.Transactions,Trans_Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Trans_Iterator);
         -- loop for each path in the transaction
         Transactions.Rewind_External_Event_Links
           (Trans_Ref.all,Link_Iterator);
         for I in 1..Transactions.Num_Of_External_Event_Links
           (Trans_Ref.all)
         loop
            Transactions.Get_Next_External_Event_Link
              (Trans_Ref.all,A_Link_Ref,Link_Iterator);
            Iterate_Transaction_Paths(Trans_Ref,A_Link_Ref);
         end loop;
      end loop;
      if Verbose then
         -- Report all ceilings
         --iterate over shared resources
         Put_Line("PCP Resource Ceilings Set To:");
         Shared_Resources.Lists.Rewind
           (The_System.Shared_Resources,Res_Iterator);
         for I in 1..Shared_Resources.Lists.Size(The_System.Shared_Resources)
         loop
            Shared_Resources.Lists.Get_Next_Item
              (Res_Ref,The_System.Shared_Resources,Res_Iterator);
            if Res_Ref.all in Shared_Resources.Immediate_Ceiling_Resource'Class
            then
               Prio:=Shared_Resources.Ceiling
                 (Shared_Resources.Immediate_Ceiling_Resource'Class
                  (Res_Ref.all));
               Put_Line(Shared_Resources.Name(Res_Ref)&" => "&
                        Priority'Image(Prio));
            end if;
         end loop;
         -- Report all reemption levels
         --iterate over shared resources
         Put_Line("SRP Resource Preemption Levels Set To:");
         Shared_Resources.Lists.Rewind
           (The_System.Shared_Resources,Res_Iterator);
         for I in 1..Shared_Resources.Lists.Size(The_System.Shared_Resources)
         loop
            Shared_Resources.Lists.Get_Next_Item
              (Res_Ref,The_System.Shared_Resources,Res_Iterator);
            if Res_Ref.all in Shared_Resources.SRP_Resource'Class
            then
               Level:=Shared_Resources.Level
                 (Shared_Resources.SRP_Resource'Class
                  (Res_Ref.all));
               Put_Line(Shared_Resources.Name(Res_Ref)&" => "&
                        Preemption_Level'Image(Level));
            end if;
         end loop;
      end if;
   exception
      when Ceiling_Out_Of_Range =>
         Tool_Exceptions.Set_Restriction_Message
           ("Found ceiling priority Out of range");
         raise Tool_Exceptions.Restriction_Not_Met;
   end Calculate_Ceilings_And_Levels;

   ----------------------------------------------
   -- Check_Task_Preemption_Levels_Consistency --
   ----------------------------------------------

   procedure Check_Task_Preemption_Levels_Consistency
     (The_System : in Mast.Systems.System;
      Verbose : in Boolean:=True)
   is
      type Processor_ID is new Natural;
      type Transaction_ID is new Natural;
      type Task_ID is new Natural;
      Max_Processors:constant Processor_ID:=Processor_ID
        (Processing_Resources.Lists.Size
         (The_System.Processing_Resources));
      Max_Transactions:constant Transaction_ID:=
        Transaction_Id((Mast.Max_Numbers.Calculate_Max_Transactions
                        (The_System)));
      Max_Tasks_Per_Transaction:constant Task_ID:=Task_ID
        (Mast.Max_Numbers.Calculate_Max_Tasks_Per_Transaction(The_System));

      subtype Processor_ID_Type is Processor_ID
        range 0..Max_Processors;
      subtype Transaction_ID_Type is Transaction_ID
        range 0..Max_Transactions;
      subtype Task_ID_Type is Task_ID
        range 0..Max_Tasks_Per_Transaction;

      package Translation is new Linear_Translation
        (Processor_ID_Type, Transaction_ID_Type, Task_ID_Type,
         Max_Processors, Max_Transactions, Max_Tasks_Per_Transaction);

      use Translation;

      package Ordered_Queue is new Priority_Queues
        (Element  => Synchronization_Parameters.Synch_Parameters_Ref,
         Priority => Time,
           ">"      => "<", -- reverse order
           "="      => "=");

      type P_Level_List is array(Integer range <>) of
        Synchronization_Parameters.Synch_Parameters_Ref;

      Transaction : Linear_Transaction_System;

      PL_Order : Time;
      Current_Level, New_Level : Preemption_Level;
      Pl_Counter : Natural:=0;
      Ordered_List : Ordered_Queue.Queue;
      Synch_P_Ref : Synchronization_Parameters.Synch_Parameters_Ref;

   begin
      Translate_Linear_System(The_System,Transaction,Verbose);
      -- Loop for each transaction, I, under analysis
      for I in 1..Max_Transactions loop
         exit when Transaction(I).Ni=0;
         -- Loop for each task, tsk, in the transaction
         for Tsk in 1..Transaction(I).Ni loop
            if Transaction(I).The_Task(Tsk).Pav.Synch_P_Ref/=null and then
              Transaction(I).The_Task(Tsk).Pav.Synch_P_Ref.all in
              Synchronization_Parameters.SRP_Parameters'Class
            then
               Pl_Order:=1.0/(Transaction(I).The_Task(Tsk).SDij-
                              Transaction(I).The_Task(Tsk).Jinit);
               -- Add the parameters object and its PL to a priority queue
               Ordered_Queue.Enqueue
                 (Transaction(I).The_Task(Tsk).Pav.Synch_P_Ref,Pl_Order,
                  Ordered_List);
               Pl_Counter:=Pl_Counter+1;
            end if;
         end loop;
      end loop;
      -- Obtain the preemption levels out of the priority queue
      declare
         Pl_List : P_Level_List(1..Pl_Counter);
      begin
         for I in 1..Pl_Counter loop
            Ordered_Queue.Dequeue(Synch_P_Ref,Pl_Order,Ordered_List);
            Pl_List(I):=Synch_P_Ref;
         end loop;

         -- Check levels
         Current_Level:=0;
         for I in 1..Pl_Counter loop
            New_Level:=Synchronization_Parameters.The_Preemption_Level
              (Synchronization_Parameters.SRP_Parameters'Class
               (Pl_List(I).all));
            if New_Level<Current_Level then
               if Verbose then
                  Put_Line
                    ("Task preemption levels out of order");
               end if;
               Tool_Exceptions.Set_Tool_Failure_Message
                 ("Task preemption levels out of order");
               raise Tool_Exceptions.Tool_Failure;
            else
               Current_Level:=New_Level;
            end if;
         end loop;
      end;
   end Check_Task_Preemption_Levels_Consistency;

   -------------------------------
   -- Check_Ceiling_Consistency --
   -------------------------------

   procedure Check_Ceiling_Consistency
     (The_System : in Mast.Systems.System;
      Verbose : in Boolean:=True;
      Ceil_List : in out Ceiling_Lists.List;
      Res_Kind_List : in Resource_Kind_Lists.List)
   is
      Res_Ref : Shared_Resources.Shared_Resource_Ref;
      Original_Ceiling : Priority;
      Original_Level : Preemption_Level;
      Calculated_CL : Ceiling_And_Level;
      Res_Iterator : Shared_Resources.Lists.Index;
   begin
      --iterate over shared resources
      Shared_Resources.Lists.Rewind
        (The_System.Shared_Resources,Res_Iterator);
      for I in 1..Shared_Resources.Lists.Size(The_System.Shared_Resources)
      loop
         Shared_Resources.Lists.Get_Next_Item
           (Res_Ref,The_System.Shared_Resources,Res_Iterator);
         if Res_Ref.all in Shared_Resources.Immediate_Ceiling_Resource'Class
         then
            Original_Ceiling:=Shared_Resources.Ceiling
              (Shared_Resources.Immediate_Ceiling_Resource'Class
               (Res_Ref.all));
            Calculated_CL:=Ceiling_Lists.Item(Res_Ref,Ceil_List);
            if Original_Ceiling > Calculated_CL.Ceiling then
               Ceiling_Lists.Update
                 (Res_Ref,(Original_Ceiling,Calculated_CL.Level),Ceil_List);
               if Verbose then
                  Put_Line("Warning: resource "&
                           Shared_Resources.Name(Res_Ref)&
                           " has unoptimized ceiling. Ceiling used ="&
                           Priority'Image(Original_Ceiling));
               end if;
            elsif Original_Ceiling<Calculated_CL.Ceiling then
               if Verbose then
                  Put_Line("Error: resource "&
                           Shared_Resources.Name(Res_Ref)&
                           " has too low ceiling");
               end if;
               Tool_Exceptions.Set_Tool_Failure_Message
                 ("Resource Ceiling Too Low");
               raise Tool_Exceptions.Tool_Failure;
            end if;
         elsif Res_Ref.all in
           Shared_Resources.Priority_Inheritance_Resource'Class
         then
            if Resource_Kind_Lists.Item
              (Res_Ref,Res_Kind_List).Kind=Global
            then
               if Verbose then
                  Put_Line("Error: priority inheritance resource "&
                           Shared_Resources.Name(Res_Ref)&
                           " should have global priority ceiling");
               end if;
               Tool_Exceptions.Set_Tool_Failure_Message
                 ("Priority Inheritance used in global resource");
               raise Tool_Exceptions.Tool_Failure;
            end if;
         elsif Res_Ref.all in
           Shared_Resources.SRP_Resource'Class
         then
            if Resource_Kind_Lists.Item
              (Res_Ref,Res_Kind_List).Kind=Global
            then
               if Verbose then
                  Put_Line("Error: SRP resource "&
                           Shared_Resources.Name(Res_Ref)&
                           " should have global priority ceiling");
               end if;
               Tool_Exceptions.Set_Tool_Failure_Message
                 ("SRP used in global resource");
               raise Tool_Exceptions.Tool_Failure;
            end if;
            Original_Level:=Shared_Resources.Level
              (Shared_Resources.SRP_Resource'Class(Res_Ref.all));
            Calculated_CL:=Ceiling_Lists.Item(Res_Ref,Ceil_List);
            if Original_Level > Calculated_CL.Level then
               Ceiling_Lists.Update
                 (Res_Ref,(Calculated_CL.Ceiling,Original_Level),Ceil_List);
               if Verbose then
                  Put_Line("Warning: resource "&
                           Shared_Resources.Name(Res_Ref)&
                           " has unoptimized preemption level. Level used ="&
                           Preemption_Level'Image(Original_Level));
               end if;
            elsif Original_Level<Calculated_CL.Level then
               if Verbose then
                  Put_Line("Error: resource "&
                           Shared_Resources.Name(Res_Ref)&
                           " has too low preemption level");
               end if;
               Tool_Exceptions.Set_Tool_Failure_Message
                 ("Resource Preemption Level Too Low");
               raise Tool_Exceptions.Tool_Failure;
            end if;
         else
            raise Incorrect_Object;
         end if;
      end loop;
   end Check_Ceiling_Consistency;

   ---------------------------------
   -- Calculate_Critical_Sections --
   ---------------------------------
   -- Calculates List of Criticals Sections, with Their length

   procedure Calculate_Critical_Sections
     (The_System : in Systems.System;
      Verbose : in Boolean;
      Ceil_List : in Ceiling_Lists.List;
      Res_Kind_List : in Resource_Kind_Lists.List;
      Critical_Sections : out Critical_Section_Lists.List)
   is

      procedure Traverse_Paths_From_Link_Once
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Link_Ref : MAST.Graphs.Link_Ref;
         Ceil_List : in Ceiling_Lists.List;
         Res_Kind_List : in Resource_Kind_Lists.List;
         Critical_Sections : in out Critical_Section_Lists.List;
         Current_Sections : in out Critical_Section_Lists.List;
         Composite_Csect : in out Critical_Section)
      is

         procedure Process_Critical_Sections
           (The_Operation_Ref : in Operations.Operation_Ref;
            The_Server : in Scheduling_Servers.Scheduling_Server_Ref;
            Ceil_List : in Ceiling_Lists.List;
            Res_Kind_List : in Resource_Kind_Lists.List;
            Critical_Sections : in out Critical_Section_Lists.List;
            Current_Sections : in out Critical_Section_Lists.List;
            Composite_Csect : in out Critical_Section)
         is
            An_Op_Ref : Operations.Operation_Ref;
            Iterator : Operations.Resource_Iteration_Object;
            Op_Iterator : Operations.Operation_Iteration_Object;
            CS_Iterator : Critical_Section_Lists.Iteration_Object;
            Csect,A_Csect : Critical_Section;
            The_Index : Critical_Section_Lists.Index;
            WCET : Time;
            Throughput : Throughput_Value:=0.0;
            Proc_Res_Ref : Processing_Resources.Processing_Resource_Ref;
         begin
            Proc_Res_Ref:=Scheduling_Servers.Server_Processing_Resource
              (The_Server.all);
            if Proc_Res_Ref.all in
              Processing_Resources.Network.Network'Class
            then
               Throughput:=Processing_Resources.Network.Throughput
                 (Processing_Resources.Network.Network'Class
                  (Proc_Res_Ref.all));
            end if;
            if The_Operation_Ref.all in
              MAST.Operations.Simple_Operation'Class
            then
               WCET:=Operations.Worst_Case_Execution_Time
                 (The_Operation_Ref.all,Throughput)/
                 Processing_Resources.Speed_Factor(Proc_Res_Ref.all);
               -- check locked resources
               MAST.Operations.Rewind_Locked_Resources
                 (MAST.Operations.Simple_Operation(The_Operation_Ref.all),
                  Iterator);
               for I in 1..MAST.Operations.Num_Of_Locked_Resources
                 (MAST.Operations.Simple_Operation(The_Operation_Ref.all))
               loop
                  MAST.Operations.Get_Next_Locked_Resource
                    (MAST.Operations.Simple_Operation
                     (The_Operation_Ref.all),
                     Csect.Resource,Iterator);
                  Csect.Ceiling:=Ceiling_Lists.Item
                    (Csect.Resource,Ceil_List).Ceiling;
                  Csect.Level:=Ceiling_Lists.Item
                    (Csect.Resource,Ceil_List).Level;
                  Csect.Kind:=Resource_Kind_Lists.Item
                    (Csect.Resource,Res_Kind_List).Kind;
                  Csect.Srvr:=The_Server;
                  Csect.Length:=0.0;
                  if Critical_Section_Lists.Empty(Current_Sections) then
                     Composite_Csect:=Csect;
                  end if;
                  Critical_Section_Lists.Add(Csect,Current_Sections);
               end loop;

               -- Update Lengths of current critical sections
               Composite_Csect.Length:=Composite_Csect.Length+WCET;
               Critical_Section_Lists.Rewind(Current_Sections,CS_Iterator);
               for I in 1..Critical_Section_Lists.Size(Current_Sections)
               loop
                  Critical_Section_Lists.Get_Next_Item
                    (A_Csect,Current_Sections,CS_Iterator);
                  A_Csect.Length:=A_Csect.Length+WCET;
                  Critical_Section_Lists.Update
                    (Critical_Section_Lists.Find(A_Csect,Current_Sections),
                     A_Csect,Current_Sections);
               end loop;

               -- Check Unlocked resources
               MAST.Operations.Rewind_Unlocked_Resources
                 (MAST.Operations.Simple_Operation(The_Operation_Ref.all),
                  Iterator);
               for I in 1..MAST.Operations.Num_Of_Unlocked_Resources
                 (MAST.Operations.Simple_Operation(The_Operation_Ref.all))
               loop
                  MAST.Operations.Get_Next_Unlocked_Resource
                    (MAST.Operations.Simple_Operation
                     (The_Operation_Ref.all),
                     A_Csect.Resource,Iterator);
                  The_Index:=Critical_Section_Lists.Find
                    (A_Csect,Current_Sections);
                  Critical_Section_Lists.Delete
                    (The_Index,Current_Sections,Csect);
                  Critical_Section_Lists.Add(Csect,Critical_Sections);
                  if Critical_Section_Lists.Empty(Current_Sections) and then
                    Csect.Resource/=Composite_Csect.Resource
                  then
                     Critical_Section_Lists.Add
                       (Composite_Csect,Critical_Sections);
                  end if;
               end loop;

            elsif The_Operation_Ref.all in
              MAST.Operations.Composite_Operation'Class
            then
               -- Iterate over all Operations
               MAST.Operations.Rewind_Operations
                 (MAST.Operations.Composite_Operation(The_Operation_Ref.all),
                  Op_Iterator);
               for I in 1..MAST.Operations.Num_Of_Operations
                 (MAST.Operations.Composite_Operation(The_Operation_Ref.all))
               loop
                  MAST.Operations.Get_Next_Operation
                    (MAST.Operations.Composite_Operation
                     (The_Operation_Ref.all),
                     An_Op_Ref,Op_Iterator);
                  Process_Critical_Sections
                    (An_Op_Ref,The_Server,Ceil_List,Res_Kind_List,
                     Critical_Sections,Current_Sections,Composite_Csect);
               end loop;
            elsif The_Operation_Ref.all in
              Operations.Message_Transmission_Operation'Class
            then
               null; -- message operations have no shared resources
            else
               raise Incorrect_Object;
            end if;
         end Process_Critical_Sections;

         An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
         Next_Link_Ref,First_Link_Ref : MAST.Graphs.Link_Ref;
         Iterator : Graphs.Event_Handlers.Iteration_Object;
         Link_Iterator : Graphs.Event_Handlers.Iteration_Object;
         An_Op_Ref : Operations.Operation_Ref;
         The_Server : Scheduling_Servers.Scheduling_Server_Ref;

      begin
         if The_Link_Ref=null then
            return;
         end if;
         An_Event_Handler_Ref:=MAST.Graphs.Output_Event_Handler
           (The_Link_Ref.all);
         if An_Event_Handler_Ref/=null then
            if An_Event_Handler_Ref.all in
              MAST.Graphs.Event_Handlers.Simple_Event_Handler'Class
            then
               if An_Event_Handler_Ref.all in
                 MAST.Graphs.Event_Handlers.Activity'Class
               then
                  The_Server:=Graphs.Event_Handlers.Activity_Server
                    (MAST.Graphs.Event_Handlers.Activity
                     (An_Event_Handler_Ref.all));
                  An_Op_Ref:=Graphs.Event_Handlers.Activity_Operation
                    (MAST.Graphs.Event_Handlers.Activity
                     (An_Event_Handler_Ref.all));
                  Process_Critical_Sections
                    (An_Op_Ref,The_Server,Ceil_List,Res_Kind_List,
                     Critical_Sections,Current_Sections,Composite_Csect);
               end if;
               Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
                 (MAST.Graphs.Event_Handlers.Simple_Event_Handler
                  (An_Event_Handler_Ref.all));
               Traverse_Paths_From_Link_Once
                 (Trans_Ref,Next_Link_Ref,Ceil_List,Res_Kind_List,
                  Critical_Sections,Current_Sections,Composite_Csect);
            elsif An_Event_Handler_Ref.all in
              MAST.Graphs.Event_Handlers.Output_Event_Handler'Class
            then
               MAST.Graphs.Event_Handlers.Rewind_Output_Links
                 (MAST.Graphs.Event_Handlers.Output_Event_Handler
                  (An_Event_Handler_Ref.all),Iterator);
               for I in 1..MAST.Graphs.Event_Handlers.Num_Of_Output_Links
                 (MAST.Graphs.Event_Handlers.Output_Event_Handler
                  (An_Event_Handler_Ref.all))
               loop
                  MAST.Graphs.Event_Handlers.Get_Next_Output_Link
                    (MAST.Graphs.Event_Handlers.Output_Event_Handler
                     (An_Event_Handler_Ref.all),
                     Next_Link_Ref,Iterator);
                  Traverse_Paths_From_Link_Once
                    (Trans_Ref,Next_Link_Ref,Ceil_List,Res_Kind_List,
                     Critical_Sections,Current_Sections,Composite_Csect);
               end loop;
            else -- input Event_Handler
               MAST.Graphs.Event_Handlers.Rewind_Input_Links
                 (MAST.Graphs.Event_Handlers.Input_Event_Handler
                  (An_Event_Handler_Ref.all),Link_Iterator);
               MAST.Graphs.Event_Handlers.Get_Next_Input_Link
                 (MAST.Graphs.Event_Handlers.Input_Event_Handler
                  (An_Event_Handler_Ref.all),First_Link_Ref,Link_Iterator);
               -- continue only if this is the first input Link
               if First_Link_Ref=The_Link_Ref then
                  Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
                    (MAST.Graphs.Event_Handlers.Input_Event_Handler
                     (An_Event_Handler_Ref.all));
                  Traverse_Paths_From_Link_Once
                    (Trans_Ref,Next_Link_Ref,Ceil_List,Res_Kind_List,
                     Critical_Sections,Current_Sections,Composite_Csect);
               end if;
            end if;
         end if;
      end Traverse_Paths_From_Link_Once;

      A_Trans_Ref : Transactions.Transaction_Ref;
      A_Link_Ref : MAST.Graphs.Link_Ref;
      Trans_Iterator : Transactions.Lists.Index;
      Link_Iterator : Transactions.Link_Iteration_Object;
      Current_Sections : Critical_Section_Lists.List;
      Csect : Critical_Section;
      CS_Iterator : Critical_Section_Lists.Iteration_Object;
      Composite_Csect : Critical_Section;

   begin
      -- loop for every transaction
      MAST.Transactions.Lists.Rewind
        (The_System.Transactions,Trans_Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (A_Trans_Ref,The_System.Transactions,Trans_Iterator);

         -- loop for each path in the transaction
         Transactions.Rewind_External_Event_Links
           (A_Trans_Ref.all,Link_Iterator);
         for I in 1..Transactions.Num_Of_External_Event_Links
           (A_Trans_Ref.all)
         loop
            Transactions.Get_Next_External_Event_Link
              (A_Trans_Ref.all,A_Link_Ref,Link_Iterator);
            Traverse_Paths_From_Link_Once
              (A_Trans_Ref,A_Link_Ref,Ceil_List,Res_Kind_List,
               Critical_Sections,Current_Sections,Composite_Csect);
         end loop;
      end loop;
      if Verbose and then
        Critical_Section_Lists.Size(Critical_Sections)>0
      then
         Put_Line("List of all critical sections found:");
         Critical_Section_Lists.Rewind (Critical_Sections,CS_Iterator);
         for I in 1..Critical_Section_Lists.Size(Critical_Sections) loop
            Critical_Section_Lists.Get_Next_Item
              (Csect,Critical_Sections,CS_Iterator);
            Put_Line("Resource= "&Shared_Resources.Name(Csect.Resource)&
                     " Server= "&Scheduling_Servers.Name(Csect.Srvr)&
                     " Ceiling= "&Priority'Image(Csect.Ceiling)&
                     " Level= "&Preemption_Level'Image(Csect.Level)&
                     " Kind= "&Resource_Kind'Image(Csect.Kind)&
                     " Length= "&IO.Time_Image(Csect.Length));
         end loop;
      end if;
   end Calculate_Critical_Sections;

   --------------------------------
   -- Add_High_Priority_Sections --
   --------------------------------
   -- Adds to the list of critical sections the List of high
   -- priority Sections that may influence the blocking time

   procedure Add_High_Priority_Sections
     (The_System : in Systems.System;
      Verbose : in Boolean;
      Critical_Sections : in out Critical_Section_Lists.List)
   is

      procedure Traverse_Paths_From_Link_Once
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Link_Ref : MAST.Graphs.Link_Ref;
         Critical_Sections : in out Critical_Section_Lists.List)
      is

         procedure Process_High_Priority_Sections
           (The_Operation_Ref : in Operations.Operation_Ref;
            The_Server : in Scheduling_Servers.Scheduling_Server_Ref;
            Critical_Sections : in out Critical_Section_Lists.List)
         is
            An_Op_Ref : Operations.Operation_Ref;
            Op_Iterator : Operations.Operation_Iteration_Object;
            Csect : Critical_Section;
            New_Sch_Par :
              Scheduling_Parameters.Overridden_Sched_Parameters_Ref:=
              Operations.New_Sched_Parameters(The_Operation_Ref.all);
            Throughput : Throughput_Value:=0.0;
            Proc_Res_Ref : Processing_Resources.Processing_Resource_Ref;
         begin
            Proc_Res_Ref:=Scheduling_Servers.Server_Processing_Resource
              (The_Server.all);
            if Proc_Res_Ref.all in
              Processing_Resources.Network.Network'Class
            then
               Throughput:=Processing_Resources.Network.Throughput
                 (Processing_Resources.Network.Network'Class
                  (Proc_Res_Ref.all));
            end if;
            if New_Sch_Par/=null
              and then New_Sch_Par.all in
              Scheduling_Parameters.Overridden_FP_Parameters
              and then
              Scheduling_Parameters.The_Priority
              (Scheduling_Parameters.Overridden_FP_Parameters
               (New_Sch_Par.all))>
              Scheduling_Parameters.The_Priority
              (Scheduling_Parameters.Fixed_Priority_Parameters'Class
               (Scheduling_Servers.Server_Sched_Parameters
                (The_Server.all).all))
            then
               Csect.Length:=Operations.Worst_Case_Execution_Time
                 (The_Operation_Ref.all,Throughput)/
                 Processing_Resources.Speed_Factor
                 (Scheduling_Servers.Server_Processing_Resource
                  (The_Server.all).all);
               Csect.Ceiling:=Scheduling_Parameters.The_Priority
                 (Scheduling_Parameters.Overridden_FP_Parameters
                  (New_Sch_Par.all));
               Csect.Resource:=
                 new Shared_Resources.Immediate_Ceiling_Resource;
               Shared_Resources.Init
                 (Csect.Resource.all,To_Var_String("Overridden_Priority_")&
                  Operations.Name(The_Operation_Ref));
               Shared_Resources.Set_Ceiling
                 (Shared_Resources.Immediate_Ceiling_Resource
                  (Csect.Resource.all),Csect.Ceiling);
               Csect.Level:=Preemption_Level'Last;
               Csect.Kind:=Local;
               Csect.Srvr:=The_Server;
               Critical_Section_Lists.Add(Csect,Critical_Sections);
            end if;

            if The_Operation_Ref.all in
              MAST.Operations.Composite_Operation'Class
            then
               -- Iterate over all Operations
               MAST.Operations.Rewind_Operations
                 (MAST.Operations.Composite_Operation(The_Operation_Ref.all),
                  Op_Iterator);
               for I in 1..MAST.Operations.Num_Of_Operations
                 (MAST.Operations.Composite_Operation(The_Operation_Ref.all))
               loop
                  MAST.Operations.Get_Next_Operation
                    (MAST.Operations.Composite_Operation
                     (The_Operation_Ref.all),
                     An_Op_Ref,Op_Iterator);
                  Process_High_Priority_Sections
                    (An_Op_Ref,The_Server,Critical_Sections);
               end loop;
            end if;
         end Process_High_Priority_Sections;

         An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
         Next_Link_Ref,First_Link_Ref : MAST.Graphs.Link_Ref;
         Iterator : Graphs.Event_Handlers.Iteration_Object;
         Link_Iterator : Graphs.Event_Handlers.Iteration_Object;
         An_Op_Ref : Operations.Operation_Ref;
         The_Server : Scheduling_Servers.Scheduling_Server_Ref;
         Csect : Critical_Section;
         Max_Task_Prio : Priority;
         Throughput : Throughput_Value:=0.0;
         Proc_Res_Ref : Processing_Resources.Processing_Resource_Ref;
      begin
         if The_Link_Ref=null then
            return;
         end if;
         An_Event_Handler_Ref:=MAST.Graphs.Output_Event_Handler
           (The_Link_Ref.all);
         if An_Event_Handler_Ref/=null then
            if An_Event_Handler_Ref.all in
              MAST.Graphs.Event_Handlers.Simple_Event_Handler'Class
            then
               if An_Event_Handler_Ref.all in
                 MAST.Graphs.Event_Handlers.Activity'Class
               then
                  Max_Task_Prio:=Schedulers.Max_Priority
                      (Scheduling_Servers.Server_Scheduler
                       (Graphs.Event_Handlers.Activity_Server
                        (Graphs.Event_Handlers.Activity
                         (An_Event_Handler_Ref.all)).all).all);
                  The_Server:=Graphs.Event_Handlers.Activity_Server
                    (MAST.Graphs.Event_Handlers.Activity
                     (An_Event_Handler_Ref.all));
                  Proc_Res_Ref:=Scheduling_Servers.Server_Processing_Resource
                    (The_Server.all);
                  if Proc_Res_Ref.all in
                    Processing_Resources.Network.Network'Class
                  then
                     Throughput:=Processing_Resources.Network.Throughput
                       (Processing_Resources.Network.Network'Class
                        (Proc_Res_Ref.all));
                  end if;
                  An_Op_Ref:=Graphs.Event_Handlers.Activity_Operation
                    (MAST.Graphs.Event_Handlers.Activity
                     (An_Event_Handler_Ref.all));
                  if Scheduling_Servers.Server_Sched_Parameters
                    (The_Server.all).all in Scheduling_Parameters.
                    Non_Preemptible_Fp_Policy'Class
                  then
                     Csect.Length:=Operations.Worst_Case_Execution_Time
                       (An_Op_Ref.all,Throughput)/
                       Processing_Resources.Speed_Factor
                       (Scheduling_Servers.Server_Processing_Resource
                        (The_Server.all).all);
                     Csect.Ceiling:=Max_Task_Prio;
                     Csect.Resource:=
                       new Shared_Resources.Immediate_Ceiling_Resource;
                     Shared_Resources.Init
                       (Csect.Resource.all,
                        To_Var_String("Non_Preemptible_")&
                        Operations.Name(An_Op_Ref));
                     Shared_Resources.Set_Ceiling
                       (Shared_Resources.Immediate_Ceiling_Resource
                        (Csect.Resource.all),Csect.Ceiling);
                     Csect.Kind:=Local;
                     Csect.Level:=Preemption_Level'Last;
                     Csect.Srvr:=The_Server;
                     Critical_Section_Lists.Add(Csect,Critical_Sections);
                  else
                     Process_High_Priority_Sections
                       (An_Op_Ref,The_Server,Critical_Sections);
                  end if;
               end if;
               Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
                 (MAST.Graphs.Event_Handlers.Simple_Event_Handler
                  (An_Event_Handler_Ref.all));
               Traverse_Paths_From_Link_Once
                 (Trans_Ref,Next_Link_Ref,Critical_Sections);
            elsif An_Event_Handler_Ref.all in
              MAST.Graphs.Event_Handlers.Output_Event_Handler'Class
            then
               MAST.Graphs.Event_Handlers.Rewind_Output_Links
                 (MAST.Graphs.Event_Handlers.Output_Event_Handler
                  (An_Event_Handler_Ref.all),Iterator);
               for I in 1..MAST.Graphs.Event_Handlers.Num_Of_Output_Links
                 (MAST.Graphs.Event_Handlers.Output_Event_Handler
                  (An_Event_Handler_Ref.all))
               loop
                  MAST.Graphs.Event_Handlers.Get_Next_Output_Link
                    (MAST.Graphs.Event_Handlers.Output_Event_Handler
                     (An_Event_Handler_Ref.all),
                     Next_Link_Ref,Iterator);
                  Traverse_Paths_From_Link_Once
                    (Trans_Ref,Next_Link_Ref,Critical_Sections);
               end loop;
            else -- input Event_Handler
               MAST.Graphs.Event_Handlers.Rewind_Input_Links
                 (MAST.Graphs.Event_Handlers.Input_Event_Handler
                  (An_Event_Handler_Ref.all),Link_Iterator);
               MAST.Graphs.Event_Handlers.Get_Next_Input_Link
                 (MAST.Graphs.Event_Handlers.Input_Event_Handler
                  (An_Event_Handler_Ref.all),First_Link_Ref,Link_Iterator);
               -- continue only if this is the first input Link
               if First_Link_Ref=The_Link_Ref then
                  Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
                    (MAST.Graphs.Event_Handlers.Input_Event_Handler
                     (An_Event_Handler_Ref.all));
                  Traverse_Paths_From_Link_Once
                    (Trans_Ref,Next_Link_Ref,Critical_Sections);
               end if;
            end if;
         end if;
      end Traverse_Paths_From_Link_Once;

      A_Trans_Ref : Transactions.Transaction_Ref;
      A_Link_Ref : MAST.Graphs.Link_Ref;
      Trans_Iterator : Transactions.Lists.Index;
      Link_Iterator : Transactions.Link_Iteration_Object;
      Csect : Critical_Section;
      CS_Iterator : Critical_Section_Lists.Iteration_Object;
      Initial_Size : Natural;

   begin
      Initial_Size:=Critical_Section_Lists.Size(Critical_Sections);
      -- loop for every transaction
      MAST.Transactions.Lists.Rewind
        (The_System.Transactions,Trans_Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (A_Trans_Ref,The_System.Transactions,Trans_Iterator);

         -- loop for each path in the transaction
         Transactions.Rewind_External_Event_Links
           (A_Trans_Ref.all,Link_Iterator);
         for I in 1..Transactions.Num_Of_External_Event_Links
           (A_Trans_Ref.all)
         loop
            Transactions.Get_Next_External_Event_Link
              (A_Trans_Ref.all,A_Link_Ref,Link_Iterator);
            Traverse_Paths_From_Link_Once
              (A_Trans_Ref,A_Link_Ref,Critical_Sections);
         end loop;
      end loop;
      if Verbose and then
        Critical_Section_Lists.Size(Critical_Sections)>Initial_Size
      then
         Put_Line("List of all high priority sections found:");
         Critical_Section_Lists.Rewind (Critical_Sections,CS_Iterator);
         for I in 1..Critical_Section_Lists.Size(Critical_Sections) loop
            Critical_Section_Lists.Get_Next_Item
              (Csect,Critical_Sections,CS_Iterator);
            if I>Initial_Size then
               Put_Line("Resource= "&Shared_Resources.Name(Csect.Resource)&
                        " Server= "&Scheduling_Servers.Name(Csect.Srvr)&
                        " Ceiling= "&Priority'Image(Csect.Ceiling)&
                        " Kind= "&Resource_Kind'Image(Csect.Kind)&
                        " Length= "&IO.Time_Image(Csect.Length));
            end if;
         end loop;
      end if;
   end Add_High_Priority_Sections;


   ------------------------------
   -- Calculate_Blocking_Times --
   ------------------------------

   procedure Calculate_Blocking_Times
     (The_System : in out Mast.Systems.System;
      Verbose : in Boolean:=True)
   is

      type Processor_ID is new Natural;
      type Transaction_ID is new Natural;
      type Task_ID is new Natural;

      Max_Processors:constant Processor_ID:=Processor_ID
        (Processing_Resources.Lists.Size
         (The_System.Processing_Resources));
      Max_Transactions:constant Transaction_ID:=Transaction_Id
        (Mast.Max_Numbers.Calculate_Max_Transactions(The_System));
      Max_Tasks_Per_Transaction:constant Task_ID:=Task_ID
        (Mast.Max_Numbers.Calculate_Max_Tasks_Per_Transaction(The_System));

      subtype Processor_ID_Type is Processor_ID
        range 0..Max_Processors;
      subtype Transaction_ID_Type is Transaction_ID
        range 0..Max_Transactions;
      subtype Task_ID_Type is Task_ID
        range 0..Max_Tasks_Per_Transaction;

      package Translation is new Linear_Translation
        (Processor_ID_Type, Transaction_ID_Type, Task_ID_Type,
         Max_Processors, Max_Transactions, Max_Tasks_Per_Transaction);

      ------------------------------------
      -- Calculate_Blocking_For_segment --
      ------------------------------------
      -- Calculates blocking time for the segment starting at The_Link_Ref

      procedure Calculate_Blocking_For_Segment
        (Trans_Ref : in MAST.Transactions.Transaction_Ref;
         The_Link_Ref : in MAST.Graphs.Link_Ref;
         Next_Link_Ref : out MAST.Graphs.Link_Ref;
         Verbose : in Boolean:=True;
         Critical_Sections : in Critical_Section_Lists.List;
         Res_Kind_List : in Resource_Kind_Lists.List;
         Transaction : Translation.Linear_Transaction_System;
         Priority_Inheritance_Behaviour : Systems.PIP_Behaviour)
      is

         type Blocking_Time is record
            Block : Time;
            Num : Natural;
         end record;

         function Remote_Blocking
           (Csect : Critical_Section) return Time
         is
            Processor : Processing_Resources.Processing_Resource_Ref;
            Proc_Num : Processor_Id_Type;
            Hj : array(Transaction_Id_Type) of Time;
            Thj : array(Transaction_Id_Type) of Time;
            Num_Hj : Transaction_Id_Type:=0;
            HLj : array(Transaction_Id_Type) of Time;
            Num_HLj : Transaction_Id_Type:=0;
            N : Task_Id_Type;
            C,T : Time;
            RBlock,Previous_RBlock : Time:=0.0;
            Count : Integer:=100_000;
         begin
            Processor:=Scheduling_Servers.Server_Processing_Resource
              (Csect.Srvr.all);
            Proc_Num:=Translation.Get_Processor_Number(The_System,Processor);

            -- get data
            for I in 1..Max_Transactions loop
               exit when Transaction(I).Ni=0;
               N:=0;
               C:=0.0;
               for J in 1..Transaction(I).Ni loop
                  if J=1 then
                     T:=Transaction(I).The_Task(J).Tij;
                  end if;
                  if Transaction(I).The_Task(J).Procij=Proc_Num and then
                    Transaction(I).The_Task(J).Prioij>Csect.Ceiling and then
                    abs(T-Transaction(I).The_Task(J).Tij)<Epsilon
                  then
                     if Transaction(I).The_Task(J).Uses_Shared_Resources then
                        if Verbose then
                           Put_Line("Restriction not met: ");
                           Put_Line("   Shared resources used in task with "&
                                    "Priority Greater Than Global Ceiling");
                        end if;
                        Tool_Exceptions.Set_Restriction_Message
                          ("Global ceiling restriction: "&
                           "insufficient priority");
                        raise Tool_Exceptions.Restriction_Not_Met;
                     end if;
                     N:=N+1;
                     C:=C+Transaction(I).The_Task(J).Cijown;
                  else
                     exit;
                  end if;
               end loop;
               if N>0 then
                  if N<Transaction(I).Ni then
                     Num_HLj:=Num_HLj+1;
                     HLj(Num_HLj):=C;
                  else
                     Num_Hj:=Num_Hj+1;
                     Hj(Num_Hj):=C;
                     Thj(Num_Hj):=T;
                  end if;
               end if;
            end loop;

            -- calculate remote blocking

            loop
               Count:=Count-1;
               Previous_RBlock:=Rblock;
               -- own critical section
               Rblock:=Csect.Length;
               -- HL segments
               for J in 1..Num_HLj loop
                  Rblock:=Rblock+HLj(J);
               end loop;
               -- H segments
               for J in 1..Num_Hj loop
                  Rblock:=Rblock+Hj(J)*Time'Ceiling(Rblock/Thj(J));
               end loop;
               exit when Rblock<=Previous_RBlock;
               Count:=Count-1;
               if Count<=0 then
                  Tool_Exceptions.Set_Tool_Failure_Message
                    ("Remote blocking calculation does not converge");
                  raise Tool_Exceptions.Tool_Failure;
               end if;
            end loop;
            return RBlock;
         end Remote_Blocking;

         function Inheritance_Blocking
           (Inheritance_Sections : Critical_Section_Lists.List;
            Priority_Inheritance_Behaviour : Systems.PIP_Behaviour)
           return Blocking_Time
           -- Calculates blocking caused by critical sections with
           -- priority inheritance protocol
         is
            Blocking_By_Tasks, Blocking_By_Resources : Blocking_Time:=
              (Block=>0.0, Num=>0);
            CS_Iterator : Critical_Section_Lists.Iteration_Object;
            Task_List : Inheritance_Section_Task_Lists.List;
            Task_Iterator : Inheritance_Section_Task_Lists.Iteration_Object;
            Res_List : Inheritance_Section_Resource_Lists.List;
            Res_Iterator : Inheritance_Section_Resource_Lists.Iteration_Object;
            Csect : Critical_Section;
            The_Task : Scheduling_Servers.Scheduling_Server_Ref;
            The_Res : Shared_Resources.Shared_Resource_Ref;
            Length : Time;
         begin
            -- Calculate sets of critical sections
            Critical_Section_Lists.Rewind(Inheritance_Sections,CS_Iterator);
            for I in 1..Critical_Section_Lists.Size(Inheritance_Sections)
            loop
               Critical_Section_Lists.Get_Next_Item
                 (Csect,Inheritance_Sections,CS_Iterator);
               if not Inheritance_Section_Task_Lists.Exists
                 (Csect.Srvr,Task_List) or else
                 Inheritance_Section_Task_Lists.Item
                 (Csect.Srvr,Task_List)<Csect.Length
               then
                  Inheritance_Section_Task_Lists.Add_Or_Update
                    (Csect.Srvr,Csect.Length,Task_List);
               end if;

               if not Inheritance_Section_Resource_Lists.Exists
                 (Csect.Resource,Res_List) or else
                 Inheritance_Section_Resource_Lists.Item
                 (Csect.Resource,Res_List)<Csect.Length
               then
                  Inheritance_Section_Resource_Lists.Add_Or_Update
                    (Csect.Resource,Csect.Length,Res_List);
               end if;
            end loop;

            -- Calculate Max Blocking by different resources
            Inheritance_Section_Resource_Lists.Rewind(Res_List,Res_Iterator);
            for I in 1..Inheritance_Section_Resource_Lists.Size(Res_List)
            loop
               Inheritance_Section_Resource_Lists.Get_Next_Item
                 (The_Res,Length,Res_List,Res_Iterator);
               Blocking_By_Resources:=(Blocking_By_Resources.Block+Length,
                                       Blocking_By_Resources.Num+1);
            end loop;

            if Priority_Inheritance_Behaviour=Systems.Strict then
               -- Calculate Max Blocking by different tasks
               Inheritance_Section_Task_Lists.Rewind(Task_List,Task_Iterator);
               for I in 1..Inheritance_Section_Task_Lists.Size(Task_List)
               loop
                  Inheritance_Section_Task_Lists.Get_Next_Item
                    (The_Task,Length,Task_List,Task_Iterator);
                  Blocking_By_Tasks:=(Blocking_By_Tasks.Block+Length,
                                      Blocking_By_Tasks.Num+1);
               end loop;

               if Blocking_By_Tasks.Block<Blocking_By_Resources.Block then
                  return Blocking_By_Tasks;
               else
                  return Blocking_By_Resources;
               end if;
            else
               return Blocking_By_Resources;
            end if;
         end Inheritance_Blocking;

         Server_Ref : Scheduling_Servers.Scheduling_Server_Ref;
         Base_Priority : Priority;
         Base_Level : Preemption_Level;
         The_Processor : Processing_Resources.Processing_Resource_Ref;
         Evnt_Hdlr_Ref : Graphs.Event_Handler_Ref;
         PCP_Blocking : Time:=0.0;
         Total_Blocking,Inh_Blocking,Global_Blocking : Blocking_Time:=
           (Block=>0.0, Num=>0);
         Inheritance_Sections : Critical_Section_Lists.List;
         Result_Ref : Results.Timing_Result_Ref;
         Iterator : Critical_Section_Lists.Iteration_Object;
         Csect : Critical_Section;
         Global_Resources : Global_Res_Lists.List;
         Glob_Res_Iteration_Object : Global_Res_Lists.Iteration_Object;
         A_Res_Ref : Shared_Resources.Shared_Resource_Ref;
         Speed_Factor : Processor_Speed;

      begin
         Evnt_Hdlr_Ref:=Graphs.Output_Event_Handler
           (The_Link_Ref.all);
         Server_Ref := Graphs.Event_Handlers.Activity_Server
           (Graphs.Event_Handlers.Activity(Evnt_Hdlr_Ref.all));
         The_Processor :=Scheduling_Servers.Server_Processing_Resource
           (Server_Ref.all);
         Speed_Factor:=Processing_Resources.Speed_Factor(The_Processor.all);
         Base_Priority:=Scheduling_Servers.Base_Priority(Server_Ref.all);
         Base_Level:=Scheduling_Servers.Base_Level(Server_Ref.all);
         -- Calculate Network Blocking
         if The_Processor.all in
           Processing_Resources.Network.Packet_Based_Network'Class
         then
            PCP_Blocking:=Processing_Resources.Network.Max_Blocking
              (Processing_Resources.Network.Packet_Based_Network'Class
               (The_Processor.all))/Speed_Factor;
         end if;

         -- Calculate List of global resources of segment

         declare
            An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
            Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
            An_Op_Ref : Operations.Operation_Ref;

            procedure Process_Global_Resources
              (Global_Resources : in out Global_Res_Lists.List;
               Res_Kind_List : in Resource_Kind_Lists.List;
               An_Op_Ref : Operations.Operation_Ref)
            is
               Res_Iterator : Operations.Resource_Iteration_Object;
               Res_Ref : Shared_Resources.Shared_Resource_Ref;
               Op_Iterator : Operations.Operation_Iteration_Object;
               New_Op_Ref : Operations.Operation_Ref;
            begin
               if An_Op_Ref.all in Operations.Simple_Operation'Class then
                  Operations.Rewind_Locked_Resources
                    (Operations.Simple_Operation'Class(An_Op_Ref.all),
                     Res_Iterator);
                  for I in 1..Operations.Num_Of_Locked_Resources
                    (Operations.Simple_Operation'Class(An_Op_Ref.all))
                  loop
                     Operations.Get_Next_Locked_Resource
                       (Operations.Simple_Operation'Class(An_Op_Ref.all),
                        Res_Ref,Res_Iterator);
                     if Resource_Kind_Lists.Item(Res_Ref,Res_Kind_List).Kind=
                       Global
                     then
                        Global_Res_Lists.Add(Res_Ref,Global_Resources);
                     end if;
                  end loop;
               elsif An_Op_Ref.all in Operations.Composite_Operation'Class then
                  Operations.Rewind_Operations
                    (Operations.Composite_Operation'Class(An_Op_Ref.all),
                     Op_Iterator);
                  for I in 1..Operations.Num_Of_Operations
                    (Operations.Composite_Operation'Class(An_Op_Ref.all))
                  loop
                     Operations.Get_Next_Operation
                       (Operations.Composite_Operation'Class(An_Op_Ref.all),
                        New_Op_Ref,Op_Iterator);
                     Process_Global_Resources
                       (Global_Resources,Res_Kind_List,New_Op_Ref);
                  end loop;
               elsif An_Op_Ref.all in
                 Operations.Message_Transmission_Operation'Class
               then
                  null; -- message operations have no shared resources
               else
                  raise Incorrect_Object;
               end if;
            end Process_Global_Resources;

         begin
            An_Event_Handler_Ref:=MAST.Graphs.
              Output_Event_Handler(The_Link_Ref.all);
            if An_Event_Handler_Ref=null or else
              An_Event_Handler_Ref.all not in
              MAST.Graphs.Event_Handlers.Activity'Class
            then
               raise Incorrect_Object;
            end if;
            Srvr_Ref:=Graphs.Event_Handlers.Activity_Server
              (Graphs.Event_Handlers.Activity(An_Event_Handler_Ref.all));
            loop
               An_Op_Ref:=Graphs.Event_Handlers.Activity_Operation
                 (Graphs.Event_Handlers.Activity(An_Event_Handler_Ref.all));
               Process_Global_Resources
                 (Global_Resources,Res_Kind_List,An_Op_Ref);
               Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
                 (MAST.Graphs.Event_Handlers.Activity
                  (An_Event_Handler_Ref.all));
               An_Event_Handler_Ref:=MAST.Graphs.
                 Output_Event_Handler(Next_Link_Ref.all);
               exit when An_Event_Handler_Ref=null or else
                 An_Event_Handler_Ref.all not in
                 MAST.Graphs.Event_Handlers.Activity'Class or else
                 Srvr_Ref/=Graphs.Event_Handlers.Activity_Server
                 (Graphs.Event_Handlers.Activity(An_Event_Handler_Ref.all));
            end loop;
         end;

         -- Calculate blocking term from set of critical sections
         Critical_Section_Lists.Rewind(Critical_Sections,Iterator);
         for I in 1..Critical_Section_Lists.Size(Critical_Sections) loop
            Critical_Section_Lists.Get_Next_Item
              (Csect,Critical_Sections,Iterator);
            if Csect.Srvr/=Server_Ref
              and then Scheduling_Servers.Server_Processing_Resource
              (Csect.Srvr.all)=The_Processor
            then
               if Csect.Resource.all in
                 Shared_Resources.SRP_Resource'Class
               then
                  if Csect.Level>=Base_Level then
                     if Csect.Length>PCP_Blocking then
                        PCP_Blocking:=Csect.Length;
                     end if;
                  end if;
               else
                  if Csect.Ceiling>=Base_Priority
                    and then Scheduling_Parameters.The_Priority
                    (Scheduling_Parameters.Fixed_Priority_Parameters'Class
                     (Scheduling_Servers.Server_Sched_Parameters
                      (Csect.Srvr.all).all))<Base_Priority
                  then
                     if Csect.Resource.all in
                       Shared_Resources.Immediate_Ceiling_Resource'Class
                     then
                        if Csect.Length>PCP_Blocking then
                           PCP_Blocking:=Csect.Length;
                        end if;
                     elsif Csect.Resource.all in
                       Shared_Resources.Priority_Inheritance_Resource'Class
                     then
                        Critical_Section_Lists.Add(Csect,Inheritance_Sections);
                     else
                        raise Incorrect_Object;
                     end if;
                  end if;
               end if;
            end if;
            -- process remote blocking
            Global_Res_Lists.Rewind
              (Global_Resources,Glob_Res_Iteration_Object);
            for I in 1..Global_Res_Lists.Size (Global_Resources)
            loop
               Global_Res_Lists.Get_Next_Item
                 (A_Res_Ref,Global_Resources,
                  Glob_Res_Iteration_Object);
               if A_Res_Ref=Csect.Resource and then
                 Scheduling_Servers.Server_Processing_Resource
                 (Csect.Srvr.all)/=The_Processor
               then
                  Global_Blocking:=
                    (Block=>Global_Blocking.Block+
                       Remote_Blocking(Csect),
                     Num=>Global_Blocking.Num+1);
                  exit;
               end if;
            end loop;
         end loop;

         Inh_Blocking:=Inheritance_Blocking
           (Inheritance_Sections,Priority_Inheritance_Behaviour);
         Total_Blocking:=
           (Block=>PCP_Blocking+Global_Blocking.Block+Inh_Blocking.Block,
            Num=>Global_Blocking.Num+Inh_Blocking.Num);

         -- Calculate end of segment
         Transaction_Operations.Identify_Segment
           (Trans_Ref, The_Link_Ref, Next_Link_Ref);

         -- Associate blocking to the link that ends the segment
         if not Graphs.Has_Results(Next_Link_Ref.all) then
            Result_Ref:=Results.Create_Timing_Result(Next_Link_Ref);
         else
            Result_Ref:=Graphs.Links.Link_Time_Results
              (Graphs.Links.Regular_Link(Next_Link_Ref.all));
         end if;
         Results.Set_Worst_Blocking_Time
           (Result_Ref.all,Total_Blocking.Block);
         Results.Set_Num_Of_Suspensions
           (Result_Ref.all,Total_Blocking.Num);

         if Verbose then
            Put_Line("Blocking term for segment of transaction "&
                     Transactions.Name(Trans_Ref)&" starting at operation "&
                     Operations.Name
                     (Graphs.Event_Handlers.Activity_Operation
                      (Graphs.Event_Handlers.Activity(Evnt_Hdlr_Ref.all)))&
                     " :");
            Put_Line("    B="&IO.Time_Image(Total_Blocking.Block));
            Put_Line("    N="&Natural'Image(Total_Blocking.Num));
         end if;

      end Calculate_Blocking_For_Segment;

      ------------------------------
      -- Calculate_Blocking_Time --
      ------------------------------
      -- Calculates blocking time for transaction Trans_Ref

      procedure Calculate_Blocking_Time
        (Trans_Ref : in Mast.Transactions.Transaction_Ref;
         The_System : in out Mast.Systems.System;
         Verbose : in Boolean:=True;
         Ceil_List : in Ceiling_Lists.List;
         Res_Kind_List : in Resource_Kind_Lists.List;
         Critical_Sections : in Critical_Section_Lists.List;
         Transaction : Translation.Linear_Transaction_System)
      is

         procedure Traverse_Paths_From_Link_Once
           (Trans_Ref : MAST.Transactions.Transaction_Ref;
            The_Link_Ref : MAST.Graphs.Link_Ref;
            The_System : in Mast.Systems.System;
            Verbose : in Boolean:=True;
            Ceil_List : in Ceiling_Lists.List;
            Res_Kind_List : in Resource_Kind_Lists.List;
            Critical_Sections : in Critical_Section_Lists.List)
         is
            An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
            First_Link_Ref,Next_Link_Ref : MAST.Graphs.Link_Ref;
            Link_Iterator : Graphs.Event_Handlers.Iteration_Object;

         begin
            if The_Link_Ref=null then
               return;
            end if;
            An_Event_Handler_Ref:=MAST.Graphs.Output_Event_Handler
              (The_Link_Ref.all);
            if An_Event_Handler_Ref/=null then
               if An_Event_Handler_Ref.all in
                 MAST.Graphs.Event_Handlers.Simple_Event_Handler'Class
               then
                  if An_Event_Handler_Ref.all in
                    MAST.Graphs.Event_Handlers.Activity'Class
                  then
                     Calculate_Blocking_For_Segment
                       (Trans_Ref,The_Link_Ref,Next_Link_Ref,
                        Verbose,Critical_Sections,Res_Kind_List,Transaction,
                        The_System.System_Pip_Behaviour);
                  else
                     Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
                       (MAST.Graphs.Event_Handlers.Simple_Event_Handler
                        (An_Event_Handler_Ref.all));
                  end if;
                  Traverse_Paths_From_Link_Once
                    (Trans_Ref,Next_Link_Ref,The_System,Verbose,
                     Ceil_List,Res_Kind_List,Critical_Sections);
               elsif An_Event_Handler_Ref.all in
                 MAST.Graphs.Event_Handlers.Output_Event_Handler'Class
               then
                  MAST.Graphs.Event_Handlers.Rewind_Output_Links
                    (MAST.Graphs.Event_Handlers.Output_Event_Handler
                     (An_Event_Handler_Ref.all),Link_Iterator);
                  for I in 1..MAST.Graphs.Event_Handlers.Num_Of_Output_Links
                    (MAST.Graphs.Event_Handlers.Output_Event_Handler
                     (An_Event_Handler_Ref.all))
                  loop
                     MAST.Graphs.Event_Handlers.Get_Next_Output_Link
                       (MAST.Graphs.Event_Handlers.Output_Event_Handler
                        (An_Event_Handler_Ref.all),
                        Next_Link_Ref,Link_Iterator);
                     Traverse_Paths_From_Link_Once
                       (Trans_Ref,Next_Link_Ref,The_System,Verbose,
                        Ceil_List,Res_Kind_List,Critical_Sections);
                  end loop;
               else -- input Event_Handler
                  MAST.Graphs.Event_Handlers.Rewind_Input_Links
                    (MAST.Graphs.Event_Handlers.Input_Event_Handler
                     (An_Event_Handler_Ref.all),Link_Iterator);
                  MAST.Graphs.Event_Handlers.Get_Next_Input_Link
                    (MAST.Graphs.Event_Handlers.Input_Event_Handler
                     (An_Event_Handler_Ref.all),First_Link_Ref,Link_Iterator);
                  -- continue only if this is the first input Link
                  if First_Link_Ref=The_Link_Ref then
                     Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
                       (MAST.Graphs.Event_Handlers.Input_Event_Handler
                        (An_Event_Handler_Ref.all));
                     Traverse_Paths_From_Link_Once
                       (Trans_Ref,Next_Link_Ref,The_System,Verbose,
                        Ceil_List,Res_Kind_List,Critical_Sections);
                  end if;
               end if;
            end if;
         end Traverse_Paths_From_Link_Once;

         A_Link_Ref : MAST.Graphs.Link_Ref;
         Iterator : Transactions.Link_Iteration_Object;

      begin
         -- loop for each path in the transaction
         Transactions.Rewind_External_Event_Links(Trans_Ref.all,Iterator);
         for I in 1..Transactions.Num_Of_External_Event_Links
           (Trans_Ref.all)
         loop
            Transactions.Get_Next_External_Event_Link
              (Trans_Ref.all,A_Link_Ref,Iterator);
            Traverse_Paths_From_Link_Once
              (Trans_Ref,A_Link_Ref,The_System,Verbose,Ceil_List,
               Res_Kind_List,Critical_Sections);
         end loop;
      end Calculate_Blocking_Time;


      -- declarations and instructions of Calculate_Blocking_Times

      Trans_Ref : MAST.Transactions.Transaction_Ref;
      Ceil_List : Ceiling_Lists.List;
      Trans_Iterator : Transactions.Lists.Index;
      Res_Kind_List : Resource_Kind_Lists.List;
      Critical_Sections : Critical_Section_Lists.List;

      Transaction : Translation.Linear_Transaction_System;

   begin
      if Restrictions.Linear_Plus_Transactions_Only (The_System,False) then
         Translation.Translate_Linear_System(The_System,Transaction,False);
      else
         if Verbose then
            Put_Line("Calculate_Blocking_Times not yet implemented for"&
                     " Multiple-Event systems");
         end if;
         raise Tool_Exceptions.Tool_Failure;
      end if;
      Check_Task_Preemption_Levels_Consistency(The_System,Verbose);
      Calculate_Resource_Kinds (The_System,Verbose,Res_Kind_List,True);
      Calculate_Ceilings (The_System,Verbose,Ceil_List,Res_Kind_List);
      Check_Ceiling_Consistency(The_System,Verbose,Ceil_List,Res_Kind_List);
      Calculate_Critical_Sections
        (The_System,Verbose,Ceil_List,Res_Kind_List,Critical_Sections);
      Add_High_Priority_Sections
        (The_System,Verbose,Critical_Sections);
      -- Loop for every transaction
      MAST.Transactions.Lists.Rewind(The_System.Transactions,Trans_Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Trans_Iterator);
         Calculate_Blocking_Time (Trans_Ref,The_System,Verbose,
                                  Ceil_List,Res_Kind_List,Critical_Sections,
                                  Transaction);
      end loop;
   exception
      when Ceiling_Out_Of_Range =>
         Tool_Exceptions.Set_Restriction_Message
           ("Found ceiling priority Out of range");
         raise Tool_Exceptions.Restriction_Not_Met;
   end Calculate_Blocking_Times;

   -------------------------------------------
   -- Check_Shared_Resources_Total_Ordering --
   -------------------------------------------

   procedure Check_Shared_Resources_Total_Ordering
     (The_System : in MAST.Systems.System;
      Ordered : out Boolean;
      Verbose : in Boolean:=True)
   is
   begin
      null;
   end Check_Shared_Resources_Total_Ordering;

   ---------------------------------
   -- Check_System_Schedulability --
   ---------------------------------

   procedure Check_System_Schedulability
     (The_System : MAST.Systems.System;
      Is_Schedulable : out Boolean;
      Verbose : in Boolean:=True)
   is
      A_Trans_Ref : Transactions.Transaction_Ref;
      Trans_Iterator : Transactions.Lists.Index;
      Is_Sched : Boolean;
   begin
      Is_Schedulable := True;
      -- loop for every transaction
      MAST.Transactions.Lists.Rewind
        (The_System.Transactions,Trans_Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (A_Trans_Ref,The_System.Transactions,Trans_Iterator);
         Check_Transaction_Schedulability
           (A_Trans_Ref,Is_Sched,Verbose);
         Is_Schedulable := Is_Schedulable and Is_Sched;
      end loop;
   end Check_System_Schedulability;

   --------------------------------------
   -- Check_Transaction_Schedulability --
   --------------------------------------

   procedure Check_Transaction_Schedulability
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Is_Schedulable : out Boolean;
      Verbose : in Boolean:=True)
   is
      A_Link_Ref : Graphs.Link_Ref;
      Link_Iterator : Transactions.Link_Iteration_Object;
      A_Timing_Req_Ref : Timing_Requirements.Timing_Requirement_Ref;
      A_Result_Ref : Results.Timing_Result_Ref;
      Is_Met : Boolean;
   begin
      Is_Schedulable := True;
      -- Check timing requirements for external event links
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
            Timing_Requirements.Check
              (A_Timing_Req_Ref.all,Results.Timing_Result(A_Result_Ref.all),
               Is_Met);
            Is_Schedulable := Is_Schedulable and Is_Met;
            if Verbose and (not Is_Met) then
               Put_Line("Timing requirement not met in transaction "&
                        Transactions.Name(Trans_Ref)&", external event "&
                        Graphs.Name(A_Link_Ref));
            end if;
         end if;

      end loop;

      -- Check timing requirements for internal event links
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
            Timing_Requirements.Check
              (A_Timing_Req_Ref.all,Results.Timing_Result(A_Result_Ref.all),
               Is_Met);
            Is_Schedulable := Is_Schedulable and Is_Met;
            if Verbose and (not Is_Met) then
               Put_Line("Timing requirement not met in transaction "&
                        Transactions.Name(Trans_Ref)&", internal event "&
                        Graphs.Name(A_Link_Ref));
            end if;
         end if;
      end loop;
   end Check_Transaction_Schedulability;

   ----------------------
   -- Utilization_Test --
   ----------------------

   procedure Utilization_Test
     (The_System : in MAST.Systems.System;
      Suceeds : out Boolean;
      Verbose : in Boolean:=True)
   is
   begin
      null;
   end Utilization_Test;

   -----------------------------------------------
   -- Calculate_Processing_Resource_Utilization --
   -----------------------------------------------

   function Calculate_Processing_Resource_Utilization
     (The_System : MAST.Systems.System;
      The_PR : Mast.Processing_Resources.Processing_Resource_Ref;
      Verbose : Boolean := True) return Float

   is
      type Processor_ID is new Natural;
      type Transaction_ID is new Natural;
      type Task_ID is new Natural;

      Max_Processors:constant Processor_ID:=Processor_ID
        (Processing_Resources.Lists.Size
         (The_System.Processing_Resources));
      Max_Transactions:constant Transaction_ID:=Transaction_Id
        ((Mast.Max_Numbers.Calculate_Max_Transactions(The_System)));
      Max_Tasks_Per_Transaction:constant Task_ID:=Task_ID
        (Mast.Max_Numbers.Calculate_Max_Tasks_Per_Transaction(The_System));

      subtype Processor_ID_Type is Processor_ID
        range 0..Max_Processors;
      subtype Transaction_ID_Type is Transaction_ID
        range 0..Max_Transactions;
      subtype Task_ID_Type is Task_ID
        range 0..Max_Tasks_Per_Transaction;

      package Translation is new Linear_Translation
        (Processor_ID_Type, Transaction_ID_Type, Task_ID_Type,
         Max_Processors, Max_Transactions, Max_Tasks_Per_Transaction);

      use Translation;

      Transaction : Linear_Transaction_System;
      Utilization : Time := 0.0;

   begin
      Translate_Linear_System(The_System,Transaction,False);
      for Tr in Transaction_ID_Type range 1..Max_Transactions loop
         exit when Transaction(Tr).Ni=0;
         -- uses Cij and Tij, which are values for the analysis
         -- of other tasks.
         for Tsk in 1..Transaction(Tr).Ni loop
            if Transaction(Tr).The_Task(Tsk).Pav.P_R_Ref = The_PR then
               Utilization := Utilization +
                 Transaction(Tr).The_Task(Tsk).Cij/Transaction(Tr).Ti;
            end if;
         end loop;
      end loop;
      if Verbose then
         Put_Line("   Utilization of "&
                  Var_Strings.To_String
                  (Mast.Processing_Resources.Name(The_PR.all))&" : "&
                  Mast.IO.Time_Image(Utilization*Time(100.0))&"%");
      end if;
      if Utilization >= Float'Large then
         return Float'Large;
      else
         return Float(Utilization);
      end if;
   end Calculate_Processing_Resource_Utilization;

   ----------------------------------
   -- Calculate_System_Utilization --
   ----------------------------------

   function Calculate_System_Utilization
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Float

   is
      type Processor_ID is new Natural;
      type Transaction_ID is new Natural;
      type Task_ID is new Natural;

      Max_Processors:constant Processor_ID:=Processor_ID
        (Processing_Resources.Lists.Size
         (The_System.Processing_Resources));
      Max_Transactions:constant Transaction_ID:=Transaction_Id
        ((Mast.Max_Numbers.Calculate_Max_Transactions(The_System)));
      Max_Tasks_Per_Transaction:constant Task_ID:=Task_ID
        (Mast.Max_Numbers.Calculate_Max_Tasks_Per_Transaction(The_System));

      subtype Processor_ID_Type is Processor_ID
        range 0..Max_Processors;
      subtype Transaction_ID_Type is Transaction_ID
        range 0..Max_Transactions;
      subtype Task_ID_Type is Task_ID
        range 0..Max_Tasks_Per_Transaction;

      package Translation is new Linear_Translation
        (Processor_ID_Type, Transaction_ID_Type, Task_ID_Type,
         Max_Processors, Max_Transactions, Max_Tasks_Per_Transaction);

      use Translation;

      Transaction : Linear_Transaction_System;
      Utilization : Time := 0.0;
      Max_Utilization : Time:=Time'First;

   begin
      Translate_Linear_System(The_System,Transaction,False);
      for Tr in Transaction_ID_Type range 1..Max_Transactions loop
         exit when Transaction(Tr).Ni=0;
         -- uses Cij and Tij, which are values for the analysis
         -- of other tasks.
         for Tsk in 1..Transaction(Tr).Ni loop
            Utilization := Utilization+
              Transaction(Tr).The_Task(Tsk).Cij/Transaction(Tr).Ti;
         end loop;
      end loop;
      Utilization := Utilization/Time(Max_Processors);
      if Verbose then
         Put_Line("   System utilization : "&
                  Mast.IO.Time_Image(Utilization*Time(100.0))&"%");
      end if;
      if Utilization >= Float'Large then
         return Float'Large;
      else
         return Float(Utilization);
      end if;
   end Calculate_System_Utilization;

end MAST.Miscelaneous_Tools;
