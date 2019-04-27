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
with Glib;                      use Glib;
with Gtk;                       use Gtk;
with Gdk.Types;                 use Gdk.Types;
with Gtk.Widget;                use Gtk.Widget;
with Gtk.Enums;                 use Gtk.Enums;
with Gtkada.Handlers;           use Gtkada.Handlers;
with Callbacks_Mast_Editor;     use Callbacks_Mast_Editor;
with Mast_Editor_Intl;          use Mast_Editor_Intl;
with Moeh_Dialog_Pkg.Callbacks; use Moeh_Dialog_Pkg.Callbacks;
with Mast;

package body Moeh_Dialog_Pkg is

   procedure Gtk_New (Moeh_Dialog : out Moeh_Dialog_Access) is
   begin
      Moeh_Dialog := new Moeh_Dialog_Record;
      Moeh_Dialog_Pkg.Initialize (Moeh_Dialog);
   end Gtk_New;

   procedure Initialize (Moeh_Dialog : access Moeh_Dialog_Record'Class) is
      pragma Suppress (All_Checks);
      Moutput_Type_Combo_Items : String_List.Glist;
      Del_Policy_Combo_Items   : String_List.Glist;
      Que_Policy_Combo_Items   : String_List.Glist;

   begin
      Gtk.Dialog.Initialize (Moeh_Dialog);
      Set_Title (Moeh_Dialog, -"Multi-Output Event Handler Parameters");
      Set_Policy (Moeh_Dialog, False, False, False);
      Set_Position (Moeh_Dialog, Win_Pos_Center);
      Set_Modal (Moeh_Dialog, False);

      Gtk_New_Hbox (Moeh_Dialog.Hbox73, True, 100);
      Pack_Start (Get_Action_Area (Moeh_Dialog), Moeh_Dialog.Hbox73);

      Gtk_New (Moeh_Dialog.Ok_Button, -"OK");
      Set_Relief (Moeh_Dialog.Ok_Button, Relief_Normal);
      Pack_Start
        (Moeh_Dialog.Hbox73,
         Moeh_Dialog.Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 40);

      Gtk_New (Moeh_Dialog.Cancel_Button, -"Cancel");
      Set_Relief (Moeh_Dialog.Cancel_Button, Relief_Normal);
      Pack_End
        (Moeh_Dialog.Hbox73,
         Moeh_Dialog.Cancel_Button,
         Expand  => True,
         Fill    => True,
         Padding => 40);
      --     Button_Callback.Connect
      --       (Moeh_Dialog.Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Cancel_Button_Clicked'Access), False);

      Dialog_Callback.Object_Connect
        (Moeh_Dialog.Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access),
         Moeh_Dialog);

      Gtk_New_Vbox (Moeh_Dialog.Vbox19, False, 0);
      Pack_Start
        (Get_Vbox (Moeh_Dialog),
         Moeh_Dialog.Vbox19,
         Expand  => False,
         Fill    => True,
         Padding => 0);

      Gtk_New (Moeh_Dialog.Table1, 1, 2, True);
      Set_Border_Width (Moeh_Dialog.Table1, 5);
      Set_Row_Spacings (Moeh_Dialog.Table1, 5);
      Set_Col_Spacings (Moeh_Dialog.Table1, 3);
      Pack_Start
        (Moeh_Dialog.Vbox19,
         Moeh_Dialog.Table1,
         Expand  => False,
         Fill    => False,
         Padding => 5);

      Gtk_New (Moeh_Dialog.Label206, -("Multi-Output Event Handler Type"));
      Set_Alignment (Moeh_Dialog.Label206, 0.95, 0.5);
      Set_Padding (Moeh_Dialog.Label206, 0, 0);
      Set_Justify (Moeh_Dialog.Label206, Justify_Center);
      Set_Line_Wrap (Moeh_Dialog.Label206, False);
      Set_Selectable (Moeh_Dialog.Label206, False);
      Set_Use_Markup (Moeh_Dialog.Label206, False);
      Set_Use_Underline (Moeh_Dialog.Label206, False);
      Attach
        (Moeh_Dialog.Table1,
         Moeh_Dialog.Label206,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Moeh_Dialog.Moutput_Type_Combo);
      Set_Value_In_List (Moeh_Dialog.Moutput_Type_Combo, False);
      Set_Use_Arrows (Moeh_Dialog.Moutput_Type_Combo, True);
      Set_Case_Sensitive (Moeh_Dialog.Moutput_Type_Combo, False);
      Set_Editable (Get_Entry (Moeh_Dialog.Moutput_Type_Combo), False);
      Set_Max_Length (Get_Entry (Moeh_Dialog.Moutput_Type_Combo), 0);
      Set_Text
        (Get_Entry (Moeh_Dialog.Moutput_Type_Combo),
         -("Multicast"));
      Set_Invisible_Char
        (Get_Entry (Moeh_Dialog.Moutput_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Moeh_Dialog.Moutput_Type_Combo), True);
      String_List.Append (Moutput_Type_Combo_Items, -("Multicast"));
      String_List.Append (Moutput_Type_Combo_Items, -("Delivery Server"));
      String_List.Append (Moutput_Type_Combo_Items, -("Query Server"));
      Combo.Set_Popdown_Strings
        (Moeh_Dialog.Moutput_Type_Combo,
         Moutput_Type_Combo_Items);
      Free_String_List (Moutput_Type_Combo_Items);
      Attach
        (Moeh_Dialog.Table1,
         Moeh_Dialog.Moutput_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Moeh_Dialog.Delivery_Table, 1, 2, True);
      Set_Border_Width (Moeh_Dialog.Delivery_Table, 5);
      Set_Row_Spacings (Moeh_Dialog.Delivery_Table, 5);
      Set_Col_Spacings (Moeh_Dialog.Delivery_Table, 3);
      Pack_Start
        (Moeh_Dialog.Vbox19,
         Moeh_Dialog.Delivery_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Moeh_Dialog.Label251, -("Delivery Policy"));
      Set_Alignment (Moeh_Dialog.Label251, 0.95, 0.5);
      Set_Padding (Moeh_Dialog.Label251, 0, 0);
      Set_Justify (Moeh_Dialog.Label251, Justify_Center);
      Set_Line_Wrap (Moeh_Dialog.Label251, False);
      Set_Selectable (Moeh_Dialog.Label251, False);
      Set_Use_Markup (Moeh_Dialog.Label251, False);
      Set_Use_Underline (Moeh_Dialog.Label251, False);
      Attach
        (Moeh_Dialog.Delivery_Table,
         Moeh_Dialog.Label251,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Moeh_Dialog.Del_Policy_Combo);
      Set_Value_In_List (Moeh_Dialog.Del_Policy_Combo, False);
      Set_Use_Arrows (Moeh_Dialog.Del_Policy_Combo, True);
      Set_Case_Sensitive (Moeh_Dialog.Del_Policy_Combo, False);
      Set_Editable (Get_Entry (Moeh_Dialog.Del_Policy_Combo), False);
      Set_Max_Length (Get_Entry (Moeh_Dialog.Del_Policy_Combo), 0);
      Set_Text (Get_Entry (Moeh_Dialog.Del_Policy_Combo), -("Random"));
      Set_Invisible_Char
        (Get_Entry (Moeh_Dialog.Del_Policy_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Moeh_Dialog.Del_Policy_Combo), True);
      for Policy in Mast.Delivery_Policy'Range loop
         String_List.Append (Del_Policy_Combo_Items,
                             -(Mast.Delivery_Policy'Image(Policy)));
      end loop;
      Combo.Set_Popdown_Strings
        (Moeh_Dialog.Del_Policy_Combo,
         Del_Policy_Combo_Items);
      Free_String_List (Del_Policy_Combo_Items);
      Attach
        (Moeh_Dialog.Delivery_Table,
         Moeh_Dialog.Del_Policy_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Moeh_Dialog.Query_Table, 1, 2, True);
      Set_Border_Width (Moeh_Dialog.Query_Table, 5);
      Set_Row_Spacings (Moeh_Dialog.Query_Table, 5);
      Set_Col_Spacings (Moeh_Dialog.Query_Table, 3);
      Pack_Start
        (Moeh_Dialog.Vbox19,
         Moeh_Dialog.Query_Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Moeh_Dialog.Label252, -("Request Policy"));
      Set_Alignment (Moeh_Dialog.Label252, 0.95, 0.5);
      Set_Padding (Moeh_Dialog.Label252, 0, 0);
      Set_Justify (Moeh_Dialog.Label252, Justify_Center);
      Set_Line_Wrap (Moeh_Dialog.Label252, False);
      Set_Selectable (Moeh_Dialog.Label252, False);
      Set_Use_Markup (Moeh_Dialog.Label252, False);
      Set_Use_Underline (Moeh_Dialog.Label252, False);
      Attach
        (Moeh_Dialog.Query_Table,
         Moeh_Dialog.Label252,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Moeh_Dialog.Que_Policy_Combo);
      Set_Value_In_List (Moeh_Dialog.Que_Policy_Combo, False);
      Set_Use_Arrows (Moeh_Dialog.Que_Policy_Combo, True);
      Set_Case_Sensitive (Moeh_Dialog.Que_Policy_Combo, False);
      Set_Editable (Get_Entry (Moeh_Dialog.Que_Policy_Combo), False);
      Set_Max_Length (Get_Entry (Moeh_Dialog.Que_Policy_Combo), 0);
      Set_Text (Get_Entry (Moeh_Dialog.Que_Policy_Combo), -("Scan"));
      Set_Invisible_Char
        (Get_Entry (Moeh_Dialog.Que_Policy_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Moeh_Dialog.Que_Policy_Combo), True);
      for Policy in Mast.Request_Policy'Range loop
         String_List.Append (Que_Policy_Combo_Items,
                             -(Mast.Request_Policy'Image(Policy)));
      end loop;
      Combo.Set_Popdown_Strings
        (Moeh_Dialog.Que_Policy_Combo,
         Que_Policy_Combo_Items);
      Free_String_List (Que_Policy_Combo_Items);
      Attach
        (Moeh_Dialog.Query_Table,
         Moeh_Dialog.Que_Policy_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      --     Entry_Callback.Connect
      --       (Get_Entry (Moeh_Dialog.Moutput_Type_Combo), "changed",
      --        Entry_Callback.To_Marshaller (On_Moeh_Type_Changed'Access));

      Moeh_Dialog_Callback.Object_Connect
        (Get_Entry (Moeh_Dialog.Moutput_Type_Combo),
         "changed",
         Moeh_Dialog_Callback.To_Marshaller (On_Moeh_Type_Changed'Access),
         Moeh_Dialog);

   end Initialize;

end Moeh_Dialog_Pkg;
