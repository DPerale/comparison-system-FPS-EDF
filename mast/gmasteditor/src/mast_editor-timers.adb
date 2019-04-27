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
with Ada.Text_IO;    use Ada.Text_IO;
with Gdk.Color;      use Gdk.Color;
with Gdk.Font;       use Gdk.Font;
with Gdk.Drawable;   use Gdk.Drawable;
with Gdk.Rectangle;  use Gdk.Rectangle;
with Gtk.Combo;      use Gtk.Combo;
with Gtk.GEntry;     use Gtk.GEntry;
with Gtk.Handlers;   use Gtk.Handlers;
with Gtk.Label;      use Gtk.Label;
with Gtk.Widget;     use Gtk.Widget;
with Pango.Font;     use Pango.Font;
with Gtkada.Dialogs; use Gtkada.Dialogs;

with Mast;                                use Mast;
with Mast.IO;                             use Mast.IO;
with Mast.Processing_Resources;           use Mast.Processing_Resources;
with Mast.Processing_Resources.Processor;
use Mast.Processing_Resources.Processor;
with Mast.Timers;                         use Mast.Timers;

with Mast_Editor.Processing_Resources; use Mast_Editor.Processing_Resources;
with Editor_Error_Window_Pkg;          use Editor_Error_Window_Pkg;
with Item_Menu_Pkg;                    use Item_Menu_Pkg;
with Timer_Dialog_Pkg;                 use Timer_Dialog_Pkg;
with Editor_Actions;                   use Editor_Actions;
with Change_Control;

package body Mast_Editor.Timers is

   package Button_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Timer_Ref);

   Zoom_Levels : constant array (Positive range <>) of Guint  :=
     (100,
      130,
      150);
   Font        : Pango_Font_Description;
   Font1       : Pango_Font_Description;

   -------------------------------------------------
   -- Types and packages used to handle dialogs info
   -------------------------------------------------

   type ME_Timer_And_Dialog is record
      It  : ME_Timer_Ref;
      Dia : Gtk_Dialog;
   end record;

   type ME_Timer_And_Dialog_Ref is access all ME_Timer_And_Dialog;

   package Me_Timer_And_Dialog_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Timer_And_Dialog_Ref);

   --------------
   -- Name     --
   --------------
   function Name (Item : in ME_Timer) return Var_String is
   begin
      return Name (Item.Proc);
   end Name;

   --------------
   -- Name     --
   --------------
   function Name (Item_Ref : in ME_Timer_Ref) return Var_String is
   begin
      return Name (Item_Ref.Proc);
   end Name;

   -----------------
   -- Print       --
   -----------------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Timer;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Ada.Text_IO.Set_Col (File, Ada.Text_IO.Count (Indentation));
      Ada.Text_IO.Put (File, "ME_Timer");
   end Print;

   -----------------
   -- Print       --
   -----------------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive)
   is
      Item_Ref : ME_Timer_Ref;
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
     (Item   : access ME_System_Timer;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Timer_Ref    : System_Timer_Ref                                  :=
        ME_Timer_Ref (Item).Tim;
      Timer_Dialog : Timer_Dialog_Access                               :=
         Timer_Dialog_Access (Dialog);
      Proc_Ref     : Mast.Processing_Resources.Processing_Resource_Ref :=
        Item.Proc;
   begin
      Change_Control.Changes_Made;
      if (Get_Text (Get_Entry (Timer_Dialog.System_Timer_Type_Combo)) =
          "Ticker")
      then
         Timer_Ref := new Ticker;
         Set_Worst_Overhead
           (Timer_Ref.all,
            Normalized_Execution_Time'Value
               (Get_Text (Timer_Dialog.Proc_Wor_Over_Entry)));
         Set_Avg_Overhead
           (Timer_Ref.all,
            Normalized_Execution_Time'Value
               (Get_Text (Timer_Dialog.Proc_Avg_Over_Entry)));
         Set_Best_Overhead
           (Timer_Ref.all,
            Normalized_Execution_Time'Value
               (Get_Text (Timer_Dialog.Proc_Bes_Over_Entry)));
         Set_Period
           (Ticker (Timer_Ref.all),
            Time'Value (Get_Text (Timer_Dialog.Proc_Period_Entry)));
      elsif (Get_Text (Get_Entry (Timer_Dialog.System_Timer_Type_Combo)) =
             "Alarm Clock")
      then
         Timer_Ref := new Alarm_Clock;
         Set_Worst_Overhead
           (Timer_Ref.all,
            Normalized_Execution_Time'Value
               (Get_Text (Timer_Dialog.Proc_Wor_Over_Entry)));
         Set_Avg_Overhead
           (Timer_Ref.all,
            Normalized_Execution_Time'Value
               (Get_Text (Timer_Dialog.Proc_Avg_Over_Entry)));
         Set_Best_Overhead
           (Timer_Ref.all,
            Normalized_Execution_Time'Value
               (Get_Text (Timer_Dialog.Proc_Bes_Over_Entry)));
      end if;
      if Proc_Ref /= null then
         Set_System_Timer (Regular_Processor (Proc_Ref.all), Timer_Ref);
      end if;
   end Write_Parameters;

   ---------------------
   -- Read Parameters --
   ---------------------
   procedure Read_Parameters
     (Item   : access ME_System_Timer;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Timer_Ref    : System_Timer_Ref    := Item.Tim;
      Timer_Dialog : Timer_Dialog_Access := Timer_Dialog_Access (Dialog);
   begin
      if Timer_Ref /= null then
         Set_Text
           (Timer_Dialog.Proc_Wor_Over_Entry,
            Execution_Time_Image (Worst_Overhead (Timer_Ref.all)));
         Set_Text
           (Timer_Dialog.Proc_Avg_Over_Entry,
            Execution_Time_Image (Avg_Overhead (Timer_Ref.all)));
         Set_Text
           (Timer_Dialog.Proc_Bes_Over_Entry,
            Execution_Time_Image (Best_Overhead (Timer_Ref.all)));
         if Timer_Ref.all in Ticker then
            Set_Text
              (Get_Entry (Timer_Dialog.System_Timer_Type_Combo),
               "Ticker");
            Set_Text
              (Timer_Dialog.Proc_Period_Entry,
               Time_Image (Period (Ticker (Timer_Ref.all))));
            Show_All (Timer_Dialog);
         elsif Timer_Ref.all in Alarm_Clock then
            Set_Text
              (Get_Entry (Timer_Dialog.System_Timer_Type_Combo),
               "Alarm Clock");
            Show_All (Timer_Dialog);
            Hide (Timer_Dialog.Proc_Period_Label);
            Hide (Timer_Dialog.Proc_Period_Entry);
         end if;
      end if;
   end Read_Parameters;

   -----------------
   -- Draw Timer  --
   -----------------
   procedure Draw
     (Item         : access ME_System_Timer;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint)
   is
      Rect     : constant Gdk_Rectangle       := Get_Coord (Item);
      W        : constant Gint                :=
         To_Canvas_Coordinates (Canvas, Rect.Width);
      H        : constant Gint                :=
         To_Canvas_Coordinates (Canvas, Rect.Height);
      Time_Ref : Mast.Timers.System_Timer_Ref := Item.Tim;
      Color    : Gdk.Color.Gdk_Color;
   begin
      Editor_Actions.Load_System_Font (Font1, Font);
      Color := Parse (To_String (ME_Timer_Ref (Item).Color_Name));
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
      if Get_Zoom (Canvas) = Zoom_Levels (1) then
         if Time_Ref /= null then
            if Time_Ref.all in Ticker then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 4,
                  Ydest + 2 * H / 3,
                  Text => "TICKER");
            else
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 15,
                  Ydest + 2 * H / 3,
                  Text => "ALARM CLOCK");
            end if;
         end if;
      elsif Get_Zoom (Canvas) = Zoom_Levels (2) then
         if Time_Ref /= null then
            if Time_Ref.all in Ticker then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 3,
                  Ydest + 2 * H / 3,
                  Text => "TICKER");
            else
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 6,
                  Ydest + 2 * H / 3,
                  Text => "ALARM CLOCK");
            end if;
         end if;
      else
         if Time_Ref /= null then
            if Time_Ref.all in Ticker then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + 4 * W / 10,
                  Ydest + 2 * H / 3,
                  Text => "TICKER");
            else
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font),
                  GC,
                  Xdest + W / 4,
                  Ydest + 2 * H / 3,
                  Text => "ALARM CLOCK");
            end if;
         end if;
      end if;
   end Draw;

   ------------------
   -- Write Timer -- (Write the params of an existing timer and refresh the
   --canvas)
   ------------------
   procedure Write_Timer
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Timer_And_Dialog_Ref)
   is
      Item         : ME_Timer_Ref        := Data.It;
      Timer_Dialog : Timer_Dialog_Access := Timer_Dialog_Access (Data.Dia);
   begin
      Write_Parameters (Item, Gtk_Dialog (Timer_Dialog));
      Refresh_Canvas (Proc_Res_Canvas);
      Destroy (Timer_Dialog);
   exception
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Invalid Value !!!");
         Show_All (Editor_Error_Window);
         Destroy (Timer_Dialog);
   end Write_Timer;

   ------------------
   -- Remove_Timer --
   ------------------
   procedure Remove_Timer
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Timer_Ref)
   is
      Timer_Name        : Var_String;
      Me_Timer_Iterator : Mast_Editor.Timers.Lists.Iteration_Object;
      Me_Timer_Ref      : Mast_Editor.Timers.ME_Timer_Ref;
      Proc_Ref          : Mast.Processing_Resources.Processing_Resource_Ref :=
        Item.Proc;
   begin
      if Message_Dialog
            (" Do you really want to remove this object? ",
             Confirmation,
             Button_Yes or Button_No,
             Button_Yes) =
         Button_Yes
      then
         Timer_Name := Name (Item);
         if Proc_Ref /= null then
            Set_System_Timer (Regular_Processor (Proc_Ref.all), null);
         end if;
         Me_Timer_Iterator :=
            Mast_Editor.Timers.Lists.Find
              (Timer_Name,
               Editor_System.Me_Timers);
         Me_Timer_Ref      :=
            Mast_Editor.Timers.Lists.Item
              (Me_Timer_Iterator,
               Editor_System.Me_Timers);
         Mast_Editor.Timers.Lists.Delete
           (Me_Timer_Iterator,
            Me_Timer_Ref,
            Editor_System.Me_Timers);
         Remove (Proc_Res_Canvas, Me_Timer_Ref);
         Refresh_Canvas (Proc_Res_Canvas);
         Change_Control.Changes_Made;
         Destroy (Item_Menu);
      end if;
   exception
      when others =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "ERROR IN TIMER REMOVAL !!!");
         Show_All (Editor_Error_Window);
         Destroy (Item_Menu);
   end Remove_Timer;

   ----------------------
   -- Properties_Timer --
   ----------------------
   procedure Properties_Timer
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Timer_Ref)
   is
      Timer_Dialog : Timer_Dialog_Access;
      Me_Data      : ME_Timer_And_Dialog_Ref := new ME_Timer_And_Dialog;
   begin
      Gtk_New (Timer_Dialog);
      Read_Parameters (Item, Gtk_Dialog (Timer_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Timer_Dialog);

      Me_Timer_And_Dialog_Cb.Connect
        (Timer_Dialog.Ok_Button,
         "clicked",
         Me_Timer_And_Dialog_Cb.To_Marshaller (Write_Timer'Access),
         Me_Data);

      Refresh_Canvas (Proc_Res_Canvas);
      Destroy (Item_Menu);
   end Properties_Timer;

   ---------------------
   -- On Button Click --
   ---------------------
   procedure On_Button_Click
     (Item  : access ME_System_Timer;
      Event : Gdk.Event.Gdk_Event_Button)
   is
      Num_Button   : Guint;
      Event_Type   : Gdk_Event_Type;
      Timer_Dialog : Timer_Dialog_Access;
      Me_Data      : ME_Timer_And_Dialog_Ref := new ME_Timer_And_Dialog;
   begin
      if Event /= null then
         Event_Type := Get_Event_Type (Event);
         if Event_Type = Gdk_2button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (1) then

               Gtk_New (Timer_Dialog);
               Read_Parameters (Item, Gtk_Dialog (Timer_Dialog));
               Me_Data.It  := ME_Timer_Ref (Item);
               Me_Data.Dia := Gtk_Dialog (Timer_Dialog);

               Me_Timer_And_Dialog_Cb.Connect
                 (Timer_Dialog.Ok_Button,
                  "clicked",
                  Me_Timer_And_Dialog_Cb.To_Marshaller (Write_Timer'Access),
                  Me_Data);
            end if;
         elsif Event_Type = Button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (3) then
               Gtk_New (Item_Menu);
               Button_Cb.Connect
                 (Item_Menu.Remove,
                  "activate",
                  Button_Cb.To_Marshaller (Remove_Timer'Access),
                  ME_Timer_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Properties,
                  "activate",
                  Button_Cb.To_Marshaller (Properties_Timer'Access),
                  ME_Timer_Ref (Item));
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
      Item        : in out ME_System_Timer;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Mast_Editor.Timers.Print (File, ME_Timer (Item), Indentation);
      Put (File, " ");
      Put (File, "Me_System_Timer");
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

end Mast_Editor.Timers;
