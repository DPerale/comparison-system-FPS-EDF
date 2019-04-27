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
package Second_Sched_Dialog_Pkg is

   type Second_Sched_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox103                 : Gtk_Hbox;
      Ok_Button               : Gtk_Button;
      Cancel_Button           : Gtk_Button;
      Vbox25                  : Gtk_Vbox;
      Table36                 : Gtk_Table;
      Label358                : Gtk_Label;
      Second_Sched_Name_Entry : Gtk_Entry;
      Label359                : Gtk_Label;
      Server_Combo            : Gtk_Combo;
      Listitem2906            : Gtk_List_Item;
      Listitem2907            : Gtk_List_Item;
      Label362                : Gtk_Label;
      Label363                : Gtk_Label;
      Policy_Type_Combo       : Gtk_Combo;
      Listitem2945            : Gtk_List_Item;
      Listitem2946            : Gtk_List_Item;
      Listitem2947            : Gtk_List_Item;
      Priority_Table          : Gtk_Table;
      Max_Prior_Entry         : Gtk_Entry;
      Min_Prior_Entry         : Gtk_Entry;
      Label364                : Gtk_Label;
      Label365                : Gtk_Label;
      Context_Table           : Gtk_Table;
      Label366                : Gtk_Label;
      Worst_Context_Entry     : Gtk_Entry;
      Avg_Context_Entry       : Gtk_Entry;
      Best_Context_Entry      : Gtk_Entry;
      Label367                : Gtk_Label;
      Label368                : Gtk_Label;
   end record;
   type Second_Sched_Dialog_Access is access all Second_Sched_Dialog_Record'
     Class;

   procedure Gtk_New (Second_Sched_Dialog : out Second_Sched_Dialog_Access);
   procedure Initialize
     (Second_Sched_Dialog : access Second_Sched_Dialog_Record'Class);

end Second_Sched_Dialog_Pkg;
