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
with Gtk.Dialog;   use Gtk.Dialog;
with Gtk.Box;      use Gtk.Box;
with Gtk.Button;   use Gtk.Button;
with Gtk.Table;    use Gtk.Table;
with Gtk.Combo;    use Gtk.Combo;
with Gtk.GEntry;   use Gtk.GEntry;
with Glib.Unicode; use Glib.Unicode;
with Gtk.Label;    use Gtk.Label;

with Gtk.Enums; use Gtk.Enums;

package Select_Ref_Event_Dialog_Pkg is

   Refer_Event_Combo_Items : String_List.Glist;

   type Select_Ref_Event_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox75          : Gtk_Hbox;
      Ok_Button       : Gtk_Button;
      Cancel_Button   : Gtk_Button;
      Table           : Gtk_Table;
      Ref_Event_Combo : Gtk_Combo;
      Label           : Gtk_Label;

   end record;
   type Select_Ref_Event_Dialog_Access is access all 
     Select_Ref_Event_Dialog_Record'Class;

   procedure Gtk_New
     (Select_Ref_Event_Dialog : out Select_Ref_Event_Dialog_Access);
   procedure Initialize
     (Select_Ref_Event_Dialog : access Select_Ref_Event_Dialog_Record'Class);

end Select_Ref_Event_Dialog_Pkg;
