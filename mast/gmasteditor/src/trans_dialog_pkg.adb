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
with Trans_Dialog_Pkg.Callbacks; use Trans_Dialog_Pkg.Callbacks;

with Pango.Font;    use Pango.Font;
with Gtk.Handlers;
with Gtk.Main;
with Gtk.Arguments; use Gtk.Arguments;
with Gdk.Event;     use Gdk.Event;

package body Trans_Dialog_Pkg is

   package Button_Cb is new Handlers.Callback (Gtk_Dialog_Record);
   -------------------------------
   -- This part is included to prevent window removal by clicking
   -- close button in the window's external frame
   package Return_Dialog_Cb is new Handlers.Return_Callback (
      Gtk_Widget_Record,
      Boolean);

   function On_Dialog_Delete_Event
     (Object : access Gtk_Widget_Record'Class;
      Params : Gtk.Arguments.Gtk_Args)
      return   Boolean;

   ----------------------------
   -- On_Dialog_Delete_Event --
   ----------------------------
   function On_Dialog_Delete_Event
     (Object : access Gtk_Widget_Record'Class;
      Params : Gtk.Arguments.Gtk_Args)
      return   Boolean
   is
   begin
      Hide (Object);
      return True;
   end On_Dialog_Delete_Event;
   -------------------------------

   procedure Gtk_New (Trans_Dialog : out Trans_Dialog_Access) is
   begin
      Trans_Dialog := new Trans_Dialog_Record;
      Trans_Dialog_Pkg.Initialize (Trans_Dialog);
   end Gtk_New;

   procedure Initialize (Trans_Dialog : access Trans_Dialog_Record'Class) is
      pragma Suppress (All_Checks);
      Pixmaps_Dir            : constant String := "pixmaps/";
      Trans_Type_Combo_Items : String_List.Glist;

   begin
      Gtk.Dialog.Initialize (Trans_Dialog);
      Set_Title (Trans_Dialog, -"Transaction Parameters");
      Set_Position (Trans_Dialog, Win_Pos_Center_Always);
      Set_Modal (Trans_Dialog, False);
      -----------------
      Return_Callback.Connect
        (Trans_Dialog,
         "delete_event",
         On_Dialog_Delete_Event'Access,
         False);
      -----------------
      Gtk_New_Hbox (Trans_Dialog.Hbox, True, 0);
      Pack_Start (Get_Action_Area (Trans_Dialog), Trans_Dialog.Hbox);

      Gtk_New (Trans_Dialog.Ok_Button, -"OK");
      Set_Relief (Trans_Dialog.Ok_Button, Relief_Normal);
      Pack_Start
        (Trans_Dialog.Hbox,
         Trans_Dialog.Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 130);

      Gtk_New (Trans_Dialog.Cancel_Button, -"Cancel");
      Set_Relief (Trans_Dialog.Cancel_Button, Relief_Normal);
      Pack_End
        (Trans_Dialog.Hbox,
         Trans_Dialog.Cancel_Button,
         Expand  => True,
         Fill    => True,
         Padding => 130);
      ---------------
      Button_Cb.Object_Connect
        (Trans_Dialog.Cancel_Button,
         "clicked",
         Button_Cb.To_Marshaller (On_Cancel_Button_Clicked'Access),
         Trans_Dialog);
      ---------------
      Gtk_New (Trans_Dialog.Table2, 3, 7, False);
      Set_Border_Width (Trans_Dialog.Table2, 5);
      Set_Row_Spacings (Trans_Dialog.Table2, 5);
      Set_Col_Spacings (Trans_Dialog.Table2, 10);
      Pack_Start
        (Get_Vbox (Trans_Dialog),
         Trans_Dialog.Table2,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Trans_Dialog.Trans_Name_Entry);
      Set_Editable (Trans_Dialog.Trans_Name_Entry, True);
      Set_Max_Length (Trans_Dialog.Trans_Name_Entry, 0);
      Set_Text (Trans_Dialog.Trans_Name_Entry, -(""));
      Set_Visibility (Trans_Dialog.Trans_Name_Entry, True);
      Set_Invisible_Char (Trans_Dialog.Trans_Name_Entry, UTF8_Get_Char ("*"));
      Attach
        (Trans_Dialog.Table2,
         Trans_Dialog.Trans_Name_Entry,
         Left_Attach   => 2,
         Right_Attach  => 3,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Trans_Dialog.Trans_Type_Combo);
      Set_Value_In_List (Trans_Dialog.Trans_Type_Combo, False);
      Set_Use_Arrows (Trans_Dialog.Trans_Type_Combo, True);
      Set_Case_Sensitive (Trans_Dialog.Trans_Type_Combo, False);
      Set_Editable (Get_Entry (Trans_Dialog.Trans_Type_Combo), False);
      Set_Has_Frame (Get_Entry (Trans_Dialog.Trans_Type_Combo), True);
      Set_Max_Length (Get_Entry (Trans_Dialog.Trans_Type_Combo), 0);
      Set_Text (Get_Entry (Trans_Dialog.Trans_Type_Combo), -("Regular"));
      Set_Invisible_Char
        (Get_Entry (Trans_Dialog.Trans_Type_Combo),
         UTF8_Get_Char ("*"));
      Set_Has_Frame (Get_Entry (Trans_Dialog.Trans_Type_Combo), True);
      String_List.Append (Trans_Type_Combo_Items, -("Regular"));
      Combo.Set_Popdown_Strings
        (Trans_Dialog.Trans_Type_Combo,
         Trans_Type_Combo_Items);
      Free_String_List (Trans_Type_Combo_Items);
      Attach
        (Trans_Dialog.Table2,
         Trans_Dialog.Trans_Type_Combo,
         Left_Attach   => 2,
         Right_Attach  => 3,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Trans_Dialog.Trans_Name_Label, -("Transaction Name"));
      Set_Alignment (Trans_Dialog.Trans_Name_Label, 0.95, 0.5);
      Set_Padding (Trans_Dialog.Trans_Name_Label, 0, 0);
      Set_Justify (Trans_Dialog.Trans_Name_Label, Justify_Center);
      Set_Line_Wrap (Trans_Dialog.Trans_Name_Label, False);
      Set_Selectable (Trans_Dialog.Trans_Name_Label, False);
      Set_Use_Markup (Trans_Dialog.Trans_Name_Label, False);
      Set_Use_Underline (Trans_Dialog.Trans_Name_Label, False);
      Attach
        (Trans_Dialog.Table2,
         Trans_Dialog.Trans_Name_Label,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Trans_Dialog.Trans_Type_Label, -("Transaction Type"));
      Set_Alignment (Trans_Dialog.Trans_Type_Label, 0.95, 0.5);
      Set_Padding (Trans_Dialog.Trans_Type_Label, 0, 0);
      Set_Justify (Trans_Dialog.Trans_Type_Label, Justify_Center);
      Set_Line_Wrap (Trans_Dialog.Trans_Type_Label, False);
      Set_Selectable (Trans_Dialog.Trans_Type_Label, False);
      Set_Use_Markup (Trans_Dialog.Trans_Type_Label, False);
      Set_Use_Underline (Trans_Dialog.Trans_Type_Label, False);
      Attach
        (Trans_Dialog.Table2,
         Trans_Dialog.Trans_Type_Label,
         Left_Attach   => 0,
         Right_Attach  => 2,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New
        (Trans_Dialog.Trans_Diagram_Label,
         -("TRANSACTION'S DIAGRAM:"));
      --------------
      Set_Alignment (Trans_Dialog.Trans_Diagram_Label, 0.4, 0.5);
      --------------
      Set_Padding (Trans_Dialog.Trans_Diagram_Label, 0, 0);
      Set_Justify (Trans_Dialog.Trans_Diagram_Label, Justify_Center);
      Set_Line_Wrap (Trans_Dialog.Trans_Diagram_Label, False);
      Set_Selectable (Trans_Dialog.Trans_Diagram_Label, False);
      Set_Use_Markup (Trans_Dialog.Trans_Diagram_Label, False);
      Set_Use_Underline (Trans_Dialog.Trans_Diagram_Label, False);
      Attach
        (Trans_Dialog.Table2,
         Trans_Dialog.Trans_Diagram_Label,
         Left_Attach   => 0,
         Right_Attach  => 5,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Trans_Dialog.Table, 8, 7, False);
      Set_Border_Width (Trans_Dialog.Table, 5);
      Set_Row_Spacings (Trans_Dialog.Table, 5);
      Set_Col_Spacings (Trans_Dialog.Table, 10);
      Pack_Start
        (Get_Vbox (Trans_Dialog),
         Trans_Dialog.Table,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Gtk_New (Trans_Dialog.Frame);
      Set_Label_Align (Trans_Dialog.Frame, 0.0, 0.5);
      Set_Shadow_Type (Trans_Dialog.Frame, Shadow_Etched_In);
      Attach
        (Trans_Dialog.Table,
         Trans_Dialog.Frame,
         Left_Attach   => 0,
         Right_Attach  => 6,
         Top_Attach    => 0,
         Bottom_Attach => 8,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Trans_Dialog.Scrolled);
      Set_Policy (Trans_Dialog.Scrolled, Policy_Always, Policy_Always);
      Set_Shadow_Type (Trans_Dialog.Scrolled, Shadow_None);
      Add (Trans_Dialog.Frame, Trans_Dialog.Scrolled);
      -- We add Canvas to the Frame
      Gtk_New (Trans_Dialog.Trans_Canvas);
      Configure
        (Trans_Dialog.Trans_Canvas,
         Grid_Size        => 0,
         Annotation_Font  => Pango.Font.From_String (Default_Annotation_Font),
         Arc_Link_Offset  => Default_Arc_Link_Offset,
         Arrow_Angle      => Default_Arrow_Angle,
         Arrow_Length     => Default_Arrow_Length,
         Motion_Threshold => Default_Motion_Threshold);
      Add (Trans_Dialog.Scrolled, Trans_Dialog.Trans_Canvas);
      ----------------------------

      Gtk_New (Trans_Dialog.Events_Frame);
      Set_Label_Align (Trans_Dialog.Events_Frame, 0.5, 0.5);
      Set_Shadow_Type (Trans_Dialog.Events_Frame, Shadow_Etched_In);
      Attach
        (Trans_Dialog.Table,
         Trans_Dialog.Events_Frame,
         Left_Attach   => 6,
         Right_Attach  => 7,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Fill,
         Yoptions      => Expand,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New_Vbox (Trans_Dialog.Vbox51, False, 10);
      Add (Trans_Dialog.Events_Frame, Trans_Dialog.Vbox51);

      Gtk_New (Trans_Dialog.Add_Ext_Button, -"Add External Event");
      Set_Border_Width (Trans_Dialog.Add_Ext_Button, 10);
      Set_Relief (Trans_Dialog.Add_Ext_Button, Relief_Normal);
      Pack_Start
        (Trans_Dialog.Vbox51,
         Trans_Dialog.Add_Ext_Button,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Trans_Dialog.Add_Int_Button, -"Add Internal Event");
      Set_Border_Width (Trans_Dialog.Add_Int_Button, 10);
      Set_Relief (Trans_Dialog.Add_Int_Button, Relief_Normal);
      Pack_Start
        (Trans_Dialog.Vbox51,
         Trans_Dialog.Add_Int_Button,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Trans_Dialog.Events_Label, -("Events "));
      Set_Alignment (Trans_Dialog.Events_Label, 0.5, 0.5);
      Set_Padding (Trans_Dialog.Events_Label, 0, 0);
      Set_Justify (Trans_Dialog.Events_Label, Justify_Left);
      Set_Line_Wrap (Trans_Dialog.Events_Label, False);
      Set_Selectable (Trans_Dialog.Events_Label, False);
      Set_Use_Markup (Trans_Dialog.Events_Label, False);
      Set_Use_Underline (Trans_Dialog.Events_Label, False);
      Set_Label_Widget (Trans_Dialog.Events_Frame, Trans_Dialog.Events_Label);

      Gtk_New (Trans_Dialog.Handlers_Frame);
      Set_Label_Align (Trans_Dialog.Handlers_Frame, 0.5, 0.5);
      Set_Shadow_Type (Trans_Dialog.Handlers_Frame, Shadow_Etched_In);
      Attach
        (Trans_Dialog.Table,
         Trans_Dialog.Handlers_Frame,
         Left_Attach   => 6,
         Right_Attach  => 7,
         Top_Attach    => 4,
         Bottom_Attach => 5,
         Xoptions      => Fill,
         Yoptions      => Expand,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New_Vbox (Trans_Dialog.Vbox52, False, 10);
      Add (Trans_Dialog.Handlers_Frame, Trans_Dialog.Vbox52);

      Gtk_New (Trans_Dialog.Add_Simple_Button, -"Add Simple");
      Set_Border_Width (Trans_Dialog.Add_Simple_Button, 10);
      Set_Relief (Trans_Dialog.Add_Simple_Button, Relief_Normal);
      Pack_Start
        (Trans_Dialog.Vbox52,
         Trans_Dialog.Add_Simple_Button,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Trans_Dialog.Add_Minput_Button, -"Add Multi-Input");
      Set_Border_Width (Trans_Dialog.Add_Minput_Button, 10);
      Set_Relief (Trans_Dialog.Add_Minput_Button, Relief_Normal);
      Pack_Start
        (Trans_Dialog.Vbox52,
         Trans_Dialog.Add_Minput_Button,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Trans_Dialog.Add_Moutput_Button, -"Add Multi-Output");
      Set_Border_Width (Trans_Dialog.Add_Moutput_Button, 10);
      Set_Relief (Trans_Dialog.Add_Moutput_Button, Relief_Normal);
      Pack_Start
        (Trans_Dialog.Vbox52,
         Trans_Dialog.Add_Moutput_Button,
         Expand  => False,
         Fill    => False,
         Padding => 0);

      Gtk_New (Trans_Dialog.Event_Handlers_Label, -("Event Handlers "));
      Set_Alignment (Trans_Dialog.Event_Handlers_Label, 0.5, 0.5);
      Set_Padding (Trans_Dialog.Event_Handlers_Label, 0, 0);
      Set_Justify (Trans_Dialog.Event_Handlers_Label, Justify_Left);
      Set_Line_Wrap (Trans_Dialog.Event_Handlers_Label, False);
      Set_Selectable (Trans_Dialog.Event_Handlers_Label, False);
      Set_Use_Markup (Trans_Dialog.Event_Handlers_Label, False);
      Set_Use_Underline (Trans_Dialog.Event_Handlers_Label, False);
      Set_Label_Widget
        (Trans_Dialog.Handlers_Frame,
         Trans_Dialog.Event_Handlers_Label);

   end Initialize;

end Trans_Dialog_Pkg;
