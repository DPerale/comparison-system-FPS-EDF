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
with System;          use System;
with Glib;            use Glib;
with Gdk.Event;       use Gdk.Event;
with Gdk.Types;       use Gdk.Types;
with Gtk.Accel_Group; use Gtk.Accel_Group;
with Gtk.Object;      use Gtk.Object;
with Gtk.Enums;       use Gtk.Enums;
with Gtk.Style;       use Gtk.Style;
with Gtk.Widget;      use Gtk.Widget;

with Mast.Schedulers;         use Mast.Schedulers;
with Mast.Schedulers.Primary; use Mast.Schedulers.Primary;
with Mast_Editor.Schedulers;  use Mast_Editor.Schedulers;
with Var_Strings;             use Var_Strings;
with Prime_Sched_Dialog_Pkg;  use Prime_Sched_Dialog_Pkg;
with Gtk.Handlers;            use Gtk.Handlers;

package body Network_Dialog_Pkg.Callbacks is

   use Gtk.Arguments;

   --------------------------------------
   -- On_Network_Cancel_Button_Clicked --
   --------------------------------------

   procedure On_Network_Cancel_Button_Clicked
     (Object : access Gtk_Dialog_Record'Class)
   is
   begin
      Destroy (Object);
   end On_Network_Cancel_Button_Clicked;

   -----------------------------------
   -- On_New_Primary_Button_Clicked --
   -----------------------------------

   procedure On_New_Primary_Button_Clicked
     (Object : access Network_Dialog_Record'Class)
   is
      Item               : ME_Scheduler_Ref            :=
         new ME_Primary_Scheduler;
      Sche_Ref           : Scheduler_Ref               :=
         new Primary_Scheduler;
      Prime_Sched_Dialog : Prime_Sched_Dialog_Access;
      Me_Data            : ME_Scheduler_And_Dialog_Ref :=
         new ME_Scheduler_And_Dialog;
   begin
      Item.W           := Sche_Width;
      Item.H           := Sche_Height;
      Item.Canvas_Name := To_Var_String ("Proc_Res_Canvas");
      Item.Color_Name  := Prime_Color;
      Item.Sche        := Sche_Ref;

      -- Add new scheduling policy type (FP Packet Based)
      String_List.Append
        (Policy_Type_Combo_Items,
         "Fixed Priority Packet Based");

      Gtk_New (Prime_Sched_Dialog);
      Read_Parameters (Item, Gtk_Dialog (Prime_Sched_Dialog));

      -- Put Network name and FP_Packet_Based Policy in Prime_Sched_Dialog
      Set_Text
        (Get_Entry (Prime_Sched_Dialog.Host_Combo),
         Get_Text (Object.Net_Name_Entry));
      Set_Text
        (Get_Entry (Prime_Sched_Dialog.Policy_Type_Combo),
         "Fixed Priority Packet Based");
      Show_All (Prime_Sched_Dialog);
      Hide (Prime_Sched_Dialog.Context_Table);

      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Prime_Sched_Dialog);

      Me_Scheduler_And_Dialog_Cb.Connect
        (Prime_Sched_Dialog.Ok_Button,
         "clicked",
         Me_Scheduler_And_Dialog_Cb.To_Marshaller (New_Primary_Sched'Access),
         Me_Data);
   end On_New_Primary_Button_Clicked;

end Network_Dialog_Pkg.Callbacks;
