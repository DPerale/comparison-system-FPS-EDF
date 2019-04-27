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
with Glib;                               use Glib;
with Gtk;                                use Gtk;
with Gdk.Types;                          use Gdk.Types;
with Gtk.Widget;                         use Gtk.Widget;
with Gtk.Enums;                          use Gtk.Enums;
with Gtkada.Handlers;                    use Gtkada.Handlers;
with Callbacks_Mast_Editor;              use Callbacks_Mast_Editor;
with Add_Operation_Dialog_Pkg.Callbacks;
use Add_Operation_Dialog_Pkg.Callbacks;
with Mast;                               use Mast;
with Mast.IO;                            use Mast.IO;
with Mast.Operations;                    use Mast.Operations;
with Var_Strings;                        use Var_Strings;
with Editor_Actions;                     use Editor_Actions;

package body Add_Operation_Dialog_Pkg is

   procedure Gtk_New
     (Add_Operation_Dialog : out Add_Operation_Dialog_Access)
   is
   begin
      Add_Operation_Dialog := new Add_Operation_Dialog_Record;
      Add_Operation_Dialog_Pkg.Initialize (Add_Operation_Dialog);
   end Gtk_New;

   procedure Initialize
     (Add_Operation_Dialog : access Add_Operation_Dialog_Record'Class)
   is
      pragma Suppress (All_Checks);
      Add_Op_Combo_Items : String_List.Glist;

      Op_List  : Mast.Operations.Lists.List := The_System.Operations;
      Op_Ref   : Mast.Operations.Operation_Ref;
      Op_Index : Mast.Operations.Lists.Index;
      Op_Name  : Var_Strings.Var_String;

   begin
      -- Recorremos la lista de Ops del sistema y mostramos los valores en la
      --lista de Ops

      Mast.Operations.Lists.Rewind (Op_List, Op_Index);
      for I in 1 .. Mast.Operations.Lists.Size (Op_List) loop
         Mast.Operations.Lists.Get_Next_Item (Op_Ref, Op_List, Op_Index);
         Op_Name := Mast.Operations.Name (Op_Ref);
         String_List.Append (Add_Op_Combo_Items, Name_Image (Op_Name));
      end loop;

      Gtk.Dialog.Initialize (Add_Operation_Dialog);
      Set_Title (Add_Operation_Dialog, "Add Operation");
      Set_Policy (Add_Operation_Dialog, False, True, True);
      Set_Position (Add_Operation_Dialog, Win_Pos_Center);
      Set_Modal (Add_Operation_Dialog, True);
      Set_Default_Size (Add_Operation_Dialog, 400, 150);

      Add_Operation_Dialog.Vbox10 := Get_Vbox (Add_Operation_Dialog);
      Set_Homogeneous (Add_Operation_Dialog.Vbox10, False);
      Set_Spacing (Add_Operation_Dialog.Vbox10, 0);

      Add_Operation_Dialog.Hbox37 := Get_Action_Area (Add_Operation_Dialog);
      Set_Border_Width (Add_Operation_Dialog.Hbox37, 10);
      Set_Homogeneous (Add_Operation_Dialog.Hbox37, False);
      Set_Spacing (Add_Operation_Dialog.Hbox37, 10);

      Gtk_New_Hbox (Add_Operation_Dialog.Hbox38, True, 0);
      Pack_Start
        (Add_Operation_Dialog.Hbox37,
         Add_Operation_Dialog.Hbox38,
         True,
         True,
         0);

      Gtk_New (Add_Operation_Dialog.Add_Op_Button, "Add");
      Set_Relief (Add_Operation_Dialog.Add_Op_Button, Relief_Normal);
      Pack_Start
        (Add_Operation_Dialog.Hbox38,
         Add_Operation_Dialog.Add_Op_Button,
         False,
         True,
         50);

      Gtk_New (Add_Operation_Dialog.Add_Op_Cancel_Button, "Cancel");
      Set_Relief (Add_Operation_Dialog.Add_Op_Cancel_Button, Relief_Normal);
      Pack_Start
        (Add_Operation_Dialog.Hbox38,
         Add_Operation_Dialog.Add_Op_Cancel_Button,
         False,
         True,
         50);
      --     Button_Callback.Connect
      --       (Add_Operation_Dialog.Add_Op_Cancel_Button, "clicked",
      --        Button_Callback.To_Marshaller
      --(On_Add_Op_Cancel_Button_Clicked'Access));

      Dialog_Callback.Object_Connect
        (Add_Operation_Dialog.Add_Op_Cancel_Button,
         "clicked",
         Dialog_Callback.To_Marshaller
            (On_Add_Op_Cancel_Button_Clicked'Access),
         Add_Operation_Dialog);

      Gtk_New (Add_Operation_Dialog.Table1, 1, 2, True);
      Set_Border_Width (Add_Operation_Dialog.Table1, 15);
      Set_Row_Spacings (Add_Operation_Dialog.Table1, 5);
      Set_Col_Spacings (Add_Operation_Dialog.Table1, 5);
      Pack_Start
        (Add_Operation_Dialog.Vbox10,
         Add_Operation_Dialog.Table1,
         True,
         False,
         0);

      Gtk_New (Add_Operation_Dialog.Add_Op_Combo);
      Set_Case_Sensitive (Add_Operation_Dialog.Add_Op_Combo, False);
      Set_Use_Arrows (Add_Operation_Dialog.Add_Op_Combo, True);
      Set_Use_Arrows_Always (Add_Operation_Dialog.Add_Op_Combo, False);
      String_List.Append (Add_Op_Combo_Items, "");
      Combo.Set_Popdown_Strings
        (Add_Operation_Dialog.Add_Op_Combo,
         Add_Op_Combo_Items);
      Free_String_List (Add_Op_Combo_Items);
      Attach
        (Add_Operation_Dialog.Table1,
         Add_Operation_Dialog.Add_Op_Combo,
         1,
         2,
         0,
         1,
         Expand or Fill,
         0,
         0,
         0);

      Add_Operation_Dialog.Add_Op_Entry :=
         Get_Entry (Add_Operation_Dialog.Add_Op_Combo);
      Set_Editable (Add_Operation_Dialog.Add_Op_Entry, False);
      Set_Max_Length (Add_Operation_Dialog.Add_Op_Entry, 0);
      Set_Text (Add_Operation_Dialog.Add_Op_Entry, "");
      Set_Visibility (Add_Operation_Dialog.Add_Op_Entry, True);

      Gtk_New (Add_Operation_Dialog.Label153, "System Operations List");
      Set_Alignment (Add_Operation_Dialog.Label153, 0.95, 0.5);
      Set_Padding (Add_Operation_Dialog.Label153, 0, 0);
      Set_Justify (Add_Operation_Dialog.Label153, Justify_Center);
      Set_Line_Wrap (Add_Operation_Dialog.Label153, False);
      Attach
        (Add_Operation_Dialog.Table1,
         Add_Operation_Dialog.Label153,
         0,
         1,
         0,
         1,
         Fill,
         0,
         0,
         0);

   end Initialize;

end Add_Operation_Dialog_Pkg;
