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
with Add_Link_Dialog_Pkg.Callbacks; use Add_Link_Dialog_Pkg.Callbacks;

package body Add_Link_Dialog_Pkg is

   procedure Gtk_New (Add_Link_Dialog : out Add_Link_Dialog_Access) is
   begin
      Add_Link_Dialog := new Add_Link_Dialog_Record;
      Add_Link_Dialog_Pkg.Initialize (Add_Link_Dialog);
   end Gtk_New;

   procedure Initialize
     (Add_Link_Dialog : access Add_Link_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
   --Combo_Items : String_List.Glist;

   begin
      Gtk.Dialog.Initialize (Add_Link_Dialog);
      Set_Title (Add_Link_Dialog, -"Link To ...");
      Set_Position (Add_Link_Dialog, Win_Pos_None);
      Set_Modal (Add_Link_Dialog, True);
      Set_Default_Size (Add_Link_Dialog, 400, 150);

      Gtk_New_Hbox (Add_Link_Dialog.Hbox, True, 60);
      Pack_Start (Get_Action_Area (Add_Link_Dialog), Add_Link_Dialog.Hbox);

      Gtk_New (Add_Link_Dialog.Ok_Button, -"Ok");
      Set_Relief (Add_Link_Dialog.Ok_Button, Relief_Normal);
      Pack_Start
        (Add_Link_Dialog.Hbox,
         Add_Link_Dialog.Ok_Button,
         Expand  => False,
         Fill    => True,
         Padding => 50);

      Gtk_New (Add_Link_Dialog.Cancel_Button, -"Cancel");
      Set_Relief (Add_Link_Dialog.Cancel_Button, Relief_Normal);
      Pack_Start
        (Add_Link_Dialog.Hbox,
         Add_Link_Dialog.Cancel_Button,
         Expand  => False,
         Fill    => True,
         Padding => 50);
      --Button_Callback.Connect
      --  (Add_Link_Dialog.Cancel_Button, "clicked",
      --   Button_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access),
      --False);

      Dialog_Callback.Object_Connect
        (Add_Link_Dialog.Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access),
         Add_Link_Dialog);

      Gtk_New (Add_Link_Dialog.Table, 1, 2, True);
      Set_Border_Width (Add_Link_Dialog.Table, 15);
      Set_Row_Spacings (Add_Link_Dialog.Table, 5);
      Set_Col_Spacings (Add_Link_Dialog.Table, 5);
      Pack_Start
        (Get_Vbox (Add_Link_Dialog),
         Add_Link_Dialog.Table,
         Expand  => True,
         Fill    => False,
         Padding => 0);

      Gtk_New (Add_Link_Dialog.Combo);
      Set_Value_In_List (Add_Link_Dialog.Combo, False);
      Set_Use_Arrows (Add_Link_Dialog.Combo, True);
      Set_Case_Sensitive (Add_Link_Dialog.Combo, False);
      Set_Editable (Get_Entry (Add_Link_Dialog.Combo), False);
      Set_Max_Length (Get_Entry (Add_Link_Dialog.Combo), 0);
      Set_Text (Get_Entry (Add_Link_Dialog.Combo), -(""));
      Set_Invisible_Char
        (Get_Entry (Add_Link_Dialog.Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Add_Link_Dialog.Combo), True);
      String_List.Append (Combo_Items, -(""));
      --String_List.Append (Combo_Items, -(""));
      Combo.Set_Popdown_Strings (Add_Link_Dialog.Combo, Combo_Items);
      Free_String_List (Combo_Items);
      Attach
        (Add_Link_Dialog.Table,
         Add_Link_Dialog.Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Add_Link_Dialog.Label, -("Event Handlers List"));
      Set_Alignment (Add_Link_Dialog.Label, 0.95, 0.5);
      Set_Padding (Add_Link_Dialog.Label, 0, 0);
      Set_Justify (Add_Link_Dialog.Label, Justify_Center);
      Set_Line_Wrap (Add_Link_Dialog.Label, False);
      Set_Selectable (Add_Link_Dialog.Label, False);
      Set_Use_Markup (Add_Link_Dialog.Label, False);
      Set_Use_Underline (Add_Link_Dialog.Label, False);
      Attach
        (Add_Link_Dialog.Table,
         Add_Link_Dialog.Label,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

   end Initialize;

end Add_Link_Dialog_Pkg;
