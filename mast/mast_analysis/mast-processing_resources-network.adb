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

with Mast.Scheduling_Servers,MAST.IO,List_Exceptions;
package body Mast.Processing_Resources.Network is

   use type MAST.Drivers.Driver_Ref;
   use type MAST.Drivers.Lists.Index;
   use type MAST.Scheduling_Servers.Scheduling_Server_Ref;

   ------------------------
   -- Add_Driver         --
   ------------------------

   procedure Add_Driver
     (Net : in out Network;
      The_Driver : MAST.Drivers.Driver_Ref)
   is
   begin
      Drivers.Lists.Add(The_Driver,Net.List_Of_Drivers);
   end Add_Driver;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (Net : in Packet_Based_Network;
      Server_List : in Scheduling_Servers.Lists.List;
      Op_List : in Operations.Lists.List)
   is
   begin
      Drivers.Adjust(Net.List_Of_Drivers,Server_List,Op_List);
   exception
      when Object_Not_Found =>
         Set_Exception_Message
           ("Error in Packet_Based_Network "&Var_Strings.To_String(Net.Name)&
            ": "&Get_Exception_Message);
         raise;
   end Adjust;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (The_List : in Processing_Resources.Lists.List;
      Server_List : in Scheduling_Servers.Lists.List;
      Op_List : in Operations.Lists.List)
   is
      Iterator : Processing_Resources.Lists.Iteration_Object;
      Res_Ref : Processing_Resource_Ref;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         if Res_Ref.all in Packet_Based_Network'Class then
            Adjust(Packet_Based_Network'Class(Res_Ref.all),
                   Server_List,Op_List);
         end if;
      end loop;
   end Adjust;

   ------------
   -- Clone  --
   ------------
   function Clone
     (Res : Packet_Based_Network)
     return  Processing_Resource_Ref
   is
      Res_Ref : Processing_Resource_Ref;
      Null_List : Drivers.Lists.List;
   begin
      Res_Ref:=new Packet_Based_Network'(Res);
      Res_Ref.The_Slack_Result:=null;
      Res_Ref.The_Utilization_Result:=null;
      Res_Ref.The_Ready_Queue_Size_Result:=null;
      -- Clone the drivers
      Network(Res_Ref.all).List_Of_Drivers:=Null_List;
      Network(Res_Ref.all).List_Of_Drivers:=
        Drivers.Clone(Res.List_Of_Drivers);
      return Res_Ref;
   end Clone;

   ------------------------
   -- Get_Next_Driver    --
   ------------------------

   procedure Get_Next_Driver
     (Net : in Network;
      The_Driver : out MAST.Drivers.Driver_Ref;
      Iterator : in out Driver_Iteration_Object)
   is
   begin
      Drivers.Lists.Get_Next_Item
        (The_Driver,Net.List_Of_Drivers,
         Drivers.Lists.Iteration_Object(Iterator));
   end Get_Next_Driver;

   ------------------
   -- Max_Blocking --
   ------------------

   function Max_Blocking
     (Net  : Packet_Based_Network)
     return Normalized_Execution_Time
   is
   begin
      return Net.Max_Blocking;
   end Max_Blocking;

   ---------------------
   -- Max_Packet_Size --
   ---------------------

   function Max_Packet_Size
     (Net  : Packet_Based_Network) return Bit_Count
   is
   begin
      if Net.Max_Packet_Units_Are_Time then
         return (Net.Max_Packet_Transmission_Time)*
           Net.The_Throughput;
      else
         return Net.Max_Packet_Size;
      end if;
   end Max_Packet_Size;

   ---------------------
   -- Min_Packet_Size --
   ---------------------

   function Min_Packet_Size
     (Net  : Packet_Based_Network) return Bit_Count
   is
   begin
      if Net.Min_Packet_Units_Are_Time then
         return (Net.Min_Packet_Transmission_Time)*
           Net.The_Throughput;
      else
         return Net.Min_Packet_Size;
      end if;
   end Min_Packet_Size;

   ---------------------------------
   -- Max_Packet_Transmission_Time --
   ---------------------------------

   function Max_Packet_Transmission_Time
     (Net  : Packet_Based_Network)
     return Normalized_Execution_Time
   is
   begin
      if Net.Max_Packet_Units_Are_Time then
         return Net.Max_Packet_Transmission_Time;
      else
         return (Net.Max_Packet_Size/Net.The_Throughput);
      end if;
   end Max_Packet_Transmission_Time;

   ---------------------------------
   -- Min_Packet_Transmission_Time --
   ---------------------------------

   function Min_Packet_Transmission_Time
     (Net  : Packet_Based_Network)
     return Normalized_Execution_Time
   is
   begin
      if Net.Min_Packet_Units_Are_Time then
         return Net.Min_Packet_Transmission_Time;
      else
         return (Net.Min_Packet_Size/Net.The_Throughput);
      end if;
   end Min_Packet_Transmission_Time;

   ------------------------
   -- Num_of_Drivers     --
   ------------------------

   function Num_Of_Drivers
     (Net : Network)
     return Natural
   is
   begin
      return Drivers.Lists.Size(Net.List_Of_Drivers);
   end Num_Of_Drivers;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Packet_Based_Network;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Name_Length : constant := 29;
   begin
      Print(File,Processing_Resource(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Packet_Based_Network",Indentation+3,Name_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Res.Name),Indentation+3,Name_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Transmission",
         Transmission_Kind'Image(Res.Transmission_Mode),
         Indentation+3,Name_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Throughput",
         IO.Speed_Image(Processor_Speed(Res.The_Throughput)),
         Indentation+3,Name_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Max_Blocking",
         IO.Execution_Time_Image(Res.Max_Blocking),
         Indentation+3,Name_Length);
      if Res.Max_Packet_Units_Are_Time then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Max_Packet_Transmission_Time",
            IO.Execution_Time_Image(Res.Max_Packet_Transmission_Time),
            Indentation+3,Name_Length);
      else
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Max_Packet_Size",
            IO.Bit_Count_Image(Res.Max_Packet_Size),
            Indentation+3,Name_Length);
      end if;
      if Res.Min_Packet_Units_Are_Time then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Min_Packet_Transmission_Time",
            IO.Execution_Time_Image(Res.Min_Packet_Transmission_Time),
            Indentation+3,Name_Length);
      else
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Min_Packet_Size",
            IO.Bit_Count_Image(Res.Min_Packet_Size),
            Indentation+3,Name_Length);
      end if;
      if Drivers.Lists.Size(Res.List_Of_Drivers) >0 then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"List_of_Drivers","",
            Indentation+3,Name_Length);
         Ada.Text_IO.New_Line(File);
         Drivers.Print(File,Res.List_Of_Drivers,Indentation+6);
      end if;
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Speed_Factor",
         IO.Speed_Image(Res.Speed_Factor),Indentation+3,Name_Length);
      MAST.IO.Print_Separator(File,",",Finalize);
   end Print;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Packet_Based_Network;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Iterator : Drivers.Lists.Index;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put
        (File,"<mast_mdl:Packet_Based_Network Name=""" &
         Io.Name_Image(Res.Name) & """ ");
      Ada.Text_Io.Put
        (File,"Transmission=""" &
         Transmission_Kind'Image(Res.Transmission_Mode) & """ ");
      --      if Throughput(Res) = 0.0
      --      then
      --          Ada.Text_Io.Put(File,"Throughput=""" &
      --                          Io.Speed_Image(1.0E9) & """ ");
      --      else
      Ada.Text_Io.Put
           (File,"Throughput=""" &
            Io.Speed_Image(Processor_Speed(Res.The_Throughput)) & """ ");
      --       end if;
      Ada.Text_Io.Put
        (File,"Max_Blocking=""" &
         IO.Execution_Time_Image(Res.Max_Blocking) & """ ");
      Ada.Text_Io.Put
        (File,"Speed_Factor=""" &
         Io.Speed_Image(Res.Speed_Factor) & """ ");
      if Res.Max_Packet_Units_Are_Time
      then
         Ada.Text_Io.Put
           (File,"Max_Packet_Size=""" &
            IO.Bit_Count_Image(Max_Packet_Transmission_Time(Res)*1.0E9) &
            """ ");
      else
         Ada.Text_Io.Put
           (File,"Max_Packet_Size=""" &
            Io.Bit_Count_Image(Max_Packet_Size(Res)) & """ ");
      end if;
      if Res.Min_Packet_Units_Are_Time
      then
         Ada.Text_Io.Put
           (File,"Min_Packet_Size=""" &
            IO.Bit_Count_Image(Max_Packet_Transmission_Time(Res)*1.0E9) &
            """ >");
      else
         Ada.Text_Io.Put
           (File,"Min_Packet_Size=""" &
            Io.Bit_Count_Image(Max_Packet_Size(Res)) & """ >");
      end if;
      if Drivers.Lists.Size(Res.List_Of_Drivers) >0 then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_Io.Put_Line(File,"<mast_mdl:List_of_Drivers>");
         Drivers.Print_XML(File,Res.List_Of_Drivers,Indentation+3);
         Ada.Text_Io.Put_Line(File,"</mast_mdl:List_of_Drivers>");
      end if;
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put(File,"</mast_mdl:Packet_Based_Network>");
   end Print_XML;

   -------------------
   -- Remove_Driver --
   -------------------

   procedure Remove_Driver
     (Net : in out Network;
      The_Driver : MAST.Drivers.Driver_Ref)
   is
      Ind : Drivers.Lists.Index;
      Drv_Ref : MAST.Drivers.Driver_Ref;
   begin
      Ind:=Drivers.Lists.Find(The_Driver,Net.List_Of_Drivers);
      if Ind=Drivers.Lists.Null_Index then
         raise List_Exceptions.Not_Found;
      end if;
      Drivers.Lists.Delete(Ind,Drv_Ref,Net.List_Of_Drivers);
   end Remove_Driver;

   ------------------------
   -- Rewind_Drivers     --
   ------------------------

   procedure Rewind_Drivers
     (Net : in Network;
      Iterator : out Driver_Iteration_Object)
   is
   begin
      Drivers.Lists.Rewind
        (Net.List_Of_Drivers,
         Drivers.Lists.Iteration_Object(Iterator));
   end Rewind_Drivers;

   ----------------------
   -- Set_Max_Blocking --
   ----------------------

   procedure Set_Max_Blocking
     (Net  : in out Packet_Based_Network;
      The_Max_Blocking : Normalized_Execution_Time)
   is
   begin
      Net.Max_Blocking:=The_Max_Blocking;
   end Set_Max_Blocking;

   -------------------------
   -- Set_Max_Packet_Size --
   -------------------------

   procedure Set_Max_Packet_Size
     (Net  : in out Packet_Based_Network;
      The_Max_Size : Bit_Count)
   is
   begin
      Net.Max_Packet_Size:=The_Max_Size;
      Net.Max_Packet_Units_Are_Time:=False;
   end Set_Max_Packet_Size;

   -------------------------
   -- Set_Min_Packet_Size --
   -------------------------

   procedure Set_Min_Packet_Size
     (Net  : in out Packet_Based_Network;
      The_Min_Size : Bit_Count)
   is
   begin
      Net.Min_Packet_Size:=The_Min_Size;
      Net.Min_Packet_Units_Are_Time:=False;
   end Set_Min_Packet_Size;

   -------------------------------------
   -- Set_Max_Packet_Transmission_Time --
   ------------------------------------

   procedure Set_Max_Packet_Transmission_Time
     (Net  : in out Packet_Based_Network;
      The_Max_Transmission_Time : Normalized_Execution_Time)
   is
   begin
      Net.Max_Packet_Transmission_Time:=The_Max_Transmission_Time;
      Net.Max_Packet_Units_Are_Time:=True;
   end Set_Max_Packet_Transmission_Time;

   -------------------------------------
   -- Set_Min_Packet_Transmission_Time --
   ------------------------------------

   procedure Set_Min_Packet_Transmission_Time
     (Net  : in out Packet_Based_Network;
      The_Min_Transmission_Time : Normalized_Execution_Time)
   is
   begin
      Net.Min_Packet_Transmission_Time:=The_Min_Transmission_Time;
      Net.Min_Packet_Units_Are_Time:=True;
   end Set_Min_Packet_Transmission_Time;

   ---------------------------
   -- Set_Transmission_Mode --
   ---------------------------

   procedure Set_Throughput
     (Net  : in out Network;
      The_Throughput : Throughput_Value)
   is
   begin
      Net.The_Throughput:=The_Throughput;
   end Set_Throughput;

   ---------------------------
   -- Set_Transmission_Mode --
   ---------------------------

   procedure Set_Transmission_Mode
     (Net  : in out Network;
      The_Transmission_Mode : Transmission_Kind)
   is
   begin
      Net.Transmission_Mode:=The_Transmission_Mode;
   end Set_Transmission_Mode;

   ---------------------------
   -- Set_Transmission_Mode --
   ---------------------------

   function Transmission_Mode
     (Net  : Network) return Transmission_Kind
   is
   begin
      return Net.Transmission_Mode;
   end Transmission_Mode;

   ----------------
   -- Throughput --
   ----------------

   function Throughput
     (Net  : Network) return Throughput_Value
   is
   begin
      return Net.The_Throughput;
   end Throughput;

end Mast.Processing_Resources.Network;
