-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2004                     --
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

with MAST.Graphs,MAST.Graphs.Event_Handlers, Mast.Graphs.Links,
  MAST.Events, MAST.Shared_Resources, Mast.Timing_Requirements,
  Mast.Scheduling_Servers, Mast.Processing_Resources,
  Mast.Processing_Resources.Processor, Mast.Processing_Resources.Network,
  Mast.Schedulers, Mast.Schedulers.Primary, Mast.Schedulers.Secondary,
  Mast.Scheduling_Policies,
  Mast.Transaction_Operations, Mast.Linear_Translation,
  Mast.Tool_Exceptions,Mast.Operations,Mast.Scheduling_Parameters,
  Mast.Transactions, Mast.Scheduling_Servers,

  Mast.Max_Numbers,
  Mast.Drivers,
  Ada.Text_IO,Var_Strings,
  Doubly_Linked_Lists;
use Ada.Text_IO,Var_Strings;
use type MAST.Graphs.Link_Ref;
use type MAST.Graphs.Event_Handler_Ref;
use type MAST.Events.Event_Ref;
use type MAST.Graphs.Event_Handler_Lists.Index;
use type MAST.Shared_Resources.Shared_Resource_Ref;
use type Mast.Timing_Requirements.Timing_Requirement_Ref;
use type Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
use type Mast.Operations.Operation_Ref;
use type Mast.Scheduling_Parameters.Sched_Parameters_Ref;
use type Mast.Scheduling_Servers.Scheduling_Server_Ref;
use type Mast.Processing_Resources.Processing_Resource_Ref;

package body MAST.Restrictions is

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

   -----------------------------
   -- Priorities_Are_In_Range --
   -----------------------------

   function Priorities_Are_In_Range
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True)
     return Boolean
   is

      function Priorities_Are_In_Range
        (Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
         Verbose : Boolean := True)
        return Boolean
      is
         Max_Int_Prio,Min_Int_Prio,Max_Prio,Min_Prio : Priority;
         Proc_Ref : Processing_Resources.Processing_Resource_Ref;
         Sched_Policy_Ref : Scheduling_Policies.Scheduling_Policy_Ref;
         Sched_Param_Ref : Scheduling_Parameters.Sched_Parameters_Ref;
      begin
         if Scheduling_Servers.Server_Scheduler(Srvr_Ref.all).all in
           Schedulers.Primary.Primary_Scheduler'Class
         then
            Proc_Ref:=Scheduling_Servers.Server_Processing_Resource
              (Srvr_Ref.all);
         end if;
         Sched_Policy_Ref:=Schedulers.Scheduling_Policy
           (Scheduling_Servers.Server_Scheduler
            (Srvr_Ref.all).all);
         if Sched_Policy_Ref.all in
           Scheduling_Policies.Fixed_Priority_Policy'Class
         then
            Max_Prio:=Scheduling_Policies.Max_Priority
              (Scheduling_Policies.Fixed_Priority_Policy'Class
               (Sched_Policy_Ref.all));
            Min_Prio:=Scheduling_Policies.Min_Priority
              (Scheduling_Policies.Fixed_Priority_Policy'Class
               (Sched_Policy_Ref.all));
            if Proc_Ref /= null and then Proc_Ref.all in
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
               if Min_Int_Prio>Max_Int_Prio or else Min_Prio>Min_Int_Prio
                 or else Max_Prio>Max_Int_Prio
               then
                  if Verbose then
                     Put_Line("Interrupt priority range is null or wrong");
                  end if;
                  return False;
               end if;
            else
               Max_Int_Prio:=Priority'Last;
               Min_Int_Prio:=Priority'Last;
            end if;
            if Min_Prio>Max_Prio then
               if Verbose then
                  Put_Line("Priority range is null");
               end if;
               return False;
            end if;
            Sched_Param_Ref:=Scheduling_Servers.Server_Sched_Parameters
              (Srvr_Ref.all);
            if Sched_Param_Ref.all in
              Scheduling_Parameters.Fixed_Priority_Parameters'Class
            then
               if Sched_Param_Ref.all in
                 Scheduling_Parameters.Interrupt_Fp_Policy'Class
               then
                  if Scheduling_Parameters.The_Priority
                    (Scheduling_Parameters.Fixed_Priority_Parameters
                     (Sched_Param_Ref.all)) not in Min_Int_Prio..Max_Int_Prio
                  then
                     if Verbose then
                        Put_Line("Interrupt Priority of server "&
                                 Scheduling_Servers.Name(Srvr_Ref)&
                                 " is out of range");
                     end if;
                     return False;
                  end if;
               else
                  if Scheduling_Parameters.The_Priority
                    (Scheduling_Parameters.Fixed_Priority_Parameters
                     (Sched_Param_Ref.all)) not in Min_Prio..Max_Prio
                  then
                     if Verbose then
                        Put_Line("Priority of server "&
                                 Scheduling_Servers.Name(Srvr_Ref)&
                                 " is out of range");
                     end if;
                     return False;
                  end if;
               end if;
               if Sched_Param_Ref.all in
                 Scheduling_Parameters.Sporadic_Server_Policy'Class
               then
                  if Scheduling_Parameters.Background_Priority
                    (Scheduling_Parameters.Sporadic_Server_Policy
                     (Sched_Param_Ref.all)) not in Min_Prio..Max_Prio
                  then
                     if Verbose then
                        Put_Line("Background priority is out of range");
                     end if;
                     return False;
                  end if;
                  if Scheduling_Parameters.Initial_Capacity
                    (Scheduling_Parameters.Sporadic_Server_Policy
                     (Sched_Param_Ref.all)) >
                    Scheduling_Parameters.Replenishment_Period
                    (Scheduling_Parameters.Sporadic_Server_Policy
                     (Sched_Param_Ref.all))
                  then
                     if Verbose then
                        Put_Line("Initial_Capacity is larger than "&
                                 "Replenishment Period");
                     end if;
                     return False;
                  end if;
               end if;
            else
               raise Incorrect_Object;
            end if;
         end if;
         return True;
      end Priorities_Are_In_Range;

      Priorities_Out_Of_Range : exception;

      procedure Operation_For_Event_Handlers
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref)
      is
         procedure Check_Operation_Priorities
           (Op_Ref : Operations.Operation_Ref;
            Sched_Policy_Ref :Scheduling_Policies.Fixed_Priority_Policy_Ref)
         is
            Iterator : Operations.Operation_Iteration_Object;
            New_Op_Ref : Operations.Operation_Ref;
         begin
            -- Check Overridden Priorities
            if Operations.New_Sched_Parameters(Op_Ref.all)/=null then
               if Scheduling_Parameters.The_Priority
                 (Scheduling_Parameters.Overridden_FP_Parameters'Class
                  (Operations.New_Sched_Parameters(Op_Ref.all).all)) not in
                 Scheduling_Policies.Min_Priority(Sched_Policy_Ref.all)..
                 Scheduling_Policies.Max_Priority(Sched_Policy_Ref.all)
               then
                  if Verbose then
                     Put_Line
                       ("Operation "&
                        Operations.Name(Op_Ref)&
                        " has overridden priority out of range");
                  end if;
                  raise Priorities_Out_Of_Range;
               end if;
            end if;
            if Op_Ref.all in Operations.Composite_Operation'Class
            then
               Operations.Rewind_Operations
                 (Operations.Composite_Operation(Op_Ref.all),
                  Iterator);
               for I in 1..Operations.Num_Of_Operations
                 (Operations.Composite_Operation(Op_Ref.all))
               loop
                  Operations.Get_Next_Operation
                    (Operations.Composite_Operation(Op_Ref.all),
                     New_Op_Ref,Iterator);
                  Check_Operation_Priorities
                    (New_Op_Ref,Sched_Policy_Ref);
               end loop;
            end if;
         end Check_Operation_Priorities;

         Sched_Policy_Ref :Scheduling_Policies.Scheduling_Policy_Ref;
      begin
         if The_Event_Handler_Ref.all in
           Graphs.Event_Handlers.Activity'Class
         then
            Sched_Policy_Ref:=Schedulers.Scheduling_Policy
              (Scheduling_Servers.Server_Scheduler
               (Graphs.Event_Handlers.Activity_Server
                (Graphs.Event_Handlers.Activity
                 (The_Event_Handler_Ref.all)).all).all);
            if Sched_Policy_Ref.all in
              Scheduling_Policies.Fixed_Priority_Policy'Class
            then
               Check_Operation_Priorities
                 (Graphs.Event_Handlers.Activity_Operation
                  (Graphs.Event_Handlers.Activity(The_Event_Handler_Ref.all)),
                  Scheduling_Policies.Fixed_Priority_Policy_Ref
                  (Sched_Policy_Ref));
            end if;
         end if;
      end Operation_For_Event_Handlers;

      procedure Operation_For_Links
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Link_Ref : MAST.Graphs.Link_Ref) is
      begin
         null;
      end Operation_For_Links;

      procedure Check_Priorities_Of_Activities is new
        Transaction_Operations.Traverse_Paths_From_Link_Once
        (Operation_For_Event_Handlers,Operation_For_Links);


      Proc_Iteration_Object : Processing_Resources.Lists.Iteration_Object;
      Proc_Ref : Processing_Resources.Processing_Resource_Ref;
      Drv_Iteration_Object : Processing_Resources.Network.
        Driver_Iteration_Object;
      Drv_Ref : Drivers.Driver_Ref;
      Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
      Srvr_Iterator : Scheduling_Servers.Lists.Iteration_Object;
      Trans_Ref : Transactions.Transaction_Ref;
      Tr_Iterator : Transactions.Lists.Iteration_Object;
      A_Link_Ref : MAST.Graphs.Link_Ref;
      L_Iterator : Transactions.Link_Iteration_Object;

   begin
      -- Check drivers
      Processing_Resources.Lists.Rewind
        (The_System.Processing_Resources,Proc_Iteration_Object);
      for Proc in 1..Processing_Resources.Lists.Size
        (The_System.Processing_Resources)
      loop
         Processing_Resources.Lists.Get_Next_Item
           (Proc_Ref,The_System.Processing_Resources,
            Proc_Iteration_Object);
         if Proc_Ref.all in Processing_Resources.Network.Network'Class then
            Processing_Resources.Network.Rewind_Drivers
              (Processing_Resources.Network.Network'Class(Proc_Ref.all),
               Drv_Iteration_Object);
            for Drv in 1..Processing_Resources.Network.Num_Of_Drivers
              (Processing_Resources.Network.Network'Class(Proc_Ref.all))
            loop
               Processing_Resources.Network.Get_Next_Driver
                 (Processing_Resources.Network.Network'Class(Proc_Ref.all),
                  Drv_Ref, Drv_Iteration_Object);
               if Drv_Ref.all in Drivers.Packet_Driver'Class then
                  if not Priorities_Are_In_Range
                    (Drivers.Packet_Server(Drivers.Packet_Driver(Drv_Ref.all)))
                  then
                     if Verbose then
                        Put_Line
                          ("Packet server of driver in "&
                           Processing_Resources.Name(Proc_Ref)&
                           " has priority out of range");
                     end if;
                     return False;
                  end if;
                  if Drv_Ref.all in Drivers.Character_Packet_Driver'Class
                  then
                     if not Priorities_Are_In_Range
                       (Drivers.Character_Server
                        (Drivers.Character_Packet_Driver(Drv_Ref.all)),
                        Verbose)
                     then
                        if Verbose then
                           Put_Line
                             ("Character server of driver in "&
                              Processing_Resources.Name(Proc_Ref)&
                              " has priority out of range");
                        end if;
                        return False;
                     end if;
                  elsif Drv_Ref.all in Drivers.RTEP_Packet_Driver'Class then
                     if not Priorities_Are_In_Range
                       (Drivers.Packet_Interrupt_Server
                        (Drivers.RTEP_Packet_Driver(Drv_Ref.all)),
                        Verbose)
                     then
                        if Verbose then
                           Put_Line
                             ("Packet interrupt server of driver in "&
                              Processing_Resources.Name(Proc_Ref)&
                              " has priority out of range");
                        end if;
                        return False;
                     end if;
                  end if;
               else
                  raise Incorrect_Object;
               end if;
            end loop;
         end if;
      end loop;

      -- Check Scheduling Servers
      Scheduling_Servers.Lists.Rewind
        (The_System.Scheduling_Servers,Srvr_Iterator);
      for I in 1..Scheduling_Servers.Lists.Size
        (The_System.Scheduling_Servers)
      loop
         Scheduling_Servers.Lists.Get_Next_Item
           (Srvr_Ref,The_System.Scheduling_Servers,Srvr_Iterator);
         if not Priorities_Are_In_Range(Srvr_Ref,Verbose)
         then
            if Verbose then
               Put_Line
                 ("Server "&Scheduling_Servers.Name(Srvr_Ref)&
                  " has priority out of range");
            end if;
            return False;
         end if;
      end loop;

      -- Check Operation overriden parameters
      -- loop for each path in the transaction
      Transactions.Lists.Rewind(The_System.Transactions,Tr_Iterator);
      for I in 1..Transactions.Lists.Size(The_System.Transactions)
      loop
         Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Tr_Iterator);
         Transactions.Rewind_External_Event_Links(Trans_Ref.all,L_Iterator);
         for I in 1..Transactions.Num_Of_External_Event_Links
           (Trans_Ref.all)
         loop
            Transactions.Get_Next_External_Event_Link
              (Trans_Ref.all,A_Link_Ref,L_Iterator);
            Check_Priorities_Of_Activities (Trans_Ref,A_Link_Ref);
         end loop;
      end loop;
      if Verbose then
         Put_Line("Priorities are all in range");
      end if;
      return True;
   exception
      when Priorities_Out_Of_Range =>
         return False;
   end Priorities_Are_In_Range;

   -----------------------------
   -- Primary_Schedulers_Only --
   -----------------------------

   function Primary_Schedulers_Only
     (The_System : MAST.Systems.System;
      Restriction_Name : String;
      Verbose : Boolean := True)
     return Boolean
   is
      Sched_Ref : Schedulers.Scheduler_Ref;
      Sched_Iterator : Schedulers.Lists.Iteration_Object;
   begin
      Schedulers.Lists.Rewind
        (The_System.Schedulers,Sched_Iterator);
      for I in 1..Schedulers.Lists.Size
        (The_System.Schedulers)
      loop
         Schedulers.Lists.Get_Next_Item
           (Sched_Ref,The_System.Schedulers,Sched_Iterator);
         if Sched_Ref.all in Schedulers.Secondary.Secondary_Scheduler'Class
         then
            Message(Verbose,Restriction_Name,"Scheduler: "&
                    To_String(MAST.Schedulers.Name(Sched_Ref)));
            return False;
         end if;
      end loop;
      return True;
   end Primary_Schedulers_Only;

   --------------------------------------
   -- Consistent_Overridden_Priorities --
   --------------------------------------

   function Consistent_Overridden_Priorities
     (The_System : MAST.Systems.System;
      Restriction_Name : String;
      Verbose : Boolean := True)
     return Boolean
   is
      Trans_Ref : Transactions.Transaction_Ref;
      Trans_Iterator : Transactions.Lists.Iteration_Object;
      New_Sp : Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Hdlr_Ref : Graphs.Event_Handler_Ref;
      Hdlr_Iterator : Transactions.Event_Handler_Iteration_Object;
      Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
      Op_Ref : Operations.Operation_Ref;
      Op_Iterator : Operations.Lists.Iteration_Object;
      Sch_Params_Ref : Scheduling_Parameters.Sched_Parameters_Ref;
   begin
      Transactions.Lists.Rewind
        (The_System.Transactions,Trans_Iterator);
      for I in 1..Transactions.Lists.Size(The_System.Transactions) loop
         Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Trans_Iterator);
         -- loop for event handlers
         Transactions.Rewind_Event_Handlers(Trans_Ref.all,Hdlr_Iterator);
         for H in 1..Transactions.Num_Of_Event_Handlers(Trans_Ref.all)
         loop
            Transactions.Get_Next_Event_Handler
              (Trans_Ref.all, Hdlr_Ref, Hdlr_Iterator);
            if Hdlr_Ref.all in Graphs.Event_Handlers.Activity'Class then
               Op_Ref:=Graphs.Event_Handlers.Activity_Operation
                 (Graphs.Event_Handlers.Activity'Class(Hdlr_Ref.all));
               if Op_Ref/=null then
                  New_Sp:=Operations.New_Sched_Parameters(Op_Ref.all);
                  if New_Sp/=null then
                     Srvr_Ref:=Graphs.Event_Handlers.Activity_Server
                       (Graphs.Event_Handlers.Activity'Class(Hdlr_Ref.all));
                     if Srvr_Ref/=null then
                        Sch_Params_Ref:=
                          Scheduling_Servers.Server_Sched_Parameters
                          (Srvr_Ref.all);
                        if Sch_Params_Ref/=null and then
                          Sch_Params_Ref.all not in
                          Scheduling_Parameters.Fixed_Priority_Parameters'Class
                        then
                           Message(Verbose,Restriction_Name,"Operation: "&
                                   To_String(MAST.Operations.Name(Op_Ref)));
                           return False;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end loop;
      end loop;
      return True;
   end Consistent_Overridden_Priorities;

   -------------------------------
   -- Max_Processor_Utilization --
   -------------------------------

   function Max_Processor_Utilization
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
      Utilization : array(1..Max_Processors) of Time :=
        (others => 0.0);
      Max_Utilization : Time:=Time'First;

   begin
      if Linear_Plus_Transactions_Only (The_System,False) then
         Translate_Linear_System(The_System,Transaction,False);
         for Tr in Transaction_ID_Type range 1..Max_Transactions loop
            exit when Transaction(Tr).Ni=0;
            -- uses Cij and Tij, which are values for the analysis
            -- of other tasks.
            for Tsk in 1..Transaction(Tr).Ni loop
               Utilization(Transaction(Tr).The_Task(Tsk).Procij):=
                 Utilization(Transaction(Tr).The_Task(Tsk).Procij)+
                 Transaction(Tr).The_Task(Tsk).Cij/Transaction(Tr).Ti;
            end loop;
         end loop;
         for Pr in Processor_ID_Type range 1..Max_Processors loop
            if Verbose and then Utilization(Pr)>=1.0 then
               Put_Line("Processor "&Get_Processor_Name(The_System,Pr)&
                        " exceeds 100% utilization");
            end if;
            if Utilization(Pr)>Max_Utilization then
               Max_Utilization:=Utilization(Pr);
            end if;
         end loop;
         if Verbose and then Max_Utilization>1.0 then
            Show_Linear_Translation(Transaction);
         end if;
      else
         if Verbose then
            Put_Line("Feasible_Processing_Load not yet implemented for"&
                     " Multiple-Event systems");
         end if;
         Tool_Exceptions.Set_Tool_Failure_Message
           ("Feasible_Processing_Load not yet implemented for"&
            " Multiple-Event systems");
         raise Tool_Exceptions.Tool_Failure;
      end if;
      if Max_Utilization >= Float'Large then
         return Float'Large;
      else
         return Float(Max_Utilization);
      end if;
   end Max_Processor_Utilization;

   --------------
   -- EDF_Only --
   --------------

   function EDF_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean
     -- All Scheduling Servers have EDF or Interrupt Parameters,
     -- there are no overriden parameters in operations, and all interrupt
     -- priorities are within the appropriate ranges for their processing
     -- resources. There are no secondary schedulers.
   is
      Restriction_Name : constant String:="EDF_Only";
      Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
      Iterator : Scheduling_Servers.Lists.Iteration_Object;
      Op_Ref : Operations.Operation_Ref;
      Op_Iterator : Operations.Lists.Iteration_Object;
      New_Sp : Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
   begin
      if not Primary_Schedulers_Only(The_System,Restriction_Name,Verbose) then
         return False;
      end if;
      Scheduling_Servers.Lists.Rewind
        (The_System.Scheduling_Servers,Iterator);
      for I in 1..Scheduling_Servers.Lists.Size
        (The_System.Scheduling_Servers)
      loop
         Scheduling_Servers.Lists.Get_Next_Item
           (Srvr_Ref,The_System.Scheduling_Servers,Iterator);
         if Scheduling_Servers.Server_Sched_Parameters(Srvr_Ref.all).all
           not in Scheduling_Parameters.EDF_Parameters'Class
           and then
           Scheduling_Servers.Server_Sched_Parameters(Srvr_Ref.all).all
           not in Scheduling_Parameters.Interrupt_Fp_Policy'Class
         then
            Message(Verbose,Restriction_Name,"Server: "&
                    To_String(MAST.Scheduling_Servers.Name(Srvr_Ref)));
            return False;
         end if;
         if Scheduling_Servers.Server_Processing_Resource(Srvr_Ref.all).all
           not in Processing_Resources.Processor.Processor'Class
           and then
           Scheduling_Servers.Server_Processing_Resource(Srvr_Ref.all).all
           not in Processing_Resources.Network.Network'Class
         then
            Message(Verbose,Restriction_Name,"Server: "&
                    To_String(MAST.Scheduling_Servers.Name(Srvr_Ref)));
            return False;
         end if;
      end loop;
      Operations.Lists.Rewind
        (The_System.Operations,Op_Iterator);
      for I in 1..Operations.Lists.Size(The_System.Operations) loop
         Operations.Lists.Get_Next_Item
           (Op_Ref,The_System.Operations,Op_Iterator);
         New_Sp:=Operations.New_Sched_Parameters(Op_Ref.all);
         if New_Sp/=null then
            Message(Verbose,Restriction_Name,"Server: "&
                    To_String(MAST.Operations.Name(Op_Ref)));
            return False;
         end if;
      end loop;
      if not Priorities_Are_In_Range(The_System,Verbose) then
         Message(Verbose,Restriction_Name,"Priorities not in range");
         return False;
      end if;
      return True;
   end EDF_Only;

   --------------------------------
   -- EDF_Within_Priorities_Only --
   --------------------------------

   function EDF_Within_Priorities_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean
     -- The primary schedulers have a fixed priority policy.
     -- All secondary schedulers have an EDF policy and are scheduled
     -- under a scheduling server that is directy attached to a
     -- primary server.
     -- All operations with overridden priorities are executed by fixed
     -- priority scheduling servers
     -- All priorities are in range
   is

      Restriction_Name : constant String:="EDF_Within_Priorities_Only";
      Sched_Ref : Schedulers.Scheduler_Ref;
      Spolicy_Ref : Scheduling_Policies.Scheduling_Policy_Ref;
      Iterator : Schedulers.Lists.Iteration_Object;

   begin
      Schedulers.Lists.Rewind
        (The_System.Schedulers,Iterator);
      for I in 1..Schedulers.Lists.Size
        (The_System.Schedulers)
      loop
         Schedulers.Lists.Get_Next_Item
           (Sched_Ref,The_System.Schedulers,Iterator);
         Spolicy_Ref:=Schedulers.Scheduling_Policy(Sched_Ref.all);
         if Sched_Ref.all in Schedulers.Primary.Primary_Scheduler'Class then
            if Spolicy_Ref.all not in
              Scheduling_Policies.Fixed_Priority_Policy'Class
            then
               Message(Verbose,Restriction_Name,"Scheduler: "&
                       To_String(MAST.Schedulers.Name(Sched_Ref)));
               return False;
            end if;
         elsif Sched_Ref.all in Schedulers.Secondary.Secondary_Scheduler'Class
         then
            if Spolicy_Ref.all not in
              Scheduling_Policies.EDF_Policy'Class
            then
               Message(Verbose,Restriction_Name,"Scheduler: "&
                       To_String(MAST.Schedulers.Name(Sched_Ref)));
               return False;
            end if;
            if Scheduling_Servers.Server_Scheduler
              (Schedulers.Secondary.Server
               (Schedulers.Secondary.Secondary_Scheduler'Class
                (Sched_Ref.all)).all).all not in
              Schedulers.Primary.Primary_Scheduler'Class
            then
               Message(Verbose,Restriction_Name,"Scheduler: "&
                       To_String(MAST.Schedulers.Name(Sched_Ref)));
               return False;
            end if;
         else
            raise Incorrect_Object;
         end if;
      end loop;
      if not Consistent_Overridden_Priorities
        (The_System,Restriction_Name,Verbose)
      then
         return False;
      end if;
      if not Priorities_Are_In_Range(The_System,Verbose) then
         Message(Verbose,Restriction_Name,"Priorities not in range");
         return False;
      end if;
      return True;
   end EDF_Within_Priorities_Only;

   ------------------------------
   -- Feasible_Processing_Load --
   ------------------------------

   function Feasible_Processing_Load
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean
     -- checks that the utilization level of each processing resource
     -- is under 100%
   is
      Feasible : Boolean;
   begin
      Feasible:=Max_Processor_Utilization(The_System,Verbose)<10.0;
      if Verbose and Feasible then
         Put_Line("Utilization load of resources is under 100%");
      end if;
      return Feasible;
   end Feasible_Processing_Load;

   -------------------------
   -- Flat_FP_Or_EDF_Only --
   -------------------------

   function Flat_FP_Or_EDF_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean
     -- Each node is Fixed_Priorities_Only or EDF_Only
   is
      Restriction_Name : constant String:="Flat_FP_Or_EDF_Only";
      Iterator : Scheduling_Servers.Lists.Iteration_Object;
      Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
   begin
      if not Primary_Schedulers_Only(The_System,Restriction_Name,Verbose) then
         return False;
      end if;
      Scheduling_Servers.Lists.Rewind
        (The_System.Scheduling_Servers,Iterator);
      for I in 1..Scheduling_Servers.Lists.Size
        (The_System.Scheduling_Servers)
      loop
         Scheduling_Servers.Lists.Get_Next_Item
           (Srvr_Ref,The_System.Scheduling_Servers,Iterator);
         if Scheduling_Servers.Server_Sched_Parameters(Srvr_Ref.all).all
           not in Scheduling_Parameters.EDF_Parameters'Class
           and then
           Scheduling_Servers.Server_Sched_Parameters(Srvr_Ref.all).all
           not in Scheduling_Parameters.Fixed_Priority_Parameters'Class
         then
            Message(Verbose,Restriction_Name,"Server: "&
                    To_String(MAST.Scheduling_Servers.Name(Srvr_Ref)));
            return False;
         end if;
         if Scheduling_Servers.Server_Processing_Resource(Srvr_Ref.all).all
           not in Processing_Resources.Processor.Processor'Class
           and then
           Scheduling_Servers.Server_Processing_Resource(Srvr_Ref.all).all
           not in Processing_Resources.Network.Network'Class
         then
            Message(Verbose,Restriction_Name,"Server: "&
                    To_String(MAST.Scheduling_Servers.Name(Srvr_Ref)));
            return False;
         end if;
      end loop;
      if not Consistent_Overridden_Priorities
        (The_System,Restriction_Name,Verbose)
      then
         return False;
      end if;
      if not Priorities_Are_In_Range(The_System,Verbose) then
         Message(Verbose,Restriction_Name,"Priorities not in range");
         return False;
      end if;
      return True;
   end Flat_FP_Or_EDF_Only;

   --------------------------------
   -- Is_Linear_Plus_Transaction --
   --------------------------------

   function Is_Linear_Plus_Transaction
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True)
     return Boolean
   is
      Restriction_Name : constant String:="Linear_Plus_Transactions_Only";
      Trans_Name : constant String:="Transaction: "&
        To_String(MAST.Transactions.Name(Trans_Ref));
      An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
      Iterator : Transactions.Event_Handler_Iteration_Object;
   begin
      MAST.Transactions.Rewind_Event_Handlers(Trans_Ref.all,Iterator);
      for I in 1..MAST.Transactions.Num_Of_Event_Handlers(Trans_Ref.all)
      loop
         MAST.Transactions.Get_Next_Event_Handler
           (Trans_Ref.all,An_Event_Handler_Ref,Iterator);
         if An_Event_Handler_Ref.all in
           MAST.Graphs.Event_Handlers.Concentrator'Class
           or An_Event_Handler_Ref.all in
           MAST.Graphs.Event_Handlers.Barrier'Class
           or An_Event_Handler_Ref.all in
           MAST.Graphs.Event_Handlers.Multicast'Class
           or An_Event_Handler_Ref.all in
           MAST.Graphs.Event_Handlers.Delivery_Server'Class
           or An_Event_Handler_Ref.all in
           MAST.Graphs.Event_Handlers.Query_Server'Class
         then
            Message(Verbose,Restriction_Name,Trans_Name);
            return False;
         end if;
      end loop;
      return True;
   end Is_Linear_Plus_Transaction;

   ---------------------------
   -- Is_Linear_Transaction --
   ---------------------------

   function Is_Linear_Transaction
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True)
     return Boolean
   is
      Restriction_Name : constant String:="Linear_Transactions_Only";
      Trans_Name : constant String:="Transaction: "&
        To_String(MAST.Transactions.Name(Trans_Ref));
      An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
      Iterator : Transactions.Event_Handler_Iteration_Object;
   begin
      if Transactions.Num_Of_External_Event_Links(Trans_Ref.all)/=1
      then
         Message(Verbose,Restriction_Name,Trans_Name);
         return False;
      end if;
      MAST.Transactions.Rewind_Event_Handlers(Trans_Ref.all,Iterator);
      for I in 1..MAST.Transactions.Num_Of_Event_Handlers(Trans_Ref.all)
      loop
         MAST.Transactions.Get_Next_Event_Handler
           (Trans_Ref.all,An_Event_Handler_Ref,Iterator);
         if An_Event_Handler_Ref.all not in
           MAST.Graphs.Event_Handlers.Activity'Class
         then
            Message(Verbose,Restriction_Name,Trans_Name);
            return False;
         end if;
      end loop;
      return True;
   end Is_Linear_Transaction;

   -----------------------------------
   -- Is_Multiple_Event_Transaction --
   -----------------------------------

   function Is_Multiple_Event_Transaction
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True)
     return Boolean
   is
      Restriction_Name : constant String:="Multiple_Event_Transactions_Only";
      Trans_Name : constant String:="Transaction: "&
        To_String(MAST.Transactions.Name(Trans_Ref));
   begin
      if Trans_Ref.all not in Transactions.Regular_Transaction'Class then
         Message(Verbose,Restriction_Name,Trans_Name);
         return False;
      else
         return True;
      end if;
   end Is_Multiple_Event_Transaction;

   ---------------------------
   -- Is_Simple_Transaction --
   ---------------------------

   function Is_Simple_Transaction
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True)
     return Boolean
   is
      Restriction_Name : constant String:="Simple_Transactions_Only";
      Trans_Name : constant String:="Transaction: "&
        To_String(MAST.Transactions.Name(Trans_Ref));
      A_Link_Ref,Last_Link_Ref : MAST.Graphs.Link_Ref;
      Iterator : Transactions.Link_Iteration_Object;
   begin
      Transactions.Rewind_External_Event_Links(Trans_Ref.all,Iterator);
      Transactions.Get_Next_External_Event_Link
        (Trans_Ref.all,A_Link_Ref,Iterator);
      Transaction_Operations.Identify_Segment
        (Trans_Ref,A_Link_Ref,Last_Link_Ref);
      if Transactions.Num_Of_External_Event_Links(Trans_Ref.all)/=1
        or else Graphs.Output_Event_Handler(Last_Link_Ref.all)/=null
      then
         Message(Verbose,Restriction_Name,Trans_Name);
         return False;
      end if;
      return True;
   exception
      when Transaction_Operations.Incorrect_Link =>
         Message(Verbose,Restriction_Name,Trans_Name);
         return False;
   end Is_Simple_Transaction;

   -------------------------
   -- Fixed_Priority_Only --
   -------------------------

   function Fixed_Priority_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True)
     return Boolean
   is
      Restriction_Name : constant String:="Fixed_Priority_Only";
      Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
      Op_Ref : Operations.Operation_Ref;
      Iterator : Scheduling_Servers.Lists.Iteration_Object;
      Op_Iterator : Operations.Lists.Iteration_Object;
      New_Sp : Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
   begin
      if not Primary_Schedulers_Only(The_System,Restriction_Name,Verbose) then
         return False;
      end if;
      -- check scheduling servers are fixed priority
      Scheduling_Servers.Lists.Rewind
        (The_System.Scheduling_Servers,Iterator);
      for I in 1..Scheduling_Servers.Lists.Size
        (The_System.Scheduling_Servers)
      loop
         Scheduling_Servers.Lists.Get_Next_Item
           (Srvr_Ref,The_System.Scheduling_Servers,Iterator);
         if Scheduling_Servers.Server_Sched_Parameters(Srvr_Ref.all).all
           not in Scheduling_Parameters.Fixed_Priority_Parameters'Class
         then
            Message(Verbose,Restriction_Name,"Server: "&
                    To_String(MAST.Scheduling_Servers.Name(Srvr_Ref)));
            return False;
         end if;
         if Scheduling_Servers.Server_Processing_Resource(Srvr_Ref.all).all
           not in Processing_Resources.Processor.Processor'Class
           and then
           Scheduling_Servers.Server_Processing_Resource(Srvr_Ref.all).all
           not in Processing_Resources.Network.Network'Class
         then
            Message(Verbose,Restriction_Name,"Server: "&
                    To_String(MAST.Scheduling_Servers.Name(Srvr_Ref)));
            return False;
         end if;
      end loop;
      -- check overridden priorities
      Operations.Lists.Rewind
        (The_System.Operations,Op_Iterator);
      for I in 1..Operations.Lists.Size(The_System.Operations) loop
         Operations.Lists.Get_Next_Item
           (Op_Ref,The_System.Operations,Op_Iterator);
         New_Sp:=Operations.New_Sched_Parameters(Op_Ref.all);
         if New_Sp/=null and then New_Sp.all not in
           Scheduling_Parameters.Overridden_FP_Parameters'Class
         then
            Message(Verbose,Restriction_Name,"Server: "&
                    To_String(MAST.Operations.Name(Op_Ref)));
            return False;
         end if;
      end loop;
      -- check priorities
      if not Priorities_Are_In_Range(The_System,Verbose) then
         Message(Verbose,Restriction_Name,"Priorities not in range");
         return False;
      end if;
      return True;
   end Fixed_Priority_Only;

   -----------------------------------
   -- Linear_Plus_Transactions_Only --
   -----------------------------------

   function Linear_Plus_Transactions_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True)
     return Boolean
   is
      Trans_Ref : MAST.Transactions.Transaction_Ref;
      Iterator : Transactions.Lists.Iteration_Object;
   begin
      MAST.Transactions.Lists.Rewind(The_System.Transactions,Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Iterator);
         if not Is_Linear_Plus_Transaction(Trans_Ref,Verbose) then
            return False;
         end if;
      end loop;
      return True;
   end Linear_Plus_Transactions_Only;

   ------------------------------
   -- Linear_Transactions_Only --
   ------------------------------

   function Linear_Transactions_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True)
     return Boolean
   is
      Trans_Ref : MAST.Transactions.Transaction_Ref;
      Iterator : Transactions.Lists.Iteration_Object;
   begin
      MAST.Transactions.Lists.Rewind(The_System.Transactions,Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Iterator);
         if not Is_Linear_Transaction(Trans_Ref,Verbose) then
            return False;
         end if;
      end loop;
      return True;
   end Linear_Transactions_Only;

   ------------------------
   -- Monoprocessor_Only --
   ------------------------

   function Monoprocessor_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True)
     return Boolean
   is
      Restriction_Name : constant String:="Monoprocessor_Only";
      Proc_Ref : Processing_Resources.Processing_Resource_Ref;
      Iterator : Processing_Resources.Lists.Iteration_Object;
   begin
      Processing_Resources.Lists.Rewind
        (The_System.Processing_Resources,Iterator);
      Processing_Resources.Lists.Get_Next_Item
        (Proc_Ref,The_System.Processing_Resources,Iterator);
      if Processing_Resources.Lists.Size
        (The_System.Processing_Resources)/=1
        or else Proc_Ref.all not in
        Processing_Resources.Processor.Processor'Class
      then
         Message(Verbose,Restriction_Name,"");
         return False;
      else
         return True;
      end if;
   end Monoprocessor_Only;

   --------------------------------------
   -- Multiple_Event_Transactions_Only --
   --------------------------------------

   function Multiple_Event_Transactions_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True)
     return Boolean
   is
      Trans_Ref : MAST.Transactions.Transaction_Ref;
      Iterator : Transactions.Lists.Iteration_Object;
   begin
      MAST.Transactions.Lists.Rewind(The_System.Transactions,Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Iterator);
         if not Is_Multiple_Event_Transaction(Trans_Ref,Verbose) then
            return False;
         end if;
      end loop;
      return True;
   end Multiple_Event_Transactions_Only;

   ----------------------------------------
   -- No_Permanent_Overridden_Priorities --
   ----------------------------------------

   function No_Permanent_FP_Inside_Composite_Operations
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean
   is
      Restriction_Name : constant String:=
        "No_Permanent_FP_Inside_Composite_Operations";
      Op_Ref : Operations.Operation_Ref;
      Iterator : Operations.Lists.Index;
      Over_Ref : Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Int_Op_Ref : Operations.Operation_Ref;
      Int_Iterator : Operations.Operation_Iteration_Object;
   begin
      Operations.Lists.Rewind(The_System.Operations,Iterator);
      for I in 1..Operations.Lists.Size(The_System.Operations) loop
         Operations.Lists.Get_Next_Item(Op_Ref,The_System.Operations,Iterator);
         if Op_Ref.all in Operations.Composite_Operation then
            Operations.Rewind_Operations
              (Operations.Composite_Operation'Class(Op_Ref.all),Int_Iterator);
            for I in 1..Operations.Num_Of_Operations
              (Operations.Composite_Operation'Class(Op_Ref.all))
            loop
               Operations.Get_Next_Operation
                 (Operations.Composite_Operation'Class(Op_Ref.all),
                  Int_Op_Ref,Int_Iterator);
               Over_Ref:=Operations.New_Sched_Parameters(Int_Op_Ref.all);
               if Over_Ref/=null and then Over_Ref.all in
                 Scheduling_Parameters.Overridden_Permanent_FP_Parameters'Class
               then
                  Message(Verbose,Restriction_Name,
                          To_String("Operation: "&
                                    Operations.Name(Op_Ref)));
                  return False;
               end if;
            end loop;
         end if;
      end loop;
      return True;
   end No_Permanent_FP_Inside_Composite_Operations;

   ----------------------------------------
   -- No_Permanent_Overridden_Priorities --
   ----------------------------------------

   function No_Permanent_Overridden_Priorities
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean
   is
      Restriction_Name : constant String:="No_Permanent_Overridden_Priorities";
      Op_Ref : Operations.Operation_Ref;
      Iterator : Operations.Lists.Index;
      Over_Ref : Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
   begin
      Operations.Lists.Rewind(The_System.Operations,Iterator);
      for I in 1..Operations.Lists.Size(The_System.Operations) loop
         Operations.Lists.Get_Next_Item(Op_Ref,The_System.Operations,Iterator);
         Over_Ref:=Operations.New_Sched_Parameters(Op_Ref.all);
         if Over_Ref/=null and then Over_Ref.all in
           Scheduling_Parameters.Overridden_Permanent_FP_Parameters'Class
         then
            Message(Verbose,Restriction_Name,To_String
                    ("Operation: " & Operations.Name(Op_Ref)));
            return False;
         end if;
      end loop;
      return True;
   end No_Permanent_Overridden_Priorities;


   --------------
   -- PCP_Only --
   --------------

   function PCP_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True)
     return Boolean
   is
      Restriction_Name : constant String:="PCP Only";
      Resource_Ref : MAST.Shared_Resources.Shared_Resource_Ref;
      Iterator : MAST.Shared_Resources.Lists.Iteration_Object;
   begin
      MAST.Shared_Resources.Lists.Rewind
        (The_System.Shared_Resources,Iterator);
      for I in 1..MAST.Shared_Resources.Lists.Size
        (The_System.Shared_Resources)
      loop
         MAST.Shared_Resources.Lists.Get_Next_Item
           (Resource_Ref,The_System.Shared_Resources,Iterator);
         if Resource_Ref.all not in
           MAST.Shared_Resources.Immediate_Ceiling_Resource'Class
         then
            Message(Verbose,Restriction_Name,"Resource: "&
                    To_String(MAST.Shared_Resources.Name(Resource_Ref.all)));
            return False;
         end if;
      end loop;
      return True;
   end PCP_Only;

   -----------------------------------------
   -- No_Intermediate_Timing_Requirements --
   -----------------------------------------

   function No_Intermediate_Timing_Requirements
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True)
     return Boolean
   is
      Restriction_Name : constant String:=
        "No_Intermediate_Timing_Requirements";
      Trans_Name : constant String:="Transaction: "&
        To_String(MAST.Transactions.Name(Trans_Ref));
      A_Link_Ref : MAST.Graphs.Link_Ref;
      Iterator : Transactions.Link_Iteration_Object;
      Tim_Req_Ref : Timing_Requirements.Timing_Requirement_Ref;
   begin
      MAST.Transactions.Rewind_Internal_Event_Links(Trans_Ref.all,Iterator);
      for I in 1..MAST.Transactions.Num_Of_Internal_Event_Links(Trans_Ref.all)
      loop
         MAST.Transactions.Get_Next_Internal_Event_Link
           (Trans_Ref.all,A_Link_Ref,Iterator);
         Tim_Req_Ref:=Graphs.Links.Link_Timing_Requirements
           (Graphs.Links.Regular_Link(A_Link_Ref.all));
         if Tim_Req_Ref/=null then
            if Graphs.Output_Event_Handler(A_Link_Ref.all)/=null
            then
               Message(Verbose,Restriction_Name,Trans_Name);
               return False;
            end if;
         end if;
      end loop;
      return True;
   end No_Intermediate_Timing_Requirements;


   -----------------------------------------
   -- No_Intermediate_Timing_Requirements --
   -----------------------------------------

   function No_Intermediate_Timing_Requirements
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean
   is
      Trans_Ref : MAST.Transactions.Transaction_Ref;
      Iterator : Transactions.Lists.Iteration_Object;
   begin
      MAST.Transactions.Lists.Rewind(The_System.Transactions,Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Iterator);
         if not No_Intermediate_Timing_Requirements (Trans_Ref,Verbose)
         then
            return False;
         end if;
      end loop;
      return True;
   end No_Intermediate_Timing_Requirements;


   --------------------------------------
   -- PCP_Or_Priority_Inheritance_Only --
   --------------------------------------

   function PCP_Or_Priority_Inheritance_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True)
     return Boolean
   is
      Restriction_Name : constant String:="PCP or PIP Only";
      Resource_Ref : MAST.Shared_Resources.Shared_Resource_Ref;
      Iterator : MAST.Shared_Resources.Lists.Iteration_Object;
   begin
      MAST.Shared_Resources.Lists.Rewind
        (The_System.Shared_Resources,Iterator);
      for I in 1..MAST.Shared_Resources.Lists.Size
        (The_System.Shared_Resources)
      loop
         MAST.Shared_Resources.Lists.Get_Next_Item
           (Resource_Ref,The_System.Shared_Resources,Iterator);
         if Resource_Ref.all not in
           MAST.Shared_Resources.Immediate_Ceiling_Resource'Class and then
           Resource_Ref.all not in
           MAST.Shared_Resources.Priority_Inheritance_Resource'Class
         then
            Message(Verbose,Restriction_Name,"Resource: "&
                    To_String(MAST.Shared_Resources.Name(Resource_Ref.all)));
            return False;
         end if;
      end loop;
      return True;
   end PCP_Or_Priority_Inheritance_Only;

   ------------------------------------------
   -- Resource_Scheduling_Restrictions_Met --
   ------------------------------------------

   function Resource_Scheduling_Restrictions_Met
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True)
     return Boolean
     -- for the specified transaction:
     --    all SRP resources are used by EDF tasks
     --    all Priority Inheritance resources are used by Fp tasks
   is
      Restriction_Name : constant String:="PCP SRP or PIP Only";
      Trans_Name : constant String:="Transaction: "&
        To_String(MAST.Transactions.Name(Trans_Ref));

      Inconsistency : exception;

      procedure Process_Operation_Resources
        (The_Operation_Ref : MAST.Operations.Operation_Ref;
         The_Server_Ref : Scheduling_Servers.Scheduling_Server_Ref)
      is
         An_Act_Ref : MAST.Operations.Operation_Ref;
         Res_Ref : MAST.Shared_Resources.Shared_Resource_Ref;
         The_Res_Index : Resource_Lists.Index;
         Iterator : Operations.Resource_Iteration_Object;
         Op_Iterator : Operations.Operation_Iteration_Object;
         Sched_Params_Ref : Scheduling_Parameters.Sched_Parameters_Ref;
      begin
         if The_Operation_Ref.all in
           MAST.Operations.Simple_Operation'Class
         then
            Sched_Params_Ref:=Scheduling_Servers.Server_Sched_Parameters
              (The_Server_Ref.all);
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
               if Res_Ref.all in Shared_Resources.SRP_Resource'Class then
                  -- all SRP resources are used by EDF tasks
                  if Sched_Params_Ref.all not in
                    Scheduling_Parameters.EDF_Parameters'Class
                  then
                     Message(Verbose,Restriction_Name,Trans_Name,
                          "SRP resource used by non EDF server. ",
                          "Resource: "&
                          To_String(MAST.Shared_Resources.Name(Res_Ref)));
                     raise Inconsistency;
                  end if;
               elsif Res_Ref.all in
                 Shared_Resources.Priority_Inheritance_Resource'Class
               then
                  -- all Priority Inheritance resources are used by Fp tasks
                  if Sched_Params_Ref.all not in
                    Scheduling_Parameters.Fixed_Priority_Parameters'Class
                  then
                     Message(Verbose,Restriction_Name,Trans_Name,
                          "PIP resource used by non FP server. ",
                          "Resource: "&
                          To_String(MAST.Shared_Resources.Name(Res_Ref)));
                     raise Inconsistency;
                  end if;
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
               Process_Operation_Resources(An_Act_Ref,The_Server_Ref);
            end loop;
         end if;
      end Process_Operation_Resources;

      procedure Process_Operation_Resources
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref)
      is
         The_Operation_Ref : MAST.Operations.Operation_Ref;
         The_Server_Ref : Scheduling_Servers.Scheduling_Server_Ref;
      begin
         if The_Event_Handler_Ref.all in
           MAST.Graphs.Event_Handlers.Activity'Class
         then
            The_Operation_Ref:=Mast.Graphs.Event_Handlers.Activity_Operation
              (MAST.Graphs.Event_Handlers.Activity'Class
               (The_Event_Handler_Ref.all));
            The_Server_Ref:=Mast.Graphs.Event_Handlers.Activity_Server
              (MAST.Graphs.Event_Handlers.Activity'Class
               (The_Event_Handler_Ref.all));
            if The_Operation_Ref/=null then
               Process_Operation_Resources(The_Operation_Ref,The_Server_Ref);
            end if;
         end if;
      end Process_Operation_Resources;

      procedure Null_Operation
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Link_Ref : MAST.Graphs.Link_Ref) is
      begin
         null;
      end Null_Operation;

      procedure Iterate_Transaction_Paths is new
        MAST.Transaction_Operations.Traverse_Paths_From_Link_Once
        (Operation_For_Links  => Null_Operation,
         Operation_For_Event_Handlers => Process_Operation_Resources);

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
         Iterate_Transaction_Paths(Trans_Ref,A_Link_Ref);
      end loop;
      return True;
   exception
      when Inconsistency =>
         return False;
   end Resource_Scheduling_Restrictions_Met;

   ------------------------------------------
   -- Resource_Scheduling_Restrictions_Met --
   ------------------------------------------

   function Resource_Scheduling_Restrictions_Met
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean
     -- all SRP resources are used by EDF tasks
     -- all Priority Inheritance resources are used by Fp tasks
   is
      Trans_Ref : MAST.Transactions.Transaction_Ref;
      Iterator : Transactions.Lists.Index;
   begin
      -- Loop for every transaction
      MAST.Transactions.Lists.Rewind(The_System.Transactions,Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Iterator);
         if not Resource_Scheduling_Restrictions_Met(Trans_Ref,Verbose)
         then
            return False;
         end if;
      end loop;
      return True;
   end Resource_Scheduling_Restrictions_Met;

   ------------------------------------------
   -- PCP_SRP_Or_Priority_Inheritance_Only --
   ------------------------------------------

   function PCP_SRP_Or_Priority_Inheritance_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean
     -- all resources are PCP, SRP, or Priority Inheritance resources
     -- all SRP resources are used by EDF tasks
     -- all Priority Inheritance resources are used by Fp tasks
   is
      Restriction_Name : constant String:="PCP SRP or PIP Only";
      Resource_Ref : MAST.Shared_Resources.Shared_Resource_Ref;
      Iterator : MAST.Shared_Resources.Lists.Iteration_Object;
   begin
      MAST.Shared_Resources.Lists.Rewind
        (The_System.Shared_Resources,Iterator);
      for I in 1..MAST.Shared_Resources.Lists.Size
        (The_System.Shared_Resources)
      loop
         MAST.Shared_Resources.Lists.Get_Next_Item
           (Resource_Ref,The_System.Shared_Resources,Iterator);
         if Resource_Ref.all not in
           MAST.Shared_Resources.Immediate_Ceiling_Resource'Class and then
           Resource_Ref.all not in
           MAST.Shared_Resources.Priority_Inheritance_Resource'Class and then
           Resource_Ref.all not in
           MAST.Shared_Resources.SRP_Resource'Class
         then
            Message(Verbose,Restriction_Name,"Resource: "&
                    To_String(MAST.Shared_Resources.Name(Resource_Ref.all)));
            return False;
         end if;
      end loop;
      return Resource_Scheduling_Restrictions_Met(The_System,Verbose);
   end PCP_SRP_Or_Priority_Inheritance_Only;

   -----------------------------------------
   -- Referenced_Events_Are_External_Only --
   -----------------------------------------

   function Referenced_Events_Are_External_Only
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True)
     return Boolean
   is
      Restriction_Name : constant String:=
        "Referenced_Events_Are_External_Only";
      Trans_Name : constant String:="Transaction: "&
        To_String(MAST.Transactions.Name(Trans_Ref));
      A_Link_Ref : MAST.Graphs.Link_Ref;
      Iterator : Transactions.Link_Iteration_Object;
      Tim_Req_Ref : Timing_Requirements.Timing_Requirement_Ref;
   begin
      MAST.Transactions.Rewind_Internal_Event_Links(Trans_Ref.all,Iterator);
      for I in 1..MAST.Transactions.Num_Of_Internal_Event_Links(Trans_Ref.all)
      loop
         MAST.Transactions.Get_Next_Internal_Event_Link
           (Trans_Ref.all,A_Link_Ref,Iterator);
         Tim_Req_Ref:=Graphs.Links.Link_Timing_Requirements
           (Graphs.Links.Regular_Link(A_Link_Ref.all));
         if Tim_Req_Ref/=null then
            if (Tim_Req_Ref.all in Timing_Requirements.Global_Deadline'Class
                and then Timing_Requirements.Event
                (Timing_Requirements.Global_Deadline
                 (Tim_Req_Ref.all)).all not in Events.External_Event'Class)
              or else
              (Tim_Req_Ref.all in
               Timing_Requirements.Max_Output_Jitter_Req'Class
               and then Timing_Requirements.Event
               (Timing_Requirements.Max_Output_Jitter_Req
                (Tim_Req_Ref.all)).all not in Events.External_Event'Class)
            then
               Message(Verbose,Restriction_Name,Trans_Name);
               return False;
            end if;
         end if;
      end loop;
      return True;
   end Referenced_Events_Are_External_Only;

   -----------------------------------------
   -- Referenced_Events_Are_External_Only --
   -----------------------------------------

   function Referenced_Events_Are_External_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean
   is
      Trans_Ref : MAST.Transactions.Transaction_Ref;
      Iterator : Transactions.Lists.Iteration_Object;
   begin
      MAST.Transactions.Lists.Rewind(The_System.Transactions,Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Iterator);
         if not Referenced_Events_Are_External_Only(Trans_Ref,Verbose)
         then
            return False;
         end if;
      end loop;
      return True;
   end Referenced_Events_Are_External_Only;

   ------------------------------
   -- Simple_Transactions_Only --
   ------------------------------

   function Simple_Transactions_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True)
     return Boolean
   is
      Trans_Ref : MAST.Transactions.Transaction_Ref;
      Iterator : Transactions.Lists.Iteration_Object;
   begin
      MAST.Transactions.Lists.Rewind(The_System.Transactions,Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions)
      loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Iterator);
         if not Is_Simple_Transaction(Trans_Ref,Verbose) then
            return False;
         end if;
      end loop;
      return True;
   end Simple_Transactions_Only;

   --------------
   -- SRP_Only --
   --------------

   function SRP_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean
     -- All Resources are SRP
   is
      Restriction_Name : constant String:="SRP Only";
      Resource_Ref : MAST.Shared_Resources.Shared_Resource_Ref;
      Iterator : MAST.Shared_Resources.Lists.Iteration_Object;
   begin
      MAST.Shared_Resources.Lists.Rewind
        (The_System.Shared_Resources,Iterator);
      for I in 1..MAST.Shared_Resources.Lists.Size
        (The_System.Shared_Resources)
      loop
         MAST.Shared_Resources.Lists.Get_Next_Item
           (Resource_Ref,The_System.Shared_Resources,Iterator);
         if Resource_Ref.all not in
           MAST.Shared_Resources.SRP_Resource'Class
         then
            Message(Verbose,Restriction_Name,"Resource: "&
                    To_String(MAST.Shared_Resources.Name(Resource_Ref.all)));
            return False;
         end if;
      end loop;
      return True;
   end SRP_Only;

end MAST.Restrictions;
