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
with Mast.Drivers;              use Mast.Drivers;
with Mast.Processing_Resources; use Mast.Processing_Resources;
with Named_Lists;

package Mast_Editor.Drivers is

   Driv_Width  : constant Gint          := 100;
   Driv_Height : constant Gint          := 35;
   Driv_Color  : Var_Strings.Var_String :=
      Var_Strings.To_Var_String ("PaleGreen");

   type ME_Driver is abstract new ME_Object with record
      Driv : Mast.Drivers.Driver_Ref;
      Proc : Mast.Processing_Resources.Processing_Resource_Ref;
      Net  : Mast.Processing_Resources.Processing_Resource_Ref;
   end record;

   function Name (Item : in ME_Driver) return Var_String;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Driver;
      Indentation : Positive;
      Finalize    : Boolean := False);

   procedure Write_Parameters
     (Item   : access ME_Driver;
      Dialog : access Gtk_Dialog_Record'Class)
is abstract;

   procedure Read_Parameters
     (Item   : access ME_Driver;
      Dialog : access Gtk_Dialog_Record'Class)
is abstract;

   type ME_Driver_Ref is access all ME_Driver'Class;

   function Name (Item_Ref : in ME_Driver_Ref) return Var_String;

   package Lists is new Named_Lists (Element => ME_Driver_Ref, Name => Name);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive);

   -------------------
   -- Packet Driver --
   -------------------

   type ME_Packet_Driver is new ME_Driver with null record;

   procedure Write_Parameters
     (Item   : access ME_Packet_Driver;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_Packet_Driver;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_Packet_Driver;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);

   procedure On_Button_Click
     (Item  : access ME_Packet_Driver;
      Event : Gdk.Event.Gdk_Event_Button);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Packet_Driver;
      Indentation : Positive;
      Finalize    : Boolean := False);

end Mast_Editor.Drivers;
