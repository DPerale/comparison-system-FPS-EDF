-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2003-2005                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors: Michael Gonzalez          mgh@unican.es                  --
--          Jose Javier Gutierrez     gutierjj@unican.es             --
--          Jose Carlos Palencia      palencij@unican.es             --
--          Jose Maria Drake          drakej@unican.es               --
--          Patricia López Martínez   lopezpa@unican.es              --
--          Yago Pereiro Estevan                                     --
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

with Dom.Core;
with Var_Strings;
with Mast.Graphs;
with Mast.Operations;
with Mast.Processing_Resources;
with Mast.Shared_Resources;
with Mast.Scheduling_Servers;
with Mast.Systems;
with Mast.Transactions;
with Ada.Text_Io;
with Mast.Schedulers;
with Mast.Timing_Requirements;

package Mast_XML_Parser is

   -- Class Utility Mast_XML_Parser

   -- Documentation:
   --    Mast_XML_Parser parses a Mast_Model file, reading from an
   --    XML format into a Mast_System data structure in Ada.
   --    It may raise the following exceptions:
   --    <Mast_XML_Exceptions.Syntax_Error>:
   --         there has been a problem during de parsing.
   --
   procedure Parse
     (Mast_System : in out Mast.Systems.System;
      File: in out Ada.Text_IO.File_Type);

private

   -- Class Mast_Root_Elements
   --
   -- Documentation:
   --    Basic elements of the Mast structure.
   type Mast_Root_Elements is
     (Regular_Processor,Packet_Based_Network,
      Primary_Scheduler,Regular_Scheduling_Server,
      Secondary_Scheduler,Immediate_Ceiling_Resource,
      Priority_Inheritance_Resource,SRP_Resource,
      Simple_Operation,Message_Transmission,
      Composite_Operation,Enclosing_Operation,
      Regular_Transaction);

   -- Class Utility Mast_Dom
   --
   -- Documentation:
   --    That is a package with functions that simplify very much
   --    used algorithms to manage the DOM tree.

   -- Documentation:
   --    The attribute is not in the element.
   Non_Existing : exception;


   -- Documentation:
   --    Given the Element_Node and the name of the attribute,
   --    it returns the value of that attribute. if it does
   --    not exist, the Non_Existing exception will be raised.
   function Get_Attribute
     (E : DOM.Core.Node;
      Att_Name : String)
     return Var_Strings.Var_String;


   -- Class Utility Priority_Inheritance_Resource
   --
   -- Documentation:
   --    Library with the procedure to
   --    add the Priority_Inheritance_Resource from the DOM
   --    tree into the Mast structure

   -- Documentation:
   --    1. Initialize a Shared_Resource of that kind.
   --    2. Process the attributes.
   --    3. Add the Shared_Resource Structure to the Mast_System structure.
   procedure Add_Priority_Inheritance_Resource
     (Mast_System : in out Mast.Systems.System;
      Sr_Node : Dom.Core.Node);


   -- Class Utility Immediate_Ceiling_Resource
   --
   -- Documentation:
   --    Library where can be found the necessary procedure to
   --    add the Immediate_Ceiling_Resource from the DOM tree
   --    into the Mast structure

   -- Documentation:
   --    1. Initialize a Shared_Resource of that kind.
   --    2.Process the attributes.
   --    3. Add the Shared_Resource Structure to the Mast_
   --    System structure.
   procedure Add_Immediate_Ceiling_Resource
     (Mast_System: in out Mast.Systems.System;
      Sr_Node : Dom.Core.Node);


   -- Class Utility SRP_Resource
   --
   -- Documentation:
   --    Library where can be found the necessary procedure to
   --    add the SRP_Resource from the DOM tree
   --    into the Mast structure

   -- Documentation:
   --    1. Initialize a Shared_Resource of that kind.
   --    2.Process the attributes.
   --    3. Add the Shared_Resource Structure to the Mast_
   --    System structure.
   procedure Add_SRP_Resource
     (Mast_System: in out Mast.Systems.System;
      Sr_Node : Dom.Core.Node);


   -- Class Mast_Scheduling_Server_Policy_Elements
   --
   -- Documentation:
   --    Kinds of Scheduling_Servers Policies in Mast.
   type Mast_Scheduling_Server_Policy_Elements is
     (Non_Preemptible_Fp_Policy,Fixed_Priority_Policy,Interrupt_FP_Policy,
      Polling_Policy,Sporadic_Server_Policy,EDF_Policy,SRP_Parameters);


   -- Class Utility Regular_Scheduling_Server
   --
   -- Documentation:
   --    Library where can be found the necessary procedures
   --    to add a Regular_Scheduling_Server from a Regular_
   --    Scheduling_Server_Node of the DOM tree into the Mast
   --    structure

   -- Documentation:
   --    Add a Regular_Scheduling_Server to the mast_system Structure
   --    from a regular_scheduling_server node of the Dom_Tree.
   --       Create an access to a Priority_Server.
   --       Look for the Scheduler associated.
   --       Call the Respective Add depending on the Scheduling_Policy.
   --       Add the Priority_Server to the Sched_Servers List.
   --
   procedure Add_Regular_Scheduling_Server
     (Mast_System: in out Mast.Systems.System;
      Rss_Node : Dom.Core.Node);


   -- Attributes of scheduling parameters

   type Sched_Par is
     (The_Priority,Preassigned,Polling_Period,Polling_Worst_Overhead,
      Polling_Avg_Overhead,Polling_Best_Overhead,Normal_Priority,
      Background_Priority,Initial_Capacity,Replenishment_Period,
      Max_Pending_Replenishments,Deadline,Preemption_Level);


   -- Documentation:
   --    Add a Scheduling_Policy from the dom tree to a
   --    Scheduling_Server structure accessed by Sched_Serv_
   --    Ref
   --       Create a Sched_Parameter Structure.
   --       Process the Attributes.
   --       Add the Sched_Pârameter Structure to
   --       the Sched_Server Structure.
   --
   procedure Add_Non_Preemptible_FP_Policy
     (Sched_Serv_Ref : in out Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Npfp_Node  : Dom.Core.Node);


   -- Documentation:
   --    Add a Scheduling_Policy from the dom tree to a
   --    Scheduling_Server structure accessed by Sched_Serv_
   --    Ref
   --       Create a Sched_Parameter Structure.
   --       Process the Attributes.
   --       Add the Sched_Pârameter Structure to
   --       the Sched_Server Structure.
   --
   procedure Add_Fixed_Priority_Policy
     (Sched_Serv_Ref : in out Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Fpp_Node : Dom.Core.Node);


   -- Documentation:
   --    Add a Scheduling_Policy from the dom tree to a
   --    Scheduling_Server structure accessed by Sched_Serv_
   --    Ref
   --       Create a Sched_Parameter Structure.
   --       Process the Attributes.
   --       Add the Sched_Pârameter Structure to
   --       the Sched_Server Structure.
   --
   procedure Add_Interrupt_FP_Policy
     (Sched_Serv_Ref : in out Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Ifpp_Node : Dom.Core.Node);


   -- Documentation:
   --    Add a Scheduling_Policy from the dom tree to a
   --    Scheduling_Server structure accessed by Sched_Serv_
   --    Ref
   --       Create a Sched_Parameter Structure.
   --       Process the Attributes.
   --       Add the Sched_Pârameter Structure to
   --       the Sched_Server Structure.
   --
   procedure Add_Polling_Policy
     (Sched_Serv_Ref : in out Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Pp_Node: Dom.Core.Node);


   -- Documentation:
   --    Add a Scheduling_Policy from the dom tree to a
   --    Scheduling_Server structure accessed by Sched_Serv_
   --    Ref
   --       Create a Sched_Parameter Structure.
   --       Process the Attributes.
   --       Add the Sched_Pârameter Structure to
   --       the Sched_Server Structure.
   --
   procedure Add_Sporadic_Server_Policy
     (Sched_Serv_Ref : in out Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Ssp_Node : Dom.Core.Node);


   -- Documentation:
   --    Add a Scheduling_Policy from the dom tree to a
   --    Scheduling_Server structure accessed by Sched_Serv_
   --    Ref
   --       Create a Sched_Parameter Structure.
   --       Process the Attributes.
   --       Add the Sched_Pârameter Structure to
   --       the Sched_Server Structure.

   procedure Add_EDF_Policy
     (Sched_Serv_Ref : in out Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Edfp_Node : Dom.Core.Node);


   -- Documentation:
   --    Add The Srp Parameters To De Scheduling_Server Structure.
   procedure Add_SRP_Parameters
     (Sched_Serv_Ref : in out Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Srpp_Node : Dom.Core.Node);


   --Structure to access the procedures:
   type Scheduling_Server_Add is access procedure
     (Sched_Serv_Ref: in out Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Fp_Policy:Dom.Core.Node);

   Scheduling_Server_Adds : array(Mast_Scheduling_Server_Policy_Elements)of
     Scheduling_Server_Add:=
     (Non_Preemptible_Fp_Policy=>Add_Non_Preemptible_Fp_Policy'Access,
      Fixed_Priority_Policy=>Add_Fixed_Priority_Policy'Access,
      Interrupt_FP_Policy=>Add_Interrupt_FP_Policy'Access,
      Polling_Policy=>Add_Polling_Policy'Access,
      Sporadic_Server_Policy=>Add_Sporadic_Server_Policy'Access,
      Edf_Policy=>Add_Edf_Policy'Access,
      SRP_Parameters=>Add_SRP_Parameters'Access);


   -- Class Mast_System_Timer_Elements
   --
   -- Documentation:
   --    Kinds of System_Timers in Mast
   type Mast_System_Timer_Elements is
     (Ticker_System_Timer,Alarm_Clock_System_Timer);


   -- Class Utility Regular_Processor
   --
   -- Documentation:
   --    Library where can be found the necessary procedures
   --    to add a Regular_Processor from a Regular_Processor_
   --    Node of the DOM tree into the Mast structure

   -- Documentation:
   --    Adds a Regular_Processor to the mast_system
   --    Structure  from a regular_processor node of the Dom_
   --    Tree.
   --
   procedure Add_Regular_Processor
     (Mast_System: in out Mast.Systems.System;
      Rp_Node : Dom.Core.Node);


   -- Documentation:
   --    Add a System_Timer from the dom tree to a Regular_
   --    Processor structure accessed by rp_res_ref
   --
   procedure Add_Ticker_System_Timer
     (Rsrc :in out Mast.Processing_Resources.Processing_Resource_Ref;
      Tst_Node  : Dom.Core.Node);


   -- Documentation:
   --    Add a System_Timer from the dom tree to a Regular_
   --    Processor structure accessed by rp_res_ref
   --
   procedure Add_Alarm_Clock_System_Timer
     (Rsrc :in out Mast.Processing_Resources.Processing_Resource_Ref;
      Acst_Node : Dom.Core.Node);


   type System_Timer_Add is access procedure
     (Rsrc :in out Mast.Processing_Resources.Processing_Resource_Ref;
      System_Timer : Dom.Core.Node);

   System_Timer_Adds : array (Mast_System_Timer_Elements)of
     System_Timer_Add:=
     (Ticker_System_Timer=>Add_Ticker_System_Timer'Access,
      Alarm_Clock_System_Timer=>Add_Alarm_Clock_System_Timer'Access);


   -- Class Mast_Timing_Requirement_Elements
   -- Documentation:
   -- Kinds of Timming_Requirements in Mast.
   type Mast_Timming_Requirement_Elements is
     (Composite_Timing_Requirement,Max_Output_Jitter_Req,Hard_Global_Deadline,
      Soft_Global_Deadline,Global_Max_Miss_Ratio,Hard_Local_Deadline,
      Soft_Local_Deadline,Local_Max_Miss_Ratio);


   -- Class Mast_Event_Elements
   --
   -- Documentation:
   --    Kinds of Events in Mast
   type Mast_Event_Elements is
     (Periodic_External_Event,Sporadic_External_Event,Unbounded_External_Event,
      Bursty_External_Event,Singular_External_Event,Regular_Event,Activity,
      System_Timed_Activity,Concentrator,Barrier,Delivery_Server,Query_Server,
      Multicast,Rate_Divisor,Ddelay,Offset);


   -- Class Utility Regular_Transaction
   --
   -- Documentation:
   --    Library where can be found the necessary procedures
   --    to add a Regular_Transaction from a Regular_
   --    Transaction_Node of the DOM tree into the Mast
   --    structure. It may raise the following
   --    exceptions: <Invalid_Link_Type>=when there are a
   --    invalid event type for an  event_handler output, <Link
   --    _Not_Found>:when an input event is not found.,
   --    <Operation_Error>:when an Operation for an event_
   --    Handle is not found.

   -- Data Members for Class Attributes

   -- Documentation:
   --    Adds a Regular_Transaction to the mast_system
   --    Structure  from a regular_transaction node of the Dom_
   --    Tree.
   --
   procedure Add_Transaction
     (Mast_System: in out Mast.Systems.System;
      Rt_Node  : Dom.Core.Node);


   -- Attributes of external events
   type External_Event_Attributes is
     (Name,Period,Max_Jitter,Phase,Avg_Interarrival,Distribution,
      Min_Interarrival,Bound_Interval,Max_Arrivals);


   -- Documentation:
   --    Add an External_Event from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_Periodic_External_Event
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Ee_Node : Dom.Core.Node);


   -- Documentation:
   --    Add an External_Event from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_Sporadic_External_Event
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Ee_Node : Dom.Core.Node);


   -- Documentation:
   --    Add an External_Event from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_Unbounded_External_Event
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Ee_Node : Dom.Core.Node);


   -- Documentation:
   --    Add an External_Event from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_Singular_External_Event
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Ee_Node : Dom.Core.Node);


   -- Documentation:
   --    Add an External_Event from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_Bursty_External_Event
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Ee_Node : Dom.Core.Node);


   -- Documentation:
   --    Add an Regular_Event from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_Regular_Event
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Ie_Node : Dom.Core.Node);


   -- Attributes of timing requirements
   type Timing_Req_Attributes is
     (Ratio,Deadline,Referenced_Event,Max_Output_Jitter);


   -- Documentation:
   --    Add a Timming_Requirement from the dom tree to a
   --    Regular_Event structure accessed by Link_ref.
   --
   procedure Add_Composite
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node : Dom.Core.Node;
      Comp_Tr_Ref: in out Mast.Timing_Requirements.Timing_Requirement_Ref);


   -- Documentation:
   --    Add a Timming_Requirement from the dom tree to a
   --    Regular_Event structure accessed by Link_ref.
   --
   procedure Add_Max_Output_Jitter
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node : Dom.Core.Node;
      Comp_Tr_Ref: in out Mast.Timing_Requirements.Timing_Requirement_Ref);


   -- Documentation:
   --    Add a Timming_Requirement from the dom tree to a
   --    Regular_Event structure accessed by Link_ref.
   --
   procedure Add_Hard_Global_Deadline
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node : Dom.Core.Node;
      Comp_Tr_Ref: in out Mast.Timing_Requirements.Timing_Requirement_Ref);


   -- Documentation:
   --    Add a Timming_Requirement from the dom tree to a
   --    Regular_Event structure accessed by Link_ref.
   --
   procedure Add_Soft_Global_Deadline
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node : Dom.Core.Node;
      Comp_Tr_Ref: in out Mast.Timing_Requirements.Timing_Requirement_Ref);


   procedure Add_Global_Max_Miss_Ratio
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node : Dom.Core.Node;
      Comp_Tr_Ref: in out Mast.Timing_Requirements.Timing_Requirement_Ref);


   -- Documentation:
   --    Add a Timming_Requirement from the dom tree to a
   --    Regular_Event structure accessed by Link_ref.
   --
   procedure Add_Hard_Local_Deadline
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node : Dom.Core.Node;
      Comp_Tr_Ref: in out Mast.Timing_Requirements.Timing_Requirement_Ref);


   -- Documentation:
   --    Add a Timming_Requirement from the dom tree to a
   --    Regular_Event structure accessed by Link_ref.
   --
   procedure Add_Soft_Local_Deadline
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node : Dom.Core.Node;
      Comp_Tr_Ref: in out Mast.Timing_Requirements.Timing_Requirement_Ref);


   -- Documentation:
   --    Add a Timming_Requirement from the dom tree to a
   --    Regular_Event structure accessed by Link_ref.
   --
   procedure Add_Local_Max_Miss_Ratio
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node : Dom.Core.Node;
      Comp_Tr_Ref: in out Mast.Timing_Requirements.Timing_Requirement_Ref);


   -- Documentation:
   --    Add an Event_Handler from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_Activity
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node);


   -- Documentation:
   --    Add an Event_Handler from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_System_Timed_Activity
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node);


   -- Documentation:
   --    Add an Event_Handler from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_Concentrator
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node);


   -- Documentation:
   --    Add an Event_Handler from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_Barrier
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node);


   -- Documentation:
   --    Add an Event_Handler from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_Delivery_Server
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node);


   -- Documentation:
   --    Add an Event_Handler from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_Query_Server
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node);


   -- Documentation:
   --    Add an Event_Handler from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_Multicast
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node);


   -- Documentation:
   --    Add an Event_Handler from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_Rate_Divisor
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node);


   -- Documentation:
   --    Add an Event_Handler from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_Delay
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node);


   -- Documentation:
   --    Add an Event_Handler from the dom tree to a Regular_
   --    Transaction structure accessed by trans_ref.
   --
   procedure Add_Offset
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node);


   --Structure to access the procedures:
   type Timming_Requirement_Add is access procedure
     (Link_Ref:in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Event:Dom.Core.Node;
      Comp_Tr_Ref: in out Mast.Timing_Requirements.Timing_Requirement_Ref);
   type Event_Add is access procedure
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Event : Dom.Core.Node);

   Timming_Requirement_Adds : array(Mast_Timming_Requirement_Elements) of
     Timming_Requirement_Add:=
     (Composite_Timing_Requirement=>Add_Composite'Access,
      Max_Output_Jitter_Req=>Add_Max_Output_Jitter'Access,
      Hard_Global_Deadline=>Add_Hard_Global_Deadline'Access,
      Soft_Global_Deadline=>Add_Soft_Global_Deadline'Access,
      Global_Max_Miss_Ratio=>Add_Global_Max_Miss_Ratio'Access,
      Hard_Local_Deadline=>Add_Hard_Local_Deadline'Access,
      Soft_Local_Deadline=>Add_Soft_Local_Deadline'Access,
      Local_Max_Miss_Ratio=>Add_Local_Max_Miss_Ratio'Access);

   Event_Adds : array(Mast_Event_Elements) of Event_Add:=
     (Periodic_External_Event=>Add_Periodic_External_Event'Access,
      Sporadic_External_Event=>Add_Sporadic_External_Event'Access,
      Unbounded_External_Event=>Add_Unbounded_External_Event'Access,
      Bursty_External_Event=>Add_Bursty_External_Event'Access,
      Singular_External_Event=>Add_Singular_External_Event'Access,
      Regular_Event=>Add_Regular_Event'Access,
      Activity=>Add_Activity'Access,
      System_Timed_Activity=>Add_System_Timed_Activity'Access,
      Concentrator=>Add_Concentrator'Access,
      Barrier=>Add_Barrier'Access,
      Delivery_Server=>Add_Delivery_Server'Access,
      Query_Server=>Add_Query_Server'Access,
      Multicast=>Add_Multicast'Access,
      Rate_Divisor=>Add_Rate_Divisor'Access,
      Ddelay=>Add_Delay'Access,
      Offset=>Add_Offset'Access);


   -- Class Mast_Scheduler_Elements
   type Mast_Scheduler_Elements is
     (Fixed_Priority_Scheduler,EDF_Scheduler,FP_Packet_Based_Scheduler);


   -- Class Utility Scheduler
   --
   -- Documentation:
   --    Library where can be found the necessary procedures
   --    to add a Scheduler from a Scheduler_Node of the DOM
   --    tree into the Mast structure


   --Documentation:
   --   Adds a Scheduler to the mast_system Structure
   --   from a scheduler node of the Dom_Tree.
   procedure Add_Primary_Scheduler
     (Mast_System: in out Mast.Systems.System;
      Sched_Node : Dom.Core.Node);


   --Documentation:
   --   Adds a Scheduler to the mast_system Structure
   --   from a scheduler node of the Dom_Tree.
   procedure Add_Secondary_Scheduler
     (Mast_System: in out Mast.Systems.System;
      Sched_Node : Dom.Core.Node);


   --Documentation:
   --   Add the Scheduler policy to the Scheduler by sched_ref
   --   (access to the initialized Scheduler structure).
   procedure Add_Fixed_Priority_Scheduler
     (Sched_Ref : in out Mast.Schedulers.Scheduler_Ref;
      Sp_Node : Dom.Core.Node);


   --Documentation:
   --   Add the Scheduler policy to the Scheduler by sched_ref
   -- (access to the initialized Scheduler structure).
   procedure Add_EDF_Scheduler
     (Sched_Ref : in out Mast.Schedulers.Scheduler_Ref;
      Sp_Node : Dom.Core.Node);


   --Documentation:
   --   Add the Scheduler policy to the Scheduler by
   --   sched_ref (access to the initialized Scheduler structure).
   procedure Add_FP_Packet_Based_Scheduler
     (Sched_Ref : in out Mast.Schedulers.Scheduler_Ref;
      Sp_Node : Dom.Core.Node);


   --Structure to access the procedures:
   type Scheduler_Add is access procedure
     (Sched_Ref: in out Mast.Schedulers.Scheduler_Ref;Sp_Node:Dom.Core.Node);

   Scheduler_Adds : array (Mast_Scheduler_Elements) of Scheduler_Add:=
     (Fixed_Priority_Scheduler=>Add_Fixed_Priority_Scheduler'Access,
      Edf_Scheduler=>Add_Edf_Scheduler'Access,
      FP_Packet_Based_Scheduler=>Add_FP_Packet_Based_Scheduler'Access);


   -- Class Utility Operations

   --
   -- Documentation:
   --    Library where can be found the necessary procedures
   --    to add Any kind of Operation from an Operation_Node
   --    of the DOM tree into the Mast structure

   -- Documentation:
   --    Adds a Composite_Operation to the mast_system
   --    Structure  from a composite_operation node of the Dom_
   --    Tree.
   --
   procedure Add_Composite_Operation
     (Mast_System: in out Mast.Systems.System;
      Co_Node : Dom.Core.Node);


   -- Documentation:
   --    Adds a Simple_Operation to the mast_system Structure
   --    from a composite_operation node of the Dom_Tree.
   --
   procedure Add_Simple_Operation
     (Mast_System: in out Mast.Systems.System;
      Sop_Node : Dom.Core.Node);


   -- Documentation:
   --    Adds a Enclosing_Operation to the mast_system
   --    Structure  from a composite_operation node of the Dom_
   --    Tree.
   --
   procedure Add_Enclosing_Operation
     (Mast_System: in out Mast.Systems.System;
      Eop_Node : Dom.Core.Node);


   -- Documentation:
   --    Adds a Message_Transmission to the mast_system
   --    Structure  from a composite_operation node of the Dom_
   --    Tree.
   --
   procedure Add_Message_Transmission
     (Mast_System: in out Mast.Systems.System;
      Mt_Node : Dom.Core.Node);



   -- Documentation:
   --    Add an overriden_param from the dom tree to a Simple_
   --    operation structure accessed by op_ref
   --
   procedure Add_Overridden_Fixed_Priority
     (Op_Ref :in out Mast.Operations.Operation_Ref;
      Op_Node : Dom.Core.Node);


   -- Documentation:
   --    Add an overriden_param from the dom tree to a Simple_
   --    operation structure accessed by op_ref
   --
   procedure Add_Overridden_Permanent_FP
     (Op_Ref :in out Mast.Operations.Operation_Ref;
      Op_Node : Dom.Core.Node);


   -- Documentation:
   --    Add a Shared_Resources_List from the Dom tree to a
   --    simple_operation structure accessed by op_ref
   --
   procedure Add_Shared_Resources_List
     (Mast_Shr :  MAST.Shared_Resources.Lists.List;
      Op_Ref      :in out Mast.Operations.Operation_Ref;
      Sr_Lst_Node : Dom.Core.Node);

   -- Documentation:
   --    Add Shared_Resources_To_Lock from the Dom tree to a
   --    simple_operation structure accessed by op_ref
   --
   procedure Add_Shared_Resources_To_Lock
     (Mast_Shr :  MAST.Shared_Resources.Lists.List;
      Op_Ref :in out Mast.Operations.Operation_Ref;
      Sr_To_Lock_Node : Dom.Core.Node);

   -- Documentation:
   --    Add Shared_Resources_To_Unlock from the Dom tree to a
   --    simple_operation structure accessed by op_ref
   --
   procedure Add_Shared_Resources_To_Unlock
     (Mast_Shr :  MAST.Shared_Resources.Lists.List;
      Op_Ref :in out Mast.Operations.Operation_Ref;
      Sr_To_Unlock_Node : Dom.Core.Node);


   --Structure to access the procedures:

   -- Operation_Adds : array(Mast_Simple_Operation_Elements) of Operation_Add:=
   -- (Overridden_Fixed_Priority=>Add_Overridden_Fixed_Priority'access,
   -- Overridden_Permanent_Fp=>Add_Overridden_Permanent_Fp'access,
   -- Shared_Resources_List=>Add_Shared_Resources_List'access,
   -- Shared_Resources_To_Lock=>Add_Shared_Resources_To_Lock'access,
   -- Shared_Resources_To_Unlock=>Add_Shared_Resources_To_Unlock'access);

   -- Class Mast_Driver_Elements
   --
   -- Documentation:
   --    Kinds of Drivers in Mast.
   type Mast_Driver_Elements is
     (Packet_Driver, Character_Packet_Driver, RTEP_Packet_Driver);


   -- Class Utility Packet_Based_Network
   --
   -- Documentation:
   --    Library where can be found the necessary procedures
   --    to add a Packet_Based_Network from a Packet_Based_
   --    Network_Node of the DOM tree into the Mast structure

   -- Documentation:
   --    Adds a Packet_Based_Network to the mast_system
   --    Structure from a packet_based_network node of the Dom_Tree.

   procedure Add_Packet_Based_Network
     (Mast_System: in out Mast.Systems.System;
      Pbn_Node : Dom.Core.Node);


   --Add a Packet_Driver from the dom tree to a
   --Packet_Based_Network structure accessed by a Processing_Resource_Ref
   -- (reference to the initializated network).
   procedure Add_Packet_Driver
     (Mast_System :in out  Mast.Systems.System;
      Rsrc :in out  Mast.Processing_Resources.Processing_Resource_Ref;
      Pd_Node : Dom.Core.Node);


   --Add a Character_Packet_Driver from the dom tree to a
   --Character_Packet_Based_Network structure accessed by a
   -- Processing_Resource_Ref (reference to the initializated network).
   procedure Add_Character_Packet_Driver
     (Mast_System :in out  Mast.Systems.System;
      Rsrc :in out Mast.Processing_Resources.Processing_Resource_Ref;
      Cpd_Node : Dom.Core.Node);


   --Add an RTEP_Packet_Driver from the dom tree to a
   --Packet_Based_Network structure accessed by a Processing_Resource_Ref
   -- (reference to the initializated network).
   procedure Add_RTEP_Packet_Driver
     (Mast_System :in out  Mast.Systems.System;
      Rsrc :in out  Mast.Processing_Resources.Processing_Resource_Ref;
      Pd_Node : Dom.Core.Node);

   --Structure to access the procedures:
   type Driver_Add is access procedure
     (Mast_System :in out Mast.Systems.System;
      Rsrc :in out Mast.Processing_Resources.Processing_Resource_Ref;
      Driver : Dom.Core.Node);

   Driver_Adds : array ( Mast_Driver_Elements) of Driver_Add:=
     (Packet_Driver=>Add_Packet_Driver'Access,
      Character_Packet_Driver=>Add_Character_Packet_Driver'Access,
      RTEP_Packet_Driver=>Add_RTEP_Packet_Driver'Access);

   --Structure to access the procedures:
   type Mast_Root_Add is access procedure
     ( Mast_System: in out Mast.Systems.System;
       Mast_Root_Element : Dom.Core.Node);

   Mast_Root_Adds : array(Mast_Root_Elements) of Mast_Root_Add:=
     (Regular_Processor=>Add_Regular_Processor'Access,
      Packet_Based_Network=>Add_Packet_Based_Network'Access,
      Primary_Scheduler=>Add_Primary_Scheduler'Access,
      Regular_Scheduling_Server=>Add_Regular_Scheduling_Server'Access,
      Secondary_Scheduler=>Add_Secondary_Scheduler'Access,
      Immediate_Ceiling_Resource=>Add_Immediate_Ceiling_Resource'Access,
      SRP_Resource=>Add_SRP_Resource'Access,
      Priority_Inheritance_Resource=>Add_Priority_Inheritance_Resource'Access,
      Simple_Operation=>Add_Simple_Operation'Access,
      Message_Transmission=>Add_Message_Transmission'Access,
      Composite_Operation=>Add_Composite_Operation'Access,
      Enclosing_Operation=>Add_Enclosing_Operation'Access,
      Regular_Transaction=>Add_Transaction'Access);

end Mast_XML_Parser;
