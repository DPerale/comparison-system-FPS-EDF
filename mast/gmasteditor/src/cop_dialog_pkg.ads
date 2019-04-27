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
with Gtk.Separator; use Gtk.Separator;
with Gtk.Frame;     use Gtk.Frame;

with Glib;                   use Glib;
with Gtk.Scrolled_Window;    use Gtk.Scrolled_Window;
with Gtk.Cell_Renderer_Text; use Gtk.Cell_Renderer_Text;
with Gtk.Tree_View;          use Gtk.Tree_View;
with Gtk.Tree_Store;         use Gtk.Tree_Store;
with Gtk.Tree_View_Column;   use Gtk.Tree_View_Column;

package Cop_Dialog_Pkg is

   Op_Column : constant := 0;

   type Cop_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox101                  : Gtk_Hbox;
      Ok_Button                : Gtk_Button;
      Cancel_Button            : Gtk_Button;
      Vbox32                   : Gtk_Vbox;
      Hbox61                   : Gtk_Hbox;
      Vbox33                   : Gtk_Vbox;
      Table1                   : Gtk_Table;
      Label422                 : Gtk_Label;
      Label423                 : Gtk_Label;
      Op_Name_Entry            : Gtk_Entry;
      Op_Type_Combo            : Gtk_Combo;
      Listitem3134             : Gtk_List_Item;
      Listitem3135             : Gtk_List_Item;
      Label428                 : Gtk_Label;
      Label427                 : Gtk_Label;
      Overrid_Param_Type_Combo : Gtk_Combo;
      Listitem3136             : Gtk_List_Item;
      Listitem3137             : Gtk_List_Item;
      Listitem3138             : Gtk_List_Item;
      Overrid_Prior_Table      : Gtk_Table;
      Label429                 : Gtk_Label;
      Overrid_Prior_Entry      : Gtk_Entry;
      Exec_Time_Table          : Gtk_Table;
      Label424                 : Gtk_Label;
      Wor_Exec_Time_Entry      : Gtk_Entry;
      Label425                 : Gtk_Label;
      Avg_Exec_Time_Entry      : Gtk_Entry;
      Label426                 : Gtk_Label;
      Bes_Exec_Time_Entry      : Gtk_Entry;
      Vseparator6              : Gtk_Vseparator;
      Vbox34                   : Gtk_Vbox;
      Table2                   : Gtk_Table;
      Add_Op_Button            : Gtk_Button;
      Remove_Op_Button         : Gtk_Button;
      Frame                    : Gtk_Frame;
      Op_Label                 : Gtk_Label;
      -------------------
      Tree_Store  : Gtk_Tree_Store;
      Tree_View   : Gtk_Tree_View;
      Scrolled    : Gtk_Scrolled_Window;
      Col         : Gtk_Tree_View_Column;
      Num         : Gint;
      Text_Render : Gtk_Cell_Renderer_Text;

   end record;
   type Cop_Dialog_Access is access all Cop_Dialog_Record'Class;

   procedure Gtk_New (Cop_Dialog : out Cop_Dialog_Access);
   procedure Initialize (Cop_Dialog : access Cop_Dialog_Record'Class);

end Cop_Dialog_Pkg;
