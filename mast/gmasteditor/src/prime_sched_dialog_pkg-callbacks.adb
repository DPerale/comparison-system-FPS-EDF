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

package body Prime_Sched_Dialog_Pkg.Callbacks is

   use Gtk.Arguments;

   ------------------------------
   -- On_Cancel_Button_Clicked --
   ------------------------------

   procedure On_Cancel_Button_Clicked
     (Object : access Gtk_Dialog_Record'Class)
   is
   begin
      Destroy (Object);
   end On_Cancel_Button_Clicked;

   ----------------------------------------
   -- On_Prime_Policy_Type_Entry_Changed --
   ----------------------------------------

   procedure On_Prime_Policy_Type_Entry_Changed
     (Object : access Prime_Sched_Dialog_Record'Class)
   is
      Policy_Type : String :=
         String (Get_Text (Get_Entry (Object.Policy_Type_Combo)));
   begin
      if Policy_Type = "Fixed Priority" then
         Show_All (Object);
         Hide (Object.Overhead_Table);
      elsif Policy_Type = "Earliest Deadline First" then
         Show_All (Object);
         Hide (Object.Priority_Table);
         Hide (Object.Overhead_Table);
      elsif Policy_Type = "Fixed Priority Packet Based" then
         Show_All (Object);
         Hide (Object.Context_Table);
      else
         Show_All (Object);
         Hide (Object.Priority_Table);
         Hide (Object.Context_Table);
         Hide (Object.Overhead_Table);
      end if;
   end On_Prime_Policy_Type_Entry_Changed;

end Prime_Sched_Dialog_Pkg.Callbacks;
