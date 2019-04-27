-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                           GMastEditor                             --
--          Graphical Editor for Modelling and Analysis              --
--                    of Real-Time Applications                      --
--                                                                   --
--                       Copyright (C) 2005                          --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors : Pilar del Rio                                           --
--                                                                   --
-- Contact info: Michael Gonzalez       mgh@unican.es                --
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
with Ada.Tags;       use Ada.Tags;
with Ada.Text_IO;    use Ada.Text_IO;
with Gdk.Color;      use Gdk.Color;
with Gdk.Font;       use Gdk.Font;
with Gdk.Drawable;   use Gdk.Drawable;
with Gdk.Rectangle;  use Gdk.Rectangle;
with Gtk.Combo;      use Gtk.Combo;
with Gtk.GEntry;     use Gtk.GEntry;
with Gtk.Handlers;   use Gtk.Handlers;
with Gtk.Label;      use Gtk.Label;
with Gtk.Table;      use Gtk.Table;
with Gtk.Widget;     use Gtk.Widget;
with Pango.Font;     use Pango.Font;
with Gtkada.Dialogs; use Gtkada.Dialogs;

with List_Exceptions;                   use List_Exceptions;
with Mast;                              use Mast;
with Mast.IO;                           use Mast.IO;
with Mast.Processing_Resources.Network; use Mast.Processing_Resources.Network;
with Mast.Operations;                   use Mast.Operations;
with Mast.Scheduling_Servers;           use Mast.Scheduling_Servers;

with Mast_Editor.Processing_Resources; use Mast_Editor.Processing_Resources;
with Editor_Error_Window_Pkg;          use Editor_Error_Window_Pkg;
with Item_Menu_Pkg;                    use Item_Menu_Pkg;
with Driver_Dialog_Pkg;                use Driver_Dialog_Pkg;
with Editor_Actions;                   use Editor_Actions;
with Change_Control;

package body Mast_Editor.Drivers is

   package Button_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Driver_Ref);

   Zoom_Levels : constant array (Positive range <>) of Guint  :=
     (100,
      130,
      150);
   Font        : Pango_Font_Description;
   Font1       : Pango_Font_Description;

   -------------------------------------------------
   -- Types and packages used to handle dialogs info
   -------------------------------------------------

   type ME_Driver_And_Dialog is record
      It  : ME_Driver_Ref;
      Dia : Gtk_Dialog;
   end record;

   type ME_Driver_And_Dialog_Ref is access all ME_Driver_And_Dialog;

   package Me_Driver_And_Dialog_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Driver_And_Dialog_Ref);

   --------------
   -- Name     --
   --------------
   function Name (Item : in ME_Driver) return Var_String is
   begin
      return (Name (Item.Proc) & Delimiter & Name (Item.Net));
   end Name;

   --------------
   -- Name     --
   --------------
   function Name (Item_Ref : in ME_Driver_Ref) return Var_String is
   begin
      return (Name (Item_Ref.Proc) & Delimiter & Name (Item_Ref.Net));
   end Name;

   -----------------
   -- Print       --
   -----------------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Driver;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Ada.Text_IO.Set_Col (File, Ada.Text_IO.Count (Indentation));
      Ada.Text_IO.Put (File, "ME_Driver");
   end Print;

   -----------------
   -- Print       --
   -----------------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive)
   is
      Item_Ref : ME_Driver_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind (The_List, Iterator);
      for I in 1 .. Lists.Size (The_List) loop
         Lists.Get_Next_Item (Item_Ref, The_List, Iterator);
         Print (File, Item_Ref.all, Indentation, True);
         Ada.Text_IO.New_Line (File);
      end loop;
   end Print;

   ----------------------
   -- Write Parameters --
   ----------------------
   procedure Write_Parameters
     (Item   : access ME_Packet_Driver;
      Dialog : access Gtk_Dialog_Record'Class)
   is

      function Server_Reference
        (Combo : Gtk.Combo.Gtk_Combo)
         return  Scheduling_Server_Ref
      is
         Serv_Name  : Var_Strings.Var_String;
         Serv_Index : Mast.Scheduling_Servers.Lists.Index;
         Serv_Ref   : Mast.Scheduling_Servers.Scheduling_Server_Ref;
      begin
         Serv_Name  := To_Var_String (Get_Text (Get_Entry (Combo)));
         Serv_Index :=
            Mast.Scheduling_Servers.Lists.Find
              (Serv_Name,
               The_System.Scheduling_Servers);
         Serv_Ref   :=
            Mast.Scheduling_Servers.Lists.Item
              (Serv_Index,
               The_System.Scheduling_Servers);
         return Serv_Ref;
      exception
         when Invalid_Index =>
            Serv_Ref := null;
            return Serv_Ref;
      end Server_Reference;

      function Operation_Reference
        (Combo : Gtk.Combo.Gtk_Combo)
         return  Operation_Ref
      is
         Op_Name  : Var_Strings.Var_String;
         Op_Index : Mast.Operations.Lists.Index;
         Op_Ref   : Mast.Operations.Operation_Ref;
      begin
         Op_Name  := To_Var_String (Get_Text (Get_Entry (Combo)));
         Op_Index :=
            Mast.Operations.Lists.Find (Op_Name, The_System.Operations);
         Op_Ref   :=
            Mast.Operations.Lists.Item (Op_Index, The_System.Operations);
         return Op_Ref;
      exception
         when Invalid_Index =>
            Op_Ref := null;
            return Op_Ref;
      end Operation_Reference;

      Driv_Ref      : Driver_Ref                                        :=
        ME_Driver_Ref (Item).Driv;
      Driver_Dialog : Driver_Dialog_Access                              :=
         Driver_Dialog_Access (Dialog);
      Net_Ref       : Mast.Processing_Resources.Processing_Resource_Ref :=
        Item.Net;
   begin
      Change_Control.Changes_Made;
      -- Remove previous driver_ref from drivers list of the network
      Mast.Processing_Resources.Network.Remove_Driver
        (Mast.Processing_Resources.Network.Packet_Based_Network (Net_Ref.all),
         Driv_Ref);

      if (Get_Text (Get_Entry (Driver_Dialog.Driver_Type_Combo)) =
          "Packet Driver")
      then
         Driv_Ref := new Packet_Driver;
      elsif (Get_Text (Get_Entry (Driver_Dialog.Driver_Type_Combo)) =
             "Character Packet Driver")
      then
         Driv_Ref := new Character_Packet_Driver;
      elsif (Get_Text (Get_Entry (Driver_Dialog.Driver_Type_Combo)) =
             "RT-EP Packet Driver")
      then
         Driv_Ref := new RTEP_Packet_Driver;
      end if;

      Set_Packet_Server
        (Packet_Driver (Driv_Ref.all),
         Server_Reference (Driver_Dialog.Packet_Server_Combo));
      Set_Packet_Send_Operation
        (Packet_Driver (Driv_Ref.all),
         Operation_Reference (Driver_Dialog.Packet_Send_Op_Combo));
      Set_Packet_Receive_Operation
        (Packet_Driver (Driv_Ref.all),
         Operation_Reference (Driver_Dialog.Packet_Rece_Op_Combo));
      if Get_Text (Get_Entry (Driver_Dialog.Message_Partitioning_Combo)) =
         "YES"
      then
         Set_Message_Partitioning (Packet_Driver (Driv_Ref.all), True);
      else
         Set_Message_Partitioning (Packet_Driver (Driv_Ref.all), False);
      end if;
      Set_Rta_Overhead_Model
        (Packet_Driver (Driv_Ref.all),
         Rta_Overhead_Model_Type'Value
            (Get_Text (Get_Entry (Driver_Dialog.Rta_Overhead_Model_Combo))));

      if Driv_Ref.all'Tag = Character_Packet_Driver'Tag then
         -- Character Packet Driver
         Set_Character_Server
           (Character_Packet_Driver (Driv_Ref.all),
            Server_Reference (Driver_Dialog.Char_Server_Combo));
         Set_Character_Send_Operation
           (Character_Packet_Driver (Driv_Ref.all),
            Operation_Reference (Driver_Dialog.Char_Send_Op_Combo));
         Set_Character_Receive_Operation
           (Character_Packet_Driver (Driv_Ref.all),
            Operation_Reference (Driver_Dialog.Char_Rece_Op_Combo));
         Set_Character_Transmission_Time
           (Character_Packet_Driver (Driv_Ref.all),
            Time'Value (Get_Text (Driver_Dialog.Char_Tx_Time_Entry)));
      elsif Driv_Ref.all'Tag = RTEP_Packet_Driver'Tag then
         -- RTEP Packet Driver
         Set_Number_Of_Stations
           (RTEP_Packet_Driver (Driv_Ref.all),
            Positive'Value (Get_Text (Driver_Dialog.Num_Of_Stations_Entry)));
         Set_Token_Delay
           (RTEP_Packet_Driver (Driv_Ref.all),
            Time'Value (Get_Text (Driver_Dialog.Token_Delay_Entry)));
         Set_Failure_Timeout
           (RTEP_Packet_Driver (Driv_Ref.all),
            Time'Value (Get_Text (Driver_Dialog.Failure_Timeout_Entry)));
         Set_Token_Transmission_Retries
           (RTEP_Packet_Driver (Driv_Ref.all),
            Natural'Value
               (Get_Text (Driver_Dialog.Token_Transmission_Retries_Entry)));
         Set_Packet_Transmission_Retries
           (RTEP_Packet_Driver (Driv_Ref.all),
            Natural'Value
               (Get_Text (Driver_Dialog.Packet_Transmission_Retries_Entry)));
         Set_Packet_Interrupt_Server
           (RTEP_Packet_Driver (Driv_Ref.all),
            Server_Reference (Driver_Dialog.Packet_Interrupt_Server_Combo));
         Set_Packet_ISR_Operation
           (RTEP_Packet_Driver (Driv_Ref.all),
            Operation_Reference (Driver_Dialog.Packet_Isr_Op_Combo));
         Set_Token_Check_Operation
           (RTEP_Packet_Driver (Driv_Ref.all),
            Operation_Reference (Driver_Dialog.Token_Check_Op_Combo));
         Set_Token_Manage_Operation
           (RTEP_Packet_Driver (Driv_Ref.all),
            Operation_Reference (Driver_Dialog.Token_Manage_Op_Combo));
         Set_Packet_Discard_Operation
           (RTEP_Packet_Driver (Driv_Ref.all),
            Operation_Reference (Driver_Dialog.Packet_Discard_Op_Combo));
         Set_Token_Retransmission_Operation
           (RTEP_Packet_Driver (Driv_Ref.all),
            Operation_Reference (Driver_Dialog.Token_Retransmission_Op_Combo));
         Set_Packet_Retransmission_Operation
           (RTEP_Packet_Driver (Driv_Ref.all),
            Operation_Reference
               (Driver_Dialog.Packet_Retransmission_Op_Combo));
      end if;

      if Net_Ref /= null then
         Add_Driver
           (Mast.Processing_Resources.Network.Packet_Based_Network (Net_Ref.all
),
            Driv_Ref);
      end if;

   end Write_Parameters;

   ---------------------
   -- Read Parameters --
   ---------------------
   procedure Read_Parameters
     (Item   : access ME_Packet_Driver;
      Dialog : access Gtk_Dialog_Record'Class)
   is

      function Server_Name
        (Serv_Ref : Scheduling_Server_Ref)
         return     Var_String
      is
      begin
         if Serv_Ref = null then
            return To_Var_String ("(NONE)");
         else
            return Mast.Scheduling_Servers.Name (Serv_Ref);
         end if;
      end Server_Name;

      function Operation_Name (Op_Ref : Operation_Ref) return Var_String is
      begin
         if Op_Ref = null then
            return To_Var_String ("(NONE)");
         else
            return Mast.Operations.Name (Op_Ref.all);
         end if;
      end Operation_Name;

      Driv_Ref      : Mast.Drivers.Driver_Ref := Item.Driv;
      Driver_Dialog : Driver_Dialog_Access    :=
         Driver_Dialog_Access (Dialog);
   begin
      if Driv_Ref /= null then
         Set_Text
           (Get_Entry (Driver_Dialog.Packet_Server_Combo),
            Name_Image
               (Server_Name (Packet_Server (Packet_Driver (Driv_Ref.all)))));
         Set_Text
           (Get_Entry (Driver_Dialog.Packet_Send_Op_Combo),
            Name_Image
               (Operation_Name
                   (Packet_Send_Operation (Packet_Driver (Driv_Ref.all)))));
         Set_Text
           (Get_Entry (Driver_Dialog.Packet_Rece_Op_Combo),
            Name_Image
               (Operation_Name
                   (Packet_Receive_Operation (Packet_Driver (Driv_Ref.all)))));

         if Message_Partitioning (Packet_Driver (Driv_Ref.all)) then
            Set_Text
              (Get_Entry (Driver_Dialog.Message_Partitioning_Combo),
               "YES");
         else
            Set_Text
              (Get_Entry (Driver_Dialog.Message_Partitioning_Combo),
               "NO");
         end if;

         Set_Text
           (Get_Entry (Driver_Dialog.Rta_Overhead_Model_Combo),
            Rta_Overhead_Model_Type'Image
               (Rta_Overhead_Model (Packet_Driver (Driv_Ref.all))));

         if Driv_Ref.all'Tag = Packet_Driver'Tag then
            Set_Text
              (Get_Entry (Driver_Dialog.Driver_Type_Combo),
               "Packet Driver");
            Show_All (Driver_Dialog);
            Hide (Driver_Dialog.Character_Server_Table);
            Hide (Driver_Dialog.Rtep_Table);
         elsif Driv_Ref.all'Tag = Character_Packet_Driver'Tag then
            Set_Text
              (Get_Entry (Driver_Dialog.Driver_Type_Combo),
               "Character Packet Driver");
            Set_Text
              (Get_Entry (Driver_Dialog.Char_Server_Combo),
               Name_Image
                  (Server_Name
                      (Character_Server
                          (Character_Packet_Driver (Driv_Ref.all)))));
            Set_Text
              (Get_Entry (Driver_Dialog.Char_Send_Op_Combo),
               Name_Image
                  (Operation_Name
                      (Character_Send_Operation
                          (Character_Packet_Driver (Driv_Ref.all)))));
            Set_Text
              (Get_Entry (Driver_Dialog.Char_Rece_Op_Combo),
               Name_Image
                  (Operation_Name
                      (Character_Receive_Operation
                          (Character_Packet_Driver (Driv_Ref.all)))));
            Set_Text
              (Driver_Dialog.Char_Tx_Time_Entry,
               Time_Image
                  (Character_Transmission_Time
                      (Character_Packet_Driver (Driv_Ref.all))));
            Show_All (Driver_Dialog);
            Hide (Driver_Dialog.Rtep_Table);
         elsif Driv_Ref.all'Tag = RTEP_Packet_Driver'Tag then
            Set_Text
              (Get_Entry (Driver_Dialog.Driver_Type_Combo),
               "RT-EP Packet Driver");
            Set_Text
              (Driver_Dialog.Num_Of_Stations_Entry,
               Positive'Image
                  (Number_Of_Stations (RTEP_Packet_Driver (Driv_Ref.all))));
            Set_Text
              (Driver_Dialog.Token_Delay_Entry,
               Time'Image (Token_Delay (RTEP_Packet_Driver (Driv_Ref.all))));
            Set_Text
              (Driver_Dialog.Failure_Timeout_Entry,
               Time'Image
                  (Failure_Timeout (RTEP_Packet_Driver (Driv_Ref.all))));
            Set_Text
              (Driver_Dialog.Token_Transmission_Retries_Entry,
               Natural'Image
                  (Token_Transmission_Retries
                      (RTEP_Packet_Driver (Driv_Ref.all))));
            Set_Text
              (Driver_Dialog.Packet_Transmission_Retries_Entry,
               Natural'Image
                  (Packet_Transmission_Retries
                      (RTEP_Packet_Driver (Driv_Ref.all))));
            Set_Text
              (Get_Entry (Driver_Dialog.Packet_Interrupt_Server_Combo),
               Name_Image
                  (Server_Name
                      (Packet_Interrupt_Server
                          (RTEP_Packet_Driver (Driv_Ref.all)))));
            Set_Text
              (Get_Entry (Driver_Dialog.Packet_Isr_Op_Combo),
               Name_Image
                  (Operation_Name
                      (Packet_ISR_Operation
                          (RTEP_Packet_Driver (Driv_Ref.all)))));
            Set_Text
              (Get_Entry (Driver_Dialog.Token_Check_Op_Combo),
               Name_Image
                  (Operation_Name
                      (Token_Check_Operation
                          (RTEP_Packet_Driver (Driv_Ref.all)))));
            Set_Text
              (Get_Entry (Driver_Dialog.Token_Manage_Op_Combo),
               Name_Image
                  (Operation_Name
                      (Token_Manage_Operation
                          (RTEP_Packet_Driver (Driv_Ref.all)))));
            Set_Text
              (Get_Entry (Driver_Dialog.Packet_Discard_Op_Combo),
               Name_Image
                  (Operation_Name
                      (Packet_Discard_Operation
                          (RTEP_Packet_Driver (Driv_Ref.all)))));
            Set_Text
              (Get_Entry (Driver_Dialog.Token_Retransmission_Op_Combo),
               Name_Image
                  (Operation_Name
                      (Token_Retransmission_Operation
                          (RTEP_Packet_Driver (Driv_Ref.all)))));
            Set_Text
              (Get_Entry (Driver_Dialog.Packet_Retransmission_Op_Combo),
               Name_Image
                  (Operation_Name
                      (Packet_Retransmission_Operation
                          (RTEP_Packet_Driver (Driv_Ref.all)))));
            Show_All (Driver_Dialog);
            Hide (Driver_Dialog.Character_Server_Table);
         end if;
      end if;
   end Read_Parameters;

   -----------------
   -- Draw Driver --
   -----------------
   procedure Draw
     (Item         : access ME_Packet_Driver;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint)
   is
      Rect      : constant Gdk_Rectangle  := Get_Coord (Item);
      W         : constant Gint           :=
         To_Canvas_Coordinates (Canvas, Rect.Width);
      H         : constant Gint           :=
         To_Canvas_Coordinates (Canvas, Rect.Height);
      Drive_Ref : Mast.Drivers.Driver_Ref := Item.Driv;
      Color     : Gdk.Color.Gdk_Color;
   begin
      Editor_Actions.Load_System_Font (Font1, Font);
      Color := Parse (To_String (ME_Driver_Ref (Item).Color_Name));
      Alloc (Gtk.Widget.Get_Default_Colormap, Color);
      Item.X_Coord := Gint (Get_Coord (Item).X);
      Item.Y_Coord := Gint (Get_Coord (Item).Y);
      Set_Foreground (GC, Color);
      Draw_Rectangle
        (Get_Window (Canvas),
         Gc     => GC,
         Filled => True,
         X      => Xdest,
         Y      => Ydest,
         Width  => W,
         Height => H);
      Set_Foreground (GC, Black (Get_Default_Colormap));
      Draw_Rectangle
        (Get_Window (Canvas),
         Gc     => GC,
         Filled => False,
         X      => Xdest,
         Y      => Ydest,
         Width  => W,
         Height => H);
      if Get_Zoom (Canvas) = Zoom_Levels (1) then
         if Drive_Ref /= null then
            if Drive_Ref.all'Tag = Packet_Driver'Tag then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 2 * H / 5,
                  Text => "PACKET");
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 4 * H / 5,
                  Text => "DRIVER");
            elsif Drive_Ref.all'Tag = Character_Packet_Driver'Tag then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + H / 3,
                  Text => "CHARACTER");
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 2 * H / 3,
                  Text => "PACKET");
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 3 * H / 3,
                  Text => "DRIVER");
            elsif Drive_Ref.all'Tag = RTEP_Packet_Driver'Tag then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + H / 3,
                  Text => "RT_EP");
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 2 * H / 3,
                  Text => "PACKET");
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 3 * H / 3,
                  Text => "DRIVER");
            end if;
         end if;
      elsif Get_Zoom (Canvas) = Zoom_Levels (2) then
         if Drive_Ref /= null then
            if Drive_Ref.all'Tag = Packet_Driver'Tag then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 2 * H / 5,
                  Text => "PACKET");
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 4 * H / 5,
                  Text => "DRIVER");
            elsif Drive_Ref.all'Tag = Character_Packet_Driver'Tag then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + H / 3,
                  Text => "CHARACTER");
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 2 * H / 3,
                  Text => "PACKET");
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 3 * H / 3,
                  Text => "DRIVER");
            elsif Drive_Ref.all'Tag = RTEP_Packet_Driver'Tag then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + H / 3,
                  Text => "RT-EP");
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 2 * H / 3,
                  Text => "PACKET");
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 3 * H / 3,
                  Text => "DRIVER");
            end if;
         end if;
      else
         if Drive_Ref /= null then
            if Drive_Ref.all'Tag = Packet_Driver'Tag then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 2 * H / 4,
                  Text => "PACKET DRIVER");
            elsif Drive_Ref.all'Tag = Character_Packet_Driver'Tag then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 2 * H / 5,
                  Text => "CHARACTER PACKET");
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 4 * H / 5,
                  Text => "DRIVER");
            elsif Drive_Ref.all'Tag = RTEP_Packet_Driver'Tag then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 2 * H / 5,
                  Text => "RT-EP PACKET");
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 20,
                  Ydest + 4 * H / 5,
                  Text => "DRIVER");
            end if;
         end if;
      end if;
   end Draw;

   ------------------
   -- Write Driver -- (Write the params of an existing driver and refresh the
   --canvas)
   ------------------
   procedure Write_Driver
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Driver_And_Dialog_Ref)
   is
      Item          : ME_Driver_Ref        := Data.It;
      Driver_Dialog : Driver_Dialog_Access := Driver_Dialog_Access (Data.Dia);
   begin
      Write_Parameters (Item, Gtk_Dialog (Driver_Dialog));
      Refresh_Canvas (Proc_Res_Canvas);
      Destroy (Driver_Dialog);

   exception
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Invalid Value !!!");
         Show_All (Editor_Error_Window);
         Destroy (Driver_Dialog);
      when others =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "ERROR WRITING DRIVER !!!");
         Show_All (Editor_Error_Window);
   end Write_Driver;

   --------------------
   -- Remove_Driver  --
   --------------------
   procedure Remove_Driver
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Driver_Ref)
   is
      Driv_Ref           : Driver_Ref := ME_Driver_Ref (Item).Driv;
      Driver_Name        : Var_String;
      Me_Driver_Iterator : Mast_Editor.Drivers.Lists.Iteration_Object;
      Me_Driver_Ref      : Mast_Editor.Drivers.ME_Driver_Ref;
      Net_Ref            : Mast.Processing_Resources.Processing_Resource_Ref
         :=
         Item.Net;

   begin
      if Message_Dialog
            (" Do you really want to remove this object? ",
             Confirmation,
             Button_Yes or Button_No,
             Button_Yes) =
         Button_Yes
      then
         Driver_Name := Name (Item);
         if Net_Ref /= null then
            Mast.Processing_Resources.Network.Remove_Driver
              (Mast.Processing_Resources.Network.Packet_Based_Network (Net_Ref.
all),
               Driv_Ref);
         end if;

         Me_Driver_Iterator :=
            Mast_Editor.Drivers.Lists.Find
              (Driver_Name,
               Editor_System.Me_Drivers);
         Me_Driver_Ref      :=
            Mast_Editor.Drivers.Lists.Item
              (Me_Driver_Iterator,
               Editor_System.Me_Drivers);
         Mast_Editor.Drivers.Lists.Delete
           (Me_Driver_Iterator,
            Me_Driver_Ref,
            Editor_System.Me_Drivers);

         Remove (Proc_Res_Canvas, Me_Driver_Ref);
         Refresh_Canvas (Proc_Res_Canvas);
         Change_Control.Changes_Made;
         Destroy (Item_Menu);
      end if;
   exception
      when others =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "ERROR IN DRIVER REMOVAL !!!");
         Show_All (Editor_Error_Window);
         Destroy (Item_Menu);
   end Remove_Driver;

   -----------------------
   -- Properties_Driver --
   -----------------------
   procedure Properties_Driver
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Driver_Ref)
   is
      Driver_Dialog : Driver_Dialog_Access;
      Me_Data       : ME_Driver_And_Dialog_Ref := new ME_Driver_And_Dialog;
   begin
      Gtk_New (Driver_Dialog);
      Set_Modal (Driver_Dialog, False);
      Read_Parameters (Item, Gtk_Dialog (Driver_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Driver_Dialog);

      Me_Driver_And_Dialog_Cb.Connect
        (Driver_Dialog.Driver_Ok_Button,
         "clicked",
         Me_Driver_And_Dialog_Cb.To_Marshaller (Write_Driver'Access),
         Me_Data);

      Refresh_Canvas (Proc_Res_Canvas);
      Destroy (Item_Menu);
   exception
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Error Reading Driver !!!");
         Show_All (Editor_Error_Window);
   end Properties_Driver;

   ---------------------
   -- On Button Click --
   ---------------------
   procedure On_Button_Click
     (Item  : access ME_Packet_Driver;
      Event : Gdk.Event.Gdk_Event_Button)
   is
      Num_Button    : Guint;
      Event_Type    : Gdk_Event_Type;
      Driver_Dialog : Driver_Dialog_Access;
      Me_Data       : ME_Driver_And_Dialog_Ref := new ME_Driver_And_Dialog;
   begin
      if Event /= null then
         Event_Type := Get_Event_Type (Event);
         if Event_Type = Gdk_2button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (1) then
               Gtk_New (Driver_Dialog);
               Set_Modal (Driver_Dialog, False);
               Read_Parameters (Item, Gtk_Dialog (Driver_Dialog));
               Me_Data.It  := ME_Driver_Ref (Item);
               Me_Data.Dia := Gtk_Dialog (Driver_Dialog);

               Me_Driver_And_Dialog_Cb.Connect
                 (Driver_Dialog.Driver_Ok_Button,
                  "clicked",
                  Me_Driver_And_Dialog_Cb.To_Marshaller (Write_Driver'Access),
                  Me_Data);
            end if;
         elsif Event_Type = Button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (3) then
               Gtk_New (Item_Menu);
               Button_Cb.Connect
                 (Item_Menu.Remove,
                  "activate",
                  Button_Cb.To_Marshaller (Remove_Driver'Access),
                  ME_Driver_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Properties,
                  "activate",
                  Button_Cb.To_Marshaller (Properties_Driver'Access),
                  ME_Driver_Ref (Item));
            end if;
         end if;
      end if;
   exception
      when Storage_Error =>
         null;
   end On_Button_Click;

   -----------
   -- Print --
   -----------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Packet_Driver;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Mast_Editor.Drivers.Print (File, ME_Driver (Item), Indentation);
      Put (File, " ");
      Put (File, "Me_Packet_Driver");
      Put (File, " ");
      Put (File, Mast.IO.Name_Image (Name (Item)));
      Put (File, " ");
      Put (File, Mast.IO.Name_Image (Item.Canvas_Name));
      if Item.X_Coord < 0 then
         Put (File, " ");
      end if;
      Put (File, Gint'Image (Item.X_Coord));
      if Item.Y_Coord < 0 then
         Put (File, " ");
      end if;
      Put (File, Gint'Image (Item.Y_Coord));
      Put (File, " ");
   end Print;

end Mast_Editor.Drivers;
