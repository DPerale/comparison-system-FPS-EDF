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

with Glib;                            use Glib;
with Gtk;                             use Gtk;
with Gdk.Types;                       use Gdk.Types;
with Gtk.Widget;                      use Gtk.Widget;
with Gtk.Enums;                       use Gtk.Enums;
with Gtkada.Handlers;                 use Gtkada.Handlers;
with Callbacks_Mast_Editor;           use Callbacks_Mast_Editor;
with Add_Shared_Dialog_Pkg.Callbacks; use Add_Shared_Dialog_Pkg.Callbacks;

with Mast;                  use Mast;
with Mast.IO;               use Mast.IO;
with Mast.Shared_Resources; use Mast.Shared_Resources;
with Var_Strings;           use Var_Strings;
with Editor_Actions;        use Editor_Actions;

package body Add_Shared_Dialog_Pkg is

   procedure Gtk_New (Add_Shared_Dialog : out Add_Shared_Dialog_Access) is
   begin
      Add_Shared_Dialog := new Add_Shared_Dialog_Record;
      Add_Shared_Dialog_Pkg.Initialize (Add_Shared_Dialog);
   end Gtk_New;

   procedure Initialize
     (Add_Shared_Dialog : access Add_Shared_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Add_Shared_Combo_Items : String_List.Glist;

      Shared_List  : Mast.Shared_Resources.Lists.List :=
        The_System.Shared_Resources;
      Shared_Ref   : Mast.Shared_Resources.Shared_Resource_Ref;
      Shared_Index : Mast.Shared_Resources.Lists.Index;
      Shared_Name  : Var_Strings.Var_String;

   begin
      -- Recorremos la lista de Res del sistema y mostramos los valores en la
      --lista de Res

      Mast.Shared_Resources.Lists.Rewind (Shared_List, Shared_Index);
      for I in 1 .. Mast.Shared_Resources.Lists.Size (Shared_List) loop
         Mast.Shared_Resources.Lists.Get_Next_Item
           (Shared_Ref,
            Shared_List,
            Shared_Index);
         Shared_Name := Mast.Shared_Resources.Name (Shared_Ref);
         String_List.Append
           (Add_Shared_Combo_Items,
            Name_Image (Shared_Name));
      end loop;

      Gtk.Dialog.Initialize (Add_Shared_Dialog);
      Set_Title (Add_Shared_Dialog, "Add Shared Resource");
      Set_Policy (Add_Shared_Dialog, False, True, True);
      Set_Position (Add_Shared_Dialog, Win_Pos_Center);
      Set_Modal (Add_Shared_Dialog, True);
      Set_Default_Size (Add_Shared_Dialog, 550, 150);

      Add_Shared_Dialog.Vbox11 := Get_Vbox (Add_Shared_Dialog);
      Set_Homogeneous (Add_Shared_Dialog.Vbox11, False);
      Set_Spacing (Add_Shared_Dialog.Vbox11, 0);

      Add_Shared_Dialog.Hbox39 := Get_Action_Area (Add_Shared_Dialog);
      Set_Border_Width (Add_Shared_Dialog.Hbox39, 10);
      Set_Homogeneous (Add_Shared_Dialog.Hbox39, False);
      Set_Spacing (Add_Shared_Dialog.Hbox39, 0);

      Gtk_New_Hbox (Add_Shared_Dialog.Hbox40, True, 15);
      Pack_Start
        (Add_Shared_Dialog.Hbox39,
         Add_Shared_Dialog.Hbox40,
         False,
         True,
         0);

      Gtk_New
        (Add_Shared_Dialog.Add_Locked_Button,
         "Add To" & ASCII.LF & "Locked Resources");
      Set_Relief (Add_Shared_Dialog.Add_Locked_Button, Relief_Normal);
      Pack_Start
        (Add_Shared_Dialog.Hbox40,
         Add_Shared_Dialog.Add_Locked_Button,
         False,
         True,
         0);

      Gtk_New
        (Add_Shared_Dialog.Add_Unlock_Button,
         "Add To" & ASCII.LF & "Unlocked Resources");
      Set_Relief (Add_Shared_Dialog.Add_Unlock_Button, Relief_Normal);
      Pack_Start
        (Add_Shared_Dialog.Hbox40,
         Add_Shared_Dialog.Add_Unlock_Button,
         False,
         True,
         0);

      Gtk_New
        (Add_Shared_Dialog.Add_Lock_Unlock_Button,
         "Add To Locked and" & ASCII.LF & "Unlocked Resources");
      Set_Relief (Add_Shared_Dialog.Add_Lock_Unlock_Button, Relief_Normal);
      Pack_Start
        (Add_Shared_Dialog.Hbox40,
         Add_Shared_Dialog.Add_Lock_Unlock_Button,
         False,
         True,
         0);

      Gtk_New (Add_Shared_Dialog.Add_Shared_Cancel_Button, "Cancel");
      Set_Relief (Add_Shared_Dialog.Add_Shared_Cancel_Button, Relief_Normal);
      Pack_Start
        (Add_Shared_Dialog.Hbox40,
         Add_Shared_Dialog.Add_Shared_Cancel_Button,
         False,
         True,
         0);
      --     Button_Callback.Connect
      --       (Add_Shared_Dialog.Add_Shared_Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Add_Shared_Cancel_Button_Clicked'Access));

      Dialog_Callback.Object_Connect
        (Add_Shared_Dialog.Add_Shared_Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller
            (On_Add_Shared_Cancel_Button_Clicked'Access),
         Add_Shared_Dialog);

      Gtk_New (Add_Shared_Dialog.Table1, 1, 2, True);
      Set_Border_Width (Add_Shared_Dialog.Table1, 15);
      Set_Row_Spacings (Add_Shared_Dialog.Table1, 5);
      Set_Col_Spacings (Add_Shared_Dialog.Table1, 5);
      Pack_Start
        (Add_Shared_Dialog.Vbox11,
         Add_Shared_Dialog.Table1,
         True,
         False,
         0);

      Gtk_New (Add_Shared_Dialog.Add_Shared_Combo);
      Set_Case_Sensitive (Add_Shared_Dialog.Add_Shared_Combo, False);
      Set_Use_Arrows (Add_Shared_Dialog.Add_Shared_Combo, True);
      Set_Use_Arrows_Always (Add_Shared_Dialog.Add_Shared_Combo, False);
      String_List.Append (Add_Shared_Combo_Items, "");
      Combo.Set_Popdown_Strings
        (Add_Shared_Dialog.Add_Shared_Combo,
         Add_Shared_Combo_Items);
      Free_String_List (Add_Shared_Combo_Items);
      Attach
        (Add_Shared_Dialog.Table1,
         Add_Shared_Dialog.Add_Shared_Combo,
         1,
         2,
         0,
         1,
         Expand or Fill,
         0,
         0,
         0);

      Add_Shared_Dialog.Add_Shared_Entry :=
         Get_Entry (Add_Shared_Dialog.Add_Shared_Combo);
      Set_Editable (Add_Shared_Dialog.Add_Shared_Entry, False);
      Set_Max_Length (Add_Shared_Dialog.Add_Shared_Entry, 0);
      Set_Text (Add_Shared_Dialog.Add_Shared_Entry, "");
      Set_Visibility (Add_Shared_Dialog.Add_Shared_Entry, True);

      Gtk_New (Add_Shared_Dialog.Label160, "System Shared Resources List");
      Set_Alignment (Add_Shared_Dialog.Label160, 0.95, 0.5);
      Set_Padding (Add_Shared_Dialog.Label160, 0, 0);
      Set_Justify (Add_Shared_Dialog.Label160, Justify_Center);
      Set_Line_Wrap (Add_Shared_Dialog.Label160, False);
      Attach
        (Add_Shared_Dialog.Table1,
         Add_Shared_Dialog.Label160,
         0,
         1,
         0,
         1,
         Fill,
         0,
         0,
         0);

   end Initialize;

end Add_Shared_Dialog_Pkg;
