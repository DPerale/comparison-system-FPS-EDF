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
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Tags;                          use Ada.Tags;
with Ada.Text_IO;                       use Ada.Text_IO;
with GNAT.OS_Lib;                       use GNAT.OS_Lib;

with Glib;           use Glib;
with Gdk.Rectangle;  use Gdk.Rectangle;
with Gtk.Adjustment; use Gtk.Adjustment;
with Gtk.Frame;      use Gtk.Frame;
with Gtk.Handlers;   use Gtk.Handlers;
with Gtk.Label;      use Gtk.Label;
with Gtk.Menu_Item;  use Gtk.Menu_Item;
with Gtk.Widget;     use Gtk.Widget;
with Gtkada.Canvas;  use Gtkada.Canvas;
with Pango.Font;     use Pango.Font;
with Pango.Layout;   use Pango.Layout;
with Pango.Context;  use Pango.Context;

with List_Exceptions;                     use List_Exceptions;
with Mast.IO;                             use Mast.IO;
with Mast.Processing_Resources;           use Mast.Processing_Resources;
with Mast.Processing_Resources.Processor;
use Mast.Processing_Resources.Processor;
with Mast.Processing_Resources.Network;   use
                                            Mast.Processing_Resources.Network;
with Mast.Shared_Resources;               use Mast.Shared_Resources;
with Mast.Operations;                     use Mast.Operations;
with Mast.Transactions;                   use Mast.Transactions;
with Mast.Schedulers;                     use Mast.Schedulers;
with Mast.Schedulers.Primary;             use Mast.Schedulers.Primary;
with Mast.Schedulers.Secondary;           use Mast.Schedulers.Secondary;
with Mast.Scheduling_Servers;             use Mast.Scheduling_Servers;
with Mast.Drivers;                        use Mast.Drivers;
with Mast.Timers;                         use Mast.Timers;
with Mast.Graphs;                         use Mast.Graphs;
with Mast.Graphs.Event_Handlers;          use Mast.Graphs.Event_Handlers;
with MAST_Parser;

with Mast_Editor;                      use Mast_Editor;
with Mast_Editor.Processing_Resources; use Mast_Editor.Processing_Resources;
with Mast_Editor.Schedulers;           use Mast_Editor.Schedulers;
with Mast_Editor.Scheduling_Servers;   use Mast_Editor.Scheduling_Servers;
with Mast_Editor.Shared_Resources;     use Mast_Editor.Shared_Resources;
with Mast_Editor.Operations;           use Mast_Editor.Operations;
with Mast_Editor.Transactions;         use Mast_Editor.Transactions;
with Mast_Editor.Timers;               use Mast_Editor.Timers;
with Mast_Editor.Drivers;              use Mast_Editor.Drivers;
with Mast_Editor_Window_Pkg;           use Mast_Editor_Window_Pkg;
with Mast_Editor.Event_Handlers;       use Mast_Editor.Event_Handlers;
with Mast_Editor.Links;                use Mast_Editor.Links;
with Trans_Dialog_Pkg;                 use Trans_Dialog_Pkg;
with Save_Changes_Dialog_Pkg;          use Save_Changes_Dialog_Pkg;
with Change_Control;

package body Editor_Actions is

   Verbose : constant Boolean :=False;

   type String_Ptr is access String;

   System_Name, Editor_System_Name : String_Ptr;
   System_Present                  : Boolean          := False;
   Editor_System_Present           : Boolean          := False;
   Temp_Arguments                  : Me_Arguments_Ref := new Me_Arguments;

   package Button_Cb is new Gtk.Handlers.User_Callback
     (Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Transaction_Ref);

   --------------
   -- New_File --
   --------------
   procedure New_File is
      Save_Changes_Dialog : Save_Changes_Dialog_Access;
   begin
      if Change_Control.Saved_Changes then
         Current_Filename := null;
         Set_Window_Title;
         Clear_All_Canvas;
         Reset_Editor_System (Editor_System);
         Reset_Mast_System (The_System);
         System_Present := False;
         Set_Sensitive (Mast_Editor_Window.Analysis, False);
         Editor_System_Present := False;
      else
         System_Present := False;
         Set_Sensitive (Mast_Editor_Window.Analysis, False);
         Editor_System_Present := False;
         Gtk_New (Save_Changes_Dialog);
         Show_All (Save_Changes_Dialog);
         Save_Changes_Dialog.New_File := True;
      end if;
   end New_File;

   ----------------------
   -- Set_Window_Title --
   ----------------------
   procedure Set_Window_Title is
   begin
      if Current_Filename = null then
         Set_Title (Mast_Editor_Window, "gMAST : (untitled) ");
      else
         Set_Title (Mast_Editor_Window, "gMAST : " & Current_Filename.all);
      end if;
   end Set_Window_Title;

   ----------------------
   -- Load System Font --
   ----------------------
   procedure Load_System_Font
     (Font_Normal : in out Pango_Font_Description;
      Font_Bold   : in out Pango_Font_Description)
   is
      Frame            : Gtk_Frame;
      Layout           : Pango_Layout;
      Context          : Pango.Context.Pango_Context;
      System_Font      : Pango.Font.Pango_Font_Description;
      System_Font_Name : Var_String;
   begin
      Gtk_New (Frame);
      Layout := Create_Pango_Layout (Frame);
      -- we need to load the font used by OS to display items'
      --parameters inside the canvas properly
      Context          := Get_Context (Layout);
      System_Font      := Get_Font_Description (Context);
      System_Font_Name := To_Var_String (To_String (System_Font));
      if Element (System_Font_Name, Length (System_Font_Name) - 1) =
        ' '
      then
         Font_Normal :=
           From_String
           ((To_String (System_Font_Name)
             (1 .. Length (System_Font_Name) - 2)) &
            " 8");
         Font_Bold   :=
           From_String
           ((To_String (System_Font_Name)
             (1 .. Length (System_Font_Name) - 2)) &
            " Bold" &
            " 8");--Windows
      else
         Font_Normal :=
           From_String
           ((To_String (System_Font_Name)
             (1 .. Length (System_Font_Name) - 3)) &
            " 10");
         Font_Bold   :=
           From_String
           ((To_String (System_Font_Name)
             (1 .. Length (System_Font_Name) - 3)) &
            " Bold" &
            " 10");--Linux
      end if;
   end Load_System_Font;

   ----------------------
   -- Id_Name_Is_Valid --
   ----------------------
   function Id_Name_Is_Valid (Id : String) return Boolean is
   begin
      if Id /= "" then
         if Id (Id'First) not  in 'a' .. 'z' then
            return False;
         else
            for J in Id'First + 1 .. Id'Last loop
               if (Id (J) not  in '0' .. '9') and
                 (Id (J) not  in 'a' .. 'z') and
                 (Id (J) /= '.') and
                 (Id (J) /= '_')
               then
                  return False;
               end if;
            end loop;
            return True;
         end if;
      else
         return False;
      end if;
   end Id_Name_Is_Valid;

   ------------------
   -- Clear_Canvas --
   ------------------
   procedure Clear_Canvas (Canvas : access Interactive_Canvas_Record'Class) is
      function Remove_Internal
        (Canvas : access Interactive_Canvas_Record'Class;
         Item   : access Canvas_Item_Record'Class)
        return   Boolean
      is
      begin
         Remove (Canvas, Item);
         return True;
      end Remove_Internal;

   begin
      For_Each_Item (Canvas, Remove_Internal'Unrestricted_Access);
      Refresh_Canvas (Canvas);
   end Clear_Canvas;

   ----------------------
   -- Clear_All_Canvas --
   ----------------------
   procedure Clear_All_Canvas is
   begin
      Clear_Canvas (Proc_Res_Canvas);
      Clear_Canvas (Sched_Server_Canvas);
      Clear_Canvas (Shared_Res_Canvas);
      Clear_Canvas (Operation_Canvas);
      Clear_Canvas (Transaction_Canvas);
   end Clear_All_Canvas;

   ---------------------
   -- Add_Canvas_Link --
   ---------------------
   procedure Add_Canvas_Link
     (Canvas : access Interactive_Canvas_Record'Class;
      Item1  : access Canvas_Item_Record'Class;
      Item2  : access Canvas_Item_Record'Class)
   is
      Link : Canvas_Link := new Canvas_Link_Record;
   begin
      Add_Link (Canvas, Link, Item1, Item2);
   end Add_Canvas_Link;

   ------------------
   -- Remove_Links --
   ------------------
   procedure Remove_Links
     (Canvas   : access Interactive_Canvas_Record'Class;
      Item1    : access Canvas_Item_Record'Class;
      Item2    : access Canvas_Item_Record'Class;
      Outgoing : Boolean := True)
   is
      function Remove_Internal
        (Canvas : access Interactive_Canvas_Record'Class;
         Link   : access Canvas_Link_Record'Class)
        return   Boolean
      is
         pragma Warnings (Off, Canvas);
      begin
         if Outgoing then
            if (Canvas_Item (Get_Src (Link))) = (Canvas_Item (Item1))
              and then (Canvas_Item (Get_Dest (Link))) =
              (Canvas_Item (Item2))
            then
               Remove_Link (Canvas, Link);
            end if;
            return True;
         else
            if (Canvas_Item (Get_Dest (Link))) = (Canvas_Item (Item1))
              and then (Canvas_Item (Get_Src (Link))) =
              (Canvas_Item (Item2))
            then
               Remove_Link (Canvas, Link);
            end if;
            return True;
         end if;
      end Remove_Internal;
   begin
      For_Each_Link (Canvas, Remove_Internal'Unrestricted_Access);
   end Remove_Links;

   ----------------------
   -- Remove_Old_Links --
   ----------------------
   procedure Remove_Old_Links
     (Canvas   : access Interactive_Canvas_Record'Class;
      Item     : access Canvas_Item_Record'Class;
      Outgoing : Boolean := True)
   is
      function Remove_Internal
        (Canvas : access Interactive_Canvas_Record'Class;
         Link   : access Canvas_Link_Record'Class)
        return   Boolean
      is
         pragma Warnings (Off, Canvas);
      begin
         if Outgoing then
            if (Canvas_Item (Get_Src (Link))) =
              (Canvas_Item (Item))
            then
               Remove_Link (Canvas, Link);
            end if;
            return True;
         else
            if (Canvas_Item (Get_Dest (Link))) =
              (Canvas_Item (Item))
            then
               Remove_Link (Canvas, Link);
            end if;
            return True;
         end if;
      end Remove_Internal;
   begin
      For_Each_Link (Canvas, Remove_Internal'Unrestricted_Access);
   end Remove_Old_Links;

   -------------------------
   -- Reset_Editor_System --
   -------------------------
   procedure Reset_Editor_System
     (The_Editor_System : in out Mast_Editor.Systems.ME_System)
   is
      New_System : Mast_Editor.Systems.ME_System;
   begin
      The_Editor_System := New_System;
   end Reset_Editor_System;

   -------------------------
   -- Reset_Mast_System --
   -------------------------
   procedure Reset_Mast_System
     (The_Mast_System : in out Mast.Systems.System)
   is
      New_System : Mast.Systems.System;
   begin
      The_System := New_System;
   end Reset_Mast_System;

   -------------------------
   -- Get_Number_Of_Items --
   -------------------------

   function Get_Number_Of_Items
     (Canvas : access Interactive_Canvas_Record'Class)
     return   Guint
   is
      Items_Number : Guint := 0;
      pragma Warnings (Off);
      function Internal
        (Canvas : access Interactive_Canvas_Record'Class;
         Item   : access Canvas_Item_Record'Class)
        return   Boolean
      is
      begin
         Items_Number := Items_Number + 1;
         return True;
      end Internal;
   begin
      For_Each_Item (Canvas, Internal'Unrestricted_Access);
      return Items_Number;
   end Get_Number_Of_Items;

   ------------------------
   -- Show_Left_Top_Item --
   ------------------------

   procedure Show_Left_Top_Item
     (Canvas : access Interactive_Canvas_Record'Class)
   is
      Iter          : Item_Iterator;
      First_Item    : Canvas_Item;
      Min_X         : Gint;
      Min_Y         : Gint;
      Left_Top_Item : Canvas_Item;

      function Get_Left_Top_Item
        (Canvas : access Interactive_Canvas_Record'Class;
         Item   : access Canvas_Item_Record'Class)
        return   Boolean
      is
         Item_Rect : Gdk.Rectangle.Gdk_Rectangle;
      begin
         Item_Rect := Get_Coord (Item);

         if Item_Rect.X <= Min_X then
            if Item_Rect.Y < Min_Y then
               Min_X         := Item_Rect.X;
               Min_Y         := Item_Rect.Y;
               Left_Top_Item := Canvas_Item (Item);
            end if;
         end if;
         return True;
      end Get_Left_Top_Item;

   begin
      if Get_Number_Of_Items (Canvas) > Guint (0) then

         Iter       := Start (Canvas);
         First_Item := Get (Iter);

         Min_X := (Get_Coord (First_Item).X);
         Min_Y := (Get_Coord (First_Item).Y);

         For_Each_Item (Canvas, Get_Left_Top_Item'Unrestricted_Access);

         if Left_Top_Item /= null then
            Show_Item (Canvas, Left_Top_Item);
         end if;

      end if;
   end Show_Left_Top_Item;

   -----------------------------
   -- Show_All_Left_Top_Items --
   -----------------------------
   procedure Show_All_Left_Top_Items is
   begin
      Show_Left_Top_Item (Proc_Res_Canvas);
      Show_Left_Top_Item (Sched_Server_Canvas);
      Show_Left_Top_Item (Shared_Res_Canvas);
      Show_Left_Top_Item (Operation_Canvas);
      Show_Left_Top_Item (Transaction_Canvas);
   end Show_All_Left_Top_Items;

   -----------------------
   -- Show_Central_Item --
   -----------------------

   procedure Show_Central_Item
     (Canvas : access Interactive_Canvas_Record'Class)
   is
      Iter         : Item_Iterator;
      First_Item   : Canvas_Item;
      Min_X        : Gint;
      Min_Y        : Gint;
      Max_X        : Gint;
      Max_Y        : Gint;
      Min_Distance : Float;
      Center_X     : Gint;
      Center_Y     : Gint;
      Central_Item : Canvas_Item;

      function Canvas_Dimensions
        (Canvas : access Interactive_Canvas_Record'Class;
         Item   : access Canvas_Item_Record'Class)
        return   Boolean
      is
         Item_Rect : Gdk.Rectangle.Gdk_Rectangle;
      begin
         Item_Rect := Get_Coord (Item);
         if Min_X > Item_Rect.X then
            Min_X := Item_Rect.X;
         end if;
         if Min_Y > Item_Rect.Y then
            Min_Y := Item_Rect.Y;
         end if;
         if Max_X < Item_Rect.X + Item_Rect.Width then
            Max_X := Item_Rect.X + Item_Rect.Width;
         end if;
         if Max_Y < Item_Rect.Y + Item_Rect.Height then
            Max_Y := Item_Rect.Y + Item_Rect.Height;
         end if;
         return True;
      end Canvas_Dimensions;

      function Minimum_Distance
        (Canvas : access Interactive_Canvas_Record'Class;
         Item   : access Canvas_Item_Record'Class)
        return   Boolean
      is
         Dist      : Float;
         Item_Rect : Gdk.Rectangle.Gdk_Rectangle;
      begin
         Item_Rect := Get_Coord (Item);
         Dist      :=
           Sqrt
           (Float (((Item_Rect.X - Center_X) ** 2) +
                   ((Item_Rect.Y - Center_Y) ** 2)));
         if Dist < Min_Distance then
            Min_Distance := Dist;
            Central_Item := Canvas_Item (Item);
         end if;
         return True;
      end Minimum_Distance;

   begin
      if Get_Number_Of_Items (Canvas) > Guint (0) then

         Iter       := Start (Canvas);
         First_Item := Get (Iter);

         Min_X := (Get_Coord (First_Item).X);
         Min_Y := (Get_Coord (First_Item).Y);
         Max_X := Min_X + (Get_Coord (First_Item).Width);
         Max_Y := Min_Y + (Get_Coord (First_Item).Height);

         For_Each_Item (Canvas, Canvas_Dimensions'Unrestricted_Access);

         Center_X := Min_X + (Max_X - Min_X) / 2;
         Center_Y := Min_Y + (Max_Y - Min_Y) / 2;

         Min_Distance := 0.5 *
           Sqrt
           (Float ((Max_X - Min_X) ** 2 +
                   (Max_Y - Min_Y) ** 2));

         For_Each_Item (Canvas, Minimum_Distance'Unrestricted_Access);

         if Central_Item /= null then
            Show_Item (Canvas, Central_Item);
         end if;

      end if;
   end Show_Central_Item;

   ----------------------------
   -- Show_All_Central_Items --
   ----------------------------
   procedure Show_All_Central_Items is
   begin
      Show_Central_Item (Proc_Res_Canvas);
      Show_Central_Item (Sched_Server_Canvas);
      Show_Central_Item (Shared_Res_Canvas);
      Show_Central_Item (Operation_Canvas);
      Show_Central_Item (Transaction_Canvas);
   end Show_All_Central_Items;

   ---------------------------
   -- Number_Of_Input_Links --
   ---------------------------
   function Number_Of_Input_Links
     (Canvas : access Interactive_Canvas_Record'Class;
      Item   : access Canvas_Item_Record'Class)
     return   Guint
   is
      Input_Links_Number : Guint := 0;

      function Number_Of_Input_Links_Internal
        (Canvas : access Interactive_Canvas_Record'Class;
         Link   : access Canvas_Link_Record'Class)
        return   Boolean
      is
         pragma Warnings (Off, Canvas);
      begin
         if (Canvas_Item (Get_Dest (Link))) = (Canvas_Item (Item)) then
            Input_Links_Number := Input_Links_Number + 1;
         end if;
         return True;
      end Number_Of_Input_Links_Internal;

   begin
      For_Each_Link
        (Canvas,
         Number_Of_Input_Links_Internal'Unrestricted_Access);
      return Input_Links_Number;
   end Number_Of_Input_Links;

   ---------------------------
   -- Number_Of_Output_Links --
   ---------------------------
   function Number_Of_Output_Links
     (Canvas : access Interactive_Canvas_Record'Class;
      Item   : access Canvas_Item_Record'Class)
     return   Guint
   is
      Output_Links_Number : Guint := 0;

      function Number_Of_Output_Links_Internal
        (Canvas : access Interactive_Canvas_Record'Class;
         Link   : access Canvas_Link_Record'Class)
        return   Boolean
      is
         pragma Warnings (Off, Canvas);
      begin
         if (Canvas_Item (Get_Src (Link))) = (Canvas_Item (Item)) then
            Output_Links_Number := Output_Links_Number + 1;
         end if;
         return True;
      end Number_Of_Output_Links_Internal;

   begin
      For_Each_Link
        (Canvas,
         Number_Of_Output_Links_Internal'Unrestricted_Access);
      return Output_Links_Number;
   end Number_Of_Output_Links;

   ---------------------------------
   -- Search_Next_Zero_Input_Item --
   ---------------------------------
   function Search_Next_Zero_Input_Item
     (Canvas : access Interactive_Canvas_Record'Class)
     return   Canvas_Item
   is
      Next_Item : Canvas_Item := null;

      function Search_Next_Zero_Input_Item_Internal
        (Canvas : access Interactive_Canvas_Record'Class;
         Item   : access Canvas_Item_Record'Class)
        return   Boolean
      is
         pragma Warnings (Off, Canvas);
      begin
         if (Number_Of_Input_Links (Canvas, Item) = 0)
           and then (Is_Visible (Item))
         then
            Next_Item := Canvas_Item (Item);
            return False;
         else
            return True;
         end if;
      end Search_Next_Zero_Input_Item_Internal;

   begin
      For_Each_Item
        (Canvas,
         Search_Next_Zero_Input_Item_Internal'Unrestricted_Access);
      return Next_Item;
   end Search_Next_Zero_Input_Item;

   ---------------------------------
   -- Move_Item_To_Index_Position --
   ---------------------------------
   procedure Move_Item_To_Index_Position
     (Canvas       : access Interactive_Canvas_Record'Class;
      Item         : access Canvas_Item_Record'Class;
      Column_Index : in Integer;
      Row_Index    : in Integer)
   is
      Space          : constant := 40;
      Element_Width  : constant := 150;
      Element_Height : constant := 75;
      H_Border       : constant := 45;
      V_Border       : constant := 15;
      Rect           : Gdk.Rectangle.Gdk_Rectangle;
   begin
      if  Me_Object_Ref(Item).X_Coord=0 and then Me_Object_Ref(Item).Y_Coord=0
      then
         Rect := Get_Coord (Item);
         if Rect.Width < Element_Width and Rect.Height < Element_Height then
            Move_To
              (Canvas,
               Item,
               Gint (Space +
                     (Column_Index - 1) * (Space + Element_Width) +
                     H_Border),
               Gint (Space +
                     (Row_Index - 1) * (Space + Element_Height) +
                     V_Border));
            ME_Object_Ref (Item).X_Coord := Gint (Get_Coord (Item).X);
            ME_Object_Ref (Item).Y_Coord := Gint (Get_Coord (Item).Y);
         else
            Move_To
              (Canvas,
               Item,
               Gint (Space + (Column_Index - 1) * (Space + Element_Width)),
               Gint (Space + (Row_Index - 1) * (Space + Element_Height)));
            ME_Object_Ref (Item).X_Coord := Gint (Get_Coord (Item).X);
            ME_Object_Ref (Item).Y_Coord := Gint (Get_Coord (Item).Y);
         end if;
      end if;
   end Move_Item_To_Index_Position;

   ----------------------
   -- Draw_Input_Items --
   ----------------------
   procedure Draw_Input_Items
     (Canvas          : access Interactive_Canvas_Record'Class;
      Item            : access Canvas_Item_Record'Class;
      Row_Index       : in Integer;
      Column_Index    : in Integer;
      Position_Matrix : in out Matrix;
      Max_Row_Index   : in out Integer)
   is
      Current_Row    : Integer;
      Current_Column : Integer;

      function Draw_Input_Items_Internal
        (Canvas    : access Interactive_Canvas_Record'Class;
         Temp_Item : access Canvas_Item_Record'Class)
        return      Boolean
      is
         pragma Warnings (Off, Canvas);
      begin
         if Has_Link (Canvas, Temp_Item, Item)
           and then (Is_Visible (Temp_Item))
         then
            Current_Row    := Row_Index;
            Current_Column := Column_Index - 1;

            while Position_Matrix (Current_Row, Current_Column) /= False loop
               Current_Row := Current_Row + 1;
            end loop;

            Move_Item_To_Index_Position
              (Canvas,
               Temp_Item,
               Current_Column,
               Current_Row); -- Draw element
            Set_Visibility (Temp_Item, False); -- Change flag
            Position_Matrix (Current_Row, Current_Column) := True;
            -- Position ocuppied

            -- Modify maximum number of rows drawn in current graph
            if Max_Row_Index < Current_Row then
               Max_Row_Index := Current_Row;
            end if;

            -- If Item has input links, put the items that still have not been
            -- moved to the right position
            if Number_Of_Input_Links (Canvas, Temp_Item) > 0 then
               Draw_Input_Items
                 (Canvas,
                  Temp_Item,
                  Current_Row,
                  Current_Column,
                  Position_Matrix,
                  Max_Row_Index);
            end if;
         end if;
         return True;
      end Draw_Input_Items_Internal;

   begin
      For_Each_Item (Canvas, Draw_Input_Items_Internal'Unrestricted_Access);
   end Draw_Input_Items;

   -----------------------
   -- Draw_Output_Items --
   -----------------------
   procedure Draw_Output_Items
     (Canvas          : access Interactive_Canvas_Record'Class;
      Item            : access Canvas_Item_Record'Class;
      Row_Index       : in Integer;
      Column_Index    : in Integer;
      Position_Matrix : in out Matrix;
      Max_Row_Index   : in out Integer)
   is
      Current_Row    : Integer;
      Current_Column : Integer;

      function Draw_Output_Items_Internal
        (Canvas    : access Interactive_Canvas_Record'Class;
         Temp_Item : access Canvas_Item_Record'Class)
        return      Boolean
      is
         pragma Warnings (Off, Canvas);
      begin
         if Has_Link (Canvas, Item, Temp_Item)
           and then (Is_Visible (Temp_Item))
         then
            Current_Row    := Row_Index;
            Current_Column := Column_Index + 1;

            while Position_Matrix (Current_Row, Current_Column) /= False loop
               Current_Row := Current_Row + 1;
            end loop;

            Move_Item_To_Index_Position
              (Canvas,
               Temp_Item,
               Current_Column,
               Current_Row); -- Draw element
            Set_Visibility (Temp_Item, False); -- Change flag
            Position_Matrix (Current_Row, Current_Column) := True;
            -- Position ocuppied

            -- Modify maximum number of rows drawn in current graph
            if Max_Row_Index < Current_Row then
               Max_Row_Index := Current_Row;
            end if;

            -- If Item has output links, put the items that still have not been
            -- moved to the right position
            if Number_Of_Input_Links (Canvas, Temp_Item) > 0 then
               Draw_Input_Items
                 (Canvas,
                  Temp_Item,
                  Current_Row,
                  Current_Column,
                  Position_Matrix,
                  Max_Row_Index);
            end if;

            -- If Item has input links, put the items that still have not been
            -- moved to the right position
            if Number_Of_Output_Links (Canvas, Temp_Item) > 0 then
               Draw_Output_Items
                 (Canvas,
                  Temp_Item,
                  Current_Row,
                  Current_Column,
                  Position_Matrix,
                  Max_Row_Index);
            end if;
         end if;
         return True;
      end Draw_Output_Items_Internal;

   begin
      For_Each_Item (Canvas, Draw_Output_Items_Internal'Unrestricted_Access);
   end Draw_Output_Items;

   ---------------------
   -- Show_TXT_Graphs --
   ---------------------
   procedure Show_TXT_Graphs
     (Canvas : access Interactive_Canvas_Record'Class)
   is
      Number_Of_Items       : Integer :=
        Integer (Get_Number_Of_Items (Canvas));
      Position_Matrix       : Matrix
        (1 .. Number_Of_Items,
         1 .. Number_Of_Items) := (others => (others => False));
      Max_Row_Index         : Integer := 0;
      Row_Index             : Integer := 1;
      Column_Index          : Integer := 1;
      Next_Zero_Input_Item  : Canvas_Item := null;
      First_Zero_Input_Item : Canvas_Item := null;

      function Show_Internal
        (Canvas : access Interactive_Canvas_Record'Class;
         Item   : access Canvas_Item_Record'Class)
        return   Boolean
      is
      begin
         Set_Visibility (Item, True);
         return True;
      end Show_Internal;

   begin
      First_Zero_Input_Item := Search_Next_Zero_Input_Item (Canvas);

      Next_Zero_Input_Item := Search_Next_Zero_Input_Item (Canvas);

      while Next_Zero_Input_Item /= null loop
         Row_Index := Max_Row_Index + 1;
         Move_Item_To_Index_Position
           (Canvas,
            Next_Zero_Input_Item,
            Column_Index,
            Row_Index); -- Draw element
         Set_Visibility (Next_Zero_Input_Item, False); -- Change flag
         Position_Matrix (Row_Index, Column_Index) := True;
         -- Position ocuppied.

         --If Item has output links, put the items that still have
         --  not been moved to the right position

         if Number_Of_Output_Links (Canvas, Next_Zero_Input_Item) > 0 then
            Draw_Output_Items
              (Canvas,
               Next_Zero_Input_Item,
               Row_Index,
               Column_Index,
               Position_Matrix,
               Max_Row_Index);
         end if;
         Next_Zero_Input_Item := Search_Next_Zero_Input_Item (Canvas);
      end loop;

      For_Each_Item (Canvas, Show_Internal'Unrestricted_Access);

      if First_Zero_Input_Item /= null
        and then
        Me_Object_Ref(First_Zero_Input_Item).X_Coord=0 and then
        Me_Object_Ref(First_Zero_Input_Item).Y_Coord=0
      then
         Move_To (Canvas, First_Zero_Input_Item, Gint (75), Gint (0));
         Show_Item (Canvas, First_Zero_Input_Item);
         Move_Item_To_Index_Position (Canvas, First_Zero_Input_Item, 1, 1);
      end if;

   end Show_TXT_Graphs;

   --------------------
   -- Show_TXT_Items --
   --------------------

   procedure Show_TXT_Items
     (Canvas : access Interactive_Canvas_Record'Class)
   is
      Borders_Space       : constant Guint := Guint (40);
      Space_Between_Items : constant Guint := Guint (10);
      Element_Width       : constant := 150;
      Element_Height      : constant := 75;
      Max_Canvas_Size     : constant := 800; -- Max size of the canvas
      Number_Of_Columns   : Guint;
      Number_Of_Rows      : Guint;
      Cur_Item            : Guint          := 0;
      Left_Top_Item       : Canvas_Item    := null;

      function Internal
        (Canvas : access Interactive_Canvas_Record'Class;
         Item   : access Canvas_Item_Record'Class)
        return   Boolean
      is
         X, Y : Guint;
      begin
         X := Borders_Space +
           (Guint (Element_Width) + Space_Between_Items) *
           (Cur_Item mod Number_Of_Columns);

         Y := Borders_Space +
           (Guint (Element_Height) + Space_Between_Items) *
           (Cur_Item / Number_Of_Columns);

         Move_To (Canvas, Item, Gint (X), Gint (Y));
         ME_Object_Ref (Item).X_Coord := Gint (Get_Coord (Item).X);
         ME_Object_Ref (Item).Y_Coord := Gint (Get_Coord (Item).Y);
         Cur_Item                     := Cur_Item + 1;

         if X = Borders_Space and Y = Borders_Space then
            Left_Top_Item := Canvas_Item (Item);
         end if;

         return True;
      end Internal;

   begin
      Number_Of_Columns := 1 +
        (Max_Canvas_Size -
         2 * Borders_Space -
         Guint (Element_Width)) /
        (Guint (Element_Width) + Space_Between_Items);

      Number_Of_Rows := Get_Number_Of_Items (Canvas) / Number_Of_Columns;

      For_Each_Item (Canvas, Internal'Unrestricted_Access);

      if Left_Top_Item /= null then
         Move_To (Canvas, Left_Top_Item, Gint (0), Gint (0));
         Show_Item (Canvas, Left_Top_Item);
         Move_To
           (Canvas,
            Left_Top_Item,
            Gint (Borders_Space),
            Gint (Borders_Space));
         ME_Object_Ref (Left_Top_Item).X_Coord :=
           Gint (Get_Coord (Left_Top_Item).X);
         ME_Object_Ref (Left_Top_Item).Y_Coord :=
           Gint (Get_Coord (Left_Top_Item).Y);
      end if;

   end Show_TXT_Items;

   ------------------
   -- Put_TXT_Item --
   ------------------

   procedure Put_TXT_Item
     (Canvas : access Interactive_Canvas_Record'Class;
      Item   : ME_Object_Ref)
   is
   begin
      Set_Screen_Size (Item, Item.W, Item.H);
      Put (Canvas, Item);
      Item.X_Coord := Gint (Get_Coord (Item).X);
      Item.Y_Coord := Gint (Get_Coord (Item).Y);
   end Put_TXT_Item;

   ------------------------
   -- Put_Item_In_Canvas --
   ------------------------

   procedure Put_Item_In_Canvas (Item : ME_Object_Ref) is
      Canvas       : Interactive_Canvas;
      Me_Tran_Iter : Mast_Editor.Transactions.Lists.Iteration_Object;
      Me_Tran_Ref  : Mast_Editor.Transactions.ME_Transaction_Ref;
   begin
      if Item.Canvas_Name = To_Var_String ("Proc_Res_Canvas") then
         Canvas := Proc_Res_Canvas;
      elsif Item.Canvas_Name = To_Var_String ("Shared_Res_Canvas") then
         Canvas := Shared_Res_Canvas;
      elsif Item.Canvas_Name = To_Var_String ("Operation_Canvas") then
         Canvas := Operation_Canvas;
      elsif Item.Canvas_Name = To_Var_String ("Sched_Server_Canvas") then
         Canvas := Sched_Server_Canvas;
      elsif Item.Canvas_Name = To_Var_String ("Transaction_Canvas") then
         Canvas := Transaction_Canvas;
      else
         begin
            -- We check if Item.Canvas_Name is the Name of any
            --of Me_Transactions
            Me_Tran_Iter :=
              Mast_Editor.Transactions.Lists.Find
              (Item.Canvas_Name,
               Editor_System.Me_Transactions);
            Me_Tran_Ref  :=
              Mast_Editor.Transactions.Lists.Item
              (Me_Tran_Iter,
               Editor_System.Me_Transactions);
         exception
            when Invalid_Index => -- ME_Transaction Not Found
               if Verbose then
                  Put_Line("Error while reading editor info."&
                           " Transaction not found: "&Item.Canvas_Name);
               end if;
         end;
         if Me_Tran_Ref /= null and then Me_Tran_Ref.Dialog /= null then
            Canvas := Me_Tran_Ref.Dialog.Trans_Canvas;
         end if;
      end if;
      if Canvas /= null then
         Set_Screen_Size (Item, Item.W, Item.H);
         Put
           (Canvas,
            Item,
            To_Canvas_Coordinates (Canvas, Item.X_Coord),
            To_Canvas_Coordinates (Canvas, Item.Y_Coord));
         Refresh_Canvas (Canvas);
      end if;
   end Put_Item_In_Canvas;

   ----------------
   -- Has_System --
   ----------------

   function Has_System return Boolean is
   begin
      return System_Present;
   end Has_System;

   -----------------------
   -- Has_Editor_System --
   -----------------------

   function Has_Editor_System return Boolean is
   begin
      return Editor_System_Present;
   end Has_Editor_System;

   --------------------
   -- Name_Of_System --
   --------------------

   function Name_Of_System return String is
   begin
      if System_Present then
         return System_Name.all;
      elsif Editor_System_Present then
         return Editor_System_Name.all;
      else
         raise No_System;
      end if;
   end Name_Of_System;

   -------------------
   -- Import_System --
   -------------------

   procedure Import_System
     (Filename        : String;
      System_Imported : in out Mast.Systems.System)
   is
      F : Ada.Text_IO.File_Type;
   begin
      Ada.Text_IO.Open (F, Ada.Text_IO.In_File, Filename);
      begin
         Ada.Text_IO.Set_Input (F);
         MAST_Parser (System_Imported);
         Close (F);
         Ada.Text_IO.Set_Input (Standard_Input);
         if System_Present /= True then
            System_Name := new String'(Filename);
            Free (Current_Filename);
            Current_Filename := new String'(Filename);
            Set_Window_Title;
            System_Present := True;
            Set_Sensitive (Mast_Editor_Window.Analysis, True);
         end if;
      exception
         when others =>
            Close (F);
            Ada.Text_IO.Set_Input (Standard_Input);
            raise;
      end;
   end Import_System;

   -------------------------
   -- Adjust_System_Lists --
   -------------------------

   procedure Adjust_System_Lists (System_Imported : Mast.Systems.System) is
      Proc_Iter  : Mast.Processing_Resources.Lists.Iteration_Object;
      Share_Iter : Mast.Shared_Resources.Lists.Iteration_Object;
      Sche_Iter  : Mast.Schedulers.Lists.Iteration_Object;
      Op_Iter    : Mast.Operations.Lists.Iteration_Object;
      Ser_Iter   : Mast.Scheduling_Servers.Lists.Iteration_Object;
      Tran_Iter  : Mast.Transactions.Lists.Iteration_Object;
      Proc_Ref   : Mast.Processing_Resources.Processing_Resource_Ref;
      Share_Ref  : Mast.Shared_Resources.Shared_Resource_Ref;
      Sche_Ref   : Mast.Schedulers.Scheduler_Ref;
      Op_Ref     : Mast.Operations.Operation_Ref;
      Ser_Ref    : Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Tran_Ref   : Mast.Transactions.Transaction_Ref;
      Duplicate_Elements : Boolean :=False;

   begin
      ------------------------
      -- Processing Resources
      ------------------------

      Mast.Processing_Resources.Lists.Rewind
        (System_Imported.Processing_Resources,
         Proc_Iter);
      for I in
        1 ..
        Mast.Processing_Resources.Lists.Size
        (System_Imported.Processing_Resources)
      loop
         Mast.Processing_Resources.Lists.Get_Next_Item
           (Proc_Ref,
            System_Imported.Processing_Resources,
            Proc_Iter);
         begin
            Mast.Processing_Resources.Lists.Add
              (Proc_Ref,
               The_System.Processing_Resources);
         exception
            when Already_Exists =>
               Duplicate_Elements:=True;
               if Verbose then
                  Put_Line("Error while adjusting lists. "&
                           "Duplicate processing resource: "&
                           Mast.Processing_Resources.Name(Proc_Ref));
               end if;
         end;
      end loop;

      ------------------------
      -- Schedulers
      ------------------------
      Mast.Schedulers.Lists.Rewind (System_Imported.Schedulers, Sche_Iter);
      for I in 1 .. Mast.Schedulers.Lists.Size (System_Imported.Schedulers)
      loop
         Mast.Schedulers.Lists.Get_Next_Item
           (Sche_Ref,
            System_Imported.Schedulers,
            Sche_Iter);
         begin
            Mast.Schedulers.Lists.Add (Sche_Ref, The_System.Schedulers);
         exception
            when Already_Exists =>
               Duplicate_Elements:=True;
               if Verbose then
                  Put_Line("Error while adjusting lists. "&
                           "Duplicate scheduler: "&
                           Mast.Schedulers.Name(Sche_Ref));
               end if;
         end;
      end loop;

      ------------------------
      -- Scheduling Servers
      ------------------------

      Mast.Scheduling_Servers.Lists.Rewind
        (System_Imported.Scheduling_Servers,
         Ser_Iter);
      for I in
        1 ..
        Mast.Scheduling_Servers.Lists.Size
        (System_Imported.Scheduling_Servers)
      loop
         Mast.Scheduling_Servers.Lists.Get_Next_Item
           (Ser_Ref,
            System_Imported.Scheduling_Servers,
            Ser_Iter);
         begin
            Mast.Scheduling_Servers.Lists.Add
              (Ser_Ref,
               The_System.Scheduling_Servers);
         exception
            when Already_Exists =>
               Duplicate_Elements:=True;
               if Verbose then
                  Put_Line("Error while adjusting lists. "&
                           "Duplicate scheduling server: "&
                           Mast.Scheduling_Servers.Name(Ser_Ref));
               end if;
         end;
      end loop;

      ------------------------
      -- Shared Resources
      ------------------------

      Mast.Shared_Resources.Lists.Rewind
        (System_Imported.Shared_Resources,
         Share_Iter);
      for I in
        1 ..
        Mast.Shared_Resources.Lists.Size
        (System_Imported.Shared_Resources)
      loop
         Mast.Shared_Resources.Lists.Get_Next_Item
           (Share_Ref,
            System_Imported.Shared_Resources,
            Share_Iter);
         begin
            Mast.Shared_Resources.Lists.Add
              (Share_Ref,
               The_System.Shared_Resources);
         exception
            when Already_Exists =>
               Duplicate_Elements:=True;
               if Verbose then
                  Put_Line("Error while adjusting lists. "&
                           "Duplicate shared resource: "&
                           Mast.Shared_Resources.Name(Share_Ref));
               end if;
         end;
      end loop;

      ------------------------
      -- Operations
      ------------------------
      Mast.Operations.Lists.Rewind (System_Imported.Operations, Op_Iter);
      for I in 1 .. Mast.Operations.Lists.Size (System_Imported.Operations)
      loop
         Mast.Operations.Lists.Get_Next_Item
           (Op_Ref,
            System_Imported.Operations,
            Op_Iter);
         begin
            Mast.Operations.Lists.Add (Op_Ref, The_System.Operations);
         exception
            when Already_Exists =>
               Duplicate_Elements:=True;
               if Verbose then
                  Put_Line("Error while adjusting lists. "&
                           "Duplicate operation: "&
                           Mast.Operations.Name(Op_Ref));
               end if;
         end;
      end loop;

      ------------------------
      -- Transactions
      ------------------------
      Mast.Transactions.Lists.Rewind
        (System_Imported.Transactions,
         Tran_Iter);
      for I in
        1 .. Mast.Transactions.Lists.Size (System_Imported.Transactions)
      loop
         Mast.Transactions.Lists.Get_Next_Item
           (Tran_Ref,
            System_Imported.Transactions,
            Tran_Iter);
         begin
            Mast.Transactions.Lists.Add (Tran_Ref, The_System.Transactions);
         exception
            when Already_Exists =>
               Duplicate_Elements:=True;
               if Verbose then
                  Put_Line("Error while adjusting lists. "&
                           "Duplicate transaction: "&
                           Mast.Transactions.Name(Tran_Ref));
               end if;
         end;
      end loop;

      if Duplicate_Elements then
         raise Duplicates;
      end if;

   end Adjust_System_Lists;

   --------------------
   -- Register_Names --
   --------------------

   procedure Register_Names (Filename : String; ME_Filename : String) is
   begin
      System_Name           := new String'(Filename);
      System_Present        := True;
      Editor_System_Name    := new String'(ME_Filename);
      Editor_System_Present := True;
      Set_Sensitive (Mast_Editor_Window.Analysis, True);
      Current_Filename := new String'(Filename);
      Set_Window_Title;
   end Register_Names;

   -----------------
   -- Read_System --
   -----------------

   procedure Read_System (Filename : String) is
      F : Ada.Text_IO.File_Type;
   begin
      System_Name := new String'(Filename);
      Ada.Text_IO.Open (F, Ada.Text_IO.In_File, Filename);
      begin
         Ada.Text_IO.Set_Input (F);
         MAST_Parser (The_System);
         Close (F);
         Ada.Text_IO.Set_Input (Standard_Input);
         System_Present := True;
         Set_Sensitive (Mast_Editor_Window.Analysis, True);
         Free (Current_Filename);
         Current_Filename := new String'(Filename);
         Set_Window_Title;
      exception
         when others =>
            Close (F);
            Ada.Text_IO.Set_Input (Standard_Input);
            System_Present := False;
            Set_Sensitive (Mast_Editor_Window.Analysis, False);
            raise;
      end;
   end Read_System;

   -----------------
   -- Save_System --
   -----------------

   procedure Save_System (Filename : String) is
      Out_Res : File_Type;
   begin
      Ada.Text_IO.Create (Out_Res, Ada.Text_IO.Out_File, Filename);
      Mast.Systems.Print (Out_Res, The_System);
      Close (Out_Res);
      System_Present := True;
      Set_Sensitive (Mast_Editor_Window.Analysis, True);
   end Save_System;

   ------------------------
   -- Save_Editor_System --
   ------------------------

   procedure Save_Editor_System
     (Filename  : String;
      Saving_As : Boolean := False)
   is
      Out_Res          : File_Type;
      Editor_File_Name : Var_String;
      Long             : Natural;
   begin
      Editor_File_Name := To_Var_String (Filename);
      Long             := Length (Editor_File_Name);
      if Long > 3 and then Element (Editor_File_Name, Long - 3) = '.' then
         Editor_File_Name := Slice (Editor_File_Name, 1, Long - 3) & "mss";
      else
         Editor_File_Name := Editor_File_Name & ".mss";
      end if;
      Ada.Text_IO.Create
        (Out_Res,
         Ada.Text_IO.Out_File,
         To_String (Editor_File_Name));
      Mast_Editor.Systems.Print (Out_Res, Editor_System);
      Close (Out_Res);
      Editor_System_Present := True;
      if Saving_As then
         Free (Current_Filename);
         Current_Filename := new String'(Filename);
      end if;
      Set_Window_Title;
      Change_Control.Saved;
   end Save_Editor_System;

   -----------------------
   -- Extract_Delimiter --
   -----------------------

   procedure Extract_Delimiter
     (Composite_Name : in Var_String;
      First_Name     : out Var_String;
      Second_Name    : out Var_String)
   is
      Delimiter_Position : Natural;
   begin
      for I in 1 .. Var_Strings.Length (Composite_Name) loop
         if Var_Strings.Slice (Composite_Name, I, I) =
           Var_Strings.To_Var_String (Delimiter)
         then
            Delimiter_Position := I;
            exit;
         end if;
      end loop;
      First_Name  :=
        Var_Strings.Slice (Composite_Name, 1, Delimiter_Position - 1);
      Second_Name :=
        Var_Strings.Slice
        (Composite_Name,
         Delimiter_Position + 1,
         Var_Strings.Length (Composite_Name));
   end Extract_Delimiter;

   ------------------------
   -- Read_Common_Params --
   ------------------------

   procedure Read_Common_Params
     (Item      : ME_Object_Ref;
      Arguments : Me_Arguments_Ref)
   is
   begin
      Item.Name        :=
        Var_Strings.Slice
        (Arguments.all (3),
         1,
         Length (Arguments.all (3)) - 1);
      Item.Canvas_Name :=
        Var_Strings.Slice
        (Arguments.all (4),
         1,
         Length (Arguments.all (4)) - 1);
      Item.X_Coord     := Gint'Value (To_String (Arguments.all (5)));
      Item.Y_Coord     := Gint'Value (To_String (Arguments.all (6)));
   end Read_Common_Params;

   ------------------------
   -- Read_Editor_System --
   ------------------------
   procedure Read_Editor_System
     (Filename         : String;
      Importing_System : Boolean := False)
   is
      Editor_File_Name                                                     :
        Var_String;
      Long                                                                 :
        Natural;
      Fich                                                                 :
        Ada.Text_IO.File_Type;
      Num, Num_Spaces                                                      :
        Integer;
      Argu                                                                 :
        String (1 .. 50);
      Ini_Argu                                                             :
        Integer;
      L_Linea                                                              :
        Integer;
      N_Linea                                                              :
        Integer;
      Linea                                                                :
        String (1 .. 150) := String'(1 .. 150 => ' ');
      Driver_Proc_Name, Driver_Net_Name, Event_Name, Handler_Id, Tran_Name :
        Var_Strings.Var_String;
      Item                                                                 :
        ME_Object_Ref;
      Proc_Iter                                                            :
        Mast.Processing_Resources.Lists.Iteration_Object;
      Share_Iter                                                           :
        Mast.Shared_Resources.Lists.Iteration_Object;
      Sche_Iter                                                            :
        Mast.Schedulers.Lists.Iteration_Object;
      Op_Iter                                                              :
        Mast.Operations.Lists.Iteration_Object;
      Ser_Iter                                                             :
        Mast.Scheduling_Servers.Lists.Iteration_Object;
      Tran_Iter                                                            :
        Mast.Transactions.Lists.Iteration_Object;
      Me_Proc_Iter, Me_Net_Iter                                            :
        Mast_Editor.Processing_Resources.Lists.Iteration_Object;
      Me_Proc_Ref, Me_Net_Ref                                              :
        Mast_Editor.Processing_Resources.ME_Processing_Resource_Ref;
      Me_Sche_Iter                                                         :
        Mast_Editor.Schedulers.Lists.Iteration_Object;
      Me_Sche_Ref                                                          :
        Mast_Editor.Schedulers.ME_Scheduler_Ref;
      Me_Tran_Iter                                                         :
        Mast_Editor.Transactions.Lists.Iteration_Object;
      Me_Tran_Ref                                                          :
        Mast_Editor.Transactions.ME_Transaction_Ref;
      Me_Lin_Iter                                                          :
        Mast_Editor.Links.Lists.Iteration_Object;
      Me_Lin_Ref                                                           :
        Mast_Editor.Links.ME_Link_Ref;
      Drive_Iterator                                                       :
        Mast.Processing_Resources.Network.Driver_Iteration_Object;
      Drive_Ref                                                            :
        Mast.Drivers.Driver_Ref;
      Lin_Iter                                                             :
        Mast.Transactions.Link_Iteration_Object;
      Link_Iter                                                            :
        Mast.Graphs.Event_Handlers.Iteration_Object;
      Lin_Ref                                                              :
        Mast.Graphs.Link_Ref;
      Han_Iter                                                             :
        Mast.Transactions.Event_Handler_Iteration_Object;
      Han_Ref                                                              :
        Mast.Graphs.Event_Handler_Ref;
      Serv_Ref                                                             :
        Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Proc_Ref                                                             :
        Mast.Processing_Resources.Processing_Resource_Ref;
   begin
      Editor_File_Name := To_Var_String (Filename);
      Long             := Length (Editor_File_Name);
      if Long > 3 and then Element (Editor_File_Name, Long - 3) = '.' then
         Editor_File_Name := Slice (Editor_File_Name, 1, Long - 3) & "mss";
      else
         Editor_File_Name := Editor_File_Name & ".mss";
      end if;
      Ada.Text_IO.Open (Fich, In_File, To_String (Editor_File_Name));
      -- raises Name_Error when file not found

      if not Importing_System then
         Reset_Editor_System (Editor_System);
         Editor_System_Name := new String'(Filename);
      else
         if Editor_System_Present /= True then
            Editor_System_Name := new String'(Filename);
         end if;
      end if;
      L_Linea := 0;
      N_Linea := 1;
      while not End_Of_File (Fich) loop
         begin
            if N_Linea = 1 then
               Get_Line (Fich, Linea, L_Linea);
               N_Linea := N_Linea + 1;
            else
               Get_Line (Fich, Linea, L_Linea);
               Ini_Argu   := 1;
               Num        := 1;
               Num_Spaces := 0;
               for I in 1 .. L_Linea loop
                  if Linea (I) = ' ' then
                     Num_Spaces := Num_Spaces + 1;
                     Argu       := String'(1 .. 50 => ' ');
                     Ini_Argu   := I - Num;
                     for J in 1 .. Num loop
                        Argu (J) := Linea (Ini_Argu + J);
                     end loop;
                     Temp_Arguments.all (Num_Spaces) :=
                       To_Var_String (Argu (1 .. Num));
                     Num                             := 1;
                  else
                     Num := Num + 1;
                  end if;
               end loop;
               if Num_Spaces = 6 then
                  --------------------
                  -- Shared Resources
                  --------------------
                  if Temp_Arguments.all (1) =
                    To_Var_String ("ME_Shared_Resource ")
                  then
                     if Temp_Arguments.all (2) =
                       To_Var_String ("Me_Priority_Inheritance_Resource ")
                     then
                        Item := new ME_Priority_Inheritance_Resource;
                        Read_Common_Params (Item, Temp_Arguments);
                        begin
                           Share_Iter                          :=
                             Mast.Shared_Resources.Lists.Find
                             (Item.Name,
                              The_System.Shared_Resources);
                           ME_Shared_Resource_Ref (Item).Share :=
                             Mast.Shared_Resources.Lists.Item
                             (Share_Iter,
                              The_System.Shared_Resources);
                           Item.Color_Name                     := Share_Color;
                           Item.W                              := Share_Width;
                           Item.H                              :=
                             Share_Height;
                           Mast_Editor.Shared_Resources.Lists.Add
                             (ME_Shared_Resource_Ref (Item),
                              Editor_System.Me_Shared_Resources);
                           Put_Item_In_Canvas (Item);
                        exception
                           when Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Shared resource: "&Item.name);
                              end if;
                        end;
                     elsif Temp_Arguments.all (2) =
                       To_Var_String ("Me_Immediate_Ceiling_Resource ")
                     then
                        Item := new ME_Immediate_Ceiling_Resource;
                        Read_Common_Params (Item, Temp_Arguments);
                        begin
                           Share_Iter                          :=
                             Mast.Shared_Resources.Lists.Find
                             (Item.Name,
                              The_System.Shared_Resources);
                           ME_Shared_Resource_Ref (Item).Share :=
                             Mast.Shared_Resources.Lists.Item
                             (Share_Iter,
                              The_System.Shared_Resources);
                           Item.Color_Name                     := Share_Color;
                           Item.W                              := Share_Width;
                           Item.H                              :=
                             Share_Height;
                           Mast_Editor.Shared_Resources.Lists.Add
                             (ME_Shared_Resource_Ref (Item),
                              Editor_System.Me_Shared_Resources);
                           Put_Item_In_Canvas (Item);
                        exception
                           when Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Shared resource: "&Item.name);
                              end if;
                        end;
                     elsif Temp_Arguments.all (2) =
                       To_Var_String ("Me_SRP_Resource ")
                     then
                        Item := new ME_SRP_Resource;
                        Read_Common_Params (Item, Temp_Arguments);
                        begin
                           Share_Iter                          :=
                             Mast.Shared_Resources.Lists.Find
                             (Item.Name,
                              The_System.Shared_Resources);
                           ME_Shared_Resource_Ref (Item).Share :=
                             Mast.Shared_Resources.Lists.Item
                             (Share_Iter,
                              The_System.Shared_Resources);
                           Item.Color_Name                     := Share_Color;
                           Item.W                              := Share_Width;
                           Item.H                              :=
                             Share_Height;
                           Mast_Editor.Shared_Resources.Lists.Add
                             (ME_Shared_Resource_Ref (Item),
                              Editor_System.Me_Shared_Resources);
                           Put_Item_In_Canvas (Item);
                        exception
                           when Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Shared resource: "&Item.name);
                              end if;
                        end;
                     end if;
                     ---------------
                     -- Operations
                     ---------------
                  elsif Temp_Arguments.all (1) =
                    To_Var_String ("ME_Operation ")
                  then
                     if Temp_Arguments (2) =
                       To_Var_String ("Me_Simple_Operation ")
                     then
                        Item := new ME_Simple_Operation;
                        Read_Common_Params (Item, Temp_Arguments);
                        begin
                           Op_Iter                    :=
                             Mast.Operations.Lists.Find
                             (Item.Name,
                              The_System.Operations);
                           ME_Operation_Ref (Item).Op :=
                             Mast.Operations.Lists.Item
                             (Op_Iter,
                              The_System.Operations);
                           Item.Color_Name            := Sop_Color;
                           Item.W                     := Op_Width;
                           Item.H                     := Op_Height;
                           Mast_Editor.Operations.Lists.Add
                             (ME_Operation_Ref (Item),
                              Editor_System.Me_Operations);
                           Put_Item_In_Canvas (Item);
                        exception
                           when Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Operation: "&Item.name);
                              end if;
                        end;
                     elsif Temp_Arguments.all (2) =
                       To_Var_String ("Me_Composite_Operation ")
                     then
                        Item := new ME_Composite_Operation;
                        Read_Common_Params (Item, Temp_Arguments);
                        begin
                           Op_Iter                    :=
                             Mast.Operations.Lists.Find
                             (Item.Name,
                              The_System.Operations);
                           ME_Operation_Ref (Item).Op :=
                             Mast.Operations.Lists.Item
                             (Op_Iter,
                              The_System.Operations);
                           Item.Color_Name            := Cop_Color;
                           Item.W                     := Op_Width;
                           Item.H                     := Op_Height;
                           Mast_Editor.Operations.Lists.Add
                             (ME_Operation_Ref (Item),
                              Editor_System.Me_Operations);
                           Put_Item_In_Canvas (Item);
                           Mast_Editor.Operations.
                             Draw_Composite_Operation_Links
                             (ME_Operation_Ref (Item));
                        exception
                           when Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Operation: "&Item.name);
                              end if;
                        end;
                     elsif Temp_Arguments.all (2) =
                       To_Var_String ("Me_Enclosing_Operation ")
                     then
                        Item := new ME_Composite_Operation;
                        Read_Common_Params (Item, Temp_Arguments);
                        begin
                           Op_Iter                    :=
                             Mast.Operations.Lists.Find
                             (Item.Name,
                              The_System.Operations);
                           ME_Operation_Ref (Item).Op :=
                             Mast.Operations.Lists.Item
                             (Op_Iter,
                              The_System.Operations);
                           Item.Color_Name            := Cop_Color;
                           Item.W                     := Op_Width;
                           Item.H                     := Op_Height;
                           Mast_Editor.Operations.Lists.Add
                             (ME_Operation_Ref (Item),
                              Editor_System.Me_Operations);
                           Put_Item_In_Canvas (Item);
                           Mast_Editor.Operations.
                             Draw_Composite_Operation_Links
                             (ME_Operation_Ref (Item));
                        exception
                           when Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Operation: "&Item.name);
                              end if;
                        end;
                     elsif Temp_Arguments.all (2) =
                       To_Var_String
                       ("Me_Message_Transmission_Operation ")
                     then
                        Item := new Me_Message_Transmission_Operation;
                        Read_Common_Params (Item, Temp_Arguments);
                        begin
                           Op_Iter                    :=
                             Mast.Operations.Lists.Find
                             (Item.Name,
                              The_System.Operations);
                           ME_Operation_Ref (Item).Op :=
                             Mast.Operations.Lists.Item
                             (Op_Iter,
                              The_System.Operations);
                           Item.Color_Name            := Txop_Color;
                           Item.W                     := Op_Width;
                           Item.H                     := Op_Height;
                           Mast_Editor.Operations.Lists.Add
                             (ME_Operation_Ref (Item),
                              Editor_System.Me_Operations);
                           Put_Item_In_Canvas (Item);
                        exception
                           when Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Operation: "&Item.name);
                              end if;
                        end;
                     end if;
                     ------------------------
                     -- Processing Resources
                     ------------------------
                  elsif Temp_Arguments.all (1) =
                    To_Var_String ("ME_Processing_Resource ")
                  then
                     if Temp_Arguments.all (2) =
                       To_Var_String ("Me_Regular_Processor ")
                     then
                        Item := new ME_Regular_Processor;
                        Read_Common_Params (Item, Temp_Arguments);
                        begin
                           Proc_Iter                             :=
                             Mast.Processing_Resources.Lists.Find
                             (Item.Name,
                              The_System.Processing_Resources);
                           ME_Processing_Resource_Ref (Item).Res :=
                             Mast.Processing_Resources.Lists.Item
                             (Proc_Iter,
                              The_System.Processing_Resources);
                           Item.Color_Name                       :=
                             Proc_Color;
                           Item.W                                :=
                             Proc_Width;
                           Item.H                                :=
                             Proc_Height;
                           Mast_Editor.Processing_Resources.Lists.Add
                             (ME_Processing_Resource_Ref (Item),
                              Editor_System.Me_Processing_Resources);
                           Put_Item_In_Canvas (Item);
                        exception
                           when Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Processing resource: "&Item.name);
                              end if;
                        end;
                     elsif Temp_Arguments.all (2) =
                       To_Var_String ("Me_Packet_Based_Network ")
                     then
                        Item := new ME_Packet_Based_Network;
                        Read_Common_Params (Item, Temp_Arguments);
                        begin
                           Proc_Iter                             :=
                             Mast.Processing_Resources.Lists.Find
                             (Item.Name,
                              The_System.Processing_Resources);
                           ME_Processing_Resource_Ref (Item).Res :=
                             Mast.Processing_Resources.Lists.Item
                             (Proc_Iter,
                              The_System.Processing_Resources);
                           Item.Color_Name                       := Net_Color;
                           Item.W                                := Net_Width;
                           Item.H                                :=
                             Net_Height;
                           Mast_Editor.Processing_Resources.Lists.Add
                             (ME_Processing_Resource_Ref (Item),
                              Editor_System.Me_Processing_Resources);
                           Put_Item_In_Canvas (Item);
                        exception
                           when Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Processing resource: "&Item.name);
                              end if;
                        end;
                     end if;
                     ---------------
                     -- Timers
                     ---------------
                  elsif Temp_Arguments.all (1) =
                    To_Var_String ("ME_Timer ")
                  then
                     if Temp_Arguments (2) =
                       To_Var_String ("Me_System_Timer ")
                     then
                        Item := new ME_System_Timer;
                        Read_Common_Params (Item, Temp_Arguments);
                        begin
                           Proc_Iter                :=
                             Mast.Processing_Resources.Lists.Find
                             (Item.Name,
                              The_System.Processing_Resources);
                           ME_Timer_Ref (Item).Proc :=
                             Mast.Processing_Resources.Lists.Item
                             (Proc_Iter,
                              The_System.Processing_Resources);
                           ME_Timer_Ref (Item).Tim  :=
                             Mast.Processing_Resources.Processor.
                             The_System_Timer
                             (Mast.Processing_Resources.Processor.
                              Regular_Processor
                              (ME_Timer_Ref (Item).Proc.all));
                           Me_Proc_Iter             :=
                             Mast_Editor.Processing_Resources.Lists.Find
                             (Item.Name,
                              Editor_System.Me_Processing_Resources);
                           Me_Proc_Ref              :=
                             Mast_Editor.Processing_Resources.Lists.Item
                             (Me_Proc_Iter,
                              Editor_System.Me_Processing_Resources);
                           Item.Color_Name          := Timer_Color;
                           Item.W                   := Timer_Width;
                           Item.H                   := Timer_Height;
                           if ME_Timer_Ref (Item).Tim /= null then
                              Mast_Editor.Timers.Lists.Add
                                (ME_Timer_Ref (Item),
                                 Editor_System.Me_Timers);
                              Put_Item_In_Canvas (Item);
                              if Me_Proc_Ref /= null then
                                 Add_Canvas_Link
                                   (Proc_Res_Canvas,
                                    Me_Proc_Ref,
                                    Item);
                              end if;
                           end if;
                           Refresh_Canvas (Proc_Res_Canvas);
                        exception
                           when Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Timer of Processing resource: "
                                          &Item.name);
                              end if;
                        end;
                     end if;

                     ---------------
                     -- Drivers
                     ---------------
                  elsif Temp_Arguments.all (1) =
                    To_Var_String ("ME_Driver ")
                  then
                     if Temp_Arguments (2) =
                       To_Var_String ("Me_Packet_Driver ")
                     then
                        Item := new ME_Packet_Driver;
                        Read_Common_Params (Item, Temp_Arguments);
                        Extract_Delimiter
                          (Item.Name,
                           Driver_Proc_Name,
                           Driver_Net_Name);
                        begin
                           Proc_Iter                 :=
                             Mast.Processing_Resources.Lists.Find
                             (Driver_Proc_Name,
                              The_System.Processing_Resources);
                           ME_Driver_Ref (Item).Proc :=
                             Mast.Processing_Resources.Lists.Item
                             (Proc_Iter,
                              The_System.Processing_Resources);
                           Proc_Iter                 :=
                             Mast.Processing_Resources.Lists.Find
                             (Driver_Net_Name,
                              The_System.Processing_Resources);
                           ME_Driver_Ref (Item).Net  :=
                             Mast.Processing_Resources.Lists.Item
                             (Proc_Iter,
                              The_System.Processing_Resources);

                           --- We search driver in the list of drivers of the
                           -- network and assign it when found
                           Mast.Processing_Resources.Network.Rewind_Drivers
                             (
                              Mast.Processing_Resources.Network.
                              Packet_Based_Network
                              (ME_Driver_Ref (Item).Net.all),
                              Drive_Iterator);
                           for I in
                             1 ..
                             Mast.Processing_Resources.Network.
                             Num_Of_Drivers
                             (Mast.Processing_Resources.Network.
                              Packet_Based_Network
                              (ME_Driver_Ref (Item).Net.all))
                           loop
                              Mast.Processing_Resources.Network.
                                Get_Next_Driver
                                (Mast.Processing_Resources.Network.
                                 Packet_Based_Network
                                 (ME_Driver_Ref (Item).Net.all),
                                 Drive_Ref,
                                 Drive_Iterator);
                              if (Drive_Ref /= null)
                                and then (Packet_Server
                                          (Packet_Driver (Drive_Ref.all)) /=
                                          null)
                              then
                                 Serv_Ref :=
                                   Packet_Server
                                   (Packet_Driver (Drive_Ref.all));
                                 if Serv_Ref /= null then
                                    begin
                                       Proc_Ref :=
                                         Server_Processing_Resource
                                         (Serv_Ref.all); -- Server processor
                                       if (Proc_Ref /= null)
                                         and then
                                         (Mast.Processing_Resources.Name
                                          (Proc_Ref) =
                                          Driver_Proc_Name)
                                       then
                                          ME_Driver_Ref (Item).Driv :=
                                            Drive_Ref;
                                          exit;
                                       end if;
                                    exception
                                       when Constraint_Error =>
                                          if Verbose then
                                             Put_Line("C-Error while reading"&
                                                      " editor info. "&
                                                      "Driver of: "&
                                                      Driver_Proc_Name);
                                          end if;
                                    end;
                                 end if;
                              end if;
                           end loop;

                           Me_Proc_Iter :=
                             Mast_Editor.Processing_Resources.Lists.Find
                             (Driver_Proc_Name,
                              Editor_System.Me_Processing_Resources);
                           Me_Proc_Ref  :=
                             Mast_Editor.Processing_Resources.Lists.Item
                             (Me_Proc_Iter,
                              Editor_System.Me_Processing_Resources);
                           Me_Net_Iter  :=
                             Mast_Editor.Processing_Resources.Lists.Find
                             (Driver_Net_Name,
                              Editor_System.Me_Processing_Resources);
                           Me_Net_Ref   :=
                             Mast_Editor.Processing_Resources.Lists.Item
                             (Me_Net_Iter,
                              Editor_System.Me_Processing_Resources);
                           Item.Name:=To_Var_String(" ");
                           Item.Color_Name := Driv_Color;
                           Item.W          := Driv_Width;
                           Item.H          := Driv_Height;
                           if ME_Driver_Ref (Item).Driv /= null then
                              Mast_Editor.Drivers.Lists.Add
                                (ME_Driver_Ref (Item),
                                 Editor_System.Me_Drivers);
                              Put_Item_In_Canvas (Item);
                              if Me_Proc_Ref /= null then
                                 Add_Canvas_Link
                                   (Proc_Res_Canvas,
                                    Item,
                                    Me_Proc_Ref);
                              end if;
                              if Me_Net_Ref /= null then
                                 Add_Canvas_Link
                                   (Proc_Res_Canvas,
                                    Me_Net_Ref,
                                    Item);
                              end if;
                           end if;
                           Refresh_Canvas (Proc_Res_Canvas);
                        exception
                           when Constraint_Error =>
                              if Verbose then
                                 Put_Line("C-Error while reading "&
                                          "editor info. "&
                                          "Driver of: "&Driver_Proc_Name);
                              end if;
                           when Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Driver of: "&Driver_Proc_Name);
                              end if;
                        end;
                     end if;

                     ---------------
                     -- Schedulers
                     ---------------
                  elsif Temp_Arguments.all (1) =
                    To_Var_String ("ME_Scheduler ")
                  then
                     if Temp_Arguments (2) =
                       To_Var_String ("Me_Primary_Scheduler ")
                     then
                        Item := new ME_Primary_Scheduler;
                        Read_Common_Params (Item, Temp_Arguments);
                        begin
                           Sche_Iter                    :=
                             Mast.Schedulers.Lists.Find
                             (Item.Name,
                              The_System.Schedulers);
                           ME_Scheduler_Ref (Item).Sche :=
                             Mast.Schedulers.Lists.Item
                             (Sche_Iter,
                              The_System.Schedulers);
                           Item.Color_Name              := Prime_Color;
                           Item.W                       := Sche_Width;
                           Item.H                       := Sche_Height;
                           if Item.Canvas_Name =
                             To_Var_String ("Proc_Res_Canvas")
                           then
                              Mast_Editor.Schedulers.Lists.Add
                                (ME_Scheduler_Ref (Item),
                                 Editor_System.Me_Schedulers);
                              Put_Item_In_Canvas (Item);
                              Mast_Editor.Schedulers.Draw_Scheduler_Host
                                (ME_Scheduler_Ref (Item));
                           elsif Item.Canvas_Name =
                             To_Var_String ("Sched_Server_Canvas")
                           then
                              Mast_Editor.Schedulers.Lists.Add
                                (ME_Scheduler_Ref (Item),
                                 Editor_System.Me_Schedulers_In_Server_Canvas);
                              Put_Item_In_Canvas (Item);
                           end if;
                        exception
                           when Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Sheduler: "&Item.name);
                              end if;
                        end;
                     elsif Temp_Arguments (2) =
                       To_Var_String ("Me_Secondary_Scheduler ")
                     then
                        Item := new ME_Secondary_Scheduler;
                        Read_Common_Params (Item, Temp_Arguments);
                        begin
                           Sche_Iter                    :=
                             Mast.Schedulers.Lists.Find
                             (Item.Name,
                              The_System.Schedulers);
                           ME_Scheduler_Ref (Item).Sche :=
                             Mast.Schedulers.Lists.Item
                             (Sche_Iter,
                              The_System.Schedulers);
                           Item.Color_Name              := Second_Color;
                           Item.W                       := Sche_Width;
                           Item.H                       := Sche_Height;
                           if Item.Canvas_Name =
                             To_Var_String ("Proc_Res_Canvas")
                           then
                              Mast_Editor.Schedulers.Lists.Add
                                (ME_Scheduler_Ref (Item),
                                 Editor_System.Me_Schedulers);
                              Put_Item_In_Canvas (Item);

                              -- We can't call this procedure here, since we
                              -- haven't read the schedulers from the file.
                              -- This call is made later for each of the
                              -- secondary schedulers, once we have all
                              -- servers info loaded from the file.

                              -- Mast_Editor.Schedulers.Draw_Scheduler_Server
                              --   (Me_Scheduler_Ref(Item));
                           elsif Item.Canvas_Name =
                             To_Var_String ("Sched_Server_Canvas")
                           then
                              Mast_Editor.Schedulers.Lists.Add
                                (ME_Scheduler_Ref (Item),
                                 Editor_System.Me_Schedulers_In_Server_Canvas);
                              Put_Item_In_Canvas (Item);
                           end if;
                        exception
                           when Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Sheduler: "&Item.name);
                              end if;
                        end;
                     end if;
                     ---------------------
                     -- Scheduling Servers
                     ---------------------
                  elsif Temp_Arguments.all (1) =
                    To_Var_String ("ME_Scheduling_Server ")
                  then
                     if Temp_Arguments.all (2) =
                       To_Var_String ("Me_Server ")
                     then
                        Item := new ME_Server;
                        Read_Common_Params (Item, Temp_Arguments);
                        begin
                           Ser_Iter                            :=
                             Mast.Scheduling_Servers.Lists.Find
                             (Item.Name,
                              The_System.Scheduling_Servers);
                           ME_Scheduling_Server_Ref (Item).Ser :=
                             Mast.Scheduling_Servers.Lists.Item
                             (Ser_Iter,
                              The_System.Scheduling_Servers);
                           Item.Color_Name                     := Ser_Color;
                           Item.W                              := Ser_Width;
                           Item.H                              := Ser_Height;
                           if Item.Canvas_Name =
                             To_Var_String ("Sched_Server_Canvas")
                           then
                              Mast_Editor.Scheduling_Servers.Lists.Add
                                (ME_Scheduling_Server_Ref (Item),
                                 Editor_System.Me_Scheduling_Servers);
                              Put_Item_In_Canvas (Item);
                              Mast_Editor.Scheduling_Servers.
                                Draw_Scheduler_In_Server_Canvas
                                (ME_Scheduling_Server_Ref (Item));
                           elsif Item.Canvas_Name =
                             To_Var_String ("Proc_Res_Canvas")
                           then
                              Mast_Editor.Scheduling_Servers.Lists.Add
                                (ME_Scheduling_Server_Ref (Item),
                                 Editor_System.Me_Servers_In_Proc_Canvas);
                              Put_Item_In_Canvas (Item);
                           end if;
                        exception
                           when Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Sheduling server: "&Item.name);
                              end if;
                        end;
                     end if;
                     -----------------------
                     -- Transactions
                     -----------------------
                  elsif Temp_Arguments.all (1) =
                    To_Var_String ("ME_Transaction ")
                  then
                     if Temp_Arguments.all (2) =
                       To_Var_String ("Me_Regular_Transaction ")
                     then
                        Item := new ME_Regular_Transaction;
                        Read_Common_Params (Item, Temp_Arguments);
                        begin
                           Tran_Iter                      :=
                             Mast.Transactions.Lists.Find
                             (Item.Name,
                              The_System.Transactions);
                           ME_Transaction_Ref (Item).Tran :=
                             Mast.Transactions.Lists.Item
                             (Tran_Iter,
                              The_System.Transactions);
                           Item.Color_Name                := Tran_Color;
                           Item.W                         := Tran_Width;
                           Item.H                         := Tran_Height;
                           Gtk_New (ME_Transaction_Ref (Item).Dialog);

                           -- We should connect right buttons signals
                           Button_Cb.Connect
                             (ME_Transaction_Ref (Item).Dialog.Add_Ext_Button,
                              "clicked",
                              Button_Cb.To_Marshaller
                              (Mast_Editor.Links.Show_External_Dialog'
                               Access),
                              ME_Transaction_Ref (Item));
                           Button_Cb.Connect
                             (ME_Transaction_Ref (Item).Dialog.Add_Int_Button,
                              "clicked",
                              Button_Cb.To_Marshaller
                              (Mast_Editor.Links.Show_Internal_Dialog'
                               Access),
                              ME_Transaction_Ref (Item));
                           Button_Cb.Connect
                             (ME_Transaction_Ref (Item).Dialog.
                              Add_Simple_Button,
                              "clicked",
                              Button_Cb.To_Marshaller
                              (
                               Mast_Editor.Event_Handlers.
                               Show_Simple_Event_Handler_Dialog'Access),
                              ME_Transaction_Ref (Item));
                           Button_Cb.Connect
                             (ME_Transaction_Ref (Item).Dialog.
                              Add_Minput_Button,
                              "clicked",
                              Button_Cb.To_Marshaller
                              (
                               Mast_Editor.Event_Handlers.
                               Show_Multi_Input_Event_Handler_Dialog'Access),
                              ME_Transaction_Ref (Item));
                           Button_Cb.Connect
                             (ME_Transaction_Ref (Item).Dialog.
                              Add_Moutput_Button,
                              "clicked",
                              Button_Cb.To_Marshaller
                              (
                               Mast_Editor.Event_Handlers.
                               Show_Multi_Output_Event_Handler_Dialog'Access),
                              ME_Transaction_Ref (Item));

                           Mast_Editor.Transactions.Lists.Add
                             (ME_Transaction_Ref (Item),
                              Editor_System.Me_Transactions);
                           Put_Item_In_Canvas (Item);
                        exception
                           when Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Transaction: "&Item.name);
                              end if;
                        end;
                     end if;

                     --------------------
                     -- Events (Links)
                     --------------------
                  elsif Temp_Arguments.all (1) =
                    To_Var_String ("ME_Link ")
                  then
                     if Temp_Arguments (2) =
                       To_Var_String ("Me_External_Link ")
                     then
                        Item := new ME_External_Link;
                        Read_Common_Params (Item, Temp_Arguments);
                        Extract_Delimiter (Item.Name, Event_Name, Tran_Name);
                        begin
                           Me_Tran_Iter               :=
                             Mast_Editor.Transactions.Lists.Find
                             (Tran_Name,
                              Editor_System.Me_Transactions);
                           ME_Link_Ref (Item).ME_Tran :=
                             Mast_Editor.Transactions.Lists.Item
                             (Me_Tran_Iter,
                              Editor_System.Me_Transactions);
                           -- We search Link in the list of external links of
                           -- the transaction and assign it when found
                           if ME_Link_Ref (Item).ME_Tran.Tran /= null then
                              ME_Link_Ref (Item).Lin :=
                                Mast.Transactions.Find_External_Event_Link
                                (Event_Name,
                                 ME_Link_Ref (Item).ME_Tran.Tran.all);
                           end if;
                           Item.Color_Name := Ext_Link_Color;
                           Item.W          := Link_Width;
                           Item.H          := Link_Height;
                           if ME_Link_Ref (Item).Lin /= null then
                              Mast_Editor.Links.Lists.Add
                                (ME_Link_Ref (Item),
                                 Editor_System.Me_Links);
                              Put_Item_In_Canvas (Item);
                           end if;
                        exception
                           when Invalid_Index | Link_Not_Found =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Event of transaction: "&Tran_Name);
                              end if;
                        end;
                     elsif Temp_Arguments (2) =
                       To_Var_String ("Me_Internal_Link ")
                     then
                        Item := new ME_Internal_Link;
                        Read_Common_Params (Item, Temp_Arguments);
                        Extract_Delimiter (Item.Name, Event_Name, Tran_Name);
                        begin
                           Me_Tran_Iter               :=
                             Mast_Editor.Transactions.Lists.Find
                             (Tran_Name,
                              Editor_System.Me_Transactions);
                           ME_Link_Ref (Item).ME_Tran :=
                             Mast_Editor.Transactions.Lists.Item
                             (Me_Tran_Iter,
                              Editor_System.Me_Transactions);
                           --- We search Link in the list of internal links of
                           --  the transaction and assign it when found
                           if ME_Link_Ref (Item).ME_Tran.Tran /= null then
                              ME_Link_Ref (Item).Lin :=
                                Mast.Transactions.Find_Internal_Event_Link
                                (Event_Name,
                                 ME_Link_Ref (Item).ME_Tran.Tran.all);
                           end if;
                           Item.Color_Name := Int_Link_Color;
                           Item.W          := Link_Width;
                           Item.H          := Link_Height;
                           if ME_Link_Ref (Item).Lin /= null then
                              Mast_Editor.Links.Lists.Add
                                (ME_Link_Ref (Item),
                                 Editor_System.Me_Links);
                              Put_Item_In_Canvas (Item);
                           end if;
                        exception
                           when Invalid_Index | Link_Not_Found =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Event of transaction: "&Tran_Name);
                              end if;
                        end;
                     end if;

                     --------------------
                     -- Event Handlers
                     --------------------
                  elsif Temp_Arguments.all (1) =
                    To_Var_String ("ME_Event_Handler ")
                  then
                     if Temp_Arguments (2) =
                       To_Var_String ("Me_Simple_Event_Handler ")
                     then
                        Item := new ME_Simple_Event_Handler;
                        Read_Common_Params (Item, Temp_Arguments);
                        Extract_Delimiter (Item.Name, Handler_Id, Tran_Name);
                        begin
                           Me_Tran_Iter                        :=
                             Mast_Editor.Transactions.Lists.Find
                             (Tran_Name,
                              Editor_System.Me_Transactions);
                           ME_Event_Handler_Ref (Item).ME_Tran :=
                             Mast_Editor.Transactions.Lists.Item
                             (Me_Tran_Iter,
                              Editor_System.Me_Transactions);
                           -- We travel through handler list of the
                           -- transaction, search for handler and assign its
                           -- value when found
                           if ME_Event_Handler_Ref (Item).ME_Tran.Tran /=
                             null
                           then
                              Mast.Transactions.Rewind_Event_Handlers
                                (ME_Event_Handler_Ref (Item).ME_Tran.Tran.all,
                                 Han_Iter);
                              for I in
                                1 ..
                                Positive'Value (To_String (Handler_Id))
                              loop
                                 Mast.Transactions.Get_Next_Event_Handler
                                   (ME_Event_Handler_Ref (Item).ME_Tran.Tran.
                                    all,
                                    Han_Ref,
                                    Han_Iter);
                              end loop;
                              ME_Event_Handler_Ref (Item).Han := Han_Ref;
                           end if;
                           ME_Event_Handler_Ref (Item).Id :=
                             Positive'Value (To_String (Handler_Id));
                           Item.Color_Name                := Handler_Color;
                           Item.W                         := Handler_Width;
                           Item.H                         := Handler_Height;
                           if ME_Event_Handler_Ref (Item).Han /= null then
                              Mast_Editor.Event_Handlers.Lists.Add
                                (ME_Event_Handler_Ref (Item),
                                 Editor_System.Me_Event_Handlers);
                              Put_Item_In_Canvas (Item);
                              -- We draw the arrows from input event and
                              -- towards output event Input Link
                              Lin_Ref :=
                                Mast.Graphs.Event_Handlers.Input_Link
                                (
                                 Mast.Graphs.Event_Handlers.
                                 Simple_Event_Handler
                                 (ME_Event_Handler_Ref (Item).Han.all));
                              if Lin_Ref /= null then
                                 begin
                                    Me_Lin_Iter :=
                                      Mast_Editor.Links.Lists.Find
                                      (Name (Lin_Ref) &
                                       Delimiter &
                                       Tran_Name,
                                       Editor_System.Me_Links);
                                    Me_Lin_Ref  :=
                                      Mast_Editor.Links.Lists.Item
                                      (Me_Lin_Iter,
                                       Editor_System.Me_Links);
                                    if Me_Lin_Ref /= null
                                      and then ME_Event_Handler_Ref (Item).
                                      ME_Tran /=
                                      null
                                    then
                                       Add_Canvas_Link
                                         (ME_Event_Handler_Ref (Item).ME_Tran.
                                          Dialog.Trans_Canvas,
                                          Me_Lin_Ref,
                                          Item);
                                       Refresh_Canvas
                                         (ME_Event_Handler_Ref (Item).ME_Tran.
                                          Dialog.Trans_Canvas);
                                    end if;
                                 exception
                                    when Invalid_Index =>
                                       if Verbose then
                                          Put_Line("Error while reading "&
                                                   "editor info. "&
                                                   "Handler of transaction: "&
                                                   Tran_Name);
                                       end if;
                                 end;
                              end if;
                              -- Output Link
                              Lin_Ref :=
                                Mast.Graphs.Event_Handlers.Output_Link
                                (
                                 Mast.Graphs.Event_Handlers.
                                 Simple_Event_Handler
                                 (ME_Event_Handler_Ref (Item).Han.all));
                              if Lin_Ref /= null then
                                 begin
                                    Me_Lin_Iter :=
                                      Mast_Editor.Links.Lists.Find
                                      (Name (Lin_Ref) &
                                       Delimiter &
                                       Tran_Name,
                                       Editor_System.Me_Links);
                                    Me_Lin_Ref  :=
                                      Mast_Editor.Links.Lists.Item
                                      (Me_Lin_Iter,
                                       Editor_System.Me_Links);
                                    if Me_Lin_Ref /= null
                                      and then ME_Event_Handler_Ref (Item).
                                      ME_Tran /=
                                      null
                                    then
                                       Add_Canvas_Link
                                         (ME_Event_Handler_Ref (Item).ME_Tran.
                                          Dialog.Trans_Canvas,
                                          Item,
                                          Me_Lin_Ref);
                                       Refresh_Canvas
                                         (ME_Event_Handler_Ref (Item).ME_Tran.
                                          Dialog.Trans_Canvas);
                                    end if;
                                 exception
                                    when Invalid_Index =>
                                       if Verbose then
                                          Put_Line("Error while reading "&
                                                   "editor info. "&
                                                   "Handler of transaction: "&
                                                   Tran_Name);
                                       end if;
                                 end;
                              end if;
                           end if;
                        exception
                           when No_More_Items | Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Handler of transaction: "&
                                          Tran_Name);
                              end if;
                        end;
                     elsif Temp_Arguments (2) =
                       To_Var_String ("Me_Multi_Input_Event_Handler ")
                     then
                        Item := new ME_Multi_Input_Event_Handler;
                        Read_Common_Params (Item, Temp_Arguments);
                        Extract_Delimiter (Item.Name, Handler_Id, Tran_Name);
                        begin
                           Me_Tran_Iter                        :=
                             Mast_Editor.Transactions.Lists.Find
                             (Tran_Name,
                              Editor_System.Me_Transactions);
                           ME_Event_Handler_Ref (Item).ME_Tran :=
                             Mast_Editor.Transactions.Lists.Item
                             (Me_Tran_Iter,
                              Editor_System.Me_Transactions);
                           -- We travel through handler list of the
                           -- transaction, search for handler and assign
                           -- its value when found
                           if ME_Event_Handler_Ref (Item).ME_Tran.Tran /=
                             null
                           then
                              Mast.Transactions.Rewind_Event_Handlers
                                (ME_Event_Handler_Ref (Item).ME_Tran.Tran.all,
                                 Han_Iter);
                              for I in
                                1 ..
                                Positive'Value (To_String (Handler_Id))
                              loop
                                 Mast.Transactions.Get_Next_Event_Handler
                                   (ME_Event_Handler_Ref (Item).ME_Tran.Tran.
                                    all,
                                    Han_Ref,
                                    Han_Iter);
                              end loop;
                              ME_Event_Handler_Ref (Item).Han := Han_Ref;
                           end if;
                           ME_Event_Handler_Ref (Item).Id :=
                             Positive'Value (To_String (Handler_Id));
                           Item.Color_Name                := Handler_Color;
                           Item.W                         := Handler_Width;
                           Item.H                         := Handler_Height;
                           if ME_Event_Handler_Ref (Item).Han /= null then
                              Mast_Editor.Event_Handlers.Lists.Add
                                (ME_Event_Handler_Ref (Item),
                                 Editor_System.Me_Event_Handlers);
                              Put_Item_In_Canvas (Item);
                              -- We draw the arrows from input events and
                              -- towards output event Input Links
                              Mast.Graphs.Event_Handlers.Rewind_Input_Links
                                (Mast.Graphs.Event_Handlers.Input_Event_Handler
                                 (ME_Event_Handler_Ref (Item).Han.all),
                                 Link_Iter);
                              for I in
                                1 ..
                                Mast.Graphs.Event_Handlers.
                                Num_Of_Input_Links
                                (Mast.Graphs.Event_Handlers.
                                 Input_Event_Handler
                                 (ME_Event_Handler_Ref (Item).Han.all))
                              loop
                                 Mast.Graphs.Event_Handlers.
                                   Get_Next_Input_Link
                                   (Mast.Graphs.Event_Handlers.
                                    Input_Event_Handler
                                    (ME_Event_Handler_Ref (Item).Han.all),
                                    Lin_Ref,
                                    Link_Iter);
                                 begin
                                    Me_Lin_Iter :=
                                      Mast_Editor.Links.Lists.Find
                                      (Name (Lin_Ref) &
                                       Delimiter &
                                       Tran_Name,
                                       Editor_System.Me_Links);
                                    Me_Lin_Ref  :=
                                      Mast_Editor.Links.Lists.Item
                                      (Me_Lin_Iter,
                                       Editor_System.Me_Links);
                                    if Me_Lin_Ref /= null
                                      and then ME_Event_Handler_Ref (Item).
                                      ME_Tran /=
                                      null
                                    then
                                       Add_Canvas_Link
                                         (ME_Event_Handler_Ref (Item).ME_Tran.
                                          Dialog.Trans_Canvas,
                                          Me_Lin_Ref,
                                          Item);
                                       Refresh_Canvas
                                         (ME_Event_Handler_Ref (Item).ME_Tran.
                                          Dialog.Trans_Canvas);
                                    end if;
                                 exception
                                    when Invalid_Index =>
                                       if Verbose then
                                          Put_Line("Error while reading "&
                                                   "editor info. "&
                                                   "Handler of transaction: "&
                                                   Tran_Name);
                                       end if;
                                 end;
                              end loop;
                              -- Output Link
                              Lin_Ref :=
                                Mast.Graphs.Event_Handlers.Output_Link
                                (Mast.Graphs.Event_Handlers.Input_Event_Handler
                                 (ME_Event_Handler_Ref (Item).Han.all));
                              begin
                                 Me_Lin_Iter :=
                                   Mast_Editor.Links.Lists.Find
                                   (Name (Lin_Ref) &
                                    Delimiter &
                                    Tran_Name,
                                    Editor_System.Me_Links);
                                 Me_Lin_Ref  :=
                                   Mast_Editor.Links.Lists.Item
                                   (Me_Lin_Iter,
                                    Editor_System.Me_Links);
                                 if Me_Lin_Ref /= null
                                   and then ME_Event_Handler_Ref (Item).
                                   ME_Tran /=
                                   null
                                 then
                                    Add_Canvas_Link
                                      (ME_Event_Handler_Ref (Item).ME_Tran.
                                       Dialog.Trans_Canvas,
                                       Item,
                                       Me_Lin_Ref);
                                    Refresh_Canvas
                                      (ME_Event_Handler_Ref (Item).ME_Tran.
                                       Dialog.Trans_Canvas);
                                 end if;
                              exception
                                 when Invalid_Index =>
                                    if Verbose then
                                       Put_Line("Error while reading "&
                                                "editor info. "&
                                                "Handler of transaction: "&
                                                Tran_Name);
                                    end if;
                              end;
                           end if;

                        exception
                           when No_More_Items | Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading editor info. "&
                                          "Handler of transaction: "&
                                          Tran_Name);
                              end if;
                        end;
                     elsif Temp_Arguments (2) =
                       To_Var_String ("Me_Multi_Output_Event_Handler ")
                     then
                        Item := new ME_Multi_Output_Event_Handler;
                        Read_Common_Params (Item, Temp_Arguments);
                        Extract_Delimiter (Item.Name, Handler_Id, Tran_Name);
                        begin
                           Me_Tran_Iter                        :=
                             Mast_Editor.Transactions.Lists.Find
                             (Tran_Name,
                              Editor_System.Me_Transactions);
                           ME_Event_Handler_Ref (Item).ME_Tran :=
                             Mast_Editor.Transactions.Lists.Item
                             (Me_Tran_Iter,
                              Editor_System.Me_Transactions);
                           -- We travel through handler list of the
                           -- transaction, search for handler and assign
                           -- its value when found
                           if ME_Event_Handler_Ref (Item).ME_Tran.Tran /=
                             null
                           then
                              Mast.Transactions.Rewind_Event_Handlers
                                (ME_Event_Handler_Ref (Item).ME_Tran.Tran.all,
                                 Han_Iter);
                              for I in
                                1 ..
                                Positive'Value (To_String (Handler_Id))
                              loop
                                 Mast.Transactions.Get_Next_Event_Handler
                                   (ME_Event_Handler_Ref (Item).ME_Tran.Tran.
                                    all,
                                    Han_Ref,
                                    Han_Iter);
                              end loop;
                              ME_Event_Handler_Ref (Item).Han := Han_Ref;
                           end if;
                           ME_Event_Handler_Ref (Item).Id :=
                             Positive'Value (To_String (Handler_Id));
                           Item.Color_Name                := Handler_Color;
                           Item.W                         := Handler_Width;
                           Item.H                         := Handler_Height;
                           if ME_Event_Handler_Ref (Item).Han /= null then
                              Mast_Editor.Event_Handlers.Lists.Add
                                (ME_Event_Handler_Ref (Item),
                                 Editor_System.Me_Event_Handlers);
                              Put_Item_In_Canvas (Item);
                              -- We draw the arrows from input event and
                              -- towards output events Input Link
                              Lin_Ref :=
                                Mast.Graphs.Event_Handlers.Input_Link
                                (
                                 Mast.Graphs.Event_Handlers.
                                 Output_Event_Handler
                                 (ME_Event_Handler_Ref (Item).Han.all));
                              begin
                                 Me_Lin_Iter :=
                                   Mast_Editor.Links.Lists.Find
                                   (Name (Lin_Ref) &
                                    Delimiter &
                                    Tran_Name,
                                    Editor_System.Me_Links);
                                 Me_Lin_Ref  :=
                                   Mast_Editor.Links.Lists.Item
                                   (Me_Lin_Iter,
                                    Editor_System.Me_Links);
                                 if Me_Lin_Ref /= null
                                   and then ME_Event_Handler_Ref (Item).
                                   ME_Tran /=
                                   null
                                 then
                                    Add_Canvas_Link
                                      (ME_Event_Handler_Ref (Item).ME_Tran.
                                       Dialog.Trans_Canvas,
                                       Me_Lin_Ref,
                                       Item);
                                    Refresh_Canvas
                                      (ME_Event_Handler_Ref (Item).ME_Tran.
                                       Dialog.Trans_Canvas);
                                 end if;
                              exception
                                 when Invalid_Index =>
                                    if Verbose then
                                       Put_Line("Error while reading "&
                                                "editor info. "&
                                                "Handler of transaction: "&
                                                Tran_Name);
                                    end if;
                              end;
                              -- Output Links
                              Mast.Graphs.Event_Handlers.Rewind_Output_Links
                                (
                                 Mast.Graphs.Event_Handlers.
                                 Output_Event_Handler
                                 (ME_Event_Handler_Ref (Item).Han.all),
                                 Link_Iter);
                              for I in
                                1 ..
                                Mast.Graphs.Event_Handlers.
                                Num_Of_Output_Links
                                (Mast.Graphs.Event_Handlers.
                                 Output_Event_Handler
                                 (ME_Event_Handler_Ref (Item).Han.all))
                              loop
                                 Mast.Graphs.Event_Handlers.
                                   Get_Next_Output_Link
                                   (Mast.Graphs.Event_Handlers.
                                    Output_Event_Handler
                                    (ME_Event_Handler_Ref (Item).Han.all),
                                    Lin_Ref,
                                    Link_Iter);
                                 begin
                                    Me_Lin_Iter :=
                                      Mast_Editor.Links.Lists.Find
                                      (Name (Lin_Ref) &
                                       Delimiter &
                                       Tran_Name,
                                       Editor_System.Me_Links);
                                    Me_Lin_Ref  :=
                                      Mast_Editor.Links.Lists.Item
                                      (Me_Lin_Iter,
                                       Editor_System.Me_Links);
                                    if Me_Lin_Ref /= null
                                      and then ME_Event_Handler_Ref (Item).
                                      ME_Tran /=
                                      null
                                    then
                                       Add_Canvas_Link
                                         (ME_Event_Handler_Ref (Item).ME_Tran.
                                          Dialog.Trans_Canvas,
                                          Item,
                                          Me_Lin_Ref);
                                       Refresh_Canvas
                                         (ME_Event_Handler_Ref (Item).ME_Tran.
                                          Dialog.Trans_Canvas);
                                    end if;
                                 exception
                                    when Invalid_Index =>
                                       if Verbose then
                                          Put_Line("Error while reading "&
                                                   "editor info. "&
                                                   "Handler of transaction: "&
                                                   Tran_Name);
                                       end if;
                                 end;
                              end loop;
                           end if;
                        exception
                           when No_More_Items | Invalid_Index =>
                              if Verbose then
                                 Put_Line("Error while reading "&
                                          "editor info. "&
                                          "Handler of transaction: "&
                                          Tran_Name);
                              end if;
                        end;
                     end if;
                     -------- End of Event Handlers Search
                  else
                     Put_Line
                       ("Error while reading from editor file at line" &
                        Integer'Image (N_Linea));
                  end if;
               else
                  Put_Line
                    ("Editor Input File has unrecognizable format: " &
                     "Line" &
                     Integer'Image (N_Linea));
               end if;
               N_Linea := N_Linea + 1;
               Linea   := String'(1 .. 150 => ' ');
            end if;
         exception
            when Already_Exists =>  -- raised while trying to add item
                                    --to editor system
               if Verbose then
                  Put_Line
                    ("Can't add item to editor system: the item at Line" &
                     Integer'Image (N_Linea) &
                     " already exists");
                  N_Linea := N_Linea + 1;
                  Linea   := String'(1 .. 150 => ' ');
               end if;
         end;
         Editor_System_Present := True;
      end loop;

      -- This loop is executed to draw the arrows from secondary schedulers
      -- to servers, since the order they are writen to editor file does not
      -- allow us to seek servers assigned to secondary schedulers before
      -- all servers lines are read.

      Mast_Editor.Schedulers.Lists.Rewind
        (Editor_System.Me_Schedulers,
         Me_Sche_Iter);
      for I in
        1 ..
        Mast_Editor.Schedulers.Lists.Size (Editor_System.Me_Schedulers)
      loop
         Mast_Editor.Schedulers.Lists.Get_Next_Item
           (Me_Sche_Ref,
            Editor_System.Me_Schedulers,
            Me_Sche_Iter);
         if Me_Sche_Ref.all'Tag =
           Mast_Editor.Schedulers.ME_Secondary_Scheduler'Tag
         then
            Mast_Editor.Schedulers.Draw_Scheduler_Server (Me_Sche_Ref);
         end if;
      end loop;

      Close (Fich);

      Free (Current_Filename);
      Current_Filename := new String'(Name_Of_System); -- raises No_System
      Set_Window_Title;
   exception
      when No_System =>
         Set_Window_Title;
      when others =>
         Close (Fich);
         Ada.Text_IO.Set_Input (Standard_Input);
         Editor_System_Present := False;
         raise;
   end Read_Editor_System;

   --------------------------
   -- Draw_TXT_File_System --
   --------------------------

   procedure Draw_TXT_File_System
     (TXT_File_System : Mast.Systems.System := The_System;
      MSS_File_Exists : Boolean             := False)
   is
      Proc_Iter  : Mast.Processing_Resources.Lists.Iteration_Object;
      Share_Iter : Mast.Shared_Resources.Lists.Iteration_Object;
      Sche_Iter  : Mast.Schedulers.Lists.Iteration_Object;
      Op_Iter    : Mast.Operations.Lists.Iteration_Object;
      Ser_Iter   : Mast.Scheduling_Servers.Lists.Iteration_Object;
      Tran_Iter  : Mast.Transactions.Lists.Iteration_Object;

      Proc_Ref  : Mast.Processing_Resources.Processing_Resource_Ref;
      Share_Ref : Mast.Shared_Resources.Shared_Resource_Ref;
      Sche_Ref  : Mast.Schedulers.Scheduler_Ref;
      Op_Ref    : Mast.Operations.Operation_Ref;
      Ser_Ref   : Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Tran_Ref  : Mast.Transactions.Transaction_Ref;

      Me_Proc_Iter  : Mast_Editor.Processing_Resources.Lists.Iteration_Object;
      Me_Share_Iter : Mast_Editor.Shared_Resources.Lists.Iteration_Object;
      Me_Sche_Iter  : Mast_Editor.Schedulers.Lists.Iteration_Object;
      Me_Op_Iter    : Mast_Editor.Operations.Lists.Iteration_Object;
      Me_Ser_Iter   : Mast_Editor.Scheduling_Servers.Lists.Iteration_Object;
      Me_Tran_Iter  : Mast_Editor.Transactions.Lists.Iteration_Object;

      Me_Proc_Ref  :
        Mast_Editor.Processing_Resources.ME_Processing_Resource_Ref;
      Me_Share_Ref : Mast_Editor.Shared_Resources.ME_Shared_Resource_Ref;
      Me_Sche_Ref  : Mast_Editor.Schedulers.ME_Scheduler_Ref;
      Me_Op_Ref    : Mast_Editor.Operations.ME_Operation_Ref;
      Me_Ser_Ref   : Mast_Editor.Scheduling_Servers.ME_Scheduling_Server_Ref;
      Me_Tran_Ref  : Mast_Editor.Transactions.ME_Transaction_Ref;

      Item : ME_Object_Ref;
   begin
      if Has_System then
         ------------------------
         -- Processing Resources
         ------------------------
         Mast.Processing_Resources.Lists.Rewind
           (TXT_File_System.Processing_Resources,
            Proc_Iter);
         for I in
           1 ..
           Mast.Processing_Resources.Lists.Size
           (TXT_File_System.Processing_Resources)
         loop
            Mast.Processing_Resources.Lists.Get_Next_Item
              (Proc_Ref,
               TXT_File_System.Processing_Resources,
               Proc_Iter);
            if Proc_Ref.all'Tag =
              Mast.Processing_Resources.Processor.Regular_Processor'Tag
            then
               Item                                  :=
                 new ME_Regular_Processor;
               ME_Processing_Resource_Ref (Item).Res := Proc_Ref;
               Item.Color_Name                       := Proc_Color;
               Item.W                                := Proc_Width;
               Item.H                                := Proc_Height;
               Item.Canvas_Name                      :=
                 To_Var_String ("Proc_Res_Canvas");
               begin
                  Mast_Editor.Processing_Resources.Lists.Add
                    (ME_Processing_Resource_Ref (Item),
                     Editor_System.Me_Processing_Resources);
                  Put_TXT_Item (Proc_Res_Canvas, Item);
                  Mast_Editor.Processing_Resources.Draw_Timer_In_Proc_Canvas
                    (ME_Processing_Resource_Ref (Item));
               exception
                  when Already_Exists =>
                     null; -- nothing to do if object exists
               end;
            elsif Proc_Ref.all'Tag =
              Mast.Processing_Resources.Network.Packet_Based_Network'Tag
            then
               Item                                  :=
                 new ME_Packet_Based_Network;
               ME_Processing_Resource_Ref (Item).Res := Proc_Ref;
               Item.Color_Name                       := Net_Color;
               Item.W                                := Net_Width;
               Item.H                                := Net_Height;
               Item.Canvas_Name                      :=
                 To_Var_String ("Proc_Res_Canvas");
               begin
                  Mast_Editor.Processing_Resources.Lists.Add
                    (ME_Processing_Resource_Ref (Item),
                     Editor_System.Me_Processing_Resources);
                  Put_TXT_Item (Proc_Res_Canvas, Item);
                  Mast_Editor.Processing_Resources.Draw_Drivers_In_Proc_Canvas
                    (ME_Processing_Resource_Ref (Item));
               exception
                  when Already_Exists =>
                     null; -- nothing to do if object exists
               end;
            end if;
         end loop;

         ------------------------
         -- Schedulers
         ------------------------
         Mast.Schedulers.Lists.Rewind (TXT_File_System.Schedulers, Sche_Iter);
         for I in
           1 .. Mast.Schedulers.Lists.Size (TXT_File_System.Schedulers)
         loop
            Mast.Schedulers.Lists.Get_Next_Item
              (Sche_Ref,
               TXT_File_System.Schedulers,
               Sche_Iter);
            if Sche_Ref.all'Tag =
              Mast.Schedulers.Primary.Primary_Scheduler'Tag
            then
               Item                         := new ME_Primary_Scheduler;
               ME_Scheduler_Ref (Item).Sche := Sche_Ref;
               Item.Color_Name              := Prime_Color;
               Item.W                       := Sche_Width;
               Item.H                       := Sche_Height;
               Item.Canvas_Name             :=
                 To_Var_String ("Proc_Res_Canvas");
               begin
                  Mast_Editor.Schedulers.Lists.Add
                    (ME_Scheduler_Ref (Item),
                     Editor_System.Me_Schedulers);
                  Put_TXT_Item (Proc_Res_Canvas, Item);
                  Mast_Editor.Schedulers.Draw_Scheduler_Host
                    (ME_Scheduler_Ref (Item));
               exception
                  when Already_Exists =>
                     null; -- nothing to do if object exists
               end;
            elsif Sche_Ref.all'Tag =
              Mast.Schedulers.Secondary.Secondary_Scheduler'Tag
            then
               Item                         := new ME_Secondary_Scheduler;
               ME_Scheduler_Ref (Item).Sche := Sche_Ref;
               Item.Color_Name              := Second_Color;
               Item.W                       := Sche_Width;
               Item.H                       := Sche_Height;
               Item.Canvas_Name             :=
                 To_Var_String ("Proc_Res_Canvas");
               begin
                  Mast_Editor.Schedulers.Lists.Add
                    (ME_Scheduler_Ref (Item),
                     Editor_System.Me_Schedulers);
                  Put_TXT_Item (Proc_Res_Canvas, Item);
                  Mast_Editor.Schedulers.Draw_Scheduler_Server
                    (ME_Scheduler_Ref (Item));
               exception
                  when Already_Exists =>
                     null; -- nothing to do if object exists
               end;
            end if;
         end loop;

         ------------------------
         -- Shared Resources
         ------------------------
         Mast.Shared_Resources.Lists.Rewind
           (TXT_File_System.Shared_Resources,
            Share_Iter);
         for I in
           1 ..
           Mast.Shared_Resources.Lists.Size
           (TXT_File_System.Shared_Resources)
         loop
            Mast.Shared_Resources.Lists.Get_Next_Item
              (Share_Ref,
               TXT_File_System.Shared_Resources,
               Share_Iter);
            if Share_Ref.all'Tag =
              Mast.Shared_Resources.Priority_Inheritance_Resource'Tag
            then
               Item                                :=
                 new ME_Priority_Inheritance_Resource;
               ME_Shared_Resource_Ref (Item).Share := Share_Ref;
            elsif Share_Ref.all'Tag =
              Mast.Shared_Resources.Immediate_Ceiling_Resource'Tag
            then
               Item                                :=
                 new ME_Immediate_Ceiling_Resource;
               ME_Shared_Resource_Ref (Item).Share := Share_Ref;
            elsif Share_Ref.all'Tag =
              Mast.Shared_Resources.SRP_Resource'Tag
            then
               Item                                := new ME_SRP_Resource;
               ME_Shared_Resource_Ref (Item).Share := Share_Ref;
            end if;
            Item.Color_Name  := Share_Color;
            Item.W           := Share_Width;
            Item.H           := Share_Height;
            Item.Canvas_Name := To_Var_String ("Shared_Res_Canvas");
            begin
               Mast_Editor.Shared_Resources.Lists.Add
                 (ME_Shared_Resource_Ref (Item),
                  Editor_System.Me_Shared_Resources);
               Put_TXT_Item (Shared_Res_Canvas, Item);
            exception
               when Already_Exists =>
                  null; -- nothing to do if object exists
            end;
         end loop;

         ------------------------
         -- Operations
         ------------------------
         Mast.Operations.Lists.Rewind (TXT_File_System.Operations, Op_Iter);
         for I in
           1 .. Mast.Operations.Lists.Size (TXT_File_System.Operations)
         loop
            Mast.Operations.Lists.Get_Next_Item
              (Op_Ref,
               TXT_File_System.Operations,
               Op_Iter);
            if Op_Ref.all'Tag = Mast.Operations.Simple_Operation'Tag then
               Item                       := new ME_Simple_Operation;
               ME_Operation_Ref (Item).Op := Op_Ref;
               Item.Color_Name            := Sop_Color;
               Item.W                     := Op_Width;
               Item.H                     := Op_Height;
               Item.Canvas_Name           :=
                 To_Var_String ("Operation_Canvas");
               begin
                  Mast_Editor.Operations.Lists.Add
                    (ME_Operation_Ref (Item),
                     Editor_System.Me_Operations);
                  Put_TXT_Item (Operation_Canvas, Item);
               exception
                  when Already_Exists =>
                     null; -- nothing to do if object exists
               end;
            elsif Op_Ref.all'Tag =
              Mast.Operations.Composite_Operation'Tag
            then
               Item                       := new ME_Composite_Operation;
               ME_Operation_Ref (Item).Op := Op_Ref;
               Item.Color_Name            := Cop_Color;
               Item.W                     := Op_Width;
               Item.H                     := Op_Height;
               Item.Canvas_Name           :=
                 To_Var_String ("Operation_Canvas");
               begin
                  Mast_Editor.Operations.Lists.Add
                    (ME_Operation_Ref (Item),
                     Editor_System.Me_Operations);
                  Put_TXT_Item (Operation_Canvas, Item);
                  Mast_Editor.Operations.Draw_Composite_Operation_Links
                    (ME_Operation_Ref (Item));
               exception
                  when Already_Exists =>
                     null; -- nothing to do if object exists
               end;
            elsif Op_Ref.all'Tag =
              Mast.Operations.Enclosing_Operation'Tag
            then
               Item                       := new ME_Composite_Operation;
               ME_Operation_Ref (Item).Op := Op_Ref;
               Item.Color_Name            := Cop_Color;
               Item.W                     := Op_Width;
               Item.H                     := Op_Height;
               Item.Canvas_Name           :=
                 To_Var_String ("Operation_Canvas");
               begin
                  Mast_Editor.Operations.Lists.Add
                    (ME_Operation_Ref (Item),
                     Editor_System.Me_Operations);
                  Put_TXT_Item (Operation_Canvas, Item);
                  Mast_Editor.Operations.Draw_Composite_Operation_Links
                    (ME_Operation_Ref (Item));
               exception
                  when Already_Exists =>
                     null; -- nothing to do if object exists
               end;
            elsif Op_Ref.all'Tag =
              Mast.Operations.Message_Transmission_Operation'Tag
            then
               Item                       :=
                 new Me_Message_Transmission_Operation;
               ME_Operation_Ref (Item).Op := Op_Ref;
               Item.Color_Name            := Txop_Color;
               Item.W                     := Op_Width;
               Item.H                     := Op_Height;
               Item.Canvas_Name           :=
                 To_Var_String ("Operation_Canvas");
               begin
                  Mast_Editor.Operations.Lists.Add
                    (ME_Operation_Ref (Item),
                     Editor_System.Me_Operations);
                  Put_TXT_Item (Operation_Canvas, Item);
               exception
                  when Already_Exists =>
                     null; -- nothing to do if object exists
               end;
            end if;
         end loop;

         ------------------------
         -- Scheduling Servers
         ------------------------
         Mast.Scheduling_Servers.Lists.Rewind
           (TXT_File_System.Scheduling_Servers,
            Ser_Iter);
         for I in
           1 ..
           Mast.Scheduling_Servers.Lists.Size
           (TXT_File_System.Scheduling_Servers)
         loop
            Mast.Scheduling_Servers.Lists.Get_Next_Item
              (Ser_Ref,
               TXT_File_System.Scheduling_Servers,
               Ser_Iter);
            if Ser_Ref.all'Tag =
              Mast.Scheduling_Servers.Scheduling_Server'Tag
            then
               Item                                := new ME_Server;
               ME_Scheduling_Server_Ref (Item).Ser := Ser_Ref;
            end if;
            Item.Color_Name  := Ser_Color;
            Item.W           := Ser_Width;
            Item.H           := Ser_Height;
            Item.Canvas_Name := To_Var_String ("Sched_Server_Canvas");
            begin
               Mast_Editor.Scheduling_Servers.Lists.Add
                 (ME_Scheduling_Server_Ref (Item),
                  Editor_System.Me_Scheduling_Servers);
               Put_TXT_Item (Sched_Server_Canvas, Item);
               Mast_Editor.Scheduling_Servers.Draw_Scheduler_In_Server_Canvas
                 (ME_Scheduling_Server_Ref (Item));
            exception
               when Already_Exists =>
                  null; -- nothing to do if object exists
            end;
         end loop;

         ------------------------
         -- Transactions
         ------------------------
         Mast.Transactions.Lists.Rewind
           (TXT_File_System.Transactions,
            Tran_Iter);
         for I in
           1 ..
           Mast.Transactions.Lists.Size (TXT_File_System.Transactions)
         loop
            Mast.Transactions.Lists.Get_Next_Item
              (Tran_Ref,
               TXT_File_System.Transactions,
               Tran_Iter);
            if Tran_Ref.all'Tag =
              Mast.Transactions.Regular_Transaction'Tag
            then
               Item                           := new ME_Regular_Transaction;
               ME_Transaction_Ref (Item).Tran := Tran_Ref;
            end if;
            Item.Color_Name  := Tran_Color;
            Item.W           := Tran_Width;
            Item.H           := Tran_Height;
            Item.Canvas_Name := To_Var_String ("Transaction_Canvas");
            Gtk_New (ME_Transaction_Ref (Item).Dialog);
            -- We should connect dialog's right buttons signals
            Button_Cb.Connect
              (ME_Transaction_Ref (Item).Dialog.Add_Ext_Button,
               "clicked",
               Button_Cb.To_Marshaller
               (Mast_Editor.Links.Show_External_Dialog'Access),
               ME_Transaction_Ref (Item));
            Button_Cb.Connect
              (ME_Transaction_Ref (Item).Dialog.Add_Int_Button,
               "clicked",
               Button_Cb.To_Marshaller
               (Mast_Editor.Links.Show_Internal_Dialog'Access),
               ME_Transaction_Ref (Item));
            Button_Cb.Connect
              (ME_Transaction_Ref (Item).Dialog.Add_Simple_Button,
               "clicked",
               Button_Cb.To_Marshaller
               (Mast_Editor.Event_Handlers.Show_Simple_Event_Handler_Dialog'
                Access),
               ME_Transaction_Ref (Item));
            Button_Cb.Connect
              (ME_Transaction_Ref (Item).Dialog.Add_Minput_Button,
               "clicked",
               Button_Cb.To_Marshaller
               (Mast_Editor.Event_Handlers.
                Show_Multi_Input_Event_Handler_Dialog'Access),
               ME_Transaction_Ref (Item));
            Button_Cb.Connect
              (ME_Transaction_Ref (Item).Dialog.Add_Moutput_Button,
               "clicked",
               Button_Cb.To_Marshaller
               (
                Mast_Editor.Event_Handlers.
                Show_Multi_Output_Event_Handler_Dialog'Access),
               ME_Transaction_Ref (Item));

            begin
               Mast_Editor.Transactions.Lists.Add
                 (ME_Transaction_Ref (Item),
                  Editor_System.Me_Transactions);
               -- Draw events and event handlers in transaction dialog
               Mast_Editor.Transactions.Draw_External_Events_In_Tran_Canvas
                 (ME_Transaction_Ref (Item));
               Mast_Editor.Transactions.Draw_Internal_Events_In_Tran_Canvas
                 (ME_Transaction_Ref (Item));
               Mast_Editor.Transactions.Draw_Event_Handlers_In_Tran_Canvas
                 (ME_Transaction_Ref (Item));
               Refresh_Canvas (ME_Transaction_Ref (Item).Dialog.Trans_Canvas);
               -- Redraw graphs of the transaction
               Show_TXT_Graphs
                 (ME_Transaction_Ref (Item).Dialog.Trans_Canvas);
               -- Put Item in Transaction_Canvas
               Put_TXT_Item (Transaction_Canvas, Item);
            exception
               when Already_Exists =>
                  Me_Tran_Iter :=
                    Mast_Editor.Transactions.Lists.Find
                    (Name (Tran_Ref),
                     Editor_System.Me_Transactions);
                  Me_Tran_Ref  :=
                    Mast_Editor.Transactions.Lists.Item
                    (Me_Tran_Iter,
                     Editor_System.Me_Transactions);

                  Mast_Editor.Transactions.Draw_External_Events_In_Tran_Canvas
                    (Me_Tran_Ref,
                     True);
                  Mast_Editor.Transactions.Draw_Internal_Events_In_Tran_Canvas
                    (Me_Tran_Ref,
                     True);
                  Mast_Editor.Transactions.Draw_Event_Handlers_In_Tran_Canvas
                    (Me_Tran_Ref,
                     True);
                  Refresh_Canvas (Me_Tran_Ref.Dialog.Trans_Canvas);
                  Show_TXT_Graphs (Me_Tran_Ref.Dialog.Trans_Canvas);

            end;
         end loop;

         if not MSS_File_Exists then
            Show_TXT_Items (Proc_Res_Canvas);
            Show_TXT_Items (Sched_Server_Canvas);
            Show_TXT_Items (Shared_Res_Canvas);
            Show_TXT_Items (Operation_Canvas);
            Show_TXT_Items (Transaction_Canvas);
         else
            -- Refresh Processing Resources arrows towards Timers and Drivers
            Mast_Editor.Processing_Resources.Lists.Rewind
              (Editor_System.Me_Processing_Resources,
               Me_Proc_Iter);
            for I in
              1 ..
              Mast_Editor.Processing_Resources.Lists.Size
              (Editor_System.Me_Processing_Resources)
            loop
               Mast_Editor.Processing_Resources.Lists.Get_Next_Item
                 (Me_Proc_Ref,
                  Editor_System.Me_Processing_Resources,
                  Me_Proc_Iter);
               if Me_Proc_Ref.all'Tag =
                 Mast_Editor.Processing_Resources.ME_Regular_Processor'Tag
               then
                  Mast_Editor.Processing_Resources.Draw_Timer_In_Proc_Canvas
                    (Me_Proc_Ref);
               elsif Proc_Ref.all'Tag =
                 Mast.Processing_Resources.Network.Packet_Based_Network'
                 Tag
               then
                  Mast_Editor.Processing_Resources.Draw_Drivers_In_Proc_Canvas
                    (Me_Proc_Ref);
               end if;
            end loop;
            -- Refresh Schedulers arrows towards Hosts and Servers
            Mast_Editor.Schedulers.Lists.Rewind
              (Editor_System.Me_Schedulers,
               Me_Sche_Iter);
            for I in
              1 ..
              Mast_Editor.Schedulers.Lists.Size
              (Editor_System.Me_Schedulers)
            loop
               Mast_Editor.Schedulers.Lists.Get_Next_Item
                 (Me_Sche_Ref,
                  Editor_System.Me_Schedulers,
                  Me_Sche_Iter);
               if Me_Sche_Ref.all'Tag =
                 Mast_Editor.Schedulers.ME_Primary_Scheduler'Tag
               then
                  Mast_Editor.Schedulers.Draw_Scheduler_Host (Me_Sche_Ref);
               elsif Me_Sche_Ref.all'Tag =
                 Mast_Editor.Schedulers.ME_Secondary_Scheduler'Tag
               then
                  Mast_Editor.Schedulers.Draw_Scheduler_Server (Me_Sche_Ref);
               end if;
            end loop;
            Mast_Editor.Schedulers.Lists.Rewind
              (Editor_System.Me_Schedulers_In_Server_Canvas,
               Me_Sche_Iter);
            for I in
              1 ..
              Mast_Editor.Schedulers.Lists.Size
              (Editor_System.Me_Schedulers_In_Server_Canvas)
            loop
               Mast_Editor.Schedulers.Lists.Get_Next_Item
                 (Me_Sche_Ref,
                  Editor_System.Me_Schedulers_In_Server_Canvas,
                  Me_Sche_Iter);
               if Me_Sche_Ref.all'Tag =
                 Mast_Editor.Schedulers.ME_Primary_Scheduler'Tag
               then
                  Mast_Editor.Schedulers.Draw_Scheduler_Host (Me_Sche_Ref);
               elsif Me_Sche_Ref.all'Tag =
                 Mast_Editor.Schedulers.ME_Secondary_Scheduler'Tag
               then
                  Mast_Editor.Schedulers.Draw_Scheduler_Server (Me_Sche_Ref);
               end if;
            end loop;
            -- Refresh Composite Op arrows towards the ones they contain
            Mast_Editor.Operations.Lists.Rewind
              (Editor_System.Me_Operations,
               Me_Op_Iter);
            for I in
              1 ..
              Mast_Editor.Operations.Lists.Size
              (Editor_System.Me_Operations)
            loop
               Mast_Editor.Operations.Lists.Get_Next_Item
                 (Me_Op_Ref,
                  Editor_System.Me_Operations,
                  Me_Op_Iter);
               if Me_Op_Ref.all'Tag =
                 Mast_Editor.Operations.ME_Composite_Operation'Tag
               then
                  Mast_Editor.Operations.Draw_Composite_Operation_Links
                    (Me_Op_Ref);
               end if;
            end loop;
         end if;

         Gtk.Adjustment.Set_Value
           (Get_Vadj (Proc_Res_Canvas),
            Get_Lower (Get_Vadj (Proc_Res_Canvas)));
         Gtk.Adjustment.Set_Value
           (Get_Hadj (Proc_Res_Canvas),
            Get_Lower (Get_Hadj (Proc_Res_Canvas)));

         Gtk.Adjustment.Set_Value
           (Get_Vadj (Sched_Server_Canvas),
            Get_Lower (Get_Vadj (Sched_Server_Canvas)));
         Gtk.Adjustment.Set_Value
           (Get_Hadj (Sched_Server_Canvas),
            Get_Lower (Get_Hadj (Sched_Server_Canvas)));

         Gtk.Adjustment.Set_Value
           (Get_Vadj (Shared_Res_Canvas),
            Get_Lower (Get_Vadj (Shared_Res_Canvas)));
         Gtk.Adjustment.Set_Value
           (Get_Hadj (Shared_Res_Canvas),
            Get_Lower (Get_Hadj (Shared_Res_Canvas)));

         Gtk.Adjustment.Set_Value
           (Get_Vadj (Operation_Canvas),
            Get_Lower (Get_Vadj (Operation_Canvas)));
         Gtk.Adjustment.Set_Value
           (Get_Hadj (Operation_Canvas),
            Get_Lower (Get_Hadj (Operation_Canvas)));

         Gtk.Adjustment.Set_Value
           (Get_Vadj (Transaction_Canvas),
            Get_Lower (Get_Vadj (Transaction_Canvas)));
         Gtk.Adjustment.Set_Value
           (Get_Hadj (Transaction_Canvas),
            Get_Lower (Get_Hadj (Transaction_Canvas)));

      end if;
   end Draw_TXT_File_System;

end Editor_Actions;
