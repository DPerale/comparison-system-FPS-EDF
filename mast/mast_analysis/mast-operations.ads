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

with Ada.Text_IO,MAST.Shared_Resources,MAST.Scheduling_Parameters,
  MAST.Results, Indexed_Lists, Named_Lists, Var_Strings;

package MAST.Operations is

   type Operation is abstract tagged private;

   procedure Init
     (Op : in out Operation;
      Name : Var_Strings.Var_String);
   function Name
     (Op : Operation) return Var_Strings.Var_String;

   function Worst_Case_Execution_Time
     (Op : Operation; Throughput : Throughput_Value)
     return Normalized_Execution_Time is abstract;
   function Avg_Case_Execution_Time
     (Op : Operation; Throughput : Throughput_Value)
     return Normalized_Execution_Time is abstract;
   function Best_Case_Execution_Time
     (Op : Operation; Throughput : Throughput_Value)
     return Normalized_Execution_Time is abstract;

   procedure Scale
     (Op : in out Operation; Factor : Normalized_Execution_Time) is abstract;
   -- Scales all execution times or message sizes multiplying them by factor

   procedure Relative_Scale
     (Op : in out Operation; Factor : Normalized_Execution_Time) is abstract;
   -- Scales the factor set by Scale function multiplying it by factor

   procedure Set_New_Sched_Parameters
     (Op : in out Operation;
      Sched_Params :
      MAST.Scheduling_Parameters.Overridden_Sched_Parameters_Ref);
   function New_Sched_Parameters
     (Op : Operation)
     return MAST.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;

   function Shared_Resources_Used
     (Op : Operation)
     return Boolean is abstract;

   function Operation_References_Shared_Resource
     (Op     : Operation;
      Sr_Ref : Shared_Resources.Shared_Resource_Ref)
     return Boolean is abstract;

   procedure Set_Slack_Result
     (Op : in out Operation;
      Res : Results.Slack_Result_Ref);

   function Slack_Result
     (Op : Operation)
     return Results.Slack_Result_Ref;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True);

  procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True) is abstract;

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      Op  : Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      Op  : Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   type Operation_Ref is access Operation'Class;

   function Clone
     (Op : Operation)
     return  Operation_Ref is abstract;

   function Name (Op_Ref : Operation_Ref )
                 return Var_Strings.Var_String;

   package Lists is new Named_Lists
     (Element => Operation_Ref,
      Name    => Name);

   procedure Adjust
     (Op : in out Operation;
      Res_List : in Shared_Resources.Lists.List;
      Op_List : in Lists.List) is abstract;
   -- To adjust internal pointers to point to objects in the lists

   procedure Scale
     (The_List : in Lists.List; Factor : Normalized_Execution_Time);
   -- Scales all execution times multiplying them by factor

   procedure Relative_Scale
     (The_List : in Lists.List; Factor : Normalized_Execution_Time);
   -- Scales the factor set by Scale function multiplying it by factor

   function Clone
     (The_List : in Lists.List)
     return Lists.List;

   procedure Adjust
     (The_List : in Lists.List;
      Res_List : in Shared_Resources.Lists.List);
   -- To adjust internal pointers to point to objects in the list
   -- it may raise Object_Not_Found

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   procedure Adjust_Ref
     (Op_Ref : in out Operation_Ref;
      The_List : Lists.List);
   -- changes the op_ref to point to the object of the same name in The_List
   -- it may raise Object_Not_Found

   function List_References_Operation
     (Op_Ref : Operation_Ref;
      The_List : Lists.List)
     return Boolean;
     -- indicates whether the list contains composite operations with
     -- a reference to the
     -- operation pointed to by Pr_Ref or not

   function List_References_Shared_Resource
     (Sr_Ref : Shared_Resources.Shared_Resource_Ref;
      The_List : Lists.List)
     return Boolean;
     -- indicates whether the list contains operations with
     -- a reference to the
     -- shared object pointed to by Sr_Ref or not


   ------------------
   -- Simple Operation
   ------------------

   type Simple_Operation is new Operation with private;

   type Simple_Operation_Ref is access all Simple_Operation'Class;

   type Resource_Iteration_Object is private;

   procedure Set_Worst_Case_Execution_Time
     (Op : in out Simple_Operation;
      Worst_Case_Execution_Time :
      Normalized_Execution_Time);
   procedure Set_Avg_Case_Execution_Time
     (Op : in out Simple_Operation;
      Avg_Case_Execution_Time :
      Normalized_Execution_Time);
   procedure Set_Best_Case_Execution_Time
     (Op : in out Simple_Operation;
      Best_Case_Execution_Time :
      Normalized_Execution_Time);
   function Worst_Case_Execution_Time
     (Op : Simple_Operation; Throughput : Throughput_Value)
     return Normalized_Execution_Time;
   function Avg_Case_Execution_Time
     (Op : Simple_Operation; Throughput : Throughput_Value)
     return Normalized_Execution_Time;
   function Best_Case_Execution_Time
     (Op : Simple_Operation; Throughput : Throughput_Value)
     return Normalized_Execution_Time;

   procedure Scale
     (Op : in out Simple_Operation; Factor : Normalized_Execution_Time);
   -- Scales all execution times multiplying them by factor

   procedure Relative_Scale
     (Op : in out Simple_Operation; Factor : Normalized_Execution_Time);
   -- Scales the factor set by Scale function multiplying it by factor

   procedure Add_Locked_Resource
     (Op : in out Simple_Operation;
      Resource : MAST.Shared_Resources.Shared_Resource_Ref);

   procedure Remove_Locked_Resource
     (Op : in out Simple_Operation;
      Resource : MAST.Shared_Resources.Shared_Resource_Ref);
   -- Raises List_Exceptions.Not_Found if Resource is not found

   function Num_Of_Locked_Resources
     (Op : Simple_Operation )
     return Natural;

   procedure Rewind_Locked_Resources
     (Op : in Simple_Operation;
      Iterator : out Resource_Iteration_Object);

   procedure Get_Next_Locked_Resource
     (Op : in Simple_Operation;
      Resource : out MAST.Shared_Resources.Shared_Resource_Ref;
      Iterator : in out Resource_Iteration_Object);

   procedure Add_Unlocked_Resource
     (Op : in out Simple_Operation;
      Resource : MAST.Shared_Resources.Shared_Resource_Ref);

   procedure Remove_Unlocked_Resource
     (Op : in out Simple_Operation;
      Resource : MAST.Shared_Resources.Shared_Resource_Ref);
   -- Raises List_Exceptions.Not_Found if Resource is not found

   function Num_Of_Unlocked_Resources
     (Op : Simple_Operation )
     return Natural;

   procedure Rewind_Unlocked_Resources
     (Op : in Simple_Operation;
      Iterator : out Resource_Iteration_Object);

   procedure Get_Next_Unlocked_Resource
     (Op : in Simple_Operation;
      Resource : out MAST.Shared_Resources.Shared_Resource_Ref;
      Iterator : in out Resource_Iteration_Object);

   procedure Add_Resource
     (Op : in out Simple_Operation;
      Resource : MAST.Shared_Resources.Shared_Resource_Ref);
   -- adds resource at the end of the list of locked resources
   -- and at the beginning of the list of unlocked resources

   procedure Remove_Resource
     (Op : in out Simple_Operation;
      Resource : MAST.Shared_Resources.Shared_Resource_Ref);
   -- Removes Resource from both lists of locked and unlocked
   -- resources. Raises List_Exceptions.Not_Found if the
   -- resource is not found in either of the two lists

   function Shared_Resources_Used
     (Op : Simple_Operation)
     return Boolean;

   function Operation_References_Shared_Resource
     (Op     : Simple_Operation;
      Sr_Ref : Shared_Resources.Shared_Resource_Ref)
     return Boolean;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Simple_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Simple_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True);

   function Clone
     (Op : Simple_Operation)
     return  Operation_Ref;
   -- Lists of locked and unlocked resources are not cloned
   -- They need to be rearranged later

   procedure Adjust
     (Op : in out Simple_Operation;
      Res_List : in Shared_Resources.Lists.List;
      Op_List : in Lists.List);
   -- To adjust internal pointers to point to objects in the lists
   -- it may raise Object_Not_Found

   -------------------
   -- Composite Operation
   -------------------

   type Composite_Operation is new Operation with private;

   type Operation_Iteration_Object is private;

   function Worst_Case_Execution_Time
     (Op : Composite_Operation; Throughput : Throughput_Value)
     return Normalized_Execution_Time;
   function Avg_Case_Execution_Time
     (Op : Composite_Operation; Throughput : Throughput_Value)
     return Normalized_Execution_Time;
   function Best_Case_Execution_Time
     (Op : Composite_Operation; Throughput : Throughput_Value)
     return Normalized_Execution_Time;

   procedure Scale
     (Op : in out Composite_Operation; Factor : Normalized_Execution_Time);
   -- Scales all execution times multiplying them by factor

   procedure Relative_Scale
     (Op : in out Composite_Operation; Factor : Normalized_Execution_Time);
   -- Scales the factor set by Scale function multiplying it by factor

   procedure Add_Operation
     (Comp_Op : in out Composite_Operation;
      Op : Operation_Ref);

   procedure Remove_Operation
     (Comp_Op : in out Composite_Operation;
      Op : Operation_Ref);
   -- raises List_Exceptions.Not_Found if Op is not found

   function Num_Of_Operations
     (Comp_Op : Composite_Operation)
     return Natural;

   procedure Rewind_Operations
     (Comp_Op : in Composite_Operation;
      Iterator : out Operation_Iteration_Object);

   procedure Get_Next_Operation
     (Comp_Op : in Composite_Operation;
      Op : out Operation_Ref;
      Iterator : in out Operation_Iteration_Object);

   function Shared_Resources_Used
     (Op : Composite_Operation)
     return Boolean;

   function Operation_References_Shared_Resource
     (Op     : Composite_Operation;
      Sr_Ref : Shared_Resources.Shared_Resource_Ref)
     return Boolean;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Composite_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Composite_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True);

   function Clone
     (Op : Composite_Operation)
     return  Operation_Ref;

   procedure Adjust
     (Op : in out Composite_Operation;
      Res_List : in Shared_Resources.Lists.List;
      Op_List : in Lists.List);
   -- To adjust internal pointers to point to objects in the lists
   -- it may raise Object_Not_Found

   ----------------------
   -- Enclosing Operation
   ----------------------

   type Enclosing_Operation is new Composite_Operation with private;

   procedure Set_Worst_Case_Execution_Time
     (Op : in out Enclosing_Operation;
      Worst_Case_Execution_Time : Normalized_Execution_Time);
   procedure Set_Avg_Case_Execution_Time
     (Op : in out Enclosing_Operation;
      Avg_Case_Execution_Time : Normalized_Execution_Time);
   procedure Set_Best_Case_Execution_Time
     (Op : in out Enclosing_Operation;
      Best_Case_Execution_Time : Normalized_Execution_Time);

   function Worst_Case_Execution_Time
     (Op : Enclosing_Operation; Throughput : Throughput_Value)
     return Normalized_Execution_Time;
   function Avg_Case_Execution_Time
     (Op : Enclosing_Operation; Throughput : Throughput_Value)
     return Normalized_Execution_Time;
   function Best_Case_Execution_Time
     (Op : Enclosing_Operation; Throughput : Throughput_Value)
     return Normalized_Execution_Time;

   procedure Scale
     (Op : in out Enclosing_Operation; Factor : Normalized_Execution_Time);
   -- Scales all execution times multiplying them by factor

   procedure Relative_Scale
     (Op : in out Enclosing_Operation; Factor : Normalized_Execution_Time);
   -- Scales the factor set by Scale function multiplying it by factor

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Enclosing_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Enclosing_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True);

   function Clone
     (Op : Enclosing_Operation)
     return  Operation_Ref;

   -- Adjust is inherited from composite

   ----------------------------------
   -- Message Transmission Operation
   -----------------------------------

   type Message_Transmission_Operation is new Operation with private;

   type Message_Transmission_Operation_Ref is
     access all Message_Transmission_Operation'Class;

   procedure Scale
     (Op : in out Message_Transmission_Operation;
      Factor : Normalized_Execution_Time);

   procedure Relative_Scale
     (Op : in out Message_Transmission_Operation;
      Factor : Normalized_Execution_Time);
   -- Scales the factor set by Scale function multiplying it by factor

   function Worst_Case_Execution_Time
     (Op : Message_Transmission_Operation; Throughput : Throughput_Value)
     return Normalized_Execution_Time;
   function Avg_Case_Execution_Time
     (Op : Message_Transmission_Operation; Throughput : Throughput_Value)
     return Normalized_Execution_Time;
   function Best_Case_Execution_Time
     (Op : Message_Transmission_Operation; Throughput : Throughput_Value)
     return Normalized_Execution_Time;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Message_Transmission_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Message_Transmission_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True);

   function Clone
     (Op : Message_Transmission_Operation)
     return  Operation_Ref;

   procedure Adjust
     (Op : in out Message_Transmission_Operation;
      Res_List : in Shared_Resources.Lists.List;
      Op_List : in Lists.List);
   -- To adjust internal pointers to point to an objects in the lists
   -- it may raise Object_Not_Found

   function Shared_Resources_Used
     (Op : Message_Transmission_Operation)
     return Boolean;

   function Operation_References_Shared_Resource
     (Op     : Message_Transmission_Operation;
      Sr_Ref : Shared_Resources.Shared_Resource_Ref)
     return Boolean;

   procedure Set_Max_Message_Size
     (Op : in out Message_Transmission_Operation;
      Max_Message_Size : Bit_Count);
   procedure Set_Avg_Message_Size
     (Op : in out Message_Transmission_Operation;
      Avg_Message_Size : Bit_Count);
   procedure Set_Min_Message_Size
     (Op : in out Message_Transmission_Operation;
      Min_Message_Size : Bit_Count);
   function Max_Message_Size
     (Op : Message_Transmission_Operation)
     return Bit_Count;
   function Avg_Message_Size
     (Op : Message_Transmission_Operation)
     return Bit_Count;
   function Min_Message_Size
     (Op : Message_Transmission_Operation)
     return Bit_Count;

private

   package Shared_Resources_List is new Indexed_Lists
     (Element => MAST.Shared_Resources.Shared_Resource_Ref,
        "=" => MAST.Shared_Resources."=");

   type Resource_Iteration_Object is new
     Shared_Resources_List.Index;

   type Operation is abstract tagged record
      Name : Var_Strings.Var_String;
      New_Sched_Parameters :
        MAST.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      The_Slack_Result : Results.Slack_Result_Ref;
   end record;

   type Simple_Operation is new Operation with record
      Worst_Case_Execution_Time,
      Avg_Case_Execution_Time : Normalized_Execution_Time
      :=Large_Execution_Time;
      Best_Case_Execution_Time  : Normalized_Execution_Time
        :=0.0;
      Scale_Factor : Normalized_Execution_Time:=1.0;
      Locked_Shared_Resources,
      Unlocked_Shared_Resources : Shared_Resources_List.List;
   end record;

   package Op_Lists is new Indexed_Lists
     (Element => Operation_Ref,
        "="     => "=");

   type Operation_Iteration_Object is new Op_Lists.Index;

   type Composite_Operation is new Operation with record
      Op_List : Op_Lists.List;
   end record;

   type Enclosing_Operation is new Composite_Operation with record
      Worst_Case_Execution_Time,
      Avg_Case_Execution_Time : Normalized_Execution_Time
      :=Large_Execution_Time;
      Best_Case_Execution_Time  : Normalized_Execution_Time
        :=0.0;
      Scale_Factor : Normalized_Execution_Time:=1.0;
   end record;

   type Message_Transmission_Operation is new Operation with record
      Max_Message_Size,
      Avg_Message_Size : Bit_Count:=Large_Bit_Count;
      Min_Message_Size  : Bit_Count:=0.0;
      Scale_Factor : Normalized_Execution_Time:=1.0;
   end record;

end MAST.Operations;
