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
with Cop_Dialog_Pkg.Callbacks; use Cop_Dialog_Pkg.Callbacks;

with Mast;    use Mast;
with Mast.IO; use Mast.IO;

package body Cop_Dialog_Pkg is

   procedure Gtk_New (Cop_Dialog : out Cop_Dialog_Access) is
   begin
      Cop_Dialog := new Cop_Dialog_Record;
      Cop_Dialog_Pkg.Initialize (Cop_Dialog);
   end Gtk_New;

   procedure Initialize (Cop_Dialog : access Cop_Dialog_Record'Class) is
      pragma Suppress (All_Checks);
      Pixmaps_Dir                    : constant String := "pixmaps/";
      Op_Type_Combo_Items            : String_List.Glist;
      Overrid_Param_Type_Combo_Items : String_List.Glist;

   begin
      Gtk.Dialog.Initialize (Cop_Dialog);
      Set_Title (Cop_Dialog, -"Composite Operation Parameters");
      Set_Position (Cop_Dialog, Win_Pos_Center_Always);
      Set_Modal (Cop_Dialog, False);

      Set_Policy (Cop_Dialog, False, False, False);

      Gtk_New_Hbox (Cop_Dialog.Hbox101, True, 0);
      Pack_Start (Get_Action_Area (Cop_Dialog), Cop_Dialog.Hbox101);

      Gtk_New (Cop_Dialog.Ok_Button, -"OK");
      Set_Relief (Cop_Dialog.Ok_Button, Relief_Normal);
      Pack_Start
        (Cop_Dialog.Hbox101,
         Cop_Dialog.Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 120);

      Gtk_New (Cop_Dialog.Cancel_Button, -"Cancel");
      Set_Relief (Cop_Dialog.Cancel_Button, Relief_Normal);
      Pack_End
        (Cop_Dialog.Hbox101,
         Cop_Dialog.Cancel_Button,
         Expand  => True,
         Fill    => True,
         Padding => 120);
      --     Button_Callback.Connect
      --       (Cop_Dialog.Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Cancel_Button_Clicked'Access), False);

      Dialog_Callback.Object_Connect
        (Cop_Dialog.Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access),
         Cop_Dialog);

      Gtk_New_Vbox (Cop_Dialog.Vbox32, False, 5);
      Set_Border_Width (Cop_Dialog.Vbox32, 10);
      Pack_Start
        (Get_Vbox (Cop_Dialog),
         Cop_Dialog.Vbox32,
         Expand  => False,
         Fill    => False,
         Padding => 5);

      Gtk_New_Hbox (Cop_Dialog.Hbox61, False, 10);
      Pack_Start
        (Cop_Dialog.Vbox32,
         Cop_Dialog.Hbox61,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New_Vbox (Cop_Dialog.Vbox33, False, 5);
      Pack_Start
        (Cop_Dialog.Hbox61,
         Cop_Dialog.Vbox33,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Cop_Dialog.Table1, 4, 2, True);
      Set_Row_Spacings (Cop_Dialog.Table1, 5);
      Set_Col_Spacings (Cop_Dialog.Table1, 5);
      Pack_Start
        (Cop_Dialog.Vbox33,
         Cop_Dialog.Table1,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Cop_Dialog.Label422, -("Operation Name"));
      Set_Alignment (Cop_Dialog.Label422, 0.95, 0.5);
      Set_Padding (Cop_Dialog.Label422, 0, 0);
      Set_Justify (Cop_Dialog.Label422, Justify_Center);
      Set_Line_Wrap (Cop_Dialog.Label422, False);
      Set_Selectable (Cop_Dialog.Label422, False);
      Set_Use_Markup (Cop_Dialog.Label422, False);
      Set_Use_Underline (Cop_Dialog.Label422, False);
      Attach
        (Cop_Dialog.Table1,
         Cop_Dialog.Label422,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Label423, -("Operation Type"));
      Set_Alignment (Cop_Dialog.Label423, 0.95, 0.5);
      Set_Padding (Cop_Dialog.Label423, 0, 0);
      Set_Justify (Cop_Dialog.Label423, Justify_Center);
      Set_Line_Wrap (Cop_Dialog.Label423, False);
      Set_Selectable (Cop_Dialog.Label423, False);
      Set_Use_Markup (Cop_Dialog.Label423, False);
      Set_Use_Underline (Cop_Dialog.Label423, False);
      Attach
        (Cop_Dialog.Table1,
         Cop_Dialog.Label423,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Op_Name_Entry);
      Set_Editable (Cop_Dialog.Op_Name_Entry, True);
      Set_Max_Length (Cop_Dialog.Op_Name_Entry, 0);
      Set_Text (Cop_Dialog.Op_Name_Entry, -(""));
      Set_Visibility (Cop_Dialog.Op_Name_Entry, True);
      Set_Invisible_Char (Cop_Dialog.Op_Name_Entry, UTF8_Get_Char ("*"));
      Attach
        (Cop_Dialog.Table1,
         Cop_Dialog.Op_Name_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Op_Type_Combo);
      Set_Value_In_List (Cop_Dialog.Op_Type_Combo, False);
      Set_Use_Arrows (Cop_Dialog.Op_Type_Combo, True);
      Set_Case_Sensitive (Cop_Dialog.Op_Type_Combo, False);
      Set_Editable (Get_Entry (Cop_Dialog.Op_Type_Combo), False);
      Set_Has_Frame (Get_Entry (Cop_Dialog.Op_Type_Combo), True);
      Set_Max_Length (Get_Entry (Cop_Dialog.Op_Type_Combo), 0);
      Set_Text (Get_Entry (Cop_Dialog.Op_Type_Combo), -("Enclosing"));
      Set_Invisible_Char
        (Get_Entry (Cop_Dialog.Op_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Cop_Dialog.Op_Type_Combo), True);
      String_List.Append (Op_Type_Combo_Items, -("Enclosing"));
      String_List.Append (Op_Type_Combo_Items, -("Composite"));
      Combo.Set_Popdown_Strings
        (Cop_Dialog.Op_Type_Combo,
         Op_Type_Combo_Items);
      Free_String_List (Op_Type_Combo_Items);
      Attach
        (Cop_Dialog.Table1,
         Cop_Dialog.Op_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Cop_Dialog.Label428,
         -("OVERRIDDEN SCHEDULING PARAMETERS:"));
      Set_Alignment (Cop_Dialog.Label428, 0.5, 0.5);
      Set_Padding (Cop_Dialog.Label428, 0, 5);
      Set_Justify (Cop_Dialog.Label428, Justify_Center);
      Set_Line_Wrap (Cop_Dialog.Label428, False);
      Set_Selectable (Cop_Dialog.Label428, False);
      Set_Use_Markup (Cop_Dialog.Label428, False);
      Set_Use_Underline (Cop_Dialog.Label428, False);
      Attach
        (Cop_Dialog.Table1,
         Cop_Dialog.Label428,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Label427, -("Parameters Type"));
      Set_Alignment (Cop_Dialog.Label427, 0.95, 0.5);
      Set_Padding (Cop_Dialog.Label427, 0, 0);
      Set_Justify (Cop_Dialog.Label427, Justify_Center);
      Set_Line_Wrap (Cop_Dialog.Label427, False);
      Set_Selectable (Cop_Dialog.Label427, False);
      Set_Use_Markup (Cop_Dialog.Label427, False);
      Set_Use_Underline (Cop_Dialog.Label427, False);
      Attach
        (Cop_Dialog.Table1,
         Cop_Dialog.Label427,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Overrid_Param_Type_Combo);
      Set_Value_In_List (Cop_Dialog.Overrid_Param_Type_Combo, False);
      Set_Use_Arrows (Cop_Dialog.Overrid_Param_Type_Combo, True);
      Set_Case_Sensitive (Cop_Dialog.Overrid_Param_Type_Combo, False);
      Set_Editable (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo), False);
      Set_Has_Frame (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo), True);
      Set_Max_Length (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo), 0);
      Set_Text
        (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo),
         -("(NONE)"));
      Set_Invisible_Char
        (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo), True);
      String_List.Append (Overrid_Param_Type_Combo_Items, -("(NONE)"));
      String_List.Append
        (Overrid_Param_Type_Combo_Items,
         -("Fixed Priority"));
      String_List.Append
        (Overrid_Param_Type_Combo_Items,
         -("Permanent Fixed Priority"));
      Combo.Set_Popdown_Strings
        (Cop_Dialog.Overrid_Param_Type_Combo,
         Overrid_Param_Type_Combo_Items);
      Free_String_List (Overrid_Param_Type_Combo_Items);
      Attach
        (Cop_Dialog.Table1,
         Cop_Dialog.Overrid_Param_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Overrid_Prior_Table, 1, 2, True);
      Set_Row_Spacings (Cop_Dialog.Overrid_Prior_Table, 5);
      Set_Col_Spacings (Cop_Dialog.Overrid_Prior_Table, 5);
      Pack_Start
        (Cop_Dialog.Vbox33,
         Cop_Dialog.Overrid_Prior_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Cop_Dialog.Label429, -("Overridden Priority"));
      Set_Alignment (Cop_Dialog.Label429, 0.95, 0.5);
      Set_Padding (Cop_Dialog.Label429, 0, 0);
      Set_Justify (Cop_Dialog.Label429, Justify_Center);
      Set_Line_Wrap (Cop_Dialog.Label429, False);
      Set_Selectable (Cop_Dialog.Label429, False);
      Set_Use_Markup (Cop_Dialog.Label429, False);
      Set_Use_Underline (Cop_Dialog.Label429, False);
      Attach
        (Cop_Dialog.Overrid_Prior_Table,
         Cop_Dialog.Label429,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Overrid_Prior_Entry);
      Set_Editable (Cop_Dialog.Overrid_Prior_Entry, True);
      Set_Max_Length (Cop_Dialog.Overrid_Prior_Entry, 0);
      Set_Text
        (Cop_Dialog.Overrid_Prior_Entry,
         Priority'Image (Priority'First));
      Set_Visibility (Cop_Dialog.Overrid_Prior_Entry, True);
      Set_Invisible_Char
        (Cop_Dialog.Overrid_Prior_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Cop_Dialog.Overrid_Prior_Table,
         Cop_Dialog.Overrid_Prior_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Exec_Time_Table, 3, 2, True);
      Set_Row_Spacings (Cop_Dialog.Exec_Time_Table, 5);
      Set_Col_Spacings (Cop_Dialog.Exec_Time_Table, 5);
      Pack_Start
        (Cop_Dialog.Vbox33,
         Cop_Dialog.Exec_Time_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Cop_Dialog.Label424, -("Worst Execution Time"));
      Set_Alignment (Cop_Dialog.Label424, 0.95, 0.5);
      Set_Padding (Cop_Dialog.Label424, 0, 0);
      Set_Justify (Cop_Dialog.Label424, Justify_Center);
      Set_Line_Wrap (Cop_Dialog.Label424, False);
      Set_Selectable (Cop_Dialog.Label424, False);
      Set_Use_Markup (Cop_Dialog.Label424, False);
      Set_Use_Underline (Cop_Dialog.Label424, False);
      Attach
        (Cop_Dialog.Exec_Time_Table,
         Cop_Dialog.Label424,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Wor_Exec_Time_Entry);
      Set_Editable (Cop_Dialog.Wor_Exec_Time_Entry, True);
      Set_Max_Length (Cop_Dialog.Wor_Exec_Time_Entry, 0);
      Set_Text
        (Cop_Dialog.Wor_Exec_Time_Entry,
         Execution_Time_Image (Mast.Large_Execution_Time));
      Set_Visibility (Cop_Dialog.Wor_Exec_Time_Entry, True);
      Set_Invisible_Char
        (Cop_Dialog.Wor_Exec_Time_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Cop_Dialog.Exec_Time_Table,
         Cop_Dialog.Wor_Exec_Time_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Label425, -("Average Execution Time"));
      Set_Alignment (Cop_Dialog.Label425, 0.95, 0.5);
      Set_Padding (Cop_Dialog.Label425, 0, 0);
      Set_Justify (Cop_Dialog.Label425, Justify_Center);
      Set_Line_Wrap (Cop_Dialog.Label425, False);
      Set_Selectable (Cop_Dialog.Label425, False);
      Set_Use_Markup (Cop_Dialog.Label425, False);
      Set_Use_Underline (Cop_Dialog.Label425, False);
      Attach
        (Cop_Dialog.Exec_Time_Table,
         Cop_Dialog.Label425,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Avg_Exec_Time_Entry);
      Set_Editable (Cop_Dialog.Avg_Exec_Time_Entry, True);
      Set_Max_Length (Cop_Dialog.Avg_Exec_Time_Entry, 0);
      Set_Text
        (Cop_Dialog.Avg_Exec_Time_Entry,
         Execution_Time_Image (Mast.Large_Execution_Time));
      Set_Visibility (Cop_Dialog.Avg_Exec_Time_Entry, True);
      Set_Invisible_Char
        (Cop_Dialog.Avg_Exec_Time_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Cop_Dialog.Exec_Time_Table,
         Cop_Dialog.Avg_Exec_Time_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Label426, -("Best Execution Time"));
      Set_Alignment (Cop_Dialog.Label426, 0.95, 0.5);
      Set_Padding (Cop_Dialog.Label426, 0, 0);
      Set_Justify (Cop_Dialog.Label426, Justify_Center);
      Set_Line_Wrap (Cop_Dialog.Label426, False);
      Set_Selectable (Cop_Dialog.Label426, False);
      Set_Use_Markup (Cop_Dialog.Label426, False);
      Set_Use_Underline (Cop_Dialog.Label426, False);
      Attach
        (Cop_Dialog.Exec_Time_Table,
         Cop_Dialog.Label426,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Bes_Exec_Time_Entry);
      Set_Editable (Cop_Dialog.Bes_Exec_Time_Entry, True);
      Set_Max_Length (Cop_Dialog.Bes_Exec_Time_Entry, 0);
      Set_Text (Cop_Dialog.Bes_Exec_Time_Entry, -("0.0"));
      Set_Visibility (Cop_Dialog.Bes_Exec_Time_Entry, True);
      Set_Invisible_Char
        (Cop_Dialog.Bes_Exec_Time_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Cop_Dialog.Exec_Time_Table,
         Cop_Dialog.Bes_Exec_Time_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New_Vseparator (Cop_Dialog.Vseparator6);
      Pack_Start
        (Cop_Dialog.Hbox61,
         Cop_Dialog.Vseparator6,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New_Vbox (Cop_Dialog.Vbox34, False, 0);
      Pack_Start
        (Cop_Dialog.Hbox61,
         Cop_Dialog.Vbox34,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Cop_Dialog.Table2, 5, 2, False);
      Set_Row_Spacings (Cop_Dialog.Table2, 5);
      Set_Col_Spacings (Cop_Dialog.Table2, 10);
      Pack_Start
        (Cop_Dialog.Vbox34,
         Cop_Dialog.Table2,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Cop_Dialog.Add_Op_Button, -"Add Operation");
      Set_Relief (Cop_Dialog.Add_Op_Button, Relief_Normal);
      Attach
        (Cop_Dialog.Table2,
         Cop_Dialog.Add_Op_Button,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Remove_Op_Button, -"Remove Operation");
      Set_Relief (Cop_Dialog.Remove_Op_Button, Relief_Normal);
      Attach
        (Cop_Dialog.Table2,
         Cop_Dialog.Remove_Op_Button,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Frame);
      Set_Label_Align (Cop_Dialog.Frame, 0.5, 0.5);
      Set_Shadow_Type (Cop_Dialog.Frame, Shadow_Etched_In);
      Attach
        (Cop_Dialog.Table2,
         Cop_Dialog.Frame,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Cop_Dialog.Op_Label, -(" Operations "));
      Set_Alignment (Cop_Dialog.Op_Label, 0.5, 0.5);
      Set_Padding (Cop_Dialog.Op_Label, 0, 0);
      Set_Justify (Cop_Dialog.Op_Label, Justify_Left);
      Set_Line_Wrap (Cop_Dialog.Op_Label, False);
      Set_Selectable (Cop_Dialog.Op_Label, False);
      Set_Use_Markup (Cop_Dialog.Op_Label, False);
      Set_Use_Underline (Cop_Dialog.Op_Label, False);
      Set_Label_Widget (Cop_Dialog.Frame, Cop_Dialog.Op_Label);

      ------------------------
      Cop_Dialog_Callback.Object_Connect
        (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo),
         "changed",
         Cop_Dialog_Callback.To_Marshaller
            (On_Overrid_Param_Type_Changed'Access),
         Cop_Dialog);

      Cop_Dialog_Callback.Object_Connect
        (Get_Entry (Cop_Dialog.Op_Type_Combo),
         "changed",
         Cop_Dialog_Callback.To_Marshaller (On_Op_Type_Entry_Changed'Access),
         Cop_Dialog);

      -------------------------------
      -- Operations  Tree View
      -------------------------------

      Set_USize (Cop_Dialog.Frame, 200, 200);

      Gtk_New (Cop_Dialog.Tree_Store, (Op_Column => GType_String));

      --  Create the view: it shows 1 column, that contain some text.
      --  In that column, a renderer is used to display the data graphically.

      Gtk_New (Cop_Dialog.Tree_View, Cop_Dialog.Tree_Store);
      Set_Headers_Visible (Cop_Dialog.Tree_View, False);

      Gtk_New (Cop_Dialog.Text_Render);

      -- Operations Column (0)
      Gtk_New (Cop_Dialog.Col);
      Cop_Dialog.Num := Append_Column (Cop_Dialog.Tree_View, Cop_Dialog.Col);
      Pack_Start (Cop_Dialog.Col, Cop_Dialog.Text_Render, True);
      Add_Attribute
        (Cop_Dialog.Col,
         Cop_Dialog.Text_Render,
         "text",
         Op_Column);

      Set_Min_Width (Cop_Dialog.Col, 110);

      --  Insert the view in the frame
      Gtk_New (Cop_Dialog.Scrolled);
      Set_Policy (Cop_Dialog.Scrolled, Policy_Always, Policy_Always);
      Set_Border_Width (Cop_Dialog.Scrolled, 5);
      Add (Cop_Dialog.Scrolled, Cop_Dialog.Tree_View);

      Show_All (Cop_Dialog.Scrolled);
      Add (Cop_Dialog.Frame, Cop_Dialog.Scrolled);

   end Initialize;

end Cop_Dialog_Pkg;
