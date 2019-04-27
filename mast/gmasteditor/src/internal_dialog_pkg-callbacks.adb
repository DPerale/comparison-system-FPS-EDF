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
with System;          use System;
with Glib;            use Glib;
with Gdk.Event;       use Gdk.Event;
with Gdk.Types;       use Gdk.Types;
with Gtk.Accel_Group; use Gtk.Accel_Group;
with Gtk.Object;      use Gtk.Object;
with Gtk.Enums;       use Gtk.Enums;
with Gtk.Style;       use Gtk.Style;
with Gtk.Widget;      use Gtk.Widget;

with Gtk.Combo;                   use Gtk.Combo;
with Gtk.Handlers;                use Gtk.Handlers;
with Gtk.Tree_Selection;          use Gtk.Tree_Selection;
with Ada.Tags;                    use Ada.Tags;
with Mast;                        use Mast;
with Mast.IO;                     use Mast.IO;
with Mast.Events;                 use Mast.Events;
with Mast.Graphs.Links;           use Mast.Graphs.Links;
with Mast.Transactions;           use Mast.Transactions;
with Callbacks_Mast_Editor;       use Callbacks_Mast_Editor;
with Editor_Error_Window_Pkg;     use Editor_Error_Window_Pkg;
with Select_Req_Type_Dialog_Pkg;  use Select_Req_Type_Dialog_Pkg;
with Var_Strings;                 use Var_Strings;
with Select_Ref_Event_Dialog_Pkg; use Select_Ref_Event_Dialog_Pkg;

package body Internal_Dialog_Pkg.Callbacks is

   use Gtk.Arguments;

   package Button_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => Select_Ref_Event_Dialog_Access);

   -------------------------------------------------
   -- Types and packages used to handle dialogs info
   -------------------------------------------------
   type Dialog2 is record
      Dia  : Gtk_Dialog;
      Dia2 : Gtk_Dialog;
   end record;

   type Dialog2_Ref is access all Dialog2;

   package Dialog2_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => Dialog2_Ref);

   ------------------------------
   -- Deadline_Edited_Callback --
   ------------------------------

   procedure Deadline_Edited_Callback
     (Tree_Store : access GObject_Record'Class;
      Params     : Glib.Values.GValues)
   is
      M           : constant Gtk_Tree_Store := Gtk_Tree_Store (Tree_Store);
      Path_String : constant String         := Get_String (Nth (Params, 1));
      Text_Value  : constant GValue         := Nth (Params, 2);
      Iter        : Gtk_Tree_Iter           :=
         Get_Iter_From_String (M, Path_String);
   begin
      Set_Value (M, Iter, Deadline_Val_Column, Text_Value);
   end Deadline_Edited_Callback;

   ---------------------------
   -- Ratio_Edited_Callback --
   ---------------------------

   procedure Ratio_Edited_Callback
     (Tree_Store : access GObject_Record'Class;
      Params     : Glib.Values.GValues)
   is
      M           : constant Gtk_Tree_Store := Gtk_Tree_Store (Tree_Store);
      Path_String : constant String         := Get_String (Nth (Params, 1));
      Text_Value  : constant GValue         := Nth (Params, 2);
      Iter        : Gtk_Tree_Iter           :=
         Get_Iter_From_String (M, Path_String);
   begin
      Set_Value (M, Iter, Ratio_Val_Column, Text_Value);
   end Ratio_Edited_Callback;

   -------------------------
   -- Set_Ref_Event_Entry --
   -------------------------

   procedure Set_Ref_Event_Entry
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Dialog2_Ref)
   is
      Internal_Dialog         : Internal_Dialog_Access         :=
         Internal_Dialog_Access (Data.Dia);
      Select_Ref_Event_Dialog : Select_Ref_Event_Dialog_Access :=
         Select_Ref_Event_Dialog_Access (Data.Dia2);

      Row_Selected : Gtk.Tree_Selection.Gtk_Tree_Selection;
      Model        : Gtk.Tree_Model.Gtk_Tree_Model;
      Iter         : Gtk.Tree_Model.Gtk_Tree_Iter;
   begin

      Row_Selected := Get_Selection (Internal_Dialog.Tree_View);
      Get_Selected (Row_Selected, Model, Iter);
      if Iter /= Null_Iter then
         Set
           (Internal_Dialog.Tree_Store,
            Iter,
            Ref_Event_Val_Column,
            Get_Text (Get_Entry (Select_Ref_Event_Dialog.Ref_Event_Combo)));
      end if;
      Destroy (Select_Ref_Event_Dialog);
   end Set_Ref_Event_Entry;

   ----------------------------------------
   -- Func_Ref_Event_Column_Double_Click --
   ----------------------------------------

   function Func_Ref_Event_Column_Double_Click
     (Object : access Internal_Dialog_Record'Class;
      Event  : Gdk.Event.Gdk_Event)
      return   Boolean
   is
      Sel   : Gtk.Tree_Selection.Gtk_Tree_Selection :=
         Get_Selection (Object.Tree_View);
      Model : Gtk.Tree_Model.Gtk_Tree_Model;
      Iter  : Gtk.Tree_Model.Gtk_Tree_Iter;

      Path      : Gtk.Tree_Model.Gtk_Tree_Path;
      Column    : Gtk.Tree_View_Column.Gtk_Tree_View_Column;
      Cell_X    : Gint;
      Cell_Y    : Gint;
      Row_Found : Boolean;

      Select_Ref_Event_Dialog : Select_Ref_Event_Dialog_Access;
      Data                    : Dialog2_Ref := new Dialog2;
   begin
      if Get_Event_Type (Event) = Gdk_2button_Press
        and then Get_Button (Event) = 1
      then

         Get_Path_At_Pos
           (Object.Tree_View,
            Gint (Get_X (Event)),
            Gint (Get_Y (Event)),
            Path,
            Column,
            Cell_X,
            Cell_Y,
            Row_Found);

         if Column = Object.Ref_Event_Col then

            Get_Selected (Sel, Model, Iter);

            if Iter /= Null_Iter
              and then (Get_String (Object.Tree_Store, Iter, 4) =
                        "Referenced Event:")
            then

               Gtk_New (Select_Ref_Event_Dialog);
               Show_All (Select_Ref_Event_Dialog);

               Data.Dia  := Gtk_Dialog (Object);
               Data.Dia2 := Gtk_Dialog (Select_Ref_Event_Dialog);

               Dialog2_Cb.Connect
                 (Select_Ref_Event_Dialog.Ok_Button,
                  "clicked",
                  Dialog2_Cb.To_Marshaller (Set_Ref_Event_Entry'Access),
                  Data);

               Path_Free (Path);
               return True;

            end if;

         end if;

         Path_Free (Path);
      end if;
      return False;
   end Func_Ref_Event_Column_Double_Click;

   --------------
   -- Add_Line --
   --------------

   procedure Add_Line
     (Tree_Store : access Gtk_Tree_Store_Record'Class;
      Req_Ref    : access Mast.Timing_Requirements.Timing_Requirement'Class;
      Parent     : Gtk_Tree_Iter := Null_Iter)
   is
      Iter : Gtk_Tree_Iter;
   begin
      Append (Tree_Store, Iter, Parent);
      if Req_Ref.all'Tag = Hard_Local_Deadline'Tag then
         Set (Tree_Store, Iter, Type_Column, "Hard Local Deadline");
         Set (Tree_Store, Iter, Deadline_Column, "Deadline:");
         Set
           (Tree_Store,
            Iter,
            Deadline_Val_Column,
            Time_Image (The_Deadline (Deadline (Req_Ref.all))));
      elsif Req_Ref.all'Tag = Soft_Local_Deadline'Tag then
         Set (Tree_Store, Iter, Type_Column, "Soft Local Deadline");
         Set (Tree_Store, Iter, Deadline_Column, "Deadline:");
         Set
           (Tree_Store,
            Iter,
            Deadline_Val_Column,
            Time_Image (The_Deadline (Deadline (Req_Ref.all))));
      elsif Req_Ref.all'Tag = Hard_Global_Deadline'Tag then
         Set (Tree_Store, Iter, Type_Column, "Hard Global Deadline");
         Set (Tree_Store, Iter, Deadline_Column, "Deadline:");
         Set
           (Tree_Store,
            Iter,
            Deadline_Val_Column,
            Time_Image (The_Deadline (Deadline (Req_Ref.all))));
         Set (Tree_Store, Iter, Ref_Event_Column, "Referenced Event:");
         if Mast.Timing_Requirements.Event (Global_Deadline (Req_Ref.all)) /=
            null
         then
            Set
              (Tree_Store,
               Iter,
               Ref_Event_Val_Column,
               Name_Image
                  (Mast.Events.Name
                      (Mast.Timing_Requirements.Event
                          (Global_Deadline (Req_Ref.all)))));
         end if;
      elsif Req_Ref.all'Tag = Soft_Global_Deadline'Tag then
         Set (Tree_Store, Iter, Type_Column, "Soft Global Deadline");
         Set (Tree_Store, Iter, Deadline_Column, "Deadline:");
         Set
           (Tree_Store,
            Iter,
            Deadline_Val_Column,
            Time_Image (The_Deadline (Deadline (Req_Ref.all))));
         Set (Tree_Store, Iter, Ref_Event_Column, "Referenced Event:");
         if Mast.Timing_Requirements.Event (Global_Deadline (Req_Ref.all)) /=
            null
         then
            Set
              (Tree_Store,
               Iter,
               Ref_Event_Val_Column,
               Name_Image
                  (Mast.Events.Name
                      (Mast.Timing_Requirements.Event
                          (Global_Deadline (Req_Ref.all)))));
         end if;
      elsif Req_Ref.all'Tag = Global_Max_Miss_Ratio'Tag then
         Set (Tree_Store, Iter, Type_Column, "Global Max Miss Ratio");
         Set (Tree_Store, Iter, Deadline_Column, "Deadline:");
         Set
           (Tree_Store,
            Iter,
            Deadline_Val_Column,
            Time_Image (The_Deadline (Deadline (Req_Ref.all))));
         Set (Tree_Store, Iter, Ref_Event_Column, "Referenced Event:");
         if Mast.Timing_Requirements.Event (Global_Deadline (Req_Ref.all)) /=
            null
         then
            Set
              (Tree_Store,
               Iter,
               Ref_Event_Val_Column,
               Name_Image
                  (Mast.Events.Name
                      (Mast.Timing_Requirements.Event
                          (Global_Deadline (Req_Ref.all)))));
         end if;
         Set (Tree_Store, Iter, Ratio_Column, "Ratio:");
         Set
           (Tree_Store,
            Iter,
            Ratio_Val_Column,
            Float_Image
               (Mast.Timing_Requirements.Ratio
                   (Global_Max_Miss_Ratio (Req_Ref.all))));
      elsif Req_Ref.all'Tag = Local_Max_Miss_Ratio'Tag then
         Set (Tree_Store, Iter, Type_Column, "Local Max Miss Ratio");
         Set (Tree_Store, Iter, Deadline_Column, "Deadline:");
         Set
           (Tree_Store,
            Iter,
            Deadline_Val_Column,
            Time_Image (The_Deadline (Deadline (Req_Ref.all))));
         Set (Tree_Store, Iter, Ratio_Column, "Ratio:");
         Set
           (Tree_Store,
            Iter,
            Ratio_Val_Column,
            Float_Image
               (Mast.Timing_Requirements.Ratio
                   (Local_Max_Miss_Ratio (Req_Ref.all))));
      elsif Req_Ref.all'Tag = Max_Output_Jitter_Req'Tag then
         Set (Tree_Store, Iter, Type_Column, "Max Output Jitter");
         Set (Tree_Store, Iter, Deadline_Column, "Max Jitter:");
         Set
           (Tree_Store,
            Iter,
            Deadline_Val_Column,
            Time_Image
               (Max_Output_Jitter (Max_Output_Jitter_Req (Req_Ref.all))));
         Set (Tree_Store, Iter, Ref_Event_Column, "Referenced Event:");
         if Mast.Timing_Requirements.Event
               (Max_Output_Jitter_Req (Req_Ref.all)) /=
            null
         then
            Set
              (Tree_Store,
               Iter,
               Ref_Event_Val_Column,
               Name_Image
                  (Mast.Events.Name
                      (Mast.Timing_Requirements.Event
                          (Max_Output_Jitter_Req (Req_Ref.all)))));
         end if;
      else
         null;
      end if;
      Set (Tree_Store, Iter, Editable_Column, True);
      Set (Tree_Store, Iter, Background_Column, "lightgrey");
      Set (Tree_Store, Iter, Foreground_Column, "red");
   end Add_Line;

   -----------------------------
   -- Read Simple Requirement --
   -----------------------------

   procedure Read_Simple_Requirement
     (Tree_Store : access Gtk_Tree_Store_Record'Class;
      Iter       : Gtk_Tree_Iter;
      Item       : access ME_Internal_Link;
      Req_Ref    : out Mast.Timing_Requirements.Simple_Timing_Requirement_Ref)
   is
      Refer_Eve_Name : Var_Strings.Var_String;
      Refer_Eve_Ref  : Mast.Events.Event_Ref;
   begin
      if (Get_String (Tree_Store, Iter, 1) = "Hard Local Deadline") then
         Req_Ref := new Hard_Local_Deadline;
         Set_The_Deadline
           (Deadline (Req_Ref.all),
            Time'Value (Get_String (Tree_Store, Iter, 3)));
      elsif (Get_String (Tree_Store, Iter, 1) = "Soft Local Deadline") then
         Req_Ref := new Soft_Local_Deadline;
         Set_The_Deadline
           (Deadline (Req_Ref.all),
            Time'Value (Get_String (Tree_Store, Iter, 3)));
      elsif (Get_String (Tree_Store, Iter, 1) = "Hard Global Deadline") then
         Req_Ref := new Hard_Global_Deadline;
         Set_The_Deadline
           (Deadline (Req_Ref.all),
            Time'Value (Get_String (Tree_Store, Iter, 3)));
         Refer_Eve_Name := To_Var_String (Get_String (Tree_Store, Iter, 5));
         if Item.ME_Tran.Tran /= null then
            Refer_Eve_Ref :=
               Mast.Transactions.Find_Any_Event
                 (Refer_Eve_Name,
                  Item.ME_Tran.Tran.all);
            Set_Event (Global_Deadline (Req_Ref.all), Refer_Eve_Ref);
         end if;
      elsif (Get_String (Tree_Store, Iter, 1) = "Soft Global Deadline") then
         Req_Ref := new Soft_Global_Deadline;
         Set_The_Deadline
           (Deadline (Req_Ref.all),
            Time'Value (Get_String (Tree_Store, Iter, 3)));
         Refer_Eve_Name := To_Var_String (Get_String (Tree_Store, Iter, 5));
         if Item.ME_Tran.Tran /= null then
            Refer_Eve_Ref :=
               Mast.Transactions.Find_Any_Event
                 (Refer_Eve_Name,
                  Item.ME_Tran.Tran.all);
            Set_Event (Global_Deadline (Req_Ref.all), Refer_Eve_Ref);
         end if;
      elsif (Get_String (Tree_Store, Iter, 1) =
             "Global Max Miss Ratio")
      then
         Req_Ref := new Global_Max_Miss_Ratio;
         Set_The_Deadline
           (Deadline (Req_Ref.all),
            Time'Value (Get_String (Tree_Store, Iter, 3)));
         Set_Ratio
           (Global_Max_Miss_Ratio (Req_Ref.all),
            Percentage'Value (Get_String (Tree_Store, Iter, 7)));
         Refer_Eve_Name := To_Var_String (Get_String (Tree_Store, Iter, 5));
         if Item.ME_Tran.Tran /= null then
            Refer_Eve_Ref :=
               Mast.Transactions.Find_Any_Event
                 (Refer_Eve_Name,
                  Item.ME_Tran.Tran.all);
            Set_Event (Global_Deadline (Req_Ref.all), Refer_Eve_Ref);
         end if;
      elsif (Get_String (Tree_Store, Iter, 1) = "Local Max Miss Ratio") then
         Req_Ref := new Local_Max_Miss_Ratio;
         Set_The_Deadline
           (Deadline (Req_Ref.all),
            Time'Value (Get_String (Tree_Store, Iter, 3)));
         Set_Ratio
           (Global_Max_Miss_Ratio (Req_Ref.all),
            Percentage'Value (Get_String (Tree_Store, Iter, 7)));
      elsif (Get_String (Tree_Store, Iter, 1) = "Max Output Jitter") then
         Req_Ref := new Max_Output_Jitter_Req;
         Set_Max_Output_Jitter
           (Max_Output_Jitter_Req (Req_Ref.all),
            Time'Value (Get_String (Tree_Store, Iter, 3)));
         Refer_Eve_Name := To_Var_String (Get_String (Tree_Store, Iter, 5));
         if Item.ME_Tran.Tran /= null then
            Refer_Eve_Ref :=
               Mast.Transactions.Find_Any_Event
                 (Refer_Eve_Name,
                  Item.ME_Tran.Tran.all);
            Set_Event (Max_Output_Jitter_Req (Req_Ref.all), Refer_Eve_Ref);
         end if;
      end if;
   end Read_Simple_Requirement;

   ------------------------
   -- Assign_Requirement --
   ------------------------

   procedure Assign_Requirement
     (Tree_Store : access Gtk_Tree_Store_Record'Class;
      Item       : access ME_Internal_Link)
   is
      Req_Ref              : Mast.Timing_Requirements.Timing_Requirement_Ref;
      Simple_Req_Ref       :
        Mast.Timing_Requirements.Simple_Timing_Requirement_Ref;
      Iter                 : Gtk_Tree_Iter := Get_Iter_First (Tree_Store);
      Ref_Eve_Name         : Var_Strings.Var_String;
      Ref_Eve_Ref          : Mast.Events.Event_Ref;
      Tree_View_Line       : Integer;
      Error_Window_Created : Boolean       := False;
   begin
      if Iter = Null_Iter then
         Req_Ref := null;
      --Put_Line (Gint'Image(N_Children(Tree_Store, Iter))); -- Si no hay
      --filas N_Chidren = 0
      else
         --Put_Line (Gint'Image(N_Children(Tree_Store, Null_Iter))); --
         --N_Children devuelve el numero de filas de la tabla
         if N_Children (Tree_Store, Null_Iter) = Gint (1) then
         ----------------------------
         -- Simple Timing Requirement
         ----------------------------
            begin
               if (Get_String (Tree_Store, Iter, 1) =
                   "Hard Local Deadline")
               then
                  Req_Ref := new Hard_Local_Deadline;
                  Set_The_Deadline
                    (Deadline (Req_Ref.all),
                     Time'Value (Get_String (Tree_Store, Iter, 3)));
               elsif (Get_String (Tree_Store, Iter, 1) =
                      "Soft Local Deadline")
               then
                  Req_Ref := new Soft_Local_Deadline;
                  Set_The_Deadline
                    (Deadline (Req_Ref.all),
                     Time'Value (Get_String (Tree_Store, Iter, 3)));
               elsif (Get_String (Tree_Store, Iter, 1) =
                      "Hard Global Deadline")
               then
                  Req_Ref := new Hard_Global_Deadline;
                  Set_The_Deadline
                    (Deadline (Req_Ref.all),
                     Time'Value (Get_String (Tree_Store, Iter, 3)));
                  Ref_Eve_Name :=
                     To_Var_String (Get_String (Tree_Store, Iter, 5));
                  if Item.ME_Tran.Tran /= null then
                     Ref_Eve_Ref :=
                        Mast.Transactions.Find_Any_Event
                          (Ref_Eve_Name,
                           Item.ME_Tran.Tran.all);
                     Set_Event (Global_Deadline (Req_Ref.all), Ref_Eve_Ref);
                  end if;
               elsif (Get_String (Tree_Store, Iter, 1) =
                      "Soft Global Deadline")
               then
                  Req_Ref := new Soft_Global_Deadline;
                  Set_The_Deadline
                    (Deadline (Req_Ref.all),
                     Time'Value (Get_String (Tree_Store, Iter, 3)));
                  Ref_Eve_Name :=
                     To_Var_String (Get_String (Tree_Store, Iter, 5));
                  if Item.ME_Tran.Tran /= null then
                     Ref_Eve_Ref :=
                        Mast.Transactions.Find_Any_Event
                          (Ref_Eve_Name,
                           Item.ME_Tran.Tran.all);
                     Set_Event (Global_Deadline (Req_Ref.all), Ref_Eve_Ref);
                  end if;
               elsif (Get_String (Tree_Store, Iter, 1) =
                      "Global Max Miss Ratio")
               then
                  Req_Ref := new Global_Max_Miss_Ratio;
                  Set_The_Deadline
                    (Deadline (Req_Ref.all),
                     Time'Value (Get_String (Tree_Store, Iter, 3)));
                  Set_Ratio
                    (Global_Max_Miss_Ratio (Req_Ref.all),
                     Percentage'Value (Get_String (Tree_Store, Iter, 7)));
                  Ref_Eve_Name :=
                     To_Var_String (Get_String (Tree_Store, Iter, 5));
                  if Item.ME_Tran.Tran /= null then
                     Ref_Eve_Ref :=
                        Mast.Transactions.Find_Any_Event
                          (Ref_Eve_Name,
                           Item.ME_Tran.Tran.all);
                     Set_Event (Global_Deadline (Req_Ref.all), Ref_Eve_Ref);
                  end if;
               elsif (Get_String (Tree_Store, Iter, 1) =
                      "Local Max Miss Ratio")
               then
                  Req_Ref := new Local_Max_Miss_Ratio;
                  Set_The_Deadline
                    (Deadline (Req_Ref.all),
                     Time'Value (Get_String (Tree_Store, Iter, 3)));
                  Set_Ratio
                    (Global_Max_Miss_Ratio (Req_Ref.all),
                     Percentage'Value (Get_String (Tree_Store, Iter, 7)));
               elsif (Get_String (Tree_Store, Iter, 1) =
                      "Max Output Jitter")
               then
                  Req_Ref := new Max_Output_Jitter_Req;
                  Set_Max_Output_Jitter
                    (Max_Output_Jitter_Req (Req_Ref.all),
                     Time'Value (Get_String (Tree_Store, Iter, 3)));
                  Ref_Eve_Name :=
                     To_Var_String (Get_String (Tree_Store, Iter, 5));
                  if Item.ME_Tran.Tran /= null then
                     Ref_Eve_Ref :=
                        Mast.Transactions.Find_Any_Event
                          (Ref_Eve_Name,
                           Item.ME_Tran.Tran.all);
                     Set_Event
                       (Max_Output_Jitter_Req (Req_Ref.all),
                        Ref_Eve_Ref);
                  end if;
               end if;
            exception
               when Event_Not_Found =>
                  Gtk_New (Editor_Error_Window);
                  Set_Text
                    (Editor_Error_Window.Label,
                     "Error while searching Referenced Event !!!");
                  Show_All (Editor_Error_Window);
            end;
         elsif N_Children (Tree_Store, Null_Iter) > Gint (1) then
            --------------------------------
            -- Composite Timing Requirement
            --------------------------------
            Req_Ref        := new Composite_Timing_Req;
            Tree_View_Line := 1;
            while Iter /= Null_Iter loop
               begin
                  Read_Simple_Requirement
                    (Tree_Store,
                     Iter,
                     Item,
                     Simple_Req_Ref);
                  Add_Requirement
                    (Composite_Timing_Req (Req_Ref.all),
                     Simple_Req_Ref);
               exception
                  when Event_Not_Found =>
                     if not Error_Window_Created then
                        Gtk_New (Editor_Error_Window);
                        Error_Window_Created := True;
                     end if;
                     Set_Text
                       (Editor_Error_Window.Label,
                        "Error while searching Referenced Event at Line" &
                        Integer'Image (Tree_View_Line) &
                        " !!!");
                     Show_All (Editor_Error_Window);
                  when Constraint_Error =>
                     if not Error_Window_Created then
                        Gtk_New (Editor_Error_Window);
                        Error_Window_Created := True;
                     end if;
                     Set_Text
                       (Editor_Error_Window.Label,
                        " Invalid Value at Line" &
                        Integer'Image (Tree_View_Line) &
                        " !!!");
                     Show_All (Editor_Error_Window);
               end;
               Next (Tree_Store, Iter);
               Tree_View_Line := Tree_View_Line + 1;
            end loop;
         end if;
      end if;
      Mast.Graphs.Links.Set_Link_Timing_Requirements
        (Regular_Link (ME_Link_Ref (Item).Lin.all),
         Req_Ref);
   end Assign_Requirement;

   ----------------------------
   -- Create_New_Requirement --
   ----------------------------

   procedure Create_New_Requirement
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Dialog2_Ref)
   is

      Internal_Dialog        : Internal_Dialog_Access        :=
         Internal_Dialog_Access (Data.Dia);
      Select_Req_Type_Dialog : Select_Req_Type_Dialog_Access :=
         Select_Req_Type_Dialog_Access (Data.Dia2);

      Req_Ref : Mast.Timing_Requirements.Timing_Requirement_Ref := null;
   begin
      if (Get_Text (Get_Entry (Select_Req_Type_Dialog.Combo)) =
          "Hard Local Deadline")
      then
         Req_Ref := new Hard_Local_Deadline;
      elsif (Get_Text (Get_Entry (Select_Req_Type_Dialog.Combo)) =
             "Soft Local Deadline")
      then
         Req_Ref := new Soft_Local_Deadline;
      elsif (Get_Text (Get_Entry (Select_Req_Type_Dialog.Combo)) =
             "Hard Global Deadline")
      then
         Req_Ref := new Hard_Global_Deadline;
      elsif (Get_Text (Get_Entry (Select_Req_Type_Dialog.Combo)) =
             "Soft Global Deadline")
      then
         Req_Ref := new Soft_Global_Deadline;
      elsif (Get_Text (Get_Entry (Select_Req_Type_Dialog.Combo)) =
             "Global Max Miss Ratio")
      then
         Req_Ref := new Global_Max_Miss_Ratio;
      elsif (Get_Text (Get_Entry (Select_Req_Type_Dialog.Combo)) =
             "Local Max Miss Ratio")
      then
         Req_Ref := new Local_Max_Miss_Ratio;
      elsif (Get_Text (Get_Entry (Select_Req_Type_Dialog.Combo)) =
             "Max Output Jitter")
      then
         Req_Ref := new Max_Output_Jitter_Req;
      end if;
      if Req_Ref /= null then
         Add_Line (Internal_Dialog.Tree_Store, Req_Ref);
      end if;
      Destroy (Select_Req_Type_Dialog);
   end Create_New_Requirement;

   ------------------------------
   -- On_Cancel_Button_Clicked --
   ------------------------------

   procedure On_Cancel_Button_Clicked
     (Object : access Gtk_Dialog_Record'Class)
   is
   begin
      Destroy (Object);
   end On_Cancel_Button_Clicked;

   -------------------------------
   -- On_Add_Req_Button_Clicked --
   -------------------------------

   procedure On_Add_Req_Button_Clicked
     (Object : access Internal_Dialog_Record'Class)
   is

      Select_Req_Type_Dialog : Select_Req_Type_Dialog_Access;
      Data                   : Dialog2_Ref := new Dialog2;

   begin

      Gtk_New (Select_Req_Type_Dialog);
      Show_All (Select_Req_Type_Dialog);

      Data.Dia  := Gtk_Dialog (Object);
      Data.Dia2 := Gtk_Dialog (Select_Req_Type_Dialog);

      Dialog2_Cb.Connect
        (Select_Req_Type_Dialog.Ok_Button,
         "clicked",
         Dialog2_Cb.To_Marshaller (Create_New_Requirement'Access),
         Data);

   end On_Add_Req_Button_Clicked;

   ----------------------------------
   -- On_Remove_Req_Button_Clicked --
   ----------------------------------

   procedure On_Remove_Req_Button_Clicked
     (Object : access Internal_Dialog_Record'Class)
   is
      Row_Selected : Gtk.Tree_Selection.Gtk_Tree_Selection;
      Model        : Gtk.Tree_Model.Gtk_Tree_Model;
      Iter         : Gtk.Tree_Model.Gtk_Tree_Iter;
   begin
      Row_Selected := Get_Selection (Object.Tree_View);
      Get_Selected (Row_Selected, Model, Iter);

      --Put_Line (To_Var_String(Get_String (Object.Tree_Store, Iter, 1)));

      if Iter /= Null_Iter then
         Remove (Object.Tree_Store, Iter);
      end if;
   end On_Remove_Req_Button_Clicked;

end Internal_Dialog_Pkg.Callbacks;
