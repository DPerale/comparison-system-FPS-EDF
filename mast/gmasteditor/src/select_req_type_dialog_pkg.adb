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
with Select_Req_Type_Dialog_Pkg.Callbacks;
use Select_Req_Type_Dialog_Pkg.Callbacks;

package body Select_Req_Type_Dialog_Pkg is

   procedure Gtk_New
     (Select_Req_Type_Dialog : out Select_Req_Type_Dialog_Access)
   is
   begin
      Select_Req_Type_Dialog := new Select_Req_Type_Dialog_Record;
      Select_Req_Type_Dialog_Pkg.Initialize (Select_Req_Type_Dialog);
   end Gtk_New;

   procedure Initialize
     (Select_Req_Type_Dialog : access Select_Req_Type_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Combo_Items : String_List.Glist;

   begin
      Gtk.Dialog.Initialize (Select_Req_Type_Dialog);
      Set_Title (Select_Req_Type_Dialog, -"Timing Requirement Type");
      Set_Position (Select_Req_Type_Dialog, Win_Pos_Center);
      Set_Modal (Select_Req_Type_Dialog, True);

      Gtk_New_Hbox (Select_Req_Type_Dialog.Hbox, True, 0);
      Pack_Start
        (Get_Action_Area (Select_Req_Type_Dialog),
         Select_Req_Type_Dialog.Hbox);

      Gtk_New (Select_Req_Type_Dialog.Ok_Button, -"OK");
      Set_Relief (Select_Req_Type_Dialog.Ok_Button, Relief_Normal);
      Pack_Start
        (Select_Req_Type_Dialog.Hbox,
         Select_Req_Type_Dialog.Ok_Button,
         Expand  => False,
         Fill    => True,
         Padding => 10);

      Gtk_New (Select_Req_Type_Dialog.Cancel_Button, -"Cancel");
      Set_Relief (Select_Req_Type_Dialog.Cancel_Button, Relief_Normal);
      Pack_Start
        (Select_Req_Type_Dialog.Hbox,
         Select_Req_Type_Dialog.Cancel_Button,
         Expand  => False,
         Fill    => True,
         Padding => 10);
      --     Button_Callback.Connect
      --       (Select_Req_Type_Dialog.Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Cancel_Button_Clicked'Access), False);

      Dialog_Callback.Object_Connect
        (Select_Req_Type_Dialog.Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access),
         Select_Req_Type_Dialog);

      Gtk_New (Select_Req_Type_Dialog.Table, 2, 1, True);
      Set_Border_Width (Select_Req_Type_Dialog.Table, 20);
      Set_Row_Spacings (Select_Req_Type_Dialog.Table, 5);
      Set_Col_Spacings (Select_Req_Type_Dialog.Table, 5);
      Pack_Start
        (Get_Vbox (Select_Req_Type_Dialog),
         Select_Req_Type_Dialog.Table,
         Expand  => True,
         Fill    => False,
         Padding => 0);

      Gtk_New
        (Select_Req_Type_Dialog.Label,
         -("Please, select timing requirement type..."));
      Set_Alignment (Select_Req_Type_Dialog.Label, 0.1, 1.0);
      Set_Padding (Select_Req_Type_Dialog.Label, 0, 5);
      Set_Justify (Select_Req_Type_Dialog.Label, Justify_Center);
      Set_Line_Wrap (Select_Req_Type_Dialog.Label, False);
      Set_Selectable (Select_Req_Type_Dialog.Label, False);
      Set_Use_Markup (Select_Req_Type_Dialog.Label, False);
      Set_Use_Underline (Select_Req_Type_Dialog.Label, False);
      Attach
        (Select_Req_Type_Dialog.Table,
         Select_Req_Type_Dialog.Label,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Select_Req_Type_Dialog.Combo);
      Set_Value_In_List (Select_Req_Type_Dialog.Combo, False);
      Set_Use_Arrows (Select_Req_Type_Dialog.Combo, True);
      Set_Case_Sensitive (Select_Req_Type_Dialog.Combo, False);
      Set_Editable (Get_Entry (Select_Req_Type_Dialog.Combo), True);
      Set_Max_Length (Get_Entry (Select_Req_Type_Dialog.Combo), 0);
      Set_Text
        (Get_Entry (Select_Req_Type_Dialog.Combo),
         -("Hard Global Deadline"));
      Set_Invisible_Char
        (Get_Entry (Select_Req_Type_Dialog.Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Select_Req_Type_Dialog.Combo), True);
      String_List.Append (Combo_Items, -("Hard Global Deadline"));
      String_List.Append (Combo_Items, -("Soft Global Deadline"));
      String_List.Append (Combo_Items, -("Hard Local Deadline"));
      String_List.Append (Combo_Items, -("Soft Local Deadline"));
      String_List.Append (Combo_Items, -("Global Max Miss Ratio"));
      String_List.Append (Combo_Items, -("Local Max Miss Ratio"));
      String_List.Append (Combo_Items, -("Max Output Jitter"));
      Combo.Set_Popdown_Strings (Select_Req_Type_Dialog.Combo, Combo_Items);
      Free_String_List (Combo_Items);
      Attach
        (Select_Req_Type_Dialog.Table,
         Select_Req_Type_Dialog.Combo,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

   end Initialize;

end Select_Req_Type_Dialog_Pkg;
