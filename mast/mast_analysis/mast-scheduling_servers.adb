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
--          Julio Luis Medina      medinajl@unican.es                --
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

with Mast.Schedulers.Primary, Mast.Schedulers.Secondary,
  Mast.Scheduling_Policies,MAST.IO;
package body MAST.Scheduling_Servers is

   use type Results.Sched_Params_Result_Ref;
   use type Results.Synch_Params_Result_Ref;
   use type Scheduling_Parameters.Sched_Parameters_Ref;
   use type Synchronization_Parameters.Synch_Parameters_Ref;
   use type Schedulers.Scheduler_Ref;
   use type Schedulers.Lists.Index;
   use type Lists.Index;

   Names_Length : constant Positive := 26;

   -----------
   -- Clone --
   -----------

   function Clone
     (The_List : in Lists.List)
     return Lists.List
   is
      The_Copy : Lists.List;
      Iterator : Lists.Iteration_Object;
      Srvr_Ref, Srvr_Ref_Copy : Scheduling_Server_Ref;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Srvr_Ref,The_List,Iterator);
         Srvr_Ref_Copy:=Clone(Srvr_Ref.all);
         Lists.Add(Srvr_Ref_Copy,The_Copy);
      end loop;
      return The_Copy;
   end Clone;


   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (The_List : in Lists.List;
      Scheduler_List : in Schedulers.Lists.List)
   is
      Iterator : Lists.Iteration_Object;
      Srvr_Ref : Scheduling_Server_Ref;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Srvr_Ref,The_List,Iterator);
         Adjust(Srvr_Ref.all,Scheduler_List);
      end loop;
   end Adjust;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (Srvr : in out Scheduling_Server;
      Scheduler_List : in Schedulers.Lists.List)
   is
      The_Index : Schedulers.Lists.Index;
   begin
      -- adjust pointers to schedulers
      if Srvr.Server_Scheduler/=null then
         The_Index:=Schedulers.Lists.Find
           (Schedulers.Name(Srvr.Server_Scheduler),Scheduler_List);
         if The_Index=Schedulers.Lists.Null_Index then
            Set_Exception_Message
              ("Error: Scheduler "&
               Var_Strings.To_String(Schedulers.Name(Srvr.Server_Scheduler))&
               " referenced in Scheduling_Server "&
               Var_Strings.To_String(Srvr.Name)&" not found");
            raise Object_Not_Found;
         else
            Srvr.Server_Scheduler:=
              Schedulers.Lists.Item(The_Index,Scheduler_List);
         end if;
      end if;
      -- add pointers to synch parameters if missing
      --if Srvr.Server_Synch_Parameters=null then
      --   Srvr.Server_Synch_Parameters:=
      --     new Mast.Synchronization_Parameters.SRP_Parameters;
      --end if;
   end Adjust;


   ----------------
   -- Adjust_Ref --
   ----------------

   procedure Adjust_Ref
     (Srvr_Ref : in out Scheduling_Server_Ref;
      The_List : in Lists.List)
   is
      Ind : Lists.Index;
   begin
      if Srvr_Ref/=null then
         Ind:=Lists.Find(Srvr_Ref.Name,The_List);
         if Ind=Lists.Null_Index then
            Set_Exception_Message
              ("Scheduling_Server "&Var_Strings.To_String(Srvr_Ref.Name)&
               " not found");
            raise Object_Not_Found;
         else
            Srvr_Ref:=Lists.Item(Ind,The_List);
         end if;
      end if;
   end Adjust_Ref;

   -----------
   -- Clone --
   -----------

   function Clone
     (Srvr : Scheduling_Server)
     return  Scheduling_Server_Ref
   is
      Srvr_Ref : Scheduling_Server_Ref;
   begin
      Srvr_Ref := new Scheduling_Server'(Srvr);
      if Srvr.Server_Sched_Parameters/= null then
         Srvr_Ref.Server_Sched_Parameters:=
           Scheduling_Parameters.Clone(Srvr.Server_Sched_Parameters.all);
      end if;
      if Srvr.Server_Synch_Parameters/= null then
         Srvr_Ref.Server_Synch_Parameters:=
           Synchronization_Parameters.Clone(Srvr.Server_Synch_Parameters.all);
      end if;
      Srvr_Ref.The_Sched_Params_Result:=null;
      Srvr_Ref.The_Synch_Params_Result:=null;
      return Srvr_Ref;
   end Clone;

   -----------------------------
   -- Get_Min_System_Priority --
   -----------------------------

   function Get_Min_System_Priority
     (The_List : Lists.List)
     return Priority
   is
      Iterator : Lists.Iteration_Object;
      Srvr_Ref : Scheduling_Server_Ref;
      Prio : Priority;
      Min_Prio : Priority:=Priority'Last;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Srvr_Ref,The_List,Iterator);
         if Srvr_Ref.Server_Sched_Parameters.all not in
           Scheduling_Parameters.Fixed_Priority_Parameters'Class
         then
            raise Incorrect_Object;
         end if;
         Prio:=Scheduling_Parameters.The_Priority
           (Scheduling_Parameters.Fixed_Priority_Parameters
            (Srvr_Ref.Server_Sched_Parameters.all));
         if Prio < Min_Prio then
            Min_Prio:=Prio;
         end if;
      end loop;
      return Min_Prio;
   end Get_Min_System_Priority;


   ----------
   -- Init --
   ----------

   procedure Init
     (Srvr : in out Scheduling_Server;
      Name : Var_Strings.Var_String)
   is
   begin
      Srvr.Name:=Name;
   end Init;

   ----------
   -- Name --
   ----------

   function Name (Srvr : Scheduling_Server)
                 return Var_Strings.Var_String is
   begin
      return Srvr.Name;
   end Name;

   ----------
   -- Name --
   ----------

   function Name
     (Srvr_Ref : Scheduling_Server_Ref)
     return Var_Strings.Var_String
   is
   begin
      return Srvr_Ref.Name;
   end Name;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Scheduling_Server;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      if Complete then
         Ada.Text_IO.Put_Line(File,"Scheduling_Server (");
      else
         Ada.Text_IO.Put(File,"  (");
      end if;
      MAST.IO.Print_Arg
        (File,"Type",
         "Regular",Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Res.Name),Indentation+3,Names_Length);
      if Res.Server_Sched_Parameters/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg(File,"Server_Sched_Parameters","",
                           Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File,"");
         MAST.Scheduling_Parameters.Print
           (File,Res.Server_Sched_Parameters.all,Indentation+6);
      end if;
      if Res.Server_Synch_Parameters/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg(File,"Synchronization_Parameters","",
                           Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File,"");
         MAST.Synchronization_Parameters.Print
           (File,Res.Server_Synch_Parameters.all,Indentation+6);
      end if;
      if Res.Server_Scheduler/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Scheduler",
            IO.Name_Image(MAST.Schedulers.Name
                          (Res.Server_Scheduler)),
            Indentation+3,Names_Length);
      end if;
      if Complete then
         MAST.IO.Print_Separator(File,MAST.IO.Comma,Finalize);
         if Finalize then
            Ada.Text_IO.New_Line(File);
         end if;
      else
         Ada.Text_IO.Put(File,")");
      end if;
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Scheduling_Server_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print(File,Res_Ref.all,Indentation,True);
         -- Ada.Text_IO.New_Line(File);
      end loop;
   end Print;

   --------------------------------
   -- Print_Results              --
   --------------------------------

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      Sch : Scheduling_Server;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant := 8;
   begin
      -- Print only if there are results
      if Sch.The_Sched_Params_Result/=null
        or else Sch.The_Synch_Params_Result/=null
      then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put(File,"Scheduling_Server (");
         MAST.IO.Print_Arg
           (File,"Name",
            IO.Name_Image(Sch.Name),Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Results","",Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File,MAST.IO.Nothing);
         MAST.IO.Print_List_Item(File,MAST.IO.Left_Paren,
                                 Indentation+7);
         if Sch.The_Sched_Params_Result/=null and then
           Results.Sched_Params(Sch.The_Sched_Params_Result.all)/=null
         then
            Results.Print(File,Sch.The_Sched_Params_Result.all,Indentation+8);
            if Sch.The_Synch_Params_Result=null or else
              Results.Synch_Params(Sch.The_Synch_Params_Result.all)=null
            then
               Ada.Text_IO.Put(File,")");
            else
               MAST.IO.Print_Separator(File,MAST.IO.Comma);
            end if;
         end if;
         if Sch.The_Synch_Params_Result/=null and then
           Results.Synch_Params(Sch.The_Synch_Params_Result.all)/=null
         then
            Results.Print(File,Sch.The_Synch_Params_Result.all,Indentation+8);
            Ada.Text_IO.Put(File,")");
         end if;
         MAST.IO.Print_Separator(File,MAST.IO.Nothing,Finalize);
         Ada.Text_IO.New_Line(File);
      end if;
   end Print_Results;

   --------------------------------
   -- Print_Results              --
   --------------------------------

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Sch_Ref : Scheduling_Server_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Sch_Ref,The_List,Iterator);
         Print_Results(File,Sch_Ref.all,Indentation,True);
      end loop;
   end Print_Results;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Scheduling_Server;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_mdl:Regular_Scheduling_Server ");
      Ada.Text_IO.Put(File,"Name=""" & IO.Name_Image(Res.Name) & """ ");
      if Res.Server_Scheduler/=null then
         Ada.Text_IO.Put
           (File,"Scheduler=""" &
            IO.Name_Image(MAST.Schedulers.Name(Res.Server_Scheduler)) &
            """ >");
      end if;
      if Res.Server_Sched_Parameters/=null then
         MAST.Scheduling_Parameters.Print_XML
           (File,Res.Server_Sched_Parameters.all,Indentation+3,False);
      end if;
      if Res.Server_Synch_Parameters/=null then
         MAST.Synchronization_Parameters.Print_XML
           (File,Res.Server_Synch_Parameters.all,Indentation+3,False);
      end if;
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put_Line(File,"</mast_mdl:Regular_Scheduling_Server>");
   end Print_XML;

   -----------
   -- Print_XML --
   -----------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Scheduling_Server_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print_XML(File,Res_Ref.all,Indentation,True);
      end loop;
   end Print_XML;


   --------------------------------
   -- Print_XML_Results          --
   --------------------------------

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      Sch : Scheduling_Server;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant := 8;
   begin
      -- Print only if there are results
      if (Sch.The_Sched_Params_Result/=null and then
          Results.Sched_Params(Sch.The_Sched_Params_Result.all)/=null) or else
        (Sch.The_Synch_Params_Result/=null and then
         Results.Synch_Params(Sch.The_Synch_Params_Result.all)/=null)
      then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put_Line
           (File,"<mast_res:Scheduling_Server Name="""&
            IO.Name_Image(Sch.Name) & """>");
         if Sch.The_Sched_Params_Result/=null and then
           Results.Sched_Params(Sch.The_Sched_Params_Result.all)/=null
         then
            Results.Print_XML
              (File,Sch.The_Sched_Params_Result.all,Indentation+3,False);
         end if;
         if Sch.The_Synch_Params_Result/=null and then
           Results.Synch_Params(Sch.The_Synch_Params_Result.all)/=null
         then
            Results.Print_XML
              (File,Sch.The_Synch_Params_Result.all,Indentation+3,False);
         end if;
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put_Line(File,"</mast_res:Scheduling_Server>");
      end if;
   end Print_XML_Results;

   --------------------------------
   -- Print_XML_Results          --
   --------------------------------

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Sch_Ref : Scheduling_Server_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Sch_Ref,The_List,Iterator);
         Print_XML_Results(File,Sch_Ref.all,Indentation,True);
      end loop;
   end Print_Xml_Results;

   -----------------------------
   -- Server_Scheduler --
   -----------------------------

   function Server_Scheduler
     (Srvr : Scheduling_Server)
     return MAST.Schedulers.Scheduler_Ref
   is
   begin
      return Srvr.Server_Scheduler;
   end Server_Scheduler;

   --------------------------------
   -- Server_Processing_Resource --
   --------------------------------

   function Server_Processing_Resource
     (Srvr : Scheduling_Server)
     return MAST.Processing_Resources.Processing_Resource_Ref
   is
   begin
      if Srvr.Server_Scheduler.all in
        Schedulers.Primary.Primary_Scheduler'Class
      then
         return Schedulers.Primary.Host
           (Schedulers.Primary.Primary_Scheduler'Class
            (Srvr.Server_Scheduler.all));
      else -- secondary scheduler
         return Server_Processing_Resource
           (Schedulers.Secondary.Server
            (Schedulers.Secondary.Secondary_Scheduler'Class
             (Srvr.Server_Scheduler.all)).all);
      end if;
   end Server_Processing_Resource;

   -----------------------------
   -- Server_Sched_Parameters --
   -----------------------------

   function Server_Sched_Parameters
     (Srvr : Scheduling_Server)
     return MAST.Scheduling_Parameters.Sched_Parameters_Ref
   is
   begin
      return Srvr.Server_Sched_Parameters;
   end Server_Sched_Parameters;

   -----------------------------
   -- Server_Synch_Parameters --
   -----------------------------

   function Server_Synch_Parameters
     (Srvr : Scheduling_Server)
     return MAST.Synchronization_Parameters.Synch_Parameters_Ref
   is
   begin
      return Srvr.Server_Synch_Parameters;
   end Server_Synch_Parameters;

   --------------------------
   -- Set_Server_Scheduler --
   --------------------------

   procedure Set_Server_Scheduler
     (Srvr : in out Scheduling_Server;
      The_Server_Scheduler :
      MAST.Schedulers.Scheduler_Ref)
   is
   begin
      Srvr.Server_Scheduler:=The_Server_Scheduler;
   end Set_Server_Scheduler;


   ---------------------------------
   -- Set_Server_Sched_Parameters --
   ---------------------------------

   procedure Set_Server_Sched_Parameters
     (Srvr : in out Scheduling_Server;
      The_Server_Sched_Parameters :
      MAST.Scheduling_Parameters.Sched_Parameters_Ref)
   is
   begin
      Srvr.Server_Sched_Parameters:=The_Server_Sched_Parameters;
   end Set_Server_Sched_Parameters;

   ---------------------------------
   -- Set_Server_Synch_Parameters --
   ---------------------------------

   procedure Set_Server_Synch_Parameters
     (Srvr : in out Scheduling_Server;
      The_Server_Synch_Parameters :
      MAST.Synchronization_Parameters.Synch_Parameters_Ref)
   is
   begin
      Srvr.Server_Synch_Parameters:=The_Server_Synch_Parameters;
   end Set_Server_Synch_Parameters;

   -----------------------------
   -- Set_Sched_Params_Result --
   -----------------------------

   procedure Set_Sched_Params_Result
     (Sch : in out Scheduling_Server;
      Res : Results.Sched_Params_Result_Ref)
   is
   begin
      Sch.The_Sched_Params_Result:=Res;
   end Set_Sched_Params_Result;

   -----------------------------
   -- Set_Synch_Params_Result --
   -----------------------------

   procedure Set_Synch_Params_Result
     (Sch : in out Scheduling_Server;
      Res : Results.Synch_Params_Result_Ref)
   is
   begin
      Sch.The_Synch_Params_Result:=Res;
   end Set_Synch_Params_Result;

   -------------------------
   -- Sched_Params_Result --
   -------------------------

   function Sched_Params_Result
     (Sch : Scheduling_Server)
     return Results.Sched_Params_Result_Ref
   is
   begin
      return Sch.The_Sched_Params_Result;
   end Sched_Params_Result;

   -------------------------
   -- Synch_Params_Result --
   -------------------------

   function Synch_Params_Result
     (Sch : Scheduling_Server)
     return Results.Synch_Params_Result_Ref
   is
   begin
      return Sch.The_Synch_Params_Result;
   end Synch_Params_Result;

   --------------------------------
   -- Set_Scheduler_State        --
   --------------------------------

   procedure Set_Scheduler_State
     (Srvr : in out Scheduling_Server;
      Has_Scheduler : in Boolean)
   is
   begin
      Srvr.Scheduler_Present:=Has_Scheduler;
   end Set_Scheduler_State;

   --------------------------------
   -- Has_Scheduler              --
   --------------------------------

   function Has_Scheduler
     (Srvr : Scheduling_Server)
     return Boolean
   is
   begin
      return Srvr.Scheduler_Present;
   end Has_Scheduler;

   --------------------------------
   -- Base_Level                 --
   --------------------------------

   function Base_Level
     (Srvr : Scheduling_Server)
     return Preemption_Level
   is
   begin
      if Schedulers.Scheduling_Policy(Srvr.Server_Scheduler.all).all in
        Scheduling_Policies.EDF_Policy'Class
      then
         if Srvr.Server_Synch_Parameters=null then
            return Preemption_Level'First;
         else
            return Synchronization_Parameters.The_Preemption_Level
              (Synchronization_Parameters.SRP_Parameters'Class
               (Srvr.Server_Synch_Parameters.all));
         end if;
      else
         -- non EDF policy
         return Preemption_Level'First;
      end if;
   end Base_Level;

   --------------------------------
   -- Base_Priority              --
   --------------------------------

   function Base_Priority
     (Srvr : Scheduling_Server)
     return Priority
   is
   begin
      if Srvr.Server_Scheduler.all in Schedulers.Primary.Primary_Scheduler then
         if Schedulers.Scheduling_Policy(Srvr.Server_Scheduler.all).all in
           Scheduling_Policies.Fixed_Priority_Policy'Class
         then
            return Scheduling_Parameters.The_Priority
              (Scheduling_Parameters.Fixed_Priority_Parameters'Class
               (Srvr.Server_Sched_Parameters.all));
         else
            -- EDF policy
            return Priority'First;
         end if;
      else
         -- secondary scheduler
         return Base_Priority
           (Schedulers.Secondary.Server
            (Schedulers.Secondary.Secondary_Scheduler
             (Srvr.Server_Scheduler.all)).all);
      end if;
   end Base_Priority;

   --------------------------------
   -- List_References_Scheduler  --
   --------------------------------

   function List_References_Scheduler
     (Sched_Ref : Mast.Schedulers.Scheduler_Ref;
      The_List : Lists.List)
     return Boolean
   is
      Ss_Ref : Scheduling_Server_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Ss_Ref,The_List,Iterator);
         if Ss_Ref.Server_Scheduler=Sched_Ref then
            return True;
         end if;
      end loop;
      return False;
   end List_References_Scheduler;

end MAST.Scheduling_Servers;
