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

with Ada.Text_IO, Mast.Drivers, Mast.Scheduling_Servers, Mast.Operations;

package Mast.Processing_Resources.Network is

   -----------------------
   -- Network
   -----------------------

   type Network is abstract new Processing_Resource with private;

   type Network_Ref is access all Network'Class;

   type Driver_Iteration_Object is private;

   procedure Set_Transmission_Mode
     (Net  : in out Network;
      The_Transmission_Mode : Transmission_Kind);
   function Transmission_Mode
     (Net  : Network) return Transmission_Kind;

   procedure Set_Throughput
     (Net  : in out Network;
      The_Throughput : Throughput_Value);
   function Throughput
     (Net  : Network) return Throughput_Value;

   procedure Add_Driver
     (Net : in out Network;
      The_Driver : MAST.Drivers.Driver_Ref);

   procedure Remove_Driver
     (Net : in out Network;
      The_Driver : MAST.Drivers.Driver_Ref);
   -- raises List_Exceptions.Not_Found if driver not found

   function Num_Of_Drivers
     (Net : Network)
     return Natural;

   procedure Rewind_Drivers
     (Net : in Network;
      Iterator : out Driver_Iteration_Object);

   procedure Get_Next_Driver
     (Net : in Network;
      The_Driver : out MAST.Drivers.Driver_Ref;
      Iterator : in out Driver_Iteration_Object);

   -----------------------
   -- Network
   -----------------------

   type Packet_Based_Network is new Network with private;

   procedure Set_Max_Blocking
     (Net  : in out Packet_Based_Network;
      The_Max_Blocking : Normalized_Execution_Time);
   function Max_Blocking
     (Net  : Packet_Based_Network) return Normalized_Execution_Time;

   procedure Set_Max_Packet_Transmission_Time
     (Net  : in out Packet_Based_Network;
      The_Max_Transmission_Time : Normalized_Execution_Time);
   function Max_Packet_Transmission_Time
     (Net  : Packet_Based_Network) return Normalized_Execution_Time;

   procedure Set_Min_Packet_Transmission_Time
     (Net  : in out Packet_Based_Network;
      The_Min_Transmission_Time : Normalized_Execution_Time);
   function Min_Packet_Transmission_Time
     (Net  : Packet_Based_Network) return Normalized_Execution_Time;

   procedure Set_Max_Packet_Size
     (Net  : in out Packet_Based_Network;
      The_Max_Size : Bit_Count);
   function Max_Packet_Size
     (Net  : Packet_Based_Network) return Bit_Count;

   procedure Set_Min_Packet_Size
     (Net  : in out Packet_Based_Network;
      The_Min_Size : Bit_Count);
   function Min_Packet_Size
     (Net  : Packet_Based_Network) return Bit_Count;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Packet_Based_Network;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Packet_Based_Network;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Res : Packet_Based_Network)
     return  Processing_Resource_Ref;

   procedure Adjust
     (Net : in Packet_Based_Network;
      Server_List : in Scheduling_Servers.Lists.List;
      Op_List : in Operations.Lists.List);
   -- it may raise Object_Not_found

   -----------------------------------------------------------------
   -- List-adjust operation (put here to avoid circular references)
   -----------------------------------------------------------------

   procedure Adjust
     (The_List : in Processing_Resources.Lists.List;
      Server_List : in Scheduling_Servers.Lists.List;
      Op_List : in Operations.Lists.List);
   -- it may raise Object_Not_found

private

   type Driver_Iteration_Object is new Drivers.Lists.Iteration_Object;

   type Network is abstract new Processing_Resource with record
      Transmission_Mode : Transmission_Kind:=Half_Duplex;
      The_Throughput : Throughput_Value:=0.0; -- Mbits/time unit
      List_Of_Drivers : Drivers.Lists.List;
   end record;

   type Packet_Based_Network is new Network with record
      Max_Blocking : Normalized_Execution_Time:=0.0;
      Max_Packet_Transmission_Time,
      Min_Packet_Transmission_Time:
         Normalized_Execution_Time := Large_Execution_Time;
      Max_Packet_Size,
      Min_Packet_Size: Bit_Count :=Large_Bit_Count;
      Max_Packet_Units_Are_Time,
      Min_Packet_Units_Are_Time: Boolean:=True;
   end record;

end Mast.Processing_Resources.Network;
