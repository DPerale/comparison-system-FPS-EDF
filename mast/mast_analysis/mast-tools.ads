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

with MAST.Systems,MAST.Transactions,
  MAST.Processing_Resources, MAST.Operations;

package MAST.Tools is

   ----------------------------------------
   -- Worst Case Response Analysis tools --
   ----------------------------------------

   type Worst_Case_Analysis_Tool is access procedure
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False);

   ----------------------
   -- Single processor --
   ----------------------

   procedure Classic_RM_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False);
   -- restricted to Monoprocessor_Only, Simple_Transactions_Only and
   -- Fixed_Priorities_Only

   procedure Varying_Priorities_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False);
   -- restricted to Monoprocessor_Only, Linear_Transactions_Only and
   -- Fixed_Priorities_Only

   procedure EDF_Monoprocessor_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False);
   -- restricted to Monoprocessor_Only, Simple_Transactions_Only and
   -- EDF_Only

   procedure EDF_Within_Priorities_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False);
   -- restricted to Monoprocessor_Only, Simple_Transactions_Only and
   -- EDF_Within_Priorities_Only

   -----------------
   -- Distributed --
   -----------------

   procedure Holistic_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False);
   -- restricted to Linear_Plus_Transactions_Only and Flat_FP_Or_EDF_Only
   -- produces results worse than Offset_Based_Analysis

   procedure Offset_Based_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False);
   -- restricted to Linear_Plus_Transactions_Only and Flat_FP_Or_EDF_Only
   -- produces results worse than Offset_Based_Optimized_Analysis in
   --    Fixed_Priorities_Only systems

   procedure Offset_Based_Optimized_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False);
   -- restricted to Linear_Plus_Transactions_Only and and Flat_FP_Or_EDF_Only

   procedure Multiple_Event_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False);
   -- restricted to Multiple_Event_Transactions_Only and
   -- Flat_FP_Or_EDF_Only

   procedure Calculate_Transaction_Slack
     (Trans_Ref : in MAST.Transactions.Transaction_Ref;
      The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True);
   -- calculates the relative amount that the execution times of the
   -- actions of the transaction referenced by Trans_Ref may grow
   -- (or may need decreasing) for the system to continue
   -- being (or become) schedulable
   -- Ci* = Ci * (1+The_Slack/100) for all actions in the transaction

   procedure Calculate_Transaction_Slacks
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True);
   -- Invokes Calculate_Transaction_Slack for all transactions in the system

   procedure Calculate_Processing_Resource_Slack
     (Res_Ref : in MAST.Processing_Resources.Processing_Resource_Ref;
      The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True);
   -- calculates the relative amount that the speed of the processing
   -- resource referenced by Res_Ref may be decreased
   -- (or may need inreasing) for the system to continue
   -- being (or become) schedulable
   -- Speed* = Speed * (1-The_Slack/100) for the processing resource

   procedure Calculate_Processing_Resource_Slacks
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True);
   -- Invokes Calculate_Processing_Resource_Slack for all processing
   -- resources in the system

   procedure Calculate_Operation_Slack
     (Op_Ref : in MAST.Operations.Operation_Ref;
      The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True);
   -- calculates the relative amount that the execution time of the
   -- operation referenced by Op_Ref may grow
   -- (or may need decreasing) for the system to continue
   -- being (or become) schedulable
   -- Ci* = Ci * (1+The_Slack/100) for that operation

  procedure Calculate_System_Slack
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True);
   -- calculates the relative amount that the execution times of the
   -- actions of all the transactions in the system may grow
   -- (or may need decreasing) for the system to continue being
   -- (or become) schedulable
   -- Ci* = Ci * (1+The_Slack/100) for all actions in the system

   --------------------------------------------
   -- Scheduling Parameters Assignment tools --
   --------------------------------------------

   type Priority_Assignment_Tool is access procedure
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True);

   procedure Monoprocessor_Assignment
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True);

   procedure Linear_HOPA
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True);

   procedure Linear_Deadline_Distribution
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True);

   procedure Multiple_Event_HOPA
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True);

   procedure Linear_Simulated_Annealing_Assignment
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True);

   procedure Multiple_Event_Simulated_Annealing_Assignment
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True);

   ------------------------------------
   -- Shared Resource Analysis Tools --
   ------------------------------------

   procedure Calculate_Ceilings_And_Levels
     (The_System : in out Mast.Systems.System;
      Verbose : in Boolean:=True);
   -- restrictions :
   --  PCP_SRP_Or_Priority_Inheritance_Only
   --  consistent shared resource usage
   --  all ceilings are consistent
   --  consistent shared resource usage for segments (i.e., all task
   --       segments unlock their locked resources)

   procedure Calculate_Blocking_Times
     (The_System : in out Mast.Systems.System;
      Verbose : in Boolean:=True);
   -- restrictions :
   --  PCP_SRP_Or_Priority_Inheritance_Only
   --  consistent shared resource usage
   --  all ceilings are consistent
   --  consistent shared resource usage for segments (i.e., all task
   --       segments unlock their locked resources)

   ------------------------
   -- Miscelaneous Tools --
   ------------------------

   procedure Utilization_Test
     (The_System : MAST.Systems.System;
      Suceeds : out Boolean;
      Verbose : in Boolean:=True);

   procedure Check_Shared_Resources_Total_Ordering
     (The_System : MAST.Systems.System;
      Ordered : out Boolean;
      Verbose : in Boolean:=True);

   procedure Check_Transaction_Schedulability
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Is_Schedulable : out Boolean;
      Verbose : in Boolean:=True);

   procedure Check_System_Schedulability
     (The_System : MAST.Systems.System;
      Is_Schedulable : out Boolean;
      Verbose : in Boolean:=True);

   function Calculate_Processing_Resource_Utilization
     (The_System : MAST.Systems.System;
      The_Pr : Mast.Processing_Resources.Processing_Resource_Ref;
      Verbose : Boolean := True) return Float;

   function Calculate_System_Utilization
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Float;


end MAST.Tools;
