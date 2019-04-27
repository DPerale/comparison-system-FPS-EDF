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

package body Wizard_Transaction_Dialog_Pkg is

   procedure Gtk_New
     (Wizard_Transaction_Dialog : out Wizard_Transaction_Dialog_Access)
   is
   begin
      Wizard_Transaction_Dialog := new Wizard_Transaction_Dialog_Record;
      Wizard_Transaction_Dialog_Pkg.Initialize (Wizard_Transaction_Dialog);
   end Gtk_New;

   procedure Initialize
     (Wizard_Transaction_Dialog : access Wizard_Transaction_Dialog_Record'
        Class)
   is
      pragma Suppress (All_Checks);
      Pixmaps_Dir : constant String := "";
   begin
      Gtk.Dialog.Initialize (Wizard_Transaction_Dialog);
      Set_Title
        (Wizard_Transaction_Dialog,
         -"Editor Wizard Tool - Step 1 of 4");
      Set_Position (Wizard_Transaction_Dialog, Win_Pos_None);
      Set_Modal (Wizard_Transaction_Dialog, True);

      Gtk_New (Wizard_Transaction_Dialog.Cancel_Button);
      Set_Relief (Wizard_Transaction_Dialog.Cancel_Button, Relief_Normal);
      Set_Flags (Wizard_Transaction_Dialog.Cancel_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Transaction_Dialog),
         Wizard_Transaction_Dialog.Cancel_Button);

      Gtk_New (Wizard_Transaction_Dialog.Alignment9, 0.5, 0.5, 0.0, 0.0);
      Add
        (Wizard_Transaction_Dialog.Cancel_Button,
         Wizard_Transaction_Dialog.Alignment9);

      Gtk_New_Hbox (Wizard_Transaction_Dialog.Hbox84, False, 2);
      Add
        (Wizard_Transaction_Dialog.Alignment9,
         Wizard_Transaction_Dialog.Hbox84);

      Gtk_New
        (Wizard_Transaction_Dialog.Image12,
         "gtk-cancel",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Transaction_Dialog.Image12, 0.5, 0.5);
      Set_Padding (Wizard_Transaction_Dialog.Image12, 0, 0);
      Pack_Start
        (Wizard_Transaction_Dialog.Hbox84,
         Wizard_Transaction_Dialog.Image12,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Transaction_Dialog.Label538, -("Cancel"));
      Set_Alignment (Wizard_Transaction_Dialog.Label538, 0.5, 0.5);
      Set_Padding (Wizard_Transaction_Dialog.Label538, 0, 0);
      Set_Justify (Wizard_Transaction_Dialog.Label538, Justify_Left);
      Set_Line_Wrap (Wizard_Transaction_Dialog.Label538, False);
      Set_Selectable (Wizard_Transaction_Dialog.Label538, False);
      Set_Use_Markup (Wizard_Transaction_Dialog.Label538, False);
      Set_Use_Underline (Wizard_Transaction_Dialog.Label538, True);
      Pack_Start
        (Wizard_Transaction_Dialog.Hbox84,
         Wizard_Transaction_Dialog.Label538,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Transaction_Dialog.Back_Button);
      Set_Relief (Wizard_Transaction_Dialog.Back_Button, Relief_Normal);
      Set_Flags (Wizard_Transaction_Dialog.Back_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Transaction_Dialog),
         Wizard_Transaction_Dialog.Back_Button);

      Gtk_New (Wizard_Transaction_Dialog.Alignment10, 0.5, 0.5, 0.0, 0.0);
      Add
        (Wizard_Transaction_Dialog.Back_Button,
         Wizard_Transaction_Dialog.Alignment10);

      Gtk_New_Hbox (Wizard_Transaction_Dialog.Hbox85, False, 2);
      Add
        (Wizard_Transaction_Dialog.Alignment10,
         Wizard_Transaction_Dialog.Hbox85);

      Gtk_New
        (Wizard_Transaction_Dialog.Image13,
         "gtk-go-back",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Transaction_Dialog.Image13, 0.5, 0.5);
      Set_Padding (Wizard_Transaction_Dialog.Image13, 0, 0);
      Pack_Start
        (Wizard_Transaction_Dialog.Hbox85,
         Wizard_Transaction_Dialog.Image13,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Transaction_Dialog.Label539, -("Back"));
      Set_Alignment (Wizard_Transaction_Dialog.Label539, 0.5, 0.5);
      Set_Padding (Wizard_Transaction_Dialog.Label539, 0, 0);
      Set_Justify (Wizard_Transaction_Dialog.Label539, Justify_Left);
      Set_Line_Wrap (Wizard_Transaction_Dialog.Label539, False);
      Set_Selectable (Wizard_Transaction_Dialog.Label539, False);
      Set_Use_Markup (Wizard_Transaction_Dialog.Label539, False);
      Set_Use_Underline (Wizard_Transaction_Dialog.Label539, True);
      Pack_Start
        (Wizard_Transaction_Dialog.Hbox85,
         Wizard_Transaction_Dialog.Label539,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Transaction_Dialog.Next_Button);
      Set_Relief (Wizard_Transaction_Dialog.Next_Button, Relief_Normal);
      Set_Flags (Wizard_Transaction_Dialog.Next_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Transaction_Dialog),
         Wizard_Transaction_Dialog.Next_Button);

      Gtk_New (Wizard_Transaction_Dialog.Alignment11, 0.5, 0.5, 0.0, 0.0);
      Add
        (Wizard_Transaction_Dialog.Next_Button,
         Wizard_Transaction_Dialog.Alignment11);

      Gtk_New_Hbox (Wizard_Transaction_Dialog.Hbox86, False, 2);
      Add
        (Wizard_Transaction_Dialog.Alignment11,
         Wizard_Transaction_Dialog.Hbox86);

      Gtk_New
        (Wizard_Transaction_Dialog.Image14,
         "gtk-go-forward",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Transaction_Dialog.Image14, 0.5, 0.5);
      Set_Padding (Wizard_Transaction_Dialog.Image14, 0, 0);
      Pack_Start
        (Wizard_Transaction_Dialog.Hbox86,
         Wizard_Transaction_Dialog.Image14,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Transaction_Dialog.Label540, -("Next"));
      Set_Alignment (Wizard_Transaction_Dialog.Label540, 0.5, 0.5);
      Set_Padding (Wizard_Transaction_Dialog.Label540, 0, 0);
      Set_Justify (Wizard_Transaction_Dialog.Label540, Justify_Left);
      Set_Line_Wrap (Wizard_Transaction_Dialog.Label540, False);
      Set_Selectable (Wizard_Transaction_Dialog.Label540, False);
      Set_Use_Markup (Wizard_Transaction_Dialog.Label540, False);
      Set_Use_Underline (Wizard_Transaction_Dialog.Label540, True);
      Pack_Start
        (Wizard_Transaction_Dialog.Hbox86,
         Wizard_Transaction_Dialog.Label540,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Transaction_Dialog.Table2, 6, 6, False);
      Set_Row_Spacings (Wizard_Transaction_Dialog.Table2, 0);
      Set_Col_Spacings (Wizard_Transaction_Dialog.Table2, 0);
      Pack_Start
        (Get_Vbox (Wizard_Transaction_Dialog),
         Wizard_Transaction_Dialog.Table2,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New
        (Wizard_Transaction_Dialog.Image,
         Pixmaps_Dir & "mast_logo.xpm");
      Set_Alignment (Wizard_Transaction_Dialog.Image, 0.5, 0.5);
      Set_Padding (Wizard_Transaction_Dialog.Image, 0, 0);
      Attach
        (Wizard_Transaction_Dialog.Table2,
         Wizard_Transaction_Dialog.Image,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Yoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Wizard_Transaction_Dialog.Label,
         -("Please, type the name of the new transaction ..."));
      Set_Alignment (Wizard_Transaction_Dialog.Label, 0.0, 0.5);
      Set_Padding (Wizard_Transaction_Dialog.Label, 0, 0);
      Set_Justify (Wizard_Transaction_Dialog.Label, Justify_Center);
      Set_Line_Wrap (Wizard_Transaction_Dialog.Label, True);
      Set_Selectable (Wizard_Transaction_Dialog.Label, False);
      Set_Use_Markup (Wizard_Transaction_Dialog.Label, False);
      Set_Use_Underline (Wizard_Transaction_Dialog.Label, False);
      Attach
        (Wizard_Transaction_Dialog.Table2,
         Wizard_Transaction_Dialog.Label,
         Left_Attach   => 2,
         Right_Attach  => 6,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Transaction_Dialog.Frame2);
      Set_Label_Align (Wizard_Transaction_Dialog.Frame2, 0.0, 0.5);
      Set_Shadow_Type (Wizard_Transaction_Dialog.Frame2, Shadow_Etched_In);
      Attach
        (Wizard_Transaction_Dialog.Table2,
         Wizard_Transaction_Dialog.Frame2,
         Left_Attach   => 0,
         Right_Attach  => 6,
         Top_Attach    => 1,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 10,
         Ypadding      => 10);

      Gtk_New_Hbox (Wizard_Transaction_Dialog.Hbox87, False, 5);
      Set_Border_Width (Wizard_Transaction_Dialog.Hbox87, 15);
      Add
        (Wizard_Transaction_Dialog.Frame2,
         Wizard_Transaction_Dialog.Hbox87);

      Gtk_New
        (Wizard_Transaction_Dialog.Name_Label,
         -("TRANSACTION NAME"));
      Set_Alignment (Wizard_Transaction_Dialog.Name_Label, 0.95, 0.5);
      Set_Padding (Wizard_Transaction_Dialog.Name_Label, 0, 0);
      Set_Justify (Wizard_Transaction_Dialog.Name_Label, Justify_Center);
      Set_Line_Wrap (Wizard_Transaction_Dialog.Name_Label, False);
      Set_Selectable (Wizard_Transaction_Dialog.Name_Label, False);
      Set_Use_Markup (Wizard_Transaction_Dialog.Name_Label, False);
      Set_Use_Underline (Wizard_Transaction_Dialog.Name_Label, False);
      Pack_Start
        (Wizard_Transaction_Dialog.Hbox87,
         Wizard_Transaction_Dialog.Name_Label,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Transaction_Dialog.Trans_Name_Entry);
      Set_Editable (Wizard_Transaction_Dialog.Trans_Name_Entry, True);
      Set_Max_Length (Wizard_Transaction_Dialog.Trans_Name_Entry, 0);
      Set_Text (Wizard_Transaction_Dialog.Trans_Name_Entry, -(""));
      Set_Visibility (Wizard_Transaction_Dialog.Trans_Name_Entry, True);
      Set_Invisible_Char
        (Wizard_Transaction_Dialog.Trans_Name_Entry,
         UTF8_Get_Char ("*"));
      Pack_Start
        (Wizard_Transaction_Dialog.Hbox87,
         Wizard_Transaction_Dialog.Trans_Name_Entry,
         Expand  => True,
         Fill    => True,
         Padding => 0);

   end Initialize;

end Wizard_Transaction_Dialog_Pkg;
