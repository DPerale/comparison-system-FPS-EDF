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
with Save_Changes_Dialog_Pkg.Callbacks; use Save_Changes_Dialog_Pkg.Callbacks;

package body Save_Changes_Dialog_Pkg is

   procedure Gtk_New (Save_Changes_Dialog : out Save_Changes_Dialog_Access) is
   begin
      Save_Changes_Dialog := new Save_Changes_Dialog_Record;
      Save_Changes_Dialog_Pkg.Initialize (Save_Changes_Dialog);
   end Gtk_New;

   procedure Initialize
     (Save_Changes_Dialog : access Save_Changes_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Pixmaps_Dir : constant String := "pixmaps/";
   begin
      Gtk.Dialog.Initialize (Save_Changes_Dialog);
      Set_Title (Save_Changes_Dialog, -"Confirmation");
      Set_Position (Save_Changes_Dialog, Win_Pos_Center);
      Set_Modal (Save_Changes_Dialog, True);
      Set_Default_Size (Save_Changes_Dialog, 400, 200);

      Gtk_New (Save_Changes_Dialog.Save_Button, -"Save");
      Set_Relief (Save_Changes_Dialog.Save_Button, Relief_Normal);
      Set_Flags (Save_Changes_Dialog.Save_Button, Can_Default);

      --     Button_Callback.Connect
      --       (Save_Changes_Dialog.Save_Button, "clicked",
      --        Button_Callback.To_Marshaller (On_Save_Button_Clicked'Access),
      --False);

      Dialog_Callback.Object_Connect
        (Save_Changes_Dialog.Save_Button,
         "clicked",
         Dialog_Callback.To_Marshaller (On_Save_Button_Clicked'Access),
         Save_Changes_Dialog);

      Pack_Start
        (Get_Action_Area (Save_Changes_Dialog),
         Save_Changes_Dialog.Save_Button);

      Gtk_New (Save_Changes_Dialog.Discard_Button, -"Discard");
      Set_Relief (Save_Changes_Dialog.Discard_Button, Relief_Normal);
      Set_Flags (Save_Changes_Dialog.Discard_Button, Can_Default);

      --    Button_Callback.Connect
      --       (Save_Changes_Dialog.Discard_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Discard_Button_Clicked'Access), False);

      Save_Changes_Dialog_Callback.Object_Connect
        (Save_Changes_Dialog.Discard_Button,
         "clicked",
         Save_Changes_Dialog_Callback.To_Marshaller
            (On_Discard_Button_Clicked'Access),
         Save_Changes_Dialog);

      Pack_Start
        (Get_Action_Area (Save_Changes_Dialog),
         Save_Changes_Dialog.Discard_Button);

      Gtk_New
        (Save_Changes_Dialog.Label,
         -("Current file has been modified." &
           ASCII.LF &
           "Do you wish to save changes?"));
      Set_Alignment (Save_Changes_Dialog.Label, 0.5, 0.5);
      Set_Padding (Save_Changes_Dialog.Label, 0, 0);
      Set_Justify (Save_Changes_Dialog.Label, Justify_Center);
      Set_Line_Wrap (Save_Changes_Dialog.Label, False);
      Set_Selectable (Save_Changes_Dialog.Label, False);
      Set_Use_Markup (Save_Changes_Dialog.Label, False);
      Set_Use_Underline (Save_Changes_Dialog.Label, False);
      Pack_Start
        (Get_Vbox (Save_Changes_Dialog),
         Save_Changes_Dialog.Label,
         Expand  => True,
         Fill    => True,
         Padding => 25);

   end Initialize;

end Save_Changes_Dialog_Pkg;
