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
with Gtk.Dialog;      use Gtk.Dialog;
with Gtk.Frame;
with Mast.Operations;
with Named_Lists;

package Mast_Editor.Operations is

   Operation_Canvas : Interactive_Canvas;
   Op_Width         : constant Gint          := 150;
   Op_Height        : constant Gint          := 65;
   Sop_Color        : Var_Strings.Var_String :=
      Var_Strings.To_Var_String ("burlywood1");
   Cop_Color        : Var_Strings.Var_String :=
      Var_Strings.To_Var_String ("yellow");
   Txop_Color       : Var_Strings.Var_String :=
      Var_Strings.To_Var_String ("pink");

   type ME_Operation is abstract new ME_Object with record
      Op : Mast.Operations.Operation_Ref;
   end record;

   function Name (Item : in ME_Operation) return Var_String;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Operation;
      Indentation : Positive;
      Finalize    : Boolean := False);

   procedure Write_Parameters
     (Item   : access ME_Operation;
      Dialog : access Gtk_Dialog_Record'Class)
is abstract;

   procedure Read_Parameters
     (Item   : access ME_Operation;
      Dialog : access Gtk_Dialog_Record'Class)
is abstract;

   type ME_Operation_Ref is access all ME_Operation'Class;

   function Name (Item_Ref : in ME_Operation_Ref) return Var_String;

   package Lists is new Named_Lists (
      Element => ME_Operation_Ref,
      Name => Name);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive);

   procedure Draw_Composite_Operation_Links (Item : in ME_Operation_Ref);

   -----------------------
   -- Simple Operation  --
   -----------------------

   type ME_Simple_Operation is new ME_Operation with null record;

   procedure Write_Parameters
     (Item   : access ME_Simple_Operation;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_Simple_Operation;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_Simple_Operation;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);
   -- Draws simple operation

   procedure On_Button_Click
     (Item  : access ME_Simple_Operation;
      Event : Gdk.Event.Gdk_Event_Button);
   -- Shows the params of simple operation by clicking with the mouse
   --(right-button)

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Simple_Operation;
      Indentation : Positive;
      Finalize    : Boolean := False);

   ---------------------------
   -- Message Tx Operation  --
   ---------------------------

   type Me_Message_Transmission_Operation is new ME_Operation with null record;

   procedure Write_Parameters
     (Item   : access Me_Message_Transmission_Operation;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access Me_Message_Transmission_Operation;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access Me_Message_Transmission_Operation;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);
   -- Draws message_tx_operation

   procedure On_Button_Click
     (Item  : access Me_Message_Transmission_Operation;
      Event : Gdk.Event.Gdk_Event_Button);
   -- Shows the params of meassage_tx_operation by clicking with the mouse
   --(right-button)

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out Me_Message_Transmission_Operation;
      Indentation : Positive;
      Finalize    : Boolean := False);

   --------------------------
   -- Composite Operation  --
   --------------------------

   type ME_Composite_Operation is new ME_Operation with null record;

   procedure Write_Parameters
     (Item   : access ME_Composite_Operation;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_Composite_Operation;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_Composite_Operation;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);
   -- Draws composite operation

   procedure On_Button_Click
     (Item  : access ME_Composite_Operation;
      Event : Gdk.Event.Gdk_Event_Button);
   -- Shows the params of compo operation by clicking with the mouse
   --(right-button)

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Composite_Operation;
      Indentation : Positive;
      Finalize    : Boolean := False);

   ---------
   -- Run --
   ---------
   procedure Run (Frame : access Gtk.Frame.Gtk_Frame_Record'Class);
   -- Puts the toolbar and scrolling canvas inside the frame

end Mast_Editor.Operations;
