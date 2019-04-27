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
with Gtk.Combo;     use Gtk.Combo;
with Gtk.GEntry;    use Gtk.GEntry;
with Glib.Unicode;  use Glib.Unicode;
with Gtk.List_Item; use Gtk.List_Item;
package Message_Tx_Dialog_Pkg is

   type Message_Tx_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox102                  : Gtk_Hbox;
      Ok_Button                : Gtk_Button;
      Cancel_Button            : Gtk_Button;
      Vbox26                   : Gtk_Vbox;
      Table37                  : Gtk_Table;
      Label380                 : Gtk_Label;
      Label381                 : Gtk_Label;
      Op_Type_Combo            : Gtk_Combo;
      Listitem2885             : Gtk_List_Item;
      Op_Name_Entry            : Gtk_Entry;
      Label384                 : Gtk_Label;
      Overrid_Param_Type_Combo : Gtk_Combo;
      Listitem2886             : Gtk_List_Item;
      Listitem2887             : Gtk_List_Item;
      Listitem2888             : Gtk_List_Item;
      Label385                 : Gtk_Label;
      Label391                 : Gtk_Label;
      Max_Message_Size_Entry   : Gtk_Entry;
      Label392                 : Gtk_Label;
      Avg_Message_Size_Entry   : Gtk_Entry;
      Label393                 : Gtk_Label;
      Min_Message_Size_Entry   : Gtk_Entry;
      Overrid_Prior_Table      : Gtk_Table;
      Label394                 : Gtk_Label;
      Overrid_Prior_Entry      : Gtk_Entry;
   end record;
   type Message_Tx_Dialog_Access is access all Message_Tx_Dialog_Record'Class;

   procedure Gtk_New (Message_Tx_Dialog : out Message_Tx_Dialog_Access);
   procedure Initialize
     (Message_Tx_Dialog : access Message_Tx_Dialog_Record'Class);

end Message_Tx_Dialog_Pkg;
