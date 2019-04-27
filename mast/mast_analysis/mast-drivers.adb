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

with Mast.IO,Mast.Scheduling_Servers,Mast.Operations;
use type Mast.Scheduling_Servers.Scheduling_Server_Ref;
use type Mast.Operations.Operation_Ref;

package body Mast.Drivers is

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (The_List : in Lists.List;
      Srvr_List : in Scheduling_Servers.Lists.List;
      Op_List : in Operations.Lists.List)
   is
      Iterator : Lists.Iteration_Object;
      Drv_Ref : Driver_Ref;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Drv_Ref,The_List,Iterator);
         Adjust(Drv_Ref.all,Srvr_List,Op_List);
      end loop;
   end Adjust;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (Drv : in out Packet_Driver;
      Srvr_List : in Scheduling_Servers.Lists.List;
      Op_List : in Operations.Lists.List)
   is
   begin
      Scheduling_Servers.Adjust_Ref(Drv.Packet_Server,Srvr_List);
      Operations.Adjust_Ref(Drv.Packet_Send_Operation,Op_List);
      Operations.Adjust_Ref(Drv.Packet_Receive_Operation,Op_List);
   exception
      when Object_Not_Found =>
         Set_Exception_Message(" Packet_Driver "&Get_Exception_Message);
         raise;
   end Adjust;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (Drv : in out Character_Packet_Driver;
      Srvr_List : in Scheduling_Servers.Lists.List;
      Op_List : in Operations.Lists.List)
   is
   begin
      Adjust(Packet_Driver(Drv),Srvr_List,Op_List);
      Scheduling_Servers.Adjust_Ref(Drv.Character_Server,Srvr_List);
      Operations.Adjust_Ref(Drv.Character_Send_Operation,Op_List);
      Operations.Adjust_Ref(Drv.Character_Receive_Operation,Op_List);
   exception
      when Object_Not_Found =>
         Set_Exception_Message
           (" Character_Packet_Driver "&Get_Exception_Message);
         raise;
   end Adjust;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (Drv : in out RTEP_Packet_Driver;
      Srvr_List : in Scheduling_Servers.Lists.List;
      Op_List : in Operations.Lists.List)
   is
   begin
      Adjust(Packet_Driver(Drv),Srvr_List,Op_List);
      Scheduling_Servers.Adjust_Ref(Drv.Packet_Interrupt_Server,Srvr_List);
      Operations.Adjust_Ref(Drv.Packet_ISR_Operation,Op_List);
      Operations.Adjust_Ref(Drv.Token_Check_Operation,Op_List);
      Operations.Adjust_Ref(Drv.Token_Manage_Operation,Op_List);
      Operations.Adjust_Ref(Drv.Packet_Discard_Operation,Op_List);
      Operations.Adjust_Ref(Drv.Token_Retransmission_Operation,Op_List);
      Operations.Adjust_Ref(Drv.Packet_Retransmission_Operation,Op_List);
   exception
      when Object_Not_Found =>
         Set_Exception_Message(" RTEP_Packet_Driver "&Get_Exception_Message);
         raise;
   end Adjust;

   ---------------------------------
   -- Character_Receive_Operation --
   ---------------------------------

   function Character_Receive_Operation
     (The_Driver : Character_Packet_Driver)
     return Operations.Operation_Ref
   is
   begin
      return The_Driver.Character_Receive_Operation;
   end Character_Receive_Operation;

   ------------------------------
   -- Character_Send_Operation --
   ------------------------------

   function Character_Send_Operation
     (The_Driver : Character_Packet_Driver)
     return Operations.Operation_Ref
   is
   begin
      return The_Driver.Character_Send_Operation;
   end Character_Send_Operation;

   ----------------------
   -- Character_Server --
   ----------------------

   function Character_Server
     (The_Driver : Character_Packet_Driver)
     return Scheduling_Servers.Scheduling_Server_Ref
   is
   begin
      return The_Driver.Character_Server;
   end Character_Server;

   ---------------------------------
   -- Character_Transmission_Time --
   ---------------------------------

   function Character_Transmission_Time
     (The_Driver : Character_Packet_Driver)
     return Time
   is
   begin
      return The_Driver.Character_Transmission_Time;
   end Character_Transmission_Time;

   -----------
   -- Clone --
   -----------

   function Clone
     (The_List : in Lists.List)
     return Lists.List
   is
      The_Copy : Lists.List;
      Iterator : Lists.Iteration_Object;
      Drv_Ref, Drv_Ref_Copy : Driver_Ref;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Drv_Ref,The_List,Iterator);
         Drv_Ref_Copy:=Clone(Drv_Ref.all);
         Lists.Add(Drv_Ref_Copy,The_Copy);
      end loop;
      return The_Copy;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Drv : Packet_Driver)
     return  Driver_Ref
   is
      Drv_Ref : Driver_Ref;
   begin
      Drv_Ref:=new Packet_Driver'(Drv);
      return Drv_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Drv : Character_Packet_Driver)
     return  Driver_Ref
   is
      Drv_Ref : Driver_Ref;
   begin
      Drv_Ref:=new Character_Packet_Driver'(Drv);
      return Drv_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Drv : RTEP_Packet_Driver)
     return  Driver_Ref
   is
      Drv_Ref : Driver_Ref;
   begin
      Drv_Ref:=new RTEP_Packet_Driver'(Drv);
      return Drv_Ref;
   end Clone;

   ---------------------
   -- Failure_Timeout --
   ---------------------

   function Failure_Timeout
     (The_Driver : RTEP_Packet_Driver)
     return Time
   is
   begin
      return The_Driver.Failure_Timeout;
   end Failure_Timeout;

   --------------------------
   -- Message_Partitioning --
   --------------------------

   function Message_Partitioning
     (The_Driver : Packet_Driver)
     return Boolean
   is
   begin
      return The_Driver.Message_Partitioning;
   end Message_Partitioning;

   ------------------------
   -- Number_Of_Stations --
   ------------------------

   function Number_Of_Stations
     (The_Driver : RTEP_Packet_Driver)
     return Positive
   is
   begin
      return The_Driver.Number_Of_Stations;
   end Number_Of_Stations;

   ------------------------------
   -- Packet_Discard_Operation --
   ------------------------------

   function Packet_Discard_Operation
     (The_Driver : RTEP_Packet_Driver)
     return Operations.Operation_Ref
   is
   begin
      return The_Driver.Packet_Discard_Operation;
   end Packet_Discard_Operation;

   -----------------------------
   -- Packet_Interrupt_Server --
   -----------------------------

   function Packet_Interrupt_Server
     (The_Driver : RTEP_Packet_Driver)
     return Scheduling_Servers.Scheduling_Server_Ref
   is
   begin
      return The_Driver.Packet_Interrupt_Server;
   end Packet_Interrupt_Server;

   --------------------------
   -- Packet_ISR_Operation --
   --------------------------

   function Packet_ISR_Operation
     (The_Driver : RTEP_Packet_Driver)
     return Operations.Operation_Ref
   is
   begin
      return The_Driver.Packet_ISR_Operation;
   end Packet_ISR_Operation;

   ------------------------------
   -- Packet_Receive_Operation --
   ------------------------------

   function Packet_Receive_Operation
     (The_Driver : Packet_Driver)
     return Operations.Operation_Ref
   is
   begin
      return The_Driver.Packet_Receive_Operation;
   end Packet_Receive_Operation;

   -------------------------------------
   -- Packet_Retransmission_Operation --
   -------------------------------------

   function Packet_Retransmission_Operation
     (The_Driver : RTEP_Packet_Driver)
     return Operations.Operation_Ref
   is
   begin
      return The_Driver.Packet_Retransmission_Operation;
   end Packet_Retransmission_Operation;

   ---------------------------
   -- Packet_Send_Operation --
   ---------------------------

   function Packet_Send_Operation
     (The_Driver : Packet_Driver)
     return Operations.Operation_Ref
   is
   begin
      return The_Driver.Packet_Send_Operation;
   end Packet_Send_Operation;

   -------------------
   -- Packet_Server --
   -------------------

   function Packet_Server
     (The_Driver : Packet_Driver)
     return Scheduling_Servers.Scheduling_Server_Ref
   is
   begin
      return The_Driver.Packet_Server;
   end Packet_Server;

   ---------------------------------
   -- Packet_Transmission_Retries --
   ---------------------------------

   function Packet_Transmission_Retries
     (The_Driver : RTEP_Packet_Driver)
     return Natural
   is
   begin
      return The_Driver.Packet_Transmission_Retries;
   end Packet_Transmission_Retries;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Drv : in out Driver;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Drv_Ref : Driver_Ref;
      Iterator : Lists.Index;
   begin
      MAST.IO.Print_List_Item(File,MAST.IO.Left_Paren,
                              Indentation);
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Drv_Ref,The_List,Iterator);
         Print(File,Drv_Ref.all,Indentation+1,True);
         if I=Lists.Size(The_List) then
            Ada.Text_IO.Put(File,")");
         else
            MAST.IO.Print_Separator(File);
         end if;
      end loop;
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Drv : in out Packet_Driver;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 24;
   begin
      Print(File,Driver(Drv),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Packet_Driver",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      Mast.IO.Print_Arg
        (File,"Message_Partitioning",
         IO.Boolean_Image(Drv.Message_Partitioning),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      Mast.IO.Print_Arg
        (File,"RTA_Overhead_Model",
         Drivers.Rta_Overhead_Model_Type'Image(Drv.Rta_Overhead_Model),
         Indentation+2,Names_Length);
      if Drv.Packet_Server/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Packet_Server",
            IO.Name_Image(Mast.Scheduling_Servers.Name(Drv.Packet_Server)),
            Indentation+2,Names_Length);
      end if;
      if Drv.Packet_Send_Operation/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Packet_Send_Operation",
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_Send_Operation)),
            Indentation+2,Names_Length);
      end if;
      if Drv.Packet_Receive_Operation/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Packet_Receive_Operation",
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_Receive_Operation)),
            Indentation+2,Names_Length);
      end if;
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Drv : in out Character_Packet_Driver;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 27;
   begin
      Print(File,Driver(Drv),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Character_Packet_Driver",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      Mast.IO.Print_Arg
        (File,"Message_Partitioning",
         IO.Boolean_Image(Drv.Message_Partitioning),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      Mast.IO.Print_Arg
        (File,"RTA_Overhead_Model",
         Drivers.Rta_Overhead_Model_Type'Image(Drv.Rta_Overhead_Model),
         Indentation+2,Names_Length);
      if Drv.Packet_Server/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Packet_Server",
            IO.Name_Image(Mast.Scheduling_Servers.Name(Drv.Packet_Server)),
            Indentation+2,Names_Length);
      end if;
      if Drv.Packet_Send_Operation/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Packet_Send_Operation",
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_Send_Operation)),
            Indentation+2,Names_Length);
      end if;
      if Drv.Packet_Receive_Operation/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Packet_Receive_Operation",
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_Receive_Operation)),
            Indentation+2,Names_Length);
      end if;
      if Drv.Character_Server/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Character_Server",
            IO.Name_Image(Mast.Scheduling_Servers.Name
                          (Drv.Character_Server)),
            Indentation+2,Names_Length);
      end if;
      if Drv.Character_Send_Operation/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Character_Send_Operation",
            IO.Name_Image(Mast.Operations.Name(Drv.Character_Send_Operation)),
            Indentation+2,Names_Length);
      end if;
      if Drv.Character_Receive_Operation/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Character_Receive_Operation",
            IO.Name_Image
            (Mast.Operations.Name(Drv.Character_Receive_Operation)),
            Indentation+2,Names_Length);
      end if;
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Character_Transmission_Time",
         IO.Time_Image(Drv.Character_Transmission_Time),
         Indentation+2,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Drv : in out RTEP_Packet_Driver;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 31;
   begin
      Print(File,Driver(Drv),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "RTEP_Packet_Driver",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      Mast.IO.Print_Arg
        (File,"Message_Partitioning",
         IO.Boolean_Image(Drv.Message_Partitioning),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      Mast.IO.Print_Arg
        (File,"RTA_Overhead_Model",
         Drivers.Rta_Overhead_Model_Type'Image(Drv.Rta_Overhead_Model),
         Indentation+2,Names_Length);
      if Drv.Packet_Server/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Packet_Server",
            IO.Name_Image(Mast.Scheduling_Servers.Name(Drv.Packet_Server)),
            Indentation+2,Names_Length);
      end if;
      if Drv.Packet_Send_Operation/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Packet_Send_Operation",
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_Send_Operation)),
            Indentation+2,Names_Length);
      end if;
      if Drv.Packet_Receive_Operation/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Packet_Receive_Operation",
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_Receive_Operation)),
            Indentation+2,Names_Length);
      end if;
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Number_Of_Stations",
         Integer'Image(Drv.Number_Of_Stations),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Token_Delay",
         IO.Time_Image(Drv.Token_Delay),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Failure_Timeout",
         IO.Time_Image(Drv.Failure_Timeout),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Token_Transmission_Retries",
         Integer'Image(Drv.Token_Transmission_Retries),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Packet_Transmission_Retries",
         Integer'Image(Drv.Packet_Transmission_Retries),
         Indentation+2,Names_Length);

      if Drv.Packet_Interrupt_Server/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Packet_Interrupt_Server",
            IO.Name_Image(Mast.Scheduling_Servers.Name
                          (Drv.Packet_Interrupt_Server)),
            Indentation+2,Names_Length);
      end if;
      if Drv.Packet_ISR_Operation/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Packet_ISR_Operation",
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_ISR_Operation)),
            Indentation+2,Names_Length);
      end if;
      if Drv.Token_Check_Operation/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Token_Check_Operation",
            IO.Name_Image(Mast.Operations.Name(Drv.Token_Check_Operation)),
            Indentation+2,Names_Length);
      end if;
      if Drv.Token_Manage_Operation/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Token_Manage_Operation",
            IO.Name_Image(Mast.Operations.Name(Drv.Token_Manage_Operation)),
            Indentation+2,Names_Length);
      end if;
      if Drv.Packet_Discard_Operation/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Packet_Discard_Operation",
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_Discard_Operation)),
            Indentation+2,Names_Length);
      end if;
      if Drv.Token_Retransmission_Operation/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Token_Retransmission_Operation",
            IO.Name_Image
            (Mast.Operations.Name(Drv.Token_Retransmission_Operation)),
            Indentation+2,Names_Length);
      end if;
      if Drv.Packet_Retransmission_Operation/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Packet_Retransmission_Operation",
            IO.Name_Image
            (Mast.Operations.Name(Drv.Packet_Retransmission_Operation)),
            Indentation+2,Names_Length);
      end if;
      Ada.Text_IO.Put(File,")");
   end Print;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Drv_Ref : Driver_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List)
      loop
         Lists.Get_Next_Item(Drv_Ref,The_List,Iterator);
         Print_XML(File,Drv_Ref.all,Indentation+3,True);
      end loop;
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Drv : in out Packet_Driver;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 24;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_mdl:Packet_Driver ");
      if Drv.Packet_Server/=null then
         Ada.Text_IO.Put
           (File,"Packet_Server=""" &
            IO.Name_Image(Mast.Scheduling_Servers.Name(Drv.Packet_Server)) &
            """ ");
      end if;
      if Drv.Packet_Send_Operation/=null then
         Ada.Text_IO.Put
           (File,"Packet_Send_Operation=""" &
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_Send_Operation)) &
            """ ");
      end if;
      if Drv.Packet_Receive_Operation/=null then
         Ada.Text_IO.Put
           (File,"Packet_Receive_Operation=""" &
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_Receive_Operation)) &
            """ ");
      end if;
      Ada.Text_IO.Put
        (File,"Message_Partitioning="""&
         IO.Boolean_Image(Drv.Message_Partitioning)&""" ");
      Ada.Text_IO.Put_Line
        (File,"RTA_Overhead_Model="""&
         IO.XML_Enum_Image
         (Drivers.Rta_Overhead_Model_Type'Image(Drv.Rta_Overhead_Model))&
         """ />");
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Drv : in out Character_Packet_Driver;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 27;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_mdl:Character_Packet_Driver ");
      Ada.Text_IO.Put
        (File,"Packet_Server=""" &
         IO.Name_Image(Mast.Scheduling_Servers.Name(Drv.Packet_Server)) &
         """ ");
      if Drv.Character_Server/=null then
         Ada.Text_Io.Put
           (File,"Character_Server=""" &
            IO.Name_Image(Mast.Scheduling_Servers.Name(Drv.Character_Server)) &
            """ ");
      end if;
      Ada.Text_IO.Put(File,"Character_Transmission_Time= """ &
                      IO.Time_Image(Drv.Character_Transmission_Time) & """ ");
      if Drv.Packet_Send_Operation/=null then
         Ada.Text_IO.Put
           (File,"Packet_Send_Operation=""" &
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_Send_Operation)) &
            """ ");
      end if;
      if Drv.Packet_Receive_Operation/=null then
         Ada.Text_IO.Put
           (File,"Packet_Receive_Operation=""" &
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_Receive_Operation)) &
            """ ");
      end if;
      if Drv.Character_Send_Operation/=null then
         Ada.Text_IO.Put
           (File,"Character_Send_Operation=""" &
            IO.Name_Image(Mast.Operations.Name(Drv.Character_Send_Operation)) &
            """ ");
      end if;
      if Drv.Character_Receive_Operation/=null then
         Ada.Text_IO.Put
           (File,"Character_Receive_Operation=""" &
            IO.Name_Image
            (Mast.Operations.Name(Drv.Character_Receive_Operation)) &
            """ ");
      end if;
      Ada.Text_IO.Put
        (File,"Message_Partitioning="""&
         IO.Boolean_Image(Drv.Message_Partitioning)&""" ");
      Ada.Text_IO.Put_Line
        (File,"RTA_Overhead_Model="""&
         IO.XML_Enum_Image
         (Drivers.Rta_Overhead_Model_Type'Image(Drv.Rta_Overhead_Model))&
         """ />");
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Drv : in out RTEP_Packet_Driver;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_mdl:RTEP_Packet_Driver ");
      if Drv.Packet_Server/=null then
         Ada.Text_IO.Put
           (File,"Packet_Server=""" &
            IO.Name_Image(Mast.Scheduling_Servers.Name(Drv.Packet_Server)) &
            """ ");
      end if;
      if Drv.Packet_Send_Operation/=null then
         Ada.Text_IO.Put
           (File,"Packet_Send_Operation=""" &
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_Send_Operation)) &
            """ ");
      end if;
      if Drv.Packet_Receive_Operation/=null then
         Ada.Text_IO.Put
           (File,"Packet_Receive_Operation=""" &
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_Receive_Operation)) &
            """ ");
      end if;
      Ada.Text_IO.Put
        (File,"Number_Of_Stations=""" &
         IO.Integer_Image(Drv.Number_Of_Stations) & """ ");
      Ada.Text_IO.Put
        (File,"Token_Delay=""" &
         IO.Time_Image(Drv.Token_Delay) & """ ");
      Ada.Text_IO.Put
        (File,"Failure_Timeout=""" &
         IO.Time_Image(Drv.Failure_Timeout) & """ ");
      Ada.Text_IO.Put
        (File,"Token_Transmission_Retries=""" &
         IO.Integer_Image(Drv.Token_Transmission_Retries) & """ ");
      Ada.Text_IO.Put
        (File,"Packet_Transmission_Retries=""" &
         IO.Integer_Image(Drv.Packet_Transmission_Retries) & """ ");
      if Drv.Packet_Interrupt_Server/=null then
         Ada.Text_IO.Put
           (File,"Packet_Interrupt_Server=""" &
            IO.Name_Image(Mast.Scheduling_Servers.Name
                          (Drv.Packet_Interrupt_Server)) & """ ");
      end if;
      if Drv.Packet_ISR_Operation/=null then
         Ada.Text_IO.Put
           (File,"Packet_ISR_Operation=""" &
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_ISR_Operation)) &
            """ ");
      end if;
      if Drv.Token_Check_Operation/=null then
         Ada.Text_IO.Put
           (File,"Token_Check_Operation=""" &
            IO.Name_Image(Mast.Operations.Name(Drv.Token_Check_Operation)) &
            """ ");
      end if;
      if Drv.Token_Manage_Operation/=null then
         Ada.Text_IO.Put
           (File,"Token_Manage_Operation=""" &
            IO.Name_Image(Mast.Operations.Name(Drv.Token_Manage_Operation)) &
            """ ");
      end if;
      if Drv.Packet_Discard_Operation/=null then
         Ada.Text_IO.Put
           (File,"Packet_Discard_Operation=""" &
            IO.Name_Image(Mast.Operations.Name(Drv.Packet_Discard_Operation)) &
            """ ");
      end if;
      if Drv.Token_Retransmission_Operation/=null then
         Ada.Text_IO.Put
           (File,"Token_Retransmission_Operation=""" &
            IO.Name_Image
            (Mast.Operations.Name(Drv.Token_Retransmission_Operation)) &
            """ ");
      end if;
      if Drv.Packet_Retransmission_Operation/=null then
         Ada.Text_IO.Put
           (File,"Packet_Retransmission_Operation=""" &
            IO.Name_Image
            (Mast.Operations.Name(Drv.Packet_Retransmission_Operation)) &
            """ ");
      end if;
      Ada.Text_IO.Put
        (File,"Message_Partitioning="""&
         IO.Boolean_Image(Drv.Message_Partitioning)&""" ");
      Ada.Text_IO.Put_Line
        (File,"RTA_Overhead_Model="""&
         IO.XML_Enum_Image
         (Drivers.Rta_Overhead_Model_Type'Image(Drv.Rta_Overhead_Model))&
         """ />");
   end Print_XML;

   --------------------
   -- Rta_Overhead_Model --
   --------------------

   function Rta_Overhead_Model
     (The_Driver : Packet_Driver)
     return Rta_Overhead_Model_Type
   is
   begin
      return The_Driver.Rta_Overhead_Model;
   end Rta_Overhead_Model;

   -------------------------------------
   -- Set_Character_Receive_Operation --
   -------------------------------------

   procedure Set_Character_Receive_Operation
     (The_Driver : in out Character_Packet_Driver;
      The_Character_Receive_Operation : Operations.Operation_Ref)
   is
   begin
      The_Driver.Character_Receive_Operation:=
        The_Character_Receive_Operation;
   end Set_Character_Receive_Operation;

   ----------------------------------
   -- Set_Character_Send_Operation --
   ----------------------------------

   procedure Set_Character_Send_Operation
     (The_Driver : in out Character_Packet_Driver;
      The_Character_Send_Operation : Operations.Operation_Ref)
   is
   begin
      The_Driver.Character_Send_Operation:=
        The_Character_Send_Operation;
   end Set_Character_Send_Operation;

   --------------------------
   -- Set_Character_Server --
   --------------------------

   procedure Set_Character_Server
     (The_Driver : in out Character_Packet_Driver;
      The_Character_Server : Scheduling_Servers.Scheduling_Server_Ref)
   is
   begin
      The_Driver.Character_Server:=The_Character_Server;
   end Set_Character_Server;

   -------------------------------------
   -- Set_Character_Transmission_Time --
   -------------------------------------

   procedure Set_Character_Transmission_Time
     (The_Driver : in out Character_Packet_Driver;
      The_Transmission_Time : Time)
   is
   begin
      The_Driver.Character_Transmission_Time:=The_Transmission_Time;
   end Set_Character_Transmission_Time;

   -------------------------
   -- Set_Failure_Timeout --
   -------------------------

   procedure Set_Failure_Timeout
     (The_Driver : in out RTEP_Packet_Driver;
      The_Failure_Timeout : Time)
   is
   begin
      The_Driver.Failure_Timeout:=The_Failure_Timeout;
   end Set_Failure_Timeout;

   ------------------------------
   -- Set_Message_Partitioning --
   ------------------------------

   procedure Set_Message_Partitioning
     (The_Driver : in out Packet_Driver;
      Partitioning : Boolean)
   is
   begin
      The_Driver.Message_Partitioning:=Partitioning;
   end Set_Message_Partitioning;

   ----------------------------
   -- Set_Number_Of_Stations --
   ----------------------------

   procedure Set_Number_Of_Stations
     (The_Driver : in out RTEP_Packet_Driver;
      The_Number_Of_Stations : Positive)
   is
   begin
      The_Driver.Number_Of_Stations:=The_Number_Of_Stations;
   end Set_Number_Of_Stations;

   ------------------------
   -- Set_Rta_Overhead_Model --
   ------------------------

   procedure Set_Rta_Overhead_Model
     (The_Driver : in out Packet_Driver;
      Model : Rta_Overhead_Model_Type)
   is
   begin
      The_Driver.Rta_Overhead_Model:=Model;
   end Set_Rta_Overhead_Model;

   ----------------------------------
   -- Set_Packet_Discard_Operation --
   ----------------------------------

   procedure Set_Packet_Discard_Operation
     (The_Driver : in out RTEP_Packet_Driver;
      The_Packet_Discard_Operation : Operations.Operation_Ref)
   is
   begin
      The_Driver.Packet_Discard_Operation:=The_Packet_Discard_Operation;
   end Set_Packet_Discard_Operation;

   ---------------------------------
   -- Set_Packet_Interrupt_Server --
   ---------------------------------

   procedure Set_Packet_Interrupt_Server
     (The_Driver : in out RTEP_Packet_Driver;
      The_Packet_Interrupt_Server : Scheduling_Servers.Scheduling_Server_Ref)
   is
   begin
      The_Driver.Packet_Interrupt_Server:=The_Packet_Interrupt_Server;
   end Set_Packet_Interrupt_Server;

   ------------------------------
   -- Set_Packet_ISR_Operation --
   ------------------------------

   procedure Set_Packet_ISR_Operation
     (The_Driver : in out RTEP_Packet_Driver;
      The_Packet_ISR_Operation : Operations.Operation_Ref)
   is
   begin
      The_Driver.Packet_ISR_Operation:=The_Packet_ISR_Operation;
   end Set_Packet_ISR_Operation;

   ----------------------------------
   -- Set_Packet_Receive_Operation --
   ----------------------------------

   procedure Set_Packet_Receive_Operation
     (The_Driver : in out Packet_Driver;
      The_Packet_Receive_Operation : Operations.Operation_Ref)
   is
   begin
      The_Driver.Packet_Receive_Operation:=The_Packet_Receive_Operation;
   end Set_Packet_Receive_Operation;

   -----------------------------------------
   -- Set_Packet_Retransmission_Operation --
   -----------------------------------------

   procedure Set_Packet_Retransmission_Operation
     (The_Driver : in out RTEP_Packet_Driver;
      The_Packet_Retransmission_Operation : Operations.Operation_Ref)
   is
   begin
      The_Driver.Packet_Retransmission_Operation:=
        The_Packet_Retransmission_Operation;
   end Set_Packet_Retransmission_Operation;

   -------------------------------
   -- Set_Packet_Send_Operation --
   -------------------------------

   procedure Set_Packet_Send_Operation
     (The_Driver : in out Packet_Driver;
      The_Packet_Send_Operation : Operations.Operation_Ref)
   is
   begin
      The_Driver.Packet_Send_Operation:=The_Packet_Send_Operation;
   end Set_Packet_Send_Operation;

   -----------------------
   -- Set_Packet_Server --
   -----------------------

   procedure Set_Packet_Server
     (The_Driver : in out Packet_Driver;
      The_Packet_Server : Scheduling_Servers.Scheduling_Server_Ref)
   is
   begin
      The_Driver.Packet_Server:=The_Packet_Server;
   end Set_Packet_Server;

   -------------------------------------
   -- Set_Packet_Transmission_Retries --
   -------------------------------------

   procedure Set_Packet_Transmission_Retries
     (The_Driver : in out RTEP_Packet_Driver;
      The_Packet_Transmission_Retries : Natural)
   is
   begin
      The_Driver.Packet_Transmission_Retries:=The_Packet_Transmission_Retries;
   end Set_Packet_Transmission_Retries;

   -------------------------------
   -- Set_Token_Check_Operation --
   -------------------------------

   procedure Set_Token_Check_Operation
     (The_Driver : in out RTEP_Packet_Driver;
      The_Token_Check_Operation : Operations.Operation_Ref)
   is
   begin
      The_Driver.Token_Check_Operation:=The_Token_Check_Operation;
   end Set_Token_Check_Operation;

   ---------------------
   -- Set_Token_Delay --
   ---------------------

   procedure Set_Token_Delay
     (The_Driver : in out RTEP_Packet_Driver;
      The_Token_Delay : Time)
   is
   begin
      The_Driver.Token_Delay:=The_Token_Delay;
   end Set_Token_Delay;

   --------------------------------
   -- Set_Token_Manage_Operation --
   --------------------------------

   procedure Set_Token_Manage_Operation
     (The_Driver : in out RTEP_Packet_Driver;
      The_Token_Manage_Operation : Operations.Operation_Ref)
   is
   begin
      The_Driver.Token_Manage_Operation:=The_Token_Manage_Operation;
   end Set_Token_Manage_Operation;

   ----------------------------------------
   -- Set_Token_Retransmission_Operation --
   ----------------------------------------

   procedure Set_Token_Retransmission_Operation
     (The_Driver : in out RTEP_Packet_Driver;
      The_Token_Retransmission_Operation : Operations.Operation_Ref)
   is
   begin
      The_Driver.Token_Retransmission_Operation:=
        The_Token_Retransmission_Operation;
   end Set_Token_Retransmission_Operation;

   ------------------------------------
   -- Set_Token_Transmission_Retries --
   ------------------------------------

   procedure Set_Token_Transmission_Retries
     (The_Driver : in out RTEP_Packet_Driver;
      The_Token_Transmission_Retries : Natural)
   is
   begin
      The_Driver.Token_Transmission_Retries:=The_Token_Transmission_Retries;
   end Set_Token_Transmission_Retries;

   ---------------------------
   -- Token_Check_Operation --
   ---------------------------

   function Token_Check_Operation
     (The_Driver : RTEP_Packet_Driver)
     return Operations.Operation_Ref
   is
   begin
      return The_Driver.Token_Check_Operation;
   end Token_Check_Operation;

   -----------------
   -- Token_Delay --
   -----------------

   function Token_Delay
     (The_Driver : RTEP_Packet_Driver)
     return Time
   is
   begin
      return The_Driver.Token_Delay;
   end Token_Delay;

   ----------------------------
   -- Token_Manage_Operation --
   ----------------------------

   function Token_Manage_Operation
     (The_Driver : RTEP_Packet_Driver)
     return Operations.Operation_Ref
   is
   begin
      return The_Driver.Token_Manage_Operation;
   end Token_Manage_Operation;

   ------------------------------------
   -- Token_Retransmission_Operation --
   ------------------------------------

   function Token_Retransmission_Operation
     (The_Driver : RTEP_Packet_Driver)
     return Operations.Operation_Ref
   is
   begin
      return The_Driver.Token_Retransmission_Operation;
   end Token_Retransmission_Operation;

   --------------------------------
   -- Token_Transmission_Retries --
   --------------------------------

   function Token_Transmission_Retries
     (The_Driver : RTEP_Packet_Driver)
     return Natural
   is
   begin
      return The_Driver.Token_Transmission_Retries;
   end Token_Transmission_Retries;

end Mast.Drivers;

