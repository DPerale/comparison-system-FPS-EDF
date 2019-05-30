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

with MAST.Systems, MAST.Transactions,MAST.Graphs,
  MAST.Graphs.Links, MAST.Graphs.Event_Handlers,
  MAST.Scheduling_Servers,MAST.Processing_Resources,
  MAST.Scheduling_Parameters, MAST.Timing_Requirements,
  MAST.Results,MAST.Events,  MAST.Shared_Resources,
  MAST.Timers,Mast.Drivers, MAST.Processing_Resources.Processor,
  Mast.Processing_Resources.Network, Mast.Schedulers,
  Mast.Scheduling_Policies, Mast.Operations,
  MAST.Transaction_Operations,Mast.IO,
  Mast.Tool_Exceptions,
  Indexed_Lists,
  Ada.Text_IO,Var_Strings;
use Ada.Text_IO,Var_Strings;
use type MAST.Graphs.Link_Ref;
use type MAST.Graphs.Event_Handler_Ref;
use type MAST.Events.Event_Ref;
use type MAST.Graphs.Link_Lists.Index;
use type MAST.Graphs.Event_Handler_Lists.Index;
use type MAST.Shared_Resources.Shared_Resource_Ref;
use type MAST.Timing_Requirements.Timing_Requirement_Ref;
use type Mast.Processing_Resources.Processing_Resource_Ref;
use type Mast.Timers.System_Timer_Ref;
use type Mast.Scheduling_Parameters.Sched_Parameters_Ref;
use type Mast.Scheduling_Servers.Scheduling_Server_Ref;
use type Mast.Operations.Operation_Ref;
use type Mast.Drivers.RTA_Overhead_Model_Type;

package body Mast.Linear_Translation is

   ----------------------------
   -- Get_Processor_Name     --
   ----------------------------

   function Get_Processor_Name
     (The_System : Systems.System;
      Proc_Number : Processor_Id_Type)
     return String
   is
      Res_Ref: Processing_Resources.Processing_Resource_Ref;
      Proc_Iterator : Processing_Resources.Lists.Iteration_Object;
   begin
      MAST.Processing_Resources.Lists.Rewind
        (The_System.Processing_Resources,Proc_Iterator);
      if Natural(Proc_Number) > MAST.Processing_Resources.Lists.Size
        (The_System.Processing_Resources)
      then
         raise Tool_Exceptions.Tool_Failure;
      end if;
      for K in 1..Proc_Number loop
         MAST.Processing_Resources.Lists.Get_Next_Item
           (Res_Ref,The_System.Processing_Resources,Proc_Iterator);
      end loop;
      return To_String(Processing_Resources.Name(Res_Ref));
   end Get_Processor_Name;

   ----------------------------
   -- Get_Processor_Number   --
   ----------------------------

   function Get_Processor_Number
     (The_System : Systems.System;
      A_Proc_Ref : Processing_Resources.Processing_Resource_Ref)
     return Processor_Id_Type
   is
      Res_Ref: Processing_Resources.Processing_Resource_Ref;
      Proc_Iterator : Processing_Resources.Lists.Iteration_Object;
   begin
      MAST.Processing_Resources.Lists.Rewind
        (The_System.Processing_Resources,Proc_Iterator);
      for K in 1..MAST.Processing_Resources.Lists.Size
        (The_System.Processing_Resources)
      loop
         MAST.Processing_Resources.Lists.Get_Next_Item
           (Res_Ref,The_System.Processing_Resources,Proc_Iterator);
         if Res_Ref = A_Proc_Ref then
            return Processor_Id_Type(K);
         end if;
      end loop;
      raise Tool_Exceptions.Tool_Failure;
   end Get_Processor_Number;

   ----------------------------------
   -- Get_Min_Used_System_Priority --
   ---------------------------------

   function Get_Min_Used_System_Priority
     (The_System : in MAST.Systems.System;
      A_Proc_Ref: Processing_Resources.Processing_Resource_Ref)
     return Priority
   is
      Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
      Srvr_Iterator : Scheduling_Servers.Lists.Iteration_Object;
      Min_Prio,A_Prio : Priority:=Priority'Last;
   begin
      Scheduling_Servers.Lists.Rewind
        (The_System.Scheduling_Servers,Srvr_Iterator);
      for I in 1..Scheduling_Servers.Lists.Size
        (The_System.Scheduling_Servers)
      loop
         Scheduling_Servers.Lists.Get_Next_Item
           (Srvr_Ref,The_System.Scheduling_Servers,Srvr_Iterator);
         if Scheduling_Servers.Server_Processing_Resource
           (Srvr_Ref.all)=A_Proc_Ref
         then
            A_Prio:=Scheduling_Servers.Base_Priority(Srvr_Ref.all);
            if A_Prio<Min_Prio then
               Min_Prio:=A_Prio;
            end if;
         end if;
      end loop;
      return Min_Prio;
   end Get_Min_Used_System_Priority;

   -------------------------------
   -- Translate_Linear_System   --
   -------------------------------

   procedure Translate_Linear_System
     (The_System : in MAST.Systems.System;
      Transaction : out Linear_Transaction_System;
      Verbose : in Boolean:=False)
   is

      Trans_Ref : MAST.Transactions.Transaction_Ref;
      An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
      A_Server_Ref,
      Last_Server_Ref : MAST.Scheduling_Servers.Scheduling_Server_Ref;
      A_Sched_Param_Ref : MAST.Scheduling_Parameters.Sched_Parameters_Ref;
      A_Synch_Param_Ref : Mast.Synchronization_Parameters.Synch_Parameters_Ref;
      A_Proc_Ref, Driver_Proc_Ref :
        MAST.Processing_Resources.Processing_Resource_Ref;
      A_Scheduler_Ref : Schedulers.Scheduler_Ref;
      A_Sched_Policy_Ref, Driver_S_Policy_Ref :
        Scheduling_Policies.Scheduling_Policy_Ref;
      A_Link_Ref,Nxt_Link_Ref,Next_Link_Ref: MAST.Graphs.Link_Ref;
      An_Event_Ref : MAST.Events.Event_Ref;
      A_Timing_Req_Ref : MAST.Timing_Requirements.Timing_Requirement_Ref;
      A_Result_Ref : MAST.Results.Timing_Result_Ref;
      Trans_Iterator : Transactions.Lists.Iteration_Object;
      EE_Iterator : Transactions.Link_Iteration_Object;
      Proc_Iterator : Processing_Resources.Lists.Iteration_Object;
      J : Task_ID_Type;
      Proc_Num: Processor_Id_Type;
      Max_Arrivals : Natural;
      Last_Trans_Id: Transaction_ID_Type;
      I,Current_Trans : Transaction_ID_Type;
      --    These are the current transaction indexes
      Timer_Ref : Timers.System_Timer_Ref;
      WS_Ovhd,WR_Ovhd,BS_Ovhd,BR_Ovhd : Time;
      Speed : Processor_Speed;
      Timer_Jitter : Time;
      Drv_Iterator : Processing_Resources.Network.Driver_Iteration_Object;
      Drv_Ref : Drivers.Driver_Ref;
      Min_System_Priority : Priority;
      Max_System_Priority : Priority;
      Min_Int_Priority : Priority;
      Max_Int_Priority : Priority;
      Min_Used_System_Priority : Priority;

      -- The following variables are
      -- used by offset or delay event handlers to set the appropriate
      -- values for the following activity
      Min_Delay, Max_Delay : Time;
      type Type_Of_Handler is (Activity, Rate_Divisor, Offset_EH, Delay_EH);
      Type_Of_Previous_Handler : Type_Of_Handler;

      -- The following variables are used by the rate divisor event handlers
      -- to set information for the following activity
      Rate_Factor : Positive;
      Accum_Rate_Factor : Time;

      Independent_Tasks : array
        (Task_ID_Type range 1..Max_Tasks_Per_Transaction) of Boolean;
      Rate_Divided_Tasks : array
        (Task_ID_Type range 1..Max_Tasks_Per_Transaction) of Natural;

      package Overhead_Task_Lists is new Indexed_Lists(Task_Data,"=");

      Overhead_Task_List: Overhead_Task_Lists.List;

      Segment_Prio : Priority;
      Segment_Dij : Time;
      Segment_Sched : Sched_Type;
      Preassigned_Prio : Boolean;
      New_Sched_Server_Detected : Boolean;

      Throughput : Throughput_Value:=0.0;

   begin
      -- Assumes Linear_Plus_Transactions_Only
      Analysis_Bound:=0.0;
      MAST.Transactions.Lists.Rewind(The_System.Transactions,Trans_Iterator);
      Last_Trans_ID:=Transaction_ID_Type
        (Transactions.Lists.Size(The_System.Transactions));
      I:=0;
      -- loop for all transactions
      for Current_Trans_Id in Transaction_ID_Type range 1..Last_Trans_Id
      loop
         I:=I+1;
         MAST.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Trans_Iterator);
         --Translate each transaction
         Transaction(I).Transaction_Id:=Current_Trans_Id;
         Transaction(I).Ni:=Task_ID_Type
           (MAST.Transactions.Num_Of_Event_Handlers(Trans_Ref.all));
         -- Final number will be smaller, because offsets, delays and
         -- rate divisors are not tasks.
         Transaction(I).Trans_Input_Type:=External;
         MAST.Transactions.Rewind_External_Event_Links
           (Trans_Ref.all,EE_Iterator);
         MAST.Transactions.Get_Next_External_Event_Link
           (Trans_Ref.all,A_Link_Ref,EE_Iterator);

         -- Initialize Oij, Jij, Jinit, Rij, Rbij, Sched_Delay, and
         -- Jitter_avoidance, Uses_Shared_Resources,
         -- Delayijmin, Delayijmax, Oijmin, Oijmax for all tasks
         for J in 1..Max_Tasks_Per_Transaction loop
            Transaction(I).The_Task(J).Oij:=0.0;
            Transaction(I).The_Task(J).Jij:=0.0;
            Transaction(I).The_Task(J).Jinit:=0.0;
            Transaction(I).The_Task(J).Rij:=0.0;
            Transaction(I).The_Task(J).Rbij:=0.0;
            Transaction(I).The_Task(J).Sched_Delay:=0.0;
            Transaction(I).The_Task(J).Delayijmin:=0.0;
            Transaction(I).The_Task(J).Delayijmax:=0.0;
            Transaction(I).The_Task(J).Oijmin:=0.0;
            Transaction(I).The_Task(J).Oijmax:=0.0;
            Transaction(I).The_Task(J).Jitter_Avoidance:=False;
            Independent_Tasks(J):=False;
            Rate_Divided_Tasks(J):=1;
            Transaction(I).The_Task(J).Uses_Shared_Resources:=False;
         end loop;

         -- Get Evi, Ti, Jinit, and kind_of_event for first event
         -- Initial phase is considered zero for worst-case analysis
         An_Event_Ref:=MAST.Graphs.Event_Of(A_Link_Ref.all);
         Transaction(I).Evi:=An_Event_Ref;
         if An_Event_Ref.all in MAST.Events.Periodic_Event'Class
         then
            Transaction(I).Ti:=MAST.Events.Period
              (MAST.Events.Periodic_Event'Class(An_Event_Ref.all));
            Transaction(I).The_Task(1).Jinit:=MAST.Events.Max_Jitter
              (MAST.Events.Periodic_Event'Class(An_Event_Ref.all));
            Transaction(I).Kind_Of_Event:=Periodic;
         elsif An_Event_Ref.all in MAST.Events.Sporadic_Event'Class then
            Transaction(I).Ti:=MAST.Events.Min_Interarrival
              (MAST.Events.Sporadic_Event'Class(An_Event_Ref.all));
            Transaction(I).Kind_Of_Event:=Sporadic;
         elsif An_Event_Ref.all in MAST.Events.Singular_Event'Class then
            Transaction(I).Ti:=Large_Time;
            Transaction(I).Kind_Of_Event:=Periodic;
         elsif An_Event_Ref.all in MAST.Events.Unbounded_Event'Class then
            Transaction(I).Ti:=Large_Time; -- So that analysis converges
            Transaction(I).Kind_Of_Event:=Unbounded;
         elsif An_Event_Ref.all in MAST.Events.Bursty_Event'Class then
            Transaction(I).Ti:=MAST.Events.Bound_Interval
              (MAST.Events.Bursty_Event'Class(An_Event_Ref.all));
            Max_Arrivals:=MAST.Events.Max_Arrivals
              (MAST.Events.Bursty_Event'Class(An_Event_Ref.all));
            Transaction(I).Kind_Of_Event:=Bursty;
         else
            raise Incorrect_Object;
         end if;

         Min_Delay:=0.0;
         Max_Delay:=0.0;
         Type_Of_Previous_Handler:=Activity;
         Accum_Rate_Factor:=1.0;
         J:=1;
         New_Sched_Server_Detected :=True;
         -- for each event handler in the transaction
         loop
            An_Event_Handler_Ref:=Graphs.Output_Event_Handler
              (A_Link_Ref.all);
            -- check kind of event handler
            if An_Event_Handler_Ref.all in
              Graphs.Event_Handlers.Offset_Event_Handler'Class
            then
               -- Offset event handler
               Min_Delay:=Graphs.Event_Handlers.Delay_Min_Interval
                 (Graphs.Event_Handlers.Offset_Event_Handler'Class
                  (An_Event_Handler_Ref.all));
               Max_Delay:=Graphs.Event_Handlers.Delay_Max_Interval
                 (Graphs.Event_Handlers.Offset_Event_Handler'Class
                  (An_Event_Handler_Ref.all));
               Type_Of_Previous_Handler:=Offset_EH;
               -- check if referenced event coincides with transaction event
               if Graphs.Event_Handlers.Referenced_Event
                 (Graphs.Event_Handlers.Offset_Event_Handler'Class
                  (An_Event_Handler_Ref.all))/=
                 An_Event_Ref
               then
                  Tool_Exceptions.Set_Tool_Failure_Message
                    ("Referenced event in offset event handler is different"&
                     " than transaction event");
                  raise Tool_Exceptions.Tool_Failure;
               end if;
               J:=J-1;
               Next_Link_Ref:=Graphs.Event_Handlers.Output_Link
                 (Graphs.Event_Handlers.Simple_Event_Handler
                  (An_Event_Handler_Ref.all));
            elsif An_Event_Handler_Ref.all in
              Graphs.Event_Handlers.Delay_Event_Handler'Class
            then
               -- Delay event handler
               Min_Delay:=Graphs.Event_Handlers.Delay_Min_Interval
                 (Graphs.Event_Handlers.Delay_Event_Handler'Class
                  (An_Event_Handler_Ref.all));
               Max_Delay:=Graphs.Event_Handlers.Delay_Max_Interval
                 (Graphs.Event_Handlers.Delay_Event_Handler'Class
                  (An_Event_Handler_Ref.all));
               Type_Of_Previous_Handler:=Delay_EH;
               J:=J-1;
               Next_Link_Ref:=Graphs.Event_Handlers.Output_Link
                 (Graphs.Event_Handlers.Simple_Event_Handler
                  (An_Event_Handler_Ref.all));
            elsif An_Event_Handler_Ref.all in
              Graphs.Event_Handlers.Rate_Divisor'Class
            then
               -- Rate divisor
               Rate_Factor:=Graphs.Event_Handlers.Rate_Factor
                 (Graphs.Event_Handlers.Rate_Divisor'Class
                  (An_Event_Handler_Ref.all));
               Type_Of_Previous_Handler:=Rate_Divisor;
               Independent_Tasks(J):=True;
               Rate_Divided_Tasks(J):=Rate_Factor;
               J:=J-1;
               Next_Link_Ref:=Graphs.Event_Handlers.Output_Link
                 (Graphs.Event_Handlers.Simple_Event_Handler
                  (An_Event_Handler_Ref.all));
            elsif An_Event_Handler_Ref.all in
              Graphs.Event_Handlers.Activity'Class
            then
               -- Activity
               Last_Server_Ref:=A_Server_Ref;
               A_Server_Ref:=MAST.Graphs.Event_Handlers.Activity_Server
                 (MAST.Graphs.Event_Handlers.Activity
                  (An_Event_Handler_Ref.all));
               New_Sched_Server_Detected:=A_Server_Ref/=Last_Server_Ref;
               A_Proc_Ref:=
                 MAST.Scheduling_Servers.Server_Processing_Resource
                 (A_Server_Ref.all);
               Speed:=Processing_Resources.Speed_Factor(A_Proc_Ref.all);
               A_Scheduler_Ref:=Scheduling_Servers.Server_Scheduler
                 (A_Server_Ref.all);
               A_Sched_Policy_Ref:=Schedulers.Scheduling_Policy
                 (A_Scheduler_Ref.all);
               if A_Sched_Policy_Ref.all in
                 Scheduling_Policies.Fixed_Priority_Policy'Class
               then
                  Min_System_Priority:=Scheduling_Policies.Min_Priority
                    (Scheduling_Policies.Fixed_Priority_Policy'Class
                     (A_Sched_Policy_Ref.all));
                  Max_System_Priority:=Scheduling_Policies.Max_Priority
                    (Scheduling_Policies.Fixed_Priority_Policy'Class
                     (A_Sched_Policy_Ref.all));
               else
                  Min_System_Priority:=Priority'First;
                  Max_System_Priority:=Priority'Last;
               end if;
               Min_Int_Priority:=Min_System_Priority;
               Max_Int_Priority:=Max_System_Priority;
               if A_Proc_Ref.all in
                 Processing_Resources.Processor.Regular_Processor'Class
               then
                  Max_Int_Priority:=Processing_Resources.Processor.
                    Max_Interrupt_Priority
                    (Processing_Resources.Processor.Regular_Processor'Class
                     (A_Proc_Ref.all));
                  Min_Int_Priority:=Processing_Resources.Processor.
                    Min_Interrupt_Priority
                    (Processing_Resources.Processor.Regular_Processor'Class
                     (A_Proc_Ref.all));
               end if;
               Min_Used_System_Priority:=
                 Get_Min_Used_System_Priority(The_System,A_Proc_Ref);

               -- Get Processor Number

               Proc_Num:=Get_Processor_Number(The_System,A_Proc_Ref);

               -- If Activity is timed, and processor has an alarm clock
               -- system timer, add timer overhead

               if A_Proc_Ref.all in
                 Processing_Resources.Processor.Regular_Processor'Class
               then
                  Timer_Ref:=Processing_Resources.Processor.The_System_Timer
                    (Processing_Resources.Processor.Regular_Processor'Class
                     (A_Proc_Ref.all));
               else
                  Timer_Ref:=null;
               end if;
               Timer_Jitter:=0.0;
               if An_Event_Handler_Ref.all in
                 Graphs.Event_Handlers.System_Timed_Activity'Class
                 and then Timer_Ref/=null
               then
                  if Timer_Ref.all in Timers.Alarm_Clock'Class
                  then
                     Transaction(I).The_Task(J+1):=Transaction(I).The_Task(J);
                     Transaction(I).The_Task(J):=
                       (Cijown  => Timers.Worst_Overhead(Timer_Ref.all)/Speed,
                        Cbijown => Timers.Best_Overhead(Timer_Ref.all)/Speed,
                        Cij     => Timers.Worst_Overhead(Timer_Ref.all)/Speed,
                        Cbij    => Timers.Best_Overhead(Timer_Ref.all)/Speed,
                        Tijown  => Transaction(I).Ti*Accum_Rate_Factor,
                        Tij     => Transaction(I).Ti*Accum_Rate_Factor,
                        Bij     => 0.0,
                        Dij     => Large_Time,
                        SDij    => 0.0,
                        Schedij => FP,
                        Oij     => 0.0,
                        Jij     => 0.0,
                        Jinit   => Transaction(I).The_Task(J+1).Jinit,
                        Sched_Delay => 0.0,
                        Oijmin      => 0.0,
                        Oijmax      => 0.0,
                        Delayijmin  => 0.0,
                        Delayijmax  => 0.0,
                        Model   => Regular,
                        Jitter_Avoidance => False,
                        Uses_Shared_Resources => False,
                        Rij     => 0.0,
                        Rbij    => 0.0,
                        Prioij=> Processing_Resources.Processor.
                          Max_Interrupt_Priority
                          (Processing_Resources.Processor.
                           Regular_Processor'Class(A_Proc_Ref.all)),
                        Procij=> Proc_Num,
                        Resij => null,
                        Pav => Transaction(I).The_Task(J).Pav);
                     Transaction(I).The_Task(J+1).Jinit := 0.0;
                     Transaction(I).The_Task(J).Pav.Hard_Prio := True;
                     Transaction(I).The_Task(J).Pav.Preassigned := True;
                     J:=J+1;
                  elsif Timer_Ref.all in Timers.Ticker'Class then
                     Timer_Jitter:=Timers.Period
                       (Timers.Ticker'Class(Timer_Ref.all));
                  else
                     raise Incorrect_Object;
                  end if;
               end if;

               -- Get Jinit, Delay, and static offset

               case Type_Of_Previous_Handler is
                  when Activity =>
                     Transaction(I).The_Task(J).Oijmin:=0.0;
                     Transaction(I).The_Task(J).Oijmax:=0.0;
                     Transaction(I).The_Task(J).Delayijmin:=0.0;
                     Transaction(I).The_Task(J).Delayijmax:=0.0;
                  when Offset_EH =>
                     Transaction(I).The_Task(J).Oijmin:=Min_Delay;
                     Transaction(I).The_Task(J).Oijmax:=Max_Delay;
                     Transaction(I).The_Task(J).Delayijmin:=0.0;
                     Transaction(I).The_Task(J).Delayijmax:=0.0;
                     -- Timer_Jitter is not changed here
                     -- the tools have to change it
                  when Delay_EH =>
                     Transaction(I).The_Task(J).Oijmin:=0.0;
                     Transaction(I).The_Task(J).Oijmax:=0.0;
                     Transaction(I).The_Task(J).Delayijmin:=Min_Delay;
                     Transaction(I).The_Task(J).Delayijmax:=Max_Delay;
                     -- Timer_Jitter is not changed here
                     -- the tools have to change it
                  when Rate_Divisor =>
                     Transaction(I).The_Task(J).Oijmin:=Time(Rate_Factor-1)*
                       (Transaction(I).Ti*Accum_Rate_Factor);
                     Transaction(I).The_Task(J).Oijmax:=Time(Rate_Factor-1)*
                       (Transaction(I).Ti*Accum_Rate_Factor);
                     Transaction(I).The_Task(J).Delayijmin:=0.0;
                     Transaction(I).The_Task(J).Delayijmax:=0.0;
                     if Transaction(I).Ti<Large_Time*(1.0+Epsilon) then
                        Accum_Rate_Factor:=Accum_Rate_Factor*Time(Rate_Factor);
                     end if;
               end case;
               Transaction(I).The_Task(J).Jinit:=
                 Transaction(I).The_Task(J).Jinit+Timer_Jitter;

               -- Get Priority
               A_Sched_Param_Ref:=
                 MAST.Scheduling_Servers.Server_Sched_Parameters
                 (A_Server_Ref.all);
               A_Synch_Param_Ref:=
                 MAST.Scheduling_Servers.Server_Synch_Parameters
                 (A_Server_Ref.all);
               if A_Sched_Param_Ref.all in
                 Scheduling_Parameters.Fixed_Priority_Parameters'Class
               then
                  if New_Sched_Server_Detected then
                     Segment_Prio:=
                       MAST.Scheduling_Parameters.The_Priority
                       (MAST.Scheduling_Parameters.
                        Fixed_Priority_Parameters'Class
                        (A_Sched_Param_Ref.all));
                     Segment_Dij:=0.0;
                     Segment_Sched:=FP;
                  end if;
                  Transaction(I).The_Task(J).Pav.Preassigned:=
                    MAST.Scheduling_Parameters.Preassigned
                    (MAST.Scheduling_Parameters.Fixed_Priority_Parameters'Class
                     (A_Sched_Param_Ref.all));
                  if A_Sched_Param_Ref.all in
                    Scheduling_Parameters.Interrupt_FP_Policy'Class then
                     Transaction(I).The_Task(J).Pav.Hard_Prio := True;
                  else
                     Transaction(I).The_Task(J).Pav.Hard_Prio := False;
                     Transaction(I).The_Task(J).Pav.S_P_Ref :=
                       A_Sched_Param_Ref;
                     Transaction(I).The_Task(J).Pav.Synch_P_Ref :=
                       A_Synch_Param_Ref;
                  end if;
               elsif A_Sched_Param_Ref.all in
                 Scheduling_Parameters.EDF_Parameters'Class
               then
                  Transaction(I).The_Task(J).Pav.S_P_Ref :=
                    A_Sched_Param_Ref;
                  Transaction(I).The_Task(J).Pav.Synch_P_Ref :=
                    A_Synch_Param_Ref;
                  if New_Sched_Server_Detected then
                     Segment_Prio:=Scheduling_Servers.Base_Priority
                       (A_Server_Ref.all);
                     Segment_Dij:=Scheduling_Parameters.Deadline
                       (MAST.Scheduling_Parameters.
                        EDF_Parameters'Class(A_Sched_Param_Ref.all));
                     Segment_Sched:=EDF;
                  end if;
               end if;

               -- Get Procij
               Transaction(I).The_Task(J).Procij:=Proc_Num;
               Transaction(I).The_Task(J).Pav.P_R_Ref :=A_Proc_Ref;
               if A_Sched_Policy_Ref.all in
                 Scheduling_Policies.Fixed_Priority_Policy'Class
               then
                  Transaction(I).The_Task(J).Pav.S_Policy_Ref :=
                    Scheduling_Policies.Fixed_Priority_Policy_Ref
                    (A_Sched_Policy_Ref);
               else
                  Transaction(I).The_Task(J).Pav.S_Policy_Ref := null;
               end if;

               -- Get Cij, Cbij, Prioij
               Transaction_Operations.Get_Segment_Data_With_Permanent_FP
                 (Trans_Ref,A_Link_Ref,Next_Link_Ref,
                  Transaction(I).The_Task(J).Cij,
                  Transaction(I).The_Task(J).Cbij,
                  Transaction(I).The_Task(J).Uses_Shared_Resources,
                  Segment_Prio,
                  Preassigned_Prio);
               Transaction(I).The_Task(J).Prioij:=Segment_Prio;
               Transaction(I).The_Task(J).SDij:=Segment_Dij;
               Transaction(I).The_Task(J).Schedij:=Segment_Sched;
               -- Commented out because priority assignment does not
               --  yet handle permanent overridden priorities
               -- if Preassigned_Prio then
               --   Transaction(I).The_Task(J).Pav.Preassigned:=True;
               -- end if;
               if Transaction(I).Kind_Of_Event=Bursty then
                  Transaction(I).The_Task(J).Cij:=
                    Transaction(I).The_Task(J).Cij*Time(Max_Arrivals);
               end if;
               Transaction(I).The_Task(J).Cijown:=
                 Transaction(I).The_Task(J).Cij;
               Transaction(I).The_Task(J).Cbijown:=
                 Transaction(I).The_Task(J).Cbij;

               -- Set Link for results
               Transaction(I).The_Task(J).Resij:=Next_Link_Ref;

               -- Get Bij

               -- Calculate end of segment
               Transaction_Operations.Identify_Segment_With_Permanent_FP
                 (Trans_Ref, A_Link_Ref, Nxt_Link_Ref);

               if MAST.Graphs.Links.Has_Results
                 (Graphs.Links.Regular_Link(Nxt_Link_Ref.all))
               then
                  A_Result_Ref:=MAST.Graphs.Links.Link_Time_Results
                    (MAST.Graphs.Links.Regular_Link(Nxt_Link_Ref.all));
                  Transaction(I).The_Task(J).Bij:=
                    MAST.Results.Worst_Blocking_Time(A_Result_Ref.all);
               else
                  Transaction(I).The_Task(J).Bij:=0.0;
               end if;
               if Transaction(I).Kind_Of_Event=Bursty then
                  Transaction(I).The_Task(J).Bij:=
                    Transaction(I).The_Task(J).Bij*Time(Max_Arrivals);
               end if;

               -- Get Dij
               if Next_Link_Ref.all in MAST.Graphs.Links.Regular_Link'Class
               then
                  A_Timing_Req_Ref:=
                    MAST.Graphs.Links.Link_Timing_Requirements
                    (MAST.Graphs.Links.Regular_Link(Next_Link_Ref.all));
                  if A_Timing_Req_Ref /= null and then
                    A_Timing_Req_Ref.all in
                    Timing_Requirements.Hard_Global_Deadline'Class
                  then
                     Transaction(I).The_Task(J).Dij:=
                       MAST.Timing_Requirements.The_Deadline
                       (MAST.Timing_Requirements.Deadline'Class
                        (A_Timing_Req_Ref.all));
                     if Analysis_Bound<Transaction(I).The_Task(J).Dij then
                        Analysis_Bound:= Transaction(I).The_Task(J).Dij;
                     end if;
                  else
                     Transaction(I).The_Task(J).Dij:=Large_Time;
                  end if;
               else
                  raise Incorrect_Object;
               end if;

               -- Get Tij, Tijown
               Transaction(I).The_Task(J).Tij:=
                 Transaction(I).Ti*Accum_Rate_Factor;
               Transaction(I).The_Task(J).Tijown:=
                 Transaction(I).Ti*Accum_Rate_Factor;
               if Analysis_Bound<Transaction(I).The_Task(J).Tij then
                  Analysis_Bound:= Transaction(I).The_Task(J).Tij;
               end if;

               -- Consider scheduling policies
               if A_Sched_Param_Ref.all in
                 Scheduling_Parameters.Fixed_Priority_Policy'Class or else
                 A_Sched_Param_Ref.all in
                 Scheduling_Parameters.Non_Preemptible_FP_Policy'Class or else
                 A_Sched_Param_Ref.all in
                 Scheduling_Parameters.Interrupt_FP_Policy'Class or else
                 A_Sched_Param_Ref.all in
                 Scheduling_Parameters.EDF_Policy'Class
               then
                  case Transaction(I).Kind_Of_Event is
                     when Periodic|Sporadic|Bursty =>
                        Transaction(I).The_Task(J).Model:=Regular;
                     when Unbounded =>
                        Transaction(I).The_Task(J).Model:=Unbounded_Effects;
                  end case;
               elsif A_Sched_Param_Ref.all in
                 Scheduling_Parameters.Sporadic_Server_Policy'Class
               then
                  declare
                     Css : Time :=Scheduling_Parameters.Initial_Capacity
                       (Scheduling_Parameters.Sporadic_Server_Policy'Class
                        (A_Sched_Param_Ref.all));
                     Tss : Time :=Scheduling_Parameters.Replenishment_Period
                       (Scheduling_Parameters.Sporadic_Server_Policy'Class
                        (A_Sched_PAram_Ref.all));
                     Cswitch : Time:=0.0;
                  begin
                     Independent_Tasks(J):=True;
                     if Scheduling_Parameters.Background_Priority
                       (Scheduling_Parameters.Sporadic_Server_Policy'Class
                        (A_Sched_Param_Ref.all)) >=Min_Used_System_Priority
                     then
                        Transaction(I).The_Task(J).Model:=Unbounded_Effects;
                        if Verbose then
                           Put_Line("Background prio of scheduling server "&
                                    To_String
                                    (Scheduling_Servers.Name(A_Server_Ref))&
                                    " is too high");
                        end if;
                     else
                        if A_Proc_Ref.all in
                          Processing_Resources.Processor.Processor'Class
                        then
                           Cswitch:=Scheduling_Policies.
                             Worst_Context_Switch
                             (Scheduling_Policies.
                              Fixed_Priority'Class(A_Sched_Policy_Ref.all))/
                             Speed;
                        end if;
                        case Transaction(I).Kind_Of_Event is
                           when Periodic|Sporadic|Bursty =>
                              -- check if enough capacity
                              if (Css/Tss)*(1.4+Epsilon)>=
                                Transaction(I).The_Task(J).Cij/
                                (Transaction(I).Ti*Accum_Rate_Factor)
                              then -- enough capacity
                                 if Tss>(Transaction(I).Ti*Accum_Rate_Factor)
                                 then -- case 1
                                    Transaction(I).The_Task(J).Sched_Delay:=
                                      Tss-Css;
                                    Transaction(I).The_Task(J).Cij:=
                                      Css+2.0*Cswitch;
                                    Transaction(I).The_Task(J).Cbij:=0.0;
                                    Transaction(I).The_Task(J).Tij:=Tss;
                                    Transaction(I).The_Task(J).
                                      Jitter_Avoidance:=True;
                                    Transaction(I).The_Task(J).Model:=
                                      Separate_Analysis;
                                 else -- case 2
                                    if Css>=Transaction(I).The_Task(J).Cij then
                                       -- case 2.1
                                       Transaction(I).The_Task(J).Cij:=
                                         Css+2.0*Cswitch;
                                       Transaction(I).The_Task(J).Cbij:=0.0;
                                       Transaction(I).The_Task(J).Tij:=Tss;
                                       Transaction(I).The_Task(J).
                                         Jitter_Avoidance:=True;
                                       Transaction(I).The_Task(J).Model:=
                                         Separate_Analysis;
                                    else
                                       -- case 2.2
                                       Transaction(I).The_Task(J).Sched_Delay:=
                                         (Time'Ceiling
                                          (Transaction(I).
                                           The_Task(J).Cijown/Css)
                                          -1.0)*Tss + Tss-Css;
                                       Transaction(I).The_Task(J).Cij:=
                                         Css+2.0*Cswitch;
                                       Transaction(I).The_Task(J).Cbij:=0.0;
                                       Transaction(I).The_Task(J).Tij:=Tss;
                                       Transaction(I).The_Task(J).
                                         Jitter_Avoidance:=True;
                                       Transaction(I).The_Task(J).Model:=
                                         Separate_Analysis;
                                    end if;
                                 end if;
                              else -- not enough capacity
                                 Transaction(I).The_Task(J).Cij:=
                                   Css+2.0*Cswitch;
                                 Transaction(I).The_Task(J).Cbij:=0.0;
                                 Transaction(I).The_Task(J).Tij:=Tss;
                                 Transaction(I).The_Task(J).Jitter_Avoidance:=
                                   True;
                                 Transaction(I).The_Task(J).Model:=
                                   Unbounded_Response;
                              end if;
                           when Unbounded =>
                              Transaction(I).The_Task(J).Cij:=Css+2.0*Cswitch;
                              Transaction(I).The_Task(J).Cbij:=0.0;
                              Transaction(I).The_Task(J).Tij:=Tss;
                              Transaction(I).The_Task(J).Tijown:=Tss;
                              Transaction(I).The_Task(J).Jitter_Avoidance:=
                                True;
                              Transaction(I).The_Task(J).Model:=
                                Unbounded_Response;
                        end case;
                     end if;
                  end;
               elsif A_Sched_Param_Ref.all in
                 Scheduling_Parameters.Polling_Policy'Class
               then
                  declare
                     Tpoll : Time :=Scheduling_Parameters.Polling_Period
                       (Scheduling_Parameters.Polling_Policy'Class
                        (A_Sched_PAram_Ref.all));
                     Speed_Factor:Processor_Speed:=Processing_Resources.
                       Speed_Factor(A_Proc_Ref.all);
                     Cpoll : Time :=
                       Scheduling_Parameters.Polling_Worst_Overhead
                       (Scheduling_Parameters.Polling_Policy'Class
                        (A_Sched_PAram_Ref.all))/Speed_Factor;
                     Cbpoll : Time :=
                       Scheduling_Parameters.Polling_Best_Overhead
                       (Scheduling_Parameters.Polling_Policy'Class
                        (A_Sched_PAram_Ref.all))/Speed_Factor;
                     Ovhd_Task : Task_Data;
                  begin
                     case Transaction(I).Kind_Of_Event is
                        when Periodic|Sporadic =>
                           if Tpoll<=(Transaction(I).Ti*Accum_Rate_Factor) then
                              -- case 1
                              --Transaction(I).The_Task(J).Sched_Delay:=Tpoll;
                              Transaction(I).The_Task(J).Jinit:=
                                Transaction(I).The_Task(J).Jinit+Tpoll;
                              Transaction(I).The_Task(J).Model:=Regular;

                              -- add additional polling overhead
                              if Tpoll*(1.0+Epsilon)<
                                (Transaction(I).Ti*Accum_Rate_Factor)
                              then
                                 Ovhd_Task:=Task_Data'
                                   (Cijown => Cpoll,
                                    Cbijown=> Cbpoll,
                                    Cij    => Cpoll,
                                    Cbij   => Cbpoll,
                                    Tijown => (Transaction(I).Ti*
                                               Accum_Rate_Factor)*Tpoll/
                                      (Transaction(I).Ti*Accum_Rate_Factor-
                                       Tpoll),
                                    Tij    => (Transaction(I).Ti*
                                               Accum_Rate_Factor)*Tpoll/
                                      (Transaction(I).Ti*Accum_Rate_Factor-
                                       Tpoll),
                                    Bij    => 0.0,
                                    Dij    => Large_Time,
                                    SDij    => 0.0,
                                    Schedij => FP,
                                    Oij    => 0.0,
                                    Jij    => 0.0,
                                    Jinit  => Transaction(I).Ti*
                                      Accum_Rate_Factor*Tpoll/
                                      (Transaction(I).Ti*Accum_Rate_Factor-
                                       Tpoll)-Tpoll,
                                    Sched_Delay      => 0.0,
                                    Oijmin           => 0.0,
                                    Oijmax           => 0.0,
                                    Delayijmin       => 0.0,
                                    Delayijmax       => 0.0,
                                    Model            => Regular,
                                    Jitter_Avoidance => False,
                                    Uses_Shared_Resources => False,
                                    Rij    => 0.0,
                                    Rbij   => 0.0,
                                    Prioij =>Transaction(I).
                                      The_Task(J).Prioij,
                                    Procij=>Transaction(I).The_Task(J).Procij,
                                    Resij => null,
                                    Pav => Transaction(I).The_Task(J).Pav);
                                 Ovhd_Task.Pav.Is_Polling:=True;
                                 Overhead_Task_Lists.Add
                                   (Ovhd_Task,Overhead_Task_List);
                                 Transaction(I).The_Task(J).Pav.Hard_Prio :=
                                   False;
                              end if;
                           else -- case 2
                              Transaction(I).The_Task(J).Tij:=Tpoll;
                              Transaction(I).The_Task(J).Model:=
                                Unbounded_Response;
                           end if;
                        when  Bursty =>
                           Transaction(I).The_Task(J).Cij:=
                             Transaction(I).The_Task(J).Cij/Time(Max_Arrivals);
                           Transaction(I).The_Task(J).Cijown:=
                             Transaction(I).The_Task(J).Cijown/
                             Time(Max_Arrivals);
                           Transaction(I).The_Task(J).Bij:=
                             Transaction(I).The_Task(J).Bij/Time(Max_Arrivals);
                           Transaction(I).The_Task(J).Tij:=Tpoll;
                           Transaction(I).The_Task(J).Tijown:=Tpoll;
                           if Tpoll*Time(Max_Arrivals)*(1.0-Epsilon)<=
                             MAST.Events.Bound_Interval
                             (MAST.Events.Bursty_Event'Class(An_Event_Ref.all))
                           then
                              -- case 1 : enough capacity
                              Transaction(I).The_Task(J).Sched_Delay:=
                                Tpoll*Time(Max_Arrivals-1);
                              Transaction(I).The_Task(J).Jinit:=
                                Transaction(I).The_Task(J).Jinit+Tpoll;
                              Transaction(I).The_Task(J).Model:=Regular;
                           else -- case 2: not enough capacity
                              Transaction(I).The_Task(J).Model:=
                                Unbounded_Response;
                           end if;
                        when Unbounded =>
                           Transaction(I).The_Task(J).Tij:=Tpoll;
                           Transaction(I).The_Task(J).Tijown:=Tpoll;
                           Transaction(I).The_Task(J).Model:=
                             Unbounded_Response;
                     end case;
                  end;
               else
                  Tool_Exceptions.Set_Tool_Failure_Message
                    ("Fixed priority scheduling policy not supported");
                  raise Tool_Exceptions.Tool_Failure;
               end if;
               Min_Delay:=0.0;
               Max_Delay:=0.0;
               Type_Of_Previous_Handler:=Activity;
            end if; -- for event_handler check

            -- Finish loop
            exit when Graphs.Output_Event_Handler(Next_Link_Ref.all)=null;

            J:=J+1;
            A_Link_Ref:=Next_Link_Ref;

         end loop; -- event handler loop

         -- Get Ni
         Transaction(I).Ni:=J;

         -- Check if there are unbounded events that are not
         -- scheduled properly
         for T in 1..Transaction(I).Ni loop
            if Transaction(I).The_Task(T).Model=Unbounded_Effects and
              Verbose
            then
               Put_Line("Warning: Transaction "&Transactions.Name(Trans_Ref)&
                        " has unbounded event");
            end if;
         end loop;

         -- Split independent tasks into several transactions
         -- take into account rate divisors
         declare
            T,Tinic : Task_Id_Type:=1;
         begin
            loop
               exit when T=Transaction(I).Ni;
               T:=T+1; -- start on the second transaction
               Tinic:=Tinic+1;
               if Independent_Tasks(Tinic) then
                  Transaction(I+1).Transaction_Id:=
                    Transaction(I).Transaction_Id;
                  Transaction(I+1).Ti:=Transaction(I).Ti*
                    Time(Rate_Divided_Tasks(Tinic));
                  Transaction(I+1).Evi:=Transaction(I).Evi;
                  Transaction(I+1).Kind_Of_Event:=Transaction(I).Kind_Of_Event;
                  Transaction(I+1).Ni:=Transaction(I).Ni-T+1;
                  Transaction(I+1).Trans_Input_Type:=Internal;
                  for Tsk in T..Transaction(I).Ni loop
                     Transaction(I+1).The_Task(Tsk-T+1):=
                       Transaction(I).The_Task(Tsk);
                  end loop;
                  Transaction(I).Ni:=T-1;
                  I:=I+1;
                  T:=1; -- restart counter on new transaction
               end if;
            end loop;
         end;
      end loop; -- Transaction loop
      Current_Trans:=I;

      Analysis_Bound:=Analysis_Bound*Time(Max_OverDeadline);
      Max_Busy_Period:=Analysis_Bound*Time(Max_OverDeadline);

      -- Add Processing Resource Overhead Tasks and Transactions

      Processing_Resources.Lists.Rewind
        (The_System.Processing_Resources,Proc_Iterator);
      Proc_Num:=0;
      for I in 1..Processing_Resources.Lists.Size
        (The_System.Processing_Resources)
      loop
         Processing_Resources.Lists.Get_Next_Item
           (A_Proc_Ref,The_System.Processing_Resources,Proc_Iterator);
         Proc_Num:=Proc_Num+1;
         Speed:=Processing_Resources.Speed_Factor(A_Proc_Ref.all);
         if A_Proc_Ref.all in
           Processing_Resources.Network.Network'Class
         then
            Throughput:=Processing_Resources.Network.Throughput
              (Processing_Resources.Network.Network'Class
               (A_Proc_Ref.all));
         else
            Throughput:=0.0;
         end if;

         if A_Proc_Ref.all in
           Processing_Resources.Network.Network'Class
         then

            -- add the tasks and transactions associated
            -- with the network drivers
            Processing_Resources.Network.Rewind_Drivers
              (Processing_Resources.Network.Network(A_Proc_Ref.all),
               Drv_Iterator);
            for D in 1..Processing_Resources.Network.Num_Of_Drivers
              (Processing_Resources.Network.Network(A_Proc_Ref.all))
            loop
               Processing_Resources.Network.Get_Next_Driver
                 (Processing_Resources.Network.Network(A_Proc_Ref.all),
                  Drv_Ref,Drv_Iterator);
               if Drv_Ref.all in Drivers.Packet_Driver'Class then
                  -- For all packet drivers, add packet driver overhead
                  case Drivers.RTA_Overhead_Model
                    (Drivers.Packet_Driver(Drv_Ref.all))
                  is
                     when Drivers.Decoupled =>
                        --
                        -- Decoupled overhead model
                        --
                        A_Server_Ref:=Drivers.Packet_Server
                          (Drivers.Packet_Driver'Class(Drv_Ref.all));
                        A_Sched_Param_Ref:=
                          Scheduling_Servers.Server_Sched_Parameters
                          (A_Server_Ref.all);
                        A_Synch_Param_Ref:=
                          Scheduling_Servers.Server_Synch_Parameters
                          (A_Server_Ref.all);
                        Driver_Proc_Ref :=
                          Scheduling_Servers.Server_Processing_Resource
                          (A_Server_Ref.all);
                        Driver_S_Policy_Ref :=
                          Schedulers.Scheduling_Policy
                          (Scheduling_Servers.Server_Scheduler
                           (A_Server_Ref.all).all);
                        Speed:=Processing_Resources.Speed_Factor
                          (Driver_Proc_Ref.all);
                        if Driver_Proc_Ref.all in
                          Processing_Resources.Network.Network'Class
                        then
                           Throughput:=Processing_Resources.Network.Throughput
                             (Processing_Resources.Network.Network'Class
                              (Driver_Proc_Ref.all));
                        else
                           Throughput:=0.0;
                        end if;
                        if Drivers.Packet_Send_Operation
                          (Drivers.Packet_Driver'Class
                           (Drv_Ref.all))/=null
                        then
                           WS_Ovhd:=Operations.Worst_Case_Execution_Time
                             (Drivers.Packet_Send_Operation
                              (Drivers.Packet_Driver'Class
                               (Drv_Ref.all)).all,Throughput)/Speed;
                           BS_Ovhd:=Operations.Best_Case_Execution_Time
                             (Drivers.Packet_Send_Operation
                              (Drivers.Packet_Driver'Class
                               (Drv_Ref.all)).all,Throughput)/Speed;
                        else
                           WS_Ovhd:=0.0;
                           BS_Ovhd:=0.0;
                        end if;
                        if Drivers.Packet_Receive_Operation
                          (Drivers.Packet_Driver'Class
                           (Drv_Ref.all))/=null
                        then
                           WR_Ovhd:=Operations.Worst_Case_Execution_Time
                             (Drivers.Packet_Receive_Operation
                              (Drivers.Packet_Driver'Class
                               (Drv_Ref.all)).all,Throughput)/Speed;
                           BR_Ovhd:=Operations.Best_Case_Execution_Time
                             (Drivers.Packet_Receive_Operation
                              (Drivers.Packet_Driver'Class
                               (Drv_Ref.all)).all,Throughput)/Speed;
                        else
                           WR_Ovhd:=0.0;
                           BR_Ovhd:=0.0;
                        end if;

                        case Processing_Resources.Network.Transmission_Mode
                          (Processing_Resources.Network.Network'Class
                           (A_Proc_Ref.all)) is
                           when Simplex | Half_Duplex=>
                              Current_Trans:=Current_Trans+1;
                              Transaction(Current_Trans).Transaction_Id:=
                                Current_Trans;
                              Transaction(Current_Trans).Kind_Of_Event:=Periodic;
                              Transaction(Current_Trans).Trans_Input_Type:=
                                External;
                              Transaction(Current_Trans).Ti:=
                                Processing_Resources.Network.
                                Min_Packet_Transmission_Time
                                (Processing_Resources.Network.
                                 Packet_Based_Network'Class(A_Proc_Ref.all))/
                                Speed;
                              Transaction(Current_Trans).Ni:=1;
                              Transaction(Current_Trans).The_Task(1):=
                                (Cijown => Time'Max(WS_Ovhd,WR_Ovhd),
                                 Cbijown=> Time'Max(BS_Ovhd,BR_Ovhd),
                                 Cij    => Time'Max(WS_Ovhd,WR_Ovhd),
                                 Cbij   => Time'Max(BS_Ovhd,BR_Ovhd),
                                 Tijown => Transaction(Current_Trans).Ti,
                                 Tij    => Transaction(Current_Trans).Ti,
                                 Bij    => 0.0,
                                 Dij    => Large_Time,
                                 SDij    => 0.0,
                                 Schedij => FP,
                                 Oij    => 0.0,
                                 Jij    => 0.0,
                                 Jinit  => 0.0,
                                 Sched_Delay      => 0.0,
                                 Oijmin           => 0.0,
                                 Oijmax           => 0.0,
                                 Delayijmin       => 0.0,
                                 Delayijmax       => 0.0,
                                 Model            => Regular,
                                 Jitter_Avoidance => False,
                                 Uses_Shared_Resources => False,
                                 Rij    => 0.0,
                                 Rbij   => 0.0,
                                 Prioij =>Scheduling_Parameters.The_Priority
                                   (Scheduling_Parameters.
                                    Fixed_Priority_Parameters'Class
                                    (A_Sched_Param_Ref.all)),
                                 Procij=>Get_Processor_Number
                                   (The_System,Driver_Proc_Ref),
                                 Resij => null,
                                 Pav => Transaction(Current_Trans).
                                   The_Task(1).Pav);
                              -- if interrupt priority, hard prio is true
                              Transaction(Current_Trans).The_Task(1).
                                Pav.Hard_Prio:=
                                Transaction(Current_Trans).The_Task(1).Prioij in
                                Min_Int_Priority..Max_Int_Priority;
                              Transaction(Current_Trans).The_Task(1).
                                Pav.Preassigned := True;
                              Transaction(Current_Trans).The_Task(1).
                                Pav.S_P_Ref :=A_Sched_Param_Ref;
                              Transaction(Current_Trans).The_Task(1).
                                Pav.Synch_P_Ref:= A_Synch_Param_Ref;
                              Transaction(Current_Trans).The_Task(1).Pav.
                                P_R_Ref :=Driver_Proc_Ref;
                              Transaction(Current_Trans).The_Task(1).Pav.
                                S_Policy_Ref :=
                                Scheduling_Policies.Fixed_Priority_Policy_Ref
                                (Driver_S_Policy_Ref);
                           when Full_Duplex =>
                              -- Send transaction
                              Current_Trans:=Current_Trans+1;
                              Transaction(Current_Trans).Transaction_Id:=
                                Current_Trans;
                              Transaction(Current_Trans).Kind_Of_Event:=Periodic;
                              Transaction(Current_Trans).Trans_Input_Type:=
                                External;
                              Transaction(Current_Trans).Ti:=
                                Processing_Resources.Network.
                                Min_Packet_Transmission_Time
                                (Processing_Resources.Network.Packet_Based_Network
                                 (A_Proc_Ref.all))/Speed;
                              Transaction(Current_Trans).Ni:=1;
                              Transaction(Current_Trans).The_Task(1):=
                                (Cijown => WS_Ovhd,
                                 Cbijown=> BS_Ovhd,
                                 Cij    => WS_Ovhd,
                                 Cbij   => BS_Ovhd,
                                 Tijown => Transaction(Current_Trans).Ti,
                                 Tij    => Transaction(Current_Trans).Ti,
                                 Bij    => 0.0,
                                 Dij    => Large_Time,
                                 SDij    => 0.0,
                                 Schedij => FP,
                                 Oij    => 0.0,
                                 Jij    => 0.0,
                                 Jinit  => 0.0,
                                 Sched_Delay      => 0.0,
                                 Oijmin           => 0.0,
                                 Oijmax           => 0.0,
                                 Delayijmin       => 0.0,
                                 Delayijmax       => 0.0,
                                 Model            => Regular,
                                 Jitter_Avoidance => False,
                                 Uses_Shared_Resources => False,
                                 Rij    => 0.0,
                                 Rbij   => 0.0,
                                 Prioij =>Scheduling_Parameters.The_Priority
                                   (Scheduling_Parameters.
                                    Fixed_Priority_Parameters'Class
                                    (A_Sched_Param_Ref.all)),
                                 Procij =>Get_Processor_Number
                                   (The_System,Driver_Proc_Ref),
                                 Resij  => null,
                                 Pav => Transaction(Current_Trans).
                                   The_Task(1).Pav);
                              -- if interrupt priority, hard prio is true
                              Transaction(Current_Trans).The_Task(1).
                                Pav.Hard_Prio:=
                                Transaction(Current_Trans).The_Task(1).Prioij in
                                Min_Int_Priority..Max_Int_Priority;
                              Transaction(Current_Trans).The_Task(1).
                                Pav.Preassigned := True;
                              Transaction(Current_Trans).The_Task(1).
                                Pav.S_P_Ref :=A_Sched_Param_Ref;
                              Transaction(Current_Trans).The_Task(1).
                                Pav.Synch_P_Ref:= A_Synch_Param_Ref;
                              Transaction(Current_Trans).The_Task(1).
                                Pav.P_R_Ref :=Driver_Proc_Ref;
                              Transaction(Current_Trans).The_Task(1).Pav.
                                S_Policy_Ref :=
                                Scheduling_Policies.Fixed_Priority_Policy_Ref
                                (Driver_S_Policy_Ref);
                              -- Receive transaction
                              Current_Trans:=Current_Trans+1;
                              Transaction(Current_Trans).Transaction_Id:=
                                Current_Trans;
                              Transaction(Current_Trans).Kind_Of_Event:=Periodic;
                              Transaction(Current_Trans).Trans_Input_Type:=
                                External;
                              Transaction(Current_Trans).Ti:=
                                Processing_Resources.Network.
                                Min_Packet_Transmission_Time
                                (Processing_Resources.Network.
                                 Packet_Based_Network'Class(A_Proc_Ref.all))/
                                Speed;
                              Transaction(Current_Trans).Ni:=1;
                              Transaction(Current_Trans).The_Task(1):=
                                (Cijown => WR_Ovhd,
                                 Cbijown=> BR_Ovhd,
                                 Cij    => WR_Ovhd,
                                 Cbij   => BR_Ovhd,
                                 Tijown => Transaction(Current_Trans).Ti,
                                 Tij    => Transaction(Current_Trans).Ti,
                                 Bij    => 0.0,
                                 Dij    => Large_Time,
                                 SDij    => 0.0,
                                 Schedij => FP,
                                 Oij    => 0.0,
                                 Jij    => 0.0,
                                 Jinit  => 0.0,
                                 Sched_Delay      => 0.0,
                                 Oijmin           => 0.0,
                                 Oijmax           => 0.0,
                                 Delayijmin       => 0.0,
                                 Delayijmax       => 0.0,
                                 Model            => Regular,
                                 Jitter_Avoidance => False,
                                 Uses_Shared_Resources => False,
                                 Rij    => 0.0,
                                 Rbij   => 0.0,
                                 Prioij =>Scheduling_Parameters.The_Priority
                                   (Scheduling_Parameters.
                                    Fixed_Priority_Parameters'Class
                                    (A_Sched_Param_Ref.all)),
                                 Procij =>Get_Processor_Number
                                   (The_System,Driver_Proc_Ref),
                                 Resij  => null,
                                 Pav => Transaction(Current_Trans).The_Task(1).
                                   Pav);
                              -- if interrupt priority, hard prio is true
                              Transaction(Current_Trans).The_Task(1).
                                Pav.Hard_Prio:=
                                Transaction(Current_Trans).The_Task(1).Prioij in
                                Min_Int_Priority..Max_Int_Priority;
                              Transaction(Current_Trans).The_Task(1).
                                Pav.Preassigned := True;
                              Transaction(Current_Trans).The_Task(1).
                                Pav.S_P_Ref := A_Sched_Param_Ref;
                              Transaction(Current_Trans).The_Task(1).
                                Pav.Synch_P_Ref := A_Synch_Param_Ref;
                              Transaction(Current_Trans).The_Task(1).
                                Pav.P_R_Ref := Driver_Proc_Ref;
                              Transaction(Current_Trans).The_Task(1).Pav.
                                S_Policy_Ref :=
                                Scheduling_Policies.Fixed_Priority_Policy_Ref
                                (Driver_S_Policy_Ref);
                        end case;

                     when  Drivers.Coupled =>
                        --Coupled Overhead Model
                        null;
                  end case;

                  -- For character drivers add character driver overhead
                  if Drv_Ref.all in Drivers.Character_Packet_Driver'Class
                  then
                     A_Server_Ref:=Drivers.Character_Server
                       (Drivers.Character_Packet_Driver'Class(Drv_Ref.all));
                     A_Sched_Param_Ref:=Scheduling_Servers.
                       Server_Sched_Parameters(A_Server_Ref.all);
                     A_Synch_Param_Ref:=Scheduling_Servers.
                       Server_Synch_Parameters(A_Server_Ref.all);
                     Driver_Proc_Ref :=
                       Scheduling_Servers.Server_Processing_Resource
                       (A_Server_Ref.all);
                     Driver_S_Policy_Ref :=
                       Schedulers.Scheduling_Policy
                       (Scheduling_Servers.Server_Scheduler
                        (A_Server_Ref.all).all);
                     Speed:=Processing_Resources.Speed_Factor
                       (Driver_Proc_Ref.all);
                     if Driver_Proc_Ref.all in
                       Processing_Resources.Network.Network'Class
                     then
                        Throughput:=Processing_Resources.Network.Throughput
                          (Processing_Resources.Network.Network'Class
                           (Driver_Proc_Ref.all));
                     else
                        Throughput:=0.0;
                     end if;
                     if Drivers.Character_Send_Operation
                       (Drivers.Character_Packet_Driver'Class
                        (Drv_Ref.all))/=null
                     then
                        WS_Ovhd:=Operations.Worst_Case_Execution_Time
                          (Drivers.Character_Send_Operation
                           (Drivers.Character_Packet_Driver'Class
                            (Drv_Ref.all)).all,Throughput)/Speed;
                        BS_Ovhd:=Operations.Best_Case_Execution_Time
                          (Drivers.Character_Send_Operation
                           (Drivers.Character_Packet_Driver'Class
                            (Drv_Ref.all)).all,Throughput)/Speed;
                     else
                        WS_Ovhd:=0.0;
                        BS_Ovhd:=0.0;
                     end if;
                     if Drivers.Character_Receive_Operation
                       (Drivers.Character_Packet_Driver'Class
                        (Drv_Ref.all))/=null
                     then
                        WR_Ovhd:=Operations.Worst_Case_Execution_Time
                          (Drivers.Character_Receive_Operation
                           (Drivers.Character_Packet_Driver'Class
                            (Drv_Ref.all)).all,Throughput)/Speed;
                        BR_Ovhd:=Operations.Best_Case_Execution_Time
                          (Drivers.Character_Receive_Operation
                           (Drivers.Character_Packet_Driver'Class
                            (Drv_Ref.all)).all,Throughput)/Speed;
                     else
                        WR_Ovhd:=0.0;
                        BR_Ovhd:=0.0;
                     end if;

                     case Processing_Resources.Network.Transmission_Mode
                       (Processing_Resources.Network.Network'Class
                        (A_Proc_Ref.all)) is
                        when Simplex | Half_Duplex=>
                           Current_Trans:=Current_Trans+1;
                           Transaction(Current_Trans).Transaction_Id:=
                             Current_Trans;
                           Transaction(Current_Trans).Kind_Of_Event:=
                             Periodic;
                           Transaction(Current_Trans).Trans_Input_Type:=
                             External;
                           Transaction(Current_Trans).Ti:=
                             Drivers.Character_Transmission_Time
                             (Drivers.Character_Packet_Driver'Class
                              (Drv_Ref.all));
                           Transaction(Current_Trans).Ni:=1;
                           Transaction(Current_Trans).The_Task(1):=
                             (Cijown => Time'Max(WS_Ovhd,WR_Ovhd),
                              Cbijown=> Time'Max(BS_Ovhd,BR_Ovhd),
                              Cij    => Time'Max(WS_Ovhd,WR_Ovhd),
                              Cbij   => Time'Max(BS_Ovhd,BR_Ovhd),
                              Tijown => Transaction(Current_Trans).Ti,
                              Tij    => Transaction(Current_Trans).Ti,
                              Bij    => 0.0,
                              Dij    => Large_Time,
                              SDij    => 0.0,
                              Schedij => FP,
                              Oij    => 0.0,
                              Jij    => 0.0,
                              Jinit  => 0.0,
                              Sched_Delay      => 0.0,
                              Oijmin           => 0.0,
                              Oijmax           => 0.0,
                              Delayijmin       => 0.0,
                              Delayijmax       => 0.0,
                              Model            => Regular,
                              Jitter_Avoidance => False,
                              Uses_Shared_Resources => False,
                              Rij    => 0.0,
                              Rbij   => 0.0,
                              Prioij =>Scheduling_Parameters.The_Priority
                                (Scheduling_Parameters.
                                 Fixed_Priority_Parameters'Class
                                 (A_Sched_Param_Ref.all)),
                              Procij =>Get_Processor_Number
                                (The_System,Driver_Proc_Ref),
                              Resij  => null,
                              Pav => Transaction(Current_Trans).
                                The_Task(1).Pav);
                           -- if interrupt priority, hard prio is true
                           Transaction(Current_Trans).The_Task(1).
                             Pav.Hard_Prio:=
                             Transaction(Current_Trans).The_Task(1).Prioij
                             in Min_Int_Priority..Max_Int_Priority;
                           Transaction(Current_Trans).The_Task(1).
                             Pav.Preassigned := True;
                           Transaction(Current_Trans).The_Task(1).
                             Pav.S_P_Ref := A_Sched_Param_Ref;
                           Transaction(Current_Trans).The_Task(1).
                             Pav.Synch_P_Ref := A_Synch_Param_Ref;
                           Transaction(Current_Trans).The_Task(1).
                             Pav.P_R_Ref := Driver_Proc_Ref;
                           Transaction(Current_Trans).The_Task(1).Pav.
                             S_Policy_Ref :=
                             Scheduling_Policies.Fixed_Priority_Policy_Ref
                             (Driver_S_Policy_Ref);
                        when Full_Duplex =>
                           -- Send transaction
                           Current_Trans:=Current_Trans+1;
                           Transaction(Current_Trans).Transaction_Id:=
                             Current_Trans;
                           Transaction(Current_Trans).Kind_Of_Event:=
                             Periodic;
                           Transaction(Current_Trans).Trans_Input_Type:=
                             External;
                           Transaction(Current_Trans).Ti:=
                             Drivers.Character_Transmission_Time
                             (Drivers.Character_Packet_Driver'Class
                              (Drv_Ref.all));
                           Transaction(Current_Trans).Ni:=1;
                           Transaction(Current_Trans).The_Task(1):=
                             (Cijown => WS_Ovhd,
                              Cbijown=> BS_Ovhd,
                              Cij    => WS_Ovhd,
                              Cbij   => BS_Ovhd,
                              Tijown => Transaction(Current_Trans).Ti,
                              Tij    => Transaction(Current_Trans).Ti,
                              Bij    => 0.0,
                              Dij    => Large_Time,
                              SDij    => 0.0,
                              Schedij => FP,
                              Oij    => 0.0,
                              Jij    => 0.0,
                              Jinit  => 0.0,
                              Sched_Delay      => 0.0,
                              Oijmin           => 0.0,
                              Oijmax           => 0.0,
                              Delayijmin       => 0.0,
                              Delayijmax       => 0.0,
                              Model            => Regular,
                              Jitter_Avoidance => False,
                              Uses_Shared_Resources => False,
                              Rij    => 0.0,
                              Rbij   => 0.0,
                              Prioij =>Scheduling_Parameters.The_Priority
                                (Scheduling_Parameters.
                                 Fixed_Priority_Parameters'Class
                                 (A_Sched_Param_Ref.all)),
                              Procij =>Get_Processor_Number
                                (The_System,Driver_Proc_Ref),
                              Resij  => null,
                              Pav => Transaction(Current_Trans).
                                The_Task(1).Pav);
                           -- if interrupt priority, hard prio is true
                           Transaction(Current_Trans).The_Task(1).
                             Pav.Hard_Prio:=
                             Transaction(Current_Trans).The_Task(1).Prioij
                             in Min_Int_Priority..Max_Int_Priority;
                           Transaction(Current_Trans).The_Task(1).
                             Pav.Preassigned := True;
                           Transaction(Current_Trans).The_Task(1).
                             Pav.S_P_Ref := A_Sched_Param_Ref;
                           Transaction(Current_Trans).The_Task(1).
                             Pav.Synch_P_Ref := A_Synch_Param_Ref;
                           Transaction(Current_Trans).The_Task(1).
                             Pav.P_R_Ref := Driver_Proc_Ref;
                           Transaction(Current_Trans).The_Task(1).Pav.
                             S_Policy_Ref :=
                             Scheduling_Policies.Fixed_Priority_Policy_Ref
                             (Driver_S_Policy_Ref);
                           -- Receive transaction
                           Current_Trans:=Current_Trans+1;
                           Transaction(Current_Trans).Transaction_Id:=
                             Current_Trans;
                           Transaction(Current_Trans).Kind_Of_Event:=
                             Periodic;
                           Transaction(Current_Trans).Trans_Input_Type:=
                             External;
                           Transaction(Current_Trans).Ti:=
                             Drivers.Character_Transmission_Time
                             (Drivers.Character_Packet_Driver'Class
                              (Drv_Ref.all));
                           Transaction(Current_Trans).Ni:=1;
                           Transaction(Current_Trans).The_Task(1):=
                             (Cijown => WR_Ovhd,
                              Cbijown=> BR_Ovhd,
                              Cij    => WR_Ovhd,
                              Cbij   => BR_Ovhd,
                              Tijown => Transaction(Current_Trans).Ti,
                              Tij    => Transaction(Current_Trans).Ti,
                              Bij    => 0.0,
                              Dij    => Large_Time,
                              SDij    => 0.0,
                              Schedij => FP,
                              Oij    => 0.0,
                              Jij    => 0.0,
                              Jinit  => 0.0,
                              Sched_Delay      => 0.0,
                              Oijmin        => 0.0,
                              Oijmax           => 0.0,
                              Delayijmin       => 0.0,
                              Delayijmax       => 0.0,
                              Model            => Regular,
                              Jitter_Avoidance => False,
                              Uses_Shared_Resources => False,
                              Rij    => 0.0,
                              Rbij   => 0.0,
                              Prioij =>Scheduling_Parameters.The_Priority
                                (Scheduling_Parameters.
                                 Fixed_Priority_Parameters'Class
                                 (A_Sched_Param_Ref.all)),
                              Procij =>Get_Processor_Number
                                (The_System,Driver_Proc_Ref),
                              Resij  => null,
                              Pav => Transaction(Current_Trans).
                                The_Task(1).Pav);
                           -- if interrupt priority, hard prio is true
                           Transaction(Current_Trans).The_Task(1).
                             Pav.Hard_Prio:=
                             Transaction(Current_Trans).The_Task(1).Prioij
                             in Min_Int_Priority..Max_Int_Priority;
                           Transaction(Current_Trans).The_Task(1).
                             Pav.Preassigned := True;
                           Transaction(Current_Trans).The_Task(1).
                             Pav.S_P_Ref := A_Sched_Param_Ref;
                           Transaction(Current_Trans).The_Task(1).
                             Pav.Synch_P_Ref := A_Synch_Param_Ref;
                           Transaction(Current_Trans).The_Task(1).
                             Pav.P_R_Ref := Driver_Proc_Ref;
                           Transaction(Current_Trans).The_Task(1).Pav.
                             S_Policy_Ref :=
                             Scheduling_Policies.Fixed_Priority_Policy_Ref
                             (Driver_S_Policy_Ref);
                     end case;
                  elsif Drv_Ref.all in Drivers.RTEP_Packet_Driver'Class then
                     -- for RTEP Packet Driver add additional overhead
                     null;--...
                  end if;
               else
                  -- incorrect driver kind
                  raise Incorrect_Object;
               end if;
            end loop;
         elsif A_Proc_Ref.all in
           Processing_Resources.Processor.Processor'Class
         then

            --add the transactions caused by Ticker system timers
            Timer_Ref:=Processing_Resources.Processor.The_System_Timer
              (Processing_Resources.Processor.Regular_Processor'Class
               (A_Proc_Ref.all));
            if Timer_Ref/=null and then
              Timer_Ref.all in Timers.Ticker'Class
            then
               Current_Trans:=Current_Trans+1;
               Transaction(Current_Trans).Transaction_Id:=
                 Current_Trans;
               Transaction(Current_Trans).Kind_Of_Event:=Periodic;
               Transaction(Current_Trans).Trans_Input_Type:=External;
               Transaction(Current_Trans).Ti:=
                 Timers.Period(Timers.Ticker'Class(Timer_Ref.all));
               Transaction(Current_Trans).Ni:=1;
               Transaction(Current_Trans).The_Task(1):=
                 (Cijown => Timers.Worst_Overhead(Timer_Ref.all)/Speed,
                  Cbijown=> Timers.Best_Overhead(Timer_Ref.all)/Speed,
                  Cij    => Timers.Worst_Overhead(Timer_Ref.all)/Speed,
                  Cbij   => Timers.Best_Overhead(Timer_Ref.all)/Speed,
                  Tijown => Transaction(Current_Trans).Ti,
                  Tij    => Transaction(Current_Trans).Ti,
                  Bij    => 0.0,
                  Dij    => Large_Time,
                  SDij    => 0.0,
                  Schedij => FP,
                  Oij    => 0.0,
                  Jij    => 0.0,
                  Jinit  => 0.0,
                  Sched_Delay      => 0.0,
                  Oijmin           => 0.0,
                  Oijmax           => 0.0,
                  Delayijmin       => 0.0,
                  Delayijmax       => 0.0,
                  Model            => Regular,
                  Jitter_Avoidance => False,
                  Uses_Shared_Resources => False,
                  Rij    => 0.0,
                  Rbij   => 0.0,
                  Prioij => Processing_Resources.Processor.
                    Max_Interrupt_Priority
                    (Processing_Resources.Processor.Regular_Processor'Class
                     (A_Proc_Ref.all)),
                  Procij => Proc_Num,
                  Resij  => null,
                  Pav => Transaction(Current_Trans).The_Task(1).Pav);
               Transaction(Current_Trans).The_Task(1).Pav.Hard_Prio := True;
               Transaction(Current_Trans).The_Task(1).Pav.Preassigned := True;
               Transaction(Current_Trans).The_Task(1).Pav.P_R_Ref :=
                 A_Proc_Ref;
               Transaction(Current_Trans).The_Task(1).Pav.
                 S_Policy_Ref :=
                 Scheduling_Policies.Fixed_Priority_Policy_Ref
                 (A_Sched_Policy_Ref);
            end if;
         else
            raise Incorrect_Object;
         end if;
      end loop;

      -- Add overhead tasks

      declare
         The_Data : Task_Data;
         Iterator : Overhead_Task_Lists.Iteration_Object;
      begin
         Overhead_Task_Lists.Rewind(Overhead_Task_List,Iterator);
         for I in 1..Overhead_Task_Lists.Size(Overhead_Task_List) loop
            Overhead_Task_Lists.Get_Next_Item
              (The_Data,Overhead_Task_List,Iterator);
            Current_Trans:=Current_Trans+1;
            Transaction(Current_Trans).Transaction_Id:=Current_Trans;
            Transaction(Current_Trans).Ti:=The_Data.Tij;
            Transaction(Current_Trans).Kind_Of_Event:=Periodic;
            Transaction(Current_Trans).Trans_Input_Type:=External;
            Transaction(Current_Trans).Ni:=1;
            Transaction(Current_Trans).The_Task(1):=The_Data;
         end loop;
      end;

      -- Add empty transactions to fill array
      for Empty in Current_Trans+1..Max_Transactions loop
         Transaction(Empty).Ti:=Large_Time;
         Transaction(Empty).Ni:=0;
      end loop;

      -- Show data

      if Verbose then
         Put_Line("Transaction data obtained for analysis : ");
         Show_Linear_Translation(Transaction);
      end if;

   end Translate_Linear_System;

   -----------------------------
   -- Show_Linear_Translation --
   -----------------------------

   procedure Show_Linear_Translation
     (Transaction : in Linear_Transaction_System) is
   begin
      for Trans in 1..Max_Transactions loop
         exit when Transaction(Trans).Ni=0;
         Put_Line("Transaction : "&Transaction_ID_Type'Image(Trans)&
                  " Period:"&IO.Time_Image(Transaction(Trans).Ti)&
                  " ID= "&Transaction_ID_Type'Image
                  (Transaction(Trans).Transaction_ID)&
                  " Trans_Input_Type= "&Transaction_Input_Type'Image
                  (Transaction(Trans).Trans_Input_Type));
         for Tsk in 1..Transaction(Trans).Ni loop
            Put_Line
              ("   Task "&Task_ID_Type'Image(Tsk)&
               " Cijown:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).Cijown)&
               " Cbijown:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).Cbijown)&
               " Cij:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).Cij)&
               " Cbij:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).Cbij)&
               " Tijown:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).Tijown)&
               " Tij:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).Tij)&
               " Bij:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).Bij)&
               " Dij:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).Dij)&
               " SDij:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).SDij)&
               " Schedij:"&Sched_Type'Image
               (Transaction(Trans).The_Task(Tsk).Schedij)&
               " Oij:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).Oij)&
               " Jinit:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).Jinit)&
               " Prioij:"&Priority'Image
               (Transaction(Trans).The_Task(Tsk).Prioij)&
               " Procij:"&Processor_ID_Type'Image
               (Transaction(Trans).The_Task(Tsk).Procij)&
               " Sch_D:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).Sched_Delay)&
               " Delayijmin:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).Delayijmin)&
               " Delayijmax:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).Delayijmax)&
               " Oijmin:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).Oijmin)&
               " Oijmax:"&IO.Time_Image
               (Transaction(Trans).The_Task(Tsk).Oijmax)&
               " Model: "&Model_Levels'Image
               (Transaction(Trans).The_Task(Tsk).Model)&
               " JA : "&Boolean'Image
               (Transaction(Trans).The_Task(Tsk).Jitter_Avoidance));
         end loop;
      end loop;
   end Show_Linear_Translation;

   ---------------------------------------
   -- Translate_Linear_Analysis_Results --
   ---------------------------------------

   procedure Translate_Linear_Analysis_Results
     (Transaction : in Linear_Transaction_System;
      The_System : in out MAST.Systems.System)
   is
      Next_Link_Ref : MAST.Graphs.Link_Ref;
      A_Result     : MAST.Results.Timing_Result_Ref;
      Trans : Linear_Transaction_System;
   begin
      Trans:=Transaction;
      -- Take into account the tasks with unbounded effects on
      -- lower priority tasks
      for I in Transaction_ID_Type range 1..Max_Transactions loop
         exit when Trans(I).Ni=0;
         for J in 1..Trans(I).Ni loop
            if Trans(I).The_Task(J).Model=Unbounded_Effects then
               for K in Transaction_ID_Type range 1..Max_Transactions loop
                  exit when Trans(K).Ni=0;
                  for L in 1..Trans(K).Ni loop
                     if Trans(K).The_Task(L).Procij=
                       Trans(I).The_Task(J).Procij and then
                       Trans(K).The_Task(L).Prioij<=
                       Trans(I).The_Task(J).Prioij
                     then
                        Trans(K).The_Task(L).Rij:=Large_Time;
                     end if;
                  end loop;
               end loop;
            end if;
         end loop;
      end loop;

      -- Set the result values for all transactions
      for I in Transaction_ID_Type range 1..Max_Transactions loop
         exit when Trans(I).Ni=0;
         for J in 1..Trans(I).Ni loop
            -- Find link at the end of the segment
            Next_Link_Ref:=Trans(I).The_Task(J).Resij;
            if Next_Link_Ref/=null then
               if Graphs.Has_Results(Next_Link_Ref.all) then
                  A_Result:=Graphs.Links.Link_Time_Results
                    (Graphs.Links.Regular_Link(Next_Link_Ref.all));
               else
                  A_Result:=MAST.Results.Create_Timing_Result(Next_Link_Ref);
               end if;
               -- Set the result values
               case Trans(I).The_Task(J).Model is
                  when Regular | Separate_Analysis =>
                     MAST.Results.Set_Worst_Global_Response_Time
                       (A_Result.all,
                        Trans(I).Evi,Trans(I).The_Task(J).Rij+
                        Trans(I).The_Task(J).Sched_Delay);
                  when Unbounded_Response | Unbounded_Effects =>
                     MAST.Results.Set_Worst_Global_Response_Time
                       (A_Result.all,
                        Trans(I).Evi,Large_Time);
               end case;
               MAST.Results.Set_Best_Global_Response_Time
                 (A_Result.all,
                  Trans(I).Evi,Trans(I).The_Task(J).Rbij);
               MAST.Results.Set_Jitter
                 (A_Result.all,
                  Trans(I).Evi,Trans(I).The_Task(J).Rij-
                  Trans(I).The_Task(J).Rbij);
            end if;
         end loop;
      end loop;
   end Translate_Linear_Analysis_Results;

   ------------------------------------------
   -- Translate_Linear_System_With_Results --
   ------------------------------------------

   procedure Translate_Linear_System_With_Results
     (The_System : in MAST.Systems.System;
      Transaction : out Linear_Transaction_System;
      Verbose : in Boolean:=False)
   is
      Next_Link_Ref : MAST.Graphs.Link_Ref;
      A_Result     : MAST.Results.Timing_Result_Ref;
   begin
      Translate_Linear_System(The_System,Transaction,Verbose);
      for I in Transaction_ID_Type range 1..Max_Transactions loop
         exit when Transaction(I).Ni=0;
         for J in 1..Transaction(I).Ni loop
            -- Find link at the end of the segment
            Next_Link_Ref:=Transaction(I).The_Task(J).Resij;
            if Next_Link_Ref/=null and then
              Graphs.Has_Results(Next_Link_Ref.all)
            then
               A_Result:=Graphs.Links.Link_Time_Results
                 (Graphs.Links.Regular_Link(Next_Link_Ref.all));
               -- Get the result values
               Transaction(I).The_Task(J).Rij :=
                 MAST.Results.Worst_Global_Response_Time
                 (A_Result.all,Transaction(I).Evi);
               Transaction(I).The_Task(J).Rbij :=
                 MAST.Results.Best_Global_Response_Time
                 (A_Result.all,Transaction(I).Evi);
               Transaction(I).The_Task(J).Jij :=
                 MAST.Results.Jitter
                 (A_Result.all,Transaction(I).Evi);
            end if;
         end loop;
      end loop;
   end Translate_Linear_System_With_Results;

   --------------------------
   -- Translate_Priorities --
   --------------------------

   procedure Translate_Priorities
     (Transaction : in Linear_Transaction_System;
      The_System : in out MAST.Systems.System)
   is
   begin
      for I in Transaction_ID_Type range 1..Max_Transactions loop
         exit when Transaction(I).Ni=0;
         for J in 1..Transaction(I).Ni loop
            -- Assign priorities via S_P_Ref field
            if not Transaction(I).The_Task(J).Pav.Hard_Prio
              and then
              not Transaction(I).The_Task(J).Pav.Preassigned
              and then
              not Transaction(I).The_Task(J).Pav.Is_Polling
              and then
              Transaction(I).The_Task(J).Pav.S_P_Ref /= null
            then
               if Transaction(I).The_Task(J).Pav.S_P_Ref.all in
                 Scheduling_Parameters.Fixed_Priority_Parameters'Class
               then
                  Mast.Scheduling_Parameters.Set_The_Priority
                    (Mast.Scheduling_Parameters.Fixed_Priority_Parameters
                     (Transaction(I).The_Task(J).Pav.S_P_Ref.all),
                     Transaction(I).The_Task(J).Prioij);
               else
                  Tool_Exceptions.Set_Tool_Failure_Message
                    ("Incorrect writing of priorities");
                  raise Tool_Exceptions.Tool_Failure;
               end if;
            end if;
         end loop;
      end loop;
   end Translate_Priorities;

end Mast.Linear_Translation;
