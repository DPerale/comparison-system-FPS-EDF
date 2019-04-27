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
with Glib;                  use Glib;
with Gtk;                   use Gtk;
with Gdk.Types;             use Gdk.Types;
with Gtk.Widget;            use Gtk.Widget;
with Gtk.Enums;             use Gtk.Enums;
with Gtkada.Handlers;       use Gtkada.Handlers;
with Callbacks_Mast_Editor; use Callbacks_Mast_Editor;
with Mast_Editor_Intl;      use Mast_Editor_Intl;
with Mast;                  use Mast;
with Mast.IO;               use Mast.IO;
with Mast.Schedulers;       use Mast.Schedulers;
with Var_Strings;           use Var_Strings;
with Editor_Actions;        use Editor_Actions;

package body Wizard_Activity_Dialog_Pkg is

   procedure Gtk_New
     (Wizard_Activity_Dialog : out Wizard_Activity_Dialog_Access)
   is
   begin
      Wizard_Activity_Dialog := new Wizard_Activity_Dialog_Record;
      Wizard_Activity_Dialog_Pkg.Initialize (Wizard_Activity_Dialog);
   end Gtk_New;

   procedure Initialize
     (Wizard_Activity_Dialog : access Wizard_Activity_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Pixmaps_Dir           : constant String := "";
      Seh_Type_Combo_Items  : String_List.Glist;
      Scheduler_Combo_Items : String_List.Glist;

      Sche_Ref   : Mast.Schedulers.Scheduler_Ref;
      Sche_Index : Mast.Schedulers.Lists.Index;
      Sche_Name  : Var_Strings.Var_String;

   begin
      -- We search System Schedulers and show them in Scheduler_Combo
      Mast.Schedulers.Lists.Rewind (The_System.Schedulers, Sche_Index);
      for I in 1 .. Mast.Schedulers.Lists.Size (The_System.Schedulers) loop
         Mast.Schedulers.Lists.Get_Next_Item
           (Sche_Ref,
            The_System.Schedulers,
            Sche_Index);
         Sche_Name := Mast.Schedulers.Name (Sche_Ref);
         String_List.Append (Scheduler_Combo_Items, Name_Image (Sche_Name));
      end loop;

      Gtk.Dialog.Initialize (Wizard_Activity_Dialog);
      Set_Title
        (Wizard_Activity_Dialog,
         -"Editor Wizard Tool - Step 3 of 4");
      Set_Position (Wizard_Activity_Dialog, Win_Pos_Center_Always);
      Set_Modal (Wizard_Activity_Dialog, True);

      Gtk_New (Wizard_Activity_Dialog.Cancel_Button);
      Set_Relief (Wizard_Activity_Dialog.Cancel_Button, Relief_Normal);

      Gtk_New (Wizard_Activity_Dialog.Alignment15, 0.5, 0.5, 0.0, 0.0);

      Gtk_New_Hbox (Wizard_Activity_Dialog.Hbox91, False, 2);

      Gtk_New
        (Wizard_Activity_Dialog.Image19,
         "gtk-cancel",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Activity_Dialog.Image19, 0.5, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Image19, 0, 0);

      Pack_Start
        (Wizard_Activity_Dialog.Hbox91,
         Wizard_Activity_Dialog.Image19,
         Expand  => False,
         Fill    => False,
         Padding => 0);
      Gtk_New (Wizard_Activity_Dialog.Label561, -("Cancel"));
      Set_Alignment (Wizard_Activity_Dialog.Label561, 0.5, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Label561, 0, 0);
      Set_Justify (Wizard_Activity_Dialog.Label561, Justify_Left);
      Set_Line_Wrap (Wizard_Activity_Dialog.Label561, False);
      Set_Selectable (Wizard_Activity_Dialog.Label561, False);
      Set_Use_Markup (Wizard_Activity_Dialog.Label561, False);
      Set_Use_Underline (Wizard_Activity_Dialog.Label561, True);

      Pack_Start
        (Wizard_Activity_Dialog.Hbox91,
         Wizard_Activity_Dialog.Label561,
         Expand  => False,
         Fill    => False,
         Padding => 0);
      Add (Wizard_Activity_Dialog.Alignment15, Wizard_Activity_Dialog.Hbox91);
      Add
        (Wizard_Activity_Dialog.Cancel_Button,
         Wizard_Activity_Dialog.Alignment15);
      Set_Flags (Wizard_Activity_Dialog.Cancel_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Activity_Dialog),
         Wizard_Activity_Dialog.Cancel_Button);
      Gtk_New (Wizard_Activity_Dialog.Back_Button);
      Set_Relief (Wizard_Activity_Dialog.Back_Button, Relief_Normal);

      Gtk_New (Wizard_Activity_Dialog.Alignment16, 0.5, 0.5, 0.0, 0.0);

      Gtk_New_Hbox (Wizard_Activity_Dialog.Hbox92, False, 2);

      Gtk_New
        (Wizard_Activity_Dialog.Image20,
         "gtk-go-back",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Activity_Dialog.Image20, 0.5, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Image20, 0, 0);

      Pack_Start
        (Wizard_Activity_Dialog.Hbox92,
         Wizard_Activity_Dialog.Image20,
         Expand  => False,
         Fill    => False,
         Padding => 0);
      Gtk_New (Wizard_Activity_Dialog.Label562, -("Back"));
      Set_Alignment (Wizard_Activity_Dialog.Label562, 0.5, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Label562, 0, 0);
      Set_Justify (Wizard_Activity_Dialog.Label562, Justify_Left);
      Set_Line_Wrap (Wizard_Activity_Dialog.Label562, False);
      Set_Selectable (Wizard_Activity_Dialog.Label562, False);
      Set_Use_Markup (Wizard_Activity_Dialog.Label562, False);
      Set_Use_Underline (Wizard_Activity_Dialog.Label562, True);

      Pack_Start
        (Wizard_Activity_Dialog.Hbox92,
         Wizard_Activity_Dialog.Label562,
         Expand  => False,
         Fill    => False,
         Padding => 0);
      Add (Wizard_Activity_Dialog.Alignment16, Wizard_Activity_Dialog.Hbox92);
      Add
        (Wizard_Activity_Dialog.Back_Button,
         Wizard_Activity_Dialog.Alignment16);
      Set_Flags (Wizard_Activity_Dialog.Back_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Activity_Dialog),
         Wizard_Activity_Dialog.Back_Button);
      Gtk_New (Wizard_Activity_Dialog.Next_Button);
      Set_Relief (Wizard_Activity_Dialog.Next_Button, Relief_Normal);

      Gtk_New (Wizard_Activity_Dialog.Alignment17, 0.5, 0.5, 0.0, 0.0);

      Gtk_New_Hbox (Wizard_Activity_Dialog.Hbox93, False, 2);

      Gtk_New
        (Wizard_Activity_Dialog.Image21,
         "gtk-go-forward",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Activity_Dialog.Image21, 0.5, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Image21, 0, 0);

      Pack_Start
        (Wizard_Activity_Dialog.Hbox93,
         Wizard_Activity_Dialog.Image21,
         Expand  => False,
         Fill    => False,
         Padding => 0);
      Gtk_New (Wizard_Activity_Dialog.Label563, -("Next"));
      Set_Alignment (Wizard_Activity_Dialog.Label563, 0.5, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Label563, 0, 0);
      Set_Justify (Wizard_Activity_Dialog.Label563, Justify_Left);
      Set_Line_Wrap (Wizard_Activity_Dialog.Label563, False);
      Set_Selectable (Wizard_Activity_Dialog.Label563, False);
      Set_Use_Markup (Wizard_Activity_Dialog.Label563, False);
      Set_Use_Underline (Wizard_Activity_Dialog.Label563, True);

      Pack_Start
        (Wizard_Activity_Dialog.Hbox93,
         Wizard_Activity_Dialog.Label563,
         Expand  => False,
         Fill    => False,
         Padding => 0);
      Add (Wizard_Activity_Dialog.Alignment17, Wizard_Activity_Dialog.Hbox93);
      Add
        (Wizard_Activity_Dialog.Next_Button,
         Wizard_Activity_Dialog.Alignment17);
      Set_Flags (Wizard_Activity_Dialog.Next_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Activity_Dialog),
         Wizard_Activity_Dialog.Next_Button);
      Gtk_New (Wizard_Activity_Dialog.Table4, 6, 6, False);
      Set_Row_Spacings (Wizard_Activity_Dialog.Table4, 0);
      Set_Col_Spacings (Wizard_Activity_Dialog.Table4, 0);

      Gtk_New (Wizard_Activity_Dialog.Image, Pixmaps_Dir & "mast_logo.xpm");
      Set_Alignment (Wizard_Activity_Dialog.Image, 0.5, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Image, 0, 0);

      Attach
        (Wizard_Activity_Dialog.Table4,
         Wizard_Activity_Dialog.Image,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Yoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);
      Gtk_New
        (Wizard_Activity_Dialog.Label,
         -("Please, select type of Activity and " &
           ASCII.LF &
           "configure its parameters ..."));
      Set_Alignment (Wizard_Activity_Dialog.Label, 0.0, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Label, 0, 0);
      Set_Justify (Wizard_Activity_Dialog.Label, Justify_Left);
      Set_Line_Wrap (Wizard_Activity_Dialog.Label, True);
      Set_Selectable (Wizard_Activity_Dialog.Label, False);
      Set_Use_Markup (Wizard_Activity_Dialog.Label, False);
      Set_Use_Underline (Wizard_Activity_Dialog.Label, False);

      Attach
        (Wizard_Activity_Dialog.Table4,
         Wizard_Activity_Dialog.Label,
         Left_Attach   => 2,
         Right_Attach  => 6,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);
      Gtk_New (Wizard_Activity_Dialog.Frame4);
      Set_Border_Width (Wizard_Activity_Dialog.Frame4, 10);
      Set_Label_Align (Wizard_Activity_Dialog.Frame4, 0.0, 0.5);
      Set_Shadow_Type (Wizard_Activity_Dialog.Frame4, Shadow_Etched_In);

      Gtk_New_Vbox (Wizard_Activity_Dialog.Vbox41, False, 0);

      Gtk_New (Wizard_Activity_Dialog.Table1, 1, 2, True);
      Set_Border_Width (Wizard_Activity_Dialog.Table1, 5);
      Set_Row_Spacings (Wizard_Activity_Dialog.Table1, 3);
      Set_Col_Spacings (Wizard_Activity_Dialog.Table1, 3);

      Gtk_New (Wizard_Activity_Dialog.Label581, -("Type"));
      Set_Alignment (Wizard_Activity_Dialog.Label581, 0.95, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Label581, 0, 0);
      Set_Justify (Wizard_Activity_Dialog.Label581, Justify_Center);
      Set_Line_Wrap (Wizard_Activity_Dialog.Label581, False);
      Set_Selectable (Wizard_Activity_Dialog.Label581, False);
      Set_Use_Markup (Wizard_Activity_Dialog.Label581, False);
      Set_Use_Underline (Wizard_Activity_Dialog.Label581, False);

      Attach
        (Wizard_Activity_Dialog.Table1,
         Wizard_Activity_Dialog.Label581,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);
      Gtk_New (Wizard_Activity_Dialog.Seh_Type_Combo);
      Set_Value_In_List (Wizard_Activity_Dialog.Seh_Type_Combo, False);
      Set_Use_Arrows (Wizard_Activity_Dialog.Seh_Type_Combo, True);
      Set_Case_Sensitive (Wizard_Activity_Dialog.Seh_Type_Combo, False);
      Set_Editable (Get_Entry (Wizard_Activity_Dialog.Seh_Type_Combo), False);
      Set_Has_Frame (Get_Entry (Wizard_Activity_Dialog.Seh_Type_Combo), True);
      Set_Max_Length (Get_Entry (Wizard_Activity_Dialog.Seh_Type_Combo), 0);
      Set_Text
        (Get_Entry (Wizard_Activity_Dialog.Seh_Type_Combo),
         -("Activity"));
      Set_Invisible_Char
        (Get_Entry (Wizard_Activity_Dialog.Seh_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Wizard_Activity_Dialog.Seh_Type_Combo), True);
      String_List.Append (Seh_Type_Combo_Items, -("Activity"));
      String_List.Append
        (Seh_Type_Combo_Items,
         -("System Timed Activity"));
      Combo.Set_Popdown_Strings
        (Wizard_Activity_Dialog.Seh_Type_Combo,
         Seh_Type_Combo_Items);
      Free_String_List (Seh_Type_Combo_Items);

      Attach
        (Wizard_Activity_Dialog.Table1,
         Wizard_Activity_Dialog.Seh_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);
      Pack_Start
        (Wizard_Activity_Dialog.Vbox41,
         Wizard_Activity_Dialog.Table1,
         Expand  => False,
         Fill    => False,
         Padding => 5);
      Gtk_New (Wizard_Activity_Dialog.Op_Frame);
      Set_Border_Width (Wizard_Activity_Dialog.Op_Frame, 10);
      Set_Label_Align (Wizard_Activity_Dialog.Op_Frame, 0.5, 0.5);
      Set_Shadow_Type (Wizard_Activity_Dialog.Op_Frame, Shadow_Etched_In);

      Gtk_New (Wizard_Activity_Dialog.Op_Table, 2, 2, True);
      Set_Border_Width (Wizard_Activity_Dialog.Op_Table, 5);
      Set_Row_Spacings (Wizard_Activity_Dialog.Op_Table, 3);
      Set_Col_Spacings (Wizard_Activity_Dialog.Op_Table, 3);

      Gtk_New (Wizard_Activity_Dialog.Label583, -("Worst Execution Time"));
      Set_Alignment (Wizard_Activity_Dialog.Label583, 0.95, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Label583, 0, 0);
      Set_Justify (Wizard_Activity_Dialog.Label583, Justify_Center);
      Set_Line_Wrap (Wizard_Activity_Dialog.Label583, False);
      Set_Selectable (Wizard_Activity_Dialog.Label583, False);
      Set_Use_Markup (Wizard_Activity_Dialog.Label583, False);
      Set_Use_Underline (Wizard_Activity_Dialog.Label583, False);

      Attach
        (Wizard_Activity_Dialog.Op_Table,
         Wizard_Activity_Dialog.Label583,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);
      Gtk_New (Wizard_Activity_Dialog.Wor_Exec_Time_Entry);
      Set_Editable (Wizard_Activity_Dialog.Wor_Exec_Time_Entry, True);
      Set_Max_Length (Wizard_Activity_Dialog.Wor_Exec_Time_Entry, 0);
      Set_Text
        (Wizard_Activity_Dialog.Wor_Exec_Time_Entry,
         Execution_Time_Image (Mast.Large_Execution_Time));
      Set_Visibility (Wizard_Activity_Dialog.Wor_Exec_Time_Entry, True);
      Set_Invisible_Char
        (Wizard_Activity_Dialog.Wor_Exec_Time_Entry,
         UTF8_Get_Char ("*"));

      Attach
        (Wizard_Activity_Dialog.Op_Table,
         Wizard_Activity_Dialog.Wor_Exec_Time_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);
      Gtk_New (Wizard_Activity_Dialog.Op_Name_Entry);
      Set_Editable (Wizard_Activity_Dialog.Op_Name_Entry, True);
      Set_Max_Length (Wizard_Activity_Dialog.Op_Name_Entry, 0);
      Set_Text (Wizard_Activity_Dialog.Op_Name_Entry, -(""));
      Set_Visibility (Wizard_Activity_Dialog.Op_Name_Entry, True);
      Set_Invisible_Char
        (Wizard_Activity_Dialog.Op_Name_Entry,
         UTF8_Get_Char ("*"));

      Attach
        (Wizard_Activity_Dialog.Op_Table,
         Wizard_Activity_Dialog.Op_Name_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);
      Gtk_New (Wizard_Activity_Dialog.Label582, -("Operation Name"));
      Set_Alignment (Wizard_Activity_Dialog.Label582, 0.95, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Label582, 0, 0);
      Set_Justify (Wizard_Activity_Dialog.Label582, Justify_Center);
      Set_Line_Wrap (Wizard_Activity_Dialog.Label582, False);
      Set_Selectable (Wizard_Activity_Dialog.Label582, False);
      Set_Use_Markup (Wizard_Activity_Dialog.Label582, False);
      Set_Use_Underline (Wizard_Activity_Dialog.Label582, False);

      Attach
        (Wizard_Activity_Dialog.Op_Table,
         Wizard_Activity_Dialog.Label582,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);
      Add (Wizard_Activity_Dialog.Op_Frame, Wizard_Activity_Dialog.Op_Table);
      Gtk_New
        (Wizard_Activity_Dialog.Op_Frame_Label,
         -("Operation Parameters  "));
      Set_Alignment (Wizard_Activity_Dialog.Op_Frame_Label, 0.5, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Op_Frame_Label, 0, 0);
      Set_Justify (Wizard_Activity_Dialog.Op_Frame_Label, Justify_Left);
      Set_Line_Wrap (Wizard_Activity_Dialog.Op_Frame_Label, False);
      Set_Selectable (Wizard_Activity_Dialog.Op_Frame_Label, False);
      Set_Use_Markup (Wizard_Activity_Dialog.Op_Frame_Label, False);
      Set_Use_Underline (Wizard_Activity_Dialog.Op_Frame_Label, False);
      Set_Label_Widget
        (Wizard_Activity_Dialog.Op_Frame,
         Wizard_Activity_Dialog.Op_Frame_Label);

      Pack_Start
        (Wizard_Activity_Dialog.Vbox41,
         Wizard_Activity_Dialog.Op_Frame,
         Expand  => True,
         Fill    => True,
         Padding => 0);
      Gtk_New (Wizard_Activity_Dialog.Serv_Frame);
      Set_Border_Width (Wizard_Activity_Dialog.Serv_Frame, 10);
      Set_Label_Align (Wizard_Activity_Dialog.Serv_Frame, 0.5, 0.5);
      Set_Shadow_Type (Wizard_Activity_Dialog.Serv_Frame, Shadow_Etched_In);

      Gtk_New (Wizard_Activity_Dialog.Serv_Table, 3, 2, True);
      Set_Border_Width (Wizard_Activity_Dialog.Serv_Table, 5);
      Set_Row_Spacings (Wizard_Activity_Dialog.Serv_Table, 3);
      Set_Col_Spacings (Wizard_Activity_Dialog.Serv_Table, 3);

      Gtk_New (Wizard_Activity_Dialog.Label609, -("Priority"));
      Set_Alignment (Wizard_Activity_Dialog.Label609, 0.95, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Label609, 0, 0);
      Set_Justify (Wizard_Activity_Dialog.Label609, Justify_Center);
      Set_Line_Wrap (Wizard_Activity_Dialog.Label609, False);
      Set_Selectable (Wizard_Activity_Dialog.Label609, False);
      Set_Use_Markup (Wizard_Activity_Dialog.Label609, False);
      Set_Use_Underline (Wizard_Activity_Dialog.Label609, False);

      Attach
        (Wizard_Activity_Dialog.Serv_Table,
         Wizard_Activity_Dialog.Label609,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);
      Gtk_New (Wizard_Activity_Dialog.Label610, -("Server Name"));
      Set_Alignment (Wizard_Activity_Dialog.Label610, 0.95, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Label610, 0, 0);
      Set_Justify (Wizard_Activity_Dialog.Label610, Justify_Center);
      Set_Line_Wrap (Wizard_Activity_Dialog.Label610, False);
      Set_Selectable (Wizard_Activity_Dialog.Label610, False);
      Set_Use_Markup (Wizard_Activity_Dialog.Label610, False);
      Set_Use_Underline (Wizard_Activity_Dialog.Label610, False);

      Attach
        (Wizard_Activity_Dialog.Serv_Table,
         Wizard_Activity_Dialog.Label610,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);
      Gtk_New (Wizard_Activity_Dialog.Server_Name_Entry);
      Set_Editable (Wizard_Activity_Dialog.Server_Name_Entry, True);
      Set_Max_Length (Wizard_Activity_Dialog.Server_Name_Entry, 0);
      Set_Text (Wizard_Activity_Dialog.Server_Name_Entry, -(""));
      Set_Visibility (Wizard_Activity_Dialog.Server_Name_Entry, True);
      Set_Invisible_Char
        (Wizard_Activity_Dialog.Server_Name_Entry,
         UTF8_Get_Char ("*"));

      Attach
        (Wizard_Activity_Dialog.Serv_Table,
         Wizard_Activity_Dialog.Server_Name_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);
      Gtk_New (Wizard_Activity_Dialog.Server_Priority_Entry);
      Set_Editable (Wizard_Activity_Dialog.Server_Priority_Entry, True);
      Set_Max_Length (Wizard_Activity_Dialog.Server_Priority_Entry, 0);
      Set_Text
        (Wizard_Activity_Dialog.Server_Priority_Entry,
         Priority'Image (Priority'First));
      Set_Visibility (Wizard_Activity_Dialog.Server_Priority_Entry, True);
      Set_Invisible_Char
        (Wizard_Activity_Dialog.Server_Priority_Entry,
         UTF8_Get_Char ("*"));

      Attach
        (Wizard_Activity_Dialog.Serv_Table,
         Wizard_Activity_Dialog.Server_Priority_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);
      Gtk_New (Wizard_Activity_Dialog.Label638, -("Scheduler"));
      Set_Alignment (Wizard_Activity_Dialog.Label638, 0.95, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Label638, 0, 0);
      Set_Justify (Wizard_Activity_Dialog.Label638, Justify_Center);
      Set_Line_Wrap (Wizard_Activity_Dialog.Label638, False);
      Set_Selectable (Wizard_Activity_Dialog.Label638, False);
      Set_Use_Markup (Wizard_Activity_Dialog.Label638, False);
      Set_Use_Underline (Wizard_Activity_Dialog.Label638, False);

      Attach
        (Wizard_Activity_Dialog.Serv_Table,
         Wizard_Activity_Dialog.Label638,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);
      Gtk_New (Wizard_Activity_Dialog.Scheduler_Combo);
      Set_Value_In_List (Wizard_Activity_Dialog.Scheduler_Combo, False);
      Set_Use_Arrows (Wizard_Activity_Dialog.Scheduler_Combo, True);
      Set_Case_Sensitive (Wizard_Activity_Dialog.Scheduler_Combo, False);
      Set_Editable
        (Get_Entry (Wizard_Activity_Dialog.Scheduler_Combo),
         False);
      Set_Has_Frame
        (Get_Entry (Wizard_Activity_Dialog.Scheduler_Combo),
         True);
      Set_Max_Length (Get_Entry (Wizard_Activity_Dialog.Scheduler_Combo), 0);
      Set_Text
        (Get_Entry (Wizard_Activity_Dialog.Scheduler_Combo),
         -("(NONE)")); -- Changed to NONE
      Set_Invisible_Char
        (Get_Entry (Wizard_Activity_Dialog.Scheduler_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Wizard_Activity_Dialog.Scheduler_Combo),
         True);
      ------------------
      Combo.Set_Popdown_Strings
        (Wizard_Activity_Dialog.Scheduler_Combo,
         Scheduler_Combo_Items);
      Free_String_List (Scheduler_Combo_Items);
      ------------------

      Attach
        (Wizard_Activity_Dialog.Serv_Table,
         Wizard_Activity_Dialog.Scheduler_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);
      Add
        (Wizard_Activity_Dialog.Serv_Frame,
         Wizard_Activity_Dialog.Serv_Table);
      Gtk_New
        (Wizard_Activity_Dialog.Serv_Frame_Label,
         -("Server Parameters  "));
      Set_Alignment (Wizard_Activity_Dialog.Serv_Frame_Label, 0.5, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Serv_Frame_Label, 0, 0);
      Set_Justify (Wizard_Activity_Dialog.Serv_Frame_Label, Justify_Left);
      Set_Line_Wrap (Wizard_Activity_Dialog.Serv_Frame_Label, False);
      Set_Selectable (Wizard_Activity_Dialog.Serv_Frame_Label, False);
      Set_Use_Markup (Wizard_Activity_Dialog.Serv_Frame_Label, False);
      Set_Use_Underline (Wizard_Activity_Dialog.Serv_Frame_Label, False);
      Set_Label_Widget
        (Wizard_Activity_Dialog.Serv_Frame,
         Wizard_Activity_Dialog.Serv_Frame_Label);

      Pack_Start
        (Wizard_Activity_Dialog.Vbox41,
         Wizard_Activity_Dialog.Serv_Frame,
         Expand  => True,
         Fill    => True,
         Padding => 0);
      Add (Wizard_Activity_Dialog.Frame4, Wizard_Activity_Dialog.Vbox41);
      Gtk_New
        (Wizard_Activity_Dialog.Frame_Label,
         -("ACTIVITY PARAMETERS  "));
      Set_Alignment (Wizard_Activity_Dialog.Frame_Label, 0.5, 0.5);
      Set_Padding (Wizard_Activity_Dialog.Frame_Label, 0, 0);
      Set_Justify (Wizard_Activity_Dialog.Frame_Label, Justify_Left);
      Set_Line_Wrap (Wizard_Activity_Dialog.Frame_Label, False);
      Set_Selectable (Wizard_Activity_Dialog.Frame_Label, False);
      Set_Use_Markup (Wizard_Activity_Dialog.Frame_Label, False);
      Set_Use_Underline (Wizard_Activity_Dialog.Frame_Label, False);
      Set_Label_Widget
        (Wizard_Activity_Dialog.Frame4,
         Wizard_Activity_Dialog.Frame_Label);

      Attach
        (Wizard_Activity_Dialog.Table4,
         Wizard_Activity_Dialog.Frame4,
         Left_Attach   => 0,
         Right_Attach  => 6,
         Top_Attach    => 1,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);
      Pack_Start
        (Get_Vbox (Wizard_Activity_Dialog),
         Wizard_Activity_Dialog.Table4,
         Expand  => True,
         Fill    => True,
         Padding => 0);
   end Initialize;

end Wizard_Activity_Dialog_Pkg;
