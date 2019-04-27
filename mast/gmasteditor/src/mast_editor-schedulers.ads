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
with Gdk.GC;          use Gdk.GC;
with Gdk.Event;       use Gdk.Event;
with Gtk.Frame;
with Gtk.Dialog;      use Gtk.Dialog;
with Gtk.Handlers;    use Gtk.Handlers;
with Gtk.Widget;      use Gtk.Widget;
with Gtk.Button;      use Gtk.Button;
with Mast.Schedulers;
with Named_Lists;

package Mast_Editor.Schedulers is

   --Scheduler_Canvas : Interactive_Canvas;
   Sche_Width   : constant Gint          := 150;
   Sche_Height  : constant Gint          := 60;
   Prime_Color  : Var_Strings.Var_String :=
      Var_Strings.To_Var_String ("violet");
   Second_Color : Var_Strings.Var_String :=
      Var_Strings.To_Var_String ("purple1");

   type ME_Scheduler is abstract new ME_Object with record
      Sche : Mast.Schedulers.Scheduler_Ref;
   end record;

   function Name (Item : in ME_Scheduler) return Var_String;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Scheduler;
      Indentation : Positive;
      Finalize    : Boolean := False);

   procedure Write_Parameters
     (Item   : access ME_Scheduler;
      Dialog : access Gtk_Dialog_Record'Class)
is abstract;

   procedure Read_Parameters
     (Item   : access ME_Scheduler;
      Dialog : access Gtk_Dialog_Record'Class)
is abstract;

   type ME_Scheduler_Ref is access all ME_Scheduler'Class;

   function Name (Item_Ref : in ME_Scheduler_Ref) return Var_String;

   package Lists is new Named_Lists (
      Element => ME_Scheduler_Ref,
      Name => Name);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive);

   -------------------------------------------------
   -- Types and packages used to handle dialogs info
   -------------------------------------------------

   type ME_Scheduler_And_Dialog is record
      It  : ME_Scheduler_Ref;
      Dia : Gtk_Dialog;
   end record;

   type ME_Scheduler_And_Dialog_Ref is access all ME_Scheduler_And_Dialog;

   package Me_Scheduler_And_Dialog_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Scheduler_And_Dialog_Ref);

   ----------------------------
   -- Other procedures
   ---------------------------

   procedure New_Primary_Sched
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Scheduler_And_Dialog_Ref);

   procedure Draw_Scheduler_Host (Item : ME_Scheduler_Ref);

   procedure Draw_Scheduler_Server (Item : ME_Scheduler_Ref);

   -----------------------
   -- Primary Scheduler --
   -----------------------
   type ME_Primary_Scheduler is new ME_Scheduler with null record;

   procedure Write_Parameters
     (Item   : access ME_Primary_Scheduler;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_Primary_Scheduler;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_Primary_Scheduler;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);
   -- Draws a primary scheduler

   procedure On_Button_Click
     (Item  : access ME_Primary_Scheduler;
      Event : Gdk.Event.Gdk_Event_Button);
   -- Shows the params of a server by clicking with the mouse (right-button)

   procedure Show_Primary_Dialog (Widget : access Gtk_Button_Record'Class);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Primary_Scheduler;
      Indentation : Positive;
      Finalize    : Boolean := False);

   -------------------------
   -- Secondary Scheduler --
   -------------------------
   type ME_Secondary_Scheduler is new ME_Scheduler with null record;

   procedure Write_Parameters
     (Item   : access ME_Secondary_Scheduler;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_Secondary_Scheduler;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_Secondary_Scheduler;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);
   -- Draws a secondary scheduler

   procedure On_Button_Click
     (Item  : access ME_Secondary_Scheduler;
      Event : Gdk.Event.Gdk_Event_Button);
   -- Shows the params of a server by clicking with the mouse (right-button)

   procedure Show_Secondary_Dialog
     (Widget : access Gtk_Button_Record'Class);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Secondary_Scheduler;
      Indentation : Positive;
      Finalize    : Boolean := False);

   --     ---------
   --     -- Run --
   --     ---------
   --     procedure Run (Frame : access Gtk.Frame.Gtk_Frame_Record'Class);

end Mast_Editor.Schedulers;
