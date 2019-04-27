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

with Mast.Processing_Resources,
  Mast.HOPA_Parameters,
  Mast.Annealing_Parameters,
  Mast.Linear_Translation,
  Priority_Queues,Hash_Lists,List_Exceptions,
  Mast.Tools.Schedulability_Index,
  Mast.Scheduling_Parameters,
  Mast.Scheduling_Policies;

with Ada.Text_IO,
  Ada.Numerics.Discrete_Random,Ada.Numerics.Float_Random,
  Ada.Numerics.Generic_Elementary_Functions,
  Mast.Max_Numbers;

use type Mast.Tools.Schedulability_Index.Index;
use Ada.Text_IO;


package body Mast.Linear_Priority_Assignment_Tools is

   ATC_Enabled : constant Boolean:=False;
   Debug : constant Boolean := False;
   My_Verbose : constant Boolean := False;

   type Processor_ID is new Natural;
   type Transaction_ID is new Natural;
   type Task_ID is new Natural;


   ----------
   -- HOPA --
   ----------

   procedure Hopa
     (The_System : in out Mast.Systems.System;
      The_Tool: in Mast.Tools.Worst_Case_Analysis_Tool;
      Verbose    : in Boolean:=True) is

      -- If a processing resource has preassigned priorities, or the number
      -- of schedulable entities is higher than the priority levels that
      -- it has, the optimum_priority_assignment procedure will not be applied


      Optimize : Boolean;

      K : Hopa_Parameters.K_Pair;
      Ka, Kr: Hopa_Parameters.K_Type;
      -- Heuristic variables of the algorithm

      Analysis_Stop_Time : Duration := Hopa_Parameters.Get_Analysis_Stop_Time;
      Audsley_Stop_Time : Duration := Hopa_Parameters.Get_Audsley_Stop_Time;

      Max_Iter : Integer; -- Heuristic number of iterations for eack K
      Schedulable, Overall_Schedulable : Boolean:=False;

      Counter_Of_Iterations : Integer:=0;

      Counter_Of_Aborted_Analysis : Integer := 0;
      Counter_Of_Aborted_Audsley : Integer := 0;
      Counter_Of_Audsley : Long_Integer := 0;

      Optimizing : Boolean := False;
      Overiteration : Integer;
      Stop_Algorithm : Boolean;
      Optimum_Sched_Index, Sched_Index :
        Mast.Tools.Schedulability_Index.Index:=
        Mast.Tools.Schedulability_Index.Lower_Index;

      Max_Processors:constant Processor_ID:=Processor_ID
        (Processing_Resources.Lists.Size
         (The_System.Processing_Resources));
      Max_Transactions:constant Transaction_ID:=Transaction_ID
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

      My_System,My_Back_Up_System : Translation.Linear_Transaction_System;

      type List_For_Tasks is array
        (Task_ID_Type range 1..Max_Tasks_Per_Transaction)
        of Translation.Priority_Assignment_Vars;

      type List_For_Transactions is array
        (Transaction_ID_Type range 1..Max_Transactions)
        of List_For_Tasks;

      Pavs : List_For_Transactions;

      Float_Generator : Ada.Numerics.Float_Random.Generator;

      ---------------
      -- Save_Pavs --
      ---------------

      procedure Save_Pavs is
      begin
         for I in Transaction_ID_Type range 1..Max_Transactions
         loop
            for J in Task_ID_Type range 1..Max_Tasks_Per_Transaction
            loop
               Pavs(I)(J) := My_System(I).The_Task(J).Pav;
            end loop;
         end loop;
      end Save_Pavs;

      ------------------
      -- Restore_Pavs --
      ------------------

      procedure Restore_Pavs is
      begin
         for I in Transaction_ID_Type range 1..Max_Transactions
         loop
            for J in Task_ID_Type range 1..Max_Tasks_Per_Transaction
            loop
               My_System(I).The_Task(J).Pav := Pavs(I)(J);
            end loop;
         end loop;
      end Restore_Pavs;

      -------------------------------------
      -- Convert_Deadlines_To_Priorities --
      -------------------------------------

      procedure Convert_Deadlines_To_Priorities is

         Queue_Length :
           array (Processor_ID_Type range 1..Max_Processors) of Natural;

         List_Of_Min_VP :
           array (Processor_ID_Type range 1..Max_Processors) of
           Virtual_Priority;

         List_Of_Min_P :
           array (Processor_ID_Type range 1..Max_Processors) of
           Priority;

         List_Of_Max_P :
           array (Processor_ID_Type range 1..Max_Processors) of
           Priority;

         Optimization_In_Processor :
           array (Processor_ID_Type range 1..Max_Processors) of
           Boolean;

         ---------------------------------------------
         -- Convert_Deadlines_To_Virtual_Priorities --
         ---------------------------------------------

         procedure Convert_Deadlines_To_Virtual_Priorities is

            type Deadline_Element is record
               Transaction : Transaction_Id_Type;
               Action : Task_Id_Type;
            end record;

            package Deadlines_Lists is new Priority_Queues
              (Element => Deadline_Element,
               Priority => Time,
                 ">" => "<",
                 "=" => "=");

            use Deadlines_Lists;

            Lists_For_Processors :
              array (Processor_ID_Type range 1..Max_Processors) of
              Deadlines_Lists.Queue;

            Item : Deadline_Element;
            Next_Priority : Virtual_Priority;
            Deadline : Time;

         begin

            for I in Processor_ID_Type range 1..Max_Processors
            loop
               Optimization_In_Processor(I) := True;
            end loop;

            for I in Transaction_ID_Type range 1..Max_Transactions
            loop
               exit when My_System(I).Ni=0;
               for J in 1..My_System(I).Ni
               loop
                  if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                    not My_System(I).The_Task(J).Pav.Is_Polling then
                     Item := (Transaction => I,
                              Action => J);
                     Deadlines_Lists.Enqueue
                       (Item,
                        My_System(I).The_Task(J).Pav.D_0,
                        Lists_For_Processors(My_System(I).The_Task(J).Procij));
                  end if;
               end loop;
            end loop;

            for I in Processor_ID_Type range 1..Max_Processors
            loop
               declare
                  J : Integer := 0;
                  Background_Priority : Priority:= Priority'First;
               begin
                  while not Deadlines_Lists.Empty(Lists_For_Processors(I))
                  loop
                     J := J+1;
                     Deadlines_Lists.Dequeue
                       (Item,Deadline,Lists_For_Processors(I));
                     if J=1 then
                        Next_Priority := Max_Virtual_Priority;
                     else
                        Next_Priority := Virtual_Priority'Pred(Next_Priority);
                     end if;
                     My_System(Item.Transaction).
                       The_Task(Item.Action).Pav.Virtual_Prio := Next_Priority;
                     if Debug then
                        Put(" Next_VP = "&
                            Virtual_Priority'Image(Next_Priority));
                        Put(" with Deadline = "&
                            Time'Image(Deadline));
                        Put(" at the position "&Integer'Image(J));
                        Put_Line(" Preasssigned="&Boolean'Image
                                 (My_System(Item.Transaction).The_Task
                                  (Item.Action).Pav.Preassigned));
                     end if;
                     if My_System(Item.Transaction).The_Task(Item.Action).
                       Pav.Preassigned then
                        -- Check if the optimum priority assigment will be
                        -- performed for this processor
                        Optimization_In_Processor(I) := False;
                     end if;
                     if My_System(Item.Transaction).The_Task(Item.Action).
                       Pav.S_P_Ref.all in
                       Scheduling_Parameters.Sporadic_Server_Policy'Class
                     then
                        begin
                           if Background_Priority <=
                             Mast.Scheduling_Parameters.
                             Background_Priority
                             (Mast.Scheduling_Parameters.
                              Sporadic_Server_Policy
                              (My_System(Item.Transaction).
                               The_Task(Item.Action).Pav.S_P_Ref.all))
                           then
                              Background_Priority :=
                                Mast.Scheduling_Parameters.
                                Background_Priority
                                (Mast.Scheduling_Parameters.
                                 Sporadic_Server_Policy
                                 (My_System(Item.Transaction).
                                  The_Task(Item.Action).Pav.S_P_Ref.all))+1;
                           end if;
                        exception
                           when Constraint_Error =>
                              Background_Priority :=
                                Mast.Scheduling_Parameters.
                                Background_Priority
                                (Mast.Scheduling_Parameters.
                                 Sporadic_Server_Policy
                                 (My_System(Item.Transaction).
                                  The_Task(Item.Action).Pav.S_P_Ref.all));
                        end;
                     end if;
                  end loop;
                  Queue_Length(I) := J;
                  -- Store the number of task per processor for optimizing
                  -- priority assignment
                  List_Of_Min_VP(I) := Next_Priority;
                  -- Store the minimum virtual priority assigned for each
                  -- processor
                  if Background_Priority > Scheduling_Policies.Min_Priority
                    (My_System(Item.Transaction).The_Task(Item.Action).
                     Pav.S_Policy_Ref.all)
                  then
                     List_Of_Min_P(I) := Background_Priority;
                  else
                     List_Of_Min_P(I) := Scheduling_Policies.Min_Priority
                       (My_System(Item.Transaction).The_Task(Item.Action).
                        Pav.S_Policy_Ref.all);
                  end if;
                  -- Store the minimum priority for each processor
                  List_Of_Max_P(I) := Scheduling_Policies.Max_Priority
                    (My_System(Item.Transaction).The_Task(Item.Action).
                     Pav.S_Policy_Ref.all);
                  -- Store the maximum priority for each processor
                  if J > Integer (List_Of_Max_P(I)-List_Of_Min_P(I)+1)
                  then
                     -- Check if the optimum priority assigment will be
                     -- performed for this processor
                     Optimization_In_Processor(I) := False;
                  end if;
               end;
            end loop;

         end Convert_Deadlines_To_Virtual_Priorities;

         ----------------------
         -- Priority_Mapping --
         ----------------------

         procedure Priority_Mapping is

            type Priority_Element is record
               Transaction : Transaction_Id_Type;
               Action : Task_Id_Type;
            end record;

            package VP_Lists is new Priority_Queues
              (Element => Priority_Element,
               Priority => Virtual_Priority,
                 ">" => ">",
                 "=" => "=");

            use VP_Lists;

            package P_Lists is new Priority_Queues
              (Element => Priority_Element,
               Priority => Priority,
                 ">" => ">",
                 "=" => "=");

            use P_Lists;

            Lists_For_VP :
              array (Processor_ID_Type range 1..Max_Processors) of
              VP_Lists.Queue;
            Lists_For_P :
              array (Processor_ID_Type range 1..Max_Processors) of
              P_Lists.Queue;

            Item1, Item2 : Priority_Element;
            Max_P, Min_P : Priority;
            Max_VP, Min_VP, VP : Virtual_Priority;

         begin

            for I in Transaction_ID_Type range 1..Max_Transactions
            loop
               exit when My_System(I).Ni=0;
               for J in 1..My_System(I).Ni
               loop
                  Item1 := (Transaction => I,
                            Action => J);
                  if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                    not My_System(I).The_Task(J).Pav.Is_Polling then
                     if  My_System(I).The_Task(J).Pav.Preassigned then
                        P_Lists.Enqueue
                          (Item1,
                           My_System(I).The_Task(J).Pav.Preassigned_Prio,
                           Lists_For_P(My_System(I).The_Task(J).Procij));
                     else
                        VP_Lists.Enqueue
                          (Item1,
                           My_System(I).The_Task(J).Pav.Virtual_Prio,
                           Lists_For_VP(My_System(I).The_Task(J).Procij));
                     end if;
                  end if;
               end loop;
            end loop;

            for I in Processor_ID_Type range 1..Max_Processors
            loop
               Min_P := List_Of_Max_P(I);
               Min_VP := Max_Virtual_Priority;
               -- Set minumum priorities to maximum values
               while not VP_Lists.Empty(Lists_For_VP(I))
               loop
                  VP_Lists.Dequeue(Item2,VP,Lists_For_VP(I));
                  if VP <= Min_VP then
                     -- New stage
                     Max_P := Min_P;
                     Max_VP := Min_VP;
                     loop
                        if not P_Lists.Empty(Lists_For_P(I)) then
                           P_Lists.Dequeue(Item1,Min_P,Lists_For_P(I));
                           Min_P := Priority'Max(Min_P,List_Of_Min_P(I));
                           Min_VP :=
                             My_System(Item1.Transaction).
                             The_Task(Item1.Action).Pav.Virtual_Prio;
                           if VP > Min_VP then
                              exit;
                           end if;
                        else
                           Min_P := List_Of_Min_P(I);
                           Min_VP := List_Of_Min_VP(I);
                           exit;
                        end if;
                     end loop;
                  end if;
                  if Debug then
                     Put("   VP = "&Virtual_Priority'Image(VP));
                     Put("   Max_P = "&Priority'Image(Max_P));
                     Put("   Min_P = "&Priority'Image(Min_P));
                     Put("   Max_VP = "&Virtual_Priority'Image(Max_VP));
                     Put_Line("   Min_VP = "&Virtual_Priority'Image(Min_VP));
                  end if;

                  My_System(Item2.Transaction).The_Task(Item2.Action).Prioij :=
                    Priority
                    (Long_Float'Floor
                     ((Long_Float(VP)-Long_Float(Min_VP))/
                      (Long_Float(Max_VP)-Long_Float(Min_VP)+1.0)*
                      (Long_Float(Max_P)-Long_Float(Min_P)+1.0)+
                      Long_Float(Min_P)));

                  if Debug then
                     Put_Line("   Priority Assigned = "&
                              Priority'Image
                              (My_System(Item2.Transaction).
                               The_Task(Item2.Action).Prioij));
                  end if;

               end loop;
            end loop;

         end Priority_Mapping;

         ---------------------------------
         -- Optimum_Priority_Assignment --
         ---------------------------------

         procedure Optimum_Priority_Assignment is

            type Deadline_Element is record
               Transaction : Transaction_Id_Type;
               Action : Task_Id_Type;
            end record;

            Item : Deadline_Element;

         begin

            for K in Processor_ID_Type range 1..Max_Processors
            loop
               if Optimization_In_Processor(K) then
                  declare
                     type Lists_Of_Task is
                       array(Integer range 1..Queue_Length(K))of
                       Deadline_Element;
                     List_Of_Task : Lists_Of_Task;
                     Num_Of_Task : Integer := 0;
                     Prio : Priority;
                     Failed : Boolean;
                     Aborted : Boolean := False;
                  begin
                     -- Extract the tasks
                     for I in Transaction_Id_Type range 1..Max_Transactions
                     loop
                        exit when My_System(I).Ni=0;
                        for J in 1..My_System(I).Ni
                        loop
                           if (My_System(I).The_Task(J).Procij = K) and then
                             not My_System(I).The_Task(J).Pav.Hard_Prio
                             and then
                             not My_System(I).The_Task(J).Pav.Is_Polling then
                              Num_Of_Task := Num_Of_Task+1;
                              List_Of_Task(Num_Of_Task).Transaction := I;
                              List_Of_Task(Num_Of_Task).Action := J;
                           end if;
                        end loop;
                     end loop;

                     if Debug then
                        Put_Line("Initial priorities.....");
                        for I in 1..Num_Of_Task
                        loop
                           Put("trans : "&Transaction_Id_Type'Image
                               (List_Of_Task(I).Transaction));
                           Put("task : "&Task_Id_Type'Image
                               (List_Of_Task(I).Action));
                           Put("   deadline = "&Time'Image
                               (My_System(List_Of_Task(I).Transaction).
                                The_Task(List_Of_Task(I).Action).Dij));
                           Put_Line("   prioridad = "&Priority'Image
                                    (My_System(List_Of_Task(I).Transaction).
                                     The_Task(List_Of_Task(I).Action).Prioij));
                        end loop;
                        New_Line;
                     end if;

                     -- Order the tasks
                     for I in 2..(Num_Of_Task)
                     loop
                        for J in reverse I..(Num_Of_Task)
                        loop
                           if My_System(List_Of_Task(J).Transaction).
                             The_Task(List_Of_Task(J).Action).Prioij >
                             My_System(List_Of_Task(J-1).Transaction).
                             The_Task(List_Of_Task(J-1).Action).Prioij then
                              Item := List_Of_Task(J);
                              List_Of_Task(J) := List_Of_Task(J-1);
                              List_Of_Task(J-1) := Item;
                           end if;
                        end loop;
                     end loop;

                     if Debug then
                        Put_Line("Ordered priorities.....");
                        for I in 1..Num_Of_Task
                        loop
                           Put("trans : "&Transaction_Id_Type'Image
                               (List_Of_Task(I).Transaction));
                           Put("task : "&Task_Id_Type'Image
                               (List_Of_Task(I).Action));
                           Put("   deadline = "&Time'Image
                               (My_System(List_Of_Task(I).Transaction).
                                The_Task(List_Of_Task(I).Action).Dij));
                           Put_Line("   prioridad = "&Priority'Image
                                    (My_System(List_Of_Task(I).Transaction).
                                     The_Task(List_Of_Task(I).Action).Prioij));
                        end loop;
                        New_Line;
                     end if;

                     -- Apply the priority assignment algorithm
                     for I in reverse 2..Num_Of_Task
                     loop
                        Failed := True;
                        for J in reverse 1..I
                        loop
                           -- Exchange tasks I and J and their priorities
                           Item := List_Of_Task(I);
                           List_Of_Task(I) := List_Of_Task(J);
                           List_Of_Task(J) := Item;
                           Prio := My_System(List_Of_Task(I).Transaction).
                             The_Task(List_Of_Task(I).Action).Prioij;
                           My_System(List_Of_Task(I).Transaction).
                             The_Task(List_Of_Task(I).Action).Prioij :=
                             My_System(List_Of_Task(J).Transaction).
                             The_Task(List_Of_Task(J).Action).Prioij;
                           My_System(List_Of_Task(J).Transaction).
                             The_Task(List_Of_Task(J).Action).Prioij := Prio;

                           if Debug then
                              Put_Line("Changing priorities.....");
                              for L in 1..Num_Of_Task
                              loop
                                 Put("trans : "&Transaction_Id_Type'Image
                                     (List_Of_Task(L).Transaction));
                                 Put("task : "&Task_Id_Type'Image
                                     (List_Of_Task(L).Action));
                                 Put("   deadline = "&Time'Image
                                     (My_System(List_Of_Task(L).Transaction).
                                      The_Task(List_Of_Task(L).Action).Dij));
                                 Put_Line("   prioridad = "&Priority'Image
                                          (My_System(List_Of_Task(L).
                                                     Transaction).
                                           The_Task(List_Of_Task(L).Action).
                                           Prioij));
                              end loop;
                              New_Line;
                           end if;

                           Translation.Translate_Priorities
                             (My_System,The_System);
                           Save_Pavs;

                           -- Check if task I is schedulable

                           Mast.Tools.Calculate_Ceilings_And_Levels
                             (The_System,My_Verbose);
                           My_Back_Up_System := My_System;
                           Counter_Of_Audsley :=
                             Long_Integer'Succ(Counter_Of_Audsley);
                           if ATC_Enabled then
                              select
                                 delay Audsley_Stop_Time;
                                 My_System := My_Back_Up_System;
                                 Aborted := True;
                                 Counter_Of_Aborted_Audsley :=
                                   Integer'Succ(Counter_Of_Aborted_Audsley);
                              then abort
                                 The_Tool(The_System,My_Verbose);
                              end select;
                           else
                              Aborted:=False;
                              The_Tool(The_System,My_Verbose);
                           end if;
                           if not Aborted then
                              Translation.Translate_Linear_System_With_Results
                                (The_System,My_System,My_Verbose);
                              Restore_Pavs;
                           end if;

                           if not Aborted and then
                             (My_System(List_Of_Task(I).Transaction).
                             The_Task(List_Of_Task(I).Action).Pav.D_0 >=
                             My_System(List_Of_Task(I).Transaction).
                               The_Task(List_Of_Task(I).Action).Rij) then
                              Failed := False;
                              exit;
                           else
                              -- Exchange tasks I and J and their
                              -- old priorities
                              Item := List_Of_Task(I);
                              List_Of_Task(I) := List_Of_Task(J);
                              List_Of_Task(J) := Item;
                              Prio := My_System(List_Of_Task(I).Transaction).
                                The_Task(List_Of_Task(I).Action).Prioij;
                              My_System(List_Of_Task(I).Transaction).
                                The_Task(List_Of_Task(I).Action).Prioij :=
                                My_System(List_Of_Task(J).Transaction).
                                The_Task(List_Of_Task(J).Action).Prioij;
                              My_System(List_Of_Task(J).Transaction).
                                The_Task(List_Of_Task(J).Action).Prioij :=
                                Prio;
                              Translation.Translate_Priorities
                                (My_System,The_System);
                              Save_Pavs;
                              exit when Aborted;

                              if Debug then
                                 Put_Line("Returning to old priorities....");
                                 for L in 1..Num_Of_Task
                                 loop
                                    Put("trans : "&Transaction_Id_Type'Image
                                        (List_Of_Task(L).Transaction));
                                    Put("task : "&Task_Id_Type'Image
                                        (List_Of_Task(L).Action));
                                    Put("   deadline = "&Time'Image
                                        (My_System(List_Of_Task(L).
                                                   Transaction).
                                         The_Task(List_Of_Task(L).
                                                  Action).Dij));
                                    Put_Line("   prioridad = "&Priority'Image
                                             (My_System(List_Of_Task(L).
                                                        Transaction).
                                              The_Task(List_Of_Task(L).Action).
                                              Prioij));
                                 end loop;
                                 New_Line;
                              end if;

                           end if;
                        end loop;
                        exit when Failed;
                     end loop;

                     if Debug then
                        Put_Line("Final assignment....");
                        for I in 1..Num_Of_Task
                        loop
                           Put("trans : "&Transaction_Id_Type'Image
                               (List_Of_Task(I).Transaction));
                           Put("   deadline = "&Time'Image
                               (My_System(List_Of_Task(I).Transaction).
                                The_Task(List_Of_Task(I).Action).Dij));
                           Put_Line("   prioridad = "&Priority'Image
                                    (My_System(List_Of_Task(I).Transaction).
                                     The_Task(List_Of_Task(I).Action).Prioij));
                        end loop;
                        New_Line;
                     end if;

                  end;
               end if;
            end loop;

         end Optimum_Priority_Assignment;


      begin

         Convert_Deadlines_To_Virtual_Priorities;

         Priority_Mapping;

         if Audsley_Stop_Time /= 0.0 then
            Optimum_Priority_Assignment;
         end if;
         -- This procedure is not called for eficiency reasons. It implements
         -- Ausley's algorithm for monoprocesors and calls the analysis
         -- tools several times (proportional to the size of the system).
         -- If we have a case where the analysis tool runs slow, the priority
         -- assignment algorithm can take too much time.
         -- In spite of this, we keep on implementing it because in some cases
         -- the algorithm can find better solutions.

      end Convert_Deadlines_To_Priorities;

      ---------------------------
      -- Initialize_Priorities --
      ---------------------------

      procedure Initialize_Priorities is

         -- Initialize priorities according to WCETs

         Max_Factor : constant Time := Large_Time;
         Max_D,Sum_C,Assigned_D,Factor : Time;

      begin
         Translation.Translate_Linear_System(The_System,My_System,My_Verbose);

         -- Save Preassigned_Prio

         for I in Transaction_Id_Type range 1..Max_Transactions
         loop
            exit when My_System(I).Ni=0;
            for J in 1..My_System(I).Ni
            loop
               My_System(I).The_Task(J).Pav.Preassigned_Prio :=
                 My_System(I).The_Task(J).Prioij;
            end loop;
         end loop;

         -- Deadline assignment

         declare
            I : Transaction_Id_Type;
            Extra : Transaction_Id_Type;
            -- Number of extra consecutive transactions with the same ID
         begin

            I := 1;
            while My_System(I).Ni/=0
            loop

               -- Calculate Extra
               Extra := 0;
               for J in Transaction_Id_Type range (I+1)..Max_Transactions
               loop
                  exit when My_System(J).Transaction_Id /=
                    My_System(I).Transaction_Id;
                  Extra := Extra+1;
               end loop;

               Max_D := Large_Time;
               for K in reverse 0..Extra
               loop
                  for J in reverse 1..My_System(I+K).Ni
                  loop
                     -- Mark the actions with deadlines to calculate factors
                     if not My_System(I+K).The_Task(J).Pav.Hard_Prio and then
                       not My_System(I).The_Task(J).Pav.Is_Polling then
                        if My_System(I+K).The_Task(J).Dij /= Large_Time and
                          My_System(I+K).The_Task(J).Dij < Max_D then
                           My_System(I+K).The_Task(J).Pav.Calculate_Factor :=
                             True;
                           My_System(I+K).The_Task(J).Pav.D_0 :=
                             My_System(I+K).The_Task(J).Dij;
                           My_System(I+K).The_Task(J).Pav.D_I :=
                             My_System(I+K).The_Task(J).Dij;
                           Max_D := My_System(I+K).The_Task(J).Dij;
                        else
                           My_System(I+K).The_Task(J).Pav.Calculate_Factor :=
                             False;
                           My_System(I+K).The_Task(J).Pav.D_0 :=
                             Large_Time;
                           My_System(I+K).The_Task(J).Pav.D_I :=
                             Large_Time;
                        end if;
                     end if;
                  end loop;
               end loop;

               Sum_C := 0.0;
               Assigned_D := 0.0;
               for K in 0..Extra
               loop
                  for J in 1..My_System(I+K).Ni
                  loop
                     -- Calculate factors
                     if not My_System(I+K).The_Task(J).Pav.Hard_Prio and then
                       not My_System(I).The_Task(J).Pav.Is_Polling then
                        Sum_C := Sum_C+My_System(I+K).The_Task(J).Cijown;
                        if My_System(I+K).The_Task(J).Pav.Calculate_Factor then
                           My_System(I+K).The_Task(J).Pav.Factor :=
                             (My_System(I+K).The_Task(J).Pav.D_0-Assigned_D)/
                             Sum_C;
                           Sum_C := 0.0;
                           Assigned_D := My_System(I+K).The_Task(J).Pav.D_0;
                        else
                           My_System(I+K).The_Task(J).Pav.Factor := 1.0;
                        end if;
                     end if;
                  end loop;
               end loop;

               Factor := Max_Factor;
               for K in reverse 0..Extra
               loop
                  for J in reverse 1..My_System(I+K).Ni
                  loop
                     -- Calculate deadlines
                     if not My_System(I+K).The_Task(J).Pav.Hard_Prio and then
                       not My_System(I).The_Task(J).Pav.Is_Polling then
                        if My_System(I+K).The_Task(J).Pav.Calculate_Factor then
                           Factor := My_System(I+K).The_Task(J).Pav.Factor;
                        end if;
                        if Factor = Max_Factor then
                           My_System(I+K).The_Task(J).Pav.D_0 := Large_Time;
                        else
                           My_System(I+K).The_Task(J).Pav.D_0 :=
                             My_System(I+K).The_Task(J).Cijown*Factor;
                        end if;
                     end if;
                  end loop;
               end loop;
               exit when (I+Extra+1) not in Transaction_Id_Type;
               I := I+Extra+1;

            end loop;
         end;

         -- Priority assignment

         Convert_Deadlines_To_Priorities;

         Translation.Translate_Priorities(My_System,The_System);

         Save_Pavs;

      end Initialize_Priorities;

      ---------------------------
      -- Assign_New_Priorities --
      ---------------------------

      procedure Assign_New_Priorities is

         -- Assignes priorities according to local deadlines calculated

         type Excess_Type is record
            Excess : Time := 0.0;
            Less, Plus : Time := 0.0;
         end record;

         Excess_For_Processors : array (Processor_ID_Type) of
           Excess_Type;
         Max_Excess_For_Events : array (Transaction_ID_Type) of
           Excess_Type;
         Max_Excess_For_Processors : Time := 0.0;

         Sum_D,Assigned_D,Factor : Time;


      begin

         Translation.Translate_Linear_System_With_Results
           (The_System,My_System,My_Verbose);
         Restore_Pavs;

         -- Excesses for actions

         declare
            I : Transaction_Id_Type;
            Extra : Transaction_Id_Type;
            -- Number of extra consecutive transactions with the same ID
         begin

            I := 1;
            while My_System(I).Ni/=0
            loop

               -- Calculate Extra
               Extra := 0;
               for J in Transaction_Id_Type range (I+1)..Max_Transactions
               loop
                  exit when My_System(J).Transaction_Id /=
                    My_System(I).Transaction_Id;
                  Extra := Extra+1;
               end loop;

               Assigned_D := 0.0;
               for K in 0..Extra
               loop
                  for J in 1..My_System(I+K).Ni
                  loop
                     -- Calculate factors
                     if My_System(I+K).The_Task(J).Pav.Calculate_Factor then
                        My_System(I+K).The_Task(J).Pav.Factor :=
                          My_System(I+K).The_Task(J).Rij/
                          (My_System(I+K).The_Task(J).Pav.D_I-Assigned_D);
                        Assigned_D := My_System(I+K).The_Task(J).Pav.D_I;
                     end if;
                  end loop;
               end loop;

               Factor := 1.0;
               for K in reverse 0..Extra
               loop
                  for J in reverse 1..My_System(I+K).Ni
                  loop
                     -- Calculate excesses
                     if not My_System(I+K).The_Task(J).Pav.Hard_Prio and then
                       not My_System(I).The_Task(J).Pav.Is_Polling then
                        if My_System(I+K).The_Task(J).Pav.Calculate_Factor then
                           Factor := My_System(I+K).The_Task(J).Pav.Factor;
                        end if;
                        My_System(I+K).The_Task(J).Pav.Excess :=
                          (My_System(I+K).The_Task(J).Rij-
                           My_System(I+K).The_Task(J).Pav.D_0)*Factor;
                     end if;
                  end loop;
               end loop;
               exit when (I+Extra+1) not in Transaction_Id_Type;
               I := I+Extra+1;
            end loop;
         end;

         -- Maximum excesses for events and processing resources

         declare
            I, T_Id : Transaction_Id_Type;
            Extra : Transaction_Id_Type;
            -- Number of extra consecutive transactions with the same ID
         begin

            I := 1;
            while My_System(I).Ni/=0
            loop

               -- Calculate Extra
               Extra := 0;
               for J in Transaction_Id_Type range (I+1)..Max_Transactions
               loop
                  exit when My_System(J).Transaction_Id /=
                    My_System(I).Transaction_Id;
                  Extra := Extra+1;
               end loop;
               T_Id := My_System(I).Transaction_Id;
               for K in 0..Extra
               loop
                  for J in 1..My_System(I+K).Ni
                  loop
                     if not My_System(I+K).The_Task(J).Pav.Hard_Prio and then
                       not My_System(I).The_Task(J).Pav.Is_Polling then
                        if My_System(I+K).The_Task(J).Pav.Excess > 0.0 then
                           Excess_For_Processors
                             (My_System(I+K).The_Task(J).Procij).Plus :=
                             Excess_For_Processors
                             (My_System(I+K).The_Task(J).Procij).Plus+
                             My_System(I+K).The_Task(J).Pav.Excess;
                           Max_Excess_For_Events(T_Id).Plus :=
                             Max_Excess_For_Events(T_Id).Plus+
                             My_System(I+K).The_Task(J).Pav.Excess;
                        else
                           Excess_For_Processors
                             (My_System(I+K).The_Task(J).Procij).Less :=
                             Excess_For_Processors
                             (My_System(I+K).The_Task(J).Procij).Less+
                             My_System(I+K).The_Task(J).Pav.Excess;
                           Max_Excess_For_Events(T_Id).Less :=
                             Max_Excess_For_Events(T_Id).Less+
                             My_System(I+K).The_Task(J).Pav.Excess;
                        end if;
                     end if;
                  end loop;
               end loop;

               if False then
                  Put("T_ID : "&Transaction_Id_Type'Image(T_Id));
                  Put("Less : "&Time'Image
                      (Max_Excess_For_Events(T_Id).Less));
                  Put_Line("Plus : "&Time'Image
                      (Max_Excess_For_Events(T_Id).Plus));
               end if;

               Max_Excess_For_Events(T_Id).Excess :=
                 Max_Excess_For_Events(T_Id).Plus+
                 Max_Excess_For_Events(T_Id).Less;
               exit when (I+Extra+1) not in Transaction_Id_Type;
               I := I+Extra+1;

            end loop;
         end;

         for I in Processor_Id_Type range 1..Max_Processors
         loop
            Excess_For_Processors(I).Excess := Excess_For_Processors(I).Plus+
              Excess_For_Processors(I).Less;
            if abs(Excess_For_Processors(I).Excess) >
              Max_Excess_For_Processors then
               Max_Excess_For_Processors :=
                 abs(Excess_For_Processors(I).Excess);
            end if;
         end loop;

         -- Deadline assignment

         for I in Transaction_Id_Type range 1..Max_Transactions
         loop
            exit when My_System(I).Ni=0;
            declare
               T_Id : Transaction_Id_Type;
            begin
               T_Id :=My_System(I).Transaction_Id;
               for J in 1..My_System(I).Ni
               loop
                  if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                    not My_System(I).The_Task(J).Pav.Is_Polling then
                     if My_System(I).The_Task(J).Pav.D_0 /= Large_Time then
                        My_System(I).The_Task(J).Pav.D_0 :=
                          My_System(I).The_Task(J).Pav.D_0*
                          (1.0+
                           Excess_For_Processors
                           (My_System(I).The_Task(J).Procij).Excess/
                           (Time(Kr)*Max_Excess_For_Processors))*
                          (1.0+
                           My_System(I).The_Task(J).Pav.Excess/
                           (Time(Ka)*Max_Excess_For_Events(T_Id).Excess));
                     end if;
                  end if;
               end loop;
            end;
         end loop;

         -- Adjustment of assigned deadlines to real deadlines

         declare
            I : Transaction_Id_Type;
            Extra : Transaction_Id_Type;
            -- Number of extra consecutive transactions with the same ID
         begin

            I := 1;
            while My_System(I).Ni/=0
            loop

               -- Calculate Extra
               Extra := 0;
               for J in Transaction_Id_Type range (I+1)..Max_Transactions
               loop
                  exit when My_System(J).Transaction_Id /=
                    My_System(I).Transaction_Id;
                  Extra := Extra+1;
               end loop;

               Assigned_D := 0.0;
               Sum_D := 0.0;
               for K in 0..Extra
               loop
                  for J in 1..My_System(I+K).Ni
                  loop
                     -- Calculate factors
                     if not My_System(I+K).The_Task(J).Pav.Hard_Prio and then
                       not My_System(I).The_Task(J).Pav.Is_Polling then
                        Sum_D := Sum_D+My_System(I+K).The_Task(J).Pav.D_0;
                        if My_System(I+K).The_Task(J).Pav.Calculate_Factor then
                           My_System(I+K).The_Task(J).Pav.Factor :=
                             My_System(I+K).The_Task(J).Pav.D_I/Sum_D;
                           Sum_D := 0.0;
                           Assigned_D := My_System(I+K).The_Task(J).Pav.D_I;
                        end if;
                     end if;
                  end loop;
               end loop;

               Factor := 1.0;
               for K in reverse 0..Extra
               loop
                  for J in reverse 1..My_System(I+K).Ni
                  loop
                     -- Adjust deadlines
                     if not My_System(I+K).The_Task(J).Pav.Hard_Prio and then
                       not My_System(I).The_Task(J).Pav.Is_Polling then
                        if My_System(I+K).The_Task(J).Pav.Calculate_Factor then
                           Factor := My_System(I+K).The_Task(J).Pav.Factor;
                        end if;
                        My_System(I+K).The_Task(J).Pav.D_0 :=
                          My_System(I+K).The_Task(J).Pav.D_0*Factor;
                     end if;
                  end loop;
               end loop;
               exit when (I+Extra+1) not in Transaction_Id_Type;
               I := I+Extra+1;
            end loop;
         end;

         -- Priority assignment

         Convert_Deadlines_To_Priorities;

         Translation.Translate_Priorities(My_System,The_System);

         Save_Pavs;

      end Assign_New_Priorities;

      ---------------------------------------------
      -- Assign_New_Priorities_Shaking_Deadlines --
      ---------------------------------------------

      procedure Assign_New_Priorities_Shaking_Deadlines is

         Sum_D,Assigned_D,Factor : Time;

         I : Transaction_Id_Type;
         Extra : Transaction_Id_Type;
         -- Number of extra consecutive transactions with the same ID

      begin

         Restore_Pavs;

         -- Shake deadlines

         for I in Transaction_Id_Type range 1..Max_Transactions
         loop
            exit when My_System(I).Ni=0;
            declare
               T_Id : Transaction_Id_Type;
            begin
               T_Id :=My_System(I).Transaction_Id;
               for J in 1..My_System(I).Ni
               loop
                  if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                    not My_System(I).The_Task(J).Pav.Is_Polling then
                     if My_System(I).The_Task(J).Pav.D_0 /= Large_Time then
                        My_System(I).The_Task(J).Pav.D_0 :=
                          My_System(I).The_Task(J).Pav.D_0*Time
                          (Ada.Numerics.Float_Random.Random(Float_Generator));
                     end if;
                  end if;
               end loop;
            end;
         end loop;

         -- Adjustment of assigned deadlines to real deadlines

         I := 1;
         while My_System(I).Ni/=0
         loop

            -- Calculate Extra
            Extra := 0;
            for J in Transaction_Id_Type range (I+1)..Max_Transactions
            loop
               exit when My_System(J).Transaction_Id /=
                 My_System(I).Transaction_Id;
               Extra := Extra+1;
            end loop;

            Assigned_D := 0.0;
            Sum_D := 0.0;
            for K in 0..Extra
            loop
               for J in 1..My_System(I+K).Ni
               loop
                  -- Calculate factors
                  if not My_System(I+K).The_Task(J).Pav.Hard_Prio and then
                    not My_System(I).The_Task(J).Pav.Is_Polling then
                     Sum_D := Sum_D+My_System(I+K).The_Task(J).Pav.D_0;
                     if My_System(I+K).The_Task(J).Pav.Calculate_Factor then
                        My_System(I+K).The_Task(J).Pav.Factor :=
                          My_System(I+K).The_Task(J).Pav.D_I/Sum_D;
                        Sum_D := 0.0;
                        Assigned_D := My_System(I+K).The_Task(J).Pav.D_I;
                     end if;
                  end if;
               end loop;
            end loop;

            Factor := 1.0;
            for K in reverse 0..Extra
            loop
               for J in reverse 1..My_System(I+K).Ni
               loop
                  -- Adjust deadlines
                  if not My_System(I+K).The_Task(J).Pav.Hard_Prio and then
                    not My_System(I).The_Task(J).Pav.Is_Polling then
                     if My_System(I+K).The_Task(J).Pav.Calculate_Factor then
                        Factor := My_System(I+K).The_Task(J).Pav.Factor;
                     end if;
                     My_System(I+K).The_Task(J).Pav.D_0 :=
                       My_System(I+K).The_Task(J).Pav.D_0*Factor;
                  end if;
               end loop;
            end loop;
            exit when (I+Extra+1) not in Transaction_Id_Type;
            I := I+Extra+1;
         end loop;

         -- Priority assignment

         Convert_Deadlines_To_Priorities;

         Translation.Translate_Priorities(My_System,The_System);

         Save_Pavs;

      end Assign_New_Priorities_Shaking_Deadlines;

      -----------------------------
      -- Save_Optimum_Priorities --
      -----------------------------

      procedure Save_Optimum_Priorities is

      begin
         Mast.Tools.Schedulability_Index.Calculate_Schedulability_Index
           (The_System,Sched_Index,Verbose);
         if Sched_Index > Optimum_Sched_Index then
            Optimum_Sched_Index := Sched_Index;
            if Verbose then
               Put("Saving optimum priority assignment with "&
                   "schedulability index : ");
               Mast.Tools.Schedulability_Index.Print(Optimum_Sched_Index);
            end if;
            for I in Transaction_Id_Type range 1..Max_Transactions
            loop
               exit when My_System(I).Ni=0;
               for J in 1..My_System(I).Ni
               loop
                  if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                    not My_System(I).The_Task(J).Pav.Is_Polling then
                     My_System(I).The_Task(J).Pav.Optimum_Prio :=
                       My_System(I).The_Task(J).Prioij;
                     Pavs(I)(J).Optimum_Prio :=
                       My_System(I).The_Task(J).Prioij;
                  end if;
               end loop;
            end loop;
         end if;

      exception
         when Mast.Tools.Schedulability_Index.Inconclusive =>
            null;

      end Save_Optimum_Priorities;

      --------------------------------
      -- Restore_Optimum_Priorities --
      --------------------------------

      procedure Restore_Optimum_Priorities is

      begin
         if Overall_Schedulable then
            if Verbose then
               Put("Restoring optimum priority assignment with "&
                   "schedulability index : ");
               Mast.Tools.Schedulability_Index.Print(Optimum_Sched_Index);
            end if;
            for I in Transaction_Id_Type range 1..Max_Transactions
            loop
               exit when My_System(I).Ni=0;
               for J in 1..My_System(I).Ni
               loop
                  if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                    not My_System(I).The_Task(J).Pav.Is_Polling then
                     My_System(I).The_Task(J).Prioij :=
                       My_System(I).The_Task(J).Pav.Optimum_Prio;
                  end if;
               end loop;
            end loop;
            Translation.Translate_Priorities(My_System,The_System);
         else
            for I in Transaction_Id_Type range 1..Max_Transactions
            loop
               exit when My_System(I).Ni=0;
               for J in 1..My_System(I).Ni
               loop
                  My_System(I).The_Task(J).Prioij :=
                    My_System(I).The_Task(J).Pav.Preassigned_Prio;
               end loop;
            end loop;
            Translation.Translate_Priorities(My_System,The_System);
         end if;
      end Restore_Optimum_Priorities;

      --------------------
      -- Stop_Condition --
      --------------------

      function Stop_Condition return Boolean is

      begin
         if Optimize then
            if Schedulable then
               Save_Optimum_Priorities;
               Overall_Schedulable := True;
               if not Optimizing then
                  Optimizing := True;
               else
                  Overiteration := Overiteration-1;
                  if Overiteration <= 0 then
                     return True;
                  end if;
               end if;
            else
               if Optimizing then
                  Overiteration := Overiteration-1;
                  if Overiteration <= 0 then
                     return True;
                  end if;
               end if;
            end if;
         else
            if Schedulable then
               Save_Optimum_Priorities;
               Overall_Schedulable := True;
               return True;
            end if;
         end if;
         if (Float(Counter_Of_Aborted_Analysis)/
             Float(Counter_Of_Iterations)) > 0.5 then
            return True;
         end if;
         return False;
      end Stop_Condition;


   begin
      Ada.Numerics.Float_Random.Reset(Float_Generator);

      Overiteration := HOPA_Parameters.Get_Overiterations;
      Optimize := (HOPA_Parameters.Get_Overiterations /= 0);

      Initialize_Priorities;
      -- Initial values according to deadline monotonic

      HOPA_Parameters.Rewind_Iterations_List;

      for I in 1..HOPA_Parameters.Size_Of_Iterations_List
      loop
         HOPA_Parameters.Rewind_K_List;
         Max_Iter := HOPA_Parameters.Get_Next_Iterations;
         for J in 1..HOPA_Parameters.Size_Of_K_List
         loop
            K := Hopa_Parameters.Get_Next_K_Pair;
            Ka := HOPA_Parameters.Get_Ka(K);
            Kr := HOPA_Parameters.Get_Kr(K);
            for L in 1..Max_Iter
            loop
               Mast.Tools.Calculate_Ceilings_And_Levels
                 (The_System,My_Verbose);
               declare
                  Aborted : Boolean := False;
               begin
                  My_Back_Up_System := My_System;
                  Counter_Of_Iterations :=
                    Integer'Succ(Counter_Of_Iterations);
                  if Verbose then
                     Put("Starting analysis on iteration: "&
                         Integer'Image(Counter_Of_Iterations));
                  end if;
                  if ATC_Enabled then
                     select
                        delay Analysis_Stop_Time;
                        My_System := My_Back_Up_System;
                        Aborted := True;
                        Counter_Of_Aborted_Analysis :=
                          Integer'Succ(Counter_Of_Aborted_Analysis);
                     then abort
                        The_Tool(The_System,My_Verbose);
                     end select;
                  else
                     Aborted:=False;
                     The_Tool(The_System,My_Verbose);
                  end if;
                  if Verbose then
                     if Aborted then
                        Put_Line("    -> Analysis aborted.");
                     else
                        Put_Line("    -> Analysis finished.");
                     end if;
                  end if;
                  if Aborted then
                     Schedulable := False;
                  else
                     Mast.Tools.Check_System_Schedulability
                       (The_System,Schedulable,My_Verbose);
                  end if;
                  Stop_Algorithm := Stop_Condition;
                  exit when Stop_Algorithm or
                    ((I = HOPA_Parameters.Size_Of_Iterations_List) and
                     (J = HOPA_Parameters.Size_Of_K_List) and
                     (L = Max_Iter));
                  -- New priority assignment
                  if not Aborted then
                     Assign_New_Priorities;
                  else
                     Assign_New_Priorities_Shaking_Deadlines;
                  end if;
               end;
            end loop;
            exit when Stop_Algorithm;
         end loop;
         exit when Stop_Algorithm;
      end loop;

      Restore_Optimum_Priorities;

      if Verbose then
         Put_Line("Linear HOPA statistics:");
         if Audsley_Stop_Time /= 0.0 then
            Put_Line
              ("   Number of times Audsley's algorithm was stopped ---> "&
               Integer'Image(Counter_Of_Aborted_Audsley));
            Put_Line
              ("   Total number of iterations on Audsley's algorithm -> "&
               Long_Integer'Image(Counter_Of_Audsley));
         end if;
         Put_Line("   Number of times the analysis was stopped ----------> "&
                  Integer'Image(Counter_Of_Aborted_Analysis));
         Put_Line("   Total number of iterations ------------------------> "&
                  Integer'Image(Counter_Of_Iterations));
         if Overall_Schedulable then
            Put_Line("The priority assignment process "&
                     "makes the system schedulable");
         else
            Put_Line("The priority assignment process "&
                     "does not make the system schedulable");
         end if;
      end if;

   end Hopa;

   -------------------------
   -- Simulated_annealing --
   -------------------------

   procedure Simulated_Annealing
     (The_System : in out Mast.Systems.System;
      The_Tool: in Mast.Tools.Worst_Case_Analysis_Tool;
      Verbose    : in     Boolean:=True) is

      -- If a processing resource has preassigned priorities, or the number
      -- of schedulable entities is higher than the priority levels that
      -- it has, the optimum_priority_assignment procedure will not be applied

      Optimize : Boolean;

      Max_Iters_To_Stop : Long_Integer;
      Overiteration : Long_Integer;

      Analysis_Stop_Time : Duration :=
        Annealing_Parameters.Get_Analysis_Stop_Time;
      Audsley_Stop_Time : Duration :=
        Annealing_Parameters.Get_Audsley_Stop_Time;

      Counter_Of_Aborted_Analysis : Long_Integer := 0;
      Counter_Of_Aborted_Audsley : Long_Integer := 0;
      Counter_Of_Audsley : Long_Integer := 0;

      Initial_Temperature : constant Long_Float := 200.0;
      Temperature : Long_Float := Initial_Temperature;

      Max_Iters_With_Greater_Energy : constant Integer := 100;
      Max_Iters_With_The_Same_Temperature : constant Integer := 15;
      Max_Random_Jumps : constant Integer := 45;

      Iters_With_Greater_Energy : Integer := 0;
      Iters_To_Stop : Long_Integer := 1;
      Iters_With_The_Same_Temperature : Integer := 0;
      Random_Jumps : Integer := 0;
      Minimum_Energy : Long_Float := Long_Float'Last;

      Actual_Energy, Neighbor_Energy, X : Long_Float;

      Schedulable : Boolean:=False;
      Overall_Schedulable : Boolean := False;
      Optimizing : Boolean := False;
      Stop_Algorithm : Boolean;
      Optimum_Sched_Index, Sched_Index :
        Mast.Tools.Schedulability_Index.Index:=
        Mast.Tools.Schedulability_Index.Lower_Index;

      Nothing_To_Do : exception;

      Max_Processors:constant Processor_ID:=Processor_ID
        (Processing_Resources.Lists.Size
         (The_System.Processing_Resources));
      Max_Transactions:constant Transaction_ID:=Transaction_ID
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

      My_System, My_Back_Up_System : Translation.Linear_Transaction_System;

      type Action_In_Transaction is record
         Transaction : Transaction_Id_Type;
         Action : Task_Id_Type;
      end record;

      type Neighbor_Type is record
         Action1, Action2 : Action_In_Transaction;
      end record;

      Neighbor : Neighbor_Type;

      package List_For_Processor is new Hash_Lists
        (Index => Natural,
         Element => Action_In_Transaction,
           "=" => "=");

      use List_For_Processor;

      Lists_For_Processors :
        array (Processor_ID_Type range 1..Max_Processors) of
        List_For_Processor.List;

      package Natural_Random is
         new Ada.Numerics.Discrete_Random(Natural);

      use Natural_Random;

      Natural_Generator : Natural_Random.Generator;
      Float_Generator : Ada.Numerics.Float_Random.Generator;

      package Long_Float_Functions is new
        Ada.Numerics.Generic_Elementary_Functions(Long_Float);

      use Long_Float_Functions;

      type List_For_Tasks is array
        (Task_ID_Type range 1..Max_Tasks_Per_Transaction)
        of Translation.Priority_Assignment_Vars;

      type List_For_Transactions is array
        (Transaction_ID_Type range 1..Max_Transactions)
        of List_For_Tasks;

      Pavs : List_For_Transactions;

      ---------------
      -- Save_Pavs --
      ---------------

      procedure Save_Pavs is
      begin
         for I in Transaction_ID_Type range 1..Max_Transactions
         loop
            for J in Task_ID_Type range 1..Max_Tasks_Per_Transaction
            loop
               Pavs(I)(J) := My_System(I).The_Task(J).Pav;
            end loop;
         end loop;
      end Save_Pavs;

      ------------------
      -- Restore_Pavs --
      ------------------

      procedure Restore_Pavs is
      begin
         for I in Transaction_ID_Type range 1..Max_Transactions
         loop
            for J in Task_ID_Type range 1..Max_Tasks_Per_Transaction
            loop
               My_System(I).The_Task(J).Pav := Pavs(I)(J);
            end loop;
         end loop;
      end Restore_Pavs;


      ---------------------------------------------------------------
      -- Convert_Deadlines_To_Priorities variables and procedures. --
      --                                                           --
      -- They are made public in order to use the mapping          --
      -- procedure.                                                --
      ---------------------------------------------------------------

      Queue_Length :
        array (Processor_ID_Type range 1..Max_Processors) of Natural;

      List_Of_Min_VP :
        array (Processor_ID_Type range 1..Max_Processors) of
        Virtual_Priority;

      List_Of_Min_P :
        array (Processor_ID_Type range 1..Max_Processors) of
        Priority;

      List_Of_Max_P :
        array (Processor_ID_Type range 1..Max_Processors) of
        Priority;

      Optimization_In_Processor :
        array (Processor_ID_Type range 1..Max_Processors) of
        Boolean;

      ---------------------------------------------
      -- Convert_Deadlines_To_Virtual_Priorities --
      ---------------------------------------------

      procedure Convert_Deadlines_To_Virtual_Priorities is

         type Deadline_Element is record
            Transaction : Transaction_Id_Type;
            Action : Task_Id_Type;
         end record;

         package Deadlines_Lists is new Priority_Queues
           (Element => Deadline_Element,
            Priority => Time,
            ">" => "<",
            "=" => "=");

         use Deadlines_Lists;

         Lists_For_Processors :
           array (Processor_ID_Type range 1..Max_Processors) of
           Deadlines_Lists.Queue;

         Item : Deadline_Element;
         Next_Priority : Virtual_Priority;
         Deadline : Time;

      begin

         for I in Processor_ID_Type range 1..Max_Processors
         loop
            Optimization_In_Processor(I) := True;
         end loop;

         for I in Transaction_ID_Type range 1..Max_Transactions
         loop
            exit when My_System(I).Ni=0;
            for J in 1..My_System(I).Ni
            loop
               if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                 not My_System(I).The_Task(J).Pav.Is_Polling then
                  Item := (Transaction => I,
                           Action => J);
                  Deadlines_Lists.Enqueue
                    (Item,
                     My_System(I).The_Task(J).Pav.D_0,
                     Lists_For_Processors(My_System(I).The_Task(J).Procij));
               end if;
            end loop;
         end loop;

         for I in Processor_ID_Type range 1..Max_Processors
         loop
            declare
               J : Integer := 0;
               Background_Priority : Priority:= Priority'First;
            begin
               while not Deadlines_Lists.Empty(Lists_For_Processors(I))
               loop
                  J := J+1;
                  Deadlines_Lists.Dequeue
                    (Item,Deadline,Lists_For_Processors(I));
                  if J=1 then
                     Next_Priority := Max_Virtual_Priority;
                  else
                     Next_Priority := Virtual_Priority'Pred(Next_Priority);
                  end if;
                  My_System(Item.Transaction).
                    The_Task(Item.Action).Pav.Virtual_Prio := Next_Priority;
                  if Debug then
                     Put(" Next_VP = "&
                         Virtual_Priority'Image(Next_Priority));
                     Put(" with Deadline = "&
                         Time'Image(Deadline));
                     Put_Line(" at the position "&Integer'Image(J));
                     Put_Line(" Preasssigned="&Boolean'Image
                         (My_System(Item.Transaction).The_Task(Item.Action).
                          Pav.Preassigned));
                  end if;
                  if My_System(Item.Transaction).The_Task(Item.Action).
                    Pav.Preassigned then
                     -- Check if the optimum priority assigment will be
                     -- performed for this processor
                     Optimization_In_Processor(I) := False;
                  end if;
                  if My_System(Item.Transaction).The_Task(Item.Action).
                    Pav.S_P_Ref.all in
                    Scheduling_Parameters.Sporadic_Server_Policy'Class
                  then
                     begin
                        if Background_Priority <=
                          Mast.Scheduling_Parameters.
                          Background_Priority
                          (Mast.Scheduling_Parameters.
                           Sporadic_Server_Policy
                           (My_System(Item.Transaction).
                            The_Task(Item.Action).Pav.S_P_Ref.all))
                        then
                           Background_Priority :=
                             Mast.Scheduling_Parameters.
                             Background_Priority
                             (Mast.Scheduling_Parameters.
                              Sporadic_Server_Policy
                              (My_System(Item.Transaction).
                               The_Task(Item.Action).Pav.S_P_Ref.all))+1;
                        end if;
                     exception
                        when Constraint_Error =>
                           Background_Priority :=
                             Mast.Scheduling_Parameters.
                             Background_Priority
                             (Mast.Scheduling_Parameters.
                              Sporadic_Server_Policy
                              (My_System(Item.Transaction).
                               The_Task(Item.Action).Pav.S_P_Ref.all));
                     end;
                  end if;
               end loop;
               Queue_Length(I) := J;
               -- Store the number of task per processor for optimizing
               -- priority assignment
               List_Of_Min_VP(I) := Next_Priority;
               -- Store the minimum virtual priority assigned for each
               -- processor
               if Background_Priority > Scheduling_Policies.Min_Priority
                 (My_System(Item.Transaction).The_Task(Item.Action).
                  Pav.S_Policy_Ref.all)
               then
                  List_Of_Min_P(I) := Background_Priority;
               else
                  List_Of_Min_P(I) := Scheduling_Policies.Min_Priority
                    (My_System(Item.Transaction).The_Task(Item.Action).
                     Pav.S_Policy_Ref.all);
               end if;
               -- Store the minimum priority for each processor
               List_Of_Max_P(I) := Scheduling_Policies.Max_Priority
                 (My_System(Item.Transaction).The_Task(Item.Action).
                  Pav.S_Policy_Ref.all);
               -- Store the maximum priority for each processor
               if J > Integer (List_Of_Max_P(I)-List_Of_Min_P(I)+1)
               then
                  -- Check if the optimum priority assigment will be
                  -- performed for this processor
                  Optimization_In_Processor(I) := False;
               end if;
            end;
         end loop;

      end Convert_Deadlines_To_Virtual_Priorities;

      ----------------------
      -- Priority_Mapping --
      ----------------------

      procedure Priority_Mapping is

         type Priority_Element is record
            Transaction : Transaction_Id_Type;
            Action : Task_Id_Type;
         end record;

         package VP_Lists is new Priority_Queues
           (Element => Priority_Element,
            Priority => Virtual_Priority,
              ">" => ">",
              "=" => "=");

         use VP_Lists;

         package P_Lists is new Priority_Queues
           (Element => Priority_Element,
            Priority => Priority,
              ">" => ">",
              "=" => "=");

         use P_Lists;

         Lists_For_VP :
           array (Processor_ID_Type range 1..Max_Processors) of
           VP_Lists.Queue;
         Lists_For_P :
           array (Processor_ID_Type range 1..Max_Processors) of
           P_Lists.Queue;

         Item1, Item2 : Priority_Element;
         Max_P, Min_P : Priority;
         Max_VP, Min_VP, VP : Virtual_Priority;

      begin

         for I in Transaction_ID_Type range 1..Max_Transactions
         loop
            exit when My_System(I).Ni=0;
            for J in 1..My_System(I).Ni
            loop
               Item1 := (Transaction => I,
                         Action => J);
               if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                 not My_System(I).The_Task(J).Pav.Is_Polling then
                  if  My_System(I).The_Task(J).Pav.Preassigned then
                     P_Lists.Enqueue
                       (Item1,
                        My_System(I).The_Task(J).Pav.Preassigned_Prio,
                        Lists_For_P(My_System(I).The_Task(J).Procij));
                  else
                     VP_Lists.Enqueue
                       (Item1,
                        My_System(I).The_Task(J).Pav.Virtual_Prio,
                        Lists_For_VP(My_System(I).The_Task(J).Procij));
                  end if;
               end if;
            end loop;
         end loop;

         for I in Processor_ID_Type range 1..Max_Processors
         loop
            Min_P := List_Of_Max_P(I);
            Min_VP := Max_Virtual_Priority;
            -- Set minumum priorities to maximum values
            while not VP_Lists.Empty(Lists_For_VP(I))
            loop
               VP_Lists.Dequeue(Item2,VP,Lists_For_VP(I));
               if VP <= Min_VP then
                  -- New stage
                  Max_P := Min_P;
                  Max_VP := Min_VP;
                  loop
                     if not P_Lists.Empty(Lists_For_P(I)) then
                        P_Lists.Dequeue(Item1,Min_P,Lists_For_P(I));
                        Min_P := Priority'Max(Min_P,List_Of_Min_P(I));
                        Min_VP :=
                          My_System(Item1.Transaction).
                          The_Task(Item1.Action).Pav.Virtual_Prio;
                        if VP > Min_VP then
                           exit;
                        end if;
                     else
                        Min_P := List_Of_Min_P(I);
                        Min_VP := List_Of_Min_VP(I);
                        exit;
                     end if;
                  end loop;
               end if;
               if Debug then
                  Put("   VP = "&Virtual_Priority'Image(VP));
                  Put("   Max_P = "&Priority'Image(Max_P));
                  Put("   Min_P = "&Priority'Image(Min_P));
                  Put("   Max_VP = "&Virtual_Priority'Image(Max_VP));
                  Put_Line("   Min_VP = "&Virtual_Priority'Image(Min_VP));
               end if;

               My_System(Item2.Transaction).The_Task(Item2.Action).Prioij :=
                 Priority
                 (Long_Float'Floor
                  ((Long_Float(VP)-Long_Float(Min_VP))/
                   (Long_Float(Max_VP)-Long_Float(Min_VP)+1.0)*
                   (Long_Float(Max_P)-Long_Float(Min_P)+1.0)+
                   Long_Float(Min_P)));

               if Debug then
                  Put_Line("   Priority Assigned = "&
                           Priority'Image
                           (My_System(Item2.Transaction).
                            The_Task(Item2.Action).Prioij));
               end if;

            end loop;
         end loop;

      end Priority_Mapping;

      -----------------------------
      -- Single_Priority_Mapping --
      -----------------------------

      procedure Single_Priority_Mapping (P : in Processor_ID_Type) is

         type Priority_Element is record
            Transaction : Transaction_Id_Type;
            Action : Task_Id_Type;
         end record;

         package VP_Lists is new Priority_Queues
           (Element => Priority_Element,
            Priority => Virtual_Priority,
              ">" => ">",
              "=" => "=");

         use VP_Lists;

         package P_Lists is new Priority_Queues
           (Element => Priority_Element,
            Priority => Priority,
              ">" => ">",
              "=" => "=");

         use P_Lists;

         List_For_VP : VP_Lists.Queue;
         List_For_P : P_Lists.Queue;

         Item1, Item2 : Priority_Element;
         Max_P, Min_P : Priority;
         Max_VP, Min_VP, VP : Virtual_Priority;

      begin

         for I in Transaction_ID_Type range 1..Max_Transactions
         loop
            exit when My_System(I).Ni=0;
            for J in 1..My_System(I).Ni
            loop
               Item1 := (Transaction => I,
                         Action => J);
               if P = My_System(I).The_Task(J).Procij
                 and then not My_System(I).The_Task(J).Pav.Hard_Prio
                 and then not My_System(I).The_Task(J).Pav.Is_Polling then
                  if  My_System(I).The_Task(J).Pav.Preassigned then
                     P_Lists.Enqueue
                       (Item1,
                        My_System(I).The_Task(J).Pav.Preassigned_Prio,
                        List_For_P);
                  else
                     VP_Lists.Enqueue
                       (Item1,
                        My_System(I).The_Task(J).Pav.Virtual_Prio,
                        List_For_VP);
                  end if;
               end if;
            end loop;
         end loop;

         Max_P := List_Of_Max_P(P);
         Max_VP := Max_Virtual_Priority;
         if not P_Lists.Empty(List_For_P) then
            P_Lists.Dequeue(Item1,Min_P,List_For_P);
            Min_VP :=
              My_System(Item1.Transaction).
              The_Task(Item1.Action).Pav.Virtual_Prio;
         else
            Min_P := List_Of_Min_P(P);
            Min_VP := List_Of_Min_VP(P);
         end if;

         while not VP_Lists.Empty(List_For_VP)
         loop
            VP_Lists.Dequeue(Item2,VP,List_For_VP);
            if VP < Min_VP then
               -- New stage
               Max_P := Min_P;
               Max_VP := Min_VP;
               if not P_Lists.Empty(List_For_P) then
                  P_Lists.Dequeue(Item1,Min_P,List_For_P);
                  Min_VP :=
                    My_System(Item1.Transaction).
                    The_Task(Item1.Action).Pav.Virtual_Prio;
               else
                  Min_P := List_Of_Min_P(P);
                  Min_VP := List_Of_Min_VP(P);
               end if;
            end if;
            if Debug then
               Put("   VP = "&Virtual_Priority'Image(VP));
               Put("   Max_P = "&Priority'Image(Max_P));
               Put("   Min_P = "&Priority'Image(Min_P));
               Put("   Max_VP = "&Virtual_Priority'Image(Max_VP));
               Put_Line("   Min_VP = "&Virtual_Priority'Image(Min_VP));
            end if;

            My_System(Item2.Transaction).The_Task(Item2.Action).Prioij :=
              Priority
              (Long_Float'Floor
               ((Long_Float(VP)-Long_Float(Min_VP))/
                (Long_Float(Max_VP)-Long_Float(Min_VP)+1.0)*
                (Long_Float(Max_P)-Long_Float(Min_P)+1.0)+
                Long_Float(Min_P)));

            if Debug then
               Put_Line("   Priority Assigned = "&
                        Priority'Image
                        (My_System(Item2.Transaction).
                         The_Task(Item2.Action).Prioij));
            end if;

         end loop;

      end Single_Priority_Mapping;

      ---------------------------------
      -- Optimum_Priority_Assignment --
      ---------------------------------

      procedure Optimum_Priority_Assignment is

         type Deadline_Element is record
            Transaction : Transaction_Id_Type;
            Action : Task_Id_Type;
         end record;

         Item : Deadline_Element;

      begin

         for K in Processor_ID_Type range 1..Max_Processors
         loop
            if Optimization_In_Processor(K) then
               declare
                  type Lists_Of_Task is
                    array(Integer range 1..Queue_Length(K))of
                    Deadline_Element;
                  List_Of_Task : Lists_Of_Task;
                  Num_Of_Task : Integer := 0;
                  Prio : Priority;
                  Failed : Boolean;
                  Aborted : Boolean := False;
               begin
                  -- Extract the tasks
                  for I in Transaction_Id_Type range 1..Max_Transactions
                  loop
                     exit when My_System(I).Ni=0;
                     for J in 1..My_System(I).Ni
                     loop
                        if (My_System(I).The_Task(J).Procij = K) and then
                          not My_System(I).The_Task(J).Pav.Hard_Prio and then
                          not My_System(I).The_Task(J).Pav.Is_Polling then
                           Num_Of_Task := Num_Of_Task+1;
                           List_Of_Task(Num_Of_Task).Transaction := I;
                           List_Of_Task(Num_Of_Task).Action := J;
                        end if;
                     end loop;
                  end loop;

                  if Debug then
                     Put_Line("Initial priorities.....");
                     for I in 1..Num_Of_Task
                     loop
                        Put("trans : "&Transaction_Id_Type'Image
                            (List_Of_Task(I).Transaction));
                        Put("task : "&Task_Id_Type'Image
                            (List_Of_Task(I).Action));
                        Put("   deadline = "&Time'Image
                            (My_System(List_Of_Task(I).Transaction).
                             The_Task(List_Of_Task(I).Action).Dij));
                        Put_Line("   prioridad = "&Priority'Image
                                 (My_System(List_Of_Task(I).Transaction).
                                  The_Task(List_Of_Task(I).Action).Prioij));
                     end loop;
                     New_Line;
                  end if;

                  -- Order the task
                  for I in 2..(Num_Of_Task)
                  loop
                     for J in reverse I..(Num_Of_Task)
                     loop
                        if My_System(List_Of_Task(J).Transaction).
                          The_Task(List_Of_Task(J).Action).Prioij >
                          My_System(List_Of_Task(J-1).Transaction).
                          The_Task(List_Of_Task(J-1).Action).Prioij then
                           Item := List_Of_Task(J);
                           List_Of_Task(J) := List_Of_Task(J-1);
                           List_Of_Task(J-1) := Item;
                        end if;
                     end loop;
                  end loop;

                  if Debug then
                     Put_Line("Ordered priorities.....");
                     for I in 1..Num_Of_Task
                     loop
                        Put("trans : "&Transaction_Id_Type'Image
                            (List_Of_Task(I).Transaction));
                        Put("task : "&Task_Id_Type'Image
                            (List_Of_Task(I).Action));
                        Put("   deadline = "&Time'Image
                            (My_System(List_Of_Task(I).Transaction).
                             The_Task(List_Of_Task(I).Action).Dij));
                        Put_Line("   prioridad = "&Priority'Image
                                 (My_System(List_Of_Task(I).Transaction).
                                  The_Task(List_Of_Task(I).Action).Prioij));
                     end loop;
                     New_Line;
                  end if;

                  -- Apply the priority assignment algorithm
                  for I in reverse 2..Num_Of_Task
                  loop
                     Failed := True;
                     for J in reverse 1..I
                     loop
                        -- Exchange tasks I and J and their priorities
                        Item := List_Of_Task(I);
                        List_Of_Task(I) := List_Of_Task(J);
                        List_Of_Task(J) := Item;
                        Prio := My_System(List_Of_Task(I).Transaction).
                          The_Task(List_Of_Task(I).Action).Prioij;
                        My_System(List_Of_Task(I).Transaction).
                          The_Task(List_Of_Task(I).Action).Prioij :=
                          My_System(List_Of_Task(J).Transaction).
                          The_Task(List_Of_Task(J).Action).Prioij;
                        My_System(List_Of_Task(J).Transaction).
                          The_Task(List_Of_Task(J).Action).Prioij := Prio;

                        if Debug then
                           Put_Line("Changing priorities.....");
                           for L in 1..Num_Of_Task
                           loop
                              Put("trans : "&Transaction_Id_Type'Image
                                  (List_Of_Task(L).Transaction));
                              Put("task : "&Task_Id_Type'Image
                                  (List_Of_Task(L).Action));
                              Put("   deadline = "&Time'Image
                                  (My_System(List_Of_Task(L).Transaction).
                                   The_Task(List_Of_Task(L).Action).Dij));
                              Put_Line("   prioridad = "&Priority'Image
                                       (My_System(List_Of_Task(L).
                                                  Transaction).
                                        The_Task(List_Of_Task(L).Action).
                                        Prioij));
                           end loop;
                           New_Line;
                        end if;

                        Translation.Translate_Priorities
                          (My_System,The_System);
                        Save_Pavs;

                        -- Check if task I is schedulable

                        Mast.Tools.Calculate_Ceilings_And_Levels
                          (The_System,My_Verbose);
                        My_Back_Up_System := My_System;
                        Counter_Of_Audsley :=
                          Long_Integer'Succ(Counter_Of_Audsley);
                        if ATC_Enabled then
                           select
                              delay Audsley_Stop_Time;
                              My_System := My_Back_Up_System;
                              Aborted := True;
                              Counter_Of_Aborted_Audsley :=
                             Long_Integer'Succ(Counter_Of_Aborted_Audsley);
                           then abort
                              The_Tool(The_System,My_Verbose);
                           end select;
                        else
                           Aborted:=False;
                           The_Tool(The_System,My_Verbose);
                        end if;
                        if not Aborted then
                           Translation.Translate_Linear_System_With_Results
                             (The_System,My_System,My_Verbose);
                           Restore_Pavs;
                        end if;

                        if not Aborted and then
                          (My_System(List_Of_Task(I).Transaction).
                           The_Task(List_Of_Task(I).Action).Pav.D_0 >=
                           My_System(List_Of_Task(I).Transaction).
                           The_Task(List_Of_Task(I).Action).Rij) then
                           Failed := False;
                           exit;
                        else
                           -- Exchange tasks I and J and their
                           -- old priorities
                           Item := List_Of_Task(I);
                           List_Of_Task(I) := List_Of_Task(J);
                           List_Of_Task(J) := Item;
                           Prio := My_System(List_Of_Task(I).Transaction).
                             The_Task(List_Of_Task(I).Action).Prioij;
                           My_System(List_Of_Task(I).Transaction).
                             The_Task(List_Of_Task(I).Action).Prioij :=
                             My_System(List_Of_Task(J).Transaction).
                             The_Task(List_Of_Task(J).Action).Prioij;
                           My_System(List_Of_Task(J).Transaction).
                             The_Task(List_Of_Task(J).Action).Prioij :=
                             Prio;
                           Translation.Translate_Priorities
                             (My_System,The_System);
                           Save_Pavs;
                           exit when Aborted;

                           if Debug then
                              Put_Line("Returning to old priorities....");
                              for L in 1..Num_Of_Task
                              loop
                                 Put("trans : "&Transaction_Id_Type'Image
                                     (List_Of_Task(L).Transaction));
                                 Put("task : "&Task_Id_Type'Image
                                     (List_Of_Task(L).Action));
                                 Put("   deadline = "&Time'Image
                                     (My_System(List_Of_Task(L).
                                                Transaction).
                                      The_Task(List_Of_Task(L).
                                               Action).Dij));
                                 Put_Line("   prioridad = "&Priority'Image
                                          (My_System(List_Of_Task(L).
                                                     Transaction).
                                           The_Task(List_Of_Task(L).Action).
                                           Prioij));
                              end loop;
                              New_Line;
                           end if;

                        end if;
                     end loop;
                     exit when Failed;
                  end loop;

                  if Debug then
                     Put_Line("Final assignment....");
                     for I in 1..Num_Of_Task
                     loop
                        Put("trans : "&Transaction_Id_Type'Image
                            (List_Of_Task(I).Transaction));
                        Put("   deadline = "&Time'Image
                            (My_System(List_Of_Task(I).Transaction).
                             The_Task(List_Of_Task(I).Action).Dij));
                        Put_Line("   prioridad = "&Priority'Image
                                 (My_System(List_Of_Task(I).Transaction).
                                  The_Task(List_Of_Task(I).Action).Prioij));
                     end loop;
                     New_Line;
                  end if;

               end;
            end if;
         end loop;

      end Optimum_Priority_Assignment;

      -------------------------------------
      -- Convert_Deadlines_To_Priorities --
      -------------------------------------

      procedure Convert_Deadlines_To_Priorities is

      begin

         Convert_Deadlines_To_Virtual_Priorities;

         Priority_Mapping;

         if Audsley_Stop_Time /= 0.0 then
            Optimum_Priority_Assignment;
         end if;
         -- This procedure is not called for eficiency reasons. It implements
         -- Ausley's algorithm for monoprocesors and calls the analysis
         -- tools several times (proportional to the size of the system).
         -- If we have a case where the analysis tool runs slow, the priority
         -- assignment algorithm can take too much time.
         -- In spite of this, we keep on implementing it because in some cases
         -- the algorithm can find better solutions.

      end Convert_Deadlines_To_Priorities;

      ---------------------------------------------------------------
      -- End of:                                                   --
      -- Convert_Deadlines_To_Priorities variables and procedures. --
      --                                                           --
      -- They are made public in order to use the mapping          --
      -- procedure.                                                --
      ---------------------------------------------------------------

      ---------------------------
      -- Initialize_Priorities --
      ---------------------------

      procedure Initialize_Priorities is

         -- Initialize priorities according to WCETs

         Max_Factor : constant Time := Large_Time;
         Max_D,Sum_C,Assigned_D,Factor : Time;

      begin
         Translation.Translate_Linear_System(The_System,My_System,My_Verbose);

         -- Save Preassigned_Prio

         for I in Transaction_Id_Type range 1..Max_Transactions
         loop
            exit when My_System(I).Ni=0;
            for J in 1..My_System(I).Ni
            loop
               My_System(I).The_Task(J).Pav.Preassigned_Prio :=
                 My_System(I).The_Task(J).Prioij;
            end loop;
         end loop;

         -- Deadline assignment

         for I in Transaction_Id_Type range 1..Max_Transactions
         loop
            exit when My_System(I).Ni=0;
            Max_D := Large_Time;
            for J in reverse 1..My_System(I).Ni
            loop
               -- Mark the actions with deadlines to calculate factors
               if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                 not My_System(I).The_Task(J).Pav.Is_Polling then
                  if My_System(I).The_Task(J).Dij /= Large_Time and
                    My_System(I).The_Task(J).Dij < Max_D then
                     My_System(I).The_Task(J).Pav.Calculate_Factor := True;
                     My_System(I).The_Task(J).Pav.D_0 :=
                       My_System(I).The_Task(J).Dij;
                     My_System(I).The_Task(J).Pav.D_I :=
                       My_System(I).The_Task(J).Dij;
                     Max_D := My_System(I).The_Task(J).Dij;
                  else
                     My_System(I).The_Task(J).Pav.Calculate_Factor := False;
                     My_System(I).The_Task(J).Pav.D_0 := Large_Time;
                     My_System(I).The_Task(J).Pav.D_I := Large_Time;
                  end if;
               end if;
            end loop;

            Sum_C := 0.0;
            Assigned_D := 0.0;
            for J in 1..My_System(I).Ni
            loop
               -- Calculate factors
               if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                 not My_System(I).The_Task(J).Pav.Is_Polling then
                  Sum_C := Sum_C+My_System(I).The_Task(J).Cijown;
                  if My_System(I).The_Task(J).Pav.Calculate_Factor then
                     My_System(I).The_Task(J).Pav.Factor :=
                       (My_System(I).The_Task(J).Pav.D_0-Assigned_D)/Sum_C;
                     Sum_C := 0.0;
                     Assigned_D := My_System(I).The_Task(J).Pav.D_0;
                  else
                     My_System(I).The_Task(J).Pav.Factor := 1.0;
                  end if;
               end if;
            end loop;

            Factor := Max_Factor;
            for J in reverse 1..My_System(I).Ni
            loop
               -- Calculate deadlines
               if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                 not My_System(I).The_Task(J).Pav.Is_Polling then
                  if My_System(I).The_Task(J).Pav.Calculate_Factor then
                     Factor := My_System(I).The_Task(J).Pav.Factor;
                  end if;
                  if Factor = Max_Factor then
                     My_System(I).The_Task(J).Pav.D_0 := Large_Time;
                  else
                     My_System(I).The_Task(J).Pav.D_0 :=
                       My_System(I).The_Task(J).Cijown*Factor;
                  end if;
               end if;
            end loop;

         end loop;

         -- Priority assignment

         Convert_Deadlines_To_Priorities;

         Translation.Translate_Priorities(My_System,The_System);

         Save_Pavs;

      end Initialize_Priorities;

      -----------------------
      -- Toggle_Priorities --
      -----------------------

      procedure Toggle_Priorities
        (The_Neighbor : Neighbor_Type) is

         Temp_Priority : Virtual_Priority;

      begin
         Temp_Priority := My_System(The_Neighbor.Action1.Transaction).
           The_Task(The_Neighbor.Action1.Action).Pav.Virtual_Prio;
         My_System(The_Neighbor.Action1.Transaction).
           The_Task(The_Neighbor.Action1.Action).Pav.Virtual_Prio :=
           My_System(The_Neighbor.Action2.Transaction).
           The_Task(The_Neighbor.Action2.Action).Pav.Virtual_Prio;
         My_System(The_Neighbor.Action2.Transaction).
           The_Task(The_Neighbor.Action2.Action).Pav.Virtual_Prio :=
           Temp_Priority;

         Single_Priority_Mapping
           (My_System(The_Neighbor.Action1.Transaction).
            The_Task(The_Neighbor.Action1.Action).Procij);

         Translation.Translate_Priorities(My_System,The_System);

         Save_Pavs;

      end Toggle_Priorities;

      ------------
      -- Energy --
      ------------

      function Energy return Long_Float is

         -- An unschedulable system means an energy over the middle energy
         -- A schedulable system means an energy under the middle energy

         Middle_Energy : constant Long_Float := Long_Float'Last/2.0;
         Energy_Plus, Energy_Less : Long_Float := Middle_Energy;

      begin
         Translation.Translate_Linear_System_With_Results
           (The_System,My_System,My_Verbose);
         Restore_Pavs;
         -- Get the results of the analysis

         for I in Transaction_Id_Type range 1..Max_Transactions
         loop
            exit when My_System(I).Ni=0;
            for J in reverse 1..My_System(I).Ni
            loop
               -- Calculates energy
               if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                 not My_System(I).The_Task(J).Pav.Is_Polling then
                  if My_System(I).The_Task(J).Pav.Calculate_Factor then
                     if My_System(I).The_Task(J).Pav.D_I >=
                       My_System(I).The_Task(J).Rij then
                        Energy_Plus := Energy_Plus + Long_Float
                          (My_System(I).The_Task(J).Rij-
                           My_System(I).The_Task(J).Pav.D_I);
                     else
                        Energy_Less := Energy_Less + Long_Float
                          (My_System(I).The_Task(J).Rij-
                           My_System(I).The_Task(J).Pav.D_I);
                     end if;
                  end if;
               end if;
            end loop;
         end loop;

         if Energy_Less /= Middle_Energy then
            return Energy_Less;
         else
            return Energy_Plus;
         end if;

      end Energy;

      -------------
      -- Cooling --
      -------------

      function Cooling (Temp : Long_Float) return Long_Float is

      begin
         return (0.9*Temp);
      end Cooling;

      ------------------
      -- Get_Neighbor --
      ------------------

      function Get_Neighbor return Neighbor_Type is

         Processor : Processor_ID_Type;
         Action1,Action2 : Natural;
         A_Neighbor : Neighbor_Type;


      begin
         -- Selects a processing resource with at least two actions
         loop
            Processor := Processor_ID_Type
              ((Natural_Random.Random(Natural_Generator)
                mod Natural(Max_Processors))+1);
            exit when List_For_Processor.Size
              (Lists_For_Processors(Processor)) >= 2;
         end loop;

         -- Selects two different actions in the processing resource
         Action1 := (Natural_Random.Random(Natural_Generator) mod
                     List_For_Processor.Size
                     (Lists_For_Processors(Processor)))+1;
         loop
            Action2 := (Natural_Random.Random(Natural_Generator) mod
                        List_For_Processor.Size
                        (Lists_For_Processors(Processor)))+1;
            exit when Action1 /= Action2;
         end loop;
         A_Neighbor.Action1 := List_For_Processor.Item
           (Action1,Lists_For_Processors(Processor));
         A_Neighbor.Action2 := List_For_Processor.Item
           (Action2,Lists_For_Processors(Processor));

         return A_Neighbor;

      end Get_Neighbor;

      -------------------------------
      -- Load_Lists_For_Processors --
      -------------------------------

      procedure Load_Lists_For_Processors is

         List_Of_Index :
           array (Processor_ID_Type range 1..Max_Processors) of Natural;
         Test : Boolean := False;

      begin
         for I in Processor_ID_Type range 1..Max_Processors
         loop
            List_Of_Index(I) := 0;
         end loop;

         for I in Transaction_Id_Type range 1..Max_Transactions
         loop
            exit when My_System(I).Ni=0;
            for J in 1..My_System(I).Ni
            loop
               if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                 not My_System(I).The_Task(J).Pav.Is_Polling then
                  List_Of_Index(My_System(I).The_Task(J).Procij) :=
                    List_Of_Index(My_System(I).The_Task(J).Procij)+1;
                  List_For_Processor.Add
                    (List_Of_Index(My_System(I).The_Task(J).Procij),
                     (Transaction=>I,Action=>J),
                     Lists_For_Processors(My_System(I).The_Task(J).Procij));
               end if;
            end loop;
         end loop;

         -- Tests if there is a processing resource with two or more actions,
         -- otherwise raises Nothing_To_Do

         for I in Processor_ID_Type range 1..Max_Processors
         loop
            if List_Of_Index(I) >= 2 then
               Test := True;
               exit;
            end if;
         end loop;
         if not Test then
            raise Nothing_To_Do;
         end if;

      exception
         when List_Exceptions.Already_Exists =>
            if Verbose then
               Put_Line("Fail in the creation of the processor list");
            end if;
      end Load_Lists_For_Processors;

      -------------------------
      -- Thermic_Equilibrium --
      -------------------------

      function Thermic_Equilibrium return Boolean is
      begin
         return (Iters_With_The_Same_Temperature =
                 Max_Iters_With_The_Same_Temperature);
      end Thermic_Equilibrium;

      -----------------------------
      -- Save_Optimum_Priorities --
      -----------------------------

      procedure Save_Optimum_Priorities is

      begin
         Mast.Tools.Schedulability_Index.Calculate_Schedulability_Index
           (The_System,Sched_Index,Verbose);
         if Sched_Index > Optimum_Sched_Index then
            Optimum_Sched_Index := Sched_Index;
            if Verbose then
               Put("Saving optimum priority assignment with "&
                   "schedulability index : ");
               Mast.Tools.Schedulability_Index.Print(Optimum_Sched_Index);
            end if;
            for I in Transaction_Id_Type range 1..Max_Transactions
            loop
               exit when My_System(I).Ni=0;
               for J in 1..My_System(I).Ni
               loop
                  if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                    not My_System(I).The_Task(J).Pav.Is_Polling then
                     My_System(I).The_Task(J).Pav.Optimum_Prio :=
                       My_System(I).The_Task(J).Prioij;
                     Pavs(I)(J).Optimum_Prio :=
                       My_System(I).The_Task(J).Prioij;
                  end if;
               end loop;
            end loop;
         end if;

      exception
         when Mast.Tools.Schedulability_Index.Inconclusive =>
            null;

      end Save_Optimum_Priorities;

      --------------------------------
      -- Restore_Optimum_Priorities --
      --------------------------------

      procedure Restore_Optimum_Priorities is

      begin
         if Overall_Schedulable then
            if Verbose then
               Put("Restoring optimum priority assignment with "&
                   "schedulability index : ");
               Mast.Tools.Schedulability_Index.Print(Optimum_Sched_Index);
            end if;
            for I in Transaction_Id_Type range 1..Max_Transactions
            loop
               exit when My_System(I).Ni=0;
               for J in 1..My_System(I).Ni
               loop
                  if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                    not My_System(I).The_Task(J).Pav.Is_Polling then
                     My_System(I).The_Task(J).Prioij :=
                       My_System(I).The_Task(J).Pav.Optimum_Prio;
                  end if;
               end loop;
            end loop;
            Translation.Translate_Priorities(My_System,The_System);
         else
            for I in Transaction_Id_Type range 1..Max_Transactions
            loop
               exit when My_System(I).Ni=0;
               for J in 1..My_System(I).Ni
               loop
                  My_System(I).The_Task(J).Prioij :=
                    My_System(I).The_Task(J).Pav.Preassigned_Prio;
               end loop;
            end loop;
            Translation.Translate_Priorities(My_System,The_System);
         end if;
      end Restore_Optimum_Priorities;

      --------------------
      -- Stop_Condition --
      --------------------

      function Stop_Condition return Boolean is

      begin
         if Schedulable then
            Save_Optimum_Priorities;
            Overall_Schedulable := True;
            if Optimize then
               if Optimizing then
                  if Iters_To_Stop >= Max_Iters_To_Stop then
                     return True;
                  end if;
                  -- else check not schedulable case below
               else
                  Optimizing := True;
                  Max_Iters_To_Stop := Iters_To_Stop+Overiteration;
                  return False;
               end if;
            else
               return True;
            end if;
         end if;

         if Iters_With_Greater_Energy =
           Max_Iters_With_Greater_Energy then
            Random_Jumps := Random_Jumps+1;
            if Random_Jumps = Max_Random_Jumps then
               return True;
            else
               for I in 1..Random_Jumps
               loop
                  Neighbor := Get_Neighbor;
                  Toggle_Priorities(Neighbor);
               end loop;
               Mast.Tools.Calculate_Ceilings_And_Levels
                 (The_System,My_Verbose);
               declare
                  Aborted : Boolean := False;
               begin
                  My_Back_Up_System := My_System;
                  if ATC_Enabled then
                     select
                        delay Analysis_Stop_Time;
                        My_System := My_Back_Up_System;
                        Aborted := True;
                        Counter_Of_Aborted_Analysis :=
                          Long_Integer'Succ(Counter_Of_Aborted_Analysis);
                     then abort
                        The_Tool(The_System,My_Verbose);
                     end select;
                  else
                     Aborted:=False;
                     The_Tool(The_System,My_Verbose);
                  end if;
                  if Aborted then
                     Schedulable := False;
                  else
                     Mast.Tools.Check_System_Schedulability
                       (The_System,Schedulable,My_Verbose);
                  end if;
                  Iters_To_Stop := Iters_To_Stop+1;
                  if Iters_To_Stop = Max_Iters_To_Stop then
                     return True;
                  end if;
                  if not Aborted then
                     Actual_Energy := Energy;
                  else
                     Actual_Energy := Long_Float'Last;
                  end if;
               end;
               Minimum_Energy := Long_Float'Last;
               Iters_With_Greater_Energy := 0;
               return Stop_Condition;
            end if;
         elsif Iters_To_Stop >= Max_Iters_To_Stop then
            return True;
         else
            if (Float(Counter_Of_Aborted_Analysis)/
                Float(Iters_To_Stop)) > 0.5 then
               return True;
            end if;
            return False;
         end if;

      end Stop_Condition;


   begin
      Natural_Random.Reset(Natural_Generator);
      Ada.Numerics.Float_Random.Reset(Float_Generator);

      Optimize := (Annealing_Parameters.Get_Overiterations /= 0);
      Max_Iters_To_Stop := Annealing_Parameters.Get_Max_Iterations;
      Overiteration := Annealing_Parameters.Get_Overiterations;

      Initialize_Priorities;
      -- Initial values according to deadline monotonic

      Load_Lists_For_Processors;
      -- Extracts the links between actions and processing resources

      -- Initial analysis to calculate actual energy
      Mast.Tools.Calculate_Ceilings_And_Levels
        (The_System,My_Verbose);
      declare
         Aborted : Boolean := False;
      begin
         if Verbose then
            Put("Starting analysis on iteration: "&
                Long_Integer'Image(Iters_To_Stop));
         end if;
         if ATC_Enabled then
            select
               delay Analysis_Stop_Time;
               Aborted := True;
               Counter_Of_Aborted_Analysis :=
                 Long_Integer'Succ(Counter_Of_Aborted_Analysis);
            then abort
               The_Tool(The_System,My_Verbose);
            end select;
         else
            Aborted:=False;
            The_Tool(The_System,My_Verbose);
         end if;
        if Verbose then
            if Aborted then
               Put_Line("    -> Analysis aborted.");
            else
               Put_Line("    -> Analysis finished.");
            end if;
         end if;
         if Aborted then
            Schedulable := False;
         else
            Mast.Tools.Check_System_Schedulability
              (The_System,Schedulable,My_Verbose);
         end if;
         if not Aborted then
            Actual_Energy := Energy;
         else
            Actual_Energy := Long_Float'Last;
         end if;
         Stop_Algorithm := Stop_Condition;
      end;

      loop
         exit when Stop_Algorithm;

         Iters_With_The_Same_Temperature := 0;
         loop
            Iters_To_Stop := Iters_To_Stop+1;

            -- New priority assignment

            Neighbor := Get_Neighbor;
            Toggle_Priorities(Neighbor);
            Mast.Tools.Calculate_Ceilings_And_Levels
              (The_System,My_Verbose);
            declare
               Aborted : Boolean := False;
            begin
               My_Back_Up_System := My_System;
               if Verbose then
                  Put("Starting analysis on iteration: "&
                      Long_Integer'Image(Iters_To_Stop));
               end if;
               if ATC_Enabled then
                  select
                     delay Analysis_Stop_Time;
                     My_System := My_Back_Up_System;
                     Aborted := True;
                     Counter_Of_Aborted_Analysis :=
                       Long_Integer'Succ(Counter_Of_Aborted_Analysis);
                  then abort
                     The_Tool(The_System,My_Verbose);
                  end select;
               else
                  Aborted:=False;
                  The_Tool(The_System,My_Verbose);
               end if;
               if Verbose then
                  if Aborted then
                     Put_Line("    -> Analysis aborted.");
                  else
                     Put_Line("    -> Analysis finished.");
                  end if;
               end if;
               if Aborted then
                  Schedulable := False;
               else
                  Mast.Tools.Check_System_Schedulability
                    (The_System,Schedulable,My_Verbose);
               end if;
               Stop_Algorithm := Stop_Condition;
               exit when Stop_Algorithm;
               if not Aborted then
                  Neighbor_Energy := Energy;
               else
                  Neighbor_Energy := Actual_Energy;
               end if;
            end;

            if Neighbor_Energy < Minimum_Energy then
               Minimum_Energy := Neighbor_Energy;
               Iters_With_Greater_Energy := 0;
               Iters_With_The_Same_Temperature := 0;
            else
               Iters_With_Greater_Energy := Iters_With_Greater_Energy + 1;
               Iters_With_The_Same_Temperature :=
                 Iters_With_The_Same_Temperature +1;
            end if;

            if Neighbor_Energy < Actual_Energy then
               Actual_Energy := Neighbor_Energy;
               -- Remains the neighbor assignment of priorities
            else
               if Temperature /= 0.0 then
                  X := (Actual_Energy-Neighbor_Energy)/Temperature;
               else
                  X := -Long_Float'Last;
               end if;
               if Long_Float_Functions.Exp(X) >= Long_Float
                 (Ada.Numerics.Float_Random.Random(Float_Generator)) then
                  Actual_Energy := Neighbor_Energy;
                  -- Remains the neighbor assignment of priorities
               else
                  Toggle_Priorities(Neighbor);
                  -- Reestablish the priorities of actual assignment
               end if;
            end if;

            exit when Thermic_Equilibrium;
         end loop;

         Temperature := Cooling(Temperature);

      end loop;

      Restore_Optimum_Priorities;

      if Verbose then
         Put_Line("Linear Simulated Annealing statistics:");
         if Audsley_Stop_Time /= 0.0 then
            Put_Line
              ("   Number of times Audsley's algorithm was stopped ---> "&
               Long_Integer'Image(Counter_Of_Aborted_Audsley));
            Put_Line
              ("   Total number of iterations on Audsley's algorithm -> "&
               Long_Integer'Image(Counter_Of_Audsley));
         end if;
         Put_Line("   Number of times the analysis was stopped ----------> "&
                  Long_Integer'Image(Counter_Of_Aborted_Analysis));
         Put_Line("   Total number of iterations ------------------------> "&
                  Long_Integer'Image(Iters_To_Stop));
         if Overall_Schedulable then
            Put_Line("The priority assignment process "&
                     "makes the system schedulable");
         else
            Put_Line("The priority assignment process "&
                     "does not make the system schedulable");
         end if;
      end if;

   exception
      when Nothing_To_Do =>
         if Verbose then
            Put_Line("No more than one action per processing resource");
         end if;

   end Simulated_Annealing;

end Mast.Linear_Priority_Assignment_Tools;



