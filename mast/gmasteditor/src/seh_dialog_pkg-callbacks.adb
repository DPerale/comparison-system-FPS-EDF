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

package body Seh_Dialog_Pkg.Callbacks is

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

   -------------------------
   -- On_Seh_Type_Changed --
   -------------------------

   procedure On_Seh_Type_Changed (Object : access Seh_Dialog_Record'Class) is
      Seh_Type : String :=
         String (Get_Text (Get_Entry (Object.Seh_Type_Combo)));
   begin
      if Seh_Type = "Activity" then
         Show_All (Object);
         Hide (Object.Rate_Table);
         Hide (Object.Delay_Table);
         Hide (Object.Ref_Table);
      elsif Seh_Type = "System Timed Activity" then
         Show_All (Object);
         Hide (Object.Rate_Table);
         Hide (Object.Delay_Table);
         Hide (Object.Ref_Table);
      elsif Seh_Type = "Rate Divisor" then
         Show_All (Object);
         Hide (Object.Activity_Table);
         Hide (Object.Delay_Table);
         Hide (Object.Ref_Table);
      elsif Seh_Type = "Delay" then
         Show_All (Object);
         Hide (Object.Activity_Table);
         Hide (Object.Rate_Table);
         Hide (Object.Ref_Table);
      elsif Seh_Type = "Offset" then
         Show_All (Object);
         Hide (Object.Activity_Table);
         Hide (Object.Rate_Table);
      else
         null;
      end if;
   end On_Seh_Type_Changed;

end Seh_Dialog_Pkg.Callbacks;
