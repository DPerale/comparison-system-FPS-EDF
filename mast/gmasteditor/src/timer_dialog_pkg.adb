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
with Glib;                       use Glib;
with Gtk;                        use Gtk;
with Gdk.Types;                  use Gdk.Types;
with Gtk.Widget;                 use Gtk.Widget;
with Gtk.Enums;                  use Gtk.Enums;
with Gtkada.Handlers;            use Gtkada.Handlers;
with Callbacks_Mast_Editor;      use Callbacks_Mast_Editor;
with Mast_Editor_Intl;           use Mast_Editor_Intl;
with Timer_Dialog_Pkg.Callbacks; use Timer_Dialog_Pkg.Callbacks;

package body Timer_Dialog_Pkg is

   procedure Gtk_New (Timer_Dialog : out Timer_Dialog_Access) is
   begin
      Timer_Dialog := new Timer_Dialog_Record;
      Timer_Dialog_Pkg.Initialize (Timer_Dialog);
   end Gtk_New;

   procedure Initialize (Timer_Dialog : access Timer_Dialog_Record'Class) is
      pragma Suppress (All_Checks);
      Pixmaps_Dir                   : constant String := "pixmaps/";
      System_Timer_Type_Combo_Items : String_List.Glist;

   begin
      Gtk.Dialog.Initialize (Timer_Dialog);
      Set_Title (Timer_Dialog, -"Timer Parameters");
      Set_Position (Timer_Dialog, Win_Pos_Center_Always);
      Set_Modal (Timer_Dialog, False);

      Gtk_New_Hbox (Timer_Dialog.Hbox104, True, 0);
      Pack_Start (Get_Action_Area (Timer_Dialog), Timer_Dialog.Hbox104);

      Gtk_New (Timer_Dialog.Ok_Button, -"OK");
      Set_Relief (Timer_Dialog.Ok_Button, Relief_Normal);
      Pack_Start
        (Timer_Dialog.Hbox104,
         Timer_Dialog.Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 60);

      Gtk_New (Timer_Dialog.Cancel_Button, -"Cancel");
      Set_Relief (Timer_Dialog.Cancel_Button, Relief_Normal);
      Pack_End
        (Timer_Dialog.Hbox104,
         Timer_Dialog.Cancel_Button,
         Expand  => True,
         Fill    => True,
         Padding => 62);
      --     Button_Callback.Connect
      --       (Timer_Dialog.Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Cancel_Button_Clicked'Access), False);

      Dialog_Callback.Object_Connect
        (Timer_Dialog.Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access),
         Timer_Dialog);

      Gtk_New_Vbox (Timer_Dialog.Vbox62, False, 5);
      Set_Border_Width (Timer_Dialog.Vbox62, 10);
      Pack_Start
        (Get_Vbox (Timer_Dialog),
         Timer_Dialog.Vbox62,
         Expand  => False,
         Fill    => True,
         Padding => 0);

      Gtk_New (Timer_Dialog.Timer_Table, 5, 2, True);
      Set_Row_Spacings (Timer_Dialog.Timer_Table, 5);
      Set_Col_Spacings (Timer_Dialog.Timer_Table, 5);
      Pack_Start
        (Timer_Dialog.Vbox62,
         Timer_Dialog.Timer_Table,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Timer_Dialog.Proc_Period_Label, -("Period"));
      Set_Alignment (Timer_Dialog.Proc_Period_Label, 0.95, 0.5);
      Set_Padding (Timer_Dialog.Proc_Period_Label, 0, 0);
      Set_Justify (Timer_Dialog.Proc_Period_Label, Justify_Center);
      Set_Line_Wrap (Timer_Dialog.Proc_Period_Label, False);
      Set_Selectable (Timer_Dialog.Proc_Period_Label, False);
      Set_Use_Markup (Timer_Dialog.Proc_Period_Label, False);
      Set_Use_Underline (Timer_Dialog.Proc_Period_Label, False);
      Attach
        (Timer_Dialog.Timer_Table,
         Timer_Dialog.Proc_Period_Label,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Timer_Dialog.Proc_Period_Entry);
      Set_Editable (Timer_Dialog.Proc_Period_Entry, True);
      Set_Max_Length (Timer_Dialog.Proc_Period_Entry, 0);
      Set_Text (Timer_Dialog.Proc_Period_Entry, -("0.00"));
      Set_Visibility (Timer_Dialog.Proc_Period_Entry, True);
      Set_Invisible_Char
        (Timer_Dialog.Proc_Period_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Timer_Dialog.Timer_Table,
         Timer_Dialog.Proc_Period_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Timer_Dialog.Label617, -("Best Overhead"));
      Set_Alignment (Timer_Dialog.Label617, 0.95, 0.5);
      Set_Padding (Timer_Dialog.Label617, 0, 0);
      Set_Justify (Timer_Dialog.Label617, Justify_Center);
      Set_Line_Wrap (Timer_Dialog.Label617, False);
      Set_Selectable (Timer_Dialog.Label617, False);
      Set_Use_Markup (Timer_Dialog.Label617, False);
      Set_Use_Underline (Timer_Dialog.Label617, False);
      Attach
        (Timer_Dialog.Timer_Table,
         Timer_Dialog.Label617,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Timer_Dialog.Proc_Bes_Over_Entry);
      Set_Editable (Timer_Dialog.Proc_Bes_Over_Entry, True);
      Set_Max_Length (Timer_Dialog.Proc_Bes_Over_Entry, 0);
      Set_Text (Timer_Dialog.Proc_Bes_Over_Entry, -("0.00"));
      Set_Visibility (Timer_Dialog.Proc_Bes_Over_Entry, True);
      Set_Invisible_Char
        (Timer_Dialog.Proc_Bes_Over_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Timer_Dialog.Timer_Table,
         Timer_Dialog.Proc_Bes_Over_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Timer_Dialog.Label618, -("Average Overhead"));
      Set_Alignment (Timer_Dialog.Label618, 0.95, 0.5);
      Set_Padding (Timer_Dialog.Label618, 0, 0);
      Set_Justify (Timer_Dialog.Label618, Justify_Center);
      Set_Line_Wrap (Timer_Dialog.Label618, False);
      Set_Selectable (Timer_Dialog.Label618, False);
      Set_Use_Markup (Timer_Dialog.Label618, False);
      Set_Use_Underline (Timer_Dialog.Label618, False);
      Attach
        (Timer_Dialog.Timer_Table,
         Timer_Dialog.Label618,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Timer_Dialog.Proc_Avg_Over_Entry);
      Set_Editable (Timer_Dialog.Proc_Avg_Over_Entry, True);
      Set_Max_Length (Timer_Dialog.Proc_Avg_Over_Entry, 0);
      Set_Text (Timer_Dialog.Proc_Avg_Over_Entry, -("0.00"));
      Set_Visibility (Timer_Dialog.Proc_Avg_Over_Entry, True);
      Set_Invisible_Char
        (Timer_Dialog.Proc_Avg_Over_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Timer_Dialog.Timer_Table,
         Timer_Dialog.Proc_Avg_Over_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Timer_Dialog.Label619, -("Worst Overhead"));
      Set_Alignment (Timer_Dialog.Label619, 0.95, 0.5);
      Set_Padding (Timer_Dialog.Label619, 0, 0);
      Set_Justify (Timer_Dialog.Label619, Justify_Center);
      Set_Line_Wrap (Timer_Dialog.Label619, False);
      Set_Selectable (Timer_Dialog.Label619, False);
      Set_Use_Markup (Timer_Dialog.Label619, False);
      Set_Use_Underline (Timer_Dialog.Label619, False);
      Attach
        (Timer_Dialog.Timer_Table,
         Timer_Dialog.Label619,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Timer_Dialog.Proc_Wor_Over_Entry);
      Set_Editable (Timer_Dialog.Proc_Wor_Over_Entry, True);
      Set_Max_Length (Timer_Dialog.Proc_Wor_Over_Entry, 0);
      Set_Text (Timer_Dialog.Proc_Wor_Over_Entry, -("0.00"));
      Set_Visibility (Timer_Dialog.Proc_Wor_Over_Entry, True);
      Set_Invisible_Char
        (Timer_Dialog.Proc_Wor_Over_Entry,
         UTF8_Get_Char ("*"));
      Attach
        (Timer_Dialog.Timer_Table,
         Timer_Dialog.Proc_Wor_Over_Entry,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Timer_Dialog.Label614, -("Type"));
      Set_Alignment (Timer_Dialog.Label614, 0.95, 0.5);
      Set_Padding (Timer_Dialog.Label614, 0, 0);
      Set_Justify (Timer_Dialog.Label614, Justify_Center);
      Set_Line_Wrap (Timer_Dialog.Label614, False);
      Set_Selectable (Timer_Dialog.Label614, False);
      Set_Use_Markup (Timer_Dialog.Label614, False);
      Set_Use_Underline (Timer_Dialog.Label614, False);
      Attach
        (Timer_Dialog.Timer_Table,
         Timer_Dialog.Label614,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Timer_Dialog.System_Timer_Type_Combo);
      Set_Value_In_List (Timer_Dialog.System_Timer_Type_Combo, False);
      Set_Use_Arrows (Timer_Dialog.System_Timer_Type_Combo, True);
      Set_Case_Sensitive (Timer_Dialog.System_Timer_Type_Combo, False);
      Set_Editable (Get_Entry (Timer_Dialog.System_Timer_Type_Combo), False);
      Set_Has_Frame (Get_Entry (Timer_Dialog.System_Timer_Type_Combo), True);
      Set_Max_Length (Get_Entry (Timer_Dialog.System_Timer_Type_Combo), 0);
      Set_Text
        (Get_Entry (Timer_Dialog.System_Timer_Type_Combo),
         -("Ticker"));
      Set_Invisible_Char
        (Get_Entry (Timer_Dialog.System_Timer_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Timer_Dialog.System_Timer_Type_Combo), True);

      --     Entry_Callback.Connect
      --       (Get_Entry (Timer_Dialog.System_Timer_Type_Combo), "activate",
      --        Entry_Callback.To_Marshaller
      --(On_System_Timer_Type_Entry_Changed'Access), False);

      Timer_Dialog_Callback.Object_Connect
        (Get_Entry (Timer_Dialog.System_Timer_Type_Combo),
         "changed",
         Timer_Dialog_Callback.To_Marshaller
            (On_System_Timer_Type_Entry_Changed'Access),
         Timer_Dialog);

      String_List.Append (System_Timer_Type_Combo_Items, -("Ticker"));
      String_List.Append (System_Timer_Type_Combo_Items, -("Alarm Clock"));
      Combo.Set_Popdown_Strings
        (Timer_Dialog.System_Timer_Type_Combo,
         System_Timer_Type_Combo_Items);
      Free_String_List (System_Timer_Type_Combo_Items);
      Attach
        (Timer_Dialog.Timer_Table,
         Timer_Dialog.System_Timer_Type_Combo,
         Left_Attach   => 1,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

   end Initialize;

end Timer_Dialog_Pkg;
