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

with MAST.Transactions,MAST.Graphs;
package MAST.Transaction_Operations is

   Incorrect_Link : exception;

   procedure Identify_Segment
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      The_Link_Ref : MAST.Graphs.Link_Ref;
      Next_Link_Ref : out MAST.Graphs.Link_Ref);
   -- raises Incorrect_Link if The_Link_Ref does not point to an Activity

   procedure Identify_Segment_With_Permanent_FP
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      The_Link_Ref : MAST.Graphs.Link_Ref;
      Next_Link_Ref : out MAST.Graphs.Link_Ref);
   -- raises Incorrect_Link if The_Link_Ref does not point to an Activity

   procedure Get_Segment_Data_With_Permanent_FP
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      The_Link_Ref : MAST.Graphs.Link_Ref;
      Next_Link_Ref : out MAST.Graphs.Link_Ref;
      WCET : out Time;
      BCET : out Time;
      Uses_Shared_Resources : out Boolean;
      Segment_Prio : in out Priority;
      Preassigned_Prio : out Boolean);
   -- This version returns different segments if different
   -- permanent overridden priorities are found
   -- raises Incorrect_Link if The_Link_Ref does not point to an Activity

   generic
      with procedure Operation_For_Event_Handlers
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref);
      with procedure Operation_For_Links
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Link_Ref : MAST.Graphs.Link_Ref);
   procedure Traverse_Paths_From_Link_Once
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      The_Link_Ref : MAST.Graphs.Link_Ref);
   -- Traverses all the links and Event_Handlers of all
   -- the transaction paths starting from the specified
   -- link, but continuing a path only for
   -- the first input link of each input Event_Handler.
   -- This allows visiting each Event_Handler and link of
   -- a transaction just once.
   -- Calls Operation_For_Event_Handlers for each Event_Handler
   -- visited, and Operation_For_Links for each link visited.

   generic
      with procedure Operation_For_Event_Handlers
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref);
      with procedure Operation_For_Links
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Link_Ref : MAST.Graphs.Link_Ref);
   procedure Traverse_Paths_From_Link
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      The_Link_Ref : MAST.Graphs.Link_Ref);
   -- Traverses all the paths of the specified transaction starting
   -- from the specified link. It traverses all possible paths from it.
   -- Calls Operation_For_Event_Handlers for each Event_Handler
   -- visited, and Operation_For_Links for each link visited.

end MAST.Transaction_Operations;

