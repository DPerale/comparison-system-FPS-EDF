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
with Gdk.GC;            use Gdk.GC;
with Gdk.Event;         use Gdk.Event;
with Gtk.Frame;
with Mast.Transactions;
with Named_Lists;
with Trans_Dialog_Pkg;

package Mast_Editor.Transactions is

   Transaction_Canvas : Interactive_Canvas;
   Tran_Width         : constant Gint          := 150;
   Tran_Height        : constant Gint          := 60;
   Tran_Color         : Var_Strings.Var_String :=
      Var_Strings.To_Var_String ("DeepSkyBlue1");

   type ME_Transaction is abstract new ME_Object with record
      Tran   : Mast.Transactions.Transaction_Ref;
      Dialog : Trans_Dialog_Pkg.Trans_Dialog_Access;
   end record;

   function Name (Item : in ME_Transaction) return Var_String;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Transaction;
      Indentation : Positive;
      Finalize    : Boolean := False);

   procedure Write_Parameters (Item : access ME_Transaction) is abstract;

   procedure Read_Parameters (Item : access ME_Transaction) is abstract;

   type ME_Transaction_Ref is access all ME_Transaction'Class;

   function Name (Item_Ref : in ME_Transaction_Ref) return Var_String;

   package Lists is new Named_Lists (
      Element => ME_Transaction_Ref,
      Name => Name);

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive);

   procedure Draw_External_Events_In_Tran_Canvas
     (Item         : ME_Transaction_Ref;
      Use_TXT_File : Boolean := False);

   procedure Draw_Internal_Events_In_Tran_Canvas
     (Item         : ME_Transaction_Ref;
      Use_TXT_File : Boolean := False);

   procedure Draw_Event_Handlers_In_Tran_Canvas
     (Item         : ME_Transaction_Ref;
      Use_TXT_File : Boolean := False);

   -------------------------
   -- Regular Transaction --
   -------------------------
   type ME_Regular_Transaction is new ME_Transaction with null record;

   procedure Write_Parameters (Item : access ME_Regular_Transaction);
   -- Read the params from the transaction dialog

   procedure Read_Parameters (Item : access ME_Regular_Transaction);
   -- Show the params in the transaction dialog

   procedure Draw
     (Item         : access ME_Regular_Transaction;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint);

   procedure On_Button_Click
     (Item  : access ME_Regular_Transaction;
      Event : Gdk.Event.Gdk_Event_Button);
   -- Show the params of a transaction by clicking with the mouse
   --(right-button)

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Regular_Transaction;
      Indentation : Positive;
      Finalize    : Boolean := False);

   ---------
   -- Run --
   ---------
   procedure Run (Frame : access Gtk.Frame.Gtk_Frame_Record'Class);
   -- Put the toolbar and scrolling canvas inside the frame

end Mast_Editor.Transactions;
