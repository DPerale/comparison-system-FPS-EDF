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
with Gtk.GEntry;    use Gtk.GEntry;
with Glib.Unicode;  use Glib.Unicode;
with Gtk.Label;     use Gtk.Label;
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

package Network_Dialog_Pkg is

   Server_Column    : constant := 0;
   Processor_Column : constant := 1;

   type Network_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox24                : Gtk_Hbox;
      Network_Ok_Button     : Gtk_Button;
      Network_Cancel_Button : Gtk_Button;
      Hbox20                : Gtk_Hbox;
      Table3                : Gtk_Table;
      Max_Pack_Size_Entry   : Gtk_Entry;
      Min_Pack_Size_Entry   : Gtk_Entry;
      Label50               : Gtk_Label;
      Label52               : Gtk_Label;
      Label48               : Gtk_Label;
      Net_Name_Entry        : Gtk_Entry;
      Label352              : Gtk_Label;
      Net_Type_Combo        : Gtk_Combo;
      Listitem1837          : Gtk_List_Item;
      Label41               : Gtk_Label;
      Net_Speed_Entry       : Gtk_Entry;
      Label42               : Gtk_Label;
      Tx_Kind_Combo         : Gtk_Combo;
      Listitem1846          : Gtk_List_Item;
      Listitem1847          : Gtk_List_Item;
      Listitem1848          : Gtk_List_Item;
      Label43               : Gtk_Label;
      Net_Max_Blo_Entry     : Gtk_Entry;
      Label353              : Gtk_Label;
      Throughput_Entry      : Gtk_Entry;
      Vseparator2           : Gtk_Vseparator;
      Table5                : Gtk_Table;
      Add_Driver_Button     : Gtk_Button;
      Remove_Driver_Button  : Gtk_Button;
      New_Primary_Button    : Gtk_Button;
      Frame                 : Gtk_Frame;
      Label637              : Gtk_Label;
      -------------------
      Tree_Store  : Gtk_Tree_Store;
      Tree_View   : Gtk_Tree_View;
      Scrolled    : Gtk_Scrolled_Window;
      Col         : Gtk_Tree_View_Column;
      Num         : Gint;
      Text_Render : Gtk_Cell_Renderer_Text;

   end record;
   type Network_Dialog_Access is access all Network_Dialog_Record'Class;

   procedure Gtk_New (Network_Dialog : out Network_Dialog_Access);
   procedure Initialize
     (Network_Dialog : access Network_Dialog_Record'Class);

end Network_Dialog_Pkg;
