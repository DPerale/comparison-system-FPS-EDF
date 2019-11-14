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

with Mast.Tool_Exceptions,
  Mast.Linear_Translation,
  Mast.Processing_Resources,
  Mast.Max_Numbers,
  Mast.Scheduling_Servers,
  Mast.Schedulers,
  Mast.Scheduling_Parameters,
  Mast.Synchronization_Parameters,
  Mast.Transaction_Operations,
  Mast.Transactions,
  Mast.Graphs, Mast.Graphs.Event_Handlers, Mast.Graphs.Links,
  Mast.Timing_Requirements,
  Priority_Queues,
  Var_Strings,
  Ada.Text_IO;

use Ada.Text_IO;
use type Mast.Scheduling_Parameters.Sched_Parameters_Ref;
use type Mast.Synchronization_Parameters.Synch_Parameters_Ref;
use type Mast.Scheduling_Servers.Lists.Index;

package body Mast.EDF_Tools is

   ------------
   -- Min0 --
   ------------

   function Min0(X,Y:Time) return Time is
   begin
      return Time'Max(Time'Min(X,Y),0.0);
   end Min0;

   -------------------------
   -- Deadline_Assignment --
   -------------------------

   procedure Deadline_Assignment
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True)
   is
      Already_Assigned : Scheduling_Servers.Lists.List;

      procedure Assign_Deadline
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref)
      is
         A_Link_Ref : MAST.Graphs.Link_Ref;
         T_Req_Ref : Timing_Requirements.Timing_Requirement_Ref;
         The_Deadline : Time;
         Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
         S_Params_Ref : Scheduling_Parameters.Sched_Parameters_Ref;

      begin
         if The_Event_Handler_Ref.all in Graphs.Event_Handlers.Activity'Class
         then
            A_Link_Ref:=Graphs.Event_Handlers.Output_Link
              (Graphs.Event_Handlers.Activity'Class
               (The_Event_Handler_Ref.all));
            if Graphs.Has_Timing_Requirements(A_Link_Ref.all) then
               T_Req_Ref:=Graphs.Links.Link_Timing_Requirements
                 (Graphs.Links.Regular_Link'Class(A_Link_Ref.all));
               if T_Req_Ref.all in Timing_Requirements.Deadline'Class then
                  The_Deadline:=Timing_Requirements.The_Deadline
                    (Timing_Requirements.Deadline'Class(T_Req_Ref.all));
                  Srvr_Ref:=Graphs.Event_Handlers.Activity_Server
                    (Graphs.Event_Handlers.Activity'Class
                     (The_Event_Handler_Ref.all));
                  S_Params_Ref:=Scheduling_Servers.Server_Sched_Parameters
                    (Srvr_Ref.all);
                  if S_Params_Ref/=null and then
                    S_Params_Ref.all in
                    Scheduling_Parameters.EDF_Parameters'Class
                    and then
                    not Scheduling_Parameters.Preassigned
                    (Scheduling_Parameters.EDF_Parameters'Class
                     (S_Params_Ref.all))
                  then
                     if Scheduling_Servers.Lists.Find
                       (Scheduling_Servers.Name(Srvr_Ref),Already_Assigned)=
                       Scheduling_Servers.Lists.Null_Index
                     then
                        Scheduling_Parameters.Set_Deadline
                          (Scheduling_Parameters.EDF_Parameters'Class
                           (S_Params_Ref.all),The_Deadline);
                        Scheduling_Servers.Lists.Add
                          (Srvr_Ref,Already_Assigned);
                     else
                        Scheduling_Parameters.Set_Deadline
                          (Scheduling_Parameters.EDF_Parameters'Class
                           (S_Params_Ref.all),Time'Min
                           (The_Deadline,Scheduling_Parameters.Deadline
                            (Scheduling_Parameters.EDF_Parameters'Class
                             (S_Params_Ref.all))));
                     end if;
                  end if;
               end if;
            end if;
         end if;
      end Assign_Deadline;

      procedure Null_Operation_For_Links
        (Trans_Ref : MAST.Transactions.Transaction_Ref;
         The_Link_Ref : MAST.Graphs.Link_Ref) is
      begin
         null;
      end Null_Operation_For_Links;

      procedure Iterate_Transaction_Paths is new
        MAST.Transaction_Operations.Traverse_Paths_From_Link_Once
        (Operation_For_Links  => Null_Operation_For_Links,
         Operation_For_Event_Handlers => Assign_Deadline);

      Trans_Ref : MAST.Transactions.Transaction_Ref;
      Iterator : Transactions.Lists.Index;
      Link_Iterator : Transactions.Link_Iteration_Object;
      A_Link_Ref : MAST.Graphs.Link_Ref;

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

      package Ordered_Queue is new Priority_Queues
        (Element  => Synchronization_Parameters.Synch_Parameters_Ref,
         Priority => Time,
           ">"      => "<", -- reverse order
           "="      => "=");

      type P_Level_List is array(Integer range <>) of
        Synchronization_Parameters.Synch_Parameters_Ref;
      Transaction : Linear_Transaction_System;
      PL_Order : Time;
      Current_Level, New_Level : Preemption_Level;
      Pl_Counter : Natural:=0;
      Ordered_List : Ordered_Queue.Queue;
      Synch_P_Ref : Synchronization_Parameters.Synch_Parameters_Ref;
      Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
      Srvr_Iterator : Scheduling_Servers.Lists.Iteration_Object;

   begin

      -- Assign timing requirements to scheduling deadlines
      -- it does so to each scheduling server referenced by an activity that
      -- verifies:
      --    - it has a timing requirement at its output event
      --    - it has an EDF scheduling server whose deadline is not preassigned
      -- If several timing requirements exist, the shortest deadline is chosen
      -- loop for all paths starting from input Links
      MAST.Transactions.Lists.Rewind(The_System.Transactions,Iterator);
      for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions) loop
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Iterator);
         MAST.Transactions.Rewind_External_Event_Links
           (Trans_Ref.all,Link_Iterator);
         for I in 1..MAST.Transactions.Num_Of_External_Event_Links
           (Trans_Ref.all)
         loop
            MAST.Transactions.Get_Next_External_Event_Link
              (Trans_Ref.all,A_Link_Ref,Link_Iterator);
            Iterate_Transaction_Paths (Trans_Ref,A_Link_Ref);
         end loop;
      end loop;

      -- Create synchronization objects for EDF scheduling servers

      Scheduling_Servers.Lists.Rewind
        (The_System.Scheduling_Servers,Srvr_Iterator);
      for I in 1..Scheduling_Servers.Lists.Size(The_System.Scheduling_Servers)
      loop
         Scheduling_Servers.Lists.Get_Next_Item
           (Srvr_Ref,The_System.Scheduling_Servers,Srvr_Iterator);
         if Scheduling_Servers.Server_Sched_Parameters(Srvr_Ref.all).all
           in Scheduling_Parameters.EDF_Parameters'Class and then
           Scheduling_Servers.Server_Synch_Parameters(Srvr_Ref.all)=null
         then
            Synch_P_Ref:=new Synchronization_Parameters.SRP_Parameters;
            Scheduling_Servers.Set_Server_Synch_Parameters
              (Srvr_Ref.all,Synch_P_Ref);
         end if;
      end loop;

      -- Calculate preemption levels for tasks, according to
      --   scheduling deadlines and jitter terms

      Translate_Linear_System(The_System,Transaction,Verbose);
      -- Loop for each transaction, I, under analysis
      for I in 1..Max_Transactions loop
         exit when Transaction(I).Ni=0;
         -- Loop for each task, tsk, in the transaction
         for Tsk in 1..Transaction(I).Ni loop
            if Transaction(I).The_Task(Tsk).Pav.Synch_P_Ref/=null and then
              Transaction(I).The_Task(Tsk).Pav.Synch_P_Ref.all in
              Synchronization_Parameters.SRP_Parameters'Class
            then
               Pl_Order:=1.0/(Transaction(I).The_Task(Tsk).SDij-
                              Transaction(I).The_Task(Tsk).Jinit);
                  -- Add the parameters object and its PL to a priority queue
               Ordered_Queue.Enqueue
                 (Transaction(I).The_Task(Tsk).Pav.Synch_P_Ref,Pl_Order,
                  Ordered_List);
               Pl_Counter:=Pl_Counter+1;
            end if;
         end loop;
      end loop;
      -- Obtain the preemption levels out of the priority queue
      declare
         Pl_List : P_Level_List(1..Pl_Counter);
      begin
         for I in 1..Pl_Counter loop
            Ordered_Queue.Dequeue(Synch_P_Ref,Pl_Order,Ordered_List);
            Pl_List(I):=Synch_P_Ref;
         end loop;

         -- Assign levels and resolve preassigned levels
         Current_Level:=0;
         for I in 1..Pl_Counter loop
            if Synchronization_Parameters.Preassigned
              (Synchronization_Parameters.SRP_Parameters'Class
               (Pl_List(I).all))
            then
               New_Level:=Synchronization_Parameters.The_Preemption_Level
                 (Synchronization_Parameters.SRP_Parameters'Class
                  (Pl_List(I).all));
               if New_Level<Current_Level then
                  for J in reverse I-1..1 loop
                     exit when
                       Synchronization_Parameters.The_Preemption_Level
                       (Synchronization_Parameters.SRP_Parameters'Class
                        (Pl_List(J).all))<=New_Level;
                     if Synchronization_Parameters.Preassigned
                       (Synchronization_Parameters.SRP_Parameters'Class
                        (Pl_List(J).all))
                     then
                        if Verbose then
                           Put_Line
                             ("Preassigned task preemption levels "&
                              "out of order");
                        end if;
                        Tool_Exceptions.Set_Tool_Failure_Message
                          ("Preassigned task preemption levels out of order");
                        raise Tool_Exceptions.Tool_Failure;
                     end if;
                     Synchronization_Parameters.Set_Preemption_Level
                       (Synchronization_Parameters.SRP_Parameters'Class
                        (Pl_List(J).all),New_Level);
                  end loop;
               else
                  Current_Level:=New_Level;
               end if;
            else
               Current_Level:=Current_Level+1;
               Synchronization_Parameters.Set_Preemption_Level
                 (Synchronization_Parameters.SRP_Parameters'Class
                  (Pl_List(I).all),Current_Level);
            end if;
         end loop;
      end;

   end Deadline_Assignment;

   --------------------------------
   -- EDF_Monoprocessor_Analysis --
   --------------------------------

   procedure EDF_Monoprocessor_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True)
   is
   begin
      -- May be implemented as a special case in the future,
      -- to optimize execution time
      EDF_Within_Priorities_Analysis(The_System,Verbose);
   end EDF_Monoprocessor_Analysis;

   ------------------------------------
   -- EDF_Within_Priorities_Analysis --
   ------------------------------------

   procedure EDF_Within_Priorities_Analysis
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
      Ci, Bi,Ri,Rbi, Rik,Wik, Wiknew, Ti, Ji, Pi_Ti : Time;
      Di : Time;       --scheduling deadline (relative)
      Si : Sched_Type; -- kind of scheduler (FP or EDF)
      L : Time;        -- length of busy period
      A, Da, E : Time;    -- phase of EDF task, and associated deadline
      Qi, Qf : Integer;
      Qti, Qtf : Time;
      P : Transaction_Id;
      Max_Task : Transaction_ID := Max_Transactions;
      Ni : Task_Id_Type;
      Jeffect : constant array(Boolean) of Time:=(False=> 1.0, True=> 0.0);
      Unbounded_Time : Boolean;

   begin
      Translate_Linear_System(The_System,Transaction,Verbose);
      --show_linear_translation(Transaction);
      Pi_Ti := Time(0);
      -- Loop for each transaction, I, under analysis
      --  for I in 1..Transaction_ID(1) loop
      for I in 1..Max_Task loop
         --  Put_Line("I: " & Transaction_ID'Image(I));
         exit when Max_Task = Transaction_ID(1);
         --  Put_Line("I: " & Transaction_ID'Image(I));
         exit when Transaction(I).Ni=0;
         -- Calculate Rbi,Ci, Ji, Bi: only last task in the transaction is
         -- analyzed; other tasks in same transaction are considered
         -- independent
         Ni:=Transaction(I).Ni;
         Ci:=Transaction(I).The_Task(Ni).Cijown;
         Ti:=Transaction(I).The_Task(Ni).Tijown;
         Ji:=Transaction(I).The_Task(Ni).Jinit;
         di:=Transaction(I).The_Task(Ni).Sdij;
         Si:=Transaction(I).The_Task(Ni).Schedij;
         Bi:=Transaction(I).The_Task(Ni).Bij;
         Rbi:=Transaction(I).The_Task(Ni).Cbijown;

         if Si=FP then
            -- Calculate initial value for Wik
            Unbounded_Time:=False;
            Wik:=Bi+Ci;
            Ri:=0.0;
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
            -- Iterate over the jobs, P, in the busy period
            P:=1;
            loop
               -- Iterate until equation converges
               loop
                  Wiknew:=Bi+Time(P)*Ci;
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
                              Put_Line("Ueffct2");
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
                           end if;
                        end if;
                     end loop;
                     exit when Unbounded_Time;
                  end loop;
                  exit when Unbounded_Time or else Wik=Wiknew;
                  Wik:=Wiknew;
               end loop;
               exit when Unbounded_Time;
               Rik:=Wik-Ti*(Time(P)-1.0);
               -- keep the worst case result
               if Rik>Ri then
                  Ri:=Rik;
               end if;
               -- check if busy period is too long
               if Ri>Analysis_Bound * 1.4 then
                  Put_Line("Utime1");
                  Unbounded_Time:=True;
                  exit;
               end if;
               -- determine if busy period is over
               exit when Rik<=Ti;
               P:=P+1;
               Wik:=Wik+Ci;
            end loop;
            -- Store the worst-case response time obtained
            if Unbounded_Time then
               Transaction(I).The_Task(Ni).Rij:=Large_Time;
               Transaction(I).The_Task(Ni).Jij:=Large_Time;
            else
               Transaction(I).The_Task(Ni).Rij:=Ri+Ji;
               Transaction(I).The_Task(Ni).Jij:=Ri+Ji-Rbi;
            end if;
         else -- EDF task under analysis
              -- Calculate length of busy period
            Unbounded_Time:=False;
            Wik:=Bi;   -- blocking time (no WCET?)
            L:=0.0;
            for J in 1..Max_Transactions loop
               exit when Transaction(J).Ni=0;
               for Tsk in 1..Transaction(J).Ni loop
                  if  Transaction(J).The_Task(Tsk).Prioij>=
                    Transaction(I).The_Task(Ni).Prioij
                  then
                     Wik:=Wik+Transaction(J).The_Task(Tsk).Cij;
                     --  wik + WCET degli altri task
                  end if;
               end loop;
            end loop;
            -- qui abbiamo
            -- wik = blocking time i + WCET altri task j

            -- Iterate until equation converges
            loop
               Wiknew:=Bi;
               -- add contributions of high priority tasks
               for J in 1..Max_Transactions loop
                  exit when Transaction(J).Ni=0;
                  for Tsk in 1..Transaction(J).Ni loop
                     if  Transaction(J).The_Task(Tsk).Prioij>=
                       Transaction(I).The_Task(Ni).Prioij
                     then
                        if Transaction(J).The_Task(Tsk).Model=
                          Unbounded_Effects
                        then
                           Put_Line("Ueffct1");
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
                           -- wiknew + ceiling (
                           --     wik + (jitter * (0 or 1)) / (periodo * WCET)
                        end if;
                     end if;
                  end loop;
               end loop;
               exit when Unbounded_Time or else Wik=Wiknew;
               Wik:=Wiknew;
            end loop;
            --  Put(" wik 2    ");
            --  Put_Line(Time_Interval'Image(Wik));
            L:=Wik;
            if I = Transaction_ID(1) then
               if L > Time_Interval(952560000) then
                  Put_Line("L: " & Integer'Image(-1));
               else
                  Put_Line("L:" & Time_Interval'Image(L));
               end if;
            end if;
            --  Put("L: ");
            --  Put_Line(Time'Image(L));
            -- check if busy period is too long
            if L>Time_Interval(952560000) then
               --  Put_Line(Time_Interval'Image(L));
--                 Put_Line(Time_Interval'Image(Analysis_Bound * 100000.0));
--                 Put_Line(Time_Interval'Image(Analysis_Bound));
--                 Put_Line("Utime2");
               L:=Time_Interval(952560000);
               Max_Task := Transaction_ID(1);
               --  Unbounded_Time:=True;
            end if;
            Unbounded_Time:=False;
            if not Unbounded_Time then
               -- Calculate worst-case response times
               Unbounded_Time:=False;
               Ri:=0.0;
               Transaction(I).The_Task(Ni).Rbij:=Rbi;
               --  Put_Line("Ji: " & Time'Image(Ji));
               --  Put_Line("-------------------------------------------");
               -- Iterate over the jobs, P, in the busy period
               for P in 1..Integer(Ceiling((L+Ji)/Ti))
               loop
                  --  Put_Line("P: " & Integer'Image(P));
                  -- Iterate for all possible coincident deadlines
                  for K in 1..Max_Transactions loop
                     --  Put_Line("K: " & Transaction_ID'Image(K));
                     exit when Transaction(K).Ni=0;
                     for KTsk in 1..Transaction(K).Ni loop

                        if  Transaction(K).The_Task(KTsk).Prioij=
                          Transaction(I).The_Task(Ni).Prioij
                        then
                           E:=Time(P-1)*Ti-Ji+Di;
                           --  Put_Line("E: " & Time'Image(E));
                           Qti:=Ceiling
                             ((E+Transaction(K).The_Task(Ktsk).Jinit-
                               Transaction(K).The_Task(Ktsk).SDij)/
                                Transaction(K).The_Task(Ktsk).Tijown)+1.0;
                           --  Put_Line("Qti: " & Time'Image(Qti));
                           if Qti>=Time(Integer'Last) then
                              Qi:=Integer'Last;
                           elsif Qti<=Time(Integer'First) then
                              Qi:=Integer'First;
                           else
                              Qi:=Integer'Max(Integer(Qti),1);
                           end if;
                           Qtf:=Ceiling
                             ((E+Ti+Transaction(K).The_Task(Ktsk).Jinit-
                               Transaction(K).The_Task(Ktsk).SDij)/
                              Transaction(K).The_Task(Ktsk).Tijown);
                           if Qtf>=Time(Integer'Last) then
                              Qf:=Integer'Last;
                           elsif Qtf<=Time(Integer'First) then
                              Qf:=Integer'First;
                           else
                              Qf:=Integer
                                (Time'Min
                                 (Qtf,Ceiling
                                  ((L+Transaction(K).The_Task(Ktsk).Jinit)/
                                   Transaction(K).The_Task(Ktsk).Tijown)));
                           end if;
                           --  Put_Line("Qi: " & Integer'Image(Qi));
                           --  Put_Line("Qf: " & Integer'Image(Qf));

                           for Q in Qi..Qf loop
                              Wik:=Bi+Ci;
                              --Put_Line("Wik1: " & Time_Interval'Image(Wik));
                              Da:=(Time(Q)-1.0)*
                                Transaction(K).The_Task(Ktsk).Tijown-
                                Transaction(K).The_Task(Ktsk).Jinit+
                                Transaction(K).The_Task(Ktsk).SDij;
                              A:=Da-(Time(P-1)*Ti-Ji+di);
                              --  Put_Line("Da: " & Time'Image(Da));
                              --  Put_Line("A: " & Time'Image(A));
                              --  Put_Line("Jinit: "
                              --         & Time'Image
                              --         (Transaction(K).The_Task(Ktsk).Jinit));
                              --  Put_Line("SDij: "
                              --         & Time'Image
                              --          (Transaction(K).The_Task(Ktsk).SDij));
                              -- Iterate until equation converges
                              loop
                                 Wiknew:=Bi+Time(P)*Ci;
                                 --Put_Line("Wiknew1: "
                                 --         & Time_Interval'Image(Wiknew));
                                 -- add contributions of high or equal
                                 -- priority tasks
                                 for J in 1..Max_Transactions loop
                                    exit when Transaction(J).Ni=0;
                                    for Tsk in 1..Transaction(J).Ni loop
                                       if  Transaction(J).The_Task(Tsk).Prioij>
                                         Transaction(I).The_Task(Ni).Prioij
                                         and then
                                         (J/=I or else Tsk/=Ni)
                                       then
                                          if Transaction(J).The_Task(Tsk).Model
                                            =Unbounded_Effects
                                          then
                                             Put_Line("Ueffct3");
                                             Wiknew:= Large_Time;
                                             Wik:=Large_Time;
                                             Unbounded_Time:=True;
                                             exit;
                                          else
                                             Wiknew:=Wiknew+Ceiling
                                               ((Wik+Transaction(J).
                                                 The_Task(Tsk).Jinit*
                                                 Jeffect(Transaction(J).
                                                         The_Task(Tsk).
                                                         Jitter_Avoidance))/
                                                Transaction(J).
                                                The_Task(Tsk).Tij)*
                                               Transaction(J).
                                               The_Task(Tsk).Cij;
                                          end if;
                                       elsif Transaction(J).
                                         The_Task(Tsk).Prioij=
                                         Transaction(I).The_Task(Ni).Prioij
                                         and then
                                         (J/=I or else Tsk/=Ni)
                                       then
                                          if Transaction(J).
                                            The_Task(Tsk).Model=
                                            Unbounded_Effects
                                          then
                                             Put_Line("Ueffct4");
                                             Wiknew:= Large_Time;
                                             Wik:=Large_Time;
                                             Unbounded_Time:=True;
                                             exit;
                                          else
--                                               Put_Line("Jinit: "
--                                                        & Time_Interval'Image
--                                                          (Transaction(J).
--                                                        The_Task(Tsk).Jinit));
--                                              Put_Line("Jeffect: "
--                                                      & Time'Image
--                                                      (Jeffect(Transaction(J).
--                                                           The_Task(Tsk).
--                                                          Jitter_Avoidance)));
                                             Wiknew:=Wiknew+Min0
                                               (Ceiling
                                                ((Wik+Transaction(J).
                                                  The_Task(Tsk).Jinit*
                                                  Jeffect(Transaction(J).
                                                          The_Task(Tsk).
                                                          Jitter_Avoidance))/
                                                 Transaction(J).
                                                 The_Task(Tsk).Tij),
                                                floor
                                                ((Transaction(J).
                                                  The_Task(Tsk).Jinit*
                                                  Jeffect(Transaction(J).
                                                          The_Task(Tsk).
                                                          Jitter_Avoidance)+Da-
                                                  Transaction(J).
                                                  The_Task(Tsk).Dij)/
                                                 Transaction(J).
                                                 The_Task(Tsk).Tij)+1.0)*
                                               Transaction(J).
                                               The_Task(Tsk).Cij;
                                             --  Put_Line("Wiknew1: "
                                             --  & Time_Interval'Image(Wiknew));

                                          end if;
                                       end if;
                                    end loop;
                                    exit when Unbounded_Time;
                                 end loop;
                                 exit when Unbounded_Time or else Wik=Wiknew;
                                 Wik:=Wiknew;
                              end loop; -- workload convergence
                              exit when Unbounded_Time;
                              Rik:=Wik-A+Ji-Ti*(Time(P)-1.0);
                              -- Put_Line("Rik: "
                              --                 & Time'Image(Rik));
                              -- keep the worst case result
                              if Rik>Ri then
                                 Ri:=Rik;
                              end if;
                              -- check if busy period is too long
                              if Ri>Analysis_Bound then
                                 Put_Line("Utime3");
                                 Unbounded_Time:=True;
                                 exit;
                              end if;
                              Wik:=Wik+Ci;
                           end loop; -- Coincident deadline q
                           exit when Unbounded_Time;
                           --  Put_Line("-------------");
                        end if; -- Pi=Pk
                     end loop; -- task Ktsk
                     exit when Unbounded_Time;
                  end loop; -- transaction k
                  exit when Unbounded_Time;
                  --  Put_Line(Time'Image(Ri));
                  if Ri > Di then
                     if Pi_Ti < (Time(P)*Ti) then
                        Pi_Ti := Time(P)*Ti;
                        --  Put_Line("P: " & Integer'Image(P));
                        --  Put_Line("Ti: " & Time'Image(Ti));
                        --  Put_Line("Pi*Ti: " & Time'Image(Time(P)*Ti));
                     end if;
                     Unbounded_Time:=True;
                  end if;
               end loop; -- job p
            end if;
            -- Store the worst-case response time obtained
            if Unbounded_Time then
               Transaction(I).The_Task(Ni).Rij:=Large_Time;
               Transaction(I).The_Task(Ni).Jij:=Large_Time;
            else
               Transaction(I).The_Task(Ni).Rij:=Ri+Ji;
               Transaction(I).The_Task(Ni).Jij:=Ri+Ji-Rbi;
            end if;
         end if;
         if L < Time_Interval(952560000) then
            Put_Line("ResponseTime:" &
                    Time'Image(Transaction(I).The_Task(Ni).Rij));
         end if;
      end loop;
--        Put_Line("Output P: " & Integer'Image(P));
--                          Put_Line("Output Ti: " & Time'Image(Ti));
      if Pi_Ti > Time(0) then
         Put_Line("FirstDeadlineMissAfter:" & Time'Image(Pi_Ti));
      end if;
      Translate_Linear_Analysis_Results(Transaction,The_System);
   end EDF_Within_Priorities_Analysis;

   ----------------------------------
   -- Linear_Deadline_Distribution --
   ----------------------------------

   procedure Linear_Deadline_Distribution
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True)
   is
   begin
      Tool_Exceptions.Set_Tool_Failure_Message("Tool not yet implemented");
      raise Tool_Exceptions.Tool_Failure;
   end Linear_Deadline_Distribution;

end Mast.EDF_Tools;
