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
with Glib;                              use Glib;
with Gtk;                               use Gtk;
with Gdk.Types;                         use Gdk.Types;
with Gtk.Widget;                        use Gtk.Widget;
with Gtk.Enums;                         use Gtk.Enums;
with Gtkada.Handlers;                   use Gtkada.Handlers;
with Callbacks_Mast_Editor;             use Callbacks_Mast_Editor;
with Mast_Editor_Intl;                  use Mast_Editor_Intl;
with Sched_Server_Dialog_Pkg.Callbacks; use Sched_Server_Dialog_Pkg.Callbacks;

with Mast;            use Mast;
with Mast.IO;         use Mast.IO;
with Mast.Schedulers; use Mast.Schedulers;
with Var_Strings;     use Var_Strings;
with Editor_Actions;  use Editor_Actions;

package body Sched_Server_Dialog_Pkg is

   procedure Gtk_New (Sched_Server_Dialog : out Sched_Server_Dialog_Access) is
   begin
      Sched_Server_Dialog := new Sched_Server_Dialog_Record;
      Sched_Server_Dialog_Pkg.Initialize (Sched_Server_Dialog);
   end Gtk_New;

   procedure Initialize
     (Sched_Server_Dialog : access Sched_Server_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Server_Type_Combo_Items : String_List.Glist;
      Sched_Combo_Items       : String_List.Glist;
      Sync_Type_Combo_Items   : String_List.Glist;
      Pre_Level_Combo_Items   : String_List.Glist;
      Policy_Type_Combo_Items : String_List.Glist;
      Pre_Prior_Combo_Items   : String_List.Glist;
      Deadline_Combo_Items    : String_List.Glist;

      Sche_Ref   : Mast.Schedulers.Scheduler_Ref;
      Sche_Index : Mast.Schedulers.Lists.Index;
      Sche_Name  : Var_Strings.Var_String;

   begin
      -- We search System Schedulers and show them in Sched_Combo
      Mast.Schedulers.Lists.Rewind (The_System.Schedulers, Sche_Index);
      for I in 1 .. Mast.Schedulers.Lists.Size (The_System.Schedulers) loop
         Mast.Schedulers.Lists.Get_Next_Item
           (Sche_Ref,
            The_System.Schedulers,
            Sche_Index);
         Sche_Name := Mast.Schedulers.Name (Sche_Ref);
         String_List.Append (Sched_Combo_Items, Name_Image (Sche_Name));
      end loop;

      Gtk.Dialog.Initialize (Sched_Server_Dialog);
      Set_Title (Sched_Server_Dialog, -"Scheduling Server Parameters");
      Set_Position (Sched_Server_Dialog, Win_Pos_Center_Always);
      Set_Modal (Sched_Server_Dialog, False);

      Set_Policy (Sched_Server_Dialog, False, False, False);
      Set_USize (Sched_Server_Dialog, 550, -1);

      Gtk_New_Hbox (Sched_Server_Dialog.Hbox66, True, 0);
      Pack_Start
        (Get_Action_Area (Sched_Server_Dialog),
         Sched_Server_Dialog.Hbox66);

      Gtk_New (Sched_Server_Dialog.Server_Ok_Button, -"OK");
      Set_Relief (Sched_Server_Dialog.Server_Ok_Button, Relief_Normal);
      Pack_Start
        (Sched_Server_Dialog.Hbox66,
         Sched_Server_Dialog.Server_Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 100);

      Gtk_New (Sched_Server_Dialog.Server_Cancel_Button, -"Cancel");
      Set_Relief (Sched_Server_Dialog.Server_Cancel_Button, Relief_Normal);
      Pack_End
        (Sched_Server_Dialog.Hbox66,
         Sched_Server_Dialog.Server_Cancel_Button,
         Expand  => True,
         Fill    => True,
         Padding => 100);
      --     Button_Callback.Connect
      --       (Sched_Server_Dialog.Server_Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Server_Cancel_Button_Clicked'Access), False);

      Dialog_Callback.Object_Connect
        (Sched_Server_Dialog.Server_Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller
            (On_Server_Cancel_Button_Clicked'Access),
         Sched_Server_Dialog);

      Gtk_New_Vbox (Sched_Server_Dialog.Vbox5, False, 0);
      Pack_Start
        (Get_Vbox (Sched_Server_Dialog),
         Sched_Server_Dialog.Vbox5,
         Expand  => False,
         Fill    => True,
         Padding => 0);

      Gtk_New (Sched_Server_Dialog.Table1, 5, 2, True);
      Set_Border_Width (Sched_Server_Dialog.Table1, 5);
      Set_Row_Spacings (Sched_Server_Dialog.Table1, 3);
      Set_Col_Spacings (Sched_Server_Dialog.Table1, 3);
      Pack_Start
        (Sched_Server_Dialog.Vbox5,
         Sched_Server_Dialog.Table1,
         Expand  => False,
         Fill    => False,
         Padding => 5);

      Gtk_New (Sched_Server_Dialog.Label109, -("Parameters Type"));
      Set_Alignment (Sched_Server_Dialog.Label109, 1.0, 0.5);
      Set_Padding (Sched_Server_Dialog.Label109, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label109, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label109, False);
      Set_Selectable (Sched_Server_Dialog.Label109, False);
      Set_Use_Markup (Sched_Server_Dialog.Label109, False);
      Set_Use_Underline (Sched_Server_Dialog.Label109, False);
      Attach
        (Sched_Server_Dialog.Table1,
         Sched_Server_Dialog.Label109,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Sched_Server_Dialog.Label110,
         -("SYNCHRONIZATION PARAMETERS :"));
      Set_Alignment (Sched_Server_Dialog.Label110, 0.5, 0.5);
      Set_Padding (Sched_Server_Dialog.Label110, 0, 5);
      Set_Justify (Sched_Server_Dialog.Label110, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label110, False);
      Set_Selectable (Sched_Server_Dialog.Label110, False);
      Set_Use_Markup (Sched_Server_Dialog.Label110, False);
      Set_Use_Underline (Sched_Server_Dialog.Label110, False);
      Attach
        (Sched_Server_Dialog.Table1,
         Sched_Server_Dialog.Label110,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Label111, -("Scheduler"));
      Set_Alignment (Sched_Server_Dialog.Label111, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label111, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label111, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label111, False);
      Set_Selectable (Sched_Server_Dialog.Label111, False);
      Set_Use_Markup (Sched_Server_Dialog.Label111, False);
      Set_Use_Underline (Sched_Server_Dialog.Label111, False);
      Attach
        (Sched_Server_Dialog.Table1,
         Sched_Server_Dialog.Label111,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Label112, -("Server Name"));
      Set_Alignment (Sched_Server_Dialog.Label112, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label112, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label112, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label112, False);
      Set_Selectable (Sched_Server_Dialog.Label112, False);
      Set_Use_Markup (Sched_Server_Dialog.Label112, False);
      Set_Use_Underline (Sched_Server_Dialog.Label112, False);
      Attach
        (Sched_Server_Dialog.Table1,
         Sched_Server_Dialog.Label112,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Label113, -("Scheduling Server Type"));
      Set_Alignment (Sched_Server_Dialog.Label113, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label113, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label113, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label113, False);
      Set_Selectable (Sched_Server_Dialog.Label113, False);
      Set_Use_Markup (Sched_Server_Dialog.Label113, False);
      Set_Use_Underline (Sched_Server_Dialog.Label113, False);
      Attach
        (Sched_Server_Dialog.Table1,
         Sched_Server_Dialog.Label113,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Server_Name_Entry);
      Set_Editable (Sched_Server_Dialog.Server_Name_Entry, True);
      Set_Max_Length (Sched_Server_Dialog.Server_Name_Entry, 0);
      Set_Text (Sched_Server_Dialog.Server_Name_Entry, -(""));
      Set_Visibility (Sched_Server_Dialog.Server_Name_Entry, True);
      Set_Invisible_Char
        (Sched_Server_Dialog.Server_Name_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sched_Server_Dialog.Table1,
         Sched_Server_Dialog.Server_Name_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Server_Type_Combo);
      Set_Value_In_List (Sched_Server_Dialog.Server_Type_Combo, False);
      Set_Use_Arrows (Sched_Server_Dialog.Server_Type_Combo, True);
      Set_Case_Sensitive (Sched_Server_Dialog.Server_Type_Combo, False);
      Set_Editable (Get_Entry (Sched_Server_Dialog.Server_Type_Combo), False);
      Set_Max_Length (Get_Entry (Sched_Server_Dialog.Server_Type_Combo), 0);
      Set_Text
        (Get_Entry (Sched_Server_Dialog.Server_Type_Combo),
         -("Regular"));
      Set_Invisible_Char
        (Get_Entry (Sched_Server_Dialog.Server_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Sched_Server_Dialog.Server_Type_Combo), True);
      String_List.Append (Server_Type_Combo_Items, -("Regular"));
      Combo.Set_Popdown_Strings
        (Sched_Server_Dialog.Server_Type_Combo,
         Server_Type_Combo_Items);
      Free_String_List (Server_Type_Combo_Items);
      Attach
        (Sched_Server_Dialog.Table1,
         Sched_Server_Dialog.Server_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Sched_Combo);
      Set_Value_In_List (Sched_Server_Dialog.Sched_Combo, False);
      Set_Use_Arrows (Sched_Server_Dialog.Sched_Combo, True);
      Set_Case_Sensitive (Sched_Server_Dialog.Sched_Combo, False);
      Set_Editable (Get_Entry (Sched_Server_Dialog.Sched_Combo), False);
      Set_Max_Length (Get_Entry (Sched_Server_Dialog.Sched_Combo), 0);
      Set_Text (Get_Entry (Sched_Server_Dialog.Sched_Combo), -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Sched_Server_Dialog.Sched_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Sched_Server_Dialog.Sched_Combo), True);
      String_List.Append (Sched_Combo_Items, -("(NONE)"));
      Combo.Set_Popdown_Strings
        (Sched_Server_Dialog.Sched_Combo,
         Sched_Combo_Items);
      Free_String_List (Sched_Combo_Items);
      Attach
        (Sched_Server_Dialog.Table1,
         Sched_Server_Dialog.Sched_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Sync_Type_Combo);
      Set_Value_In_List (Sched_Server_Dialog.Sync_Type_Combo, False);
      Set_Use_Arrows (Sched_Server_Dialog.Sync_Type_Combo, True);
      Set_Case_Sensitive (Sched_Server_Dialog.Sync_Type_Combo, False);
      Set_Editable (Get_Entry (Sched_Server_Dialog.Sync_Type_Combo), False);
      Set_Max_Length (Get_Entry (Sched_Server_Dialog.Sync_Type_Combo), 0);
      Set_Text
        (Get_Entry (Sched_Server_Dialog.Sync_Type_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Sched_Server_Dialog.Sync_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Sched_Server_Dialog.Sync_Type_Combo), True);
      String_List.Append (Sync_Type_Combo_Items, -("(NONE)"));
      String_List.Append
        (Sync_Type_Combo_Items,
         -("Stack Resource Protocol"));
      Combo.Set_Popdown_Strings
        (Sched_Server_Dialog.Sync_Type_Combo,
         Sync_Type_Combo_Items);
      Free_String_List (Sync_Type_Combo_Items);
      Attach
        (Sched_Server_Dialog.Table1,
         Sched_Server_Dialog.Sync_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Srp_Table, 2, 2, True);
      Set_Border_Width (Sched_Server_Dialog.Srp_Table, 5);
      Set_Row_Spacings (Sched_Server_Dialog.Srp_Table, 5);
      Set_Col_Spacings (Sched_Server_Dialog.Srp_Table, 3);
      Pack_Start
        (Sched_Server_Dialog.Vbox5,
         Sched_Server_Dialog.Srp_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New
        (Sched_Server_Dialog.Label114,
         -("Preemption Level Preassigned"));
      Set_Alignment (Sched_Server_Dialog.Label114, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label114, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label114, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label114, False);
      Set_Selectable (Sched_Server_Dialog.Label114, False);
      Set_Use_Markup (Sched_Server_Dialog.Label114, False);
      Set_Use_Underline (Sched_Server_Dialog.Label114, False);
      Attach
        (Sched_Server_Dialog.Srp_Table,
         Sched_Server_Dialog.Label114,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Label115, -("Preemption Level"));
      Set_Alignment (Sched_Server_Dialog.Label115, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label115, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label115, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label115, False);
      Set_Selectable (Sched_Server_Dialog.Label115, False);
      Set_Use_Markup (Sched_Server_Dialog.Label115, False);
      Set_Use_Underline (Sched_Server_Dialog.Label115, False);
      Attach
        (Sched_Server_Dialog.Srp_Table,
         Sched_Server_Dialog.Label115,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Preemption_Level_Entry);
      Set_Editable (Sched_Server_Dialog.Preemption_Level_Entry, True);
      Set_Max_Length (Sched_Server_Dialog.Preemption_Level_Entry, 0);
      Set_Text
        (Sched_Server_Dialog.Preemption_Level_Entry,
         Preemption_Level'Image (Preemption_Level'First));
      Set_Visibility (Sched_Server_Dialog.Preemption_Level_Entry, True);
      Set_Invisible_Char
        (Sched_Server_Dialog.Preemption_Level_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sched_Server_Dialog.Srp_Table,
         Sched_Server_Dialog.Preemption_Level_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Pre_Level_Combo);
      Set_Value_In_List (Sched_Server_Dialog.Pre_Level_Combo, False);
      Set_Use_Arrows (Sched_Server_Dialog.Pre_Level_Combo, True);
      Set_Case_Sensitive (Sched_Server_Dialog.Pre_Level_Combo, False);
      Set_Editable (Get_Entry (Sched_Server_Dialog.Pre_Level_Combo), False);
      Set_Max_Length (Get_Entry (Sched_Server_Dialog.Pre_Level_Combo), 0);
      Set_Text (Get_Entry (Sched_Server_Dialog.Pre_Level_Combo), -("NO"));
      Set_Invisible_Char
        (Get_Entry (Sched_Server_Dialog.Pre_Level_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Sched_Server_Dialog.Pre_Level_Combo), True);
      String_List.Append (Pre_Level_Combo_Items, -("NO"));
      String_List.Append (Pre_Level_Combo_Items, -("YES"));
      Combo.Set_Popdown_Strings
        (Sched_Server_Dialog.Pre_Level_Combo,
         Pre_Level_Combo_Items);
      Free_String_List (Pre_Level_Combo_Items);
      Attach
        (Sched_Server_Dialog.Srp_Table,
         Sched_Server_Dialog.Pre_Level_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Policy_Type_Table, 2, 2, True);
      Set_Border_Width (Sched_Server_Dialog.Policy_Type_Table, 5);
      Set_Row_Spacings (Sched_Server_Dialog.Policy_Type_Table, 5);
      Set_Col_Spacings (Sched_Server_Dialog.Policy_Type_Table, 3);
      Pack_Start
        (Sched_Server_Dialog.Vbox5,
         Sched_Server_Dialog.Policy_Type_Table,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Sched_Server_Dialog.Label375, -("SCHEDULING PARAMETERS :"));
      Set_Alignment (Sched_Server_Dialog.Label375, 0.5, 0.5);
      Set_Padding (Sched_Server_Dialog.Label375, 0, 5);
      Set_Justify (Sched_Server_Dialog.Label375, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label375, False);
      Set_Selectable (Sched_Server_Dialog.Label375, False);
      Set_Use_Markup (Sched_Server_Dialog.Label375, False);
      Set_Use_Underline (Sched_Server_Dialog.Label375, False);
      Attach
        (Sched_Server_Dialog.Policy_Type_Table,
         Sched_Server_Dialog.Label375,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Label376, -("Policy Type"));
      Set_Alignment (Sched_Server_Dialog.Label376, 1.0, 0.5);
      Set_Padding (Sched_Server_Dialog.Label376, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label376, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label376, False);
      Set_Selectable (Sched_Server_Dialog.Label376, False);
      Set_Use_Markup (Sched_Server_Dialog.Label376, False);
      Set_Use_Underline (Sched_Server_Dialog.Label376, False);
      Attach
        (Sched_Server_Dialog.Policy_Type_Table,
         Sched_Server_Dialog.Label376,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Policy_Type_Combo);
      Set_Value_In_List (Sched_Server_Dialog.Policy_Type_Combo, False);
      Set_Use_Arrows (Sched_Server_Dialog.Policy_Type_Combo, True);
      Set_Case_Sensitive (Sched_Server_Dialog.Policy_Type_Combo, False);
      Set_Editable (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo), False);
      Set_Max_Length (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo), 0);
      Set_Text
        (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo), True);
      String_List.Append (Policy_Type_Combo_Items, -("(NONE)"));
      String_List.Append
        (Policy_Type_Combo_Items,
         -("Non Preemptible Fixed Priority"));
      String_List.Append (Policy_Type_Combo_Items, -("Fixed Priority"));
      String_List.Append
        (Policy_Type_Combo_Items,
         -("Interrupt Fixed Priority"));
      String_List.Append (Policy_Type_Combo_Items, -("Polling"));
      String_List.Append (Policy_Type_Combo_Items, -("Sporadic Server"));
      String_List.Append
        (Policy_Type_Combo_Items,
         -("Earliest Deadline First"));
      Combo.Set_Popdown_Strings
        (Sched_Server_Dialog.Policy_Type_Combo,
         Policy_Type_Combo_Items);
      Free_String_List (Policy_Type_Combo_Items);
      Attach
        (Sched_Server_Dialog.Policy_Type_Table,
         Sched_Server_Dialog.Policy_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Priority_Table, 2, 2, True);
      Set_Border_Width (Sched_Server_Dialog.Priority_Table, 5);
      Set_Row_Spacings (Sched_Server_Dialog.Priority_Table, 5);
      Set_Col_Spacings (Sched_Server_Dialog.Priority_Table, 3);
      Pack_Start
        (Sched_Server_Dialog.Vbox5,
         Sched_Server_Dialog.Priority_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Sched_Server_Dialog.Label377, -("Preassigned Priority"));
      Set_Alignment (Sched_Server_Dialog.Label377, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label377, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label377, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label377, False);
      Set_Selectable (Sched_Server_Dialog.Label377, False);
      Set_Use_Markup (Sched_Server_Dialog.Label377, False);
      Set_Use_Underline (Sched_Server_Dialog.Label377, False);
      Attach
        (Sched_Server_Dialog.Priority_Table,
         Sched_Server_Dialog.Label377,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Label378, -("Priority"));
      Set_Alignment (Sched_Server_Dialog.Label378, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label378, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label378, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label378, False);
      Set_Selectable (Sched_Server_Dialog.Label378, False);
      Set_Use_Markup (Sched_Server_Dialog.Label378, False);
      Set_Use_Underline (Sched_Server_Dialog.Label378, False);
      Attach
        (Sched_Server_Dialog.Priority_Table,
         Sched_Server_Dialog.Label378,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Server_Priority_Entry);
      Set_Editable (Sched_Server_Dialog.Server_Priority_Entry, True);
      Set_Max_Length (Sched_Server_Dialog.Server_Priority_Entry, 0);
      Set_Text
        (Sched_Server_Dialog.Server_Priority_Entry,
         Priority'Image (Priority'First));
      Set_Visibility (Sched_Server_Dialog.Server_Priority_Entry, True);
      Set_Invisible_Char
        (Sched_Server_Dialog.Server_Priority_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sched_Server_Dialog.Priority_Table,
         Sched_Server_Dialog.Server_Priority_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Pre_Prior_Combo);
      Set_Value_In_List (Sched_Server_Dialog.Pre_Prior_Combo, False);
      Set_Use_Arrows (Sched_Server_Dialog.Pre_Prior_Combo, True);
      Set_Case_Sensitive (Sched_Server_Dialog.Pre_Prior_Combo, False);
      Set_Editable (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo), False);
      Set_Max_Length (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo), 0);
      Set_Text (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo), -("NO"));
      Set_Invisible_Char
        (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo), True);
      String_List.Append (Pre_Prior_Combo_Items, -("NO"));
      String_List.Append (Pre_Prior_Combo_Items, -("YES"));
      Combo.Set_Popdown_Strings
        (Sched_Server_Dialog.Pre_Prior_Combo,
         Pre_Prior_Combo_Items);
      Free_String_List (Pre_Prior_Combo_Items);
      Attach
        (Sched_Server_Dialog.Priority_Table,
         Sched_Server_Dialog.Pre_Prior_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Polling_Table, 4, 2, True);
      Set_Border_Width (Sched_Server_Dialog.Polling_Table, 5);
      Set_Row_Spacings (Sched_Server_Dialog.Polling_Table, 5);
      Set_Col_Spacings (Sched_Server_Dialog.Polling_Table, 3);
      Pack_Start
        (Sched_Server_Dialog.Vbox5,
         Sched_Server_Dialog.Polling_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Sched_Server_Dialog.Label116, -("Polling Best Overhead"));
      Set_Alignment (Sched_Server_Dialog.Label116, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label116, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label116, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label116, False);
      Set_Selectable (Sched_Server_Dialog.Label116, False);
      Set_Use_Markup (Sched_Server_Dialog.Label116, False);
      Set_Use_Underline (Sched_Server_Dialog.Label116, False);
      Attach
        (Sched_Server_Dialog.Polling_Table,
         Sched_Server_Dialog.Label116,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Polling_Period_Entry);
      Set_Editable (Sched_Server_Dialog.Polling_Period_Entry, True);
      Set_Max_Length (Sched_Server_Dialog.Polling_Period_Entry, 0);
      Set_Text (Sched_Server_Dialog.Polling_Period_Entry, -("0.0"));
      Set_Visibility (Sched_Server_Dialog.Polling_Period_Entry, True);
      Set_Invisible_Char
        (Sched_Server_Dialog.Polling_Period_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sched_Server_Dialog.Polling_Table,
         Sched_Server_Dialog.Polling_Period_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Polling_Wor_Over_Entry);
      Set_Editable (Sched_Server_Dialog.Polling_Wor_Over_Entry, True);
      Set_Max_Length (Sched_Server_Dialog.Polling_Wor_Over_Entry, 0);
      Set_Text (Sched_Server_Dialog.Polling_Wor_Over_Entry, -("0.0"));
      Set_Visibility (Sched_Server_Dialog.Polling_Wor_Over_Entry, True);
      Set_Invisible_Char
        (Sched_Server_Dialog.Polling_Wor_Over_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sched_Server_Dialog.Polling_Table,
         Sched_Server_Dialog.Polling_Wor_Over_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Polling_Bes_Over_Entry);
      Set_Editable (Sched_Server_Dialog.Polling_Bes_Over_Entry, True);
      Set_Max_Length (Sched_Server_Dialog.Polling_Bes_Over_Entry, 0);
      Set_Text (Sched_Server_Dialog.Polling_Bes_Over_Entry, -("0.0"));
      Set_Visibility (Sched_Server_Dialog.Polling_Bes_Over_Entry, True);
      Set_Invisible_Char
        (Sched_Server_Dialog.Polling_Bes_Over_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sched_Server_Dialog.Polling_Table,
         Sched_Server_Dialog.Polling_Bes_Over_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Polling_Avg_Over_Entry);
      Set_Editable (Sched_Server_Dialog.Polling_Avg_Over_Entry, True);
      Set_Max_Length (Sched_Server_Dialog.Polling_Avg_Over_Entry, 0);
      Set_Text (Sched_Server_Dialog.Polling_Avg_Over_Entry, -("0.0"));
      Set_Visibility (Sched_Server_Dialog.Polling_Avg_Over_Entry, True);
      Set_Invisible_Char
        (Sched_Server_Dialog.Polling_Avg_Over_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sched_Server_Dialog.Polling_Table,
         Sched_Server_Dialog.Polling_Avg_Over_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Label117, -("Polling Period"));
      Set_Alignment (Sched_Server_Dialog.Label117, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label117, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label117, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label117, False);
      Set_Selectable (Sched_Server_Dialog.Label117, False);
      Set_Use_Markup (Sched_Server_Dialog.Label117, False);
      Set_Use_Underline (Sched_Server_Dialog.Label117, False);
      Attach
        (Sched_Server_Dialog.Polling_Table,
         Sched_Server_Dialog.Label117,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Sched_Server_Dialog.Label118,
         -("Polling Average Overhead"));
      Set_Alignment (Sched_Server_Dialog.Label118, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label118, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label118, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label118, False);
      Set_Selectable (Sched_Server_Dialog.Label118, False);
      Set_Use_Markup (Sched_Server_Dialog.Label118, False);
      Set_Use_Underline (Sched_Server_Dialog.Label118, False);
      Attach
        (Sched_Server_Dialog.Polling_Table,
         Sched_Server_Dialog.Label118,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Label119, -("Polling Worst Overhead"));
      Set_Alignment (Sched_Server_Dialog.Label119, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label119, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label119, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label119, False);
      Set_Selectable (Sched_Server_Dialog.Label119, False);
      Set_Use_Markup (Sched_Server_Dialog.Label119, False);
      Set_Use_Underline (Sched_Server_Dialog.Label119, False);
      Attach
        (Sched_Server_Dialog.Polling_Table,
         Sched_Server_Dialog.Label119,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Sporadic_Table, 4, 2, True);
      Set_Border_Width (Sched_Server_Dialog.Sporadic_Table, 5);
      Set_Row_Spacings (Sched_Server_Dialog.Sporadic_Table, 5);
      Set_Col_Spacings (Sched_Server_Dialog.Sporadic_Table, 3);
      Pack_Start
        (Sched_Server_Dialog.Vbox5,
         Sched_Server_Dialog.Sporadic_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Sched_Server_Dialog.Label120, -("Replenishment Period"));
      Set_Alignment (Sched_Server_Dialog.Label120, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label120, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label120, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label120, False);
      Set_Selectable (Sched_Server_Dialog.Label120, False);
      Set_Use_Markup (Sched_Server_Dialog.Label120, False);
      Set_Use_Underline (Sched_Server_Dialog.Label120, False);
      Attach
        (Sched_Server_Dialog.Sporadic_Table,
         Sched_Server_Dialog.Label120,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Back_Prior_Entry);
      Set_Editable (Sched_Server_Dialog.Back_Prior_Entry, True);
      Set_Max_Length (Sched_Server_Dialog.Back_Prior_Entry, 0);
      Set_Text
        (Sched_Server_Dialog.Back_Prior_Entry,
         Priority'Image (Priority'First));
      Set_Visibility (Sched_Server_Dialog.Back_Prior_Entry, True);
      Set_Invisible_Char
        (Sched_Server_Dialog.Back_Prior_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sched_Server_Dialog.Sporadic_Table,
         Sched_Server_Dialog.Back_Prior_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Init_Capa_Entry);
      Set_Editable (Sched_Server_Dialog.Init_Capa_Entry, True);
      Set_Max_Length (Sched_Server_Dialog.Init_Capa_Entry, 0);
      Set_Text (Sched_Server_Dialog.Init_Capa_Entry, -("0.0"));
      Set_Visibility (Sched_Server_Dialog.Init_Capa_Entry, True);
      Set_Invisible_Char
        (Sched_Server_Dialog.Init_Capa_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sched_Server_Dialog.Sporadic_Table,
         Sched_Server_Dialog.Init_Capa_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Reple_Period_Entry);
      Set_Editable (Sched_Server_Dialog.Reple_Period_Entry, True);
      Set_Max_Length (Sched_Server_Dialog.Reple_Period_Entry, 0);
      Set_Text (Sched_Server_Dialog.Reple_Period_Entry, -("0.0"));
      Set_Visibility (Sched_Server_Dialog.Reple_Period_Entry, True);
      Set_Invisible_Char
        (Sched_Server_Dialog.Reple_Period_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sched_Server_Dialog.Sporadic_Table,
         Sched_Server_Dialog.Reple_Period_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Max_Pend_Reple_Entry);
      Set_Editable (Sched_Server_Dialog.Max_Pend_Reple_Entry, True);
      Set_Max_Length (Sched_Server_Dialog.Max_Pend_Reple_Entry, 0);
      Set_Text (Sched_Server_Dialog.Max_Pend_Reple_Entry, -("1"));
      Set_Visibility (Sched_Server_Dialog.Max_Pend_Reple_Entry, True);
      Set_Invisible_Char
        (Sched_Server_Dialog.Max_Pend_Reple_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sched_Server_Dialog.Sporadic_Table,
         Sched_Server_Dialog.Max_Pend_Reple_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Sched_Server_Dialog.Label122,
         -("Max Pending Replenishments"));
      Set_Alignment (Sched_Server_Dialog.Label122, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label122, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label122, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label122, False);
      Set_Selectable (Sched_Server_Dialog.Label122, False);
      Set_Use_Markup (Sched_Server_Dialog.Label122, False);
      Set_Use_Underline (Sched_Server_Dialog.Label122, False);
      Attach
        (Sched_Server_Dialog.Sporadic_Table,
         Sched_Server_Dialog.Label122,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Label123, -("Initial Capacity"));
      Set_Alignment (Sched_Server_Dialog.Label123, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label123, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label123, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label123, False);
      Set_Selectable (Sched_Server_Dialog.Label123, False);
      Set_Use_Markup (Sched_Server_Dialog.Label123, False);
      Set_Use_Underline (Sched_Server_Dialog.Label123, False);
      Attach
        (Sched_Server_Dialog.Sporadic_Table,
         Sched_Server_Dialog.Label123,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Label121, -("Background Priority"));
      Set_Alignment (Sched_Server_Dialog.Label121, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label121, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label121, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label121, False);
      Set_Selectable (Sched_Server_Dialog.Label121, False);
      Set_Use_Markup (Sched_Server_Dialog.Label121, False);
      Set_Use_Underline (Sched_Server_Dialog.Label121, False);
      Attach
        (Sched_Server_Dialog.Sporadic_Table,
         Sched_Server_Dialog.Label121,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Edf_Table, 2, 2, True);
      Set_Border_Width (Sched_Server_Dialog.Edf_Table, 5);
      Set_Row_Spacings (Sched_Server_Dialog.Edf_Table, 5);
      Set_Col_Spacings (Sched_Server_Dialog.Edf_Table, 3);
      Pack_Start
        (Sched_Server_Dialog.Vbox5,
         Sched_Server_Dialog.Edf_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Sched_Server_Dialog.Label369, -("Preassigned Deadline"));
      Set_Alignment (Sched_Server_Dialog.Label369, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label369, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label369, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label369, False);
      Set_Selectable (Sched_Server_Dialog.Label369, False);
      Set_Use_Markup (Sched_Server_Dialog.Label369, False);
      Set_Use_Underline (Sched_Server_Dialog.Label369, False);
      Attach
        (Sched_Server_Dialog.Edf_Table,
         Sched_Server_Dialog.Label369,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Label370, -("Deadline"));
      Set_Alignment (Sched_Server_Dialog.Label370, 0.95, 0.5);
      Set_Padding (Sched_Server_Dialog.Label370, 0, 0);
      Set_Justify (Sched_Server_Dialog.Label370, Justify_Center);
      Set_Line_Wrap (Sched_Server_Dialog.Label370, False);
      Set_Selectable (Sched_Server_Dialog.Label370, False);
      Set_Use_Markup (Sched_Server_Dialog.Label370, False);
      Set_Use_Underline (Sched_Server_Dialog.Label370, False);
      Attach
        (Sched_Server_Dialog.Edf_Table,
         Sched_Server_Dialog.Label370,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Deadline_Entry);
      Set_Editable (Sched_Server_Dialog.Deadline_Entry, True);
      Set_Max_Length (Sched_Server_Dialog.Deadline_Entry, 0);
      Set_Text (Sched_Server_Dialog.Deadline_Entry, -("0.0"));
      Set_Visibility (Sched_Server_Dialog.Deadline_Entry, True);
      Set_Invisible_Char
        (Sched_Server_Dialog.Deadline_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sched_Server_Dialog.Edf_Table,
         Sched_Server_Dialog.Deadline_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sched_Server_Dialog.Deadline_Combo);
      Set_Value_In_List (Sched_Server_Dialog.Deadline_Combo, False);
      Set_Use_Arrows (Sched_Server_Dialog.Deadline_Combo, True);
      Set_Case_Sensitive (Sched_Server_Dialog.Deadline_Combo, False);
      Set_Editable (Get_Entry (Sched_Server_Dialog.Deadline_Combo), False);
      Set_Max_Length (Get_Entry (Sched_Server_Dialog.Deadline_Combo), 0);
      Set_Text (Get_Entry (Sched_Server_Dialog.Deadline_Combo), -("NO"));
      Set_Invisible_Char
        (Get_Entry (Sched_Server_Dialog.Deadline_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Sched_Server_Dialog.Deadline_Combo), True);
      String_List.Append (Deadline_Combo_Items, -("NO"));
      String_List.Append (Deadline_Combo_Items, -("YES"));
      Combo.Set_Popdown_Strings
        (Sched_Server_Dialog.Deadline_Combo,
         Deadline_Combo_Items);
      Free_String_List (Deadline_Combo_Items);
      Attach
        (Sched_Server_Dialog.Edf_Table,
         Sched_Server_Dialog.Deadline_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      --     Entry_Callback.Connect
      --       (Get_Entry (Sched_Server_Dialog.Sync_Type_Combo), "changed",
      --        Entry_Callback.To_Marshaller
      --(On_Sync_Type_Entry_Changed'Access));

      Sched_Server_Dialog_Callback.Object_Connect
        (Get_Entry (Sched_Server_Dialog.Sync_Type_Combo),
         "changed",
         Sched_Server_Dialog_Callback.To_Marshaller
            (On_Sync_Type_Entry_Changed'Access),
         Sched_Server_Dialog);

      --     Entry_Callback.Connect
      --       (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo), "changed",
      --        Entry_Callback.To_Marshaller
      --(On_Policy_Type_Entry_Changed'Access));

      Sched_Server_Dialog_Callback.Object_Connect
        (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo),
         "changed",
         Sched_Server_Dialog_Callback.To_Marshaller
            (On_Policy_Type_Entry_Changed'Access),
         Sched_Server_Dialog);

   end Initialize;

end Sched_Server_Dialog_Pkg;
