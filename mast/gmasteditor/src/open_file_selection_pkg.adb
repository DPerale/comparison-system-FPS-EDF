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
with Open_File_Selection_Pkg.Callbacks; use Open_File_Selection_Pkg.Callbacks;

package body Open_File_Selection_Pkg is

   procedure Gtk_New (Open_File_Selection : out Open_File_Selection_Access) is
   begin
      Open_File_Selection := new Open_File_Selection_Record;
      Open_File_Selection_Pkg.Initialize (Open_File_Selection);
   end Gtk_New;

   procedure Initialize
     (Open_File_Selection : access Open_File_Selection_Record'Class)
   is
      pragma Suppress (All_Checks);
   begin
      Gtk.File_Selection.Initialize (Open_File_Selection, "Open File");
      Set_Show_File_Op_Buttons (Open_File_Selection, True);
      Set_Border_Width (Open_File_Selection, 10);
      Set_Title (Open_File_Selection, "Open File");
      Set_Policy (Open_File_Selection, False, True, False);
      Set_Position (Open_File_Selection, Win_Pos_Mouse);
      Set_Modal (Open_File_Selection, True);
      Return_Callback.Connect
        (Open_File_Selection,
         "delete_event",
         On_Open_Filesel_Delete_Event'Access);

      Open_File_Selection.Ok_Button1 := Get_Ok_Button (Open_File_Selection);
      Set_Relief (Open_File_Selection.Ok_Button1, Relief_Normal);
      Set_Flags (Open_File_Selection.Ok_Button1, Can_Default);

      --     Button_Callback.Connect
      --       (Open_File_Selection.Ok_Button1, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Open_Filesel_Ok_Button_Clicked'Access));

      Open_File_Selection_Callback.Object_Connect
        (Open_File_Selection.Ok_Button1,
         "clicked",
         Open_File_Selection_Callback.To_Marshaller
            (On_Open_Filesel_Ok_Button_Clicked'Access),
         Open_File_Selection);

      Open_File_Selection.Cancel_Button1 :=
         Get_Cancel_Button (Open_File_Selection);
      Set_Relief (Open_File_Selection.Cancel_Button1, Relief_Normal);
      Set_Flags (Open_File_Selection.Cancel_Button1, Can_Default);

      --     Button_Callback.Connect
      --       (Open_File_Selection.Cancel_Button1, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Open_Filesel_Cancel_Button_Clicked'Access));

      Dialog_Callback.Object_Connect
        (Open_File_Selection.Cancel_Button1,
         "clicked",
         Dialog_Callback.To_Marshaller
            (On_Open_Filesel_Cancel_Button_Clicked'Access),
         Open_File_Selection);

   end Initialize;

end Open_File_Selection_Pkg;
