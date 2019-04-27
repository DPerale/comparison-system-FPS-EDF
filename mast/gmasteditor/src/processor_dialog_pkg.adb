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
with Glib;                           use Glib;
with Gtk;                            use Gtk;
with Gdk.Types;                      use Gdk.Types;
with Gtk.Widget;                     use Gtk.Widget;
with Gtk.Enums;                      use Gtk.Enums;
with Gtkada.Handlers;                use Gtkada.Handlers;
with Callbacks_Mast_Editor;          use Callbacks_Mast_Editor;
with Mast_Editor_Intl;               use Mast_Editor_Intl;
with Processor_Dialog_Pkg.Callbacks; use Processor_Dialog_Pkg.Callbacks;
with Mast;                           use Mast;
with Mast.IO;                        use Mast.IO;

package body Processor_Dialog_Pkg is

   procedure Gtk_New (Processor_Dialog : out Processor_Dialog_Access) is
   begin
      Processor_Dialog := new Processor_Dialog_Record;
      Processor_Dialog_Pkg.Initialize (Processor_Dialog);
   end Gtk_New;

   procedure Initialize
     (Processor_Dialog : access Processor_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Proc_Type_Combo_Items         : String_List.Glist;
      System_Timer_Type_Combo_Items : String_List.Glist;

   begin
      Gtk.Dialog.Initialize (Processor_Dialog);
      Set_Title (Processor_Dialog, -"Processor Parameters");
      Set_Position (Processor_Dialog, Win_Pos_Center);
      Set_Modal (Processor_Dialog, False);

      Gtk_New_Hbox (Processor_Dialog.Hbox23, True, 0);
      Pack_Start
        (Get_Action_Area (Processor_Dialog),
         Processor_Dialog.Hbox23);

      Gtk_New (Processor_Dialog.Proc_Dialog_Ok_Button, -"OK");
      Set_Relief (Processor_Dialog.Proc_Dialog_Ok_Button, Relief_Normal);
      Pack_Start
        (Processor_Dialog.Hbox23,
         Processor_Dialog.Proc_Dialog_Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 130);

      Gtk_New (Processor_Dialog.Proc_Dialog_Cancel_Button, -"Cancel");
      Set_Relief (Processor_Dialog.Proc_Dialog_Cancel_Button, Relief_Normal);
      Pack_End
        (Processor_Dialog.Hbox23,
         Processor_Dialog.Proc_Dialog_Cancel_Button,
         Expand  => True,
         Fill    => True,
         Padding => 130);
      --     Button_Callback.Connect
      --       (Processor_Dialog.Proc_Dialog_Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Proc_Dialog_Cancel_Button_Clicked'Access), False);

      Dialog_Callback.Object_Connect
        (Processor_Dialog.Proc_Dialog_Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller
            (On_Proc_Dialog_Cancel_Button_Clicked'Access),
         Processor_Dialog);

      Gtk_New_Hbox (Processor_Dialog.Hbox18, False, 0);
      Pack_Start
        (Get_Vbox (Processor_Dialog),
         Processor_Dialog.Hbox18,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Processor_Dialog.Table1, 8, 2, False);
      Set_Border_Width (Processor_Dialog.Table1, 10);
      Set_Row_Spacings (Processor_Dialog.Table1, 5);
      Set_Col_Spacings (Processor_Dialog.Table1, 5);
      Pack_Start
        (Processor_Dialog.Hbox18,
         Processor_Dialog.Table1,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Processor_Dialog.Label26, -("Processor Name"));
      Set_Alignment (Processor_Dialog.Label26, 0.95, 0.5);
      Set_Padding (Processor_Dialog.Label26, 0, 0);
      Set_Justify (Processor_Dialog.Label26, Justify_Center);
      Set_Line_Wrap (Processor_Dialog.Label26, False);
      Set_Selectable (Processor_Dialog.Label26, False);
      Set_Use_Markup (Processor_Dialog.Label26, False);
      Set_Use_Underline (Processor_Dialog.Label26, False);
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Label26,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Label68, -("Processor Type"));
      Set_Alignment (Processor_Dialog.Label68, 0.95, 0.5);
      Set_Padding (Processor_Dialog.Label68, 0, 0);
      Set_Justify (Processor_Dialog.Label68, Justify_Center);
      Set_Line_Wrap (Processor_Dialog.Label68, False);
      Set_Selectable (Processor_Dialog.Label68, False);
      Set_Use_Markup (Processor_Dialog.Label68, False);
      Set_Use_Underline (Processor_Dialog.Label68, False);
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Label68,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Label29, -("Speed Factor"));
      Set_Alignment (Processor_Dialog.Label29, 0.95, 0.5);
      Set_Padding (Processor_Dialog.Label29, 0, 0);
      Set_Justify (Processor_Dialog.Label29, Justify_Center);
      Set_Line_Wrap (Processor_Dialog.Label29, False);
      Set_Selectable (Processor_Dialog.Label29, False);
      Set_Use_Markup (Processor_Dialog.Label29, False);
      Set_Use_Underline (Processor_Dialog.Label29, False);
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Label29,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Label30, -("Maximum Interrupt Priority"));
      Set_Alignment (Processor_Dialog.Label30, 0.95, 0.5);
      Set_Padding (Processor_Dialog.Label30, 0, 0);
      Set_Justify (Processor_Dialog.Label30, Justify_Center);
      Set_Line_Wrap (Processor_Dialog.Label30, False);
      Set_Selectable (Processor_Dialog.Label30, False);
      Set_Use_Markup (Processor_Dialog.Label30, False);
      Set_Use_Underline (Processor_Dialog.Label30, False);
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Label30,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Label31, -("Minimum Interrupt Priority"));
      Set_Alignment (Processor_Dialog.Label31, 0.95, 0.5);
      Set_Padding (Processor_Dialog.Label31, 0, 0);
      Set_Justify (Processor_Dialog.Label31, Justify_Center);
      Set_Line_Wrap (Processor_Dialog.Label31, False);
      Set_Selectable (Processor_Dialog.Label31, False);
      Set_Use_Markup (Processor_Dialog.Label31, False);
      Set_Use_Underline (Processor_Dialog.Label31, False);
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Label31,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Label35, -("Worst ISR Switch"));
      Set_Alignment (Processor_Dialog.Label35, 0.95, 0.5);
      Set_Padding (Processor_Dialog.Label35, 0, 0);
      Set_Justify (Processor_Dialog.Label35, Justify_Center);
      Set_Line_Wrap (Processor_Dialog.Label35, False);
      Set_Selectable (Processor_Dialog.Label35, False);
      Set_Use_Markup (Processor_Dialog.Label35, False);
      Set_Use_Underline (Processor_Dialog.Label35, False);
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Label35,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 5,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Label36, -("Average ISR Switch"));
      Set_Alignment (Processor_Dialog.Label36, 0.95, 0.5);
      Set_Padding (Processor_Dialog.Label36, 0, 0);
      Set_Justify (Processor_Dialog.Label36, Justify_Center);
      Set_Line_Wrap (Processor_Dialog.Label36, False);
      Set_Selectable (Processor_Dialog.Label36, False);
      Set_Use_Markup (Processor_Dialog.Label36, False);
      Set_Use_Underline (Processor_Dialog.Label36, False);
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Label36,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 6,
         Bottom_Attach => 7,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Label37, -("Best ISR Switch"));
      Set_Alignment (Processor_Dialog.Label37, 0.95, 0.5);
      Set_Padding (Processor_Dialog.Label37, 0, 0);
      Set_Justify (Processor_Dialog.Label37, Justify_Center);
      Set_Line_Wrap (Processor_Dialog.Label37, False);
      Set_Selectable (Processor_Dialog.Label37, False);
      Set_Use_Markup (Processor_Dialog.Label37, False);
      Set_Use_Underline (Processor_Dialog.Label37, False);
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Label37,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 7,
         Bottom_Attach => 8,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Proc_Speed_Entry);
      Set_Editable (Processor_Dialog.Proc_Speed_Entry, True);
      Set_Max_Length (Processor_Dialog.Proc_Speed_Entry, 0);
      Set_Text (Processor_Dialog.Proc_Speed_Entry, -("1.00"));
      Set_Visibility (Processor_Dialog.Proc_Speed_Entry, True);
      Set_Invisible_Char
        (Processor_Dialog.Proc_Speed_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Proc_Speed_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Proc_Name_Entry);
      Set_Editable (Processor_Dialog.Proc_Name_Entry, True);
      Set_Max_Length (Processor_Dialog.Proc_Name_Entry, 0);
      Set_Text (Processor_Dialog.Proc_Name_Entry, -(""));
      Set_Visibility (Processor_Dialog.Proc_Name_Entry, True);
      Set_Invisible_Char
        (Processor_Dialog.Proc_Name_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Proc_Name_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Proc_Max_Int_Pri_Entry);
      Set_Editable (Processor_Dialog.Proc_Max_Int_Pri_Entry, True);
      Set_Max_Length (Processor_Dialog.Proc_Max_Int_Pri_Entry, 0);
      Set_Text
        (Processor_Dialog.Proc_Max_Int_Pri_Entry,
         Priority'Image (Priority'Last));
      Set_Visibility (Processor_Dialog.Proc_Max_Int_Pri_Entry, True);
      Set_Invisible_Char
        (Processor_Dialog.Proc_Max_Int_Pri_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Proc_Max_Int_Pri_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Proc_Min_Int_Pri_Entry);
      Set_Editable (Processor_Dialog.Proc_Min_Int_Pri_Entry, True);
      Set_Max_Length (Processor_Dialog.Proc_Min_Int_Pri_Entry, 0);
      Set_Text
        (Processor_Dialog.Proc_Min_Int_Pri_Entry,
         Priority'Image (Priority'First));
      Set_Visibility (Processor_Dialog.Proc_Min_Int_Pri_Entry, True);
      Set_Invisible_Char
        (Processor_Dialog.Proc_Min_Int_Pri_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Proc_Min_Int_Pri_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Proc_Wor_Isr_Swi_Entry);
      Set_Editable (Processor_Dialog.Proc_Wor_Isr_Swi_Entry, True);
      Set_Max_Length (Processor_Dialog.Proc_Wor_Isr_Swi_Entry, 0);
      Set_Text (Processor_Dialog.Proc_Wor_Isr_Swi_Entry, -("0.00"));
      Set_Visibility (Processor_Dialog.Proc_Wor_Isr_Swi_Entry, True);
      Set_Invisible_Char
        (Processor_Dialog.Proc_Wor_Isr_Swi_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Proc_Wor_Isr_Swi_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 5,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Proc_Avg_Isr_Swi_Entry);
      Set_Editable (Processor_Dialog.Proc_Avg_Isr_Swi_Entry, True);
      Set_Max_Length (Processor_Dialog.Proc_Avg_Isr_Swi_Entry, 0);
      Set_Text (Processor_Dialog.Proc_Avg_Isr_Swi_Entry, -("0.00"));
      Set_Visibility (Processor_Dialog.Proc_Avg_Isr_Swi_Entry, True);
      Set_Invisible_Char
        (Processor_Dialog.Proc_Avg_Isr_Swi_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Proc_Avg_Isr_Swi_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 6,
         Bottom_Attach => 7,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Proc_Bes_Isr_Swi_Entry);
      Set_Editable (Processor_Dialog.Proc_Bes_Isr_Swi_Entry, True);
      Set_Max_Length (Processor_Dialog.Proc_Bes_Isr_Swi_Entry, 0);
      Set_Text (Processor_Dialog.Proc_Bes_Isr_Swi_Entry, -("0.00"));
      Set_Visibility (Processor_Dialog.Proc_Bes_Isr_Swi_Entry, True);
      Set_Invisible_Char
        (Processor_Dialog.Proc_Bes_Isr_Swi_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Proc_Bes_Isr_Swi_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 7,
         Bottom_Attach => 8,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Proc_Type_Combo);
      Set_Value_In_List (Processor_Dialog.Proc_Type_Combo, False);
      Set_Use_Arrows (Processor_Dialog.Proc_Type_Combo, True);
      Set_Case_Sensitive (Processor_Dialog.Proc_Type_Combo, False);
      Set_Editable (Get_Entry (Processor_Dialog.Proc_Type_Combo), False);
      Set_Max_Length (Get_Entry (Processor_Dialog.Proc_Type_Combo), 0);
      Set_Text
        (Get_Entry (Processor_Dialog.Proc_Type_Combo),
         -("Regular"));
      Set_Invisible_Char
        (Get_Entry (Processor_Dialog.Proc_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Processor_Dialog.Proc_Type_Combo), True);
      String_List.Append (Proc_Type_Combo_Items, -("Regular"));
      Combo.Set_Popdown_Strings
        (Processor_Dialog.Proc_Type_Combo,
         Proc_Type_Combo_Items);
      Free_String_List (Proc_Type_Combo_Items);
      Attach
        (Processor_Dialog.Table1,
         Processor_Dialog.Proc_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New_Vseparator (Processor_Dialog.Vseparator1);
      Pack_Start
        (Processor_Dialog.Hbox18,
         Processor_Dialog.Vseparator1,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New_Vbox (Processor_Dialog.Vbox3, False, 5);
      Set_Border_Width (Processor_Dialog.Vbox3, 10);
      -----------
      Set_USize (Processor_Dialog.Vbox3, 265, -1);
      -----------
      Pack_Start
        (Processor_Dialog.Hbox18,
         Processor_Dialog.Vbox3,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Processor_Dialog.Table2, 2, 2, True);
      Set_Row_Spacings (Processor_Dialog.Table2, 5);
      Set_Col_Spacings (Processor_Dialog.Table2, 5);
      Pack_Start
        (Processor_Dialog.Vbox3,
         Processor_Dialog.Table2,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Processor_Dialog.Label55, -("SYSTEM TIMER"));
      Set_Alignment (Processor_Dialog.Label55, 0.5, 0.5);
      Set_Padding (Processor_Dialog.Label55, 0, 0);
      Set_Justify (Processor_Dialog.Label55, Justify_Center);
      Set_Line_Wrap (Processor_Dialog.Label55, False);
      Set_Selectable (Processor_Dialog.Label55, False);
      Set_Use_Markup (Processor_Dialog.Label55, False);
      Set_Use_Underline (Processor_Dialog.Label55, False);
      Attach
        (Processor_Dialog.Table2,
         Processor_Dialog.Label55,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Label59, -("Type"));
      Set_Alignment (Processor_Dialog.Label59, 0.95, 0.5);
      Set_Padding (Processor_Dialog.Label59, 0, 0);
      Set_Justify (Processor_Dialog.Label59, Justify_Center);
      Set_Line_Wrap (Processor_Dialog.Label59, False);
      Set_Selectable (Processor_Dialog.Label59, False);
      Set_Use_Markup (Processor_Dialog.Label59, False);
      Set_Use_Underline (Processor_Dialog.Label59, False);
      Attach
        (Processor_Dialog.Table2,
         Processor_Dialog.Label59,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.System_Timer_Type_Combo);
      Set_Value_In_List (Processor_Dialog.System_Timer_Type_Combo, False);
      Set_Use_Arrows (Processor_Dialog.System_Timer_Type_Combo, True);
      Set_Case_Sensitive (Processor_Dialog.System_Timer_Type_Combo, False);
      Set_Editable
        (Get_Entry (Processor_Dialog.System_Timer_Type_Combo),
         False);
      Set_Max_Length
        (Get_Entry (Processor_Dialog.System_Timer_Type_Combo),
         0);
      Set_Text
        (Get_Entry (Processor_Dialog.System_Timer_Type_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Processor_Dialog.System_Timer_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Processor_Dialog.System_Timer_Type_Combo),
         True);
      String_List.Append (System_Timer_Type_Combo_Items, -("(NONE)"));
      String_List.Append (System_Timer_Type_Combo_Items, -("Alarm Clock"));
      String_List.Append (System_Timer_Type_Combo_Items, -("Ticker"));
      Combo.Set_Popdown_Strings
        (Processor_Dialog.System_Timer_Type_Combo,
         System_Timer_Type_Combo_Items);
      Free_String_List (System_Timer_Type_Combo_Items);
      Attach
        (Processor_Dialog.Table2,
         Processor_Dialog.System_Timer_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Timer_Table, 4, 2, True);
      Set_Row_Spacings (Processor_Dialog.Timer_Table, 5);
      Set_Col_Spacings (Processor_Dialog.Timer_Table, 5);
      Pack_Start
        (Processor_Dialog.Vbox3,
         Processor_Dialog.Timer_Table,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Processor_Dialog.Label56, -("Worst Overhead"));
      Set_Alignment (Processor_Dialog.Label56, 0.95, 0.5);
      Set_Padding (Processor_Dialog.Label56, 0, 0);
      Set_Justify (Processor_Dialog.Label56, Justify_Center);
      Set_Line_Wrap (Processor_Dialog.Label56, False);
      Set_Selectable (Processor_Dialog.Label56, False);
      Set_Use_Markup (Processor_Dialog.Label56, False);
      Set_Use_Underline (Processor_Dialog.Label56, False);
      Attach
        (Processor_Dialog.Timer_Table,
         Processor_Dialog.Label56,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Label57, -("Average Overhead"));
      Set_Alignment (Processor_Dialog.Label57, 0.95, 0.5);
      Set_Padding (Processor_Dialog.Label57, 0, 0);
      Set_Justify (Processor_Dialog.Label57, Justify_Center);
      Set_Line_Wrap (Processor_Dialog.Label57, False);
      Set_Selectable (Processor_Dialog.Label57, False);
      Set_Use_Markup (Processor_Dialog.Label57, False);
      Set_Use_Underline (Processor_Dialog.Label57, False);
      Attach
        (Processor_Dialog.Timer_Table,
         Processor_Dialog.Label57,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Label58, -("Best Overhead"));
      Set_Alignment (Processor_Dialog.Label58, 0.95, 0.5);
      Set_Padding (Processor_Dialog.Label58, 0, 0);
      Set_Justify (Processor_Dialog.Label58, Justify_Center);
      Set_Line_Wrap (Processor_Dialog.Label58, False);
      Set_Selectable (Processor_Dialog.Label58, False);
      Set_Use_Markup (Processor_Dialog.Label58, False);
      Set_Use_Underline (Processor_Dialog.Label58, False);
      Attach
        (Processor_Dialog.Timer_Table,
         Processor_Dialog.Label58,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Proc_Period_Label, -("Period"));
      Set_Alignment (Processor_Dialog.Proc_Period_Label, 0.95, 0.5);
      Set_Padding (Processor_Dialog.Proc_Period_Label, 0, 0);
      Set_Justify (Processor_Dialog.Proc_Period_Label, Justify_Center);
      Set_Line_Wrap (Processor_Dialog.Proc_Period_Label, False);
      Set_Selectable (Processor_Dialog.Proc_Period_Label, False);
      Set_Use_Markup (Processor_Dialog.Proc_Period_Label, False);
      Set_Use_Underline (Processor_Dialog.Proc_Period_Label, False);
      Attach
        (Processor_Dialog.Timer_Table,
         Processor_Dialog.Proc_Period_Label,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Proc_Wor_Over_Entry);
      Set_Editable (Processor_Dialog.Proc_Wor_Over_Entry, True);
      Set_Max_Length (Processor_Dialog.Proc_Wor_Over_Entry, 0);
      Set_Text (Processor_Dialog.Proc_Wor_Over_Entry, -("0.00"));
      Set_Visibility (Processor_Dialog.Proc_Wor_Over_Entry, True);
      Set_Invisible_Char
        (Processor_Dialog.Proc_Wor_Over_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Processor_Dialog.Timer_Table,
         Processor_Dialog.Proc_Wor_Over_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Proc_Avg_Over_Entry);
      Set_Editable (Processor_Dialog.Proc_Avg_Over_Entry, True);
      Set_Max_Length (Processor_Dialog.Proc_Avg_Over_Entry, 0);
      Set_Text (Processor_Dialog.Proc_Avg_Over_Entry, -("0.00"));
      Set_Visibility (Processor_Dialog.Proc_Avg_Over_Entry, True);
      Set_Invisible_Char
        (Processor_Dialog.Proc_Avg_Over_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Processor_Dialog.Timer_Table,
         Processor_Dialog.Proc_Avg_Over_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Proc_Bes_Over_Entry);
      Set_Editable (Processor_Dialog.Proc_Bes_Over_Entry, True);
      Set_Max_Length (Processor_Dialog.Proc_Bes_Over_Entry, 0);
      Set_Text (Processor_Dialog.Proc_Bes_Over_Entry, -("0.00"));
      Set_Visibility (Processor_Dialog.Proc_Bes_Over_Entry, True);
      Set_Invisible_Char
        (Processor_Dialog.Proc_Bes_Over_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Processor_Dialog.Timer_Table,
         Processor_Dialog.Proc_Bes_Over_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Processor_Dialog.Proc_Period_Entry);
      Set_Editable (Processor_Dialog.Proc_Period_Entry, True);
      Set_Max_Length (Processor_Dialog.Proc_Period_Entry, 0);
      Set_Text (Processor_Dialog.Proc_Period_Entry, -("0.00"));
      Set_Visibility (Processor_Dialog.Proc_Period_Entry, True);
      Set_Invisible_Char
        (Processor_Dialog.Proc_Period_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Processor_Dialog.Timer_Table,
         Processor_Dialog.Proc_Period_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Processor_Dialog.New_Primary_Button,
         -"New Primary Scheduler...");
      Set_Border_Width (Processor_Dialog.New_Primary_Button, 20);
      Set_Relief (Processor_Dialog.New_Primary_Button, Relief_Normal);
      Pack_End
        (Processor_Dialog.Vbox3,
         Processor_Dialog.New_Primary_Button,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      --     Button_Callback.Connect
      --       (Processor_Dialog.New_Primary_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_New_Primary_Button_Clicked'Access), False);

      Processor_Dialog_Callback.Object_Connect
        (Processor_Dialog.New_Primary_Button,
         "clicked",
         Processor_Dialog_Callback.To_Marshaller
            (On_New_Primary_Button_Clicked'Access),
         Processor_Dialog);

      --     Entry_Callback.Connect
      --       (Get_Entry (Processor_Dialog.System_Timer_Type_Combo),
      --"changed",
      --        Entry_Callback.To_Marshaller
      --(On_System_Timer_Type_Entry_Changed'Access));

      Processor_Dialog_Callback.Object_Connect
        (Get_Entry (Processor_Dialog.System_Timer_Type_Combo),
         "changed",
         Processor_Dialog_Callback.To_Marshaller
            (On_System_Timer_Type_Entry_Changed'Access),
         Processor_Dialog);

   end Initialize;

end Processor_Dialog_Pkg;
