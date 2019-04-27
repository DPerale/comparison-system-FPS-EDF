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
with Gtk.Dialog;          use Gtk.Dialog;
with Gtk.Box;             use Gtk.Box;
with Gtk.Button;          use Gtk.Button;
with Gtk.Table;           use Gtk.Table;
with Gtk.GEntry;          use Gtk.GEntry;
with Glib.Unicode;        use Glib.Unicode;
with Gtk.Combo;           use Gtk.Combo;
with Gtk.List_Item;       use Gtk.List_Item;
with Gtk.Label;           use Gtk.Label;
with Gtk.Frame;           use Gtk.Frame;
with Gtk.Scrolled_Window; use Gtk.Scrolled_Window;
with Gtkada.Canvas;       use Gtkada.Canvas;

package Trans_Dialog_Pkg is

   type Trans_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox                 : Gtk_Hbox;
      Ok_Button            : Gtk_Button;
      Cancel_Button        : Gtk_Button;
      Table2               : Gtk_Table;
      Trans_Name_Entry     : Gtk_Entry;
      Trans_Type_Combo     : Gtk_Combo;
      Listitem2616         : Gtk_List_Item;
      Trans_Name_Label     : Gtk_Label;
      Trans_Type_Label     : Gtk_Label;
      Trans_Diagram_Label  : Gtk_Label;
      Table                : Gtk_Table;
      Frame                : Gtk_Frame;
      Scrolled             : Gtk_Scrolled_Window;
      Events_Frame         : Gtk_Frame;
      Vbox51               : Gtk_Vbox;
      Add_Ext_Button       : Gtk_Button;
      Add_Int_Button       : Gtk_Button;
      Events_Label         : Gtk_Label;
      Handlers_Frame       : Gtk_Frame;
      Vbox52               : Gtk_Vbox;
      Add_Simple_Button    : Gtk_Button;
      Add_Minput_Button    : Gtk_Button;
      Add_Moutput_Button   : Gtk_Button;
      Event_Handlers_Label : Gtk_Label;
      ------------
      Trans_Canvas : Gtkada.Canvas.Interactive_Canvas;
   end record;
   type Trans_Dialog_Access is access Trans_Dialog_Record'Class;

   procedure Gtk_New (Trans_Dialog : out Trans_Dialog_Access);
   procedure Initialize (Trans_Dialog : access Trans_Dialog_Record'Class);

end Trans_Dialog_Pkg;
