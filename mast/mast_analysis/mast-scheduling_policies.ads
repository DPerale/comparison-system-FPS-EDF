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

with Ada.Text_IO;
package Mast.Scheduling_Policies is

   type Scheduling_Policy is abstract tagged private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Scheduling_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False);

  procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Scheduling_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   type Scheduling_Policy_Ref is access Scheduling_Policy'Class;

   function Clone
     (Policy : Scheduling_Policy)
     return  Scheduling_Policy_Ref is abstract;

   -----------------------------
   -- Fixed_Priority_Policy
   -----------------------------

   type Fixed_Priority_Policy is abstract new
     Scheduling_Policy with private;

   procedure Set_Max_Priority
     (Policy : in out Fixed_Priority_Policy;
      The_Priority : Priority);
   function Max_Priority
     (Policy : Fixed_Priority_Policy) return Priority;
   procedure Set_Min_Priority
     (Policy : in out Fixed_Priority_Policy;
      The_Priority : Priority);
   function Min_Priority
     (Policy : Fixed_Priority_Policy) return Priority;

   type Fixed_Priority_Policy_Ref is access all Fixed_Priority_Policy'Class;

   -----------------------------
   -- Fixed_Priority
   -----------------------------

   type Fixed_Priority is new
     Fixed_Priority_Policy with private;

   procedure Set_Worst_Context_Switch
     (Policy : in out Fixed_Priority;
      The_Worst_Context_Switch : Normalized_Execution_Time);
   procedure Set_Avg_Context_Switch
     (Policy : in out Fixed_Priority;
      The_Avg_Context_Switch : Normalized_Execution_Time);
   procedure Set_Best_Context_Switch
     (Policy : in out Fixed_Priority;
      The_Best_Context_Switch : Normalized_Execution_Time);
   function Worst_Context_Switch
     (Policy : Fixed_Priority) return Normalized_Execution_Time;
   function Avg_Context_Switch
     (Policy : Fixed_Priority) return Normalized_Execution_Time;
   function Best_Context_Switch
     (Policy : Fixed_Priority) return Normalized_Execution_Time;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Fixed_Priority;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Fixed_Priority;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Policy : Fixed_Priority)
     return  Scheduling_Policy_Ref;

   ---------------------------------
   -- Earliest Deadline First_Policy
   ---------------------------------

   type EDF_Policy is abstract new
     Scheduling_Policy with private;

   -----------------------------
   -- Earliest Deadline First
   -----------------------------

   type EDF is  new
     EDF_Policy with private;

   procedure Set_Worst_Context_Switch
     (Policy : in out EDF;
      The_Worst_Context_Switch : Normalized_Execution_Time);
   procedure Set_Avg_Context_Switch
     (Policy : in out EDF;
      The_Avg_Context_Switch : Normalized_Execution_Time);
   procedure Set_Best_Context_Switch
     (Policy : in out EDF;
      The_Best_Context_Switch : Normalized_Execution_Time);
   function Worst_Context_Switch
     (Policy : EDF) return Normalized_Execution_Time;
   function Avg_Context_Switch
     (Policy : EDF) return Normalized_Execution_Time;
   function Best_Context_Switch
     (Policy : EDF) return Normalized_Execution_Time;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out EDF;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out EDF;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Policy : EDF)
     return  Scheduling_Policy_Ref;

   -----------------------------
   -- Fixed_Priority_Packet_Based
   -----------------------------

   type FP_Packet_Based is new
     Fixed_Priority_Policy with private;

   procedure Set_Packet_Worst_Overhead
     (Policy : in out FP_Packet_Based;
      The_Packet_Worst_Overhead : Normalized_Execution_Time);
   procedure Set_Packet_Avg_Overhead
     (Policy : in out FP_Packet_Based;
      The_Packet_Avg_Overhead : Normalized_Execution_Time);
   procedure Set_Packet_Best_Overhead
     (Policy : in out FP_Packet_Based;
      The_Packet_Best_Overhead : Normalized_Execution_Time);
   function Packet_Worst_Overhead
     (Policy : FP_Packet_Based;
      Throughput : Throughput_Value)
     return Normalized_Execution_Time;
   function Packet_Avg_Overhead
     (Policy : FP_Packet_Based;
      Throughput : Throughput_Value)
     return Normalized_Execution_Time;
   function Packet_Best_Overhead
     (Policy : FP_Packet_Based;
      Throughput : Throughput_Value)
     return Normalized_Execution_Time;

   procedure Set_Packet_Overhead_Max_Size
     (Policy : in out FP_Packet_Based;
      The_Packet_Overhead_Max_Size : Bit_Count);
   procedure Set_Packet_Overhead_Avg_Size
     (Policy : in out FP_Packet_Based;
      The_Packet_Overhead_Avg_Size : Bit_Count);
   procedure Set_Packet_Overhead_Min_Size
     (Policy : in out FP_Packet_Based;
      The_Packet_Overhead_Min_Size : Bit_Count);
   function Packet_Overhead_Max_Size
     (Policy : FP_Packet_Based;
      Throughput : Throughput_Value)
     return Bit_Count;
   function Packet_Overhead_Avg_Size
     (Policy : FP_Packet_Based;
      Throughput : Throughput_Value)
     return Bit_Count;
   function Packet_Overhead_Min_Size
     (Policy : FP_Packet_Based;
      Throughput : Throughput_Value)
     return Bit_Count;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out FP_Packet_Based;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out FP_Packet_Based;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Policy : FP_Packet_Based)
     return  Scheduling_Policy_Ref;

private

   type Scheduling_Policy is abstract tagged null record;

   type Fixed_Priority_Policy is abstract new
     Scheduling_Policy with record
        Max_Priority : Priority:=Priority'Last;
        Min_Priority : Priority:=Priority'First;
   end record;

   type Fixed_Priority is new
     Fixed_Priority_Policy with record
        Worst_Context_Switch,
        Avg_Context_Switch,
        Best_Context_Switch : Normalized_Execution_Time:=0.0;
   end record;

   type EDF_Policy is abstract new Scheduling_Policy with null record;

   type EDF is new
     EDF_Policy with record
        Worst_Context_Switch,
        Avg_Context_Switch,
        Best_Context_Switch : Normalized_Execution_Time:=0.0;
   end record;

   type FP_Packet_Based is new
     Fixed_Priority_Policy with record
        Packet_Worst_Overhead,
        Packet_Avg_Overhead,
        Packet_Best_Overhead : Normalized_Execution_Time:=0.0;
        Packet_Overhead_Max_Size,
        Packet_Overhead_Avg_Size,
        Packet_Overhead_Min_Size : Bit_Count:=0.0;
        Packet_Worst_Ovhd_Units_Are_Time,
        Packet_Avg_Ovhd_Units_Are_Time,
        Packet_Best_Ovhd_Units_Are_Time : Boolean:=True;
        Throughput_Value_Is_Set : Boolean :=False;
   end record;

end Mast.Scheduling_Policies;
