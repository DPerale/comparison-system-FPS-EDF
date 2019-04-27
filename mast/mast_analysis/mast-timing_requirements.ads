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

with Ada.Text_IO, MAST.Events, Indexed_Lists, MAST.Results;

package MAST.Timing_Requirements is

   Inconclusive : exception; -- raised by Check

   type Timing_Requirement is abstract tagged private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Timing_Requirement;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Timing_Requirement;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   procedure Check
     (Req : in out Timing_Requirement;
      Res : MAST.Results.Timing_Result'Class;
      Is_Met : out Boolean) is abstract;

   procedure Schedulability_Index
     (Req : in out Timing_Requirement;
      Res : MAST.Results.Timing_Result'Class;
      The_Index : out Float) is abstract;

   function References_Event
     (Evnt : Mast.Events.Event_Ref;
      Req  : Timing_Requirement)
     return Boolean is abstract;
   -- Indicates whether the timing requirement references the
   -- event specified by Evnt

   type Timing_Requirement_Ref is access Timing_Requirement'Class;

   function Clone
     (Req : Timing_Requirement)
     return Timing_Requirement_Ref is abstract;

   procedure Adjust
     (Req : in out Timing_Requirement;
      Events_List : Events.Lists.List);
   -- Adjusts the pointers in Req to point at objects in Events_List
   -- it may raise Object_Not_found

   type Simple_Timing_Requirement is abstract
     new Timing_Requirement with private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Simple_Timing_Requirement;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Simple_Timing_Requirement;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   type Simple_Timing_Requirement_Ref is
     access all Simple_Timing_Requirement'Class;

   ------------------------
   -- Deadline
   ------------------------

   type Deadline is abstract
     new Simple_Timing_Requirement with private;

   procedure Set_The_Deadline
     (Req : in out Deadline;
      The_Deadline : Time);
   function The_Deadline
     (Req : Deadline) return Time;

   function References_Event
     (Evnt : Mast.Events.Event_Ref;
      Req  : Deadline)
     return Boolean;


   ------------------------
   -- Global Deadline
   ------------------------

   type Global_Deadline is abstract
     new Deadline with private;

   procedure Set_Event
     (Req : in out Global_Deadline;
      The_Event : MAST.Events.Event_Ref);
   function Event
     (Req : Global_Deadline) return MAST.Events.Event_Ref;

   procedure Adjust
     (Req : in out Global_Deadline;
      Events_List : Events.Lists.List);
   -- Adjusts the pointers in Req to point at objects in Events_List
   -- it may raise Object_Not_found

   function References_Event
     (Evnt : Mast.Events.Event_Ref;
      Req  : Global_Deadline)
     return Boolean;

   ------------------------
   -- Hard Global Deadline
   ------------------------

   type Hard_Global_Deadline is
     new Global_Deadline with private;

   procedure Check
     (Req : in out Hard_Global_Deadline;
      Res : MAST.Results.Timing_Result'Class;
      Is_Met : out Boolean);

   procedure Schedulability_Index
     (Req : in out Hard_Global_Deadline;
      Res : MAST.Results.Timing_Result'Class;
      The_Index : out Float);

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Hard_Global_Deadline;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Hard_Global_Deadline;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Req : Hard_Global_Deadline)
     return Timing_Requirement_Ref;
   -- Clone is incomplete. The Event field points at the old system
   -- This field needs later adjustment

   ------------------------
   -- Hard Local Deadline
   ------------------------

   type Hard_Local_Deadline is new Deadline with private;

   procedure Check
     (Req : in out Hard_Local_Deadline;
      Res : MAST.Results.Timing_Result'Class;
      Is_Met : out Boolean);

   procedure Schedulability_Index
     (Req : in out Hard_Local_Deadline;
      Res : MAST.Results.Timing_Result'Class;
      The_Index : out Float);

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Hard_Local_Deadline;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Hard_Local_Deadline;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Req : Hard_Local_Deadline)
     return Timing_Requirement_Ref;
   -- Clone is incomplete. The Event field points at the old system
   -- This field needs later adjustment

   ------------------------
   -- Soft Global Deadline
   ------------------------

   type Soft_Global_Deadline is
     new Global_Deadline with private;

   procedure Check
     (Req : in out Soft_Global_Deadline;
      Res : MAST.Results.Timing_Result'Class;
      Is_Met : out Boolean);
   -- Is met will be true if Res is not a Simulation_Timing_Result

   procedure Schedulability_Index
     (Req : in out Soft_Global_Deadline;
      Res : MAST.Results.Timing_Result'Class;
      The_Index : out Float);

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Soft_Global_Deadline;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Soft_Global_Deadline;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Req : Soft_Global_Deadline)
     return Timing_Requirement_Ref;

   ------------------------
   -- Soft Local Deadline
   ------------------------

   type Soft_Local_Deadline is new Deadline with private;

   procedure Check
     (Req : in out Soft_Local_Deadline;
      Res : MAST.Results.Timing_Result'Class;
      Is_Met : out Boolean);
   -- Is met will be true if Res is not a Simulation_Timing_Result

   procedure Schedulability_Index
     (Req : in out Soft_Local_Deadline;
      Res : MAST.Results.Timing_Result'Class;
      The_Index : out Float);

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Soft_Local_Deadline;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Soft_Local_Deadline;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Req : Soft_Local_Deadline)
     return Timing_Requirement_Ref;

   ------------------------
   -- Global Max Miss Ratio
   ------------------------

   type Global_Max_Miss_Ratio is
     new Global_Deadline with private;

   procedure Set_Ratio
     (Req : in out Global_Max_Miss_Ratio;
      The_Ratio : Percentage);
   function Ratio
     (Req : Global_Max_Miss_Ratio) return Percentage;

   procedure Check
     (Req : in out Global_Max_Miss_Ratio;
      Res : MAST.Results.Timing_Result'Class;
      Is_Met : out Boolean);
   -- Is met will be true if Res is not a Simulation Timing_Result

   procedure Schedulability_Index
     (Req : in out Global_Max_Miss_Ratio;
      Res : MAST.Results.Timing_Result'Class;
      The_Index : out Float);

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Global_Max_Miss_Ratio;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Global_Max_Miss_Ratio;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Req : Global_Max_Miss_Ratio)
     return Timing_Requirement_Ref;
   -- Clone is incomplete. The Event field points at the old system
   -- This field needs later adjustment

   ------------------------
   -- Local Max Miss Ratio
   ------------------------

   type Local_Max_Miss_Ratio is
     new Deadline with private;

   procedure Set_Ratio
     (Req : in out Local_Max_Miss_Ratio;
      The_Ratio : Percentage);
   function Ratio
     (Req : Local_Max_Miss_Ratio) return Percentage;

   procedure Check
     (Req : in out Local_Max_Miss_Ratio;
      Res : MAST.Results.Timing_Result'Class;
      Is_Met : out Boolean);
   -- Is met will be true if Res is not a Simulation_Timing_Result

   procedure Schedulability_Index
     (Req : in out Local_Max_Miss_Ratio;
      Res : MAST.Results.Timing_Result'Class;
      The_Index : out Float);

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Local_Max_Miss_Ratio;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Local_Max_Miss_Ratio;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Req : Local_Max_Miss_Ratio)
     return Timing_Requirement_Ref;

   --------------------------------
   -- Max Output Jitter Requirement
   --------------------------------

   type Max_Output_Jitter_Req is
     new Simple_Timing_Requirement with private;

   procedure Set_Max_Output_Jitter
     (Req : in out Max_Output_Jitter_Req;
      The_Max_Output_Jitter : Time);
   function Max_Output_Jitter
     (Req : Max_Output_Jitter_Req) return Time;

   procedure Set_Event
     (Req : in out Max_Output_Jitter_Req;
      The_Event : MAST.Events.Event_Ref);
   function Event
     (Req : Max_Output_Jitter_Req)
     return MAST.Events.Event_Ref;

   procedure Check
     (Req : in out Max_Output_Jitter_Req;
      Res : MAST.Results.Timing_Result'Class;
      Is_Met : out Boolean);

   procedure Schedulability_Index
     (Req : in out Max_Output_Jitter_Req;
      Res : MAST.Results.Timing_Result'Class;
      The_Index : out Float);

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Max_Output_Jitter_Req;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Max_Output_Jitter_Req;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Req : Max_Output_Jitter_Req)
     return Timing_Requirement_Ref;
   -- Clone is incomplete. The Event field points at the old system
   -- This field needs later adjustment

   procedure Adjust
     (Req : in out Max_Output_Jitter_Req;
      Events_List : Events.Lists.List);
   -- Adjusts the pointers in Req to point at objects in Events_List
   -- it may raise Object_Not_found

   function References_Event
     (Evnt : Mast.Events.Event_Ref;
      Req  : Max_Output_Jitter_Req)
     return Boolean;

   --------------------------------
   -- Composite Timing Requirement
   --------------------------------

   type Iteration_Object is private;

   type Composite_Timing_Req is
     new Timing_Requirement with private;

   procedure Add_Requirement
     (Comp_Req : in out Composite_Timing_Req;
      Req : Simple_Timing_Requirement_Ref);

   procedure Find_Hard_Global_Deadline
     (Comp_Req : in Composite_Timing_Req;
      The_Event : in MAST.Events.Event_Ref;
      The_Dline : out Time;
      Is_Present : out Boolean);

   procedure Find_Hard_Local_Deadline
     (Comp_Req : in Composite_Timing_Req;
      The_Dline : out Time;
      Is_Present : out Boolean);

   procedure Find_Soft_Global_Deadline
     (Comp_Req : in Composite_Timing_Req;
      The_Event : in MAST.Events.Event_Ref;
      The_Dline : out Time;
      Is_Present : out Boolean);

   procedure Find_Soft_Local_Deadline
     (Comp_Req : in Composite_Timing_Req;
      The_Dline : out Time;
      Is_Present : out Boolean);

   procedure Find_Max_Output_Jitter_Req
     (Comp_Req : in Composite_Timing_Req;
      The_Event : in MAST.Events.Event_Ref;
      Max_Jitter : out Time;
      Is_Present : out Boolean);

   procedure Find_Global_Max_Miss_Ratio
     (Comp_Req : in Composite_Timing_Req;
      The_Event : in MAST.Events.Event_Ref;
      The_Dline : in Time;
      The_Ratio : out Percentage;
      Is_Present : out Boolean);

   procedure Find_Local_Max_Miss_Ratio
     (Comp_Req : in Composite_Timing_Req;
      The_Dline : in Time;
      The_Ratio : out Percentage;
      Is_Present : out Boolean);

   function Num_Of_Requirements
     (Comp_Req : Composite_Timing_Req)
     return Natural;

   procedure Rewind_Requirements
     (Comp_Req : in Composite_Timing_Req;
      Iterator : out Iteration_Object);

   procedure Get_Next_Requirement
     (Comp_Req : in Composite_Timing_Req;
      Req : out Simple_Timing_Requirement_Ref;
      Iterator : in out Iteration_Object);

   procedure Check
     (Req : in out Composite_Timing_Req;
      Res : MAST.Results.Timing_Result'Class;
      Is_Met : out Boolean);

   procedure Schedulability_Index
     (Req : in out Composite_Timing_Req;
      Res : MAST.Results.Timing_Result'Class;
      The_Index : out Float);

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Composite_Timing_Req;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Composite_Timing_Req;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Req : Composite_Timing_Req)
     return Timing_Requirement_Ref;

   procedure Adjust
     (Req : in out Composite_Timing_Req;
      Events_List : Events.Lists.List);
   -- Adjusts the pointers in Req to point at objects in Events_List
   -- it may raise Object_Not_found

   function References_Event
     (Evnt : Mast.Events.Event_Ref;
      Req  : Composite_Timing_Req)
     return Boolean;

private

   type Timing_Requirement is abstract tagged null record;

   type Simple_Timing_Requirement is abstract
     new Timing_Requirement with null record;

   type Deadline is abstract
     new Simple_Timing_Requirement with record
        The_Deadline : Time:=0.0;
   end record;

   type Global_Deadline is abstract
     new Deadline with record
        Event : MAST.Events.Event_Ref;
   end record;

   type Hard_Global_Deadline is
     new Global_Deadline with null record;

   type Hard_Local_Deadline is new Deadline with null record;

   type Soft_Global_Deadline is
     new Global_Deadline with null record;

   type Soft_Local_Deadline is new Deadline with null record;

   type Global_Max_Miss_Ratio is
     new Global_Deadline with record
        Ratio : Percentage:=5.0;
   end record;

   type Local_Max_Miss_Ratio is
     new Deadline with record
        Ratio : Percentage:=5.0;
   end record;

   type Max_Output_Jitter_Req is
     new Simple_Timing_Requirement with record
        Max_Output_Jitter : Time:=0.0;
        Event : MAST.Events.Event_Ref;
   end record;

   package Req_Lists is new Indexed_Lists
     (Element => Simple_Timing_Requirement_Ref,
        "="     => "=");

   type Iteration_Object is new Req_Lists.Index;

   type Composite_Timing_Req is
     new Timing_Requirement with record
        Req_List : Req_Lists.List;
   end record;

end MAST.Timing_Requirements;
