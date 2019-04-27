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
with Glib;                     use Glib;
with Gtk;                      use Gtk;
with Gdk.Types;                use Gdk.Types;
with Gtk.Widget;               use Gtk.Widget;
with Gtk.Enums;                use Gtk.Enums;
with Gtkada.Handlers;          use Gtkada.Handlers;
with Callbacks_Mast_Editor;    use Callbacks_Mast_Editor;
with Mast_Editor_Intl;         use Mast_Editor_Intl;
with Seh_Dialog_Pkg.Callbacks; use Seh_Dialog_Pkg.Callbacks;
with Mast.IO;                  use Mast.IO;
with Mast.Scheduling_Servers;  use Mast.Scheduling_Servers;
with Mast.Operations;          use Mast.Operations;
with Var_Strings;              use Var_Strings;
with Editor_Actions;           use Editor_Actions;

package body Seh_Dialog_Pkg is

   procedure Gtk_New (Seh_Dialog : out Seh_Dialog_Access) is
   begin
      Seh_Dialog := new Seh_Dialog_Record;
      Seh_Dialog_Pkg.Initialize (Seh_Dialog);
   end Gtk_New;

   procedure Initialize (Seh_Dialog : access Seh_Dialog_Record'Class) is
      pragma Suppress (All_Checks);
      Seh_Type_Combo_Items : String_List.Glist;
      Op_Combo_Items       : String_List.Glist;
      Ser_Combo_Items      : String_List.Glist;
      --Ref_Event_Combo_Items : String_List.Glist;

      Ser_Ref   : Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Ser_Index : Mast.Scheduling_Servers.Lists.Index;
      Ser_Name  : Var_Strings.Var_String;

      Op_Ref   : Mast.Operations.Operation_Ref;
      Op_Index : Mast.Operations.Lists.Index;
      Op_Name  : Var_Strings.Var_String;

   begin
      -- We search System Servers and show them in Server_Combo
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
         String_List.Append (Ser_Combo_Items, Name_Image (Ser_Name));
      end loop;

      -- We search System Operations and show them in Op_Combo
      Mast.Operations.Lists.Rewind (The_System.Operations, Op_Index);
      for I in 1 .. Mast.Operations.Lists.Size (The_System.Operations) loop
         Mast.Operations.Lists.Get_Next_Item
           (Op_Ref,
            The_System.Operations,
            Op_Index);
         Op_Name := Mast.Operations.Name (Op_Ref);
         String_List.Append (Op_Combo_Items, Name_Image (Op_Name));
      end loop;

      Gtk.Dialog.Initialize (Seh_Dialog);
      Set_Title (Seh_Dialog, -"Simple Event Handler Parameters");
      Set_Policy (Seh_Dialog, False, False, False);
      Set_Position (Seh_Dialog, Win_Pos_Center);
      Set_Modal (Seh_Dialog, False);

      Gtk_New_Hbox (Seh_Dialog.Hbox71, True, 100);
      Pack_Start (Get_Action_Area (Seh_Dialog), Seh_Dialog.Hbox71);

      Gtk_New (Seh_Dialog.Ok_Button, -"OK");
      Set_Relief (Seh_Dialog.Ok_Button, Relief_Normal);
      Pack_Start
        (Seh_Dialog.Hbox71,
         Seh_Dialog.Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 40);

      Gtk_New (Seh_Dialog.Cancel_Button, -"Cancel");
      Set_Relief (Seh_Dialog.Cancel_Button, Relief_Normal);
      Pack_End
        (Seh_Dialog.Hbox71,
         Seh_Dialog.Cancel_Button,
         Expand  => True,
         Fill    => True,
         Padding => 40);
      --     Button_Callback.Connect
      --       (Seh_Dialog.Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Cancel_Button_Clicked'Access), False);

      Dialog_Callback.Object_Connect
        (Seh_Dialog.Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access),
         Seh_Dialog);

      Gtk_New_Vbox (Seh_Dialog.Vbox17, False, 0);
      Pack_Start
        (Get_Vbox (Seh_Dialog),
         Seh_Dialog.Vbox17,
         Expand  => False,
         Fill    => True,
         Padding => 0);

      Gtk_New (Seh_Dialog.Table1, 1, 2, True);
      Set_Border_Width (Seh_Dialog.Table1, 5);
      Set_Row_Spacings (Seh_Dialog.Table1, 3);
      Set_Col_Spacings (Seh_Dialog.Table1, 3);
      Pack_Start
        (Seh_Dialog.Vbox17,
         Seh_Dialog.Table1,
         Expand  => False,
         Fill    => False,
         Padding => 5);

      Gtk_New (Seh_Dialog.Label195, -("Simple Event Handler Type"));
      Set_Alignment (Seh_Dialog.Label195, 0.95, 0.5);
      Set_Padding (Seh_Dialog.Label195, 0, 0);
      Set_Justify (Seh_Dialog.Label195, Justify_Center);
      Set_Line_Wrap (Seh_Dialog.Label195, False);
      Set_Selectable (Seh_Dialog.Label195, False);
      Set_Use_Markup (Seh_Dialog.Label195, False);
      Set_Use_Underline (Seh_Dialog.Label195, False);
      Attach
        (Seh_Dialog.Table1,
         Seh_Dialog.Label195,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Seh_Dialog.Seh_Type_Combo);
      Set_Value_In_List (Seh_Dialog.Seh_Type_Combo, False);
      Set_Use_Arrows (Seh_Dialog.Seh_Type_Combo, True);
      Set_Case_Sensitive (Seh_Dialog.Seh_Type_Combo, False);
      Set_Editable (Get_Entry (Seh_Dialog.Seh_Type_Combo), False);
      Set_Max_Length (Get_Entry (Seh_Dialog.Seh_Type_Combo), 0);
      Set_Text (Get_Entry (Seh_Dialog.Seh_Type_Combo), -("Activity"));
      Set_Invisible_Char
        (Get_Entry (Seh_Dialog.Seh_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Seh_Dialog.Seh_Type_Combo), True);
      String_List.Append (Seh_Type_Combo_Items, -("Activity"));
      String_List.Append
        (Seh_Type_Combo_Items,
         -("System Timed Activity"));
      String_List.Append (Seh_Type_Combo_Items, -("Rate Divisor"));
      String_List.Append (Seh_Type_Combo_Items, -("Delay"));
      String_List.Append (Seh_Type_Combo_Items, -("Offset"));
      Combo.Set_Popdown_Strings
        (Seh_Dialog.Seh_Type_Combo,
         Seh_Type_Combo_Items);
      Free_String_List (Seh_Type_Combo_Items);
      Attach
        (Seh_Dialog.Table1,
         Seh_Dialog.Seh_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Seh_Dialog.Activity_Table, 2, 2, True);
      Set_Border_Width (Seh_Dialog.Activity_Table, 5);
      Set_Row_Spacings (Seh_Dialog.Activity_Table, 3);
      Set_Col_Spacings (Seh_Dialog.Activity_Table, 3);
      Pack_Start
        (Seh_Dialog.Vbox17,
         Seh_Dialog.Activity_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Seh_Dialog.Label196, -("Activity Operation"));
      Set_Alignment (Seh_Dialog.Label196, 0.95, 0.5);
      Set_Padding (Seh_Dialog.Label196, 0, 0);
      Set_Justify (Seh_Dialog.Label196, Justify_Center);
      Set_Line_Wrap (Seh_Dialog.Label196, False);
      Set_Selectable (Seh_Dialog.Label196, False);
      Set_Use_Markup (Seh_Dialog.Label196, False);
      Set_Use_Underline (Seh_Dialog.Label196, False);
      Attach
        (Seh_Dialog.Activity_Table,
         Seh_Dialog.Label196,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Seh_Dialog.Op_Combo);
      Set_Value_In_List (Seh_Dialog.Op_Combo, False);
      Set_Use_Arrows (Seh_Dialog.Op_Combo, True);
      Set_Case_Sensitive (Seh_Dialog.Op_Combo, False);
      Set_Editable (Get_Entry (Seh_Dialog.Op_Combo), False);
      Set_Max_Length (Get_Entry (Seh_Dialog.Op_Combo), 0);
      Set_Text (Get_Entry (Seh_Dialog.Op_Combo), -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Seh_Dialog.Op_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Seh_Dialog.Op_Combo), True);
      String_List.Append (Op_Combo_Items, -("(NONE)"));
      Combo.Set_Popdown_Strings (Seh_Dialog.Op_Combo, Op_Combo_Items);
      Free_String_List (Op_Combo_Items);
      Attach
        (Seh_Dialog.Activity_Table,
         Seh_Dialog.Op_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Seh_Dialog.Ser_Combo);
      Set_Value_In_List (Seh_Dialog.Ser_Combo, False);
      Set_Use_Arrows (Seh_Dialog.Ser_Combo, True);
      Set_Case_Sensitive (Seh_Dialog.Ser_Combo, False);
      Set_Editable (Get_Entry (Seh_Dialog.Ser_Combo), False);
      Set_Max_Length (Get_Entry (Seh_Dialog.Ser_Combo), 0);
      Set_Text (Get_Entry (Seh_Dialog.Ser_Combo), -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Seh_Dialog.Ser_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Seh_Dialog.Ser_Combo), True);
      String_List.Append (Ser_Combo_Items, -("(NONE)"));
      Combo.Set_Popdown_Strings (Seh_Dialog.Ser_Combo, Ser_Combo_Items);
      Free_String_List (Ser_Combo_Items);
      Attach
        (Seh_Dialog.Activity_Table,
         Seh_Dialog.Ser_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Seh_Dialog.Label200, -("Activity Server"));
      Set_Alignment (Seh_Dialog.Label200, 0.95, 0.5);
      Set_Padding (Seh_Dialog.Label200, 0, 0);
      Set_Justify (Seh_Dialog.Label200, Justify_Center);
      Set_Line_Wrap (Seh_Dialog.Label200, False);
      Set_Selectable (Seh_Dialog.Label200, False);
      Set_Use_Markup (Seh_Dialog.Label200, False);
      Set_Use_Underline (Seh_Dialog.Label200, False);
      Attach
        (Seh_Dialog.Activity_Table,
         Seh_Dialog.Label200,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Seh_Dialog.Rate_Table, 1, 2, True);
      Set_Border_Width (Seh_Dialog.Rate_Table, 5);
      Set_Row_Spacings (Seh_Dialog.Rate_Table, 3);
      Set_Col_Spacings (Seh_Dialog.Rate_Table, 3);
      Pack_Start
        (Seh_Dialog.Vbox17,
         Seh_Dialog.Rate_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Seh_Dialog.Label246, -("Rate Factor"));
      Set_Alignment (Seh_Dialog.Label246, 0.95, 0.5);
      Set_Padding (Seh_Dialog.Label246, 0, 0);
      Set_Justify (Seh_Dialog.Label246, Justify_Center);
      Set_Line_Wrap (Seh_Dialog.Label246, False);
      Set_Selectable (Seh_Dialog.Label246, False);
      Set_Use_Markup (Seh_Dialog.Label246, False);
      Set_Use_Underline (Seh_Dialog.Label246, False);
      Attach
        (Seh_Dialog.Rate_Table,
         Seh_Dialog.Label246,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Seh_Dialog.Rate_Entry);
      Set_Editable (Seh_Dialog.Rate_Entry, True);
      Set_Max_Length (Seh_Dialog.Rate_Entry, 0);
      Set_Text (Seh_Dialog.Rate_Entry, -("1"));
      Set_Visibility (Seh_Dialog.Rate_Entry, True);
      Set_Invisible_Char (Seh_Dialog.Rate_Entry, UTF8_Get_Char ("*"));
      Attach
        (Seh_Dialog.Rate_Table,
         Seh_Dialog.Rate_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Seh_Dialog.Delay_Table, 2, 2, True);
      Set_Border_Width (Seh_Dialog.Delay_Table, 5);
      Set_Row_Spacings (Seh_Dialog.Delay_Table, 3);
      Set_Col_Spacings (Seh_Dialog.Delay_Table, 3);
      Pack_Start
        (Seh_Dialog.Vbox17,
         Seh_Dialog.Delay_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Seh_Dialog.Label248, -("Delay Max Interval"));
      Set_Alignment (Seh_Dialog.Label248, 0.95, 0.5);
      Set_Padding (Seh_Dialog.Label248, 0, 0);
      Set_Justify (Seh_Dialog.Label248, Justify_Center);
      Set_Line_Wrap (Seh_Dialog.Label248, False);
      Set_Selectable (Seh_Dialog.Label248, False);
      Set_Use_Markup (Seh_Dialog.Label248, False);
      Set_Use_Underline (Seh_Dialog.Label248, False);
      Attach
        (Seh_Dialog.Delay_Table,
         Seh_Dialog.Label248,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Seh_Dialog.Label249, -("Delay Min Interval"));
      Set_Alignment (Seh_Dialog.Label249, 0.95, 0.5);
      Set_Padding (Seh_Dialog.Label249, 0, 0);
      Set_Justify (Seh_Dialog.Label249, Justify_Center);
      Set_Line_Wrap (Seh_Dialog.Label249, False);
      Set_Selectable (Seh_Dialog.Label249, False);
      Set_Use_Markup (Seh_Dialog.Label249, False);
      Set_Use_Underline (Seh_Dialog.Label249, False);
      Attach
        (Seh_Dialog.Delay_Table,
         Seh_Dialog.Label249,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Seh_Dialog.Delay_Max_Entry);
      Set_Editable (Seh_Dialog.Delay_Max_Entry, True);
      Set_Max_Length (Seh_Dialog.Delay_Max_Entry, 0);
      Set_Text (Seh_Dialog.Delay_Max_Entry, -("0.0"));
      Set_Visibility (Seh_Dialog.Delay_Max_Entry, True);
      Set_Invisible_Char (Seh_Dialog.Delay_Max_Entry, UTF8_Get_Char ("*"));
      Attach
        (Seh_Dialog.Delay_Table,
         Seh_Dialog.Delay_Max_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Seh_Dialog.Delay_Min_Entry);
      Set_Editable (Seh_Dialog.Delay_Min_Entry, True);
      Set_Max_Length (Seh_Dialog.Delay_Min_Entry, 0);
      Set_Text (Seh_Dialog.Delay_Min_Entry, -("0.0"));
      Set_Visibility (Seh_Dialog.Delay_Min_Entry, True);
      Set_Invisible_Char (Seh_Dialog.Delay_Min_Entry, UTF8_Get_Char ("*"));
      Attach
        (Seh_Dialog.Delay_Table,
         Seh_Dialog.Delay_Min_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Seh_Dialog.Ref_Table, 1, 2, True);
      Set_Border_Width (Seh_Dialog.Ref_Table, 5);
      Set_Row_Spacings (Seh_Dialog.Ref_Table, 3);
      Set_Col_Spacings (Seh_Dialog.Ref_Table, 3);
      Pack_Start
        (Seh_Dialog.Vbox17,
         Seh_Dialog.Ref_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Seh_Dialog.Label250, -("Referenced Event"));
      Set_Alignment (Seh_Dialog.Label250, 0.95, 0.5);
      Set_Padding (Seh_Dialog.Label250, 0, 0);
      Set_Justify (Seh_Dialog.Label250, Justify_Center);
      Set_Line_Wrap (Seh_Dialog.Label250, False);
      Set_Selectable (Seh_Dialog.Label250, False);
      Set_Use_Markup (Seh_Dialog.Label250, False);
      Set_Use_Underline (Seh_Dialog.Label250, False);
      Attach
        (Seh_Dialog.Ref_Table,
         Seh_Dialog.Label250,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Seh_Dialog.Ref_Event_Combo);
      Set_Value_In_List (Seh_Dialog.Ref_Event_Combo, False);
      Set_Use_Arrows (Seh_Dialog.Ref_Event_Combo, True);
      Set_Case_Sensitive (Seh_Dialog.Ref_Event_Combo, False);
      Set_Editable (Get_Entry (Seh_Dialog.Ref_Event_Combo), False);
      Set_Max_Length (Get_Entry (Seh_Dialog.Ref_Event_Combo), 0);
      Set_Text (Get_Entry (Seh_Dialog.Ref_Event_Combo), -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Seh_Dialog.Ref_Event_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Seh_Dialog.Ref_Event_Combo), True);
      String_List.Append (Ref_Event_Combo_Items, -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Seh_Dialog.Ref_Event_Combo,
         Ref_Event_Combo_Items);
      Free_String_List (Ref_Event_Combo_Items);
      Attach
        (Seh_Dialog.Ref_Table,
         Seh_Dialog.Ref_Event_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      --     Entry_Callback.Connect
      --       (Get_Entry (Seh_Dialog.Seh_Type_Combo), "changed",
      --        Entry_Callback.To_Marshaller (On_Seh_Type_Changed'Access));

      Seh_Dialog_Callback.Object_Connect
        (Get_Entry (Seh_Dialog.Seh_Type_Combo),
         "changed",
         Seh_Dialog_Callback.To_Marshaller (On_Seh_Type_Changed'Access),
         Seh_Dialog);

   end Initialize;

end Seh_Dialog_Pkg;
