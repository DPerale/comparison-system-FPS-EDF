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
with Ada.Exceptions;
use Ada.Exceptions;
with Ada.Tags;                use Ada.Tags;
with Gdk.Color;               use Gdk.Color;
with Gdk.Font;                use Gdk.Font;
with Gdk.Drawable;            use Gdk.Drawable;
with Gdk.Rectangle;           use Gdk.Rectangle;
with Gtk.Button;              use Gtk.Button;
with Gtk.Combo;               use Gtk.Combo;
with Gtk.Handlers;            use Gtk.Handlers;
with Gtk.GEntry;              use Gtk.GEntry;
with Gtk.Enums;               use Gtk.Enums;
with Gtk.Label;               use Gtk.Label;
with Gtk.Menu_Item;           use Gtk.Menu_Item;
with Gtk.Scrolled_Window;     use Gtk.Scrolled_Window;
with Gtk.Table;               use Gtk.Table;
with Pango.Font;              use Pango.Font;
with Gtkada.Dialogs;          use Gtkada.Dialogs;

with List_Exceptions;            use List_Exceptions;
with Mast;                       use Mast;
with Mast.IO;                    use Mast.IO;
with Mast.Events;                use Mast.Events;
with Mast.Timing_Requirements;   use Mast.Timing_Requirements;
with Mast.Graphs;                use Mast.Graphs;
with Mast.Graphs.Event_Handlers; use Mast.Graphs.Event_Handlers;
with Mast.Transactions;          use Mast.Transactions;

with Mast_Editor.Event_Handlers;    use Mast_Editor.Event_Handlers;
with Item_Menu_Pkg;                 use Item_Menu_Pkg;
with Editor_Error_Window_Pkg;       use Editor_Error_Window_Pkg;
with Internal_Dialog_Pkg;           use Internal_Dialog_Pkg;
with Internal_Dialog_Pkg.Callbacks; use Internal_Dialog_Pkg.Callbacks;
with External_Dialog_Pkg;           use External_Dialog_Pkg;
with Add_Link_Dialog_Pkg;           use Add_Link_Dialog_Pkg;
with Editor_Actions;                use Editor_Actions;
with Change_Control;
with Select_Ref_Event_Dialog_Pkg;   use Select_Ref_Event_Dialog_Pkg;

package body Mast_Editor.Links is

   package Button_Cb is new Gtk.Handlers.User_Callback
     (Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Link_Ref);

   Font  : Pango_Font_Description;
   Font1 : Pango_Font_Description;

   -------------------------------------------------
   -- Types and packages used to handle dialogs info
   -------------------------------------------------
   type ME_Link_And_Dialog is record
      It  : ME_Link_Ref;
      Dia : Gtk_Dialog;
   end record;

   type ME_Link_And_Dialog_Ref is access all ME_Link_And_Dialog;

   package Me_Link_And_Dialog_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Link_And_Dialog_Ref);

   --------------
   -- Name     --
   --------------
   function Name (Item : in ME_Link) return Var_String is
   begin
      return (Name (Item.Lin) & Delimiter & Name (Item.ME_Tran));
   end Name;

   --------------
   -- Name     --
   --------------
   function Name (Item_Ref : in ME_Link_Ref) return Var_String is
   begin
      return (Name (Item_Ref.Lin) & Delimiter & Name (Item_Ref.ME_Tran));
   end Name;

   -----------------
   -- Print       --
   -----------------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Link;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Ada.Text_IO.Set_Col (File, Ada.Text_IO.Count (Indentation));
      Ada.Text_IO.Put (File, "ME_Link");
   end Print;

   -----------------
   -- Print       --
   -----------------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive)
   is
      Item_Ref : ME_Link_Ref;
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
     (Item   : access ME_Internal_Link;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Lin_Ref         : Link_Ref               := ME_Link_Ref (Item).Lin;
      Eve_Ref         : Mast.Events.Event_Ref;
      Old_Req_Ref     : Mast.Timing_Requirements.Timing_Requirement_Ref;
      Internal_Dialog : Internal_Dialog_Access :=
         Internal_Dialog_Access (Dialog);
   begin
      Change_Control.Changes_Made;
      Eve_Ref := Mast.Graphs.Event_Of (Lin_Ref.all);
      if Eve_Ref /= null then
         Init
           (Eve_Ref.all,
            Var_Strings.To_Lower
               (To_Var_String (Get_Text (Internal_Dialog.Event_Name_Entry))));
      else
         Eve_Ref := new Mast.Events.Internal_Event;
         Init
           (Eve_Ref.all,
            Var_Strings.To_Lower
               (To_Var_String (Get_Text (Internal_Dialog.Event_Name_Entry))));
      end if;
      Mast.Graphs.Set_Event (Lin_Ref.all, Eve_Ref);
      if Has_Timing_Requirements (Regular_Link (Lin_Ref.all)) then
         Old_Req_Ref :=
            Link_Timing_Requirements (Regular_Link (Lin_Ref.all));
      end if;
      Internal_Dialog_Pkg.Callbacks.Assign_Requirement
        (Internal_Dialog.Tree_Store,
         Item);
   end Write_Parameters;

   ----------------------
   -- Write Parameters --
   ----------------------
   procedure Write_Parameters
     (Item   : access ME_External_Link;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Lin_Ref         : Link_Ref               := ME_Link_Ref (Item).Lin;
      Eve_Ref         : Mast.Events.Event_Ref;
      External_Dialog : External_Dialog_Access :=
         External_Dialog_Access (Dialog);
   begin
      Change_Control.Changes_Made;
      Eve_Ref := Event_Of (Lin_Ref.all);
      -- Extenal_Event is an abstract type so we must init Eve_Ref with
      --non-abstract derivated types
      if (Get_Text (Get_Entry
                       (External_Dialog.External_Event_Type_Combo)) =
          "Periodic")
      then
         Eve_Ref := new Mast.Events.Periodic_Event;
         Init
           (Eve_Ref.all,
            Var_Strings.To_Lower
               (To_Var_String
                   (Get_Text (External_Dialog.External_Event_Name_Entry))));
         Set_Period
           (Periodic_Event (Eve_Ref.all),
            Time'Value (Get_Text (External_Dialog.Period_Entry)));
         Set_Max_Jitter
           (Periodic_Event (Eve_Ref.all),
            Time'Value (Get_Text (External_Dialog.Max_Jitter_Entry)));
         Set_Phase
           (Periodic_Event (Eve_Ref.all),
            Absolute_Time'Value (Get_Text (External_Dialog.Per_Phase_Entry)));
      elsif (Get_Text
                (Get_Entry (External_Dialog.External_Event_Type_Combo)) =
             "Singular")
      then
         Eve_Ref := new Mast.Events.Singular_Event;
         Init
           (Eve_Ref.all,
            Var_Strings.To_Lower
               (To_Var_String
                   (Get_Text (External_Dialog.External_Event_Name_Entry))));
         Set_Phase
           (Singular_Event (Eve_Ref.all),
            Absolute_Time'Value (Get_Text (External_Dialog.Sing_Phase_Entry)));
      elsif (Get_Text
                (Get_Entry (External_Dialog.External_Event_Type_Combo)) =
             "Sporadic")
      then
         Eve_Ref := new Mast.Events.Sporadic_Event;
         Init
           (Eve_Ref.all,
            Var_Strings.To_Lower
               (To_Var_String
                   (Get_Text (External_Dialog.External_Event_Name_Entry))));
         Set_Avg_Interarrival
           (Aperiodic_Event (Eve_Ref.all),
            Time'Value (Get_Text (External_Dialog.Spo_Avg_Entry)));
         Set_Distribution
           (Aperiodic_Event (Eve_Ref.all),
            Distribution_Function'Value
               (Get_Text (Get_Entry (External_Dialog.Spo_Dist_Func_Combo))));
         Set_Min_Interarrival
           (Sporadic_Event (Eve_Ref.all),
            Time'Value (Get_Text (External_Dialog.Spo_Min_Entry)));
      elsif (Get_Text
                (Get_Entry (External_Dialog.External_Event_Type_Combo)) =
             "Unbounded")
      then
         Eve_Ref := new Mast.Events.Unbounded_Event;
         Init
           (Eve_Ref.all,
            Var_Strings.To_Lower
               (To_Var_String
                   (Get_Text (External_Dialog.External_Event_Name_Entry))));
         Set_Avg_Interarrival
           (Aperiodic_Event (Eve_Ref.all),
            Time'Value (Get_Text (External_Dialog.Unb_Avg_Entry)));
         Set_Distribution
           (Aperiodic_Event (Eve_Ref.all),
            Distribution_Function'Value
               (Get_Text (Get_Entry (External_Dialog.Unb_Dist_Func_Combo))));
      elsif (Get_Text
                (Get_Entry (External_Dialog.External_Event_Type_Combo)) =
             "Bursty")
      then
         Eve_Ref := new Mast.Events.Bursty_Event;
         Init
           (Eve_Ref.all,
            Var_Strings.To_Lower
               (To_Var_String
                   (Get_Text (External_Dialog.External_Event_Name_Entry))));
         Set_Avg_Interarrival
           (Aperiodic_Event (Eve_Ref.all),
            Time'Value (Get_Text (External_Dialog.Bur_Avg_Entry)));
         Set_Distribution
           (Aperiodic_Event (Eve_Ref.all),
            Distribution_Function'Value
               (Get_Text (Get_Entry (External_Dialog.Bur_Dist_Func_Combo))));
         Set_Bound_Interval
           (Bursty_Event (Eve_Ref.all),
            Time'Value (Get_Text (External_Dialog.Bur_Bound_Entry)));
         Set_Max_Arrivals
           (Bursty_Event (Eve_Ref.all),
            Positive'Value (Get_Text (External_Dialog.Max_Arrival_Entry)));
      else
         null;
      end if;
      Set_Event (Lin_Ref.all, Eve_Ref);
   end Write_Parameters;

   ---------------------
   -- Read Parameters --
   ---------------------
   procedure Read_Parameters
     (Item   : access ME_Internal_Link;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Lin_Ref         : Link_Ref               := Item.Lin;
      Eve_Ref         : Mast.Events.Event_Ref;
      Req_Ref         : Mast.Timing_Requirements.Timing_Requirement_Ref;
      Req_Iter        : Mast.Timing_Requirements.Iteration_Object;
      Simple_Req_Ref  : Mast.Timing_Requirements.Simple_Timing_Requirement_Ref;
      Tran_Eve_Ref    : Mast.Graphs.Link_Ref;
      Tran_Eve_Index  : Mast.Transactions.Link_Iteration_Object;
      Tran_Eve_Name   : Var_Strings.Var_String;
      Internal_Dialog : Internal_Dialog_Access :=
         Internal_Dialog_Access (Dialog);
   begin
      if Lin_Ref /= null and then Event_Of (Lin_Ref.all) /= null then
         Eve_Ref := Event_Of (Lin_Ref.all);
         Set_Text
           (Internal_Dialog.Event_Name_Entry,
            Name_Image (Name (Eve_Ref)));
      end if;
      if Mast.Graphs.Links.Has_Timing_Requirements
           (Regular_Link (Lin_Ref.all))
      then
         Req_Ref :=
            Mast.Graphs.Links.Link_Timing_Requirements
              (Regular_Link (Lin_Ref.all));
         if Req_Ref.all'Tag =
            Mast.Timing_Requirements.Composite_Timing_Req'Tag
         then
            Mast.Timing_Requirements.Rewind_Requirements
              (Composite_Timing_Req (Req_Ref.all),
               Req_Iter);
            for I in
                  1 ..
                  Mast.Timing_Requirements.Num_Of_Requirements
                     (Composite_Timing_Req (Req_Ref.all))
            loop
               Mast.Timing_Requirements.Get_Next_Requirement
                 (Composite_Timing_Req (Req_Ref.all),
                  Simple_Req_Ref,
                  Req_Iter);
               Internal_Dialog_Pkg.Callbacks.Add_Line
                 (Internal_Dialog.Tree_Store,
                  Simple_Req_Ref);
            end loop;
         else
            Internal_Dialog_Pkg.Callbacks.Add_Line
              (Internal_Dialog.Tree_Store,
               Req_Ref);
         end if;
      end if;
      Show_All (Internal_Dialog);

      -- This part of the code takes care of creating
      --Select_Ref_Event_Dialog_Pkg.Refer_Event_Combo_Items list
      -- correctly, considering the possibility of invoking
      --Gtk_New(Select_Ref_Event_Dialog) from
      -- Internal_Dialog
      if Item.ME_Tran /= null and then Item.ME_Tran.Tran /= null then
         Free_String_List (Refer_Event_Combo_Items);
         Mast.Transactions.Rewind_External_Event_Links
           (Item.ME_Tran.Tran.all,
            Tran_Eve_Index);
         for I in
               1 ..
               Mast.Transactions.Num_Of_External_Event_Links
                  (Item.ME_Tran.Tran.all)
         loop
            Mast.Transactions.Get_Next_External_Event_Link
              (Item.ME_Tran.Tran.all,
               Tran_Eve_Ref,
               Tran_Eve_Index);
            Tran_Eve_Name := Mast.Graphs.Name (Tran_Eve_Ref.all);
            String_List.Append
              (Select_Ref_Event_Dialog_Pkg.Refer_Event_Combo_Items,
               Name_Image (Tran_Eve_Name));
         end loop;
         Mast.Transactions.Rewind_Internal_Event_Links
           (Item.ME_Tran.Tran.all,
            Tran_Eve_Index);
         for I in
               1 ..
               Mast.Transactions.Num_Of_Internal_Event_Links
                  (Item.ME_Tran.Tran.all)
         loop
            Mast.Transactions.Get_Next_Internal_Event_Link
              (Item.ME_Tran.Tran.all,
               Tran_Eve_Ref,
               Tran_Eve_Index);
            Tran_Eve_Name := Mast.Graphs.Name (Tran_Eve_Ref.all);
            String_List.Append
              (Select_Ref_Event_Dialog_Pkg.Refer_Event_Combo_Items,
               Name_Image (Tran_Eve_Name));
         end loop;
         String_List.Append (Refer_Event_Combo_Items, (""));
      end if;
   end Read_Parameters;

   ---------------------
   -- Read Parameters --
   ---------------------
   procedure Read_Parameters
     (Item   : access ME_External_Link;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Lin_Ref         : Link_Ref               := Item.Lin;
      Eve_Ref         : Mast.Events.Event_Ref;
      External_Dialog : External_Dialog_Access :=
         External_Dialog_Access (Dialog);
   begin
      Show_All (External_Dialog);
      Hide (External_Dialog.Singular_Table);
      Hide (External_Dialog.Sporadic_Table);
      Hide (External_Dialog.Unbounded_Table);
      Hide (External_Dialog.Bursty_Table);
      if Lin_Ref /= null and then Event_Of (Lin_Ref.all) /= null then
         Eve_Ref := Event_Of (Lin_Ref.all);
         if Eve_Ref.all'Tag = Mast.Events.Periodic_Event'Tag then
            Set_Text
              (Get_Entry (External_Dialog.External_Event_Type_Combo),
               "Periodic");
            Set_Text
              (External_Dialog.External_Event_Name_Entry,
               Name_Image (Name (Eve_Ref)));
            Set_Text
              (External_Dialog.Period_Entry,
               Time_Image (Period (Periodic_Event (Eve_Ref.all))));
            Set_Text
              (External_Dialog.Max_Jitter_Entry,
               Time_Image (Max_Jitter (Periodic_Event (Eve_Ref.all))));
            Set_Text
              (External_Dialog.Per_Phase_Entry,
               Time_Image (Time (Phase (Periodic_Event (Eve_Ref.all)))));
            Show_All (External_Dialog.Periodic_Table);
         elsif Eve_Ref.all'Tag = Mast.Events.Singular_Event'Tag then
            Set_Text
              (Get_Entry (External_Dialog.External_Event_Type_Combo),
               "Singular");
            Set_Text
              (External_Dialog.External_Event_Name_Entry,
               Name_Image (Name (Eve_Ref)));
            Set_Text
              (External_Dialog.Sing_Phase_Entry,
               Time_Image (Time (Phase (Singular_Event (Eve_Ref.all)))));
            Show_All (External_Dialog.Singular_Table);
         elsif Eve_Ref.all'Tag = Mast.Events.Sporadic_Event'Tag then
            Set_Text
              (Get_Entry (External_Dialog.External_Event_Type_Combo),
               "Sporadic");
            Set_Text
              (External_Dialog.External_Event_Name_Entry,
               Name_Image (Name (Eve_Ref)));
            Set_Text
              (External_Dialog.Spo_Avg_Entry,
               Time_Image (Avg_Interarrival (Aperiodic_Event (Eve_Ref.all))));
            Set_Text
              (Get_Entry (External_Dialog.Spo_Dist_Func_Combo),
               Distribution_Function'Image
                  (Distribution (Aperiodic_Event (Eve_Ref.all))));
            Set_Text
              (External_Dialog.Spo_Min_Entry,
               Time_Image (Min_Interarrival (Sporadic_Event (Eve_Ref.all))));
            Show_All (External_Dialog.Sporadic_Table);
         elsif Eve_Ref.all'Tag = Mast.Events.Unbounded_Event'Tag then
            Set_Text
              (Get_Entry (External_Dialog.External_Event_Type_Combo),
               "Unbounded");
            Set_Text
              (External_Dialog.External_Event_Name_Entry,
               Name_Image (Name (Eve_Ref)));
            Set_Text
              (External_Dialog.Unb_Avg_Entry,
               Time_Image (Avg_Interarrival (Aperiodic_Event (Eve_Ref.all))));
            Set_Text
              (Get_Entry (External_Dialog.Unb_Dist_Func_Combo),
               Distribution_Function'Image
                  (Distribution (Aperiodic_Event (Eve_Ref.all))));
            Show_All (External_Dialog.Unbounded_Table);
         elsif Eve_Ref.all'Tag = Mast.Events.Bursty_Event'Tag then
            Set_Text
              (Get_Entry (External_Dialog.External_Event_Type_Combo),
               "Bursty");
            Set_Text
              (External_Dialog.External_Event_Name_Entry,
               Name_Image (Name (Eve_Ref)));
            Set_Text
              (External_Dialog.Bur_Avg_Entry,
               Time_Image (Avg_Interarrival (Aperiodic_Event (Eve_Ref.all))));
            Set_Text
              (Get_Entry (External_Dialog.Bur_Dist_Func_Combo),
               Distribution_Function'Image
                  (Distribution (Aperiodic_Event (Eve_Ref.all))));
            Set_Text
              (External_Dialog.Bur_Bound_Entry,
               Time_Image (Bound_Interval (Bursty_Event (Eve_Ref.all))));
            Set_Text
              (External_Dialog.Max_Arrival_Entry,
               Integer'Image (Max_Arrivals (Bursty_Event (Eve_Ref.all))));
            Show_All (External_Dialog.Bursty_Table);
         else
            null;
         end if;
      end if;
   end Read_Parameters;

   --------------------------
   -- Draw Internal Event  --
   --------------------------
   procedure Draw
     (Item         : access ME_Internal_Link;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint)
   is
      Rect       : constant Gdk_Rectangle := Get_Coord (Item);
      W          : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Width);
      H          : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Height);
      Int_Link   : Link_Ref               := Item.Lin;
      Event_Name : String                 :=
         Name_Image (Name (Int_Link.all));
      Color      : Gdk.Color.Gdk_Color;
   begin
      Editor_Actions.Load_System_Font (Font1, Font);
      if not Is_Selected (Canvas, Item) then
         if Mast.Graphs.Links.Has_Timing_Requirements
              (Regular_Link (Int_Link.all))
         then
            ME_Link_Ref (Item).Color_Name := Int_Link_Req_Color;
         else
            ME_Link_Ref (Item).Color_Name := Int_Link_Color;
         end if;
      end if;
      Color := Parse (To_String (ME_Link_Ref (Item).Color_Name));
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
      Draw_Text
        (Get_Window (Canvas),
         From_Description (Font),
         GC,
         Xdest + W / 20,
         Ydest + 2 * H / 3,
         Event_Name);
   end Draw;

   --------------------------
   -- Draw External Event  --
   --------------------------
   procedure Draw
     (Item         : access ME_External_Link;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint)
   is
      Rect       : constant Gdk_Rectangle := Get_Coord (Item);
      W          : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Width);
      H          : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Height);
      Int_Link   : Link_Ref               := Item.Lin;
      Event_Name : String                 :=
         Name_Image (Name (Int_Link.all));
      Color      : Gdk.Color.Gdk_Color;
   begin
      Editor_Actions.Load_System_Font (Font1, Font);
      Color := Parse (To_String (ME_Link_Ref (Item).Color_Name));
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
      Draw_Text
        (Get_Window (Canvas),
         From_Description (Font),
         GC,
         Xdest + W / 20,
         Ydest + 2 * H / 3,
         Event_Name);
   end Draw;

   --------------------
   -- Write Internal --  (Writes the params of an existing Internal Event and
   --refreshes the canvas)
   --------------------
   procedure Write_Internal
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Link_And_Dialog_Ref)
   is
      Item            : ME_Link_Ref            := Data.It;
      Internal_Dialog : Internal_Dialog_Access :=
         Internal_Dialog_Access (Data.Dia);
   begin
      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (Internal_Dialog.Event_Name_Entry)))
      then
         Write_Parameters (Item, Gtk_Dialog (Internal_Dialog));
         Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
         Destroy (Internal_Dialog);
      else
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Identifier not Valid!!!");
         Show_All (Editor_Error_Window);
      end if;
   exception
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, " Invalid Value !!!");
         Show_All (Editor_Error_Window);
         Destroy (Internal_Dialog);
   end Write_Internal;

   --------------------
   -- Write External --  (Writes the params of an existing External Event and
   --refreshes the canvas)
   --------------------
   procedure Write_External
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Link_And_Dialog_Ref)
   is
      Item            : ME_Link_Ref            := Data.It;
      External_Dialog : External_Dialog_Access :=
         External_Dialog_Access (Data.Dia);
   begin
      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (External_Dialog.External_Event_Name_Entry)))
      then
         Write_Parameters (Item, Gtk_Dialog (External_Dialog));
         Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
         Destroy (External_Dialog);
      else
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Identifier not Valid!!!");
         Show_All (Editor_Error_Window);
      end if;
   exception
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, " Invalid Value !!!");
         Show_All (Editor_Error_Window);
         Destroy (External_Dialog);
   end Write_External;

   ------------------
   -- New Internal -- (Add new internal event to canvas and to the transaction)
   ------------------
   procedure New_Internal
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Link_And_Dialog_Ref)
   is
      Item            : ME_Link_Ref            := Data.It;
      Internal_Dialog : Internal_Dialog_Access :=
         Internal_Dialog_Access (Data.Dia);
   begin
      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (Internal_Dialog.Event_Name_Entry)))
      then
         Write_Parameters (Item, Gtk_Dialog (Internal_Dialog));
         Mast.Transactions.Add_Internal_Event_Link
           (Item.ME_Tran.Tran.all,
            Item.Lin);
         Mast_Editor.Links.Lists.Add (Item, Editor_System.Me_Links);
         Set_Screen_Size (Item, Item.W, Item.H);
         Put (Item.ME_Tran.Dialog.Trans_Canvas, Item);
         Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
         Show_Item (Item.ME_Tran.Dialog.Trans_Canvas, Item);
         Destroy (Internal_Dialog);
      else
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Identifier not Valid!!!");
         Show_All (Editor_Error_Window);
      end if;
   exception
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Invalid Value !!!");
         Show_All (Editor_Error_Window);
         Destroy (Internal_Dialog);
      when Already_Exists =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Event Already Exists !!!");
         Show_All (Editor_Error_Window);
         Destroy (Internal_Dialog);
   end New_Internal;

   ------------------
   -- New External -- (Adds new external event to canvas and to the
   --transaction)
   ------------------
   procedure New_External
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Link_And_Dialog_Ref)
   is
      Item            : ME_Link_Ref            := Data.It;
      External_Dialog : External_Dialog_Access :=
         External_Dialog_Access (Data.Dia);
   begin
      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (External_Dialog.External_Event_Name_Entry)))
      then
         Write_Parameters (Item, Gtk_Dialog (External_Dialog));
         Mast.Transactions.Add_External_Event_Link
           (Item.ME_Tran.Tran.all,
            Item.Lin);
         Mast_Editor.Links.Lists.Add (Item, Editor_System.Me_Links);
         Set_Screen_Size (Item, Item.W, Item.H);
         Put (Item.ME_Tran.Dialog.Trans_Canvas, Item);
         Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
         Show_Item (Item.ME_Tran.Dialog.Trans_Canvas, Item);
         Destroy (External_Dialog);
      else
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Identifier not Valid!!!");
         Show_All (Editor_Error_Window);
      end if;
   exception
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Invalid Value !!!");
         Show_All (Editor_Error_Window);
         Destroy (External_Dialog);
      when Already_Exists =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Event Already Exists !!!");
         Show_All (Editor_Error_Window);
         Destroy (External_Dialog);
   end New_External;

   ------------------------
   -- Show Internal Dialog -- (Shows internal dialog with default params)
   ------------------------
   procedure Show_Internal_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Res    : ME_Transaction_Ref)
   is
      Item            : ME_Link_Ref            := new ME_Internal_Link;
      Lin_Ref         : Mast.Graphs.Link_Ref   := new Regular_Link;
      Internal_Dialog : Internal_Dialog_Access;
      Me_Data         : ME_Link_And_Dialog_Ref := new ME_Link_And_Dialog;
   begin
      Item.W           := Link_Width;
      Item.H           := Link_Height;
      Item.Canvas_Name := Name (Res);
      Item.Color_Name  := Int_Link_Color;
      Item.Lin         := Lin_Ref;
      Item.ME_Tran     := Res;

      Gtk_New (Internal_Dialog);
      Read_Parameters (Item, Gtk_Dialog (Internal_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Internal_Dialog);

      Me_Link_And_Dialog_Cb.Connect
        (Internal_Dialog.Ok_Button,
         "clicked",
         Me_Link_And_Dialog_Cb.To_Marshaller (New_Internal'Access),
         Me_Data);

   end Show_Internal_Dialog;

   ------------------------
   -- Show External Dialog -- (Shows external dialog with default params)
   ------------------------
   procedure Show_External_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Res    : ME_Transaction_Ref)
   is
      Item            : ME_Link_Ref            := new ME_External_Link;
      Lin_Ref         : Mast.Graphs.Link_Ref   := new Regular_Link;
      External_Dialog : External_Dialog_Access;
      Me_Data         : ME_Link_And_Dialog_Ref := new ME_Link_And_Dialog;
   begin
      Item.W           := Link_Width;
      Item.H           := Link_Height;
      Item.Canvas_Name := Name (Res);
      Item.Color_Name  := Ext_Link_Color;
      Item.Lin         := Lin_Ref;
      Item.ME_Tran     := Res;

      Gtk_New (External_Dialog);
      Read_Parameters (Item, Gtk_Dialog (External_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (External_Dialog);

      Me_Link_And_Dialog_Cb.Connect
        (External_Dialog.Ok_Button,
         "clicked",
         Me_Link_And_Dialog_Cb.To_Marshaller (New_External'Access),
         Me_Data);

   end Show_External_Dialog;

   -----------------
   -- Remove_Link --
   -----------------
   procedure Remove_Link
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Link_Ref)
   is
      Me_Lin_Index    : Mast_Editor.Links.Lists.Index;
      Me_Item_Deleted : ME_Link_Ref;
      Evnt : Mast.Events.Event_Ref;
   begin
      Evnt:=Mast.Graphs.Event_Of(Item.Lin.all);
      if (Mast.Transactions.References_Event(Evnt,Item.ME_Tran.Tran.all)) then
         -- Link cannot be deleted
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "EVENT IS REFERENCED BY A TIMING REQUIEREMENT");
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

            -- Remove Item.Lin from the list of events of the transaction
            if Item.all'Tag = Mast_Editor.Links.ME_Internal_Link'Tag then
               Mast.Transactions.Remove_Internal_Event_Link
                 (Item.ME_Tran.Tran.all,
                  Item.Lin);
            elsif Item.all'Tag = Mast_Editor.Links.ME_External_Link'Tag then
               Mast.Transactions.Remove_External_Event_Link
                 (Item.ME_Tran.Tran.all,
                  Item.Lin);
            end if;

            -- Remove Item from Editor_System.Me_Links list
            Me_Lin_Index    :=
              Mast_Editor.Links.Lists.Find
              (Name (Item),
               Editor_System.Me_Links);
            Mast_Editor.Links.Lists.Delete
              (Me_Lin_Index,
               Me_Item_Deleted,
               Editor_System.Me_Links);

            --Remove_Old_Links(Item.ME_Tran.Dialog.Trans_Canvas, Item, False);
            --Remove_Old_Links(Item.ME_Tran.Dialog.Trans_Canvas, Item, True);
            Remove (Item.ME_Tran.Dialog.Trans_Canvas, Item);
            Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
            Change_Control.Changes_Made;
            Destroy (Item_Menu);
         end if;
      end if;
   exception
      when Exc: others =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "ERROR IN EVENT REMOVAL !!!"&
                   Exception_Name(Exc));
         Show_All (Editor_Error_Window);
         Destroy (Item_Menu);
   end Remove_Link;

   ---------------------
   -- Properties_Int  --
   ---------------------
   procedure Properties_Int
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Link_Ref)
   is
      Internal_Dialog : Internal_Dialog_Access;
      Me_Data         : ME_Link_And_Dialog_Ref := new ME_Link_And_Dialog;
   begin
      Gtk_New (Internal_Dialog);
      Read_Parameters (Item, Gtk_Dialog (Internal_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Internal_Dialog);

      Me_Link_And_Dialog_Cb.Connect
        (Internal_Dialog.Ok_Button,
         "clicked",
         Me_Link_And_Dialog_Cb.To_Marshaller (Write_Internal'Access),
         Me_Data);

      Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
      Destroy (Item_Menu);
   end Properties_Int;

   ---------------------
   -- Properties_Ext  --
   ---------------------
   procedure Properties_Ext
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Link_Ref)
   is
      External_Dialog : External_Dialog_Access;
      Me_Data         : ME_Link_And_Dialog_Ref := new ME_Link_And_Dialog;
   begin
      Gtk_New (External_Dialog);
      Read_Parameters (Item, Gtk_Dialog (External_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (External_Dialog);

      Me_Link_And_Dialog_Cb.Connect
        (External_Dialog.Ok_Button,
         "clicked",
         Me_Link_And_Dialog_Cb.To_Marshaller (Write_External'Access),
         Me_Data);

      Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
      Destroy (Item_Menu);
   end Properties_Ext;

   ---------------------
   -- On Button Click --
   ---------------------
   procedure On_Button_Click
     (Item  : access ME_Internal_Link;
      Event : Gdk.Event.Gdk_Event_Button)
   is
      Num_Button      : Guint;
      Event_Type      : Gdk_Event_Type;
      Internal_Dialog : Internal_Dialog_Access;
      Me_Data         : ME_Link_And_Dialog_Ref := new ME_Link_And_Dialog;
   begin
      if Event /= null then
         Event_Type := Get_Event_Type (Event);
         if Event_Type = Gdk_2button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (1) then

               Gtk_New (Internal_Dialog);
               Read_Parameters (Item, Gtk_Dialog (Internal_Dialog));
               Me_Data.It  := ME_Link_Ref (Item);
               Me_Data.Dia := Gtk_Dialog (Internal_Dialog);

               Me_Link_And_Dialog_Cb.Connect
                 (Internal_Dialog.Ok_Button,
                  "clicked",
                  Me_Link_And_Dialog_Cb.To_Marshaller (Write_Internal'Access),
                  Me_Data);

            end if;
         elsif Event_Type = Button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (3) then
               Gtk_New (Item_Menu);
               Button_Cb.Connect
                 (Item_Menu.Remove,
                  "activate",
                  Button_Cb.To_Marshaller (Remove_Link'Access),
                  ME_Link_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Properties,
                  "activate",
                  Button_Cb.To_Marshaller (Properties_Int'Access),
                  ME_Link_Ref (Item));
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
     (Item  : access ME_External_Link;
      Event : Gdk.Event.Gdk_Event_Button)
   is
      Num_Button      : Guint;
      Event_Type      : Gdk_Event_Type;
      External_Dialog : External_Dialog_Access;
      Me_Data         : ME_Link_And_Dialog_Ref := new ME_Link_And_Dialog;
   begin
      if Event /= null then
         Event_Type := Get_Event_Type (Event);
         if Event_Type = Gdk_2button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (1) then

               Gtk_New (External_Dialog);
               Read_Parameters (Item, Gtk_Dialog (External_Dialog));
               Me_Data.It  := ME_Link_Ref (Item);
               Me_Data.Dia := Gtk_Dialog (External_Dialog);

               Me_Link_And_Dialog_Cb.Connect
                 (External_Dialog.Ok_Button,
                  "clicked",
                  Me_Link_And_Dialog_Cb.To_Marshaller (Write_External'Access),
                  Me_Data);

            end if;
         elsif Event_Type = Button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (3) then
               Gtk_New (Item_Menu);
               Button_Cb.Connect
                 (Item_Menu.Remove,
                  "activate",
                  Button_Cb.To_Marshaller (Remove_Link'Access),
                  ME_Link_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Properties,
                  "activate",
                  Button_Cb.To_Marshaller (Properties_Ext'Access),
                  ME_Link_Ref (Item));
            end if;
         end if;
      end if;
   exception
      when Storage_Error =>
         null;
   end On_Button_Click;

   -----------
   -- Print --
   -----------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Internal_Link;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Mast_Editor.Links.Print (File, ME_Link (Item), Indentation);
      Put (File, " ");
      Put (File, "Me_Internal_Link");
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
      Item        : in out ME_External_Link;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Mast_Editor.Links.Print (File, ME_Link (Item), Indentation);
      Put (File, " ");
      Put (File, "Me_External_Link");
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

end Mast_Editor.Links;
