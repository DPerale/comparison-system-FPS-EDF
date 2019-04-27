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
with Glib;                          use Glib;
with Gtk;                           use Gtk;
with Gdk.Types;                     use Gdk.Types;
with Gtk.Widget;                    use Gtk.Widget;
with Gtk.Enums;                     use Gtk.Enums;
with Gtkada.Handlers;               use Gtkada.Handlers;
with Callbacks_Mast_Editor;         use Callbacks_Mast_Editor;
with Mast_Editor_Intl;              use Mast_Editor_Intl;
with Internal_Dialog_Pkg.Callbacks; use Internal_Dialog_Pkg.Callbacks;

with Glib.Object;  use Glib.Object;
with Gtk.Handlers; use Gtk.Handlers;

package body Internal_Dialog_Pkg is

   package Object_Callback is new Gtk.Handlers.Callback (GObject_Record);

   procedure Gtk_New (Internal_Dialog : out Internal_Dialog_Access) is
   begin
      Internal_Dialog := new Internal_Dialog_Record;
      Internal_Dialog_Pkg.Initialize (Internal_Dialog);
   end Gtk_New;

   procedure Initialize
     (Internal_Dialog : access Internal_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Internal_Event_Type_Combo_Items : String_List.Glist;

   begin
      Gtk.Dialog.Initialize (Internal_Dialog);
      Set_Title (Internal_Dialog, -"Internal Event Parameters");
      Set_Position (Internal_Dialog, Win_Pos_Center);
      Set_Modal (Internal_Dialog, False);

      Gtk_New_Hbox (Internal_Dialog.Hbox70, True, 100);
      Pack_Start (Get_Action_Area (Internal_Dialog), Internal_Dialog.Hbox70);

      Gtk_New (Internal_Dialog.Ok_Button, -"OK");
      Set_Relief (Internal_Dialog.Ok_Button, Relief_Normal);
      Pack_Start
        (Internal_Dialog.Hbox70,
         Internal_Dialog.Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Internal_Dialog.Cancel_Button, -"Cancel");
      Set_Relief (Internal_Dialog.Cancel_Button, Relief_Normal);
      Pack_End
        (Internal_Dialog.Hbox70,
         Internal_Dialog.Cancel_Button,
         Expand  => True,
         Fill    => True,
         Padding => 0);
      --     Button_Callback.Connect
      --       (Internal_Dialog.Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Cancel_Button_Clicked'Access), False);
      Dialog_Callback.Object_Connect
        (Internal_Dialog.Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access),
         Internal_Dialog);

      Gtk_New_Vbox (Internal_Dialog.Vbox16, False, 0);
      Pack_Start
        (Get_Vbox (Internal_Dialog),
         Internal_Dialog.Vbox16,
         Expand  => False,
         Fill    => True,
         Padding => 0);

      Gtk_New (Internal_Dialog.Table1, 2, 2, True);
      Set_Border_Width (Internal_Dialog.Table1, 5);
      Set_Row_Spacings (Internal_Dialog.Table1, 3);
      Set_Col_Spacings (Internal_Dialog.Table1, 3);
      Pack_Start
        (Internal_Dialog.Vbox16,
         Internal_Dialog.Table1,
         Expand  => False,
         Fill    => False,
         Padding => 5);

      Gtk_New (Internal_Dialog.Label183, -("Event Name"));
      Set_Alignment (Internal_Dialog.Label183, 0.95, 0.5);
      Set_Padding (Internal_Dialog.Label183, 0, 0);
      Set_Justify (Internal_Dialog.Label183, Justify_Center);
      Set_Line_Wrap (Internal_Dialog.Label183, False);
      Set_Selectable (Internal_Dialog.Label183, False);
      Set_Use_Markup (Internal_Dialog.Label183, False);
      Set_Use_Underline (Internal_Dialog.Label183, False);
      Attach
        (Internal_Dialog.Table1,
         Internal_Dialog.Label183,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Internal_Dialog.Label184, -("Internal Event Type"));
      Set_Alignment (Internal_Dialog.Label184, 0.95, 0.5);
      Set_Padding (Internal_Dialog.Label184, 0, 0);
      Set_Justify (Internal_Dialog.Label184, Justify_Center);
      Set_Line_Wrap (Internal_Dialog.Label184, False);
      Set_Selectable (Internal_Dialog.Label184, False);
      Set_Use_Markup (Internal_Dialog.Label184, False);
      Set_Use_Underline (Internal_Dialog.Label184, False);
      Attach
        (Internal_Dialog.Table1,
         Internal_Dialog.Label184,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Internal_Dialog.Event_Name_Entry);
      Set_Editable (Internal_Dialog.Event_Name_Entry, True);
      Set_Max_Length (Internal_Dialog.Event_Name_Entry, 0);
      Set_Text (Internal_Dialog.Event_Name_Entry, -(""));
      Set_Visibility (Internal_Dialog.Event_Name_Entry, True);
      Set_Invisible_Char
        (Internal_Dialog.Event_Name_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Internal_Dialog.Table1,
         Internal_Dialog.Event_Name_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Internal_Dialog.Internal_Event_Type_Combo);
      Set_Value_In_List (Internal_Dialog.Internal_Event_Type_Combo, False);
      Set_Use_Arrows (Internal_Dialog.Internal_Event_Type_Combo, True);
      Set_Case_Sensitive (Internal_Dialog.Internal_Event_Type_Combo, False);
      Set_Editable
        (Get_Entry (Internal_Dialog.Internal_Event_Type_Combo),
         False);
      Set_Max_Length
        (Get_Entry (Internal_Dialog.Internal_Event_Type_Combo),
         0);
      Set_Text
        (Get_Entry (Internal_Dialog.Internal_Event_Type_Combo),
         -("Regular"));
      Set_Invisible_Char
        (Get_Entry (Internal_Dialog.Internal_Event_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Internal_Dialog.Internal_Event_Type_Combo),
         True);
      String_List.Append (Internal_Event_Type_Combo_Items, -("Regular"));
      Combo.Set_Popdown_Strings
        (Internal_Dialog.Internal_Event_Type_Combo,
         Internal_Event_Type_Combo_Items);
      Free_String_List (Internal_Event_Type_Combo_Items);
      Attach
        (Internal_Dialog.Table1,
         Internal_Dialog.Internal_Event_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Internal_Dialog.Timing_Table, 2, 2, True);
      Set_Border_Width (Internal_Dialog.Timing_Table, 5);
      Set_Row_Spacings (Internal_Dialog.Timing_Table, 15);
      Set_Col_Spacings (Internal_Dialog.Timing_Table, 3);
      Pack_Start
        (Internal_Dialog.Vbox16,
         Internal_Dialog.Timing_Table,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Internal_Dialog.Timing_Label, -("TIMING REQUIREMENTS: "));
      Set_Alignment (Internal_Dialog.Timing_Label, 0.5, 0.5);
      Set_Padding (Internal_Dialog.Timing_Label, 0, 0);
      Set_Justify (Internal_Dialog.Timing_Label, Justify_Center);
      Set_Line_Wrap (Internal_Dialog.Timing_Label, False);
      Set_Selectable (Internal_Dialog.Timing_Label, False);
      Set_Use_Markup (Internal_Dialog.Timing_Label, False);
      Set_Use_Underline (Internal_Dialog.Timing_Label, False);
      Attach
        (Internal_Dialog.Timing_Table,
         Internal_Dialog.Timing_Label,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Internal_Dialog.Add_Req_Button, -"Add Requirement");
      Set_Relief (Internal_Dialog.Add_Req_Button, Relief_Normal);
      Attach
        (Internal_Dialog.Timing_Table,
         Internal_Dialog.Add_Req_Button,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);
      --     Button_Callback.Connect
      --       (Internal_Dialog.Add_Req_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Add_Req_Button_Clicked'Access), False);

      Internal_Dialog_Callback.Object_Connect
        (Internal_Dialog.Add_Req_Button,
         "clicked",
         Internal_Dialog_Callback.To_Marshaller
            (On_Add_Req_Button_Clicked'Access),
         Internal_Dialog);

      Gtk_New (Internal_Dialog.Remove_Req_Button, -"Remove Requirement");
      Set_Relief (Internal_Dialog.Remove_Req_Button, Relief_Normal);
      Attach
        (Internal_Dialog.Timing_Table,
         Internal_Dialog.Remove_Req_Button,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);
      --     Button_Callback.Connect
      --       (Internal_Dialog.Remove_Req_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Remove_Req_Button_Clicked'Access), False);

      Internal_Dialog_Callback.Object_Connect
        (Internal_Dialog.Remove_Req_Button,
         "clicked",
         Internal_Dialog_Callback.To_Marshaller
            (On_Remove_Req_Button_Clicked'Access),
         Internal_Dialog);

      Gtk_New (Internal_Dialog.Frame);
      Set_Border_Width (Internal_Dialog.Frame, 5);
      Set_Label_Align (Internal_Dialog.Frame, 0.0, 0.5);
      Set_Shadow_Type (Internal_Dialog.Frame, Shadow_None);
      Pack_Start
        (Internal_Dialog.Vbox16,
         Internal_Dialog.Frame,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      -----------------------------------------------
      Set_USize (Internal_Dialog.Frame, 695, 250);

      Gtk_New
        (Internal_Dialog.Tree_Store,
         (Editable_Column     => GType_Boolean,  -- not shown in treeview
         Type_Column          => GType_String,
         Deadline_Column      => GType_String,
         Deadline_Val_Column  => GType_String,
         Ref_Event_Column     => GType_String,
         Ref_Event_Val_Column => GType_String,
         Ratio_Column         => GType_String,
         Ratio_Val_Column     => GType_String,
         Foreground_Column    => GType_String,   -- not shown in treeview
         Background_Column    => GType_String)); -- not shown in treeview

      --  Create the view: it shows 7 columns, that contain some text.
      --  In each column, a renderer is used to display the data graphically.

      Gtk_New (Internal_Dialog.Tree_View, Internal_Dialog.Tree_Store);

      Gtk_New (Internal_Dialog.Text_Render);
      Gtk_New (Internal_Dialog.Deadline_Edit_Render);
      Gtk_New (Internal_Dialog.Ref_Event_Edit_Render);
      Gtk_New (Internal_Dialog.Ratio_Edit_Render);

      -- Type Column (1)
      Gtk_New (Internal_Dialog.Col);
      Internal_Dialog.Num :=
         Append_Column (Internal_Dialog.Tree_View, Internal_Dialog.Col);
      Set_Title (Internal_Dialog.Col, "TYPE");
      Pack_Start (Internal_Dialog.Col, Internal_Dialog.Text_Render, True);
      Add_Attribute
        (Internal_Dialog.Col,
         Internal_Dialog.Text_Render,
         "text",
         Type_Column);
      Add_Attribute
        (Internal_Dialog.Col,
         Internal_Dialog.Text_Render,
         "background",
         Background_Column);

      -- Deadline/Max_Jitter Column (2)
      Gtk_New (Internal_Dialog.Col);
      Internal_Dialog.Num :=
         Append_Column (Internal_Dialog.Tree_View, Internal_Dialog.Col);
      Set_Title (Internal_Dialog.Col, "ATTRIBUTES");
      Pack_Start (Internal_Dialog.Col, Internal_Dialog.Text_Render, True);
      Add_Attribute
        (Internal_Dialog.Col,
         Internal_Dialog.Text_Render,
         "text",
         Deadline_Column);
      Add_Attribute
        (Internal_Dialog.Col,
         Internal_Dialog.Text_Render,
         "background",
         Background_Column);

      -- Deadline/Max_Jitter Value Column (3)
      Gtk_New (Internal_Dialog.Col);
      Internal_Dialog.Num :=
         Append_Column (Internal_Dialog.Tree_View, Internal_Dialog.Col);
      Pack_Start
        (Internal_Dialog.Col,
         Internal_Dialog.Deadline_Edit_Render,
         True);
      Add_Attribute
        (Internal_Dialog.Col,
         Internal_Dialog.Deadline_Edit_Render,
         "text",
         Deadline_Val_Column);
      Add_Attribute
        (Internal_Dialog.Col,
         Internal_Dialog.Deadline_Edit_Render,
         "editable",
         Editable_Column);
      Add_Attribute
        (Internal_Dialog.Col,
         Internal_Dialog.Deadline_Edit_Render,
         "foreground",
         Foreground_Column);

      -- Referenced_Event Column (4)
      Gtk_New (Internal_Dialog.Col);
      Internal_Dialog.Num :=
         Append_Column (Internal_Dialog.Tree_View, Internal_Dialog.Col);
      Pack_Start (Internal_Dialog.Col, Internal_Dialog.Text_Render, True);
      Add_Attribute
        (Internal_Dialog.Col,
         Internal_Dialog.Text_Render,
         "text",
         Ref_Event_Column);
      Add_Attribute
        (Internal_Dialog.Col,
         Internal_Dialog.Text_Render,
         "background",
         Background_Column);

      -- Referenced_Event Value Column (5)
      Gtk_New (Internal_Dialog.Ref_Event_Col);
      Internal_Dialog.Num :=
         Append_Column
           (Internal_Dialog.Tree_View,
            Internal_Dialog.Ref_Event_Col);

      Set_Min_Width (Internal_Dialog.Ref_Event_Col, 160);

      Pack_Start
        (Internal_Dialog.Ref_Event_Col,
         Internal_Dialog.Ref_Event_Edit_Render,
         True);
      Add_Attribute
        (Internal_Dialog.Ref_Event_Col,
         Internal_Dialog.Ref_Event_Edit_Render,
         "text",
         Ref_Event_Val_Column);
      Add_Attribute
        (Internal_Dialog.Ref_Event_Col,
         Internal_Dialog.Ref_Event_Edit_Render,
         "foreground",
         Foreground_Column);

      -- Ratio Column (6)
      Gtk_New (Internal_Dialog.Col);
      Internal_Dialog.Num :=
         Append_Column (Internal_Dialog.Tree_View, Internal_Dialog.Col);
      Pack_Start (Internal_Dialog.Col, Internal_Dialog.Text_Render, True);
      Add_Attribute
        (Internal_Dialog.Col,
         Internal_Dialog.Text_Render,
         "text",
         Ratio_Column);
      Add_Attribute
        (Internal_Dialog.Col,
         Internal_Dialog.Text_Render,
         "background",
         Background_Column);

      -- Ratio Value Column (7)
      Gtk_New (Internal_Dialog.Col);
      Internal_Dialog.Num :=
         Append_Column (Internal_Dialog.Tree_View, Internal_Dialog.Col);
      Pack_Start
        (Internal_Dialog.Col,
         Internal_Dialog.Ratio_Edit_Render,
         True);
      Add_Attribute
        (Internal_Dialog.Col,
         Internal_Dialog.Ratio_Edit_Render,
         "text",
         Ratio_Val_Column);
      Add_Attribute
        (Internal_Dialog.Col,
         Internal_Dialog.Ratio_Edit_Render,
         "editable",
         Editable_Column);
      Add_Attribute
        (Internal_Dialog.Col,
         Internal_Dialog.Ratio_Edit_Render,
         "foreground",
         Foreground_Column);

      --  By default, the text renderers don't react to clicks, ie the user
      --  cannot interactively change the value of the text entries. This needs
      --  a special callback for the "edited" signal.
      --
      --  A callback should be used for validation of the input.

      Object_Callback.Object_Connect
        (Internal_Dialog.Deadline_Edit_Render,
         "edited",
         Deadline_Edited_Callback'Access,
         Slot_Object => Internal_Dialog.Tree_Store);

      Object_Callback.Object_Connect
        (Internal_Dialog.Ratio_Edit_Render,
         "edited",
         Ratio_Edited_Callback'Access,
         Slot_Object => Internal_Dialog.Tree_Store);

      -- Callback used to show ref_event_list dialog when a double-click
      -- event happens inside ref_event_column
      F_Internal_Dialog_Callback.Object_Connect
        (Internal_Dialog.Tree_View,
         "button-press-event",
         F_Internal_Dialog_Callback.To_Marshaller
            (Func_Ref_Event_Column_Double_Click'Access),
         Internal_Dialog);

      --  Insert the view in the frame
      Gtk_New (Internal_Dialog.Scrolled);
      Set_Policy (Internal_Dialog.Scrolled, Policy_Always, Policy_Always);
      Add (Internal_Dialog.Scrolled, Internal_Dialog.Tree_View);

      Show_All (Internal_Dialog.Scrolled);
      Add (Internal_Dialog.Frame, Internal_Dialog.Scrolled);

   end Initialize;

end Internal_Dialog_Pkg;
