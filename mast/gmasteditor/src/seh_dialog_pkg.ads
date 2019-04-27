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

with Gtk.Enums; use Gtk.Enums;

package Seh_Dialog_Pkg is

   Ref_Event_Combo_Items : String_List.Glist;

   type Seh_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox71          : Gtk_Hbox;
      Ok_Button       : Gtk_Button;
      Cancel_Button   : Gtk_Button;
      Vbox17          : Gtk_Vbox;
      Table1          : Gtk_Table;
      Label195        : Gtk_Label;
      Seh_Type_Combo  : Gtk_Combo;
      Listitem1989    : Gtk_List_Item;
      Listitem1990    : Gtk_List_Item;
      Listitem1991    : Gtk_List_Item;
      Listitem1992    : Gtk_List_Item;
      Listitem1993    : Gtk_List_Item;
      Activity_Table  : Gtk_Table;
      Label196        : Gtk_Label;
      Op_Combo        : Gtk_Combo;
      Listitem1994    : Gtk_List_Item;
      Ser_Combo       : Gtk_Combo;
      Listitem1995    : Gtk_List_Item;
      Label200        : Gtk_Label;
      Rate_Table      : Gtk_Table;
      Label246        : Gtk_Label;
      Rate_Entry      : Gtk_Entry;
      Delay_Table     : Gtk_Table;
      Label248        : Gtk_Label;
      Label249        : Gtk_Label;
      Delay_Max_Entry : Gtk_Entry;
      Delay_Min_Entry : Gtk_Entry;
      Ref_Table       : Gtk_Table;
      Label250        : Gtk_Label;
      Ref_Event_Combo : Gtk_Combo;
      Listitem1996    : Gtk_List_Item;
   end record;
   type Seh_Dialog_Access is access all Seh_Dialog_Record'Class;

   procedure Gtk_New (Seh_Dialog : out Seh_Dialog_Access);
   procedure Initialize (Seh_Dialog : access Seh_Dialog_Record'Class);

end Seh_Dialog_Pkg;
