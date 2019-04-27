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

with Ada.Text_IO,MAST.Graphs, MAST.Events, Mast.Scheduling_Parameters,
  Mast.Synchronization_Parameters,
  Hash_Lists, Var_Strings;

package MAST.Results is

   use type MAST.Events.Event_Ref;

   No_Results_For_Event : exception;
   No_Results_For_Deadline : exception;

   type Result is abstract tagged private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Result;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Result;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   type Result_Ref is access Result'Class;

   ------------------------
   -- Slack_Result      --
   ------------------------

   type Slack_Result is new Result with private;

   procedure Set_Slack
     (Res    : in out Slack_Result;
      Value  : Unrestricted_Percentage);

   function Slack (Res : Slack_Result) return Unrestricted_Percentage;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Slack_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Slack_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   type Slack_Result_Ref is access Slack_Result'Class;

   ------------------------
   -- Trace_Result      --
   ------------------------

   type Trace_Result is new Result with private;

   procedure Set_Pathname
     (Res    : in out Trace_Result;
      Value  : String);

   function Pathname (Res : Trace_Result) return String;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Trace_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Trace_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   type Trace_Result_Ref is access Trace_Result'Class;

   ------------------------
   -- Utilization_Result --
   ------------------------

   type Utilization_Result is new Result with private;

   procedure Set_Total
     (Res    : in out Utilization_Result;
      Value  : Unrestricted_Percentage);

   function Total
     (Res : Utilization_Result)
     return Unrestricted_Percentage;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Utilization_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Utilization_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   type Utilization_Result_Ref is access Utilization_Result'Class;

   ---------------------------------
   -- Detailed_Utilization_Result --
   ---------------------------------

   type Detailed_Utilization_Result is new Utilization_Result with private;

   procedure Set_Application
     (Res    : in out Detailed_Utilization_Result;
      Value  : Percentage);

   function Application
     (Res : Detailed_Utilization_Result)
     return Percentage;

   procedure Set_Context_Switch
     (Res    : in out Detailed_Utilization_Result;
      Value  : Percentage);

   function Context_Switch
     (Res : Detailed_Utilization_Result)
     return Percentage;

   procedure Set_Timer
     (Res    : in out Detailed_Utilization_Result;
      Value  : Percentage);

   function Timer
     (Res : Detailed_Utilization_Result)
     return Percentage;

   procedure Set_Driver
     (Res    : in out Detailed_Utilization_Result;
      Value  : Percentage);

   function Driver
     (Res : Detailed_Utilization_Result)
     return Percentage;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Detailed_Utilization_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Detailed_Utilization_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   type Detailed_Utilization_Result_Ref is
     access Detailed_Utilization_Result'Class;

   ------------------------
   -- Queue_Size_Result  --
   ------------------------

   type Queue_Size_Result is new Result with private;

   procedure Set_Max_Num
     (Res    : in out Queue_Size_Result;
      Value  : Natural);

   function Max_Num (Res : Queue_Size_Result) return Natural;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Queue_Size_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Queue_Size_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   type Queue_Size_Result_Ref is access Queue_Size_Result'Class;

   ------------------------
   -- Ready_Queue_Size_Result  --
   ------------------------

   type Ready_Queue_Size_Result is new Queue_Size_Result with private;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Ready_Queue_Size_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Ready_Queue_Size_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   type Ready_Queue_Size_Result_Ref is
     access all Ready_Queue_Size_Result'Class;

   -------------------------
   -- Sched_Params_Result --
   -------------------------

   type Sched_Params_Result is new Result with private;

   procedure Set_Sched_Params
     (Res    : in out Sched_Params_Result;
      Value  : Scheduling_Parameters.Sched_Parameters_Ref);

   function Sched_Params
     (Res : Sched_Params_Result)
     return Scheduling_Parameters.Sched_Parameters_Ref;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Sched_Params_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Sched_Params_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   type Sched_Params_Result_Ref is access Sched_Params_Result'Class;

   -------------------------
   -- Synch_Params_Result --
   -------------------------

   type Synch_Params_Result is new Result with private;

   procedure Set_Synch_Params
     (Res    : in out Synch_Params_Result;
      Value  : Synchronization_Parameters.Synch_Parameters_Ref);

   function Synch_Params
     (Res : Synch_Params_Result)
     return Synchronization_Parameters.Synch_Parameters_Ref;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Synch_Params_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Synch_Params_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   type Synch_Params_Result_Ref is access Synch_Params_Result'Class;

   ------------------------
   -- Shared_Resource_Result     --
   ------------------------

   type Shared_Resource_Result is abstract new Result with private;

   type Shared_Resource_Result_Ref is access Shared_Resource_Result'Class;

   ------------------------
   -- Ceiling_Result     --
   ------------------------

   type Ceiling_Result is new Shared_Resource_Result with private;

   procedure Set_Ceiling
     (Res    : in out Ceiling_Result;
      Value  : Priority);

   function Ceiling (Res : Ceiling_Result) return Priority;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Ceiling_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Ceiling_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   type Ceiling_Result_Ref is access Ceiling_Result'Class;

   ------------------------
   -- Preemption_Level_Result     --
   ------------------------

   type Preemption_Level_Result is new Shared_Resource_Result with private;

   procedure Set_Preemption_Level
     (Res    : in out Preemption_Level_Result;
      Value  : Preemption_Level);

   function Preemption_Level
     (Res : Preemption_Level_Result)
     return Mast.Preemption_Level;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Preemption_Level_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File        : Ada.Text_IO.File_Type;
      Res         : in out Preemption_Level_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   type Preemption_Level_Result_Ref is access Preemption_Level_Result'Class;

   ------------------------
   -- Timing_Result
   ------------------------

   type Timing_Parameters is record
      Worst_Response_Time : Time := Large_Time;
      Best_Response_Time : Time :=0.0;
      Jitter : Time := Large_Time;
   end record;

   type Time_Iteration_Object is private;

   type Timing_Result is new Result with private;

   procedure Set_Link
     (The_Result : in out Timing_Result;
      The_Link : MAST.Graphs.Link_Ref);

   function Link_Of
     (The_Result : Timing_Result) return MAST.Graphs.Link_Ref;

   -- Local response times

   procedure Set_Worst_Local_Response_Time
     (The_Result : in out Timing_Result;
      Worst_Local_Response_Time : Time);

   function Worst_Local_Response_Time
     (The_Result : Timing_Result) return Time;

   procedure Set_Best_Local_Response_Time
     (The_Result : in out Timing_Result;
      Best_Local_Response_Time : Time);

   function Best_Local_Response_Time
     (The_Result : Timing_Result) return Time;

   -- Worst_Blocking

   procedure Set_Worst_Blocking_Time
     (The_Result : in out Timing_Result;
      Blocking_Time : Time);

   function Worst_Blocking_Time
     (The_Result : Timing_Result) return Time;

   -- Num_Of_Suspensions

   procedure Set_Num_Of_Suspensions
     (The_Result : in out Timing_Result;
      Num : Natural);

   function Num_Of_Suspensions
     (The_Result : Timing_Result) return Natural;

   -- Global response times and jitter

   procedure Set_Worst_Global_Response_Time
     (The_Result : in out Timing_Result;
      The_Event : MAST.Events.Event_Ref;
      Worst_Global_Response_Time : Time);

   procedure Set_Best_Global_Response_Time
     (The_Result : in out Timing_Result;
      The_Event : MAST.Events.Event_Ref;
      Best_Global_Response_Time : Time);

   procedure Set_Jitter
     (The_Result : in out Timing_Result;
      The_Event : MAST.Events.Event_Ref;
      Jitter : Time);

   procedure Set_Worst_Global_Response_Time
     (The_Result : in out Timing_Result;
      Worst_Global_Response_Time : Time);
   -- sets data for first stored event
   -- may raise No_Results_For_Event

   procedure Set_Best_Global_Response_Time
     (The_Result : in out Timing_Result;
      Best_Global_Response_Time : Time);
   -- sets data for first stored event
   -- may raise No_Results_For_Event

   procedure Set_Jitter
     (The_Result : in out Timing_Result;
      Jitter : Time);
   -- sets data for first stored event
   -- may raise No_Results_For_Event

   function Worst_Global_Response_Time
     (The_Result : Timing_Result;
      The_Event : MAST.Events.Event_Ref) return Time;
   -- may raise No_Results_For_Event

   function Best_Global_Response_Time
     (The_Result : Timing_Result;
      The_Event : MAST.Events.Event_Ref) return Time;
   -- may raise No_Results_For_Event

   function Jitter
     (The_Result : Timing_Result;
      The_Event : MAST.Events.Event_Ref) return Time;
   -- may raise No_Results_For_Event

   function Worst_Global_Response_Time
     (The_Result : Timing_Result) return Time;
   -- returns data for first stored event

   function Best_Global_Response_Time
     (The_Result : Timing_Result) return Time;
   -- returns data for first stored event

   function Jitter
     (The_Result : Timing_Result) return Time;
   -- returns data for first stored event

   procedure Rewind_Global_Timing_Parameters
     (The_Result : in Timing_Result;
      Iterator : out Time_Iteration_Object);

   procedure Get_Next_Global_Timing_Parameters
     (The_Result : in Timing_Result;
      The_Event : out MAST.Events.Event_Ref;
      Timing_Params : out Timing_Parameters;
      Iterator : in out Time_Iteration_Object);

   function Num_Of_Global_Timing_Parameters
     (The_Result : Timing_Result) return Natural;

   -- Other operations

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Timing_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Timing_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   type Timing_Result_Ref is access Timing_Result'Class;

   function Create_Timing_Result
     (The_Link_Ref : MAST.Graphs.Link_Ref) return Timing_Result_Ref;
   -- creates a timing result bidirectionally linked to
   -- the specified arc

   ------------------------------
   -- Simulation_Timing_Result
   ------------------------------

   type Sim_Iteration_Object is private;
   type Local_Ratio_Iteration_Object is private;
   type Global_Ratio_Iteration_Object is private;

   type Miss_Ratio_Data is record
      Num_Missed, Total : Natural:=0;
   end record;

   type Simulation_Parameters is record
      Sum_Of_Simulation_Times : Time:=0.0;
      Num_Of_Simulation_Times : Natural:=0;
   end record;

   type Simulation_Timing_Result is new Timing_Result with private;

   -- Local simulation times

   procedure Record_Local_Response_Time
     (The_Result : in out Simulation_Timing_Result;
      Local_Simulation_Time : Time);
   -- affects worst, avg and best local simulation times,
   -- num of recorded local simulation times, and
   -- local miss ratios that have already been reset

   procedure Set_Local_Simulation_Time
     (The_Result : in out Simulation_Timing_Result;
      Value : Simulation_Parameters);

   function Avg_Local_Response_Time
     (The_Result : Simulation_Timing_Result) return Time;

   -- Global simulation times: setting for any event

   procedure Record_Global_Response_Time
     (The_Result : in out Simulation_Timing_Result;
      The_Event : MAST.Events.Event_Ref;
      Global_Simulation_Time : Time);
   -- if no global time had been recorded or set for the event,
   -- an entry is created for that event.
   -- affects worst, avg and best global simulation times,
   -- num of recorded global simulation times, and
   -- global miss ratios that have already been reset
   -- all, only for the specified event

   procedure Set_Global_Simulation_Time
     (The_Result : in out Simulation_Timing_Result;
      The_Event : MAST.Events.Event_Ref;
      Value : Simulation_Parameters);
   -- if no global time had been recorded or set for the event,
   -- an entry is created for that event.

   -- Global simulation times: setting for first event

   procedure Record_Global_Response_Time
     (The_Result : in out Simulation_Timing_Result;
      Global_Simulation_Time : Time);
   -- same as above, but affects data for the first stored event
   -- may raise No_Results_For_Event

   procedure Set_Global_Simulation_Time
     (The_Result : in out Simulation_Timing_Result;
      Value : Simulation_Parameters);
   -- same as above, but affects data for the first stored event
   -- may raise No_Results_For_Event

   -- Global simulation times: reading for any event

   function Avg_Global_Response_Time
     (The_Result : Simulation_Timing_Result;
      The_Event : MAST.Events.Event_Ref) return Time;
   -- may raise No_Results_For_Event

   -- Global simulation times: reading for first event

   function Avg_Global_Response_Time
     (The_Result : Simulation_Timing_Result) return Time;
   -- returns data for first stored event

   -- Global simulation times: iterating

   procedure Rewind_Global_Simulation_Times
     (The_Result : in Simulation_Timing_Result;
      Iterator : out Sim_Iteration_Object);

   procedure Get_Next_Global_Simulation_Times
     (The_Result : in Simulation_Timing_Result;
      The_Event : out MAST.Events.Event_Ref;
      Global_Simulation_Params : out Simulation_Parameters;
      Iterator : in out Sim_Iteration_Object);

   function Num_Of_Global_Simulation_Times
     (The_Result : Simulation_Timing_Result) return Natural;

   -- Average Blocking

   procedure Set_Avg_Blocking_Time
     (The_Result : in out Simulation_Timing_Result;
      Value : Time);

   function Avg_Blocking_Time
     (The_Result : Simulation_Timing_Result) return Time;


   -- Maximum preemption time

   procedure Set_Max_Preemption_Time
     (The_Result : in out Simulation_Timing_Result;
      Value : Time);

   function Max_Preemption_Time
     (The_Result : Simulation_Timing_Result) return Time;

   -- Suspension_Time

   procedure Set_Suspension_Time
     (The_Result : in out Simulation_Timing_Result;
      Value : Time);

   function Suspension_Time
     (The_Result : Simulation_Timing_Result) return Time;

   -- Num_Of_Queued_Activations

   procedure Set_Num_Of_Queued_Activations
     (The_Result : in out Simulation_Timing_Result;
      Value : Natural);

   function Num_Of_Queued_Activations
     (The_Result : Simulation_Timing_Result) return Natural;

   -- Local_Miss_Ratios

   procedure Reset_Local_Miss_Ratio
     (The_Result : in out Simulation_Timing_Result;
      The_Deadline : Time);
   -- Resets the entry for storing the miss ratio for the specified
   -- deadline, or creates one if it does not exist.
   -- The actual miss ratio is then set by successive calls to
   -- record_local_simulation_time

   procedure Set_Local_Miss_Ratio
     (The_Result : in out Simulation_Timing_Result;
      The_Deadline : Time;
      Value : Miss_Ratio_Data);
   -- Sets the entry for the specified miss ratio deadline,
   -- creating it if necessary.

   procedure Rewind_Local_Miss_Ratios
     (The_Result : in Simulation_Timing_Result;
      Iterator : out Local_Ratio_Iteration_Object);

   procedure Get_Next_Local_Miss_Ratio
     (The_Result : in Simulation_Timing_Result;
      The_Deadline : out Time;
      The_Ratio : out Percentage;
      Iterator : in out Local_Ratio_Iteration_Object);

   function Local_Miss_Ratio
     (The_Result : Simulation_Timing_Result;
      The_Deadline : Time) return Percentage;
   -- may raise No_Results_For_Deadline

   function Num_Of_Local_Miss_Ratios
     (The_Result : Simulation_Timing_Result) return Natural;

   -- Global_Miss_Ratios

   procedure Reset_Global_Miss_Ratio
     (The_Result : in out Simulation_Timing_Result;
      The_Deadline : Time;
      The_Event : MAST.Events.Event_Ref);
   -- Resets the entry for storing the miss ratio for the specified
   -- deadline and event, or creates one if it does not exist.
   -- The actual miss ratio is then set by successive calls to
   -- record_global_simulation_time, with the specified event

   procedure Set_Global_Miss_Ratio
     (The_Result : in out Simulation_Timing_Result;
      The_Deadline : Time;
      The_Event : MAST.Events.Event_Ref;
      Value : Miss_Ratio_Data);
   -- Sets the entry for the specified miss ratio deadline,
   -- creating it if necessary.

   procedure Rewind_Global_Miss_Ratios
     (The_Result : in Simulation_Timing_Result;
      Iterator : out Global_Ratio_Iteration_Object);

   procedure Get_Next_Global_Miss_Ratio
     (The_Result : in Simulation_Timing_Result;
      The_Deadline : out Time;
      The_Event : out MAST.Events.Event_Ref;
      The_Ratio : out Percentage;
      Iterator : in out Global_Ratio_Iteration_Object);

   function Global_Miss_Ratio
     (The_Result : Simulation_Timing_Result;
      The_Deadline : Time;
      The_Event : MAST.Events.Event_Ref) return Percentage;
   -- may raise No_Results_For_Deadline or No_Results_For_Event

   function Num_Of_Global_Miss_Ratios
     (The_Result : Simulation_Timing_Result) return Natural;

   -- Other operations

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Simulation_Timing_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Simulation_Timing_Result;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Create_Simulation_Timing_Result
     (The_Link_Ref : MAST.Graphs.Link_Ref) return Timing_Result_Ref;
   -- creates a simulation timing result bidirectionally linked to
   -- the specified arc

   type Simulation_Timing_Result_Ref is access Simulation_Timing_Result'Class;

private

   type Result is abstract tagged null record;

   package Time_Result_Lists is new Hash_Lists
     (Index => MAST.Events.Event_Ref,
      Element => Time, "=" => "=");

   package Sim_Params_Lists is new Hash_Lists
     (Index => MAST.Events.Event_Ref,
      Element => Simulation_Parameters, "=" => "=");

   package Miss_Ratio_Lists is new Hash_Lists
     (Index => Time, Element =>Miss_Ratio_Data, "=" => "=");

   type List_Ref is access Miss_Ratio_Lists.List;
   package List_Of_Miss_Lists is new Hash_Lists
     (Index => MAST.Events.Event_Ref,
      Element => List_Ref, "=" => "=");

   type Time_Iteration_Object is record
      Worst,Best,Jitters : Time_Result_Lists.Iteration_Object;
   end record;

   type Sim_Iteration_Object is new Sim_Params_Lists.Iteration_Object;

   type Local_Ratio_Iteration_Object is new
     Miss_Ratio_Lists.Iteration_Object;

   type Global_Ratio_Iteration_Object is record
      List_Of_Lists_Iterator : List_Of_Miss_Lists.Iteration_Object;
      Miss_List_Iterator : Miss_Ratio_Lists.Iteration_Object;
      Current_List : List_Ref;
      Current_Event : MAST.Events.Event_Ref;
   end record;

   type Slack_Result is new Result with record
      The_Slack : Float;
   end record;

   type Trace_Result is new Result with record
      The_Pathname : Var_Strings.Var_String;
   end record;

   type Utilization_Result is new Result with record
      Total_Util : Float;
   end record;

   type Detailed_Utilization_Result is new Utilization_Result with record
      Is_Detailed : Boolean:=False;
      Application_Util : Float;
      Context_Switch_Util : Float;
      Timer_Util : Float;
      Driver_Util : Float;
   end record;

   type Queue_Size_Result is new Result with record
      The_Max_Num : Natural;
   end record;

   type Ready_Queue_Size_Result is new Queue_Size_Result with null record;

   type Sched_Params_Result is new Result with record
      The_Sched_Params : Scheduling_Parameters.Sched_Parameters_Ref;
   end record;

   type Synch_Params_Result is new Result with record
      The_Synch_Params : Synchronization_Parameters.Synch_Parameters_Ref;
   end record;

   type Shared_Resource_Result is abstract new Result with null record;

   type Ceiling_Result is new Shared_Resource_Result with record
      The_Ceiling : Priority;
   end record;

   type Preemption_Level_Result is new Shared_Resource_Result with record
      The_Preemption_Level : Mast.Preemption_Level;
   end record;

   type Timing_Result is new Result with record
      The_Link : MAST.Graphs.Link_Ref;
      Has_Local_Response_Time,
      Has_Worst_Blocking_Time,
      Has_Worst_Global_Response_Times,
      Has_Best_Global_Response_Times : Boolean:=False;
      Worst_Local_Response_Time : Time := 0.0;
      Best_Local_Response_Time : Time := 0.0;
      Worst_Blocking_Time : Time :=0.0;
      Num_Of_Suspensions : Natural:=0;
      Worst_Global_Response_Times,
      Best_Global_Response_Times,
      Jitters : Time_Result_Lists.List;
   end record;

   type Simulation_Timing_Result is new Timing_Result with record
      The_Avg_Blocking_Time,
      The_Max_Preemption_Time,
      The_Suspension_Time : Time:=0.0;
      The_Num_Of_Queued_Activations : Natural:=0;
      Local_Simulation_Time : Simulation_Parameters;
      Global_Simulation_Times : Sim_Params_Lists.List;
      Local_Miss_Ratios : Miss_Ratio_Lists.List;
      Global_Miss_Ratios : List_Of_Miss_Lists.List;
   end record;

end MAST.Results;
