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
package Timer_Dialog_Pkg is

   type Timer_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox104                 : Gtk_Hbox;
      Ok_Button               : Gtk_Button;
      Cancel_Button           : Gtk_Button;
      Vbox62                  : Gtk_Vbox;
      Timer_Table             : Gtk_Table;
      Proc_Period_Label       : Gtk_Label;
      Proc_Period_Entry       : Gtk_Entry;
      Label617                : Gtk_Label;
      Proc_Bes_Over_Entry     : Gtk_Entry;
      Label618                : Gtk_Label;
      Proc_Avg_Over_Entry     : Gtk_Entry;
      Label619                : Gtk_Label;
      Proc_Wor_Over_Entry     : Gtk_Entry;
      Label614                : Gtk_Label;
      System_Timer_Type_Combo : Gtk_Combo;
      Listitem3029            : Gtk_List_Item;
      Listitem3030            : Gtk_List_Item;
   end record;
   type Timer_Dialog_Access is access all Timer_Dialog_Record'Class;

   procedure Gtk_New (Timer_Dialog : out Timer_Dialog_Access);
   procedure Initialize (Timer_Dialog : access Timer_Dialog_Record'Class);

end Timer_Dialog_Pkg;
