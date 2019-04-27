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
package External_Dialog_Pkg is

   type External_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox68                    : Gtk_Hbox;
      Ok_Button                 : Gtk_Button;
      Cancel_Button             : Gtk_Button;
      Vbox15                    : Gtk_Vbox;
      Table1                    : Gtk_Table;
      Label174                  : Gtk_Label;
      Label175                  : Gtk_Label;
      External_Event_Name_Entry : Gtk_Entry;
      External_Event_Type_Combo : Gtk_Combo;
      Listitem1912              : Gtk_List_Item;
      Listitem1913              : Gtk_List_Item;
      Listitem1914              : Gtk_List_Item;
      Listitem1915              : Gtk_List_Item;
      Listitem1916              : Gtk_List_Item;
      Periodic_Table            : Gtk_Table;
      Label180                  : Gtk_Label;
      Label181                  : Gtk_Label;
      Label182                  : Gtk_Label;
      Max_Jitter_Entry          : Gtk_Entry;
      Period_Entry              : Gtk_Entry;
      Per_Phase_Entry           : Gtk_Entry;
      Singular_Table            : Gtk_Table;
      Label230                  : Gtk_Label;
      Sing_Phase_Entry          : Gtk_Entry;
      Sporadic_Table            : Gtk_Table;
      Label225                  : Gtk_Label;
      Label226                  : Gtk_Label;
      Spo_Avg_Entry             : Gtk_Entry;
      Spo_Min_Entry             : Gtk_Entry;
      Spo_Dist_Func_Combo       : Gtk_Combo;
      Listitem1917              : Gtk_List_Item;
      Listitem1918              : Gtk_List_Item;
      Label227                  : Gtk_Label;
      Unbounded_Table           : Gtk_Table;
      Unb_Avg_Entry             : Gtk_Entry;
      Label237                  : Gtk_Label;
      Unb_Dist_Func_Combo       : Gtk_Combo;
      Listitem1919              : Gtk_List_Item;
      Listitem1920              : Gtk_List_Item;
      Label238                  : Gtk_Label;
      Bursty_Table              : Gtk_Table;
      Label239                  : Gtk_Label;
      Label240                  : Gtk_Label;
      Bur_Avg_Entry             : Gtk_Entry;
      Bur_Bound_Entry           : Gtk_Entry;
      Bur_Dist_Func_Combo       : Gtk_Combo;
      Listitem1921              : Gtk_List_Item;
      Listitem1922              : Gtk_List_Item;
      Label241                  : Gtk_Label;
      Label242                  : Gtk_Label;
      Max_Arrival_Entry         : Gtk_Entry;
   end record;
   type External_Dialog_Access is access all External_Dialog_Record'Class;

   procedure Gtk_New (External_Dialog : out External_Dialog_Access);
   procedure Initialize
     (External_Dialog : access External_Dialog_Record'Class);

end External_Dialog_Pkg;
