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
with Glib;                                 use Glib;
with Gtk;                                  use Gtk;
with Gdk.Types;                            use Gdk.Types;
with Gtk.Widget;                           use Gtk.Widget;
with Gtk.Enums;                            use Gtk.Enums;
with Gtkada.Handlers;                      use Gtkada.Handlers;
with Callbacks_Mast_Editor;                use Callbacks_Mast_Editor;
with Mast_Editor_Intl;                     use Mast_Editor_Intl;
with Shared_Resource_Dialog_Pkg.Callbacks;
use Shared_Resource_Dialog_Pkg.Callbacks;

package body Shared_Resource_Dialog_Pkg is

   procedure Gtk_New
     (Shared_Resource_Dialog : out Shared_Resource_Dialog_Access)
   is
   begin
      Shared_Resource_Dialog := new Shared_Resource_Dialog_Record;
      Shared_Resource_Dialog_Pkg.Initialize (Shared_Resource_Dialog);
   end Gtk_New;

   procedure Initialize
     (Shared_Resource_Dialog : access Shared_Resource_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Pixmaps_Dir                 : constant String := "pixmaps/";
      Preassigned_Combo_Items     : String_List.Glist;
      Shared_Res_Type_Combo_Items : String_List.Glist;

   begin
      Gtk.Dialog.Initialize (Shared_Resource_Dialog);
      Set_Title (Shared_Resource_Dialog, -"Shared Resource Parameters");
      Set_Position (Shared_Resource_Dialog, Win_Pos_Center_Always);
      Set_Modal (Shared_Resource_Dialog, False);

      Set_Policy (Shared_Resource_Dialog, False, False, False);
      Set_USize (Shared_Resource_Dialog, 330, -1);

      Gtk_New_Hbox (Shared_Resource_Dialog.Hbox74, True, 100);
      Pack_Start
        (Get_Action_Area (Shared_Resource_Dialog),
         Shared_Resource_Dialog.Hbox74);

      Gtk_New (Shared_Resource_Dialog.Ok_Button, -"OK");
      Set_Relief (Shared_Resource_Dialog.Ok_Button, Relief_Normal);
      Pack_Start
        (Shared_Resource_Dialog.Hbox74,
         Shared_Resource_Dialog.Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Shared_Resource_Dialog.Cancel_Button, -"Cancel");
      Set_Relief (Shared_Resource_Dialog.Cancel_Button, Relief_Normal);
      Pack_End
        (Shared_Resource_Dialog.Hbox74,
         Shared_Resource_Dialog.Cancel_Button,
         Expand  => True,
         Fill    => True,
         Padding => 0);
      --     Button_Callback.Connect
      --       (Shared_Resource_Dialog.Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Cancel_Button_Clicked'Access), False);

      Dialog_Callback.Object_Connect
        (Shared_Resource_Dialog.Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access),
         Shared_Resource_Dialog);

      Gtk_New (Shared_Resource_Dialog.Table1, 5, 2, False);
      Set_Border_Width (Shared_Resource_Dialog.Table1, 10);
      Set_Row_Spacings (Shared_Resource_Dialog.Table1, 3);
      Set_Col_Spacings (Shared_Resource_Dialog.Table1, 3);
      Pack_Start
        (Get_Vbox (Shared_Resource_Dialog),
         Shared_Resource_Dialog.Table1,
         Expand  => False,
         Fill    => True,
         Padding => 0);

      Gtk_New (Shared_Resource_Dialog.Preassigned_Label, -("Preassigned"));
      Set_Alignment (Shared_Resource_Dialog.Preassigned_Label, 0.95, 0.5);
      Set_Padding (Shared_Resource_Dialog.Preassigned_Label, 0, 0);
      Set_Justify (Shared_Resource_Dialog.Preassigned_Label, Justify_Center);
      Set_Line_Wrap (Shared_Resource_Dialog.Preassigned_Label, False);
      Set_Selectable (Shared_Resource_Dialog.Preassigned_Label, False);
      Set_Use_Markup (Shared_Resource_Dialog.Preassigned_Label, False);
      Set_Use_Underline (Shared_Resource_Dialog.Preassigned_Label, False);
      Attach
        (Shared_Resource_Dialog.Table1,
         Shared_Resource_Dialog.Preassigned_Label,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Shared_Resource_Dialog.Preassigned_Combo);
      Set_Value_In_List (Shared_Resource_Dialog.Preassigned_Combo, False);
      Set_Use_Arrows (Shared_Resource_Dialog.Preassigned_Combo, True);
      Set_Case_Sensitive (Shared_Resource_Dialog.Preassigned_Combo, False);
      Set_Editable
        (Get_Entry (Shared_Resource_Dialog.Preassigned_Combo),
         False);
      Set_Has_Frame
        (Get_Entry (Shared_Resource_Dialog.Preassigned_Combo),
         True);
      Set_Max_Length
        (Get_Entry (Shared_Resource_Dialog.Preassigned_Combo),
         0);
      Set_Text
        (Get_Entry (Shared_Resource_Dialog.Preassigned_Combo),
         -("NO"));
      Set_Invisible_Char
        (Get_Entry (Shared_Resource_Dialog.Preassigned_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Shared_Resource_Dialog.Preassigned_Combo),
         True);
      String_List.Append (Preassigned_Combo_Items, -("NO"));
      String_List.Append (Preassigned_Combo_Items, -("YES"));
      Combo.Set_Popdown_Strings
        (Shared_Resource_Dialog.Preassigned_Combo,
         Preassigned_Combo_Items);
      Free_String_List (Preassigned_Combo_Items);
      Attach
        (Shared_Resource_Dialog.Table1,
         Shared_Resource_Dialog.Preassigned_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Shared_Resource_Dialog.Ceiling_Label,
         -("Ceiling Priority"));
      Set_Alignment (Shared_Resource_Dialog.Ceiling_Label, 0.95, 0.5);
      Set_Padding (Shared_Resource_Dialog.Ceiling_Label, 0, 0);
      Set_Justify (Shared_Resource_Dialog.Ceiling_Label, Justify_Center);
      Set_Line_Wrap (Shared_Resource_Dialog.Ceiling_Label, False);
      Set_Selectable (Shared_Resource_Dialog.Ceiling_Label, False);
      Set_Use_Markup (Shared_Resource_Dialog.Ceiling_Label, False);
      Set_Use_Underline (Shared_Resource_Dialog.Ceiling_Label, False);
      Attach
        (Shared_Resource_Dialog.Table1,
         Shared_Resource_Dialog.Ceiling_Label,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Shared_Resource_Dialog.Ceiling_Entry);
      Set_Editable (Shared_Resource_Dialog.Ceiling_Entry, True);
      Set_Max_Length (Shared_Resource_Dialog.Ceiling_Entry, 0);
      Set_Text (Shared_Resource_Dialog.Ceiling_Entry, -("32767"));
      Set_Visibility (Shared_Resource_Dialog.Ceiling_Entry, True);
      Set_Invisible_Char
        (Shared_Resource_Dialog.Ceiling_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Shared_Resource_Dialog.Table1,
         Shared_Resource_Dialog.Ceiling_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Shared_Resource_Dialog.Label125, -("Type"));
      Set_Alignment (Shared_Resource_Dialog.Label125, 0.95, 0.5);
      Set_Padding (Shared_Resource_Dialog.Label125, 0, 0);
      Set_Justify (Shared_Resource_Dialog.Label125, Justify_Center);
      Set_Line_Wrap (Shared_Resource_Dialog.Label125, False);
      Set_Selectable (Shared_Resource_Dialog.Label125, False);
      Set_Use_Markup (Shared_Resource_Dialog.Label125, False);
      Set_Use_Underline (Shared_Resource_Dialog.Label125, False);
      Attach
        (Shared_Resource_Dialog.Table1,
         Shared_Resource_Dialog.Label125,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Shared_Resource_Dialog.Shared_Res_Type_Combo);
      Set_Value_In_List (Shared_Resource_Dialog.Shared_Res_Type_Combo, False);
      Set_Use_Arrows (Shared_Resource_Dialog.Shared_Res_Type_Combo, True);
      Set_Case_Sensitive
        (Shared_Resource_Dialog.Shared_Res_Type_Combo,
         False);
      Set_Editable
        (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo),
         False);
      Set_Has_Frame
        (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo),
         True);
      Set_Max_Length
        (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo),
         0);
      Set_Text
        (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo),
         -("Immediate Ceiling Resource"));
      Set_Invisible_Char
        (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo),
         True);

      String_List.Append
        (Shared_Res_Type_Combo_Items,
         -("Immediate Ceiling Resource"));
      String_List.Append
        (Shared_Res_Type_Combo_Items,
         -("Priority Inheritance Resource"));
      String_List.Append
        (Shared_Res_Type_Combo_Items,
         -("Stack Resource Policy"));
      Combo.Set_Popdown_Strings
        (Shared_Resource_Dialog.Shared_Res_Type_Combo,
         Shared_Res_Type_Combo_Items);
      Free_String_List (Shared_Res_Type_Combo_Items);
      Attach
        (Shared_Resource_Dialog.Table1,
         Shared_Resource_Dialog.Shared_Res_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Shared_Resource_Dialog.Label124, -("Name"));
      Set_Alignment (Shared_Resource_Dialog.Label124, 0.95, 0.5);
      Set_Padding (Shared_Resource_Dialog.Label124, 0, 0);
      Set_Justify (Shared_Resource_Dialog.Label124, Justify_Center);
      Set_Line_Wrap (Shared_Resource_Dialog.Label124, False);
      Set_Selectable (Shared_Resource_Dialog.Label124, False);
      Set_Use_Markup (Shared_Resource_Dialog.Label124, False);
      Set_Use_Underline (Shared_Resource_Dialog.Label124, False);
      Attach
        (Shared_Resource_Dialog.Table1,
         Shared_Resource_Dialog.Label124,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Shared_Resource_Dialog.Shared_Res_Name_Entry);
      Set_Editable (Shared_Resource_Dialog.Shared_Res_Name_Entry, True);
      Set_Max_Length (Shared_Resource_Dialog.Shared_Res_Name_Entry, 0);
      Set_Text (Shared_Resource_Dialog.Shared_Res_Name_Entry, -(""));
      Set_Visibility (Shared_Resource_Dialog.Shared_Res_Name_Entry, True);
      Set_Invisible_Char
        (Shared_Resource_Dialog.Shared_Res_Name_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Shared_Resource_Dialog.Table1,
         Shared_Resource_Dialog.Shared_Res_Name_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Shared_Resource_Dialog.Level_Label, -("Preemption Level"));
      Set_Alignment (Shared_Resource_Dialog.Level_Label, 0.95, 0.5);
      Set_Padding (Shared_Resource_Dialog.Level_Label, 0, 0);
      Set_Justify (Shared_Resource_Dialog.Level_Label, Justify_Center);
      Set_Line_Wrap (Shared_Resource_Dialog.Level_Label, False);
      Set_Selectable (Shared_Resource_Dialog.Level_Label, False);
      Set_Use_Markup (Shared_Resource_Dialog.Level_Label, False);
      Set_Use_Underline (Shared_Resource_Dialog.Level_Label, False);
      Attach
        (Shared_Resource_Dialog.Table1,
         Shared_Resource_Dialog.Level_Label,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Shared_Resource_Dialog.Level_Entry);
      Set_Editable (Shared_Resource_Dialog.Level_Entry, True);
      Set_Max_Length (Shared_Resource_Dialog.Level_Entry, 0);
      Set_Text (Shared_Resource_Dialog.Level_Entry, -("32767"));
      Set_Visibility (Shared_Resource_Dialog.Level_Entry, True);
      Set_Invisible_Char
        (Shared_Resource_Dialog.Level_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Shared_Resource_Dialog.Table1,
         Shared_Resource_Dialog.Level_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xpadding      => 0,
         Ypadding      => 0);

      --     Entry_Callback.Connect
      --       (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo),
      --"changed",
      --        Entry_Callback.To_Marshaller
      --(On_Shared_Res_Type_Entry_Changed'Access), False);

      Shared_Resource_Dialog_Callback.Object_Connect
        (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo),
         "changed",
         Shared_Resource_Dialog_Callback.To_Marshaller
            (On_Shared_Res_Type_Entry_Changed'Access),
         Shared_Resource_Dialog);

   end Initialize;

end Shared_Resource_Dialog_Pkg;
