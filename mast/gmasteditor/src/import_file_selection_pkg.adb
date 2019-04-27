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
with Glib;                                use Glib;
with Gtk;                                 use Gtk;
with Gdk.Types;                           use Gdk.Types;
with Gtk.Widget;                          use Gtk.Widget;
with Gtk.Enums;                           use Gtk.Enums;
with Gtkada.Handlers;                     use Gtkada.Handlers;
with Callbacks_Mast_Editor;               use Callbacks_Mast_Editor;
with Mast_Editor_Intl;                    use Mast_Editor_Intl;
with Import_File_Selection_Pkg.Callbacks;
use Import_File_Selection_Pkg.Callbacks;

package body Import_File_Selection_Pkg is

   procedure Gtk_New
     (Import_File_Selection : out Import_File_Selection_Access)
   is
   begin
      Import_File_Selection := new Import_File_Selection_Record;
      Import_File_Selection_Pkg.Initialize (Import_File_Selection);
   end Gtk_New;

   procedure Initialize
     (Import_File_Selection : access Import_File_Selection_Record'Class)
   is
      pragma Suppress (All_Checks);
   begin
      Gtk.File_Selection.Initialize
        (Import_File_Selection,
         -"Import Components From File ...");
      Set_Show_File_Op_Buttons (Import_File_Selection, True);
      Set_Border_Width (Import_File_Selection, 10);
      Set_Title (Import_File_Selection, -"Import Components From File ...");
      Set_Position (Import_File_Selection, Win_Pos_None);
      Set_Modal (Import_File_Selection, True);
      Return_Callback.Connect
        (Import_File_Selection,
         "delete_event",
         On_Import_Filesel_Delete_Event'Access,
         False);

      --     Button_Callback.Connect
      --       (Get_Ok_Button (Import_File_Selection), "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Import_Filesel_Ok_Button_Clicked'Access));

      Import_File_Selection_Callback.Object_Connect
        (Get_Ok_Button (Import_File_Selection),
         "clicked",
         Import_File_Selection_Callback.To_Marshaller
            (On_Import_Filesel_Ok_Button_Clicked'Access),
         Import_File_Selection);

      --     Button_Callback.Connect
      --       (Get_Cancel_Button(Import_File_Selection), "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Import_Filesel_Cancel_Button_Clicked'Access));

      Dialog_Callback.Object_Connect
        (Get_Cancel_Button (Import_File_Selection),
         "clicked",
         Dialog_Callback.To_Marshaller
            (On_Import_Filesel_Cancel_Button_Clicked'Access),
         Import_File_Selection);

   end Initialize;

end Import_File_Selection_Pkg;
