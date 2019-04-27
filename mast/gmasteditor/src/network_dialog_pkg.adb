-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                           GMastEditor                             --
--          Graphical Editor for Modelling and Analysis              --
--                    of Real-Time Applications                      --
--                                                                   --
--                       Copyright (C) 2005-2008                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors : Pilar del Rio                                           --
--           Michael Gonzalez                                        --
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
with Glib;                         use Glib;
with Gtk;                          use Gtk;
with Gdk.Types;                    use Gdk.Types;
with Gtk.Widget;                   use Gtk.Widget;
with Gtk.Enums;                    use Gtk.Enums;
with Gtkada.Handlers;              use Gtkada.Handlers;
with Callbacks_Mast_Editor;        use Callbacks_Mast_Editor;
with Mast_Editor_Intl;             use Mast_Editor_Intl;
with Network_Dialog_Pkg.Callbacks; use Network_Dialog_Pkg.Callbacks;

with Mast;    use Mast;
with Mast.IO; use Mast.IO;

package body Network_Dialog_Pkg is

   procedure Gtk_New (Network_Dialog : out Network_Dialog_Access) is
   begin
      Network_Dialog := new Network_Dialog_Record;
      Network_Dialog_Pkg.Initialize (Network_Dialog);
   end Gtk_New;

   procedure Initialize
     (Network_Dialog : access Network_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Pixmaps_Dir          : constant String := "pixmaps/";
      Net_Type_Combo_Items : String_List.Glist;
      Tx_Kind_Combo_Items  : String_List.Glist;

   begin
      Gtk.Dialog.Initialize (Network_Dialog);
      Set_Title (Network_Dialog, -"Network Parameters");
      Set_Position (Network_Dialog, Win_Pos_Center_Always);
      Set_Modal (Network_Dialog, False);

      Gtk_New_Hbox (Network_Dialog.Hbox24, True, 0);
      Pack_Start (Get_Action_Area (Network_Dialog), Network_Dialog.Hbox24);

      Gtk_New (Network_Dialog.Network_Ok_Button, -"OK");
      Set_Relief (Network_Dialog.Network_Ok_Button, Relief_Normal);
      Pack_Start
        (Network_Dialog.Hbox24,
         Network_Dialog.Network_Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 130);

      Gtk_New (Network_Dialog.Network_Cancel_Button, -"Cancel");
      Set_Relief (Network_Dialog.Network_Cancel_Button, Relief_Normal);
      Pack_End
        (Network_Dialog.Hbox24,
         Network_Dialog.Network_Cancel_Button,
         Expand  => True,
         Fill    => True,
         Padding => 130);
      --     Button_Callback.Connect
      --       (Network_Dialog.Network_Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Network_Cancel_Button_Clicked'Access), False);

      --     Dialog_Callback.Object_Connect
      --       (Network_Dialog.Network_Cancel_Button, "clicked",
      --        Dialog_Callback.To_Marshaller
      --(On_Network_Cancel_Button_Clicked'Access), Network_Dialog);

      Gtk_New_Hbox (Network_Dialog.Hbox20, False, 0);
      Pack_Start
        (Get_Vbox (Network_Dialog),
         Network_Dialog.Hbox20,
         Expand  => False,
         Fill    => True,
         Padding => 0);

      Gtk_New (Network_Dialog.Table3, 8, 2, False);
      Set_Border_Width (Network_Dialog.Table3, 15);
      Set_Row_Spacings (Network_Dialog.Table3, 5);
      Set_Col_Spacings (Network_Dialog.Table3, 5);
      Pack_Start
        (Network_Dialog.Hbox20,
         Network_Dialog.Table3,
         Expand  => False,
         Fill    => True,
         Padding => 0);

      Gtk_New (Network_Dialog.Max_Pack_Size_Entry);
      Set_Editable (Network_Dialog.Max_Pack_Size_Entry, True);
      Set_Max_Length (Network_Dialog.Max_Pack_Size_Entry, 0);
      Set_Text
        (Network_Dialog.Max_Pack_Size_Entry,
         Bit_Count_Image (Large_Bit_Count));
      Set_Visibility (Network_Dialog.Max_Pack_Size_Entry, True);
      Set_Invisible_Char
        (Network_Dialog.Max_Pack_Size_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Max_Pack_Size_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 6,
         Bottom_Attach => 7,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Min_Pack_Size_Entry);
      Set_Editable (Network_Dialog.Min_Pack_Size_Entry, True);
      Set_Max_Length (Network_Dialog.Min_Pack_Size_Entry, 0);
      Set_Text
        (Network_Dialog.Min_Pack_Size_Entry,
         Bit_Count_Image (Large_Bit_Count));
      Set_Visibility (Network_Dialog.Min_Pack_Size_Entry, True);
      Set_Invisible_Char
        (Network_Dialog.Min_Pack_Size_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Min_Pack_Size_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 7,
         Bottom_Attach => 8,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Label50, -("Max Packet Size"));
      Set_Alignment (Network_Dialog.Label50, 0.95, 0.5);
      Set_Padding (Network_Dialog.Label50, 0, 0);
      Set_Justify (Network_Dialog.Label50, Justify_Center);
      Set_Line_Wrap (Network_Dialog.Label50, False);
      Set_Selectable (Network_Dialog.Label50, False);
      Set_Use_Markup (Network_Dialog.Label50, False);
      Set_Use_Underline (Network_Dialog.Label50, False);
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Label50,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 6,
         Bottom_Attach => 7,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Label52, -("Min Packet Size"));
      Set_Alignment (Network_Dialog.Label52, 0.95, 0.5);
      Set_Padding (Network_Dialog.Label52, 0, 0);
      Set_Justify (Network_Dialog.Label52, Justify_Center);
      Set_Line_Wrap (Network_Dialog.Label52, False);
      Set_Selectable (Network_Dialog.Label52, False);
      Set_Use_Markup (Network_Dialog.Label52, False);
      Set_Use_Underline (Network_Dialog.Label52, False);
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Label52,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 7,
         Bottom_Attach => 8,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Label48, -("Network Name"));
      Set_Alignment (Network_Dialog.Label48, 0.95, 0.5);
      Set_Padding (Network_Dialog.Label48, 0, 0);
      Set_Justify (Network_Dialog.Label48, Justify_Center);
      Set_Line_Wrap (Network_Dialog.Label48, False);
      Set_Selectable (Network_Dialog.Label48, False);
      Set_Use_Markup (Network_Dialog.Label48, False);
      Set_Use_Underline (Network_Dialog.Label48, False);
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Label48,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Net_Name_Entry);
      Set_Editable (Network_Dialog.Net_Name_Entry, True);
      Set_Max_Length (Network_Dialog.Net_Name_Entry, 0);
      Set_Text (Network_Dialog.Net_Name_Entry, -(""));
      Set_Visibility (Network_Dialog.Net_Name_Entry, True);
      Set_Invisible_Char (Network_Dialog.Net_Name_Entry, UTF8_Get_Char ("*"));
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Net_Name_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Label352, -("Network Type"));
      Set_Alignment (Network_Dialog.Label352, 0.95, 0.5);
      Set_Padding (Network_Dialog.Label352, 0, 0);
      Set_Justify (Network_Dialog.Label352, Justify_Right);
      Set_Line_Wrap (Network_Dialog.Label352, False);
      Set_Selectable (Network_Dialog.Label352, False);
      Set_Use_Markup (Network_Dialog.Label352, False);
      Set_Use_Underline (Network_Dialog.Label352, False);
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Label352,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Net_Type_Combo);
      Set_Value_In_List (Network_Dialog.Net_Type_Combo, False);
      Set_Use_Arrows (Network_Dialog.Net_Type_Combo, True);
      Set_Case_Sensitive (Network_Dialog.Net_Type_Combo, False);
      Set_Editable (Get_Entry (Network_Dialog.Net_Type_Combo), False);
      Set_Has_Frame (Get_Entry (Network_Dialog.Net_Type_Combo), True);
      Set_Max_Length (Get_Entry (Network_Dialog.Net_Type_Combo), 0);
      Set_Text
        (Get_Entry (Network_Dialog.Net_Type_Combo),
         -("Packet Based"));
      Set_Invisible_Char
        (Get_Entry (Network_Dialog.Net_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Network_Dialog.Net_Type_Combo), True);
      String_List.Append (Net_Type_Combo_Items, -("Packet Based"));
      Combo.Set_Popdown_Strings
        (Network_Dialog.Net_Type_Combo,
         Net_Type_Combo_Items);
      Free_String_List (Net_Type_Combo_Items);
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Net_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Label41, -("Speed Factor"));
      Set_Alignment (Network_Dialog.Label41, 0.95, 0.5);
      Set_Padding (Network_Dialog.Label41, 0, 0);
      Set_Justify (Network_Dialog.Label41, Justify_Center);
      Set_Line_Wrap (Network_Dialog.Label41, False);
      Set_Selectable (Network_Dialog.Label41, False);
      Set_Use_Markup (Network_Dialog.Label41, False);
      Set_Use_Underline (Network_Dialog.Label41, False);
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Label41,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Net_Speed_Entry);
      Set_Editable (Network_Dialog.Net_Speed_Entry, True);
      Set_Max_Length (Network_Dialog.Net_Speed_Entry, 0);
      Set_Text (Network_Dialog.Net_Speed_Entry, -("1.00"));
      Set_Visibility (Network_Dialog.Net_Speed_Entry, True);
      Set_Invisible_Char
        (Network_Dialog.Net_Speed_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Net_Speed_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Label42, -("Transmision Kind"));
      Set_Alignment (Network_Dialog.Label42, 0.95, 0.5);
      Set_Padding (Network_Dialog.Label42, 0, 0);
      Set_Justify (Network_Dialog.Label42, Justify_Center);
      Set_Line_Wrap (Network_Dialog.Label42, False);
      Set_Selectable (Network_Dialog.Label42, False);
      Set_Use_Markup (Network_Dialog.Label42, False);
      Set_Use_Underline (Network_Dialog.Label42, False);
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Label42,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Tx_Kind_Combo);
      Set_Value_In_List (Network_Dialog.Tx_Kind_Combo, False);
      Set_Use_Arrows (Network_Dialog.Tx_Kind_Combo, True);
      Set_Case_Sensitive (Network_Dialog.Tx_Kind_Combo, False);
      Set_Editable (Get_Entry (Network_Dialog.Tx_Kind_Combo), False);
      Set_Has_Frame (Get_Entry (Network_Dialog.Tx_Kind_Combo), True);
      Set_Max_Length (Get_Entry (Network_Dialog.Tx_Kind_Combo), 0);
      Set_Text
        (Get_Entry (Network_Dialog.Tx_Kind_Combo),
         -("Half_Duplex"));
      Set_Invisible_Char
        (Get_Entry (Network_Dialog.Tx_Kind_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Network_Dialog.Tx_Kind_Combo), True);
      for Kind in Mast.Transmission_Kind'Range loop
         String_List.Append (Tx_Kind_Combo_Items,
                             -(Mast.Transmission_Kind'Image(Kind)));
      end loop;
      Combo.Set_Popdown_Strings
        (Network_Dialog.Tx_Kind_Combo,
         Tx_Kind_Combo_Items);
      Free_String_List (Tx_Kind_Combo_Items);
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Tx_Kind_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Label43, -("Maximum Blocking"));
      Set_Alignment (Network_Dialog.Label43, 0.95, 0.5);
      Set_Padding (Network_Dialog.Label43, 0, 0);
      Set_Justify (Network_Dialog.Label43, Justify_Center);
      Set_Line_Wrap (Network_Dialog.Label43, False);
      Set_Selectable (Network_Dialog.Label43, False);
      Set_Use_Markup (Network_Dialog.Label43, False);
      Set_Use_Underline (Network_Dialog.Label43, False);
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Label43,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Net_Max_Blo_Entry);
      Set_Editable (Network_Dialog.Net_Max_Blo_Entry, True);
      Set_Max_Length (Network_Dialog.Net_Max_Blo_Entry, 0);
      Set_Text (Network_Dialog.Net_Max_Blo_Entry, -("0.00"));
      Set_Visibility (Network_Dialog.Net_Max_Blo_Entry, True);
      Set_Invisible_Char
        (Network_Dialog.Net_Max_Blo_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Net_Max_Blo_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Label353, -("Throughput"));
      Set_Alignment (Network_Dialog.Label353, 0.95, 0.5);
      Set_Padding (Network_Dialog.Label353, 0, 0);
      Set_Justify (Network_Dialog.Label353, Justify_Right);
      Set_Line_Wrap (Network_Dialog.Label353, False);
      Set_Selectable (Network_Dialog.Label353, False);
      Set_Use_Markup (Network_Dialog.Label353, False);
      Set_Use_Underline (Network_Dialog.Label353, False);
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Label353,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 5,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Throughput_Entry);
      Set_Editable (Network_Dialog.Throughput_Entry, True);
      Set_Max_Length (Network_Dialog.Throughput_Entry, 0);
      Set_Text (Network_Dialog.Throughput_Entry, -("0.00"));
      Set_Visibility (Network_Dialog.Throughput_Entry, True);
      Set_Invisible_Char
        (Network_Dialog.Throughput_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Network_Dialog.Table3,
         Network_Dialog.Throughput_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 5,
         Bottom_Attach => 6,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New_Vseparator (Network_Dialog.Vseparator2);
      Pack_Start
        (Network_Dialog.Hbox20,
         Network_Dialog.Vseparator2,
         Expand  => False,
         Fill    => True,
         Padding => 0);

      Gtk_New (Network_Dialog.Table5, 6, 2, False);
      Set_Border_Width (Network_Dialog.Table5, 15);
      Set_Row_Spacings (Network_Dialog.Table5, 5);
      Set_Col_Spacings (Network_Dialog.Table5, 5);
      Pack_Start
        (Network_Dialog.Hbox20,
         Network_Dialog.Table5,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Network_Dialog.Add_Driver_Button, -"Add Driver");
      Set_Relief (Network_Dialog.Add_Driver_Button, Relief_Normal);
      Attach
        (Network_Dialog.Table5,
         Network_Dialog.Add_Driver_Button,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Remove_Driver_Button, -"Remove Driver");
      Set_Relief (Network_Dialog.Remove_Driver_Button, Relief_Normal);
      Attach
        (Network_Dialog.Table5,
         Network_Dialog.Remove_Driver_Button,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Network_Dialog.New_Primary_Button,
         -"New Primary Scheduler...");
      Set_Relief (Network_Dialog.New_Primary_Button, Relief_Normal);
      Attach
        (Network_Dialog.Table5,
         Network_Dialog.New_Primary_Button,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 5,
         Bottom_Attach => 6,
         Xpadding      => 0,
         Ypadding      => 0);
      --     Button_Callback.Connect
      --       (Network_Dialog.New_Primary_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_New_Primary_Button_Clicked'Access), False);

      Network_Dialog_Callback.Object_Connect
        (Network_Dialog.New_Primary_Button,
         "clicked",
         Network_Dialog_Callback.To_Marshaller
            (On_New_Primary_Button_Clicked'Access),
         Network_Dialog);

      Gtk_New (Network_Dialog.Label637, -("List of Drivers :"));
      Set_Alignment (Network_Dialog.Label637, 0.5, 0.5);
      Set_Padding (Network_Dialog.Label637, 0, 0);
      Set_Justify (Network_Dialog.Label637, Justify_Left);
      Set_Line_Wrap (Network_Dialog.Label637, False);
      Set_Selectable (Network_Dialog.Label637, False);
      Set_Use_Markup (Network_Dialog.Label637, False);
      Set_Use_Underline (Network_Dialog.Label637, False);
      Attach
        (Network_Dialog.Table5,
         Network_Dialog.Label637,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Network_Dialog.Frame);
      Set_Label_Align (Network_Dialog.Frame, 0.5, 0.5);
      Set_Shadow_Type (Network_Dialog.Frame, Shadow_Etched_In);
      Attach
        (Network_Dialog.Table5,
         Network_Dialog.Frame,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Yoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      --------------

      Set_USize (Network_Dialog.Frame, 250, 250);

      Gtk_New
        (Network_Dialog.Tree_Store,
         (Server_Column => GType_String, Processor_Column => GType_String));

      --  Create the view: it shows 2 columns, that contain some text.
      --  In each column, a renderer is used to display the data graphically.

      Gtk_New (Network_Dialog.Tree_View, Network_Dialog.Tree_Store);

      Gtk_New (Network_Dialog.Text_Render);

      -- Server Column (1)
      Gtk_New (Network_Dialog.Col);
      Network_Dialog.Num :=
         Append_Column (Network_Dialog.Tree_View, Network_Dialog.Col);
      Set_Title (Network_Dialog.Col, "Server       ");
      Pack_Start (Network_Dialog.Col, Network_Dialog.Text_Render, True);
      Add_Attribute
        (Network_Dialog.Col,
         Network_Dialog.Text_Render,
         "text",
         Server_Column);

      Set_Min_Width (Network_Dialog.Col, 110);

      -- Deadline/Max_Jitter Column (2)
      Gtk_New (Network_Dialog.Col);
      Network_Dialog.Num :=
         Append_Column (Network_Dialog.Tree_View, Network_Dialog.Col);
      Set_Title (Network_Dialog.Col, "Processor    ");
      Pack_Start (Network_Dialog.Col, Network_Dialog.Text_Render, True);
      Add_Attribute
        (Network_Dialog.Col,
         Network_Dialog.Text_Render,
         "text",
         Processor_Column);

      --Set_Min_Width (Network_Dialog.Col, 100);

      --  Insert the view in the frame
      Gtk_New (Network_Dialog.Scrolled);
      Set_Policy (Network_Dialog.Scrolled, Policy_Always, Policy_Always);
      Add (Network_Dialog.Scrolled, Network_Dialog.Tree_View);

      Show_All (Network_Dialog.Scrolled);
      Add (Network_Dialog.Frame, Network_Dialog.Scrolled);

   end Initialize;

end Network_Dialog_Pkg;
