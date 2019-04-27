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
with Glib;                              use Glib;
with Gtk;                               use Gtk;
with Gdk.Types;                         use Gdk.Types;
with Gtk.Widget;                        use Gtk.Widget;
with Gtk.Enums;                         use Gtk.Enums;
with Gtkada.Handlers;                   use Gtkada.Handlers;
with Callbacks_Mast_Editor;             use Callbacks_Mast_Editor;
with Mast_Editor_Intl;                  use Mast_Editor_Intl;
with Editor_Error_Window_Pkg.Callbacks; use Editor_Error_Window_Pkg.Callbacks;

package body Editor_Error_Window_Pkg is

   procedure Gtk_New (Editor_Error_Window : out Editor_Error_Window_Access) is
   begin
      Editor_Error_Window := new Editor_Error_Window_Record;
      Editor_Error_Window_Pkg.Initialize (Editor_Error_Window);
   end Gtk_New;

   procedure Initialize
     (Editor_Error_Window : access Editor_Error_Window_Record'Class)
   is
      pragma Suppress (All_Checks);
   begin
      Gtk.Dialog.Initialize (Editor_Error_Window);
      Set_Title (Editor_Error_Window, -"ERROR !!!");
      Set_Position (Editor_Error_Window, Win_Pos_Center_Always);
      Set_Modal (Editor_Error_Window, True);
      Set_USize (Editor_Error_Window, -1, 180);

      Gtk_New_Hbox (Editor_Error_Window.Hbox, True, 0);
      Pack_Start
        (Get_Action_Area (Editor_Error_Window),
         Editor_Error_Window.Hbox);

      Gtk_New (Editor_Error_Window.Ok_Button, -"OK");
      Set_Relief (Editor_Error_Window.Ok_Button, Relief_Normal);
      Set_USize (Editor_Error_Window.Ok_Button, 100, -1);
      Pack_Start
        (Editor_Error_Window.Hbox,
         Editor_Error_Window.Ok_Button,
         Expand  => True,
         Fill    => True,
         Padding => 120);
      Button_Callback.Connect
        (Editor_Error_Window.Ok_Button,
         "clicked",
         Button_Callback.To_Marshaller (On_Ok_Button_Clicked'Access),
         False);

      Gtk_New (Editor_Error_Window.Table, 3, 1, True);
      Set_Border_Width (Editor_Error_Window.Table, 5);
      Set_Row_Spacings (Editor_Error_Window.Table, 5);
      Set_Col_Spacings (Editor_Error_Window.Table, 5);
      Pack_Start
        (Get_Vbox (Editor_Error_Window),
         Editor_Error_Window.Table,
         Expand  => False,
         Fill    => False,
         Padding => 10);

      Gtk_New (Editor_Error_Window.Down_Label);
      Set_Alignment (Editor_Error_Window.Down_Label, 0.1, 1.0);
      Set_Padding (Editor_Error_Window.Down_Label, 0, 5);
      Set_Justify (Editor_Error_Window.Down_Label, Justify_Center);
      Set_Line_Wrap (Editor_Error_Window.Down_Label, False);
      Set_Selectable (Editor_Error_Window.Down_Label, False);
      Set_Use_Markup (Editor_Error_Window.Down_Label, False);
      Set_Use_Underline (Editor_Error_Window.Down_Label, False);
      Attach
        (Editor_Error_Window.Table,
         Editor_Error_Window.Down_Label,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xoptions      => Expand,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Editor_Error_Window.Up_Label);
      Set_Alignment (Editor_Error_Window.Up_Label, 0.1, 1.0);
      Set_Padding (Editor_Error_Window.Up_Label, 0, 5);
      Set_Justify (Editor_Error_Window.Up_Label, Justify_Center);
      Set_Line_Wrap (Editor_Error_Window.Up_Label, False);
      Set_Selectable (Editor_Error_Window.Up_Label, False);
      Set_Use_Markup (Editor_Error_Window.Up_Label, False);
      Set_Use_Underline (Editor_Error_Window.Up_Label, False);
      Attach
        (Editor_Error_Window.Table,
         Editor_Error_Window.Up_Label,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Expand,
         Xpadding      => 0,
         Ypadding      => 0);

      Gtk_New (Editor_Error_Window.Label, -("Error !!!"));
      Set_Alignment (Editor_Error_Window.Label, 0.1, 1.0);
      Set_Padding (Editor_Error_Window.Label, 0, 5);
      Set_Justify (Editor_Error_Window.Label, Justify_Center);
      Set_Line_Wrap (Editor_Error_Window.Label, False);
      Set_Selectable (Editor_Error_Window.Label, False);
      Set_Use_Markup (Editor_Error_Window.Label, False);
      Set_Use_Underline (Editor_Error_Window.Label, False);
      Attach
        (Editor_Error_Window.Table,
         Editor_Error_Window.Label,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xoptions      => Expand,
         Xpadding      => 0,
         Ypadding      => 0);

   end Initialize;

end Editor_Error_Window_Pkg;
