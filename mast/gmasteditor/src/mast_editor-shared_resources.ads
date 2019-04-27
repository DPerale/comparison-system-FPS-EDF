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
with Gdk.GC;                use Gdk.GC;
with Gdk.Event;             use Gdk.Event;
with Gtk.Dialog;            use Gtk.Dialog;
with Gtk.Frame;
with Mast.Shared_Resources;
with Named_Lists;

package Mast_Editor.Shared_Resources is

   Shared_Res_Canvas : Interactive_Canvas;
   Share_Width       : constant Gint          := 150;
   Share_Height      : constant Gint          := 60;
   Share_Color       : Var_Strings.Var_String :=
      Var_Strings.To_Var_String ("wheat1");

   type ME_Shared_Resource is abstract new ME_Object with record
      Share : Mast.Shared_Resources.Shared_Resource_Ref;
   end record;

   function Name (Item : in ME_Shared_Resource) return Var_String;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Shared_Resource;
      Indentation : Positive;
      Finalize    : Boolean := False);

   procedure Write_Parameters
     (Item   : access ME_Shared_Resource;
      Dialog : access Gtk_Dialog_Record'Class)
is abstract;

   procedure Read_Parameters
     (Item   : access ME_Shared_Resource;
      Dialog : access Gtk_Dialog_Record'Class)
is abstract;

   type ME_Shared_Resource_Ref is access all ME_Shared_Resource'Class;

   function Name (Item_Ref : in ME_Shared_Resource_Ref) return Var_String;

   package Lists is new Named_Lists (
      Element => ME_Shared_Resource_Ref,
      Name => Name);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive);

   -----------------------------------
   -- Priority Inheritance Resource --
   -----------------------------------

   type ME_Priority_Inheritance_Resource is new ME_Shared_Resource with null 
record;

   procedure Write_Parameters
     (Item   : access ME_Priority_Inheritance_Resource;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_Priority_Inheritance_Resource;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_Priority_Inheritance_Resource;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);
   -- Draw priority inheritance resource

   procedure On_Button_Click
     (Item  : access ME_Priority_Inheritance_Resource;
      Event : Gdk.Event.Gdk_Event_Button);
   -- Show params of the resource by clicking with the mouse (right-button)

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Priority_Inheritance_Resource;
      Indentation : Positive;
      Finalize    : Boolean := False);

   --------------------------------
   -- Immediate Ceiling Resource --
   --------------------------------

   type ME_Immediate_Ceiling_Resource is new ME_Shared_Resource with null 
record;

   procedure Write_Parameters
     (Item   : access ME_Immediate_Ceiling_Resource;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_Immediate_Ceiling_Resource;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_Immediate_Ceiling_Resource;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);
   -- Draw immediate ceiling resource

   procedure On_Button_Click
     (Item  : access ME_Immediate_Ceiling_Resource;
      Event : Gdk.Event.Gdk_Event_Button);
   -- Show params of the resource by clicking with the mouse (right-button)

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Immediate_Ceiling_Resource;
      Indentation : Positive;
      Finalize    : Boolean := False);

   ---------------------------
   -- Stack Resource Policy --
   ---------------------------

   type ME_SRP_Resource is new ME_Shared_Resource with null record;

   procedure Write_Parameters
     (Item   : access ME_SRP_Resource;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_SRP_Resource;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_SRP_Resource;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);
   -- Draw SRP resource

   procedure On_Button_Click
     (Item  : access ME_SRP_Resource;
      Event : Gdk.Event.Gdk_Event_Button);
   -- Show params of the resource by clicking with the mouse (right-button)

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_SRP_Resource;
      Indentation : Positive;
      Finalize    : Boolean := False);

   ---------
   -- Run --
   ---------
   procedure Run (Frame : access Gtk.Frame.Gtk_Frame_Record'Class);
   -- Put the toolbar and scrolling canvas inside the frame

end Mast_Editor.Shared_Resources;
