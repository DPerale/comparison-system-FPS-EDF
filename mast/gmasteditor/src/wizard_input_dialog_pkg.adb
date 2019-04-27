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
with Glib;                              use Glib;
with Gtk;                               use Gtk;
with Gdk.Types;                         use Gdk.Types;
with Gtk.Widget;                        use Gtk.Widget;
with Gtk.Enums;                         use Gtk.Enums;
with Gtkada.Handlers;                   use Gtkada.Handlers;
with Callbacks_Mast_Editor;             use Callbacks_Mast_Editor;
with Mast_Editor_Intl;                  use Mast_Editor_Intl;
with Wizard_Input_Dialog_Pkg.Callbacks; use Wizard_Input_Dialog_Pkg.Callbacks;
with Mast;

package body Wizard_Input_Dialog_Pkg is

   procedure Gtk_New (Wizard_Input_Dialog : out Wizard_Input_Dialog_Access) is
   begin
      Wizard_Input_Dialog := new Wizard_Input_Dialog_Record;
      Wizard_Input_Dialog_Pkg.Initialize (Wizard_Input_Dialog);
   end Gtk_New;

   procedure Initialize
     (Wizard_Input_Dialog : access Wizard_Input_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Pixmaps_Dir                     : constant String := "";
      External_Event_Type_Combo_Items : String_List.Glist;
      Spo_Dist_Func_Combo_Items       : String_List.Glist;
      Unb_Dist_Func_Combo_Items       : String_List.Glist;
      Bur_Dist_Func_Combo_Items       : String_List.Glist;

   begin
      Gtk.Dialog.Initialize (Wizard_Input_Dialog);
      Set_Title (Wizard_Input_Dialog, -"Editor Wizard Tool - Step 2 of 4");
      Set_Position (Wizard_Input_Dialog, Win_Pos_Center_Always);
      Set_Modal (Wizard_Input_Dialog, True);
      Set_Policy (Wizard_Input_Dialog, False, False, False);

      Gtk_New (Wizard_Input_Dialog.Cancel_Button);
      Set_Relief (Wizard_Input_Dialog.Cancel_Button, Relief_Normal);
      Set_Flags (Wizard_Input_Dialog.Cancel_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Input_Dialog),
         Wizard_Input_Dialog.Cancel_Button);

      Gtk_New (Wizard_Input_Dialog.Alignment12, 0.5, 0.5, 0.0, 0.0);
      Add
        (Wizard_Input_Dialog.Cancel_Button,
         Wizard_Input_Dialog.Alignment12);

      Gtk_New_Hbox (Wizard_Input_Dialog.Hbox88, False, 2);
      Add (Wizard_Input_Dialog.Alignment12, Wizard_Input_Dialog.Hbox88);

      Gtk_New
        (Wizard_Input_Dialog.Image15,
         "gtk-cancel",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Input_Dialog.Image15, 0.5, 0.5);
      Set_Padding (Wizard_Input_Dialog.Image15, 0, 0);
      Pack_Start
        (Wizard_Input_Dialog.Hbox88,
         Wizard_Input_Dialog.Image15,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Input_Dialog.Label542, -("Cancel"));
      Set_Alignment (Wizard_Input_Dialog.Label542, 0.5, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label542, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label542, Justify_Left);
      Set_Line_Wrap (Wizard_Input_Dialog.Label542, False);
      Set_Selectable (Wizard_Input_Dialog.Label542, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label542, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label542, True);
      Pack_Start
        (Wizard_Input_Dialog.Hbox88,
         Wizard_Input_Dialog.Label542,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Input_Dialog.Back_Button);
      Set_Relief (Wizard_Input_Dialog.Back_Button, Relief_Normal);
      Set_Flags (Wizard_Input_Dialog.Back_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Input_Dialog),
         Wizard_Input_Dialog.Back_Button);

      Gtk_New (Wizard_Input_Dialog.Alignment13, 0.5, 0.5, 0.0, 0.0);
      Add (Wizard_Input_Dialog.Back_Button, Wizard_Input_Dialog.Alignment13);

      Gtk_New_Hbox (Wizard_Input_Dialog.Hbox89, False, 2);
      Add (Wizard_Input_Dialog.Alignment13, Wizard_Input_Dialog.Hbox89);

      Gtk_New
        (Wizard_Input_Dialog.Image16,
         "gtk-go-back",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Input_Dialog.Image16, 0.5, 0.5);
      Set_Padding (Wizard_Input_Dialog.Image16, 0, 0);
      Pack_Start
        (Wizard_Input_Dialog.Hbox89,
         Wizard_Input_Dialog.Image16,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Input_Dialog.Label543, -("Back"));
      Set_Alignment (Wizard_Input_Dialog.Label543, 0.5, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label543, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label543, Justify_Left);
      Set_Line_Wrap (Wizard_Input_Dialog.Label543, False);
      Set_Selectable (Wizard_Input_Dialog.Label543, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label543, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label543, True);
      Pack_Start
        (Wizard_Input_Dialog.Hbox89,
         Wizard_Input_Dialog.Label543,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Input_Dialog.Next_Button);
      Set_Relief (Wizard_Input_Dialog.Next_Button, Relief_Normal);
      Set_Flags (Wizard_Input_Dialog.Next_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Input_Dialog),
         Wizard_Input_Dialog.Next_Button);

      Gtk_New (Wizard_Input_Dialog.Alignment14, 0.5, 0.5, 0.0, 0.0);
      Add (Wizard_Input_Dialog.Next_Button, Wizard_Input_Dialog.Alignment14);

      Gtk_New_Hbox (Wizard_Input_Dialog.Hbox90, False, 2);
      Add (Wizard_Input_Dialog.Alignment14, Wizard_Input_Dialog.Hbox90);

      Gtk_New
        (Wizard_Input_Dialog.Image17,
         "gtk-go-forward",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Input_Dialog.Image17, 0.5, 0.5);
      Set_Padding (Wizard_Input_Dialog.Image17, 0, 0);
      Pack_Start
        (Wizard_Input_Dialog.Hbox90,
         Wizard_Input_Dialog.Image17,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Input_Dialog.Label544, -("Next"));
      Set_Alignment (Wizard_Input_Dialog.Label544, 0.5, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label544, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label544, Justify_Left);
      Set_Line_Wrap (Wizard_Input_Dialog.Label544, False);
      Set_Selectable (Wizard_Input_Dialog.Label544, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label544, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label544, True);
      Pack_Start
        (Wizard_Input_Dialog.Hbox90,
         Wizard_Input_Dialog.Label544,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Input_Dialog.Table3, 6, 6, False);
      Set_Row_Spacings (Wizard_Input_Dialog.Table3, 0);
      Set_Col_Spacings (Wizard_Input_Dialog.Table3, 0);
      Pack_Start
        (Get_Vbox (Wizard_Input_Dialog),
         Wizard_Input_Dialog.Table3,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Wizard_Input_Dialog.Image, Pixmaps_Dir & "mast_logo.xpm");
      Set_Alignment (Wizard_Input_Dialog.Image, 0.5, 0.5);
      Set_Padding (Wizard_Input_Dialog.Image, 0, 0);
      Attach
        (Wizard_Input_Dialog.Table3,
         Wizard_Input_Dialog.Image,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Yoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Wizard_Input_Dialog.Label,
         -("Please, select Input Event type and " &
           ASCII.LF &
           "configure its parameters ..."));
      Set_Alignment (Wizard_Input_Dialog.Label, 0.0, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label, Justify_Left);
      Set_Line_Wrap (Wizard_Input_Dialog.Label, True);
      Set_Selectable (Wizard_Input_Dialog.Label, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label, False);
      Attach
        (Wizard_Input_Dialog.Table3,
         Wizard_Input_Dialog.Label,
         Left_Attach   => 2,
         Right_Attach  => 6,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Frame3);
      Set_Border_Width (Wizard_Input_Dialog.Frame3, 10);
      Set_Label_Align (Wizard_Input_Dialog.Frame3, 0.0, 0.5);
      Set_Shadow_Type (Wizard_Input_Dialog.Frame3, Shadow_Etched_In);
      Attach
        (Wizard_Input_Dialog.Table3,
         Wizard_Input_Dialog.Frame3,
         Left_Attach   => 0,
         Right_Attach  => 6,
         Top_Attach    => 1,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New_Vbox (Wizard_Input_Dialog.Vbox31, False, 0);
      Add (Wizard_Input_Dialog.Frame3, Wizard_Input_Dialog.Vbox31);

      Gtk_New (Wizard_Input_Dialog.Table1, 2, 2, True);
      Set_Border_Width (Wizard_Input_Dialog.Table1, 5);
      Set_Row_Spacings (Wizard_Input_Dialog.Table1, 3);
      Set_Col_Spacings (Wizard_Input_Dialog.Table1, 3);
      Pack_Start
        (Wizard_Input_Dialog.Vbox31,
         Wizard_Input_Dialog.Table1,
         Expand  => False,
         Fill    => False,
         Padding => 5);

      Gtk_New (Wizard_Input_Dialog.Label546, -("Event Name"));
      Set_Alignment (Wizard_Input_Dialog.Label546, 0.95, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label546, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label546, Justify_Center);
      Set_Line_Wrap (Wizard_Input_Dialog.Label546, False);
      Set_Selectable (Wizard_Input_Dialog.Label546, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label546, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label546, False);
      Attach
        (Wizard_Input_Dialog.Table1,
         Wizard_Input_Dialog.Label546,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Label547, -("Type"));
      Set_Alignment (Wizard_Input_Dialog.Label547, 0.95, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label547, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label547, Justify_Center);
      Set_Line_Wrap (Wizard_Input_Dialog.Label547, False);
      Set_Selectable (Wizard_Input_Dialog.Label547, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label547, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label547, False);
      Attach
        (Wizard_Input_Dialog.Table1,
         Wizard_Input_Dialog.Label547,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.External_Event_Name_Entry);
      Set_Editable (Wizard_Input_Dialog.External_Event_Name_Entry, True);
      Set_Max_Length (Wizard_Input_Dialog.External_Event_Name_Entry, 0);
      Set_Text (Wizard_Input_Dialog.External_Event_Name_Entry, -(""));
      Set_Visibility (Wizard_Input_Dialog.External_Event_Name_Entry, True);
      Set_Invisible_Char
        (Wizard_Input_Dialog.External_Event_Name_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Wizard_Input_Dialog.Table1,
         Wizard_Input_Dialog.External_Event_Name_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.External_Event_Type_Combo);
      Set_Value_In_List
        (Wizard_Input_Dialog.External_Event_Type_Combo,
         False);
      Set_Use_Arrows (Wizard_Input_Dialog.External_Event_Type_Combo, True);
      Set_Case_Sensitive
        (Wizard_Input_Dialog.External_Event_Type_Combo,
         False);
      Set_Editable
        (Get_Entry (Wizard_Input_Dialog.External_Event_Type_Combo),
         False);
      Set_Has_Frame
        (Get_Entry (Wizard_Input_Dialog.External_Event_Type_Combo),
         True);
      Set_Max_Length
        (Get_Entry (Wizard_Input_Dialog.External_Event_Type_Combo),
         0);
      Set_Text
        (Get_Entry (Wizard_Input_Dialog.External_Event_Type_Combo),
         -("Periodic"));
      Set_Invisible_Char
        (Get_Entry (Wizard_Input_Dialog.External_Event_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Wizard_Input_Dialog.External_Event_Type_Combo),
         True);

      --     Entry_Callback.Connect
      --       (Get_Entry (Wizard_Input_Dialog.External_Event_Type_Combo),
      --"changed",
      --        Entry_Callback.To_Marshaller
      --(On_External_Event_Type_Entry_Changed'Access), False);

      Wizard_Input_Dialog_Callback.Object_Connect
        (Get_Entry (Wizard_Input_Dialog.External_Event_Type_Combo),
         "changed",
         Wizard_Input_Dialog_Callback.To_Marshaller
            (On_External_Event_Type_Changed'Access),
         Wizard_Input_Dialog);

      String_List.Append (External_Event_Type_Combo_Items, -("Periodic"));
      String_List.Append (External_Event_Type_Combo_Items, -("Singular"));
      String_List.Append (External_Event_Type_Combo_Items, -("Sporadic"));
      String_List.Append (External_Event_Type_Combo_Items, -("Unbounded"));
      String_List.Append (External_Event_Type_Combo_Items, -("Bursty"));
      Combo.Set_Popdown_Strings
        (Wizard_Input_Dialog.External_Event_Type_Combo,
         External_Event_Type_Combo_Items);
      Free_String_List (External_Event_Type_Combo_Items);
      Attach
        (Wizard_Input_Dialog.Table1,
         Wizard_Input_Dialog.External_Event_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Periodic_Table, 3, 2, True);
      Set_Border_Width (Wizard_Input_Dialog.Periodic_Table, 5);
      Set_Row_Spacings (Wizard_Input_Dialog.Periodic_Table, 3);
      Set_Col_Spacings (Wizard_Input_Dialog.Periodic_Table, 3);
      Pack_Start
        (Wizard_Input_Dialog.Vbox31,
         Wizard_Input_Dialog.Periodic_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Wizard_Input_Dialog.Label548, -("Phase"));
      Set_Alignment (Wizard_Input_Dialog.Label548, 0.95, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label548, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label548, Justify_Center);
      Set_Line_Wrap (Wizard_Input_Dialog.Label548, False);
      Set_Selectable (Wizard_Input_Dialog.Label548, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label548, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label548, False);
      Attach
        (Wizard_Input_Dialog.Periodic_Table,
         Wizard_Input_Dialog.Label548,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Label549, -("Maximum Jitter"));
      Set_Alignment (Wizard_Input_Dialog.Label549, 0.95, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label549, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label549, Justify_Center);
      Set_Line_Wrap (Wizard_Input_Dialog.Label549, False);
      Set_Selectable (Wizard_Input_Dialog.Label549, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label549, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label549, False);
      Attach
        (Wizard_Input_Dialog.Periodic_Table,
         Wizard_Input_Dialog.Label549,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Label550, -("Period"));
      Set_Alignment (Wizard_Input_Dialog.Label550, 0.95, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label550, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label550, Justify_Center);
      Set_Line_Wrap (Wizard_Input_Dialog.Label550, False);
      Set_Selectable (Wizard_Input_Dialog.Label550, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label550, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label550, False);
      Attach
        (Wizard_Input_Dialog.Periodic_Table,
         Wizard_Input_Dialog.Label550,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Max_Jitter_Entry);
      Set_Editable (Wizard_Input_Dialog.Max_Jitter_Entry, True);
      Set_Max_Length (Wizard_Input_Dialog.Max_Jitter_Entry, 0);
      Set_Text (Wizard_Input_Dialog.Max_Jitter_Entry, -("0.0"));
      Set_Visibility (Wizard_Input_Dialog.Max_Jitter_Entry, True);
      Set_Invisible_Char
        (Wizard_Input_Dialog.Max_Jitter_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Wizard_Input_Dialog.Periodic_Table,
         Wizard_Input_Dialog.Max_Jitter_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Period_Entry);
      Set_Editable (Wizard_Input_Dialog.Period_Entry, True);
      Set_Max_Length (Wizard_Input_Dialog.Period_Entry, 0);
      Set_Text (Wizard_Input_Dialog.Period_Entry, -("0.0"));
      Set_Visibility (Wizard_Input_Dialog.Period_Entry, True);
      Set_Invisible_Char
        (Wizard_Input_Dialog.Period_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Wizard_Input_Dialog.Periodic_Table,
         Wizard_Input_Dialog.Period_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Per_Phase_Entry);
      Set_Editable (Wizard_Input_Dialog.Per_Phase_Entry, True);
      Set_Max_Length (Wizard_Input_Dialog.Per_Phase_Entry, 0);
      Set_Text (Wizard_Input_Dialog.Per_Phase_Entry, -("0.0"));
      Set_Visibility (Wizard_Input_Dialog.Per_Phase_Entry, True);
      Set_Invisible_Char
        (Wizard_Input_Dialog.Per_Phase_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Wizard_Input_Dialog.Periodic_Table,
         Wizard_Input_Dialog.Per_Phase_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Singular_Table, 1, 2, True);
      Set_Border_Width (Wizard_Input_Dialog.Singular_Table, 5);
      Set_Row_Spacings (Wizard_Input_Dialog.Singular_Table, 3);
      Set_Col_Spacings (Wizard_Input_Dialog.Singular_Table, 3);
      Pack_Start
        (Wizard_Input_Dialog.Vbox31,
         Wizard_Input_Dialog.Singular_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Wizard_Input_Dialog.Label551, -("Phase"));
      Set_Alignment (Wizard_Input_Dialog.Label551, 0.95, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label551, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label551, Justify_Center);
      Set_Line_Wrap (Wizard_Input_Dialog.Label551, False);
      Set_Selectable (Wizard_Input_Dialog.Label551, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label551, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label551, False);
      Attach
        (Wizard_Input_Dialog.Singular_Table,
         Wizard_Input_Dialog.Label551,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Sing_Phase_Entry);
      Set_Editable (Wizard_Input_Dialog.Sing_Phase_Entry, True);
      Set_Max_Length (Wizard_Input_Dialog.Sing_Phase_Entry, 0);
      Set_Text (Wizard_Input_Dialog.Sing_Phase_Entry, -("0.0"));
      Set_Visibility (Wizard_Input_Dialog.Sing_Phase_Entry, True);
      Set_Invisible_Char
        (Wizard_Input_Dialog.Sing_Phase_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Wizard_Input_Dialog.Singular_Table,
         Wizard_Input_Dialog.Sing_Phase_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Sporadic_Table, 3, 2, True);
      Set_Border_Width (Wizard_Input_Dialog.Sporadic_Table, 5);
      Set_Row_Spacings (Wizard_Input_Dialog.Sporadic_Table, 3);
      Set_Col_Spacings (Wizard_Input_Dialog.Sporadic_Table, 3);
      Pack_Start
        (Wizard_Input_Dialog.Vbox31,
         Wizard_Input_Dialog.Sporadic_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Wizard_Input_Dialog.Label552, -("Min Interarrival Time"));
      Set_Alignment (Wizard_Input_Dialog.Label552, 0.95, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label552, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label552, Justify_Center);
      Set_Line_Wrap (Wizard_Input_Dialog.Label552, False);
      Set_Selectable (Wizard_Input_Dialog.Label552, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label552, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label552, False);
      Attach
        (Wizard_Input_Dialog.Sporadic_Table,
         Wizard_Input_Dialog.Label552,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Label553, -("Distribution Function"));
      Set_Alignment (Wizard_Input_Dialog.Label553, 0.95, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label553, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label553, Justify_Center);
      Set_Line_Wrap (Wizard_Input_Dialog.Label553, False);
      Set_Selectable (Wizard_Input_Dialog.Label553, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label553, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label553, False);
      Attach
        (Wizard_Input_Dialog.Sporadic_Table,
         Wizard_Input_Dialog.Label553,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Spo_Avg_Entry);
      Set_Editable (Wizard_Input_Dialog.Spo_Avg_Entry, True);
      Set_Max_Length (Wizard_Input_Dialog.Spo_Avg_Entry, 0);
      Set_Text (Wizard_Input_Dialog.Spo_Avg_Entry, -("0.0"));
      Set_Visibility (Wizard_Input_Dialog.Spo_Avg_Entry, True);
      Set_Invisible_Char
        (Wizard_Input_Dialog.Spo_Avg_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Wizard_Input_Dialog.Sporadic_Table,
         Wizard_Input_Dialog.Spo_Avg_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Spo_Min_Entry);
      Set_Editable (Wizard_Input_Dialog.Spo_Min_Entry, True);
      Set_Max_Length (Wizard_Input_Dialog.Spo_Min_Entry, 0);
      Set_Text (Wizard_Input_Dialog.Spo_Min_Entry, -("0.0"));
      Set_Visibility (Wizard_Input_Dialog.Spo_Min_Entry, True);
      Set_Invisible_Char
        (Wizard_Input_Dialog.Spo_Min_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Wizard_Input_Dialog.Sporadic_Table,
         Wizard_Input_Dialog.Spo_Min_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Spo_Dist_Func_Combo);
      Set_Value_In_List (Wizard_Input_Dialog.Spo_Dist_Func_Combo, False);
      Set_Use_Arrows (Wizard_Input_Dialog.Spo_Dist_Func_Combo, True);
      Set_Case_Sensitive (Wizard_Input_Dialog.Spo_Dist_Func_Combo, False);
      Set_Editable
        (Get_Entry (Wizard_Input_Dialog.Spo_Dist_Func_Combo),
         False);
      Set_Has_Frame
        (Get_Entry (Wizard_Input_Dialog.Spo_Dist_Func_Combo),
         True);
      Set_Max_Length (Get_Entry (Wizard_Input_Dialog.Spo_Dist_Func_Combo), 0);
      Set_Text
        (Get_Entry (Wizard_Input_Dialog.Spo_Dist_Func_Combo),
         -("Uniform"));
      Set_Invisible_Char
        (Get_Entry (Wizard_Input_Dialog.Spo_Dist_Func_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Wizard_Input_Dialog.Spo_Dist_Func_Combo),
         True);
      for Distrib in Mast.Distribution_Function'Range loop
         String_List.Append (Spo_Dist_Func_Combo_Items,
                             -(Mast.Distribution_Function'Image(Distrib)));
      end loop;
      Combo.Set_Popdown_Strings
        (Wizard_Input_Dialog.Spo_Dist_Func_Combo,
         Spo_Dist_Func_Combo_Items);
      Free_String_List (Spo_Dist_Func_Combo_Items);
      Attach
        (Wizard_Input_Dialog.Sporadic_Table,
         Wizard_Input_Dialog.Spo_Dist_Func_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Label554, -("Avg Interarrival Time"));
      Set_Alignment (Wizard_Input_Dialog.Label554, 0.95, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label554, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label554, Justify_Center);
      Set_Line_Wrap (Wizard_Input_Dialog.Label554, False);
      Set_Selectable (Wizard_Input_Dialog.Label554, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label554, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label554, False);
      Attach
        (Wizard_Input_Dialog.Sporadic_Table,
         Wizard_Input_Dialog.Label554,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Unbounded_Table, 2, 2, True);
      Set_Border_Width (Wizard_Input_Dialog.Unbounded_Table, 5);
      Set_Row_Spacings (Wizard_Input_Dialog.Unbounded_Table, 3);
      Set_Col_Spacings (Wizard_Input_Dialog.Unbounded_Table, 3);
      Pack_Start
        (Wizard_Input_Dialog.Vbox31,
         Wizard_Input_Dialog.Unbounded_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Wizard_Input_Dialog.Unb_Avg_Entry);
      Set_Editable (Wizard_Input_Dialog.Unb_Avg_Entry, True);
      Set_Max_Length (Wizard_Input_Dialog.Unb_Avg_Entry, 0);
      Set_Text (Wizard_Input_Dialog.Unb_Avg_Entry, -("0.0"));
      Set_Visibility (Wizard_Input_Dialog.Unb_Avg_Entry, True);
      Set_Invisible_Char
        (Wizard_Input_Dialog.Unb_Avg_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Wizard_Input_Dialog.Unbounded_Table,
         Wizard_Input_Dialog.Unb_Avg_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Label555, -("Avg Interarrival Time"));
      Set_Alignment (Wizard_Input_Dialog.Label555, 0.95, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label555, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label555, Justify_Center);
      Set_Line_Wrap (Wizard_Input_Dialog.Label555, False);
      Set_Selectable (Wizard_Input_Dialog.Label555, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label555, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label555, False);
      Attach
        (Wizard_Input_Dialog.Unbounded_Table,
         Wizard_Input_Dialog.Label555,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Unb_Dist_Func_Combo);
      Set_Value_In_List (Wizard_Input_Dialog.Unb_Dist_Func_Combo, False);
      Set_Use_Arrows (Wizard_Input_Dialog.Unb_Dist_Func_Combo, True);
      Set_Case_Sensitive (Wizard_Input_Dialog.Unb_Dist_Func_Combo, False);
      Set_Editable
        (Get_Entry (Wizard_Input_Dialog.Unb_Dist_Func_Combo),
         False);
      Set_Has_Frame
        (Get_Entry (Wizard_Input_Dialog.Unb_Dist_Func_Combo),
         True);
      Set_Max_Length (Get_Entry (Wizard_Input_Dialog.Unb_Dist_Func_Combo), 0);
      Set_Text
        (Get_Entry (Wizard_Input_Dialog.Unb_Dist_Func_Combo),
         -("Uniform"));
      Set_Invisible_Char
        (Get_Entry (Wizard_Input_Dialog.Unb_Dist_Func_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Wizard_Input_Dialog.Unb_Dist_Func_Combo),
         True);
      for Distrib in Mast.Distribution_Function'Range loop
         String_List.Append (Unb_Dist_Func_Combo_Items,
                             -(Mast.Distribution_Function'Image(Distrib)));
      end loop;
      Combo.Set_Popdown_Strings
        (Wizard_Input_Dialog.Unb_Dist_Func_Combo,
         Unb_Dist_Func_Combo_Items);
      Free_String_List (Unb_Dist_Func_Combo_Items);
      Attach
        (Wizard_Input_Dialog.Unbounded_Table,
         Wizard_Input_Dialog.Unb_Dist_Func_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Label556, -("Distribution Function"));
      Set_Alignment (Wizard_Input_Dialog.Label556, 0.95, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label556, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label556, Justify_Center);
      Set_Line_Wrap (Wizard_Input_Dialog.Label556, False);
      Set_Selectable (Wizard_Input_Dialog.Label556, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label556, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label556, False);
      Attach
        (Wizard_Input_Dialog.Unbounded_Table,
         Wizard_Input_Dialog.Label556,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Bursty_Table, 4, 2, True);
      Set_Border_Width (Wizard_Input_Dialog.Bursty_Table, 5);
      Set_Row_Spacings (Wizard_Input_Dialog.Bursty_Table, 3);
      Set_Col_Spacings (Wizard_Input_Dialog.Bursty_Table, 3);
      Pack_Start
        (Wizard_Input_Dialog.Vbox31,
         Wizard_Input_Dialog.Bursty_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Wizard_Input_Dialog.Label557, -("Bound Interval"));
      Set_Alignment (Wizard_Input_Dialog.Label557, 0.95, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label557, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label557, Justify_Center);
      Set_Line_Wrap (Wizard_Input_Dialog.Label557, False);
      Set_Selectable (Wizard_Input_Dialog.Label557, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label557, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label557, False);
      Attach
        (Wizard_Input_Dialog.Bursty_Table,
         Wizard_Input_Dialog.Label557,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Label558, -("Distribution Function"));
      Set_Alignment (Wizard_Input_Dialog.Label558, 0.95, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label558, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label558, Justify_Center);
      Set_Line_Wrap (Wizard_Input_Dialog.Label558, False);
      Set_Selectable (Wizard_Input_Dialog.Label558, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label558, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label558, False);
      Attach
        (Wizard_Input_Dialog.Bursty_Table,
         Wizard_Input_Dialog.Label558,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Bur_Avg_Entry);
      Set_Editable (Wizard_Input_Dialog.Bur_Avg_Entry, True);
      Set_Max_Length (Wizard_Input_Dialog.Bur_Avg_Entry, 0);
      Set_Text (Wizard_Input_Dialog.Bur_Avg_Entry, -("0.0"));
      Set_Visibility (Wizard_Input_Dialog.Bur_Avg_Entry, True);
      Set_Invisible_Char
        (Wizard_Input_Dialog.Bur_Avg_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Wizard_Input_Dialog.Bursty_Table,
         Wizard_Input_Dialog.Bur_Avg_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Bur_Bound_Entry);
      Set_Editable (Wizard_Input_Dialog.Bur_Bound_Entry, True);
      Set_Max_Length (Wizard_Input_Dialog.Bur_Bound_Entry, 0);
      Set_Text (Wizard_Input_Dialog.Bur_Bound_Entry, -("0.0"));
      Set_Visibility (Wizard_Input_Dialog.Bur_Bound_Entry, True);
      Set_Invisible_Char
        (Wizard_Input_Dialog.Bur_Bound_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Wizard_Input_Dialog.Bursty_Table,
         Wizard_Input_Dialog.Bur_Bound_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Bur_Dist_Func_Combo);
      Set_Value_In_List (Wizard_Input_Dialog.Bur_Dist_Func_Combo, False);
      Set_Use_Arrows (Wizard_Input_Dialog.Bur_Dist_Func_Combo, True);
      Set_Case_Sensitive (Wizard_Input_Dialog.Bur_Dist_Func_Combo, False);
      Set_Editable
        (Get_Entry (Wizard_Input_Dialog.Bur_Dist_Func_Combo),
         False);
      Set_Has_Frame
        (Get_Entry (Wizard_Input_Dialog.Bur_Dist_Func_Combo),
         True);
      Set_Max_Length (Get_Entry (Wizard_Input_Dialog.Bur_Dist_Func_Combo), 0);
      Set_Text
        (Get_Entry (Wizard_Input_Dialog.Bur_Dist_Func_Combo),
         -("Uniform"));
      Set_Invisible_Char
        (Get_Entry (Wizard_Input_Dialog.Bur_Dist_Func_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Wizard_Input_Dialog.Bur_Dist_Func_Combo),
         True);
      for Distrib in Mast.Distribution_Function'Range loop
         String_List.Append (Bur_Dist_Func_Combo_Items,
                             -(Mast.Distribution_Function'Image(Distrib)));
      end loop;
      Combo.Set_Popdown_Strings
        (Wizard_Input_Dialog.Bur_Dist_Func_Combo,
         Bur_Dist_Func_Combo_Items);
      Free_String_List (Bur_Dist_Func_Combo_Items);
      Attach
        (Wizard_Input_Dialog.Bursty_Table,
         Wizard_Input_Dialog.Bur_Dist_Func_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Label559, -("Avg Interarrival Time"));
      Set_Alignment (Wizard_Input_Dialog.Label559, 0.95, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label559, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label559, Justify_Center);
      Set_Line_Wrap (Wizard_Input_Dialog.Label559, False);
      Set_Selectable (Wizard_Input_Dialog.Label559, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label559, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label559, False);
      Attach
        (Wizard_Input_Dialog.Bursty_Table,
         Wizard_Input_Dialog.Label559,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Label560, -("Max Arrivals"));
      Set_Alignment (Wizard_Input_Dialog.Label560, 0.95, 0.5);
      Set_Padding (Wizard_Input_Dialog.Label560, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Label560, Justify_Center);
      Set_Line_Wrap (Wizard_Input_Dialog.Label560, False);
      Set_Selectable (Wizard_Input_Dialog.Label560, False);
      Set_Use_Markup (Wizard_Input_Dialog.Label560, False);
      Set_Use_Underline (Wizard_Input_Dialog.Label560, False);
      Attach
        (Wizard_Input_Dialog.Bursty_Table,
         Wizard_Input_Dialog.Label560,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Input_Dialog.Max_Arrival_Entry);
      Set_Editable (Wizard_Input_Dialog.Max_Arrival_Entry, True);
      Set_Max_Length (Wizard_Input_Dialog.Max_Arrival_Entry, 0);
      Set_Text (Wizard_Input_Dialog.Max_Arrival_Entry, -("1"));
      Set_Visibility (Wizard_Input_Dialog.Max_Arrival_Entry, True);
      Set_Invisible_Char
        (Wizard_Input_Dialog.Max_Arrival_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Wizard_Input_Dialog.Bursty_Table,
         Wizard_Input_Dialog.Max_Arrival_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Wizard_Input_Dialog.Frame_Label,
         -("INPUT EVENT PARAMETERS  "));
      Set_Alignment (Wizard_Input_Dialog.Frame_Label, 0.5, 0.5);
      Set_Padding (Wizard_Input_Dialog.Frame_Label, 0, 0);
      Set_Justify (Wizard_Input_Dialog.Frame_Label, Justify_Left);
      Set_Line_Wrap (Wizard_Input_Dialog.Frame_Label, False);
      Set_Selectable (Wizard_Input_Dialog.Frame_Label, False);
      Set_Use_Markup (Wizard_Input_Dialog.Frame_Label, False);
      Set_Use_Underline (Wizard_Input_Dialog.Frame_Label, False);
      Set_Label_Widget
        (Wizard_Input_Dialog.Frame3,
         Wizard_Input_Dialog.Frame_Label);

   end Initialize;

end Wizard_Input_Dialog_Pkg;
