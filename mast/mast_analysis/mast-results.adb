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
--          Julio Medina Pasaje    medinajl@unican.es                --
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

with List_Exceptions, MAST.Graphs.Links, MAST.IO,
  Ada.Strings,Ada.Strings.Fixed,Ada.Text_IO,Ada.Float_Text_IO;
use Ada.Strings,Ada.Strings.Fixed,Ada.Text_IO,Ada.Float_Text_IO;

package body MAST.Results is

   use type MAST.Graphs.Link_Ref;
   use type Scheduling_Parameters.Sched_Parameters_Ref;
   use type Synchronization_Parameters.Synch_Parameters_Ref;

   Names_Length : constant Positive := 29;

   -----------------
   -- Application --
   -----------------

   function Application
     (Res : Detailed_Utilization_Result)
     return Percentage
   is
   begin
      return Res.Application_Util;
   end Application;

   --------------------------------
   -- Avg_Global_Response_Time --
   --------------------------------

   function Avg_Global_Response_Time
     (The_Result : Simulation_Timing_Result;
      The_Event : MAST.Events.Event_Ref)
     return Time
   is
      Params : Simulation_Parameters;
   begin
      Params:=Sim_Params_Lists.Item
        (The_Event,The_Result.Global_Simulation_Times);
      return Params.Sum_Of_Simulation_Times/
        Time(Params.Num_Of_Simulation_Times);
   exception
      when List_Exceptions.Invalid_Index =>
         raise No_Results_For_Event;
   end Avg_Global_Response_Time;

   ------------------------------
   -- Avg_Global_Response_Time --
   ------------------------------

   function Avg_Global_Response_Time
     (The_Result : Simulation_Timing_Result)
     return Time
   is
      Params : Simulation_Parameters;
   begin
      Params:=Sim_Params_Lists.First_Item
        (The_Result.Global_Simulation_Times);
      return Params.Sum_Of_Simulation_Times/
        Time(Params.Num_Of_Simulation_Times);
   exception
      when List_Exceptions.Empty =>
         raise No_Results_For_Event;
   end Avg_Global_Response_Time;

   -----------------------------
   -- Avg_Local_Response_Time --
   -----------------------------

   function Avg_Local_Response_Time
     (The_Result : Simulation_Timing_Result)
     return Time
   is
   begin
      return The_Result.Local_Simulation_Time.
        Sum_Of_Simulation_Times/
        Time(The_Result.Local_Simulation_Time.
             Num_Of_Simulation_Times);
   end Avg_Local_Response_Time;

   -------------------------------
   -- Best_Global_Response_Time --
   -------------------------------

   function Best_Global_Response_Time
     (The_Result : Timing_Result;
      The_Event : MAST.Events.Event_Ref)
     return Time
   is
   begin
      return Time_Result_Lists.Item
        (The_Event,The_Result.Best_Global_Response_Times);
   exception
      when List_Exceptions.Invalid_Index =>
         raise No_Results_For_Event;
   end Best_Global_Response_Time;

   -------------------------------
   -- Best_Global_Response_Time --
   -------------------------------

   function Best_Global_Response_Time
     (The_Result : Timing_Result)
     return Time
   is
   begin
      return Time_Result_Lists.First_Item
        (The_Result.Best_Global_Response_Times);
   exception
      when List_Exceptions.Empty =>
         raise No_Results_For_Event;
   end Best_Global_Response_Time;

   -------------------------------
   -- Best_Local_Response_Time --
   -------------------------------

   function Best_Local_Response_Time
     (The_Result : Timing_Result) return Time
   is
   begin
      return The_Result.Best_Local_Response_Time;
   end Best_Local_Response_Time;

   -------------
   -- Ceiling --
   -------------

   function Ceiling (Res : Ceiling_Result) return Priority is
   begin
      return Res.The_Ceiling;
   end Ceiling;

   --------------------
   -- Context_Switch --
   --------------------

   function Context_Switch
     (Res : Detailed_Utilization_Result)
     return Percentage
   is
   begin
      return Res.Context_Switch_Util;
   end Context_Switch;

   -------------------------------------
   -- Create_Simulation_Timing_Result --
   -------------------------------------

   function Create_Simulation_Timing_Result
     (The_Link_Ref : MAST.Graphs.Link_Ref)
     return Timing_Result_Ref
   is
      Res_Ref : Timing_Result_Ref;
   begin
      Res_Ref  := new Simulation_Timing_Result;
      MAST.Graphs.Links.Set_Link_Time_Results
        (Mast.Graphs.Links.Regular_Link(The_Link_Ref.all),
         Res_Ref);
      Set_Link(Timing_Result'Class(Res_Ref.all),The_Link_Ref);
      return Res_Ref;
   end Create_Simulation_Timing_Result;

   -------------------------------------
   -- Create_Timing_Result --
   -------------------------------------

   function Create_Timing_Result
     (The_Link_Ref : MAST.Graphs.Link_Ref)
     return Timing_Result_Ref
   is
      Res_Ref : Timing_Result_Ref;
   begin
      Res_Ref  := new Timing_Result;
      MAST.Graphs.Links.Set_Link_Time_Results
        (Mast.Graphs.Links.Regular_Link(The_Link_Ref.all),
         Res_Ref);
      Set_Link(Timing_Result'Class(Res_Ref.all),The_Link_Ref);
      return Res_Ref;
   end Create_Timing_Result;

   ------------
   -- Driver --
   ------------

   function Driver
     (Res : Detailed_Utilization_Result)
     return Percentage
   is
   begin
      return Res.Driver_Util;
   end Driver;

   ---------------------------------------
   -- Get_Next_Global_Simulation_Times --
   ---------------------------------------

   procedure Get_Next_Global_Simulation_Times
     (The_Result : in Simulation_Timing_Result;
      The_Event : out MAST.Events.Event_Ref;
      Global_Simulation_Params : out Simulation_Parameters;
      Iterator : in out Sim_Iteration_Object)
   is
   begin
      Sim_Params_Lists.Get_Next_Item
        (The_Event,Global_Simulation_Params,
         The_Result.Global_Simulation_Times,
         Sim_Params_Lists.Iteration_Object(Iterator));
   end Get_Next_Global_Simulation_Times;

   -------------------------------
   -- Get_Next_Local_Miss_Ratio --
   -------------------------------

   procedure Get_Next_Local_Miss_Ratio
     (The_Result : in Simulation_Timing_Result;
      The_Deadline : out Time;
      The_Ratio : out Percentage;
      Iterator : in out Local_Ratio_Iteration_Object)
   is
      The_Data : Miss_Ratio_Data;
   begin
      Miss_Ratio_Lists.Get_Next_Item
        (The_Deadline, The_Data,
         The_Result.Local_Miss_Ratios,
         Miss_Ratio_Lists.Iteration_Object(Iterator));
      The_Ratio:=100.0*Float(The_Data.Num_Missed)/Float(The_Data.Total);
   end Get_Next_Local_Miss_Ratio;

   -------------------------------
   -- Get_Next_Global_Miss_Ratio --
   -------------------------------

   procedure Get_Next_Global_Miss_Ratio
     (The_Result : in Simulation_Timing_Result;
      The_Deadline : out Time;
      The_Event : out MAST.Events.Event_Ref;
      The_Ratio : out Percentage;
      Iterator : in out Global_Ratio_Iteration_Object)
   is
      The_Data : Miss_Ratio_Data;
   begin
      if Iterator.Current_List=null then
         raise List_Exceptions.No_More_Items;
      else
         begin
            Miss_Ratio_Lists.Get_Next_Item
              (The_Deadline, The_Data,
               Iterator.Current_List.all,Iterator.Miss_List_Iterator);
            The_Ratio:=100.0*Float(The_Data.Num_Missed)/Float(The_Data.Total);
            The_Event:=Iterator.Current_Event;
         exception
            when List_Exceptions.No_More_Items =>
               List_Of_Miss_Lists.Get_Next_Item
                 (Iterator.Current_Event,Iterator.Current_List,
                  The_Result.Global_Miss_Ratios,
                  Iterator.List_Of_Lists_Iterator);
               Miss_Ratio_Lists.Rewind
                 (Iterator.Current_List.all,Iterator.Miss_List_Iterator);
               Get_Next_Global_Miss_Ratio
                 (The_Result,The_Deadline,The_Event,The_Ratio,Iterator);
         end;
      end if;
   end Get_Next_Global_Miss_Ratio;

   ----------------------------------------
   -- Get_Next_Global_Timing_Parameters --
   ----------------------------------------

   procedure Get_Next_Global_Timing_Parameters
     (The_Result : in Timing_Result;
      The_Event : out MAST.Events.Event_Ref;
      Timing_Params : out Timing_Parameters;
      Iterator : in out Time_Iteration_Object)
   is
   begin
      Time_Result_Lists.Get_Next_Item
        (The_Event,Timing_Params.Worst_Response_Time,
         The_Result.Worst_Global_Response_Times,Iterator.Worst);
      Time_Result_Lists.Get_Next_Item
        (The_Event,Timing_Params.Best_Response_Time,
         The_Result.Best_Global_Response_Times,Iterator.Best);
      Time_Result_Lists.Get_Next_Item
        (The_Event,Timing_Params.Jitter,
         The_Result.Jitters,Iterator.Jitters);
   end Get_Next_Global_Timing_Parameters;

   -----------------------
   -- Global_Miss_Ratio --
   -----------------------

   function Global_Miss_Ratio
     (The_Result : Simulation_Timing_Result;
      The_Deadline : Time;
      The_Event : MAST.Events.Event_Ref)
     return Percentage
   is
      The_List : List_Ref;
      The_Data : Miss_Ratio_Data;
   begin
      begin
         The_List:=List_Of_Miss_Lists.Item
           (The_Event,The_Result.Global_Miss_Ratios);
      exception
         when List_Exceptions.Invalid_Index =>
            raise No_Results_For_Event;
      end;
      The_Data:=Miss_Ratio_Lists.Item(The_Deadline,The_List.all);
      return 100.0*Float(The_Data.Num_Missed)/Float(The_Data.Total);
   exception
      when List_Exceptions.Invalid_Index =>
         raise No_Results_For_Deadline;
   end Global_Miss_Ratio;

   ------------
   -- Jitter --
   ------------

   function Jitter
     (The_Result : Timing_Result;
      The_Event : MAST.Events.Event_Ref)
     return Time
   is
   begin
      return Time_Result_Lists.Item
        (The_Event,The_Result.Jitters);
   exception
      when List_Exceptions.Invalid_Index =>
         raise No_Results_For_Event;
   end Jitter;

   ------------
   -- Jitter --
   ------------

   function Jitter
     (The_Result : Timing_Result)
     return Time
   is
   begin
      return Time_Result_Lists.First_Item
        (The_Result.Jitters);
   exception
      when List_Exceptions.Empty =>
         raise No_Results_For_Event;
   end Jitter;

   -----------------------
   -- Link_Of           --
   -----------------------

   function Link_Of
     (The_Result : Timing_Result)
     return MAST.Graphs.Link_Ref
   is
   begin
      return The_Result.The_Link;
   end Link_Of;

   ----------------------
   -- Local_Miss_Ratio --
   ----------------------

   function Local_Miss_Ratio
     (The_Result : Simulation_Timing_Result;
      The_Deadline : Time)
     return Percentage
   is
      The_Data : Miss_Ratio_Data;
   begin
      The_Data:= Miss_Ratio_Lists.Item
        (The_Deadline,The_Result.Local_Miss_Ratios);
      return 100.0*Float(The_Data.Num_Missed)/Float(The_Data.Total);
   exception
      when List_Exceptions.Invalid_Index =>
         raise No_Results_For_Deadline;
   end Local_Miss_Ratio;


   -------------
   -- Max_Num --
   -------------

   function Max_Num (Res : Queue_Size_Result) return Natural is
   begin
      return Res.The_Max_Num;
   end Max_Num;

   ---------------------------------------
   -- Num_Of_Global_Timing_Parameters --
   ---------------------------------------

   function Num_Of_Global_Timing_Parameters
     (The_Result : Timing_Result)
     return Natural
   is
   begin
      return Time_Result_Lists.Size
        (The_Result.Worst_Global_Response_Times);
   end Num_Of_Global_Timing_Parameters;

   --------------------------------------
   -- Num_Of_Global_Simulation_Times --
   --------------------------------------

   function Num_Of_Global_Simulation_Times
     (The_Result : Simulation_Timing_Result)
     return Natural
   is
   begin
      return Sim_Params_Lists.Size
        (The_Result.Global_Simulation_Times);
   end Num_Of_Global_Simulation_Times;

   ------------------------------
   -- Num_Of_Local_Miss_Ratios --
   ------------------------------

   function Num_Of_Local_Miss_Ratios
     (The_Result : Simulation_Timing_Result)
     return Natural
   is
   begin
      return Miss_Ratio_Lists.Size
        (The_Result.Local_Miss_Ratios);
   end Num_Of_Local_Miss_Ratios;

   -------------------------------
   -- Num_Of_Global_Miss_Ratios --
   -------------------------------

   function Num_Of_Global_Miss_Ratios
     (The_Result : Simulation_Timing_Result)
     return Natural
   is
      Count : Natural:=0;
      The_List : List_Ref;
      The_Event : MAST.Events.Event_Ref;
      Iterator : List_Of_Miss_Lists.Iteration_Object;
   begin
      List_Of_Miss_Lists.Rewind(The_Result.Global_Miss_Ratios,Iterator);
      for I in 1..List_Of_Miss_Lists.Size(The_Result.Global_Miss_Ratios)
      loop
         List_Of_Miss_Lists.Get_Next_Item
           (The_Event,The_List,The_Result.Global_Miss_Ratios,Iterator);
         Count:=Count+Miss_Ratio_Lists.Size(The_List.all);
      end loop;
      return Count;
   end Num_Of_Global_Miss_Ratios;

   ------------------------
   -- Num_Of_Suspensions
   ------------------------

   function Num_Of_Suspensions
     (The_Result : Timing_Result) return Natural
   is
   begin
      return The_Result.Num_Of_Suspensions;
   end Num_Of_Suspensions;

   --------------
   -- Pathname --
   --------------

   function Pathname (Res : Trace_Result) return String is
   begin
      return Var_Strings.To_String(Res.The_Pathname);
   end Pathname;

   ----------------------
   -- Preemption_Level --
   ----------------------

   function Preemption_Level
     (Res : Preemption_Level_Result)
     return Mast.Preemption_Level
   is
   begin
      return Res.The_Preemption_Level;
   end Preemption_Level;

   -----------
   -- Print --
   -----------

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Slack_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Integer := 6;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
      MAST.IO.Print_Arg
        (File,"Type","Slack",Indentation+1,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Value",IO.Slack_Image(Res.The_Slack),
         Indentation+1,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Trace_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Integer := 10;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
      MAST.IO.Print_Arg
        (File,"Type","Trace",Indentation+1,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Pathname",Var_Strings.To_String(Res.The_Pathname),
         Indentation+1,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Utilization_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Integer := 6;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
      MAST.IO.Print_Arg
        (File,"Type","Utilization",Indentation+1,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Total",IO.Percentage_Image(Res.Total_Util),
         Indentation+1,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Detailed_Utilization_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Integer := 15;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
      MAST.IO.Print_Arg
        (File,"Type","Detailed_Utilization",Indentation+1,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Total",IO.Percentage_Image(Res.Total_Util),
         Indentation+1,Names_Length);
      if Res.Is_Detailed then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Application",IO.Percentage_Image(Res.Application_Util),
            Indentation+1,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Context_Switch",IO.Percentage_Image(Res.Context_Switch_Util),
            Indentation+1,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Timer",IO.Percentage_Image(Res.Timer_Util),
            Indentation+1,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Driver",IO.Percentage_Image(Res.Driver_Util),
            Indentation+1,Names_Length);
      end if;
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Queue_Size_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Integer := 8;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
      MAST.IO.Print_Arg
        (File,"Type","Queue_Size",Indentation+1,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Max_Num",Integer'Image(Res.The_Max_Num),
         Indentation+1,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Ready_Queue_Size_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Integer := 8;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
      MAST.IO.Print_Arg
        (File,"Type","Ready_Queue_Size",Indentation+1,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Max_Num",Integer'Image(Res.The_Max_Num),
         Indentation+1,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Sched_Params_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Integer := 24;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
      MAST.IO.Print_Arg
        (File,"Type","Scheduling_Parameters",Indentation+1,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Server_Sched_Parameters","",
         Indentation+1,Names_Length);
      MAST.IO.Print_Separator(File,"");
      MAST.Scheduling_Parameters.Print
        (File,Res.The_Sched_Params.all,Indentation+6);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Synch_Params_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Integer := 23;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
      MAST.IO.Print_Arg
        (File,"Type","Synchronization_Parameters",
         Indentation+1,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Server_Synch_Parameters","",
         Indentation+1,Names_Length);
      MAST.IO.Print_Separator(File,"");
      MAST.Synchronization_Parameters.Print
        (File,Res.The_Synch_Params.all,Indentation+6);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Ceiling_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Integer := 8;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
      MAST.IO.Print_Arg
        (File,"Type","Priority_Ceiling",Indentation+1,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Ceiling",Priority'Image(Res.The_Ceiling),
         Indentation+1,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Preemption_Level_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Integer := 6;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
      MAST.IO.Print_Arg
        (File,"Type","Preemption_Level",Indentation+1,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Level",Mast.Preemption_Level'Image(Res.The_Preemption_Level),
         Indentation+1,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Time_Result_Lists.List;
      Indentation : Positive)
   is
      Names_Length : constant Integer := 16;
      The_Event : MAST.Events.Event_Ref;
      The_Time  : Time;
      Iterator : Time_Result_Lists.Iteration_Object;
   begin
      Set_Col(File,Ada.Text_IO.Count(Indentation));
      Put(File,'(');
      Time_Result_Lists.Rewind(The_List,Iterator);
      for I in 1..Time_Result_Lists.Size(The_List) loop
         if I>1 then
            MAST.IO.Print_Separator(File);
         end if;
         Time_Result_Lists.Get_Next_Item(The_Event,The_Time,The_List,
                                         Iterator);
         Set_Col(File,Ada.Text_IO.Count(Indentation+1));
         Put(File,'(');
         MAST.IO.Print_Arg
           (File,"Referenced_Event",
            IO.Name_Image(MAST.Events.Name(The_Event)),
            Indentation+2,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Time_Value",
            IO.Time_Image(The_Time),
            Indentation+2,Names_Length);
         Put(File,')');
      end loop;
      Put(File,')');
   end Print;

   -----------
   -- Print --
   -----------

   type Time_Parameter_Function is access function
     (Sim_Param : Simulation_Parameters) return String;

   function Avg_Simulation_Time
     (Sim_Param : Simulation_Parameters) return String
   is
   begin
      return IO.Time_Image
        (Sim_Param.Sum_Of_Simulation_Times/
         Time(Sim_Param.Num_Of_Simulation_Times));
   end Avg_Simulation_Time;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Sim_Params_Lists.List;
      Time_Value : Time_Parameter_Function;
      Indentation : Positive)
   is
      Names_Length : constant Integer := 16;
      The_Event : MAST.Events.Event_Ref;
      The_Params  : Simulation_Parameters;
      Iterator : Sim_Params_Lists.Iteration_Object;
   begin
      Set_Col(File,Ada.Text_IO.Count(Indentation));
      Put(File,'(');
      Sim_Params_Lists.Rewind(The_List,Iterator);
      for I in 1..Sim_Params_Lists.Size(The_List) loop
         if I>1 then
            MAST.IO.Print_Separator(File);
         end if;
         Sim_Params_Lists.Get_Next_Item(The_Event,The_Params,
                                        The_List,Iterator);
         Set_Col(File,Ada.Text_IO.Count(Indentation+1));
         Put(File,'(');
         MAST.IO.Print_Arg
           (File,"Referenced_Event",
            IO.Name_Image(MAST.Events.Name(The_Event)),
            Indentation+2,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Time_Value",
            Time_Value(The_Params),
            Indentation+2,Names_Length);
         Put(File,')');
      end loop;
      Put(File,')');
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Miss_Ratio_Lists.List;
      Indentation : Positive)
   is
      Names_Length : constant Integer := 8;
      The_Deadline : Time;
      The_Ratio    : Percentage;
      The_Data     : Miss_Ratio_Data;
      Ratio_Image : String(1..20);
      Iterator : Miss_Ratio_Lists.Iteration_Object;
   begin
      Set_Col(File,Ada.Text_IO.Count(Indentation));
      Put(File,'(');
      Miss_Ratio_Lists.Rewind(The_List,Iterator);
      for I in 1..Miss_Ratio_Lists.Size(The_List) loop
         if I>1 then
            MAST.IO.Print_Separator(File);
         end if;
         Miss_Ratio_Lists.Get_Next_Item
           (The_Deadline,The_Data,The_List,Iterator);
         The_Ratio:=100.0*Float(The_Data.Num_Missed)/Float(The_Data.Total);
         Set_Col(File,Ada.Text_IO.Count(Indentation+1));
         Put(File,'(');
         MAST.IO.Print_Arg
           (File,"Deadline",
            IO.Time_Image(The_Deadline),
            Indentation+2,Names_Length);
         MAST.IO.Print_Separator(File);
         Put(Ratio_Image,The_Ratio,2,0);
         MAST.IO.Print_Arg
           (File,"Ratio",
            Trim(Ratio_Image,Both),
            Indentation+2,Names_Length);
         Put(File,')');
      end loop;
      Put(File,')');
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out List_Of_Miss_Lists.List;
      Indentation : Positive)
   is
      Names_Length : constant Integer := 16;
      The_Event : MAST.Events.Event_Ref;
      The_Miss_List  : List_Ref;
      Iterator : List_Of_Miss_Lists.Iteration_Object;
   begin
      Set_Col(File,Ada.Text_IO.Count(Indentation));
      Put(File,'(');
      List_Of_Miss_Lists.Rewind(The_List,Iterator);
      for I in 1..List_Of_Miss_Lists.Size(The_List) loop
         if I>1 then
            MAST.IO.Print_Separator(File);
         end if;
         List_Of_Miss_Lists.Get_Next_Item
           (The_Event,The_Miss_List,The_List,Iterator);
         Set_Col(File,Ada.Text_IO.Count(Indentation+1));
         Put(File,'(');
         MAST.IO.Print_Arg
           (File,"Referenced_Event",
            IO.Name_Image(MAST.Events.Name(The_Event)),
            Indentation+2,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Miss_Ratios","",Indentation+2,Names_Length);
         New_Line(File);
         Set_Col(File,Ada.Text_IO.Count(Indentation+4));
         Print(File,The_Miss_List.all,Indentation+5);
         Put(File,')');
      end loop;
      Put(File,')');
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Timing_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
      MAST.IO.Print_Arg
        (File,"Type",
         "Timing_Result",Indentation+1,Names_Length);
      if Res.The_Link /= null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Event_Name",
            IO.Name_Image(MAST.Graphs.Name(Res.The_Link)),
            Indentation+1,Names_Length);
      end if;
      if Res.Has_Local_Response_Time then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Worst_Local_Response_Time",
            IO.Time_Image(Res.Worst_Local_Response_Time),
            Indentation+1,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Best_Local_Response_Time",
            IO.Time_Image(Res.Best_Local_Response_Time),
            Indentation+1,Names_Length);
      end if;
      if Res.Has_Worst_Blocking_Time then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Num_Of_Suspensions",
            Natural'Image(Res.Num_Of_Suspensions),
            Indentation+1,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Worst_Blocking_Time",
            IO.Time_Image(Res.Worst_Blocking_Time),
            Indentation+1,Names_Length);
      end if;
      if Time_Result_Lists.Size(Res.Worst_Global_Response_Times)>0 and then
        Res.Has_Worst_Global_Response_Times
      then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Worst_Global_Response_Times","",
            Indentation+1,Names_Length);
         New_Line(File);
         Print(File,Res.Worst_Global_Response_Times,Indentation+4);
      end if;
      if Time_Result_Lists.Size(Res.Best_Global_Response_Times)>0 and then
        Res.Has_Best_Global_Response_Times
      then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Best_Global_Response_Times","",
            Indentation+1,Names_Length);
         New_Line(File);
         Print(File,Res.Best_Global_Response_Times,Indentation+4);
      end if;
      if Time_Result_Lists.Size(Res.Jitters)>0 and then
        Res.Has_Worst_Global_Response_Times
      then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Jitters","",
            Indentation+1,Names_Length);
         New_Line(File);
         Print(File,Res.Jitters,Indentation+4);
      end if;
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Simulation_Timing_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
      MAST.IO.Print_Arg
        (File,"Type",
         "Simulation_Timing_Result",Indentation+1,Names_Length);
      if Res.The_Link /= null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Event_Name",
            IO.Name_Image(MAST.Graphs.Name(Res.The_Link)),
            Indentation,Names_Length);
      end if;
      if Res.Has_Local_Response_Time then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Worst_Local_Response_Time",
            IO.Time_Image(Res.Worst_Local_Response_Time),
            Indentation+1,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Avg_Local_Response_Time",
            Avg_Simulation_Time(Res.Local_Simulation_Time),
            Indentation+1,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Best_Local_Response_Time",
            IO.Time_Image(Res.Best_Local_Response_Time),
            Indentation+1,Names_Length);
      end if;
      if Res.Has_Worst_Blocking_Time then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Num_Of_Suspensions",
            Natural'Image(Res.Num_Of_Suspensions),
            Indentation+1,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Worst_Blocking_Time",
            IO.Time_Image(Res.Worst_Blocking_Time),
            Indentation+1,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Avg_Blocking_Time",
            IO.Time_Image(Res.The_Avg_Blocking_Time),
            Indentation+1,Names_Length);
      end if;
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Max_Preemption_Time",
         IO.Time_Image(Res.The_Max_Preemption_Time),
         Indentation+1,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Suspension_Time",
         IO.Time_Image(Res.The_Suspension_Time),
         Indentation+1,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Num_Of_Queued_Activations",
         Natural'Image(Res.The_Num_Of_Queued_Activations),
         Indentation+1,Names_Length);
      if Time_Result_Lists.Size(Res.Worst_Global_Response_Times)>0 and then
        Res.Has_Worst_Global_Response_Times
      then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Worst_Global_Response_Times","",
            Indentation+1,Names_Length);
         New_Line(File);
         Print(File,Res.Worst_Global_Response_Times,Indentation+4);
      end if;
      if Sim_Params_Lists.Size(Res.Global_Simulation_Times)>0 then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Avg_Global_Response_Times","",
            Indentation+1,Names_Length);
         New_Line(File);
         Print(File,Res.Global_Simulation_Times,
               Avg_Simulation_Time'Access,Indentation+4);
      end if;
      if Time_Result_Lists.Size(Res.Best_Global_Response_Times)>0 and then
        Res.Has_Best_Global_Response_Times
      then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Best_Global_Response_Times","",
            Indentation+1,Names_Length);
         New_Line(File);
         Print(File,Res.Best_Global_Response_Times,Indentation+4);
      end if;
      if Time_Result_Lists.Size(Res.Jitters)>0 and then
        Res.Has_Worst_Global_Response_Times
      then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Jitters","",
            Indentation+1,Names_Length);
         New_Line(File);
         Print(File,Res.Jitters,Indentation+4);
      end if;
      if Miss_Ratio_Lists.Size(Res.Local_Miss_Ratios)>0 then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Local_Miss_Ratios","",
            Indentation+1,Names_Length);
         New_Line(File);
         Print(File,Res.Local_Miss_Ratios,Indentation+4);
      end if;
      if List_Of_Miss_Lists.Size(Res.Global_Miss_Ratios)>0 then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Global_Miss_Ratios","",
            Indentation+1,Names_Length);
         New_Line(File);
         Print(File,Res.Global_Miss_Ratios,Indentation+4);
      end if;
      Ada.Text_IO.Put(File,")");
   end Print;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Slack_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put_Line
        (File,"<mast_res:Slack "&"Value=""" &
         IO.Float_Image(Res.The_Slack)& """/>");
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Trace_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put_Line
        (File,"<mast_res:Trace Pathname=""" &
         Var_Strings.To_String(Res.The_Pathname) & """/>" );
      Ada.Text_IO.New_Line(File);
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Utilization_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put_Line
        (File,"<mast_res:Utilization Total=""" &
         IO.Float_Image(Res.Total_Util)& """/>");
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------


   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Detailed_Utilization_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_res:Detailed_Utilization ");
      Ada.Text_IO.Put(File,"Total=""" &IO.Float_Image(Res.Total_Util)& """ ");
      if Res.Is_Detailed then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line
           (File,"Application=""" &IO.Float_Image(Res.Application_Util)&
            """ ");
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line
           (File,"Context_Switch=""" &
            IO.Float_Image(Res.Context_Switch_Util)& """ ");
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line
           (File,"Timer=""" &IO.Float_Image(Res.Timer_Util)& """ ");
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line
           (File,"Driver=""" &IO.Float_Image(Res.Driver_Util)& """ />");
      end if;
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Queue_Size_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put_Line
        (File,"<mast_res:Queue_Size Max_Num=""" &
         IO.Integer_Image(Res.The_Max_Num)& """/>");
   end Print_XML;

   -----------
   -- Print_XML --
   -----------

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Ready_Queue_Size_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put_Line
        (File,"<mast_res:Ready_Queue_Size Max_Num="""
         &IO.Integer_Image(Res.The_Max_Num)& """/>");
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Sched_Params_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Integer := 24;
   begin
      MAST.Scheduling_Parameters.Print_XML
        (File,Res.The_Sched_Params.all,Indentation+3,False,"mast_res");
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Synch_Params_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Integer := 23;
   begin
      MAST.Synchronization_Parameters.Print_XML
        (File,Res.The_Synch_Params.all,Indentation+3,False,"mast_res");
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Ceiling_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Integer := 8;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put_Line
        (File,"<mast_res:Priority_Ceiling Ceiling=""" &
         IO.Priority_Image(Res.The_Ceiling)&"""/>");
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------
   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Preemption_Level_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Integer := 6;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put_Line
        (File,"<mast_res:Preemption_Level Level=""" &
         IO.Preemption_Level_Image(Res.The_Preemption_Level)&"""/>");
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Time_Result_Lists.List;
      Indentation : Positive)
   is
      Names_Length : constant Integer := 16;
      The_Event : MAST.Events.Event_Ref;
      The_Time  : Time;
      Iterator : Time_Result_Lists.Iteration_Object;
   begin
      Time_Result_Lists.Rewind(The_List,Iterator);
      for I in 1..Time_Result_Lists.Size(The_List) loop
         Time_Result_Lists.Get_Next_Item
           (The_Event,The_Time,The_List,Iterator);
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put(File,"<mast_res:Global_Response_Time ");
         Ada.Text_IO.Put
           (File," Referenced_Event=""" &
            IO.Name_Image(MAST.Events.Name(The_Event)) &"""");
         Ada.Text_IO.Put_Line
           (File," Time_Value=""" & IO.Time_Image(The_Time) &"""/>");
      end loop;
   end Print_XML;

   ---------------------
   -- Print_XML       --
   ---------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Sim_Params_Lists.List;
      Time_Value : Time_Parameter_Function;
      Indentation : Positive)
   is
      Names_Length : constant Integer := 16;
      The_Event : MAST.Events.Event_Ref;
      The_Params  : Simulation_Parameters;
      Iterator : Sim_Params_Lists.Iteration_Object;
   begin
      Sim_Params_Lists.Rewind(The_List,Iterator);
      for I in 1..Sim_Params_Lists.Size(The_List) loop
         Sim_Params_Lists.Get_Next_Item
           (The_Event,The_Params,The_List,Iterator);
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put(File,"<mast_res:Global_Response_Time ");
         Ada.Text_IO.Put
           (File," Referenced_Event=""" &
            IO.Name_Image(MAST.Events.Name(The_Event)) &"""");
         Ada.Text_IO.Put_Line
           (File," Time_Value=""" &
            Mast.IO.Time_Image(Mast.Time'Value(Time_Value(The_Params)))&
            """/>");
      end loop;
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Miss_Ratio_Lists.List;
      Indentation : Positive)
   is
      Names_Length : constant Integer := 8;
      The_Deadline : Time;
      The_Ratio    : Percentage;
      The_Data     : Miss_Ratio_Data;
      Ratio_Image : String(1..20);
      Iterator : Miss_Ratio_Lists.Iteration_Object;
   begin
      Miss_Ratio_Lists.Rewind(The_List,Iterator);
      for I in 1..Miss_Ratio_Lists.Size(The_List) loop
         Miss_Ratio_Lists.Get_Next_Item
           (The_Deadline,The_Data,The_List,Iterator);
         The_Ratio:=100.0*Float(The_Data.Num_Missed)/Float(The_Data.Total);
         Put(Ratio_Image,The_Ratio,2,0);
         Set_Col(File,Ada.Text_Io.Count(Indentation));
         Ada.Text_IO.Put(File,"<mast_res:Miss_Ratio ");
         Ada.Text_IO.Put
           (File,"Deadline=""" & IO.Time_Image(The_Deadline) & """");
         Ada.Text_IO.Put_Line
           (File," Ratio=""" & Trim(Ratio_Image,Both) & """/>");
      end loop;
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out List_Of_Miss_Lists.List;
      Indentation : Positive)
   is
      Names_Length : constant Integer := 16;
      The_Event : MAST.Events.Event_Ref;
      The_Miss_List  : List_Ref;
      Iterator : List_Of_Miss_Lists.Iteration_Object;
   begin
      List_Of_Miss_Lists.Rewind(The_List,Iterator);
      for I in 1..List_Of_Miss_Lists.Size(The_List) loop
         List_Of_Miss_Lists.Get_Next_Item
           (The_Event,The_Miss_List,The_List,Iterator);
         Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put(File,"<mast_res:Global_Miss_Ratio ");
         Ada.Text_IO.Put_Line
           (File,"Referenced_Event=""" &
            IO.Name_Image(MAST.Events.Name(The_Event)) & """>");
         Print_XML(File,The_Miss_List.all,Indentation+3);
         Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put(File,"</mast_res:Global_Miss_Ratio> ");
      end loop;
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Timing_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_res:Timing_Result ");
      if Res.The_Link /= null then
         Ada.Text_IO.Put
           (File,"Event_Name="""&
            IO.Name_Image(MAST.Graphs.Name(Res.The_Link)) & """ ");
      end if;
      if Res.Has_Local_Response_Time then
         Ada.Text_IO.Put
           (File,"Worst_Local_Response_Time="""&
            IO.Time_Image(Res.Worst_Local_Response_Time) & """ ");
         Ada.Text_IO.Put
           (File,"Best_Local_Response_Time="""&
            IO.Time_Image(Res.Best_Local_Response_Time) & """ ");
      end if;
      if Res.Has_Worst_Blocking_Time then
         Ada.Text_IO.Put
           (File,"Num_Of_Suspensions="""&
            IO.Integer_Image(Res.Num_Of_Suspensions) & """ ");
         Ada.Text_IO.Put
           (File,"Worst_Blocking_Time="""&
            IO.Time_Image(Res.Worst_Blocking_Time) & """ ");
      end if;
      Ada.Text_IO.Put_Line(File,">");
      if Time_Result_Lists.Size(Res.Worst_Global_Response_Times)>0 and then
        Res.Has_Worst_Global_Response_Times
      then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"<mast_res:Worst_Global_Response_Times>");
         Print_XML(File,Res.Worst_Global_Response_Times,Indentation+6);
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"</mast_res:Worst_Global_Response_Times>");
      end if;
      if Time_Result_Lists.Size(Res.Best_Global_Response_Times)>0 and then
        Res.Has_Best_Global_Response_Times
      then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"<mast_res:Best_Global_Response_Times>");
         Print_XML(File,Res.Best_Global_Response_Times,Indentation+6);
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"</mast_res:Best_Global_Response_Times>");
      end if;
      if Time_Result_Lists.Size(Res.Jitters)>0 and then
        Res.Has_Worst_Global_Response_Times
      then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"<mast_res:Jitters>");
         Print_XML(File,Res.Jitters,Indentation+6);
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"</mast_res:Jitters>");
      end if;
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put_Line(File,"</mast_res:Timing_Result> ");
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Simulation_Timing_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False )
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_res:Simulation_Timing_Result ");
      if Res.The_Link /= null then
         Ada.Text_IO.Put
           (File," Event_Name=""" &
            IO.Name_Image(MAST.Graphs.Name(Res.The_Link)) & """");
      end if;
      if Res.Has_Local_Response_Time then
         Ada.Text_IO.Put
           (File," Worst_Local_Response_Time=""" &
            IO.Time_Image(Res.Worst_Local_Response_Time) & """");
         Ada.Text_IO.Put
           (File," Avg_Local_Response_Time=""" &
            Mast.IO.Time_Image(Avg_Local_Response_Time(Res)) & """");
         Ada.Text_IO.Put
           (File," Best_Local_Response_Time=""" &
            IO.Time_Image(Res.Best_Local_Response_Time)& """");
      end if;
      if Res.Has_Worst_Blocking_Time then
         Ada.Text_IO.Put
           (File," Num_Of_Suspensions=""" &
            IO.Integer_Image(Res.Num_Of_Suspensions) & """");
         Ada.Text_IO.Put
           (File," Worst_Blocking_Time=""" &
            IO.Time_Image(Res.Worst_Blocking_Time) & """");
         Ada.Text_IO.Put
           (File," Avg_Blocking_Time=""" &
            IO.Time_Image(Res.The_Avg_Blocking_Time) & """");
      end if;
      Ada.Text_IO.Put
        (File," Max_Preemption_Time=""" &
         IO.Time_Image(Res.The_Max_Preemption_Time) & """");
      Ada.Text_IO.Put
        (File," Suspension_Time=""" &
         IO.Time_Image(Res.The_Suspension_Time) & """");
      Ada.Text_IO.Put_Line
        (File," Num_Of_Queued_Activations=""" &
         IO.Integer_Image(Res.The_Num_Of_Queued_Activations) & """>");
      if Time_Result_Lists.Size(Res.Worst_Global_Response_Times)>0 and then
        Res.Has_Worst_Global_Response_Times
      then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"<mast_res:Worst_Global_Response_Times>");
         Print_XML(File,Res.Worst_Global_Response_Times,Indentation+6);
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"</mast_res:Worst_Global_Response_Times>");
      end if;
      if Sim_Params_Lists.Size(Res.Global_Simulation_Times)>0 then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"<mast_res:Avg_Global_Response_Times>");
         Print_XML
           (File,Res.Global_Simulation_Times,
            Avg_Simulation_Time'Access,Indentation+6);
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"</mast_res:Avg_Global_Response_Times>");
      end if;
      if Time_Result_Lists.Size(Res.Best_Global_Response_Times)>0 and then
        Res.Has_Best_Global_Response_Times
      then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"<mast_res:Best_Global_Response_Times>");
         Print_XML(File,Res.Best_Global_Response_Times,Indentation+6);
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"</mast_res:Best_Global_Response_Times>");
      end if;
      if Time_Result_Lists.Size(Res.Jitters)>0 and then
        Res.Has_Worst_Global_Response_Times
      then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"<mast_res:Jitters>");
         Print_XML(File,Res.Jitters,Indentation+6);
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"</mast_res:Jitters>");
      end if;
      if Miss_Ratio_Lists.Size(Res.Local_Miss_Ratios)>0 then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"<mast_res:Local_Miss_Ratios>");
         Print_XML(File,Res.Local_Miss_Ratios,Indentation+6);
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"</mast_res:Local_Miss_Ratios>");
      end if;
      if List_Of_Miss_Lists.Size(Res.Global_Miss_Ratios)>0 then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"<mast_res:Global_Miss_Ratios>");
         Print_XML(File,Res.Global_Miss_Ratios,Indentation+6);
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put_Line(File,"</mast_res:Global_Miss_Ratios>");
      end if;
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put_Line(File,"</mast_res:Simulation_Timing_Result> ");
   end Print_XML;

   ----------------------------------
   -- Update Simulation Parameters --
   ----------------------------------

   procedure Update
     (The_Time : Time;
      Worst, Best : in out Time;
      Params : in out Simulation_Parameters)
   is
   begin
      if The_Time>Worst then
         Worst:=The_Time;
      end if;
      if The_Time<Best then
         Best:=The_Time;
      end if;
      Params.Sum_Of_Simulation_Times:=
        Params.Sum_Of_Simulation_Times+The_Time;
      Params.Num_Of_Simulation_Times:=
        Params.Num_Of_Simulation_Times+1;
   end Update;

   ----------------------------------
   -- Update Miss Ratio Data       --
   ----------------------------------

   procedure Update
     (The_Time : Time;
      The_Deadline : Time;
      Data : in out Miss_Ratio_Data)
   is
   begin
      if The_Time>The_Deadline then
         Data.Num_Missed:=Data.Num_Missed+1;
      end if;
      Data.Total:=Data.Total+1;
   end Update;

   -----------------------------------
   -- Record Local repsonse times --
   -----------------------------------

   procedure Record_Local_Response_Time
     (The_Result : in out Simulation_Timing_Result;
      Local_Simulation_Time : Time)
   is
      The_Deadline : Time;
      The_Ratio_Data : Miss_Ratio_Data;
      Iterator : Miss_Ratio_Lists.Iteration_Object;
   begin
      The_Result.Has_Local_Response_Time:=True;
      Update (Local_Simulation_Time,The_Result.Worst_Local_Response_Time,
              The_Result.Best_Local_Response_Time,
              The_Result.Local_Simulation_Time);
      Miss_Ratio_Lists.Rewind(The_Result.Local_Miss_Ratios,Iterator);
      for I in 1..Miss_Ratio_Lists.Size
        (The_Result.Local_Miss_Ratios)
      loop
         Miss_Ratio_Lists.Get_Next_Item
           (The_Deadline,The_Ratio_Data,
            The_Result.Local_Miss_Ratios,Iterator);
         Update(Local_Simulation_Time,The_Deadline,The_Ratio_Data);
         Miss_Ratio_Lists.Update
           (The_Deadline,The_Ratio_Data,
            The_Result.Local_Miss_Ratios);
      end loop;
   end Record_Local_Response_Time;

   ----------------------------------
   -- Record_Global_Response_Time --
   ----------------------------------

   procedure Record_Global_Response_Time
     (The_Result : in out Simulation_Timing_Result;
      The_Event : MAST.Events.Event_Ref;
      Global_Simulation_Time : Time)
   is
      The_Miss_List : List_Ref;
      Params : Simulation_Parameters;
      The_Deadline,Worst,Best : Time;
      The_Ratio_Data : Miss_Ratio_Data;
      Iterator : Miss_Ratio_Lists.Iteration_Object;
   begin
      The_Result.Has_Worst_Global_Response_Times:=True;
      The_Result.Has_Best_Global_Response_Times:=True;
      -- Update or create simulation parameters
      begin
         Params:=Sim_Params_Lists.Item
           (The_Event,
            The_Result.Global_Simulation_Times);
      exception
         when List_Exceptions.Invalid_Index =>
            Params:=
              (Sum_Of_Simulation_Times=>Global_Simulation_Time,
               Num_Of_Simulation_Times=>1);
            Sim_Params_Lists.Add
              (The_Event,Params,
               The_Result.Global_Simulation_Times);
      end;
      begin
         Worst:=Time_Result_Lists.Item
           (The_Event,The_Result.Worst_Global_Response_Times);
      exception
         when List_Exceptions.Invalid_Index =>
            Time_Result_Lists.Add
              (The_Event,Global_Simulation_Time,
               The_Result.Worst_Global_Response_Times);
      end;
      begin
         Best:=Time_Result_Lists.Item
           (The_Event,The_Result.Best_Global_Response_Times);
      exception
         when List_Exceptions.Invalid_Index =>
            Time_Result_Lists.Add
              (The_Event,Global_Simulation_Time,
               The_Result.Best_Global_Response_Times);
      end;
      Update (Global_Simulation_Time,Worst,Best,Params);
      Sim_Params_Lists.Update
        (The_Event,Params,
         The_Result.Global_Simulation_Times);
      Time_Result_Lists.Update
        (The_Event,Worst,
         The_Result.Worst_Global_Response_Times);
      Time_Result_Lists.Update
        (The_Event,Best,
         The_Result.Best_Global_Response_Times);

      -- update (but not create) global miss ratios
      The_Miss_List:=List_Of_Miss_Lists.Item
        (The_Event,The_Result.Global_Miss_Ratios);
      Miss_Ratio_Lists.Rewind(The_Miss_List.all,Iterator);
      for I in 1..Miss_Ratio_Lists.Size(The_Miss_List.all) loop
         Miss_Ratio_Lists.Get_Next_Item
           (The_Deadline,The_Ratio_Data,The_Miss_List.all,Iterator);
         Update(Global_Simulation_Time,The_Deadline,The_Ratio_Data);
         Miss_Ratio_Lists.Update
           (The_Deadline,The_Ratio_Data,The_Miss_List.all);
      end loop;
   end Record_Global_Response_Time;

   ----------------------------------
   -- Record_Global_Response_Time --
   ----------------------------------

   procedure Record_Global_Response_Time
     (The_Result : in out Simulation_Timing_Result;
      Global_Simulation_Time : Time)
   is
      The_Miss_List : List_Ref;
      Params : Simulation_Parameters;
      The_Deadline,Worst,Best : Time;
      The_Ratio_Data : Miss_Ratio_Data;
      Iterator : Miss_Ratio_Lists.Iteration_Object;
   begin
      -- Update (but not create) simulation parameters
      Params:=Sim_Params_Lists.First_Item
        (The_Result.Global_Simulation_Times);
      Worst:=Time_Result_Lists.First_Item
        (The_Result.Worst_Global_Response_Times);
      Best:=Time_Result_Lists.First_Item
        (The_Result.Best_Global_Response_Times);
      Update (Global_Simulation_Time,Worst,Best,Params);
      Sim_Params_Lists.Update_First
        (Params,The_Result.Global_Simulation_Times);
      Time_Result_Lists.Update_First
        (Worst,The_Result.Worst_Global_Response_Times);
      Time_Result_Lists.Update_First
        (Best,The_Result.Best_Global_Response_Times);
      -- update (but not create) global miss ratios
      The_Miss_List:=List_Of_Miss_Lists.First_Item
        (The_Result.Global_Miss_Ratios);
      Miss_Ratio_Lists.Rewind(The_Miss_List.all,Iterator);
      for I in 1..Miss_Ratio_Lists.Size(The_Miss_List.all) loop
         Miss_Ratio_Lists.Get_Next_Item
           (The_Deadline,The_Ratio_Data,The_Miss_List.all,Iterator);
         Update(Global_Simulation_Time,The_Deadline,The_Ratio_Data);
         Miss_Ratio_Lists.Update
           (The_Deadline,The_Ratio_Data,The_Miss_List.all);
      end loop;
   exception
      when List_Exceptions.Invalid_Index =>
         raise No_Results_For_Event;
   end Record_Global_Response_Time;

   ----------------------------
   -- Reset_Local_Miss_Ratio --
   ----------------------------

   procedure Reset_Local_Miss_Ratio
     (The_Result : in out Simulation_Timing_Result;
      The_Deadline : Time)
   is
      Ratio_Data : Miss_Ratio_Data;
   begin
      Ratio_Data:=Miss_Ratio_Lists.Item
        (The_Deadline,The_Result.LOcal_Miss_Ratios);
      Miss_Ratio_Lists.Update
        (The_Deadline,Miss_Ratio_Data'(0,0),
         The_Result.Local_Miss_Ratios);
   exception
      when List_Exceptions.Invalid_Index =>
         Miss_Ratio_Lists.Add
           (The_Deadline,Miss_Ratio_Data'(0,0),
            The_Result.Local_Miss_Ratios);
   end Reset_Local_Miss_Ratio;

   ------------------------------
   -- Reset_Global_Miss_Ratios --
   ------------------------------

   procedure Reset_Global_Miss_Ratio
     (The_Result : in out Simulation_Timing_Result;
      The_Deadline : Time;
      The_Event : MAST.Events.Event_Ref)
   is
      Ratio_Data : Miss_Ratio_Data;
      Ratio_List : List_Ref;
   begin
      Ratio_List:=List_Of_Miss_Lists.Item
        (The_Event,The_Result.Global_Miss_Ratios);
      begin
         Ratio_Data:=Miss_Ratio_Lists.Item
           (The_Deadline,Ratio_List.all);
         Miss_Ratio_Lists.Update
           (The_Deadline,Miss_Ratio_Data'(0,0),Ratio_List.all);
      exception
         when List_Exceptions.Invalid_Index =>
            Miss_Ratio_Lists.Add
              (The_Deadline,Miss_Ratio_Data'(0,0),Ratio_List.all);
      end;
   exception
      when List_Exceptions.Invalid_Index =>
         Ratio_List:=new Miss_Ratio_Lists.List;
         Miss_Ratio_Lists.Add
           (The_Deadline,Miss_Ratio_Data'(0,0),Ratio_List.all);
         List_Of_Miss_Lists.Add
           (The_Event,Ratio_List,The_Result.Global_Miss_Ratios);
   end Reset_Global_Miss_Ratio;

   --------------------------------------
   -- Rewind_Global_Simulation_Times --
   --------------------------------------

   procedure Rewind_Global_Simulation_Times
     (The_Result : in Simulation_Timing_Result;
      Iterator : out Sim_Iteration_Object)
   is
   begin
      Sim_Params_Lists.Rewind
        (The_Result.Global_Simulation_Times,
         Sim_Params_Lists.Iteration_Object(Iterator));
   end Rewind_Global_Simulation_Times;

   ------------------------------
   -- Rewind_Local_Miss_Ratios --
   ------------------------------

   procedure Rewind_Local_Miss_Ratios
     (The_Result : in Simulation_Timing_Result;
      Iterator : out Local_Ratio_Iteration_Object)
   is
   begin
      Miss_Ratio_Lists.Rewind
        (The_Result.Local_Miss_Ratios,
         Miss_Ratio_Lists.Iteration_Object(Iterator));
   end Rewind_Local_Miss_Ratios;

   ------------------------------
   -- Rewind_Global_Miss_Ratios --
   ------------------------------

   procedure Rewind_Global_Miss_Ratios
     (The_Result : in Simulation_Timing_Result;
      Iterator : out Global_Ratio_Iteration_Object)
   is
   begin
      List_Of_Miss_Lists.Rewind
        (The_Result.Global_Miss_Ratios,Iterator.List_Of_Lists_Iterator);
      List_Of_Miss_Lists.Get_Next_Item
        (Iterator.Current_Event, Iterator.Current_List,
         The_Result.Global_Miss_Ratios,Iterator.List_Of_Lists_Iterator);
      Miss_Ratio_Lists.Rewind
        (Iterator.Current_List.all,Iterator.Miss_List_Iterator);
   exception
      when List_Exceptions.No_More_Items =>
         Iterator.Current_List:=null;
         Iterator.Current_Event:=null;
   end Rewind_Global_Miss_Ratios;

   ---------------------------------------
   -- Rewind_Global_Timing_Parameters --
   ---------------------------------------

   procedure Rewind_Global_Timing_Parameters
     (The_Result : in Timing_Result;
      Iterator : out Time_Iteration_Object)
   is
   begin
      Time_Result_Lists.Rewind
        (The_Result.Worst_Global_Response_Times,Iterator.Worst);
      Time_Result_Lists.Rewind
        (The_Result.Best_Global_Response_Times,Iterator.Best);
      Time_Result_Lists.Rewind
        (The_Result.Jitters,Iterator.Jitters);
   end Rewind_Global_Timing_Parameters;

   ------------------
   -- Sched_Params --
   ------------------

   function Sched_Params
     (Res : Sched_Params_Result)
     return Scheduling_Parameters.Sched_Parameters_Ref
   is
   begin
      return Res.The_Sched_Params;
   end Sched_Params;

   ---------------------
   -- Set_Application --
   ---------------------

   procedure Set_Application
     (Res    : in out Detailed_Utilization_Result;
      Value  : Percentage)
   is
   begin
      Res.Is_Detailed:=True;
      Res.Application_Util:=Value;
   end Set_Application;

   ----------------------------------
   -- Set_Best_Local_Response_Time --
   ----------------------------------

   procedure Set_Best_Local_Response_Time
     (The_Result : in out Timing_Result;
      Best_Local_Response_Time : Time)
   is
   begin
      The_Result.Has_Local_Response_Time:=True;
      The_Result.Best_Local_Response_Time:=Best_Local_Response_Time;
   end Set_Best_Local_Response_Time;

   -----------------
   -- Set_Ceiling --
   -----------------

   procedure Set_Ceiling
     (Res    : in out Ceiling_Result;
      Value  : Priority)
   is
   begin
      Res.The_Ceiling:=Value;
   end Set_Ceiling;

   ------------------------
   -- Set_Context_Switch --
   ------------------------

   procedure Set_Context_Switch
     (Res    : in out Detailed_Utilization_Result;
      Value  : Percentage)
   is
   begin
      Res.Is_Detailed:=True;
      Res.Context_Switch_Util:=Value;
   end Set_Context_Switch;

   ----------------
   -- Set_Driver --
   ----------------

   procedure Set_Driver
     (Res    : in out Detailed_Utilization_Result;
      Value  : Percentage)
   is
   begin
      Res.Is_Detailed:=True;
      Res.Driver_Util:=Value;
   end Set_Driver;

   --------------------------------
   -- Set_Global_Simulation_Time --
   --------------------------------

   procedure Set_Global_Simulation_Time
     (The_Result : in out Simulation_Timing_Result;
      The_Event : MAST.Events.Event_Ref;
      Value : Simulation_Parameters)
   is
   begin
      -- Update or create simulation parameters
      begin
         Sim_Params_Lists.Update
           (The_Event,Value,
            The_Result.Global_Simulation_Times);
      exception
         when List_Exceptions.Invalid_Index =>
            Sim_Params_Lists.Add
              (The_Event,Value,
               The_Result.Global_Simulation_Times);
      end;
   end Set_Global_Simulation_Time;

   --------------------------------
   -- Set_Global_Simulation_Time --
   --------------------------------

   procedure Set_Global_Simulation_Time
     (The_Result : in out Simulation_Timing_Result;
      Value : Simulation_Parameters)
   is
   begin
      -- Update (but not create) simulation parameters
      Sim_Params_Lists.Update_First
        (Value,The_Result.Global_Simulation_Times);
   exception
      when List_Exceptions.Invalid_Index =>
         raise No_Results_For_Event;
   end Set_Global_Simulation_Time;

   -------------------------------
   -- Set_Global_Miss_Ratio     --
   -------------------------------

   procedure Set_Global_Miss_Ratio
     (The_Result : in out Simulation_Timing_Result;
      The_Deadline : Time;
      The_Event : MAST.Events.Event_Ref;
      Value : Miss_Ratio_Data)
   is
      Ratio_Data : Miss_Ratio_Data;
      Ratio_List : List_Ref;
   begin
      Ratio_List:=List_Of_Miss_Lists.Item
        (The_Event,The_Result.Global_Miss_Ratios);
      begin
         Ratio_Data:=Miss_Ratio_Lists.Item
           (The_Deadline,Ratio_List.all);
         Miss_Ratio_Lists.Update
           (The_Deadline,Value,Ratio_List.all);
      exception
         when List_Exceptions.Invalid_Index =>
            Miss_Ratio_Lists.Add
              (The_Deadline,Value,Ratio_List.all);
      end;
   exception
      when List_Exceptions.Invalid_Index =>
         Ratio_List:=new Miss_Ratio_Lists.List;
         Miss_Ratio_Lists.Add
           (The_Deadline,Value,Ratio_List.all);
         List_Of_Miss_Lists.Add
           (The_Event,Ratio_List,The_Result.Global_Miss_Ratios);
   end Set_Global_Miss_Ratio;

   -------------------------------
   -- Set_Local_Miss_Ratio      --
   -------------------------------

   procedure Set_Local_Miss_Ratio
     (The_Result : in out Simulation_Timing_Result;
      The_Deadline : Time;
      Value : Miss_Ratio_Data)
   is
      Ratio_Data : Miss_Ratio_Data;
   begin
      Ratio_Data:=Miss_Ratio_Lists.Item
        (The_Deadline,The_Result.Local_Miss_Ratios);
      Miss_Ratio_Lists.Update
        (The_Deadline,Value,
         The_Result.Local_Miss_Ratios);
   exception
      when List_Exceptions.Invalid_Index =>
         Miss_Ratio_Lists.Add
           (The_Deadline,Value,
            The_Result.Local_Miss_Ratios);
   end Set_Local_Miss_Ratio;

   -------------------------------
   -- Set_Local_Simulation_Time --
   -------------------------------

   procedure Set_Local_Simulation_Time
     (The_Result : in out Simulation_Timing_Result;
      Value : Simulation_Parameters)
   is
   begin
      The_Result.Local_Simulation_Time:=Value;
   end Set_Local_Simulation_Time;

   -----------------
   -- Set_Max_Num --
   -----------------

   procedure Set_Max_Num
     (Res    : in out Queue_Size_Result;
      Value  : Natural)
   is
   begin
      Res.The_Max_Num:=Value;
   end Set_Max_Num;

   ------------------
   -- Set_Pathname --
   ------------------

   procedure Set_Pathname
     (Res    : in out Trace_Result;
      Value  : String)
   is
   begin
      Res.The_Pathname:=Var_Strings.To_Var_String(Value);
   end Set_Pathname;

   --------------------------
   -- Set_Preemption_Level --
   --------------------------

   procedure Set_Preemption_Level
     (Res    : in out Preemption_Level_Result;
      Value  : Mast.Preemption_Level)
   is
   begin
      Res.The_Preemption_Level:=Value;
   end Set_Preemption_Level;

   ----------------------
   -- Set_Sched_Params --
   ----------------------

   procedure Set_Sched_Params
     (Res    : in out Sched_Params_Result;
      Value  : Scheduling_Parameters.Sched_Parameters_Ref)
   is
   begin
      Res.The_Sched_Params:=Value;
   end Set_Sched_Params;

   ---------------
   -- Set_Slack --
   ---------------

   procedure Set_Slack
     (Res    : in out Slack_Result;
      Value  : Unrestricted_Percentage)
   is
   begin
      Res.The_Slack:=Value;
   end Set_Slack;

   ----------------------
   -- Set_Synch_Params --
   ----------------------

   procedure Set_Synch_Params
     (Res    : in out Synch_Params_Result;
      Value  : Synchronization_Parameters.Synch_Parameters_Ref)
   is
   begin
      Res.The_Synch_Params:=Value;
   end Set_Synch_Params;

   ---------------
   -- Set_Timer --
   ---------------

   procedure Set_Timer
     (Res    : in out Detailed_Utilization_Result;
      Value  : Percentage)
   is
   begin
      Res.Is_Detailed:=True;
      Res.Timer_Util:=Value;
   end Set_Timer;

   ---------------
   -- Set_Total --
   ---------------

   procedure Set_Total
     (Res    : in out Utilization_Result;
      Value  : Unrestricted_Percentage)
   is
   begin
      Res.Total_Util:=Value;
   end Set_Total;

   ---------------------------
   -- Set_Link              --
   ---------------------------

   procedure Set_Link
     (The_Result : in out Timing_Result;
      The_Link : MAST.Graphs.Link_Ref)
   is
   begin
      The_Result.The_Link := The_Link;
   end Set_Link;

   -----------------------------------
   -- Set_Best_Global_Response_Time --
   -----------------------------------

   procedure Set_Best_Global_Response_Time
     (The_Result : in out Timing_Result;
      The_Event : MAST.Events.Event_Ref;
      Best_Global_Response_Time : Time)
   is
   begin
      The_Result.Has_Best_Global_Response_Times:=True;
      Time_Result_Lists.Add_Or_Update
        (The_Event,Best_Global_Response_Time,
         The_Result.Best_Global_Response_Times);
   end Set_Best_Global_Response_Time;

   -----------------------------------
   -- Set_Best_Global_Response_Time --
   -----------------------------------

   procedure Set_Best_Global_Response_Time
     (The_Result : in out Timing_Result;
      Best_Global_Response_Time : Time)
   is
   begin
      The_Result.Has_Best_Global_Response_Times:=True;
      Time_Result_Lists.Update_First
        (Best_Global_Response_Time,
         The_Result.Best_Global_Response_Times);
   exception
      when List_Exceptions.Empty =>
         raise No_Results_For_Event;
   end Set_Best_Global_Response_Time;

   -----------------------------
   -- Set_Worst_Blocking_Time --
   -----------------------------

   procedure Set_Worst_Blocking_Time
     (The_Result : in out Timing_Result;
      Blocking_Time : Time)
   is
   begin
      The_Result.Has_Worst_Blocking_Time:=True;
      The_Result.Worst_Blocking_Time := Blocking_Time;
   end Set_Worst_Blocking_Time;

   ----------------
   -- Set_Jitter --
   ----------------

   procedure Set_Jitter
     (The_Result : in out Timing_Result;
      The_Event : MAST.Events.Event_Ref;
      Jitter : Time)
   is
   begin
      The_Result.Has_Worst_Global_Response_Times:=True;
      Time_Result_Lists.Add_Or_Update
        (The_Event,Jitter,
         The_Result.Jitters);
   end Set_Jitter;

   ----------------
   -- Set_Jitter --
   ----------------

   procedure Set_Jitter
     (The_Result : in out Timing_Result;
      Jitter : Time)
   is
   begin
      The_Result.Has_Worst_Global_Response_Times:=True;
      Time_Result_Lists.Update_First
        (Jitter,
         The_Result.Jitters);
   exception
      when List_Exceptions.Empty =>
         raise No_Results_For_Event;
   end Set_Jitter;

   ------------------------------------
   -- Set_Worst_Global_Response_Time --
   ------------------------------------

   procedure Set_Worst_Global_Response_Time
     (The_Result : in out Timing_Result;
      The_Event : MAST.Events.Event_Ref;
      Worst_Global_Response_Time : Time)
   is
   begin
      The_Result.Has_Worst_Global_Response_Times:=True;
      Time_Result_Lists.Add_Or_Update
        (The_Event,Worst_Global_Response_Time,
         The_Result.Worst_Global_Response_Times);
   end Set_Worst_Global_Response_Time;

   ------------------------------------
   -- Set_Worst_Global_Response_Time --
   ------------------------------------

   procedure Set_Worst_Global_Response_Time
     (The_Result : in out Timing_Result;
      Worst_Global_Response_Time : Time)
   is
   begin
      The_Result.Has_Worst_Global_Response_Times:=True;
      Time_Result_Lists.Update_First
        (Worst_Global_Response_Time,
         The_Result.Worst_Global_Response_Times);
   exception
      when List_Exceptions.Empty =>
         raise No_Results_For_Event;
   end Set_Worst_Global_Response_Time;

   -----------------------------------
   -- Set_Worst_Local_Response_Time --
   -----------------------------------

   procedure Set_Worst_Local_Response_Time
     (The_Result : in out Timing_Result;
      Worst_Local_Response_Time : Time)
   is
   begin
      The_Result.Has_Local_Response_Time:=True;
      The_Result.Worst_Local_Response_Time :=
        Worst_Local_Response_Time;
   end Set_Worst_Local_Response_Time;

   ------------------------
   -- Set_Num_Of_Suspensions
   ------------------------

   procedure Set_Num_Of_Suspensions
     (The_Result : in out Timing_Result;
      Num : Natural)
   is
   begin
      The_Result.Has_Worst_Blocking_Time:=True;
      The_Result.Num_Of_Suspensions:=Num;
   end Set_Num_Of_Suspensions;

   ------------------------
   -- Set_Average Blocking
   ------------------------

   procedure Set_Avg_Blocking_Time
     (The_Result : in out Simulation_Timing_Result;
      Value : Time)
   is
   begin
      The_Result.The_Avg_Blocking_Time:=Value;
   end Set_Avg_Blocking_Time;

   ------------------------------
   -- Set_Maximum preemption time
   ------------------------------

   procedure Set_Max_Preemption_Time
     (The_Result : in out Simulation_Timing_Result;
      Value : Time)
   is
   begin
      The_Result.The_Max_Preemption_Time:=Value;
   end Set_Max_Preemption_Time;

   ------------------------
   -- Set_Suspension_Time
   ------------------------

   procedure Set_Suspension_Time
     (The_Result : in out Simulation_Timing_Result;
      Value : Time)
   is
   begin
      The_Result.The_Suspension_Time:=Value;
   end Set_Suspension_Time;

   --------------------------------
   -- Set_Num_Of_Queued_Activations
   --------------------------------

   procedure Set_Num_Of_Queued_Activations
     (The_Result : in out Simulation_Timing_Result;
      Value : Natural)
   is
   begin
      The_Result.The_Num_Of_Queued_Activations:=Value;
   end Set_Num_Of_Queued_Activations;

   ------------------
   -- Synch_Params --
   ------------------

   function Synch_Params
     (Res    : Synch_Params_Result)
     return Synchronization_Parameters.Synch_Parameters_Ref
   is
   begin
      return Res.The_Synch_Params;
   end Synch_Params;

   ------------------------
   -- Average Blocking
   ------------------------

   function Avg_Blocking_Time
     (The_Result : Simulation_Timing_Result) return Time
   is
   begin
      return The_Result.The_Avg_Blocking_Time;
   end Avg_Blocking_Time;

   --------------------------
   -- Maximum preemption time
   --------------------------

   function Max_Preemption_Time
     (The_Result : Simulation_Timing_Result) return Time
   is
   begin
      return The_Result.The_Max_Preemption_Time;
   end Max_Preemption_Time;

   ------------------------
   -- Suspension_Time
   ------------------------

   function Suspension_Time
     (The_Result : Simulation_Timing_Result) return Time
   is
   begin
      return The_Result.The_Suspension_Time;
   end Suspension_Time;

   ----------------------------
   -- Num_Of_Queued_Activations
   ----------------------------

   function Num_Of_Queued_Activations
     (The_Result : Simulation_Timing_Result) return Natural
   is
   begin
      return The_Result.The_Num_Of_Queued_Activations;
   end Num_Of_Queued_Activations;

   -----------
   -- Slack --
   -----------

   function Slack
     (Res : Slack_Result) return Unrestricted_Percentage
   is
   begin
      return Res.The_Slack;
   end Slack;

   -----------
   -- Timer --
   -----------

   function Timer
     (Res : Detailed_Utilization_Result) return Percentage
   is
   begin
      return Res.Timer_Util;
   end Timer;

   -----------
   -- Total --
   -----------

   function Total
     (Res : Utilization_Result)
     return Unrestricted_Percentage
   is
   begin
      return Res.Total_Util;
   end Total;

   -------------------------
   -- Worst_Blocking_Time --
   -------------------------

   function Worst_Blocking_Time
     (The_Result : Timing_Result)
     return Time
   is
   begin
      return The_Result.Worst_Blocking_Time;
   end Worst_Blocking_Time;

   --------------------------------
   -- Worst_Global_Response_Time --
   --------------------------------

   function Worst_Global_Response_Time
     (The_Result : Timing_Result;
      The_Event : MAST.Events.Event_Ref)
     return Time
   is
   begin
      return Time_Result_Lists.Item
        (The_Event,The_Result.Worst_Global_Response_Times);
   exception
      when List_Exceptions.Invalid_Index =>
         raise No_Results_For_Event;
   end Worst_Global_Response_Time;

   --------------------------------
   -- Worst_Global_Response_Time --
   --------------------------------

   function Worst_Global_Response_Time
     (The_Result : Timing_Result)
     return Time
   is
   begin
      return Time_Result_Lists.First_Item
        (The_Result.Worst_Global_Response_Times);
   exception
      when List_Exceptions.Empty =>
         raise No_Results_For_Event;
   end Worst_Global_Response_Time;

   -------------------------------
   -- Worst_Local_Response_Time --
   -------------------------------

   function Worst_Local_Response_Time
     (The_Result : Timing_Result)
     return Time
   is
   begin
      return The_Result.Worst_Local_Response_Time;
   end Worst_Local_Response_Time;

end MAST.Results;
