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

with Mast.Processing_Resources,Mast.Timers, Mast.Restrictions,
  Mast.Linear_Translation,  Mast.Tools.Schedulability_Index,
  Mast.Max_Numbers,
  Priority_Queues, Ada.Text_IO,
  Mast.Scheduling_Parameters,
  Mast.Scheduling_Policies;

use type Mast.Timers.System_Timer_Ref;
use type Mast.Tools.Schedulability_Index.Index;
use Ada.Text_IO;


package body Mast.Monoprocessor_Tools is


   Debug : constant Boolean := False;
   My_Verbose : constant Boolean := False;


   function Gcd (A, B : Integer) return Integer is
      M : Integer := A;
      N : Integer := B;
      T : Integer;
   begin
      while N /= 0 loop
         T := M;
         M := N;
         N := T mod N;
      end loop;
      return M;
   end Gcd;

   function Lcm (A, B : Integer) return Integer is
   begin
      if A = 0 or B = 0 then
         return 0;
      end if;
      return abs (A) * (abs (B) / Gcd (A, B));
   end Lcm;

   ------------------------
   -- Priority_Assignment --
   ------------------------

   procedure Priority_Assignment
     (The_System : in out MAST.Systems.System;
      The_Tool: in Mast.Tools.Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True)
   is

      type Processor_ID is new Natural;
      type Transaction_ID is new Natural;
      type Task_ID is new Natural;

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

      My_System : Translation.Linear_Transaction_System;

      Queue_Length : Natural;
      List_Of_Min_VP : Virtual_Priority;
      List_Of_Min_P, List_Of_Max_P : Priority;
      Optimization_In_Processor : Boolean := True;

      type List_For_Tasks is array
        (Task_ID_Type range 1..Max_Tasks_Per_Transaction)
        of Translation.Priority_Assignment_Vars;

      type List_For_Transactions is array
        (Transaction_ID_Type range 1..Max_Transactions)
        of List_For_Tasks;

      Pavs : List_For_Transactions;

      Sched_Index : Mast.Tools.Schedulability_Index.Index;

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

      ------------------------------------
      -- Deadlines_Greater_Than_Periods --
      ------------------------------------

      function Deadlines_Greater_Than_Periods return Boolean is
      begin
         for I in Transaction_Id_Type range 1..Max_Transactions
         loop
            exit when My_System(I).Ni=0;
            for J in 1..My_System(I).Ni
            loop
               if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                 not My_System(I).The_Task(J).Pav.Is_Polling
               then
                  if My_System(I).The_Task(J).Dij >
                    My_System(I).The_Task(J).Tij then
                     return True;
                  end if;
               end if;
            end loop;
         end loop;
         return False;
      end Deadlines_Greater_Than_Periods;

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

         Lists_For_VP : VP_Lists.Queue;
         Lists_For_P : P_Lists.Queue;

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
                        Lists_For_P);
                  else
                     VP_Lists.Enqueue
                       (Item1,
                        My_System(I).The_Task(J).Pav.Virtual_Prio,
                        Lists_For_VP);
                  end if;
               end if;
            end loop;
         end loop;

         Min_P := List_Of_Max_P;
         Min_VP := Max_Virtual_Priority;
         -- Set minumum priorities to maximum values

         while not VP_Lists.Empty(Lists_For_VP)
         loop
            VP_Lists.Dequeue(Item2,VP,Lists_For_VP);
            if VP <= Min_VP then
               -- New stage
               Max_P := Min_P;
               Max_VP := Min_VP;
               loop
                  if not P_Lists.Empty(Lists_For_P) then
                     P_Lists.Dequeue(Item1,Min_P,Lists_For_P);
                     Min_P := Priority'Max(Min_P,List_Of_Min_P);
                     Min_VP :=
                       My_System(Item1.Transaction).
                       The_Task(Item1.Action).Pav.Virtual_Prio;
                     if VP > Min_VP then
                        exit;
                     end if;
                  else
                     Min_P := List_Of_Min_P;
                     Min_VP := List_Of_Min_VP;
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

      end Priority_Mapping;

      -----------------------------------
      -- Deadline_Monotonic_Assignment --
      -----------------------------------

      procedure Deadline_Monotonic_Assignment is

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

         List_For_Processor : Deadlines_Lists.Queue;
         Item : Deadline_Element;
         Next_Priority : Virtual_Priority;
         Deadline : Time;

      begin

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

         for I in Transaction_ID_Type range 1..Max_Transactions
         loop
            exit when My_System(I).Ni=0;
            for J in 1..My_System(I).Ni
            loop
               if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                 not My_System(I).The_Task(J).Pav.Is_Polling
               then
                  Item := (Transaction => I,
                           Action => J);
                  Deadlines_Lists.Enqueue
                    (Item,
                     My_System(I).The_Task(J).Dij,
                     List_For_Processor);
               end if;
            end loop;
         end loop;

         declare
            J : Integer := 0;
            Background_Priority : Priority:= Priority'First;
         begin
            while not Deadlines_Lists.Empty(List_For_Processor)
            loop
               J := J+1;
               Deadlines_Lists.Dequeue
                 (Item,Deadline,List_For_Processor);
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
                      (My_System(Item.Transaction).The_Task(Item.Action).
                       Pav.Preassigned));
               end if;
               if My_System(Item.Transaction).The_Task(Item.Action).
                 Pav.Preassigned then
                  -- Check if the optimum priority assigment will be
                  -- performed for this processor
                  Optimization_In_Processor := False;
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
            Queue_Length := J;
            -- Store the number of task for optimizing
            -- priority assignment
            List_Of_Min_VP := Next_Priority;
            -- Store the minimum virtual priority assigned for the
            -- processor
            if Background_Priority > Scheduling_Policies.Min_Priority
              (My_System(Item.Transaction).The_Task(Item.Action).
               Pav.S_Policy_Ref.all)
            then
               List_Of_Min_P := Background_Priority;
            else
               List_Of_Min_P := Scheduling_Policies.Min_Priority
                 (My_System(Item.Transaction).The_Task(Item.Action).
                  Pav.S_Policy_Ref.all);
            end if;
            -- Store the maximum priority for the processor
            List_Of_Max_P := Scheduling_Policies.Max_Priority
              (My_System(Item.Transaction).The_Task(Item.Action).
               Pav.S_Policy_Ref.all);
            -- Store the maximum priority for the processor
            if J > Integer (List_Of_Max_P-List_Of_Min_P+1)
            then
               -- Check if the optimum priority assigment will be
               -- performed for the processor
               Optimization_In_Processor := False;
            end if;
         end;

         Priority_Mapping;

      end Deadline_Monotonic_Assignment;

      ---------------------------------
      -- Optimum_Priority_Assignment --
      ---------------------------------

      procedure Optimum_Priority_Assignment is

         type Task_Element is record
            Transaction : Transaction_Id_Type;
            Action : Task_Id_Type;
         end record;

         type Lists_Of_Task is
           array(Integer range 1..Queue_Length)
           of Task_Element;
         List_Of_Task : Lists_Of_Task;
         Num_Of_Task : Integer := 0;
         Item : Task_Element;
         Prio : Priority;
         Failed : Boolean;


      begin

         -- Extract the tasks
         for I in Transaction_Id_Type range 1..Max_Transactions
         loop
            exit when My_System(I).Ni=0;
            for J in 1..My_System(I).Ni
            loop
               if not My_System(I).The_Task(J).Pav.Hard_Prio and then
                 not My_System(I).The_Task(J).Pav.Is_Polling
               then
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

               Translation.Translate_Priorities(My_System,The_System);
               Save_Pavs;

               -- Check if task I is schedulable

               Mast.Tools.Calculate_Ceilings_And_Levels
                 (The_System,My_Verbose);
               The_Tool(The_System,My_Verbose);
               Translation.Translate_Linear_System_With_Results
                 (The_System,My_System,My_Verbose);
               Restore_Pavs;
               if My_System(List_Of_Task(I).Transaction).
                 The_Task(List_Of_Task(I).Action).Dij >=
                 My_System(List_Of_Task(I).Transaction).
                 The_Task(List_Of_Task(I).Action).Rij then
                  Failed := False;
                  exit;
               else
                  -- Exchange tasks I and J and their old priorities
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
                  Translation.Translate_Priorities(My_System,The_System);
                  Save_Pavs;
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

      end Optimum_Priority_Assignment;


   begin
      Translation.Translate_Linear_System
        (The_System,My_System,My_Verbose);

      Deadline_Monotonic_Assignment;
      if Deadlines_Greater_Than_Periods and Optimization_In_Processor then
         Optimum_Priority_Assignment;
      end if;

      Translation.Translate_Priorities(My_System,The_System);

      if Verbose then
         Mast.Tools.Calculate_Ceilings_And_Levels
           (The_System,My_Verbose);
         The_Tool(The_System,My_Verbose);
         Translation.Translate_Linear_System_With_Results
           (The_System,My_System,My_Verbose);
         Mast.Tools.Schedulability_Index.Calculate_Schedulability_Index
           (The_System,Sched_Index,My_Verbose);
         Put("Monoprocessor Priority Assignment with "&
             "Schedulability Index : ");
         Mast.Tools.Schedulability_Index.Print(Sched_Index);
      end if;

   end Priority_Assignment;

   -----------------
   -- RM_Analysis --
   -----------------

   procedure RM_Analysis
     (The_System : in out MAST.Systems.System;
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

      Transaction : Linear_Transaction_System;
      Ci, Bi,Ri,Rbi, Rik,Wik, Wiknew, Ti, Ji : Time;
      K : Transaction_Id;
      Preemptions : Integer;
      Ni : Task_Id_Type;
      Jeffect : constant array(Boolean) of Time:=(False=> 1.0, True=> 0.0);
      Unbounded_Time : Boolean;

   begin
      Translate_Linear_System(The_System,Transaction,Verbose);
      --show_linear_translation(Transaction);

      -- Loop for each transaction, I, under analysis

      for I in 1..Max_Transactions loop
         exit when Transaction(I).Ni=0;
         -- Calculate Rbi,Ci, Ji, Bi: only last task in the transaction is
         -- analyzed; other tasks in same transaction are considered
         -- independent
         Ni:=Transaction(I).Ni;
         Ci:=Transaction(I).The_Task(Ni).Cijown;
         Ti:=Transaction(I).The_Task(Ni).Tijown;
         Ji:=Transaction(I).The_Task(Ni).Jinit;
         Bi:=Transaction(I).The_Task(Ni).Bij;
         Rbi:=Transaction(I).The_Task(Ni).Cbijown;
         -- Calculate initial value for Wik
         Unbounded_Time:=False;
         --  Wik:=Bi+Ci;
         Ri:=0.0;
         -- Transaction(I).The_Task(Ni).Rbij:=Wik;
         for discriminant in 0..1 loop
            Wik:=Bi+Ci;
            if discriminant = 1 or discriminant = 0 then
               for J in 1..Max_Transactions loop
                  exit when Transaction(J).Ni=0;
                  for Tsk in 1..Transaction(J).Ni loop
                     if  Transaction(J).The_Task(Tsk).Prioij>=
                       Transaction(I).The_Task(Ni).Prioij and then
                       (J/=I or else Tsk/=Ni)
                     then
                        Wik:=Wik+Transaction(J).The_Task(Tsk).Cij;
                     end if;
                  end loop;
               end loop;
               Transaction(I).The_Task(Ni).Rbij:=Rbi;
            else
               Wik := Time_Interval(1);
               for tsk in 1..Max_Transactions loop
                  wik := Time_Interval(Lcm
                    (Integer(Wik),
                     Integer(Transaction(tsk).The_Task(Task_ID(1)).Tij)));
               end loop;
            end if;
            -- Iterate over the jobs, K, in the busy period
            if discriminant = 1 then
               K:=1;

               loop
                  -- Iterate until equation converges
                  loop
                     Wiknew:=Bi+Time(K)*Ci;
                     Preemptions := 0;
                     -- add contributions of high priority tasks
                     for J in 1..Max_Transactions loop
                        exit when Transaction(J).Ni=0;
                        for Tsk in 1..Transaction(J).Ni loop
                           if  Transaction(J).The_Task(Tsk).Prioij>=
                             Transaction(I).The_Task(Ni).Prioij and then
                             (J/=I or else Tsk/=Ni)
                           then
                              if Transaction(J).The_Task(Tsk).Model=
                                Unbounded_Effects
                              then
                                 Wiknew:= Large_Time;
                                 Wik:=Large_Time;
                                 Unbounded_Time:=True;
                                 exit;
                              else
                                 Wiknew:=Wiknew+Ceiling
                                   ((Wik+Transaction(J).The_Task(Tsk).Jinit*
                                      Jeffect(Transaction(J).The_Task(Tsk).
                                            Jitter_Avoidance))/
                                          Transaction(J).The_Task(Tsk).Tij)*
                                     Transaction(J).The_Task(Tsk).Cij;
                                 Preemptions := Preemptions + Integer
                                   (Ceiling(Wik/
                                        Transaction(J).The_Task(Tsk).Tij));
                              end if;
                           end if;
                        end loop;
                        exit when Unbounded_Time;
                     end loop;
                     exit when Unbounded_Time or else Wik=Wiknew;
                     Wik:=Wiknew;
                  end loop;
                  exit when Unbounded_Time;
                  Rik:=Wik-Ti*(Time(K)-1.0);
                  -- keep the worst case result
                  if Rik>Ri then
                     Ri:=Rik;
                  end if;
                  -- check if busy period is too long
                  if Ri>Analysis_Bound then
                     Unbounded_Time:=True;
                     exit;
                  end if;
                  -- determine if busy period is over
                  exit when Rik<=Ti;
                  K:=K+1;
                  Wik:=Wik+Ci;
               end loop;
            else
               K:=1;

               loop
                  -- Iterate until equation converges
                  loop
                     Wiknew:=Bi+Time(K)*Ci;
                     Preemptions := 0;
                     -- add contributions of high priority tasks
                     for J in 1..Max_Transactions loop
                        exit when Transaction(J).Ni=0;
                        for Tsk in 1..Transaction(J).Ni loop
                           if  Transaction(J).The_Task(Tsk).Prioij>=
                             Transaction(I).The_Task(Ni).Prioij and then
                             (J/=I or else Tsk/=Ni)
                           then
                              if Transaction(J).The_Task(Tsk).Model=
                                Unbounded_Effects
                              then
                                 Wiknew:= Large_Time;
                                 Wik:=Large_Time;
                                 Unbounded_Time:=True;
                                 exit;
                              else
                                 Wiknew:=Wiknew+Ceiling
                                   ((Wik+Transaction(J).The_Task(Tsk).Jinit*
                                      Jeffect(Transaction(J).The_Task(Tsk).
                                            Jitter_Avoidance))/
                                          Transaction(J).The_Task(Tsk).Tij)*
                                     Transaction(J).The_Task(Tsk).Cij;
                                 Preemptions := Preemptions + Integer
                                      (Wik/Transaction(J).The_Task(Tsk).Tij);
                              end if;
                           end if;
                        end loop;
                        exit when Unbounded_Time;
                     end loop;
                     exit when Unbounded_Time or else Wik=Wiknew;
                     Wik:=Wiknew;
                  end loop;
                  exit when Unbounded_Time;
                  if Ri>Analysis_Bound then
                     Unbounded_Time:=True;
                     exit;
                  end if;
                  -- determine if busy period is over
                  exit when Rik<=Ti;
                  K:=K+1;
                  Wik:=Wik+Ci;
               end loop;
            end if;

         end loop;
         -- Store the worst-case response time obtained
         if Unbounded_Time then
            Transaction(I).The_Task(Ni).Rij:=Large_Time;
            Transaction(I).The_Task(Ni).Jij:=Large_Time;
         else
            Transaction(I).The_Task(Ni).Rij:=Ri+Ji;
            Transaction(I).The_Task(Ni).Jij:=Ri+Ji-Rbi;
         end if;
         Put_Line("ResponseTime:" &
                    Time'Image(Transaction(I).The_Task(Ni).Rij));
         if Transaction(I).The_Task(Ni).Rij > Transaction(I).The_Task(Ni).Dij
         then
            Put_Line ("DMtask:" & Transaction_ID'Image(I));
         end if;
         if I = Max_Transactions then
            if Transaction(I).The_Task(Ni).Rij
              > Time_Interval(952560000) then
                  Put_Line("L: " & Integer'Image(-1));
               else
                  Put_Line("L:" &  Time'Image(Transaction(I).The_Task(Ni).Rij));
               end if;
         end if;
      end loop;
      Translate_Linear_Analysis_Results(Transaction,The_System);
   end RM_Analysis;

   ---------------------------------
   -- Varying_Priorities_Analysis --
   ---------------------------------

   procedure Varying_Priorities_Analysis
     (The_System : in out MAST.Systems.System;
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

      procedure Find_Canonical_Form
        (Original  : in  Transaction_Data;
         Canonical : out Transaction_Data)
      is
      begin
         Canonical:=Original;
         for J in reverse 2..Canonical.Ni loop
            if Canonical.The_Task(J-1).Prioij>Canonical.The_Task(J).Prioij then
               Canonical.The_Task(J-1).Prioij:=Canonical.The_Task(J).Prioij;
            end if;
         end loop;
      end Find_Canonical_Form;

      type H_Set_Parameters is record
         Ci,Ji,Ti : Time;
         Pi : Priority;
         Trans : Transaction_Id;
      end record;

      type Time_Array is array(Transaction_Id_Type) of Time;
      type H_Set_Array is array(Transaction_Id_Type) of H_Set_Parameters;

      procedure Find_Sets
        (Transaction : in Linear_Transaction_System;
         I           : in Transaction_Id;
         Prio        : in Priority;
         H           : out H_Set_Array;
         NumH        : out Transaction_Id;
         HL          : out Time_Array;
         NumHL       : out Transaction_Id;
         MaxLH       : out Time;
         Unbounded_Time : out Boolean)
      is
         Ci : Time;
         Is_H_Segment, Finished : Boolean;
         L_Segment : Task_Id_Type;
         Min_Prio : Priority;
         Jeffect : constant array(Boolean) of Time:=(False=> 1.0, True=> 0.0);
      begin
         Unbounded_Time:=False;
         NumH:=0;
         NumHL:=0;
         MaxLH:=0.0;
         -- loop for each transaction except the one under analysis
         for J in 1..Max_Transactions loop
            exit when Transaction(J).Ni=0;
            if J/=I then
               Ci:=0.0;
               Is_H_Segment:=True;
               L_Segment:=1;
               Min_Prio:=Priority'Last;
               -- Loop for all actions in the transaction
               for Tsk in 1..Transaction(J).Ni loop
                  if Transaction(J).The_Task(Tsk).Prioij<Min_Prio then
                     Min_Prio:=Transaction(J).The_Task(Tsk).Prioij;
                  end if;
                  if Transaction(J).The_Task(Tsk).Prioij>=Prio then
                     if Transaction(J).The_Task(Tsk).Model=Unbounded_Effects
                     then
                        Unbounded_Time:=True;
                        return;
                     end if;
                     Ci:=Ci+Transaction(J).The_Task(Tsk).Cij;
                  else
                     Is_H_Segment:=False;
                     if Tsk>1 then
                        NumHL:=NumHL+1;
                        HL(NumHL):=Ci;
                        L_Segment:=Tsk;
                     end if;
                     exit;
                  end if;
               end loop;
               if Is_H_Segment then
                  NumH:=NumH+1;
                  H(NumH).Ci:=Ci;
                  H(NumH).Ji:=Transaction(J).The_Task(1).Jinit*
                    Jeffect(Transaction(J).The_Task(1).Jitter_Avoidance);
                  for Tsk in 2..Transaction(J).Ni loop
                     H(NumH).Ji:=H(NumH).Ji+Transaction(J).The_Task(1).Jinit*
                       Jeffect(Transaction(J).The_Task(1).Jitter_Avoidance);
                  end loop;
                  H(NumH).Ti:=Transaction(J).The_Task(1).Tij;
                  H(NumH).Pi:=Min_Prio;
                  H(NumH).Trans:=J;
               else
                  -- Search for LH segments
                  Finished :=False;
                  while L_Segment<Transaction(J).Ni and then not Finished loop
                     Ci:=0.0;
                     Finished:=True;
                     for Tsk in L_Segment+1..Transaction(J).Ni loop
                        if Transaction(J).The_Task(Tsk).Prioij>=Prio then
                           Ci:=Ci+Transaction(J).The_Task(Tsk).Cij;
                        else
                           Finished:=False;
                           L_Segment:=Tsk;
                           exit;
                        end if;
                     end loop;
                     if Ci>MaxLH then
                        MaxLH:=Ci;
                     end if;
                  end loop;
               end if;
            end if;
         end loop;
      end Find_Sets;

      procedure Recalculate_Sets
        (Transaction : in Linear_Transaction_System;
         Prio        : in Priority;
         H           : in H_Set_Array;
         NumH        : in Transaction_Id;
         H_New       : out H_Set_Array;
         NumH_new    : out Transaction_Id;
         HL_new      : out Time_Array;
         NumHL_new   : out Transaction_Id;
         Diff        : out H_Set_Array;
         N_Diff      : out Transaction_Id)
      is
         Ci : Time;
         I : Transaction_Id;
      begin
         Numh_New:=0;
         NumHL_New:=0;
         N_Diff:=0;
         for K in 1..NumH loop
            if H(K).Pi>=Prio then
               -- Is H transaction
               Numh_New:=Numh_New+1;
               H_New(Numh_New):=H(K);
            else
               -- Is in the difference (was H transaction, and now it's not)
               N_Diff:=N_Diff+1;
               Diff(N_Diff):=H(K);
               I:=H(K).Trans;
               if Transaction(I).The_Task(1).Prioij>=Prio then
                  -- Is HL transaction
                  Ci:=Transaction(I).The_Task(1).Cij;
                  for Tsk in 2..Transaction(I).Ni loop
                     if Transaction(I).The_Task(Tsk).Prioij>=Prio then
                        Ci:=Ci+Transaction(I).The_Task(Tsk).Cij;
                     else
                        exit;
                     end if;
                  end loop;
                  NumHL_New:=NumHL_New+1;
                  HL_New(NumHL_New):=Ci;
               end if;
            end if;
         end loop;
      end Recalculate_Sets;

      Canonical : Transaction_Data;
      Transaction : Linear_Transaction_System;
      H1,H_Old,H_New,Diff : H_Set_Array;
      NumH1,NumH_Old,NumH_New,N_Diff : Transaction_Id;
      HL1,HL_New : Time_Array;
      NumHL1,NumHL_New : Transaction_Id;
      MaxLH : Time;
      Ni : Task_Id_Type;
      Prio_Level : Priority;
      S, Wik, Wiknew, Ti, Bi, Ci, Ci1, Rij, Ri, Rik, Rbi : Time;
      Unbounded_Time : Boolean;
      PCP_Only : Boolean;
      NumJobs : Natural;

   begin
      Translate_Linear_System(The_System,Transaction,Verbose);
      PCP_Only := Restrictions.PCP_Only(The_System,False);
      --show_linear_translation(Transaction);

      -- Loop for each transaction, I, under analysis
      for I in 1..Max_Transactions loop
         exit when Transaction(I).Ni=0;
         -- Calculate best-case response times
         Rbi:=0.0;
         for Tsk in 1..Transaction(I).Ni loop
            Rbi:=Rbi+Transaction(I).The_Task(Tsk).Cbijown;
            Transaction(I).The_Task(Tsk).Rbij:=Rbi;
         end loop;
         -- Find canonical form
         Find_Canonical_Form(Transaction(I),Canonical);
         Ni:=Canonical.Ni;
         Prio_Level:=Canonical.The_Task(1).Prioij;
         Find_Sets(Transaction,I,Prio_Level,H1,NumH1,
                   HL1,NumHL1,MaxLH,Unbounded_Time);
         if Unbounded_Time then
            for J in 1..Ni loop
               Transaction(I).The_Task(J).Rij:=Large_Time;
            end loop;
         else
            Ti:=Canonical.The_Task(1).Tijown;

            -- Determine Ci and Bi by taking into account blocking times
            -- of all segments
            Bi:=0.0;
            Ci:=0.0;
            for J in 1..Ni loop
               Ci:=Ci+Canonical.The_Task(J).Cijown;
               if PCP_Only then
                  if Canonical.The_Task(J).Bij>MaxLH then
                     MaxLH:=Canonical.The_Task(J).Bij;
                  end if;
               else
                  Bi:=Bi+Canonical.The_Task(J).Bij;
               end if;
            end loop;

            -- Determine the length of the busy period
            S:=Bi+MaxLH;
            for K in 1..NumHL1 loop
               S:=S+HL1(K);
            end loop;
            Wik:=S+Ci;
            for K in 1..NumH1 loop
               Wik:=Wik+H1(K).Ci;
            end loop;
            Numjobs:=0;
            Ri:=0.0;
            loop
               Numjobs:=Numjobs+1;
               loop
                  Wiknew:=S+Time(Numjobs)*Ci;
                  for K in 1..NumH1 loop
                     Wiknew:=Wiknew+Ceiling((Wik+H1(K).Ji)/
                                                 H1(K).Ti)*H1(K).Ci;
                  end loop;
                  exit when Wik=Wiknew;
                  Wik:=Wiknew;
               end loop;
               Rik:=Wik-Ti*Time(numjobs-1);
               -- keep the worst case result
               if Rik>Ri then
                  Ri:=Rik;
               end if;
               -- check if busy period is too long
               if Ri>Analysis_Bound then
                  Unbounded_Time:=True;
                  exit;
               end if;
               -- determine if busy period is over
               exit when Rik<=Ti;
               Wik:=Wik+Ci;
            end loop;
            Numjobs:=Natural(Ceiling(Wik/Ti));

            if Unbounded_Time then
               for J in 1..Ni loop
                  Transaction(I).The_Task(J).Rij:=Large_Time;
               end loop;
            else

               -- Initialize the completion times
               for J in 1..Ni loop
                  Transaction(I).The_Task(J).Rij:=0.0;
               end loop;

               -- loop for all jobs in the busy period
               for Job in 1..Numjobs loop
                  -- Calculate response time of the job-th job of first action
                  Ci1:=Canonical.The_Task(1).Cijown;
                  S:=Bi+Ci1+Time(Job-1)*Ci+MaxLH;
                  for K in 1..NumHL1 loop
                     S:=S+HL1(K);
                  end loop;
                  Wik:=S;
                  for K in 1..NumH1 loop
                     Wik:=Wik+H1(K).Ci;
                  end loop;
                  loop
                     Wiknew:=S;
                     for K in 1..NumH1 loop
                        Wiknew:=Wiknew+Ceiling((Wik+H1(K).Ji)/H1(K).Ti)*
                          H1(K).Ci;
                     end loop;
                     exit when Wik=Wiknew;
                     Wik:=Wiknew;
                  end loop;
                  Rij:=Wik-Time(Job-1)*Ti;
                  if Rij > Transaction(I).The_Task(1).Rij and then
                    Prio_Level=Transaction(I).The_Task(1).Prioij
                  then
                     Transaction(I).The_Task(1).Rij:=Rij;
                  end if;
                  H_Old:=H1;
                  NumH_Old:=NumH1;
                  -- loop for all actions, j, in the canonical form
                  for J in 2..Ni loop
                     -- Reclassify event sequences relative to action aij
                     Prio_Level:=Canonical.The_Task(j).Prioij;
                     Recalculate_Sets
                       (Transaction,Prio_Level,H_Old,NumH_Old,H_New,
                        NumH_New,HL_New,NumHL_New,Diff,N_Diff);
                     -- Calculate response time of the job-th job of aij
                     S:=S+Canonical.The_Task(J).Cijown;
                     for K in 1..NumHL_new loop
                        S:=S+HL_new(K);
                     end loop;
                     for K in 1..N_Diff loop
                        S:=S+Ceiling((Wik+Diff(K).Ji)/
                                          Diff(K).Ti)*Diff(K).Ci;
                     end loop;
                     loop
                        Wiknew:=S;
                        for K in 1..NumH_New loop
                           Wiknew:=Wiknew+Ceiling
                             ((Wik+H_New(K).Ji)/H_new(K).Ti)*H_New(K).Ci;
                        end loop;
                        exit when Wik=Wiknew;
                        Wik:=Wiknew;
                     end loop;
                     Rij:=Wik-Time(Job-1)*Ti;
                     if Rij > Transaction(I).The_Task(J).Rij and then
                       Prio_Level=Transaction(I).The_Task(J).Prioij
                     then
                        Transaction(I).The_Task(J).Rij:=Rij;
                     end if;
                     H_Old:=H_New;
                     NumH_Old:=NumH_New;
                  end loop;
               end loop;
            end if;
         end if;
         -- Adjust the worst-case response times obtained
         if not Unbounded_Time then
            for Tsk in 1..Transaction(I).Ni loop
               if Transaction(I).The_Task(Tsk).Rij>0.0 then
                  Transaction(I).The_Task(Tsk).Rij:=
                    Transaction(I).The_Task(Tsk).Rij+
                    Transaction(I).The_Task(1).Jinit;
                  Transaction(I).The_Task(Tsk).Jij:=
                    Transaction(I).The_Task(Tsk).Rij-
                    Transaction(I).The_Task(Tsk).Rbij;
               else
                  Transaction(I).The_Task(Tsk).Rbij:=0.0;
                  Transaction(I).The_Task(Tsk).Jij:=0.0;
               end if;
            end loop;
         end if;
      end loop;
      -- Put the results in place
      Translate_Linear_Analysis_Results(Transaction,The_System);
   end Varying_Priorities_Analysis;

end Mast.Monoprocessor_Tools;
