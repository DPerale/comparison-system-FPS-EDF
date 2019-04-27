-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                           GMastEditor                             --
--          Graphical Editor for Modelling and Analysis              --
--                    of Real-Time Applications                      --
--                                                                   --
--                       Copyright (C) 2005-2008                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors : Pilar del Rio                                           --
--           Michael Gonzalez                                        --
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
with Ada.Text_IO;             use Ada.Text_IO;
with Ada.Characters.Handling;
with Ada.Tags;                use Ada.Tags;
with Callbacks_Mast_Editor;   use Callbacks_Mast_Editor;
with Gdk.Color;               use Gdk.Color;
with Gdk.Font;                use Gdk.Font;
with Gdk.Drawable;            use Gdk.Drawable;
with Gdk.Rectangle;           use Gdk.Rectangle;
with Glib.Object;
with Glib.Glist;              use Glib.Glist;
with Gtk.Alignment;           use Gtk.Alignment;
with Gtk.Box;                 use Gtk.Box;
with Gtk.Button;              use Gtk.Button;
with Gtk.Combo;               use Gtk.Combo;
with Gtk.Enums;               use Gtk.Enums;
with Gtk.Frame;               use Gtk.Frame;
with Gtk.GEntry;              use Gtk.GEntry;
with Gtk.Handlers;            use Gtk.Handlers;
with Gtk.Label;               use Gtk.Label;
with Gtk.List;                use Gtk.List;
with Gtk.List_Item;           use Gtk.List_Item;
with Gtk.Menu_Item;           use Gtk.Menu_Item;
with Gtk.Scrolled_Window;     use Gtk.Scrolled_Window;
with Gtk.Separator;           use Gtk.Separator;
with Gtk.Table;               use Gtk.Table;
with Gtk.Tree_Model;          use Gtk.Tree_Model;
with Gtk.Tree_Selection;      use Gtk.Tree_Selection;
with Gtk.Tree_Store;          use Gtk.Tree_Store;
with Gtk.Tree_View;           use Gtk.Tree_View;
with Gtk.Widget;              use Gtk.Widget;
with Gtkada.Canvas;           use Gtkada.Canvas;
with Pango.Font;              use Pango.Font;
with Gtkada.Dialogs;          use Gtkada.Dialogs;

with List_Exceptions;              use List_Exceptions;
with Mast;                         use Mast;
with Mast.IO;                      use Mast.IO;
with Mast.Operations;              use Mast.Operations;
with Mast.Shared_Resources;        use Mast.Shared_Resources;
with Mast.Scheduling_Parameters;   use Mast.Scheduling_Parameters;
with Aux_Window_Pkg;               use Aux_Window_Pkg;
with Editor_Error_Window_Pkg;      use Editor_Error_Window_Pkg;
with Sop_Dialog_Pkg;               use Sop_Dialog_Pkg;
with Cop_Dialog_Pkg;               use Cop_Dialog_Pkg;
with Message_Tx_Dialog_Pkg;        use Message_Tx_Dialog_Pkg;
with Add_Operation_Dialog_Pkg;     use Add_Operation_Dialog_Pkg;
with Add_Shared_Dialog_Pkg;        use Add_Shared_Dialog_Pkg;
with Item_Menu_Pkg;                use Item_Menu_Pkg;
with Editor_Actions;               use Editor_Actions;
with Mast_Editor.Shared_Resources; use Mast_Editor.Shared_Resources;
with Mast.Transactions;
with Change_Control;

package body Mast_Editor.Operations is

   package Canvas_Cb is new Gtk.Handlers.Callback (
      Interactive_Canvas_Record);

   package Button_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Operation_Ref);

   Zoom_Levels : constant array (Positive range <>) of Guint  :=
     (100,
      130,
      150);
   Font        : Pango_Font_Description;
   Font1       : Pango_Font_Description;
   Green_Gc    : Gdk.GC.Gdk_GC;

   -------------------------------------------------
   -- Types and packages used to handle dialogs info
   -------------------------------------------------
   type Double_Operation is record
      Op      : Operation_Ref;
      Temp_Op : Operation_Ref;
   end record;

   type Double_Operation_Ref is access all Double_Operation;

   package Double_Operation_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => Double_Operation_Ref);

   type Operation_And_Dialog is record
      It  : Operation_Ref;
      Dia : Gtk_Dialog;
   end record;

   type Operation_And_Dialog_Ref is access all Operation_And_Dialog;

   package Operation_And_Dialog_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => Operation_And_Dialog_Ref);

   type Operation_And_Dialog2 is record
      It   : Operation_Ref;
      Dia  : Gtk_Dialog;
      Dia2 : Gtk_Dialog;
   end record;

   type Operation_And_Dialog2_Ref is access all Operation_And_Dialog2;

   package Operation_And_Dialog2_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => Operation_And_Dialog2_Ref);

   type ME_Operation_And_Dialog is record
      It  : ME_Operation_Ref;
      Dia : Gtk_Dialog;
   end record;

   type ME_Operation_And_Dialog_Ref is access all ME_Operation_And_Dialog;

   package Me_Operation_And_Dialog_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Operation_And_Dialog_Ref);

   type ME_Operation_And_Dialog2 is record
      It   : ME_Operation_Ref;
      Dia  : Gtk_Dialog;
      Dia2 : Gtk_Dialog;
   end record;

   type ME_Operation_And_Dialog2_Ref is access all ME_Operation_And_Dialog2;

   package Me_Operation_And_Dialog2_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Operation_And_Dialog2_Ref);

   --------------
   -- Name     --
   --------------
   function Name (Item : in ME_Operation) return Var_String is
   begin
      return Name (Item.Op);
   end Name;

   --------------
   -- Name     --
   --------------
   function Name (Item_Ref : in ME_Operation_Ref) return Var_String is
   begin
      return Name (Item_Ref.Op);
   end Name;

   -----------------
   -- Print       --
   -----------------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Operation;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Ada.Text_IO.Set_Col (File, Ada.Text_IO.Count (Indentation));
      Ada.Text_IO.Put (File, "ME_Operation");
   end Print;

   -----------------
   -- Print       --
   -----------------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive)
   is
      Item_Ref : ME_Operation_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind (The_List, Iterator);
      for I in 1 .. Lists.Size (The_List) loop
         Lists.Get_Next_Item (Item_Ref, The_List, Iterator);
         Print (File, Item_Ref.all, Indentation, True);
         Ada.Text_IO.New_Line (File);
      end loop;
   end Print;

   ----------------------
   -- Write Parameters --
   ----------------------
   procedure Write_Parameters
     (Item   : access ME_Simple_Operation;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Op_Ref         : Operation_Ref     := ME_Operation_Ref (Item).Op;
      Sche_Param_Ref :
        Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Sop_Dialog     : Sop_Dialog_Access := Sop_Dialog_Access (Dialog);
   begin
      Change_Control.Changes_Made;
      Init
        (Op_Ref.all,
         Var_Strings.To_Lower
            (To_Var_String (Get_Text (Sop_Dialog.Op_Name_Entry))));
      Set_Worst_Case_Execution_Time
        (Simple_Operation (Op_Ref.all),
         Normalized_Execution_Time'Value
            (Get_Text (Sop_Dialog.Wor_Exec_Time_Entry)));
      Set_Avg_Case_Execution_Time
        (Simple_Operation (Op_Ref.all),
         Normalized_Execution_Time'Value
            (Get_Text (Sop_Dialog.Avg_Exec_Time_Entry)));
      Set_Best_Case_Execution_Time
        (Simple_Operation (Op_Ref.all),
         Normalized_Execution_Time'Value
            (Get_Text (Sop_Dialog.Bes_Exec_Time_Entry)));

      Sche_Param_Ref := Mast.Operations.New_Sched_Parameters (Op_Ref.all);
      if (Get_Text (Get_Entry (Sop_Dialog.Overrid_Param_Type_Combo)) =
          "(NONE)")
      then
         Sche_Param_Ref := null;
      elsif (Get_Text (Get_Entry (Sop_Dialog.Overrid_Param_Type_Combo)) =
             "Fixed Priority")
      then
         Sche_Param_Ref := new Overridden_FP_Parameters;
         Set_The_Priority
           (Overridden_FP_Parameters (Sche_Param_Ref.all),
            Priority'Value (Get_Text (Sop_Dialog.Overrid_Prior_Entry)));
      elsif (Get_Text (Get_Entry (Sop_Dialog.Overrid_Param_Type_Combo)) =
             "Permanent Fixed Priority")
      then
         Sche_Param_Ref := new Overridden_Permanent_FP_Parameters;
         Set_The_Priority
           (Overridden_Permanent_FP_Parameters (Sche_Param_Ref.all),
            Priority'Value (Get_Text (Sop_Dialog.Overrid_Prior_Entry)));
      end if;
      Mast.Operations.Set_New_Sched_Parameters (Op_Ref.all, Sche_Param_Ref);
   end Write_Parameters;

   ----------------------
   -- Write Parameters --
   ----------------------
   procedure Write_Parameters
     (Item   : access Me_Message_Transmission_Operation;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Op_Ref            : Operation_Ref            :=
        ME_Operation_Ref (Item).Op;
      Sche_Param_Ref    :
        Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Message_Tx_Dialog : Message_Tx_Dialog_Access :=
         Message_Tx_Dialog_Access (Dialog);
   begin
      Change_Control.Changes_Made;
      Init
        (Op_Ref.all,
         Var_Strings.To_Lower
            (To_Var_String (Get_Text (Message_Tx_Dialog.Op_Name_Entry))));
      Set_Max_Message_Size
        (Message_Transmission_Operation (Op_Ref.all),
         Bit_Count'Value
            (Get_Text (Message_Tx_Dialog.Max_Message_Size_Entry)));
      Set_Avg_Message_Size
        (Message_Transmission_Operation (Op_Ref.all),
         Bit_Count'Value
            (Get_Text (Message_Tx_Dialog.Avg_Message_Size_Entry)));
      Set_Min_Message_Size
        (Message_Transmission_Operation (Op_Ref.all),
         Bit_Count'Value
            (Get_Text (Message_Tx_Dialog.Min_Message_Size_Entry)));

      Sche_Param_Ref := Mast.Operations.New_Sched_Parameters (Op_Ref.all);
      if (Get_Text (Get_Entry
                       (Message_Tx_Dialog.Overrid_Param_Type_Combo)) =
          "(NONE)")
      then
         Sche_Param_Ref := null;
      elsif (Get_Text
                (Get_Entry (Message_Tx_Dialog.Overrid_Param_Type_Combo)) =
             "Fixed Priority")
      then
         Sche_Param_Ref := new Overridden_FP_Parameters;
         Set_The_Priority
           (Overridden_FP_Parameters (Sche_Param_Ref.all),
            Priority'Value (Get_Text (Message_Tx_Dialog.Overrid_Prior_Entry)));
      elsif (Get_Text
                (Get_Entry (Message_Tx_Dialog.Overrid_Param_Type_Combo)) =
             "Permanent Fixed Priority")
      then
         Sche_Param_Ref := new Overridden_Permanent_FP_Parameters;
         Set_The_Priority
           (Overridden_Permanent_FP_Parameters (Sche_Param_Ref.all),
            Priority'Value (Get_Text (Message_Tx_Dialog.Overrid_Prior_Entry)));
      end if;
      Mast.Operations.Set_New_Sched_Parameters (Op_Ref.all, Sche_Param_Ref);
   end Write_Parameters;

   ----------------------
   -- Write Parameters --
   ----------------------
   procedure Write_Parameters
     (Item   : access ME_Composite_Operation;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Op_Ref         : Operation_Ref     := ME_Operation_Ref (Item).Op;
      Enc_Op         : Mast.Operations.Enclosing_Operation;
      Sche_Param_Ref :
        Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Cop_Dialog     : Cop_Dialog_Access := Cop_Dialog_Access (Dialog);
   begin
      Change_Control.Changes_Made;
      if Op_Ref = null then
         if (Get_Text (Get_Entry (Cop_Dialog.Op_Type_Combo)) =
             "Composite")
         then
            Op_Ref := new Composite_Operation;
         elsif (Get_Text (Get_Entry (Cop_Dialog.Op_Type_Combo)) =
                "Enclosing")
         then
            Op_Ref := new Enclosing_Operation;
            Enc_Op := Enclosing_Operation (Op_Ref.all);
            Set_Worst_Case_Execution_Time
              (Enc_Op,
               Normalized_Execution_Time'Value
                  (Get_Text (Cop_Dialog.Wor_Exec_Time_Entry)));
            Set_Avg_Case_Execution_Time
              (Enc_Op,
               Normalized_Execution_Time'Value
                  (Get_Text (Cop_Dialog.Avg_Exec_Time_Entry)));
            Set_Best_Case_Execution_Time
              (Enc_Op,
               Normalized_Execution_Time'Value
                  (Get_Text (Cop_Dialog.Bes_Exec_Time_Entry)));
            Enclosing_Operation (Op_Ref.all) := Enc_Op;
         end if;
      else
         if Op_Ref.all'Tag= Enclosing_Operation'Tag and
            (Get_Text (Get_Entry (Cop_Dialog.Op_Type_Combo)) = "Enclosing")
         then
            Enc_Op := Enclosing_Operation (Op_Ref.all);
            Set_Worst_Case_Execution_Time
              (Enc_Op,
               Normalized_Execution_Time'Value
                  (Get_Text (Cop_Dialog.Wor_Exec_Time_Entry)));
            Set_Avg_Case_Execution_Time
              (Enc_Op,
               Normalized_Execution_Time'Value
                  (Get_Text (Cop_Dialog.Avg_Exec_Time_Entry)));
            Set_Best_Case_Execution_Time
              (Enc_Op,
               Normalized_Execution_Time'Value
                  (Get_Text (Cop_Dialog.Bes_Exec_Time_Entry)));
            Enclosing_Operation (Op_Ref.all) := Enc_Op;
         elsif Op_Ref.all'Tag= Composite_Operation'Tag and
               (Get_Text (Get_Entry (Cop_Dialog.Op_Type_Combo)) =
                "Composite")
         then
            null;
         else
            Gtk_New (Editor_Error_Window);
            Set_Text
              (Editor_Error_Window.Label,
               " Type Conversion not Valid !! ");
            Show_All (Editor_Error_Window);
         end if;
      end if;

      Init
        (Op_Ref.all,
         Var_Strings.To_Lower
            (To_Var_String (Get_Text (Cop_Dialog.Op_Name_Entry))));

      Sche_Param_Ref := Mast.Operations.New_Sched_Parameters (Op_Ref.all);
      if (Get_Text (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo)) =
          "(NONE)")
      then
         Sche_Param_Ref := null;
      elsif (Get_Text (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo)) =
             "Fixed Priority")
      then
         Sche_Param_Ref := new Overridden_FP_Parameters;
         Set_The_Priority
           (Overridden_FP_Parameters (Sche_Param_Ref.all),
            Priority'Value (Get_Text (Cop_Dialog.Overrid_Prior_Entry)));
      elsif (Get_Text (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo)) =
             "Permanent Fixed Priority")
      then
         Sche_Param_Ref := new Overridden_Permanent_FP_Parameters;
         Set_The_Priority
           (Overridden_Permanent_FP_Parameters (Sche_Param_Ref.all),
            Priority'Value (Get_Text (Cop_Dialog.Overrid_Prior_Entry)));
      end if;
      Mast.Operations.Set_New_Sched_Parameters (Op_Ref.all, Sche_Param_Ref);
   end Write_Parameters;

   ----------------------
   -- Read Parameters --
   ----------------------
   procedure Read_Parameters
     (Item   : access ME_Simple_Operation;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Op_Ref         : Operation_Ref    := Item.Op;
      Op_Name        : String           := Name_Image (Name (Op_Ref));
      Sche_Param_Ref :
        Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Shared_Ref     : Mast.Shared_Resources.Shared_Resource_Ref;
      Res_Iterator   : Mast.Operations.Resource_Iteration_Object;
      Through        : Throughput_Value := 1.0;
      -- We need to define the Throughput in order to call
      --  *_Case_Execution_Time functions.  The default value
      --  is not relevant since it is not used within these
      --  functions

      Sop_Dialog     : Sop_Dialog_Access := Sop_Dialog_Access (Dialog);
      Locked_Parent, Unlocked_Parent: Gtk_Tree_Iter := Null_Iter;
      Locked_Iter, Unlocked_Iter: Gtk_Tree_Iter;
   begin
      Set_Text (Sop_Dialog.Op_Name_Entry, Op_Name);
      Set_Text
        (Sop_Dialog.Wor_Exec_Time_Entry,
         Execution_Time_Image
            (Worst_Case_Execution_Time
                (Simple_Operation (Op_Ref.all),
                 Through)));
      Set_Text
        (Sop_Dialog.Avg_Exec_Time_Entry,
         Execution_Time_Image
            (Avg_Case_Execution_Time
                (Simple_Operation (Op_Ref.all),
                 Through)));
      Set_Text
        (Sop_Dialog.Bes_Exec_Time_Entry,
         Execution_Time_Image
            (Best_Case_Execution_Time
                (Simple_Operation (Op_Ref.all),
                 Through)));

      Rewind_Locked_Resources (Simple_Operation (Op_Ref.all), Res_Iterator);
      for I in 1 .. Num_Of_Locked_Resources (Simple_Operation (Op_Ref.all))
      loop
         begin
            Get_Next_Locked_Resource
              (Simple_Operation (Op_Ref.all),
               Shared_Ref,
               Res_Iterator);
            Append (Sop_Dialog.Locked_Tree_Store, Locked_Iter, Locked_Parent);
            Set
              (Sop_Dialog.Locked_Tree_Store,
               Locked_Iter,
               Locked_Column,
               Name_Image (Name (Shared_Ref)));
         exception
            when No_More_Items =>
               exit;
         end;
      end loop;

      Rewind_Unlocked_Resources (Simple_Operation (Op_Ref.all), Res_Iterator);
      for I in
            1 .. Num_Of_Unlocked_Resources (Simple_Operation (Op_Ref.all))
      loop
         begin
            Get_Next_Unlocked_Resource
              (Simple_Operation (Op_Ref.all),
               Shared_Ref,
               Res_Iterator);
            Append
              (Sop_Dialog.Unlocked_Tree_Store,
               Unlocked_Iter,
               Unlocked_Parent);
            Set
              (Sop_Dialog.Unlocked_Tree_Store,
               Unlocked_Iter,
               Unlocked_Column,
               Name_Image (Name (Shared_Ref)));
         exception
            when No_More_Items =>
               exit;
         end;
      end loop;

      Sche_Param_Ref                                     :=
         Mast.Operations.New_Sched_Parameters (Op_Ref.all);
      if Sche_Param_Ref = null then
         Set_Text (Get_Entry (Sop_Dialog.Overrid_Param_Type_Combo), "(NONE)");
         Show_All (Sop_Dialog);
         Hide (Sop_Dialog.Overrid_Prior_Table);
      else
         if Sche_Param_Ref.all'Tag =
            Overridden_Permanent_FP_Parameters'Tag
         then
            Set_Text
              (Get_Entry (Sop_Dialog.Overrid_Param_Type_Combo),
               "Permanent Fixed Priority");
            Set_Text
              (Sop_Dialog.Overrid_Prior_Entry,
               Priority'Image
                  (The_Priority
                      (Overridden_Permanent_FP_Parameters (Sche_Param_Ref.all))
));
         else
            Set_Text
              (Get_Entry (Sop_Dialog.Overrid_Param_Type_Combo),
               "Fixed Priority");
            Set_Text
              (Sop_Dialog.Overrid_Prior_Entry,
               Priority'Image
                  (The_Priority
                      (Overridden_FP_Parameters (Sche_Param_Ref.all))));
         end if;
         Show_All (Sop_Dialog);
      end if;
   end Read_Parameters;

   ----------------------
   -- Read Parameters --
   ----------------------
   procedure Read_Parameters
     (Item   : access Me_Message_Transmission_Operation;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Op_Ref            : Operation_Ref            := Item.Op;
      Op_Name           : String                   :=
         Name_Image (Name (Op_Ref));
      Sche_Param_Ref    :
        Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Message_Tx_Dialog : Message_Tx_Dialog_Access :=
         Message_Tx_Dialog_Access (Dialog);
   begin
      Set_Text (Message_Tx_Dialog.Op_Name_Entry, Op_Name);
      Set_Text
        (Message_Tx_Dialog.Max_Message_Size_Entry,
         Bit_Count_Image
            (Max_Message_Size (Message_Transmission_Operation (Op_Ref.all))));
      Set_Text
        (Message_Tx_Dialog.Avg_Message_Size_Entry,
         Bit_Count_Image
            (Avg_Message_Size (Message_Transmission_Operation (Op_Ref.all))));
      Set_Text
        (Message_Tx_Dialog.Min_Message_Size_Entry,
         Bit_Count_Image
            (Min_Message_Size (Message_Transmission_Operation (Op_Ref.all))));
      Sche_Param_Ref := Mast.Operations.New_Sched_Parameters (Op_Ref.all);
      if Sche_Param_Ref = null then
         Set_Text
           (Get_Entry (Message_Tx_Dialog.Overrid_Param_Type_Combo),
            "(NONE)");
         Show_All (Message_Tx_Dialog);
         Hide (Message_Tx_Dialog.Overrid_Prior_Table);
      else
         if Sche_Param_Ref.all'Tag =
            Overridden_Permanent_FP_Parameters'Tag
         then
            Set_Text
              (Get_Entry (Message_Tx_Dialog.Overrid_Param_Type_Combo),
               "Permanent Fixed Priority");
            Set_Text
              (Message_Tx_Dialog.Overrid_Prior_Entry,
               Priority'Image
                  (The_Priority
                      (Overridden_Permanent_FP_Parameters (Sche_Param_Ref.all))
));
         else
            Set_Text
              (Get_Entry (Message_Tx_Dialog.Overrid_Param_Type_Combo),
               "Fixed Priority");
            Set_Text
              (Message_Tx_Dialog.Overrid_Prior_Entry,
               Priority'Image
                  (The_Priority
                      (Overridden_FP_Parameters (Sche_Param_Ref.all))));
         end if;
         Show_All (Message_Tx_Dialog);
      end if;
   end Read_Parameters;

   ----------------------
   -- Read Parameters --
   ----------------------
   procedure Read_Parameters
     (Item   : access ME_Composite_Operation;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Op_Ref         : Operation_Ref    := Item.Op;
      Op_Name        : String           := Name_Image (Name (Op_Ref));
      Sche_Param_Ref :
        Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Oper_Ref       : Mast.Operations.Operation_Ref;
      Op_Iterator    : Mast.Operations.Operation_Iteration_Object;
      Through        : Throughput_Value := 1.0; -- We need to define the
                                                --Throughput in order to call
                                                --*_Case_Execution_Time
                                                --functions.
                                                -- The default value is not
                                                --relevant since it is not
                                                --used within these functions
      Cop_Dialog     : Cop_Dialog_Access := Cop_Dialog_Access (Dialog);
      Parent         : Gtk_Tree_Iter    := Null_Iter;
      Iter           : Gtk_Tree_Iter;
   begin
      Set_Text (Cop_Dialog.Op_Name_Entry, Op_Name);

      if Op_Ref.all in Enclosing_Operation then
         Set_Text (Get_Entry (Cop_Dialog.Op_Type_Combo), "Enclosing");
         Set_Text
           (Cop_Dialog.Wor_Exec_Time_Entry,
            Execution_Time_Image
               (Worst_Case_Execution_Time
                   (Enclosing_Operation (Op_Ref.all),
                    Through)));
         Set_Text
           (Cop_Dialog.Avg_Exec_Time_Entry,
            Execution_Time_Image
               (Avg_Case_Execution_Time
                   (Enclosing_Operation (Op_Ref.all),
                    Through)));
         Set_Text
           (Cop_Dialog.Bes_Exec_Time_Entry,
            Execution_Time_Image
               (Best_Case_Execution_Time
                   (Enclosing_Operation (Op_Ref.all),
                    Through)));
         Rewind_Operations (Enclosing_Operation (Op_Ref.all), Op_Iterator);
         for I in 1 .. Num_Of_Operations (Composite_Operation (Op_Ref.all))
         loop
            begin
               Get_Next_Operation
                 (Enclosing_Operation (Op_Ref.all),
                  Oper_Ref,
                  Op_Iterator);
               Append (Cop_Dialog.Tree_Store, Iter, Parent);
               Set
                 (Cop_Dialog.Tree_Store,
                  Iter,
                  Op_Column,
                  Name_Image (Name (Oper_Ref)));
            exception
               when No_More_Items =>
                  exit;
            end;
         end loop;
         Show_All (Cop_Dialog);
      elsif Op_Ref.all in Composite_Operation then
         Set_Text (Get_Entry (Cop_Dialog.Op_Type_Combo), "Composite");
         Rewind_Operations (Composite_Operation (Op_Ref.all), Op_Iterator);
         for I in 1 .. Num_Of_Operations (Composite_Operation (Op_Ref.all))
         loop
            begin
               Get_Next_Operation
                 (Composite_Operation (Op_Ref.all),
                  Oper_Ref,
                  Op_Iterator);
               Append (Cop_Dialog.Tree_Store, Iter, Parent);
               Set
                 (Cop_Dialog.Tree_Store,
                  Iter,
                  Op_Column,
                  Name_Image (Name (Oper_Ref)));
            exception
               when No_More_Items =>
                  exit;
            end;
         end loop;
         Show_All (Cop_Dialog);
         Hide (Cop_Dialog.Exec_Time_Table);
      end if;

      Sche_Param_Ref                 :=
         Mast.Operations.New_Sched_Parameters (Op_Ref.all);
      if Sche_Param_Ref = null then
         Set_Text (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo), "(NONE)");
         Hide (Cop_Dialog.Overrid_Prior_Table);
      else
         if Sche_Param_Ref.all'Tag =
            Overridden_Permanent_FP_Parameters'Tag
         then
            Set_Text
              (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo),
               "Permanent Fixed Priority");
            Set_Text
              (Cop_Dialog.Overrid_Prior_Entry,
               Priority'Image
                  (The_Priority
                      (Overridden_Permanent_FP_Parameters (Sche_Param_Ref.all))
));
         else
            Set_Text
              (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo),
               "Fixed Priority");
            Set_Text
              (Cop_Dialog.Overrid_Prior_Entry,
               Priority'Image
                  (The_Priority
                      (Overridden_FP_Parameters (Sche_Param_Ref.all))));
         end if;
         Show_All (Cop_Dialog.Overrid_Prior_Table);
      end if;
   end Read_Parameters;

   ---------------------
   -- Draw Simple     --
   ---------------------
   procedure Draw
     (Item         : access ME_Simple_Operation;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint)
   is
      Rect           : constant Gdk_Rectangle := Get_Coord (Item);
      W              : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Width);
      H              : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Height);
      Op_Ref         : Operation_Ref          := Item.Op;
      Op_Name        : String                 := Name_Image (Name (Op_Ref));
      Sche_Param_Ref :
        Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Color          : Gdk.Color.Gdk_Color;
   begin
      Color := Parse (To_String (ME_Operation_Ref (Item).Color_Name));
      Alloc (Gtk.Widget.Get_Default_Colormap, Color);
      Item.X_Coord := Gint (Get_Coord (Item).X);
      Item.Y_Coord := Gint (Get_Coord (Item).Y);
      Set_Foreground (GC, Color);
      Draw_Rectangle
        (Get_Window (Canvas),
         Gc     => GC,
         Filled => True,
         X      => Xdest,
         Y      => Ydest,
         Width  => W,
         Height => H);
      Set_Foreground (GC, Black (Get_Default_Colormap));
      Draw_Rectangle
        (Get_Window (Canvas),
         Gc     => GC,
         Filled => False,
         X      => Xdest,
         Y      => Ydest,
         Width  => W,
         Height => H);
      Draw_Line
        (Get_Window (Canvas),
         GC,
         Xdest,
         Ydest + H / 5,
         Xdest + W,
         Ydest + H / 5);
      if Get_Zoom (Canvas) = Zoom_Levels (1) then
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 20,
            Ydest + H / 6,
            Op_Name);
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 3 * H / 6,
            Text => "SIMPLE");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 5 * H / 6,
            Text => "OPERATION");
      elsif Get_Zoom (Canvas) = Zoom_Levels (2) then
         Sche_Param_Ref := Mast.Operations.New_Sched_Parameters (Op_Ref.all);
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 20,
            Ydest + H / 7,
            Op_Name);
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 4 * H / 10,
            Text => "SIMPLE OPERATION");
      else
         Sche_Param_Ref := Mast.Operations.New_Sched_Parameters (Op_Ref.all);
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 10,
            Ydest + H / 8,
            Op_Name);
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 10,
            Ydest + 4 * H / 10,
            Text => "SIMPLE OPERATION");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 10,
            Ydest + 7 * H / 10,
            "Locked Res: " &
            Positive'Image
               (Num_Of_Locked_Resources (Simple_Operation (Op_Ref.all))));
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 10,
            Ydest + 9 * H / 10,
            "Unlocked Res: " &
            Positive'Image
               (Num_Of_Unlocked_Resources (Simple_Operation (Op_Ref.all))));
      end if;
   end Draw;

   ---------------------
   -- Draw Message Tx --
   ---------------------
   procedure Draw
     (Item         : access Me_Message_Transmission_Operation;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint)
   is
      Rect           : constant Gdk_Rectangle := Get_Coord (Item);
      W              : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Width);
      H              : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Height);
      Op_Ref         : Operation_Ref          := Item.Op;
      Op_Name        : String                 := Name_Image (Name (Op_Ref));
      Sche_Param_Ref :
        Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Color          : Gdk.Color.Gdk_Color;
   begin
      Color := Parse (To_String (ME_Operation_Ref (Item).Color_Name));
      Alloc (Gtk.Widget.Get_Default_Colormap, Color);
      Item.X_Coord := Gint (Get_Coord (Item).X);
      Item.Y_Coord := Gint (Get_Coord (Item).Y);
      Set_Foreground (GC, Color);
      Draw_Rectangle
        (Get_Window (Canvas),
         Gc     => GC,
         Filled => True,
         X      => Xdest,
         Y      => Ydest,
         Width  => W,
         Height => H);
      Set_Foreground (GC, Black (Get_Default_Colormap));
      Draw_Rectangle
        (Get_Window (Canvas),
         Gc     => GC,
         Filled => False,
         X      => Xdest,
         Y      => Ydest,
         Width  => W,
         Height => H);
      Draw_Line
        (Get_Window (Canvas),
         GC,
         Xdest,
         Ydest + H / 5,
         Xdest + W,
         Ydest + H / 5);
      if Get_Zoom (Canvas) = Zoom_Levels (1) then
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 20,
            Ydest + H / 6,
            Op_Name);
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 3 * H / 6,
            Text => "MESSAGE TX");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 5 * H / 6,
            Text => "OPERATION");
      elsif Get_Zoom (Canvas) = Zoom_Levels (2) then
         Sche_Param_Ref := Mast.Operations.New_Sched_Parameters (Op_Ref.all);
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 20,
            Ydest + H / 7,
            Op_Name);
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 4 * H / 10,
            Text => "MESSAGE TX OPERATION");
      else
         Sche_Param_Ref := Mast.Operations.New_Sched_Parameters (Op_Ref.all);
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 10,
            Ydest + H / 8,
            Op_Name);
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 10,
            Ydest + 4 * H / 10,
            Text => "MESSAGE TX OPERATION");
      end if;
   end Draw;

   ---------------------
   -- Draw Composite  --
   ---------------------
   procedure Draw
     (Item         : access ME_Composite_Operation;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint)
   is
      Rect           : constant Gdk_Rectangle := Get_Coord (Item);
      W              : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Width);
      H              : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Height);
      Op_Ref         : Operation_Ref          := Item.Op;
      Op_Name        : String                 := Name_Image (Name (Op_Ref));
      Sche_Param_Ref :
        Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Color          : Gdk.Color.Gdk_Color;
   begin
      Color := Parse (To_String (ME_Operation_Ref (Item).Color_Name));
      Alloc (Gtk.Widget.Get_Default_Colormap, Color);
      Item.X_Coord := Gint (Get_Coord (Item).X);
      Item.Y_Coord := Gint (Get_Coord (Item).Y);
      Set_Foreground (GC, Color);
      Draw_Rectangle
        (Get_Window (Canvas),
         Gc     => GC,
         Filled => True,
         X      => Xdest,
         Y      => Ydest,
         Width  => W,
         Height => H);
      Set_Foreground (GC, Black (Get_Default_Colormap));
      Draw_Rectangle
        (Get_Window (Canvas),
         Gc     => GC,
         Filled => False,
         X      => Xdest,
         Y      => Ydest,
         Width  => W,
         Height => H);
      Draw_Line
        (Get_Window (Canvas),
         GC,
         Xdest,
         Ydest + H / 5,
         Xdest + W,
         Ydest + H / 5);
      if Get_Zoom (Canvas) = Zoom_Levels (1) then
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 20,
            Ydest + H / 6,
            Op_Name);
         if Op_Ref.all in Enclosing_Operation then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 20,
               Ydest + 3 * H / 6,
               Text => "ENCLOSING");
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 20,
               Ydest + 5 * H / 6,
               Text => "OPERATION");
         elsif Op_Ref.all in Composite_Operation then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 20,
               Ydest + 3 * H / 6,
               Text => "COMPOSITE");
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 20,
               Ydest + 5 * H / 6,
               Text => "OPERATION");
         end if;
      elsif Get_Zoom (Canvas) = Zoom_Levels (2) then
         Sche_Param_Ref := Mast.Operations.New_Sched_Parameters (Op_Ref.all);
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 20,
            Ydest + H / 7,
            Op_Name);
         if Op_Ref.all in Enclosing_Operation then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 20,
               Ydest + 4 * H / 10,
               Text => "ENCLOSING OPERATION");
         elsif Op_Ref.all in Composite_Operation then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 20,
               Ydest + 4 * H / 10,
               Text => "COMPOSITE OPERATION");
         end if;
      else
         Sche_Param_Ref := Mast.Operations.New_Sched_Parameters (Op_Ref.all);
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 10,
            Ydest + H / 8,
            Op_Name);
         if Op_Ref.all in Enclosing_Operation then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 10,
               Ydest + 4 * H / 10,
               Text => "ENCLOSING OPERATION");
         elsif Op_Ref.all in Composite_Operation then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 10,
               Ydest + 4 * H / 10,
               Text => "COMPOSITE OPERATION");
         end if;
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 10,
            Ydest + 8 * H / 10,
            "Num Of Operations: " &
            Positive'Image
               (Num_Of_Operations (Composite_Operation (Op_Ref.all))));
      end if;
   end Draw;

   ------------------------------------
   -- Draw Composite Operation Links --
   ------------------------------------

   procedure Draw_Composite_Operation_Links (Item : ME_Operation_Ref) is
      Op_Ref         : Mast.Operations.Operation_Ref;
      Op_Iterator    : Mast.Operations.Operation_Iteration_Object;
      Me_Op_Iterator : Mast_Editor.Operations.Lists.Iteration_Object;
      Me_Op_Ref      : ME_Operation_Ref;
   begin
      Editor_Actions.Remove_Old_Links (Operation_Canvas, Item);

      Mast.Operations.Rewind_Operations
        (Composite_Operation (Item.Op.all),
         Op_Iterator);
      for I in
            1 ..
            Mast.Operations.Num_Of_Operations
               (Composite_Operation (Item.Op.all))
      loop
         begin
            Mast.Operations.Get_Next_Operation
              (Composite_Operation (Item.Op.all),
               Op_Ref,
               Op_Iterator);
            Me_Op_Iterator :=
               Mast_Editor.Operations.Lists.Find
                 (Name (Op_Ref),
                  Editor_System.Me_Operations);
            Me_Op_Ref      :=
               Mast_Editor.Operations.Lists.Item
                 (Me_Op_Iterator,
                  Editor_System.Me_Operations);
            Add_Canvas_Link (Operation_Canvas, Item, Me_Op_Ref);
         exception
            when No_More_Items =>
               exit;
         end;
      end loop;
      Refresh_Canvas (Operation_Canvas);
   exception
      when Invalid_Index => -- simple operation not found
         Refresh_Canvas (Operation_Canvas);
   end Draw_Composite_Operation_Links;

   ----------------------------------------
   -- Cancel_Simple_Operation_Conversion --
   ----------------------------------------
   procedure Cancel_Simple_Operation_Conversion
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Operation_And_Dialog2_Ref)
   is
   begin
      Set_Text
        (Get_Entry (Sop_Dialog_Access (Data.Dia).Op_Type_Combo),
         "Simple");
      Show (Data.Dia); -- Sop_Dialog;
      Destroy (Data.Dia2); -- Cop_Dialog;
   end Cancel_Simple_Operation_Conversion;

   ------------------------------
   -- Convert_Simple_Operation -- Convert Simple Operation To Enclosing
   --Operation
   ------------------------------
   procedure Convert_Simple_Operation
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Operation_And_Dialog2_Ref)
   is
      Op_Name         : Var_String;
      Op_Index        : Mast.Operations.Lists.Index;
      Item_Deleted    : Mast.Operations.Operation_Ref;
      Me_Op_Index     : Mast_Editor.Operations.Lists.Index;
      Me_Item_Deleted : Mast_Editor.Operations.ME_Operation_Ref;
      X_Coord         : Gint                                    :=
         Gint (Get_Coord (Data.It).X);
      Y_Coord         : Gint                                    :=
         Gint (Get_Coord (Data.It).Y);
      Oper            : Mast.Operations.Operation_Ref           :=
         new Enclosing_Operation;
      Item            : Mast_Editor.Operations.ME_Operation_Ref :=
         new ME_Composite_Operation;
      Cop_Dialog      : Cop_Dialog_Access                       :=
         Cop_Dialog_Access (Data.Dia2);

      -- Variables used to change from enclosing to composite
      Op_Ref  : Operation_Ref := new Composite_Operation;
      Op_Temp : Composite_Operation;
   begin
      -- Delete Old Operation
      Op_Name      := Name (Data.It);
      Op_Index     :=
         Mast.Operations.Lists.Find (Op_Name, The_System.Operations);
      Item_Deleted :=
         Mast.Operations.Lists.Item (Op_Index, The_System.Operations);
      Mast.Operations.Lists.Delete
        (Op_Index,
         Item_Deleted,
         The_System.Operations);
      Me_Op_Index     :=
         Mast_Editor.Operations.Lists.Find
           (Op_Name,
            Editor_System.Me_Operations);
      Me_Item_Deleted :=
         Mast_Editor.Operations.Lists.Item
           (Me_Op_Index,
            Editor_System.Me_Operations);
      Mast_Editor.Operations.Lists.Delete
        (Me_Op_Index,
         Me_Item_Deleted,
         Editor_System.Me_Operations);
      Remove (Operation_Canvas, Data.It);

      -- Create New Operation
      Item.W           := Op_Width;
      Item.H           := Op_Height;
      Item.Canvas_Name := To_Var_String ("Operation_Canvas");
      Item.Color_Name  := Cop_Color;
      Item.Op          := Oper;

      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (Cop_Dialog.Op_Name_Entry)))
      then
         if (Get_Text (Get_Entry (Cop_Dialog.Op_Type_Combo)) =
             "Composite")
         then
            Op_Temp                          :=
              Composite_Operation (Item.Op.all);
            Composite_Operation (Op_Ref.all) := Op_Temp;
            Item.Op                          := Op_Ref;
         end if;
         Write_Parameters (Item, Gtk_Dialog (Cop_Dialog));
         Mast.Operations.Lists.Add (Item.Op, The_System.Operations);
         Mast_Editor.Operations.Lists.Add (Item, Editor_System.Me_Operations);
         Set_Screen_Size (Item, Item.W, Item.H);
         Put (Operation_Canvas, Item, X_Coord, Y_Coord); -- Put New Op in the
                                                         --same place of
                                                         --Deleted Op
         Refresh_Canvas (Operation_Canvas);
         Show_Item (Operation_Canvas, Item);
         Destroy (Data.Dia); -- Sop_Dialog;
         Destroy (Data.Dia2); -- Cop_Dialog;
      else
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Identifier not Valid!!!");
         Show_All (Editor_Error_Window);
      end if;
   exception
      when Invalid_Index =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "ERROR IN SIMPLE OPERATION CONVERTION !!!");
         Show_All (Editor_Error_Window);
         Destroy (Data.Dia);
         Destroy (Data.Dia2);
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, " Invalid Value!!!");
         Show_All (Editor_Error_Window);
         Destroy (Data.Dia);
         Destroy (Data.Dia2);
      when Already_Exists =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " The operation already exists!!!");
         Show_All (Editor_Error_Window);
         Destroy (Data.Dia);
         Destroy (Data.Dia2);
   end Convert_Simple_Operation;

   ------------------------------
   -- Change_Type_To_Enclosing -- (Change simple op to enclosing op)
   ------------------------------
   procedure Change_Type_To_Enclosing
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Operation_And_Dialog_Ref)
   is
      Sop_Dialog : Sop_Dialog_Access            :=
         Sop_Dialog_Access (Data.Dia);
      Cop_Dialog : Cop_Dialog_Access;
      Data2      : ME_Operation_And_Dialog2_Ref :=
         new ME_Operation_And_Dialog2;
   begin
      if Get_Text (Get_Entry (Sop_Dialog.Op_Type_Combo)) =
         "Enclosing"
      then
         Hide (Sop_Dialog);

         Gtk_New (Cop_Dialog);
         Set_Text
           (Cop_Dialog.Op_Name_Entry,
            Get_Text (Sop_Dialog.Op_Name_Entry));
         Set_Text
           (Cop_Dialog.Wor_Exec_Time_Entry,
            Get_Text (Sop_Dialog.Wor_Exec_Time_Entry));
         Set_Text
           (Cop_Dialog.Avg_Exec_Time_Entry,
            Get_Text (Sop_Dialog.Avg_Exec_Time_Entry));
         Set_Text
           (Cop_Dialog.Bes_Exec_Time_Entry,
            Get_Text (Sop_Dialog.Bes_Exec_Time_Entry));

         Show_All (Cop_Dialog);

         if Get_Text (Get_Entry (Sop_Dialog.Overrid_Param_Type_Combo)) =
            "(NONE)"
         then
            Set_Text
              (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo),
               "(NONE)");
            Hide (Cop_Dialog.Overrid_Prior_Table);
         elsif Get_Text (Get_Entry
                            (Sop_Dialog.Overrid_Param_Type_Combo)) =
               "Permanent Fixed Priority"
         then
            Set_Text
              (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo),
               "Permanent Fixed Priority");
            Set_Text
              (Cop_Dialog.Overrid_Prior_Entry,
               Get_Text (Sop_Dialog.Overrid_Prior_Entry));
            Show_All (Cop_Dialog.Overrid_Prior_Table);
         elsif Get_Text (Get_Entry
                            (Sop_Dialog.Overrid_Param_Type_Combo)) =
               "Fixed Priority"
         then
            Set_Text
              (Get_Entry (Cop_Dialog.Overrid_Param_Type_Combo),
               "Fixed Priority");
            Set_Text
              (Cop_Dialog.Overrid_Prior_Entry,
               Get_Text (Sop_Dialog.Overrid_Prior_Entry));
            Show_All (Cop_Dialog.Overrid_Prior_Table);
         end if;

         Data2.It   := Data.It;
         Data2.Dia  := Data.Dia;
         Data2.Dia2 := Gtk_Dialog (Cop_Dialog);

         --  Add_Op and Remove_Op buttons not sensitive at first
         Set_Sensitive (Cop_Dialog.Add_Op_Button, False);
         Set_Sensitive (Cop_Dialog.Remove_Op_Button, False);

         --  Destroys all the handlers associated to Cop_Dialog.Cancel_Button
         Gtk.Handlers.Handlers_Destroy
           (Glib.Object.GObject (Cop_Dialog.Cancel_Button));

         Me_Operation_And_Dialog2_Cb.Connect
           (Cop_Dialog.Ok_Button,
            "clicked",
            Me_Operation_And_Dialog2_Cb.To_Marshaller
               (Convert_Simple_Operation'Access),
            Data2);

         Me_Operation_And_Dialog2_Cb.Connect
           (Cop_Dialog.Cancel_Button,
            "clicked",
            Me_Operation_And_Dialog2_Cb.To_Marshaller
               (Cancel_Simple_Operation_Conversion'Access),
            Data2);
      end if;
   end Change_Type_To_Enclosing;

   -------------------
   -- Write Simple  -- (Writes the params of an existing simple_op and
   --refreshes the canvas)
   -------------------
   procedure Write_Simple
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Operation_And_Dialog_Ref)
   is
      Item       : ME_Operation_Ref  := Data.It;
      Sop_Dialog : Sop_Dialog_Access := Sop_Dialog_Access (Data.Dia);
   begin
      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (Sop_Dialog.Op_Name_Entry)))
      then
         Write_Parameters (Item, Gtk_Dialog (Sop_Dialog));
         Refresh_Canvas (Operation_Canvas);
         Destroy (Sop_Dialog);
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
   end Write_Simple;

   ----------------------
   -- Write Message Tx -- (Writes the params of an existing message_tx_op and
   --refreshes the canvas)
   ----------------------
   procedure Write_Message_Tx
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Operation_And_Dialog_Ref)
   is
      Item              : ME_Operation_Ref         := Data.It;
      Message_Tx_Dialog : Message_Tx_Dialog_Access :=
         Message_Tx_Dialog_Access (Data.Dia);
   begin
      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (Message_Tx_Dialog.Op_Name_Entry)))
      then
         Write_Parameters (Item, Gtk_Dialog (Message_Tx_Dialog));
         Refresh_Canvas (Operation_Canvas);
         Destroy (Message_Tx_Dialog);
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
         Destroy (Message_Tx_Dialog);
   end Write_Message_Tx;

   ---------------------
   -- Write Composite -- (Write params of an existing composite_op and refresh
   --canvas)
   ---------------------
   procedure Write_Composite
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Operation_And_Dialog_Ref)
   is
      Op_Ref     : Operation_Ref     := new Composite_Operation;
      Op_Temp    : Composite_Operation;
      Item       : ME_Operation_Ref  := Data.It;
      Cop_Dialog : Cop_Dialog_Access := Cop_Dialog_Access (Data.Dia);
   begin
      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (Cop_Dialog.Op_Name_Entry)))
      then
         if Mast.Operations.Num_Of_Operations
               (Composite_Operation (Item.Op.all)) <
            1
         then
            -- Message Error shown in the other handler
            --(Update_Operations_List)
            null;
         --Gtk_New (Editor_Error_Window);
         --Set_Text (Editor_Error_Window.Label, "Operation must contain at
         --least one operation!");
         --Show_All (Editor_Error_Window);
         else
            --if (Get_Text (Get_Entry (Cop_Dialog.Op_Type_Combo)) =
            --    "Composite")
            --then
            --   Op_Temp                          :=
            --     Composite_Operation (Item.Op.all);
            --   Composite_Operation (Op_Ref.all) := Op_Temp;
            --   Item.Op                          := Op_Ref;
            --end if;
            Write_Parameters (Item, Gtk_Dialog (Cop_Dialog));
            Draw_Composite_Operation_Links (Item);
            Refresh_Canvas (Operation_Canvas);
            Destroy (Cop_Dialog);
         end if;
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
   end Write_Composite;

   ----------------------------
   -- Update Resources Lists -- (Updates resources list changed in sop dialog
   --when Ok button is clicked)
   ----------------------------
   procedure Update_Resources_Lists
     (Widget : access Gtk_Widget_Record'Class;
      Double : Double_Operation_Ref)
   is
   begin
      Simple_Operation (Double.Op.all) :=
        Simple_Operation (Double.Temp_Op.all);
   end Update_Resources_Lists;

   ----------------------------
   -- Update Operations List -- (Update operations list changed in
   --"Cop_dialog" when Ok_button is cliked)
   ----------------------------
   procedure Update_Operations_List
     (Widget : access Gtk_Widget_Record'Class;
      Double : Double_Operation_Ref)
   is
   begin
      if Mast.Operations.Num_Of_Operations
            (Composite_Operation (Double.Temp_Op.all)) <
         1
      then
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Operation must contain at least one operation!");
         Show_All (Editor_Error_Window);
      else
         if Double.Op.all'Tag = Composite_Operation'Tag then
            Composite_Operation (Double.Op.all) :=
              Composite_Operation (Double.Temp_Op.all);
         elsif Double.Op.all'Tag = Enclosing_Operation'Tag then
            Enclosing_Operation (Double.Op.all) :=
              Enclosing_Operation (Double.Temp_Op.all);
         end if;
      end if;
   end Update_Operations_List;

   ----------------------
   -- Write Operation  -- (Read name from "add_operation_dialog" and add it to
   --Cop_dialog)
   ----------------------
   procedure Write_Operation
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Operation_And_Dialog2_Ref)
   is
      Op                   : Operation_Ref               := Data.It;
      Cop_Dialog           : Cop_Dialog_Access           :=
         Cop_Dialog_Access (Data.Dia);
      Add_Operation_Dialog : Add_Operation_Dialog_Access :=
         Add_Operation_Dialog_Access (Data.Dia2);
      Op_Name              : Var_Strings.Var_String;
      Op_Index             : Mast.Operations.Lists.Index;
      Op_Ref               : Mast.Operations.Operation_Ref;
      Parent               : Gtk_Tree_Iter               := Null_Iter;
      Iter                 : Gtk_Tree_Iter;
   begin
      if Get_Text (Add_Operation_Dialog.Add_Op_Entry) = "" then
         Destroy (Add_Operation_Dialog);
      else
         Op_Name  :=
            To_Var_String (Get_Text (Add_Operation_Dialog.Add_Op_Entry));
         Op_Index :=
            Mast.Operations.Lists.Find (Op_Name, The_System.Operations);
         Op_Ref   :=
            Mast.Operations.Lists.Item (Op_Index, The_System.Operations);

         if Op_Ref /= null then
            Append (Cop_Dialog.Tree_Store, Iter, Parent);
            Set
              (Cop_Dialog.Tree_Store,
               Iter,
               Op_Column,
               Name_Image (Mast.Operations.Name (Op_Ref)));
         end if;

         Mast.Operations.Add_Operation (Composite_Operation (Op.all), Op_Ref);
         Destroy (Add_Operation_Dialog);
      end if;
   exception
      when Invalid_Index =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Operation not found in system ! ");
         Show_All (Editor_Error_Window);
         Destroy (Add_Operation_Dialog);
   end Write_Operation;

   ----------------------
   -- Remove Operation -- (Remove operation selected in "Cop_dialog")
   ----------------------
   procedure Remove_Operation
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Operation_And_Dialog_Ref)
   is
      Op         : Operation_Ref     := Data.It;
      Cop_Dialog : Cop_Dialog_Access := Cop_Dialog_Access (Data.Dia);

      Op_Name     : Var_String;
      Op_Ref      : Mast.Operations.Operation_Ref;
      Op_Iterator : Mast.Operations.Operation_Iteration_Object;

      Row_Selected : Gtk.Tree_Selection.Gtk_Tree_Selection;
      Model        : Gtk.Tree_Model.Gtk_Tree_Model;
      Iter         : Gtk.Tree_Model.Gtk_Tree_Iter;

   begin
      Row_Selected := Gtk.Tree_View.Get_Selection (Cop_Dialog.Tree_View);
      Get_Selected (Row_Selected, Model, Iter);

      if Iter /= Null_Iter then -- Iter = Null_Iter when no row selected
         Op_Name :=
            To_Var_String (Get_String (Cop_Dialog.Tree_Store, Iter, 0));
         Mast.Operations.Rewind_Operations
           (Mast.Operations.Composite_Operation (Op.all),
            Op_Iterator);
         for I in
               1 ..
               Mast.Operations.Num_Of_Operations
                  (Mast.Operations.Composite_Operation (Op.all))
         loop
            begin
               Mast.Operations.Get_Next_Operation
                 (Mast.Operations.Composite_Operation (Op.all),
                  Op_Ref,
                  Op_Iterator);
               if Name (Op_Ref) = Op_Name then
                  Mast.Operations.Remove_Operation
                    (Mast.Operations.Composite_Operation (Op.all),
                     Op_Ref);
                  Remove (Cop_Dialog.Tree_Store, Iter);
                  exit;
               end if;
            exception
               when No_More_Items =>
                  exit;
            end;
         end loop;
      end if;
   end Remove_Operation;

   --------------------
   -- Add Operation  -- (Show the "add_operation_dialog")
   --------------------
   procedure Add_Operation
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Operation_And_Dialog_Ref)
   is
      Add_Operation_Dialog : Add_Operation_Dialog_Access;
      Data2                : Operation_And_Dialog2_Ref :=
         new Operation_And_Dialog2;

   begin
      Gtk_New (Add_Operation_Dialog);
      Show_All (Add_Operation_Dialog);

      Data2.It   := Data.It;
      Data2.Dia  := Data.Dia;
      Data2.Dia2 := Gtk_Dialog (Add_Operation_Dialog);

      Operation_And_Dialog2_Cb.Connect
        (Add_Operation_Dialog.Add_Op_Button,
         "clicked",
         Operation_And_Dialog2_Cb.To_Marshaller (Write_Operation'Access),
         Data2);

   end Add_Operation;

   -------------------
   -- Remove Shared -- (Remove shared resource selected in sop_dialog)
   -------------------
   procedure Remove_Shared
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Operation_And_Dialog_Ref)
   is
      Op         : Operation_Ref     := Data.It;
      Sop_Dialog : Sop_Dialog_Access := Sop_Dialog_Access (Data.Dia);

      Shared_Name     : Var_String;
      Shared_Ref      : Mast.Shared_Resources.Shared_Resource_Ref;
      Shared_Iterator : Mast.Operations.Resource_Iteration_Object;

      Row_Selected : Gtk.Tree_Selection.Gtk_Tree_Selection;
      Model        : Gtk.Tree_Model.Gtk_Tree_Model;
      Iter         : Gtk.Tree_Model.Gtk_Tree_Iter;
   begin
      -- Locked
      Row_Selected :=
         Gtk.Tree_View.Get_Selection (Sop_Dialog.Locked_Tree_View);
      Get_Selected (Row_Selected, Model, Iter);

      if Iter /= Null_Iter then -- Iter = Null_Iter when no row is selected
         Shared_Name :=
            To_Var_String
              (Get_String (Sop_Dialog.Locked_Tree_Store, Iter, 0));
         Mast.Operations.Rewind_Locked_Resources
           (Mast.Operations.Simple_Operation (Op.all),
            Shared_Iterator);
         for I in
               1 ..
               Mast.Operations.Num_Of_Locked_Resources
                  (Mast.Operations.Simple_Operation (Op.all))
         loop
            begin
               Mast.Operations.Get_Next_Locked_Resource
                 (Mast.Operations.Simple_Operation (Op.all),
                  Shared_Ref,
                  Shared_Iterator);
               if Name (Shared_Ref) = Shared_Name then
                  Mast.Operations.Remove_Locked_Resource
                    (Mast.Operations.Simple_Operation (Op.all),
                     Shared_Ref);
                  Remove (Sop_Dialog.Locked_Tree_Store, Iter);
                  exit;
               end if;
            exception
               when No_More_Items =>
                  exit;
            end;
         end loop;
      end if;

      -- Unlocked
      Row_Selected :=
         Gtk.Tree_View.Get_Selection (Sop_Dialog.Unlocked_Tree_View);
      Get_Selected (Row_Selected, Model, Iter);

      if Iter /= Null_Iter then -- Iter = Null_Iter when no row is selected
         Shared_Name :=
            To_Var_String
              (Get_String (Sop_Dialog.Unlocked_Tree_Store, Iter, 0));
         Mast.Operations.Rewind_Unlocked_Resources
           (Mast.Operations.Simple_Operation (Op.all),
            Shared_Iterator);
         for I in
               1 ..
               Mast.Operations.Num_Of_Unlocked_Resources
                  (Mast.Operations.Simple_Operation (Op.all))
         loop
            begin
               Mast.Operations.Get_Next_Unlocked_Resource
                 (Mast.Operations.Simple_Operation (Op.all),
                  Shared_Ref,
                  Shared_Iterator);
               if Name (Shared_Ref) = Shared_Name then
                  Mast.Operations.Remove_Unlocked_Resource
                    (Mast.Operations.Simple_Operation (Op.all),
                     Shared_Ref);
                  Remove (Sop_Dialog.Unlocked_Tree_Store, Iter);
                  exit;
               end if;
            exception
               when No_More_Items =>
                  exit;
            end;
         end loop;
      end if;

   end Remove_Shared;

   -------------------
   -- Write Locked  -- (Read resource from "add_shared_dialog" and add it to
   --simple_op locked list)
   -------------------
   procedure Write_Locked
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Operation_And_Dialog2_Ref)
   is
      Op                : Operation_Ref            := Data.It;
      Sop_Dialog        : Sop_Dialog_Access        :=
         Sop_Dialog_Access (Data.Dia);
      Add_Shared_Dialog : Add_Shared_Dialog_Access :=
         Add_Shared_Dialog_Access (Data.Dia2);
      Shared_Name       : Var_Strings.Var_String;
      Shared_Index      : Mast.Shared_Resources.Lists.Index;
      Shared_Ref        : Mast.Shared_Resources.Shared_Resource_Ref;
      Parent            : Gtk_Tree_Iter            := Null_Iter;
      Iter              : Gtk_Tree_Iter;
   begin
      if Get_Text (Add_Shared_Dialog.Add_Shared_Entry) = "" then
         Destroy (Add_Shared_Dialog);
      else
         Shared_Name  :=
            To_Var_String (Get_Text (Add_Shared_Dialog.Add_Shared_Entry));
         Shared_Index :=
            Mast.Shared_Resources.Lists.Find
              (Shared_Name,
               The_System.Shared_Resources);
         Shared_Ref   :=
            Mast.Shared_Resources.Lists.Item
              (Shared_Index,
               The_System.Shared_Resources);

         if Shared_Ref /= null then
            Append (Sop_Dialog.Locked_Tree_Store, Iter, Parent);
            Set
              (Sop_Dialog.Locked_Tree_Store,
               Iter,
               Locked_Column,
               Name_Image (Mast.Shared_Resources.Name (Shared_Ref)));
         end if;

         Mast.Operations.Add_Locked_Resource
           (Simple_Operation (Op.all),
            Shared_Ref);
         Destroy (Add_Shared_Dialog);
      end if;
   exception
      when Invalid_Index =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Shared resource not found in system ! ");
         Show_All (Editor_Error_Window);
         Destroy (Add_Shared_Dialog);
   end Write_Locked;

   ---------------------
   -- Write Unlocked  -- (Read resource from "add_shared_dialog" and add it to
   --simple_op unlocked list)
   ---------------------
   procedure Write_Unlocked
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Operation_And_Dialog2_Ref)
   is
      Op                : Operation_Ref            := Data.It;
      Sop_Dialog        : Sop_Dialog_Access        :=
         Sop_Dialog_Access (Data.Dia);
      Add_Shared_Dialog : Add_Shared_Dialog_Access :=
         Add_Shared_Dialog_Access (Data.Dia2);
      Shared_Name       : Var_Strings.Var_String;
      Shared_Index      : Mast.Shared_Resources.Lists.Index;
      Shared_Ref        : Mast.Shared_Resources.Shared_Resource_Ref;
      Parent            : Gtk_Tree_Iter            := Null_Iter;
      Iter              : Gtk_Tree_Iter;
   begin
      if Get_Text (Add_Shared_Dialog.Add_Shared_Entry) = "" then
         Destroy (Add_Shared_Dialog);
      else
         Shared_Name  :=
            To_Var_String (Get_Text (Add_Shared_Dialog.Add_Shared_Entry));
         Shared_Index :=
            Mast.Shared_Resources.Lists.Find
              (Shared_Name,
               The_System.Shared_Resources);
         Shared_Ref   :=
            Mast.Shared_Resources.Lists.Item
              (Shared_Index,
               The_System.Shared_Resources);

         if Shared_Ref /= null then
            Append (Sop_Dialog.Unlocked_Tree_Store, Iter, Parent);
            Set
              (Sop_Dialog.Unlocked_Tree_Store,
               Iter,
               Unlocked_Column,
               Name_Image (Mast.Shared_Resources.Name (Shared_Ref)));
         end if;

         Mast.Operations.Add_Unlocked_Resource
           (Simple_Operation (Op.all),
            Shared_Ref);
         Destroy (Add_Shared_Dialog);
      end if;
   exception
      when Invalid_Index =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Shared resource not found in system ! ");
         Show_All (Editor_Error_Window);
         Destroy (Add_Shared_Dialog);
   end Write_Unlocked;

   ---------------------------
   -- Write Locked Unlocked --  (Reads resource from "add_shared_dialog" and
   --adds it to both locked and unlocked lists)
   ---------------------------
   procedure Write_Locked_Unlocked
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Operation_And_Dialog2_Ref)
   is
      Op                             : Operation_Ref            := Data.It;
      Sop_Dialog                     : Sop_Dialog_Access        :=
         Sop_Dialog_Access (Data.Dia);
      Add_Shared_Dialog              : Add_Shared_Dialog_Access :=
         Add_Shared_Dialog_Access (Data.Dia2);
      Shared_Name                    : Var_Strings.Var_String;
      Shared_Index                   : Mast.Shared_Resources.Lists.Index;
      Shared_Ref                     :
        Mast.Shared_Resources.Shared_Resource_Ref;
      Locked_Parent, Unlocked_Parent : Gtk_Tree_Iter            := Null_Iter;
      Locked_Iter, Unlocked_Iter     : Gtk_Tree_Iter;
   begin
      if Get_Text (Add_Shared_Dialog.Add_Shared_Entry) = "" then
         Destroy (Add_Shared_Dialog);
      else
         Shared_Name  :=
            To_Var_String (Get_Text (Add_Shared_Dialog.Add_Shared_Entry));
         Shared_Index :=
            Mast.Shared_Resources.Lists.Find
              (Shared_Name,
               The_System.Shared_Resources);
         Shared_Ref   :=
            Mast.Shared_Resources.Lists.Item
              (Shared_Index,
               The_System.Shared_Resources);

         if Shared_Ref /= null then
            Append (Sop_Dialog.Locked_Tree_Store, Locked_Iter, Locked_Parent);
            Set
              (Sop_Dialog.Locked_Tree_Store,
               Locked_Iter,
               Locked_Column,
               Name_Image (Mast.Shared_Resources.Name (Shared_Ref)));
            Prepend
              (Sop_Dialog.Unlocked_Tree_Store,
               Unlocked_Iter,
               Unlocked_Parent);
            Set
              (Sop_Dialog.Unlocked_Tree_Store,
               Unlocked_Iter,
               Unlocked_Column,
               Name_Image (Mast.Shared_Resources.Name (Shared_Ref)));
         end if;

         Mast.Operations.Add_Resource (Simple_Operation (Op.all), Shared_Ref);
         Destroy (Add_Shared_Dialog);
      end if;
   exception
      when Invalid_Index =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Shared resource not found in system ! ");
         Show_All (Editor_Error_Window);
         Destroy (Add_Shared_Dialog);
   end Write_Locked_Unlocked;

   ------------------
   -- Add Shared   -- (Shows "add_shared_dialog")
   ------------------
   procedure Add_Shared
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Operation_And_Dialog_Ref)
   is
      Add_Shared_Dialog : Add_Shared_Dialog_Access;
      Data2             : Operation_And_Dialog2_Ref :=
         new Operation_And_Dialog2;
   begin
      Gtk_New (Add_Shared_Dialog);
      Show_All (Add_Shared_Dialog);

      Data2.It   := Data.It;
      Data2.Dia  := Data.Dia;
      Data2.Dia2 := Gtk_Dialog (Add_Shared_Dialog);

      Operation_And_Dialog2_Cb.Connect
        (Add_Shared_Dialog.Add_Locked_Button,
         "clicked",
         Operation_And_Dialog2_Cb.To_Marshaller (Write_Locked'Access),
         Data2);
      Operation_And_Dialog2_Cb.Connect
        (Add_Shared_Dialog.Add_Unlock_Button,
         "clicked",
         Operation_And_Dialog2_Cb.To_Marshaller (Write_Unlocked'Access),
         Data2);
      Operation_And_Dialog2_Cb.Connect
        (Add_Shared_Dialog.Add_Lock_Unlock_Button,
         "clicked",
         Operation_And_Dialog2_Cb.To_Marshaller
            (Write_Locked_Unlocked'Access),
         Data2);
   end Add_Shared;

   -------------------
   -- New Simple    -- (Adds a new simple op. to the canvas and to the lists
   --of the systems)
   -------------------
   procedure New_Simple
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Operation_And_Dialog_Ref)
   is
      Item       : ME_Operation_Ref  := Data.It;
      Sop_Dialog : Sop_Dialog_Access := Sop_Dialog_Access (Data.Dia);
   begin
      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (Sop_Dialog.Op_Name_Entry)))
      then
         Write_Parameters (Item, Gtk_Dialog (Sop_Dialog));
         Mast.Operations.Lists.Add (Item.Op, The_System.Operations);
         Mast_Editor.Operations.Lists.Add (Item, Editor_System.Me_Operations);
         Set_Screen_Size (Item, Item.W, Item.H);
         Put (Operation_Canvas, Item);
         Refresh_Canvas (Operation_Canvas);
         Show_Item (Operation_Canvas, Item);
         Destroy (Sop_Dialog);
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
   end New_Simple;

   --------------------
   -- New Message Tx -- (Add new message_tx_op. to canvas and to the lists of
   --the systems)
   --------------------
   procedure New_Message_Tx
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Operation_And_Dialog_Ref)
   is

      Item              : ME_Operation_Ref         := Data.It;
      Message_Tx_Dialog : Message_Tx_Dialog_Access :=
         Message_Tx_Dialog_Access (Data.Dia);

   begin
      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (Message_Tx_Dialog.Op_Name_Entry)))
      then

         Write_Parameters (Item, Gtk_Dialog (Message_Tx_Dialog));

         Mast.Operations.Lists.Add (Item.Op, The_System.Operations);
         Mast_Editor.Operations.Lists.Add (Item, Editor_System.Me_Operations);
         Set_Screen_Size (Item, Item.W, Item.H);
         Put (Operation_Canvas, Item);
         Refresh_Canvas (Operation_Canvas);
         Show_Item (Operation_Canvas, Item);
         Destroy (Message_Tx_Dialog);
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
         Destroy (Message_Tx_Dialog);
      when Already_Exists =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " The operation already exists!!!");
         Show_All (Editor_Error_Window);
         Destroy (Message_Tx_Dialog);
   end New_Message_Tx;

   -------------------
   -- New Composite -- (Add new composite op. to the canvas and to the lists
   --of the systems)
   -------------------
   procedure New_Composite
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Operation_And_Dialog_Ref)
   is
      Op_Ref      : Operation_Ref := new Composite_Operation;
      Op_Temp     : Composite_Operation;
      Op_Iterator : Mast.Operations.Operation_Iteration_Object;

      Item       : ME_Operation_Ref  := Data.It;
      Cop_Dialog : Cop_Dialog_Access := Cop_Dialog_Access (Data.Dia);

   begin

      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (Cop_Dialog.Op_Name_Entry)))
      then
         if Mast.Operations.Num_Of_Operations
               (Composite_Operation (Item.Op.all)) <
            1
         then
            Gtk_New (Editor_Error_Window);
            Set_Text
              (Editor_Error_Window.Label,
               "Operation must contain at least one operation!");
            Show_All (Editor_Error_Window);
         else
            if (Get_Text (Get_Entry (Cop_Dialog.Op_Type_Combo)) =
                "Composite")
            then
               Op_Temp                          :=
                 Composite_Operation (Item.Op.all);
               Composite_Operation (Op_Ref.all) := Op_Temp;
               Item.Op                          := Op_Ref;
            end if;

            Write_Parameters (Item, Gtk_Dialog (Cop_Dialog));

            Mast.Operations.Lists.Add (Item.Op, The_System.Operations);
            Mast_Editor.Operations.Lists.Add
              (Item,
               Editor_System.Me_Operations);
            Set_Screen_Size (Item, Item.W, Item.H);
            Put (Operation_Canvas, Item);
            Refresh_Canvas (Operation_Canvas);
            Show_Item (Operation_Canvas, Item);
            Draw_Composite_Operation_Links (Item);
            Destroy (Cop_Dialog);
         end if;
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
         Destroy (Cop_Dialog);
      when Already_Exists =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " The operation already exists!!!");
         Show_All (Editor_Error_Window);
         Destroy (Cop_Dialog);
   end New_Composite;

   -------------------------
   -- Show Simple Dialog -- (Show "Sop_dialog" with default params)
   -------------------------
   procedure Show_Simple_Dialog (Widget : access Gtk_Button_Record'Class) is
      Item       : ME_Operation_Ref            := new ME_Simple_Operation;
      Oper       : Operation_Ref               := new Simple_Operation;
      Sop_Dialog : Sop_Dialog_Access;
      Data       : Operation_And_Dialog_Ref    := new Operation_And_Dialog;
      Me_Data    : ME_Operation_And_Dialog_Ref := new ME_Operation_And_Dialog;
   begin
      Item.W           := Op_Width;
      Item.H           := Op_Height;
      Item.Canvas_Name := To_Var_String ("Operation_Canvas");
      Item.Color_Name  := Sop_Color;
      Item.Op          := Oper;

      Gtk_New (Sop_Dialog);
      Read_Parameters (Item, Gtk_Dialog (Sop_Dialog));
      Data.It     := Oper;
      Data.Dia    := Gtk_Dialog (Sop_Dialog);
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Sop_Dialog);

      Operation_And_Dialog_Cb.Connect
        (Sop_Dialog.Add_Res_Button,
         "clicked",
         Operation_And_Dialog_Cb.To_Marshaller (Add_Shared'Access),
         Data);

      Operation_And_Dialog_Cb.Connect
        (Sop_Dialog.Remove_Res_Button,
         "clicked",
         Operation_And_Dialog_Cb.To_Marshaller (Remove_Shared'Access),
         Data);

      Me_Operation_And_Dialog_Cb.Connect
        (Sop_Dialog.Ok_Button,
         "clicked",
         Me_Operation_And_Dialog_Cb.To_Marshaller (New_Simple'Access),
         Me_Data);

   end Show_Simple_Dialog;

   -----------------------------
   -- Show Message Tx Dialog -- (Show "Message_Tx_Dialog" with default params)
   -----------------------------
   procedure Show_Message_Tx_Dialog
     (Widget : access Gtk_Button_Record'Class)
   is
      Item : ME_Operation_Ref := new Me_Message_Transmission_Operation;
      Oper : Operation_Ref    := new Message_Transmission_Operation;

      Message_Tx_Dialog : Message_Tx_Dialog_Access;
      Me_Data           : ME_Operation_And_Dialog_Ref :=
         new ME_Operation_And_Dialog;

   begin
      Item.W           := Op_Width;
      Item.H           := Op_Height;
      Item.Canvas_Name := To_Var_String ("Operation_Canvas");
      Item.Color_Name  := Txop_Color;
      Item.Op          := Oper;

      Gtk_New (Message_Tx_Dialog);
      Read_Parameters (Item, Gtk_Dialog (Message_Tx_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Message_Tx_Dialog);

      Me_Operation_And_Dialog_Cb.Connect
        (Message_Tx_Dialog.Ok_Button,
         "clicked",
         Me_Operation_And_Dialog_Cb.To_Marshaller (New_Message_Tx'Access),
         Me_Data);

   end Show_Message_Tx_Dialog;

   ---------------------------
   -- Show Composite Dialog -- (Show "Cop_dialog" with default params)
   ---------------------------
   procedure Show_Composite_Dialog
     (Widget : access Gtk_Button_Record'Class)
   is
      Item : ME_Operation_Ref := new ME_Composite_Operation;
      Oper : Operation_Ref    := new Enclosing_Operation;

      Cop_Dialog : Cop_Dialog_Access;
      Data       : Operation_And_Dialog_Ref    := new Operation_And_Dialog;
      Me_Data    : ME_Operation_And_Dialog_Ref := new ME_Operation_And_Dialog;

   begin
      Item.W           := Op_Width;
      Item.H           := Op_Height;
      Item.Canvas_Name := To_Var_String ("Operation_Canvas");
      Item.Color_Name  := Cop_Color;
      Item.Op          := Oper;

      Gtk_New (Cop_Dialog);
      Read_Parameters (Item, Gtk_Dialog (Cop_Dialog));
      Data.It     := Oper;
      Data.Dia    := Gtk_Dialog (Cop_Dialog);
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Cop_Dialog);

      Operation_And_Dialog_Cb.Connect
        (Cop_Dialog.Add_Op_Button,
         "clicked",
         Operation_And_Dialog_Cb.To_Marshaller (Add_Operation'Access),
         Data);

      Operation_And_Dialog_Cb.Connect
        (Cop_Dialog.Remove_Op_Button,
         "clicked",
         Operation_And_Dialog_Cb.To_Marshaller (Remove_Operation'Access),
         Data);

      Me_Operation_And_Dialog_Cb.Connect
        (Cop_Dialog.Ok_Button,
         "clicked",
         Me_Operation_And_Dialog_Cb.To_Marshaller (New_Composite'Access),
         Me_Data);

   end Show_Composite_Dialog;

   ----------------
   -- Remove_Op  -- Removes operation from the system
   ----------------
   procedure Remove_Op
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Operation_Ref)
   is
      Op_Name         : Var_String;
      Op_Index        : Mast.Operations.Lists.Index;
      Item_Deleted    : Mast.Operations.Operation_Ref;
      Me_Op_Index     : Mast_Editor.Operations.Lists.Index;
      Me_Item_Deleted : Mast_Editor.Operations.ME_Operation_Ref;
   begin
      Op_Name      := Name (Item);
      Op_Index     :=
         Mast.Operations.Lists.Find (Op_Name, The_System.Operations);
      Item_Deleted :=
         Mast.Operations.Lists.Item (Op_Index, The_System.Operations);
      if Mast.Transactions.List_References_Operation
           (Item_Deleted,
            The_System.Transactions)
      then
         -- Operation cannot be deleted
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "OPERATION IS REFERENCED BY AN ACTIVITY");
         Show_All (Editor_Error_Window);
         Destroy (Item_Menu);
      elsif Mast.Operations.List_References_Operation
               (Item_Deleted,
                The_System.Operations)
      then
         -- Operation cannot be deleted
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "OPERATION IS REFERENCED BY A COMPOSITE OPERATION");
         Show_All (Editor_Error_Window);
         Destroy (Item_Menu);
      else
         if Message_Dialog
               (" Do you really want to remove this object? ",
                Confirmation,
                Button_Yes or Button_No,
                Button_Yes) =
            Button_Yes
         then
            Mast.Operations.Lists.Delete
              (Op_Index,
               Item_Deleted,
               The_System.Operations);
            Me_Op_Index     :=
               Mast_Editor.Operations.Lists.Find
                 (Op_Name,
                  Editor_System.Me_Operations);
            Me_Item_Deleted :=
               Mast_Editor.Operations.Lists.Item
                 (Me_Op_Index,
                  Editor_System.Me_Operations);
            Mast_Editor.Operations.Lists.Delete
              (Me_Op_Index,
               Me_Item_Deleted,
               Editor_System.Me_Operations);
            Remove (Operation_Canvas, Item);
            Refresh_Canvas (Operation_Canvas);
            Change_Control.Changes_Made;
            Destroy (Item_Menu);
         end if;
      end if;
   exception
      when Invalid_Index =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "ERROR IN OPERATION REMOVAL !!!");
         Show_All (Editor_Error_Window);
         Destroy (Item_Menu);
   end Remove_Op;

   ---------------------------
   -- Simple_Operation_Copy --
   ---------------------------

   function Simple_Operation_Copy
     (Op   : Simple_Operation)
      return Operation_Ref
   is
      Sche_Param, Sche_Param_Copy :
        Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Op_Copy                     : Operation_Ref;
      Temp_Res                    : Shared_Resource_Ref;
      Iterator                    : Resource_Iteration_Object;
      Through                     : Throughput_Value := 1.0;   -- We need to
                                                               --define the
                                                               --Throughput in
                                                               --order to call
                                                               --*_Case_Executi
                                                               --on_Time
                                                               --functions.
                                                               -- The default
                                                               --value is not
                                                               --relevant
                                                               --since it is
                                                               --not used
                                                               --within these
                                                               --functions
   begin
      Op_Copy := new Simple_Operation;
      Init (Simple_Operation (Op_Copy.all), Name (Op));
      Set_Worst_Case_Execution_Time
        (Simple_Operation (Op_Copy.all),
         Worst_Case_Execution_Time (Op, Through));
      Set_Best_Case_Execution_Time
        (Simple_Operation (Op_Copy.all),
         Best_Case_Execution_Time (Op, Through));
      Set_Avg_Case_Execution_Time
        (Simple_Operation (Op_Copy.all),
         Avg_Case_Execution_Time (Op, Through));
      Sche_Param := Mast.Operations.New_Sched_Parameters (Op);
      if Sche_Param = null then
         Sche_Param_Copy := null;
      else
         if Sche_Param.all'Tag = Overridden_FP_Parameters'Tag then
            Sche_Param_Copy :=
              new Overridden_FP_Parameters'(Overridden_FP_Parameters (
              Sche_Param.all));
         elsif Sche_Param.all'Tag =
               Overridden_Permanent_FP_Parameters'Tag
         then
            Sche_Param_Copy :=
              new Overridden_Permanent_FP_Parameters'(
              Overridden_Permanent_FP_Parameters (Sche_Param.all));
         end if;
      end if;
      Mast.Operations.Set_New_Sched_Parameters (Op_Copy.all, Sche_Param_Copy);
      Mast.Operations.Rewind_Locked_Resources (Op, Iterator);
      for I in 1 .. Mast.Operations.Num_Of_Locked_Resources (Op) loop
         Mast.Operations.Get_Next_Locked_Resource (Op, Temp_Res, Iterator);
         Add_Locked_Resource (Simple_Operation (Op_Copy.all), Temp_Res);
      end loop;
      Mast.Operations.Rewind_Unlocked_Resources (Op, Iterator);
      for I in 1 .. Mast.Operations.Num_Of_Unlocked_Resources (Op) loop
         Mast.Operations.Get_Next_Unlocked_Resource (Op, Temp_Res, Iterator);
         Add_Unlocked_Resource (Simple_Operation (Op_Copy.all), Temp_Res);
      end loop;
      return Op_Copy;
   end Simple_Operation_Copy;

   ---------------------
   -- Properties_Sop  -- Shows Simple operation's properties
   ---------------------
   procedure Properties_Sop
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Operation_Ref)
   is
      Temp       : Operation_Ref;
      Double     : Double_Operation_Ref;
      Sop_Dialog : Sop_Dialog_Access;
      Data       : Operation_And_Dialog_Ref    := new Operation_And_Dialog;
      Me_Data    : ME_Operation_And_Dialog_Ref := new ME_Operation_And_Dialog;
   begin
      if Item.Op /= null then
         if Item.Op.all'Tag = Simple_Operation'Tag then
            Temp := Simple_Operation_Copy (Simple_Operation (Item.Op.all));
         end if;
         Double         := new Double_Operation;
         Double.Op      := Item.Op;
         Double.Temp_Op := Temp;
      end if;

      if (Num_Of_Locked_Resources (Simple_Operation (Item.Op.all)) = 0)
        and then (Num_Of_Unlocked_Resources (Simple_Operation (Item.Op.all)) =
                  0)
      then
         String_List.Append (Op_Type_Combo_Items, "Enclosing");
      end if;

      Gtk_New (Sop_Dialog);
      Read_Parameters (Item, Gtk_Dialog (Sop_Dialog));
      Data.It     := Temp;
      Data.Dia    := Gtk_Dialog (Sop_Dialog);
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Sop_Dialog);

      Operation_And_Dialog_Cb.Connect
        (Sop_Dialog.Add_Res_Button,
         "clicked",
         Operation_And_Dialog_Cb.To_Marshaller (Add_Shared'Access),
         Data);

      Operation_And_Dialog_Cb.Connect
        (Sop_Dialog.Remove_Res_Button,
         "clicked",
         Operation_And_Dialog_Cb.To_Marshaller (Remove_Shared'Access),
         Data);

      Double_Operation_Cb.Connect
        (Sop_Dialog.Ok_Button,
         "clicked",
         Double_Operation_Cb.To_Marshaller (Update_Resources_Lists'Access),
         Double);

      Me_Operation_And_Dialog_Cb.Connect
        (Sop_Dialog.Ok_Button,
         "clicked",
         Me_Operation_And_Dialog_Cb.To_Marshaller (Write_Simple'Access),
         Me_Data);

      Me_Operation_And_Dialog_Cb.Connect
        (Get_Entry (Sop_Dialog.Op_Type_Combo),
         "changed",
         Me_Operation_And_Dialog_Cb.To_Marshaller
            (Change_Type_To_Enclosing'Access),
         Me_Data);

      Refresh_Canvas (Operation_Canvas);
      Destroy (Item_Menu);
   end Properties_Sop;

   ---------------------------
   -- Properties_Message_Tx -- Shows Message_Tx_Operation's properties
   ---------------------------
   procedure Properties_Message_Tx
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Operation_Ref)
   is

      Message_Tx_Dialog : Message_Tx_Dialog_Access;
      Me_Data           : ME_Operation_And_Dialog_Ref :=
         new ME_Operation_And_Dialog;

   begin

      Gtk_New (Message_Tx_Dialog);
      Read_Parameters (Item, Gtk_Dialog (Message_Tx_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Message_Tx_Dialog);

      Me_Operation_And_Dialog_Cb.Connect
        (Message_Tx_Dialog.Ok_Button,
         "clicked",
         Me_Operation_And_Dialog_Cb.To_Marshaller (Write_Message_Tx'Access),
         Me_Data);

      Refresh_Canvas (Operation_Canvas);
      Destroy (Item_Menu);
   end Properties_Message_Tx;

   ------------------------------
   -- Composite_Operation_Copy --
   ------------------------------

   function Composite_Operation_Copy
     (Op   : Composite_Operation)
      return Operation_Ref
   is
      Sche_Param, Sche_Param_Copy :
        Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Op_Copy, Temp_Op            : Operation_Ref;
      Iterator                    : Operation_Iteration_Object;
   begin

      Op_Copy := new Composite_Operation;
      Init (Composite_Operation (Op_Copy.all), Name (Op));
      Sche_Param := Mast.Operations.New_Sched_Parameters (Op);
      if Sche_Param = null then
         Sche_Param_Copy := null;
      else
         if Sche_Param.all'Tag = Overridden_FP_Parameters'Tag then
            Sche_Param_Copy :=
              new Overridden_FP_Parameters'(Overridden_FP_Parameters (
              Sche_Param.all));
         elsif Sche_Param.all'Tag =
               Overridden_Permanent_FP_Parameters'Tag
         then
            Sche_Param_Copy :=
              new Overridden_Permanent_FP_Parameters'(
              Overridden_Permanent_FP_Parameters (Sche_Param.all));
         end if;
      end if;
      Mast.Operations.Set_New_Sched_Parameters (Op_Copy.all, Sche_Param_Copy);
      Mast.Operations.Rewind_Operations (Op, Iterator);
      for I in 1 .. Mast.Operations.Num_Of_Operations (Op) loop
         Mast.Operations.Get_Next_Operation (Op, Temp_Op, Iterator);
         Add_Operation (Composite_Operation (Op_Copy.all), Temp_Op);
      end loop;
      return Op_Copy;
   end Composite_Operation_Copy;

   ------------------------------
   -- Enclosing_Operation_Copy --
   ------------------------------

   function Enclosing_Operation_Copy
     (Op   : Enclosing_Operation)
      return Operation_Ref
   is
      Sche_Param, Sche_Param_Copy :
        Mast.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Op_Copy, Temp_Op            : Operation_Ref;
      Iterator                    : Operation_Iteration_Object;
      Through                     : Throughput_Value := 1.0;

      -- We need to define the Throughput in order to call
      --  *_Case_Execution_Time functions.  The default
      --  value is not relevant since it is not used within
      --  these functions

   begin
      Op_Copy := new Enclosing_Operation;
      Init (Enclosing_Operation (Op_Copy.all), Name (Op));
      Set_Worst_Case_Execution_Time
        (Enclosing_Operation (Op_Copy.all),
         Worst_Case_Execution_Time (Op, Through));
      Set_Best_Case_Execution_Time
        (Enclosing_Operation (Op_Copy.all),
         Best_Case_Execution_Time (Op, Through));
      Set_Avg_Case_Execution_Time
        (Enclosing_Operation (Op_Copy.all),
         Avg_Case_Execution_Time (Op, Through));
      Sche_Param := Mast.Operations.New_Sched_Parameters (Op);
      if Sche_Param = null then
         Sche_Param_Copy := null;
      else
         if Sche_Param.all'Tag = Overridden_FP_Parameters'Tag then
            Sche_Param_Copy :=
              new Overridden_FP_Parameters'(Overridden_FP_Parameters (
              Sche_Param.all));
         elsif Sche_Param.all'Tag =
               Overridden_Permanent_FP_Parameters'Tag
         then
            Sche_Param_Copy :=
              new Overridden_Permanent_FP_Parameters'(
              Overridden_Permanent_FP_Parameters (Sche_Param.all));
         end if;
      end if;
      Mast.Operations.Set_New_Sched_Parameters (Op_Copy.all, Sche_Param_Copy);
      Mast.Operations.Rewind_Operations (Op, Iterator);
      for I in 1 .. Mast.Operations.Num_Of_Operations (Op) loop
         Mast.Operations.Get_Next_Operation (Op, Temp_Op, Iterator);
         Add_Operation (Composite_Operation (Op_Copy.all), Temp_Op);
      end loop;
      return Op_Copy;
   end Enclosing_Operation_Copy;

   --------------------
   -- Properties_Cop -- Shows Composite operation's properties
   --------------------
   procedure Properties_Cop
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Operation_Ref)
   is
      Temp       : Operation_Ref;
      Double     : Double_Operation_Ref;
      Cop_Dialog : Cop_Dialog_Access;
      Data       : Operation_And_Dialog_Ref    := new Operation_And_Dialog;
      Me_Data    : ME_Operation_And_Dialog_Ref := new ME_Operation_And_Dialog;
   begin
      if Item.Op /= null then
         if Item.Op.all'Tag = Composite_Operation'Tag then
            Temp :=
               Composite_Operation_Copy (Composite_Operation (Item.Op.all));
         elsif Item.Op.all'Tag = Enclosing_Operation'Tag then
            Temp :=
               Enclosing_Operation_Copy (Enclosing_Operation (Item.Op.all));
         end if;
         Double         := new Double_Operation;
         Double.Op      := Item.Op;
         Double.Temp_Op := Temp;
      end if;

      Gtk_New (Cop_Dialog);
      Read_Parameters (Item, Gtk_Dialog (Cop_Dialog));
      Data.It     := Temp;
      Data.Dia    := Gtk_Dialog (Cop_Dialog);
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Cop_Dialog);

      Operation_And_Dialog_Cb.Connect
        (Cop_Dialog.Add_Op_Button,
         "clicked",
         Operation_And_Dialog_Cb.To_Marshaller (Add_Operation'Access),
         Data);
      Operation_And_Dialog_Cb.Connect
        (Cop_Dialog.Remove_Op_Button,
         "clicked",
         Operation_And_Dialog_Cb.To_Marshaller (Remove_Operation'Access),
         Data);

      Double_Operation_Cb.Connect
        (Cop_Dialog.Ok_Button,
         "clicked",
         Double_Operation_Cb.To_Marshaller (Update_Operations_List'Access),
         Double);

      Me_Operation_And_Dialog_Cb.Connect
        (Cop_Dialog.Ok_Button,
         "clicked",
         Me_Operation_And_Dialog_Cb.To_Marshaller (Write_Composite'Access),
         Me_Data);

      Refresh_Canvas (Operation_Canvas);
      Destroy (Item_Menu);
   end Properties_Cop;

   ---------------------------
   -- View_Shared_Resources -- Show Auxiliary Window with operation's resources
   ---------------------------
   procedure View_Shared_Resources
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Operation_Ref)
   is
      Temp_Item     : ME_Operation_Ref;
      Op_Ref        : Operation_Ref := Item.Op;
      Temp_List     : Mast_Editor.Shared_Resources.Lists.List;
      Me_Shared_Ref : Mast_Editor.Shared_Resources.ME_Shared_Resource_Ref;
      Shared_Ref    : Mast.Shared_Resources.Shared_Resource_Ref;
      Res_Iterator  : Mast.Operations.Resource_Iteration_Object;
      Op_Iterator   : Mast.Operations.Operation_Iteration_Object;
      Simple_Ref    : Operation_Ref;
      Aux           : Aux_Window_Access;
      Init_X        : Gint          := 10;
      Init_Y        : Gint          := 60;
      Coord_X       : Gint          := 300;
      Coord_Y       : Gint          := 10;
      Space         : Gint          := 75;
   begin
      if Item.all'Tag = ME_Simple_Operation'Tag then
         Temp_Item            := new ME_Simple_Operation;
         Temp_Item.Color_Name := Sop_Color;
      elsif Item.all'Tag = ME_Composite_Operation'Tag then
         Temp_Item            := new ME_Composite_Operation;
         Temp_Item.Color_Name := Cop_Color;
      end if;
      Temp_Item.W           := Op_Width;
      Temp_Item.H           := Op_Height;
      Temp_Item.Canvas_Name := To_Var_String ("Aux_Canvas");
      Temp_Item.Op          := Item.Op;
      Gtk_New (Aux);
      Set_Title (Aux, "Shared Resources of the Operation");
      Set_Screen_Size (Temp_Item, Temp_Item.W, Temp_Item.H);
      Put (Aux.Aux_Canvas, Temp_Item, Init_X, Init_Y);

      if Item.all'Tag = ME_Simple_Operation'Tag then
         -- Locked Resources --
         Rewind_Locked_Resources
           (Simple_Operation (Op_Ref.all),
            Res_Iterator);
         for I in
               1 .. Num_Of_Locked_Resources (Simple_Operation (Op_Ref.all))
         loop
            Get_Next_Locked_Resource
              (Simple_Operation (Op_Ref.all),
               Shared_Ref,
               Res_Iterator);
            if Shared_Ref.all'Tag = Immediate_Ceiling_Resource'Tag then
               Me_Shared_Ref := new ME_Immediate_Ceiling_Resource;
            elsif Shared_Ref.all'Tag =
                  Priority_Inheritance_Resource'Tag
            then
               Me_Shared_Ref := new ME_Priority_Inheritance_Resource;
            elsif Shared_Ref.all'Tag = SRP_Resource'Tag then
               Me_Shared_Ref := new ME_SRP_Resource;
            end if;
            Me_Shared_Ref.W           := Share_Width;
            Me_Shared_Ref.H           := Share_Height;
            Me_Shared_Ref.Canvas_Name := To_Var_String ("Aux_Canvas");
            Me_Shared_Ref.Color_Name  := Share_Color;
            Me_Shared_Ref.Share       := Shared_Ref;
            begin
               Mast_Editor.Shared_Resources.Lists.Add
                 (Me_Shared_Ref,
                  Temp_List);
               Set_Screen_Size
                 (Me_Shared_Ref,
                  Me_Shared_Ref.W,
                  Me_Shared_Ref.H);
               Put (Aux.Aux_Canvas, Me_Shared_Ref, Coord_X, Coord_Y);
               Coord_Y := Coord_Y + Space;
               Add_Canvas_Link (Aux.Aux_Canvas, Temp_Item, Me_Shared_Ref);
            exception
               when Already_Exists =>
                  null;
            end;
         end loop;
         -- Unlocked Resources --
         Rewind_Unlocked_Resources
           (Simple_Operation (Op_Ref.all),
            Res_Iterator);
         for I in
               1 ..
               Num_Of_Unlocked_Resources (Simple_Operation (Op_Ref.all))
         loop
            Get_Next_Unlocked_Resource
              (Simple_Operation (Op_Ref.all),
               Shared_Ref,
               Res_Iterator);
            if Shared_Ref.all'Tag = Immediate_Ceiling_Resource'Tag then
               Me_Shared_Ref := new ME_Immediate_Ceiling_Resource;
            elsif Shared_Ref.all'Tag =
                  Priority_Inheritance_Resource'Tag
            then
               Me_Shared_Ref := new ME_Priority_Inheritance_Resource;
            elsif Shared_Ref.all'Tag = SRP_Resource'Tag then
               Me_Shared_Ref := new ME_SRP_Resource;
            end if;
            Me_Shared_Ref.W           := Share_Width;
            Me_Shared_Ref.H           := Share_Height;
            Me_Shared_Ref.Canvas_Name := To_Var_String ("Aux_Canvas");
            Me_Shared_Ref.Color_Name  := Share_Color;
            Me_Shared_Ref.Share       := Shared_Ref;
            begin
               Mast_Editor.Shared_Resources.Lists.Add
                 (Me_Shared_Ref,
                  Temp_List);
               Set_Screen_Size
                 (Me_Shared_Ref,
                  Me_Shared_Ref.W,
                  Me_Shared_Ref.H);
               Put (Aux.Aux_Canvas, Me_Shared_Ref, Coord_X, Coord_Y);
               Coord_Y := Coord_Y + Space;
               Add_Canvas_Link (Aux.Aux_Canvas, Temp_Item, Me_Shared_Ref);
            exception
               when Already_Exists =>
                  null;
            end;
         end loop;

      elsif Item.all'Tag = ME_Composite_Operation'Tag then
         Rewind_Operations (Composite_Operation (Op_Ref.all), Op_Iterator);
         for I in 1 .. Num_Of_Operations (Composite_Operation (Op_Ref.all))
         loop
            begin
               Get_Next_Operation
                 (Composite_Operation (Op_Ref.all),
                  Simple_Ref,
                  Op_Iterator);
               -- Locked Resources --
               Rewind_Locked_Resources
                 (Simple_Operation (Simple_Ref.all),
                  Res_Iterator);
               for I in
                     1 ..
                     Num_Of_Locked_Resources
                        (Simple_Operation (Simple_Ref.all))
               loop
                  Get_Next_Locked_Resource
                    (Simple_Operation (Simple_Ref.all),
                     Shared_Ref,
                     Res_Iterator);
                  if Shared_Ref.all'Tag =
                     Immediate_Ceiling_Resource'Tag
                  then
                     Me_Shared_Ref := new ME_Immediate_Ceiling_Resource;
                  elsif Shared_Ref.all'Tag =
                        Priority_Inheritance_Resource'Tag
                  then
                     Me_Shared_Ref := new ME_Priority_Inheritance_Resource;
                  elsif Shared_Ref.all'Tag = SRP_Resource'Tag then
                     Me_Shared_Ref := new ME_SRP_Resource;
                  end if;
                  Me_Shared_Ref.W           := Share_Width;
                  Me_Shared_Ref.H           := Share_Height;
                  Me_Shared_Ref.Canvas_Name := To_Var_String ("Aux_Canvas");
                  Me_Shared_Ref.Color_Name  := Share_Color;
                  Me_Shared_Ref.Share       := Shared_Ref;
                  begin
                     Mast_Editor.Shared_Resources.Lists.Add
                       (Me_Shared_Ref,
                        Temp_List);
                     Set_Screen_Size
                       (Me_Shared_Ref,
                        Me_Shared_Ref.W,
                        Me_Shared_Ref.H);
                     Put (Aux.Aux_Canvas, Me_Shared_Ref, Coord_X, Coord_Y);
                     Coord_Y := Coord_Y + Space;
                     Add_Canvas_Link
                       (Aux.Aux_Canvas,
                        Temp_Item,
                        Me_Shared_Ref);
                  exception
                     when Already_Exists =>
                        null;
                  end;
               end loop;
               -- Unlocked Resources --
               Rewind_Unlocked_Resources
                 (Simple_Operation (Simple_Ref.all),
                  Res_Iterator);
               for I in
                     1 ..
                     Num_Of_Unlocked_Resources
                        (Simple_Operation (Simple_Ref.all))
               loop
                  Get_Next_Unlocked_Resource
                    (Simple_Operation (Simple_Ref.all),
                     Shared_Ref,
                     Res_Iterator);
                  if Shared_Ref.all'Tag =
                     Immediate_Ceiling_Resource'Tag
                  then
                     Me_Shared_Ref := new ME_Immediate_Ceiling_Resource;
                  elsif Shared_Ref.all'Tag =
                        Priority_Inheritance_Resource'Tag
                  then
                     Me_Shared_Ref := new ME_Priority_Inheritance_Resource;
                  elsif Shared_Ref.all'Tag = SRP_Resource'Tag then
                     Me_Shared_Ref := new ME_SRP_Resource;
                  end if;
                  Me_Shared_Ref.W           := Share_Width;
                  Me_Shared_Ref.H           := Share_Height;
                  Me_Shared_Ref.Canvas_Name := To_Var_String ("Aux_Canvas");
                  Me_Shared_Ref.Color_Name  := Share_Color;
                  Me_Shared_Ref.Share       := Shared_Ref;
                  begin
                     Mast_Editor.Shared_Resources.Lists.Add
                       (Me_Shared_Ref,
                        Temp_List);
                     Set_Screen_Size
                       (Me_Shared_Ref,
                        Me_Shared_Ref.W,
                        Me_Shared_Ref.H);
                     Put (Aux.Aux_Canvas, Me_Shared_Ref, Coord_X, Coord_Y);
                     Coord_Y := Coord_Y + Space;
                     Add_Canvas_Link
                       (Aux.Aux_Canvas,
                        Temp_Item,
                        Me_Shared_Ref);
                  exception
                     when Already_Exists =>
                        null;
                  end;
               end loop;
            exception
               when No_More_Items =>
                  exit;
            end;
         end loop;
      end if;
      Refresh_Canvas (Aux.Aux_Canvas);
      Show_All (Aux);
   end View_Shared_Resources;

   ---------------------
   -- On Button Click --
   ---------------------
   procedure On_Button_Click
     (Item  : access ME_Simple_Operation;
      Event : Gdk.Event.Gdk_Event_Button)
   is
      Temp        : Operation_Ref;
      Double      : Double_Operation_Ref;
      Num_Button  : Guint;
      Event_Type  : Gdk_Event_Type;
      View_Shared : Gtk_Menu_Item;
      Sop_Dialog  : Sop_Dialog_Access;
      Data        : Operation_And_Dialog_Ref    := new Operation_And_Dialog;
      Me_Data     : ME_Operation_And_Dialog_Ref :=
         new ME_Operation_And_Dialog;
   begin
      if Event /= null
        and then Item.Canvas_Name /= To_Var_String ("Aux_Canvas")
      then
         Event_Type := Get_Event_Type (Event);
         if Event_Type = Gdk_2button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (1) then

               if Item.Op /= null then
                  if Item.Op.all'Tag = Simple_Operation'Tag then
                     Temp :=
                        Simple_Operation_Copy
                          (Simple_Operation (Item.Op.all));
                  end if;
                  Double         := new Double_Operation;
                  Double.Op      := Item.Op;
                  Double.Temp_Op := Temp;
               end if;

               if (Num_Of_Locked_Resources (Simple_Operation (Item.Op.all)) =
                   0)
                 and then (Num_Of_Unlocked_Resources
                              (Simple_Operation (Item.Op.all)) =
                           0)
               then
                  String_List.Append (Op_Type_Combo_Items, "Enclosing");
               end if;

               Gtk_New (Sop_Dialog);
               Read_Parameters (Item, Gtk_Dialog (Sop_Dialog));
               Data.It     := Temp;
               Data.Dia    := Gtk_Dialog (Sop_Dialog);
               Me_Data.It  := ME_Operation_Ref (Item);
               Me_Data.Dia := Gtk_Dialog (Sop_Dialog);

               Operation_And_Dialog_Cb.Connect
                 (Sop_Dialog.Add_Res_Button,
                  "clicked",
                  Operation_And_Dialog_Cb.To_Marshaller (Add_Shared'Access),
                  Data);

               Operation_And_Dialog_Cb.Connect
                 (Sop_Dialog.Remove_Res_Button,
                  "clicked",
                  Operation_And_Dialog_Cb.To_Marshaller
                     (Remove_Shared'Access),
                  Data);

               Double_Operation_Cb.Connect
                 (Sop_Dialog.Ok_Button,
                  "clicked",
                  Double_Operation_Cb.To_Marshaller
                     (Update_Resources_Lists'Access),
                  Double);

               Me_Operation_And_Dialog_Cb.Connect
                 (Sop_Dialog.Ok_Button,
                  "clicked",
                  Me_Operation_And_Dialog_Cb.To_Marshaller
                     (Write_Simple'Access),
                  Me_Data);

               Me_Operation_And_Dialog_Cb.Connect
                 (Get_Entry (Sop_Dialog.Op_Type_Combo),
                  "changed",
                  Me_Operation_And_Dialog_Cb.To_Marshaller
                     (Change_Type_To_Enclosing'Access),
                  Me_Data);
            end if;
         elsif Event_Type = Button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (3) then
               Gtk_New (Item_Menu);
               --We add a new option to item_menu
               Gtk_New (View_Shared, "View Shared Resources");
               Set_Right_Justify (View_Shared, False);
               Prepend (Item_Menu, View_Shared);
               Show (View_Shared);
               -------------------
               Button_Cb.Connect
                 (View_Shared,
                  "activate",
                  Button_Cb.To_Marshaller (View_Shared_Resources'Access),
                  ME_Operation_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Remove,
                  "activate",
                  Button_Cb.To_Marshaller (Remove_Op'Access),
                  ME_Operation_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Properties,
                  "activate",
                  Button_Cb.To_Marshaller (Properties_Sop'Access),
                  ME_Operation_Ref (Item));
            end if;
         end if;
      end if;
   exception
      when Storage_Error =>
         null;
   end On_Button_Click;

   ---------------------
   -- On Button Click --
   ---------------------
   procedure On_Button_Click
     (Item  : access Me_Message_Transmission_Operation;
      Event : Gdk.Event.Gdk_Event_Button)
   is
      Num_Button        : Guint;
      Event_Type        : Gdk_Event_Type;
      Message_Tx_Dialog : Message_Tx_Dialog_Access;
      Me_Data           : ME_Operation_And_Dialog_Ref :=
         new ME_Operation_And_Dialog;
   begin
      if Event /= null then
         Event_Type := Get_Event_Type (Event);
         if Event_Type = Gdk_2button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (1) then

               Gtk_New (Message_Tx_Dialog);
               Read_Parameters (Item, Gtk_Dialog (Message_Tx_Dialog));
               Me_Data.It  := ME_Operation_Ref (Item);
               Me_Data.Dia := Gtk_Dialog (Message_Tx_Dialog);

               Me_Operation_And_Dialog_Cb.Connect
                 (Message_Tx_Dialog.Ok_Button,
                  "clicked",
                  Me_Operation_And_Dialog_Cb.To_Marshaller
                     (Write_Message_Tx'Access),
                  Me_Data);
            end if;
         elsif Event_Type = Button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (3) then
               Gtk_New (Item_Menu);
               Button_Cb.Connect
                 (Item_Menu.Remove,
                  "activate",
                  Button_Cb.To_Marshaller (Remove_Op'Access),
                  ME_Operation_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Properties,
                  "activate",
                  Button_Cb.To_Marshaller (Properties_Message_Tx'Access),
                  ME_Operation_Ref (Item));
            end if;
         end if;
      end if;
   exception
      when Storage_Error =>
         null;
   end On_Button_Click;

   ---------------------
   -- On Button Click --
   ---------------------
   procedure On_Button_Click
     (Item  : access ME_Composite_Operation;
      Event : Gdk.Event.Gdk_Event_Button)
   is
      Temp        : Operation_Ref;
      Double      : Double_Operation_Ref;
      Num_Button  : Guint;
      Event_Type  : Gdk_Event_Type;
      View_Shared : Gtk_Menu_Item;
      Cop_Dialog  : Cop_Dialog_Access;
      Data        : Operation_And_Dialog_Ref    := new Operation_And_Dialog;
      Me_Data     : ME_Operation_And_Dialog_Ref :=
         new ME_Operation_And_Dialog;
   begin
      if Event /= null
        and then Item.Canvas_Name /= To_Var_String ("Aux_Canvas")
      then
         Event_Type := Get_Event_Type (Event);
         if Event_Type = Gdk_2button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (1) then

               if Item.Op /= null then
                  if Item.Op.all'Tag = Composite_Operation'Tag then
                     Temp :=
                        Composite_Operation_Copy
                          (Composite_Operation (Item.Op.all));
                  elsif Item.Op.all'Tag = Enclosing_Operation'Tag then
                     Temp :=
                        Enclosing_Operation_Copy
                          (Enclosing_Operation (Item.Op.all));
                  end if;
                  Double         := new Double_Operation;
                  Double.Op      := Item.Op;
                  Double.Temp_Op := Temp;
               end if;

               Gtk_New (Cop_Dialog);
               Read_Parameters (Item, Gtk_Dialog (Cop_Dialog));
               Data.It     := Temp;
               Data.Dia    := Gtk_Dialog (Cop_Dialog);
               Me_Data.It  := ME_Operation_Ref (Item);
               Me_Data.Dia := Gtk_Dialog (Cop_Dialog);

               Operation_And_Dialog_Cb.Connect
                 (Cop_Dialog.Add_Op_Button,
                  "clicked",
                  Operation_And_Dialog_Cb.To_Marshaller
                     (Add_Operation'Access),
                  Data);
               Operation_And_Dialog_Cb.Connect
                 (Cop_Dialog.Remove_Op_Button,
                  "clicked",
                  Operation_And_Dialog_Cb.To_Marshaller
                     (Remove_Operation'Access),
                  Data);

               Double_Operation_Cb.Connect
                 (Cop_Dialog.Ok_Button,
                  "clicked",
                  Double_Operation_Cb.To_Marshaller
                     (Update_Operations_List'Access),
                  Double);

               Me_Operation_And_Dialog_Cb.Connect
                 (Cop_Dialog.Ok_Button,
                  "clicked",
                  Me_Operation_And_Dialog_Cb.To_Marshaller
                     (Write_Composite'Access),
                  Me_Data);
            end if;
         elsif Event_Type = Button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (3) then
               Gtk_New (Item_Menu);
               --We add a new option to item_menu
               Gtk_New (View_Shared, "View Shared Resources");
               Set_Right_Justify (View_Shared, False);
               Prepend (Item_Menu, View_Shared);
               Show (View_Shared);
               -------------------
               Button_Cb.Connect
                 (View_Shared,
                  "activate",
                  Button_Cb.To_Marshaller (View_Shared_Resources'Access),
                  ME_Operation_Ref (Item));

               Button_Cb.Connect
                 (Item_Menu.Remove,
                  "activate",
                  Button_Cb.To_Marshaller (Remove_Op'Access),
                  ME_Operation_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Properties,
                  "activate",
                  Button_Cb.To_Marshaller (Properties_Cop'Access),
                  ME_Operation_Ref (Item));
            end if;
         end if;
      end if;
   exception
      when Storage_Error =>
         null;
   end On_Button_Click;

   -----------------
   -- Simple Mode --
   -----------------
   procedure Simple_Mode (Canvas : access Interactive_Canvas_Record'Class) is
   begin
      Zoom (Canvas, Zoom_Levels (1), 1);
   end Simple_Mode;

   -----------------------
   -- Complete Mode Non --
   -----------------------
   procedure Complete_Mode_Non
     (Canvas : access Interactive_Canvas_Record'Class)
   is
   begin
      Zoom (Canvas, Zoom_Levels (2), 1);
   end Complete_Mode_Non;

   -----------------------
   -- Complete Mode Exp --
   -----------------------
   procedure Complete_Mode_Exp
     (Canvas : access Interactive_Canvas_Record'Class)
   is
   begin
      Zoom (Canvas, Zoom_Levels (3), 1);
   end Complete_Mode_Exp;

   -----------
   -- Print --
   -----------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Simple_Operation;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Mast_Editor.Operations.Print (File, ME_Operation (Item), Indentation);
      Put (File, " ");
      Put (File, "Me_Simple_Operation");
      Put (File, " ");
      Put (File, Mast.IO.Name_Image (Name (Item)));
      Put (File, " ");
      Put (File, Mast.IO.Name_Image (Item.Canvas_Name));
      if Item.X_Coord < 0 then
         Put (File, " ");
      end if;
      Put (File, Gint'Image (Item.X_Coord));
      if Item.Y_Coord < 0 then
         Put (File, " ");
      end if;
      Put (File, Gint'Image (Item.Y_Coord));
      Put (File, " ");
   end Print;

   -----------
   -- Print --
   -----------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out Me_Message_Transmission_Operation;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Mast_Editor.Operations.Print (File, ME_Operation (Item), Indentation);
      Put (File, " ");
      Put (File, "Me_Message_Transmission_Operation");
      Put (File, " ");
      Put (File, Mast.IO.Name_Image (Name (Item)));
      Put (File, " ");
      Put (File, Mast.IO.Name_Image (Item.Canvas_Name));
      if Item.X_Coord < 0 then
         Put (File, " ");
      end if;
      Put (File, Gint'Image (Item.X_Coord));
      if Item.Y_Coord < 0 then
         Put (File, " ");
      end if;
      Put (File, Gint'Image (Item.Y_Coord));
      Put (File, " ");
   end Print;

   -----------
   -- Print --
   -----------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Composite_Operation;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Mast_Editor.Operations.Print (File, ME_Operation (Item), Indentation);
      Put (File, " ");
      if Item.Op /= null and Item.Op.all in Enclosing_Operation then
         Put (File, "Me_Enclosing_Operation");
      else
         Put (File, "Me_Composite_Operation");
      end if;
      Put (File, " ");
      Put (File, Mast.IO.Name_Image (Name (Item)));
      Put (File, " ");
      Put (File, Mast.IO.Name_Image (Item.Canvas_Name));
      if Item.X_Coord < 0 then
         Put (File, " ");
      end if;
      Put (File, Gint'Image (Item.X_Coord));
      if Item.Y_Coord < 0 then
         Put (File, " ");
      end if;
      Put (File, Gint'Image (Item.Y_Coord));
      Put (File, " ");
   end Print;

   ---------
   -- Run --
   ---------
   procedure Run (Frame : access Gtk.Frame.Gtk_Frame_Record'Class) is
      Box, Bbox, Cbox : Gtk_Box;
      Button          : Gtk_Button;
      Scrolled        : Gtk_Scrolled_Window;
      Vseparator      : Gtk_Vseparator;
      Alignment       : Gtk_Alignment;
   begin
      Gtk_New_Vbox (Box, Homogeneous => False);
      Add (Frame, Box);
      Gtk_New (Scrolled);
      Set_Border_Width (Scrolled, 5);
      Pack_Start (Box, Scrolled);
      Gtk_New_Hbox (Bbox, Homogeneous => False);
      Pack_Start (Box, Bbox, False, False, 4);

      Gtk_New_Hbox (Cbox, True, 10);
      Pack_Start (Bbox, Cbox, False, False, 4);

      Gtk_New (Operation_Canvas);
      Configure
        (Operation_Canvas,
         Grid_Size        => 0,
         Annotation_Font  => Pango.Font.From_String (Default_Annotation_Font),
         Arc_Link_Offset  => Default_Arc_Link_Offset,
         Arrow_Angle      => Default_Arrow_Angle,
         Arrow_Length     => Default_Arrow_Length,
         Motion_Threshold => Default_Motion_Threshold);
      Add (Scrolled, Operation_Canvas);

      Gtk_New (Button, "Simple" & ASCII.LF & "Mode");
      Pack_Start (Cbox, Button, False, True, 0);
      Canvas_Cb.Object_Connect
        (Button,
         "clicked",
         Canvas_Cb.To_Marshaller (Simple_Mode'Access),
         Operation_Canvas);

      Gtk_New (Button, "Complete Mode" & ASCII.LF & "(Non-Expanded)");
      Pack_Start (Cbox, Button, False, True, 0);
      Canvas_Cb.Object_Connect
        (Button,
         "clicked",
         Canvas_Cb.To_Marshaller (Complete_Mode_Non'Access),
         Operation_Canvas);

      Gtk_New (Button, "Complete Mode" & ASCII.LF & "(Expanded)");
      Pack_Start (Cbox, Button, False, True, 0);
      Canvas_Cb.Object_Connect
        (Button,
         "clicked",
         Canvas_Cb.To_Marshaller (Complete_Mode_Exp'Access),
         Operation_Canvas);

      Gtk_New_Vseparator (Vseparator);
      Pack_Start (Bbox, Vseparator, False, False, 10);

      Gtk_New (Button, "New Simple" & ASCII.LF & "Operation");
      Pack_Start (Bbox, Button, True, True, 4);
      Button_Callback.Connect
        (Button,
         "clicked",
         Button_Callback.To_Marshaller (Show_Simple_Dialog'Access));

      Gtk_New (Button, "New Composite" & ASCII.LF & "Operation");
      Pack_Start (Bbox, Button, True, True, 4);
      Button_Callback.Connect
        (Button,
         "clicked",
         Button_Callback.To_Marshaller (Show_Composite_Dialog'Access));

      Gtk_New (Button, "New Message" & ASCII.LF & "Tx Operation");
      Pack_Start (Bbox, Button, True, True, 4);
      Button_Callback.Connect
        (Button,
         "clicked",
         Button_Callback.To_Marshaller (Show_Message_Tx_Dialog'Access));

      Gtk_New (Alignment, 0.5, 0.5, 1.0, 1.0);
      Pack_Start (Bbox, Alignment, True, True, 4);
      Gtk_New (Alignment, 0.5, 0.5, 1.0, 1.0);
      Pack_Start (Bbox, Alignment, True, True, 4);
      Gtk_New (Alignment, 0.5, 0.5, 1.0, 1.0);
      Pack_Start (Bbox, Alignment, True, True, 4);

      Realize (Operation_Canvas);

      Gdk_New (Green_Gc, Get_Window (Operation_Canvas));

      Editor_Actions.Load_System_Font (Font, Font1);

      Show_All (Frame);
   end Run;
end Mast_Editor.Operations;
