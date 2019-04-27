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

with Mast.IO;
package body Mast.Scheduling_Policies is

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Scheduling_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
   end Print;

   -----------------------------
   -- Fixed_Priority_Policy
   -----------------------------

   procedure Set_Max_Priority
     (Policy : in out Fixed_Priority_Policy;
      The_Priority : Priority)
   is
   begin
      Policy.Max_Priority := The_Priority;
   end Set_Max_Priority;

   function Max_Priority
     (Policy : Fixed_Priority_Policy) return Priority
   is
   begin
      return Policy.Max_Priority;
   end Max_Priority;

   procedure Set_Min_Priority
     (Policy : in out Fixed_Priority_Policy;
      The_Priority : Priority)
   is
   begin
      Policy.Min_Priority := The_Priority;
   end Set_Min_Priority;

   function Min_Priority
     (Policy : Fixed_Priority_Policy) return Priority
   is
   begin
      return Policy.Min_Priority;
   end Min_Priority;

   -----------------------------
   -- Fixed_Priority
   -----------------------------

   procedure Set_Worst_Context_Switch
     (Policy : in out Fixed_Priority;
      The_Worst_Context_Switch : Normalized_Execution_Time)
   is
   begin
      Policy.Worst_Context_Switch := The_Worst_Context_Switch;
   end Set_Worst_Context_Switch;

   procedure Set_Avg_Context_Switch
     (Policy : in out Fixed_Priority;
      The_Avg_Context_Switch : Normalized_Execution_Time)
   is
   begin
      Policy.Avg_Context_Switch := The_Avg_Context_Switch;
   end Set_Avg_Context_Switch;

   procedure Set_Best_Context_Switch
     (Policy : in out Fixed_Priority;
      The_Best_Context_Switch : Normalized_Execution_Time)
   is
   begin
      Policy.Best_Context_Switch := The_Best_Context_Switch;
   end Set_Best_Context_Switch;


   function Worst_Context_Switch
     (Policy : Fixed_Priority) return Normalized_Execution_Time
   is
   begin
      return Policy.Worst_Context_Switch;
   end Worst_Context_Switch;

   function Avg_Context_Switch
     (Policy : Fixed_Priority) return Normalized_Execution_Time
   is
   begin
      return Policy.Avg_Context_Switch;
   end Avg_Context_Switch;

   function Best_Context_Switch
     (Policy : Fixed_Priority) return Normalized_Execution_Time
   is
   begin
      return Policy.Best_Context_Switch;
   end Best_Context_Switch;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Fixed_Priority;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 20;
   begin
      Print(File,Scheduling_Policy(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Fixed_Priority",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Worst_Context_Switch",
         IO.Execution_Time_Image(Res.Worst_Context_Switch),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Avg_Context_Switch",
         IO.Execution_Time_Image(Res.Avg_Context_Switch),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Best_Context_Switch",
         IO.Execution_Time_Image(Res.Best_Context_Switch),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Max_Priority",
         Priority'Image(Res.Max_Priority),Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Min_Priority",
         Priority'Image(Res.Min_Priority),Indentation+2,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Fixed_Priority;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 20;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:Fixed_Priority_Scheduler ");
      Ada.Text_Io.Put
        (File,"Worst_Context_Switch=""" &
         Io.Execution_Time_Image(Res.Worst_Context_Switch) & """ ");
      Ada.Text_Io.Put
        (File,"Avg_Context_Switch=""" &
         IO.Execution_Time_Image(Res.Avg_Context_Switch) & """ ");
      Ada.Text_Io.Put
        (File,"Best_Context_Switch=""" &
         IO.Execution_Time_Image(Res.Best_Context_Switch) & """ ");
      Ada.Text_Io.Put
        (File,"Max_Priority=""" & IO.Priority_Image(Res.Max_Priority) &
         """ ");
      Ada.Text_Io.Put_Line
        (File,"Min_Priority=""" & IO.Priority_Image(Res.Min_Priority) &
         """ />");
   end Print_XML;

   function Clone
     (Policy : Fixed_Priority)
     return  Scheduling_Policy_Ref
   is
      Policy_Ref : Scheduling_Policy_Ref;
   begin
      Policy_Ref:=new Fixed_Priority'(Policy);
      return Policy_Ref;
   end Clone;


   -----------------------------
   -- Earliest Deadline First
   -----------------------------

   procedure Set_Worst_Context_Switch
     (Policy : in out EDF;
      The_Worst_Context_Switch : Normalized_Execution_Time)
   is
   begin
      Policy.Worst_Context_Switch := The_Worst_Context_Switch;
   end Set_Worst_Context_Switch;

   procedure Set_Avg_Context_Switch
     (Policy : in out EDF;
      The_Avg_Context_Switch : Normalized_Execution_Time)
   is
   begin
      Policy.Avg_Context_Switch := The_Avg_Context_Switch;
   end Set_Avg_Context_Switch;

   procedure Set_Best_Context_Switch
     (Policy : in out EDF;
      The_Best_Context_Switch : Normalized_Execution_Time)
   is
   begin
      Policy.Best_Context_Switch := The_Best_Context_Switch;
   end Set_Best_Context_Switch;

   function Worst_Context_Switch
     (Policy : EDF) return Normalized_Execution_Time
   is
   begin
      return Policy.Worst_Context_Switch;
   end Worst_Context_Switch;

   function Avg_Context_Switch
     (Policy : EDF) return Normalized_Execution_Time
   is
   begin
      return Policy.Avg_Context_Switch;
   end Avg_Context_Switch;

   function Best_Context_Switch
     (Policy : EDF) return Normalized_Execution_Time
   is
   begin
      return Policy.Best_Context_Switch;
   end Best_Context_Switch;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out EDF;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 20;
   begin
      Print(File,Scheduling_Policy(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "EDF",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Worst_Context_Switch",
         IO.Execution_Time_Image(Res.Worst_Context_Switch),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Avg_Context_Switch",
         IO.Execution_Time_Image(Res.Avg_Context_Switch),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Best_Context_Switch",
         IO.Execution_Time_Image(Res.Best_Context_Switch),
         Indentation+2,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out EDF;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 20;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:EDF_Scheduler ");
      Ada.Text_Io.Put
        (File,"Worst_Context_Switch=""" &
         Io.Execution_Time_Image(Res.Worst_Context_Switch) & """ ");
      Ada.Text_Io.Put
        (File,"Avg_Context_Switch=""" &
         IO.Execution_Time_Image(Res.Avg_Context_Switch) & """ ");
      Ada.Text_Io.Put_Line
        (File,"Best_Context_Switch=""" &
         IO.Execution_Time_Image(Res.Best_Context_Switch) & """ />");
   end Print_XML;

   function Clone
     (Policy : EDF)
     return  Scheduling_Policy_Ref
   is
      Policy_Ref : Scheduling_Policy_Ref;
   begin
      Policy_Ref:=new EDF'(Policy);
      return Policy_Ref;
   end Clone;

   -----------------------------
   -- Fixed_Priority_Packet_Based
   -----------------------------

   procedure Set_Packet_Worst_Overhead
     (Policy : in out FP_Packet_Based;
      The_Packet_Worst_Overhead : Normalized_Execution_Time)
   is
   begin
      Policy.Packet_Worst_Overhead := The_Packet_Worst_Overhead;
      Policy.Packet_Worst_Ovhd_Units_Are_Time:=True;
   end Set_Packet_Worst_Overhead;

   procedure Set_Packet_Avg_Overhead
     (Policy : in out FP_Packet_Based;
      The_Packet_Avg_Overhead : Normalized_Execution_Time)
   is
   begin
      Policy.Packet_Avg_Overhead := The_Packet_Avg_Overhead;
      Policy.Packet_Avg_Ovhd_Units_Are_Time:=True;
   end Set_Packet_Avg_Overhead;

   procedure Set_Packet_Best_Overhead
     (Policy : in out FP_Packet_Based;
      The_Packet_Best_Overhead : Normalized_Execution_Time)
   is
   begin
      Policy.Packet_Best_Overhead := The_Packet_Best_Overhead;
      Policy.Packet_Best_Ovhd_Units_Are_Time:=True;
   end Set_Packet_Best_Overhead;

   function Packet_Worst_Overhead
     (Policy : FP_Packet_Based;
      Throughput : Throughput_Value) return Normalized_Execution_Time
   is
   begin
      if Policy.Packet_Worst_Ovhd_Units_Are_Time then
         return Policy.Packet_Worst_Overhead;
      else
         return (Policy.Packet_Overhead_Max_Size/Throughput);
      end if;
   end Packet_Worst_Overhead;

   function Packet_Avg_Overhead
     (Policy : FP_Packet_Based;
      Throughput : Throughput_Value) return Normalized_Execution_Time
   is
   begin
      if Policy.Packet_Avg_Ovhd_Units_Are_Time then
         return Policy.Packet_Avg_Overhead;
      else
         return (Policy.Packet_Overhead_Avg_Size/Throughput);
      end if;
   end Packet_Avg_Overhead;

   function Packet_Best_Overhead
     (Policy : FP_Packet_Based;
      Throughput : Throughput_Value) return Normalized_Execution_Time
   is
   begin
      if Policy.Packet_Best_Ovhd_Units_Are_Time then
         return Policy.Packet_Best_Overhead;
      else
         return (Policy.Packet_Overhead_Min_Size/Throughput);
      end if;
   end Packet_Best_Overhead;

   ------------------------------
   -- Packet_Overhead_Avg_Size --
   ------------------------------

   function Packet_Overhead_Avg_Size
     (Policy : FP_Packet_Based;
      Throughput : Throughput_Value)
     return Bit_Count
   is
   begin
      if Policy.Packet_Avg_Ovhd_Units_Are_Time then
         return (Policy.Packet_Avg_Overhead)*Throughput;
      else
         return Policy.Packet_Overhead_Avg_Size;
      end if;
   end Packet_Overhead_Avg_Size;

   ------------------------------
   -- Packet_Overhead_Max_Size --
   ------------------------------

   function Packet_Overhead_Max_Size
     (Policy : FP_Packet_Based;
      Throughput : Throughput_Value)
     return Bit_Count
   is
   begin
      if Policy.Packet_Worst_Ovhd_Units_Are_Time then
         return (Policy.Packet_Worst_Overhead)*Throughput;
      else
         return Policy.Packet_Overhead_Max_Size;
      end if;
   end Packet_Overhead_Max_Size;

   ------------------------------
   -- Packet_Overhead_Min_Size --
   ------------------------------

   function Packet_Overhead_Min_Size
     (Policy : FP_Packet_Based;
      Throughput : Throughput_Value)
     return Bit_Count
   is
   begin
      if Policy.Packet_Best_Ovhd_Units_Are_Time then
         return (Policy.Packet_Best_Overhead)*Throughput;
      else
         return Policy.Packet_Overhead_Min_Size;
      end if;
   end Packet_Overhead_Min_Size;

   ----------------------------------
   -- Set_Packet_Overhead_Avg_Size --
   ----------------------------------

   procedure Set_Packet_Overhead_Avg_Size
     (Policy : in out FP_Packet_Based;
      The_Packet_Overhead_Avg_Size : Bit_Count)
   is
   begin
      Policy.Packet_Overhead_Avg_Size:=The_Packet_Overhead_Avg_Size;
      Policy.Packet_Avg_Ovhd_Units_Are_Time:=False;
   end Set_Packet_Overhead_Avg_Size;

   ----------------------------------
   -- Set_Packet_Overhead_Max_Size --
   ----------------------------------

   procedure Set_Packet_Overhead_Max_Size
     (Policy : in out FP_Packet_Based;
      The_Packet_Overhead_Max_Size : Bit_Count)
   is
   begin
      Policy.Packet_Overhead_Max_Size:=The_Packet_Overhead_Max_Size;
      Policy.Packet_Worst_Ovhd_Units_Are_Time:=False;
   end Set_Packet_Overhead_Max_Size;

   ----------------------------------
   -- Set_Packet_Overhead_Min_Size --
   ----------------------------------

   procedure Set_Packet_Overhead_Min_Size
     (Policy : in out FP_Packet_Based;
      The_Packet_Overhead_Min_Size : Bit_Count)
   is
   begin
      Policy.Packet_Overhead_Min_Size:=The_Packet_Overhead_Min_Size;
      Policy.Packet_Best_Ovhd_Units_Are_Time:=False;
   end Set_Packet_Overhead_Min_Size;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out FP_Packet_Based;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 24;
   begin
      Print(File,Scheduling_Policy(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "FP_Packet_Based",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      if Res.Packet_Worst_Ovhd_Units_Are_Time then
         MAST.IO.Print_Arg
           (File,"Packet_Worst_Overhead",
            IO.Execution_Time_Image(Res.Packet_Worst_Overhead),
            Indentation+2,Names_Length);
      else
         MAST.IO.Print_Arg
           (File,"Packet_Overhead_Max_Size",
            IO.Bit_Count_Image(Res.Packet_Overhead_Max_Size),
            Indentation+2,Names_Length);
      end if;
      MAST.IO.Print_Separator(File);
      if Res.Packet_Avg_Ovhd_Units_Are_Time then
         MAST.IO.Print_Arg
           (File,"Packet_Avg_Overhead",
            IO.Execution_Time_Image(Res.Packet_Avg_Overhead),
            Indentation+2,Names_Length);
      else
         MAST.IO.Print_Arg
           (File,"Packet_Overhead_Avg_Size",
            IO.Bit_Count_Image(Res.Packet_Overhead_Avg_Size),
            Indentation+2,Names_Length);
      end if;
      MAST.IO.Print_Separator(File);
      if Res.Packet_Best_Ovhd_Units_Are_Time then
         MAST.IO.Print_Arg
           (File,"Packet_Best_Overhead",
            IO.Execution_Time_Image(Res.Packet_Best_Overhead),
            Indentation+2,Names_Length);
      else
         MAST.IO.Print_Arg
           (File,"Packet_Overhead_Min_Size",
            IO.Bit_Count_Image(Res.Packet_Overhead_Min_Size),
            Indentation+2,Names_Length);
      end if;
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Max_Priority",
         Priority'Image(Res.Max_Priority),Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Min_Priority",
         Priority'Image(Res.Min_Priority),Indentation+2,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out FP_Packet_Based;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 21;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:FP_Packet_Based_Scheduler ");
      if Res.Packet_Worst_Ovhd_Units_Are_Time
      then
         Ada.Text_Io.Put
           (File,"Packet_Overhead_Max_Size=""" &
            Io.Bit_Count_Image(Res.Packet_Worst_Overhead*1.0E9) & """ ");
      else
         Ada.Text_Io.Put
           (File,"Packet_Overhead_Max_Size=""" &
            Io.Bit_Count_Image(Res.Packet_Overhead_Max_Size) & """ ");
      end if;
      if Res.Packet_Avg_Ovhd_Units_Are_Time
      then
         Ada.Text_Io.Put
           (File,"Packet_Overhead_Avg_Size=""" &
            Io.Bit_Count_Image(Res.Packet_Avg_Overhead*1.0E9) & """ ");
      else
         Ada.Text_Io.Put
           (File,"Packet_Overhead_Avg_Size=""" &
            Io.Bit_Count_Image(Res.Packet_Overhead_Avg_Size) & """ ");
      end if;
      if Res.Packet_Best_Ovhd_Units_Are_Time
      then
         Ada.Text_Io.Put
           (File,"Packet_Overhead_Min_Size=""" &
            Io.Bit_Count_Image(Res.Packet_Best_Overhead*1.0E9) & """ ");
      else
         Ada.Text_Io.Put
           (File,"Packet_Overhead_Min_Size=""" &
            Io.Bit_Count_Image(Res.Packet_Overhead_Min_Size) & """ ");
      end if;
      Ada.Text_Io.Put
        (File,"Max_Priority=""" & IO.Priority_Image(Res.Max_Priority) &
         """ ");
      Ada.Text_Io.Put_Line
        (File,"Min_Priority=""" & IO.Priority_Image(Res.Min_Priority) &
         """ />");
   end Print_XML;


   function Clone
     (Policy : FP_Packet_Based)
     return  Scheduling_Policy_Ref
   is
      Policy_Ref : Scheduling_Policy_Ref;
   begin
      Policy_Ref:=new FP_Packet_Based'(Policy);
      return Policy_Ref;
   end Clone;

end Mast.Scheduling_Policies;
