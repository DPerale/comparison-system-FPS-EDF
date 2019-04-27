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
with Glib;                        use Glib;
with Gtk;                         use Gtk;
with Gdk.Types;                   use Gdk.Types;
with Gtk.Widget;                  use Gtk.Widget;
with Gtk.Enums;                   use Gtk.Enums;
with Gtkada.Handlers;             use Gtkada.Handlers;
with Callbacks_Mast_Editor;       use Callbacks_Mast_Editor;
with Mast_Editor_Intl;            use Mast_Editor_Intl;
with Driver_Dialog_Pkg.Callbacks; use Driver_Dialog_Pkg.Callbacks;

with Mast;                                use Mast;
with Mast.IO;                             use Mast.IO;
with Mast.Scheduling_Servers;             use Mast.Scheduling_Servers;
with Mast.Operations;                     use Mast.Operations;
with Mast.Processing_Resources;           use Mast.Processing_Resources;
with Mast.Processing_Resources.Processor;
use Mast.Processing_Resources.Processor;
with Mast.Processing_Resources.Network;   use 
  Mast.Processing_Resources.Network;
with Editor_Actions;                      use Editor_Actions;
with Var_Strings;                         use Var_Strings;
with Ada.Tags;                            use Ada.Tags;

package body Driver_Dialog_Pkg is

   procedure Gtk_New (Driver_Dialog : out Driver_Dialog_Access) is
   begin
      Driver_Dialog := new Driver_Dialog_Record;
      Driver_Dialog_Pkg.Initialize (Driver_Dialog);
   end Gtk_New;

   procedure Initialize (Driver_Dialog : access Driver_Dialog_Record'Class) is
      pragma Suppress (All_Checks);
      Pixmaps_Dir                          : constant String := "pixmaps/";
      Packet_Server_Combo_Items            : String_List.Glist;
      Packet_Send_Op_Combo_Items           : String_List.Glist;
      Packet_Rece_Op_Combo_Items           : String_List.Glist;
      Driver_Type_Combo_Items              : String_List.Glist;
      Message_Partitioning_Combo_Items     : String_List.Glist;
      Rta_Overhead_Model_Combo_Items       : String_List.Glist;
      Char_Rece_Op_Combo_Items             : String_List.Glist;
      Char_Send_Op_Combo_Items             : String_List.Glist;
      Char_Server_Combo_Items              : String_List.Glist;
      Packet_Interrupt_Server_Combo_Items  : String_List.Glist;
      Packet_Isr_Op_Combo_Items            : String_List.Glist;
      Token_Check_Op_Combo_Items           : String_List.Glist;
      Token_Manage_Op_Combo_Items          : String_List.Glist;
      Packet_Discard_Op_Combo_Items        : String_List.Glist;
      Token_Retransmission_Op_Combo_Items  : String_List.Glist;
      Packet_Retransmission_Op_Combo_Items : String_List.Glist;

      Ser_Ref   : Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Ser_Index : Mast.Scheduling_Servers.Lists.Index;
      Ser_Name  : Var_Strings.Var_String;

      Op_Ref   : Mast.Operations.Operation_Ref;
      Op_Index : Mast.Operations.Lists.Index;
      Op_Name  : Var_Strings.Var_String;

   begin
      -- We search System Servers and show them in *_Server_Combos
      Mast.Scheduling_Servers.Lists.Rewind
        (The_System.Scheduling_Servers,
         Ser_Index);
      for I in 
            1 ..
            Mast.Scheduling_Servers.Lists.Size
               (The_System.Scheduling_Servers)
      loop
         Mast.Scheduling_Servers.Lists.Get_Next_Item
           (Ser_Ref,
            The_System.Scheduling_Servers,
            Ser_Index);
         Ser_Name := Mast.Scheduling_Servers.Name (Ser_Ref);
         String_List.Append
           (Packet_Server_Combo_Items,
            Name_Image (Ser_Name));
         String_List.Append (Char_Server_Combo_Items, Name_Image (Ser_Name));
         String_List.Append
           (Packet_Interrupt_Server_Combo_Items,
            Name_Image (Ser_Name));
      end loop;

      -- We search System Operations and show them in *_*_Op_Combos
      Mast.Operations.Lists.Rewind (The_System.Operations, Op_Index);
      for I in 1 .. Mast.Operations.Lists.Size (The_System.Operations) loop
         Mast.Operations.Lists.Get_Next_Item
           (Op_Ref,
            The_System.Operations,
            Op_Index);
         Op_Name := Mast.Operations.Name (Op_Ref);
         String_List.Append
           (Packet_Send_Op_Combo_Items,
            Name_Image (Op_Name));
         String_List.Append
           (Packet_Rece_Op_Combo_Items,
            Name_Image (Op_Name));
         String_List.Append (Char_Send_Op_Combo_Items, Name_Image (Op_Name));
         String_List.Append (Char_Rece_Op_Combo_Items, Name_Image (Op_Name));
         String_List.Append (Packet_Isr_Op_Combo_Items, Name_Image (Op_Name));
         String_List.Append
           (Token_Check_Op_Combo_Items,
            Name_Image (Op_Name));
         String_List.Append
           (Token_Manage_Op_Combo_Items,
            Name_Image (Op_Name));
         String_List.Append
           (Packet_Discard_Op_Combo_Items,
            Name_Image (Op_Name));
         String_List.Append
           (Token_Retransmission_Op_Combo_Items,
            Name_Image (Op_Name));
         String_List.Append
           (Packet_Retransmission_Op_Combo_Items,
            Name_Image (Op_Name));
      end loop;

      Gtk.Dialog.Initialize (Driver_Dialog);
      Set_Title (Driver_Dialog, -"Driver Parameters");
      Set_Position (Driver_Dialog, Win_Pos_Center_Always);
      Set_Modal (Driver_Dialog, True); -- change this property when using
                                       --On_Button_Click
      Set_Policy (Driver_Dialog, False, False, False);

      Gtk_New_Hbox (Driver_Dialog.Hbox27, True, 0);
      Pack_Start (Get_Action_Area (Driver_Dialog), Driver_Dialog.Hbox27);

      Gtk_New (Driver_Dialog.Driver_Ok_Button, -"OK");
      Set_Relief (Driver_Dialog.Driver_Ok_Button, Relief_Normal);
      Pack_Start
        (Driver_Dialog.Hbox27,
         Driver_Dialog.Driver_Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 110);

      Gtk_New (Driver_Dialog.Driver_Cancel_Button, -"Cancel");
      Set_Relief (Driver_Dialog.Driver_Cancel_Button, Relief_Normal);
      Pack_End
        (Driver_Dialog.Hbox27,
         Driver_Dialog.Driver_Cancel_Button,
         Expand  => True,
         Fill    => True,
         Padding => 110);
      --     Button_Callback.Connect
      --       (Driver_Dialog.Driver_Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Driver_Cancel_Button_Clicked'Access), False);

      Dialog_Callback.Object_Connect
        (Driver_Dialog.Driver_Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller
            (On_Driver_Cancel_Button_Clicked'Access),
         Driver_Dialog);

      Gtk_New (Driver_Dialog.Packet_Server_Table, 6, 3, True);
      Set_Border_Width (Driver_Dialog.Packet_Server_Table, 5);
      Set_Row_Spacings (Driver_Dialog.Packet_Server_Table, 5);
      Set_Col_Spacings (Driver_Dialog.Packet_Server_Table, 5);
      Pack_Start
        (Get_Vbox (Driver_Dialog),
         Driver_Dialog.Packet_Server_Table,
         Expand  => False,
         Fill    => True,
         Padding => 0);

      Gtk_New (Driver_Dialog.New_Operation_Button, -"New Operation...");
      Set_Relief (Driver_Dialog.New_Operation_Button, Relief_Normal);
      Attach
        (Driver_Dialog.Packet_Server_Table,
         Driver_Dialog.New_Operation_Button,
         Left_Attach   => 2,
         Right_Attach  => 3,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);
      --     Button_Callback.Connect
      --       (Driver_Dialog.New_Operation_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_New_Operation_Button_Clicked'Access), False);
      Driver_Dialog_Callback.Object_Connect
        (Driver_Dialog.New_Operation_Button,
         "clicked",
         Driver_Dialog_Callback.To_Marshaller
            (On_New_Operation_Button_Clicked'Access),
         Driver_Dialog);

      Gtk_New (Driver_Dialog.New_Server_Button, -"New Server...");
      Set_Relief (Driver_Dialog.New_Server_Button, Relief_Normal);
      Attach
        (Driver_Dialog.Packet_Server_Table,
         Driver_Dialog.New_Server_Button,
         Left_Attach   => 2,
         Right_Attach  => 3,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);
      --     Button_Callback.Connect
      --       (Driver_Dialog.New_Server_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_New_Server_Button_Clicked'Access), False);
      Driver_Dialog_Callback.Object_Connect
        (Driver_Dialog.New_Server_Button,
         "clicked",
         Driver_Dialog_Callback.To_Marshaller
            (On_New_Server_Button_Clicked'Access),
         Driver_Dialog);

      Gtk_New (Driver_Dialog.Packet_Server_Combo);
      Set_Value_In_List (Driver_Dialog.Packet_Server_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Packet_Server_Combo, True);
      Set_Case_Sensitive (Driver_Dialog.Packet_Server_Combo, False);
      Set_Editable (Get_Entry (Driver_Dialog.Packet_Server_Combo), False);
      Set_Has_Frame (Get_Entry (Driver_Dialog.Packet_Server_Combo), True);
      Set_Max_Length (Get_Entry (Driver_Dialog.Packet_Server_Combo), 0);
      Set_Text
        (Get_Entry (Driver_Dialog.Packet_Server_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Packet_Server_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Driver_Dialog.Packet_Server_Combo), True);
      String_List.Append (Packet_Server_Combo_Items, -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Packet_Server_Combo,
         Packet_Server_Combo_Items);
      Free_String_List (Packet_Server_Combo_Items);
      Attach
        (Driver_Dialog.Packet_Server_Table,
         Driver_Dialog.Packet_Server_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Packet_Send_Op_Combo);
      Set_Value_In_List (Driver_Dialog.Packet_Send_Op_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Packet_Send_Op_Combo, True);
      Set_Case_Sensitive (Driver_Dialog.Packet_Send_Op_Combo, False);
      Set_Editable (Get_Entry (Driver_Dialog.Packet_Send_Op_Combo), False);
      Set_Has_Frame (Get_Entry (Driver_Dialog.Packet_Send_Op_Combo), True);
      Set_Max_Length (Get_Entry (Driver_Dialog.Packet_Send_Op_Combo), 0);
      Set_Text
        (Get_Entry (Driver_Dialog.Packet_Send_Op_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Packet_Send_Op_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Driver_Dialog.Packet_Send_Op_Combo), True);
      String_List.Append (Packet_Send_Op_Combo_Items, -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Packet_Send_Op_Combo,
         Packet_Send_Op_Combo_Items);
      Free_String_List (Packet_Send_Op_Combo_Items);
      Attach
        (Driver_Dialog.Packet_Server_Table,
         Driver_Dialog.Packet_Send_Op_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Packet_Rece_Op_Combo);
      Set_Value_In_List (Driver_Dialog.Packet_Rece_Op_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Packet_Rece_Op_Combo, True);
      Set_Case_Sensitive (Driver_Dialog.Packet_Rece_Op_Combo, False);
      Set_Editable (Get_Entry (Driver_Dialog.Packet_Rece_Op_Combo), False);
      Set_Has_Frame (Get_Entry (Driver_Dialog.Packet_Rece_Op_Combo), True);
      Set_Max_Length (Get_Entry (Driver_Dialog.Packet_Rece_Op_Combo), 0);
      Set_Text
        (Get_Entry (Driver_Dialog.Packet_Rece_Op_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Packet_Rece_Op_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Driver_Dialog.Packet_Rece_Op_Combo), True);
      String_List.Append (Packet_Rece_Op_Combo_Items, -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Packet_Rece_Op_Combo,
         Packet_Rece_Op_Combo_Items);
      Free_String_List (Packet_Rece_Op_Combo_Items);
      Attach
        (Driver_Dialog.Packet_Server_Table,
         Driver_Dialog.Packet_Rece_Op_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Driver_Type_Combo);
      Set_Value_In_List (Driver_Dialog.Driver_Type_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Driver_Type_Combo, True);
      Set_Case_Sensitive (Driver_Dialog.Driver_Type_Combo, False);
      Set_Editable (Get_Entry (Driver_Dialog.Driver_Type_Combo), False);
      Set_Has_Frame (Get_Entry (Driver_Dialog.Driver_Type_Combo), True);
      Set_Max_Length (Get_Entry (Driver_Dialog.Driver_Type_Combo), 0);
      Set_Text
        (Get_Entry (Driver_Dialog.Driver_Type_Combo),
         -("Packet Driver"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Driver_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Driver_Dialog.Driver_Type_Combo), True);
      --     Entry_Callback.Connect
      --       (Get_Entry (Driver_Dialog.Driver_Type_Combo), "changed",
      --        Entry_Callback.To_Marshaller
      --(On_Driver_Type_Entry_Activate'Access), False);
      String_List.Append (Driver_Type_Combo_Items, -("Packet Driver"));
      String_List.Append
        (Driver_Type_Combo_Items,
         -("Character Packet Driver"));
      String_List.Append
        (Driver_Type_Combo_Items,
         -("RT-EP Packet Driver"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Driver_Type_Combo,
         Driver_Type_Combo_Items);
      Free_String_List (Driver_Type_Combo_Items);
      Attach
        (Driver_Dialog.Packet_Server_Table,
         Driver_Dialog.Driver_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Message_Partitioning_Combo);
      Set_Value_In_List (Driver_Dialog.Message_Partitioning_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Message_Partitioning_Combo, True);
      Set_Case_Sensitive (Driver_Dialog.Message_Partitioning_Combo, False);
      Set_Editable
        (Get_Entry (Driver_Dialog.Message_Partitioning_Combo),
         False);
      Set_Has_Frame
        (Get_Entry (Driver_Dialog.Message_Partitioning_Combo),
         True);
      Set_Max_Length
        (Get_Entry (Driver_Dialog.Message_Partitioning_Combo),
         0);
      Set_Text
        (Get_Entry (Driver_Dialog.Message_Partitioning_Combo),
         -("YES"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Message_Partitioning_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Driver_Dialog.Message_Partitioning_Combo),
         True);
      String_List.Append (Message_Partitioning_Combo_Items, -("YES"));
      String_List.Append (Message_Partitioning_Combo_Items, -("NO"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Message_Partitioning_Combo,
         Message_Partitioning_Combo_Items);
      Free_String_List (Message_Partitioning_Combo_Items);
      Attach
        (Driver_Dialog.Packet_Server_Table,
         Driver_Dialog.Message_Partitioning_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Rta_Overhead_Model_Combo);
      Set_Value_In_List (Driver_Dialog.Rta_Overhead_Model_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Rta_Overhead_Model_Combo, True);
      Set_Case_Sensitive (Driver_Dialog.Rta_Overhead_Model_Combo, False);
      Set_Editable
        (Get_Entry (Driver_Dialog.Rta_Overhead_Model_Combo),
         False);
      Set_Has_Frame
        (Get_Entry (Driver_Dialog.Rta_Overhead_Model_Combo),
         True);
      Set_Max_Length (Get_Entry (Driver_Dialog.Rta_Overhead_Model_Combo), 0);
      Set_Text
        (Get_Entry (Driver_Dialog.Rta_Overhead_Model_Combo),
         -("Decoupled"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Rta_Overhead_Model_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Driver_Dialog.Rta_Overhead_Model_Combo),
         True);
      String_List.Append (Rta_Overhead_Model_Combo_Items, -("Decoupled"));
      String_List.Append (Rta_Overhead_Model_Combo_Items, -("Coupled"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Rta_Overhead_Model_Combo,
         Rta_Overhead_Model_Combo_Items);
      Free_String_List (Rta_Overhead_Model_Combo_Items);
      Attach
        (Driver_Dialog.Packet_Server_Table,
         Driver_Dialog.Rta_Overhead_Model_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 5,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label621, -("RTA Overhead Model"));
      Set_Alignment (Driver_Dialog.Label621, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label621, 0, 0);
      Set_Justify (Driver_Dialog.Label621, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label621, False);
      Set_Selectable (Driver_Dialog.Label621, False);
      Set_Use_Markup (Driver_Dialog.Label621, False);
      Set_Use_Underline (Driver_Dialog.Label621, False);
      Attach
        (Driver_Dialog.Packet_Server_Table,
         Driver_Dialog.Label621,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 5,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label620, -("Message Partitioning"));
      Set_Alignment (Driver_Dialog.Label620, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label620, 0, 0);
      Set_Justify (Driver_Dialog.Label620, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label620, False);
      Set_Selectable (Driver_Dialog.Label620, False);
      Set_Use_Markup (Driver_Dialog.Label620, False);
      Set_Use_Underline (Driver_Dialog.Label620, False);
      Attach
        (Driver_Dialog.Packet_Server_Table,
         Driver_Dialog.Label620,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label89, -("Packet Receive Operation"));
      Set_Alignment (Driver_Dialog.Label89, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label89, 0, 0);
      Set_Justify (Driver_Dialog.Label89, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label89, False);
      Set_Selectable (Driver_Dialog.Label89, False);
      Set_Use_Markup (Driver_Dialog.Label89, False);
      Set_Use_Underline (Driver_Dialog.Label89, False);
      Attach
        (Driver_Dialog.Packet_Server_Table,
         Driver_Dialog.Label89,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label90, -("Packet Send Operation"));
      Set_Alignment (Driver_Dialog.Label90, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label90, 0, 0);
      Set_Justify (Driver_Dialog.Label90, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label90, False);
      Set_Selectable (Driver_Dialog.Label90, False);
      Set_Use_Markup (Driver_Dialog.Label90, False);
      Set_Use_Underline (Driver_Dialog.Label90, False);
      Attach
        (Driver_Dialog.Packet_Server_Table,
         Driver_Dialog.Label90,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label91, -("Packet Server"));
      Set_Alignment (Driver_Dialog.Label91, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label91, 0, 0);
      Set_Justify (Driver_Dialog.Label91, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label91, False);
      Set_Selectable (Driver_Dialog.Label91, False);
      Set_Use_Markup (Driver_Dialog.Label91, False);
      Set_Use_Underline (Driver_Dialog.Label91, False);
      Attach
        (Driver_Dialog.Packet_Server_Table,
         Driver_Dialog.Label91,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label92, -("DRIVER TYPE"));
      Set_Alignment (Driver_Dialog.Label92, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label92, 0, 0);
      Set_Justify (Driver_Dialog.Label92, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label92, False);
      Set_Selectable (Driver_Dialog.Label92, False);
      Set_Use_Markup (Driver_Dialog.Label92, False);
      Set_Use_Underline (Driver_Dialog.Label92, False);
      Attach
        (Driver_Dialog.Packet_Server_Table,
         Driver_Dialog.Label92,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Character_Server_Table, 4, 3, True);
      Set_Border_Width (Driver_Dialog.Character_Server_Table, 5);
      Set_Row_Spacings (Driver_Dialog.Character_Server_Table, 5);
      Set_Col_Spacings (Driver_Dialog.Character_Server_Table, 5);
      Pack_Start
        (Get_Vbox (Driver_Dialog),
         Driver_Dialog.Character_Server_Table,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Driver_Dialog.Char_Tx_Time_Entry);
      Set_Editable (Driver_Dialog.Char_Tx_Time_Entry, True);
      Set_Max_Length (Driver_Dialog.Char_Tx_Time_Entry, 0);
      Set_Text
        (Driver_Dialog.Char_Tx_Time_Entry,
         Time_Image (Mast.Large_Time));
      Set_Visibility (Driver_Dialog.Char_Tx_Time_Entry, True);
      Set_Invisible_Char
        (Driver_Dialog.Char_Tx_Time_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Driver_Dialog.Character_Server_Table,
         Driver_Dialog.Char_Tx_Time_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Char_Rece_Op_Combo);
      Set_Value_In_List (Driver_Dialog.Char_Rece_Op_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Char_Rece_Op_Combo, True);
      Set_Case_Sensitive (Driver_Dialog.Char_Rece_Op_Combo, False);
      Set_Editable (Get_Entry (Driver_Dialog.Char_Rece_Op_Combo), False);
      Set_Has_Frame (Get_Entry (Driver_Dialog.Char_Rece_Op_Combo), True);
      Set_Max_Length (Get_Entry (Driver_Dialog.Char_Rece_Op_Combo), 0);
      Set_Text (Get_Entry (Driver_Dialog.Char_Rece_Op_Combo), -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Char_Rece_Op_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Driver_Dialog.Char_Rece_Op_Combo), True);
      String_List.Append (Char_Rece_Op_Combo_Items, -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Char_Rece_Op_Combo,
         Char_Rece_Op_Combo_Items);
      Free_String_List (Char_Rece_Op_Combo_Items);
      Attach
        (Driver_Dialog.Character_Server_Table,
         Driver_Dialog.Char_Rece_Op_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Char_Send_Op_Combo);
      Set_Value_In_List (Driver_Dialog.Char_Send_Op_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Char_Send_Op_Combo, True);
      Set_Case_Sensitive (Driver_Dialog.Char_Send_Op_Combo, False);
      Set_Editable (Get_Entry (Driver_Dialog.Char_Send_Op_Combo), False);
      Set_Has_Frame (Get_Entry (Driver_Dialog.Char_Send_Op_Combo), True);
      Set_Max_Length (Get_Entry (Driver_Dialog.Char_Send_Op_Combo), 0);
      Set_Text (Get_Entry (Driver_Dialog.Char_Send_Op_Combo), -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Char_Send_Op_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Driver_Dialog.Char_Send_Op_Combo), True);
      String_List.Append (Char_Send_Op_Combo_Items, -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Char_Send_Op_Combo,
         Char_Send_Op_Combo_Items);
      Free_String_List (Char_Send_Op_Combo_Items);
      Attach
        (Driver_Dialog.Character_Server_Table,
         Driver_Dialog.Char_Send_Op_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Char_Server_Combo);
      Set_Value_In_List (Driver_Dialog.Char_Server_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Char_Server_Combo, True);
      Set_Case_Sensitive (Driver_Dialog.Char_Server_Combo, False);
      Set_Editable (Get_Entry (Driver_Dialog.Char_Server_Combo), False);
      Set_Has_Frame (Get_Entry (Driver_Dialog.Char_Server_Combo), True);
      Set_Max_Length (Get_Entry (Driver_Dialog.Char_Server_Combo), 0);
      Set_Text (Get_Entry (Driver_Dialog.Char_Server_Combo), -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Char_Server_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Driver_Dialog.Char_Server_Combo), True);
      String_List.Append (Char_Server_Combo_Items, -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Char_Server_Combo,
         Char_Server_Combo_Items);
      Free_String_List (Char_Server_Combo_Items);
      Attach
        (Driver_Dialog.Character_Server_Table,
         Driver_Dialog.Char_Server_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label102, -("Character Transmission Time "));
      Set_Alignment (Driver_Dialog.Label102, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label102, 0, 0);
      Set_Justify (Driver_Dialog.Label102, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label102, False);
      Set_Selectable (Driver_Dialog.Label102, False);
      Set_Use_Markup (Driver_Dialog.Label102, False);
      Set_Use_Underline (Driver_Dialog.Label102, False);
      Attach
        (Driver_Dialog.Character_Server_Table,
         Driver_Dialog.Label102,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label103, -("Character Receive Operation"));
      Set_Alignment (Driver_Dialog.Label103, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label103, 0, 0);
      Set_Justify (Driver_Dialog.Label103, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label103, False);
      Set_Selectable (Driver_Dialog.Label103, False);
      Set_Use_Markup (Driver_Dialog.Label103, False);
      Set_Use_Underline (Driver_Dialog.Label103, False);
      Attach
        (Driver_Dialog.Character_Server_Table,
         Driver_Dialog.Label103,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label104, -("Character Send Operation"));
      Set_Alignment (Driver_Dialog.Label104, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label104, 0, 0);
      Set_Justify (Driver_Dialog.Label104, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label104, False);
      Set_Selectable (Driver_Dialog.Label104, False);
      Set_Use_Markup (Driver_Dialog.Label104, False);
      Set_Use_Underline (Driver_Dialog.Label104, False);
      Attach
        (Driver_Dialog.Character_Server_Table,
         Driver_Dialog.Label104,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label478, -("Character Server"));
      Set_Alignment (Driver_Dialog.Label478, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label478, 0, 0);
      Set_Justify (Driver_Dialog.Label478, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label478, False);
      Set_Selectable (Driver_Dialog.Label478, False);
      Set_Use_Markup (Driver_Dialog.Label478, False);
      Set_Use_Underline (Driver_Dialog.Label478, False);
      Attach
        (Driver_Dialog.Character_Server_Table,
         Driver_Dialog.Label478,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Rtep_Table, 12, 3, True);
      Set_Border_Width (Driver_Dialog.Rtep_Table, 5);
      Set_Row_Spacings (Driver_Dialog.Rtep_Table, 5);
      Set_Col_Spacings (Driver_Dialog.Rtep_Table, 5);
      Pack_Start
        (Get_Vbox (Driver_Dialog),
         Driver_Dialog.Rtep_Table,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Driver_Dialog.Num_Of_Stations_Entry);
      Set_Editable (Driver_Dialog.Num_Of_Stations_Entry, True);
      Set_Max_Length (Driver_Dialog.Num_Of_Stations_Entry, 0);
      Set_Text
        (Driver_Dialog.Num_Of_Stations_Entry,
         Positive'Image (Positive'Last));
      Set_Visibility (Driver_Dialog.Num_Of_Stations_Entry, True);
      Set_Invisible_Char
        (Driver_Dialog.Num_Of_Stations_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Num_Of_Stations_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Token_Delay_Entry);
      Set_Editable (Driver_Dialog.Token_Delay_Entry, True);
      Set_Max_Length (Driver_Dialog.Token_Delay_Entry, 0);
      Set_Text (Driver_Dialog.Token_Delay_Entry, -("0.0"));
      Set_Visibility (Driver_Dialog.Token_Delay_Entry, True);
      Set_Invisible_Char
        (Driver_Dialog.Token_Delay_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Token_Delay_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Failure_Timeout_Entry);
      Set_Editable (Driver_Dialog.Failure_Timeout_Entry, True);
      Set_Max_Length (Driver_Dialog.Failure_Timeout_Entry, 0);
      Set_Text
        (Driver_Dialog.Failure_Timeout_Entry,
         Time_Image (Mast.Large_Time));
      Set_Visibility (Driver_Dialog.Failure_Timeout_Entry, True);
      Set_Invisible_Char
        (Driver_Dialog.Failure_Timeout_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Failure_Timeout_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label624, -("Failure Timeout"));
      Set_Alignment (Driver_Dialog.Label624, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label624, 0, 0);
      Set_Justify (Driver_Dialog.Label624, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label624, False);
      Set_Selectable (Driver_Dialog.Label624, False);
      Set_Use_Markup (Driver_Dialog.Label624, False);
      Set_Use_Underline (Driver_Dialog.Label624, False);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Label624,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label623, -("Token Delay"));
      Set_Alignment (Driver_Dialog.Label623, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label623, 0, 0);
      Set_Justify (Driver_Dialog.Label623, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label623, False);
      Set_Selectable (Driver_Dialog.Label623, False);
      Set_Use_Markup (Driver_Dialog.Label623, False);
      Set_Use_Underline (Driver_Dialog.Label623, False);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Label623,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label622, -("Number Of Stations"));
      Set_Alignment (Driver_Dialog.Label622, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label622, 0, 0);
      Set_Justify (Driver_Dialog.Label622, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label622, False);
      Set_Selectable (Driver_Dialog.Label622, False);
      Set_Use_Markup (Driver_Dialog.Label622, False);
      Set_Use_Underline (Driver_Dialog.Label622, False);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Label622,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Token_Transmission_Retries_Entry);
      Set_Editable (Driver_Dialog.Token_Transmission_Retries_Entry, True);
      Set_Max_Length (Driver_Dialog.Token_Transmission_Retries_Entry, 0);
      Set_Text (Driver_Dialog.Token_Transmission_Retries_Entry, -("0"));
      Set_Visibility (Driver_Dialog.Token_Transmission_Retries_Entry, True);
      Set_Invisible_Char
        (Driver_Dialog.Token_Transmission_Retries_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Token_Transmission_Retries_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Packet_Transmission_Retries_Entry);
      Set_Editable (Driver_Dialog.Packet_Transmission_Retries_Entry, True);
      Set_Max_Length (Driver_Dialog.Packet_Transmission_Retries_Entry, 0);
      Set_Text (Driver_Dialog.Packet_Transmission_Retries_Entry, -("0"));
      Set_Visibility (Driver_Dialog.Packet_Transmission_Retries_Entry, True);
      Set_Invisible_Char
        (Driver_Dialog.Packet_Transmission_Retries_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Packet_Transmission_Retries_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label629, -("Token Check Operation"));
      Set_Alignment (Driver_Dialog.Label629, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label629, 0, 0);
      Set_Justify (Driver_Dialog.Label629, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label629, False);
      Set_Selectable (Driver_Dialog.Label629, False);
      Set_Use_Markup (Driver_Dialog.Label629, False);
      Set_Use_Underline (Driver_Dialog.Label629, False);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Label629,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 7,
         Bottom_Attach => 8,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label630, -("Token Manage Operation"));
      Set_Alignment (Driver_Dialog.Label630, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label630, 0, 0);
      Set_Justify (Driver_Dialog.Label630, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label630, False);
      Set_Selectable (Driver_Dialog.Label630, False);
      Set_Use_Markup (Driver_Dialog.Label630, False);
      Set_Use_Underline (Driver_Dialog.Label630, False);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Label630,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 8,
         Bottom_Attach => 9,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label631, -("Packet Discard Operation"));
      Set_Alignment (Driver_Dialog.Label631, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label631, 0, 0);
      Set_Justify (Driver_Dialog.Label631, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label631, False);
      Set_Selectable (Driver_Dialog.Label631, False);
      Set_Use_Markup (Driver_Dialog.Label631, False);
      Set_Use_Underline (Driver_Dialog.Label631, False);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Label631,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 9,
         Bottom_Attach => 10,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label632, -("Token Retransmision Operation"));
      Set_Alignment (Driver_Dialog.Label632, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label632, 0, 0);
      Set_Justify (Driver_Dialog.Label632, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label632, False);
      Set_Selectable (Driver_Dialog.Label632, False);
      Set_Use_Markup (Driver_Dialog.Label632, False);
      Set_Use_Underline (Driver_Dialog.Label632, False);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Label632,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 10,
         Bottom_Attach => 11,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Driver_Dialog.Label633,
         -("Packet Retransmition Operation"));
      Set_Alignment (Driver_Dialog.Label633, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label633, 0, 0);
      Set_Justify (Driver_Dialog.Label633, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label633, False);
      Set_Selectable (Driver_Dialog.Label633, False);
      Set_Use_Markup (Driver_Dialog.Label633, False);
      Set_Use_Underline (Driver_Dialog.Label633, False);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Label633,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 11,
         Bottom_Attach => 12,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Packet_Interrupt_Server_Combo);
      Set_Value_In_List (Driver_Dialog.Packet_Interrupt_Server_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Packet_Interrupt_Server_Combo, True);
      Set_Case_Sensitive (Driver_Dialog.Packet_Interrupt_Server_Combo, False);
      Set_Editable
        (Get_Entry (Driver_Dialog.Packet_Interrupt_Server_Combo),
         False);
      Set_Has_Frame
        (Get_Entry (Driver_Dialog.Packet_Interrupt_Server_Combo),
         True);
      Set_Max_Length
        (Get_Entry (Driver_Dialog.Packet_Interrupt_Server_Combo),
         0);
      Set_Text
        (Get_Entry (Driver_Dialog.Packet_Interrupt_Server_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Packet_Interrupt_Server_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Driver_Dialog.Packet_Interrupt_Server_Combo),
         True);
      String_List.Append
        (Packet_Interrupt_Server_Combo_Items,
         -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Packet_Interrupt_Server_Combo,
         Packet_Interrupt_Server_Combo_Items);
      Free_String_List (Packet_Interrupt_Server_Combo_Items);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Packet_Interrupt_Server_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 5,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Packet_Isr_Op_Combo);
      Set_Value_In_List (Driver_Dialog.Packet_Isr_Op_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Packet_Isr_Op_Combo, True);
      Set_Case_Sensitive (Driver_Dialog.Packet_Isr_Op_Combo, False);
      Set_Editable (Get_Entry (Driver_Dialog.Packet_Isr_Op_Combo), False);
      Set_Has_Frame (Get_Entry (Driver_Dialog.Packet_Isr_Op_Combo), True);
      Set_Max_Length (Get_Entry (Driver_Dialog.Packet_Isr_Op_Combo), 0);
      Set_Text
        (Get_Entry (Driver_Dialog.Packet_Isr_Op_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Packet_Isr_Op_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Driver_Dialog.Packet_Isr_Op_Combo), True);
      String_List.Append (Packet_Isr_Op_Combo_Items, -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Packet_Isr_Op_Combo,
         Packet_Isr_Op_Combo_Items);
      Free_String_List (Packet_Isr_Op_Combo_Items);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Packet_Isr_Op_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 6,
         Bottom_Attach => 7,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Token_Check_Op_Combo);
      Set_Value_In_List (Driver_Dialog.Token_Check_Op_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Token_Check_Op_Combo, True);
      Set_Case_Sensitive (Driver_Dialog.Token_Check_Op_Combo, False);
      Set_Editable (Get_Entry (Driver_Dialog.Token_Check_Op_Combo), False);
      Set_Has_Frame (Get_Entry (Driver_Dialog.Token_Check_Op_Combo), True);
      Set_Max_Length (Get_Entry (Driver_Dialog.Token_Check_Op_Combo), 0);
      Set_Text
        (Get_Entry (Driver_Dialog.Token_Check_Op_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Token_Check_Op_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Driver_Dialog.Token_Check_Op_Combo), True);
      String_List.Append (Token_Check_Op_Combo_Items, -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Token_Check_Op_Combo,
         Token_Check_Op_Combo_Items);
      Free_String_List (Token_Check_Op_Combo_Items);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Token_Check_Op_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 7,
         Bottom_Attach => 8,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Token_Manage_Op_Combo);
      Set_Value_In_List (Driver_Dialog.Token_Manage_Op_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Token_Manage_Op_Combo, True);
      Set_Case_Sensitive (Driver_Dialog.Token_Manage_Op_Combo, False);
      Set_Editable (Get_Entry (Driver_Dialog.Token_Manage_Op_Combo), False);
      Set_Has_Frame (Get_Entry (Driver_Dialog.Token_Manage_Op_Combo), True);
      Set_Max_Length (Get_Entry (Driver_Dialog.Token_Manage_Op_Combo), 0);
      Set_Text
        (Get_Entry (Driver_Dialog.Token_Manage_Op_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Token_Manage_Op_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Driver_Dialog.Token_Manage_Op_Combo), True);
      String_List.Append (Token_Manage_Op_Combo_Items, -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Token_Manage_Op_Combo,
         Token_Manage_Op_Combo_Items);
      Free_String_List (Token_Manage_Op_Combo_Items);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Token_Manage_Op_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 8,
         Bottom_Attach => 9,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Packet_Discard_Op_Combo);
      Set_Value_In_List (Driver_Dialog.Packet_Discard_Op_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Packet_Discard_Op_Combo, True);
      Set_Case_Sensitive (Driver_Dialog.Packet_Discard_Op_Combo, False);
      Set_Editable (Get_Entry (Driver_Dialog.Packet_Discard_Op_Combo), False);
      Set_Has_Frame (Get_Entry (Driver_Dialog.Packet_Discard_Op_Combo), True);
      Set_Max_Length (Get_Entry (Driver_Dialog.Packet_Discard_Op_Combo), 0);
      Set_Text
        (Get_Entry (Driver_Dialog.Packet_Discard_Op_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Packet_Discard_Op_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Driver_Dialog.Packet_Discard_Op_Combo), True);
      String_List.Append (Packet_Discard_Op_Combo_Items, -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Packet_Discard_Op_Combo,
         Packet_Discard_Op_Combo_Items);
      Free_String_List (Packet_Discard_Op_Combo_Items);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Packet_Discard_Op_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 9,
         Bottom_Attach => 10,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Token_Retransmission_Op_Combo);
      Set_Value_In_List (Driver_Dialog.Token_Retransmission_Op_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Token_Retransmission_Op_Combo, True);
      Set_Case_Sensitive (Driver_Dialog.Token_Retransmission_Op_Combo, False);
      Set_Editable
        (Get_Entry (Driver_Dialog.Token_Retransmission_Op_Combo),
         False);
      Set_Has_Frame
        (Get_Entry (Driver_Dialog.Token_Retransmission_Op_Combo),
         True);
      Set_Max_Length
        (Get_Entry (Driver_Dialog.Token_Retransmission_Op_Combo),
         0);
      Set_Text
        (Get_Entry (Driver_Dialog.Token_Retransmission_Op_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Token_Retransmission_Op_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Driver_Dialog.Token_Retransmission_Op_Combo),
         True);
      String_List.Append
        (Token_Retransmission_Op_Combo_Items,
         -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Token_Retransmission_Op_Combo,
         Token_Retransmission_Op_Combo_Items);
      Free_String_List (Token_Retransmission_Op_Combo_Items);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Token_Retransmission_Op_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 10,
         Bottom_Attach => 11,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Packet_Retransmission_Op_Combo);
      Set_Value_In_List (Driver_Dialog.Packet_Retransmission_Op_Combo, False);
      Set_Use_Arrows (Driver_Dialog.Packet_Retransmission_Op_Combo, True);
      Set_Case_Sensitive
        (Driver_Dialog.Packet_Retransmission_Op_Combo,
         False);
      Set_Editable
        (Get_Entry (Driver_Dialog.Packet_Retransmission_Op_Combo),
         False);
      Set_Has_Frame
        (Get_Entry (Driver_Dialog.Packet_Retransmission_Op_Combo),
         True);
      Set_Max_Length
        (Get_Entry (Driver_Dialog.Packet_Retransmission_Op_Combo),
         0);
      Set_Text
        (Get_Entry (Driver_Dialog.Packet_Retransmission_Op_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Driver_Dialog.Packet_Retransmission_Op_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Driver_Dialog.Packet_Retransmission_Op_Combo),
         True);
      String_List.Append
        (Packet_Retransmission_Op_Combo_Items,
         -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Driver_Dialog.Packet_Retransmission_Op_Combo,
         Packet_Retransmission_Op_Combo_Items);
      Free_String_List (Packet_Retransmission_Op_Combo_Items);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Packet_Retransmission_Op_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 11,
         Bottom_Attach => 12,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label628, -("Packet ISR Operation"));
      Set_Alignment (Driver_Dialog.Label628, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label628, 0, 0);
      Set_Justify (Driver_Dialog.Label628, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label628, False);
      Set_Selectable (Driver_Dialog.Label628, False);
      Set_Use_Markup (Driver_Dialog.Label628, False);
      Set_Use_Underline (Driver_Dialog.Label628, False);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Label628,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 6,
         Bottom_Attach => 7,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label627, -("Packet Interrupt Server"));
      Set_Alignment (Driver_Dialog.Label627, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label627, 0, 0);
      Set_Justify (Driver_Dialog.Label627, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label627, False);
      Set_Selectable (Driver_Dialog.Label627, False);
      Set_Use_Markup (Driver_Dialog.Label627, False);
      Set_Use_Underline (Driver_Dialog.Label627, False);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Label627,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 5,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label626, -("Packet Transmission Retries"));
      Set_Alignment (Driver_Dialog.Label626, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label626, 0, 0);
      Set_Justify (Driver_Dialog.Label626, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label626, False);
      Set_Selectable (Driver_Dialog.Label626, False);
      Set_Use_Markup (Driver_Dialog.Label626, False);
      Set_Use_Underline (Driver_Dialog.Label626, False);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Label626,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Driver_Dialog.Label625, -("Token Transmission Retries"));
      Set_Alignment (Driver_Dialog.Label625, 0.95, 0.5);
      Set_Padding (Driver_Dialog.Label625, 0, 0);
      Set_Justify (Driver_Dialog.Label625, Justify_Center);
      Set_Line_Wrap (Driver_Dialog.Label625, False);
      Set_Selectable (Driver_Dialog.Label625, False);
      Set_Use_Markup (Driver_Dialog.Label625, False);
      Set_Use_Underline (Driver_Dialog.Label625, False);
      Attach
        (Driver_Dialog.Rtep_Table,
         Driver_Dialog.Label625,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Driver_Dialog_Callback.Object_Connect
        (Get_Entry (Driver_Dialog.Driver_Type_Combo),
         "changed",
         Driver_Dialog_Callback.To_Marshaller
            (On_Driver_Type_Entry_Changed'Access),
         Driver_Dialog);

   end Initialize;

end Driver_Dialog_Pkg;
