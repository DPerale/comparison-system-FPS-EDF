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
with Gdk.GC;                  use Gdk.GC;
with Gdk.Event;               use Gdk.Event;
with Gtk.Dialog;              use Gtk.Dialog;
with Gtk.Frame;
with Mast.Scheduling_Servers;
with Named_Lists;

package Mast_Editor.Scheduling_Servers is

   Sched_Server_Canvas : Interactive_Canvas;
   Ser_Width           : constant Gint          := 150;
   Ser_Height          : constant Gint          := 60;
   Ser_Color           : Var_Strings.Var_String :=
      Var_Strings.To_Var_String ("orange1");

   type ME_Scheduling_Server is abstract new ME_Object with record
      Ser : Mast.Scheduling_Servers.Scheduling_Server_Ref;
   end record;

   function Name (Item : in ME_Scheduling_Server) return Var_String;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Scheduling_Server;
      Indentation : Positive;
      Finalize    : Boolean := False);

   procedure Write_Parameters
     (Item   : access ME_Scheduling_Server;
      Dialog : access Gtk_Dialog_Record'Class)
is abstract;

   procedure Read_Parameters
     (Item   : access ME_Scheduling_Server;
      Dialog : access Gtk_Dialog_Record'Class)
is abstract;

   type ME_Scheduling_Server_Ref is access all ME_Scheduling_Server'Class;

   function Name (Item_Ref : in ME_Scheduling_Server_Ref) return Var_String;

   package Lists is new Named_Lists (
      Element => ME_Scheduling_Server_Ref,
      Name => Name);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive);

   procedure Draw_Scheduler_In_Server_Canvas
     (Item : ME_Scheduling_Server_Ref);

   ------------
   -- Server --
   ------------
   type ME_Server is new ME_Scheduling_Server with null record;

   procedure Write_Parameters
     (Item   : access ME_Server;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_Server;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_Server;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);
   -- Draws a server

   procedure On_Button_Click
     (Item  : access ME_Server;
      Event : Gdk.Event.Gdk_Event_Button);
   -- Shows the params of a server by clicking with the mouse (right-button)

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Server;
      Indentation : Positive;
      Finalize    : Boolean := False);

   ---------
   -- Run --
   ---------
   procedure Run (Frame : access Gtk.Frame.Gtk_Frame_Record'Class);
   -- Put the toolbar and scrolling canvas inside the frame

end Mast_Editor.Scheduling_Servers;
