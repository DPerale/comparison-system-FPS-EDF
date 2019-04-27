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
with Glib;                                          use Glib;
with Gtk;                                           use Gtk;
with Gdk.Types;                                     use Gdk.Types;
with Gtk.Widget;                                    use Gtk.Widget;
with Gtk.Enums;                                     use Gtk.Enums;
with Gtkada.Handlers;                               use Gtkada.Handlers;
with Callbacks_Mast_Editor;                         use Callbacks_Mast_Editor;
with Mast_Editor_Intl;                              use Mast_Editor_Intl;
with Add_New_Server_To_Driver_Dialog_Pkg.Callbacks;
use Add_New_Server_To_Driver_Dialog_Pkg.Callbacks;

package body Add_New_Server_To_Driver_Dialog_Pkg is

   procedure Gtk_New
     (Add_New_Server_To_Driver_Dialog : out
        Add_New_Server_To_Driver_Dialog_Access)
   is
   begin
      Add_New_Server_To_Driver_Dialog :=
        new Add_New_Server_To_Driver_Dialog_Record;
      Add_New_Server_To_Driver_Dialog_Pkg.Initialize
        (Add_New_Server_To_Driver_Dialog);
   end Gtk_New;

   procedure Initialize
     (Add_New_Server_To_Driver_Dialog : access 
        Add_New_Server_To_Driver_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Pixmaps_Dir : constant String := "/";
   begin
      Gtk.Dialog.Initialize (Add_New_Server_To_Driver_Dialog);
      Set_Title
        (Add_New_Server_To_Driver_Dialog,
         -"Adding Driver's Servers");
      Set_Position (Add_New_Server_To_Driver_Dialog, Win_Pos_Center_Always);
      Set_Modal (Add_New_Server_To_Driver_Dialog, True);

      Gtk_New_Hbox (Add_New_Server_To_Driver_Dialog.Hbox3, True, 0);

      Gtk_New (Add_New_Server_To_Driver_Dialog.Ok_Button, -"OK");
      Set_Relief (Add_New_Server_To_Driver_Dialog.Ok_Button, Relief_Normal);

      Pack_Start
        (Add_New_Server_To_Driver_Dialog.Hbox3,
         Add_New_Server_To_Driver_Dialog.Ok_Button,
         Expand  => False,
         Fill    => True,
         Padding => 30);
      Gtk_New (Add_New_Server_To_Driver_Dialog.Cancel_Button, -"Cancel");
      Set_Relief
        (Add_New_Server_To_Driver_Dialog.Cancel_Button,
         Relief_Normal);

      Pack_Start
        (Add_New_Server_To_Driver_Dialog.Hbox3,
         Add_New_Server_To_Driver_Dialog.Cancel_Button,
         Expand  => False,
         Fill    => True,
         Padding => 30);
      --     Button_Callback.Connect
      --       (Add_New_Server_To_Driver_Dialog.Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Cancel_Button_Clicked'Access), False);

      Dialog_Callback.Object_Connect
        (Add_New_Server_To_Driver_Dialog.Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller (On_Cancel_Button_Clicked'Access),
         Add_New_Server_To_Driver_Dialog);

      Pack_Start
        (Get_Action_Area (Add_New_Server_To_Driver_Dialog),
         Add_New_Server_To_Driver_Dialog.Hbox3);
      Gtk_New (Add_New_Server_To_Driver_Dialog.Table1, 4, 1, True);
      Set_Border_Width (Add_New_Server_To_Driver_Dialog.Table1, 10);
      Set_Row_Spacings (Add_New_Server_To_Driver_Dialog.Table1, 5);
      Set_Col_Spacings (Add_New_Server_To_Driver_Dialog.Table1, 5);

      Gtk_New
        (Add_New_Server_To_Driver_Dialog.Packet_Server_Button,
         -("Packet Server"));
      Set_Relief
        (Add_New_Server_To_Driver_Dialog.Packet_Server_Button,
         Relief_Normal);
      Set_Active
        (Add_New_Server_To_Driver_Dialog.Packet_Server_Button,
         False);
      Set_Inconsistent
        (Add_New_Server_To_Driver_Dialog.Packet_Server_Button,
         False);
      Set_Relief
        (Add_New_Server_To_Driver_Dialog.Packet_Server_Button,
         Relief_Normal);
      Set_Use_Underline
        (Add_New_Server_To_Driver_Dialog.Packet_Server_Button,
         True);

      Attach
        (Add_New_Server_To_Driver_Dialog.Table1,
         Add_New_Server_To_Driver_Dialog.Packet_Server_Button,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 1,
         Bottom_Attach => 2,
         Xpadding      => 0,
         Ypadding      => 0);
      Gtk_New
        (Add_New_Server_To_Driver_Dialog.Character_Server_Button,
         -("Character Server"));
      Set_Relief
        (Add_New_Server_To_Driver_Dialog.Character_Server_Button,
         Relief_Normal);
      Set_Active
        (Add_New_Server_To_Driver_Dialog.Character_Server_Button,
         False);
      Set_Inconsistent
        (Add_New_Server_To_Driver_Dialog.Character_Server_Button,
         False);
      Set_Relief
        (Add_New_Server_To_Driver_Dialog.Character_Server_Button,
         Relief_Normal);
      Set_Use_Underline
        (Add_New_Server_To_Driver_Dialog.Character_Server_Button,
         True);

      Attach
        (Add_New_Server_To_Driver_Dialog.Table1,
         Add_New_Server_To_Driver_Dialog.Character_Server_Button,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 2,
         Bottom_Attach => 3,
         Xpadding      => 0,
         Ypadding      => 0);
      Gtk_New
        (Add_New_Server_To_Driver_Dialog.Label1,
         -("Add New Server to ..."));
      Set_Alignment (Add_New_Server_To_Driver_Dialog.Label1, 0.1, 1.0);
      Set_Padding (Add_New_Server_To_Driver_Dialog.Label1, 0, 5);
      Set_Justify (Add_New_Server_To_Driver_Dialog.Label1, Justify_Center);
      Set_Line_Wrap (Add_New_Server_To_Driver_Dialog.Label1, False);
      Set_Selectable (Add_New_Server_To_Driver_Dialog.Label1, False);
      Set_Use_Markup (Add_New_Server_To_Driver_Dialog.Label1, False);
      Set_Use_Underline (Add_New_Server_To_Driver_Dialog.Label1, False);

      Attach
        (Add_New_Server_To_Driver_Dialog.Table1,
         Add_New_Server_To_Driver_Dialog.Label1,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 0,
         Bottom_Attach => 1,
         Xoptions      => Fill,
         Xpadding      => 0,
         Ypadding      => 0);
      Gtk_New
        (Add_New_Server_To_Driver_Dialog.Packet_Int_Server_Button,
         -("Packet Interrupt Server"));
      Set_Relief
        (Add_New_Server_To_Driver_Dialog.Packet_Int_Server_Button,
         Relief_Normal);
      Set_Active
        (Add_New_Server_To_Driver_Dialog.Packet_Int_Server_Button,
         False);
      Set_Inconsistent
        (Add_New_Server_To_Driver_Dialog.Packet_Int_Server_Button,
         False);
      Set_Relief
        (Add_New_Server_To_Driver_Dialog.Packet_Int_Server_Button,
         Relief_Normal);
      Set_Use_Underline
        (Add_New_Server_To_Driver_Dialog.Packet_Int_Server_Button,
         True);

      Attach
        (Add_New_Server_To_Driver_Dialog.Table1,
         Add_New_Server_To_Driver_Dialog.Packet_Int_Server_Button,
         Left_Attach   => 0,
         Right_Attach  => 1,
         Top_Attach    => 3,
         Bottom_Attach => 4,
         Xpadding      => 0,
         Ypadding      => 0);
      Pack_Start
        (Get_Vbox (Add_New_Server_To_Driver_Dialog),
         Add_New_Server_To_Driver_Dialog.Table1,
         Expand  => True,
         Fill    => False,
         Padding => 0);
   end Initialize;

end Add_New_Server_To_Driver_Dialog_Pkg;
