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
with Glib;                            use Glib;
with Gtk;                             use Gtk;
with Gdk.Types;                       use Gdk.Types;
with Gtk.Widget;                      use Gtk.Widget;
with Gtk.Enums;                       use Gtk.Enums;
with Gtkada.Handlers;                 use Gtkada.Handlers;
with Callbacks_Mast_Editor;           use Callbacks_Mast_Editor;
with Mast_Editor_Intl;                use Mast_Editor_Intl;
with Message_Tx_Dialog_Pkg.Callbacks; use Message_Tx_Dialog_Pkg.Callbacks;
with Mast;                            use Mast;

package body Message_Tx_Dialog_Pkg is

   procedure Gtk_New (Message_Tx_Dialog : out Message_Tx_Dialog_Access) is
   begin
      Message_Tx_Dialog := new Message_Tx_Dialog_Record;
      Message_Tx_Dialog_Pkg.Initialize (Message_Tx_Dialog);
   end Gtk_New;

   procedure Initialize
     (Message_Tx_Dialog : access Message_Tx_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Pixmaps_Dir                    : constant String := "pixmaps/";
      Op_Type_Combo_Items            : String_List.Glist;
      Overrid_Param_Type_Combo_Items : String_List.Glist;

   begin
      Gtk.Dialog.Initialize (Message_Tx_Dialog);
      Set_Title
        (Message_Tx_Dialog,
         -"Message Transmission Operation Parameters");
      Set_Position (Message_Tx_Dialog, Win_Pos_Center_Always);
      Set_Modal (Message_Tx_Dialog, False);

      Gtk_New_Hbox (Message_Tx_Dialog.Hbox102, True, 100);
      Pack_Start
        (Get_Action_Area (Message_Tx_Dialog),
         Message_Tx_Dialog.Hbox102);

      Gtk_New (Message_Tx_Dialog.Ok_Button, -"OK");
      Set_Relief (Message_Tx_Dialog.Ok_Button, Relief_Normal);
      Pack_Start
        (Message_Tx_Dialog.Hbox102,
         Message_Tx_Dialog.Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Message_Tx_Dialog.Cancel_Button, -"Cancel");
      Set_Relief (Message_Tx_Dialog.Cancel_Button, Relief_Normal);
      Pack_End
        (Message_Tx_Dialog.Hbox102,
         Message_Tx_Dialog.Cancel_Button,
         Expand  => True,
         Fill    => True,
         Padding => 0);
      --     Button_Callback.Connect
      --       (Message_Tx_Dialog.Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Cancel_Button_Clicked'Access), False);

      Dialog_Callback.Object_Connect
        (Message_Tx_Dialog.Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access),
         Message_Tx_Dialog);

      Gtk_New_Vbox (Message_Tx_Dialog.Vbox26, False, 0);
      Set_Border_Width (Message_Tx_Dialog.Vbox26, 5);
      Pack_Start
        (Get_Vbox (Message_Tx_Dialog),
         Message_Tx_Dialog.Vbox26,
         Expand  => False,
         Fill    => True,
         Padding => 0);

      Gtk_New (Message_Tx_Dialog.Table37, 7, 2, True);
      Set_Row_Spacings (Message_Tx_Dialog.Table37, 5);
      Set_Col_Spacings (Message_Tx_Dialog.Table37, 3);
      Pack_Start
        (Message_Tx_Dialog.Vbox26,
         Message_Tx_Dialog.Table37,
         Expand  => False,
         Fill    => False,
         Padding => 5);

      Gtk_New (Message_Tx_Dialog.Label380, -("Operation Type"));
      Set_Alignment (Message_Tx_Dialog.Label380, 0.95, 0.5);
      Set_Padding (Message_Tx_Dialog.Label380, 0, 0);
      Set_Justify (Message_Tx_Dialog.Label380, Justify_Center);
      Set_Line_Wrap (Message_Tx_Dialog.Label380, False);
      Set_Selectable (Message_Tx_Dialog.Label380, False);
      Set_Use_Markup (Message_Tx_Dialog.Label380, False);
      Set_Use_Underline (Message_Tx_Dialog.Label380, False);
      Attach
        (Message_Tx_Dialog.Table37,
         Message_Tx_Dialog.Label380,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Message_Tx_Dialog.Label381, -("Operation Name"));
      Set_Alignment (Message_Tx_Dialog.Label381, 0.95, 0.5);
      Set_Padding (Message_Tx_Dialog.Label381, 0, 0);
      Set_Justify (Message_Tx_Dialog.Label381, Justify_Center);
      Set_Line_Wrap (Message_Tx_Dialog.Label381, False);
      Set_Selectable (Message_Tx_Dialog.Label381, False);
      Set_Use_Markup (Message_Tx_Dialog.Label381, False);
      Set_Use_Underline (Message_Tx_Dialog.Label381, False);
      Attach
        (Message_Tx_Dialog.Table37,
         Message_Tx_Dialog.Label381,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Message_Tx_Dialog.Op_Type_Combo);
      Set_Value_In_List (Message_Tx_Dialog.Op_Type_Combo, False);
      Set_Use_Arrows (Message_Tx_Dialog.Op_Type_Combo, True);
      Set_Case_Sensitive (Message_Tx_Dialog.Op_Type_Combo, False);
      Set_Editable (Get_Entry (Message_Tx_Dialog.Op_Type_Combo), False);
      Set_Has_Frame (Get_Entry (Message_Tx_Dialog.Op_Type_Combo), True);
      Set_Max_Length (Get_Entry (Message_Tx_Dialog.Op_Type_Combo), 0);
      Set_Text
        (Get_Entry (Message_Tx_Dialog.Op_Type_Combo),
         -("Message Transmission"));
      Set_Invisible_Char
        (Get_Entry (Message_Tx_Dialog.Op_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Message_Tx_Dialog.Op_Type_Combo), True);
      String_List.Append (Op_Type_Combo_Items, -("Message Transmission"));
      Combo.Set_Popdown_Strings
        (Message_Tx_Dialog.Op_Type_Combo,
         Op_Type_Combo_Items);
      Free_String_List (Op_Type_Combo_Items);
      Attach
        (Message_Tx_Dialog.Table37,
         Message_Tx_Dialog.Op_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Message_Tx_Dialog.Op_Name_Entry);
      Set_Editable (Message_Tx_Dialog.Op_Name_Entry, True);
      Set_Max_Length (Message_Tx_Dialog.Op_Name_Entry, 0);
      Set_Text (Message_Tx_Dialog.Op_Name_Entry, -(""));
      Set_Visibility (Message_Tx_Dialog.Op_Name_Entry, True);
      Set_Invisible_Char
        (Message_Tx_Dialog.Op_Name_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Message_Tx_Dialog.Table37,
         Message_Tx_Dialog.Op_Name_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Message_Tx_Dialog.Label384,
         -("OVERRIDDEN SCHEDULING PARAMETERS:"));
      Set_Alignment (Message_Tx_Dialog.Label384, 0.5, 0.5);
      Set_Padding (Message_Tx_Dialog.Label384, 0, 5);
      Set_Justify (Message_Tx_Dialog.Label384, Justify_Center);
      Set_Line_Wrap (Message_Tx_Dialog.Label384, False);
      Set_Selectable (Message_Tx_Dialog.Label384, False);
      Set_Use_Markup (Message_Tx_Dialog.Label384, False);
      Set_Use_Underline (Message_Tx_Dialog.Label384, False);
      Attach
        (Message_Tx_Dialog.Table37,
         Message_Tx_Dialog.Label384,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 5,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Message_Tx_Dialog.Overrid_Param_Type_Combo);
      Set_Value_In_List (Message_Tx_Dialog.Overrid_Param_Type_Combo, False);
      Set_Use_Arrows (Message_Tx_Dialog.Overrid_Param_Type_Combo, True);
      Set_Case_Sensitive (Message_Tx_Dialog.Overrid_Param_Type_Combo, False);
      Set_Editable
        (Get_Entry (Message_Tx_Dialog.Overrid_Param_Type_Combo),
         False);
      Set_Has_Frame
        (Get_Entry (Message_Tx_Dialog.Overrid_Param_Type_Combo),
         True);
      Set_Max_Length
        (Get_Entry (Message_Tx_Dialog.Overrid_Param_Type_Combo),
         0);
      Set_Text
        (Get_Entry (Message_Tx_Dialog.Overrid_Param_Type_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Message_Tx_Dialog.Overrid_Param_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Message_Tx_Dialog.Overrid_Param_Type_Combo),
         True);
      String_List.Append (Overrid_Param_Type_Combo_Items, -("(NONE)"));
      String_List.Append
        (Overrid_Param_Type_Combo_Items,
         -("Fixed Priority"));
      String_List.Append
        (Overrid_Param_Type_Combo_Items,
         -("Permanent Fixed Priority"));
      Combo.Set_Popdown_Strings
        (Message_Tx_Dialog.Overrid_Param_Type_Combo,
         Overrid_Param_Type_Combo_Items);
      Free_String_List (Overrid_Param_Type_Combo_Items);
      Attach
        (Message_Tx_Dialog.Table37,
         Message_Tx_Dialog.Overrid_Param_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 6,
         Bottom_Attach => 7,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Message_Tx_Dialog.Label385,
         -("Overridden Sched Parameters Type"));
      Set_Alignment (Message_Tx_Dialog.Label385, 0.95, 0.5);
      Set_Padding (Message_Tx_Dialog.Label385, 0, 0);
      Set_Justify (Message_Tx_Dialog.Label385, Justify_Center);
      Set_Line_Wrap (Message_Tx_Dialog.Label385, False);
      Set_Selectable (Message_Tx_Dialog.Label385, False);
      Set_Use_Markup (Message_Tx_Dialog.Label385, False);
      Set_Use_Underline (Message_Tx_Dialog.Label385, False);
      Attach
        (Message_Tx_Dialog.Table37,
         Message_Tx_Dialog.Label385,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 6,
         Bottom_Attach => 7,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Message_Tx_Dialog.Label391, -("Max Message Size"));
      Set_Alignment (Message_Tx_Dialog.Label391, 0.95, 0.5);
      Set_Padding (Message_Tx_Dialog.Label391, 0, 0);
      Set_Justify (Message_Tx_Dialog.Label391, Justify_Center);
      Set_Line_Wrap (Message_Tx_Dialog.Label391, False);
      Set_Selectable (Message_Tx_Dialog.Label391, False);
      Set_Use_Markup (Message_Tx_Dialog.Label391, False);
      Set_Use_Underline (Message_Tx_Dialog.Label391, False);
      Attach
        (Message_Tx_Dialog.Table37,
         Message_Tx_Dialog.Label391,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Message_Tx_Dialog.Max_Message_Size_Entry);
      Set_Editable (Message_Tx_Dialog.Max_Message_Size_Entry, True);
      Set_Max_Length (Message_Tx_Dialog.Max_Message_Size_Entry, 0);
      Set_Text (Message_Tx_Dialog.Max_Message_Size_Entry, -(""));
      Set_Visibility (Message_Tx_Dialog.Max_Message_Size_Entry, True);
      Set_Invisible_Char
        (Message_Tx_Dialog.Max_Message_Size_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Message_Tx_Dialog.Table37,
         Message_Tx_Dialog.Max_Message_Size_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Message_Tx_Dialog.Label392, -("Avg Message Size"));
      Set_Alignment (Message_Tx_Dialog.Label392, 0.95, 0.5);
      Set_Padding (Message_Tx_Dialog.Label392, 0, 0);
      Set_Justify (Message_Tx_Dialog.Label392, Justify_Center);
      Set_Line_Wrap (Message_Tx_Dialog.Label392, False);
      Set_Selectable (Message_Tx_Dialog.Label392, False);
      Set_Use_Markup (Message_Tx_Dialog.Label392, False);
      Set_Use_Underline (Message_Tx_Dialog.Label392, False);
      Attach
        (Message_Tx_Dialog.Table37,
         Message_Tx_Dialog.Label392,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Message_Tx_Dialog.Avg_Message_Size_Entry);
      Set_Editable (Message_Tx_Dialog.Avg_Message_Size_Entry, True);
      Set_Max_Length (Message_Tx_Dialog.Avg_Message_Size_Entry, 0);
      Set_Text (Message_Tx_Dialog.Avg_Message_Size_Entry, -(""));
      Set_Visibility (Message_Tx_Dialog.Avg_Message_Size_Entry, True);
      Set_Invisible_Char
        (Message_Tx_Dialog.Avg_Message_Size_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Message_Tx_Dialog.Table37,
         Message_Tx_Dialog.Avg_Message_Size_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Message_Tx_Dialog.Label393, -("Min Message Size"));
      Set_Alignment (Message_Tx_Dialog.Label393, 0.95, 0.5);
      Set_Padding (Message_Tx_Dialog.Label393, 0, 0);
      Set_Justify (Message_Tx_Dialog.Label393, Justify_Center);
      Set_Line_Wrap (Message_Tx_Dialog.Label393, False);
      Set_Selectable (Message_Tx_Dialog.Label393, False);
      Set_Use_Markup (Message_Tx_Dialog.Label393, False);
      Set_Use_Underline (Message_Tx_Dialog.Label393, False);
      Attach
        (Message_Tx_Dialog.Table37,
         Message_Tx_Dialog.Label393,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Message_Tx_Dialog.Min_Message_Size_Entry);
      Set_Editable (Message_Tx_Dialog.Min_Message_Size_Entry, True);
      Set_Max_Length (Message_Tx_Dialog.Min_Message_Size_Entry, 0);
      Set_Text (Message_Tx_Dialog.Min_Message_Size_Entry, -("0.0"));
      Set_Visibility (Message_Tx_Dialog.Min_Message_Size_Entry, True);
      Set_Invisible_Char
        (Message_Tx_Dialog.Min_Message_Size_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Message_Tx_Dialog.Table37,
         Message_Tx_Dialog.Min_Message_Size_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Message_Tx_Dialog.Overrid_Prior_Table, 1, 2, True);
      Set_Row_Spacings (Message_Tx_Dialog.Overrid_Prior_Table, 5);
      Set_Col_Spacings (Message_Tx_Dialog.Overrid_Prior_Table, 3);
      Pack_Start
        (Message_Tx_Dialog.Vbox26,
         Message_Tx_Dialog.Overrid_Prior_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Message_Tx_Dialog.Label394, -("Overridden Priority"));
      Set_Alignment (Message_Tx_Dialog.Label394, 0.95, 0.5);
      Set_Padding (Message_Tx_Dialog.Label394, 0, 0);
      Set_Justify (Message_Tx_Dialog.Label394, Justify_Center);
      Set_Line_Wrap (Message_Tx_Dialog.Label394, False);
      Set_Selectable (Message_Tx_Dialog.Label394, False);
      Set_Use_Markup (Message_Tx_Dialog.Label394, False);
      Set_Use_Underline (Message_Tx_Dialog.Label394, False);
      Attach
        (Message_Tx_Dialog.Overrid_Prior_Table,
         Message_Tx_Dialog.Label394,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Message_Tx_Dialog.Overrid_Prior_Entry);
      Set_Editable (Message_Tx_Dialog.Overrid_Prior_Entry, True);
      Set_Max_Length (Message_Tx_Dialog.Overrid_Prior_Entry, 0);
      Set_Text
        (Message_Tx_Dialog.Overrid_Prior_Entry,
         Priority'Image (Priority'First));
      Set_Visibility (Message_Tx_Dialog.Overrid_Prior_Entry, True);
      Set_Invisible_Char
        (Message_Tx_Dialog.Overrid_Prior_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Message_Tx_Dialog.Overrid_Prior_Table,
         Message_Tx_Dialog.Overrid_Prior_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      --     Entry_Callback.Connect
      --       (Get_Entry (Message_Tx_Dialog.Overrid_Param_Type_Combo),
      --"changed",
      --        Entry_Callback.To_Marshaller
      --(On_Overrid_Param_Type_Changed'Access));

      Message_Tx_Dialog_Callback.Object_Connect
        (Get_Entry (Message_Tx_Dialog.Overrid_Param_Type_Combo),
         "changed",
         Message_Tx_Dialog_Callback.To_Marshaller
            (On_Overrid_Param_Type_Changed'Access),
         Message_Tx_Dialog);

   end Initialize;

end Message_Tx_Dialog_Pkg;
