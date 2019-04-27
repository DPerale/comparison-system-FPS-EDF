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
with Gtk.Dialog;    use Gtk.Dialog;
with Gtk.Box;       use Gtk.Box;
with Gtk.Button;    use Gtk.Button;
with Gtk.Table;     use Gtk.Table;
with Gtk.Label;     use Gtk.Label;
with Gtk.GEntry;    use Gtk.GEntry;
with Glib.Unicode;  use Glib.Unicode;
with Gtk.Combo;     use Gtk.Combo;
with Gtk.List_Item; use Gtk.List_Item;
with Gtk.Enums;     use Gtk.Enums;

package Prime_Sched_Dialog_Pkg is

   Policy_Type_Combo_Items : String_List.Glist;

   type Prime_Sched_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox67                 : Gtk_Hbox;
      Ok_Button              : Gtk_Button;
      Cancel_Button          : Gtk_Button;
      Vbox24                 : Gtk_Vbox;
      Table1                 : Gtk_Table;
      Label333               : Gtk_Label;
      Prime_Sched_Name_Entry : Gtk_Entry;
      Label332               : Gtk_Label;
      Host_Combo             : Gtk_Combo;
      Listitem1881           : Gtk_List_Item;
      Label331               : Gtk_Label;
      Label322               : Gtk_Label;
      Policy_Type_Combo      : Gtk_Combo;
      Listitem1882           : Gtk_List_Item;
      Listitem1883           : Gtk_List_Item;
      Listitem1884           : Gtk_List_Item;
      Priority_Table         : Gtk_Table;
      Max_Prior_Entry        : Gtk_Entry;
      Min_Prior_Entry        : Gtk_Entry;
      Label345               : Gtk_Label;
      Label347               : Gtk_Label;
      Context_Table          : Gtk_Table;
      Label348               : Gtk_Label;
      Worst_Context_Entry    : Gtk_Entry;
      Avg_Context_Entry      : Gtk_Entry;
      Best_Context_Entry     : Gtk_Entry;
      Label349               : Gtk_Label;
      Label351               : Gtk_Label;
      Overhead_Table         : Gtk_Table;
      Label354               : Gtk_Label;
      Packet_Over_Max_Entry  : Gtk_Entry;
      Packet_Over_Avg_Entry  : Gtk_Entry;
      Packet_Over_Min_Entry  : Gtk_Entry;
      Label355               : Gtk_Label;
      Label357               : Gtk_Label;
   end record;
   type Prime_Sched_Dialog_Access is access all Prime_Sched_Dialog_Record'
     Class;

   procedure Gtk_New (Prime_Sched_Dialog : out Prime_Sched_Dialog_Access);
   procedure Initialize
     (Prime_Sched_Dialog : access Prime_Sched_Dialog_Record'Class);

end Prime_Sched_Dialog_Pkg;
