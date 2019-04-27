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
with Glib;                                  use Glib;
with Gtk;                                   use Gtk;
with Gdk.Types;                             use Gdk.Types;
with Gtk.Widget;                            use Gtk.Widget;
with Gtk.Enums;                             use Gtk.Enums;
with Gtkada.Handlers;                       use Gtkada.Handlers;
with Callbacks_Mast_Editor;                 use Callbacks_Mast_Editor;
with Mast_Editor_Intl;                      use Mast_Editor_Intl;
with Select_Ref_Event_Dialog_Pkg.Callbacks;
use Select_Ref_Event_Dialog_Pkg.Callbacks;

with Gtk.Handlers; use Gtk.Handlers;

package body Select_Ref_Event_Dialog_Pkg is

   package Dialog_Callback is new Gtk.Handlers.Callback (Gtk_Dialog_Record);

   procedure Gtk_New
     (Select_Ref_Event_Dialog : out Select_Ref_Event_Dialog_Access)
   is
   begin
      Select_Ref_Event_Dialog := new Select_Ref_Event_Dialog_Record;
      Select_Ref_Event_Dialog_Pkg.Initialize (Select_Ref_Event_Dialog);
   end Gtk_New;

   procedure Initialize
     (Select_Ref_Event_Dialog : access Select_Ref_Event_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Pixmaps_Dir : constant String := "pixmaps/";
   --Ref_Event_Combo_Items : String_List.Glist;

   begin
      Gtk.Dialog.Initialize (Select_Ref_Event_Dialog);
      Set_Title (Select_Ref_Event_Dialog, -"Select Referenced Event ...");
      Set_Position (Select_Ref_Event_Dialog, Win_Pos_Center);
      Set_Modal (Select_Ref_Event_Dialog, True);
      Set_Default_Size (Select_Ref_Event_Dialog, 400, 150);

      Gtk_New_Hbox (Select_Ref_Event_Dialog.Hbox75, True, 60);
      Pack_Start
        (Get_Action_Area (Select_Ref_Event_Dialog),
         Select_Ref_Event_Dialog.Hbox75);

      Gtk_New (Select_Ref_Event_Dialog.Ok_Button, -"Ok");
      Set_Relief (Select_Ref_Event_Dialog.Ok_Button, Relief_Normal);
      Pack_Start
        (Select_Ref_Event_Dialog.Hbox75,
         Select_Ref_Event_Dialog.Ok_Button,
         Expand  => False,
         Fill    => True,
         Padding => 50);

      Gtk_New (Select_Ref_Event_Dialog.Cancel_Button, -"Cancel");
      Set_Relief (Select_Ref_Event_Dialog.Cancel_Button, Relief_Normal);
      Pack_Start
        (Select_Ref_Event_Dialog.Hbox75,
         Select_Ref_Event_Dialog.Cancel_Button,
         Expand  => False,
         Fill    => True,
         Padding => 50);

      --Button_Callback.Connect
      --  (Select_Ref_Event_Dialog.Cancel_Button, "clicked",
      --   Button_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access),
      --False);
      Dialog_Callback.Object_Connect
        (Select_Ref_Event_Dialog.Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access),
         Select_Ref_Event_Dialog);

      Gtk_New (Select_Ref_Event_Dialog.Table, 1, 2, True);
      Set_Border_Width (Select_Ref_Event_Dialog.Table, 15);
      Set_Row_Spacings (Select_Ref_Event_Dialog.Table, 5);
      Set_Col_Spacings (Select_Ref_Event_Dialog.Table, 5);
      Pack_Start
        (Get_Vbox (Select_Ref_Event_Dialog),
         Select_Ref_Event_Dialog.Table,
         Expand  => True,
         Fill    => False,
         Padding => 0);

      Gtk_New (Select_Ref_Event_Dialog.Ref_Event_Combo);
      Set_Value_In_List (Select_Ref_Event_Dialog.Ref_Event_Combo, False);
      Set_Use_Arrows (Select_Ref_Event_Dialog.Ref_Event_Combo, True);
      Set_Case_Sensitive (Select_Ref_Event_Dialog.Ref_Event_Combo, False);
      Set_Editable
        (Get_Entry (Select_Ref_Event_Dialog.Ref_Event_Combo),
         False);
      Set_Has_Frame
        (Get_Entry (Select_Ref_Event_Dialog.Ref_Event_Combo),
         True);
      Set_Max_Length (Get_Entry (Select_Ref_Event_Dialog.Ref_Event_Combo), 0);
      Set_Text (Get_Entry (Select_Ref_Event_Dialog.Ref_Event_Combo), -(""));
      Set_Invisible_Char
        (Get_Entry (Select_Ref_Event_Dialog.Ref_Event_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame
        (Get_Entry (Select_Ref_Event_Dialog.Ref_Event_Combo),
         True);
      --String_List.Append (Refer_Event_Combo_Items, -(""));
      Combo.Set_Popdown_Strings
        (Select_Ref_Event_Dialog.Ref_Event_Combo,
         Refer_Event_Combo_Items);
      --Free_String_List (Refer_Event_Combo_Items);
      Attach
        (Select_Ref_Event_Dialog.Table,
         Select_Ref_Event_Dialog.Ref_Event_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Select_Ref_Event_Dialog.Label,
         -("Transaction's Events List"));
      Set_Alignment (Select_Ref_Event_Dialog.Label, 0.95, 0.5);
      Set_Padding (Select_Ref_Event_Dialog.Label, 0, 0);
      Set_Justify (Select_Ref_Event_Dialog.Label, Justify_Center);
      Set_Line_Wrap (Select_Ref_Event_Dialog.Label, False);
      Set_Selectable (Select_Ref_Event_Dialog.Label, False);
      Set_Use_Markup (Select_Ref_Event_Dialog.Label, False);
      Set_Use_Underline (Select_Ref_Event_Dialog.Label, False);
      Attach
        (Select_Ref_Event_Dialog.Table,
         Select_Ref_Event_Dialog.Label,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

   end Initialize;

end Select_Ref_Event_Dialog_Pkg;
