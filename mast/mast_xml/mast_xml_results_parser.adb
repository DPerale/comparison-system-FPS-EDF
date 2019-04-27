-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2003-2008                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors: Michael Gonzalez          mgh@unican.es                  --
--          Jose Javier Gutierrez     gutierjj@unican.es             --
--          Jose Carlos Palencia      palencij@unican.es             --
--          Jose Maria Drake          drakej@unican.es               --
--          Patricia López Martínez   lopezpa@unican.es              --
--          Yago Pereiro Estevan                                     --
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

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Text_IO;
with Dom.Core.Attrs;
with Dom.Core.Documents;
with Dom.Core.Elements;
with Dom.Core.Nodes;
with Dom.Readers;
with Input_Sources;
with Input_Sources.File;
with Sax.Readers;
with Mast; use Mast;
with Mast.Events;
with Mast.Graphs;
with Mast.Graphs.Links;
with Mast.Operations;
with Mast.Processing_Resources;
with Mast.Scheduling_Parameters;
with Mast.Scheduling_Servers;
with Mast.Shared_Resources;
with Mast.Systems;
with Mast.Results;
with Mast.Synchronization_Parameters;
with Mast.Transactions;
with Var_Strings; use Var_Strings;
with Mast_Xml_Parser_Extension;
with Mast_XML_Exceptions;

package body Mast_XML_Results_Parser is

   use type Mast.Operations.Lists.Index;
   use type Mast.Processing_Resources.Lists.Index;
   use type Mast.Scheduling_Servers.Lists.Index;
   use type Mast.Shared_Resources.Lists.Index;
   use type Mast.Transactions.Lists.Index;

   function To_Boolean ( Yes_No : String) return Boolean is
   begin
      return To_Lower(Yes_No) = "yes";
   end To_Boolean;

   -------------------------
   --Add_Shared_Resource --
   -------------------------

   procedure Add_Shared_Resource
     (Mast_System:in out Mast.Systems.System;
      Shared_Res_List: Dom.Core.Node_List)
   is
      -- Add all the Shared_resources in the Shared_Res_List
      -- to the Mast_System Structure.
      I                   : Integer:=0;
      Shared_Res          : Dom.Core.Node;
      Temporal_List       : Dom.Core.Node_List;
      The_Index           : Mast.Shared_Resources.Lists.Index;
      SR_Ref              : Mast.Shared_Resources.Shared_Resource_Ref;
      The_Ceiling_Res     : Mast.Results.Ceiling_Result_Ref;
      The_Queue_Size_Res  : Mast.Results.Queue_Size_Result_Ref;
      The_Utilization_Res : Mast.Results.Utilization_Result_Ref;
      The_Preemption_Res  : Mast.Results.Preemption_Level_Result_Ref;
      A_Name              : Var_String;
   begin
      I:=0;
      while I<Dom.Core.Nodes.Length(Shared_Res_List)
      loop
         --Go through the Shared Resources List
         Shared_Res:=Dom.Core.Nodes.Item(Shared_Res_List,I);
         I:=I+1;
         A_Name:=Var_Strings.To_Var_String
           (To_Lower(Dom.Core.Elements.Get_Attribute(Shared_Res,"Name")));
         The_Index:=Mast.Shared_Resources.Lists.Find
           (A_Name,Mast_System.Shared_Resources);
         if The_Index=Shared_Resources.Lists.Null_Index then
            Mast_XML_Exceptions.Parser_Error
              ("Shared resource not found: "&To_String(A_Name));
         else
            Sr_Ref:=Mast.Shared_Resources.Lists.Item
              (The_Index,Mast_System.Shared_Resources);

            Temporal_List:=Dom.Core.Elements.Get_Elements_By_Tag_Name
              (Shared_Res,"mast_res:Priority_Ceiling");
            if Dom.Core.Nodes.Length(Temporal_List)>0
            then
               The_Ceiling_Res:=new Mast.Results.Ceiling_Result;
               Mast.Shared_Resources.Set_Ceiling_Result
                 (Sr_Ref.all,The_Ceiling_Res);
               begin
                  Mast.Results.Set_Ceiling
                    (The_Ceiling_Res.all,Priority'Value
                     (Dom.Core.Elements.Get_Attribute
                      (Dom.Core.Nodes.Item(Temporal_List,0),"Ceiling")));
               exception
                  when Constraint_Error =>
                     Mast_XML_Exceptions.Parser_Error
                       ("Priority ceiling value out of range"&
                        ", in results of shared resource: "&To_String(A_Name));
               end;
            end if;

            Temporal_List:=Dom.Core.Elements.Get_Elements_By_Tag_Name
              (Shared_Res,"mast_res:Utilization");

            if Dom.Core.Nodes.Length(Temporal_List)>0
            then
               The_Utilization_Res:=new Mast.Results.Utilization_Result;
               Mast.Shared_Resources.Set_Utilization_Result
                 (Sr_Ref.all,The_Utilization_Res);
               Mast.Results.Set_Total
                 (The_Utilization_Res.all,
                  Float'Value(Dom.Core.Elements.Get_Attribute
                              (Dom.Core.Nodes.Item(Temporal_List,0),"Total")));
            end if;

            Temporal_List:=Dom.Core.Elements.Get_Elements_By_Tag_Name
              (Shared_Res,"mast_res:Queue_Size");

            if Dom.Core.Nodes.Length(Temporal_List)>0
            then

               The_Queue_Size_Res:=new Mast.Results.Queue_Size_Result;
               Mast.Shared_Resources.Set_Queue_Size_Result
                 (Sr_Ref.all,The_Queue_Size_Res);

               Mast.Results.Set_Max_Num
                 (The_Queue_Size_Res.all,
                  Natural'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Dom.Core.Nodes.Item(Temporal_List,0),"Max_Num")));
            end if;

            Temporal_List:=Dom.Core.Elements.Get_Elements_By_Tag_Name
              (Shared_Res,"mast_res:Preemption_Level");

            if Dom.Core.Nodes.Length(Temporal_List)>0
            then
               The_Preemption_Res:=new Mast.Results.Preemption_Level_Result;
               Mast.Shared_Resources.Set_Preemption_Level_Result
                 (Sr_Ref.all,The_Preemption_Res);
               begin
                  Mast.Results.Set_Preemption_Level
                    (The_Preemption_Res.all,Preemption_Level'Value
                     (Dom.Core.Elements.Get_Attribute
                      (Dom.Core.Nodes.Item(Temporal_List,0),"Level")));
               exception
                  when Constraint_Error =>
                     Mast_XML_Exceptions.Parser_Error
                       ("Preemption level value out of range"&
                        ", in results of shared resource: "&To_String(A_Name));
               end;
            end if;
         end if;
      end loop;
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in results of shared resource: "&
            To_String(A_Name));
   end Add_Shared_Resource;

   ---------------------
   -- Add_Transaction --
   ---------------------

   procedure Add_Transaction
     (Mast_System:in out Mast.Systems.System;
      Trans_Node_List: in Dom.Core.Node_List)
   is

      type Trans_Res is (Slack,Timing_Result,Simulation_Timing_Result);

      type Timing_Attrs is (Event_Name,Worst_Local_Response_Time,
                            Avg_Local_Response_Time,Best_Local_Response_Time,
                            Worst_Blocking_Time,Num_Of_Suspensions,
                            Avg_Blocking_Time,Max_Preemption_Time,
                            Suspension_Time,Num_Of_Queued_Activations);

      I,J,K,L,M          : Integer:=0;
      Reg_Trans_Node,
      Temp_Node,
      Attribute        : Dom.Core.Node;
      Temporal_List,
      Temporal_List_2,
      Temporal_List_3,
      Trans_List       : Dom.Core.Node_List;
      Attribute_List   : Dom.Core.Named_Node_Map;
      The_Index        : Mast.Transactions.Lists.Index;
      The_Link         : MAST.Graphs.Link_Ref;
      Tr_Ref           : Transactions.Transaction_Ref;
      The_Timing_Res   : Mast.Results.Timing_Result_Ref;
      The_Event_Ref    : MAST.Events.Event_Ref;
      The_Slack_Res    : Mast.Results.Slack_Result_Ref;
      A_Name           : Var_String;

   begin
      while I<Dom.Core.Nodes.Length(Trans_Node_List) loop
         --Analyze each transaction.
         Reg_Trans_Node:=Dom.Core.Nodes.Item(Trans_Node_List,I);
         --Get a transaction.
         I:=I+1;
         A_Name:=Var_Strings.To_Var_String
           (To_Lower(Dom.Core.Elements.Get_Attribute(Reg_Trans_Node,"Name")));
         The_Index:=Mast.Transactions.Lists.Find
           (A_Name,Mast_System.Transactions);
         if The_Index=Transactions.Lists.Null_Index then
            Mast_XML_Exceptions.Parser_Error
              ("Transaction not found: "&To_String(A_Name));
         else
            Tr_Ref:=Mast.Transactions.Lists.Item
              (The_Index,Mast_System.Transactions);
            --Add Slacks.------------------------------------
            Trans_List:=Dom.Core.Nodes.Child_Nodes(Reg_Trans_Node);
            M:=0;
            while M<Dom.Core.Nodes.Length(Trans_List)
            loop
               if Dom.Core.Nodes.Local_Name
                 (Dom.Core.Nodes.Item(Trans_List,M))/=""
               then
                  case Trans_Res'Value
                    (Dom.Core.Nodes.Local_Name
                     (Dom.Core.Nodes.Item(Trans_List,M)))is
                     when Slack =>
                        The_Slack_Res:=new Mast.Results.Slack_Result;
                        Mast.Transactions.Set_Slack_Result
                          (Tr_Ref.all,The_Slack_Res);
                        Mast.Results.Set_Slack
                          (The_Slack_Res.all,
                           Float'Value(Dom.Core.Elements.Get_Attribute
                                       (Dom.Core.Nodes.Item
                                        (Trans_List,M),"Value")));

                     when Timing_Result | Simulation_Timing_Result =>
                        if Trans_Res'Value
                          (Dom.Core.Nodes.Local_Name
                           (Dom.Core.Nodes.Item(Trans_List,M)))=Timing_Result
                        then
                           The_Timing_Res:=new Mast.Results.Timing_Result;
                        else
                           The_Timing_Res:=
                             new Mast.Results.Simulation_Timing_Result;
                        end if;
                        declare
                           Ln_Name : Var_String;
                        begin
                           Ln_Name:=Var_Strings.To_Var_String
                             (To_Lower(Dom.Core.Elements.Get_Attribute
                                       (Dom.Core.Nodes.Item(Trans_List,M),
                                        "Event_Name")));
                           The_Link:=Transactions.Find_Internal_Event_Link
                             (Ln_Name,Tr_Ref.all);
                           MAST.Graphs.Links.Set_Link_Time_Results
                             (Mast.Graphs.Links.Regular_Link(The_Link.all),
                              The_Timing_Res);
                           Mast.Results.Set_Link(The_Timing_Res.all,The_Link);
                        exception
                           when Transactions.Link_Not_Found =>
                              Mast_XML_Exceptions.Parser_Error
                                (To_String
                                 ("Event "&Ln_Name&
                                  " not found in transaction "&A_Name));
                        end;
                        Attribute_List:=Dom.Core.Nodes.Attributes
                          (Dom.Core.Nodes.Item(Trans_List,M));
                        J:=0;

                        while J<Dom.Core.Nodes.Length(Attribute_List)
                        loop
                           Attribute:=Dom.Core.Nodes.Item(Attribute_List,J);
                           J:=J+1;
                           case Timing_Attrs'Value
                             (Dom.Core.Attrs.Name(Attribute))
                           is
                              when Event_Name =>
                                 null;
                              when Worst_Local_Response_Time =>
                                 Mast.Results.Set_Worst_Local_Response_Time
                                   (The_Timing_Res.all,
                                    Time'Value
                                    (Dom.Core.Elements.Get_Attribute
                                     (Dom.Core.Nodes.Item(Trans_List,M),
                                      "Worst_Local_Response_Time")));
                              when Best_Local_Response_Time =>
                                 Mast.Results.Set_Best_Local_Response_Time
                                   (The_Timing_Res.all,
                                    Time'Value
                                    (Dom.Core.Elements.Get_Attribute
                                     (Dom.Core.Nodes.Item(Trans_List,M),
                                      "Best_Local_Response_Time")));
                              when Avg_Local_Response_Time =>
                                 Mast.Results.Set_Local_Simulation_Time
                                   (Mast.Results.Simulation_Timing_Result
                                    (The_Timing_Res.all),
                                    (Time'Value
                                     (Dom.Core.Elements.Get_Attribute
                                      (Dom.Core.Nodes.Item(Trans_List,M),
                                       "Avg_Local_Response_Time")),1));
                              when Avg_Blocking_Time =>
                                 Mast.Results.Set_Avg_Blocking_Time
                                   (Mast.Results.Simulation_Timing_Result
                                    (The_Timing_Res.all),
                                    Time'Value
                                    (Dom.Core.Elements.Get_Attribute
                                     (Dom.Core.Nodes.Item(Trans_List,M),
                                      "Avg_Blocking_Time")));
                              when Worst_Blocking_Time =>
                                 Mast.Results.Set_Worst_Blocking_Time
                                   (The_Timing_Res.all,
                                    Time'Value
                                    (Dom.Core.Elements.Get_Attribute
                                     (Dom.Core.Nodes.Item(Trans_List,M),
                                      "Worst_Blocking_Time")));
                              when Num_Of_Suspensions =>
                                 Mast.Results.Set_Num_Of_Suspensions
                                   (The_Timing_Res.all,
                                    Integer'Value
                                    (Dom.Core.Elements.Get_Attribute
                                     (Dom.Core.Nodes.Item(Trans_List,M),
                                      "Num_Of_Suspensions")));
                              when Max_Preemption_Time =>
                                 Mast.Results.Set_Max_Preemption_Time
                                   (Mast.Results.Simulation_Timing_Result
                                    (The_Timing_Res.all),
                                    Time'Value
                                    (Dom.Core.Elements.Get_Attribute
                                     (Dom.Core.Nodes.Item(Trans_List,M),
                                      "Max_Preemption_Time")));
                              when Suspension_Time =>
                                 Mast.Results.Set_Suspension_Time
                                   (Mast.Results.Simulation_Timing_Result
                                    (The_Timing_Res.all),
                                    Time'Value
                                    (Dom.Core.Elements.Get_Attribute
                                     (Dom.Core.Nodes.Item(Trans_List,M),
                                      "Suspension_Time")));
                              when Num_Of_Queued_Activations =>
                                 Mast.Results.Set_Num_Of_Queued_Activations
                                   (Mast.Results.Simulation_Timing_Result
                                    (The_Timing_Res.all),
                                    Integer'Value
                                    (Dom.Core.Elements.Get_Attribute
                                     (Dom.Core.Nodes.Item(Trans_List,M),
                                      "Num_Of_Queued_Activations")));
                           end case;
                        end loop;

                        Temporal_List:=
                          Dom.Core.Elements.Get_Elements_By_Tag_Name
                          (Dom.Core.Nodes.Item(Trans_List,M),
                           "mast_res:Worst_Global_Response_Times");
                        if Dom.Core.Nodes.Length(Temporal_List)>0
                        then
                           Temporal_List_2:=
                             Dom.Core.Elements.Get_Elements_By_Tag_Name
                             (Dom.Core.Nodes.Item(Temporal_List,0),
                              "mast_res:Global_Response_Time");
                           K:=0;
                           while K<Dom.Core.Nodes.Length(Temporal_List_2)
                           loop
                              Temp_Node:=DOm.Core.Nodes.Item
                                (Temporal_List_2,K);
                              K:=K+1;
                              declare
                                 Ref_Name : Var_String;
                              begin
                                 Ref_Name:=Var_Strings.To_Var_String
                                   (To_Lower
                                    (Dom.Core.Elements.Get_Attribute
                                     (Temp_Node,"Referenced_Event")));
                                 The_Event_Ref:=Transactions.Find_Any_Event
                                   (Ref_Name,Tr_Ref.all);
                                 Mast.Results.Set_Worst_Global_Response_Time
                                   (The_Timing_Res.all,
                                    The_Event_Ref,
                                    MAST.Time'Value
                                    (Dom.Core.Elements.Get_Attribute
                                     (Temp_Node,"Time_Value")));
                              exception
                                 when Transactions.Event_Not_Found =>
                                    Mast_XML_Exceptions.Parser_Error
                                      ("Event name "&To_String(ref_name)&
                                       " not found, in transaction: "&
                                       To_String(A_Name));
                              end;
                           end loop;
                        end if;

                        Temporal_List:=
                          Dom.Core.Elements.Get_Elements_By_Tag_Name
                          (Dom.Core.Nodes.Item(Trans_List,M),
                           "mast_res:Avg_Global_Response_Times");
                        if Dom.Core.Nodes.Length(Temporal_List)>0
                        then
                           Temporal_List_2:=
                             Dom.Core.Elements.Get_Elements_By_Tag_Name
                             (Dom.Core.Nodes.Item(Temporal_List,0),
                              "mast_res:Global_Response_Time");
                           K:=0;
                           while K<Dom.Core.Nodes.Length(Temporal_List_2)
                           loop
                              Temp_Node:=DOm.Core.Nodes.Item
                                (Temporal_List_2,K);
                              K:=K+1;
                              declare
                                 Ref_Name : Var_String;
                              begin
                                 Ref_Name:=Var_Strings.To_Var_String
                                   (To_Lower
                                    (Dom.Core.Elements.Get_Attribute
                                     (Temp_Node,"Referenced_Event")));
                                 The_Event_Ref:=Transactions.Find_Any_Event
                                   (Ref_Name,Tr_Ref.all);
                                 Mast.Results.Set_Global_Simulation_Time
                                   (Mast.Results.Simulation_Timing_Result
                                    (The_Timing_Res.all),
                                    The_Event_Ref,
                                    (MAST.Time'Value
                                     (Dom.Core.Elements.Get_Attribute
                                      (Temp_Node,"Time_Value")),1));
                              exception
                                 when Transactions.Event_Not_Found =>
                                    Mast_XML_Exceptions.Parser_Error
                                      ("Event name "&To_String(ref_name)&
                                       " not found, in transaction: "&
                                       To_String(A_Name));
                              end;
                           end loop;
                        end if;

                        Temporal_List:=
                          Dom.Core.Elements.Get_Elements_By_Tag_Name
                          (Dom.Core.Nodes.Item(Trans_List,M),
                           "mast_res:Best_Global_Response_Times");
                        if Dom.Core.Nodes.Length(Temporal_List)>0
                        then
                           Temporal_List_2:=
                             Dom.Core.Elements.Get_Elements_By_Tag_Name
                             (Dom.Core.Nodes.Item(Temporal_List,0),
                              "mast_res:Global_Response_Time");
                           K:=0;
                           while K<Dom.Core.Nodes.Length(Temporal_List_2)
                           loop
                              Temp_Node:=DOm.Core.Nodes.Item
                                (Temporal_List_2,K);
                              K:=K+1;
                              declare
                                 Ref_Name : Var_String;
                              begin
                                 Ref_Name:=Var_Strings.To_Var_String
                                   (To_Lower
                                    (Dom.Core.Elements.Get_Attribute
                                     (Temp_Node,"Referenced_Event")));
                                 The_Event_Ref:=Transactions.Find_Any_Event
                                   (Ref_Name,Tr_Ref.all);
                                 Mast.Results.Set_Best_Global_Response_Time
                                   (The_Timing_Res.all,
                                    The_Event_Ref,
                                    MAST.Time'Value
                                    (Dom.Core.Elements.Get_Attribute
                                     (Temp_Node,"Time_Value")));
                              exception
                                 when Transactions.Event_Not_Found =>
                                    Mast_XML_Exceptions.Parser_Error
                                      ("Event name "&To_String(ref_name)&
                                       " not found, in transaction: "&
                                       To_String(A_Name));
                              end;
                           end loop;
                        end if;

                        Temporal_List:=
                          Dom.Core.Elements.Get_Elements_By_Tag_Name
                          (Dom.Core.Nodes.Item(Trans_List,M),
                           "mast_res:Jitters");
                        if Dom.Core.Nodes.Length(Temporal_List)>0
                        then
                           Temporal_List_2:=
                             Dom.Core.Elements.Get_Elements_By_Tag_Name
                             (Dom.Core.Nodes.Item(Temporal_List,0),
                              "mast_res:Global_Response_Time");
                           K:=0;
                           while K<Dom.Core.Nodes.Length(Temporal_List_2)
                           loop
                              Temp_Node:=Dom.Core.Nodes.Item
                                (Temporal_List_2,K);
                              K:=K+1;
                              declare
                                 Ref_Name : Var_String;
                              begin
                                 Ref_Name:=Var_Strings.To_Var_String
                                   (To_Lower
                                    (Dom.Core.Elements.Get_Attribute
                                     (Temp_Node,"Referenced_Event")));
                                 The_Event_Ref:=Transactions.Find_Any_Event
                                   (Ref_Name,Tr_Ref.all);
                                 Mast.Results.Set_Jitter
                                   (The_Timing_Res.all, The_Event_Ref,
                                    MAST.Time'Value
                                    (Dom.Core.Elements.Get_Attribute
                                     (Temp_Node,"Time_Value")));
                              exception
                                 when Transactions.Event_Not_Found =>
                                    Mast_XML_Exceptions.Parser_Error
                                      ("Event name "&To_String(ref_name)&
                                       " not found, in transaction: "&
                                       To_String(A_Name));
                              end;
                           end loop;
                        end if;
                        Temporal_List:=
                          Dom.Core.Elements.Get_Elements_By_Tag_Name
                          (Dom.Core.Nodes.Item(Trans_List,M),
                           "mast_res:Local_Miss_Ratios");
                        if Dom.Core.Nodes.Length(Temporal_List)>0
                        then
                           Temporal_List_2:=
                             Dom.Core.Elements.Get_Elements_By_Tag_Name
                             (Dom.Core.Nodes.Item(Temporal_List,0),
                              "mast_res:Miss_Ratio");
                           K:=0;
                           while K<Dom.Core.Nodes.Length(Temporal_List_2)
                           loop
                              Temp_Node:=Dom.Core.Nodes.Item
                                (Temporal_List_2,K);
                              K:=K+1;
                              Mast.Results.Set_Local_Miss_Ratio
                                (Mast.Results.Simulation_Timing_Result
                                 (The_Timing_Res.all),
                                 Mast.Time'Value
                                 (Dom.Core.Elements.Get_Attribute
                                  (Temp_Node,"Deadline")),
                                 (Integer(Float'Value
                                          (Dom.Core.Elements.Get_Attribute
                                           (Temp_Node,"Ratio"))*1.0E6),1E8));
                           end loop;
                        end if;

                        Temporal_List:=
                          Dom.Core.Elements.Get_Elements_By_Tag_Name
                          (Dom.Core.Nodes.Item(Trans_List,M),
                           "mast_res:Global_Miss_Ratios");
                        if Dom.Core.Nodes.Length(Temporal_List)>0
                        then
                           Temporal_List_2:=
                             Dom.Core.Elements.Get_Elements_By_Tag_Name
                             (Dom.Core.Nodes.Item(Temporal_List,0),
                              "mast_res:Global_Miss_Ratio");
                           K:=0;
                           while K<Dom.Core.Nodes.Length(Temporal_List_2)
                           loop
                              Temp_Node:=Dom.Core.Nodes.Item
                                (Temporal_List_2,K);
                              declare
                                 Ref_Name : Var_String;
                              begin
                                 Ref_Name:=Var_Strings.To_Var_String
                                   (To_Lower
                                    (Dom.Core.Elements.Get_Attribute
                                     (Temp_Node,"Referenced_Event")));
                                 The_Event_Ref:=Transactions.Find_Any_Event
                                   (Ref_Name,Tr_Ref.all);
                                 Temporal_List_3:=
                                   Dom.Core.Elements.Get_Elements_By_Tag_Name
                                   (Dom.Core.Nodes.Item(Temporal_List_2,K),
                                    "mast_res:Miss_Ratio");
                                 L:=0;
                                 while L<Dom.Core.Nodes.Length(Temporal_List_3)
                                 loop
                                    Temp_Node:=Dom.Core.Nodes.Item
                                      (Temporal_List_3,L);
                                    L:=L+1;
                                    Mast.Results.Set_Global_Miss_Ratio
                                      (Mast.Results.Simulation_Timing_Result
                                       (The_Timing_Res.all),
                                       Mast.Time'Value
                                       (Dom.Core.Elements.Get_Attribute
                                        (Temp_Node,"Deadline")),
                                       The_Event_Ref,
                                       (Integer
                                        (Float'Value
                                         (Dom.Core.Elements.Get_Attribute
                                          (Temp_Node,"Ratio"))*1.0E6),1E8));
                                 end loop;
                              exception
                                 when Transactions.Event_Not_Found =>
                                    Mast_XML_Exceptions.Parser_Error
                                      ("Event name "&To_String(ref_name)&
                                       " not found, in transaction: "&
                                       To_String(A_Name));
                              end;
                              K:=K+1;
                           end loop;
                        end if;
                  end case;
               end if;
               M:=M+1;
            end loop;
         end if;
      end loop;
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in results of transaction: "&To_String(A_Name));
   end Add_Transaction;

   ---------------------
   -- Add_Operations ---
   ---------------------

   procedure Add_Operation
     (Mast_System:in out Mast.Systems.System;
      Operation_List: Dom.Core.Node_List)
   is
      I             : Integer:=0;
      Operation     : Dom.Core.Node;
      Temporal_List : Dom.Core.Node_List;
      The_Index     : Mast.Operations.Lists.Index;
      Op_Ref        : MAst.Operations.Operation_Ref;
      The_Slack_Res : Mast.Results.Slack_Result_Ref;
      A_Name        : Var_String;
   begin
      while I<Dom.Core.Nodes.Length(Operation_List) loop
         --Analyze each operation.
         Operation:=Dom.Core.Nodes.Item(Operation_List,I);
         --Get an operation.
         I:=I+1;
         A_Name:=Var_Strings.To_Var_String
           (To_Lower(Dom.Core.Elements.Get_Attribute(Operation,"Name")));
         The_Index:=MAst.Operations.Lists.Find
           (A_Name,Mast_System.Operations);
         if The_Index=Operations.Lists.Null_Index then
            Mast_XML_Exceptions.Parser_Error
              ("Operation not found: "&To_String(A_Name));
         else
            Op_Ref:=MAst.Operations.Lists.Item
              (The_Index,Mast_System.Operations);
            --Add Slack if it exists.
            Temporal_List:=Dom.Core.Elements.Get_Elements_By_Tag_Name
              (Operation,"mast_res:Slack");
            if Dom.Core.Nodes.Length(Temporal_List)>0
            then
               The_Slack_Res:=new Mast.Results.Slack_Result;
               Mast.Operations.Set_Slack_Result(Op_Ref.all,The_Slack_Res);
               Mast.Results.Set_Slack
                 (The_Slack_Res.all,
                  Float'Value(Dom.Core.Elements.Get_Attribute
                              (Dom.Core.Nodes.Item(Temporal_List,0),"Value")));
            end if;
         end if;
      end loop;
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in results of operation: "&To_String(A_Name));
   end Add_Operation;


   ------------------------------
   -- Add_Scheduling_Server --
   ------------------------------

   procedure Add_Scheduling_Server
     (Mast_System:in out Mast.Systems.System;
      Sched_Serv_Node_List: in Dom.Core.Node_List)
   is
      type Sched_Par is (The_Priority,Preassigned,Polling_Period,
                         Polling_Worst_Overhead,Polling_Avg_Overhead,
                         Polling_Best_Overhead,Normal_Priority,
                         Background_Priority,Initial_Capacity,
                         Replenishment_Period,Max_Pending_Replenishments,
                         Deadline);

      type Synch_Par is (Preemption_Level,Preassigned);

      I,J              : Integer:=0;
      Sched_Serv_Node  : Dom.Core.Node;
      The_Index        : Mast.Scheduling_Servers.Lists.Index;
      SS_Ref           : Scheduling_Servers.Scheduling_Server_Ref;
      Sp_Ref           : Mast.Synchronization_Parameters.Synch_Parameters_Ref;
      The_Synch_Res    : Mast.Results.Synch_Params_Result_Ref;
      The_SP_Res       : Mast.Results.Sched_Params_Result_Ref;
      Sched_Params_Ref : Mast.Scheduling_Parameters.Sched_Parameters_Ref;
      Attribute_List   : Dom.Core.Named_Node_Map;
      Temporal_List    : Dom.Core.Node_List;
      Attribute        : Dom.Core.Node;
      A_Name           : Var_String;

   begin
      --Analyze one by one all the Scheduling Servers of the list
      while I<Dom.Core.Nodes.Length(Sched_Serv_Node_List) loop
         --Initialize the Scheduling Server Structure.
         Sched_Serv_Node:=Dom.Core.Nodes.Item(Sched_Serv_Node_List,I);
         A_Name:=Var_Strings.To_Var_String
           (To_Lower(Dom.Core.Elements.Get_Attribute(Sched_Serv_Node,"Name")));
         The_Index:=Mast.Scheduling_Servers.Lists.Find
           (A_Name,Mast_System.Scheduling_Servers);
         if The_Index=Scheduling_Servers.Lists.Null_Index then
            Mast_XML_Exceptions.Parser_Error
              ("Scheduling_Server not found: "&To_String(A_Name));
         else
            SS_Ref:=Mast.Scheduling_Servers.Lists.Item
              (The_Index,Mast_System.Scheduling_Servers);
            The_SP_Res:=new Mast.Results.Sched_Params_Result;
            Mast.Scheduling_Servers.Set_Sched_Params_Result
              (SS_Ref.all,The_SP_Res);
            Temporal_List:=Dom.Core.Elements.Get_Elements_By_Tag_Name
              (Sched_Serv_Node,"mast_res:Non_Preemptible_FP_Policy");
            if Dom.Core.Nodes.Length(Temporal_List)>0
            then
               Sched_Params_Ref:=
                 new Mast.Scheduling_Parameters.Non_Preemptible_Fp_Policy;
               Attribute_List:=Dom.Core.Nodes.Attributes
                 (Dom.Core.Nodes.Item(Temporal_List,0));
               J:=0;
               while J<Dom.Core.Nodes.Length(Attribute_List)
               loop
                  Attribute:=Dom.Core.Nodes.Item(Attribute_List,J);
                  J:=J+1;
                  case Sched_Par'Value(Dom.Core.Attrs.Name(Attribute))is
                     when The_Priority =>
                        Mast.Scheduling_Parameters.Set_The_Priority
                          (Mast.Scheduling_Parameters.
                           Fixed_Priority_Parameters'Class
                           (Sched_Params_Ref.all),
                           MAST.Priority'Value
                           (Dom.Core.Elements.Get_Attribute
                            (Dom.Core.Nodes.Item(Temporal_List,0),
                             "The_Priority")));
                     when Preassigned =>
                        Mast.Scheduling_Parameters.Set_Preassigned
                          (Mast.Scheduling_Parameters.
                           Fixed_Priority_Parameters'Class
                           (Sched_Params_Ref.all),
                           To_Boolean(Dom.Core.Elements.Get_Attribute
                                      (Dom.Core.Nodes.Item(Temporal_List,0),
                                       "Preassigned")));
                     when others=>
                        Mast_XML_Exceptions.Parser_Error
                          ("Argument error in results of scheduling server: "&
                           To_String(A_Name));
                  end case;
               end loop;
               Mast.Results.Set_Sched_Params(The_SP_Res.all,Sched_Params_Ref);
            end if;

            Temporal_List:=Dom.Core.Elements.Get_Elements_By_Tag_Name
              ( Sched_Serv_Node,"mast_res:Fixed_Priority_Policy");

            if Dom.Core.Nodes.Length(Temporal_List)>0
            then
               Sched_Params_Ref:=
                 new Mast.Scheduling_Parameters.Fixed_Priority_Policy;
               Mast.Results.Set_Sched_Params(The_SP_Res.all,Sched_Params_Ref);
               Attribute_List:=Dom.Core.Nodes.Attributes
                 (Dom.Core.Nodes.Item(Temporal_List,0));
               J:=0;
               while J<Dom.Core.Nodes.Length(Attribute_List)
               loop
                  Attribute:=Dom.Core.Nodes.Item(Attribute_List,J);
                  J:=J+1;
                  case Sched_Par'Value(Dom.Core.Attrs.Name(Attribute))is
                     when The_Priority =>
                        begin
                           Mast.Scheduling_Parameters.Set_The_Priority
                             (Mast.Scheduling_Parameters.
                              Fixed_Priority_Parameters'Class
                              (Sched_Params_Ref.all),
                              MAST.Priority'Value
                              (Dom.Core.Elements.Get_Attribute
                               (Dom.Core.Nodes.Item(Temporal_List,0),
                                "The_Priority")));
                        exception
                           when Constraint_Error =>
                              Mast_XML_Exceptions.Parser_Error
                                ("Priority value out of range"&
                                 " in results of scheduling server: "&
                                 To_String(A_Name));
                        end;
                     when Preassigned =>
                        Mast.Scheduling_Parameters.Set_Preassigned
                          (Mast.Scheduling_Parameters.
                           Fixed_Priority_Parameters'Class
                           (Sched_Params_Ref.all),
                           To_Boolean(Dom.Core.Elements.Get_Attribute
                                      (Dom.Core.Nodes.Item(Temporal_List,0),
                                       "Preassigned")));
                     when others=>
                        Mast_XML_Exceptions.Parser_Error
                          ("Argument error in results of scheduling server: "&
                           To_String(A_Name));
                  end case;
               end loop;
               Mast.Results.Set_Sched_Params(The_SP_Res.all,Sched_Params_Ref);
            end if;

            Temporal_List:=Dom.Core.Elements.Get_Elements_By_Tag_Name
              ( Sched_Serv_Node,"mast_res:Interrupt_FP_Policy");

            if Dom.Core.Nodes.Length(Temporal_List)>0
            then
               Sched_Params_Ref:=
                 new Mast.Scheduling_Parameters.Interrupt_FP_Policy;
               Attribute_List:=Dom.Core.Nodes.Attributes
                 (Dom.Core.Nodes.Item(Temporal_List,0));
               J:=0;
               while J<Dom.Core.Nodes.Length(Attribute_List)
               loop
                  Attribute:=Dom.Core.Nodes.Item(Attribute_List,J);
                  J:=J+1;
                  case Sched_Par'Value(Dom.Core.Attrs.Name(Attribute))is
                     when The_Priority =>
                        begin
                           Mast.Scheduling_Parameters.Set_The_Priority
                             (Mast.Scheduling_Parameters.
                              Fixed_Priority_Parameters'Class
                              (Sched_Params_Ref.all),
                              MAST.Priority'Value
                              (Dom.Core.Elements.Get_Attribute
                               (Dom.Core.Nodes.Item(Temporal_List,0),
                                "The_Priority")));
                        exception
                           when Constraint_Error =>
                              Mast_XML_Exceptions.Parser_Error
                                ("Priority value out of range"&
                                 " in results of scheduling server: "&
                                 To_String(A_Name));
                        end;
                     when Preassigned =>
                        declare
                           Is_Preassigned: Boolean;
                        begin
                           Is_Preassigned:=To_Boolean
                             (Dom.Core.Elements.Get_Attribute
                              (Dom.Core.Nodes.Item(Temporal_List,0),
                               "Preassigned"));
                           Mast.Scheduling_Parameters.Set_Preassigned
                             (Mast.Scheduling_Parameters.
                              Fixed_Priority_Parameters'Class
                              (Sched_Params_Ref.all),Is_Preassigned);
                           if not Is_Preassigned then
                              Mast_XML_Exceptions.Parser_Error
                                ("Preassigned field in Interrupt Scheduler"&
                                 " cannot be 'NO'");
                           end if;
                        end;
                     when others=>
                        Mast_XML_Exceptions.Parser_Error
                          ("Argument error in results of scheduling server: "&
                           To_String(A_Name));
                  end case;
               end loop;
               Mast.Results.Set_Sched_Params(The_SP_Res.all,Sched_Params_Ref);
            end if;

            Temporal_List:=Dom.Core.Elements.Get_Elements_By_Tag_Name
              ( Sched_Serv_Node,"mast_res:Polling_Policy");
            if Dom.Core.Nodes.Length(Temporal_List)>0
            then
               Sched_Params_Ref:=
                 new Mast.Scheduling_Parameters.Polling_Policy;
               Attribute_List:=Dom.Core.Nodes.Attributes
                 (Dom.Core.Nodes.Item(Temporal_List,0));
               J:=0;
               while J<Dom.Core.Nodes.Length(Attribute_List)
               loop
                  Attribute:=Dom.Core.Nodes.Item(Attribute_List,J);
                  J:=J+1;
                  case Sched_Par'Value(Dom.Core.Attrs.Name(Attribute))is
                     when The_Priority =>
                        begin
                           Mast.Scheduling_Parameters.Set_The_Priority
                             (Mast.Scheduling_Parameters.
                              Fixed_Priority_Parameters'Class
                              (Sched_Params_Ref.all),
                              MAST.Priority'Value
                              (Dom.Core.Elements.Get_Attribute
                               (Dom.Core.Nodes.Item(Temporal_List,0),
                                "The_Priority")));
                        exception
                           when Constraint_Error =>
                              Mast_XML_Exceptions.Parser_Error
                                ("Priority value out of range"&
                                 " in results of scheduling server: "&
                                 To_String(A_Name));
                        end;
                     when Preassigned =>
                        Mast.Scheduling_Parameters.Set_Preassigned
                          (Mast.Scheduling_Parameters.
                           Fixed_Priority_Parameters'Class
                           (Sched_Params_Ref.all),
                           To_Boolean(Dom.Core.Elements.Get_Attribute
                                      (Dom.Core.Nodes.Item(Temporal_List,0),
                                       "Preassigned")));
                     when Polling_Period =>
                        Mast.Scheduling_Parameters.Set_Polling_Period
                          (Mast.Scheduling_Parameters.Polling_Policy'Class
                           (Sched_Params_Ref.all),
                           MAST.Time'Value
                           (Dom.Core.Elements.Get_Attribute
                            (Dom.Core.Nodes.Item(Temporal_List,0),
                             "Polling_Period")));
                     when Polling_Worst_Overhead =>
                        Mast.Scheduling_Parameters.Set_Polling_Worst_Overhead
                          (Mast.Scheduling_Parameters.Polling_Policy'Class
                           (Sched_Params_Ref.all),
                           MAST.Normalized_Execution_Time'Value
                           (Dom.Core.Elements.Get_Attribute
                            (Dom.Core.Nodes.Item(Temporal_List,0),
                             "Polling_Worst_Overhead")));
                     when Polling_Avg_Overhead =>
                        Mast.Scheduling_Parameters.Set_Polling_Avg_Overhead
                          (Mast.Scheduling_Parameters.Polling_Policy'Class
                           (Sched_Params_Ref.all),
                           MAST.Normalized_Execution_Time'Value
                           (Dom.Core.Elements.Get_Attribute
                            (Dom.Core.Nodes.Item(Temporal_List,0),
                             "Polling_Avg_Overhead")));
                     when Polling_Best_Overhead =>
                        Mast.Scheduling_Parameters.Set_Polling_Best_Overhead
                          (Mast.Scheduling_Parameters.Polling_Policy'Class
                           (Sched_Params_Ref.all),
                           MAST.Normalized_Execution_Time'Value
                           (Dom.Core.Elements.Get_Attribute
                            (Dom.Core.Nodes.Item(Temporal_List,0),
                             "Polling_Best_Overhead")));
                     when others=>
                        Mast_XML_Exceptions.Parser_Error
                          ("Argument error in results of scheduling server: "&
                           To_String(A_Name));
                  end case;
               end loop;
               Mast.Results.Set_Sched_Params(The_SP_Res.all,Sched_Params_Ref);
            end if;

            Temporal_List:=Dom.Core.Elements.Get_Elements_By_Tag_Name
              ( Sched_Serv_Node,"mast_res:Sporadic_Server_Policy");
            if Dom.Core.Nodes.Length(Temporal_List)>0
            then
               Sched_Params_Ref:=
                 new Mast.Scheduling_Parameters.Sporadic_Server_Policy;
               Attribute_List:=Dom.Core.Nodes.Attributes
                 (Dom.Core.Nodes.Item(Temporal_List,0));
               J:=0;
               while J<Dom.Core.Nodes.Length(Attribute_List)
               loop
                  Attribute:=Dom.Core.Nodes.Item(Attribute_List,J);
                  J:=J+1;
                  case Sched_Par'Value(Dom.Core.Attrs.Name(Attribute))is
                     when Normal_Priority =>
                        begin
                           Mast.Scheduling_Parameters.Set_The_Priority
                             (Mast.Scheduling_Parameters.
                              Fixed_Priority_Parameters'Class
                              (Sched_Params_Ref.all),
                              MAST.Priority'Value
                              (Dom.Core.Elements.Get_Attribute
                               (Dom.Core.Nodes.Item(Temporal_List,0),
                                "Normal_Priority")));
                        exception
                           when Constraint_Error =>
                              Mast_XML_Exceptions.Parser_Error
                                ("Normal priority value out of range"&
                                 " in results of scheduling server: "&
                                 To_String(A_Name));
                        end;
                     when Preassigned =>
                        Mast.Scheduling_Parameters.Set_Preassigned
                          (Mast.Scheduling_Parameters.
                           Fixed_Priority_Parameters'Class
                           (Sched_Params_Ref.all),
                           To_Boolean(Dom.Core.Elements.Get_Attribute
                                      (Dom.Core.Nodes.Item(Temporal_List,0),
                                       "Preassigned")));
                     when Background_Priority =>
                        begin
                           Mast.Scheduling_Parameters.Set_Background_Priority
                             (Mast.Scheduling_Parameters.
                              Sporadic_Server_Policy'Class
                              (Sched_Params_Ref.all),
                              MAST.Priority'Value
                              (Dom.Core.Elements.Get_Attribute
                               (Dom.Core.Nodes.Item(Temporal_List,0),
                                "Background_Priority")));
                        exception
                           when Constraint_Error =>
                              Mast_XML_Exceptions.Parser_Error
                                ("Background priority value out of range"&
                                 " in results of scheduling server: "&
                                 To_String(A_Name));
                        end;
                     when Initial_Capacity =>
                        Mast.Scheduling_Parameters.Set_Initial_Capacity
                          (Mast.Scheduling_Parameters.
                           Sporadic_Server_Policy'Class
                           (Sched_Params_Ref.all),
                           MAST.Time'Value
                           (Dom.Core.Elements.Get_Attribute
                            (Dom.Core.Nodes.Item(Temporal_List,0),
                             "Initial_Capacity")));
                     when Replenishment_Period =>
                        Mast.Scheduling_Parameters.Set_Replenishment_Period
                          (Mast.Scheduling_Parameters.
                           Sporadic_Server_Policy'Class
                           (Sched_Params_Ref.all),
                           MAST.Time'Value
                           (Dom.Core.Elements.Get_Attribute
                            (Dom.Core.Nodes.Item(Temporal_List,0),
                             "Replenishment_Period")));
                     when Max_Pending_Replenishments =>
                        Mast.Scheduling_Parameters.
                          Set_Max_Pending_Replenishments
                          (Mast.Scheduling_Parameters.
                           Sporadic_Server_Policy'Class
                           (Sched_Params_Ref.all),
                           Integer'Value
                           (Dom.Core.Elements.Get_Attribute
                            (Dom.Core.Nodes.Item(Temporal_List,0),
                             "Max_Pending_Replenishments")));
                     when others=>
                        Mast_XML_Exceptions.Parser_Error
                          ("Argument error in results of scheduling server: "&
                           To_String(A_Name));
                  end case;
               end loop;
               Mast.Results.Set_Sched_Params(The_SP_Res.all,Sched_Params_Ref);
            end if;

            Temporal_List:=Dom.Core.Elements.Get_Elements_By_Tag_Name
              ( Sched_Serv_Node,"mast_res:EDF_Policy");

            if Dom.Core.Nodes.Length(Temporal_List)>0
            then
               Sched_Params_Ref:=
                 new Mast.Scheduling_Parameters.EDF_Policy;
               Mast.Results.Set_Sched_Params(The_SP_Res.all,Sched_Params_Ref);
               Attribute_List:=Dom.Core.Nodes.Attributes
                 (Dom.Core.Nodes.Item(Temporal_List,0));
               J:=0;
               while J<Dom.Core.Nodes.Length(Attribute_List)
               loop
                  Attribute:=Dom.Core.Nodes.Item(Attribute_List,J);
                  J:=J+1;
                  case Sched_Par'Value(Dom.Core.Attrs.Name(Attribute))is
                     when Deadline =>
                        Mast.Scheduling_Parameters.Set_Deadline
                          (Mast.Scheduling_Parameters.
                           EDF_Parameters'Class
                           (Sched_Params_Ref.all),
                           MAST.Time'Value
                           (Dom.Core.Elements.Get_Attribute
                            (Dom.Core.Nodes.Item(Temporal_List,0),
                             "Deadline")));
                     when Preassigned =>
                        Mast.Scheduling_Parameters.Set_Preassigned
                          (Mast.Scheduling_Parameters.
                           EDF_Parameters'Class
                           (Sched_Params_Ref.all),
                           To_Boolean(Dom.Core.Elements.Get_Attribute
                                      (Dom.Core.Nodes.Item(Temporal_List,0),
                                       "Preassigned")));
                     when others=>
                        Mast_XML_Exceptions.Parser_Error
                          ("Argument error in results of scheduling server: "&
                           To_String(A_Name));
                  end case;
               end loop;
               Mast.Results.Set_Sched_Params(The_SP_Res.all,Sched_Params_Ref);
            end if;

            Temporal_List:=Dom.Core.Elements.Get_Elements_By_Tag_Name
              (Sched_Serv_Node,"mast_res:SRP_Parameters");
            The_Synch_Res:=new Mast.Results.Synch_Params_Result;
            Mast.Scheduling_Servers.Set_Synch_Params_Result
              (SS_Ref.all,The_Synch_Res);
            if Dom.Core.Nodes.Length(Temporal_List)>0
            then
               Sp_Ref:=
                 new Mast.Synchronization_Parameters.SRP_Parameters;
               Attribute_List:=Dom.Core.Nodes.Attributes
                 (Dom.Core.Nodes.Item(Temporal_List,0));
               J:=0;
               while J<Dom.Core.Nodes.Length(Attribute_List)
               loop
                  Attribute:=Dom.Core.Nodes.Item(Attribute_List,J);
                  J:=J+1;
                  case Synch_Par'Value(Dom.Core.Attrs.Name(Attribute))is
                     when Preemption_Level =>
                        begin
                           Mast.Synchronization_Parameters.Set_Preemption_Level
                             (Mast.Synchronization_Parameters.SRP_Parameters
                              (Sp_Ref.all),
                              MAST.Preemption_Level'Value
                              (Dom.Core.Elements.Get_Attribute
                               (Dom.Core.Nodes.Item(Temporal_List,0),
                                "Preemption_Level")));
                        exception
                           when Constraint_Error =>
                              Mast_XML_Exceptions.Parser_Error
                                ("Preemption level out of range"&
                                 " in results of scheduling server: "&
                                 To_String(A_Name));
                        end;
                     when Preassigned =>
                        Mast.Synchronization_Parameters.Set_Preassigned
                          (Mast.Synchronization_Parameters.SRP_Parameters
                           (Sp_Ref.all),
                           To_Boolean(Dom.Core.Elements.Get_Attribute
                                      (Dom.Core.Nodes.Item(Temporal_List,0),
                                       "Preassigned")));
                  end case;
               end loop;
               Mast.Results.Set_Synch_Params(The_Synch_Res.all,Sp_Ref);
            end if;
         end if;
         I:=I+1;
      end loop;
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in results of scheduling server: "&
            To_String(A_Name));
   end Add_Scheduling_Server;

   -----------------------------
   -- Add_Processing_Resource --
   -----------------------------

   procedure Add_Processing_Resource
     (Mast_System:in out Mast.Systems.System;
      Processors_List: in Dom.Core.Node_List)
   is
      type Det_Util_Attributes
      is (Total,Application,Context_Switch,Timer,Driver);
      --List of Attributes of the Fixed_Priority_Processor.

      Pr_Ref              : Processing_Resources.Processing_Resource_Ref;
      The_Slack_Res       : Mast.Results.Slack_Result_Ref;
      The_Utilization_Res : Mast.Results.Utilization_Result_Ref;
      The_Queue_Size_Res  : MAST.Results.Queue_Size_Result_Ref;
      I,J                 : Integer:=0     ;
      Nodo                : Dom.Core.Element;
      Attribute_List      : Dom.Core.Named_Node_Map;
      Attribute           : Dom.Core.Attr;
      Temporal_List       : Dom.Core.Node_List;
      The_Index           : Processing_Resources.Lists.Index;
      A_Name              : Var_String;

   begin

      --Analysis of all the processors
      -- (Each element in the Processors_List is a Processor)
      while  I<Dom.Core.Nodes.Length(Processors_List)
      loop
         Nodo:=Dom.Core.Nodes.Item(Processors_List,I);
         I:=I+1;
         A_Name:=Var_Strings.To_Var_String
           (To_Lower(Dom.Core.Elements.Get_Attribute(Nodo,"Name")));
         The_Index:=Processing_Resources.Lists.Find
           (A_Name,Mast_System.Processing_Resources);
         if The_Index=Processing_Resources.Lists.Null_Index then
            Mast_XML_Exceptions.Parser_Error
              ("Processing resource not found: "&To_String(A_Name));
         else
            Pr_Ref:=Processing_Resources.Lists.Item
              (The_Index,Mast_System.Processing_Resources);
            Temporal_List:=Dom.Core.Elements.Get_Elements_By_Tag_Name
              (Nodo,"mast_res:Slack");
            if Dom.Core.Nodes.Length(Temporal_List)>0
            then
               The_Slack_Res:=new Mast.Results.Slack_Result;
               Processing_Resources.Set_Slack_Result(Pr_Ref.all,The_Slack_Res);
               Mast.Results.Set_Slack
                 (The_Slack_Res.all,
                  Float'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Dom.Core.Nodes.Item(Temporal_List,0),"Value")));
            end if;

            Temporal_List:=Dom.Core.Elements.Get_Elements_By_Tag_Name
              (Nodo,"mast_res:Detailed_Utilization");

            if Dom.Core.Nodes.Length(Temporal_List)>0
            then
               The_Utilization_Res:=new
                 Mast.Results.Detailed_Utilization_Result;
               Processing_Resources.Set_Utilization_Result
                 (Pr_Ref.all,The_Utilization_Res);
               Attribute_List:=Dom.Core.Nodes.Attributes
                 (Dom.Core.Nodes.Item(Temporal_List,0));
               J:=0;
               while J<Dom.Core.Nodes.Length(Attribute_List)
               loop
                  Attribute:=Dom.Core.Nodes.Item(Attribute_List,J);
                  J:=J+1;
                  case Det_Util_Attributes'Value
                    (Dom.Core.Attrs.Name(Attribute))is
                     when Total =>
                        Mast.Results.Set_Total
                          (Mast.Results.Detailed_Utilization_Result
                           (The_Utilization_Res.all),
                           Float'Value
                           (Dom.Core.Elements.Get_Attribute
                            (Dom.Core.Nodes.Item(Temporal_List,0),"Total")));
                     when Application =>
                        Mast.Results.Set_Application
                          (Mast.Results.Detailed_Utilization_Result
                           (The_Utilization_Res.all),
                           Float'Value
                           (Dom.Core.Elements.Get_Attribute
                            (Dom.Core.Nodes.Item(Temporal_List,0),
                             "Application")));
                     when Context_Switch =>
                        Mast.Results.Set_Context_Switch
                          (Mast.Results.Detailed_Utilization_Result
                           (The_Utilization_Res.all),
                           Float'Value
                           (Dom.Core.Elements.Get_Attribute
                            (Dom.Core.Nodes.Item(Temporal_List,0),
                             "Context_Switch")));
                     when Timer =>
                        Mast.Results.Set_Timer
                          (Mast.Results.Detailed_Utilization_Result
                           (The_Utilization_Res.all),
                           Float'Value
                           (Dom.Core.Elements.Get_Attribute
                            (Dom.Core.Nodes.Item(Temporal_List,0),"Timer")));
                     when Driver =>
                        Mast.Results.Set_Driver
                          (Mast.Results.Detailed_Utilization_Result
                           (The_Utilization_Res.all),
                           Float'Value
                           (Dom.Core.Elements.Get_Attribute
                            (Dom.Core.Nodes.Item(Temporal_List,0),"Driver")));
                  end case;
               end loop;
            end if;

            Temporal_List:=Dom.Core.Elements.Get_Elements_By_Tag_Name
              (Nodo,"mast_res:Ready_Queue_Size");
            if Dom.Core.Nodes.Length(Temporal_List)>0
            then
               The_Queue_Size_Res:=new Mast.Results.Ready_Queue_Size_Result;
               Processing_Resources.Set_Ready_Queue_Size_Result
                 (Pr_Ref.all,
                  Mast.Results.Ready_Queue_Size_Result_Ref
                  (The_Queue_Size_Res));
               Mast.Results.Set_Max_Num
                 (The_Queue_Size_Res.all,
                  Natural'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Dom.Core.Nodes.Item(Temporal_List,0),"Max_Num")));
            end if;
         end if;
      end loop;
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in results of processing resource: "&
            To_String(A_Name));
   end Add_Processing_Resource;

   ----------------------
   -- Add_System_Slack --
   ----------------------

   procedure Add_System_Slack
     (Mast_System:in out Mast.Systems.System;
      Slack_List: Dom.Core.Node_List)
   is
      Slack_Node     : Dom.Core.Node;
      Temporal_List : Dom.Core.Node_List;
      The_Slack_Res : Mast.Results.Slack_Result_Ref;
      Value : Mast.Unrestricted_Percentage;
   begin
      if  Dom.Core.Nodes.Length(Slack_List)>0 then
         Slack_Node:=Dom.Core.Nodes.Item(Slack_List,0);
         Value:=Mast.Unrestricted_Percentage'Value
           (Dom.Core.Elements.Get_Attribute(Slack_Node,"Value"));
         The_Slack_Res:=new Mast.Results.Slack_Result;
         Mast.Results.Set_Slack(The_Slack_Res.all,Value);
         Mast_System.The_Slack_Result:=The_Slack_Res;
      end if;
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in System Slack result");
   end Add_System_Slack;


   -----------
   -- Parse --
   -----------

   procedure Parse
     (Mast_System:in out Mast.Systems.System;
      File: in out Ada.Text_IO.File_Type)
   is
      My_Tree_Reader       : Dom.Readers.Tree_Reader;
      FileType,Version,S   : Ada.Strings.Unbounded.Unbounded_String;
      Tree                 : Dom.Core.Document;
      Read                 : Input_Sources.File.File_Input;
   begin
      Mast_XML_Exceptions.Clear_Errors;
      -- File Handle. --
      S:=Ada.Strings.Unbounded.To_Unbounded_String(Ada.Text_IO.Name(File));
      Ada.Text_IO.Close(File);
      Input_Sources.File.Open(Ada.Strings.Unbounded.To_String(S),Read);
      -- Read the XML file and get the tree. --
      --Validation ON OF (True, false)
      Dom.Readers.Set_Feature
        (My_Tree_Reader, Sax.Readers.Validation_Feature, False);
      --SAX Parse. (SAX)
      Dom.Readers.Parse (My_Tree_Reader, Read);
      Input_Sources.File.Close (Read);
      Tree:=Dom.Readers.Get_Tree (My_Tree_Reader);
      Dom.Core.Nodes.Normalize(Tree);
      -- Mast_Model Analysis --
      -- Analyze if the XML document is a Mast-Model-file & check the version.
      Mast_XML_Parser_Extension.Get_Kind_Of_XML_File(Tree,FileType,Version);
      if (FileType /=
          Ada.Strings.Unbounded.To_Unbounded_String("XML-Mast-Result-File"))
      then
         raise Mast_XML_Exceptions.Not_A_Mast_XML_File;
      end if;

      if  (Ada.Strings.Unbounded.To_String(Version) /=
           Ada.Strings.Unbounded.To_Unbounded_String("1.1"))
      then
         raise Mast_XML_Exceptions.Not_A_Mast_XML_File;
      end if;

      -- Model name and Date Analysis. --
      Mast_System.Model_Name:=Var_Strings.To_Var_String
        (To_Lower
         (Dom.Core.Elements.Get_Attribute
          (Dom.Core.Nodes.Item
           (Dom.Core.Documents.Get_Elements_By_Tag_Name
            (Tree,"mast_res:REAL_TIME_SITUATION"),0),"Model_Name")));
      Mast_System.Model_Date:=Dom.Core.Elements.Get_Attribute
        (Dom.Core.Nodes.Item(Dom.Core.Documents.Get_Elements_By_Tag_Name
                             (Tree,
                              "mast_res:REAL_TIME_SITUATION"),0),"Model_Date");
      Mast_System.Generation_Tool:=Var_Strings.To_Var_String
        (Dom.Core.Elements.Get_Attribute
         (Dom.Core.Nodes.Item
          (Dom.Core.Documents.Get_Elements_By_Tag_Name
           (Tree,"mast_res:REAL_TIME_SITUATION"),0),"Generation_Tool"));
      Mast_System.Generation_Profile:=Var_Strings.To_Var_String
        (Dom.Core.Elements.Get_Attribute
         (Dom.Core.Nodes.Item
          (Dom.Core.Documents.Get_Elements_By_Tag_Name
           (Tree,"mast_res:REAL_TIME_SITUATION"),0),"Generation_Profile"));
      Mast_System.Generation_Date:=Dom.Core.Elements.Get_Attribute
        (Dom.Core.Nodes.Item(Dom.Core.Documents.Get_Elements_By_Tag_Name
                             (Tree,"mast_res:REAL_TIME_SITUATION"),0),
         "Generation_Date");
      -- Get the list of elements for each kind of structure
      -- and give it to the respective "Add" procedure.
      -- Each "Add" procedure adds all the elements of a determined
      -- kind of structure that appear in the
      -- XML file to the Mast_System structure.
      Add_Processing_Resource
        (Mast_System,Dom.Core.Documents.Get_Elements_By_Tag_Name
         (Tree,"mast_res:Processing_Resource"));
      Add_Scheduling_Server
        (Mast_System,Dom.Core.Documents.Get_Elements_By_Tag_Name
         (Tree,"mast_res:Scheduling_Server"));
      Add_Shared_Resource
        (Mast_System,Dom.Core.Documents.Get_Elements_By_Tag_Name
         (Tree,"mast_res:Shared_Resource"));
      Add_Operation
        (Mast_System,Dom.Core.Documents.Get_Elements_By_Tag_Name
         (Tree,"mast_res:Operation"));
      Add_Transaction
        (Mast_System,Dom.Core.Documents.Get_Elements_By_Tag_Name
         (Tree,"mast_res:Transaction"));
      Add_System_Slack
        (Mast_System,Dom.Core.Documents.Get_Elements_By_Tag_Name
         (Tree,"mast_res:Slack"));
      -- Free Memory.--
      Dom.Readers.Free(My_Tree_Reader);

      Mast_XML_Exceptions.Report_Errors;
   exception
      when Mast_XML_Exceptions.Not_A_Mast_XML_File =>
         Ada.Text_IO.Put_Line
           ("The MAST  XML results file is not a Mast_Model_File");
         raise Mast_XML_Exceptions.Syntax_Error;
      when Mast_XML_Exceptions.Incorrect_Version =>
         Ada.Text_IO.Put_Line
           ("The MAST XML results file has an unsupported version tag");
         raise Mast_XML_Exceptions.Syntax_Error;
      when Mast_XML_Exceptions.Parser_Detected_Error =>
         Ada.Text_IO.Put_Line
           ("The MAST XML results file has errors detected by the parser");
         raise Mast_XML_Exceptions.Syntax_Error;
      when Mast_XML_Exceptions.Syntax_Error =>
         Ada.Text_Io.Put_Line
           ("Syntax error while processing the MAST XML results file");
         Ada.Text_Io.Put_Line
           ("Use an XML validation tool to find about the errors");
         raise Mast_XML_Exceptions.Syntax_Error;
      when Mast.Object_Not_Found =>
         Ada.Text_IO.Put_Line(Mast.Get_Exception_Message);
         raise Mast_XML_Exceptions.Syntax_Error;
      when others =>
         Ada.Text_Io.Put_Line
           ("The MAST XML results file has possible syntactic errors");
         Ada.Text_Io.Put_Line
           ("Use an XML validation tool to find about the errors");
         raise Mast_XML_Exceptions.Syntax_Error;
   end Parse;

end Mast_XML_Results_Parser;
