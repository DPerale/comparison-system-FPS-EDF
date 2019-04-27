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

with MAST.Systems,MAST.Transactions;

package MAST.Consistency_Checks is

   function Consistent_Transaction_Graphs
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- Checks the following rules for all transactions in the system:
   -- Rule 1: At least one external event Link
   -- Rule 2: Each external event Link directed at one Event_Handler,
   --         and with an external event
   -- Rule 3: Each internal event Link comes from a Event_Handler
   -- Rule 4: Each simple Event_Handler has an input Link
   --         and an output Link
   -- Rule 5: Each input Event_Handler has 2 or more input
   --         links and an output Link
   -- Rule 6: Each output Event_Handler has 2 or more
   --         output Links and an input Link
   -- Rule 7: No circular dependencies
   -- Rule 8: No isolated Links
   -- Rule 9: No isolated Event_Handlers
   -- Rule 10: All Activities have an operation
   -- Rule 11: All Activities have a scheduling server
   -- Rule 12: All Scheduling servers have a scheduler
   -- Rule 13: All Scheduling servers have scheduling parameters
   -- Rule 14: All rate divisors, offset and delay event handlers
   --          are only followed by activities
   -- Rule 15: All primary schedulers have a processing resource
   -- Rule 16: All secondary schedulers have a scheduling server
   -- Rule 17: All Schedulers have a scheduling policy
   -- Rule 18: All scheduling policies of the type
   --          FP_Packet_Based are associated with a primary
   --          scheduler located on a network
   -- Rule 19: All scheduling servers with parameters of the FP family
   --          are associated with schedulers having a policy of the
   --          FP family
   -- Rule 20: All scheduling servers with parameters of the EDF family
   --          are associated with schedulers having a policy of the
   --          EDF family
   -- Rule 21: All scheduling servers with parameters of the type
   --          Interrupt_FP_Policy are associated with primary schedulers
   -- Rule 22: All Message Transmission Operations are executed by
   --          scheduling servers executing on a network
   -- Rule 23: Each processing resource has at most one primary scheduler
   -- Rule 24: Each scheduling server has at most one secondary scheduler
   -- Rule 25: The size of each message sent through a network driver
   --          that does not support message partitioning is smaller than the
   --          maximum allowable message size
   -- Rule 27: All scheduling policies of a type that is not
   --          FP_Packet_Based are associated with a primary
   --          scheduler located on a processor

   function Consistent_Transaction_Graphs
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True) return Boolean;
   -- Checks the same rules for one transaction only

   function Consistent_Shared_Resource_Usage
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- Checks the following rules for all transactions in the system:
   -- Rule 1: all locked resources are unlocked
   -- Rule 2: no resource is locked if it was already locked
   -- Rule 3: no resource is unlocked if not previously locked

   function Consistent_Shared_Resource_Usage
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True) return Boolean;
   -- Checks the same rules for one transaction only

   function Consistent_Shared_Resource_Usage_For_Segments
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Boolean;
   -- Checks the following rule for all transactions in the system:
   --    all locked resources in a segment are unlocked in that segment

   function Consistent_Shared_Resource_Usage_For_Segments
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Verbose : Boolean := True) return Boolean;
   -- Checks the same rules for one transaction only

end MAST.Consistency_Checks;
