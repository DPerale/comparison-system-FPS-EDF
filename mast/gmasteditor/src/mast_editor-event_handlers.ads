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
with Gdk.GC;                     use Gdk.GC;
with Gdk.Event;                  use Gdk.Event;
with Gtk.Dialog;                 use Gtk.Dialog;
with Gtk.Widget;                 use Gtk.Widget;
with Mast.Graphs.Event_Handlers; use Mast.Graphs.Event_Handlers;
with Mast_Editor.Transactions;   use Mast_Editor.Transactions;
with Named_Lists;

package Mast_Editor.Event_Handlers is

   Handler_Width  : constant Gint          := 150;
   Handler_Height : constant Gint          := 50;
   Handler_Color  : Var_Strings.Var_String :=
      Var_Strings.To_Var_String ("lightsteelblue1");

   type ME_Event_Handler is abstract new ME_Object with record
      Han     : Mast.Graphs.Event_Handler_Ref;
      ME_Tran : Mast_Editor.Transactions.ME_Transaction_Ref;
      Id      : Natural := 1;
   end record;

   function Name (Item : in ME_Event_Handler) return Var_String;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean := False);

   procedure Write_Parameters
     (Item   : access ME_Event_Handler;
      Dialog : access Gtk_Dialog_Record'Class)
      is abstract;

   procedure Read_Parameters
     (Item   : access ME_Event_Handler;
      Dialog : access Gtk_Dialog_Record'Class)
      is abstract;

   type ME_Event_Handler_Ref is access all ME_Event_Handler'Class;

   function Name (Item_Ref : in ME_Event_Handler_Ref) return Var_String;

   package Lists is new Named_Lists (
      Element => ME_Event_Handler_Ref,
      Name => Name);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive);

   --------------------------
   -- Simple_Event_Handler --
   --------------------------

   type ME_Simple_Event_Handler is new ME_Event_Handler with null record;

   procedure Write_Parameters
     (Item   : access ME_Simple_Event_Handler;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_Simple_Event_Handler;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_Simple_Event_Handler;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);

   procedure On_Button_Click
     (Item  : access ME_Simple_Event_Handler;
      Event : Gdk.Event.Gdk_Event_Button);

   procedure Show_Simple_Event_Handler_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Res    : ME_Transaction_Ref);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Simple_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean := False);

   -------------------------------
   -- Multi_Input_Event_Handler --
   -------------------------------

   type ME_Multi_Input_Event_Handler is new ME_Event_Handler with null record;

   procedure Write_Parameters
     (Item   : access ME_Multi_Input_Event_Handler;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_Multi_Input_Event_Handler;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_Multi_Input_Event_Handler;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);

   procedure On_Button_Click
     (Item  : access ME_Multi_Input_Event_Handler;
      Event : Gdk.Event.Gdk_Event_Button);

   procedure Show_Multi_Input_Event_Handler_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Res    : ME_Transaction_Ref);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Multi_Input_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean := False);

   --------------------------------
   -- Multi_Output_Event_Handler --
   --------------------------------

   type ME_Multi_Output_Event_Handler is new ME_Event_Handler with null record;

   procedure Write_Parameters
     (Item   : access ME_Multi_Output_Event_Handler;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Read_Parameters
     (Item   : access ME_Multi_Output_Event_Handler;
      Dialog : access Gtk_Dialog_Record'Class);

   procedure Draw
     (Item         : access ME_Multi_Output_Event_Handler;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);

   procedure On_Button_Click
     (Item  : access ME_Multi_Output_Event_Handler;
      Event : Gdk.Event.Gdk_Event_Button);

   procedure Show_Multi_Output_Event_Handler_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Res    : ME_Transaction_Ref);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Multi_Output_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean := False);

end Mast_Editor.Event_Handlers;
