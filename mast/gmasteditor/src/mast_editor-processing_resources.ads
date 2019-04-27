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
with Gdk.GC;                    use Gdk.GC;
with Gdk.Event;                 use Gdk.Event;
with Gtk.Dialog;                use Gtk.Dialog;
with Gtk.Frame;
with Mast.Processing_Resources;
with Named_Lists;

package Mast_Editor.Processing_Resources is

   Proc_Res_Canvas : Interactive_Canvas;
   Proc_Width      : constant Gint          := 150;
   Proc_Height     : constant Gint          := 65;
   Net_Width       : constant Gint          := 150;
   Net_Height      : constant Gint          := 75;
   Proc_Color      : Var_Strings.Var_String :=
      Var_Strings.To_Var_String ("red");
   Net_Color       : Var_Strings.Var_String :=
      Var_Strings.To_Var_String ("turquoise");

   type ME_Processing_Resource is abstract new ME_Object with record
      Res : Mast.Processing_Resources.Processing_Resource_Ref;
   end record;

   function Name (Item : in ME_Processing_Resource) return Var_String;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Processing_Resource;
      Indentation : Positive;
      Finalize    : Boolean := False);

   procedure Write_Parameters
     (Item   : access ME_Processing_Resource;
      Dialog : access Gtk_Dialog_Record'Class)
      is abstract;

   procedure Read_Parameters
     (Item   : access ME_Processing_Resource;
      Dialog : access Gtk_Dialog_Record'Class)
      is abstract;

   type ME_Processing_Resource_Ref is access all ME_Processing_Resource'Class;

   function Name
     (Item_Ref : in ME_Processing_Resource_Ref)
      return     Var_String;

   package Lists is new Named_Lists (
      Element => ME_Processing_Resource_Ref,
      Name => Name);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive);

   procedure Draw_Timer_In_Proc_Canvas (Item : ME_Processing_Resource_Ref);

   procedure Draw_Drivers_In_Proc_Canvas
     (Item : ME_Processing_Resource_Ref);

   ---------------
   -- Processor --
   ---------------

   type ME_Processor is abstract new ME_Processing_Resource with null record;
   type ME_Processor_Ref is access ME_Processor'Class;

   type ME_Regular_Processor is new ME_Processor with null record;

   procedure Write_Parameters
     (Item   : access ME_Regular_Processor;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_Regular_Processor;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_Regular_Processor;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);
   -- Draws a processor

   procedure On_Button_Click
     (Item  : access ME_Regular_Processor;
      Event : Gdk.Event.Gdk_Event_Button);
   -- Shows the params of a processor by clicking with the mouse (right-button)

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Regular_Processor;
      Indentation : Positive;
      Finalize    : Boolean := False);

   -------------
   -- Network --
   -------------

   type ME_Network is abstract new ME_Processing_Resource with null record;
   type ME_Network_Ref is access ME_Network'Class;

   type ME_Packet_Based_Network is new ME_Network with null record;

   procedure Write_Parameters
     (Item   : access ME_Packet_Based_Network;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_Packet_Based_Network;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_Packet_Based_Network;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);
   -- Draws a network

   procedure On_Button_Click
     (Item  : access ME_Packet_Based_Network;
      Event : Gdk.Event.Gdk_Event_Button);
   -- Shows the params of a network by clicking with the mouse (right-button)

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Packet_Based_Network;
      Indentation : Positive;
      Finalize    : Boolean := False);

   ---------
   -- Run --
   ---------
   procedure Run (Frame : access Gtk.Frame.Gtk_Frame_Record'Class);
   -- Puts the toolbar and scrolling canvas inside the frame

end Mast_Editor.Processing_Resources;
