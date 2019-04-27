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

with MAST.Systems,Mast.Graphs,Mast.Events,Mast.Scheduling_Parameters,
  Mast.Synchronization_Parameters,
  Mast.Processing_Resources, Mast.Scheduling_Policies;

generic
   type Processor_ID_Type is range <>;
   type Transaction_ID_Type is range <>;
   type Task_ID_Type is range <>;
   Max_Processors : Processor_ID_Type;
   Max_Transactions : Transaction_ID_Type;
   Max_Tasks_Per_Transaction : Task_ID_Type;

package Mast.Linear_Translation is

   Max_OverDeadline : constant Natural := 100;
   Analysis_Bound : Time;
   Max_Busy_Period : Time;


   -------------------------------------------------------------------
   --                  History of main changes
   -------------------------------------------------------------------
   -- New features added (Oct 2000) to Task_Data
   --  Cijown, Cbijown
   --  Independent Tij for each task. Should not use Transaction Ti
   --  Tijown
   --  Jij: the calculated jitter
   --  Jinit: the initial jitter (may not be null for internal events)
   --  Sched_Delay
   --  Independent
   --  Model
   --  Jitter_Avoidance
   --  Uses shared resources:
   --       Note: this is used to calculate remote blockings, not in the
   --             analysis itself

   -- New features added (Oct 2000) to Transaction_Data:
   -- Kind_of_event

   -- Changes introduced to Task_Data for version 1.2 (Sep 2001):
   --   Eliminate the independent field. Instead, an independent transaction
   --     is new transaction, with the same Transaction Id, and following
   --     the parent transaction in the array
   -- Changes introduced to Task_Data for version 1.2 (Sep 2002):
   --   Add the Delay fields (Delayijmin, Delayijmax):
   --      They represent an amount to be added to the offset
   --      inherited by task ij from the previous task
   -- Changes introduced to Task_Data for version 1.2 (Sep 2002):
   --   Add the Offset fields (Oijmin, Oijmax):
   --      They represent a minimum and maximum amount of offset to
   --      be used for the task. The actual offset will be the maximum
   --      of the inherited offset and this field.
   --      Used also to account for the delay of rate divisors

   -- Changes introduced to Transaction_Data for version 1.2 (Sep 2001):
   --   Added the Transaction_Id field, because now a transaction may split
   --   accross several cells in the array. Before, the transaction Id
   --   was the index in the array.
   -- Changes introduced to Transaction_Data for version 1.2 (May 2002):
   --    Add the Input type field(Trans_Input_Type):
   --       It represents the type of the input event of the transaction:
   --             External : external event
   --             Internal : internal event coming from an an event handler
   --                        of the type activity, offset, delay,
   --                        or rate divisor
   -- Changes introduced to Transaction_Data for version 1.3.5 (Jan 2004):
   --    Add the following fields:
   --        SDij : Scheduling deadline (not to be confused with Dij, which
   --               is a timing requirement; only used for EDF tasks
   --        Schedij : Kind of scheduler: FP or EDF
   -- Changes introduces to priority assignment variables for version 1.3.5:
   --    Add the following field to the Priority_Assignment_Vars:
   --       Synch_P_Ref : pointer to the synchronization parameters that
   --                     contains the preemption levels


   type Event_Kinds is (Periodic,Sporadic,Bursty,Unbounded);
   -- Reflects the model for analysis, only
   -- Values are:
   --    Periodic : default analysis
   --    Sporadic : special treatment in offset-based methods
   --    Bursty : treated as sporadic
   --    Unbounded: self analysis is not relevant

   type Model_Levels is (Regular, Separate_Analysis,
                         Unbounded_Response, Unbounded_Effects);
   -- Regular:           Own analysis model is the same as model for
   --                    analysis of others
   -- Separate_Analysis: The own analysis model is different than the model
   --                    for the analysis of other tasks. (Cij,Tij) holds the
   --                    values for the other's analysis, while
   --                    (Cijown, Tijown) hold the values for the task's
   --                    own analysis.
   -- Unbounded_Response:Own analysis leads to unbounded response time
   -- Unbounded_Effects: effects on lower priority threads are unbounded

   type Transaction_Input_Type is (External, Internal);
   --  Represents the type of the input event of the transaction:
   --      External : external event
   --      Internal : external event coming from another transaction
   --                 (the one placed immediately before in the array)
   --                 that transaction finishes with an event handler
   --                 of the type activity, offset, delay,
   --                 or rate divisor

   type Virtual_Priority is range 1..2**31-2;
   -- We do not include the value 2**31-1 to force range checking

   Max_Virtual_Priority : constant Virtual_Priority :=
     Virtual_Priority(10*Priority'Last);

   type Sched_Type is (FP, EDF);
   -- kind of scheduler used for this task

   type Priority_Assignment_Vars is record
      Hard_Prio : Boolean:=True;
      -- If TRUE, the object has an unchangeable priority
      S_P_Ref : Scheduling_Parameters.Sched_Parameters_Ref := null;
      -- Added to handle preemption levels
      Synch_P_Ref : Synchronization_Parameters.Synch_Parameters_Ref := null;
      P_R_Ref : Processing_Resources.Processing_Resource_Ref :=null;
      S_Policy_Ref : Scheduling_Policies.Fixed_Priority_Policy_Ref:=null;
      Calculate_Factor : Boolean;  -- Mark to calculate factor
      Factor : Time;
      S : Time;        -- Slack
      Excess : Time;   -- Excess
      D_I : Time;      -- Initial deadline
      D_0 : Time;      -- Actual deadline
      D_1 : Time;      -- Deadline before
      Optimum_Prio : Priority;
      Virtual_Prio : Virtual_Priority;
      Preassigned_Prio : Priority;
      Preassigned  : Boolean:=False;
      Is_Polling : Boolean:=False;
      -- if True, this task is modelling a polling overhead; its priority
      --    is not assigned by the priority assignment tools
   end record;
   -- New type to include priority assignment features

   type Task_Data is record
      Cijown,
      Cbijown    : Time;          -- WCET and BCET for own task's analysis
      Cij,
      Cbij       : Time;          -- WCET and BCET for analysis of other tasks
      Tijown     : Time;          -- Period for own analysis
      Tij        : Time;          -- Period for analysis of other tasks
      Bij        : Time;          -- Blocking
      Dij        : Time;          -- Deadline (timing requirement)
      SDij       : Time;          -- Scheduling deadline (for EDF tasks)
      Schedij    : Sched_Type;    -- FP or EDF scheduling
      Oij        : Time;          -- Activation phase
      Jij        : Time;          -- Calculated Jitter
      Jinit      : Time;          -- Initial Jitter
      Sched_Delay: Time;          -- Scheduling Delay
                                  -- Effect added at response time translation
      Oijmin     : Time;          -- Minimum (static) offset
      Oijmax     : Time;          -- Maximum offset
      Delayijmin : Time;          -- Minimum delay relative to previous task
      Delayijmax : Time;          -- Maximum delay relative to previous task
      Model      : Model_Levels;  -- Modelling level for this task
      Jitter_Avoidance : Boolean; -- Scheduler avoids jitter on lower priority
      Uses_Shared_Resources : Boolean; -- the task uses shared resources
      Rij,Rbij   : Time;          -- Worst and Best case response times
      Prioij     : Priority;      -- Priority
      Procij     : Processor_ID_Type; -- Processor
      Resij      : MAST.Graphs.Link_Ref; -- Link to which
                                         -- results will be attached
      Pav      : Priority_Assignment_Vars;
      -- Assignment of priorities fields
   end record;

   type The_Transaction_Tasks is array
     (Task_ID_Type range 1..Max_Tasks_Per_Transaction) of Task_Data;

   type Transaction_Data is record
      Transaction_Id : Transaction_ID_Type; -- Id of this transaction
      Ti : Time;              -- Transaction period
      Ni : Task_ID_Type:=0;   -- Number of tasks in transaction
                              --   if zero, there are no more
                              --   transactions
      Evi : Events.Event_Ref; -- Pointer to external event
      Kind_Of_Event : Event_Kinds;
      The_Task : The_Transaction_Tasks;  -- Tasks of the transaction
      Trans_Input_Type : Transaction_Input_Type:=External;
   end record;

   type Linear_Transaction_System is array
     (Transaction_ID_Type range 1..Max_Transactions)
     of Transaction_Data;

   procedure Translate_Linear_System
     (The_System : in MAST.Systems.System;
      Transaction : out Linear_Transaction_System;
      Verbose : in Boolean:=False);

   procedure Translate_Linear_Analysis_Results
     (Transaction : in Linear_Transaction_System;
      The_System : in out MAST.Systems.System);

   procedure Translate_Linear_System_With_Results
     (The_System : in MAST.Systems.System;
      Transaction : out Linear_Transaction_System;
      Verbose : in Boolean:=False);

   procedure Translate_Priorities
     (Transaction : in Linear_Transaction_System;
      The_System : in out MAST.Systems.System);


   function Get_Processor_Number
     (The_System : Systems.System;
      A_Proc_Ref : Processing_Resources.Processing_Resource_Ref)
     return Processor_Id_Type;

   function Get_Processor_Name
     (The_System : Systems.System;
      Proc_Number : Processor_Id_Type)
     return String;

   procedure Show_Linear_Translation
     (Transaction : in Linear_Transaction_System);

end Mast.Linear_Translation;
