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
----------------------------------------------------------------------
with System;          use System;
with Glib;            use Glib;
with Gdk.Event;       use Gdk.Event;
with Gdk.Types;       use Gdk.Types;
with Gtk.Accel_Group; use Gtk.Accel_Group;
with Gtk.Object;      use Gtk.Object;
with Gtk.Enums;       use Gtk.Enums;
with Gtk.Style;       use Gtk.Style;
with Gtk.Widget;      use Gtk.Widget;

with Mast.Scheduling_Servers;           use Mast.Scheduling_Servers;
with Mast_Editor.Scheduling_Servers;    use Mast_Editor.Scheduling_Servers;
with Mast.Operations;                   use Mast.Operations;
with Mast_Editor.Operations;            use Mast_Editor.Operations;
with Var_Strings;                       use Var_Strings;
with Gtk.Handlers;                      use Gtk.Handlers;
with Sched_Server_Dialog_Pkg;           use Sched_Server_Dialog_Pkg;
with Sched_Server_Dialog_Pkg.Callbacks; use Sched_Server_Dialog_Pkg.Callbacks;
with Sop_Dialog_Pkg;                    use Sop_Dialog_Pkg;
with Sop_Dialog_Pkg.Callbacks;          use Sop_Dialog_Pkg.Callbacks;

with Add_New_Op_To_Driver_Dialog_Pkg;               use 
  Add_New_Op_To_Driver_Dialog_Pkg;
with Add_New_Op_To_Driver_Dialog_Pkg.Callbacks;
use Add_New_Op_To_Driver_Dialog_Pkg.Callbacks;
with Add_New_Server_To_Driver_Dialog_Pkg;
use Add_New_Server_To_Driver_Dialog_Pkg;
with Add_New_Server_To_Driver_Dialog_Pkg.Callbacks;
use Add_New_Server_To_Driver_Dialog_Pkg.Callbacks;

with Editor_Error_Window_Pkg; use Editor_Error_Window_Pkg;
with Gtkada.Canvas;           use Gtkada.Canvas;
with Editor_Actions;          use Editor_Actions;
with Ada.Characters.Handling;
with List_Exceptions;         use List_Exceptions;
with Gtk.Toggle_Button;       use Gtk.Toggle_Button;
with Gtk.GEntry;              use Gtk.GEntry;
with Mast.IO;                 use Mast.IO;
with Gtk.List;                use Gtk.List;
with Gtk.Check_Button;        use Gtk.Check_Button;
with Gtk.Adjustment;

package body Driver_Dialog_Pkg.Callbacks is

   use Gtk.Arguments;

   -------------------------------------------------
   -- Types and packages used to handle dialogs info
   -------------------------------------------------

   type Me_Scheduling_Server_And_Dialog2 is record
      It   : ME_Scheduling_Server_Ref;
      Dia  : Gtk_Dialog;
      Dia2 : Gtk_Dialog;
   end record;

   type Me_Scheduling_Server_And_Dialog2_Ref is access all
     Me_Scheduling_Server_And_Dialog2;

   package Me_Scheduling_Server_And_Dialog2_Cb is new
     Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => Me_Scheduling_Server_And_Dialog2_Ref);

   type Me_Operation_And_Dialog2 is record
      It   : ME_Operation_Ref;
      Dia  : Gtk_Dialog;
      Dia2 : Gtk_Dialog;
   end record;

   type Me_Operation_And_Dialog2_Ref is access all Me_Operation_And_Dialog2;

   package Me_Operation_And_Dialog2_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => Me_Operation_And_Dialog2_Ref);

   type Operation_And_Dialog is record
      It  : Operation_Ref;
      Dia : Gtk_Dialog;
   end record;

   type Operation_And_Dialog_Ref is access all Operation_And_Dialog;

   package Operation_And_Dialog_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => Operation_And_Dialog_Ref);

   -------------------------------------
   -- On_Driver_Cancel_Button_Clicked --
   -------------------------------------

   procedure On_Driver_Cancel_Button_Clicked
     (Object : access Gtk_Dialog_Record'Class)
   is
   begin
      Destroy (Object);
   end On_Driver_Cancel_Button_Clicked;

   -------------------------------------------
   -- Add Operation To Driver Dialog Combos --
   -------------------------------------------
   procedure Add_Operation_To_Driver_Dialog_Combos
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Me_Operation_And_Dialog2_Ref)
   is

      Item                        : ME_Operation_Ref                   :=
        Data.It;
      Driver_Dialog               : Driver_Dialog_Access               :=
         Driver_Dialog_Access (Data.Dia);
      Add_New_Op_To_Driver_Dialog : Add_New_Op_To_Driver_Dialog_Access :=
         Add_New_Op_To_Driver_Dialog_Access (Data.Dia2);

      Op : Gtk_List_Item;
   begin
      Gtk_New (Op, Name_Image (Mast_Editor.Operations.Name (Item)));
      Show (Op);
      Add (Get_List (Driver_Dialog.Packet_Send_Op_Combo), Op);
      Gtk_New (Op, Name_Image (Mast_Editor.Operations.Name (Item)));
      Show (Op);
      Add (Get_List (Driver_Dialog.Packet_Rece_Op_Combo), Op);
      Gtk_New (Op, Name_Image (Mast_Editor.Operations.Name (Item)));
      Show (Op);
      Add (Get_List (Driver_Dialog.Char_Send_Op_Combo), Op);
      Gtk_New (Op, Name_Image (Mast_Editor.Operations.Name (Item)));
      Show (Op);
      Add (Get_List (Driver_Dialog.Char_Rece_Op_Combo), Op);
      Gtk_New (Op, Name_Image (Mast_Editor.Operations.Name (Item)));
      Show (Op);
      Add (Get_List (Driver_Dialog.Packet_Isr_Op_Combo), Op);
      Gtk_New (Op, Name_Image (Mast_Editor.Operations.Name (Item)));
      Show (Op);
      Add (Get_List (Driver_Dialog.Token_Check_Op_Combo), Op);
      Gtk_New (Op, Name_Image (Mast_Editor.Operations.Name (Item)));
      Show (Op);
      Add (Get_List (Driver_Dialog.Token_Manage_Op_Combo), Op);
      Gtk_New (Op, Name_Image (Mast_Editor.Operations.Name (Item)));
      Show (Op);
      Add (Get_List (Driver_Dialog.Packet_Discard_Op_Combo), Op);
      Gtk_New (Op, Name_Image (Mast_Editor.Operations.Name (Item)));
      Show (Op);
      Add (Get_List (Driver_Dialog.Token_Retransmission_Op_Combo), Op);
      Gtk_New (Op, Name_Image (Mast_Editor.Operations.Name (Item)));
      Show (Op);
      Add (Get_List (Driver_Dialog.Packet_Retransmission_Op_Combo), Op);

      if Visible_Is_Set (Add_New_Op_To_Driver_Dialog.Table1) then
         if Get_Active
              (Gtk.Toggle_Button.Gtk_Toggle_Button (
              Add_New_Op_To_Driver_Dialog.Packet_Send_Op_Button))
         then
            Set_Text
              (Get_Entry (Driver_Dialog.Packet_Send_Op_Combo),
               Name_Image (Mast_Editor.Operations.Name (Item)));
         end if;
         if Get_Active
              (Gtk.Toggle_Button.Gtk_Toggle_Button (
              Add_New_Op_To_Driver_Dialog.Packet_Receive_Op_Button))
         then
            Set_Text
              (Get_Entry (Driver_Dialog.Packet_Rece_Op_Combo),
               Name_Image (Mast_Editor.Operations.Name (Item)));
         end if;
      end if;
      if Visible_Is_Set (Add_New_Op_To_Driver_Dialog.Table2) then
         if Get_Active
              (Gtk.Toggle_Button.Gtk_Toggle_Button (
              Add_New_Op_To_Driver_Dialog.Char_Send_Op_Button))
         then
            Set_Text
              (Get_Entry (Driver_Dialog.Char_Send_Op_Combo),
               Name_Image (Mast_Editor.Operations.Name (Item)));
         end if;
         if Get_Active
              (Gtk.Toggle_Button.Gtk_Toggle_Button (
              Add_New_Op_To_Driver_Dialog.Char_Receive_Op_Button))
         then
            Set_Text
              (Get_Entry (Driver_Dialog.Char_Rece_Op_Combo),
               Name_Image (Mast_Editor.Operations.Name (Item)));
         end if;
      end if;
      if Visible_Is_Set (Add_New_Op_To_Driver_Dialog.Table3) then
         if Get_Active
              (Gtk.Toggle_Button.Gtk_Toggle_Button (
              Add_New_Op_To_Driver_Dialog.Packet_Isr_Op_Button))
         then
            Set_Text
              (Get_Entry (Driver_Dialog.Packet_Isr_Op_Combo),
               Name_Image (Mast_Editor.Operations.Name (Item)));
         end if;
         if Get_Active
              (Gtk.Toggle_Button.Gtk_Toggle_Button (
              Add_New_Op_To_Driver_Dialog.Token_Chk_Op_Button))
         then
            Set_Text
              (Get_Entry (Driver_Dialog.Token_Check_Op_Combo),
               Name_Image (Mast_Editor.Operations.Name (Item)));
         end if;
         if Get_Active
              (Gtk.Toggle_Button.Gtk_Toggle_Button (
              Add_New_Op_To_Driver_Dialog.Token_Man_Op_Button))
         then
            Set_Text
              (Get_Entry (Driver_Dialog.Token_Manage_Op_Combo),
               Name_Image (Mast_Editor.Operations.Name (Item)));
         end if;
         if Get_Active
              (Gtk.Toggle_Button.Gtk_Toggle_Button (
              Add_New_Op_To_Driver_Dialog.Packet_Dis_Op_Button))
         then
            Set_Text
              (Get_Entry (Driver_Dialog.Packet_Discard_Op_Combo),
               Name_Image (Mast_Editor.Operations.Name (Item)));
         end if;
         if Get_Active
              (Gtk.Toggle_Button.Gtk_Toggle_Button (
              Add_New_Op_To_Driver_Dialog.Token_Rtx_Op_Button))
         then
            Set_Text
              (Get_Entry (Driver_Dialog.Token_Retransmission_Op_Combo),
               Name_Image (Mast_Editor.Operations.Name (Item)));
         end if;
         if Get_Active
              (Gtk.Toggle_Button.Gtk_Toggle_Button (
              Add_New_Op_To_Driver_Dialog.Packet_Rtx_Op_Button))
         then
            Set_Text
              (Get_Entry (Driver_Dialog.Packet_Retransmission_Op_Combo),
               Name_Image (Mast_Editor.Operations.Name (Item)));
         end if;
      end if;

      Destroy (Add_New_Op_To_Driver_Dialog);
   end Add_Operation_To_Driver_Dialog_Combos;

   ------------------------------------------
   -- Show Add New Op To Driver Dialog --
   ------------------------------------------
   procedure Show_Add_New_Op_To_Driver_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Me_Operation_And_Dialog2_Ref)
   is
      Item          : ME_Operation_Ref     := Data.It;
      Driver_Dialog : Driver_Dialog_Access := Driver_Dialog_Access (Data.Dia);
      Sop_Dialog    : Sop_Dialog_Access    := Sop_Dialog_Access (Data.Dia2);

      Add_New_Op_To_Driver_Dialog : Add_New_Op_To_Driver_Dialog_Access;
      Data2                       : Me_Operation_And_Dialog2_Ref :=
         new Me_Operation_And_Dialog2;

   begin
      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (Sop_Dialog.Op_Name_Entry)))
      then

         Write_Parameters (Item, Gtk_Dialog (Sop_Dialog));

         Mast.Operations.Lists.Add (Item.Op, The_System.Operations);
         Mast_Editor.Operations.Lists.Add (Item, Editor_System.Me_Operations);
         Set_Screen_Size (Item, Item.W, Item.H);

         Put
           (Operation_Canvas,
            Item,
            Gint (Gtk.Adjustment.Get_Value (Get_Hadj (Operation_Canvas))),
            Gint (Gtk.Adjustment.Get_Value (Get_Vadj (Operation_Canvas))));

         Refresh_Canvas (Operation_Canvas);
         Show_Item (Operation_Canvas, Item);
         Destroy (Sop_Dialog);

         Gtk_New (Add_New_Op_To_Driver_Dialog);
         Show_All (Add_New_Op_To_Driver_Dialog);

         if (Get_Text (Get_Entry (Driver_Dialog.Driver_Type_Combo)) =
             "Packet Driver")
         then
            Hide (Add_New_Op_To_Driver_Dialog.Table2);
            Hide (Add_New_Op_To_Driver_Dialog.Table3);
         elsif (Get_Text (Get_Entry (Driver_Dialog.Driver_Type_Combo)) =
                "Character Packet Driver")
         then
            Hide (Add_New_Op_To_Driver_Dialog.Table3);
         elsif (Get_Text (Get_Entry (Driver_Dialog.Driver_Type_Combo)) =
                "RT-EP Packet Driver")
         then
            Hide (Add_New_Op_To_Driver_Dialog.Table2);
         end if;

         Data2.It   := Item;
         Data2.Dia  := Gtk_Dialog (Driver_Dialog);
         Data2.Dia2 := Gtk_Dialog (Add_New_Op_To_Driver_Dialog);

         Me_Operation_And_Dialog2_Cb.Connect
           (Add_New_Op_To_Driver_Dialog.Ok_Button,
            "clicked",
            Me_Operation_And_Dialog2_Cb.To_Marshaller
               (Add_Operation_To_Driver_Dialog_Combos'Access),
            Data2);

      else
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Identifier not Valid!!!");
         Show_All (Editor_Error_Window);
      end if;
   exception
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, " Invalid Value!!!");
         Show_All (Editor_Error_Window);
         Destroy (Sop_Dialog);
      when Already_Exists =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " The operation already exists!!!");
         Show_All (Editor_Error_Window);
         Destroy (Sop_Dialog);
   end Show_Add_New_Op_To_Driver_Dialog;

   -------------------------------------
   -- On_New_Operation_Button_Clicked --
   -------------------------------------

   procedure On_New_Operation_Button_Clicked
     (Object : access Driver_Dialog_Record'Class)
   is
      Item : ME_Operation_Ref := new ME_Simple_Operation;
      Oper : Operation_Ref    := new Simple_Operation;

      Driver_Dialog : Driver_Dialog_Access := Driver_Dialog_Access (Object);
      Sop_Dialog    : Sop_Dialog_Access;
      --Data : Operation_And_Dialog_Ref := new Operation_And_Dialog;
      Me_Data : Me_Operation_And_Dialog2_Ref := new Me_Operation_And_Dialog2;

   begin
      Item.W           := Op_Width;
      Item.H           := Op_Height;
      Item.Canvas_Name := To_Var_String ("Operation_Canvas");
      Item.Color_Name  := Sop_Color;
      Item.Op          := Oper;

      Gtk_New (Sop_Dialog);
      Set_Modal (Sop_Dialog, True);

      Set_Sensitive (Sop_Dialog.Add_Res_Button, False);
      Set_Sensitive (Sop_Dialog.Remove_Res_Button, False);

      Read_Parameters (Item, Gtk_Dialog (Sop_Dialog));

      --Data.It := Oper;
      --Data.Dia := Gtk_Dialog(Sop_Dialog);

      Me_Data.It   := Item;
      Me_Data.Dia  := Gtk_Dialog (Driver_Dialog);
      Me_Data.Dia2 := Gtk_Dialog (Sop_Dialog);

      -- No habilitamos los botones para estos cbs asi que no es necesario
      --conectarlos
      --        Operation_And_Dialog_Cb.Connect
      --          (Sop_Dialog.Add_Res_Button, "clicked",
      --           Operation_And_Dialog_Cb.To_Marshaller (Add_Shared'Access),
      --Data);

      --        Operation_And_Dialog_Cb.Connect
      --          (Sop_Dialog.Remove_Res_Button, "clicked",
      --           Operation_And_Dialog_Cb.To_Marshaller
      --(Remove_Shared'Access), Data);

      Me_Operation_And_Dialog2_Cb.Connect
        (Sop_Dialog.Ok_Button,
         "clicked",
         Me_Operation_And_Dialog2_Cb.To_Marshaller
            (Show_Add_New_Op_To_Driver_Dialog'Access),
         Me_Data);

   end On_New_Operation_Button_Clicked;

   ----------------------------------------
   -- Add Server To Driver Dialog Combos --
   ----------------------------------------
   procedure Add_Server_To_Driver_Dialog_Combos
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Me_Scheduling_Server_And_Dialog2_Ref)
   is

      Item                            : ME_Scheduling_Server_Ref := Data.It;
      Driver_Dialog                   : Driver_Dialog_Access     :=
         Driver_Dialog_Access (Data.Dia);
      Add_New_Server_To_Driver_Dialog : Add_New_Server_To_Driver_Dialog_Access
         :=
         Add_New_Server_To_Driver_Dialog_Access (Data.Dia2);

      Serv : Gtk_List_Item;
   begin
      Gtk_New
        (Serv,
         Name_Image (Mast_Editor.Scheduling_Servers.Name (Item)));
      Show (Serv);
      Add (Get_List (Driver_Dialog.Packet_Server_Combo), Serv);
      Gtk_New
        (Serv,
         Name_Image (Mast_Editor.Scheduling_Servers.Name (Item)));
      Show (Serv);
      Add (Get_List (Driver_Dialog.Char_Server_Combo), Serv);
      Gtk_New
        (Serv,
         Name_Image (Mast_Editor.Scheduling_Servers.Name (Item)));
      Show (Serv);
      Add (Get_List (Driver_Dialog.Packet_Interrupt_Server_Combo), Serv);
      if Visible_Is_Set
            (Add_New_Server_To_Driver_Dialog.Packet_Server_Button)
        and then Get_Active
                    (Gtk.Toggle_Button.Gtk_Toggle_Button (
           Add_New_Server_To_Driver_Dialog.Packet_Server_Button))
      then
         Set_Text
           (Get_Entry (Driver_Dialog.Packet_Server_Combo),
            Name_Image (Mast_Editor.Scheduling_Servers.Name (Item)));
      end if;
      if Visible_Is_Set
            (Add_New_Server_To_Driver_Dialog.Character_Server_Button)
        and then Get_Active
                    (Gtk.Toggle_Button.Gtk_Toggle_Button (
           Add_New_Server_To_Driver_Dialog.Character_Server_Button))
      then
         Set_Text
           (Get_Entry (Driver_Dialog.Char_Server_Combo),
            Name_Image (Mast_Editor.Scheduling_Servers.Name (Item)));
      end if;
      if Visible_Is_Set
            (Add_New_Server_To_Driver_Dialog.Packet_Int_Server_Button)
        and then Get_Active
                    (Gtk.Toggle_Button.Gtk_Toggle_Button (
           Add_New_Server_To_Driver_Dialog.Packet_Int_Server_Button))
      then
         Set_Text
           (Get_Entry (Driver_Dialog.Packet_Interrupt_Server_Combo),
            Name_Image (Mast_Editor.Scheduling_Servers.Name (Item)));
      end if;
      Destroy (Add_New_Server_To_Driver_Dialog);
   end Add_Server_To_Driver_Dialog_Combos;

   ------------------------------------------
   -- Show Add New Server To Driver Dialog --
   ------------------------------------------
   procedure Show_Add_New_Server_To_Driver_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Me_Scheduling_Server_And_Dialog2_Ref)
   is
      Item                : ME_Scheduling_Server_Ref   := Data.It;
      Driver_Dialog       : Driver_Dialog_Access       :=
         Driver_Dialog_Access (Data.Dia);
      Sched_Server_Dialog : Sched_Server_Dialog_Access :=
         Sched_Server_Dialog_Access (Data.Dia2);

      Add_New_Server_To_Driver_Dialog : Add_New_Server_To_Driver_Dialog_Access;
      Data2                           : Me_Scheduling_Server_And_Dialog2_Ref
         :=
         new Me_Scheduling_Server_And_Dialog2;

   begin
      if (Get_Text (Get_Entry (Sched_Server_Dialog.Sched_Combo)) =
          "(NONE)") or
         (Get_Text (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo)) =
          "(NONE)")
      then
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Scheduler and Policy Type can't be set to (NONE)!");
         Show_All (Editor_Error_Window);
      else
         if Id_Name_Is_Valid
              (Ada.Characters.Handling.To_Lower
                  (Get_Text (Sched_Server_Dialog.Server_Name_Entry)))
         then

            Write_Parameters (Item, Gtk_Dialog (Sched_Server_Dialog));

            Mast.Scheduling_Servers.Lists.Add
              (Item.Ser,
               The_System.Scheduling_Servers);
            Mast_Editor.Scheduling_Servers.Lists.Add
              (Item,
               Editor_System.Me_Scheduling_Servers);
            Set_Screen_Size (Item, Item.W, Item.H);

            Put
              (Sched_Server_Canvas,
               Item,
               Gint (Gtk.Adjustment.Get_Value
                        (Get_Hadj (Sched_Server_Canvas))),
               Gint (Gtk.Adjustment.Get_Value
                        (Get_Vadj (Sched_Server_Canvas))));

            Refresh_Canvas (Sched_Server_Canvas);
            Show_Item (Sched_Server_Canvas, Item);
            Draw_Scheduler_In_Server_Canvas (Item);
            Destroy (Sched_Server_Dialog);

            Gtk_New (Add_New_Server_To_Driver_Dialog);
            Show_All (Add_New_Server_To_Driver_Dialog);

            if (Get_Text (Get_Entry (Driver_Dialog.Driver_Type_Combo)) =
                "Packet Driver")
            then
               Hide (Add_New_Server_To_Driver_Dialog.Character_Server_Button);
               Hide
                 (Add_New_Server_To_Driver_Dialog.Packet_Int_Server_Button);
            elsif (Get_Text (Get_Entry
                                (Driver_Dialog.Driver_Type_Combo)) =
                   "Character Packet Driver")
            then
               Hide
                 (Add_New_Server_To_Driver_Dialog.Packet_Int_Server_Button);
            elsif (Get_Text (Get_Entry
                                (Driver_Dialog.Driver_Type_Combo)) =
                   "RT-EP Packet Driver")
            then
               Hide (Add_New_Server_To_Driver_Dialog.Character_Server_Button);
            end if;

            Data2.It   := Item;
            Data2.Dia  := Gtk_Dialog (Driver_Dialog);
            Data2.Dia2 := Gtk_Dialog (Add_New_Server_To_Driver_Dialog);

            Me_Scheduling_Server_And_Dialog2_Cb.Connect
              (Add_New_Server_To_Driver_Dialog.Ok_Button,
               "clicked",
               Me_Scheduling_Server_And_Dialog2_Cb.To_Marshaller
                  (Add_Server_To_Driver_Dialog_Combos'Access),
               Data2);

         else
            Gtk_New (Editor_Error_Window);
            Set_Text (Editor_Error_Window.Label, "Identifier not Valid!!!");
            Show_All (Editor_Error_Window);
         end if;
      end if;
   exception
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Invalid Value !!!");
         Show_All (Editor_Error_Window);
         Destroy (Sched_Server_Dialog);
      when Already_Exists =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "The Server Already Exists !!!");
         Show_All (Editor_Error_Window);
         Destroy (Sched_Server_Dialog);
   end Show_Add_New_Server_To_Driver_Dialog;

   ----------------------------------
   -- On_New_Server_Button_Clicked --
   ----------------------------------

   procedure On_New_Server_Button_Clicked
     (Object : access Driver_Dialog_Record'Class)
   is
      Item     : ME_Scheduling_Server_Ref := new ME_Server;
      Serv_Ref : Scheduling_Server_Ref    := new Scheduling_Server;

      Driver_Dialog       : Driver_Dialog_Access                 :=
         Driver_Dialog_Access (Object);
      Sched_Server_Dialog : Sched_Server_Dialog_Access;
      Me_Data             : Me_Scheduling_Server_And_Dialog2_Ref :=
         new Me_Scheduling_Server_And_Dialog2;

   begin
      Item.W           := Ser_Width;
      Item.H           := Ser_Height;
      Item.Canvas_Name := To_Var_String ("Sched_Server_Canvas");
      Item.Color_Name  := Ser_Color;
      Item.Ser         := Serv_Ref;

      Gtk_New (Sched_Server_Dialog);
      Set_Modal (Sched_Server_Dialog, True);
      Read_Parameters (Item, Gtk_Dialog (Sched_Server_Dialog));

      Me_Data.It   := Item;
      Me_Data.Dia  := Gtk_Dialog (Driver_Dialog);
      Me_Data.Dia2 := Gtk_Dialog (Sched_Server_Dialog);

      Me_Scheduling_Server_And_Dialog2_Cb.Connect
        (Sched_Server_Dialog.Server_Ok_Button,
         "clicked",
         Me_Scheduling_Server_And_Dialog2_Cb.To_Marshaller
            (Show_Add_New_Server_To_Driver_Dialog'Access),
         Me_Data);

   end On_New_Server_Button_Clicked;

   ----------------------------------
   -- On_Driver_Type_Entry_Changed --
   ----------------------------------

   procedure On_Driver_Type_Entry_Changed
     (Object : access Driver_Dialog_Record'Class)
   is
      Driver_Type : String :=
         String (Get_Text (Get_Entry (Object.Driver_Type_Combo)));
   begin
      if Driver_Type = "Packet Driver" then
         Show (Object.Packet_Server_Table);
         Hide (Object.Character_Server_Table);
         Hide (Object.Rtep_Table);
      elsif Driver_Type = "Character Packet Driver" then
         Show (Object.Packet_Server_Table);
         Show (Object.Character_Server_Table);
         Hide (Object.Rtep_Table);
      elsif Driver_Type = "RT-EP Packet Driver" then
         Show (Object.Packet_Server_Table);
         Hide (Object.Character_Server_Table);
         Show (Object.Rtep_Table);
      else
         null;
      end if;
   end On_Driver_Type_Entry_Changed;

end Driver_Dialog_Pkg.Callbacks;
