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
with Glib;                          use Glib;
with Gtk;                           use Gtk;
with Gdk.Types;                     use Gdk.Types;
with Gtk.Widget;                    use Gtk.Widget;
with Gtk.Enums;                     use Gtk.Enums;
with Gtkada.Handlers;               use Gtkada.Handlers;
with Callbacks_Mast_Editor;         use Callbacks_Mast_Editor;
with Mast_Editor_Intl;              use Mast_Editor_Intl;
with External_Dialog_Pkg.Callbacks; use External_Dialog_Pkg.Callbacks;
with Mast;

package body External_Dialog_Pkg is

   procedure Gtk_New (External_Dialog : out External_Dialog_Access) is
   begin
      External_Dialog := new External_Dialog_Record;
      External_Dialog_Pkg.Initialize (External_Dialog);
   end Gtk_New;

   procedure Initialize
     (External_Dialog : access External_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      External_Event_Type_Combo_Items : String_List.Glist;
      Spo_Dist_Func_Combo_Items       : String_List.Glist;
      Unb_Dist_Func_Combo_Items       : String_List.Glist;
      Bur_Dist_Func_Combo_Items       : String_List.Glist;

   begin
      Gtk.Dialog.Initialize (External_Dialog);
      Set_Title (External_Dialog, -"External Event Parameters");
      Set_Policy (External_Dialog, False, False, False);
      Set_Position (External_Dialog, Win_Pos_Center_Always);
      Set_Modal (External_Dialog, False);

      Gtk_New_Hbox (External_Dialog.Hbox68, True, 0);
      Pack_Start (Get_Action_Area (External_Dialog), External_Dialog.Hbox68);

      Gtk_New (External_Dialog.Ok_Button, -"OK");
      Set_Relief (External_Dialog.Ok_Button, Relief_Normal);
      Pack_Start
        (External_Dialog.Hbox68,
         External_Dialog.Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 80);

      Gtk_New (External_Dialog.Cancel_Button, -"Cancel");
      Set_Relief (External_Dialog.Cancel_Button, Relief_Normal);
      Pack_End
        (External_Dialog.Hbox68,
         External_Dialog.Cancel_Button,
         Expand  => True,
         Fill    => True,
         Padding => 80);
      --     Button_Callback.Connect
      --       (External_Dialog.Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Cancel_Button_Clicked'Access), False);
      Dialog_Callback.Object_Connect
        (External_Dialog.Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access),
         External_Dialog);

      Gtk_New_Vbox (External_Dialog.Vbox15, False, 0);
      Pack_Start
        (Get_Vbox (External_Dialog),
         External_Dialog.Vbox15,
         Expand  => False,
         Fill    => True,
         Padding => 0);

      Gtk_New (External_Dialog.Table1, 2, 2, True);
      Set_Border_Width (External_Dialog.Table1, 5);
      Set_Row_Spacings (External_Dialog.Table1, 3);
      Set_Col_Spacings (External_Dialog.Table1, 3);
      Pack_Start
        (External_Dialog.Vbox15,
         External_Dialog.Table1,
         Expand  => False,
         Fill    => False,
         Padding => 5);

      Gtk_New (External_Dialog.Label174, -("Event Name"));
      Set_Alignment (External_Dialog.Label174, 0.95, 0.5);
      Set_Padding (External_Dialog.Label174, 0, 0);
      Set_Justify (External_Dialog.Label174, Justify_Center);
      Set_Line_Wrap (External_Dialog.Label174, False);
      Set_Selectable (External_Dialog.Label174, False);
      Set_Use_Markup (External_Dialog.Label174, False);
      Set_Use_Underline (External_Dialog.Label174, False);
      Attach
        (External_Dialog.Table1,
         External_Dialog.Label174,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Label175, -("External Event Type"));
      Set_Alignment (External_Dialog.Label175, 0.95, 0.5);
      Set_Padding (External_Dialog.Label175, 0, 0);
      Set_Justify (External_Dialog.Label175, Justify_Center);
      Set_Line_Wrap (External_Dialog.Label175, False);
      Set_Selectable (External_Dialog.Label175, False);
      Set_Use_Markup (External_Dialog.Label175, False);
      Set_Use_Underline (External_Dialog.Label175, False);
      Attach
        (External_Dialog.Table1,
         External_Dialog.Label175,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.External_Event_Name_Entry);
      Set_Editable (External_Dialog.External_Event_Name_Entry, True);
      Set_Max_Length (External_Dialog.External_Event_Name_Entry, 0);
      Set_Text (External_Dialog.External_Event_Name_Entry, -(""));
      Set_Visibility (External_Dialog.External_Event_Name_Entry, True);
      Set_Invisible_Char
        (External_Dialog.External_Event_Name_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (External_Dialog.Table1,
         External_Dialog.External_Event_Name_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.External_Event_Type_Combo);
      Set_Value_In_List (External_Dialog.External_Event_Type_Combo, False);
      Set_Use_Arrows (External_Dialog.External_Event_Type_Combo, True);
      Set_Case_Sensitive (External_Dialog.External_Event_Type_Combo, False);
      Set_Editable
        (Get_Entry (External_Dialog.External_Event_Type_Combo),
         False);
      Set_Max_Length
        (Get_Entry (External_Dialog.External_Event_Type_Combo),
         0);
      Set_Text
        (Get_Entry (External_Dialog.External_Event_Type_Combo),
         -("Periodic"));
      Set_Invisible_Char
        (Get_Entry (External_Dialog.External_Event_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (External_Dialog.External_Event_Type_Combo),
         True);
      String_List.Append (External_Event_Type_Combo_Items, -("Periodic"));
      String_List.Append (External_Event_Type_Combo_Items, -("Singular"));
      String_List.Append (External_Event_Type_Combo_Items, -("Sporadic"));
      String_List.Append (External_Event_Type_Combo_Items, -("Unbounded"));
      String_List.Append (External_Event_Type_Combo_Items, -("Bursty"));
      Combo.Set_Popdown_Strings
        (External_Dialog.External_Event_Type_Combo,
         External_Event_Type_Combo_Items);
      Free_String_List (External_Event_Type_Combo_Items);
      Attach
        (External_Dialog.Table1,
         External_Dialog.External_Event_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Periodic_Table, 3, 2, True);
      Set_Border_Width (External_Dialog.Periodic_Table, 5);
      Set_Row_Spacings (External_Dialog.Periodic_Table, 3);
      Set_Col_Spacings (External_Dialog.Periodic_Table, 3);
      Pack_Start
        (External_Dialog.Vbox15,
         External_Dialog.Periodic_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (External_Dialog.Label180, -("Phase"));
      Set_Alignment (External_Dialog.Label180, 0.95, 0.5);
      Set_Padding (External_Dialog.Label180, 0, 0);
      Set_Justify (External_Dialog.Label180, Justify_Center);
      Set_Line_Wrap (External_Dialog.Label180, False);
      Set_Selectable (External_Dialog.Label180, False);
      Set_Use_Markup (External_Dialog.Label180, False);
      Set_Use_Underline (External_Dialog.Label180, False);
      Attach
        (External_Dialog.Periodic_Table,
         External_Dialog.Label180,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Label181, -("Maximum Jitter"));
      Set_Alignment (External_Dialog.Label181, 0.95, 0.5);
      Set_Padding (External_Dialog.Label181, 0, 0);
      Set_Justify (External_Dialog.Label181, Justify_Center);
      Set_Line_Wrap (External_Dialog.Label181, False);
      Set_Selectable (External_Dialog.Label181, False);
      Set_Use_Markup (External_Dialog.Label181, False);
      Set_Use_Underline (External_Dialog.Label181, False);
      Attach
        (External_Dialog.Periodic_Table,
         External_Dialog.Label181,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Label182, -("Period"));
      Set_Alignment (External_Dialog.Label182, 0.95, 0.5);
      Set_Padding (External_Dialog.Label182, 0, 0);
      Set_Justify (External_Dialog.Label182, Justify_Center);
      Set_Line_Wrap (External_Dialog.Label182, False);
      Set_Selectable (External_Dialog.Label182, False);
      Set_Use_Markup (External_Dialog.Label182, False);
      Set_Use_Underline (External_Dialog.Label182, False);
      Attach
        (External_Dialog.Periodic_Table,
         External_Dialog.Label182,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Max_Jitter_Entry);
      Set_Editable (External_Dialog.Max_Jitter_Entry, True);
      Set_Max_Length (External_Dialog.Max_Jitter_Entry, 0);
      Set_Text (External_Dialog.Max_Jitter_Entry, -("0.0"));
      Set_Visibility (External_Dialog.Max_Jitter_Entry, True);
      Set_Invisible_Char
        (External_Dialog.Max_Jitter_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (External_Dialog.Periodic_Table,
         External_Dialog.Max_Jitter_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Period_Entry);
      Set_Editable (External_Dialog.Period_Entry, True);
      Set_Max_Length (External_Dialog.Period_Entry, 0);
      Set_Text (External_Dialog.Period_Entry, -("0.0"));
      Set_Visibility (External_Dialog.Period_Entry, True);
      Set_Invisible_Char (External_Dialog.Period_Entry, UTF8_Get_Char ("*"));
      Attach
        (External_Dialog.Periodic_Table,
         External_Dialog.Period_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Per_Phase_Entry);
      Set_Editable (External_Dialog.Per_Phase_Entry, True);
      Set_Max_Length (External_Dialog.Per_Phase_Entry, 0);
      Set_Text (External_Dialog.Per_Phase_Entry, -("0.0"));
      Set_Visibility (External_Dialog.Per_Phase_Entry, True);
      Set_Invisible_Char
        (External_Dialog.Per_Phase_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (External_Dialog.Periodic_Table,
         External_Dialog.Per_Phase_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Singular_Table, 1, 2, True);
      Set_Border_Width (External_Dialog.Singular_Table, 5);
      Set_Row_Spacings (External_Dialog.Singular_Table, 3);
      Set_Col_Spacings (External_Dialog.Singular_Table, 3);
      Pack_Start
        (External_Dialog.Vbox15,
         External_Dialog.Singular_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (External_Dialog.Label230, -("Phase"));
      Set_Alignment (External_Dialog.Label230, 0.95, 0.5);
      Set_Padding (External_Dialog.Label230, 0, 0);
      Set_Justify (External_Dialog.Label230, Justify_Center);
      Set_Line_Wrap (External_Dialog.Label230, False);
      Set_Selectable (External_Dialog.Label230, False);
      Set_Use_Markup (External_Dialog.Label230, False);
      Set_Use_Underline (External_Dialog.Label230, False);
      Attach
        (External_Dialog.Singular_Table,
         External_Dialog.Label230,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Sing_Phase_Entry);
      Set_Editable (External_Dialog.Sing_Phase_Entry, True);
      Set_Max_Length (External_Dialog.Sing_Phase_Entry, 0);
      Set_Text (External_Dialog.Sing_Phase_Entry, -("0.0"));
      Set_Visibility (External_Dialog.Sing_Phase_Entry, True);
      Set_Invisible_Char
        (External_Dialog.Sing_Phase_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (External_Dialog.Singular_Table,
         External_Dialog.Sing_Phase_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Sporadic_Table, 3, 2, True);
      Set_Border_Width (External_Dialog.Sporadic_Table, 5);
      Set_Row_Spacings (External_Dialog.Sporadic_Table, 3);
      Set_Col_Spacings (External_Dialog.Sporadic_Table, 3);
      Pack_Start
        (External_Dialog.Vbox15,
         External_Dialog.Sporadic_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (External_Dialog.Label225, -("Min Interarrival Time"));
      Set_Alignment (External_Dialog.Label225, 0.95, 0.5);
      Set_Padding (External_Dialog.Label225, 0, 0);
      Set_Justify (External_Dialog.Label225, Justify_Center);
      Set_Line_Wrap (External_Dialog.Label225, False);
      Set_Selectable (External_Dialog.Label225, False);
      Set_Use_Markup (External_Dialog.Label225, False);
      Set_Use_Underline (External_Dialog.Label225, False);
      Attach
        (External_Dialog.Sporadic_Table,
         External_Dialog.Label225,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Label226, -("Distribution Function"));
      Set_Alignment (External_Dialog.Label226, 0.95, 0.5);
      Set_Padding (External_Dialog.Label226, 0, 0);
      Set_Justify (External_Dialog.Label226, Justify_Center);
      Set_Line_Wrap (External_Dialog.Label226, False);
      Set_Selectable (External_Dialog.Label226, False);
      Set_Use_Markup (External_Dialog.Label226, False);
      Set_Use_Underline (External_Dialog.Label226, False);
      Attach
        (External_Dialog.Sporadic_Table,
         External_Dialog.Label226,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Spo_Avg_Entry);
      Set_Editable (External_Dialog.Spo_Avg_Entry, True);
      Set_Max_Length (External_Dialog.Spo_Avg_Entry, 0);
      Set_Text (External_Dialog.Spo_Avg_Entry, -("0.0"));
      Set_Visibility (External_Dialog.Spo_Avg_Entry, True);
      Set_Invisible_Char (External_Dialog.Spo_Avg_Entry, UTF8_Get_Char ("*"));
      Attach
        (External_Dialog.Sporadic_Table,
         External_Dialog.Spo_Avg_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Spo_Min_Entry);
      Set_Editable (External_Dialog.Spo_Min_Entry, True);
      Set_Max_Length (External_Dialog.Spo_Min_Entry, 0);
      Set_Text (External_Dialog.Spo_Min_Entry, -("0.0"));
      Set_Visibility (External_Dialog.Spo_Min_Entry, True);
      Set_Invisible_Char (External_Dialog.Spo_Min_Entry, UTF8_Get_Char ("*"));
      Attach
        (External_Dialog.Sporadic_Table,
         External_Dialog.Spo_Min_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Spo_Dist_Func_Combo);
      Set_Value_In_List (External_Dialog.Spo_Dist_Func_Combo, False);
      Set_Use_Arrows (External_Dialog.Spo_Dist_Func_Combo, True);
      Set_Case_Sensitive (External_Dialog.Spo_Dist_Func_Combo, False);
      Set_Editable (Get_Entry (External_Dialog.Spo_Dist_Func_Combo), False);
      Set_Max_Length (Get_Entry (External_Dialog.Spo_Dist_Func_Combo), 0);
      Set_Text
        (Get_Entry (External_Dialog.Spo_Dist_Func_Combo),
         -("Uniform"));
      Set_Invisible_Char
        (Get_Entry (External_Dialog.Spo_Dist_Func_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (External_Dialog.Spo_Dist_Func_Combo), True);
      for Distrib in Mast.Distribution_Function'Range loop
         String_List.Append (Spo_Dist_Func_Combo_Items,
                             -(Mast.Distribution_Function'Image(Distrib)));
      end loop;
      Combo.Set_Popdown_Strings
        (External_Dialog.Spo_Dist_Func_Combo,
         Spo_Dist_Func_Combo_Items);
      Free_String_List (Spo_Dist_Func_Combo_Items);
      Attach
        (External_Dialog.Sporadic_Table,
         External_Dialog.Spo_Dist_Func_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Label227, -("Avg Interarrival Time"));
      Set_Alignment (External_Dialog.Label227, 0.95, 0.5);
      Set_Padding (External_Dialog.Label227, 0, 0);
      Set_Justify (External_Dialog.Label227, Justify_Center);
      Set_Line_Wrap (External_Dialog.Label227, False);
      Set_Selectable (External_Dialog.Label227, False);
      Set_Use_Markup (External_Dialog.Label227, False);
      Set_Use_Underline (External_Dialog.Label227, False);
      Attach
        (External_Dialog.Sporadic_Table,
         External_Dialog.Label227,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Unbounded_Table, 2, 2, True);
      Set_Border_Width (External_Dialog.Unbounded_Table, 5);
      Set_Row_Spacings (External_Dialog.Unbounded_Table, 3);
      Set_Col_Spacings (External_Dialog.Unbounded_Table, 3);
      Pack_Start
        (External_Dialog.Vbox15,
         External_Dialog.Unbounded_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (External_Dialog.Unb_Avg_Entry);
      Set_Editable (External_Dialog.Unb_Avg_Entry, True);
      Set_Max_Length (External_Dialog.Unb_Avg_Entry, 0);
      Set_Text (External_Dialog.Unb_Avg_Entry, -("0.0"));
      Set_Visibility (External_Dialog.Unb_Avg_Entry, True);
      Set_Invisible_Char (External_Dialog.Unb_Avg_Entry, UTF8_Get_Char ("*"));
      Attach
        (External_Dialog.Unbounded_Table,
         External_Dialog.Unb_Avg_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Label237, -("Avg Interarrival Time"));
      Set_Alignment (External_Dialog.Label237, 0.95, 0.5);
      Set_Padding (External_Dialog.Label237, 0, 0);
      Set_Justify (External_Dialog.Label237, Justify_Center);
      Set_Line_Wrap (External_Dialog.Label237, False);
      Set_Selectable (External_Dialog.Label237, False);
      Set_Use_Markup (External_Dialog.Label237, False);
      Set_Use_Underline (External_Dialog.Label237, False);
      Attach
        (External_Dialog.Unbounded_Table,
         External_Dialog.Label237,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Unb_Dist_Func_Combo);
      Set_Value_In_List (External_Dialog.Unb_Dist_Func_Combo, False);
      Set_Use_Arrows (External_Dialog.Unb_Dist_Func_Combo, True);
      Set_Case_Sensitive (External_Dialog.Unb_Dist_Func_Combo, False);
      Set_Editable (Get_Entry (External_Dialog.Unb_Dist_Func_Combo), False);
      Set_Max_Length (Get_Entry (External_Dialog.Unb_Dist_Func_Combo), 0);
      Set_Text
        (Get_Entry (External_Dialog.Unb_Dist_Func_Combo),
         -("Uniform"));
      Set_Invisible_Char
        (Get_Entry (External_Dialog.Unb_Dist_Func_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (External_Dialog.Unb_Dist_Func_Combo), True);
      for Distrib in Mast.Distribution_Function'Range loop
         String_List.Append (Unb_Dist_Func_Combo_Items,
                             -(Mast.Distribution_Function'Image(Distrib)));
      end loop;
      Combo.Set_Popdown_Strings
        (External_Dialog.Unb_Dist_Func_Combo,
         Unb_Dist_Func_Combo_Items);
      Free_String_List (Unb_Dist_Func_Combo_Items);
      Attach
        (External_Dialog.Unbounded_Table,
         External_Dialog.Unb_Dist_Func_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Label238, -("Distribution Function"));
      Set_Alignment (External_Dialog.Label238, 0.95, 0.5);
      Set_Padding (External_Dialog.Label238, 0, 0);
      Set_Justify (External_Dialog.Label238, Justify_Center);
      Set_Line_Wrap (External_Dialog.Label238, False);
      Set_Selectable (External_Dialog.Label238, False);
      Set_Use_Markup (External_Dialog.Label238, False);
      Set_Use_Underline (External_Dialog.Label238, False);
      Attach
        (External_Dialog.Unbounded_Table,
         External_Dialog.Label238,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Bursty_Table, 4, 2, True);
      Set_Border_Width (External_Dialog.Bursty_Table, 5);
      Set_Row_Spacings (External_Dialog.Bursty_Table, 3);
      Set_Col_Spacings (External_Dialog.Bursty_Table, 3);
      Pack_Start
        (External_Dialog.Vbox15,
         External_Dialog.Bursty_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (External_Dialog.Label239, -("Bound Interval"));
      Set_Alignment (External_Dialog.Label239, 0.95, 0.5);
      Set_Padding (External_Dialog.Label239, 0, 0);
      Set_Justify (External_Dialog.Label239, Justify_Center);
      Set_Line_Wrap (External_Dialog.Label239, False);
      Set_Selectable (External_Dialog.Label239, False);
      Set_Use_Markup (External_Dialog.Label239, False);
      Set_Use_Underline (External_Dialog.Label239, False);
      Attach
        (External_Dialog.Bursty_Table,
         External_Dialog.Label239,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Label240, -("Distribution Function"));
      Set_Alignment (External_Dialog.Label240, 0.95, 0.5);
      Set_Padding (External_Dialog.Label240, 0, 0);
      Set_Justify (External_Dialog.Label240, Justify_Center);
      Set_Line_Wrap (External_Dialog.Label240, False);
      Set_Selectable (External_Dialog.Label240, False);
      Set_Use_Markup (External_Dialog.Label240, False);
      Set_Use_Underline (External_Dialog.Label240, False);
      Attach
        (External_Dialog.Bursty_Table,
         External_Dialog.Label240,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Bur_Avg_Entry);
      Set_Editable (External_Dialog.Bur_Avg_Entry, True);
      Set_Max_Length (External_Dialog.Bur_Avg_Entry, 0);
      Set_Text (External_Dialog.Bur_Avg_Entry, -("0.0"));
      Set_Visibility (External_Dialog.Bur_Avg_Entry, True);
      Set_Invisible_Char (External_Dialog.Bur_Avg_Entry, UTF8_Get_Char ("*"));
      Attach
        (External_Dialog.Bursty_Table,
         External_Dialog.Bur_Avg_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Bur_Bound_Entry);
      Set_Editable (External_Dialog.Bur_Bound_Entry, True);
      Set_Max_Length (External_Dialog.Bur_Bound_Entry, 0);
      Set_Text (External_Dialog.Bur_Bound_Entry, -("0.0"));
      Set_Visibility (External_Dialog.Bur_Bound_Entry, True);
      Set_Invisible_Char
        (External_Dialog.Bur_Bound_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (External_Dialog.Bursty_Table,
         External_Dialog.Bur_Bound_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Bur_Dist_Func_Combo);
      Set_Value_In_List (External_Dialog.Bur_Dist_Func_Combo, False);
      Set_Use_Arrows (External_Dialog.Bur_Dist_Func_Combo, True);
      Set_Case_Sensitive (External_Dialog.Bur_Dist_Func_Combo, False);
      Set_Editable (Get_Entry (External_Dialog.Bur_Dist_Func_Combo), False);
      Set_Max_Length (Get_Entry (External_Dialog.Bur_Dist_Func_Combo), 0);
      Set_Text
        (Get_Entry (External_Dialog.Bur_Dist_Func_Combo),
         -("Uniform"));
      Set_Invisible_Char
        (Get_Entry (External_Dialog.Bur_Dist_Func_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (External_Dialog.Bur_Dist_Func_Combo), True);
      for Distrib in Mast.Distribution_Function'Range loop
         String_List.Append (Bur_Dist_Func_Combo_Items,
                             -(Mast.Distribution_Function'Image(Distrib)));
      end loop;
      Combo.Set_Popdown_Strings
        (External_Dialog.Bur_Dist_Func_Combo,
         Bur_Dist_Func_Combo_Items);
      Free_String_List (Bur_Dist_Func_Combo_Items);
      Attach
        (External_Dialog.Bursty_Table,
         External_Dialog.Bur_Dist_Func_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Label241, -("Avg Interarrival Time"));
      Set_Alignment (External_Dialog.Label241, 0.95, 0.5);
      Set_Padding (External_Dialog.Label241, 0, 0);
      Set_Justify (External_Dialog.Label241, Justify_Center);
      Set_Line_Wrap (External_Dialog.Label241, False);
      Set_Selectable (External_Dialog.Label241, False);
      Set_Use_Markup (External_Dialog.Label241, False);
      Set_Use_Underline (External_Dialog.Label241, False);
      Attach
        (External_Dialog.Bursty_Table,
         External_Dialog.Label241,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Label242, -("Max Arrivals"));
      Set_Alignment (External_Dialog.Label242, 0.95, 0.5);
      Set_Padding (External_Dialog.Label242, 0, 0);
      Set_Justify (External_Dialog.Label242, Justify_Center);
      Set_Line_Wrap (External_Dialog.Label242, False);
      Set_Selectable (External_Dialog.Label242, False);
      Set_Use_Markup (External_Dialog.Label242, False);
      Set_Use_Underline (External_Dialog.Label242, False);
      Attach
        (External_Dialog.Bursty_Table,
         External_Dialog.Label242,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (External_Dialog.Max_Arrival_Entry);
      Set_Editable (External_Dialog.Max_Arrival_Entry, True);
      Set_Max_Length (External_Dialog.Max_Arrival_Entry, 0);
      Set_Text (External_Dialog.Max_Arrival_Entry, -("1"));
      Set_Visibility (External_Dialog.Max_Arrival_Entry, True);
      Set_Invisible_Char
        (External_Dialog.Max_Arrival_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (External_Dialog.Bursty_Table,
         External_Dialog.Max_Arrival_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xpadding      => 0,
         Ypadding      => 0);

      --      Entry_Callback.Connect
      --       (Get_Entry (External_Dialog.External_Event_Type_Combo),
      --"changed",
      --        Entry_Callback.To_Marshaller
      --(On_External_Event_Type_Changed'Access));

      External_Dialog_Callback.Object_Connect
        (Get_Entry (External_Dialog.External_Event_Type_Combo),
         "changed",
         External_Dialog_Callback.To_Marshaller
            (On_External_Event_Type_Changed'Access),
         External_Dialog);

   end Initialize;

end External_Dialog_Pkg;
