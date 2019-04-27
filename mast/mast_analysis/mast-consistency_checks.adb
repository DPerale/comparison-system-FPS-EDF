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

with MAST.Graphs,MAST.Graphs.Links,MAST.Graphs.Event_Handlers,
  MAST.Events, MAST.Operations, MAST.Shared_Resources,
  MAST.Transaction_Operations, MAST.Scheduling_Servers,
  Mast.Processing_Resources,Mast.Scheduling_Parameters,
  Mast.Processing_Resources.Network,
  Mast.Processing_Resources.Processor,
  Mast.Drivers,
  Mast.Schedulers, Mast.Schedulers.Primary, Mast.Schedulers.Secondary,
  Mast.Scheduling_Policies,
  Ada.Text_IO,Var_Strings,
  Doubly_Linked_Lists,List_Exceptions;
use Ada.Text_IO,Var_Strings;
use type MAST.Graphs.Link_Ref;
use type MAST.Graphs.Event_Handler_Ref;
use type MAST.Events.Event_Ref;
use type MAST.Graphs.Link_Lists.Index;
use type MAST.Graphs.Event_Handler_Lists.Index;
use type MAST.Shared_Resources.Shared_Resource_Ref;
use type Mast.Scheduling_Servers.Scheduling_Server_Ref;
use type Mast.Operations.Operation_Ref;
use type Mast.Processing_Resources.Processing_Resource_Ref;
use type Mast.Scheduling_Parameters.Sched_Parameters_Ref;
use type Mast.Schedulers.Scheduler_Ref;
use type Mast.Scheduling_Policies.Scheduling_Policy_Ref;
use type Mast.Processing_Resources.Processor.Processor_Ref;

package body MAST.Consistency_Checks is

   package Resource_Lists is new Doubly_Linked_Lists
     (Element => MAST.Shared_Resources.Shared_Resource_Ref,
        "="     => "=");

   use type Resource_Lists.Index;

   ---------------
   -- Message   --
   ---------------

   procedure Message (Verbose : Boolean;
                      Restriction_Name, Message_Line1 : String;
                      Message_Line2,Message_Line3 : String:="") is
   begin
      if Verbose then
         Put_Line("Detected Restriction Failure in: "&Restriction_Name);
         Put_Line("   "&Message_Line1);
         if Message_Line2/="" then
            Put_Line("   "&Message_Line2);
         end if;
         if Message_Line3/="" then
            Put_Line("   "&Message_Line3);
         end if;
      end if;
   end Message;

   --------------------------------------
   -- Consistent_Shared_Resource_Usage --
   --------------------------------------

   function Consistent_Shared_Resource_Usage
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True)
     return Boolean
   is
      Restriction_Name : constant String:=
        "Consistent Shared Resource Usage";
      Trans_Name : constant String:="Transaction: "&
        To_String(MAST.Transactions.Name(Trans_Ref));

      Inconsistency : exception;

      procedure Process_Operation_Resources
        (The_Operation_Ref : MAST.Operations.Operation_Ref;
         Locked_Resources : in out Resource_Lists.List)
      is
         An_Act_Ref : MAST.Operations.Operation_Ref;
         Res_Ref : MAST.Shared_Resources.Shared_Resource_Ref;
         The_Res_Index : Resource_Lists.Index;
         Iterator : Operations.Resource_Iteration_Object;
         Op_Iterator : Operations.Operation_Iteration_Object;
      begin
         if The_Operation_Ref.all in
           MAST.Operations.Simple_Operation'Class
         then
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
                  Res_Ref,Iterator);
               -- Rule 2: no resource is locked if it was already locked
               if Resource_Lists.Find(Res_Ref,Locked_Resources)/=
                 Resource_Lists.Null_Index
               then
                  Message(Verbose,Restriction_Name,Trans_Name,
                          "Rule 2 not met: resource locked twice",
                          "Resource: "&
                          To_String(MAST.Shared_Resources.Name(Res_Ref)));
                  raise Inconsistency;
               else
                  Resource_Lists.Add(Res_Ref,Locked_Resources);
               end if;
            end loop;
            -- check unlocked resources
            MAST.Operations.Rewind_Unlocked_Resources
              (MAST.Operations.Simple_Operation(The_Operation_Ref.all),
               Iterator);
            for I in 1..MAST.Operations.Num_Of_Unlocked_Resources
              (MAST.Operations.Simple_Operation(The_Operation_Ref.all))
            loop
               MAST.Operations.Get_Next_Unlocked_Resource
                 (MAST.Operations.Simple_Operation(The_Operation_Ref.all),
                  Res_Ref,Iterator);
               -- Rule 3: no resource is unlocked if not previously locked
               The_Res_Index:= Resource_Lists.Find
                 (Res_Ref,Locked_Resources);
               if  The_Res_Index=Resource_Lists.Null_Index
               then
                  Message(Verbose,Restriction_Name,Trans_Name,
                          "Rule 3 not met: unlocked resource that was "&
                          "not previously locked",
                          "Resource: "&
                          To_String(MAST.Shared_Resources.Name(Res_Ref)));
                  raise Inconsistency;
               else
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
               Process_Operation_Resources(An_Act_Ref,Locked_Resources);
            end loop;
         elsif The_Operation_Ref.all in
           MAST.Operations.Message_Transmission_Operation'Class
         then
            null; -- messages have no shared resources
         else
            raise Incorrect_Object;
         end if;
      end Process_Operation_Resources;

      procedure Traverse_Paths_From_Link
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Link_Ref : MAST.Graphs.Link_Ref;
         Locked_Resources : in out Resource_Lists.List)
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
                     Locked_Resources);
               end if;
               Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
                 (MAST.Graphs.Event_Handlers.Simple_Event_Handler
                  (An_Event_Handler_Ref.all));
               Traverse_Paths_From_Link
                 (Trans_Ref,Next_Link_Ref,Locked_Resources);
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
                    (Trans_Ref,Next_Link_Ref,Cloned_Locked_Resources);
               end loop;
            else -- input Event_Handler
               Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
                 (MAST.Graphs.Event_Handlers.Input_Event_Handler
                  (An_Event_Handler_Ref.all));
               Traverse_Paths_From_Link
                 (Trans_Ref,Next_Link_Ref,Locked_Resources);
            end if;
         else
            -- end of a path
            -- Rule 1: all locked resources are unlocked
            if not Resource_Lists.Empty(Locked_Resources) then
               Message(Verbose,Restriction_Name,Trans_Name,
                       "Rule 1 not met: not all locked resources "&
                       "were unlocked");
               raise Inconsistency;
            end if;
         end if;
      end Traverse_Paths_From_Link;

      Locked_Resources : Resource_Lists.List;
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
         Resource_Lists.Init(Locked_Resources);
         Traverse_Paths_From_Link
           (Trans_Ref,A_Link_Ref,Locked_Resources);
      end loop;
      return True;
   exception
      when Inconsistency =>
         return False;
   end Consistent_Shared_Resource_Usage;

   --------------------------------------
   -- Consistent_Shared_Resource_Usage --
   --------------------------------------

   function Consistent_Shared_Resource_Usage
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True)
     return Boolean
   is
      Trans_Ref : MAST.Transactions.Transaction_Ref;
      Copy_Of_Trans_List : MAST.Transactions.Lists.List:=
        The_System.Transactions;
      Iterator : Transactions.Lists.Index;
   begin
      -- Loop for every transaction
      MAST.Transactions.Lists.Rewind(Copy_Of_Trans_List,Iterator);
      for I in 1..MAST.Transactions.Lists.Size(Copy_Of_Trans_List)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,Copy_Of_Trans_List,Iterator);
         if not Consistent_Shared_Resource_Usage(Trans_Ref,Verbose)
         then
            return False;
         end if;
      end loop;
      return True;
   end Consistent_Shared_Resource_Usage;

   ---------------------------------------------------
   -- Consistent_Shared_Resource_Usage_For_Segments --
   ---------------------------------------------------
   -- Checks the following rule for the specified transaction:
   --    all locked resources in a segment are unlocked in that segment

   function Consistent_Shared_Resource_Usage_For_Segments
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True)
     return Boolean
   is
      Restriction_Name : constant String:=
        "Consistent Shared Resource Usage For Segments";
      Trans_Name : constant String:="Transaction: "&
        To_String(MAST.Transactions.Name(Trans_Ref));

      Inconsistency : exception;

      procedure Process_Operation_Resources
        (The_Operation_Ref : MAST.Operations.Operation_Ref;
         Locked_Resources : in out Resource_Lists.List)
      is
         An_Act_Ref : MAST.Operations.Operation_Ref;
         Res_Ref : MAST.Shared_Resources.Shared_Resource_Ref;
         The_Res_Index : Resource_Lists.Index;
         Iterator : Operations.Resource_Iteration_Object;
         Op_Iterator : Operations.Operation_Iteration_Object;
      begin
         if The_Operation_Ref.all in
           MAST.Operations.Simple_Operation'Class
         then
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
                  Res_Ref,Iterator);
               Resource_Lists.Add(Res_Ref,Locked_Resources);
            end loop;
            -- check unlocked resources
            MAST.Operations.Rewind_Unlocked_Resources
              (MAST.Operations.Simple_Operation(The_Operation_Ref.all),
               Iterator);
            for I in 1..MAST.Operations.Num_Of_Unlocked_Resources
              (MAST.Operations.Simple_Operation(The_Operation_Ref.all))
            loop
               MAST.Operations.Get_Next_Unlocked_Resource
                 (MAST.Operations.Simple_Operation(The_Operation_Ref.all),
                  Res_Ref,Iterator);
               The_Res_Index:=Resource_Lists.Find(Res_Ref,Locked_Resources);
               Resource_Lists.Delete
                 (The_Res_Index,Locked_Resources,Res_Ref);
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
               Process_Operation_Resources(An_Act_Ref,Locked_Resources);
            end loop;
         else
            raise Incorrect_Object;
         end if;
      end Process_Operation_Resources;

      procedure Check_Segment
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Link_Ref : MAST.Graphs.Link_Ref;
         Next_Link_Ref : out MAST.Graphs.Link_Ref)
      is
         An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
         Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
         Locked_Resources : Resource_Lists.List;
      begin
         An_Event_Handler_Ref:=MAST.Graphs.
           Output_Event_Handler(The_Link_Ref.all);
         if An_Event_Handler_Ref=null or else An_Event_Handler_Ref.all not in
           MAST.Graphs.Event_Handlers.Activity'Class
         then
            raise Incorrect_Object;
         end if;
         Srvr_Ref:=Graphs.Event_Handlers.Activity_Server
           (Graphs.Event_Handlers.Activity(An_Event_Handler_Ref.all));
         loop
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
            Process_Operation_Resources
              (MAST.Graphs.Event_Handlers.Activity_Operation
               (MAST.Graphs.Event_Handlers.Activity
                (An_Event_Handler_Ref.all)),
               Locked_Resources);
         end loop;
         -- end of a segment
         -- Rule 1: all locked resources are unlocked
         if not Resource_Lists.Empty(Locked_Resources) then
            Message(Verbose,Restriction_Name,Trans_Name,
                    "Rule not met: not all locked resources "&
                    "were unlocked in segment");
            raise Inconsistency;
         end if;
      end Check_Segment;

      procedure Traverse_Paths_From_Link
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Link_Ref : MAST.Graphs.Link_Ref)
      is
         An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
         Next_Link_Ref : MAST.Graphs.Link_Ref;
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
                  Check_Segment
                    (Trans_Ref,The_Link_Ref,Next_Link_Ref);
               end if;
               Traverse_Paths_From_Link
                 (Trans_Ref,Next_Link_Ref);
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
                  Traverse_Paths_From_Link
                    (Trans_Ref,Next_Link_Ref);
               end loop;
            else -- input Event_Handler
               Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
                 (MAST.Graphs.Event_Handlers.Input_Event_Handler
                  (An_Event_Handler_Ref.all));
               Traverse_Paths_From_Link
                 (Trans_Ref,Next_Link_Ref);
            end if;
         end if;
      end Traverse_Paths_From_Link;

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
         Traverse_Paths_From_Link
           (Trans_Ref,A_Link_Ref);
      end loop;
      return True;
   exception
      when Inconsistency =>
         return False;
   end Consistent_Shared_Resource_Usage_For_Segments;

   ---------------------------------------------------
   -- Consistent_Shared_Resource_Usage_For_Segments --
   ---------------------------------------------------

   function Consistent_Shared_Resource_Usage_For_Segments
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True)
     return Boolean
   is
      Trans_Ref : MAST.Transactions.Transaction_Ref;
      Copy_Of_Trans_List : MAST.Transactions.Lists.List:=
        The_System.Transactions;
      Iterator : Transactions.Lists.Index;
   begin
      -- Loop for every transaction
      MAST.Transactions.Lists.Rewind(Copy_Of_Trans_List,Iterator);
      for I in 1..MAST.Transactions.Lists.Size(Copy_Of_Trans_List)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,Copy_Of_Trans_List,Iterator);
         if not Consistent_Shared_Resource_Usage_For_Segments
           (Trans_Ref,Verbose)
         then
            return False;
         end if;
      end loop;
      return True;
   end Consistent_Shared_Resource_Usage_For_Segments;

   -----------------------------------
   -- Consistent_Transaction_Graphs --
   -----------------------------------

   function Consistent_Transaction_Graphs
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True)
     return Boolean
   is
      Restriction_Name : constant String:="Consistent Transaction Graph";
      Trans_Name : constant String:="Transaction: "&
        To_String(MAST.Transactions.Name(Trans_Ref));
      A_Link_Ref : MAST.Graphs.Link_Ref;
      An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
      Visited_Links_List : MAST.Graphs.Link_Lists.List;
      Visited_Event_Handlers_List : MAST.Graphs.Event_Handler_Lists.List;
      Initial_Event_Handler : Graphs.Event_Handler_Ref;

      Circular_Dependency : exception;

      procedure Add_To_Visited
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Link_Ref : MAST.Graphs.Link_Ref) is
      begin
         MAST.Graphs.Link_Lists.Add(The_Link_Ref,Visited_Links_List);
      end Add_To_Visited;

      procedure Add_To_Visited
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref)
      is
         The_Index : MAST.Graphs.Event_Handler_Lists.Index;
      begin
         The_Index:=MAST.Graphs.Event_Handler_Lists.Find
           (The_Event_Handler_Ref,Visited_Event_Handlers_List);
         if The_Index=MAST.Graphs.Event_Handler_Lists.Null_Index then
            MAST.Graphs.Event_Handler_Lists.Add
              (The_Event_Handler_Ref,Visited_Event_Handlers_List);
         else
            raise List_Exceptions.Already_Exists;
         end if;
      end Add_To_Visited;

      procedure Iterate_Transaction_Paths is new
        MAST.Transaction_Operations.Traverse_Paths_From_Link_Once
        (Operation_For_Links  => Add_To_Visited,
         Operation_For_Event_Handlers => Add_To_Visited);

      procedure Check_Circular_Dependencies
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Link_Ref : MAST.Graphs.Link_Ref) is
      begin
         if The_Link_Ref/=null and then
           Graphs.Output_Event_Handler(The_Link_Ref.all)=
           Initial_Event_Handler
         then
            raise Circular_Dependency;
         end if;
      end Check_Circular_Dependencies;

      procedure Check_Circular_Dependencies
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref) is
      begin
         null;
      end Check_Circular_Dependencies;

      procedure Iterate_From_Input_Event_Handler is new
        MAST.Transaction_Operations.Traverse_Paths_From_Link_Once
        (Operation_For_Links  => Check_Circular_Dependencies,
         Operation_For_Event_Handlers => Check_Circular_Dependencies);

      function Message_Ops_On_Network
        (Op_Ref : Operations.Operation_Ref;
         Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref)
        return Boolean
      is
         Iterator : Operations.Operation_Iteration_Object;
         An_Op_Ref : Operations.Operation_Ref;
      begin
         if Op_Ref.all in
           Operations.Simple_Operation'Class
         then
            return True;
         elsif Op_Ref.all in
           Operations.Composite_Operation'Class
         then
            -- iterate for internal operations
            Operations.Rewind_Operations
              (Operations.Composite_Operation'Class(Op_Ref.all),Iterator);
            for I in 1..Operations.Num_Of_Operations
              (Operations.Composite_Operation'Class(Op_Ref.all))
            loop
               Operations.Get_Next_Operation
                 (Operations.Composite_Operation'Class(Op_Ref.all),
                  An_Op_Ref,Iterator);
               if not Message_Ops_On_Network(An_Op_Ref,Srvr_Ref) then
                  return False;
               end if;
            end loop;
            return True;
         elsif Op_Ref.all in
           Operations.Message_Transmission_Operation'Class
         then
            begin
               if Scheduling_Servers.Server_Processing_Resource
                 (Srvr_Ref.all).all not in
                 Processing_Resources.Network.Network'Class
               then
                  return False;
               end if;
            exception
               when Incorrect_Object =>
                  return False;
            end;
            return True;
         else
            raise Incorrect_Object;
         end if;
      end Message_Ops_On_Network;

      function Message_Size_OK
        (Op_Ref : Operations.Operation_Ref;
         Network_Ref : Processing_Resources.Network.Network_Ref;
         Processor_Ref : Processing_Resources.Processor.Processor_Ref)
        return Boolean
      is
         Drv_Ref : Drivers.Driver_Ref;
         Drv_Iter : Processing_Resources.Network.Driver_Iteration_Object;
         Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
         Proc_Ref : Processing_Resources.Processing_Resource_Ref;
         The_Throughput : Throughput_Value:=
           Processing_Resources.Network.Throughput(Network_Ref.all);
      begin
         if Network_Ref.all in
           Processing_Resources.Network.Packet_Based_Network'class
         then
            Processing_Resources.Network.Rewind_Drivers
              (Network_Ref.all,Drv_Iter);
            for I in 1..Processing_Resources.Network.Num_Of_Drivers
              (Network_Ref.all)
            loop
               Processing_Resources.Network.Get_Next_Driver
                 (Network_Ref.all,Drv_Ref,Drv_Iter);
               if Drv_Ref.all in Drivers.Packet_Driver'Class then
                  Srvr_Ref := Drivers.Packet_Server
                    (Drivers.Packet_Driver'Class(Drv_Ref.all));
                  Proc_Ref:=Scheduling_Servers.Server_Processing_Resource
                    (Srvr_Ref.all);
                  if  Proc_Ref.all in
                    Processing_Resources.Processor.Processor'Class and then
                    Processing_Resources.Processor.Processor_Ref(Proc_Ref) =
                    Processor_Ref
                  then
                     if not Drivers.Message_Partitioning
                       (Drivers.Packet_Driver'Class(Drv_Ref.all))
                     then
                        return Operations.Worst_Case_Execution_Time
                          (Op_Ref.all,The_Throughput) <=
                          Processing_Resources.Network.
                          Max_Packet_Transmission_Time
                          (Processing_Resources.Network.Packet_Based_Network
                           (Network_Ref.all));
                     else
                        return True;
                     end if;
                  end if;
               else
                  raise Incorrect_Object;
               end if;
            end loop;
            -- No driver found means that the message size is not limited
            return True;
         else
            raise Incorrect_Object;
         end if;
      end Message_Size_OK;

      function Message_Size_OK_In_Sender
        (Op_Ref : Operations.Operation_Ref;
         Net_Ref : Processing_Resources.Network.Network_Ref;
         An_Event_Handler_Ref : Graphs.Event_Handler_Ref)
        return Boolean
      is
         Prev_Ev_Hdler_Ref : Graphs.Event_Handler_Ref;
         Prev_Link_Ref : Graphs.Link_Ref;
         Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
         Proc_Ref : Processing_Resources.Processing_Resource_Ref;
         Processor_Ref : Processing_Resources.Processor.Processor_Ref;
         Iter : Graphs.Event_Handlers.Iteration_Object;
      begin
         if An_Event_Handler_Ref.all in
           Graphs.Event_Handlers.Input_Event_Handler'Class
         then
            Graphs.Event_Handlers.Rewind_Input_Links
              (Graphs.Event_Handlers.Input_Event_Handler'Class
               (An_Event_Handler_Ref.all),Iter);
            for I in 1..Graphs.Event_Handlers.Num_Of_Input_Links
              (Graphs.Event_Handlers.Input_Event_Handler'Class
               (An_Event_Handler_Ref.all))
            loop
               Graphs.Event_Handlers.Get_Next_Input_Link
                 (Graphs.Event_Handlers.Input_Event_Handler'Class
                  (An_Event_Handler_Ref.all),Prev_Link_Ref,Iter);
               if Prev_Link_Ref/=null then
                  Prev_Ev_Hdler_Ref:=Graphs.Input_Event_Handler
                    (Prev_Link_Ref.all);
                  if Prev_Ev_Hdler_Ref/=null then
                     if Prev_Ev_Hdler_Ref.all in
                       Graphs.Event_Handlers.Activity'Class
                     then
                        Srvr_Ref:=Mast.Graphs.Event_Handlers.Activity_Server
                          (MAST.Graphs.Event_Handlers.Activity'class
                           (Prev_Ev_Hdler_Ref.all));
                        if Srvr_Ref/=null then
                           Proc_Ref:=
                             Scheduling_Servers.Server_Processing_Resource
                             (Srvr_Ref.all);
                           if Proc_Ref/=null and then Proc_Ref.all in
                             Processing_Resources.Processor.Processor'Class
                           then
                              Processor_Ref:=
                                Processing_Resources.Processor.Processor_Ref
                                (Proc_Ref);
                              if not Message_Size_OK
                                (Op_Ref,Net_Ref,Processor_Ref)
                              then
                                 return False;
                              end if;
                           end if;
                        end if;
                     else
                        if not Message_Size_OK_In_Sender
                          (Op_Ref,Net_Ref,Prev_Ev_Hdler_Ref)
                        then
                           return False;
                        end if;
                     end if;
                  end if;
               end if;
            end loop;
            -- If control reaches here all sizes have already been checked
            return True;
         else
            if An_Event_Handler_Ref.all in
              Graphs.Event_Handlers.Simple_Event_Handler'Class
            then
               Prev_Link_Ref:=Graphs.Event_Handlers.Input_Link
                 (Graphs.Event_Handlers.Simple_Event_Handler'Class
                  (An_Event_Handler_Ref.all));
            elsif An_Event_Handler_Ref.all in
              Graphs.Event_Handlers.Output_Event_Handler'Class
            then
               Prev_Link_Ref:=Graphs.Event_Handlers.Input_Link
                 (Graphs.Event_Handlers.Output_Event_Handler'Class
                  (An_Event_Handler_Ref.all));
            else
               raise Incorrect_Object;
            end if;
            if Prev_Link_Ref/=null then
               Prev_Ev_Hdler_Ref:=Graphs.Input_Event_Handler
                 (Prev_Link_Ref.all);
               if Prev_Ev_Hdler_Ref/=null then
                  if Prev_Ev_Hdler_Ref.all in
                    Graphs.Event_Handlers.Activity'Class
                  then
                     Srvr_Ref:=Mast.Graphs.Event_Handlers.Activity_Server
                       (MAST.Graphs.Event_Handlers.Activity'class
                        (Prev_Ev_Hdler_Ref.all));
                     if Srvr_Ref/=null then
                        Proc_Ref:=
                          Scheduling_Servers.Server_Processing_Resource
                          (Srvr_Ref.all);
                        if Proc_Ref/=null and then Proc_Ref.all in
                          Processing_Resources.Processor.Processor'Class
                        then
                           Processor_Ref:=
                             Processing_Resources.Processor.Processor_Ref
                             (Proc_Ref);
                           return Message_Size_OK
                             (Op_Ref,Net_Ref,Processor_Ref);
                        else
                           return True;
                        end if;
                     else
                        return True;
                     end if;
                  else
                     return Message_Size_OK_In_Sender
                       (Op_Ref,Net_Ref,Prev_Ev_Hdler_Ref);
                  end if;
               else
                  return True;
               end if;
            else
               return True;
            end if;
         end if;
      end Message_Size_OK_In_Sender;

      function Message_Size_OK_In_Receiver
        (Op_Ref : Operations.Operation_Ref;
         Net_Ref : Processing_Resources.Network.Network_Ref;
         An_Event_Handler_Ref : Graphs.Event_Handler_Ref)
        return Boolean
      is
         Post_Ev_Hdler_Ref : Graphs.Event_Handler_Ref;
         Post_Link_Ref : Graphs.Link_Ref;
         Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
         Proc_Ref : Processing_Resources.Processing_Resource_Ref;
         Processor_Ref : Processing_Resources.Processor.Processor_Ref;
         Iter : Graphs.Event_Handlers.Iteration_Object;
      begin
         if An_Event_Handler_Ref.all in
           Graphs.Event_Handlers.Output_Event_Handler'Class
         then
            Graphs.Event_Handlers.Rewind_Output_Links
              (Graphs.Event_Handlers.Output_Event_Handler'Class
               (An_Event_Handler_Ref.all),Iter);
            for I in 1..Graphs.Event_Handlers.Num_Of_Output_Links
              (Graphs.Event_Handlers.Output_Event_Handler'Class
               (An_Event_Handler_Ref.all))
            loop
               Graphs.Event_Handlers.Get_Next_Output_Link
                 (Graphs.Event_Handlers.Output_Event_Handler'Class
                  (An_Event_Handler_Ref.all),Post_Link_Ref,Iter);
               if Post_Link_Ref/=null then
                  Post_Ev_Hdler_Ref:=Graphs.Output_Event_Handler
                    (Post_Link_Ref.all);
                  if Post_Ev_Hdler_Ref/=null then
                     if Post_Ev_Hdler_Ref.all in
                       Graphs.Event_Handlers.Activity'Class
                     then
                        Srvr_Ref:=Mast.Graphs.Event_Handlers.Activity_Server
                          (MAST.Graphs.Event_Handlers.Activity'class
                           (Post_Ev_Hdler_Ref.all));
                        if Srvr_Ref/=null then
                           Proc_Ref:=
                             Scheduling_Servers.Server_Processing_Resource
                             (Srvr_Ref.all);
                           if Proc_Ref/=null and then Proc_Ref.all in
                             Processing_Resources.Processor.Processor'Class
                           then
                              Processor_Ref:=
                                Processing_Resources.Processor.Processor_Ref
                                (Proc_Ref);
                              if not Message_Size_OK
                                (Op_Ref,Net_Ref,Processor_Ref)
                              then
                                 return False;
                              end if;
                           end if;
                        end if;
                     else
                        if not Message_Size_OK_In_Receiver
                          (Op_Ref,Net_Ref,Post_Ev_Hdler_Ref)
                        then
                           return False;
                        end if;
                     end if;
                  end if;
               end if;
            end loop;
            -- If control reaches here all sizes have already been checked
            return True;
         else
            if An_Event_Handler_Ref.all in
              Graphs.Event_Handlers.Simple_Event_Handler'Class
            then
               Post_Link_Ref:=Graphs.Event_Handlers.Output_Link
                 (Graphs.Event_Handlers.Simple_Event_Handler'Class
                  (An_Event_Handler_Ref.all));
            elsif An_Event_Handler_Ref.all in
              Graphs.Event_Handlers.Input_Event_Handler'Class
            then
               Post_Link_Ref:=Graphs.Event_Handlers.Output_Link
                 (Graphs.Event_Handlers.Input_Event_Handler'Class
                  (An_Event_Handler_Ref.all));
            else
               raise Incorrect_Object;
            end if;
            if Post_Link_Ref/=null then
               Post_Ev_Hdler_Ref:=Graphs.Output_Event_Handler
                 (Post_Link_Ref.all);
               if Post_Ev_Hdler_Ref/=null then
                  if Post_Ev_Hdler_Ref.all in
                    Graphs.Event_Handlers.Activity'Class
                  then
                     Srvr_Ref:=Mast.Graphs.Event_Handlers.Activity_Server
                       (MAST.Graphs.Event_Handlers.Activity'class
                        (Post_Ev_Hdler_Ref.all));
                     if Srvr_Ref/=null then
                        Proc_Ref:=
                          Scheduling_Servers.Server_Processing_Resource
                          (Srvr_Ref.all);
                        if Proc_Ref/=null and then Proc_Ref.all in
                          Processing_Resources.Processor.Processor'Class
                        then
                           Processor_Ref:=
                             Processing_Resources.Processor.Processor_Ref
                             (Proc_Ref);
                           return Message_Size_OK
                             (Op_Ref,Net_Ref,Processor_Ref);
                        else
                           return True;
                        end if;
                     else
                        return True;
                     end if;
                  else
                     return Message_Size_OK_In_Receiver
                       (Op_Ref,Net_Ref,Post_Ev_Hdler_Ref);
                  end if;
               else
                  return True;
               end if;
            else
               return True;
            end if;
         end if;
      end Message_Size_OK_In_Receiver;

      Link_Iterator : Transactions.Link_Iteration_Object;
      Event_Iterator : Transactions.Event_Handler_Iteration_Object;
      Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
      Op_Ref : Operations.Operation_Ref;

   begin
      -- Rule 1: At least one input Link
      if Transactions.Num_Of_External_Event_Links(Trans_Ref.all)=0 then
         Message(Verbose,Restriction_Name,Trans_Name,
                 "Rule 1 not met: No input Links");
         return False;
      end if;
      -- Loop for all external event links, to check rule 2
      MAST.Transactions.Rewind_External_Event_Links
        (Trans_Ref.all,Link_Iterator);
      for I in 1..MAST.Transactions.Num_Of_External_Event_Links
        (Trans_Ref.all)
      loop
         MAST.Transactions.Get_Next_External_Event_Link
           (Trans_Ref.all,A_Link_Ref,Link_Iterator);
         -- Rule 2: Each input Link directed at one Event_Handler,
         -- and with an external event
         if MAST.Graphs.Output_Event_Handler(A_Link_Ref.all)=null or else
           MAST.Graphs.Links.Event_Of
           (Mast.Graphs.Links.Regular_Link(A_Link_Ref.all))=null
         then
            Message(Verbose,Restriction_Name,Trans_Name,
                    "Rule 2 not met: input Link has no Event_Handler, "&
                    "or has no external event",
                    "Link: "&To_String(MAST.Graphs.Name(A_Link_Ref)));
            return False;
         end if;
      end loop;
      -- Loop for all internal event links, to check rule 3
      MAST.Transactions.Rewind_Internal_Event_Links
        (Trans_Ref.all,Link_Iterator);
      for I in 1..MAST.Transactions.Num_Of_Internal_Event_Links
        (Trans_Ref.all)
      loop
         MAST.Transactions.Get_Next_Internal_Event_Link
           (Trans_Ref.all,A_Link_Ref,Link_Iterator);
         -- Rule 3: Each non-input Link comes from a Event_Handler
         if MAST.Graphs.Input_Event_Handler(A_Link_Ref.all)=null then
            Message
              (Verbose,Restriction_Name,Trans_Name,
               "Rule 3 not met: non-input Link has no "&
               "input Event_Handler",
               "Link: "&To_String(MAST.Graphs.Name(A_Link_Ref)));
            return False;
         end if;
      end loop;

      -- Loop for all Event_Handlers, to check Rules 4, 5, 6, 10,
      --   11, 22, 25 and 14

      MAST.Transactions.Rewind_Event_Handlers
        (Trans_Ref.all,Event_Iterator);
      for I in 1..MAST.Transactions.Num_Of_Event_Handlers(Trans_Ref.all)
      loop
         MAST.Transactions.Get_Next_Event_Handler
           (Trans_Ref.all,An_Event_Handler_Ref,Event_Iterator);
         -- Rule 4: Each simple Event_Handler has an input Link
         --   and an output Link
         if An_Event_Handler_Ref.all in
           MAST.Graphs.Event_Handlers.Simple_Event_Handler'Class
         then
            if MAST.Graphs.Event_Handlers.Input_Link
              (MAST.Graphs.Event_Handlers.Simple_Event_Handler
               (An_Event_Handler_Ref.all))=null or else
              MAST.Graphs.Event_Handlers.Output_Link
              (MAST.Graphs.Event_Handlers.Simple_Event_Handler
               (An_Event_Handler_Ref.all))=null
            then
               Message
                 (Verbose,Restriction_Name,Trans_Name,
                  "Rule 4 not met: Simple Event_Handler has no "&
                  "input link or no output Link");
               return False;
            end if;
            -- Rule 10: All Activities have an operation
            -- Rule 11: All Activities have a scheduling server
            if An_Event_Handler_Ref.all in
              MAST.Graphs.Event_Handlers.Activity'Class
            then
               Op_Ref:=Mast.Graphs.Event_Handlers.Activity_Operation
                 (MAST.Graphs.Event_Handlers.Activity
                  (An_Event_Handler_Ref.all));
               Srvr_Ref:=Mast.Graphs.Event_Handlers.Activity_Server
                 (MAST.Graphs.Event_Handlers.Activity
                  (An_Event_Handler_Ref.all));
               if Op_Ref=null then
                  Message
                    (Verbose,Restriction_Name,Trans_Name,
                     "Rule 10 not met: Activity has no operation");
                  return False;
               else
                  -- Rule 22: All Message Transmission Operations are
                  --          executed by scheduling servers executing
                  --          on a network
                  if not Message_Ops_On_Network(Op_Ref, Srvr_Ref)
                  then
                     Message
                       (Verbose,Restriction_Name,Trans_Name,
                        "Rule 22 not met: Message operation "&
                        To_String(Operations.Name(Op_Ref))&
                        " is not executed on a network");
                     return False;
                  end if;
                  -- Rule 25: The size of each message sent through a network
                  --          driver that does not support message
                  --          partitioning is smaller than the
                  --          maximum allowable message size
                  if Srvr_Ref/=null then
                     declare
                        Sch_Ref : Schedulers.Scheduler_Ref;
                        Proc_Ref :
                          Processing_Resources.Processing_Resource_Ref;
                        Net_Ref : Processing_Resources.Network.Network_Ref;
                     begin
                        Sch_Ref:=Scheduling_Servers.Server_Scheduler
                          (Srvr_Ref.all);
                        if Sch_Ref/=null and then Sch_Ref.all in
                          Schedulers.Primary.Primary_Scheduler
                        then
                           Proc_Ref:=Schedulers.Primary.Host
                             (Schedulers.Primary.Primary_Scheduler'Class
                              (Sch_Ref.all));
                           if Proc_Ref/=null and then Proc_Ref.all in
                             Processing_Resources.Network.Network'Class
                           then
                              Net_Ref:=Processing_Resources.Network.Network_Ref
                                (Proc_Ref);
                              if (not Message_Size_OK_In_Sender
                                  (Op_Ref,Net_Ref,An_Event_Handler_Ref))
                                or else
                                (not Message_Size_OK_In_Receiver
                                 (Op_Ref,Net_Ref,An_Event_Handler_Ref))
                              then
                                 Message
                                   (Verbose,Restriction_Name,Trans_Name,
                                    "Rule 25 not met: Message size of "&
                                    To_String(Operations.Name(Op_Ref))&
                                    " too large for network driver");
                                 return False;
                              end if;
                           end if;
                        end if;
                     end;
                  end if;
               end if;
               if Srvr_Ref=null then
                  Message
                    (Verbose,Restriction_Name,Trans_Name,
                     "Rule 11 not met: Activity has no scheduling server");
                  return False;
               end if;
            elsif An_Event_Handler_Ref.all in
              MAST.Graphs.Event_Handlers.Delay_Event_Handler'Class or else
              An_Event_Handler_Ref.all in
              MAST.Graphs.Event_Handlers.Rate_Divisor'Class
            then
               -- Rule 14: All rate divisors, offset and delay event handlers
               --          are only followed by activities
               declare
                  Out_Lnk: Graphs.Link_Ref:=
                    MAST.Graphs.Event_Handlers.Output_Link
                    (MAST.Graphs.Event_Handlers.Simple_Event_Handler
                     (An_Event_Handler_Ref.all));
                  Next_Evnt_Hdlr: Graphs.Event_Handler_Ref:=
                    Mast.Graphs.Output_Event_Handler(Out_Lnk.all);
               begin
                  if Next_Evnt_Hdlr=null or else not (Next_Evnt_Hdlr.all in
                                                      Graphs.Event_Handlers.Activity'Class)
                  then
                     Message
                       (Verbose,Restriction_Name,Trans_Name,
                        "Rule 14 not met: Rate Divisor, Delay, or Offest"&
                        " are not followed by activity");
                     return False;
                  end if;
               end;
            end if;
         elsif An_Event_Handler_Ref.all in
           MAST.Graphs.Event_Handlers.Input_Event_Handler'Class
         then
            -- Rule 5: Each input Event_Handler has 2 or more input
            --         links and an output Link
            if MAST.Graphs.Event_Handlers.Num_Of_Input_Links
              (MAST.Graphs.Event_Handlers.Input_Event_Handler
               (An_Event_Handler_Ref.all))<=1 or else
              MAST.Graphs.Event_Handlers.Output_Link
              (MAST.Graphs.Event_Handlers.Input_Event_Handler
               (An_Event_Handler_Ref.all))=null
            then
               Message
                 (Verbose,Restriction_Name,Trans_Name,
                  "Rule 5 not met: Input Event_Handler has <2 "&
                  "input links or no output Link");
               return False;
            end if;
         elsif An_Event_Handler_Ref.all in
           MAST.Graphs.Event_Handlers.Output_Event_Handler'Class
         then
            -- Rule 6: Each output Event_Handler has 2 or more
            --         output Links and an input Link
            if MAST.Graphs.Event_Handlers.Num_Of_Output_Links
              (MAST.Graphs.Event_Handlers.Output_Event_Handler
               (An_Event_Handler_Ref.all))<=1 or else
              MAST.Graphs.Event_Handlers.Input_Link
              (MAST.Graphs.Event_Handlers.Output_Event_Handler
               (An_Event_Handler_Ref.all))=null
            then
               Message
                 (Verbose,Restriction_Name,Trans_Name,
                  "Rule 6 not met: Output Event_Handler has <2 "&
                  "output links or no input Link");
               return False;
            end if;
         else
            Message(Verbose,Restriction_Name,Trans_Name,
                    "Unknown Event_Handler Type");
            return False;
         end if;
      end loop;

      -- loop for all paths starting from input Links
      MAST.Transactions.Rewind_External_Event_Links
        (Trans_Ref.all,Link_Iterator);
      begin
         for I in 1..MAST.Transactions.Num_Of_External_Event_Links
           (Trans_Ref.all)
         loop
            MAST.Transactions.Get_Next_External_Event_Link
              (Trans_Ref.all,A_Link_Ref,Link_Iterator);
            Iterate_Transaction_Paths (Trans_Ref,A_Link_Ref);
         end loop;
      exception
         when List_Exceptions.Already_Exists =>
            -- Rule 7: No circular dependencies
            Message(Verbose,Restriction_Name,Trans_Name,
                    "Rule 7 not met: Circular dependecy");
            return False;
      end;

      -- Check circular dependencies for Input Event Handlers
      MAST.Transactions.Rewind_Event_Handlers
        (Trans_Ref.all,Event_Iterator);
      begin
         for I in 1..MAST.Transactions.Num_Of_Event_Handlers
           (Trans_Ref.all)
         loop
            MAST.Transactions.Get_Next_Event_Handler
              (Trans_Ref.all,Initial_Event_Handler,Event_Iterator);
            if Initial_Event_Handler.all in
              Graphs.Event_Handlers.Input_Event_Handler'Class
            then
               Iterate_From_Input_Event_Handler
                 (Trans_Ref,Graphs.
                  Event_Handlers.Output_Link
                  (Graphs.Event_Handlers.Input_Event_Handler
                   (Initial_Event_Handler.all)));
            end if;
         end loop;
      exception
         when Circular_Dependency =>
            -- Rule 7: No circular dependencies
            Message(Verbose,Restriction_Name,Trans_Name,
                    "Rule 7 not met: Circular dependecy");
            return False;
      end;

      -- Loop for all external event Links, to check Rule 8
      MAST.Transactions.Rewind_External_Event_Links
        (Trans_Ref.all,Link_Iterator);
      for I in 1..MAST.Transactions.Num_Of_External_Event_Links
        (Trans_Ref.all)
      loop
         MAST.Transactions.Get_Next_External_Event_Link
           (Trans_Ref.all,A_Link_Ref,Link_Iterator);
         -- Rule 8: No isolated Links
         if MAST.Graphs.Link_Lists.Find
           (MAST.Graphs.Name(A_Link_Ref),Visited_Links_List)=
           MAST.Graphs.Link_Lists.Null_Index
         then
            Message(Verbose,Restriction_Name,Trans_Name,
                    "Rule 8 not met: isolated Link, ",
                    "Link: "&To_String(MAST.Graphs.Name(A_Link_Ref)));
            return False;
         end if;
      end loop;

      -- Loop for all internal event Links, to check Rule 8
      MAST.Transactions.Rewind_Internal_Event_Links
        (Trans_Ref.all,Link_Iterator);
      for I in 1..MAST.Transactions.Num_Of_Internal_Event_Links
        (Trans_Ref.all)
      loop
         MAST.Transactions.Get_Next_Internal_Event_Link
           (Trans_Ref.all,A_Link_Ref,Link_Iterator);
         -- Rule 8: No isolated Links
         if MAST.Graphs.Link_Lists.Find
           (MAST.Graphs.Name(A_Link_Ref),Visited_Links_List)=
           MAST.Graphs.Link_Lists.Null_Index
         then
            Message(Verbose,Restriction_Name,Trans_Name,
                    "Rule 8 not met: isolated Link, ",
                    "Link: "&To_String(MAST.Graphs.Name(A_Link_Ref)));
            return False;
         end if;
      end loop;

      -- Loop for all Event_Handlers, to check Rule 9
      MAST.Transactions.Rewind_Event_Handlers
        (Trans_Ref.all,Event_Iterator);
      for I in 1..MAST.Transactions.Num_Of_Event_Handlers(Trans_Ref.all)
      loop
         MAST.Transactions.Get_Next_Event_Handler
           (Trans_Ref.all,An_Event_Handler_Ref,Event_Iterator);
         -- Rule 9: No isolated Event_Handlers
         if MAST.Graphs.Event_Handler_Lists.Find
           (An_Event_Handler_Ref,Visited_Event_Handlers_List)=
           MAST.Graphs.Event_Handler_Lists.Null_Index
         then
            Message(Verbose,Restriction_Name,Trans_Name,
                    "Rule 9 not met: isolated Event_Handler, ");
            return False;
         end if;
      end loop;

      -- All consistency checks met
      return True;
   end Consistent_Transaction_Graphs;

   -----------------------------------
   -- Consistent_Transaction_Graphs --
   -----------------------------------

   function Consistent_Transaction_Graphs
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True)
     return Boolean
   is
      Trans_Ref : MAST.Transactions.Transaction_Ref;
      Iterator : Transactions.Lists.Index;
   begin
      -- Loop for every transaction
      MAST.Transactions.Lists.Rewind(The_System.Transactions,Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions) loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Iterator);
         if not Consistent_Transaction_Graphs(Trans_Ref,Verbose) then
            return False;
         end if;
      end loop;

      -- loop for all schedulers to check for rules 15-17,23-24
      declare
         Restriction_Name : constant String:="Consistent Transaction Graph";
         Iterator : Schedulers.Lists.Iteration_Object;
         Sched_Ref : Schedulers.Scheduler_Ref;
         Host_Ref : Processing_Resources.Processing_Resource_Ref;
         Proc_List : Processing_Resources.Lists.List;
         SS_Ref : Scheduling_Servers.Scheduling_Server_Ref;
         SS_List : Scheduling_Servers.Lists.List;
      begin
         Schedulers.Lists.Rewind(The_System.Schedulers,Iterator);
         for I in 1..Schedulers.Lists.Size(The_System.Schedulers) loop
            Schedulers.Lists.Get_Next_Item
              (Sched_Ref,The_System.Schedulers,Iterator);
            declare
               Sched_Name : constant String:="Scheduler: "&
                 To_String(MAST.Schedulers.Name(Sched_Ref));
            begin
               if Sched_Ref.all in
                 Schedulers.Primary.Primary_Scheduler'Class
               then
                  -- Rule 15: All primary schedulers have a processing resource
                  Host_Ref:=Schedulers.Primary.Host
                    (Schedulers.Primary.Primary_Scheduler'Class
                     (Sched_Ref.all));
                  if Host_Ref=null then
                     Message(Verbose,Restriction_Name,Sched_Name,
                             "Rule 15 not met: Primary scheduler has no "&
                             "processing resource");
                     return False;
                  else
                     -- Rule 23: Each processing resource has at most
                     --          one primary scheduler
                     begin
                        Processing_Resources.Lists.Add(Host_Ref,Proc_List);
                     exception
                        when List_Exceptions.Already_Exists =>
                           Message(Verbose,Restriction_Name,Sched_Name,
                                   "Rule 23 not met: Two primary schedulers "&
                                   "have the same processing resource");
                           return False;
                     end;
                  end if;
               elsif Sched_Ref.all in
                 Schedulers.Secondary.Secondary_Scheduler'Class
               then
                  -- Rule 16: All secondary schedulers have a scheduling server
                  SS_Ref:=Schedulers.Secondary.Server
                    (Schedulers.Secondary.Secondary_Scheduler'Class
                     (Sched_Ref.all));
                  if SS_Ref=null then
                     Message(Verbose,Restriction_Name,Sched_Name,
                             "Rule 16 not met: Secondary scheduler has no "&
                             "scheduling server");
                     return False;
                  else
                     -- Rule 24: Each scheduling server has at most
                     --          one secondary scheduler
                     begin
                        Scheduling_Servers.Lists.Add(SS_Ref,SS_List);
                     exception
                        when List_Exceptions.Already_Exists =>
                           Message(Verbose,Restriction_Name,Sched_Name,
                                   "Rule 24 not met: Two secondary schedulers"&
                                   " have the same scheduling server");
                           return False;
                     end;
                  end if;
               else
                  raise Incorrect_Object;
               end if;

               -- Rule 17: All Schedulers have a scheduling policy
               if Schedulers.Scheduling_Policy(Sched_Ref.all)=null then
                  Message(Verbose,Restriction_Name,Sched_Name,
                          "Rule 17 not met: Scheduler has no "&
                          "scheduling policy");
                  return False;
               end if;
               -- Rule 18: All scheduling policies of the type
               --          FP_Packet_Based are associated with a primary
               --          scheduler located on a network
               if Schedulers.Scheduling_Policy(Sched_Ref.all).all in
                 Scheduling_Policies.FP_Packet_Based'Class
               then
                  if not (Sched_Ref.all in
                          Schedulers.Primary.Primary_Scheduler'Class
                          and then
                          Schedulers.Primary.Host
                          (Schedulers.Primary.Primary_Scheduler'Class
                           (Sched_Ref.all)).all in
                          Processing_Resources.Network.Network'Class)
                  then
                     Message(Verbose,Restriction_Name,Sched_Name,
                             "Rule 18 not met: Schedulers with Packet_Based "&
                             "policy not assigned to a network");
                     return False;
                  end if;
               else
                  -- Rule 27: All scheduling policies of a type that is not
                  --          FP_Packet_Based and associated with a primary
                  --          scheduler must be located on a processor
                  if Sched_Ref.all in
                    Schedulers.Primary.Primary_Scheduler'Class
                    and then
                       not (Schedulers.Primary.Host
                          (Schedulers.Primary.Primary_Scheduler'Class
                           (Sched_Ref.all)).all in
                          Processing_Resources.Processor.Processor'Class)
                  then
                     Message(Verbose,Restriction_Name,Sched_Name,
                             "Rule 27 not met: Primary schedulers with non "&
                             "Packet_Based policy not assigned to a"&
                             " processor");
                     return False;
                  end if;
               end if;
            end;
         end loop;
      end;

      declare
         Restriction_Name : constant String:="Consistent Transaction Graph";
         Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
         Srvr_Iterator : Scheduling_Servers.Lists.Iteration_Object;
         Sched_Ref : Schedulers.Scheduler_Ref;
         Sch_Params_Ref : Scheduling_Parameters.Sched_Parameters_Ref;
      begin
         -- Loop for every Scheduling Server
         Mast.Scheduling_Servers.Lists.Rewind
           (The_System.Scheduling_Servers,Srvr_Iterator);
         for I in 1..Mast.Scheduling_Servers.Lists.Size
           (The_System.Scheduling_Servers)
         loop
            Mast.Scheduling_Servers.Lists.Get_Next_Item
              (Srvr_Ref,The_System.Scheduling_Servers,Srvr_Iterator);
            declare
               Srvr_Name : constant String:="Scheduling Server: "&
                 To_String(MAST.Scheduling_Servers.Name(Srvr_Ref));
            begin
               -- Rule 12: All scheduling servers have a scheduler
               Sched_Ref:=Scheduling_Servers.Server_Scheduler(Srvr_Ref.all);
               if Sched_Ref=null then
                  Message(Verbose,Restriction_Name,Srvr_Name,
                          "Rule 12 not met: Server has no scheduler");
                  return False;
               end if;
               -- Rule 13: All Scheduling servers have scheduling parameters
               Sch_Params_Ref:=Scheduling_Servers.Server_Sched_Parameters
                 (Srvr_Ref.all);
               if Sch_Params_Ref=null then
                  Message(Verbose,Restriction_Name,Srvr_Name,
                          "Rule 13 not met: Server has no "&
                          "scheduling_parameters");
                  return False;
               end if;
               if Sch_Params_Ref.all in
                 Scheduling_Parameters.Fixed_Priority_Parameters'Class
               then
                  -- Rule 19: All scheduling servers with parameters of the FP
                  -- family are associated with schedulers having a policy of
                  -- the FP family
                  if not (Schedulers.Scheduling_Policy(Sched_Ref.all).all in
                          Scheduling_Policies.Fixed_Priority_Policy'Class)
                  then
                     Message(Verbose,Restriction_Name,Srvr_Name,
                             "Rule 19 not met: Server FP parameters are "&
                             "incompatible with schedulers's sched policy");
                     return False;
                  end if;

                  -- Rule 21: All scheduling servers with parameters of the
                  -- type Interrupt_FP_Policy are associated with primary
                  -- schedulers
                  if Sch_Params_Ref.all in
                    Scheduling_Parameters.Interrupt_FP_Policy'Class and then
                    Sched_Ref.all not in
                    Schedulers.Primary.Primary_Scheduler'class
                  then
                     Message(Verbose,Restriction_Name,Srvr_Name,
                             "Rule 21 not met: Server Interrupt_FP params "&
                             "not associated with primary scheduler");
                     return False;
                  end if;

               elsif Sch_Params_Ref.all in
                 Scheduling_Parameters.EDF_Parameters'Class
               then

                  -- Rule 20: All scheduling servers with parameters of the EDF
                  -- family are associated with schedulers having a policy of
                  -- the EDF family
                  if not (Schedulers.Scheduling_Policy(Sched_Ref.all).all in
                          Scheduling_Policies.EDF_Policy'Class)
                  then
                     Message(Verbose,Restriction_Name,Srvr_Name,
                             "Rule 20 not met: Server EDF parameters are "&
                             "incompatible with schedulers's sched policy");
                     return False;
                  end if;
               else
                  raise Incorrect_Object;
               end if;

            end;
         end loop;
      end;

      -- All consistency checks met
      return True;
   end Consistent_Transaction_Graphs;

end MAST.Consistency_Checks;
