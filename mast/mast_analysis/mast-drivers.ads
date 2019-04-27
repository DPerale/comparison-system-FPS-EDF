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

with Mast.Scheduling_Servers,Mast.Operations, Indexed_Lists, Ada.Text_IO;

package Mast.Drivers is

   type Rta_Overhead_Model_Type is (Coupled, Decoupled);

   --------------------
   -- Abstract Driver
   --------------------

   type Driver is abstract tagged private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Drv : in out Driver;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Drv : in out Driver;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   type Driver_Ref is access Driver'Class;

   function Clone
     (Drv : Driver)
     return  Driver_Ref is abstract;

   procedure Adjust
     (Drv : in out Driver;
      Srvr_List : in Scheduling_Servers.Lists.List;
      Op_List : in Operations.Lists.List) is abstract;

   package Lists is new Indexed_Lists
     (Element => Driver_Ref,
        "=" => "=");

   function Clone
     (The_List : in Lists.List)
     return Lists.List;

   procedure Adjust
     (The_List : in Lists.List;
      Srvr_List : in Scheduling_Servers.Lists.List;
      Op_List : in Operations.Lists.List);

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   --------------------
   -- Packet_Driver
   --------------------

   type Packet_Driver is new Driver with private;

   procedure Set_Packet_Server
     (The_Driver : in out Packet_Driver;
      The_Packet_Server : Scheduling_Servers.Scheduling_Server_Ref);
   function Packet_Server
     (The_Driver : Packet_Driver)
     return Scheduling_Servers.Scheduling_Server_Ref;

   procedure Set_Packet_Send_Operation
     (The_Driver : in out Packet_Driver;
      The_Packet_Send_Operation : Operations.Operation_Ref);
   function Packet_Send_Operation
     (The_Driver : Packet_Driver)
     return Operations.Operation_Ref;

   procedure Set_Packet_Receive_Operation
     (The_Driver : in out Packet_Driver;
      The_Packet_Receive_Operation : Operations.Operation_Ref);
   function Packet_Receive_Operation
     (The_Driver : Packet_Driver)
     return Operations.Operation_Ref;

   procedure Set_Message_Partitioning
     (The_Driver : in out Packet_Driver;
      Partitioning : Boolean);
   function Message_Partitioning
     (The_Driver : Packet_Driver)
     return Boolean;

   procedure Set_Rta_Overhead_Model
     (The_Driver : in out Packet_Driver;
      Model : Rta_Overhead_Model_Type);
   function Rta_Overhead_Model
     (The_Driver : Packet_Driver)
     return Rta_Overhead_Model_Type;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Drv : in out Packet_Driver;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Drv : in out Packet_Driver;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Drv : Packet_Driver)
     return  Driver_Ref;

   procedure Adjust
     (Drv : in out Packet_Driver;
      Srvr_List : in Scheduling_Servers.Lists.List;
      Op_List : in Operations.Lists.List);

   -----------------------------
   -- Character_Packet_Driver --
   -----------------------------

   type Character_Packet_Driver is new Packet_Driver with private;

   procedure Set_Character_Server
     (The_Driver : in out Character_Packet_Driver;
      The_Character_Server : Scheduling_Servers.Scheduling_Server_Ref);
   function Character_Server
     (The_Driver : Character_Packet_Driver)
     return Scheduling_Servers.Scheduling_Server_Ref;

   procedure Set_Character_Send_Operation
     (The_Driver : in out Character_Packet_Driver;
      The_Character_Send_Operation : Operations.Operation_Ref);
   function Character_Send_Operation
     (The_Driver : Character_Packet_Driver)
     return Operations.Operation_Ref;

   procedure Set_Character_Receive_Operation
     (The_Driver : in out Character_Packet_Driver;
      The_Character_Receive_Operation : Operations.Operation_Ref);
   function Character_Receive_Operation
     (The_Driver : Character_Packet_Driver)
     return Operations.Operation_Ref;

   procedure Set_Character_Transmission_Time
     (The_Driver : in out Character_Packet_Driver;
      The_Transmission_Time : Time);
   function Character_Transmission_Time
     (The_Driver : Character_Packet_Driver)
     return Time;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Drv : in out Character_Packet_Driver;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Drv : in out Character_Packet_Driver;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Drv : Character_Packet_Driver)
     return  Driver_Ref;

   procedure Adjust
     (Drv : in out Character_Packet_Driver;
      Srvr_List : in Scheduling_Servers.Lists.List;
      Op_List : in Operations.Lists.List);

   -----------------------------
   -- RTEP_Packet_Driver --
   -----------------------------

   type RTEP_Packet_Driver is new Packet_Driver with private;

   procedure Set_Number_Of_Stations
     (The_Driver : in out RTEP_Packet_Driver;
      The_Number_Of_Stations : Positive);
   function Number_Of_Stations
     (The_Driver : RTEP_Packet_Driver)
     return Positive;

   procedure Set_Token_Delay
     (The_Driver : in out RTEP_Packet_Driver;
      The_Token_Delay : Time);
   function Token_Delay
     (The_Driver : RTEP_Packet_Driver)
     return Time;

   procedure Set_Failure_Timeout
     (The_Driver : in out RTEP_Packet_Driver;
      The_Failure_Timeout : Time);
   function Failure_Timeout
     (The_Driver : RTEP_Packet_Driver)
     return Time;

   procedure Set_Token_Transmission_Retries
     (The_Driver : in out RTEP_Packet_Driver;
      The_Token_Transmission_Retries : Natural);
   function Token_Transmission_Retries
     (The_Driver : RTEP_Packet_Driver)
     return Natural;

   procedure Set_Packet_Transmission_Retries
     (The_Driver : in out RTEP_Packet_Driver;
      The_Packet_Transmission_Retries : Natural);
   function Packet_Transmission_Retries
     (The_Driver : RTEP_Packet_Driver)
     return Natural;

   procedure Set_Packet_Interrupt_Server
     (The_Driver : in out RTEP_Packet_Driver;
      The_Packet_Interrupt_Server : Scheduling_Servers.Scheduling_Server_Ref);
   function Packet_Interrupt_Server
     (The_Driver : RTEP_Packet_Driver)
     return Scheduling_Servers.Scheduling_Server_Ref;

   procedure Set_Packet_ISR_Operation
     (The_Driver : in out RTEP_Packet_Driver;
      The_Packet_ISR_Operation : Operations.Operation_Ref);
   function Packet_ISR_Operation
     (The_Driver : RTEP_Packet_Driver)
     return Operations.Operation_Ref;

   procedure Set_Token_Check_Operation
     (The_Driver : in out RTEP_Packet_Driver;
      The_Token_Check_Operation : Operations.Operation_Ref);
   function Token_Check_Operation
     (The_Driver : RTEP_Packet_Driver)
     return Operations.Operation_Ref;

   procedure Set_Token_Manage_Operation
     (The_Driver : in out RTEP_Packet_Driver;
      The_Token_Manage_Operation : Operations.Operation_Ref);
   function Token_Manage_Operation
     (The_Driver : RTEP_Packet_Driver)
     return Operations.Operation_Ref;

   procedure Set_Packet_Discard_Operation
     (The_Driver : in out RTEP_Packet_Driver;
      The_Packet_Discard_Operation : Operations.Operation_Ref);
   function Packet_Discard_Operation
     (The_Driver : RTEP_Packet_Driver)
     return Operations.Operation_Ref;

   procedure Set_Token_Retransmission_Operation
     (The_Driver : in out RTEP_Packet_Driver;
      The_Token_Retransmission_Operation : Operations.Operation_Ref);
   function Token_Retransmission_Operation
     (The_Driver : RTEP_Packet_Driver)
     return Operations.Operation_Ref;

   procedure Set_Packet_Retransmission_Operation
     (The_Driver : in out RTEP_Packet_Driver;
      The_Packet_Retransmission_Operation : Operations.Operation_Ref);
   function Packet_Retransmission_Operation
     (The_Driver : RTEP_Packet_Driver)
     return Operations.Operation_Ref;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Drv : in out RTEP_Packet_Driver;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Drv : in out RTEP_Packet_Driver;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Drv : RTEP_Packet_Driver)
     return  Driver_Ref;

   procedure Adjust
     (Drv : in out RTEP_Packet_Driver;
      Srvr_List : in Scheduling_Servers.Lists.List;
      Op_List : in Operations.Lists.List);

private

   type Driver is abstract tagged null record;

   type Packet_Driver is new Driver with record
      Packet_Server : Scheduling_Servers.Scheduling_Server_Ref;
      Packet_Send_Operation,
      Packet_Receive_Operation: Operations.Operation_Ref;
      Message_Partitioning : Boolean:=True;
      Rta_Overhead_Model : Rta_Overhead_Model_Type:=Decoupled;
   end record;

   type Character_Packet_Driver is new Packet_Driver with record
      Character_Send_Operation,
      Character_Receive_Operation: Operations.Operation_Ref;
      Character_Server : Scheduling_Servers.Scheduling_Server_Ref;
      Character_Transmission_Time : Time:=Large_Time;
   end record;

   type RTEP_Packet_Driver is new Packet_Driver with record
      Number_Of_Stations : Positive:=Positive'Last;
      Token_Delay : Time:=0.0;
      Failure_Timeout : Time:= Large_Time;
      Token_Transmission_Retries,
      Packet_Transmission_Retries : Natural:=0;
      Packet_Interrupt_Server : Scheduling_Servers.Scheduling_Server_Ref;
      Packet_ISR_Operation,
      Token_Check_Operation,
      Token_Manage_Operation,
      Packet_Discard_Operation,
      Token_Retransmission_Operation,
      Packet_Retransmission_Operation: Operations.Operation_Ref;
   end record;

end Mast.Drivers;
