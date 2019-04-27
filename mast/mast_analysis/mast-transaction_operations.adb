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

with MAST.Graphs.Event_Handlers,Mast.Events,Mast.Scheduling_Servers,
  Mast.Processing_Resources,Mast.Processing_Resources.Processor,
  Mast.Processing_Resources.Processor, Mast.Processing_Resources.Network,
  Mast.Schedulers,Mast.Scheduling_Policies,
  Mast.Scheduling_Parameters,Mast.Operations,Mast.Graphs.Links,
  Mast.Results;
use type MAST.Graphs.Link_Ref;
use type MAST.Graphs.Event_Handler_Ref;
use type Mast.Events.Event_Ref;
use type Mast.Scheduling_Servers.Scheduling_Server_Ref;
use type Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
package body MAST.Transaction_Operations is

   ----------------------------------
   -- Identify_Segment             --
   ----------------------------------

   procedure Identify_Segment
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      The_Link_Ref : MAST.Graphs.Link_Ref;
      Next_Link_Ref : out MAST.Graphs.Link_Ref)
   is
      An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
      Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
   begin
      An_Event_Handler_Ref:=MAST.Graphs.
        Output_Event_Handler(The_Link_Ref.all);
      if An_Event_Handler_Ref=null or else An_Event_Handler_Ref.all not in
        MAST.Graphs.Event_Handlers.Activity'Class
      then
         raise Incorrect_Link;
      end if;
      Srvr_Ref:=Graphs.Event_Handlers.Activity_Server
        (Graphs.Event_Handlers.Activity(An_Event_Handler_Ref.all));
      loop
         Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
           (MAST.Graphs.Event_Handlers.Activity
            (An_Event_Handler_Ref.all));
         An_Event_Handler_Ref:=MAST.Graphs.
           Output_Event_Handler(Next_Link_Ref.all);
         exit when An_Event_Handler_Ref=null or else
           An_Event_Handler_Ref.all not in
           MAST.Graphs.Event_Handlers.Activity'Class or else
           Srvr_Ref/=Graphs.Event_Handlers.Activity_Server
           (Graphs.Event_Handlers.Activity(An_Event_Handler_Ref.all));
      end loop;
   end Identify_Segment;

   ----------------------------------------
   -- Identify_Segment_With_Permanent_FP --
   ----------------------------------------

   procedure Identify_Segment_With_Permanent_FP
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      The_Link_Ref : MAST.Graphs.Link_Ref;
      Next_Link_Ref : out MAST.Graphs.Link_Ref)
   is
      An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
      Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
      Op_Ref : Operations.Operation_Ref;
      Over_Ref : Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      First_Time : Boolean:=True;
   begin
      An_Event_Handler_Ref:=MAST.Graphs.
        Output_Event_Handler(The_Link_Ref.all);
      if An_Event_Handler_Ref=null or else An_Event_Handler_Ref.all not in
        MAST.Graphs.Event_Handlers.Activity'Class
      then
         raise Incorrect_Link;
      end if;
      Srvr_Ref:=Graphs.Event_Handlers.Activity_Server
        (Graphs.Event_Handlers.Activity(An_Event_Handler_Ref.all));
      loop
         Op_Ref:=Graphs.Event_Handlers.Activity_Operation
           (Graphs.Event_Handlers.Activity(An_Event_Handler_Ref.all));
         Over_Ref:=Operations.New_Sched_Parameters(Op_Ref.all);
         if First_Time then
            First_Time:=False;
         else
            -- If permanent overridden FP then finish segment
            exit when Over_Ref/=null and then Over_Ref.all in
              Scheduling_Parameters.Overridden_Permanent_FP_Parameters'Class;
         end if;
         Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
           (MAST.Graphs.Event_Handlers.Activity
            (An_Event_Handler_Ref.all));
         An_Event_Handler_Ref:=MAST.Graphs.
           Output_Event_Handler(Next_Link_Ref.all);
         exit when An_Event_Handler_Ref=null or else
           An_Event_Handler_Ref.all not in
           MAST.Graphs.Event_Handlers.Activity'Class or else
           Srvr_Ref/=Graphs.Event_Handlers.Activity_Server
           (Graphs.Event_Handlers.Activity(An_Event_Handler_Ref.all));
      end loop;
   end Identify_Segment_With_Permanent_FP;

   ----------------------------------
   -- Time_With_Overhead           --
   ----------------------------------

   function Time_With_Overhead (C, Interval, Ovhd : Time) return Time
   is
   begin
      return C+ Time'Ceiling(C/Interval)*Ovhd;
   end Time_With_Overhead;

   ----------------------------------------
   -- Get_Segment_Data_With_Permanent_FP --
   ----------------------------------------

   procedure Get_Segment_Data_With_Permanent_FP
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      The_Link_Ref : MAST.Graphs.Link_Ref;
      Next_Link_Ref : out MAST.Graphs.Link_Ref;
      WCET : out Time;
      BCET : out Time;
      Uses_Shared_Resources : out Boolean;
      Segment_Prio : in out Priority;
      Preassigned_Prio : out Boolean)
   is
      An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
      Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref;
      Proc_Ref : Processing_Resources.Processing_Resource_Ref;
      Scheduler_Ref : Schedulers.Scheduler_Ref;
      Sched_Policy_Ref : Scheduling_Policies.Scheduling_Policy_Ref;
      Op_Ref : Operations.Operation_Ref;
      Speed_Factor : Processor_Speed;
      Packet_W_Ovhd,Packet_B_Ovhd,Packet_Time : Time:=0.0;
      A_Result_Ref : MAST.Results.Timing_Result_Ref;
      Num_Suspensions : Natural:=0;
      Is_Network : Boolean:=False;
      Throughput : Throughput_Value:=0.0;
      Sched_Param_Ref : Scheduling_Parameters.Sched_Parameters_Ref;
      Over_Ref : Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      First_Time : Boolean:=True;

   begin
      Preassigned_Prio :=False;
      Uses_Shared_Resources:=False;
      An_Event_Handler_Ref:=MAST.Graphs.
        Output_Event_Handler(The_Link_Ref.all);
      if An_Event_Handler_Ref=null or else An_Event_Handler_Ref.all not in
        MAST.Graphs.Event_Handlers.Activity'Class
      then
         raise Incorrect_Link;
      end if;
      Srvr_Ref:=Graphs.Event_Handlers.Activity_Server
        (Graphs.Event_Handlers.Activity(An_Event_Handler_Ref.all));
      Sched_Param_Ref:=Scheduling_Servers.Server_Sched_Parameters
        (Srvr_Ref.all);
      Scheduler_Ref:=Scheduling_Servers.Server_Scheduler(Srvr_Ref.all);
      Sched_Policy_Ref:=Schedulers.Scheduling_Policy(Scheduler_Ref.all);
      Proc_Ref:=Scheduling_Servers.Server_Processing_Resource
        (Srvr_Ref.all);
      Speed_Factor:=Processing_Resources.Speed_Factor(Proc_Ref.all);

      -- Calculate context switch overheads
      if Proc_Ref.all in Processing_Resources.Processor.Regular_Processor'Class
      then
         if Sched_Param_Ref.all in
           Scheduling_Parameters.Interrupt_FP_Policy'Class
         then
            WCET:=2.0*Processing_Resources.Processor.Worst_ISR_Switch
              (Processing_Resources.Processor.Regular_Processor'Class
               (Proc_Ref.all))/Speed_Factor;
            -- number of suspensions not considered for best case
            BCET:=2.0*Processing_Resources.Processor.Best_ISR_Switch
              (Processing_Resources.Processor.Regular_Processor'Class
               (Proc_Ref.all))/Speed_Factor;
         else
            if Sched_Policy_Ref.all in
              Scheduling_Policies.Fixed_Priority'Class
            then
               WCET:=2.0*Scheduling_Policies.Worst_Context_Switch
                 (Scheduling_Policies.Fixed_Priority'Class
                  (Sched_Policy_Ref.all))/Speed_Factor;
               BCET:=2.0*Scheduling_Policies.Best_Context_Switch
                 (Scheduling_Policies.Fixed_Priority'Class
                  (Sched_Policy_Ref.all))/Speed_Factor;
            elsif Sched_Policy_Ref.all in
              Scheduling_Policies.EDF'Class
            then
               WCET:=2.0*Scheduling_Policies.Worst_Context_Switch
                 (Scheduling_Policies.EDF'Class
                  (Sched_Policy_Ref.all))/Speed_Factor;
               BCET:=2.0*Scheduling_Policies.Best_Context_Switch
                 (Scheduling_Policies.EDF'Class
                  (Sched_Policy_Ref.all))/Speed_Factor;
            else
               raise Incorrect_Object;
            end if;
         end if;
      elsif Proc_Ref.all in
        Processing_Resources.Network.Packet_Based_Network'Class and then
        Sched_Policy_Ref.all in Scheduling_Policies.FP_Packet_Based'Class
      then
         WCET:=0.0;
         BCET:=0.0;
         Throughput:=Processing_Resources.Network.Throughput
           (Processing_Resources.Network.Packet_Based_Network'Class
            (Proc_Ref.all));
         Packet_W_Ovhd:=Scheduling_Policies.Packet_Worst_Overhead
           (Scheduling_Policies.FP_Packet_Based'Class(Sched_Policy_Ref.all),
           Throughput)/Speed_Factor;
         Packet_B_Ovhd:=Scheduling_Policies.Packet_Best_Overhead
           (Scheduling_Policies.FP_Packet_Based'Class(Sched_Policy_Ref.all),
           Throughput)/Speed_Factor;
         Packet_Time:=Processing_Resources.Network.Max_Packet_Transmission_Time
           (Processing_Resources.Network.Packet_Based_Network'Class
            (Proc_Ref.all))/Speed_Factor;
         Is_Network:=True;
      else
         raise Incorrect_Object;
      end if;

      -- add all execution times
      loop
         Op_Ref:=Graphs.Event_Handlers.Activity_Operation
           (Graphs.Event_Handlers.Activity(An_Event_Handler_Ref.all));
         Over_Ref:=Operations.New_Sched_Parameters(Op_Ref.all);
         if First_Time then
            First_Time:=False;
            -- Calculate new priority
            if Over_Ref/=null and then Over_Ref.all in
              Scheduling_Parameters.Overridden_Permanent_FP_Parameters'class
            then
               Segment_Prio:=Scheduling_Parameters.The_Priority
                 (Scheduling_Parameters.Overridden_FP_Parameters'Class
                  (Over_Ref.all));
               Preassigned_Prio:=True;
            end if;
         else
            -- If permanent overridden FP then finish segment
            exit when Over_Ref/=null and then Over_Ref.all in
              Scheduling_Parameters.Overridden_Permanent_FP_Parameters'Class;
         end if;

         if Is_Network then
            WCET:=WCET+Time_With_Overhead
              (Operations.Worst_Case_Execution_Time
               (Op_Ref.all,Throughput)/Speed_Factor,Packet_Time,Packet_W_Ovhd);
            BCET:=BCET+Time_With_Overhead
              (Operations.Best_Case_Execution_Time
               (Op_Ref.all,Throughput)/Speed_Factor,Packet_Time,Packet_B_Ovhd);
         else
            WCET:=WCET+Operations.Worst_Case_Execution_Time
              (Op_Ref.all,Throughput)/Speed_Factor;
            BCET:=BCET+Operations.Best_Case_Execution_Time
              (Op_Ref.all,Throughput)/Speed_Factor;
         end if;

         -- determine if the operation uses shared resources
         Uses_Shared_Resources := Uses_Shared_Resources or
           Operations.Shared_Resources_Used(Op_Ref.all);

         -- continue loop
         Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
           (MAST.Graphs.Event_Handlers.Activity
            (An_Event_Handler_Ref.all));
         An_Event_Handler_Ref:=MAST.Graphs.
           Output_Event_Handler(Next_Link_Ref.all);
         exit when An_Event_Handler_Ref=null or else
           An_Event_Handler_Ref.all not in
           MAST.Graphs.Event_Handlers.Activity'Class or else
           Srvr_Ref/=Graphs.Event_Handlers.Activity_Server
           (Graphs.Event_Handlers.Activity(An_Event_Handler_Ref.all));
      end loop;

      -- Add overhead due to suspensions

      if Proc_Ref.all in
        Processing_Resources.Processor.Processor'Class
      then
         -- Get number of suspensions
         if MAST.Graphs.Links.Has_Results
           (Graphs.Links.Regular_Link(Next_Link_Ref.all))
         then
            A_Result_Ref:=MAST.Graphs.Links.Link_Time_Results
              (MAST.Graphs.Links.Regular_Link(Next_Link_Ref.all));
            Num_Suspensions:=
              MAST.Results.Num_Of_Suspensions(A_Result_Ref.all);
         end if;

         if Sched_Param_Ref.all in
           Scheduling_Parameters.Interrupt_FP_Policy'Class
         then
            WCET:=WCET+Time(Num_Suspensions*2)*
              (Processing_Resources.Processor.Worst_ISR_Switch
              (Processing_Resources.Processor.Regular_Processor'Class
               (Proc_Ref.all))/Speed_Factor);
            -- number of suspensions not considered for best case
         else
            if Sched_Policy_Ref.all in
              Scheduling_Policies.Fixed_Priority'Class
            then
               WCET:=WCET+Time(Num_Suspensions*2)*
                 (Scheduling_Policies.Worst_Context_Switch
                  (Scheduling_Policies.Fixed_Priority'Class
                   (Sched_Policy_Ref.all))/Speed_Factor);
               -- number of suspensions not considered for best case
            elsif Sched_Policy_Ref.all in
              Scheduling_Policies.EDF'Class
            then
               WCET:=WCET+Time(Num_Suspensions*2)*
                 (Scheduling_Policies.Worst_Context_Switch
                  (Scheduling_Policies.EDF'Class
                   (Sched_Policy_Ref.all))/Speed_Factor);
               -- number of suspensions not considered for best case
            else
               raise Incorrect_Object;
            end if;
         end if;
      end if;

   end Get_Segment_Data_With_Permanent_FP;

   ----------------------------------
   -- Traverse_Paths_From_Link --
   ----------------------------------

   procedure Traverse_Paths_From_Link
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      The_Link_Ref : MAST.Graphs.Link_Ref)
   is
      An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
      First_Link_Ref, Next_Link_Ref : MAST.Graphs.Link_Ref;
      Iterator : Graphs.Event_Handlers.Iteration_Object;
   begin
      Operation_For_Links(Trans_Ref,The_Link_Ref);
      An_Event_Handler_Ref:=MAST.Graphs.
        Output_Event_Handler(The_Link_Ref.all);
      if An_Event_Handler_Ref/=null then
         Operation_For_Event_Handlers(Trans_Ref,An_Event_Handler_Ref);
         if An_Event_Handler_Ref.all in
           MAST.Graphs.Event_Handlers.Simple_Event_Handler'Class
         then
            Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
              (MAST.Graphs.Event_Handlers.Simple_Event_Handler
               (An_Event_Handler_Ref.all));
            Traverse_Paths_From_Link
              (Trans_Ref,Next_Link_Ref);
         elsif An_Event_Handler_Ref.all in
           MAST.Graphs.Event_Handlers.Output_Event_Handler'Class
         then
            MAST.Graphs.Event_Handlers.Rewind_Output_Links
              (MAST.Graphs.Event_Handlers.Output_Event_Handler
               (An_Event_Handler_Ref.all),Iterator);
            for I in 1..MAST.Graphs.Event_Handlers.Num_Of_Output_Links
              (MAST.Graphs.Event_Handlers.Output_Event_Handler
               (An_Event_Handler_Ref.all))
            loop
               MAST.Graphs.Event_Handlers.Get_Next_Output_Link
                 (MAST.Graphs.Event_Handlers.Output_Event_Handler
                  (An_Event_Handler_Ref.all),
                  Next_Link_Ref,Iterator);
               Traverse_Paths_From_Link
                 (Trans_Ref,Next_Link_Ref);
            end loop;
         else -- input Event_Handler
            Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
              (MAST.Graphs.Event_Handlers.Input_Event_Handler
               (An_Event_Handler_Ref.all));
            Traverse_Paths_From_Link
              (Trans_Ref,Next_Link_Ref);
         end if;
      end if;
   end Traverse_Paths_From_Link;

   ---------------------------------------
   -- Traverse_Paths_From_Link_Once --
   ---------------------------------------

   procedure Traverse_Paths_From_Link_Once
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      The_Link_Ref : MAST.Graphs.Link_Ref)
   is
      An_Event_Handler_Ref : MAST.Graphs.Event_Handler_Ref;
      First_Link_Ref, Next_Link_Ref : MAST.Graphs.Link_Ref;
      Iterator : Graphs.Event_Handlers.Iteration_Object;
   begin
      Operation_For_Links(Trans_Ref,The_Link_Ref);
      An_Event_Handler_Ref:=MAST.Graphs.
        Output_Event_Handler(The_Link_Ref.all);
      if An_Event_Handler_Ref/=null then
         if An_Event_Handler_Ref.all in
           MAST.Graphs.Event_Handlers.Simple_Event_Handler'Class
         then
            Operation_For_Event_Handlers(Trans_Ref,An_Event_Handler_Ref);
            Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
              (MAST.Graphs.Event_Handlers.Simple_Event_Handler
               (An_Event_Handler_Ref.all));
            Traverse_Paths_From_Link_Once
              (Trans_Ref,Next_Link_Ref);
         elsif An_Event_Handler_Ref.all in
           MAST.Graphs.Event_Handlers.Output_Event_Handler'Class
         then
            Operation_For_Event_Handlers(Trans_Ref,An_Event_Handler_Ref);
            MAST.Graphs.Event_Handlers.Rewind_Output_Links
              (MAST.Graphs.Event_Handlers.Output_Event_Handler
               (An_Event_Handler_Ref.all),Iterator);
            for I in 1..MAST.Graphs.Event_Handlers.Num_Of_Output_Links
              (MAST.Graphs.Event_Handlers.Output_Event_Handler
               (An_Event_Handler_Ref.all))
            loop
               MAST.Graphs.Event_Handlers.Get_Next_Output_Link
                 (MAST.Graphs.Event_Handlers.Output_Event_Handler
                  (An_Event_Handler_Ref.all),
                  Next_Link_Ref,Iterator);
               Traverse_Paths_From_Link_Once
                 (Trans_Ref,Next_Link_Ref);
            end loop;
         else -- input Event_Handler
            MAST.Graphs.Event_Handlers.Rewind_Input_Links
              (MAST.Graphs.Event_Handlers.Input_Event_Handler
               (An_Event_Handler_Ref.all),Iterator);
            MAST.Graphs.Event_Handlers.Get_Next_Input_Link
              (MAST.Graphs.Event_Handlers.Input_Event_Handler
               (An_Event_Handler_Ref.all),First_Link_Ref,Iterator);
            -- continue only if this is the first input Link
            if First_Link_Ref=The_Link_Ref then
               Operation_For_Event_Handlers
                 (Trans_Ref,An_Event_Handler_Ref);
               Next_Link_Ref:=MAST.Graphs.Event_Handlers.Output_Link
                 (MAST.Graphs.Event_Handlers.Input_Event_Handler
                  (An_Event_Handler_Ref.all));
               Traverse_Paths_From_Link_Once
                 (Trans_Ref,Next_Link_Ref);
            end if;
         end if;
      end if;
   end Traverse_Paths_From_Link_Once;

end MAST.Transaction_Operations;

