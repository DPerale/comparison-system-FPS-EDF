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
package Sched_Server_Dialog_Pkg is

   type Sched_Server_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox66                 : Gtk_Hbox;
      Server_Ok_Button       : Gtk_Button;
      Server_Cancel_Button   : Gtk_Button;
      Vbox5                  : Gtk_Vbox;
      Table1                 : Gtk_Table;
      Label109               : Gtk_Label;
      Label110               : Gtk_Label;
      Label111               : Gtk_Label;
      Label112               : Gtk_Label;
      Label113               : Gtk_Label;
      Server_Name_Entry      : Gtk_Entry;
      Server_Type_Combo      : Gtk_Combo;
      Listitem1813           : Gtk_List_Item;
      Sched_Combo            : Gtk_Combo;
      Listitem1814           : Gtk_List_Item;
      Sync_Type_Combo        : Gtk_Combo;
      Listitem1815           : Gtk_List_Item;
      Listitem1816           : Gtk_List_Item;
      Srp_Table              : Gtk_Table;
      Label114               : Gtk_Label;
      Label115               : Gtk_Label;
      Preemption_Level_Entry : Gtk_Entry;
      Pre_Level_Combo        : Gtk_Combo;
      Listitem1817           : Gtk_List_Item;
      Listitem1818           : Gtk_List_Item;
      Policy_Type_Table      : Gtk_Table;
      Label375               : Gtk_Label;
      Label376               : Gtk_Label;
      Policy_Type_Combo      : Gtk_Combo;
      Listitem1819           : Gtk_List_Item;
      Listitem1820           : Gtk_List_Item;
      Listitem1821           : Gtk_List_Item;
      Listitem1822           : Gtk_List_Item;
      Listitem1823           : Gtk_List_Item;
      Listitem1824           : Gtk_List_Item;
      Listitem1825           : Gtk_List_Item;
      Priority_Table         : Gtk_Table;
      Label377               : Gtk_Label;
      Label378               : Gtk_Label;
      Server_Priority_Entry  : Gtk_Entry;
      Pre_Prior_Combo        : Gtk_Combo;
      Listitem1826           : Gtk_List_Item;
      Listitem1827           : Gtk_List_Item;
      Polling_Table          : Gtk_Table;
      Label116               : Gtk_Label;
      Polling_Period_Entry   : Gtk_Entry;
      Polling_Wor_Over_Entry : Gtk_Entry;
      Polling_Bes_Over_Entry : Gtk_Entry;
      Polling_Avg_Over_Entry : Gtk_Entry;
      Label117               : Gtk_Label;
      Label118               : Gtk_Label;
      Label119               : Gtk_Label;
      Sporadic_Table         : Gtk_Table;
      Label120               : Gtk_Label;
      Back_Prior_Entry       : Gtk_Entry;
      Init_Capa_Entry        : Gtk_Entry;
      Reple_Period_Entry     : Gtk_Entry;
      Max_Pend_Reple_Entry   : Gtk_Entry;
      Label122               : Gtk_Label;
      Label123               : Gtk_Label;
      Label121               : Gtk_Label;
      Edf_Table              : Gtk_Table;
      Label369               : Gtk_Label;
      Label370               : Gtk_Label;
      Deadline_Entry         : Gtk_Entry;
      Deadline_Combo         : Gtk_Combo;
      Listitem1828           : Gtk_List_Item;
      Listitem1829           : Gtk_List_Item;
   end record;
   type Sched_Server_Dialog_Access is access all Sched_Server_Dialog_Record'
     Class;

   procedure Gtk_New (Sched_Server_Dialog : out Sched_Server_Dialog_Access);
   procedure Initialize
     (Sched_Server_Dialog : access Sched_Server_Dialog_Record'Class);

end Sched_Server_Dialog_Pkg;
