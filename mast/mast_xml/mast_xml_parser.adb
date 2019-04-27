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
--          Yago Pereiro                                             --
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

with Ada.Text_IO;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Strings;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Mast_XML_Exceptions;
with Dom.Core.Elements;
with Dom.Core.Documents;
with Dom.Core.Nodes;
with Dom.Core.Attrs;
with Dom.Readers;
with Input_Sources.File;
with Sax.Readers;
with Mast.Schedulers.Primary;
with Mast.Systems;
with Mast.Schedulers.Secondary;
with Mast.Shared_Resources;
with Mast.Scheduling_Servers;
with Mast.Scheduling_Policies;
with Mast.Scheduling_Parameters;
with Mast.Synchronization_Parameters;
with Mast.Processing_Resources.Processor;
with Mast.Processing_Resources.Network;
with Mast.Timers;
with Mast.Events;
with Mast.Graphs;
with Mast.Graphs.Links;
with Mast.Timing_Requirements;
with Mast.Graphs.Event_Handlers;
with Mast.Operations;
with Mast.Drivers;
with Mast_XML_Parser_Extension;
with List_Exceptions;
with Var_Strings; use Var_Strings;

use Mast;

package body Mast_XML_Parser is

   use type Mast.Schedulers.Lists.Index;
   use type Mast.Shared_Resources.Lists.Index;
   use type Mast.Schedulers.Lists.Index;
   use type Mast.Scheduling_Servers.Lists.Index;
   use type Mast.Timing_Requirements.Timing_Requirement_Ref;
   use type Mast.Operations.Lists.Index;
   use type Mast.Processing_Resources.Lists.Index;

   function Get_Attribute
     (E : DOM.Core.Node;
      Att_Name : String)return Var_String
   is
      Value: Var_String;
   begin
      Value:=To_Var_String(Dom.Core.Elements.Get_Attribute(E,Att_Name));
      --If the attribute doesn't appear the function will return "".
      if Value=Null_Var_String
      then
         raise Non_Existing;
      end if;
      return Value;
   end Get_Attribute;

   function To_Xml_Format(Word: String) return String is
      Xml_Word: String(1..Word'Length+9);
   begin
      Xml_Word(1..9):="mast_mdl:";
      Xml_Word(10..Xml_Word'Last):=Ada.Characters.Handling.To_Lower(Word);
      --Set the first letter to uppercase
      if Xml_Word'Last>=10 then
         Xml_Word(10):=Ada.Characters.Handling.To_Upper(XML_Word(10));
      end if;
      -- Set letters after an '_' character to uppercase
      for I in 11..XML_Word'Last loop
         if Xml_Word(I-1)='_'then
            Xml_Word(I):=Ada.Characters.Handling.To_Upper(Xml_Word(I));
         end if;
      end loop;
      return Xml_Word;
   end To_XML_Format;

   function Mast_Root_Element_Tag
     (Root_Elem: Mast_Root_Elements)
     return String
   is
   begin
      case Root_Elem is
         when SRP_Resource =>
            return "mast_mdl:SRP_Resource";
         when others =>
            return To_Xml_Format(Mast_Root_Elements'Image(Root_Elem));
      end case;
   end Mast_Root_Element_Tag;


   function Find_Separator
     (Line : Unbounded_String)
     return Natural
   is
      Within_Quotes : Boolean:=False;
   begin
      for I in 1..Length(Line) loop
         if Element(Line,I)='"' then
            Within_Quotes:=not Within_Quotes;
         end if;
         if not Within_Quotes and then Element(Line,I)<=' ' then
            return I;
         end if;
      end loop;
      return 0;
   end Find_Separator;

   function No_Quotes (S : Unbounded_String) return Var_String is
   begin
      if Length(S)>=2 and then
        (Element(S,1)='"' and then Element(S,Length(S))='"')
      then
         return To_Var_String((Slice(S,2,Length(S)-1)));
      else
         return To_Var_String(To_String(S));
      end if;
   end No_Quotes;

   function Trim(S : Unbounded_String) return Unbounded_String is
   begin
      for I in 1..Length(S) loop
         if Element(S,I)>' ' then
            return To_Unbounded_String(Slice(S,I,Length(S)));
         end if;
      end loop;
      return Null_Unbounded_String;
   end Trim;

   function First_Word
     (Line : Unbounded_String)
     return Var_String
   is
      No_Spaces : Unbounded_String:=Trim(Line);
      Pos_Sp : Natural;
   begin
      if Length(No_Spaces)=0 then
         return Null_Var_String;
      else
         Pos_Sp := Find_Separator(No_Spaces);
         if Pos_Sp=0 then
            return No_Quotes(No_Spaces);
         else
            return No_Quotes
              (To_Unbounded_String(Slice (No_Spaces,1,Pos_Sp-1)));
         end if;
      end if;
   end First_Word;

   function Delete_First_Word
     (Line : Unbounded_String)
     return Unbounded_String
   is
      No_Spaces : Unbounded_String:=Trim(Line);
      Pos_Sp : Natural;
   begin
      if Length(No_Spaces)=0 then
         return Null_Unbounded_String;
      else
         Pos_Sp := Find_Separator(No_Spaces);
         if Pos_Sp=0 then
            return Null_Unbounded_String;
         else
            return To_Unbounded_String
              (Slice(No_Spaces,Pos_Sp,Length(No_Spaces)));
         end if;
      end if;
   end Delete_First_Word;

   function To_Boolean ( Yes_No : String) return Boolean is
   begin
      if To_Lower(Yes_No)="yes" then
         return True;
      elsif To_Lower(Yes_No)="no" then
         return False;
      else
         raise Constraint_Error;
      end if;
   end To_Boolean;

   procedure Check_Identifier
     (Str : Var_String)
   is
      C : Character;
      Lstr : Var_String;
      Wrong_Identifier : exception;
   begin
      if Length(Str)>2 and then
        (Element(Str,1)='"' and then Element(Str,Length(Str))='"')
      then
         Lstr:=To_Lower(Slice(Str,2,Length(Str)-1));
      else
         Lstr:=To_Lower(Str);
      end if;
      if Length(LStr)=0 then
         raise Wrong_Identifier;
      end if;
      C:=Element(Lstr,1);
      if not (C in 'a'..'z') then
         raise Wrong_Identifier;
      end if;
      for I in 2..Length(Lstr) loop
         C:=Element(Lstr,I);
         if not (C in 'a'..'z' or else C in '0'..'9' or else
                 C ='_' or else C='.')
         then
            raise Wrong_Identifier;
         end if;
      end loop;
   exception
      when Wrong_Identifier =>
         Mast_XML_Exceptions.Parser_Error
           ("Wrong identifier: "&To_String(Str));
   end Check_Identifier;

   ---------------------------------------
   -- Add_Priority_Inheritance_Resource --
   ---------------------------------------

   procedure Add_Priority_Inheritance_Resource
     (Mast_System :in out Mast.Systems.System;
      Sr_Node : Dom.Core.Node)
   is
      Sr_Ref : Mast.Shared_Resources.Shared_Resource_Ref;
      A_Name : Var_Strings.Var_String;
   begin
      Sr_Ref:=new Mast.Shared_Resources.Priority_Inheritance_Resource;
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Sr_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Shared_Resources.Init
        (Sr_Ref.all,A_Name);
      Mast.Shared_Resources.Lists.Add(Sr_Ref,Mast_System.Shared_Resources);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Priority Inheritance resource: "&
            To_String(A_Name));
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("Shared resource already exists: "&To_String(A_Name));
   end Add_Priority_Inheritance_Resource;

   ------------------------------------
   -- Add_Immediate_Ceiling_Resource --
   ------------------------------------

   procedure Add_Immediate_Ceiling_Resource
     (Mast_System: in out Mast.Systems.System;
      Sr_Node : Dom.Core.Node)
   is
      Sr_Ref : Mast.Shared_Resources.Shared_Resource_Ref;
      A_Name : Var_Strings.Var_String;
   begin
      Sr_Ref:=new Mast.Shared_Resources.Immediate_Ceiling_Resource;
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Sr_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Shared_Resources.Init
        (Sr_Ref.all,A_Name);
      begin
         Mast.Shared_Resources.Set_Ceiling
           (Mast.Shared_Resources.Immediate_Ceiling_Resource(Sr_Ref.all),
            Mast.Priority'Value(To_String(Get_Attribute(Sr_Node,"Ceiling"))));
      exception
         when Non_Existing=>
            null;
         when Constraint_Error =>
            Mast_Xml_Exceptions.Parser_Error
              ("Priority value out of range in Immediate Ceiling Resource: "&
               To_String(A_Name));
      end;
      begin
         Mast.Shared_Resources.Set_Preassigned
           (Mast.Shared_Resources.Immediate_Ceiling_Resource(Sr_Ref.all),
            To_Boolean(To_String(Get_Attribute(Sr_Node,"Preassigned"))));
      exception
         when Non_Existing=>
            null;
      end;
      Mast.Shared_Resources.Lists.Add(Sr_Ref,Mast_System.Shared_Resources);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Immediate Ceiling resource: "&
            To_String(A_Name));
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("Shared resource already exists: "&To_String(A_Name));
   end Add_Immediate_Ceiling_Resource;

   ----------------------
   -- Add_SRP_Resource --
   ----------------------

   procedure Add_SRP_Resource
     (Mast_System: in out Mast.Systems.System;
      Sr_Node : Dom.Core.Node)
   is
      Sr_Ref : Mast.Shared_Resources.Shared_Resource_Ref;
      A_Name : Var_Strings.Var_String;
   begin
      Sr_Ref:=new Mast.Shared_Resources.SRP_Resource;
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Sr_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Shared_Resources.Init
        (Sr_Ref.all,A_Name);
      begin
         Mast.Shared_Resources.Set_Level
           (Mast.Shared_Resources.SRP_Resource(Sr_Ref.all),
            Mast.Preemption_Level'Value
            (To_String(Get_Attribute(Sr_Node,"Preemption_Level"))));
      exception
         when Non_Existing=>
            null;
         when Constraint_Error =>
            Mast_XML_Exceptions.Parser_Error
              ("Preemption level value out of range in SRP resource: "&
               To_String(A_Name));
      end;
      begin
         Mast.Shared_Resources.Set_Preassigned
           (Mast.Shared_Resources.SRP_Resource(Sr_Ref.all),
            To_Boolean(To_String(Get_Attribute(Sr_Node,"Preassigned"))));
      exception
         when Non_Existing=>
            null;
      end;
      Mast.Shared_Resources.Lists.Add(Sr_Ref,Mast_System.Shared_Resources);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in SRP resource: "&To_String(A_Name));
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("Shared resource already exists: "&To_String(A_Name));
   end Add_Srp_Resource;

   ---------------------------
   -- Add_Primary_Scheduler --
   ---------------------------

   procedure Add_Primary_Scheduler
     (Mast_System: in out Mast.Systems.System;
      Sched_Node : Dom.Core.Node)
   is
      Sched_Ref        : Mast.Schedulers.Scheduler_Ref;
      Pr_Index         : Mast.Processing_Resources.Lists.Index;
      Sched_Param_List : Dom.Core.Node_List;
      I                : Integer:=0;
      Act_Sch          : Dom.Core.Node;
      A_Name           : Var_Strings.Var_String;
   begin
      Sched_Ref:= new Mast.Schedulers.Primary.Primary_Scheduler;
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Sched_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Schedulers.Init
        (Mast.Schedulers.Scheduler(Sched_Ref.all),A_Name);
      Pr_Index:=Mast.Processing_Resources.Lists.Find
        (Var_Strings.To_Lower
         (Var_Strings.To_Var_String
          (Dom.Core.Elements.Get_Attribute(Sched_Node,"Host"))),
         Mast_System.Processing_Resources);
      if Pr_Index=Processing_Resources.Lists.Null_Index then
         declare
            Proc_Ref : Processing_Resources.Processing_Resource_Ref:=
              new Processing_Resources.Processor.Regular_Processor;
         begin
            Processing_Resources.Init
              (Proc_Ref.all,Var_Strings.To_Lower
               (Var_Strings.To_Var_String
                (Dom.Core.Elements.Get_Attribute(Sched_Node,"Host"))));
            Schedulers.Primary.Set_Host
              (Schedulers.Primary.Primary_Scheduler'Class
               (Sched_Ref.all),Proc_Ref);
         end;
      else
         Mast.Schedulers.Primary.Set_Host
           (Mast.Schedulers.Primary.Primary_Scheduler(Sched_Ref.all),
            Mast.Processing_Resources.Lists.Item
            (Pr_Index,Mast_System.Processing_Resources));
      end if;
      Sched_Param_List:=Dom.Core.Nodes.Child_Nodes(Sched_Node);
      while I<Dom.Core.Nodes.Length(Sched_Param_List)
      loop
         Act_Sch:=Dom.Core.Nodes.Item(Sched_Param_List,I);
         I:=I+1;
         if Dom.Core.Nodes.Local_Name(Act_Sch)/=""
         then
            Scheduler_Adds
              (Mast_Scheduler_Elements'Value
               (Dom.Core.Nodes.Local_Name(Act_Sch)))
              (Mast.Schedulers.Scheduler_Ref(Sched_Ref),Act_Sch);
         end if;
      end loop;
      Mast.Schedulers.Lists.Add(Sched_Ref,Mast_System.Schedulers);
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("Primary scheduler already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Primary Scheduler: "&To_String(A_Name));
   end Add_Primary_Scheduler;

   -----------------------------
   -- Add_Secondary_Scheduler --
   -----------------------------

   procedure Add_Secondary_Scheduler
     (Mast_System: in out Mast.Systems.System;
      Sched_Node : Dom.Core.Node)
   is
      Sched_Ref        : Mast.Schedulers.Scheduler_Ref;
      Ss_Index         : Mast.Scheduling_Servers.Lists.Index;
      Sched_Param_List : Dom.Core.Node_List;
      I                : Integer:=0;
      Act_Sch          : Dom.Core.Node;
      A_Name           : Var_Strings.Var_String;
   begin
      Sched_Ref:= new Mast.Schedulers.Secondary.Secondary_Scheduler;
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Sched_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Schedulers.Init
        (Mast.Schedulers.Scheduler(Sched_Ref.all),A_Name);
      Mast.Schedulers.Lists.Add(Sched_Ref,Mast_System.Schedulers);

      Ss_Index:=Mast.Scheduling_Servers.Lists.Find
        (Var_Strings.To_Lower
         (Var_Strings.To_Var_String
          (Dom.Core.Elements.Get_Attribute(Sched_Node,"Host"))),
         Mast_System.Scheduling_Servers);
      if Ss_Index=Mast.Scheduling_Servers.Lists.Null_Index
      then
         declare
            Ss: Mast.Scheduling_Servers.Scheduling_Server_Ref;
         begin
            Ss :=new Mast.Scheduling_Servers.Scheduling_Server;
            Mast.Scheduling_Servers.Init
              (Ss.all,
               Var_Strings.To_Lower
               (Var_Strings.To_Var_String
                (Dom.Core.Elements.Get_Attribute(Sched_Node,"Host"))));
            Mast.Schedulers.Secondary.Set_Server
              (Mast.Schedulers.Secondary.Secondary_Scheduler
               (Sched_Ref.all),Ss);
         end;
      else
         Mast.Schedulers.Secondary.Set_Server
           (Mast.Schedulers.Secondary.Secondary_Scheduler(Sched_Ref.all),
            Mast.Scheduling_Servers.Lists.Item
            (Ss_Index,Mast_System.Scheduling_Servers));
      end if;

      Sched_Param_List:=Dom.Core.Nodes.Child_Nodes(Sched_Node);
      while I<Dom.Core.Nodes.Length(Sched_Param_List)
      loop
         Act_Sch:=Dom.Core.Nodes.Item(Sched_Param_List,I);
         I:=I+1;
         if Dom.Core.Nodes.Local_Name(Act_Sch)/=""
         then
            Scheduler_Adds
              (Mast_Scheduler_Elements'Value
               (Dom.Core.Nodes.Local_Name(Act_Sch)))
              (Mast.Schedulers.Scheduler_Ref(Sched_Ref),Act_Sch);
         end if;
      end loop;
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("Secondary scheduler already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Secondary Scheduler: "&To_String(A_Name));
   end Add_Secondary_Scheduler;

   ----------------------------------
   -- Add_Fixed_Priority_Scheduler --
   ----------------------------------

   procedure Add_Fixed_Priority_Scheduler
     (Sched_Ref :in out Mast.Schedulers.Scheduler_Ref;
      Sp_Node : Dom.Core.Node)
   is
      Policy: Mast.Scheduling_Policies.Scheduling_Policy_Ref;
   begin
      Policy :=new Mast.Scheduling_Policies.Fixed_Priority;
      begin
         Mast.Scheduling_Policies.Set_Max_Priority
           (Mast.Scheduling_Policies.Fixed_Priority_Policy(Policy.all),
            Mast.Priority'Value
            (To_String(Get_Attribute(Sp_Node,"Max_Priority"))));
      exception
         when Non_Existing=>
            null;
         when Constraint_Error =>
            Mast_XML_Exceptions.Parser_Error
              ("Maximum priority value out of range in "&
               "Fixed Priority Scheduler");
      end;
      begin
         Mast.Scheduling_Policies.Set_Min_Priority
           (Mast.Scheduling_Policies.Fixed_Priority_Policy(Policy.all),
            Mast.Priority'Value
            (To_String(Get_Attribute(Sp_Node,"Min_Priority"))));
      exception
         when Non_Existing=>
            null;
         when Constraint_Error =>
            Mast_XML_Exceptions.Parser_Error
              ("Minimum priority value out of range in "&
               "Fixed Priority Scheduler");
      end;
      begin
         Mast.Scheduling_Policies.Set_Worst_Context_Switch
           (Mast.Scheduling_Policies.Fixed_Priority(Policy.all),
            Mast.Normalized_Execution_Time'Value
            (To_String(Get_Attribute(Sp_Node,"Worst_Context_Switch"))));
      exception
         when Non_Existing=>
            null;
      end;
      begin
         Mast.Scheduling_Policies.Set_Avg_Context_Switch
           (Mast.Scheduling_Policies.Fixed_Priority(Policy.all),
            Mast.Normalized_Execution_Time'Value
            (To_String(Get_Attribute(Sp_Node,"Avg_Context_Switch"))));
      exception
         when Non_Existing=>
            null;
      end;
      begin
         Mast.Scheduling_Policies.Set_Best_Context_Switch
           (Mast.Scheduling_Policies.Fixed_Priority(Policy.all),
            Mast.Normalized_Execution_Time'Value
            (To_String(Get_Attribute(Sp_Node,"Best_Context_Switch"))));
      exception
         when Non_Existing=>
            null;
      end;
      Mast.Schedulers.Set_Scheduling_Policy(Sched_Ref.all,Policy);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Fixed Priority Scheduler");
   end Add_Fixed_Priority_Scheduler;

   -----------------------
   -- Add_EDF_Scheduler --
   -----------------------

   procedure Add_EDF_Scheduler
     (Sched_Ref :in out Mast.Schedulers.Scheduler_Ref;
      Sp_Node : Dom.Core.Node)
   is
      Policy: Mast.Scheduling_Policies.Scheduling_Policy_Ref;
   begin
      Policy :=new Mast.Scheduling_Policies.EDF;
      declare
      begin
         Mast.Scheduling_Policies.Set_Worst_Context_Switch
           (Mast.Scheduling_Policies.EDF(Policy.all),
            Mast.Normalized_Execution_Time'Value
            (To_String(Get_Attribute(Sp_Node,"Worst_Context_Switch"))));
      exception
         when Non_Existing=>
            null;
      end;
      declare
      begin
         Mast.Scheduling_Policies.Set_Avg_Context_Switch
           (Mast.Scheduling_Policies.EDF(Policy.all),
            Mast.Normalized_Execution_Time'Value
            (To_String(Get_Attribute(Sp_Node,"Avg_Context_Switch"))));
      exception
         when Non_Existing=>
            null;
      end;
      declare
      begin
         Mast.Scheduling_Policies.Set_Best_Context_Switch
           (Mast.Scheduling_Policies.EDF(Policy.all),
            Mast.Normalized_Execution_Time'Value
            (To_String(Get_Attribute(Sp_Node,"Best_Context_Switch"))));
      exception
         when Non_Existing=>
            null;
      end;
      Mast.Schedulers.Set_Scheduling_Policy(Sched_Ref.all,Policy);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in EDF Scheduler");
   end Add_EDF_Scheduler;


   -----------------------------------
   -- Add_FP_Packet_Based_Scheduler --
   -----------------------------------

   procedure Add_FP_Packet_Based_Scheduler
     (Sched_Ref :in out Mast.Schedulers.Scheduler_Ref;
      Sp_Node : Dom.Core.Node)
   is
      Policy: Mast.Scheduling_Policies.Scheduling_Policy_Ref;
   begin
      Policy :=new Mast.Scheduling_Policies.FP_Packet_Based;
      begin
         Mast.Scheduling_Policies.Set_Max_Priority
           (Mast.Scheduling_Policies.Fixed_Priority_Policy(Policy.all),
            Mast.Priority'Value
            (To_String(Get_Attribute(Sp_Node,"Max_Priority"))));
      exception
         when Non_Existing=>
            null;
         when Constraint_Error =>
            Mast_XML_Exceptions.Parser_Error
              ("Maximum priority value out of range "&
               "in FP Packet Based Scheduler");
      end;
      begin
         Mast.Scheduling_Policies.Set_Min_Priority
           (Mast.Scheduling_Policies.Fixed_Priority_Policy(Policy.all),
            Mast.Priority'Value
            (To_String(Get_Attribute(Sp_Node,"Min_Priority"))));
      exception
         when Non_Existing=>
            null;
         when Constraint_Error =>
            Mast_XML_Exceptions.Parser_Error
              ("Minimum priority value out of range "&
               "in FP Packet Based Scheduler");
      end;
      begin
         Mast.Scheduling_Policies.Set_Packet_Overhead_Max_Size
           (Mast.Scheduling_Policies.FP_Packet_Based(Policy.all),
            Mast.Bit_Count'Value
            (To_String(Get_Attribute(Sp_Node,"Packet_Overhead_Max_Size"))));
      exception
         when Non_Existing=>
            null;
      end;
      begin
         Mast.Scheduling_Policies.Set_Packet_Overhead_Avg_Size
           (Mast.Scheduling_Policies.FP_Packet_Based(Policy.all),
            Mast.Bit_Count'Value
            (To_String(Get_Attribute(Sp_Node,"Packet_Overhead_Avg_Size"))));

      exception
         when Non_Existing=>
            null;
      end;
      begin
         Mast.Scheduling_Policies.Set_Packet_Overhead_Min_Size
           (Mast.Scheduling_Policies.FP_Packet_Based(Policy.all),
            Mast.Bit_Count'Value
            (To_String(Get_Attribute(Sp_Node,"Packet_Overhead_Min_Size"))));

      exception
         when Non_Existing=>
            null;
      end;
      Mast.Schedulers.Set_Scheduling_Policy(Sched_Ref.all,Policy);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in FP Packet Based Scheduler");
   end Add_Fp_Packet_Based_Scheduler;

   ---------------------------
   -- Add_Regular_Processor --
   ---------------------------

   procedure Add_Regular_Processor
     (Mast_System: in out Mast.Systems.System;
      Rp_Node : Dom.Core.Node)
   is
      type Processor_Attributes is
        (Name,Max_Interrupt_Priority,Min_Interrupt_Priority,
         Worst_ISR_Switch,Avg_ISR_Switch,Best_ISR_Switch,Speed_Factor);

      Pr_Ref      : Mast.Processing_Resources.Processing_Resource_Ref;
      Attr_Lst    : Dom.Core.Named_Node_Map;
      St_List     : Dom.Core.Node_List;
      I,J         : Natural:=0;
      Attr,Act_St : Dom.Core.Node;
      A_Name      : Var_Strings.Var_String;
   begin
      Pr_Ref:= new Mast.Processing_Resources.Processor.Regular_Processor;
      A_Name:=To_Lower(Var_Strings.To_Var_String
                       (Dom.Core.Elements.Get_Attribute(Rp_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Processing_Resources.Init(Pr_Ref.all,A_Name);

      Mast.Processing_Resources.Lists.Add
        (Pr_Ref,Mast_System.Processing_Resources);
      --Attribute processing--
      Attr_Lst:=Dom.Core.Nodes.Attributes(Rp_Node);
      Attr:=Dom.Core.Nodes.Item(Attr_Lst,J);
      J:=0;
      while J<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Attr:=Dom.Core.Nodes.Item(Attr_Lst,J);
         J:=J+1;
         case Processor_Attributes'Value(Dom.Core.Attrs.Name(Attr))is
            when Speed_Factor =>
               Mast.Processing_Resources.Set_Speed_Factor
                 (Pr_Ref.all,
                  Mast.Processor_Speed'Value
                  (Dom.Core.Elements.Get_Attribute(Rp_Node,"Speed_Factor")));
            when Max_Interrupt_Priority=>
               begin
                  Mast.Processing_Resources.Processor.
                    Set_Max_Interrupt_Priority
                    (Mast.Processing_Resources.Processor.Regular_Processor
                     (Pr_Ref.all),
                     Mast.Priority'Value
                     (Dom.Core.Elements.Get_Attribute
                      (Rp_Node,"Max_Interrupt_Priority")));
               exception
                  when Constraint_Error =>
                     Mast_XML_Exceptions.Parser_Error
                       ("Maximum priority value out of range"&
                        "In Regular Processor: "&To_String(A_Name));
               end;
            when  Min_Interrupt_Priority=>
               begin
                  Mast.Processing_Resources.Processor.
                    Set_Min_Interrupt_Priority
                    (Mast.Processing_Resources.Processor.Regular_Processor
                     (Pr_Ref.all),
                     Mast.Priority'Value
                     (Dom.Core.Elements.Get_Attribute
                      (Rp_Node,"Min_Interrupt_Priority")));
               exception
                  when Constraint_Error =>
                     Mast_XML_Exceptions.Parser_Error
                       ("Minimum priority value out of range"&
                        "In Regular Processor: "&To_String(A_Name));
               end;
            when Worst_ISR_Switch =>
               Mast.Processing_Resources.Processor.Set_Worst_ISR_Switch
                 (Mast.Processing_Resources.Processor.Regular_Processor
                  (Pr_Ref.all),
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Rp_Node,"Worst_ISR_Switch")));
            when Avg_ISR_Switch =>
               Mast.Processing_Resources.Processor.Set_Avg_ISR_Switch
                 (Mast.Processing_Resources.Processor.Regular_Processor
                  (Pr_Ref.all),
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Rp_Node,"Avg_ISR_Switch")));
            when Best_ISR_Switch =>
               Mast.Processing_Resources.Processor.Set_Best_ISR_Switch
                 (Mast.Processing_Resources.Processor.Regular_Processor
                  (Pr_Ref.all),
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Rp_Node,"Best_ISR_Switch")));
            when Name=>
               null;
         end case;
      end loop;
      St_List:=Dom.Core.Nodes.Child_Nodes(Rp_Node);
      while I<Dom.Core.Nodes.Length(St_List)
      loop
         Act_St:=Dom.Core.Nodes.Item(St_List,I);
         I:=I+1;
         if Dom.Core.Nodes.Local_Name(Act_St)/=""
         then
            System_Timer_Adds
              (Mast_System_Timer_Elements'Value
               (Dom.Core.Nodes.Local_Name(Act_St)))(Pr_Ref,Act_St);
         end if;
      end loop;
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("Regular processor already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Regular Processor: "&To_String(A_Name));
   end Add_Regular_Processor;

   -----------------------------
   -- Add_Ticker_System_Timer --
   -----------------------------

   procedure Add_Ticker_System_Timer
     (Rsrc :in out Mast.Processing_Resources.Processing_Resource_Ref;
      Tst_Node : Dom.Core.Node)
   is
      type Ticker_Attributes is
        (Worst_Overhead,Avg_Overhead,Best_Overhead,Period);
      I         : Integer:=0;
      Attr      : Dom.Core.Node;
      Attr_Lst  : Dom.Core.Named_Node_Map;
      Timer_Ref : Mast.Timers.System_Timer_Ref;
   begin
      Timer_Ref:= new Mast.Timers.Ticker;
      Attr_Lst:=Dom.Core.Nodes.Attributes(Tst_Node);
      while I<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Attr:=Dom.Core.Nodes.Item(Attr_Lst,I);
         I:=I+1;
         case Ticker_Attributes'Value(Dom.Core.Attrs.Name(Attr))is
            when  Worst_Overhead=>
               Mast.Timers.Set_Worst_Overhead
                 (Timer_Ref.all,
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Tst_Node,"Worst_Overhead")));
            when  Avg_Overhead=>
               Mast.Timers.Set_Avg_Overhead
                 (Timer_Ref.all,
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Tst_Node,"Avg_Overhead")));
            when  Best_Overhead=>
               Mast.Timers.Set_Best_Overhead
                 (Timer_Ref.all,
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Tst_Node,"Best_Overhead")));
            when Period =>
               Mast.Timers.Set_Period
                 (Mast.Timers.Ticker(Timer_Ref.all),
                  Mast.Time'Value(Dom.Core.Elements.Get_Attribute
                                  (Tst_Node,"Period")));
         end case;
      end loop;
      Mast.Processing_Resources.Processor.Set_System_Timer
        (Mast.Processing_Resources.Processor.Regular_Processor(Rsrc.all),
         Timer_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Ticker System Timer");
   end Add_Ticker_System_Timer;

   ----------------------------------
   -- Add_Alarm_Clock_System_Timer --
   ----------------------------------

   procedure Add_Alarm_Clock_System_Timer
     (Rsrc :in out Mast.Processing_Resources.Processing_Resource_Ref;
      Acst_Node: Dom.Core.Node)
   is
      type Alarm_Clock_Attributes is
        (Worst_Overhead,Avg_Overhead,Best_Overhead);

      I         : Integer:=0;
      Attr      : Dom.Core.Node;
      Attr_Lst  : Dom.Core.Named_Node_Map;
      Timer_Ref : Mast.Timers.System_Timer_Ref;
   begin
      Timer_Ref:= new Mast.Timers.Alarm_Clock;
      Attr_Lst:=Dom.Core.Nodes.Attributes(Acst_Node);
      while I<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Attr:=Dom.Core.Nodes.Item(Attr_Lst,I);
         I:=I+1;
         case Alarm_Clock_Attributes'Value(Dom.Core.Attrs.Name(Attr))is
            when  Worst_Overhead=>
               Mast.Timers.Set_Worst_Overhead
                 (Timer_Ref.all,
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Acst_Node,"Worst_Overhead")));
            when  Avg_Overhead=>
               Mast.Timers.Set_Avg_Overhead
                 (Timer_Ref.all,
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Acst_Node,"Avg_Overhead")));
            when  Best_Overhead=>
               Mast.Timers.Set_Best_Overhead
                 (Timer_Ref.all,
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Acst_Node,"Best_Overhead")));
         end case;
      end loop;
      Mast.Processing_Resources.Processor.Set_System_Timer
        (Mast.Processing_Resources.Processor.Regular_Processor(Rsrc.all),
         Timer_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Alarm Clock System Timer");
   end Add_Alarm_Clock_System_Timer;

   ---------------------
   -- Add_Transaction --
   ---------------------

   procedure Add_Transaction
     (Mast_System: in out Mast.Systems.System;
      Rt_Node : Dom.Core.Node)
   is
      Rt_Ref : Mast.Transactions.Transaction_Ref;
      Rt_Lst : Dom.Core.Node_List;
      Act_Rt : Dom.Core.Node;
      I      : Integer:=0;
      A_Name : Var_Strings.Var_String;
   begin
      Rt_Ref:= new Mast.Transactions.Regular_Transaction;
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Rt_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Transactions.Init(Rt_Ref.all,A_Name);
      Rt_Lst:=Dom.Core.Nodes.Child_Nodes(Rt_Node);
      while I<Dom.Core.Nodes.Length(Rt_Lst)
      loop
         Act_Rt:=Dom.Core.Nodes.Item(Rt_Lst,I);
         I:=I+1;
         if Dom.Core.Nodes.Local_Name(Act_Rt)/=""
         then
            if Dom.Core.Nodes.Local_Name(Act_Rt) = "Delay"
            then
               Event_Adds(Ddelay)
                 (MAST_System,
                  Mast.Transactions.Transaction_Ref(Rt_Ref),Act_Rt);
            else
               Event_Adds
                 (Mast_Event_Elements'Value(Dom.Core.Nodes.Local_Name(Act_Rt)))
                 (Mast_System,
                  Mast.Transactions.Transaction_Ref(Rt_Ref),Act_Rt);
            end if;
         end if;
      end loop;
      Mast.Transactions.Lists.Add(Rt_Ref,Mast_System.Transactions);
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("Transaction already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Transaction: "&To_String(A_Name));
   end Add_Transaction;

   -- Add procedures for external events

   ---------------------------------
   -- Add_Periodic_External_Event --
   ---------------------------------
   procedure Add_Periodic_External_Event
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Ee_Node : Dom.Core.Node)
   is
      Link_Ref : Mast.Graphs.Link_Ref;
      Event_Ref: Mast.Events.Event_Ref;
      J        : Integer:=0;
      Attr_Lst : Dom.Core.Named_Node_Map;
      Act_Attr : Dom.Core.Node;
      A_Name   : Var_Strings.Var_String;
   begin
      Event_Ref:= new Mast.Events.Periodic_Event;
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Ee_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Events.Init(Event_Ref.all,A_Name);
      Attr_Lst:=Dom.Core.Nodes.Attributes(Ee_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,J);
         J:=J+1;
         case External_Event_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))
         is
            when Name =>
               null;
            when Period=>
               Mast.Events.Set_Period
                 (Mast.Events.Periodic_Event(Event_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when Max_Jitter=>
               Mast.Events.Set_Max_Jitter
                 (Mast.Events.Periodic_Event(Event_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when Phase=>
               Mast.Events.Set_Phase
                 (Mast.Events.Periodic_Event(Event_Ref.all),
                  Mast.Absolute_Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when others =>
               Ada.Text_IO.Put_Line("Syntax error in Periodic External Event");
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      Link_Ref:= new Mast.Graphs.Links.Regular_Link;
      Mast.Graphs.Set_Event(Link_Ref.all,Event_Ref);
      Mast.Transactions.Add_External_Event_Link(Trans_Ref.all,Link_Ref);
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("External event already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Periodic External Event: "&To_String(A_Name));
   end Add_Periodic_External_Event;

   ----------------------------------
   -- Add_Sporadic_External_Event --
   ----------------------------------

   procedure Add_Sporadic_External_Event
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Ee_Node : Dom.Core.Node)
   is
      Event_Ref : Mast.Events.Event_Ref;
      J         : Integer:=0;
      Attr_Lst  : Dom.Core.Named_Node_Map;
      Act_Attr  : Dom.Core.Node;
      Link_Ref  : Mast.Graphs.Link_Ref;
      A_Name    : Var_Strings.Var_String;
   begin
      Event_Ref:= new Mast.Events.Sporadic_Event;
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Ee_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Events.Init(Event_Ref.all,A_Name);
      Attr_Lst:=Dom.Core.Nodes.Attributes(Ee_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,J);
         J:=J+1;
         case External_Event_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))
         is
            when Name =>
               null;
            when Min_Interarrival=>
               Mast.Events.Set_Min_Interarrival
                 (Mast.Events.Sporadic_Event(Event_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when Avg_Interarrival =>
               Mast.Events.Set_Avg_Interarrival
                 (Mast.Events.Sporadic_Event(Event_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when Distribution=>
               Mast.Events.Set_Distribution
                 (Mast.Events.Sporadic_Event(Event_Ref.all),
                  Mast.Distribution_Function'Value
                  (Dom.Core.Attrs.Value(Act_Attr)));
            when others =>
               Ada.Text_IO.Put_Line("Syntax error in Sporadic External Event");
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      Link_Ref:= new Mast.Graphs.Links.Regular_Link;
      Mast.Graphs.Set_Event(Link_Ref.all,Event_Ref);
      Mast.Transactions.Add_External_Event_Link(Trans_Ref.all,Link_Ref);
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("External event already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Sporadic External Event: "&To_String(A_Name));
   end Add_Sporadic_External_Event;

   ----------------------------------
   -- Add_Unbounded_External_Event --
   ----------------------------------

   procedure Add_Unbounded_External_Event
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Ee_Node : Dom.Core.Node)
   is
      Event_Ref : Mast.Events.Event_Ref;
      J         : Integer:=0;
      Attr_Lst  : Dom.Core.Named_Node_Map;
      Act_Attr  : Dom.Core.Node;
      Link_Ref  : Mast.Graphs.Link_Ref;
      A_Name    : Var_Strings.Var_String;
   begin
      Event_Ref:= new Mast.Events.Unbounded_Event;
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Ee_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Events.Init(Event_Ref.all,A_Name);
      Attr_Lst:=Dom.Core.Nodes.Attributes(Ee_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,J);
         J:=J+1;
         case External_Event_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))
         is
            when Name =>
               null;
            when Avg_Interarrival=>
               Mast.Events.Set_Avg_Interarrival
                 (Mast.Events.Unbounded_Event(Event_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when Distribution=>
               Mast.Events.Set_Distribution
                 (Mast.Events.Unbounded_Event(Event_Ref.all),
                  Mast.Distribution_Function'Value
                  (Dom.Core.Attrs.Value(Act_Attr)));
            when others =>
               Ada.Text_IO.Put_Line
                 ("Syntax error in Unbounded External Event");
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      Link_Ref:= new Mast.Graphs.Links.Regular_Link;
      Mast.Graphs.Set_Event(Link_Ref.all,Event_Ref);
      Mast.Transactions.Add_External_Event_Link(Trans_Ref.all,Link_Ref);
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("External event already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Unbounded External Event: "&To_String(A_Name));
   end Add_Unbounded_External_Event;

   ----------------------------------
   -- Add_Singular_External_Event --
   ----------------------------------

   procedure Add_Singular_External_Event
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Ee_Node : Dom.Core.Node)
   is
      Link_Ref  : Mast.Graphs.Link_Ref;
      Event_Ref : Mast.Events.Event_Ref;
      J         : Integer:=0;
      Attr_Lst  : Dom.Core.Named_Node_Map;
      Act_Attr  : Dom.Core.Node;
      A_Name    : Var_Strings.Var_String;
   begin
      Event_Ref:= new Mast.Events.Singular_Event;
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Ee_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Events.Init(Event_Ref.all,A_Name);
      Attr_Lst:=Dom.Core.Nodes.Attributes(Ee_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,J);
         J:=J+1;
         case External_Event_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))
         is
            when Name =>
               null;
            when Phase=>
               Mast.Events.Set_Phase
                 (Mast.Events.Singular_Event(Event_Ref.all),
                  Mast.Absolute_Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when others =>
               Ada.Text_IO.Put_Line("Syntax error in Singular External Event");
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      Link_Ref:= new Mast.Graphs.Links.Regular_Link;
      Mast.Graphs.Set_Event(Link_Ref.all,Event_Ref);
      Mast.Transactions.Add_External_Event_Link(Trans_Ref.all,Link_Ref);
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("External event already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Singular External Event: "&To_String(A_Name));
   end Add_Singular_External_Event;

   -------------------------------
   -- Add_Bursty_External_Event --
   -------------------------------

   procedure Add_Bursty_External_Event
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Ee_Node : Dom.Core.Node)
   is
      Event_Ref : Mast.Events.Event_Ref;
      Link_Ref  : Mast.Graphs.Link_Ref;
      J         : Integer:=0;
      Attr_Lst  : Dom.Core.Named_Node_Map;
      Act_Attr  : Dom.Core.Node;
      A_Name    : Var_Strings.Var_String;
   begin
      Event_Ref:= new Mast.Events.Bursty_Event;
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Ee_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Events.Init(Event_Ref.all,A_Name);
      Attr_Lst:=Dom.Core.Nodes.Attributes(Ee_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,J);
         J:=J+1;
         case External_Event_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))
         is
            when Name =>
               null;
            when Avg_Interarrival=>
               Mast.Events.Set_Avg_Interarrival
                 (Mast.Events.Bursty_Event(Event_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when Distribution=>
               Mast.Events.Set_Distribution
                 (Mast.Events.Bursty_Event(Event_Ref.all),
                  Mast.Distribution_Function'Value
                  (Dom.Core.Attrs.Value(Act_Attr)));
            when Bound_Interval=>
               Mast.Events.Set_Bound_Interval
                 (Mast.Events.Bursty_Event(Event_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when Max_Arrivals=>
               Mast.Events.Set_Max_Arrivals
                 (Mast.Events.Bursty_Event(Event_Ref.all),
                  Positive'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when others =>
               Ada.Text_IO.Put_Line("Syntax error in Bursty External Event");
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      Link_Ref:= new Mast.Graphs.Links.Regular_Link;
      Mast.Graphs.Set_Event(Link_Ref.all,Event_Ref);
      Mast.Transactions.Add_External_Event_Link(Trans_Ref.all,Link_Ref);
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("External event already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Bursty External Event: "&To_String(A_Name));
   end Add_Bursty_External_Event;


   -- Add procedure for internal events and their timing requirements

   -----------------------
   -- Add_Regular_Event --
   -----------------------

   procedure Add_Regular_Event
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Ie_Node : Dom.Core.Node)
   is
      Link_Ref    : Mast.Graphs.Link_Ref;
      Ctr_Lst     : Dom.Core.Node_List;
      Act_Ctr     : Dom.Core.Node;
      I           : Integer:=0;
      Ie_Ref      : Mast.Events.Event_Ref;
      Tr_Null_Ref : Mast.Timing_Requirements.Timing_Requirement_Ref:=null;
      A_Name      : Var_Strings.Var_String;
   begin
      Ie_Ref:= new Mast.Events.Internal_Event;
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Ie_Node,"Event")));
      Check_Identifier(A_Name);
      Mast.Events.Init
        (Ie_Ref.all,A_Name);
      Link_Ref:= new Mast.Graphs.Links.Regular_Link;
      Mast.Graphs.Set_Event(Link_Ref.all,Ie_Ref);
      Ctr_Lst:=Dom.Core.Nodes.Child_Nodes(Ie_Node);
      while I<Dom.Core.Nodes.Length(Ctr_Lst)
      loop
         Act_Ctr:=Dom.Core.Nodes.Item(Ctr_Lst,I);
         I:=I+1;
         if Dom.Core.Nodes.Local_Name(Act_Ctr)/=""
         then
            Timming_Requirement_Adds
              (Mast_Timming_Requirement_Elements'Value
               (Dom.Core.Nodes.Local_Name(Act_Ctr)))
              (Link_Ref,Trans_Ref,Act_Ctr,Tr_Null_Ref);
         end if;
      end loop;
      Mast.Transactions.Add_Internal_Event_Link(Trans_Ref.all,Link_Ref);
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("Internal event already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Regular Event: "&To_String(A_Name));
   end Add_Regular_Event;

   ---------------------------
   -- Add_Max_Output_Jitter --
   ---------------------------

   procedure Add_Max_Output_Jitter
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node  : Dom.Core.Node;
      Comp_Tr_Ref: in out Mast.Timing_Requirements.Timing_Requirement_Ref)
   is
      Attr_Lst : Dom.Core.Named_Node_Map;
      J        : Integer:=0;
      Act_Attr : Dom.Core.Node;
      Tr_Ref   : Mast.Timing_Requirements.Timing_Requirement_Ref;
      Ref_Name : Var_Strings.Var_String;
   begin
      Tr_Ref:= new Mast.Timing_Requirements.Max_Output_Jitter_Req;
      Attr_Lst:=Dom.Core.Nodes.Attributes(Tr_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,J);
         J:=J+1;
         case Timing_Req_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))
         is
            when Max_Output_Jitter=>
               Mast.Timing_Requirements.Set_Max_Output_Jitter
                 (Mast.Timing_Requirements.Max_Output_Jitter_Req(Tr_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when Referenced_Event=>
               begin
                  Ref_Name:=Var_Strings.To_Lower
                    (Var_Strings.To_Var_String
                     (Dom.Core.Attrs.Value(Act_Attr)));
                  Mast.Timing_Requirements.Set_Event
                    (Mast.Timing_Requirements.Max_Output_Jitter_Req
                     (Tr_Ref.all),Mast.Transactions.Find_Any_Event
                     (Ref_Name,Trans_Ref.all));
               exception
                  when Transactions.Event_Not_Found =>
                     declare
                        Evnt_Ref : Events.Event_Ref:=
                          new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,Ref_Name);
                        Mast.Timing_Requirements.Set_Event
                          (Mast.Timing_Requirements.Max_Output_Jitter_Req
                           (Tr_Ref.all),Evnt_Ref);
                     end;
               end;
            when others =>
               Ada.Text_IO.Put_Line("Syntax error in Max Output Jitter Req");
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      if Comp_Tr_Ref=null
      then
         Mast.Graphs.Links.Set_Link_Timing_Requirements
           (Mast.Graphs.Links.Regular_Link(Link_Ref.all),
            Tr_Ref);
      else
         Mast.Timing_Requirements.Add_Requirement
           (Mast.Timing_Requirements.Composite_Timing_Req(Comp_Tr_Ref.all),
            Mast.Timing_Requirements.Simple_Timing_Requirement_Ref(Tr_Ref));
      end if;
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Max Output Jitter Req, in Link: "&
            To_String(Graphs.Name(Link_Ref)));
   end Add_Max_Output_Jitter;

   ------------------------------
   -- Add_Hard_Global_Deadline --
   ------------------------------

   procedure Add_Hard_Global_Deadline
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node : Dom.Core.Node;
      Comp_Tr_Ref: in out Mast.Timing_Requirements.Timing_Requirement_Ref)
   is
      Attr_Lst : Dom.Core.Named_Node_Map;
      J        : Integer:=0;
      Act_Attr : Dom.Core.Node;
      Tr_Ref   : Mast.Timing_Requirements.Timing_Requirement_Ref;
      Ref_Name : Var_Strings.Var_String;
   begin
      Tr_Ref:= new Mast.Timing_Requirements.Hard_Global_Deadline;
      Attr_Lst:=Dom.Core.Nodes.Attributes(Tr_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,J);
         J:=J+1;
         case Timing_Req_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))
         is
            when Deadline=>
               Mast.Timing_Requirements.Set_The_Deadline
                 (Mast.Timing_Requirements.Deadline(Tr_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when Referenced_Event=>
               begin
                  Ref_Name:=Var_Strings.To_Lower
                    (Var_Strings.To_Var_String
                     (Dom.Core.Attrs.Value(Act_Attr)));
                  Mast.Timing_Requirements.Set_Event
                    (Mast.Timing_Requirements.Hard_Global_Deadline(Tr_Ref.all),
                     Mast.Transactions.Find_Any_Event
                     (Ref_Name,Trans_Ref.all));
               exception
                  when Transactions.Event_Not_Found =>
                     declare
                        Evnt_Ref : Events.Event_Ref:=
                          new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,Ref_Name);
                        Mast.Timing_Requirements.Set_Event
                          (Mast.Timing_Requirements.Global_Deadline
                           (Tr_Ref.all),Evnt_Ref);
                     end;
               end;
            when others =>
               Ada.Text_IO.Put_Line("Syntax error in Hard Global Deadline");
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      if Comp_Tr_Ref=null
      then
         Mast.Graphs.Links.Set_Link_Timing_Requirements
           (Mast.Graphs.Links.Regular_Link(Link_Ref.all),
            Tr_Ref);
      else
         Mast.Timing_Requirements.Add_Requirement
           (Mast.Timing_Requirements.Composite_Timing_Req(Comp_Tr_Ref.all),
            Mast.Timing_Requirements.Simple_Timing_Requirement_Ref(Tr_Ref));
      end if;
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Hard Global Deadline, in Link: "&
            To_String(Graphs.Name(Link_Ref)));
   end Add_Hard_Global_Deadline;

   ------------------------------
   -- Add_Soft_Global_Deadline --
   ------------------------------

   procedure Add_Soft_Global_Deadline
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node : Dom.Core.Node;
      Comp_Tr_Ref:in out Mast.Timing_Requirements.Timing_Requirement_Ref)
   is
      Attr_Lst : Dom.Core.Named_Node_Map;
      J        : Integer:=0;
      Act_Attr : Dom.Core.Node;
      Tr_Ref   : Mast.Timing_Requirements.Timing_Requirement_Ref;
      Ref_Name : Var_Strings.Var_String;
   begin
      Tr_Ref:= new Mast.Timing_Requirements.Soft_Global_Deadline;
      Attr_Lst:=Dom.Core.Nodes.Attributes(Tr_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,J);
         J:=J+1;
         case Timing_Req_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))
         is
            when Deadline=>
               Mast.Timing_Requirements.Set_The_Deadline
                 (Mast.Timing_Requirements.Deadline(Tr_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when Referenced_Event=>
               begin
                  Ref_Name:=Var_Strings.To_Lower
                    (Var_Strings.To_Var_String
                     (Dom.Core.Attrs.Value(Act_Attr)));
                  Mast.Timing_Requirements.Set_Event
                    (Mast.Timing_Requirements.Soft_Global_Deadline(Tr_Ref.all),
                     Mast.Transactions.Find_Any_Event
                     (Ref_Name,Trans_Ref.all));
               exception
                  when Mast.Transactions.Event_Not_Found =>
                     declare
                        Evnt_Ref : Events.Event_Ref:=
                          new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,Ref_Name);
                        Mast.Timing_Requirements.Set_Event
                          (Mast.Timing_Requirements.Global_Deadline
                           (Tr_Ref.all),Evnt_Ref);
                     end;
               end;
            when others =>
               Ada.Text_IO.Put_Line("Syntax error in Soft Global Deadline");
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      if Comp_Tr_Ref=null
      then
         Mast.Graphs.Links.Set_Link_Timing_Requirements
           (Mast.Graphs.Links.Regular_Link(Link_Ref.all),
            Tr_Ref);
      else
         Mast.Timing_Requirements.Add_Requirement
           (Mast.Timing_Requirements.Composite_Timing_Req(Comp_Tr_Ref.all),
            Mast.Timing_Requirements.Simple_Timing_Requirement_Ref(Tr_Ref));
      end if;
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Soft Global Deadline, in Link: "&
            To_String(Graphs.Name(Link_Ref)));
   end Add_Soft_Global_Deadline;

   -------------------------------
   -- Add_Global_Max_Miss_Ratio --
   -------------------------------

   procedure Add_Global_Max_Miss_Ratio
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node : Dom.Core.Node;
      Comp_Tr_Ref: in out Mast.Timing_Requirements.Timing_Requirement_Ref)
   is
      Attr_Lst : Dom.Core.Named_Node_Map;
      J        : Integer:=0;
      Act_Attr : Dom.Core.Node;
      Tr_Ref   : Mast.Timing_Requirements.Timing_Requirement_Ref;
      Ref_Name : Var_Strings.Var_String;
   begin
      Tr_Ref:= new Mast.Timing_Requirements.Global_Max_Miss_Ratio;
      Attr_Lst:=Dom.Core.Nodes.Attributes(Tr_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,J);
         J:=J+1;
         case Timing_Req_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))
         is
            when Ratio=>
               Mast.Timing_Requirements.Set_Ratio
                 (Mast.Timing_Requirements.Global_Max_Miss_Ratio(Tr_Ref.all),
                  Mast.Percentage'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when Deadline=>
               Mast.Timing_Requirements.Set_The_Deadline
                 (Mast.Timing_Requirements.Deadline(Tr_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when Referenced_Event=>
               begin
                  Ref_Name:=Var_Strings.To_Lower
                    (Var_Strings.To_Var_String
                     (Dom.Core.Attrs.Value(Act_Attr)));
                  Mast.Timing_Requirements.Set_Event
                    (Mast.Timing_Requirements.Global_Max_Miss_Ratio
                     (Tr_Ref.all),Mast.Transactions.Find_Any_Event
                     (Ref_Name,Trans_Ref.all));
               exception
                  when Transactions.Event_Not_Found =>
                     declare
                        Evnt_Ref : Events.Event_Ref:=
                          new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,Ref_Name);
                        Mast.Timing_Requirements.Set_Event
                          (Mast.Timing_Requirements.Global_Deadline
                           (Tr_Ref.all),Evnt_Ref);
                     end;
               end;
            when others =>
               Ada.Text_IO.Put_Line("Syntax error in Global Max Miss Ratio");
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      if Comp_Tr_Ref=null
      then
         Mast.Graphs.Links.Set_Link_Timing_Requirements
           (Mast.Graphs.Links.Regular_Link(Link_Ref.all),
            Tr_Ref);
      else
         Mast.Timing_Requirements.Add_Requirement
           (Mast.Timing_Requirements.Composite_Timing_Req(Comp_Tr_Ref.all),
            Mast.Timing_Requirements.Simple_Timing_Requirement_Ref(Tr_Ref));
      end if;
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Global Max Miss Ratio, in Link: "&
            To_String(Graphs.Name(Link_Ref)));
   end Add_Global_Max_Miss_Ratio;

   ------------------------------
   -- Add_Hard_Local_Deadline --
   ------------------------------

   procedure Add_Hard_Local_Deadline
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node : Dom.Core.Node;
      Comp_Tr_Ref: in out Mast.Timing_Requirements.Timing_Requirement_Ref)
   is
      Attr_Lst : Dom.Core.Named_Node_Map;
      J        : Integer:=0;
      Act_Attr : Dom.Core.Node;
      Tr_Ref   : Mast.Timing_Requirements.Timing_Requirement_Ref;
   begin
      Tr_Ref:= new Mast.Timing_Requirements.Hard_Local_Deadline;
      Attr_Lst:=Dom.Core.Nodes.Attributes(Tr_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,J);
         J:=J+1;
         case Timing_Req_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))
         is
            when Deadline=>
               Mast.Timing_Requirements.Set_The_Deadline
                 (Mast.Timing_Requirements.Deadline(Tr_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when others =>
               Ada.Text_IO.Put_Line("Syntax error in Hard Local Deadline");
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      if Comp_Tr_Ref=null
      then
         Mast.Graphs.Links.Set_Link_Timing_Requirements
           (Mast.Graphs.Links.Regular_Link(Link_Ref.all),
            Tr_Ref);
      else
         Mast.Timing_Requirements.Add_Requirement
           (Mast.Timing_Requirements.Composite_Timing_Req(Comp_Tr_Ref.all),
            Mast.Timing_Requirements.Simple_Timing_Requirement_Ref(Tr_Ref));
      end if;
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Hard Local Deadline, in Link: "&
            To_String(Graphs.Name(Link_Ref)));
   end Add_Hard_Local_Deadline;

   ------------------------------
   -- Add_Soft_Local_Deadline --
   ------------------------------

   procedure Add_Soft_Local_Deadline
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node : Dom.Core.Node;
      Comp_Tr_Ref: in out Mast.Timing_Requirements.Timing_Requirement_Ref)
   is
      Attr_Lst : Dom.Core.Named_Node_Map;
      J        : Integer:=0;
      Act_Attr : Dom.Core.Node;
      Tr_Ref   : Mast.Timing_Requirements.Timing_Requirement_Ref;
   begin
      Tr_Ref:= new Mast.Timing_Requirements.Soft_Local_Deadline;
      Attr_Lst:=Dom.Core.Nodes.Attributes(Tr_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,J);
         J:=J+1;
         case Timing_Req_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))
         is
            when Deadline=>
               Mast.Timing_Requirements.Set_The_Deadline
                 (Mast.Timing_Requirements.Deadline(Tr_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when others =>
               Ada.Text_IO.Put_Line("Syntax error in Soft Local Deadline");
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      if Comp_Tr_Ref=null
      then
         Mast.Graphs.Links.Set_Link_Timing_Requirements
           (Mast.Graphs.Links.Regular_Link(Link_Ref.all),
            Tr_Ref);
      else
         Mast.Timing_Requirements.Add_Requirement
           (Mast.Timing_Requirements.Composite_Timing_Req(Comp_Tr_Ref.all),
            Mast.Timing_Requirements.Simple_Timing_Requirement_Ref(Tr_Ref));
      end if;
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Soft Local Deadline, in Link: "&
            To_String(Graphs.Name(Link_Ref)));
   end Add_Soft_Local_Deadline;

   ------------------------------
   -- Add_Local_Max_Miss_Ratio --
   ------------------------------

   procedure Add_Local_Max_Miss_Ratio
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node : Dom.Core.Node;
      Comp_Tr_Ref: in out Mast.Timing_Requirements.Timing_Requirement_Ref)
   is
      Attr_Lst : Dom.Core.Named_Node_Map;
      J        : Integer:=0;
      Act_Attr : Dom.Core.Node;
      Tr_Ref   : Mast.Timing_Requirements.Timing_Requirement_Ref;
   begin
      Tr_Ref:= new Mast.Timing_Requirements.Local_Max_Miss_Ratio;
      Attr_Lst:=Dom.Core.Nodes.Attributes(Tr_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,J);
         J:=J+1;
         case Timing_Req_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))
         is
            when Ratio=>
               Mast.Timing_Requirements.Set_Ratio
                 (Mast.Timing_Requirements.Local_Max_Miss_Ratio(Tr_Ref.all),
                  Mast.Percentage'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when Deadline=>
               Mast.Timing_Requirements.Set_The_Deadline
                 (Mast.Timing_Requirements.Deadline(Tr_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Attr)));
            when others =>
               Ada.Text_IO.Put_Line("Syntax error in Local Max Miss Ratio");
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      if Comp_Tr_Ref=null
      then
         Mast.Graphs.Links.Set_Link_Timing_Requirements
           (Mast.Graphs.Links.Regular_Link(Link_Ref.all),
            Tr_Ref);
      else
         Mast.Timing_Requirements.Add_Requirement
           (Mast.Timing_Requirements.Composite_Timing_Req(Comp_Tr_Ref.all),
            Mast.Timing_Requirements.Simple_Timing_Requirement_Ref(Tr_Ref));
      end if;
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Local Max Miss Ratio, in Link: "&
            To_String(Graphs.Name(Link_Ref)));
   end Add_Local_Max_Miss_Ratio;

   -------------------
   -- Add_Composite --
   -------------------

   procedure Add_Composite
     (Link_Ref :in out Mast.Graphs.Link_Ref;
      Trans_Ref: Mast.Transactions.Transaction_Ref;
      Tr_Node : Dom.Core.Node;
      Comp_Tr_Ref:in out Mast.Timing_Requirements.Timing_Requirement_Ref)
   is
      I       : Integer:=0;
      Ctr_Lst : Dom.Core.Node_List;
      Act_Ctr : Dom.Core.Node;
   begin
      if Comp_Tr_Ref=null
      then
         Comp_Tr_Ref:= new Mast.Timing_Requirements.Composite_Timing_Req;
      end if;
      Ctr_Lst:=Dom.Core.Nodes.Child_Nodes(Tr_Node);
      --Get the Children of the Requirement list there are Text-nodes
      --And Simple_Timing_Requirement nodes.
      while I<Dom.Core.Nodes.Length(Ctr_Lst)
      loop
         Act_Ctr:=Dom.Core.Nodes.Item(Ctr_Lst,I);
         I:=I+1;
         if Dom.Core.Nodes.Local_Name(Act_Ctr)/=""
         then
            Timming_Requirement_Adds
              (Mast_Timming_Requirement_Elements'Value
               (Dom.Core.Nodes.Local_Name(Act_Ctr)))
              (Link_Ref,Trans_Ref,Act_Ctr,Comp_Tr_Ref);
         end if;
      end loop;
      Mast.Graphs.Links.Set_Link_Timing_Requirements
        (Mast.Graphs.Links.Regular_Link(Link_Ref.all),Comp_Tr_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Composite Timing Req, in Link: "&
            To_String(Graphs.Name(Link_Ref)));
   end Add_Composite;

   ------------------
   -- Add_Activity --
   ------------------

   procedure Add_Activity
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node)
   is
      Eh_Ref   :   Mast.Graphs.Event_Handler_Ref;
      Op_Index :   Mast.Operations.Lists.Index;
      Ss_Index :   Mast.Scheduling_Servers.Lists.Index;
      Link_Ref :   Mast.Graphs.Link_Ref;
      IE_Name,
      OE_Name,
      AO_Name,
      AS_Name  : Var_Strings.Var_String;
   begin
      Eh_Ref:= new Mast.Graphs.Event_Handlers.Activity;
      -- Process the Input_Event.
      begin
         IE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Eh_Node,"Input_Event")));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (IE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Output_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Set_Input_Link
           (Mast.Graphs.Event_Handlers.Simple_Event_Handler
            (Eh_Ref.all),Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,IE_Name);
               Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Graphs.Set_Output_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Graphs.Event_Handlers.Set_Input_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(IE_Name)&
               ": Invalid event type for event_handler input, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      -- Process the Output_Event
      begin
         OE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Eh_Node,"Output_Event")));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (OE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Input_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Set_Output_Link
           (Mast.Graphs.Event_Handlers.Simple_Event_Handler
            (Eh_Ref.all),Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,OE_Name);
               Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Graphs.Set_Input_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Graphs.Event_Handlers.Set_Output_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(OE_Name)&
               ": Invalid event type for event_handler output, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      --Process the Operation
      AO_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Eh_Node,"Activity_Operation")));
      Op_Index:=Mast.Operations.Lists.Find
        (AO_Name,Mast_System.Operations);
      if Op_Index=Mast.Operations.Lists.Null_Index
      then
         declare
            Op_Ref : Operations.Operation_Ref:=
              new Operations.Simple_Operation;
         begin
            Operations.Init(Op_Ref.all,AO_Name);
            Graphs.Event_Handlers.Set_Activity_Operation
              (Graphs.Event_Handlers.Activity(EH_Ref.all),Op_Ref);
         end;
      else
         Mast.Graphs.Event_Handlers.Set_Activity_Operation
           (Mast.Graphs.Event_Handlers.Activity(Eh_Ref.all),
            Mast.Operations.Lists.Item(Op_Index,Mast_System.Operations));
      end if;
      --Process the Activity_Server
      AS_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Eh_Node,"Activity_Server")));
      Ss_Index:=Mast.Scheduling_Servers.Lists.Find
        (AS_Name,Mast_System.Scheduling_Servers);
      if Ss_Index=Mast.Scheduling_Servers.Lists.Null_Index then
         declare
            Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref:=
              new Scheduling_Servers.Scheduling_Server;
         begin
            Scheduling_Servers.Init(Srvr_Ref.all,AS_Name);
            Graphs.Event_Handlers.Set_Activity_Server
              (Mast.Graphs.Event_Handlers.Activity(EH_Ref.all),Srvr_Ref);
         end;
      else
         Mast.Graphs.Event_Handlers.Set_Activity_Server
           (Mast.Graphs.Event_Handlers.Activity(Eh_Ref.all),
            Mast.Scheduling_Servers.Lists.Item
            (Ss_Index,Mast_System.Scheduling_Servers));
      end if;
      -- Add the event_handler structure to the transaction structure.
      Mast.Transactions.Add_Event_Handler(Trans_Ref.all,Eh_Ref);
   end Add_Activity;

   -------------------------------
   -- Add_System_Timed_Activity --
   -------------------------------

   procedure Add_System_Timed_Activity
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node)
   is
      Eh_Ref   : Mast.Graphs.Event_Handler_Ref;
      Link_Ref : Mast.Graphs.Link_Ref;
      Op_Index : Mast.Operations.Lists.Index;
      Ss_Index : Mast.Scheduling_Servers.Lists.Index;
      IE_Name,
      OE_Name,
      AO_Name,
      AS_Name  : Var_Strings.Var_String;
   begin
      Eh_Ref:= new Mast.Graphs.Event_Handlers.System_Timed_Activity;
      -- Process the Input_Event.
      begin
         IE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Eh_Node,"Input_Event")));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (IE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Output_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Set_Input_Link
           (Mast.Graphs.Event_Handlers.Simple_Event_Handler
            (Eh_Ref.all),Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,IE_Name);
               Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Graphs.Set_Output_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Graphs.Event_Handlers.Set_Input_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(IE_Name)&
               ": Invalid event type for event_handler input, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      -- Process the Output_Event
      begin
         OE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Eh_Node,"Output_Event")));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (OE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Input_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Set_Output_Link
           (Mast.Graphs.Event_Handlers.Simple_Event_Handler
            (Eh_Ref.all),Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,OE_Name);
               Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Graphs.Set_Input_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Graphs.Event_Handlers.Set_Output_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(OE_Name)&
               ": Invalid event type for event_handler output, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      --Process the Operation
      AO_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Eh_Node,"Activity_Operation")));
      Op_Index:=Mast.Operations.Lists.Find
        (AO_Name, Mast_System.Operations);
      if Op_Index=Mast.Operations.Lists.Null_Index
      then
         declare
            Op_Ref : Operations.Operation_Ref:=
              new Operations.Simple_Operation;
         begin
            Operations.Init(Op_Ref.all,AO_Name);
            Graphs.Event_Handlers.Set_Activity_Operation
              (Graphs.Event_Handlers.Activity(EH_Ref.all),Op_Ref);
         end;
      else
         Mast.Graphs.Event_Handlers.Set_Activity_Operation
           (Mast.Graphs.Event_Handlers.Activity(Eh_Ref.all),
            Mast.Operations.Lists.Item(Op_Index,Mast_System.Operations));
      end if;
      --Process the Activity_Server
      AS_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Eh_Node,"Activity_Server")));
      Ss_Index:=Mast.Scheduling_Servers.Lists.Find
        (AS_Name,Mast_System.Scheduling_Servers);
      if Ss_Index=Mast.Scheduling_Servers.Lists.Null_Index then
         declare
            Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref:=
              new Scheduling_Servers.Scheduling_Server;
         begin
            Scheduling_Servers.Init(Srvr_Ref.all,AS_Name);
            Graphs.Event_Handlers.Set_Activity_Server
              (Mast.Graphs.Event_Handlers.Activity(EH_Ref.all),Srvr_Ref);
         end;
      else
         Mast.Graphs.Event_Handlers.Set_Activity_Server
           (Mast.Graphs.Event_Handlers.Activity(Eh_Ref.all),
            Mast.Scheduling_Servers.Lists.Item
            (Ss_Index,Mast_System.Scheduling_Servers));
      end if;
      -- Add the event_handler structure to the transaction structure.
      Mast.Transactions.Add_Event_Handler(Trans_Ref.all,Eh_Ref);
   end Add_System_Timed_Activity;

   ----------------------
   -- Add_Concentrator --
   ----------------------

   procedure Add_Concentrator
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node)
   is
      Eh_Ref   : Mast.Graphs.Event_Handler_Ref;
      Link_Ref : Mast.Graphs.Link_Ref;
      Attr     : Ada.Strings.Unbounded.Unbounded_String;
      I,J      : Integer:=1;
      IE_Name,
      OE_Name  : Var_Strings.Var_String;
   begin
      Eh_Ref:= new Mast.Graphs.Event_Handlers.Concentrator;
      -- Process the Input_Event_List
      Attr:=Ada.Strings.Unbounded.To_Unbounded_String
        (Dom.Core.Elements.Get_Attribute(Eh_Node,"Input_Events_List"));
      -- Get the Atttibute String.
      while I<Length(Attr)
      loop
         if Ada.Strings.Unbounded.Element(Attr,I)=' '
         then
            -- Get and process one by one the input events
            -- that are separated by whitespaces.
            begin
               IE_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Ada.Strings.Unbounded.Slice(Attr,J,I-1)));
               Link_Ref:=Mast.Transactions.Find_Any_Link
                 (IE_Name,Trans_Ref.all);
               Mast.Graphs.Set_Output_Event_Handler
                 (Link_Ref.all, Eh_Ref);
               Mast.Graphs.Event_Handlers.Add_Input_Link
                 (Mast.Graphs.Event_Handlers.Input_Event_Handler
                  (Eh_Ref.all),Link_Ref);
            exception
               when Mast.Transactions.Link_Not_Found =>
                  declare
                     Lnk_Ref : Graphs.Link_Ref:=
                       new Graphs.Links.Regular_Link;
                     Evnt_Ref : Events.Event_Ref:=
                       new Events.Internal_Event;
                  begin
                     Events.Init(Evnt_Ref.all,IE_Name);
                     Mast.Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                     Mast.Graphs.Set_Output_Event_Handler
                       (Lnk_Ref.all, EH_Ref);
                     Mast.Graphs.Event_Handlers.Add_Input_Link
                       (Mast.Graphs.Event_Handlers.Input_Event_Handler
                        (EH_Ref.all),Lnk_Ref);
                  end;
               when Mast.Graphs.Invalid_Link_Type =>
                  Mast_XML_Exceptions.Parser_Error
                    (To_String(IE_Name)&
                     ": Invalid event type for event_handler input, "&
                     "in transaction: "&
                     To_String(Transactions.Name(Trans_Ref)));
            end;
            J:=I+1;
         end if;
         I:=I+1;
      end loop;
      begin
         IE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String(Ada.Strings.Unbounded.Slice(Attr,J,I)));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (IE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Output_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Add_Input_Link
           (Mast.Graphs.Event_Handlers.Input_Event_Handler
            (Eh_Ref.all), Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,IE_Name);
               Mast.Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Mast.Graphs.Set_Output_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Mast.Graphs.Event_Handlers.Add_Input_Link
                 (Mast.Graphs.Event_Handlers.Input_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(IE_Name)&
               ": Invalid event type for event_handler input, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      --Process the Output_Event
      begin
         OE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Eh_Node,"Output_Event")));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (OE_Name, Trans_Ref.all);
         Mast.Graphs.Set_Input_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Set_Output_Link
           (MAst.Graphs.Event_Handlers.Input_Event_Handler
            (Eh_Ref.all),Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,OE_Name);
               Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Graphs.Set_Input_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Graphs.Event_Handlers.Set_Output_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(OE_Name)&
               ": Invalid event type for event_handler output, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      -- Add the event_handler structure to the transaction structure.
      Mast.Transactions.Add_Event_Handler(Trans_Ref.all,Eh_Ref);
   end Add_Concentrator;

   -----------------
   -- Add_Barrier --
   -----------------

   procedure Add_Barrier
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node)
   is
      Eh_Ref   : Mast.Graphs.Event_Handler_Ref;
      Link_Ref : Mast.Graphs.Link_Ref;
      Attr     : Ada.Strings.Unbounded.Unbounded_String;
      I,J      : Integer:=1;
      IE_Name,
      OE_Name  : Var_Strings.Var_String;
   begin
      Eh_Ref:= new Mast.Graphs.Event_Handlers.Barrier;
      -- Process the Input_Event_List
      Attr:=Ada.Strings.Unbounded.To_Unbounded_String
        (Dom.Core.Elements.Get_Attribute(Eh_Node,"Input_Events_List"));
      -- Get the Atttibute String.
      while I<Length(Attr)
      loop
         -- Get and process one by one the input events
         -- that are separated by whitespaces.
         if Ada.Strings.Unbounded.Element(Attr,I)=' '
         then
            begin
               IE_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Ada.Strings.Unbounded.Slice(Attr,J,I-1)));
               Link_Ref:=Mast.Transactions.Find_Any_Link
                 (IE_Name, Trans_Ref.all);
               Mast.Graphs.Set_Output_Event_Handler
                 (Link_Ref.all, Eh_Ref);
               Mast.Graphs.Event_Handlers.Add_Input_Link
                 (Mast.Graphs.Event_Handlers.Input_Event_Handler
                  (Eh_Ref.all), Link_Ref);
            exception
               when Mast.Transactions.Link_Not_Found =>
                  declare
                     Lnk_Ref : Graphs.Link_Ref:=
                       new Graphs.Links.Regular_Link;
                     Evnt_Ref : Events.Event_Ref:=
                       new Events.Internal_Event;
                  begin
                     Events.Init(Evnt_Ref.all,IE_Name);
                     Mast.Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                     Mast.Graphs.Set_Output_Event_Handler
                       (Lnk_Ref.all, EH_Ref);
                     Mast.Graphs.Event_Handlers.Add_Input_Link
                       (Mast.Graphs.Event_Handlers.Input_Event_Handler
                        (EH_Ref.all),Lnk_Ref);
                  end;
               when Mast.Graphs.Invalid_Link_Type =>
                  Mast_XML_Exceptions.Parser_Error
                    (To_String(IE_Name)&
                     ": Invalid event type for event_handler input, "&
                     "in transaction: "&
                     To_String(Transactions.Name(Trans_Ref)));
            end;
            J:=I+1;
         end if;
         I:=I+1;
      end loop;
      begin
         IE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Ada.Strings.Unbounded.Slice(Attr,J,I)));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (IE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Output_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Add_Input_Link
           (Mast.Graphs.Event_Handlers.Input_Event_Handler
            (Eh_Ref.all), Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,IE_Name);
               Mast.Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Mast.Graphs.Set_Output_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Mast.Graphs.Event_Handlers.Add_Input_Link
                 (Mast.Graphs.Event_Handlers.Input_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(IE_Name)&
               ": Invalid event type for event_handler input, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      --Process: Output_Event
      begin
         OE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Eh_Node,"Output_Event")));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (OE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Input_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Set_Output_Link
           (MAst.Graphs.Event_Handlers.Input_Event_Handler
            (Eh_Ref.all), Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,OE_Name);
               Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Graphs.Set_Input_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Graphs.Event_Handlers.Set_Output_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(OE_Name)&
               ": Invalid event type for event_handler output, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      -- Add the event_handler structure to the transaction structure.
      Mast.Transactions.Add_Event_Handler(Trans_Ref.all,Eh_Ref);
   end Add_Barrier;

   -------------------------
   -- Add_Delivery_Server --
   -------------------------

   procedure Add_Delivery_Server
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node)
   is
      Eh_Ref   : Mast.Graphs.Event_Handler_Ref;
      Link_Ref : Mast.Graphs.Link_Ref;
      Attr     : Ada.Strings.Unbounded.Unbounded_String;
      I,J      : Integer:=1;
      IE_Name,
      OE_Name  : Var_Strings.Var_String;
   begin
      Eh_Ref:= new Mast.Graphs.Event_Handlers.Delivery_Server;
      --Process the Delivery_Server:
      --Process the Input_Event
      begin
         IE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Eh_Node,"Input_Event")));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (IE_Name, Trans_Ref.all);
         Mast.Graphs.Set_Output_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Set_Input_Link
           (Mast.Graphs.Event_Handlers.Output_Event_Handler
            (Eh_Ref.all), Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,IE_Name);
               Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Graphs.Set_Output_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Graphs.Event_Handlers.Set_Input_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(IE_Name)&
               ": Invalid event type for event_handler input, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      --Process the Output_Event_List
      Attr:=Ada.Strings.Unbounded.To_Unbounded_String
        (Dom.Core.Elements.Get_Attribute(Eh_Node,"Output_Events_List"));
      while I<Length(Attr)
      loop
         -- Get and process one by one the input events
         -- that are separated by whitespaces.
         if Ada.Strings.Unbounded.Element(Attr,I)=' '
         then
            begin
               OE_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Ada.Strings.Unbounded.Slice(Attr,J,I-1)));
               Link_Ref:=Mast.Transactions.Find_Any_Link
                 (OE_Name,Trans_Ref.all);
               Mast.Graphs.Set_Input_Event_Handler
                 (Link_Ref.all, Eh_Ref);
               Mast.Graphs.Event_Handlers.Add_Output_Link
                 (Mast.Graphs.Event_Handlers.Output_Event_Handler
                  (Eh_Ref.all), Link_Ref);
            exception
               when Mast.Transactions.Link_Not_Found =>
                  declare
                     Lnk_Ref : Graphs.Link_Ref:=
                       new Graphs.Links.Regular_Link;
                     Evnt_Ref : Events.Event_Ref:=
                       new Events.Internal_Event;
                  begin
                     Events.Init(Evnt_Ref.all,OE_Name);
                     Mast.Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                     Mast.Graphs.Set_Input_Event_Handler
                       (Lnk_Ref.all, EH_Ref);
                     Mast.Graphs.Event_Handlers.Add_Output_Link
                       (Mast.Graphs.Event_Handlers.Output_Event_Handler
                        (EH_Ref.all),Lnk_Ref);
                  end;
               when Mast.Graphs.Invalid_Link_Type =>
                  Mast_XML_Exceptions.Parser_Error
                    (To_String(OE_Name)&
                     ": Invalid event type for event_handler output, "&
                     "in transaction: "&
                     To_String(Transactions.Name(Trans_Ref)));
            end;
            J:=I+1;
         end if;
         I:=I+1;
      end loop;
      begin
         OE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String(Ada.Strings.Unbounded.Slice(Attr,J,I)));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (OE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Input_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Add_Output_Link
           (Mast.Graphs.Event_Handlers.Output_Event_Handler
            (Eh_Ref.all), Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,OE_Name);
               Mast.Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Mast.Graphs.Set_Input_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Mast.Graphs.Event_Handlers.Add_Output_Link
                 (Mast.Graphs.Event_Handlers.Output_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(OE_Name)&
               ": Invalid event type for event_handler output, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      --Process the Delivery_Policy
      Mast.Graphs.Event_Handlers.Set_Policy
        (Mast.Graphs.Event_Handlers.Delivery_Server(Eh_Ref.all),
         Mast.Delivery_Policy'Value(Dom.Core.Elements.Get_Attribute
                                    (Eh_Node,"Delivery_Policy")));
      -- Add the event_handler structure to the transaction structure.
      Mast.Transactions.Add_Event_Handler(Trans_Ref.all,Eh_Ref);
   end Add_Delivery_Server;

   ----------------------
   -- Add_Query_Server --
   ----------------------

   procedure Add_Query_Server
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node)
   is
      Eh_Ref   : Mast.Graphs.Event_Handler_Ref;
      Link_Ref : Mast.Graphs.Link_Ref;
      Attr     : Ada.Strings.Unbounded.Unbounded_String;
      I,J      : Integer:=1;
      IE_Name,
      OE_Name  : Var_Strings.Var_String;
   begin
      Eh_Ref:= new Mast.Graphs.Event_Handlers.Query_Server;
      -- Process the Add_Query_Server:
      --Process the Input_Event
      begin
         IE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Eh_Node,"Input_Event")));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (IE_Name, Trans_Ref.all);
         Mast.Graphs.Set_Output_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Set_Input_Link
           (Mast.Graphs.Event_Handlers.Output_Event_Handler
            (Eh_Ref.all), Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,IE_Name);
               Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Graphs.Set_Output_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Graphs.Event_Handlers.Set_Input_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(IE_Name)&
               ": Invalid event type for event_handler input, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      --Process the Output_Event_List
      Attr:=Ada.Strings.Unbounded.To_Unbounded_String
        (Dom.Core.Elements.Get_Attribute(Eh_Node,"Output_Events_List"));
      while I<Length(Attr)
      loop
         -- Get and process one by one the input events
         -- that are separated by whitespaces.
         if Ada.Strings.Unbounded.Element(Attr,I)=' '
         then
            begin
               OE_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Ada.Strings.Unbounded.Slice(Attr,J,I-1)));
               Link_Ref:=Mast.Transactions.Find_Any_Link
                 (OE_Name, Trans_Ref.all);
               Mast.Graphs.Set_Input_Event_Handler
                 (Link_Ref.all, Eh_Ref);
               Mast.Graphs.Event_Handlers.Add_Output_Link
                 (Mast.Graphs.Event_Handlers.Output_Event_Handler
                  (Eh_Ref.all), Link_Ref);
            exception
               when Mast.Transactions.Link_Not_Found =>
                  declare
                     Lnk_Ref : Graphs.Link_Ref:=
                       new Graphs.Links.Regular_Link;
                     Evnt_Ref : Events.Event_Ref:=
                       new Events.Internal_Event;
                  begin
                     Events.Init(Evnt_Ref.all,OE_Name);
                     Mast.Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                     Mast.Graphs.Set_Input_Event_Handler
                       (Lnk_Ref.all, EH_Ref);
                     Mast.Graphs.Event_Handlers.Add_Output_Link
                       (Mast.Graphs.Event_Handlers.Output_Event_Handler
                        (EH_Ref.all),Lnk_Ref);
                  end;
               when Mast.Graphs.Invalid_Link_Type =>
                  Mast_XML_Exceptions.Parser_Error
                    (To_String(OE_Name)&
                     ": Invalid event type for event_handler output, "&
                     "in transaction: "&
                     To_String(Transactions.Name(Trans_Ref)));
            end;
            J:=I+1;
         end if;
         I:=I+1;
      end loop;
      begin
         OE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String(Ada.Strings.Unbounded.Slice(Attr,J,I)));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (OE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Input_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Add_Output_Link
           (Mast.Graphs.Event_Handlers.Output_Event_Handler
            (Eh_Ref.all), Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,OE_Name);
               Mast.Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Mast.Graphs.Set_Input_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Mast.Graphs.Event_Handlers.Add_Output_Link
                 (Mast.Graphs.Event_Handlers.Output_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(OE_Name)&
               ": Invalid event type for event_handler output, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      -- Process the Request_Policy
      Mast.Graphs.Event_Handlers.Set_Policy
        (Mast.Graphs.Event_Handlers.Query_Server(Eh_Ref.all),
         Mast.Request_Policy'Value
         (Dom.Core.Elements.Get_Attribute(Eh_Node,"Request_Policy")));
      -- Add the event_handler structure to the transaction structure.
      Mast.Transactions.Add_Event_Handler(Trans_Ref.all,Eh_Ref);
   end Add_Query_Server;

   -------------------
   -- Add_Multicast --
   -------------------

   procedure Add_Multicast
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node)
   is
      Eh_Ref   : Mast.Graphs.Event_Handler_Ref;
      Link_Ref : Mast.Graphs.Link_Ref;
      Attr     : Ada.Strings.Unbounded.Unbounded_String;
      I,J      : Integer:=1;
      IE_Name,
      OE_Name  : Var_Strings.Var_String;
   begin
      Eh_Ref:= new Mast.Graphs.Event_Handlers.Multicast;
      -- Process the Input_Event
      begin
         IE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Eh_Node,"Input_Event")));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (IE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Output_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Set_Input_Link
           (Mast.Graphs.Event_Handlers.Output_Event_Handler
            (Eh_Ref.all), Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,IE_Name);
               Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Graphs.Set_Output_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Graphs.Event_Handlers.Set_Input_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(IE_Name)&
               ": Invalid event type for event_handler input, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      --Processs the Output_Event_List
      Attr:=Ada.Strings.Unbounded.To_Unbounded_String
        (Dom.Core.Elements.Get_Attribute(Eh_Node,"Output_Events_List"));
      while I<Length(Attr)
      loop
         -- Get and process one by one the input events
         -- that are separated by whitespaces.
         if Ada.Strings.Unbounded.Element(Attr,I)=' '
         then
            begin
               OE_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Ada.Strings.Unbounded.Slice(Attr,J,I-1)));
               Link_Ref:=Mast.Transactions.Find_Any_Link
                 (OE_Name,Trans_Ref.all);
               Mast.Graphs.Set_Input_Event_Handler
                 (Link_Ref.all, Eh_Ref);
               Mast.Graphs.Event_Handlers.Add_Output_Link
                 (Mast.Graphs.Event_Handlers.Output_Event_Handler
                  (Eh_Ref.all), Link_Ref);
            exception
               when Mast.Transactions.Link_Not_Found =>
                  declare
                     Lnk_Ref : Graphs.Link_Ref:=
                       new Graphs.Links.Regular_Link;
                     Evnt_Ref : Events.Event_Ref:=
                       new Events.Internal_Event;
                  begin
                     Events.Init(Evnt_Ref.all,OE_Name);
                     Mast.Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                     Mast.Graphs.Set_Input_Event_Handler
                       (Lnk_Ref.all, EH_Ref);
                     Mast.Graphs.Event_Handlers.Add_Output_Link
                       (Mast.Graphs.Event_Handlers.Output_Event_Handler
                        (EH_Ref.all),Lnk_Ref);
                  end;
               when Mast.Graphs.Invalid_Link_Type =>
                  Mast_XML_Exceptions.Parser_Error
                    (To_String(OE_Name)&
                     ": Invalid event type for event_handler output, "&
                     "in transaction: "&
                     To_String(Transactions.Name(Trans_Ref)));
            end;
            J:=I+1;
         end if;
         I:=I+1;
      end loop;
      begin
         OE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String(Ada.Strings.Unbounded.Slice(Attr,J,I)));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (OE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Input_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Add_Output_Link
           (Mast.Graphs.Event_Handlers.Output_Event_Handler
            (Eh_Ref.all), Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,OE_Name);
               Mast.Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Mast.Graphs.Set_Input_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Mast.Graphs.Event_Handlers.Add_Output_Link
                 (Mast.Graphs.Event_Handlers.Output_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(OE_Name)&
               ": Invalid event type for event_handler output, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      -- Add the event_handler structure to the transaction structure.
      Mast.Transactions.Add_Event_Handler(Trans_Ref.all,Eh_Ref);
   end Add_Multicast;

   ----------------------
   -- Add_Rate_Divisor --
   ----------------------

   procedure Add_Rate_Divisor
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node)
   is
      Eh_Ref   : Mast.Graphs.Event_Handler_Ref;
      Link_Ref : Mast.Graphs.Link_Ref;
      IE_Name,
      OE_Name  : Var_Strings.Var_String;
   begin
      Eh_Ref:= new Mast.Graphs.Event_Handlers.Rate_Divisor;
      -- Process the Input_Event:
      begin
         IE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Eh_Node,"Input_Event")));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (IE_Name, Trans_Ref.all);
         Mast.Graphs.Set_Output_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Set_Input_Link
           (Mast.Graphs.Event_Handlers.Simple_Event_Handler
            (Eh_Ref.all), Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,IE_Name);
               Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Graphs.Set_Output_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Graphs.Event_Handlers.Set_Input_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(IE_Name)&
               ": Invalid event type for event_handler input, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      -- Process the Output_Event
      begin
         OE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Eh_Node,"Output_Event")));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (OE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Input_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Set_Output_Link
           (Mast.Graphs.Event_Handlers.Simple_Event_Handler
            (Eh_Ref.all), Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,OE_Name);
               Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Graphs.Set_Input_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Graphs.Event_Handlers.Set_Output_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(OE_Name)&
               ": Invalid event type for event_handler output, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      -- Process the Rate_Factor
      Mast.Graphs.Event_Handlers.Set_Rate_Factor
        (Mast.Graphs.Event_Handlers.Rate_Divisor(Eh_Ref.all),
         Integer'Value
         (Dom.Core.Elements.Get_Attribute(Eh_Node,"Rate_Factor")));
      -- Add the event_handler structure to the transaction structure.
      Mast.Transactions.Add_Event_Handler(Trans_Ref.all,Eh_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Rate Divisor Event Handler with input event "&
            To_String(IE_Name)&", in Transaction: "&
            To_String(Transactions.Name(Trans_Ref)));
   end Add_Rate_Divisor;

   ---------------
   -- Add_Delay --
   ---------------

   procedure Add_Delay
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node)
   is
      Eh_Ref   : Mast.Graphs.Event_Handler_Ref;
      Link_Ref : Mast.Graphs.Link_Ref;
      IE_Name,
      OE_Name  : Var_Strings.Var_String;
   begin
      Eh_Ref:= new Mast.Graphs.Event_Handlers.Delay_Event_Handler;
      --Process the Input_Event
      begin
         IE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Eh_Node,"Input_Event")));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (IE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Output_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Set_Input_Link
           (Mast.Graphs.Event_Handlers.Simple_Event_Handler
            (Eh_Ref.all), Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,IE_Name);
               Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Graphs.Set_Output_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Graphs.Event_Handlers.Set_Input_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(IE_Name)&
               ": Invalid event type for event_handler input, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      --Process the Output_Event
      begin
         OE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Eh_Node,"Output_Event")));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (OE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Input_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Set_Output_Link
           (Mast.Graphs.Event_Handlers.Simple_Event_Handler
            (Eh_Ref.all), Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,OE_Name);
               Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Graphs.Set_Input_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Graphs.Event_Handlers.Set_Output_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(OE_Name)&
               ": Invalid event type for event_handler output, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      -- Process the Max_Interval
      Mast.Graphs.Event_Handlers.Set_Delay_Max_Interval
        (Mast.Graphs.Event_Handlers.Delay_Event_Handler(Eh_Ref.all),
         Mast.Time'Value
         (Dom.Core.Elements.Get_Attribute(Eh_Node,"Delay_Max_Interval")));
      -- Process the Min_Interval
      Mast.Graphs.Event_Handlers.Set_Delay_Min_Interval
        (Mast.Graphs.Event_Handlers.Delay_Event_Handler(Eh_Ref.all),
         Mast.Time'Value
         (Dom.Core.Elements.Get_Attribute(Eh_Node,"Delay_Min_Interval")));
      -- Add the event_handler structure to the transaction structure.
      Mast.Transactions.Add_Event_Handler(Trans_Ref.all,Eh_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Delay Event Handler with input event "&
            To_String(IE_Name)&", in Transaction: "&
            To_String(Transactions.Name(Trans_Ref)));
   end Add_Delay;

   ----------------
   -- Add_Offset --
   ----------------

   procedure Add_Offset
     (Mast_System: in out Mast.Systems.System;
      Trans_Ref :in out Mast.Transactions.Transaction_Ref;
      Eh_Node : Dom.Core.Node)
   is
      Eh_Ref   : Mast.Graphs.Event_Handler_Ref;
      Link_Ref : Mast.Graphs.Link_Ref;
      IE_Name,
      OE_Name,
      EE_Name  : Var_Strings.Var_String;
   begin
      Eh_Ref:= new Mast.Graphs.Event_Handlers.Offset_Event_Handler;
      -- Process the Input_Event
      begin
         IE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Eh_Node,"Input_Event")));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (IE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Output_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Set_Input_Link
           (Mast.Graphs.Event_Handlers.Simple_Event_Handler
            (Eh_Ref.all), Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,IE_Name);
               Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Graphs.Set_Output_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Graphs.Event_Handlers.Set_Input_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(IE_Name)&
               ": Invalid event type for event_handler input, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      --Process the Output_Event
      begin
         OE_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Eh_Node,"Output_Event")));
         Link_Ref:=Mast.Transactions.Find_Any_Link
           (OE_Name,Trans_Ref.all);
         Mast.Graphs.Set_Input_Event_Handler
           (Link_Ref.all, Eh_Ref);
         Mast.Graphs.Event_Handlers.Set_Output_Link
           (Mast.Graphs.Event_Handlers.Simple_Event_Handler
            (Eh_Ref.all), Link_Ref);
      exception
         when Mast.Transactions.Link_Not_Found =>
            declare
               Lnk_Ref : Graphs.Link_Ref:=
                 new Graphs.Links.Regular_Link;
               Evnt_Ref : Events.Event_Ref:=
                 new Events.Internal_Event;
            begin
               Events.Init(Evnt_Ref.all,OE_Name);
               Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
               Graphs.Set_Input_Event_Handler
                 (Lnk_Ref.all, EH_Ref);
               Graphs.Event_Handlers.Set_Output_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler
                  (EH_Ref.all),Lnk_Ref);
            end;
         when Mast.Graphs.Invalid_Link_Type =>
            Mast_XML_Exceptions.Parser_Error
              (To_String(OE_Name)&
               ": Invalid event type for event_handler output, "&
               "in transaction: "&
               To_String(Transactions.Name(Trans_Ref)));
      end;
      -- Process the Max_Interval
      Mast.Graphs.Event_Handlers.Set_Delay_Max_Interval
        (Mast.Graphs.Event_Handlers.Delay_Event_Handler(Eh_Ref.all),
         Mast.Time'Value
         (Dom.Core.Elements.Get_Attribute(Eh_Node,"Delay_Max_Interval")));
      -- Process the Min_Interval
      Mast.Graphs.Event_Handlers.Set_Delay_Min_Interval
        (Mast.Graphs.Event_Handlers.Delay_Event_Handler(Eh_Ref.all),
         Mast.Time'Value
         (Dom.Core.Elements.Get_Attribute(Eh_Node,"Delay_Min_Interval")));
      -- Process the Referenced_Event
      EE_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Eh_Node,"Referenced_Event")));
      Mast.Graphs.Event_Handlers.Set_Referenced_Event
        (Mast.Graphs.Event_Handlers.Offset_Event_Handler(Eh_Ref.all),
         Mast.Transactions.Find_Any_Event(EE_Name,Trans_Ref.all));
      -- Add the event_handler structure to the transaction structure.
      Mast.Transactions.Add_Event_Handler(Trans_Ref.all,Eh_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Offset Event Handler with input event "&
            To_String(IE_Name)&", in Transaction: "&
            To_String(Transactions.Name(Trans_Ref)));
   end Add_Offset;

   -- Add procedures for Scheduling Servers

   -----------------------------------
   -- Add_Regular_Scheduling_Server --
   -----------------------------------

   procedure Add_Regular_Scheduling_Server
     (Mast_System: in out Mast.Systems.System;
      Rss_Node : Dom.Core.Node)
   is
      Ss_Ref   : Mast.Scheduling_Servers.Scheduling_Server_Ref;
      S_Index  : Mast.Schedulers.Lists.Index;
      Act_Ssp  :Dom.Core.Node;
      Ssp_List : Dom.Core.Node_List;
      I        : Integer:=0;
      A_Name,
      Sch_Name : Var_Strings.Var_String;
   begin
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Rss_Node,"Name")));
      Check_Identifier(A_Name);
      Ss_Ref:= new Mast.Scheduling_Servers.Scheduling_Server;
      Mast.Scheduling_Servers.Init
        (Ss_Ref.all,A_Name);
      Mast.Scheduling_Servers.Lists.Add
        (Ss_Ref,Mast_System.Scheduling_Servers);
      Sch_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Rss_Node,"Scheduler")));
      S_Index:=Mast.Schedulers.Lists.Find
        (Sch_Name,Mast_System.Schedulers);
      if S_Index=Mast.Schedulers.Lists.Null_Index
      then
         declare
            Sched_Ref : Mast.Schedulers.Scheduler_Ref;
         begin
            Sched_Ref:= new Mast.Schedulers.Secondary.Secondary_Scheduler;
            Mast.Schedulers.Init
              (Mast.Schedulers.Scheduler(Sched_Ref.all),Sch_Name);
            Mast.Scheduling_Servers.Set_Server_Scheduler
              (Ss_Ref.all,Sched_Ref);
         end;
      else
         Mast.Scheduling_Servers.Set_Server_Scheduler
           (Ss_Ref.all,
            Mast.Schedulers.Lists.Item(S_Index,Mast_System.Schedulers));
      end if;
      Ssp_List:=Dom.Core.Nodes.Child_Nodes(Rss_Node);
      while I<Dom.Core.Nodes.Length(Ssp_List)
      loop
         Act_Ssp:=Dom.Core.Nodes.Item(Ssp_List,I);
         I:=I+1;
         if Dom.Core.Nodes.Local_Name(Act_Ssp)/=""
         then
            Scheduling_Server_Adds
              (Mast_Scheduling_Server_Policy_Elements'Value
               (Dom.Core.Nodes.Local_Name(Act_Ssp)))
              (Mast.Scheduling_Servers.Scheduling_Server_Ref(Ss_Ref),Act_Ssp);
         end if;
      end loop;
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("Sheduling Server already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Scheduling Server: "&To_String(A_Name));
   end Add_Regular_Scheduling_Server;

   -----------------------------------
   -- Add_Non_Preemptible_FP_Policy --
   -----------------------------------

   procedure Add_Non_Preemptible_FP_Policy
     (Sched_Serv_Ref :in out Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Npfp_Node : Dom.Core.Node)
   is
      Sp_Ref  : Mast.Scheduling_Parameters.Sched_Parameters_Ref;
      Att_Lst : Dom.Core.Named_Node_Map;
      J       : Integer:=0;
      Act_Att : Dom.Core.Node;
   begin
      Sp_Ref:=new Mast.Scheduling_Parameters.Non_Preemptible_FP_Policy;
      Att_Lst:=Dom.Core.Nodes.Attributes(Npfp_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Att_Lst)
      loop
         Act_Att:=Dom.Core.Nodes.Item(Att_Lst,J);
         J:=J+1;
         case Sched_Par'Value(Dom.Core.Attrs.Name(Act_Att))is
            when The_Priority =>
               Mast.Scheduling_Parameters.Set_The_Priority
                 (Mast.Scheduling_Parameters.Fixed_Priority_Parameters
                  (Sp_Ref.all),
                  Mast.Priority'Value(Dom.Core.Attrs.Value(Act_Att)));
            when Preassigned =>
               Mast.Scheduling_Parameters.Set_Preassigned
                 (Mast.Scheduling_Parameters.Fixed_Priority_Parameters
                  (Sp_Ref.all),
                  To_Boolean(Dom.Core.Attrs.Value(Act_Att)));
            when others=>
               Mast_XML_Exceptions.Parser_Error
                 ("Syntax error in Non_Preemptible_FP_Policy, "&
                  "in scheduling server: "&
                  To_String(Scheduling_Servers.Name(Sched_Serv_Ref)));
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      Mast.Scheduling_Servers.Set_Server_Sched_Parameters
        (Sched_Serv_Ref.all,Sp_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Non_Preemptible_FP_Policy, "&
            "in scheduling server: "&
            To_String(Scheduling_Servers.Name(Sched_Serv_Ref)));
   end Add_Non_Preemptible_FP_Policy;

   -------------------------------
   -- Add_Fixed_Priority_Policy --
   -------------------------------

   procedure Add_Fixed_Priority_Policy
     (Sched_Serv_Ref :in out Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Fpp_Node : Dom.Core.Node)
   is
      Sp_Ref  : Mast.Scheduling_Parameters.Sched_Parameters_Ref;
      Att_Lst : Dom.Core.Named_Node_Map;
      J       : Integer:=0;
      Act_Att : Dom.Core.Node;
   begin
      Sp_Ref:=new Mast.Scheduling_Parameters.Fixed_Priority_Policy;
      Att_Lst:=Dom.Core.Nodes.Attributes(Fpp_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Att_Lst)
      loop
         Act_Att:=Dom.Core.Nodes.Item(Att_Lst,J);
         J:=J+1;
         case Sched_Par'Value(Dom.Core.Attrs.Name(Act_Att))is
            when The_Priority =>
               Mast.Scheduling_Parameters.Set_The_Priority
                 (Mast.Scheduling_Parameters.Fixed_Priority_Parameters
                  (Sp_Ref.all),
                  Mast.Priority'Value(Dom.Core.Attrs.Value(Act_Att)));
            when Preassigned =>
               Mast.Scheduling_Parameters.Set_Preassigned
                 (Mast.Scheduling_Parameters.Fixed_Priority_Parameters
                  (Sp_Ref.all),
                  To_Boolean(Dom.Core.Attrs.Value(Act_Att)));

            when others=>
               Mast_XML_Exceptions.Parser_Error
                 ("Syntax error in Fixed_Priority_Policy, "&
                  "in scheduling server: "&
                  To_String(Scheduling_Servers.Name(Sched_Serv_Ref)));
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      Mast.Scheduling_Servers.Set_Server_Sched_Parameters
        (Sched_Serv_Ref.all,Sp_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Fixed_Priority_Policy, "&
            "in scheduling server: "&
            To_String(Scheduling_Servers.Name(Sched_Serv_Ref)));
   end Add_Fixed_Priority_Policy;

   -----------------------------
   -- Add_Interrupt_FP_Policy --
   -----------------------------

   procedure Add_Interrupt_FP_Policy
     (Sched_Serv_Ref :in out Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Ifpp_Node : Dom.Core.Node)
   is
      Sp_Ref  : Mast.Scheduling_Parameters.Sched_Parameters_Ref;
      Att_Lst : Dom.Core.Named_Node_Map;
      J       : Integer:=0;
      Act_Att : Dom.Core.Node;
   begin
      Sp_Ref:=new Mast.Scheduling_Parameters.Interrupt_FP_Policy;
      Att_Lst:=Dom.Core.Nodes.Attributes(Ifpp_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Att_Lst)
      loop
         Act_Att:=Dom.Core.Nodes.Item(Att_Lst,J);
         J:=J+1;
         case Sched_Par'Value(Dom.Core.Attrs.Name(Act_Att))is
            when The_Priority =>
               Mast.Scheduling_Parameters.Set_The_Priority
                 (Mast.Scheduling_Parameters.Fixed_Priority_Parameters
                  (Sp_Ref.all),
                  Mast.Priority'Value(Dom.Core.Attrs.Value(Act_Att)));
            when Preassigned =>
               Mast.Scheduling_Parameters.Set_Preassigned
                 (Mast.Scheduling_Parameters.Fixed_Priority_Parameters
                  (Sp_Ref.all),
                  To_Boolean(Dom.Core.Attrs.Value(Act_Att)));
            when others=>
               Mast_XML_Exceptions.Parser_Error
                 ("Syntax error in Interrupt_FP_Policy, "&
                  "in scheduling server: "&
                  To_String(Scheduling_Servers.Name(Sched_Serv_Ref)));
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      Mast.Scheduling_Servers.Set_Server_Sched_Parameters
        (Sched_Serv_Ref.all,Sp_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Interrupt_FP_Policy, "&
            "in scheduling server: "&
            To_String(Scheduling_Servers.Name(Sched_Serv_Ref)));
   end Add_Interrupt_FP_Policy;

   ------------------------
   -- Add_Polling_Policy --
   ------------------------

   procedure Add_Polling_Policy
     (Sched_Serv_Ref :in out Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Pp_Node : Dom.Core.Node)
   is
      Sp_Ref  : Mast.Scheduling_Parameters.Sched_Parameters_Ref;
      Att_Lst : Dom.Core.Named_Node_Map;
      J       : Integer:=0;
      Act_Att : Dom.Core.Node;
   begin
      Sp_Ref:=new Mast.Scheduling_Parameters.Polling_Policy;
      Att_Lst:=Dom.Core.Nodes.Attributes(Pp_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Att_Lst)
      loop
         Act_Att:=Dom.Core.Nodes.Item(Att_Lst,J);
         J:=J+1;
         case Sched_Par'Value(Dom.Core.Attrs.Name(Act_Att))is
            when The_Priority =>
               Mast.Scheduling_Parameters.Set_The_Priority
                 (Mast.Scheduling_Parameters.Fixed_Priority_Parameters
                  (Sp_Ref.all),
                  Mast.Priority'Value(Dom.Core.Attrs.Value(Act_Att)));
            when Preassigned =>
               Mast.Scheduling_Parameters.Set_Preassigned
                 (Mast.Scheduling_Parameters.Fixed_Priority_Parameters
                  (Sp_Ref.all),
                  To_Boolean(Dom.Core.Attrs.Value(Act_Att)));
            when Polling_Period =>
               Mast.Scheduling_Parameters.Set_Polling_Period
                 (Mast.Scheduling_Parameters.Polling_Policy(Sp_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Att)));
            when Polling_Worst_Overhead =>
               Mast.Scheduling_Parameters.Set_Polling_Worst_Overhead
                 (Mast.Scheduling_Parameters.Polling_Policy(Sp_Ref.all),
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Attrs.Value(Act_Att)));
            when Polling_Avg_Overhead =>
               Mast.Scheduling_Parameters.Set_Polling_Avg_Overhead
                 (Mast.Scheduling_Parameters.Polling_Policy(Sp_Ref.all),
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Attrs.Value(Act_Att)));
            when Polling_Best_Overhead =>
               Mast.Scheduling_Parameters.Set_Polling_Best_Overhead
                 (Mast.Scheduling_Parameters.Polling_Policy(Sp_Ref.all),
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Attrs.Value(Act_Att)));
            when others=>
               Mast_XML_Exceptions.Parser_Error
                 ("Syntax error in Polling Policy, "&
                  "in scheduling server: "&
                  To_String(Scheduling_Servers.Name(Sched_Serv_Ref)));
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      Mast.Scheduling_Servers.Set_Server_Sched_Parameters
        (Sched_Serv_Ref.all,Sp_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Polling_Policy, "&
            "in scheduling server: "&
            To_String(Scheduling_Servers.Name(Sched_Serv_Ref)));
   end Add_Polling_Policy;

   --------------------------------
   -- Add_Sporadic_Server_Policy --
   --------------------------------

   procedure Add_Sporadic_Server_Policy
     (Sched_Serv_Ref :in out Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Ssp_Node : Dom.Core.Node)
   is
      Sp_Ref  : Mast.Scheduling_Parameters.Sched_Parameters_Ref;
      Att_Lst : Dom.Core.Named_Node_Map;
      J       : Integer:=0;
      Act_Att : Dom.Core.Node;
   begin
      Sp_Ref:=new Mast.Scheduling_Parameters.Sporadic_Server_Policy;
      Att_Lst:=Dom.Core.Nodes.Attributes(Ssp_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Att_Lst)
      loop
         Act_Att:=Dom.Core.Nodes.Item(Att_Lst,J);
         J:=J+1;
         case Sched_Par'Value(Dom.Core.Attrs.Name(Act_Att))is
            when Normal_Priority =>
               Mast.Scheduling_Parameters.Set_The_Priority
                 (Mast.Scheduling_Parameters.Fixed_Priority_Parameters
                  (Sp_Ref.all),
                  Mast.Priority'Value(Dom.Core.Attrs.Value(Act_Att)));

            when Preassigned =>
               Mast.Scheduling_Parameters.Set_Preassigned
                 (Mast.Scheduling_Parameters.Fixed_Priority_Parameters
                  (Sp_Ref.all),
                  To_Boolean(Dom.Core.Attrs.Value(Act_Att)));

            when Background_Priority =>
               Mast.Scheduling_Parameters.Set_Background_Priority
                 (Mast.Scheduling_Parameters.Sporadic_Server_Policy
                  (Sp_Ref.all),
                  Mast.Priority'Value(Dom.Core.Attrs.Value(Act_Att)));

            when Initial_Capacity =>
               Mast.Scheduling_Parameters.Set_Initial_Capacity
                 (Mast.Scheduling_Parameters.Sporadic_Server_Policy
                  (Sp_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Att)));

            when Replenishment_Period =>
               Mast.Scheduling_Parameters.Set_Replenishment_Period
                 (Mast.Scheduling_Parameters.Sporadic_Server_Policy
                  (Sp_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Att)));

            when Max_Pending_Replenishments =>
               Mast.Scheduling_Parameters.Set_Max_Pending_Replenishments
                 (Mast.Scheduling_Parameters.Sporadic_Server_Policy
                  (Sp_Ref.all),
                  Positive'Value(Dom.Core.Attrs.Value(Act_Att)));
            when others=>
               Mast_XML_Exceptions.Parser_Error
                 ("Syntax error in Sporadic Server Policy, "&
                  "in scheduling server: "&
                  To_String(Scheduling_Servers.Name(Sched_Serv_Ref)));
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      Mast.Scheduling_Servers.Set_Server_Sched_Parameters
        (Sched_Serv_Ref.all,Sp_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Sporadic_Server_Policy, "&
            "in scheduling server: "&
            To_String(Scheduling_Servers.Name(Sched_Serv_Ref)));
   end Add_Sporadic_Server_Policy;

   --------------------
   -- Add_EDF_Policy --
   --------------------

   procedure Add_EDF_Policy
     (Sched_Serv_Ref : in out Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Edfp_Node : Dom.Core.Node)
   is
      Sp_Ref  : Mast.Scheduling_Parameters.Sched_Parameters_Ref;
      Att_Lst : Dom.Core.Named_Node_Map;
      J       : Integer:=0;
      Act_Att : Dom.Core.Node;
   begin
      Sp_Ref:=new Mast.Scheduling_Parameters.EDF_Policy;
      Att_Lst:=Dom.Core.Nodes.Attributes(Edfp_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Att_Lst)
      loop
         Act_Att:=Dom.Core.Nodes.Item(Att_Lst,J);
         J:=J+1;
         case Sched_Par'Value(Dom.Core.Attrs.Name(Act_Att))is
            when Preassigned =>
               Mast.Scheduling_Parameters.Set_Preassigned
                 (Mast.Scheduling_Parameters.EDF_Policy(Sp_Ref.all),
                  To_Boolean(Dom.Core.Attrs.Value(Act_Att)));
            when Deadline =>
               Mast.Scheduling_Parameters.Set_Deadline
                 (Mast.Scheduling_Parameters.EDF_Policy(Sp_Ref.all),
                  Mast.Time'Value(Dom.Core.Attrs.Value(Act_Att)));
            when others=>
               Mast_XML_Exceptions.Parser_Error
                 ("Syntax error in EDF Policy, "&
                  "in scheduling server: "&
                  To_String(Scheduling_Servers.Name(Sched_Serv_Ref)));
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      Mast.Scheduling_Servers.Set_Server_Sched_Parameters
        (Sched_Serv_Ref.all,Sp_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in EDF_Policy, "&
            "in scheduling server: "&
            To_String(Scheduling_Servers.Name(Sched_Serv_Ref)));
   end Add_EDF_Policy;

   ------------------------
   -- Add_SRP_Parameters --
   ------------------------

   procedure Add_SRP_Parameters
     (Sched_Serv_Ref :in out Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Srpp_Node : Dom.Core.Node)
   is
      Srp_Ref : Mast.Synchronization_Parameters.Synch_Parameters_Ref;
      Att_Lst : Dom.Core.Named_Node_Map;
      J       : Integer:=0;
      Act_Att : Dom.Core.Node;
   begin

      Srp_Ref:=new Mast.Synchronization_Parameters.SRP_Parameters;
      Att_Lst:=Dom.Core.Nodes.Attributes(Srpp_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Att_Lst)
      loop
         Act_Att:=Dom.Core.Nodes.Item(Att_Lst,J);
         J:=J+1;
         case Sched_Par'Value(Dom.Core.Attrs.Name(Act_Att))is
            when Preemption_Level =>
               Mast.Synchronization_Parameters.Set_Preemption_Level
                 (Mast.Synchronization_Parameters.SRP_Parameters(Srp_Ref.all),
                  Mast.Preemption_Level'Value(Dom.Core.Attrs.Value(Act_Att)));
            when Preassigned =>
               Mast.Synchronization_Parameters.Set_Preassigned
                 (Mast.Synchronization_Parameters.SRP_Parameters(Srp_Ref.all),
                  To_Boolean(Dom.Core.Attrs.Value(Act_Att)));
            when others =>
               Mast_XML_Exceptions.Parser_Error
                 ("Syntax error in SRP Parameters, "&
                  "in scheduling server: "&
                  To_String(Scheduling_Servers.Name(Sched_Serv_Ref)));
               raise Mast_XML_Exceptions.Syntax_Error;
         end case;
      end loop;
      Mast.Scheduling_Servers.Set_Server_Synch_Parameters
        (Sched_Serv_Ref.all,Srp_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in SRP_Parameters, "&
            "in scheduling server: "&
            To_String(Scheduling_Servers.Name(Sched_Serv_Ref)));
   end Add_SRP_Parameters;

   --------------------------
   -- Add_Simple_Operation --
   --------------------------

   procedure Add_Simple_Operation
     (Mast_System: in out Mast.Systems.System;
      Sop_Node : Dom.Core.Node)
   is
      A_Name    : Var_Strings.Var_String;

      function Get_Simple_Operation
        (Mast_Shr : MAST.Shared_Resources.Lists.List;
         Sop_Node: Dom.Core.Node) return Mast.Operations.Operation_Ref
      is
         type Simple_Attributes is
           (Name,Worst_Case_Execution_Time,
            Average_Case_Execution_Time,
            Best_Case_Execution_Time);

         type Simples is
           (Overridden_Fixed_Priority,Overridden_Permanent_FP,
            Shared_Resources_List,Shared_Resources_To_Lock,
            Shared_Resources_To_Unlock);

         Attr_Lst  : Dom.Core.Named_Node_Map;
         Lst       : Dom.Core.Node_List;
         I         : Integer:=0;
         Act_Node,
         Act_Attr  : Dom.Core.Node;
         Sop_Ref   : Mast.Operations.Operation_Ref;

      begin
         Sop_Ref:= new Mast.Operations.Simple_Operation;
         A_Name:=Var_Strings.To_Lower
           (Var_Strings.To_Var_String
            (Dom.Core.Elements.Get_Attribute(Sop_Node,"Name")));
         Check_Identifier(A_Name);
         Mast.Operations.Init
           (Sop_Ref.all,A_Name);
         --Initialize the Simple_Operation Structure.
         Lst:=Dom.Core.Nodes.Child_Nodes(Sop_Node);
         --Get the list of children of the Simple_Operation node,
         --and there can be Overriden_Fixed_Priority, Overriden_Permanent_FP,
         --Shared_Resources_list, Shared_Resources_To_Lock,
         --and Shared_Resources_To_Unlock.
         while I<Dom.Core.Nodes.Length(Lst)
         loop
            --Analyze the child nodes one by one.
            Act_Node:=Dom.Core.Nodes.Item(Lst,I);
            I:=I+1;
            if Dom.Core.Nodes.Local_Name(Act_Node)/=""
            then
               --Filter the text nodes.
               --Analyze the nodes and process them depending on it's kind.
               case  Simples'Value(Dom.Core.Nodes.Local_Name(Act_Node))
               is
                  when Overridden_Fixed_Priority =>
                     Add_Overridden_Fixed_Priority(Sop_Ref,Act_Node);
                  when Overridden_Permanent_FP =>
                     Add_Overridden_Permanent_FP(Sop_Ref,Act_Node);
                  when Shared_Resources_List =>
                     Add_Shared_Resources_List (Mast_Shr,Sop_Ref,Act_Node);
                  when Shared_Resources_To_Lock =>
                     Add_Shared_Resources_To_Lock(Mast_Shr,Sop_Ref,Act_Node);
                  when Shared_Resources_To_Unlock =>
                     Add_Shared_Resources_To_Unlock(Mast_Shr,Sop_Ref,Act_Node);
               end case;
            end if;
         end loop;
         Attr_Lst:=Dom.Core.Nodes.Attributes(Sop_Node);
         --Get the list of Attributes of the Simple_Operation.
         I:=0;
         while I<Dom.Core.Nodes.Length(Attr_Lst)
         loop
            Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,I);
            I:=I+1;
            --Analyze the attributes one by one processing them by it's name.
            case Simple_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))is
               when Name =>
                  null;
               when Worst_Case_Execution_Time=>
                  Mast.Operations.Set_Worst_Case_Execution_Time
                    (Mast.Operations.Simple_Operation(Sop_Ref.all),
                     Mast.Normalized_Execution_Time'Value
                     (Dom.Core.Elements.Get_Attribute
                      (Sop_Node,"Worst_Case_Execution_Time")));
               when  Average_Case_Execution_Time=>
                  Mast.Operations.Set_Avg_Case_Execution_Time
                    (Mast.Operations.Simple_Operation(Sop_Ref.all),
                     Mast.Normalized_Execution_Time'Value
                     (Dom.Core.Elements.Get_Attribute
                      (Sop_Node,"Average_Case_Execution_Time")));
               when  Best_Case_Execution_Time=>
                  Mast.Operations.Set_Best_Case_Execution_Time
                    (Mast.Operations.Simple_Operation(Sop_Ref.all),
                     Mast.Normalized_Execution_Time'Value
                     (Dom.Core.Elements.Get_Attribute
                      (Sop_Node,"Best_Case_Execution_Time")));
            end case;
         end loop;
         return Sop_Ref;
      end Get_Simple_Operation;

   begin
      Mast.Operations.Lists.Add
        (Get_Simple_Operation (Mast_System.Shared_Resources,Sop_Node),
         Mast_System.Operations);
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("Operation already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Simple Operation: "&To_String(A_Name));
   end Add_Simple_Operation;


   -----------------------------
   -- Add_Composite_Operation --
   -----------------------------

   procedure Add_Composite_Operation
     (Mast_System: in out Mast.Systems.System;
      Co_Node : Dom.Core.Node)
   is
      type Composites is
        (Overridden_Fixed_Priority,Overridden_Permanent_FP,
         Operation_List);

      I               : Integer:=0;
      Act_Ssp         : Dom.Core.Node;
      Ssp_Lst         : Dom.Core.Node_List;
      Co_Ref          : Mast.Operations.Operation_Ref;
      Composite_Index : Mast.Operations.Lists.Index;
      Cop_Lst         : Unbounded_String;
      Composite_Elem  : Var_Strings.Var_String;
      A_Name          : Var_Strings.Var_String;
   begin
      Co_Ref:= new Mast.Operations.Composite_Operation;
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Co_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Operations.Init
        (Co_Ref.all,A_Name);
      Ssp_Lst:=Dom.Core.Nodes.Child_Nodes(Co_Node);
      -- Get the list of child nodes of the composite operation,
      -- there mast be text-nodes, there can be Composite_Operation_List
      -- and there can be an Overridden_Sched_Parameters node.
      while I<Dom.Core.Nodes.Length(Ssp_Lst)
      loop
         Act_Ssp:=Dom.Core.Nodes.Item(Ssp_Lst,I);
         I:=I+1;
         if Dom.Core.Nodes.Local_Name(Act_Ssp)/=""
         then
            case  Composites'Value(Dom.Core.Nodes.Local_Name(Act_Ssp))
            is
               when Overridden_Fixed_Priority =>
                  Add_Overridden_Fixed_Priority(Co_Ref,Act_Ssp);
               when Overridden_Permanent_FP =>
                  Add_Overridden_Permanent_FP(Co_Ref,Act_Ssp);
               when Operation_List =>
                  --Get the Composite_Operation list,
                  --it is a String that we have to analyze
                  --word by word.
                  Cop_Lst:=To_Unbounded_String
                    (To_Lower
                     (Dom.Core.Nodes.Node_Value
                      (Dom.Core.Nodes.Item
                       (Dom.Core.Nodes.Child_Nodes(Act_Ssp),0))));
                  --Get the first word and process it.
                  Composite_Elem:=First_Word(Cop_Lst);
                  while Composite_Elem /= Null_Var_String
                  loop
                     --Process the elements and add to the structure
                     Composite_Index:=Mast.Operations.Lists.Find
                       (Composite_Elem,MAST_System.Operations);
                     if Composite_Index=Mast.Operations.Lists.Null_Index
                     then
                        declare
                           New_Op_Ref : Operations.Operation_Ref:=
                             new Operations.Simple_Operation;
                        begin
                           Operations.Init(New_Op_Ref.all,Composite_Elem);
                           Operations.Add_Operation
                             (Operations.Composite_Operation
                              (Co_Ref.all),New_Op_Ref);
                        end;
                     else
                        Mast.Operations.Add_Operation
                          (Mast.Operations.Composite_Operation(Co_Ref.all),
                           MAst.Operations.Lists.Item
                           (Composite_Index,MAST_System.Operations));
                     end if;
                     Cop_Lst:=Delete_First_Word(Cop_Lst);
                     Composite_Elem:=First_Word(Cop_Lst);
                  end loop;
            end case;
         end if;
      end loop;
      Mast.Operations.Lists.Add(Co_Ref,Mast_System.Operations);
      --Add the composite operation structure to the Mast structure.
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("Operation already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Composite Operation: "&To_String(A_Name));
   end Add_Composite_Operation;

   -----------------------------
   -- Add_Enclosing_Operation --
   -----------------------------

   procedure Add_Enclosing_Operation
     (Mast_System: in out Mast.Systems.System;
      Eop_Node : Dom.Core.Node)
   is
      type Enclosing_Attributes is
        (Name,Worst_Case_Execution_Time,
         Average_Case_Execution_Time,
         Best_Case_Execution_Time);

      type Enclosings is
        (Overridden_Fixed_Priority,Overridden_Permanent_FP,
         Operation_List);

      I                : Integer:=0;
      Act_Ssp,Act_Attr : Dom.Core.Node;
      Ssp_Lst          : Dom.Core.Node_List;
      Attr_Lst         : Dom.Core.Named_Node_Map;
      Eo_Ref           : Mast.Operations.Operation_Ref;
      Enclosing_Index  : Mast.Operations.Lists.Index;
      Eop_Lst          : Unbounded_String;
      Enclosing_Elem   : Var_Strings.Var_String;
      A_Name           : Var_Strings.Var_String;

   begin
      Eo_Ref:= new Mast.Operations.Enclosing_Operation;
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Eop_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Operations.Init
        (Eo_Ref.all,A_Name);
      Ssp_Lst:=Dom.Core.Nodes.Child_Nodes(Eop_Node);
      -- Get the list of child nodes of the composite operation,
      -- there mast be text-nodes there can be a Composite_Operation_List
      -- and there can be an Overridden_Sched_Parameters node.
      while I<Dom.Core.Nodes.Length(Ssp_Lst)
      loop
         Act_Ssp:=Dom.Core.Nodes.Item(Ssp_Lst,I);
         I:=I+1;
         if Dom.Core.Nodes.Local_Name(Act_Ssp)/=""
         then
            case  Enclosings'Value(Dom.Core.Nodes.Local_Name(Act_Ssp))
            is
               when Overridden_Fixed_Priority =>
                  Add_Overridden_Fixed_Priority(Eo_Ref,Act_Ssp);
               when Overridden_Permanent_FP =>
                  Add_Overridden_Permanent_FP(Eo_Ref,Act_Ssp);
               when Operation_List =>
                  --Get the Composite_Operation list,
                  -- it is a String we have to analyze it  word by word.
                  Eop_Lst:=To_Unbounded_String
                    (To_Lower
                     (Dom.Core.Nodes.Node_Value
                      (Dom.Core.Nodes.Item
                       (Dom.Core.Nodes.Child_Nodes(Act_Ssp),0))));
                  --Get the first word and process it.
                  Enclosing_Elem:=First_Word(Eop_Lst);
                  while Enclosing_Elem /= Null_Var_String
                  loop
                     --Process the elements and add to the structure
                     Enclosing_Index:=Mast.Operations.Lists.Find
                       (Enclosing_Elem,MAST_System.Operations);
                     if Enclosing_Index=Mast.Operations.Lists.Null_Index
                     then
                        declare
                           New_Op_Ref : Operations.Operation_Ref:=
                             new Operations.Simple_Operation;
                        begin
                           Operations.Init(New_Op_Ref.all,Enclosing_Elem);
                           Operations.Add_Operation
                             (Operations.Composite_Operation
                              (Eo_Ref.all),New_Op_Ref);
                        end;
                     else
                        Mast.Operations.Add_Operation
                          (Mast.Operations.Composite_Operation(Eo_Ref.all),
                           MAst.Operations.Lists.Item
                           (Enclosing_Index,MAST_System.Operations));
                     end if;
                     Eop_Lst:=Delete_First_Word(Eop_Lst);
                     Enclosing_Elem:=First_Word(Eop_Lst);
                  end loop;
            end case;
         end if;
      end loop;
      Attr_Lst:=Dom.Core.Nodes.Attributes(Eop_Node);
      --Get the list of Attributes of the Simple_Operation
      I:=0;
      while I<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,I);
         I:=I+1;
         --Analyze the attributes one by one processing them by their name
         case Enclosing_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))is
            when Name =>
               null;
            when Worst_Case_Execution_Time=>
               Mast.Operations.Set_Worst_Case_Execution_Time
                 (Mast.Operations.Enclosing_Operation(Eo_Ref.all),
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Eop_Node,"Worst_Case_Execution_Time")));
            when  Average_Case_Execution_Time=>
               Mast.Operations.Set_Avg_Case_Execution_Time
                 (Mast.Operations.Enclosing_Operation(Eo_Ref.all),
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Eop_Node,"Average_Case_Execution_Time")));
            when  Best_Case_Execution_Time=>
               Mast.Operations.Set_Best_Case_Execution_Time
                 (Mast.Operations.Enclosing_Operation(Eo_Ref.all),
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Eop_Node,"Best_Case_Execution_Time")));
         end case;
      end loop;
      Mast.Operations.Lists.Add(Eo_Ref,Mast_System.Operations);
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("Operation already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Encosing Operation: "&To_String(A_Name));
   end Add_Enclosing_Operation;

   ------------------------------
   -- Add_Message_Transmission --
   ------------------------------

   procedure Add_Message_Transmission
     (Mast_System: in out Mast.Systems.System;
      Mt_Node: Dom.Core.Node)
   is
      type Mt_Attributes is
        (Name,Min_Message_Size,Avg_Message_Size,Max_Message_Size);

      type Mts is
        (Overridden_Fixed_Priority,Overridden_Permanent_FP);

      I        : Integer:=0;
      Act_Ssp,
      Act_Attr : Dom.Core.Node;
      Ssp_Lst  : Dom.Core.Node_List;
      Attr_Lst : Dom.Core.Named_Node_Map;
      Mt_Ref   : Mast.Operations.Operation_Ref;
      A_Name   : Var_Strings.Var_String;

   begin
      Mt_Ref:= new Mast.Operations.Message_Transmission_Operation;
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Mt_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Operations.Init
        (Mt_Ref.all,A_Name);
      Ssp_Lst:=Dom.Core.Nodes.Child_Nodes(Mt_Node);
      -- Get the list of child nodes of the composite operation
      while I<Dom.Core.Nodes.Length(Ssp_Lst)
      loop
         Act_Ssp:=Dom.Core.Nodes.Item(Ssp_Lst,I);
         I:=I+1;
         if Dom.Core.Nodes.Local_Name(Act_Ssp)/=""
         then
            case  Mts'Value(Dom.Core.Nodes.Local_Name(Act_Ssp))
            is
               when Overridden_Fixed_Priority =>
                  Add_Overridden_Fixed_Priority(Mt_Ref,Act_Ssp);
               when Overridden_Permanent_FP =>
                  Add_Overridden_Permanent_FP(Mt_Ref,Act_Ssp);
            end case;
         end if;
      end loop;
      Attr_Lst:=Dom.Core.Nodes.Attributes(Mt_Node);
      --Get the list of Attributes of the Simple_Operation.
      I:=0;
      while I<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,I);
         I:=I+1;
         --Analyze the attributes one by one processing them by it's name.
         case Mt_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))is
            when Name =>
               null;
            when Min_Message_Size=>
               Mast.Operations.Set_Min_Message_Size
                 (Mast.Operations.Message_Transmission_Operation(Mt_Ref.all),
                  Mast.Bit_Count'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Mt_Node,"Min_Message_Size")));
            when  Avg_Message_Size=>
               Mast.Operations.Set_Avg_Message_Size
                 (Mast.Operations.Message_Transmission_Operation(Mt_Ref.all),
                  Mast.Bit_Count'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Mt_Node,"Avg_Message_Size")));
            when  Max_Message_Size=>
               Mast.Operations.Set_Max_Message_Size
                 (Mast.Operations.Message_Transmission_Operation(Mt_Ref.all),
                  Mast.Bit_Count'Value
                  (Dom.Core.Elements.Get_Attribute
                   (Mt_Node,"Max_Message_Size")));
         end case;
      end loop;
      Mast.Operations.Lists.Add(Mt_Ref,Mast_System.Operations);
      --Add the operation structure to the Mast structure.
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("Operation already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Message Transmission Operation: "&
            To_String(A_Name));
   end Add_Message_Transmission;

   -----------------------------------
   -- Add_Overridden_Fixed_Priority --
   -----------------------------------

   procedure Add_Overridden_Fixed_Priority
     (Op_Ref :in out Mast.Operations.Operation_Ref;
      Op_Node : Dom.Core.Node)
   is
      Ovfp_Ref : Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
   begin
      Ovfp_Ref:=new Mast.Scheduling_Parameters.Overridden_FP_Parameters;
      Mast.Scheduling_Parameters.Set_The_Priority
        (Mast.Scheduling_Parameters.Overridden_FP_Parameters(Ovfp_Ref.all),
         Mast.Priority'Value
         (Dom.Core.Elements.Get_Attribute(Op_Node,"The_Priority")));
      Mast.Operations.Set_New_Sched_Parameters(Op_Ref.all,Ovfp_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Overridden_Fixed_Priority, in operation"&
            To_String(Operations.Name(Op_Ref)));
   end Add_Overridden_Fixed_Priority;

   -----------------------------------
   -- Add_Overridden_Permanent_FP--
   -----------------------------------

   procedure Add_Overridden_Permanent_FP
     (Op_Ref :in out Mast.Operations.Operation_Ref;
      Op_Node : Dom.Core.Node)
   is
      Ovpfp_Ref :   Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
   begin
      Ovpfp_Ref:=new
        Mast.Scheduling_Parameters.Overridden_Permanent_FP_Parameters;
      Mast.Scheduling_Parameters.Set_The_Priority
        (Mast.Scheduling_Parameters.Overridden_FP_Parameters(Ovpfp_Ref.all),
         Mast.Priority'Value
         (Dom.Core.Elements.Get_Attribute(Op_Node,"The_Priority")));
      Mast.Operations.Set_New_Sched_Parameters(Op_Ref.all,Ovpfp_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Overridden_Permanent_FP, in operation"&
            To_String(Operations.Name(Op_Ref)));
   end Add_Overridden_Permanent_FP;

   -------------------------------
   -- Add_Shared_Resources_List --
   -------------------------------

   procedure Add_Shared_Resources_List
     (Mast_Shr : MAST.Shared_Resources.Lists.List;
      Op_Ref      :in out Mast.Operations.Operation_Ref;
      Sr_Lst_Node : Dom.Core.Node)
   is
      Shared_List      : Unbounded_String;
      Shared_Elem      : Var_Strings.Var_String;
      Shared_Res_Index : Mast.Shared_Resources.Lists.Index;

   begin
      Shared_List:=To_Unbounded_String
        (To_Lower
         (Dom.Core.Nodes.Node_Value
          (Dom.Core.Nodes.Item(Dom.Core.Nodes.Child_Nodes(Sr_Lst_Node),0))));
      --Get the string
      Shared_Elem:=First_Word(Shared_List);
      --Get the first word.
      while Shared_Elem /= Null_Var_String
      loop
         --Process the word and add the Shared Resource to the
         --structure.
         Shared_Res_Index:=Mast.Shared_Resources.Lists.Find
           (Shared_Elem,Mast_Shr);
         if Shared_Res_Index=Mast.Shared_Resources.Lists.Null_Index
         then
            declare
               Sh_Res_Ref : Shared_Resources.Shared_Resource_Ref:=
                 new Shared_Resources.Priority_Inheritance_Resource;
            begin
               Shared_Resources.Init(Sh_Res_Ref.all,Shared_Elem);
               Operations.Add_Resource
                 (Operations.Simple_Operation(Op_Ref.all),Sh_Res_Ref);
            end;
         else
            Mast.Operations.Add_Resource
              (Mast.Operations.Simple_Operation(Op_Ref.all),
               MAst.Shared_Resources.Lists.Item(Shared_Res_Index,Mast_Shr));
         end if;
         Shared_List:=Delete_First_Word(Shared_List);
         --Delete the first word.
         Shared_Elem:=First_Word(Shared_List);
         --Get the next word (now the first).
      end loop;
   end Add_Shared_Resources_List;

   -----------------------------------
   -- Add_Shared_Resources_To_Lock --
   -----------------------------------

   procedure Add_Shared_Resources_To_Lock
     (Mast_Shr :  MAST.Shared_Resources.Lists.List;
      Op_Ref :in out Mast.Operations.Operation_Ref;
      Sr_To_Lock_Node : Dom.Core.Node)
   is
      Shared_List      : Unbounded_String;
      Shared_Elem      : Var_Strings.Var_String;
      Shared_Res_Index : Mast.Shared_Resources.Lists.Index;
   begin
      --Analyze the list of shared resources word by word and process them
      Shared_List:=To_Unbounded_String
        (To_Lower
         (Dom.Core.Nodes.Node_Value
          (Dom.Core.Nodes.Item
           (Dom.Core.Nodes.Child_Nodes(Sr_To_Lock_Node),0))));
      --Get the string
      Shared_Elem:=First_Word(Shared_List);
      --Get the first word.
      while Shared_Elem /= Null_Var_String
      loop
         Shared_Res_Index:=Mast.Shared_Resources.Lists.Find
           (Shared_Elem,Mast_Shr);
         --Process the word and add the Shared Resource to the
         --structure.
         if Shared_Res_Index=Mast.Shared_Resources.Lists.Null_Index
         then
            declare
               Sh_Res_Ref : Shared_Resources.Shared_Resource_Ref:=
                 new Shared_Resources.Priority_Inheritance_Resource;
            begin
               Shared_Resources.Init(Sh_Res_Ref.all,Shared_Elem);
               Operations.Add_Resource
                 (Operations.Simple_Operation(Op_Ref.all),Sh_Res_Ref);
            end;
         else
            Mast.Operations.Add_Locked_Resource
              (Mast.Operations.Simple_Operation(Op_Ref.all),
               Mast.Shared_Resources.Lists.Item(Shared_Res_Index,Mast_Shr));
         end if;
         Shared_List:=Delete_First_Word(Shared_List);
         --Delete the first word.
         Shared_Elem:=First_Word(Shared_List);
         --Get the next word (now the first).
      end loop;
   end Add_Shared_Resources_To_Lock;

   ------------------------------------
   -- Add_Shared_Resources_To_Unlock --
   ------------------------------------

   procedure Add_Shared_Resources_To_Unlock
     (Mast_Shr :  MAST.Shared_Resources.Lists.List;
      Op_Ref :in out Mast.Operations.Operation_Ref;
      Sr_To_Unlock_Node : Dom.Core.Node)
   is
      Shared_List      : Unbounded_String;
      Shared_Elem      : Var_Strings.Var_String;
      Shared_Res_Index : Mast.Shared_Resources.Lists.Index;
   begin
      --Analyze the list of shared resources word by word and process them
      Shared_List:=To_Unbounded_String
        (To_Lower
         (Dom.Core.Nodes.Node_Value
          (Dom.Core.Nodes.Item
           (Dom.Core.Nodes.Child_Nodes(Sr_To_Unlock_Node),0))));
      Shared_Elem:=First_Word(Shared_List);
      while Shared_Elem /= Null_Var_String
      loop
         Shared_Res_Index:=
           Mast.Shared_Resources.Lists.Find(Shared_Elem,Mast_Shr);
         --Process the word and add the Shared Resource to the
         --structure.
         if Shared_Res_Index=Mast.Shared_Resources.Lists.Null_Index
         then
            declare
               Sh_Res_Ref : Shared_Resources.Shared_Resource_Ref:=
                 new Shared_Resources.Priority_Inheritance_Resource;
            begin
               Shared_Resources.Init(Sh_Res_Ref.all,Shared_Elem);
               Operations.Add_Resource
                 (Operations.Simple_Operation(Op_Ref.all),Sh_Res_Ref);
            end;
         else
            Mast.Operations.Add_Unlocked_Resource
              (Mast.Operations.Simple_Operation(Op_Ref.all),
               Mast.Shared_Resources.Lists.Item(Shared_Res_Index,Mast_Shr));
         end if;
         Shared_List:=Delete_First_Word(Shared_List);
         --Delete the first word.
         Shared_Elem:=First_Word(Shared_List);
         --Get the next word (now the first).
      end loop;
   end Add_Shared_Resources_To_Unlock;

   ------------------------------
   -- Add_Packet_Based_Network --
   ------------------------------

   procedure Add_Packet_Based_Network (Mast_System: in out Mast.Systems.System;
                                       Pbn_Node : Dom.Core.Node)
   is
      type Network_Attributes is
        (Name,Speed_Factor,Throughput,Transmission,
         Max_Blocking, Max_Packet_Size, Min_Packet_Size);

      Pr_Ref           : Mast.Processing_Resources.Processing_Resource_Ref;
      Attr_Lst         : Dom.Core.Named_Node_Map;
      I,J              : Integer:=0;
      Act_Attr,
      Act_D            : Dom.Core.Node;
      List_Of_Drivers,
      D_List           : Dom.Core.Node_List;
      A_Name           : Var_Strings.Var_String;
   begin
      Pr_Ref:= new Mast.Processing_Resources.Network.Packet_Based_Network;
      --Initialize the Network and add to the Processing_Resources list.
      A_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Pbn_Node,"Name")));
      Check_Identifier(A_Name);
      Mast.Processing_Resources.Init
        (Pr_Ref.all,A_Name);
      Mast.Processing_Resources.Lists.Add
        (Pr_Ref,Mast_System.Processing_Resources);
      --Attribute processing--
      Attr_Lst:=Dom.Core.Nodes.Attributes(Pbn_Node);
      --Get the list of attributes of the network.
      J:=0;
      while J<Dom.Core.Nodes.Length(Attr_Lst)
      loop
         Act_Attr:=Dom.Core.Nodes.Item(Attr_Lst,J);
         J:=J+1;
         --Process each Attribute by it's name.
         case Network_Attributes'Value(Dom.Core.Attrs.Name(Act_Attr))is
            when Name =>
               null;
            when Speed_Factor =>
               Mast.Processing_Resources.Set_Speed_Factor
                 (Pr_Ref.all,
                  Mast.Processor_Speed'Value
                  (Dom.Core.Elements.Get_Attribute(Pbn_Node,"Speed_Factor")));
            when  Throughput=>
               Mast.Processing_Resources.Network.Set_Throughput
                 (Mast.Processing_Resources.Network.Packet_Based_Network
                  (Pr_Ref.all),
                  Mast.Throughput_Value'Value
                  (Dom.Core.Elements.Get_Attribute(Pbn_Node,"Throughput")));
            when Transmission =>
               Mast.Processing_Resources.Network.Set_Transmission_Mode
                 (Mast.Processing_Resources.Network.Packet_Based_Network
                  (Pr_Ref.all),
                  Mast.Transmission_Kind'Value
                  (Dom.Core.Elements.Get_Attribute(Pbn_Node,"Transmission")));
            when Max_Blocking =>
               Mast.Processing_Resources.Network.Set_Max_Blocking
                 (Mast.Processing_Resources.Network.Packet_Based_Network
                  (Pr_Ref.all),
                  Mast.Normalized_Execution_Time'Value
                  (Dom.Core.Elements.Get_Attribute(Pbn_Node,"Max_Blocking")));

            when  Max_Packet_Size=>
               declare
                  Size : Bit_Count:=Mast.Bit_Count'Value
                    (Dom.Core.Elements.Get_Attribute
                     (Pbn_Node,"Max_Packet_Size"));
               begin
                  if Size<=0.0 then
                     Mast_XML_Exceptions.Parser_Error
                       ("Max_Packet_Size must be greater than zero"&
                        ", in Packet Based Network: "&To_String(A_Name));
                  else
                     Mast.Processing_Resources.Network.Set_Max_Packet_Size
                       (Mast.Processing_Resources.Network.Packet_Based_Network
                        (Pr_Ref.all),Size);
                  end if;
               end;
            when  Min_Packet_Size=>
               declare
                  Size : Bit_Count:=Mast.Bit_Count'Value
                    (Dom.Core.Elements.Get_Attribute
                     (Pbn_Node,"Min_Packet_Size"));
               begin
                  if Size<=0.0 then
                     Mast_XML_Exceptions.Parser_Error
                       ("Min_Packet_Size must be greater than zero"&
                        ", in Packet Based Network: "&To_String(A_Name));
                  else
                     Mast.Processing_Resources.Network.Set_Min_Packet_Size
                       (Mast.Processing_Resources.Network.Packet_Based_Network
                        (Pr_Ref.all),Size);
                  end if;
               end;
         end case;
      end loop;
      --Drivers_List Analysis.--
      List_Of_Drivers:=Dom.Core.Elements.Get_Elements_By_Tag_Name
        (Pbn_Node,"mast_mdl:List_of_Drivers");
      -- There can be one or none List_of_drivers.
      if Dom.Core.Nodes.Length(List_Of_Drivers)>0 then
         --The List_of_Drivers has Drivers, the number of Drivers
         -- is not limited.
         --Each Driver can be of a different type
         D_List:=Dom.Core.Nodes.Child_Nodes
           (Dom.Core.Nodes.Item(List_Of_Drivers,0));
         I:=0;
         while I<Dom.Core.Nodes.Length(D_List)
         loop
            Act_D:=Dom.Core.Nodes.Item(D_List,I);
            I:=I+1;
            if Dom.Core.Nodes.Local_Name(Act_D)/=""
            then
               Driver_Adds(Mast_Driver_Elements'Value
                           (Dom.Core.Nodes.Local_Name(Act_D)))
                 (Mast_System, Pr_Ref, Act_D);
            end if;
         end loop;
      end if;
   exception
      when List_Exceptions.Already_Exists =>
         Mast_XML_Exceptions.Parser_Error
           ("Processing resource already exists: "&To_String(A_Name));
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Packet Based Network: "&To_String(A_Name));
   end Add_Packet_Based_Network;

   -----------------------
   -- Add_Packet_Driver --
   -----------------------

   procedure Add_Packet_Driver
     (Mast_System :in out  Mast.Systems.System;
      Rsrc :in out Mast.Processing_Resources.Processing_Resource_Ref;
      Pd_Node : Dom.Core.Node)
   is
      D_Ref    : Mast.Drivers.Driver_Ref;
      S_Index  : Mast.Scheduling_Servers.Lists.Index;
      Op_Index : Operations.Lists.Index;
      PS_Name,
      Op_Name  : Var_Strings.Var_String;
      Att_Lst  : Dom.Core.Named_Node_Map;
      J        : Integer:=0;
      Act_Att  : Dom.Core.Node;

      type Packet_Driver_Attrs is
        (Packet_Send_Operation, Packet_Receive_Operation, Packet_Server,
         Message_Partitioning, RTA_Overhead_Model);

   begin
      D_Ref:= new Mast.Drivers.Packet_Driver;
      PS_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Pd_Node,"Packet_Server")));
      S_Index:=Mast.Scheduling_Servers.Lists.Find
        (PS_Name, Mast_System.Scheduling_Servers);
      if S_Index=Mast.Scheduling_Servers.Lists.Null_Index
      then
         declare
            Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref:=
              new Scheduling_Servers.Scheduling_Server;
         begin
            Scheduling_Servers.Init(Srvr_Ref.all,PS_Name);
            Drivers.Set_Packet_Server
              (Drivers.Packet_Driver'Class(D_Ref.all),Srvr_Ref);
         end;
      else
         Mast.Drivers.Set_Packet_Server
           (Mast.Drivers.Packet_Driver(D_Ref.all),
            Mast.Scheduling_Servers.Lists.Item
            (S_Index,Mast_System.Scheduling_Servers));
      end if;
      -- Process optional atributes
      Att_Lst:=Dom.Core.Nodes.Attributes(Pd_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Att_Lst)
      loop
         Act_Att:=Dom.Core.Nodes.Item(Att_Lst,J);
         J:=J+1;
         case Packet_Driver_Attrs'Value(Dom.Core.Attrs.Name(Act_Att)) is
            when Packet_Send_Operation =>
               Op_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Dom.Core.Elements.Get_Attribute
                   (Pd_Node,"Packet_Send_Operation")));
               Op_Index:=Operations.Lists.Find
                 (Op_Name,MAST_System.Operations);
               if Op_Index=Operations.Lists.Null_Index then
                  declare
                     Op_Ref : Operations.Operation_Ref:=
                       new Operations.Simple_Operation;
                  begin
                     Operations.Init(Op_Ref.all,Op_Name);
                     Drivers.Set_Packet_Send_Operation
                       (Drivers.Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               else
                  declare
                     Op_Ref : Operations.Operation_Ref;
                  begin
                     Op_Ref:=Operations.Lists.Item
                       (Op_Index,MAST_System.Operations);
                     Drivers.Set_Packet_Send_Operation
                       (Drivers.Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               end if;
            when Packet_Receive_Operation =>
               Op_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Dom.Core.Elements.Get_Attribute
                   (Pd_Node,"Packet_Receive_Operation")));
               Op_Index:=Operations.Lists.Find
                 (Op_Name,MAST_System.Operations);
               if Op_Index=Operations.Lists.Null_Index then
                  declare
                     Op_Ref : Operations.Operation_Ref:=
                       new Operations.Simple_Operation;
                  begin
                     Operations.Init(Op_Ref.all,Op_Name);
                     Drivers.Set_Packet_Receive_Operation
                       (Drivers.Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               else
                  declare
                     Op_Ref : Operations.Operation_Ref;
                  begin
                     Op_Ref:=Operations.Lists.Item
                       (Op_Index,MAST_System.Operations);
                     Drivers.Set_Packet_Receive_Operation
                       (Drivers.Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               end if;
            when Packet_Server =>
               null;
            when Message_Partitioning =>
               Drivers.Set_Message_Partitioning
                 (Drivers.Packet_Driver'Class(D_Ref.all),
                  To_Boolean
                  (To_String(Get_Attribute(Pd_Node,"Message_Partitioning"))));
            when RTA_Overhead_Model =>
               begin
                  Drivers.Set_Rta_Overhead_Model
                    (Drivers.Packet_Driver'Class(D_Ref.all),
                     Drivers.Rta_Overhead_Model_Type'Value
                     (To_String(Get_Attribute(Pd_Node,"RTA_Overhead_Model"))));
               exception
                  when Constraint_Error =>
                     Mast_XML_Exceptions.Parser_Error
                       ("Overhead Model in Packet Driver is invalid"&
                        ", in network: "&
                        To_String(Processing_Resources.Name(Rsrc)));
               end;
         end case;
      end loop;
      Processing_Resources.Network.Add_Driver
        (Processing_Resources.Network.Packet_Based_Network'Class(Rsrc.all),
         D_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Packet Driver"&
            ", in network: "&To_String(Processing_Resources.Name(Rsrc)));
   end Add_Packet_Driver;

   -----------------------------------
   -- Add_Character_Packet_Driver --
   -----------------------------------

   procedure Add_Character_Packet_Driver
     (Mast_System :in out  Mast.Systems.System;
      Rsrc     : in out Mast.Processing_Resources.Processing_Resource_Ref;
      Cpd_Node : Dom.Core.Node)
   is
      D_Ref    : Mast.Drivers.Driver_Ref;
      S_Index  : Mast.Scheduling_Servers.Lists.Index;
      Op_Index : Operations.Lists.Index;
      PS_Name,
      CPS_Name,
      Op_Name  : Var_Strings.Var_String;
      Att_Lst  : Dom.Core.Named_Node_Map;
      J        : Integer:=0;
      Act_Att  : Dom.Core.Node;

      type Packet_Driver_Attrs is
        (Packet_Send_Operation, Packet_Receive_Operation, Packet_Server,
         Character_Send_Operation, Character_Receive_Operation,
         Character_Server, Character_Transmission_Time,
         Message_Partitioning, RTA_Overhead_Model);

   begin
      D_Ref:= new Mast.Drivers.Character_Packet_Driver;
      PS_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Cpd_Node,"Packet_Server")));
      S_Index:=Mast.Scheduling_Servers.Lists.Find
        (PS_Name, Mast_System.Scheduling_Servers);
      if S_Index=Mast.Scheduling_Servers.Lists.Null_Index
      then
         declare
            Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref:=
              new Scheduling_Servers.Scheduling_Server;
         begin
            Scheduling_Servers.Init(Srvr_Ref.all,PS_Name);
            Drivers.Set_Packet_Server
              (Drivers.Packet_Driver'Class(D_Ref.all),Srvr_Ref);
         end;
      else
         Mast.Drivers.Set_Packet_Server
           (Mast.Drivers.Packet_Driver(D_Ref.all),
            Mast.Scheduling_Servers.Lists.Item
            (S_Index,Mast_System.Scheduling_Servers));
      end if;
      CPS_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Cpd_Node,"Character_Server")));
      S_Index:=Mast.Scheduling_Servers.Lists.Find
        (CPS_Name, Mast_System.Scheduling_Servers);
      if S_Index=Mast.Scheduling_Servers.Lists.Null_Index
      then
         declare
            Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref:=
              new Scheduling_Servers.Scheduling_Server;
         begin
            Scheduling_Servers.Init(Srvr_Ref.all,CPS_Name);
            Drivers.Set_Character_Server
              (Drivers.Character_Packet_Driver'Class(D_Ref.all),Srvr_Ref);
         end;
      else
         Mast.Drivers.Set_Character_Server
           (Mast.Drivers.Character_Packet_Driver(D_Ref.all),
            Mast.Scheduling_Servers.Lists.Item
            (S_Index,Mast_System.Scheduling_Servers));
      end if;
      -- Process optional atributes
      Att_Lst:=Dom.Core.Nodes.Attributes(Cpd_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Att_Lst)
      loop
         Act_Att:=Dom.Core.Nodes.Item(Att_Lst,J);
         J:=J+1;
         case Packet_Driver_Attrs'Value(Dom.Core.Attrs.Name(Act_Att))is
            when Packet_Send_Operation =>
               Op_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Dom.Core.Elements.Get_Attribute
                   (Cpd_Node,"Packet_Send_Operation")));
               Op_Index:=Operations.Lists.Find
                 (Op_Name,MAST_System.Operations);
               if Op_Index=Operations.Lists.Null_Index then
                  declare
                     Op_Ref : Operations.Operation_Ref:=
                       new Operations.Simple_Operation;
                  begin
                     Operations.Init(Op_Ref.all,Op_Name);
                     Drivers.Set_Packet_Send_Operation
                       (Drivers.Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               else
                  declare
                     Op_Ref : Operations.Operation_Ref;
                  begin
                     Op_Ref:=Operations.Lists.Item
                       (Op_Index,MAST_System.Operations);
                     Drivers.Set_Packet_Send_Operation
                       (Drivers.Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               end if;
            when Packet_Receive_Operation =>
               Op_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Dom.Core.Elements.Get_Attribute
                   (Cpd_Node,"Packet_Receive_Operation")));
               Op_Index:=Operations.Lists.Find
                 (Op_Name,MAST_System.Operations);
               if Op_Index=Operations.Lists.Null_Index then
                  declare
                     Op_Ref : Operations.Operation_Ref:=
                       new Operations.Simple_Operation;
                  begin
                     Operations.Init(Op_Ref.all,Op_Name);
                     Drivers.Set_Packet_Receive_Operation
                       (Drivers.Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               else
                  declare
                     Op_Ref : Operations.Operation_Ref;
                  begin
                     Op_Ref:=Operations.Lists.Item
                       (Op_Index,MAST_System.Operations);
                     Drivers.Set_Packet_Receive_Operation
                       (Drivers.Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               end if;
            when Packet_Server | Character_Server=>
               null;
            when Character_Send_Operation =>
               Op_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Dom.Core.Elements.Get_Attribute
                   (Cpd_Node,"Character_Send_Operation")));
               Op_Index:=Operations.Lists.Find
                 (Op_Name,MAST_System.Operations);
               if Op_Index=Operations.Lists.Null_Index then
                  declare
                     Op_Ref : Operations.Operation_Ref:=
                       new Operations.Simple_Operation;
                  begin
                     Operations.Init(Op_Ref.all,Op_Name);
                     Drivers.Set_Character_Send_Operation
                       (Drivers.Character_Packet_Driver'Class
                        (D_Ref.all),Op_Ref);
                  end;
               else
                  declare
                     Op_Ref : Operations.Operation_Ref;
                  begin
                     Op_Ref:=Operations.Lists.Item
                       (Op_Index,MAST_System.Operations);
                     Drivers.Set_Character_Send_Operation
                       (Drivers.Character_Packet_Driver'Class
                        (D_Ref.all),Op_Ref);
                  end;
               end if;
            when Character_Receive_Operation =>
               Op_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Dom.Core.Elements.Get_Attribute
                   (Cpd_Node,"Character_Receive_Operation")));
               Op_Index:=Operations.Lists.Find
                 (Op_Name,MAST_System.Operations);
               if Op_Index=Operations.Lists.Null_Index then
                  declare
                     Op_Ref : Operations.Operation_Ref:=
                       new Operations.Simple_Operation;
                  begin
                     Operations.Init(Op_Ref.all,Op_Name);
                     Drivers.Set_Character_Receive_Operation
                       (Drivers.Character_Packet_Driver'Class
                        (D_Ref.all),Op_Ref);
                  end;
               else
                  declare
                     Op_Ref : Operations.Operation_Ref;
                  begin
                     Op_Ref:=Operations.Lists.Item
                       (Op_Index,MAST_System.Operations);
                     Drivers.Set_Character_Receive_Operation
                       (Drivers.Character_Packet_Driver'Class
                        (D_Ref.all),Op_Ref);
                  end;
               end if;
            when Character_Transmission_Time =>
               Mast.Drivers.Set_Character_Transmission_Time
                 (Mast.Drivers.Character_Packet_Driver(D_Ref.all),
                  Mast.Time'Value(Dom.Core.Elements.Get_Attribute
                                  (Cpd_Node,"Character_Transmission_Time")));
            when Message_Partitioning =>
               Drivers.Set_Message_Partitioning
                 (Drivers.Packet_Driver'Class(D_Ref.all),
                  To_Boolean
                  (To_String(Get_Attribute(Cpd_Node,"Message_Partitioning"))));
            when RTA_Overhead_Model =>
               begin
                  Drivers.Set_Rta_Overhead_Model
                    (Drivers.Packet_Driver'Class(D_Ref.all),
                     Drivers.Rta_Overhead_Model_Type'Value
                     (To_String
                      (Get_Attribute(Cpd_Node,"RTA_Overhead_Model"))));
               exception
                  when Constraint_Error =>
                     Mast_XML_Exceptions.Parser_Error
                       ("Overhead Model in Packet Driver is invalid"&
                        ", in network: "&
                        To_String(Processing_Resources.Name(Rsrc)));
               end;
         end case;
      end loop;
      Processing_Resources.Network.Add_Driver
        (Processing_Resources.Network.Packet_Based_Network'Class(Rsrc.all),
         D_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in Character Packet Driver"&
            ", in network: "&To_String(Processing_Resources.Name(Rsrc)));
   end Add_Character_Packet_Driver;

   ----------------------------
   -- Add_RTEP_Packet_Driver --
   ----------------------------

   procedure Add_RTEP_Packet_Driver
     (Mast_System :in out  Mast.Systems.System;
      Rsrc :in out Mast.Processing_Resources.Processing_Resource_Ref;
      Pd_Node : Dom.Core.Node)
   is
      D_Ref    : Mast.Drivers.Driver_Ref;
      S_Index  : Mast.Scheduling_Servers.Lists.Index;
      Op_Index : Operations.Lists.Index;
      PS_Name,
      IS_Name,
      Op_Name  : Var_Strings.Var_String;
      Att_Lst  : Dom.Core.Named_Node_Map;
      J        : Integer:=0;
      Act_Att  : Dom.Core.Node;

      type Packet_Driver_Attrs is
        (Packet_Send_Operation, Packet_Receive_Operation, Packet_Server,
         Number_Of_Stations, Token_Delay, Failure_Timeout,
         Token_Transmission_Retries, Packet_Transmission_Retries,
         Packet_Interrupt_Server, Packet_ISR_Operation,
         Token_Check_Operation, Token_Manage_Operation,
         Packet_Discard_Operation, Token_Retransmission_Operation,
         Packet_Retransmission_Operation,
         Message_Partitioning, RTA_Overhead_Model);

   begin
      D_Ref:= new Mast.Drivers.RTEP_Packet_Driver;
      PS_Name:=Var_Strings.To_Lower
        (Var_Strings.To_Var_String
         (Dom.Core.Elements.Get_Attribute(Pd_Node,"Packet_Server")));
      S_Index:=Mast.Scheduling_Servers.Lists.Find
        (PS_Name, Mast_System.Scheduling_Servers);
      if S_Index=Mast.Scheduling_Servers.Lists.Null_Index
      then
         declare
            Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref:=
              new Scheduling_Servers.Scheduling_Server;
         begin
            Scheduling_Servers.Init(Srvr_Ref.all,PS_Name);
            Drivers.Set_Packet_Server
              (Drivers.Packet_Driver'Class(D_Ref.all),Srvr_Ref);
         end;
      else
         Mast.Drivers.Set_Packet_Server
           (Mast.Drivers.Packet_Driver(D_Ref.all),
            Mast.Scheduling_Servers.Lists.Item
            (S_Index,Mast_System.Scheduling_Servers));
      end if;
      Mast.Drivers.Set_Number_Of_Stations
        (Mast.Drivers.RTEP_Packet_Driver(D_Ref.all),
         Integer'Value(Dom.Core.Elements.Get_Attribute
                       (Pd_Node,"Number_Of_Stations")));
      -- Process optional atributes
      Att_Lst:=Dom.Core.Nodes.Attributes(Pd_Node);
      J:=0;
      while J<Dom.Core.Nodes.Length(Att_Lst)
      loop
         Act_Att:=Dom.Core.Nodes.Item(Att_Lst,J);
         J:=J+1;
         case Packet_Driver_Attrs'Value(Dom.Core.Attrs.Name(Act_Att))is
            when Packet_Send_Operation =>
               Op_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Dom.Core.Elements.Get_Attribute
                   (Pd_Node,"Packet_Send_Operation")));
               Op_Index:=Operations.Lists.Find
                 (Op_Name,MAST_System.Operations);
               if Op_Index=Operations.Lists.Null_Index then
                  declare
                     Op_Ref : Operations.Operation_Ref:=
                       new Operations.Simple_Operation;
                  begin
                     Operations.Init(Op_Ref.all,Op_Name);
                     Drivers.Set_Packet_Send_Operation
                       (Drivers.Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               else
                  declare
                     Op_Ref : Operations.Operation_Ref;
                  begin
                     Op_Ref:=Operations.Lists.Item
                       (Op_Index,MAST_System.Operations);
                     Drivers.Set_Packet_Send_Operation
                       (Drivers.Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               end if;
            when Packet_Receive_Operation =>
               Op_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Dom.Core.Elements.Get_Attribute
                   (Pd_Node,"Packet_Receive_Operation")));
               Op_Index:=Operations.Lists.Find
                 (Op_Name,MAST_System.Operations);
               if Op_Index=Operations.Lists.Null_Index then
                  declare
                     Op_Ref : Operations.Operation_Ref:=
                       new Operations.Simple_Operation;
                  begin
                     Operations.Init(Op_Ref.all,Op_Name);
                     Drivers.Set_Packet_Receive_Operation
                       (Drivers.Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               else
                  declare
                     Op_Ref : Operations.Operation_Ref;
                  begin
                     Op_Ref:=Operations.Lists.Item
                       (Op_Index,MAST_System.Operations);
                     Drivers.Set_Packet_Receive_Operation
                       (Drivers.Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               end if;
            when Packet_Server =>
               null;
            when Number_Of_Stations =>
               null;
            when Token_Delay =>
               Mast.Drivers.Set_Token_Delay
                 (Mast.Drivers.RTEP_Packet_Driver(D_Ref.all),
                  Mast.Time'Value(Dom.Core.Elements.Get_Attribute
                                  (Pd_Node,"Token_Delay")));
            when Failure_Timeout =>
               Mast.Drivers.Set_Failure_Timeout
                 (Mast.Drivers.RTEP_Packet_Driver(D_Ref.all),
                  Mast.Time'Value(Dom.Core.Elements.Get_Attribute
                                  (Pd_Node,"Failure_Timeout")));
            when Token_Transmission_Retries =>
               Mast.Drivers.Set_Token_Transmission_Retries
                 (Mast.Drivers.RTEP_Packet_Driver(D_Ref.all),
                  Integer'Value(Dom.Core.Elements.Get_Attribute
                                (Pd_Node,"Token_Transmission_Retries")));
            when Packet_Transmission_Retries =>
               Mast.Drivers.Set_Packet_Transmission_Retries
                 (Mast.Drivers.RTEP_Packet_Driver(D_Ref.all),
                  Integer'Value(Dom.Core.Elements.Get_Attribute
                                (Pd_Node,"Packet_Transmission_Retries")));
            when Packet_Interrupt_Server =>
               IS_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Dom.Core.Elements.Get_Attribute
                   (Pd_Node,"Packet_Interrupt_Server")));
               S_Index:=Mast.Scheduling_Servers.Lists.Find
                 (IS_Name, Mast_System.Scheduling_Servers);
               if S_Index=Mast.Scheduling_Servers.Lists.Null_Index
               then
                  declare
                     Srvr_Ref : Scheduling_Servers.Scheduling_Server_Ref:=
                       new Scheduling_Servers.Scheduling_Server;
                  begin
                     Scheduling_Servers.Init(Srvr_Ref.all,IS_Name);
                     Drivers.Set_Packet_Interrupt_Server
                       (Drivers.RTEP_Packet_Driver'Class(D_Ref.all),Srvr_Ref);
                  end;
               else
                  Mast.Drivers.Set_Packet_Interrupt_Server
                    (Mast.Drivers.RTEP_Packet_Driver(D_Ref.all),
                     Mast.Scheduling_Servers.Lists.Item
                     (S_Index,Mast_System.Scheduling_Servers));
               end if;
            when Packet_ISR_Operation =>
               Op_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Dom.Core.Elements.Get_Attribute
                   (Pd_Node,"Packet_ISR_Operation")));
               Op_Index:=Operations.Lists.Find
                 (Op_Name,MAST_System.Operations);
               if Op_Index=Operations.Lists.Null_Index then
                  declare
                     Op_Ref : Operations.Operation_Ref:=
                       new Operations.Simple_Operation;
                  begin
                     Operations.Init(Op_Ref.all,Op_Name);
                     Drivers.Set_Packet_ISR_Operation
                       (Drivers.RTEP_Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               else
                  declare
                     Op_Ref : Operations.Operation_Ref;
                  begin
                     Op_Ref:=Operations.Lists.Item
                       (Op_Index,MAST_System.Operations);
                     Drivers.Set_Packet_ISR_Operation
                       (Drivers.RTEP_Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               end if;
            when Token_Check_Operation =>
               Op_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Dom.Core.Elements.Get_Attribute
                   (Pd_Node,"Token_Check_Operation")));
               Op_Index:=Operations.Lists.Find
                 (Op_Name,MAST_System.Operations);
               if Op_Index=Operations.Lists.Null_Index then
                  declare
                     Op_Ref : Operations.Operation_Ref:=
                       new Operations.Simple_Operation;
                  begin
                     Operations.Init(Op_Ref.all,Op_Name);
                     Drivers.Set_Token_Check_Operation
                       (Drivers.RTEP_Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               else
                  declare
                     Op_Ref : Operations.Operation_Ref;
                  begin
                     Op_Ref:=Operations.Lists.Item
                       (Op_Index,MAST_System.Operations);
                     Drivers.Set_Token_Check_Operation
                       (Drivers.RTEP_Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               end if;
            when Token_Manage_Operation =>
               Op_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Dom.Core.Elements.Get_Attribute
                   (Pd_Node,"Token_Manage_Operation")));
               Op_Index:=Operations.Lists.Find
                 (Op_Name,MAST_System.Operations);
               if Op_Index=Operations.Lists.Null_Index then
                  declare
                     Op_Ref : Operations.Operation_Ref:=
                       new Operations.Simple_Operation;
                  begin
                     Operations.Init(Op_Ref.all,Op_Name);
                     Drivers.Set_Token_Manage_Operation
                       (Drivers.RTEP_Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               else
                  declare
                     Op_Ref : Operations.Operation_Ref;
                  begin
                     Op_Ref:=Operations.Lists.Item
                       (Op_Index,MAST_System.Operations);
                     Drivers.Set_Token_Manage_Operation
                       (Drivers.RTEP_Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               end if;
            when Packet_Discard_Operation =>
               Op_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Dom.Core.Elements.Get_Attribute
                   (Pd_Node,"Packet_Discard_Operation")));
               Op_Index:=Operations.Lists.Find
                 (Op_Name,MAST_System.Operations);
               if Op_Index=Operations.Lists.Null_Index then
                  declare
                     Op_Ref : Operations.Operation_Ref:=
                       new Operations.Simple_Operation;
                  begin
                     Operations.Init(Op_Ref.all,Op_Name);
                     Drivers.Set_Packet_Discard_Operation
                       (Drivers.RTEP_Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               else
                  declare
                     Op_Ref : Operations.Operation_Ref;
                  begin
                     Op_Ref:=Operations.Lists.Item
                       (Op_Index,MAST_System.Operations);
                     Drivers.Set_Packet_Discard_Operation
                       (Drivers.RTEP_Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               end if;
            when Token_Retransmission_Operation =>
               Op_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Dom.Core.Elements.Get_Attribute
                   (Pd_Node,"Token_Retransmission_Operation")));
               Op_Index:=Operations.Lists.Find
                 (Op_Name,MAST_System.Operations);
               if Op_Index=Operations.Lists.Null_Index then
                  declare
                     Op_Ref : Operations.Operation_Ref:=
                       new Operations.Simple_Operation;
                  begin
                     Operations.Init(Op_Ref.all,Op_Name);
                     Drivers.Set_Token_Retransmission_Operation
                       (Drivers.RTEP_Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               else
                  declare
                     Op_Ref : Operations.Operation_Ref;
                  begin
                     Op_Ref:=Operations.Lists.Item
                       (Op_Index,MAST_System.Operations);
                     Drivers.Set_Token_Retransmission_Operation
                       (Drivers.RTEP_Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               end if;
            when Packet_Retransmission_Operation =>
               Op_Name:=Var_Strings.To_Lower
                 (Var_Strings.To_Var_String
                  (Dom.Core.Elements.Get_Attribute
                   (Pd_Node,"Packet_Retransmission_Operation")));
               Op_Index:=Operations.Lists.Find
                 (Op_Name,MAST_System.Operations);
               if Op_Index=Operations.Lists.Null_Index then
                  declare
                     Op_Ref : Operations.Operation_Ref:=
                       new Operations.Simple_Operation;
                  begin
                     Operations.Init(Op_Ref.all,Op_Name);
                     Drivers.Set_Packet_Retransmission_Operation
                       (Drivers.RTEP_Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               else
                  declare
                     Op_Ref : Operations.Operation_Ref;
                  begin
                     Op_Ref:=Operations.Lists.Item
                       (Op_Index,MAST_System.Operations);
                     Drivers.Set_Packet_Retransmission_Operation
                       (Drivers.RTEP_Packet_Driver'Class(D_Ref.all),Op_Ref);
                  end;
               end if;
            when Message_Partitioning =>
               Drivers.Set_Message_Partitioning
                 (Drivers.Packet_Driver'Class(D_Ref.all),
                  To_Boolean
                  (To_String(Get_Attribute(Pd_Node,"Message_Partitioning"))));
            when RTA_Overhead_Model =>
               begin
                  Drivers.Set_Rta_Overhead_Model
                    (Drivers.Packet_Driver'Class(D_Ref.all),
                     Drivers.Rta_Overhead_Model_Type'Value
                     (To_String(Get_Attribute(Pd_Node,"RTA_Overhead_Model"))));
               exception
                  when Constraint_Error =>
                     Mast_XML_Exceptions.Parser_Error
                       ("Overhead Model in Packet Driver is invalid"&
                        ", in network: "&
                        To_String(Processing_Resources.Name(Rsrc)));
               end;
         end case;
      end loop;
      Processing_Resources.Network.Add_Driver
        (Processing_Resources.Network.Packet_Based_Network'Class(Rsrc.all),
         D_Ref);
   exception
      when Constraint_Error =>
         Mast_XML_Exceptions.Parser_Error
           ("Argument error in RTEP Packet Driver"&
            ", in network: "&To_String(Processing_Resources.Name(Rsrc)));
   end Add_RTEP_Packet_Driver;

   -----------
   -- Parse --
   -----------

   procedure Parse
     (Mast_System: in out Mast.Systems.System;
      File:in out Ada.Text_IO.File_Type)
   is
      My_Tree_Reader     : Dom.Readers.Tree_Reader;
      FileType,Version,S : Ada.Strings.Unbounded.Unbounded_String;
      Tree               : Dom.Core.Document;
      Read               : Input_Sources.File.File_Input;
      Element_Kind_Lst   : Dom.Core.Node_List;
      Act_Root,Parent    : Dom.Core.Node;
      I                  : Integer:=0;
   begin
      Mast_XML_Exceptions.Clear_Errors;
      S:=Ada.Strings.Unbounded.To_Unbounded_String(Ada.Text_IO.Name(File));
      Ada.Text_IO.Close(File);
      Input_Sources.File.Open(Ada.Strings.Unbounded.To_String(S),Read);
      -- Read the XML file and get the tree. --
      --Validation ON OF (True, false)
      Dom.Readers.Set_Feature
        (My_Tree_Reader, Sax.Readers.Validation_Feature, False);
      Dom.Readers.Parse (My_Tree_Reader, Read); --SAX Parse. (SAX)
      Input_Sources.File.Close (Read);-- Close File_Input file.
      Tree:=Dom.Readers.Get_Tree (My_Tree_Reader);
      Dom.Core.Nodes.Normalize(Tree);
      -- Mast_Model Analysis --
      -- Analyze if the XML document is a Mast-Model-file
      -- and check the version.
      Mast_XML_Parser_Extension.Get_Kind_Of_XML_File(Tree,FileType,Version);
      if (FileType /=
          Ada.Strings.Unbounded.To_Unbounded_String("XML-Mast-Model-File"))
      then
         raise Mast_XML_Exceptions.Not_A_Mast_XML_File;
      end if;
      if  (Ada.Strings.Unbounded.To_String(Version) /=
           Ada.Strings.Unbounded.To_Unbounded_String("1.1"))
      then
         raise Mast_XML_Exceptions.Incorrect_Version;
      end if;
      -- Model name and Date Analysis. --
      Mast_System.Model_Name:=Var_Strings.To_Var_String
        (Dom.Core.Elements.Get_Attribute
         (Dom.Core.Nodes.Item
          (Dom.Core.Documents.Get_Elements_By_Tag_Name
           (Tree,"mast_mdl:MAST_MODEL"),0),"Model_Name"));

      Mast_System.Model_Date:=Dom.Core.Elements.Get_Attribute
        (Dom.Core.Nodes.Item(Dom.Core.Documents.Get_Elements_By_Tag_Name
                             (Tree,"mast_mdl:MAST_MODEL"),0),"Model_Date");
      -- Get the list of elements for each kind of structure
      -- and give it to the respective "Add" procedure.
      -- Each "Add" procedure adds all the elements of a determined kind
      --of structure that appear in the XML file to the Mast_System structure.
      Parent:=Dom.Core.Nodes.Item
        (Dom.Core.Documents.Get_Elements_By_Tag_Name
         (Tree,"mast_mdl:MAST_MODEL"),0);
      for Mast_El in Mast_Root_Elements
      loop
         Element_Kind_Lst:=Dom.Core.Elements.Get_Elements_By_Tag_Name
           (Parent,Mast_Root_Element_Tag(Mast_El));
         I:=0;
         while I<Dom.Core.Nodes.Length(Element_Kind_Lst)
         loop
            Act_Root:=Dom.Core.Nodes.Item(Element_Kind_Lst,I);
            I:=I+1;
            Mast_Root_Adds
              (Mast_Root_Elements'Value(Dom.Core.Nodes.Local_Name(Act_Root)))
              (Mast_System,Act_Root);
         end loop;
      end loop;
      Mast_XML_Exceptions.Report_Errors;
      Mast.Systems.Adjust(Mast_System);
   exception
      when Mast_XML_Exceptions.Not_A_Mast_XML_File =>
         Ada.Text_IO.Put_Line
           ("The MAST  XML input file is not a Mast_Model_File");
         raise Mast_XML_Exceptions.Syntax_Error;
      when Mast_XML_Exceptions.Incorrect_Version =>
         Ada.Text_IO.Put_Line
           ("The MAST XML input file has an unsupported version tag");
         raise Mast_XML_Exceptions.Syntax_Error;
      when Mast_XML_Exceptions.Parser_Detected_Error =>
         Ada.Text_IO.Put_Line
           ("The MAST XML input file has errors detected by the parser");
         raise Mast_XML_Exceptions.Syntax_Error;
      when Non_Existing | Mast_XML_Exceptions.Syntax_Error =>
         Ada.Text_Io.Put_Line
           ("Syntax error while processing the MAST XML input file");
         Ada.Text_Io.Put_Line
           ("Use an XML validation tool to find about the errors");
         raise Mast_XML_Exceptions.Syntax_Error;
      when Mast.Object_Not_Found =>
         Ada.Text_IO.Put_Line(Mast.Get_Exception_Message);
         raise Mast_XML_Exceptions.Syntax_Error;
      when others =>
         Ada.Text_Io.Put_Line
           ("The MAST XML input file has possible syntactic errors");
         Ada.Text_Io.Put_Line
           ("Use an XML validation tool to find about the errors");
         raise Mast_XML_Exceptions.Syntax_Error;
   end Parse;

end Mast_XML_Parser;
