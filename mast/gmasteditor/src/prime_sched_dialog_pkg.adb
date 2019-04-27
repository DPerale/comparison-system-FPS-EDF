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
with Glib;                             use Glib;
with Gtk;                              use Gtk;
with Gdk.Types;                        use Gdk.Types;
with Gtk.Widget;                       use Gtk.Widget;
with Gtk.Enums;                        use Gtk.Enums;
with Gtkada.Handlers;                  use Gtkada.Handlers;
with Callbacks_Mast_Editor;            use Callbacks_Mast_Editor;
with Mast_Editor_Intl;                 use Mast_Editor_Intl;
with Prime_Sched_Dialog_Pkg.Callbacks; use Prime_Sched_Dialog_Pkg.Callbacks;

with Mast;                      use Mast;
with Mast.IO;                   use Mast.IO;
with Mast.Processing_Resources; use Mast.Processing_Resources;
with Var_Strings;               use Var_Strings;
with Editor_Actions;            use Editor_Actions;

package body Prime_Sched_Dialog_Pkg is

   procedure Gtk_New (Prime_Sched_Dialog : out Prime_Sched_Dialog_Access) is
   begin
      Prime_Sched_Dialog := new Prime_Sched_Dialog_Record;
      Prime_Sched_Dialog_Pkg.Initialize (Prime_Sched_Dialog);
   end Gtk_New;

   procedure Initialize
     (Prime_Sched_Dialog : access Prime_Sched_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Host_Combo_Items : String_List.Glist;
      --Policy_Type_Combo_Items : String_List.Glist;

      Hos_Ref   : Mast.Processing_Resources.Processing_Resource_Ref;
      Hos_Index : Mast.Processing_Resources.Lists.Index;
      Hos_Name  : Var_Strings.Var_String;

   begin
      -- We search System Hosts and show them in Host_Combo
      Mast.Processing_Resources.Lists.Rewind
        (The_System.Processing_Resources,
         Hos_Index);
      for I in 
            1 ..
            Mast.Processing_Resources.Lists.Size
               (The_System.Processing_Resources)
      loop
         Mast.Processing_Resources.Lists.Get_Next_Item
           (Hos_Ref,
            The_System.Processing_Resources,
            Hos_Index);
         Hos_Name := Mast.Processing_Resources.Name (Hos_Ref);
         String_List.Append (Host_Combo_Items, Name_Image (Hos_Name));
      end loop;

      Gtk.Dialog.Initialize (Prime_Sched_Dialog);
      Set_Title (Prime_Sched_Dialog, -"Primary Scheduler Parameters");
      Set_Position (Prime_Sched_Dialog, Win_Pos_Center_Always);
      Set_Modal (Prime_Sched_Dialog, False);

      Set_Policy (Prime_Sched_Dialog, False, False, False);
      Set_USize (Prime_Sched_Dialog, 450, -1);

      Gtk_New_Hbox (Prime_Sched_Dialog.Hbox67, True, 100);
      Pack_Start
        (Get_Action_Area (Prime_Sched_Dialog),
         Prime_Sched_Dialog.Hbox67);

      Gtk_New (Prime_Sched_Dialog.Ok_Button, -"OK");
      Set_Relief (Prime_Sched_Dialog.Ok_Button, Relief_Normal);
      Pack_Start
        (Prime_Sched_Dialog.Hbox67,
         Prime_Sched_Dialog.Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 50);

      Gtk_New (Prime_Sched_Dialog.Cancel_Button, -"Cancel");
      Set_Relief (Prime_Sched_Dialog.Cancel_Button, Relief_Normal);
      Pack_End
        (Prime_Sched_Dialog.Hbox67,
         Prime_Sched_Dialog.Cancel_Button,
         Expand  => True,
         Fill    => True,
         Padding => 50);
      --     Button_Callback.Connect
      --       (Prime_Sched_Dialog.Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Cancel_Button_Clicked'Access), False);

      Dialog_Callback.Object_Connect
        (Prime_Sched_Dialog.Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access),
         Prime_Sched_Dialog);

      Gtk_New_Vbox (Prime_Sched_Dialog.Vbox24, False, 0);
      Pack_Start
        (Get_Vbox (Prime_Sched_Dialog),
         Prime_Sched_Dialog.Vbox24,
         Expand  => False,
         Fill    => True,
         Padding => 0);

      Gtk_New (Prime_Sched_Dialog.Table1, 4, 2, True);
      Set_Border_Width (Prime_Sched_Dialog.Table1, 5);
      Set_Row_Spacings (Prime_Sched_Dialog.Table1, 3);
      Set_Col_Spacings (Prime_Sched_Dialog.Table1, 3);
      Pack_Start
        (Prime_Sched_Dialog.Vbox24,
         Prime_Sched_Dialog.Table1,
         Expand  => False,
         Fill    => False,
         Padding => 5);

      Gtk_New (Prime_Sched_Dialog.Label333, -("Name"));
      Set_Alignment (Prime_Sched_Dialog.Label333, 0.95, 0.5);
      Set_Padding (Prime_Sched_Dialog.Label333, 0, 0);
      Set_Justify (Prime_Sched_Dialog.Label333, Justify_Center);
      Set_Line_Wrap (Prime_Sched_Dialog.Label333, False);
      Set_Selectable (Prime_Sched_Dialog.Label333, False);
      Set_Use_Markup (Prime_Sched_Dialog.Label333, False);
      Set_Use_Underline (Prime_Sched_Dialog.Label333, False);
      Attach
        (Prime_Sched_Dialog.Table1,
         Prime_Sched_Dialog.Label333,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Prime_Sched_Name_Entry);
      Set_Editable (Prime_Sched_Dialog.Prime_Sched_Name_Entry, True);
      Set_Max_Length (Prime_Sched_Dialog.Prime_Sched_Name_Entry, 0);
      Set_Text (Prime_Sched_Dialog.Prime_Sched_Name_Entry, -(""));
      Set_Visibility (Prime_Sched_Dialog.Prime_Sched_Name_Entry, True);
      Set_Invisible_Char
        (Prime_Sched_Dialog.Prime_Sched_Name_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Prime_Sched_Dialog.Table1,
         Prime_Sched_Dialog.Prime_Sched_Name_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Label332, -("Host"));
      Set_Alignment (Prime_Sched_Dialog.Label332, 0.95, 0.5);
      Set_Padding (Prime_Sched_Dialog.Label332, 0, 0);
      Set_Justify (Prime_Sched_Dialog.Label332, Justify_Center);
      Set_Line_Wrap (Prime_Sched_Dialog.Label332, False);
      Set_Selectable (Prime_Sched_Dialog.Label332, False);
      Set_Use_Markup (Prime_Sched_Dialog.Label332, False);
      Set_Use_Underline (Prime_Sched_Dialog.Label332, False);
      Attach
        (Prime_Sched_Dialog.Table1,
         Prime_Sched_Dialog.Label332,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Host_Combo);
      Set_Value_In_List (Prime_Sched_Dialog.Host_Combo, False);
      Set_Use_Arrows (Prime_Sched_Dialog.Host_Combo, True);
      Set_Case_Sensitive (Prime_Sched_Dialog.Host_Combo, False);
      Set_Editable (Get_Entry (Prime_Sched_Dialog.Host_Combo), False);
      Set_Max_Length (Get_Entry (Prime_Sched_Dialog.Host_Combo), 0);
      Set_Text (Get_Entry (Prime_Sched_Dialog.Host_Combo), -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Prime_Sched_Dialog.Host_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Prime_Sched_Dialog.Host_Combo), True);
      String_List.Append (Host_Combo_Items, -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Prime_Sched_Dialog.Host_Combo,
         Host_Combo_Items);
      Free_String_List (Host_Combo_Items);
      Attach
        (Prime_Sched_Dialog.Table1,
         Prime_Sched_Dialog.Host_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Label331, -("SCHEDULING POLICY :"));
      Set_Alignment (Prime_Sched_Dialog.Label331, 0.5, 0.5);
      Set_Padding (Prime_Sched_Dialog.Label331, 0, 5);
      Set_Justify (Prime_Sched_Dialog.Label331, Justify_Center);
      Set_Line_Wrap (Prime_Sched_Dialog.Label331, False);
      Set_Selectable (Prime_Sched_Dialog.Label331, False);
      Set_Use_Markup (Prime_Sched_Dialog.Label331, False);
      Set_Use_Underline (Prime_Sched_Dialog.Label331, False);
      Attach
        (Prime_Sched_Dialog.Table1,
         Prime_Sched_Dialog.Label331,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Label322, -("Policy Type"));
      Set_Alignment (Prime_Sched_Dialog.Label322, 1.0, 0.5);
      Set_Padding (Prime_Sched_Dialog.Label322, 0, 0);
      Set_Justify (Prime_Sched_Dialog.Label322, Justify_Center);
      Set_Line_Wrap (Prime_Sched_Dialog.Label322, False);
      Set_Selectable (Prime_Sched_Dialog.Label322, False);
      Set_Use_Markup (Prime_Sched_Dialog.Label322, False);
      Set_Use_Underline (Prime_Sched_Dialog.Label322, False);
      Attach
        (Prime_Sched_Dialog.Table1,
         Prime_Sched_Dialog.Label322,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Policy_Type_Combo);
      Set_Value_In_List (Prime_Sched_Dialog.Policy_Type_Combo, False);
      Set_Use_Arrows (Prime_Sched_Dialog.Policy_Type_Combo, True);
      Set_Case_Sensitive (Prime_Sched_Dialog.Policy_Type_Combo, False);
      Set_Editable (Get_Entry (Prime_Sched_Dialog.Policy_Type_Combo), False);
      Set_Max_Length (Get_Entry (Prime_Sched_Dialog.Policy_Type_Combo), 0);
      Set_Text
        (Get_Entry (Prime_Sched_Dialog.Policy_Type_Combo),
         -("Fixed Priority"));
      Set_Invisible_Char
        (Get_Entry (Prime_Sched_Dialog.Policy_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Prime_Sched_Dialog.Policy_Type_Combo), True);
      String_List.Prepend (Policy_Type_Combo_Items, -("Fixed Priority"));
      --String_List.Append (Policy_Type_Combo_Items, -("Fixed Priority"));
      String_List.Append
        (Policy_Type_Combo_Items,
         -("Earliest Deadline First"));
      --String_List.Append (Policy_Type_Combo_Items, -("Fixed Priority Packet
      --Based"));
      Combo.Set_Popdown_Strings
        (Prime_Sched_Dialog.Policy_Type_Combo,
         Policy_Type_Combo_Items);
      Free_String_List (Policy_Type_Combo_Items);
      Attach
        (Prime_Sched_Dialog.Table1,
         Prime_Sched_Dialog.Policy_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Priority_Table, 2, 2, True);
      Set_Border_Width (Prime_Sched_Dialog.Priority_Table, 5);
      Set_Row_Spacings (Prime_Sched_Dialog.Priority_Table, 5);
      Set_Col_Spacings (Prime_Sched_Dialog.Priority_Table, 3);
      Pack_Start
        (Prime_Sched_Dialog.Vbox24,
         Prime_Sched_Dialog.Priority_Table,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Prime_Sched_Dialog.Max_Prior_Entry);
      Set_Editable (Prime_Sched_Dialog.Max_Prior_Entry, True);
      Set_Max_Length (Prime_Sched_Dialog.Max_Prior_Entry, 0);
      Set_Text
        (Prime_Sched_Dialog.Max_Prior_Entry,
         Priority'Image (Priority'Last));
      Set_Visibility (Prime_Sched_Dialog.Max_Prior_Entry, True);
      Set_Invisible_Char
        (Prime_Sched_Dialog.Max_Prior_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Prime_Sched_Dialog.Priority_Table,
         Prime_Sched_Dialog.Max_Prior_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Min_Prior_Entry);
      Set_Editable (Prime_Sched_Dialog.Min_Prior_Entry, True);
      Set_Max_Length (Prime_Sched_Dialog.Min_Prior_Entry, 0);
      Set_Text
        (Prime_Sched_Dialog.Min_Prior_Entry,
         Priority'Image (Priority'First));
      Set_Visibility (Prime_Sched_Dialog.Min_Prior_Entry, True);
      Set_Invisible_Char
        (Prime_Sched_Dialog.Min_Prior_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Prime_Sched_Dialog.Priority_Table,
         Prime_Sched_Dialog.Min_Prior_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Label345, -("Max Priority"));
      Set_Alignment (Prime_Sched_Dialog.Label345, 0.95, 0.5);
      Set_Padding (Prime_Sched_Dialog.Label345, 0, 0);
      Set_Justify (Prime_Sched_Dialog.Label345, Justify_Center);
      Set_Line_Wrap (Prime_Sched_Dialog.Label345, False);
      Set_Selectable (Prime_Sched_Dialog.Label345, False);
      Set_Use_Markup (Prime_Sched_Dialog.Label345, False);
      Set_Use_Underline (Prime_Sched_Dialog.Label345, False);
      Attach
        (Prime_Sched_Dialog.Priority_Table,
         Prime_Sched_Dialog.Label345,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Label347, -("Min Priority"));
      Set_Alignment (Prime_Sched_Dialog.Label347, 0.95, 0.5);
      Set_Padding (Prime_Sched_Dialog.Label347, 0, 0);
      Set_Justify (Prime_Sched_Dialog.Label347, Justify_Center);
      Set_Line_Wrap (Prime_Sched_Dialog.Label347, False);
      Set_Selectable (Prime_Sched_Dialog.Label347, False);
      Set_Use_Markup (Prime_Sched_Dialog.Label347, False);
      Set_Use_Underline (Prime_Sched_Dialog.Label347, False);
      Attach
        (Prime_Sched_Dialog.Priority_Table,
         Prime_Sched_Dialog.Label347,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Context_Table, 3, 2, True);
      Set_Border_Width (Prime_Sched_Dialog.Context_Table, 5);
      Set_Row_Spacings (Prime_Sched_Dialog.Context_Table, 5);
      Set_Col_Spacings (Prime_Sched_Dialog.Context_Table, 3);
      Pack_Start
        (Prime_Sched_Dialog.Vbox24,
         Prime_Sched_Dialog.Context_Table,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Prime_Sched_Dialog.Label348, -("Best Context Switch"));
      Set_Alignment (Prime_Sched_Dialog.Label348, 0.95, 0.5);
      Set_Padding (Prime_Sched_Dialog.Label348, 0, 0);
      Set_Justify (Prime_Sched_Dialog.Label348, Justify_Center);
      Set_Line_Wrap (Prime_Sched_Dialog.Label348, False);
      Set_Selectable (Prime_Sched_Dialog.Label348, False);
      Set_Use_Markup (Prime_Sched_Dialog.Label348, False);
      Set_Use_Underline (Prime_Sched_Dialog.Label348, False);
      Attach
        (Prime_Sched_Dialog.Context_Table,
         Prime_Sched_Dialog.Label348,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Worst_Context_Entry);
      Set_Editable (Prime_Sched_Dialog.Worst_Context_Entry, True);
      Set_Max_Length (Prime_Sched_Dialog.Worst_Context_Entry, 0);
      Set_Text (Prime_Sched_Dialog.Worst_Context_Entry, -("0.0"));
      Set_Visibility (Prime_Sched_Dialog.Worst_Context_Entry, True);
      Set_Invisible_Char
        (Prime_Sched_Dialog.Worst_Context_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Prime_Sched_Dialog.Context_Table,
         Prime_Sched_Dialog.Worst_Context_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Avg_Context_Entry);
      Set_Editable (Prime_Sched_Dialog.Avg_Context_Entry, True);
      Set_Max_Length (Prime_Sched_Dialog.Avg_Context_Entry, 0);
      Set_Text (Prime_Sched_Dialog.Avg_Context_Entry, -("0.0"));
      Set_Visibility (Prime_Sched_Dialog.Avg_Context_Entry, True);
      Set_Invisible_Char
        (Prime_Sched_Dialog.Avg_Context_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Prime_Sched_Dialog.Context_Table,
         Prime_Sched_Dialog.Avg_Context_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Best_Context_Entry);
      Set_Editable (Prime_Sched_Dialog.Best_Context_Entry, True);
      Set_Max_Length (Prime_Sched_Dialog.Best_Context_Entry, 0);
      Set_Text (Prime_Sched_Dialog.Best_Context_Entry, -("0.0"));
      Set_Visibility (Prime_Sched_Dialog.Best_Context_Entry, True);
      Set_Invisible_Char
        (Prime_Sched_Dialog.Best_Context_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Prime_Sched_Dialog.Context_Table,
         Prime_Sched_Dialog.Best_Context_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Label349, -("Worst Context Switch"));
      Set_Alignment (Prime_Sched_Dialog.Label349, 0.95, 0.5);
      Set_Padding (Prime_Sched_Dialog.Label349, 0, 0);
      Set_Justify (Prime_Sched_Dialog.Label349, Justify_Center);
      Set_Line_Wrap (Prime_Sched_Dialog.Label349, False);
      Set_Selectable (Prime_Sched_Dialog.Label349, False);
      Set_Use_Markup (Prime_Sched_Dialog.Label349, False);
      Set_Use_Underline (Prime_Sched_Dialog.Label349, False);
      Attach
        (Prime_Sched_Dialog.Context_Table,
         Prime_Sched_Dialog.Label349,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Label351, -("Avg Context Switch"));
      Set_Alignment (Prime_Sched_Dialog.Label351, 0.95, 0.5);
      Set_Padding (Prime_Sched_Dialog.Label351, 0, 0);
      Set_Justify (Prime_Sched_Dialog.Label351, Justify_Center);
      Set_Line_Wrap (Prime_Sched_Dialog.Label351, False);
      Set_Selectable (Prime_Sched_Dialog.Label351, False);
      Set_Use_Markup (Prime_Sched_Dialog.Label351, False);
      Set_Use_Underline (Prime_Sched_Dialog.Label351, False);
      Attach
        (Prime_Sched_Dialog.Context_Table,
         Prime_Sched_Dialog.Label351,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Overhead_Table, 3, 2, True);
      Set_Border_Width (Prime_Sched_Dialog.Overhead_Table, 5);
      Set_Row_Spacings (Prime_Sched_Dialog.Overhead_Table, 5);
      Set_Col_Spacings (Prime_Sched_Dialog.Overhead_Table, 3);
      Pack_Start
        (Prime_Sched_Dialog.Vbox24,
         Prime_Sched_Dialog.Overhead_Table,
         Expand  => False,
         Fill    => False,
         Padding => 5);

      Gtk_New (Prime_Sched_Dialog.Label354, -("Packet Overhead Min Size"));
      Set_Alignment (Prime_Sched_Dialog.Label354, 0.95, 0.5);
      Set_Padding (Prime_Sched_Dialog.Label354, 0, 0);
      Set_Justify (Prime_Sched_Dialog.Label354, Justify_Center);
      Set_Line_Wrap (Prime_Sched_Dialog.Label354, False);
      Set_Selectable (Prime_Sched_Dialog.Label354, False);
      Set_Use_Markup (Prime_Sched_Dialog.Label354, False);
      Set_Use_Underline (Prime_Sched_Dialog.Label354, False);
      Attach
        (Prime_Sched_Dialog.Overhead_Table,
         Prime_Sched_Dialog.Label354,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Packet_Over_Max_Entry);
      Set_Editable (Prime_Sched_Dialog.Packet_Over_Max_Entry, True);
      Set_Max_Length (Prime_Sched_Dialog.Packet_Over_Max_Entry, 0);
      Set_Text (Prime_Sched_Dialog.Packet_Over_Max_Entry, -("0.0"));
      Set_Visibility (Prime_Sched_Dialog.Packet_Over_Max_Entry, True);
      Set_Invisible_Char
        (Prime_Sched_Dialog.Packet_Over_Max_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Prime_Sched_Dialog.Overhead_Table,
         Prime_Sched_Dialog.Packet_Over_Max_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Packet_Over_Avg_Entry);
      Set_Editable (Prime_Sched_Dialog.Packet_Over_Avg_Entry, True);
      Set_Max_Length (Prime_Sched_Dialog.Packet_Over_Avg_Entry, 0);
      Set_Text (Prime_Sched_Dialog.Packet_Over_Avg_Entry, -("0.0"));
      Set_Visibility (Prime_Sched_Dialog.Packet_Over_Avg_Entry, True);
      Set_Invisible_Char
        (Prime_Sched_Dialog.Packet_Over_Avg_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Prime_Sched_Dialog.Overhead_Table,
         Prime_Sched_Dialog.Packet_Over_Avg_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Packet_Over_Min_Entry);
      Set_Editable (Prime_Sched_Dialog.Packet_Over_Min_Entry, True);
      Set_Max_Length (Prime_Sched_Dialog.Packet_Over_Min_Entry, 0);
      Set_Text (Prime_Sched_Dialog.Packet_Over_Min_Entry, -("0.0"));
      Set_Visibility (Prime_Sched_Dialog.Packet_Over_Min_Entry, True);
      Set_Invisible_Char
        (Prime_Sched_Dialog.Packet_Over_Min_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Prime_Sched_Dialog.Overhead_Table,
         Prime_Sched_Dialog.Packet_Over_Min_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Label355, -("Packet Overhead Max Size"));
      Set_Alignment (Prime_Sched_Dialog.Label355, 0.95, 0.5);
      Set_Padding (Prime_Sched_Dialog.Label355, 0, 0);
      Set_Justify (Prime_Sched_Dialog.Label355, Justify_Center);
      Set_Line_Wrap (Prime_Sched_Dialog.Label355, False);
      Set_Selectable (Prime_Sched_Dialog.Label355, False);
      Set_Use_Markup (Prime_Sched_Dialog.Label355, False);
      Set_Use_Underline (Prime_Sched_Dialog.Label355, False);
      Attach
        (Prime_Sched_Dialog.Overhead_Table,
         Prime_Sched_Dialog.Label355,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Prime_Sched_Dialog.Label357, -("Packet Overhead Avg Size"));
      Set_Alignment (Prime_Sched_Dialog.Label357, 0.95, 0.5);
      Set_Padding (Prime_Sched_Dialog.Label357, 0, 0);
      Set_Justify (Prime_Sched_Dialog.Label357, Justify_Center);
      Set_Line_Wrap (Prime_Sched_Dialog.Label357, False);
      Set_Selectable (Prime_Sched_Dialog.Label357, False);
      Set_Use_Markup (Prime_Sched_Dialog.Label357, False);
      Set_Use_Underline (Prime_Sched_Dialog.Label357, False);
      Attach
        (Prime_Sched_Dialog.Overhead_Table,
         Prime_Sched_Dialog.Label357,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      --     Entry_Callback.Connect
      --       (Get_Entry (Prime_Sched_Dialog.Policy_Type_Combo), "changed",
      --        Entry_Callback.To_Marshaller
      --(On_Prime_Policy_Type_Entry_Changed'Access));

      Prime_Sched_Dialog_Callback.Object_Connect
        (Get_Entry (Prime_Sched_Dialog.Policy_Type_Combo),
         "changed",
         Prime_Sched_Dialog_Callback.To_Marshaller
            (On_Prime_Policy_Type_Entry_Changed'Access),
         Prime_Sched_Dialog);

   end Initialize;

end Prime_Sched_Dialog_Pkg;
