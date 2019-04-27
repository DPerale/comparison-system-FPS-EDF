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
package Moeh_Dialog_Pkg is

   type Moeh_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox73             : Gtk_Hbox;
      Ok_Button          : Gtk_Button;
      Cancel_Button      : Gtk_Button;
      Vbox19             : Gtk_Vbox;
      Table1             : Gtk_Table;
      Label206           : Gtk_Label;
      Moutput_Type_Combo : Gtk_Combo;
      Listitem2024       : Gtk_List_Item;
      Listitem2025       : Gtk_List_Item;
      Listitem2026       : Gtk_List_Item;
      Delivery_Table     : Gtk_Table;
      Label251           : Gtk_Label;
      Del_Policy_Combo   : Gtk_Combo;
      Listitem2027       : Gtk_List_Item;
      Listitem2028       : Gtk_List_Item;
      Query_Table        : Gtk_Table;
      Label252           : Gtk_Label;
      Que_Policy_Combo   : Gtk_Combo;
      Listitem2029       : Gtk_List_Item;
      Listitem2030       : Gtk_List_Item;
      Listitem2031       : Gtk_List_Item;
      Listitem2032       : Gtk_List_Item;
   end record;
   type Moeh_Dialog_Access is access all Moeh_Dialog_Record'Class;

   procedure Gtk_New (Moeh_Dialog : out Moeh_Dialog_Access);
   procedure Initialize (Moeh_Dialog : access Moeh_Dialog_Record'Class);

end Moeh_Dialog_Pkg;
