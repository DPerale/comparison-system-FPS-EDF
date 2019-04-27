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
with Sop_Dialog_Pkg.Callbacks; use Sop_Dialog_Pkg.Callbacks;

with Mast;    use Mast;
with Mast.IO; use Mast.IO;

package body Sop_Dialog_Pkg is

   procedure Gtk_New (Sop_Dialog : out Sop_Dialog_Access) is
   begin
      Sop_Dialog := new Sop_Dialog_Record;
      Sop_Dialog_Pkg.Initialize (Sop_Dialog);
   end Gtk_New;

   procedure Initialize (Sop_Dialog : access Sop_Dialog_Record'Class) is
      pragma Suppress (All_Checks);
      Pixmaps_Dir : constant String := "pixmaps/";
      --Op_Type_Combo_Items : String_List.Glist;
      Overrid_Param_Type_Combo_Items : String_List.Glist;

   begin
      Gtk.Dialog.Initialize (Sop_Dialog);
      Set_Title (Sop_Dialog, -"Simple Operation Parameters");
      Set_Position (Sop_Dialog, Win_Pos_Center_Always);
      Set_Modal (Sop_Dialog, False);

      Set_Policy (Sop_Dialog, False, False, False);

      Gtk_New_Hbox (Sop_Dialog.Hbox64, True, 0);
      Pack_Start (Get_Action_Area (Sop_Dialog), Sop_Dialog.Hbox64);

      Gtk_New (Sop_Dialog.Ok_Button, -"OK");
      Set_Relief (Sop_Dialog.Ok_Button, Relief_Normal);
      Pack_Start
        (Sop_Dialog.Hbox64,
         Sop_Dialog.Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 150);

      Gtk_New (Sop_Dialog.Cancel_Button, -"Cancel");
      Set_Relief (Sop_Dialog.Cancel_Button, Relief_Normal);
      Pack_End
        (Sop_Dialog.Hbox64,
         Sop_Dialog.Cancel_Button,
         Expand  => True,
         Fill    => True,
         Padding => 150);
      --     Button_Callback.Connect
      --       (Sop_Dialog.Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Sop_Cancel_Button_Clicked'Access), False);

      Dialog_Callback.Object_Connect
        (Sop_Dialog.Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller (On_Sop_Cancel_Button_Clicked'Access),
         Sop_Dialog);

      Gtk_New_Hbox (Sop_Dialog.Hbox65, False, 10);
      Pack_Start
        (Get_Vbox (Sop_Dialog),
         Sop_Dialog.Hbox65,
         Expand  => False,
         Fill    => False,
         Padding => 5);

      Gtk_New_Vbox (Sop_Dialog.Vbox28, False, 5);
      Pack_Start
        (Sop_Dialog.Hbox65,
         Sop_Dialog.Vbox28,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Sop_Dialog.Table1, 7, 2, True);
      Set_Row_Spacings (Sop_Dialog.Table1, 5);
      Set_Col_Spacings (Sop_Dialog.Table1, 5);
      Pack_Start
        (Sop_Dialog.Vbox28,
         Sop_Dialog.Table1,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Sop_Dialog.Label404, -("Operation Name"));
      Set_Alignment (Sop_Dialog.Label404, 0.95, 0.5);
      Set_Padding (Sop_Dialog.Label404, 0, 0);
      Set_Justify (Sop_Dialog.Label404, Justify_Center);
      Set_Line_Wrap (Sop_Dialog.Label404, False);
      Set_Selectable (Sop_Dialog.Label404, False);
      Set_Use_Markup (Sop_Dialog.Label404, False);
      Set_Use_Underline (Sop_Dialog.Label404, False);
      Attach
        (Sop_Dialog.Table1,
         Sop_Dialog.Label404,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Label405, -("Operation Type"));
      Set_Alignment (Sop_Dialog.Label405, 0.95, 0.5);
      Set_Padding (Sop_Dialog.Label405, 0, 0);
      Set_Justify (Sop_Dialog.Label405, Justify_Center);
      Set_Line_Wrap (Sop_Dialog.Label405, False);
      Set_Selectable (Sop_Dialog.Label405, False);
      Set_Use_Markup (Sop_Dialog.Label405, False);
      Set_Use_Underline (Sop_Dialog.Label405, False);
      Attach
        (Sop_Dialog.Table1,
         Sop_Dialog.Label405,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Label406, -("Worst Execution Time"));
      Set_Alignment (Sop_Dialog.Label406, 0.95, 0.5);
      Set_Padding (Sop_Dialog.Label406, 0, 0);
      Set_Justify (Sop_Dialog.Label406, Justify_Center);
      Set_Line_Wrap (Sop_Dialog.Label406, False);
      Set_Selectable (Sop_Dialog.Label406, False);
      Set_Use_Markup (Sop_Dialog.Label406, False);
      Set_Use_Underline (Sop_Dialog.Label406, False);
      Attach
        (Sop_Dialog.Table1,
         Sop_Dialog.Label406,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Label407, -("Average Execution Time"));
      Set_Alignment (Sop_Dialog.Label407, 0.95, 0.5);
      Set_Padding (Sop_Dialog.Label407, 0, 0);
      Set_Justify (Sop_Dialog.Label407, Justify_Center);
      Set_Line_Wrap (Sop_Dialog.Label407, False);
      Set_Selectable (Sop_Dialog.Label407, False);
      Set_Use_Markup (Sop_Dialog.Label407, False);
      Set_Use_Underline (Sop_Dialog.Label407, False);
      Attach
        (Sop_Dialog.Table1,
         Sop_Dialog.Label407,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Label408, -("Best Execution Time"));
      Set_Alignment (Sop_Dialog.Label408, 0.95, 0.5);
      Set_Padding (Sop_Dialog.Label408, 0, 0);
      Set_Justify (Sop_Dialog.Label408, Justify_Center);
      Set_Line_Wrap (Sop_Dialog.Label408, False);
      Set_Selectable (Sop_Dialog.Label408, False);
      Set_Use_Markup (Sop_Dialog.Label408, False);
      Set_Use_Underline (Sop_Dialog.Label408, False);
      Attach
        (Sop_Dialog.Table1,
         Sop_Dialog.Label408,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Label410, -("Parameters Type"));
      Set_Alignment (Sop_Dialog.Label410, 0.95, 0.5);
      Set_Padding (Sop_Dialog.Label410, 0, 0);
      Set_Justify (Sop_Dialog.Label410, Justify_Center);
      Set_Line_Wrap (Sop_Dialog.Label410, False);
      Set_Selectable (Sop_Dialog.Label410, False);
      Set_Use_Markup (Sop_Dialog.Label410, False);
      Set_Use_Underline (Sop_Dialog.Label410, False);
      Attach
        (Sop_Dialog.Table1,
         Sop_Dialog.Label410,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 6,
         Bottom_Attach => 7,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Sop_Dialog.Label409,
         -("OVERRIDDEN SCHEDULING PARAMETERS:"));
      Set_Alignment (Sop_Dialog.Label409, 0.5, 0.5);
      Set_Padding (Sop_Dialog.Label409, 0, 5);
      Set_Justify (Sop_Dialog.Label409, Justify_Center);
      Set_Line_Wrap (Sop_Dialog.Label409, False);
      Set_Selectable (Sop_Dialog.Label409, False);
      Set_Use_Markup (Sop_Dialog.Label409, False);
      Set_Use_Underline (Sop_Dialog.Label409, False);
      Attach
        (Sop_Dialog.Table1,
         Sop_Dialog.Label409,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 5,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Op_Name_Entry);
      Set_Editable (Sop_Dialog.Op_Name_Entry, True);
      Set_Max_Length (Sop_Dialog.Op_Name_Entry, 0);
      Set_Text (Sop_Dialog.Op_Name_Entry, -(""));
      Set_Visibility (Sop_Dialog.Op_Name_Entry, True);
      Set_Invisible_Char (Sop_Dialog.Op_Name_Entry, UTF8_Get_Char ("*"));
      Attach
        (Sop_Dialog.Table1,
         Sop_Dialog.Op_Name_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Wor_Exec_Time_Entry);
      Set_Editable (Sop_Dialog.Wor_Exec_Time_Entry, True);
      Set_Max_Length (Sop_Dialog.Wor_Exec_Time_Entry, 0);
      Set_Text
        (Sop_Dialog.Wor_Exec_Time_Entry,
         Execution_Time_Image (Mast.Large_Execution_Time));
      Set_Visibility (Sop_Dialog.Wor_Exec_Time_Entry, True);
      Set_Invisible_Char
        (Sop_Dialog.Wor_Exec_Time_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sop_Dialog.Table1,
         Sop_Dialog.Wor_Exec_Time_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Avg_Exec_Time_Entry);
      Set_Editable (Sop_Dialog.Avg_Exec_Time_Entry, True);
      Set_Max_Length (Sop_Dialog.Avg_Exec_Time_Entry, 0);
      Set_Text (Sop_Dialog.Avg_Exec_Time_Entry, -(""));
      Set_Visibility (Sop_Dialog.Avg_Exec_Time_Entry, True);
      Set_Invisible_Char
        (Sop_Dialog.Avg_Exec_Time_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sop_Dialog.Table1,
         Sop_Dialog.Avg_Exec_Time_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Bes_Exec_Time_Entry);
      Set_Editable (Sop_Dialog.Bes_Exec_Time_Entry, True);
      Set_Max_Length (Sop_Dialog.Bes_Exec_Time_Entry, 0);
      Set_Text (Sop_Dialog.Bes_Exec_Time_Entry, -("0.0"));
      Set_Visibility (Sop_Dialog.Bes_Exec_Time_Entry, True);
      Set_Invisible_Char
        (Sop_Dialog.Bes_Exec_Time_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sop_Dialog.Table1,
         Sop_Dialog.Bes_Exec_Time_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Op_Type_Combo);
      Set_Value_In_List (Sop_Dialog.Op_Type_Combo, False);
      Set_Use_Arrows (Sop_Dialog.Op_Type_Combo, True);
      Set_Case_Sensitive (Sop_Dialog.Op_Type_Combo, False);
      Set_Editable (Get_Entry (Sop_Dialog.Op_Type_Combo), False);
      Set_Has_Frame (Get_Entry (Sop_Dialog.Op_Type_Combo), True);
      Set_Max_Length (Get_Entry (Sop_Dialog.Op_Type_Combo), 0);
      Set_Text (Get_Entry (Sop_Dialog.Op_Type_Combo), -("Simple"));
      Set_Invisible_Char
        (Get_Entry (Sop_Dialog.Op_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Sop_Dialog.Op_Type_Combo), True);
      --String_List.Append (Op_Type_Combo_Items, -("Simple"));
      String_List.Prepend (Op_Type_Combo_Items, -("Simple"));
      --String_List.Append (Op_Type_Combo_Items, -("Enclosing"));
      Combo.Set_Popdown_Strings
        (Sop_Dialog.Op_Type_Combo,
         Op_Type_Combo_Items);
      Free_String_List (Op_Type_Combo_Items);
      Attach
        (Sop_Dialog.Table1,
         Sop_Dialog.Op_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Overrid_Param_Type_Combo);
      Set_Value_In_List (Sop_Dialog.Overrid_Param_Type_Combo, False);
      Set_Use_Arrows (Sop_Dialog.Overrid_Param_Type_Combo, True);
      Set_Case_Sensitive (Sop_Dialog.Overrid_Param_Type_Combo, False);
      Set_Editable (Get_Entry (Sop_Dialog.Overrid_Param_Type_Combo), False);
      Set_Has_Frame (Get_Entry (Sop_Dialog.Overrid_Param_Type_Combo), True);
      Set_Max_Length (Get_Entry (Sop_Dialog.Overrid_Param_Type_Combo), 0);
      Set_Text
        (Get_Entry (Sop_Dialog.Overrid_Param_Type_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Sop_Dialog.Overrid_Param_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Sop_Dialog.Overrid_Param_Type_Combo), True);
      String_List.Append (Overrid_Param_Type_Combo_Items, -("(NONE)"));
      String_List.Append
        (Overrid_Param_Type_Combo_Items,
         -("Fixed Priority"));
      String_List.Append
        (Overrid_Param_Type_Combo_Items,
         -("Permanent Fixed Priority"));
      Combo.Set_Popdown_Strings
        (Sop_Dialog.Overrid_Param_Type_Combo,
         Overrid_Param_Type_Combo_Items);
      Free_String_List (Overrid_Param_Type_Combo_Items);
      Attach
        (Sop_Dialog.Table1,
         Sop_Dialog.Overrid_Param_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 6,
         Bottom_Attach => 7,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Overrid_Prior_Table, 1, 2, True);
      Set_Row_Spacings (Sop_Dialog.Overrid_Prior_Table, 5);
      Set_Col_Spacings (Sop_Dialog.Overrid_Prior_Table, 5);
      Pack_Start
        (Sop_Dialog.Vbox28,
         Sop_Dialog.Overrid_Prior_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Sop_Dialog.Label421, -("Overridden Priority"));
      Set_Alignment (Sop_Dialog.Label421, 0.95, 0.5);
      Set_Padding (Sop_Dialog.Label421, 0, 0);
      Set_Justify (Sop_Dialog.Label421, Justify_Center);
      Set_Line_Wrap (Sop_Dialog.Label421, False);
      Set_Selectable (Sop_Dialog.Label421, False);
      Set_Use_Markup (Sop_Dialog.Label421, False);
      Set_Use_Underline (Sop_Dialog.Label421, False);
      Attach
        (Sop_Dialog.Overrid_Prior_Table,
         Sop_Dialog.Label421,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Overrid_Prior_Entry);
      Set_Editable (Sop_Dialog.Overrid_Prior_Entry, True);
      Set_Max_Length (Sop_Dialog.Overrid_Prior_Entry, 0);
      Set_Text
        (Sop_Dialog.Overrid_Prior_Entry,
         Priority'Image (Priority'First));
      Set_Visibility (Sop_Dialog.Overrid_Prior_Entry, True);
      Set_Invisible_Char
        (Sop_Dialog.Overrid_Prior_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Sop_Dialog.Overrid_Prior_Table,
         Sop_Dialog.Overrid_Prior_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New_Vseparator (Sop_Dialog.Vseparator5);
      Pack_Start
        (Sop_Dialog.Hbox65,
         Sop_Dialog.Vseparator5,
         Expand  => False,
         Fill    => True,
         Padding => 0);

      Gtk_New_Vbox (Sop_Dialog.Vbox29, False, 0);
      Pack_Start
        (Sop_Dialog.Hbox65,
         Sop_Dialog.Vbox29,
         Expand  => False,
         Fill    => True,
         Padding => 0);

      Gtk_New (Sop_Dialog.Table2, 6, 2, False);
      Set_Row_Spacings (Sop_Dialog.Table2, 5);
      Set_Col_Spacings (Sop_Dialog.Table2, 10);
      Pack_Start
        (Sop_Dialog.Vbox29,
         Sop_Dialog.Table2,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Sop_Dialog.Add_Res_Button, -"Add Shared Resource");
      Set_Relief (Sop_Dialog.Add_Res_Button, Relief_Normal);
      Attach
        (Sop_Dialog.Table2,
         Sop_Dialog.Add_Res_Button,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 5,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Remove_Res_Button, -"Remove Shared Resource");
      Set_Relief (Sop_Dialog.Remove_Res_Button, Relief_Normal);
      Attach
        (Sop_Dialog.Table2,
         Sop_Dialog.Remove_Res_Button,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 5,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Lock_Frame);
      Set_Label_Align (Sop_Dialog.Lock_Frame, 0.5, 0.5);
      Set_Shadow_Type (Sop_Dialog.Lock_Frame, Shadow_Etched_In);
      Attach
        (Sop_Dialog.Table2,
         Sop_Dialog.Lock_Frame,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Label635, -(" Locked Shared Resources "));
      Set_Alignment (Sop_Dialog.Label635, 0.5, 0.5);
      Set_Padding (Sop_Dialog.Label635, 0, 0);
      Set_Justify (Sop_Dialog.Label635, Justify_Left);
      Set_Line_Wrap (Sop_Dialog.Label635, False);
      Set_Selectable (Sop_Dialog.Label635, False);
      Set_Use_Markup (Sop_Dialog.Label635, False);
      Set_Use_Underline (Sop_Dialog.Label635, False);
      Set_Label_Widget (Sop_Dialog.Lock_Frame, Sop_Dialog.Label635);

      Gtk_New (Sop_Dialog.Unlock_Frame);
      Set_Label_Align (Sop_Dialog.Unlock_Frame, 0.5, 0.5);
      Set_Shadow_Type (Sop_Dialog.Unlock_Frame, Shadow_Etched_In);
      Attach
        (Sop_Dialog.Table2,
         Sop_Dialog.Unlock_Frame,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Sop_Dialog.Label636, -(" Unlocked Shared Resources "));
      Set_Alignment (Sop_Dialog.Label636, 0.5, 0.5);
      Set_Padding (Sop_Dialog.Label636, 0, 0);
      Set_Justify (Sop_Dialog.Label636, Justify_Left);
      Set_Line_Wrap (Sop_Dialog.Label636, False);
      Set_Selectable (Sop_Dialog.Label636, False);
      Set_Use_Markup (Sop_Dialog.Label636, False);
      Set_Use_Underline (Sop_Dialog.Label636, False);
      Set_Label_Widget (Sop_Dialog.Unlock_Frame, Sop_Dialog.Label636);

      ----------------------
      Sop_Dialog_Callback.Object_Connect
        (Get_Entry (Sop_Dialog.Overrid_Param_Type_Combo),
         "changed",
         Sop_Dialog_Callback.To_Marshaller
            (On_Overrid_Param_Type_Changed'Access),
         Sop_Dialog);

      -------------------------------
      -- Locked Tree View
      -------------------------------

      Set_USize (Sop_Dialog.Lock_Frame, 200, 200);

      Gtk_New (Sop_Dialog.Locked_Tree_Store, (Locked_Column => GType_String));

      --  Create the view: it shows 1 column, that contain some text.
      --  In that column, a renderer is used to display the data graphically.

      Gtk_New (Sop_Dialog.Locked_Tree_View, Sop_Dialog.Locked_Tree_Store);
      Set_Headers_Visible (Sop_Dialog.Locked_Tree_View, False);

      Gtk_New (Sop_Dialog.Locked_Text_Render);

      -- Locked Shared Resource Column (0)
      Gtk_New (Sop_Dialog.Locked_Col);
      Sop_Dialog.Locked_Num :=
         Append_Column (Sop_Dialog.Locked_Tree_View, Sop_Dialog.Locked_Col);
      Pack_Start (Sop_Dialog.Locked_Col, Sop_Dialog.Locked_Text_Render, True);
      Add_Attribute
        (Sop_Dialog.Locked_Col,
         Sop_Dialog.Locked_Text_Render,
         "text",
         Locked_Column);

      Set_Min_Width (Sop_Dialog.Locked_Col, 110);

      --  Insert the view in the frame
      Gtk_New (Sop_Dialog.Locked_Scrolled);
      Set_Policy (Sop_Dialog.Locked_Scrolled, Policy_Always, Policy_Always);
      Set_Border_Width (Sop_Dialog.Locked_Scrolled, 5);
      Add (Sop_Dialog.Locked_Scrolled, Sop_Dialog.Locked_Tree_View);

      Show_All (Sop_Dialog.Locked_Scrolled);
      Add (Sop_Dialog.Lock_Frame, Sop_Dialog.Locked_Scrolled);

      -------------------------------
      -- Unlocked Tree View
      -------------------------------
      Set_USize (Sop_Dialog.Unlock_Frame, 200, 200);

      Gtk_New
        (Sop_Dialog.Unlocked_Tree_Store,
         (Unlocked_Column => GType_String));

      --  Create the view: it shows 1 column, that contain some text.
      --  In that column, a renderer is used to display the data graphically.

      Gtk_New (Sop_Dialog.Unlocked_Tree_View, Sop_Dialog.Unlocked_Tree_Store);
      Set_Headers_Visible (Sop_Dialog.Unlocked_Tree_View, False);

      Gtk_New (Sop_Dialog.Unlocked_Text_Render);

      --  Unlocked Shared Resource Column (0)
      Gtk_New (Sop_Dialog.Unlocked_Col);
      Sop_Dialog.Unlocked_Num :=
         Append_Column
           (Sop_Dialog.Unlocked_Tree_View,
            Sop_Dialog.Unlocked_Col);
      Pack_Start
        (Sop_Dialog.Unlocked_Col,
         Sop_Dialog.Unlocked_Text_Render,
         True);
      Add_Attribute
        (Sop_Dialog.Unlocked_Col,
         Sop_Dialog.Unlocked_Text_Render,
         "text",
         Unlocked_Column);

      Set_Min_Width (Sop_Dialog.Unlocked_Col, 110);

      --  Insert the view in the frame
      Gtk_New (Sop_Dialog.Unlocked_Scrolled);
      Set_Policy (Sop_Dialog.Unlocked_Scrolled, Policy_Always, Policy_Always);
      Set_Border_Width (Sop_Dialog.Unlocked_Scrolled, 5);
      Add (Sop_Dialog.Unlocked_Scrolled, Sop_Dialog.Unlocked_Tree_View);

      Show_All (Sop_Dialog.Unlocked_Scrolled);
      Add (Sop_Dialog.Unlock_Frame, Sop_Dialog.Unlocked_Scrolled);

   end Initialize;

end Sop_Dialog_Pkg;
