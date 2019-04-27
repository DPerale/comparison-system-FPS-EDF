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

package body Wizard_Welcome_Dialog_Pkg is

   procedure Gtk_New
     (Wizard_Welcome_Dialog : out Wizard_Welcome_Dialog_Access)
   is
   begin
      Wizard_Welcome_Dialog := new Wizard_Welcome_Dialog_Record;
      Wizard_Welcome_Dialog_Pkg.Initialize (Wizard_Welcome_Dialog);
   end Gtk_New;

   procedure Initialize
     (Wizard_Welcome_Dialog : access Wizard_Welcome_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Pixmaps_Dir : constant String := "";
   begin
      Gtk.Dialog.Initialize (Wizard_Welcome_Dialog);
      Set_Title (Wizard_Welcome_Dialog, -"Editor Wizard Tool");
      Set_Position (Wizard_Welcome_Dialog, Win_Pos_Center_Always);
      Set_Modal (Wizard_Welcome_Dialog, True);

      Set_USize (Wizard_Welcome_Dialog, 450, 250);

      Gtk_New (Wizard_Welcome_Dialog.Cancel_Button);
      Set_Relief (Wizard_Welcome_Dialog.Cancel_Button, Relief_Normal);
      Set_Flags (Wizard_Welcome_Dialog.Cancel_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Welcome_Dialog),
         Wizard_Welcome_Dialog.Cancel_Button);

      Gtk_New (Wizard_Welcome_Dialog.Alignment1, 0.5, 0.5, 0.0, 0.0);
      Add
        (Wizard_Welcome_Dialog.Cancel_Button,
         Wizard_Welcome_Dialog.Alignment1);

      Gtk_New_Hbox (Wizard_Welcome_Dialog.Hbox76, False, 2);
      Add (Wizard_Welcome_Dialog.Alignment1, Wizard_Welcome_Dialog.Hbox76);

      Gtk_New
        (Wizard_Welcome_Dialog.Image2,
         "gtk-cancel",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Welcome_Dialog.Image2, 0.5, 0.5);
      Set_Padding (Wizard_Welcome_Dialog.Image2, 0, 0);
      Pack_Start
        (Wizard_Welcome_Dialog.Hbox76,
         Wizard_Welcome_Dialog.Image2,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Welcome_Dialog.Label527, -("Cancel"));
      Set_Alignment (Wizard_Welcome_Dialog.Label527, 0.5, 0.5);
      Set_Padding (Wizard_Welcome_Dialog.Label527, 0, 0);
      Set_Justify (Wizard_Welcome_Dialog.Label527, Justify_Left);
      Set_Line_Wrap (Wizard_Welcome_Dialog.Label527, False);
      Set_Selectable (Wizard_Welcome_Dialog.Label527, False);
      Set_Use_Markup (Wizard_Welcome_Dialog.Label527, False);
      Set_Use_Underline (Wizard_Welcome_Dialog.Label527, True);
      Pack_Start
        (Wizard_Welcome_Dialog.Hbox76,
         Wizard_Welcome_Dialog.Label527,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Welcome_Dialog.Next_Button);
      Set_Relief (Wizard_Welcome_Dialog.Next_Button, Relief_Normal);
      Set_Flags (Wizard_Welcome_Dialog.Next_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Welcome_Dialog),
         Wizard_Welcome_Dialog.Next_Button);

      Gtk_New (Wizard_Welcome_Dialog.Alignment3, 0.5, 0.5, 0.0, 0.0);
      Add
        (Wizard_Welcome_Dialog.Next_Button,
         Wizard_Welcome_Dialog.Alignment3);

      Gtk_New_Hbox (Wizard_Welcome_Dialog.Hbox78, False, 2);
      Add (Wizard_Welcome_Dialog.Alignment3, Wizard_Welcome_Dialog.Hbox78);

      Gtk_New
        (Wizard_Welcome_Dialog.Image4,
         "gtk-go-forward",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Welcome_Dialog.Image4, 0.5, 0.5);
      Set_Padding (Wizard_Welcome_Dialog.Image4, 0, 0);
      Pack_Start
        (Wizard_Welcome_Dialog.Hbox78,
         Wizard_Welcome_Dialog.Image4,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Welcome_Dialog.Label529, -("Next"));
      Set_Alignment (Wizard_Welcome_Dialog.Label529, 0.5, 0.5);
      Set_Padding (Wizard_Welcome_Dialog.Label529, 0, 0);
      Set_Justify (Wizard_Welcome_Dialog.Label529, Justify_Left);
      Set_Line_Wrap (Wizard_Welcome_Dialog.Label529, False);
      Set_Selectable (Wizard_Welcome_Dialog.Label529, False);
      Set_Use_Markup (Wizard_Welcome_Dialog.Label529, False);
      Set_Use_Underline (Wizard_Welcome_Dialog.Label529, True);
      Pack_Start
        (Wizard_Welcome_Dialog.Hbox78,
         Wizard_Welcome_Dialog.Label529,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Welcome_Dialog.Table1, 6, 6, False);
      Set_Row_Spacings (Wizard_Welcome_Dialog.Table1, 0);
      Set_Col_Spacings (Wizard_Welcome_Dialog.Table1, 0);
      Pack_Start
        (Get_Vbox (Wizard_Welcome_Dialog),
         Wizard_Welcome_Dialog.Table1,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New
        (Wizard_Welcome_Dialog.Label,
         -("Welcome to MAST Editor Wizard Tool !!!"));
      Set_Alignment (Wizard_Welcome_Dialog.Label, 0.0, 0.5);
      Set_Padding (Wizard_Welcome_Dialog.Label, 0, 0);
      Set_Justify (Wizard_Welcome_Dialog.Label, Justify_Center);
      Set_Line_Wrap (Wizard_Welcome_Dialog.Label, True);
      Set_Selectable (Wizard_Welcome_Dialog.Label, False);
      Set_Use_Markup (Wizard_Welcome_Dialog.Label, False);
      Set_Use_Underline (Wizard_Welcome_Dialog.Label, False);
      Attach
        (Wizard_Welcome_Dialog.Table1,
         Wizard_Welcome_Dialog.Label,
         Left_Attach   => 0,
         Right_Attach  => 6,
         Top_Attach    => 0,
         Bottom_Attach => 3,
         Xoptions      => Expand,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Welcome_Dialog.Textview);
      Set_Editable (Wizard_Welcome_Dialog.Textview, False);
      Set_Justification (Wizard_Welcome_Dialog.Textview, Justify_Left);
      Set_Wrap_Mode (Wizard_Welcome_Dialog.Textview, Wrap_None);
      Set_Cursor_Visible (Wizard_Welcome_Dialog.Textview, False);
      Set_Pixels_Above_Lines (Wizard_Welcome_Dialog.Textview, 0);
      Set_Pixels_Below_Lines (Wizard_Welcome_Dialog.Textview, 0);
      Set_Pixels_Inside_Wrap (Wizard_Welcome_Dialog.Textview, 0);
      Set_Left_Margin (Wizard_Welcome_Dialog.Textview, 50);
      Set_Right_Margin (Wizard_Welcome_Dialog.Textview, 0);
      Set_Indent (Wizard_Welcome_Dialog.Textview, 0);
      declare
         Iter : Gtk_Text_Iter;
      begin
         Get_Iter_At_Line
           (Get_Buffer (Wizard_Welcome_Dialog.Textview),
            Iter,
            0);
         Insert
           (Get_Buffer (Wizard_Welcome_Dialog.Textview),
            Iter,
            -(ASCII.LF &
              ASCII.LF &
              "This Wizard will guide you in Simple " &
              ASCII.LF &
              "Transaction creation proccess." &
              ASCII.LF &
              "" &
              ASCII.LF &
              "Just follow next steps to create a new " &
              ASCII.LF &
              "Simple Transaction from scratch."));
      end;
      Attach
        (Wizard_Welcome_Dialog.Table1,
         Wizard_Welcome_Dialog.Textview,
         Left_Attach   => 2,
         Right_Attach  => 6,
         Top_Attach    => 3,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Yoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Welcome_Dialog.Image, Pixmaps_Dir & "mast_logo.xpm");
      Set_Alignment (Wizard_Welcome_Dialog.Image, 0.5, 0.5);
      Set_Padding (Wizard_Welcome_Dialog.Image, 0, 0);
      Attach
        (Wizard_Welcome_Dialog.Table1,
         Wizard_Welcome_Dialog.Image,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

   end Initialize;

end Wizard_Welcome_Dialog_Pkg;
