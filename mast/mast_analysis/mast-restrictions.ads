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

with MAST.Systems,MAST.Transactions;

package MAST.Restrictions is

   ------------------------------
   -- System-Wide Restrictions --
   ------------------------------

   function Monoprocessor_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- only one processing resource: a Fixed_Priority_CPU

   function Max_Processor_Utilization
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Float;
   -- returns the maximum utilization level of all processing resources

   function Feasible_Processing_Load
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- checks that Max_Processor_Utilization is under 100%

   function Fixed_Priority_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- All Scheduling servers have Fixed Priority parameters,
   -- all overriden parameters in operations are Fixed Priority,
   -- and all priorities are within the appropriate ranges for their
   -- processing resources. There are no secondary schedulers.

   function EDF_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- All Scheduling Servers have EDF or Interrupt Parameters,
   -- there are no overriden parameters in operations, and all interrupt
   -- priorities are within the appropriate ranges for their processing
   -- resources. There are no secondary schedulers.

   function EDF_Within_Priorities_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- The primary schedulers have a fixed priority policy.
   -- All secondary schedulers have an EDF policy and are scheduled
   -- under a scheduling server that is directy attached to a
   -- primary server.
   -- All operations with overridden priorities are executed by fixed
   -- priority scheduling servers
   -- All priorities are in range

   function Flat_FP_Or_EDF_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- Each node is Fixed_Priorities_Only or EDF_Only

   function PCP_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- All Resources are PCP

   function PCP_Or_Priority_Inheritance_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- all resources are PCP or Priority Inheritance resources

   function PCP_SRP_Or_Priority_Inheritance_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- all resources are PCP, SRP, or Priority Inheritance resources
   -- all SRP resources are used by EDF tasks
   -- all Priority Inheritance resources are used by Fp tasks

   function SRP_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- All Resources are SRP

   function Referenced_Events_Are_External_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- No internal events are referenced

   function No_Intermediate_Timing_Requirements
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- No Timing requirements are attached to intermediate event channels,
   -- i.e., all timing requirements are attached to output events

   function No_Permanent_Overridden_Priorities
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- Checks that there is no operation with permanent overridden priorities

   function No_Permanent_FP_Inside_Composite_Operations
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- Checks that there is no composite operation that contains
   -- other operations with permanent overridden priorities

   -----------------------------------
   -- Transaction Kind Restrictions --
   -----------------------------------

   function Simple_Transactions_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- Checks that every transaction verifies Is_Simple_Transaction

   function Is_Simple_Transaction
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True) return Boolean;
   -- Checks that the transaction has only one segment
   --   (A segment is a continuous sequence of activities executed
   --    by the same server)

   function Linear_Transactions_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- Checks that every transaction verifies Is_Linear_Transaction

   function Is_Linear_Transaction
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True) return Boolean;
   -- checks that the transaction only has one external event
   -- and that its Event handlers are all Activities.

   function Linear_Plus_Transactions_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- Checks that every transaction verifies
   -- Is_Linear_Plus_Transaction

   function Is_Linear_Plus_Transaction
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True) return Boolean;
   -- Checks that the transaction has no Concentrators or
   -- Delivery_Servers or Query_Servers

   function Multiple_Event_Transactions_Only
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- Checks that every transaction verifies
   -- Is_Multiple_Event_Transaction

   function Is_Multiple_Event_Transaction
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True) return Boolean;
   -- Checks that the transaction is regular

end MAST.Restrictions;
