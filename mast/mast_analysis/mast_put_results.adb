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

with MAST.Results,MAST.Transactions,MAST.Graphs,MAST.Graphs.Links,
  MAST.Events,MAST.Systems,MAST.Timing_Requirements,Ada.Text_IO,
  Mast.Graphs.Event_Handlers, Mast.Processing_Resources,
  MAST.Operations, MAST.Scheduling_Servers, MAST.Shared_Resources,
  Mast.Synchronization_Parameters;
use MAST,
  MAST.Results,MAST.Transactions,MAST.Graphs,MAST.Graphs.Links,MAST.Events,
  Ada.Text_IO,MAST.Timing_Requirements, Mast.Synchronization_Parameters;

procedure MAST_Put_Results (The_System : in out MAST.Systems.System) is

   Trans_Ref : Transaction_Ref;
   PR_Ref : Processing_Resources.Processing_Resource_Ref;
   SR_Ref : Shared_Resources.Shared_Resource_Ref;
   Op_Ref : Operations.Operation_Ref;
   Sch_Ref : Scheduling_Servers.Scheduling_Server_Ref;
   Lnk_Ref : Link_Ref;
   Res_Ref : Timing_Result_Ref;
   The_Event : Event_Ref;
   Atr : Timing_Requirement_Ref;
   Is_Met : Boolean;
   Trans_Iterator : Mast.Transactions.Lists.Index;
   PR_Iterator : Mast.Processing_Resources.Lists.Index;
   Op_Iterator : Mast.Operations.Lists.Index;
   SR_Iterator : Mast.Shared_Resources.Lists.Index;
   Sch_Iterator : Mast.Scheduling_Servers.Lists.Index;
   Link_Iterator, Ext_Link_Iterator : Mast.Transactions.Link_Iteration_Object;

   The_Slack_Ref : Results.Slack_Result_Ref;
   The_Ceiling_Ref : Results.Ceiling_Result_Ref;
   The_PL_Ref : Results.Preemption_Level_Result_Ref;
   The_Utilization_Ref : Results.Utilization_Result_Ref;
   The_Size_Ref : Results.Queue_Size_Result_Ref;
   The_Sched_Res_Ref : Results.Sched_Params_Result_Ref;
   The_Synch_Res_Ref : Results.Synch_Params_Result_Ref;
   The_Synch_Params_Ref : Synchronization_Parameters.Synch_Parameters_Ref;

begin

   -- Processing_Resource Results

   Processing_Resources.Lists.Rewind
     (The_System.Processing_Resources,PR_Iterator);
   for I in 1..Processing_Resources.Lists.Size
     (The_System.Processing_Resources)
   loop
      Processing_Resources.Lists.Get_Next_Item
        (PR_Ref,The_System.Processing_Resources,PR_Iterator);

      The_Slack_Ref:=new Results.Slack_Result;
      Results.Set_Slack(The_Slack_Ref.all,50.0);
      Processing_Resources.Set_Slack_Result(PR_Ref.all,The_Slack_Ref);

      The_Utilization_Ref:=new Results.Detailed_Utilization_Result;
      Results.Set_Total(The_Utilization_Ref.all,50.0);
      Results.Set_Application
        (Results.Detailed_Utilization_Result(The_Utilization_Ref.all),40.0);
      Results.Set_Context_Switch
        (Results.Detailed_Utilization_Result(The_Utilization_Ref.all),30.0);
      Processing_Resources.Set_Utilization_Result
        (PR_Ref.all,The_Utilization_Ref);
      Results.Set_Timer
        (Results.Detailed_Utilization_Result(The_Utilization_Ref.all),20.0);
      Results.Set_driver
        (Results.Detailed_Utilization_Result(The_Utilization_Ref.all),5.0);

      The_Size_Ref:=new Results.Ready_Queue_Size_Result;
      Results.Set_Max_Num(The_Size_Ref.all,555);
      Processing_Resources.Set_Ready_Queue_Size_Result
        (PR_Ref.all,Results.Ready_Queue_Size_Result_Ref(The_Size_Ref));
   end loop;

   -- Operation Results

   Operations.Lists.Rewind
     (The_System.Operations,Op_Iterator);
   for I in 1..2 --Operations.Lists.Size(The_System.Operations)
   loop
      Operations.Lists.Get_Next_Item
        (Op_Ref,The_System.Operations,Op_Iterator);

      The_Slack_Ref:=new Results.Slack_Result;
      Results.Set_Slack(The_Slack_Ref.all,3.0);
      Operations.Set_Slack_Result(Op_Ref.all,The_Slack_Ref);

   end loop;

   -- Scheduling Server Results

   Scheduling_Servers.Lists.Rewind
     (The_System.Scheduling_Servers,Sch_Iterator);
   for I in 1..Scheduling_Servers.Lists.Size(The_System.Scheduling_Servers)
   loop
      Scheduling_Servers.Lists.Get_Next_Item
        (Sch_Ref,The_System.Scheduling_Servers,Sch_Iterator);

      The_Sched_Res_Ref:=new Results.Sched_Params_Result;
      Results.Set_Sched_Params
        (The_Sched_Res_Ref.all,
        Scheduling_Servers.Server_Sched_Parameters(Sch_Ref.all));
      Scheduling_Servers.Set_Sched_Params_Result
        (Sch_Ref.all,The_Sched_Res_Ref);

      The_Synch_Res_Ref:=new Results.Synch_Params_Result;
      if Scheduling_Servers.Server_Synch_Parameters(Sch_Ref.all)/=null then
         Results.Set_Synch_Params
           (The_Synch_Res_Ref.all,
            Scheduling_Servers.Server_Synch_Parameters(Sch_Ref.all));
      else
         The_Synch_Params_Ref := new Synchronization_Parameters.SRP_Parameters;
         Synchronization_Parameters.Set_Preemption_Level
           (Synchronization_Parameters.SRP_Parameters'Class
            (The_Synch_Params_Ref.all),6);
         Results.Set_Synch_Params
           (The_Synch_Res_Ref.all,The_Synch_Params_Ref);
      end if;
      Scheduling_Servers.Set_Synch_Params_Result
        (Sch_Ref.all,The_Synch_Res_Ref);

   end loop;

   -- Shared Resource Results

   Shared_Resources.Lists.Rewind
     (The_System.Shared_Resources,SR_Iterator);
   for I in 1..Shared_Resources.Lists.Size(The_System.Shared_Resources)
   loop
      Shared_Resources.Lists.Get_Next_Item
        (SR_Ref,The_System.Shared_Resources,SR_Iterator);

      The_Ceiling_Ref:=new Results.Ceiling_Result;
      Results.Set_Ceiling(The_Ceiling_Ref.all,7);
      Shared_Resources.Set_Ceiling_Result(SR_Ref.all,The_Ceiling_Ref);

      The_PL_Ref:=new Results.Preemption_Level_Result;
      Results.Set_Preemption_Level(The_PL_Ref.all,1777);
      Shared_Resources.Set_Preemption_Level_Result(SR_Ref.all,The_PL_Ref);

      The_Utilization_Ref:=new Results.Utilization_Result;
      Results.Set_Total(The_Utilization_Ref.all,50.0);
      Shared_Resources.Set_Utilization_Result
        (SR_Ref.all,The_Utilization_Ref);

      The_Size_Ref:=new Results.Queue_Size_Result;
      Results.Set_Max_Num(The_Size_Ref.all,333);
      Shared_Resources.Set_Queue_Size_Result
        (SR_Ref.all,The_Size_Ref);

   end loop;

   -- Transaction results

   MAST.Transactions.Lists.Rewind(The_System.Transactions,Trans_Iterator);
   for I in 1..MAST.Transactions.Lists.Size(The_System.Transactions) loop
      MAST.Transactions.Lists.Get_Next_Item
        (Trans_Ref,The_System.Transactions,Trans_Iterator);
      MAST.Transactions.Rewind_Internal_Event_Links
        (Trans_Ref.all,Link_Iterator);
      for J in 1..Num_Of_Internal_Event_Links(Trans_Ref.all) loop
         Get_Next_Internal_Event_Link(Trans_Ref.all,Lnk_Ref,Link_Iterator);
         if Input_Event_Handler(Lnk_Ref.all)/=null and then
           Input_Event_Handler(Lnk_Ref.all).all in
           MAST.Graphs.Event_Handlers.Activity'Class
         then
            Res_Ref  := Create_Simulation_Timing_Result(Lnk_Ref);
            -- worst case parameters
            Set_Worst_Local_Response_Time
              (Timing_Result(Res_Ref.all),100.0);
            Set_Worst_Blocking_Time
              (Timing_Result(Res_Ref.all),33.0);
            MAST.Transactions.Rewind_External_Event_Links
              (Trans_Ref.all,Ext_Link_Iterator);
            for I in 1..Num_Of_External_Event_Links(Trans_Ref.all) loop
               Get_Next_External_Event_Link
                 (Trans_Ref.all,Lnk_Ref,Ext_Link_Iterator);
               The_Event:=Event_Of(Lnk_Ref.all);
               Set_Worst_Global_Response_Time
                 (Timing_Result(Res_Ref.all),The_Event,120.0);
               Set_Best_Global_Response_Time
                 (Timing_Result(Res_Ref.all),The_Event,40.0);
               Set_Jitter
                 (Timing_Result(Res_Ref.all),The_Event,5.0);
            end loop;
            -- simulation parameters
            Reset_Local_Miss_Ratio(Simulation_Timing_Result(Res_Ref.all),56.0);
            Reset_Local_Miss_Ratio(Simulation_Timing_Result(Res_Ref.all),160.0);
            for T in 10..100 loop
               Record_Local_Response_Time
                 (Simulation_Timing_Result(Res_Ref.all),Mast.Time(T));
            end loop;
            MAST.Transactions.Rewind_External_Event_Links
              (Trans_Ref.all,Ext_Link_Iterator);
            for I in 1..Num_Of_External_Event_Links(Trans_Ref.all) loop
               Get_Next_External_Event_Link
                 (Trans_Ref.all,Lnk_Ref,Ext_Link_Iterator);
               The_Event:=Event_Of(Lnk_Ref.all);
               Reset_Global_Miss_Ratio
                 (Simulation_Timing_Result(Res_Ref.all),230.0,The_Event);
               Reset_Global_Miss_Ratio
                 (Simulation_Timing_Result(Res_Ref.all),320.0,The_Event);
               for T in 210..300 loop
                  Record_Global_Response_Time
                    (Simulation_Timing_Result(Res_Ref.all),The_Event,Mast.Time(T));
               end loop;
            end loop;
            for T in 310..400 loop
               Record_Global_Response_Time
                 (Simulation_Timing_Result(Res_Ref.all),Mast.Time(T));
            end loop;
            Atr:=Link_Timing_Requirements
              (Regular_Link(Lnk_Ref.all));
            if Atr/=null
            then
               Print(Standard_Output,Atr.all,1);
               begin
                  Check(Link_Timing_Requirements
                        (Regular_Link(Lnk_Ref.all)).all,
                        Timing_Result(Res_Ref.all),
                        Is_Met);
                  if Is_Met then
                     Put_Line("Requirement met");
                  else
                     Put_Line("...Missed");
                  end if;
               exception
                  when Inconclusive =>
                     Put_Line("...Inconclusive");
               end;
               Print(Standard_Output,Res_Ref.all,5);
            end if;
         end if;
      end loop;
   end loop;
end MAST_Put_Results;
