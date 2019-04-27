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
with Ada.Tags;                use Ada.Tags;
with Ada.Text_IO;             use Ada.Text_IO;
with Ada.Characters.Handling;

with Callbacks_Mast_Editor; use Callbacks_Mast_Editor;
with Gdk.Color;             use Gdk.Color;
with Gdk.Drawable;          use Gdk.Drawable;
with Gdk.Font;              use Gdk.Font;
with Gdk.Rectangle;         use Gdk.Rectangle;
with Gtk.Alignment;         use Gtk.Alignment;
with Gtk.Box;               use Gtk.Box;
with Gtk.Button;            use Gtk.Button;
with Gtk.Combo;             use Gtk.Combo;
with Gtk.Frame;             use Gtk.Frame;
with Gtk.Handlers;          use Gtk.Handlers;
with Gtk.GEntry;            use Gtk.GEntry;
with Gtk.Label;             use Gtk.Label;
with Gtk.Menu_Item;         use Gtk.Menu_Item;
with Gtk.Scrolled_Window;   use Gtk.Scrolled_Window;
with Gtk.Separator;         use Gtk.Separator;
with Gtk.Widget;            use Gtk.Widget;
with Gtkada.Canvas;         use Gtkada.Canvas;
with Pango.Font;            use Pango.Font;
with Gtkada.Dialogs;        use Gtkada.Dialogs;

with List_Exceptions;             use List_Exceptions;
with Mast;                        use Mast;
with Mast.IO;                     use Mast.IO;
with Mast.Shared_Resources;       use Mast.Shared_Resources;
with Mast.Operations;             use Mast.Operations;
with Mast.Scheduling_Servers;     use Mast.Scheduling_Servers;
with Mast.Transactions;           use Mast.Transactions;
with Mast.Transaction_Operations; use Mast.Transaction_Operations;
with Mast.Graphs;                 use Mast.Graphs;
with Mast.Graphs.Event_Handlers;  use Mast.Graphs.Event_Handlers;

with Aux_Window_Pkg;                 use Aux_Window_Pkg;
with Item_Menu_Pkg;                  use Item_Menu_Pkg;
with Editor_Error_Window_Pkg;        use Editor_Error_Window_Pkg;
with Shared_Resource_Dialog_Pkg;     use Shared_Resource_Dialog_Pkg;
with Editor_Actions;                 use Editor_Actions;
with Mast_Editor.Operations;         use Mast_Editor.Operations;
with Mast_Editor.Scheduling_Servers; use Mast_Editor.Scheduling_Servers;
with Change_Control;

package body Mast_Editor.Shared_Resources is

   package Canvas_Cb is new Gtk.Handlers.Callback (
      Interactive_Canvas_Record);

   package Button_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Shared_Resource_Ref);

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

   type ME_Shared_Resource_And_Dialog is record
      It  : ME_Shared_Resource_Ref;
      Dia : Gtk_Dialog;
   end record;

   type ME_Shared_Resource_And_Dialog_Ref is access all
     ME_Shared_Resource_And_Dialog;

   package Me_Shared_Resource_And_Dialog_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Shared_Resource_And_Dialog_Ref);

   --------------
   -- Name     --
   --------------
   function Name (Item : in ME_Shared_Resource) return Var_String is
   begin
      return Name (Item.Share);
   end Name;

   --------------
   -- Name     --
   --------------
   function Name (Item_Ref : in ME_Shared_Resource_Ref) return Var_String is
   begin
      return Name (Item_Ref.Share);
   end Name;

   -----------------
   -- Print       --
   -----------------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Shared_Resource;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Ada.Text_IO.Set_Col (File, Ada.Text_IO.Count (Indentation));
      Ada.Text_IO.Put (File, "ME_Shared_Resource");
   end Print;

   -----------------
   -- Print       --
   -----------------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive)
   is
      Item_Ref : ME_Shared_Resource_Ref;
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
     (Item   : access ME_Priority_Inheritance_Resource;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Shared_Ref             : Shared_Resource_Ref           :=
        ME_Shared_Resource_Ref (Item).Share;
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access :=
         Shared_Resource_Dialog_Access (Dialog);
   begin
      Change_Control.Changes_Made;
      if (Get_Text
             (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo)) /=
          "Priority Inheritance Resource")
      then
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Type Conversion Not Valid");
         Show_All (Editor_Error_Window);
      else
         Init
           (Shared_Ref.all,
            Var_Strings.To_Lower
               (To_Var_String
                   (Get_Text (Shared_Resource_Dialog.Shared_Res_Name_Entry))));
      end if;
   end Write_Parameters;

   ----------------------
   -- Write Parameters --
   ----------------------
   procedure Write_Parameters
     (Item   : access ME_Immediate_Ceiling_Resource;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Shared_Ref             : Shared_Resource_Ref           :=
        ME_Shared_Resource_Ref (Item).Share;
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access :=
         Shared_Resource_Dialog_Access (Dialog);
   begin
      Change_Control.Changes_Made;
      if (Get_Text
             (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo)) /=
          "Immediate Ceiling Resource")
      then
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Type Conversion Not Valid");
         Show_All (Editor_Error_Window);
      else
         Init
           (Shared_Ref.all,
            Var_Strings.To_Lower
               (To_Var_String
                   (Get_Text (Shared_Resource_Dialog.Shared_Res_Name_Entry))));
         if (Get_Text (Get_Entry
                          (Shared_Resource_Dialog.Preassigned_Combo)) =
             "YES")
         then
            Set_Preassigned
              (Immediate_Ceiling_Resource (Shared_Ref.all),
               True);
         else
            Set_Preassigned
              (Immediate_Ceiling_Resource (Shared_Ref.all),
               False);
         end if;
         Set_Ceiling
           (Immediate_Ceiling_Resource (Shared_Ref.all),
            Priority'Value (Get_Text (Shared_Resource_Dialog.Ceiling_Entry)));
      end if;
   end Write_Parameters;

   ----------------------
   -- Write Parameters --
   ----------------------
   procedure Write_Parameters
     (Item   : access ME_SRP_Resource;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Shared_Ref             : Shared_Resource_Ref           :=
        ME_Shared_Resource_Ref (Item).Share;
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access :=
         Shared_Resource_Dialog_Access (Dialog);
   begin
      Change_Control.Changes_Made;
      if (Get_Text
             (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo)) /=
          "Stack Resource Policy")
      then
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Type Conversion Not Valid");
         Show_All (Editor_Error_Window);
      else
         Init
           (Shared_Ref.all,
            Var_Strings.To_Lower
               (To_Var_String
                   (Get_Text (Shared_Resource_Dialog.Shared_Res_Name_Entry))));
         if (Get_Text (Get_Entry
                          (Shared_Resource_Dialog.Preassigned_Combo)) =
             "YES")
         then
            Set_Preassigned (SRP_Resource (Shared_Ref.all), True);
         else
            Set_Preassigned (SRP_Resource (Shared_Ref.all), False);
         end if;
         Set_Level
           (SRP_Resource (Shared_Ref.all),
            Preemption_Level'Value
               (Get_Text (Shared_Resource_Dialog.Level_Entry)));
      end if;
   end Write_Parameters;

   ---------------------
   -- Read Parameters --
   ---------------------
   procedure Read_Parameters
     (Item   : access ME_Priority_Inheritance_Resource;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Shared_Ref             : Shared_Resource_Ref           := Item.Share;
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access :=
         Shared_Resource_Dialog_Access (Dialog);
   begin
      Set_Text
        (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo),
         "Priority Inheritance Resource");
      if Shared_Ref /= null then
         Set_Text
           (Shared_Resource_Dialog.Shared_Res_Name_Entry,
            Name_Image (Name (Shared_Ref)));
      end if;
      Show_All (Shared_Resource_Dialog);
      Hide (Shared_Resource_Dialog.Preassigned_Label);
      Hide (Shared_Resource_Dialog.Preassigned_Combo);
      Hide (Shared_Resource_Dialog.Ceiling_Label);
      Hide (Shared_Resource_Dialog.Ceiling_Entry);
      Hide (Shared_Resource_Dialog.Level_Label);
      Hide (Shared_Resource_Dialog.Level_Entry);
   end Read_Parameters;

   ---------------------
   -- Read Parameters --
   ---------------------
   procedure Read_Parameters
     (Item   : access ME_Immediate_Ceiling_Resource;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Shared_Ref             : Shared_Resource_Ref           := Item.Share;
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access :=
         Shared_Resource_Dialog_Access (Dialog);
   begin
      Set_Text
        (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo),
         "Immediate Ceiling Resource");
      if Shared_Ref /= null then
         Set_Text
           (Shared_Resource_Dialog.Shared_Res_Name_Entry,
            Name_Image (Name (Shared_Ref)));
         if Preassigned (Immediate_Ceiling_Resource (Shared_Ref.all)) then
            Set_Text
              (Get_Entry (Shared_Resource_Dialog.Preassigned_Combo),
               "YES");
         else
            Set_Text
              (Get_Entry (Shared_Resource_Dialog.Preassigned_Combo),
               "NO");
         end if;
         Set_Text
           (Shared_Resource_Dialog.Ceiling_Entry,
            Priority'Image
               (Ceiling (Immediate_Ceiling_Resource (Shared_Ref.all))));
      end if;
      Show_All (Shared_Resource_Dialog);
      Hide (Shared_Resource_Dialog.Level_Label);
      Hide (Shared_Resource_Dialog.Level_Entry);
   end Read_Parameters;

   ---------------------
   -- Read Parameters --
   ---------------------
   procedure Read_Parameters
     (Item   : access ME_SRP_Resource;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Shared_Ref             : Shared_Resource_Ref           := Item.Share;
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access :=
         Shared_Resource_Dialog_Access (Dialog);
   begin
      Set_Text
        (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo),
         "Stack Resource Policy");
      if Shared_Ref /= null then
         Set_Text
           (Shared_Resource_Dialog.Shared_Res_Name_Entry,
            Name_Image (Name (Shared_Ref)));
         if Preassigned (SRP_Resource (Shared_Ref.all)) then
            Set_Text
              (Get_Entry (Shared_Resource_Dialog.Preassigned_Combo),
               "YES");
         else
            Set_Text
              (Get_Entry (Shared_Resource_Dialog.Preassigned_Combo),
               "NO");
         end if;
         Set_Text
           (Shared_Resource_Dialog.Level_Entry,
            Preemption_Level'Image (Level (SRP_Resource (Shared_Ref.all))));
      end if;
      Show_All (Shared_Resource_Dialog);
      Hide (Shared_Resource_Dialog.Ceiling_Label);
      Hide (Shared_Resource_Dialog.Ceiling_Entry);
   end Read_Parameters;

   -----------------------------------------
   -- Draw Priority Inheritance Resource  --
   -----------------------------------------
   procedure Draw
     (Item         : access ME_Priority_Inheritance_Resource;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint)
   is
      Rect       : constant Gdk_Rectangle := Get_Coord (Item);
      W          : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Width);
      H          : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Height);
      Shared     : Shared_Resource_Ref    := Item.Share;
      Share_Name : String                 := Name_Image (Name (Shared));
      Color      : Gdk.Color.Gdk_Color;
   begin
      Color := Parse (To_String (ME_Shared_Resource_Ref (Item).Color_Name));
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
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 5 * H / 10,
            Text => "PRIORITY");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 7 * H / 10,
            Text => "INHERITANCE");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 20,
            Ydest + H / 6,
            Share_Name);
      elsif Get_Zoom (Canvas) = Zoom_Levels (2) then
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 5 * H / 12,
            Text => "PRIORITY");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 7 * H / 12,
            Text => "INHERITANCE");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 20,
            Ydest + H / 6,
            Share_Name);
      else
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 10,
            Ydest + 3 * H / 6,
            Text => "PRIORITY INHERITANCE");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 10,
            Ydest + H / 7,
            Share_Name);
      end if;
   end Draw;

   --------------------------------------
   -- Draw Immediate Ceiling Resource  --
   --------------------------------------
   procedure Draw
     (Item         : access ME_Immediate_Ceiling_Resource;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint)
   is
      Rect       : constant Gdk_Rectangle := Get_Coord (Item);
      W          : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Width);
      H          : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Height);
      Shared     : Shared_Resource_Ref    := Item.Share;
      Share_Name : String                 := Name_Image (Name (Shared));
      Color      : Gdk.Color.Gdk_Color;
   begin
      Color := Parse (To_String (ME_Shared_Resource_Ref (Item).Color_Name));
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
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 5 * H / 10,
            Text => "IMMEDIATE");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 7 * H / 10,
            Text => "CEILING");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 20,
            Ydest + H / 6,
            Share_Name);
      elsif Get_Zoom (Canvas) = Zoom_Levels (2) then
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 5 * H / 12,
            Text => "IMMEDIATE");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 7 * H / 12,
            Text => "CEILING");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 9 * H / 10,
            "Ceiling:" &
            Priority'Image
               (Ceiling (Immediate_Ceiling_Resource (Shared.all))));
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 20,
            Ydest + H / 6,
            Share_Name);
      else
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 10,
            Ydest + 3 * H / 6,
            Text => "IMMEDIATE CEILING");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 10,
            Ydest + 8 * H / 10,
            "Ceiling:" &
            Priority'Image
               (Ceiling (Immediate_Ceiling_Resource (Shared.all))));
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 10,
            Ydest + H / 6,
            Share_Name);
      end if;
   end Draw;

   --------------------------------
   -- Draw Stack Resource Policy --
   --------------------------------
   procedure Draw
     (Item         : access ME_SRP_Resource;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint)
   is
      Rect       : constant Gdk_Rectangle := Get_Coord (Item);
      W          : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Width);
      H          : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Height);
      Shared     : Shared_Resource_Ref    := Item.Share;
      Share_Name : String                 := Name_Image (Name (Shared));
      Color      : Gdk.Color.Gdk_Color;
   begin
      Color := Parse (To_String (ME_Shared_Resource_Ref (Item).Color_Name));
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
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 5 * H / 10,
            Text => "STACK");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 7 * H / 10,
            Text => "RESOURCE");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 9 * H / 10,
            Text => "POLICY");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 20,
            Ydest + H / 6,
            Share_Name);
      elsif Get_Zoom (Canvas) = Zoom_Levels (2) then
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 5 * H / 12,
            Text => "STACK RESOURCE");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 7 * H / 12,
            Text => "POLICY");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 9 * H / 10,
            "Preemp Level:" &
            Preemption_Level'Image (Level (SRP_Resource (Shared.all))));
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 20,
            Ydest + H / 6,
            Share_Name);
      else
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 10,
            Ydest + 3 * H / 6,
            Text => "STACK RESOURCE POLICY");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 10,
            Ydest + 8 * H / 10,
            "Preemp Level:" &
            Preemption_Level'Image (Level (SRP_Resource (Shared.all))));
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 10,
            Ydest + H / 6,
            Share_Name);
      end if;
   end Draw;

   --------------------------------
   -- Write Priority Inheritance --  (Write the params of an existing resource
   --and refresh the canvas)
   --------------------------------
   procedure Write_Priority_Inheritance
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Shared_Resource_And_Dialog_Ref)
   is
      Item                   : ME_Shared_Resource_Ref        := Data.It;
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access :=
         Shared_Resource_Dialog_Access (Data.Dia);
   begin
      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (Shared_Resource_Dialog.Shared_Res_Name_Entry)))
      then
         Write_Parameters (Item, Gtk_Dialog (Shared_Resource_Dialog));
         Refresh_Canvas (Shared_Res_Canvas);
         Destroy (Shared_Resource_Dialog);
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
         Destroy (Shared_Resource_Dialog);
   end Write_Priority_Inheritance;

   -----------------------------
   -- Write Immediate Ceiling -- (Write the params of an existing resource and
   --refresh the canvas)
   -----------------------------
   procedure Write_Immediate_Ceiling
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Shared_Resource_And_Dialog_Ref)
   is
      Item                   : ME_Shared_Resource_Ref        := Data.It;
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access :=
         Shared_Resource_Dialog_Access (Data.Dia);
   begin
      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (Shared_Resource_Dialog.Shared_Res_Name_Entry)))
      then
         Write_Parameters (Item, Gtk_Dialog (Shared_Resource_Dialog));
         Refresh_Canvas (Shared_Res_Canvas);
         Destroy (Shared_Resource_Dialog);
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
         Destroy (Shared_Resource_Dialog);
   end Write_Immediate_Ceiling;

   ------------------------
   -- Write SRP Resource -- (Write the params of an existing resource and
   --refresh the canvas)
   ------------------------
   procedure Write_SRP_Resource
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Shared_Resource_And_Dialog_Ref)
   is
      Item                   : ME_Shared_Resource_Ref        := Data.It;
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access :=
         Shared_Resource_Dialog_Access (Data.Dia);
   begin
      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (Shared_Resource_Dialog.Shared_Res_Name_Entry)))
      then
         Write_Parameters (Item, Gtk_Dialog (Shared_Resource_Dialog));
         Refresh_Canvas (Shared_Res_Canvas);
         Destroy (Shared_Resource_Dialog);
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
         Destroy (Shared_Resource_Dialog);
   end Write_SRP_Resource;

   --------------------
   -- New_Shared_Res -- (Add new shared resource to canvas and to the lists of
   --the systems)
   --------------------
   procedure New_Shared
     (Widget : access Shared_Resource_Dialog_Record'Class)
   is
      Item                   : ME_Shared_Resource_Ref;
      Shared_Ref             : Shared_Resource_Ref;
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access :=
         Shared_Resource_Dialog_Access (Widget);
   begin
      if Id_Name_Is_Valid
           (Ada.Characters.Handling.To_Lower
               (Get_Text (Shared_Resource_Dialog.Shared_Res_Name_Entry)))
      then
         if (Get_Text
                (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo)) =
             "Priority Inheritance Resource")
         then
            Item       := new ME_Priority_Inheritance_Resource;
            Shared_Ref := new Priority_Inheritance_Resource;
         elsif (Get_Text
                   (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo)) =
                "Immediate Ceiling Resource")
         then
            Item       := new ME_Immediate_Ceiling_Resource;
            Shared_Ref := new Immediate_Ceiling_Resource;
         elsif (Get_Text
                   (Get_Entry (Shared_Resource_Dialog.Shared_Res_Type_Combo)) =
                "Stack Resource Policy")
         then
            Item       := new ME_SRP_Resource;
            Shared_Ref := new SRP_Resource;
         end if;

         Item.W           := Share_Width;
         Item.H           := Share_Height;
         Item.Canvas_Name := To_Var_String ("Shared_Res_Canvas");
         Item.Color_Name  := Share_Color;
         Item.Share       := Shared_Ref;

         Write_Parameters (Item, Gtk_Dialog (Shared_Resource_Dialog));

         Mast.Shared_Resources.Lists.Add
           (Item.Share,
            The_System.Shared_Resources);
         Mast_Editor.Shared_Resources.Lists.Add
           (Item,
            Editor_System.Me_Shared_Resources);
         Set_Screen_Size (Item, Item.W, Item.H);
         Put (Shared_Res_Canvas, Item);
         Refresh_Canvas (Shared_Res_Canvas);
         Show_Item (Shared_Res_Canvas, Item);
         Destroy (Shared_Resource_Dialog);
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
         Destroy (Shared_Resource_Dialog);
      when Already_Exists =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " The Shared Resource Already Exists !!!");
         Show_All (Editor_Error_Window);
         Destroy (Shared_Resource_Dialog);
   end New_Shared;

   ------------------------
   -- Show Shared Dialog -- (Show the shared resource dialog)
   ------------------------
   procedure Show_Shared_Dialog (Widget : access Gtk_Button_Record'Class) is
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access;
   begin
      Gtk_New (Shared_Resource_Dialog);
      Show_All (Shared_Resource_Dialog);
      Hide (Shared_Resource_Dialog.Level_Label);
      Hide (Shared_Resource_Dialog.Level_Entry);

      Shared_Resource_Dialog_Callback.Object_Connect
        (Shared_Resource_Dialog.Ok_Button,
         "clicked",
         Shared_Resource_Dialog_Callback.To_Marshaller (New_Shared'Access),
         Shared_Resource_Dialog);
   end Show_Shared_Dialog;

   ------------------------
   -- Remove_Shared_Res  --
   ------------------------
   procedure Remove_Shared_Res
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Shared_Resource_Ref)
   is
      Share_Name      : Var_String;
      Share_Index     : Mast.Shared_Resources.Lists.Index;
      Item_Deleted    : Mast.Shared_Resources.Shared_Resource_Ref;
      Me_Share_Index  : Mast_Editor.Shared_Resources.Lists.Index;
      Me_Item_Deleted : Mast_Editor.Shared_Resources.ME_Shared_Resource_Ref;
   begin
      Share_Name   := Name (Item);
      Share_Index  :=
         Mast.Shared_Resources.Lists.Find
           (Share_Name,
            The_System.Shared_Resources);
      Item_Deleted :=
         Mast.Shared_Resources.Lists.Item
           (Share_Index,
            The_System.Shared_Resources);
      if Mast.Operations.List_References_Shared_Resource
           (Item_Deleted,
            The_System.Operations)
      then
         -- Operation cannot be deleted
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "SHARED OBJECT IS REFERENCED BY AN OPERATION");
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
            Mast.Shared_Resources.Lists.Delete
              (Share_Index,
               Item_Deleted,
               The_System.Shared_Resources);
            Me_Share_Index  :=
               Mast_Editor.Shared_Resources.Lists.Find
                 (Share_Name,
                  Editor_System.Me_Shared_Resources);
            Me_Item_Deleted :=
               Mast_Editor.Shared_Resources.Lists.Item
                 (Me_Share_Index,
                  Editor_System.Me_Shared_Resources);
            Mast_Editor.Shared_Resources.Lists.Delete
              (Me_Share_Index,
               Me_Item_Deleted,
               Editor_System.Me_Shared_Resources);
            Remove (Shared_Res_Canvas, Item);
            Refresh_Canvas (Shared_Res_Canvas);
            Change_Control.Changes_Made;
            Destroy (Item_Menu);
         end if;
      end if;
   exception
      when Invalid_Index =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "ERROR IN RESOURCE REMOVAL !!!");
         Show_All (Editor_Error_Window);
         Put_Line
           (Positive'Image
               (Mast.Shared_Resources.Lists.Size
                   (The_System.Shared_Resources)));
         Put_Line
           (Positive'Image
               (Mast_Editor.Shared_Resources.Lists.Size
                   (Editor_System.Me_Shared_Resources)));
         Destroy (Item_Menu);
   end Remove_Shared_Res;

   -----------------------
   -- Properties_Prior  --
   -----------------------
   procedure Properties_Prior
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Shared_Resource_Ref)
   is
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access;
      Me_Data                : ME_Shared_Resource_And_Dialog_Ref :=
         new ME_Shared_Resource_And_Dialog;
   begin
      Gtk_New (Shared_Resource_Dialog);
      Read_Parameters (Item, Gtk_Dialog (Shared_Resource_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Shared_Resource_Dialog);

      Me_Shared_Resource_And_Dialog_Cb.Connect
        (Shared_Resource_Dialog.Ok_Button,
         "clicked",
         Me_Shared_Resource_And_Dialog_Cb.To_Marshaller
            (Write_Priority_Inheritance'Access),
         Me_Data);

      Refresh_Canvas (Shared_Res_Canvas);
      Destroy (Item_Menu);
   end Properties_Prior;

   -----------------------
   -- Properties_Imme  --
   -----------------------
   procedure Properties_Imme
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Shared_Resource_Ref)
   is
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access;
      Me_Data                : ME_Shared_Resource_And_Dialog_Ref :=
         new ME_Shared_Resource_And_Dialog;
   begin
      Gtk_New (Shared_Resource_Dialog);
      Read_Parameters (Item, Gtk_Dialog (Shared_Resource_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Shared_Resource_Dialog);

      Me_Shared_Resource_And_Dialog_Cb.Connect
        (Shared_Resource_Dialog.Ok_Button,
         "clicked",
         Me_Shared_Resource_And_Dialog_Cb.To_Marshaller
            (Write_Immediate_Ceiling'Access),
         Me_Data);

      Refresh_Canvas (Shared_Res_Canvas);
      Destroy (Item_Menu);
   end Properties_Imme;

   ---------------------
   -- Properties_SRP  --
   ---------------------
   procedure Properties_SRP
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Shared_Resource_Ref)
   is
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access;
      Me_Data                : ME_Shared_Resource_And_Dialog_Ref :=
         new ME_Shared_Resource_And_Dialog;
   begin
      Gtk_New (Shared_Resource_Dialog);
      Read_Parameters (Item, Gtk_Dialog (Shared_Resource_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Shared_Resource_Dialog);

      Me_Shared_Resource_And_Dialog_Cb.Connect
        (Shared_Resource_Dialog.Ok_Button,
         "clicked",
         Me_Shared_Resource_And_Dialog_Cb.To_Marshaller
            (Write_SRP_Resource'Access),
         Me_Data);

      Refresh_Canvas (Shared_Res_Canvas);
      Destroy (Item_Menu);
   end Properties_SRP;

   ------------------
   -- View_Servers -- Show Auxiliary Window with servers associated to shared
   --resource
   ------------------
   procedure View_Servers
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Shared_Resource_Ref)
   is
      Temp_Item      : ME_Shared_Resource_Ref;
      Temp_List      : Mast_Editor.Scheduling_Servers.Lists.List;
      Me_Server_Ref  : Mast_Editor.Scheduling_Servers.ME_Scheduling_Server_Ref;
      A_Link_Ref     : Mast.Graphs.Link_Ref;
      Link_Iterator  : Mast.Transactions.Link_Iteration_Object;
      Trans_Ref      : Mast.Transactions.Transaction_Ref;
      Trans_Iterator : Mast.Transactions.Lists.Iteration_Object;
      Aux            : Aux_Window_Access;
      Init_X         : Gint := 10;
      Init_Y         : Gint := 60;
      Coord_X        : Gint := 300;
      Coord_Y        : Gint := 10;
      Space          : Gint := 75;

      procedure Null_Op
        (Trans_Ref    : Mast.Transactions.Transaction_Ref;
         The_Link_Ref : Mast.Graphs.Link_Ref)
      is
      begin
         null;
      end Null_Op;

      procedure Search_Server
        (Trans_Ref    : Mast.Transactions.Transaction_Ref;
         The_Link_Ref : Mast.Graphs.Event_Handler_Ref)
      is
         Oper_Ref      : Mast.Operations.Operation_Ref;
         Reso_Ref      : Mast.Shared_Resources.Shared_Resource_Ref;
         Serv_Ref      : Mast.Scheduling_Servers.Scheduling_Server_Ref;
         Oper_Iterator : Mast.Operations.Lists.Iteration_Object;
         Reso_Iterator : Mast.Operations.Resource_Iteration_Object;
      begin
         if The_Link_Ref.all in Graphs.Event_Handlers.Activity'Class then
            Oper_Ref :=
               Mast.Graphs.Event_Handlers.Activity_Operation
                 (Graphs.Event_Handlers.Activity (The_Link_Ref.all));
            if (Mast.Operations.Operation_References_Shared_Resource
                (Oper_Ref.all,Item.Share))
            then
               Serv_Ref                  :=
                 Mast.Graphs.Event_Handlers.Activity_Server
                 (Graphs.Event_Handlers.Activity (The_Link_Ref.all));
               Me_Server_Ref             := new ME_Server;
               Me_Server_Ref.W           := Ser_Width;
               Me_Server_Ref.H           := Ser_Height;
               Me_Server_Ref.Canvas_Name :=
                 To_Var_String ("Aux_Canvas");
               Me_Server_Ref.Color_Name  := Ser_Color;
               Me_Server_Ref.Ser         := Serv_Ref;
               begin
                  Mast_Editor.Scheduling_Servers.Lists.Add
                    (Me_Server_Ref,
                     Temp_List);
                  Set_Screen_Size
                    (Me_Server_Ref,
                     Me_Server_Ref.W,
                     Me_Server_Ref.H);
                  Put (Aux.Aux_Canvas, Me_Server_Ref, Coord_X, Coord_Y);
                  Coord_Y := Coord_Y + Space;
                  Add_Canvas_Link
                    (Aux.Aux_Canvas,
                     Me_Server_Ref,
                     Temp_Item);
               exception
                  when Already_Exists =>
                     null;
               end;
            end if;
         end if;
      end Search_Server;

      procedure Iterate_Transaction_Paths is new
        Mast.Transaction_Operations.Traverse_Paths_From_Link_Once (
         Operation_For_Links => Null_Op,
         Operation_For_Event_Handlers => Search_Server);

   begin
      if Item.all'Tag = ME_Priority_Inheritance_Resource'Tag then
         Temp_Item := new ME_Priority_Inheritance_Resource;
      elsif Item.all'Tag = ME_Immediate_Ceiling_Resource'Tag then
         Temp_Item := new ME_Immediate_Ceiling_Resource;
      elsif Item.all'Tag = ME_SRP_Resource'Tag then
         Temp_Item := new ME_SRP_Resource;
      end if;
      Temp_Item.Color_Name  := Share_Color;
      Temp_Item.W           := Share_Width;
      Temp_Item.H           := Share_Height;
      Temp_Item.Canvas_Name := To_Var_String ("Aux_Canvas");
      Temp_Item.Share       := Item.Share;
      Gtk_New (Aux);
      Set_Title (Aux, "Scheduling Servers associated to Shared Resource");
      Set_Screen_Size (Temp_Item, Temp_Item.W, Temp_Item.H);
      Put (Aux.Aux_Canvas, Temp_Item, Init_X, Init_Y);

      -- Loop for each transaction
      Mast.Transactions.Lists.Rewind
        (The_System.Transactions,
         Trans_Iterator);
      for I in 1 .. Mast.Transactions.Lists.Size (The_System.Transactions)
      loop
         Mast.Transactions.Lists.Get_Next_Item
           (Trans_Ref,
            The_System.Transactions,
            Trans_Iterator);
         -- loop for each path in the transaction
         Transactions.Rewind_External_Event_Links
           (Trans_Ref.all,
            Link_Iterator);
         for I in
               1 .. Transactions.Num_Of_External_Event_Links (Trans_Ref.all)
         loop
            Transactions.Get_Next_External_Event_Link
              (Trans_Ref.all,
               A_Link_Ref,
               Link_Iterator);
            Iterate_Transaction_Paths (Trans_Ref, A_Link_Ref);
         end loop;
      end loop;

      Refresh_Canvas (Aux.Aux_Canvas);
      Show_All (Aux);
   end View_Servers;

   ---------------------
   -- View_Operations -- Show Auxiliary Window with SIMPLE operations using
   --shared resource
   ---------------------
   procedure View_Operations
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Shared_Resource_Ref)
   is
      Temp_Item        : ME_Shared_Resource_Ref;
      Shared_Ref       : Shared_Resource_Ref := Item.Share;
      Temp_List        : Mast_Editor.Operations.Lists.List;
      Me_Operation_Ref : Mast_Editor.Operations.ME_Operation_Ref;
      Op_Ref           : Mast.Operations.Operation_Ref;
      Op_Iterator      : Mast.Operations.Lists.Iteration_Object;
      Res_Iterator     : Mast.Operations.Resource_Iteration_Object;
      Aux              : Aux_Window_Access;
      Init_X           : Gint                := 10;
      Init_Y           : Gint                := 60;
      Coord_X          : Gint                := 300;
      Coord_Y          : Gint                := 10;
      Space            : Gint                := 75;
   begin
      if Item.all'Tag = ME_Priority_Inheritance_Resource'Tag then
         Temp_Item := new ME_Priority_Inheritance_Resource;
      elsif Item.all'Tag = ME_Immediate_Ceiling_Resource'Tag then
         Temp_Item := new ME_Immediate_Ceiling_Resource;
      elsif Item.all'Tag = ME_SRP_Resource'Tag then
         Temp_Item := new ME_SRP_Resource;
      end if;
      Temp_Item.Color_Name  := Share_Color;
      Temp_Item.W           := Share_Width;
      Temp_Item.H           := Share_Height;
      Temp_Item.Canvas_Name := To_Var_String ("Aux_Canvas");
      Temp_Item.Share       := Item.Share;
      Gtk_New (Aux);
      Set_Title (Aux, "Operations using Shared Resource");
      Set_Screen_Size (Temp_Item, Temp_Item.W, Temp_Item.H);
      Put (Aux.Aux_Canvas, Temp_Item, Init_X, Init_Y);

      Mast.Operations.Lists.Rewind (The_System.Operations, Op_Iterator);
      for I in 1 .. Mast.Operations.Lists.Size (The_System.Operations) loop
         Mast.Operations.Lists.Get_Next_Item
           (Op_Ref,
            The_System.Operations,
            Op_Iterator);
         if Op_Ref.all'Tag = Mast.Operations.Simple_Operation'Tag then
            -- Locked Resources --
            Rewind_Locked_Resources
              (Simple_Operation (Op_Ref.all),
               Res_Iterator);
            for I in
                  1 ..
                  Num_Of_Locked_Resources (Simple_Operation (Op_Ref.all))
            loop
               Get_Next_Locked_Resource
                 (Simple_Operation (Op_Ref.all),
                  Shared_Ref,
                  Res_Iterator);
               if Mast.Shared_Resources.Name (Shared_Ref) =
                  Mast_Editor.Shared_Resources.Name (Item)
               then
                  Me_Operation_Ref             := new ME_Simple_Operation;
                  Me_Operation_Ref.W           := Op_Width;
                  Me_Operation_Ref.H           := Op_Height;
                  Me_Operation_Ref.Canvas_Name :=
                     To_Var_String ("Aux_Canvas");
                  Me_Operation_Ref.Color_Name  := Sop_Color;
                  Me_Operation_Ref.Op          := Op_Ref;
                  begin
                     Mast_Editor.Operations.Lists.Add
                       (Me_Operation_Ref,
                        Temp_List);
                     Set_Screen_Size
                       (Me_Operation_Ref,
                        Me_Operation_Ref.W,
                        Me_Operation_Ref.H);
                     Put (Aux.Aux_Canvas, Me_Operation_Ref, Coord_X, Coord_Y);
                     Coord_Y := Coord_Y + Space;
                     Add_Canvas_Link
                       (Aux.Aux_Canvas,
                        Me_Operation_Ref,
                        Temp_Item);
                  exception
                     when Already_Exists =>
                        null;
                  end;
               end if;
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
               if Mast.Shared_Resources.Name (Shared_Ref) =
                  Mast_Editor.Shared_Resources.Name (Item)
               then
                  Me_Operation_Ref             := new ME_Simple_Operation;
                  Me_Operation_Ref.W           := Op_Width;
                  Me_Operation_Ref.H           := Op_Height;
                  Me_Operation_Ref.Canvas_Name :=
                     To_Var_String ("Aux_Canvas");
                  Me_Operation_Ref.Color_Name  := Sop_Color;
                  Me_Operation_Ref.Op          := Op_Ref;
                  begin
                     Mast_Editor.Operations.Lists.Add
                       (Me_Operation_Ref,
                        Temp_List);
                     Set_Screen_Size
                       (Me_Operation_Ref,
                        Me_Operation_Ref.W,
                        Me_Operation_Ref.H);
                     Put (Aux.Aux_Canvas, Me_Operation_Ref, Coord_X, Coord_Y);
                     Coord_Y := Coord_Y + Space;
                     Add_Canvas_Link
                       (Aux.Aux_Canvas,
                        Me_Operation_Ref,
                        Temp_Item);
                  exception
                     when Already_Exists =>
                        null;
                  end;
               end if;
            end loop;
         end if;
      end loop;
      Refresh_Canvas (Aux.Aux_Canvas);
      Show_All (Aux);
   end View_Operations;

   ---------------------
   -- On Button Click --
   ---------------------
   procedure On_Button_Click
     (Item  : access ME_Priority_Inheritance_Resource;
      Event : Gdk.Event.Gdk_Event_Button)
   is
      Num_Button             : Guint;
      Event_Type             : Gdk_Event_Type;
      View_Serv, View_Op     : Gtk_Menu_Item;
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access;
      Me_Data                : ME_Shared_Resource_And_Dialog_Ref :=
         new ME_Shared_Resource_And_Dialog;
   begin
      if Event /= null
        and then Item.Canvas_Name /= To_Var_String ("Aux_Canvas")
      then
         Event_Type := Get_Event_Type (Event);
         if Event_Type = Gdk_2button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (1) then

               Gtk_New (Shared_Resource_Dialog);
               Read_Parameters (Item, Gtk_Dialog (Shared_Resource_Dialog));
               Me_Data.It  := ME_Shared_Resource_Ref (Item);
               Me_Data.Dia := Gtk_Dialog (Shared_Resource_Dialog);

               Me_Shared_Resource_And_Dialog_Cb.Connect
                 (Shared_Resource_Dialog.Ok_Button,
                  "clicked",
                  Me_Shared_Resource_And_Dialog_Cb.To_Marshaller
                     (Write_Priority_Inheritance'Access),
                  Me_Data);

            end if;
         elsif Event_Type = Button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (3) then
               Gtk_New (Item_Menu);
               --We add a new options to item_menu
               Gtk_New (View_Op, "View Operations");
               Set_Right_Justify (View_Op, False);
               Prepend (Item_Menu, View_Op);
               Show (View_Op);
               Gtk_New (View_Serv, "View Servers");
               Set_Right_Justify (View_Serv, False);
               Prepend (Item_Menu, View_Serv);
               Show (View_Serv);
               -------------------
               Button_Cb.Connect
                 (View_Op,
                  "activate",
                  Button_Cb.To_Marshaller (View_Operations'Access),
                  ME_Shared_Resource_Ref (Item));
               Button_Cb.Connect
                 (View_Serv,
                  "activate",
                  Button_Cb.To_Marshaller (View_Servers'Access),
                  ME_Shared_Resource_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Remove,
                  "activate",
                  Button_Cb.To_Marshaller (Remove_Shared_Res'Access),
                  ME_Shared_Resource_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Properties,
                  "activate",
                  Button_Cb.To_Marshaller (Properties_Prior'Access),
                  ME_Shared_Resource_Ref (Item));
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
     (Item  : access ME_Immediate_Ceiling_Resource;
      Event : Gdk.Event.Gdk_Event_Button)
   is
      Num_Button             : Guint;
      Event_Type             : Gdk_Event_Type;
      View_Serv, View_Op     : Gtk_Menu_Item;
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access;
      Me_Data                : ME_Shared_Resource_And_Dialog_Ref :=
         new ME_Shared_Resource_And_Dialog;
   begin
      if Event /= null
        and then Item.Canvas_Name /= To_Var_String ("Aux_Canvas")
      then
         Event_Type := Get_Event_Type (Event);
         if Event_Type = Gdk_2button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (1) then

               Gtk_New (Shared_Resource_Dialog);
               Read_Parameters (Item, Gtk_Dialog (Shared_Resource_Dialog));
               Me_Data.It  := ME_Shared_Resource_Ref (Item);
               Me_Data.Dia := Gtk_Dialog (Shared_Resource_Dialog);

               Me_Shared_Resource_And_Dialog_Cb.Connect
                 (Shared_Resource_Dialog.Ok_Button,
                  "clicked",
                  Me_Shared_Resource_And_Dialog_Cb.To_Marshaller
                     (Write_Immediate_Ceiling'Access),
                  Me_Data);

            end if;
         elsif Event_Type = Button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (3) then
               Gtk_New (Item_Menu);
               --We add a new options to item_menu
               Gtk_New (View_Op, "View Operations");
               Set_Right_Justify (View_Op, False);
               Prepend (Item_Menu, View_Op);
               Show (View_Op);
               Gtk_New (View_Serv, "View Servers");
               Set_Right_Justify (View_Serv, False);
               Prepend (Item_Menu, View_Serv);
               Show (View_Serv);
               -------------------
               Button_Cb.Connect
                 (View_Op,
                  "activate",
                  Button_Cb.To_Marshaller (View_Operations'Access),
                  ME_Shared_Resource_Ref (Item));
               Button_Cb.Connect
                 (View_Serv,
                  "activate",
                  Button_Cb.To_Marshaller (View_Servers'Access),
                  ME_Shared_Resource_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Remove,
                  "activate",
                  Button_Cb.To_Marshaller (Remove_Shared_Res'Access),
                  ME_Shared_Resource_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Properties,
                  "activate",
                  Button_Cb.To_Marshaller (Properties_Imme'Access),
                  ME_Shared_Resource_Ref (Item));
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
     (Item  : access ME_SRP_Resource;
      Event : Gdk.Event.Gdk_Event_Button)
   is
      Num_Button             : Guint;
      Event_Type             : Gdk_Event_Type;
      View_Serv, View_Op     : Gtk_Menu_Item;
      Shared_Resource_Dialog : Shared_Resource_Dialog_Access;
      Me_Data                : ME_Shared_Resource_And_Dialog_Ref :=
         new ME_Shared_Resource_And_Dialog;
   begin
      if Event /= null
        and then Item.Canvas_Name /= To_Var_String ("Aux_Canvas")
      then
         Event_Type := Get_Event_Type (Event);
         if Event_Type = Gdk_2button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (1) then

               Gtk_New (Shared_Resource_Dialog);
               Read_Parameters (Item, Gtk_Dialog (Shared_Resource_Dialog));
               Me_Data.It  := ME_Shared_Resource_Ref (Item);
               Me_Data.Dia := Gtk_Dialog (Shared_Resource_Dialog);

               Me_Shared_Resource_And_Dialog_Cb.Connect
                 (Shared_Resource_Dialog.Ok_Button,
                  "clicked",
                  Me_Shared_Resource_And_Dialog_Cb.To_Marshaller
                     (Write_Immediate_Ceiling'Access),
                  Me_Data);

            end if;
         elsif Event_Type = Button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (3) then
               Gtk_New (Item_Menu);
               --We add a new options to item_menu
               Gtk_New (View_Op, "View Operations");
               Set_Right_Justify (View_Op, False);
               Prepend (Item_Menu, View_Op);
               Show (View_Op);
               Gtk_New (View_Serv, "View Servers");
               Set_Right_Justify (View_Serv, False);
               Prepend (Item_Menu, View_Serv);
               Show (View_Serv);
               -------------------
               Button_Cb.Connect
                 (View_Op,
                  "activate",
                  Button_Cb.To_Marshaller (View_Operations'Access),
                  ME_Shared_Resource_Ref (Item));
               Button_Cb.Connect
                 (View_Serv,
                  "activate",
                  Button_Cb.To_Marshaller (View_Servers'Access),
                  ME_Shared_Resource_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Remove,
                  "activate",
                  Button_Cb.To_Marshaller (Remove_Shared_Res'Access),
                  ME_Shared_Resource_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Properties,
                  "activate",
                  Button_Cb.To_Marshaller (Properties_SRP'Access),
                  ME_Shared_Resource_Ref (Item));
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
      Item        : in out ME_Priority_Inheritance_Resource;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Mast_Editor.Shared_Resources.Print
        (File,
         ME_Shared_Resource (Item),
         Indentation);
      Put (File, " ");
      Put (File, "Me_Priority_Inheritance_Resource");
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
      Item        : in out ME_Immediate_Ceiling_Resource;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Mast_Editor.Shared_Resources.Print
        (File,
         ME_Shared_Resource (Item),
         Indentation);
      Put (File, " ");
      Put (File, "Me_Immediate_Ceiling_Resource");
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
      Item        : in out ME_SRP_Resource;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Mast_Editor.Shared_Resources.Print
        (File,
         ME_Shared_Resource (Item),
         Indentation);
      Put (File, " ");
      Put (File, "Me_SRP_Resource");
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

      Gtk_New (Shared_Res_Canvas);
      Configure
        (Shared_Res_Canvas,
         Grid_Size        => 0,
         Annotation_Font  => Pango.Font.From_String (Default_Annotation_Font),
         Arc_Link_Offset  => Default_Arc_Link_Offset,
         Arrow_Angle      => Default_Arrow_Angle,
         Arrow_Length     => Default_Arrow_Length,
         Motion_Threshold => Default_Motion_Threshold);
      Add (Scrolled, Shared_Res_Canvas);

      Gtk_New (Button, "Simple" & ASCII.LF & "Mode");
      Pack_Start (Cbox, Button, False, True, 0);
      Canvas_Cb.Object_Connect
        (Button,
         "clicked",
         Canvas_Cb.To_Marshaller (Simple_Mode'Access),
         Shared_Res_Canvas);

      Gtk_New (Button, "Complete Mode" & ASCII.LF & "(Non-Expanded)");
      Pack_Start (Cbox, Button, False, True, 0);
      Canvas_Cb.Object_Connect
        (Button,
         "clicked",
         Canvas_Cb.To_Marshaller (Complete_Mode_Non'Access),
         Shared_Res_Canvas);

      Gtk_New (Button, "Complete Mode" & ASCII.LF & "(Expanded)");
      Pack_Start (Cbox, Button, False, True, 0);
      Canvas_Cb.Object_Connect
        (Button,
         "clicked",
         Canvas_Cb.To_Marshaller (Complete_Mode_Exp'Access),
         Shared_Res_Canvas);

      Gtk_New_Vseparator (Vseparator);
      Pack_Start (Bbox, Vseparator, False, False, 10);

      Gtk_New (Button, "New Shared" & ASCII.LF & "Resource");
      Pack_Start (Bbox, Button, True, True, 4);
      Button_Callback.Connect
        (Button,
         "clicked",
         Button_Callback.To_Marshaller (Show_Shared_Dialog'Access));

      Gtk_New (Alignment, 0.5, 0.5, 1.0, 1.0);
      Pack_Start (Bbox, Alignment, True, True, 4);
      Gtk_New (Alignment, 0.5, 0.5, 1.0, 1.0);
      Pack_Start (Bbox, Alignment, True, True, 4);
      Gtk_New (Alignment, 0.5, 0.5, 1.0, 1.0);
      Pack_Start (Bbox, Alignment, True, True, 4);

      Realize (Shared_Res_Canvas);

      Gdk_New (Green_Gc, Get_Window (Shared_Res_Canvas));

      Editor_Actions.Load_System_Font (Font, Font1);

      Show_All (Frame);
   end Run;
end Mast_Editor.Shared_Resources;
