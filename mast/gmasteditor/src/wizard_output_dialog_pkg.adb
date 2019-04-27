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

package body Wizard_Output_Dialog_Pkg is

   procedure Gtk_New
     (Wizard_Output_Dialog : out Wizard_Output_Dialog_Access)
   is
   begin
      Wizard_Output_Dialog := new Wizard_Output_Dialog_Record;
      Wizard_Output_Dialog_Pkg.Initialize (Wizard_Output_Dialog);
   end Gtk_New;

   procedure Initialize
     (Wizard_Output_Dialog : access Wizard_Output_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Pixmaps_Dir : constant String := "";
   begin
      Gtk.Dialog.Initialize (Wizard_Output_Dialog);
      Set_Title (Wizard_Output_Dialog, -"Editor Wizard Tool - Step 4 of 4");
      Set_Position (Wizard_Output_Dialog, Win_Pos_None);
      Set_Modal (Wizard_Output_Dialog, True);

      Gtk_New (Wizard_Output_Dialog.Cancel_Button);
      Set_Relief (Wizard_Output_Dialog.Cancel_Button, Relief_Normal);
      Set_Flags (Wizard_Output_Dialog.Cancel_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Output_Dialog),
         Wizard_Output_Dialog.Cancel_Button);

      Gtk_New (Wizard_Output_Dialog.Alignment18, 0.5, 0.5, 0.0, 0.0);
      Add
        (Wizard_Output_Dialog.Cancel_Button,
         Wizard_Output_Dialog.Alignment18);

      Gtk_New_Hbox (Wizard_Output_Dialog.Hbox94, False, 2);
      Add (Wizard_Output_Dialog.Alignment18, Wizard_Output_Dialog.Hbox94);

      Gtk_New
        (Wizard_Output_Dialog.Image23,
         "gtk-cancel",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Output_Dialog.Image23, 0.5, 0.5);
      Set_Padding (Wizard_Output_Dialog.Image23, 0, 0);
      Pack_Start
        (Wizard_Output_Dialog.Hbox94,
         Wizard_Output_Dialog.Image23,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Output_Dialog.Label588, -("Cancel"));
      Set_Alignment (Wizard_Output_Dialog.Label588, 0.5, 0.5);
      Set_Padding (Wizard_Output_Dialog.Label588, 0, 0);
      Set_Justify (Wizard_Output_Dialog.Label588, Justify_Left);
      Set_Line_Wrap (Wizard_Output_Dialog.Label588, False);
      Set_Selectable (Wizard_Output_Dialog.Label588, False);
      Set_Use_Markup (Wizard_Output_Dialog.Label588, False);
      Set_Use_Underline (Wizard_Output_Dialog.Label588, True);
      Pack_Start
        (Wizard_Output_Dialog.Hbox94,
         Wizard_Output_Dialog.Label588,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Output_Dialog.Back_Button);
      Set_Relief (Wizard_Output_Dialog.Back_Button, Relief_Normal);
      Set_Flags (Wizard_Output_Dialog.Back_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Output_Dialog),
         Wizard_Output_Dialog.Back_Button);

      Gtk_New (Wizard_Output_Dialog.Alignment19, 0.5, 0.5, 0.0, 0.0);
      Add
        (Wizard_Output_Dialog.Back_Button,
         Wizard_Output_Dialog.Alignment19);

      Gtk_New_Hbox (Wizard_Output_Dialog.Hbox95, False, 2);
      Add (Wizard_Output_Dialog.Alignment19, Wizard_Output_Dialog.Hbox95);

      Gtk_New
        (Wizard_Output_Dialog.Image24,
         "gtk-go-back",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Output_Dialog.Image24, 0.5, 0.5);
      Set_Padding (Wizard_Output_Dialog.Image24, 0, 0);
      Pack_Start
        (Wizard_Output_Dialog.Hbox95,
         Wizard_Output_Dialog.Image24,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Output_Dialog.Label589, -("Back"));
      Set_Alignment (Wizard_Output_Dialog.Label589, 0.5, 0.5);
      Set_Padding (Wizard_Output_Dialog.Label589, 0, 0);
      Set_Justify (Wizard_Output_Dialog.Label589, Justify_Left);
      Set_Line_Wrap (Wizard_Output_Dialog.Label589, False);
      Set_Selectable (Wizard_Output_Dialog.Label589, False);
      Set_Use_Markup (Wizard_Output_Dialog.Label589, False);
      Set_Use_Underline (Wizard_Output_Dialog.Label589, True);
      Pack_Start
        (Wizard_Output_Dialog.Hbox95,
         Wizard_Output_Dialog.Label589,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Output_Dialog.Next_Button);
      Set_Relief (Wizard_Output_Dialog.Next_Button, Relief_Normal);
      Set_Flags (Wizard_Output_Dialog.Next_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Output_Dialog),
         Wizard_Output_Dialog.Next_Button);

      Gtk_New (Wizard_Output_Dialog.Alignment20, 0.5, 0.5, 0.0, 0.0);
      Add
        (Wizard_Output_Dialog.Next_Button,
         Wizard_Output_Dialog.Alignment20);

      Gtk_New_Hbox (Wizard_Output_Dialog.Hbox96, False, 2);
      Add (Wizard_Output_Dialog.Alignment20, Wizard_Output_Dialog.Hbox96);

      Gtk_New
        (Wizard_Output_Dialog.Image25,
         "gtk-go-forward",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Output_Dialog.Image25, 0.5, 0.5);
      Set_Padding (Wizard_Output_Dialog.Image25, 0, 0);
      Pack_Start
        (Wizard_Output_Dialog.Hbox96,
         Wizard_Output_Dialog.Image25,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Output_Dialog.Label590, -("Next"));
      Set_Alignment (Wizard_Output_Dialog.Label590, 0.5, 0.5);
      Set_Padding (Wizard_Output_Dialog.Label590, 0, 0);
      Set_Justify (Wizard_Output_Dialog.Label590, Justify_Left);
      Set_Line_Wrap (Wizard_Output_Dialog.Label590, False);
      Set_Selectable (Wizard_Output_Dialog.Label590, False);
      Set_Use_Markup (Wizard_Output_Dialog.Label590, False);
      Set_Use_Underline (Wizard_Output_Dialog.Label590, True);
      Pack_Start
        (Wizard_Output_Dialog.Hbox96,
         Wizard_Output_Dialog.Label590,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Output_Dialog.Table5, 6, 6, False);
      Set_Row_Spacings (Wizard_Output_Dialog.Table5, 0);
      Set_Col_Spacings (Wizard_Output_Dialog.Table5, 0);
      Pack_Start
        (Get_Vbox (Wizard_Output_Dialog),
         Wizard_Output_Dialog.Table5,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Wizard_Output_Dialog.Image, Pixmaps_Dir & "mast_logo.xpm");
      Set_Alignment (Wizard_Output_Dialog.Image, 0.5, 0.5);
      Set_Padding (Wizard_Output_Dialog.Image, 0, 0);
      Attach
        (Wizard_Output_Dialog.Table5,
         Wizard_Output_Dialog.Image,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Yoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Wizard_Output_Dialog.Label,
         -("Please, type Output Event name and its deadline ..."));
      Set_Alignment (Wizard_Output_Dialog.Label, 0.0, 0.5);
      Set_Padding (Wizard_Output_Dialog.Label, 0, 0);
      Set_Justify (Wizard_Output_Dialog.Label, Justify_Left);
      Set_Line_Wrap (Wizard_Output_Dialog.Label, True);
      Set_Selectable (Wizard_Output_Dialog.Label, False);
      Set_Use_Markup (Wizard_Output_Dialog.Label, False);
      Set_Use_Underline (Wizard_Output_Dialog.Label, False);
      Attach
        (Wizard_Output_Dialog.Table5,
         Wizard_Output_Dialog.Label,
         Left_Attach   => 2,
         Right_Attach  => 6,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Output_Dialog.Frame5);
      Set_Border_Width (Wizard_Output_Dialog.Frame5, 10);
      Set_Label_Align (Wizard_Output_Dialog.Frame5, 0.0, 0.5);
      Set_Shadow_Type (Wizard_Output_Dialog.Frame5, Shadow_Etched_In);
      Attach
        (Wizard_Output_Dialog.Table5,
         Wizard_Output_Dialog.Frame5,
         Left_Attach   => 0,
         Right_Attach  => 6,
         Top_Attach    => 1,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New_Vbox (Wizard_Output_Dialog.Vbox51, False, 0);
      Add (Wizard_Output_Dialog.Frame5, Wizard_Output_Dialog.Vbox51);

      Gtk_New (Wizard_Output_Dialog.Table1, 2, 2, True);
      Set_Border_Width (Wizard_Output_Dialog.Table1, 5);
      Set_Row_Spacings (Wizard_Output_Dialog.Table1, 3);
      Set_Col_Spacings (Wizard_Output_Dialog.Table1, 3);
      Pack_Start
        (Wizard_Output_Dialog.Vbox51,
         Wizard_Output_Dialog.Table1,
         Expand  => False,
         Fill    => False,
         Padding => 5);

      Gtk_New (Wizard_Output_Dialog.Label600, -("Event Name"));
      Set_Alignment (Wizard_Output_Dialog.Label600, 0.95, 0.5);
      Set_Padding (Wizard_Output_Dialog.Label600, 0, 0);
      Set_Justify (Wizard_Output_Dialog.Label600, Justify_Center);
      Set_Line_Wrap (Wizard_Output_Dialog.Label600, False);
      Set_Selectable (Wizard_Output_Dialog.Label600, False);
      Set_Use_Markup (Wizard_Output_Dialog.Label600, False);
      Set_Use_Underline (Wizard_Output_Dialog.Label600, False);
      Attach
        (Wizard_Output_Dialog.Table1,
         Wizard_Output_Dialog.Label600,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Output_Dialog.Event_Name_Entry);
      Set_Editable (Wizard_Output_Dialog.Event_Name_Entry, True);
      Set_Max_Length (Wizard_Output_Dialog.Event_Name_Entry, 0);
      Set_Text (Wizard_Output_Dialog.Event_Name_Entry, -(""));
      Set_Visibility (Wizard_Output_Dialog.Event_Name_Entry, True);
      Set_Invisible_Char
        (Wizard_Output_Dialog.Event_Name_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Wizard_Output_Dialog.Table1,
         Wizard_Output_Dialog.Event_Name_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Output_Dialog.Label611, -("Deadline"));
      Set_Alignment (Wizard_Output_Dialog.Label611, 0.95, 0.5);
      Set_Padding (Wizard_Output_Dialog.Label611, 0, 0);
      Set_Justify (Wizard_Output_Dialog.Label611, Justify_Center);
      Set_Line_Wrap (Wizard_Output_Dialog.Label611, False);
      Set_Selectable (Wizard_Output_Dialog.Label611, False);
      Set_Use_Markup (Wizard_Output_Dialog.Label611, False);
      Set_Use_Underline (Wizard_Output_Dialog.Label611, False);
      Attach
        (Wizard_Output_Dialog.Table1,
         Wizard_Output_Dialog.Label611,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Output_Dialog.Deadline_Entry);
      Set_Editable (Wizard_Output_Dialog.Deadline_Entry, True);
      Set_Max_Length (Wizard_Output_Dialog.Deadline_Entry, 0);
      Set_Text (Wizard_Output_Dialog.Deadline_Entry, -("0.0"));
      Set_Visibility (Wizard_Output_Dialog.Deadline_Entry, True);
      Set_Invisible_Char
        (Wizard_Output_Dialog.Deadline_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Wizard_Output_Dialog.Table1,
         Wizard_Output_Dialog.Deadline_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Wizard_Output_Dialog.Frame_Label,
         -("OUTPUT EVENT PARAMETERS  "));
      Set_Alignment (Wizard_Output_Dialog.Frame_Label, 0.5, 0.5);
      Set_Padding (Wizard_Output_Dialog.Frame_Label, 0, 0);
      Set_Justify (Wizard_Output_Dialog.Frame_Label, Justify_Left);
      Set_Line_Wrap (Wizard_Output_Dialog.Frame_Label, False);
      Set_Selectable (Wizard_Output_Dialog.Frame_Label, False);
      Set_Use_Markup (Wizard_Output_Dialog.Frame_Label, False);
      Set_Use_Underline (Wizard_Output_Dialog.Frame_Label, False);
      Set_Label_Widget
        (Wizard_Output_Dialog.Frame5,
         Wizard_Output_Dialog.Frame_Label);

   end Initialize;

end Wizard_Output_Dialog_Pkg;
