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

with Gtk.Enums; use Gtk.Enums;

with Glib;                   use Glib;
with Gtk.Scrolled_Window;    use Gtk.Scrolled_Window;
with Gtk.Cell_Renderer_Text; use Gtk.Cell_Renderer_Text;
with Gtk.Tree_View;          use Gtk.Tree_View;
with Gtk.Tree_Store;         use Gtk.Tree_Store;
with Gtk.Tree_View_Column;   use Gtk.Tree_View_Column;

package Sop_Dialog_Pkg is

   Op_Type_Combo_Items : String_List.Glist;

   Locked_Column   : constant := 0;
   Unlocked_Column : constant := 0;

   type Sop_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox64                   : Gtk_Hbox;
      Ok_Button                : Gtk_Button;
      Cancel_Button            : Gtk_Button;
      Hbox65                   : Gtk_Hbox;
      Vbox28                   : Gtk_Vbox;
      Table1                   : Gtk_Table;
      Label404                 : Gtk_Label;
      Label405                 : Gtk_Label;
      Label406                 : Gtk_Label;
      Label407                 : Gtk_Label;
      Label408                 : Gtk_Label;
      Label410                 : Gtk_Label;
      Label409                 : Gtk_Label;
      Op_Name_Entry            : Gtk_Entry;
      Wor_Exec_Time_Entry      : Gtk_Entry;
      Avg_Exec_Time_Entry      : Gtk_Entry;
      Bes_Exec_Time_Entry      : Gtk_Entry;
      Op_Type_Combo            : Gtk_Combo;
      Listitem3129             : Gtk_List_Item;
      Listitem3130             : Gtk_List_Item;
      Overrid_Param_Type_Combo : Gtk_Combo;
      Listitem3131             : Gtk_List_Item;
      Listitem3132             : Gtk_List_Item;
      Listitem3133             : Gtk_List_Item;
      Overrid_Prior_Table      : Gtk_Table;
      Label421                 : Gtk_Label;
      Overrid_Prior_Entry      : Gtk_Entry;
      Vseparator5              : Gtk_Vseparator;
      Vbox29                   : Gtk_Vbox;
      Table2                   : Gtk_Table;
      Add_Res_Button           : Gtk_Button;
      Remove_Res_Button        : Gtk_Button;
      Lock_Frame               : Gtk_Frame;
      Label635                 : Gtk_Label;
      Unlock_Frame             : Gtk_Frame;
      Label636                 : Gtk_Label;
      -------------------
      Locked_Tree_Store  : Gtk_Tree_Store;
      Locked_Tree_View   : Gtk_Tree_View;
      Locked_Scrolled    : Gtk_Scrolled_Window;
      Locked_Col         : Gtk_Tree_View_Column;
      Locked_Num         : Gint;
      Locked_Text_Render : Gtk_Cell_Renderer_Text;

      Unlocked_Tree_Store  : Gtk_Tree_Store;
      Unlocked_Tree_View   : Gtk_Tree_View;
      Unlocked_Scrolled    : Gtk_Scrolled_Window;
      Unlocked_Col         : Gtk_Tree_View_Column;
      Unlocked_Num         : Gint;
      Unlocked_Text_Render : Gtk_Cell_Renderer_Text;

   end record;
   type Sop_Dialog_Access is access all Sop_Dialog_Record'Class;

   procedure Gtk_New (Sop_Dialog : out Sop_Dialog_Access);
   procedure Initialize (Sop_Dialog : access Sop_Dialog_Record'Class);

end Sop_Dialog_Pkg;
