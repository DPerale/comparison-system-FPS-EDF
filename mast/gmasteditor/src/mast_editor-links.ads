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
with Gdk.GC;                   use Gdk.GC;
with Gdk.Event;                use Gdk.Event;
with Gtk.Dialog;               use Gtk.Dialog;
with Gtk.Widget;               use Gtk.Widget;
with Mast.Graphs.Links;        use Mast.Graphs.Links;
with Mast_Editor.Transactions; use Mast_Editor.Transactions;
with Named_Lists;

package Mast_Editor.Links is

   Link_Width         : constant Gint          := 60;
   Link_Height        : constant Gint          := 20;
   Int_Link_Color     : Var_Strings.Var_String :=
      Var_Strings.To_Var_String ("grey");
   Int_Link_Req_Color : Var_Strings.Var_String :=
      Var_Strings.To_Var_String ("orange");
   Ext_Link_Color     : Var_Strings.Var_String :=
      Var_Strings.To_Var_String ("beige");

   type ME_Link is abstract new ME_Object with record
      Lin     : Mast.Graphs.Link_Ref;
      ME_Tran : Mast_Editor.Transactions.ME_Transaction_Ref;
   end record;

   function Name (Item : in ME_Link) return Var_String;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Link;
      Indentation : Positive;
      Finalize    : Boolean := False);

   procedure Write_Parameters
     (Item   : access ME_Link;
      Dialog : access Gtk_Dialog_Record'Class)
      is abstract;

   procedure Read_Parameters
     (Item   : access ME_Link;
      Dialog : access Gtk_Dialog_Record'Class)
      is abstract;

   type ME_Link_Ref is access all ME_Link'Class;

   function Name (Item_Ref : in ME_Link_Ref) return Var_String;

   package Lists is new Named_Lists (Element => ME_Link_Ref, Name => Name);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive);

   -------------------
   -- Internal_Link --
   -------------------

   type ME_Internal_Link is new ME_Link with null record;

   procedure Write_Parameters
     (Item   : access ME_Internal_Link;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_Internal_Link;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_Internal_Link;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);

   procedure On_Button_Click
     (Item  : access ME_Internal_Link;
      Event : Gdk.Event.Gdk_Event_Button);
   -- Show the params of internal event by clicking with the mouse
   --(right-button)

   procedure Show_Internal_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Res    : ME_Transaction_Ref);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Internal_Link;
      Indentation : Positive;
      Finalize    : Boolean := False);

   -------------------
   -- External_Link --
   -------------------

   type ME_External_Link is new ME_Link with null record;

   procedure Write_Parameters
     (Item   : access ME_External_Link;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_External_Link;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_External_Link;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);

   procedure On_Button_Click
     (Item  : access ME_External_Link;
      Event : Gdk.Event.Gdk_Event_Button);
   -- Show the params of external event by clicking with the mouse
   --(right-button)

   procedure Show_External_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Res    : ME_Transaction_Ref);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_External_Link;
      Indentation : Positive;
      Finalize    : Boolean := False);

end Mast_Editor.Links;
