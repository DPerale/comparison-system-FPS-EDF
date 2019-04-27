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

package body Wizard_Completed_Dialog_Pkg is

   procedure Gtk_New
     (Wizard_Completed_Dialog : out Wizard_Completed_Dialog_Access)
   is
   begin
      Wizard_Completed_Dialog := new Wizard_Completed_Dialog_Record;
      Wizard_Completed_Dialog_Pkg.Initialize (Wizard_Completed_Dialog);
   end Gtk_New;

   procedure Initialize
     (Wizard_Completed_Dialog : access Wizard_Completed_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Pixmaps_Dir : constant String := "";
   begin
      Gtk.Dialog.Initialize (Wizard_Completed_Dialog);
      Set_Title
        (Wizard_Completed_Dialog,
         -"Editor Wizard Tool - Completed !");
      Set_Position (Wizard_Completed_Dialog, Win_Pos_Center_Always);
      Set_Modal (Wizard_Completed_Dialog, True);

      Set_USize (Wizard_Completed_Dialog, 500, 350);

      Gtk_New (Wizard_Completed_Dialog.Cancel_Button);
      Set_Relief (Wizard_Completed_Dialog.Cancel_Button, Relief_Normal);
      Set_Flags (Wizard_Completed_Dialog.Cancel_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Completed_Dialog),
         Wizard_Completed_Dialog.Cancel_Button);

      Gtk_New (Wizard_Completed_Dialog.Alignment21, 0.5, 0.5, 0.0, 0.0);
      Add
        (Wizard_Completed_Dialog.Cancel_Button,
         Wizard_Completed_Dialog.Alignment21);

      Gtk_New_Hbox (Wizard_Completed_Dialog.Hbox97, False, 2);
      Add
        (Wizard_Completed_Dialog.Alignment21,
         Wizard_Completed_Dialog.Hbox97);

      Gtk_New
        (Wizard_Completed_Dialog.Image28,
         "gtk-cancel",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Completed_Dialog.Image28, 0.5, 0.5);
      Set_Padding (Wizard_Completed_Dialog.Image28, 0, 0);
      Pack_Start
        (Wizard_Completed_Dialog.Hbox97,
         Wizard_Completed_Dialog.Image28,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Completed_Dialog.Label604, -("Cancel"));
      Set_Alignment (Wizard_Completed_Dialog.Label604, 0.5, 0.5);
      Set_Padding (Wizard_Completed_Dialog.Label604, 0, 0);
      Set_Justify (Wizard_Completed_Dialog.Label604, Justify_Left);
      Set_Line_Wrap (Wizard_Completed_Dialog.Label604, False);
      Set_Selectable (Wizard_Completed_Dialog.Label604, False);
      Set_Use_Markup (Wizard_Completed_Dialog.Label604, False);
      Set_Use_Underline (Wizard_Completed_Dialog.Label604, True);
      Pack_Start
        (Wizard_Completed_Dialog.Hbox97,
         Wizard_Completed_Dialog.Label604,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Completed_Dialog.Back_Button);
      Set_Relief (Wizard_Completed_Dialog.Back_Button, Relief_Normal);
      Set_Flags (Wizard_Completed_Dialog.Back_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Completed_Dialog),
         Wizard_Completed_Dialog.Back_Button);

      Gtk_New (Wizard_Completed_Dialog.Alignment22, 0.5, 0.5, 0.0, 0.0);
      Add
        (Wizard_Completed_Dialog.Back_Button,
         Wizard_Completed_Dialog.Alignment22);

      Gtk_New_Hbox (Wizard_Completed_Dialog.Hbox98, False, 2);
      Add
        (Wizard_Completed_Dialog.Alignment22,
         Wizard_Completed_Dialog.Hbox98);

      Gtk_New
        (Wizard_Completed_Dialog.Image29,
         "gtk-go-back",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Completed_Dialog.Image29, 0.5, 0.5);
      Set_Padding (Wizard_Completed_Dialog.Image29, 0, 0);
      Pack_Start
        (Wizard_Completed_Dialog.Hbox98,
         Wizard_Completed_Dialog.Image29,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Completed_Dialog.Label605, -("Back"));
      Set_Alignment (Wizard_Completed_Dialog.Label605, 0.5, 0.5);
      Set_Padding (Wizard_Completed_Dialog.Label605, 0, 0);
      Set_Justify (Wizard_Completed_Dialog.Label605, Justify_Left);
      Set_Line_Wrap (Wizard_Completed_Dialog.Label605, False);
      Set_Selectable (Wizard_Completed_Dialog.Label605, False);
      Set_Use_Markup (Wizard_Completed_Dialog.Label605, False);
      Set_Use_Underline (Wizard_Completed_Dialog.Label605, True);
      Pack_Start
        (Wizard_Completed_Dialog.Hbox98,
         Wizard_Completed_Dialog.Label605,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Completed_Dialog.Apply_Button);
      Set_Relief (Wizard_Completed_Dialog.Apply_Button, Relief_Normal);
      Set_Flags (Wizard_Completed_Dialog.Apply_Button, Can_Default);
      Pack_Start
        (Get_Action_Area (Wizard_Completed_Dialog),
         Wizard_Completed_Dialog.Apply_Button);

      Gtk_New (Wizard_Completed_Dialog.Alignment23, 0.5, 0.5, 0.0, 0.0);
      Add
        (Wizard_Completed_Dialog.Apply_Button,
         Wizard_Completed_Dialog.Alignment23);

      Gtk_New_Hbox (Wizard_Completed_Dialog.Hbox99, False, 2);
      Add
        (Wizard_Completed_Dialog.Alignment23,
         Wizard_Completed_Dialog.Hbox99);

      Gtk_New
        (Wizard_Completed_Dialog.Image30,
         "gtk-apply",
         Gtk_Icon_Size'Val (4));
      Set_Alignment (Wizard_Completed_Dialog.Image30, 0.5, 0.5);
      Set_Padding (Wizard_Completed_Dialog.Image30, 0, 0);
      Pack_Start
        (Wizard_Completed_Dialog.Hbox99,
         Wizard_Completed_Dialog.Image30,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Completed_Dialog.Label606, -("Apply"));
      Set_Alignment (Wizard_Completed_Dialog.Label606, 0.5, 0.5);
      Set_Padding (Wizard_Completed_Dialog.Label606, 0, 0);
      Set_Justify (Wizard_Completed_Dialog.Label606, Justify_Left);
      Set_Line_Wrap (Wizard_Completed_Dialog.Label606, False);
      Set_Selectable (Wizard_Completed_Dialog.Label606, False);
      Set_Use_Markup (Wizard_Completed_Dialog.Label606, False);
      Set_Use_Underline (Wizard_Completed_Dialog.Label606, True);
      Pack_Start
        (Wizard_Completed_Dialog.Hbox99,
         Wizard_Completed_Dialog.Label606,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Wizard_Completed_Dialog.Table1, 6, 6, False);
      Set_Row_Spacings (Wizard_Completed_Dialog.Table1, 0);
      Set_Col_Spacings (Wizard_Completed_Dialog.Table1, 0);
      Pack_Start
        (Get_Vbox (Wizard_Completed_Dialog),
         Wizard_Completed_Dialog.Table1,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Wizard_Completed_Dialog.Label, -("Process Completed !!!"));
      Set_Alignment (Wizard_Completed_Dialog.Label, 0.0, 0.5);
      Set_Padding (Wizard_Completed_Dialog.Label, 0, 0);
      Set_Justify (Wizard_Completed_Dialog.Label, Justify_Center);
      Set_Line_Wrap (Wizard_Completed_Dialog.Label, True);
      Set_Selectable (Wizard_Completed_Dialog.Label, False);
      Set_Use_Markup (Wizard_Completed_Dialog.Label, False);
      Set_Use_Underline (Wizard_Completed_Dialog.Label, False);
      Attach
        (Wizard_Completed_Dialog.Table1,
         Wizard_Completed_Dialog.Label,
         Left_Attach   => 0,
         Right_Attach  => 6,
         Top_Attach    => 0,
         Bottom_Attach => 3,
         Xoptions      => Expand,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Completed_Dialog.Textview);
      Set_Editable (Wizard_Completed_Dialog.Textview, False);
      Set_Justification (Wizard_Completed_Dialog.Textview, Justify_Left);
      Set_Wrap_Mode (Wizard_Completed_Dialog.Textview, Wrap_None);
      Set_Cursor_Visible (Wizard_Completed_Dialog.Textview, False);
      Set_Pixels_Above_Lines (Wizard_Completed_Dialog.Textview, 0);
      Set_Pixels_Below_Lines (Wizard_Completed_Dialog.Textview, 0);
      Set_Pixels_Inside_Wrap (Wizard_Completed_Dialog.Textview, 0);
      Set_Left_Margin (Wizard_Completed_Dialog.Textview, 50);
      Set_Right_Margin (Wizard_Completed_Dialog.Textview, 0);
      Set_Indent (Wizard_Completed_Dialog.Textview, 0);
      declare
         Iter : Gtk_Text_Iter;
      begin
         Get_Iter_At_Line
           (Get_Buffer (Wizard_Completed_Dialog.Textview),
            Iter,
            0);
         Insert
           (Get_Buffer (Wizard_Completed_Dialog.Textview),
            Iter,
            -(ASCII.LF &
              ASCII.LF &
              "The wizard tool has enough information to generate the new" &
              ASCII.LF &
              "transaction automatically." &
              ASCII.LF &
              "" &
              ASCII.LF &
              "To finish the creation process click on Apply button and the" &
              ASCII.LF &
              "new transaction will be added to the system." &
              ASCII.LF &
              "" &
              ASCII.LF &
              "If Cancel button is clicked changes will be discarded and" &
              ASCII.LF &
              "system will remain unchanged." &
              ASCII.LF &
              "" &
              ASCII.LF &
              "Thank you."));
      end;
      Attach
        (Wizard_Completed_Dialog.Table1,
         Wizard_Completed_Dialog.Textview,
         Left_Attach   => 2,
         Right_Attach  => 6,
         Top_Attach    => 3,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Yoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Wizard_Completed_Dialog.Image, Pixmaps_Dir & "mast_logo.xpm");
      Set_Alignment (Wizard_Completed_Dialog.Image, 0.5, 0.5);
      Set_Padding (Wizard_Completed_Dialog.Image, 0, 0);
      Attach
        (Wizard_Completed_Dialog.Table1,
         Wizard_Completed_Dialog.Image,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 6,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

   end Initialize;

end Wizard_Completed_Dialog_Pkg;
