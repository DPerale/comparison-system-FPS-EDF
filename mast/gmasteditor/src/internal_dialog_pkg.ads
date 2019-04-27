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
with Gtk.Frame;     use Gtk.Frame;

with Glib;                   use Glib;
with Gtk.Scrolled_Window;    use Gtk.Scrolled_Window;
with Gtk.Cell_Renderer_Text; use Gtk.Cell_Renderer_Text;
with Gtk.Tree_View;          use Gtk.Tree_View;
with Gtk.Tree_Store;         use Gtk.Tree_Store;
with Gtk.Tree_View_Column;   use Gtk.Tree_View_Column;

package Internal_Dialog_Pkg is

   Editable_Column      : constant := 0;
   Type_Column          : constant := 1;
   Deadline_Column      : constant := 2;
   Deadline_Val_Column  : constant := 3;
   Ref_Event_Column     : constant := 4;
   Ref_Event_Val_Column : constant := 5;
   Ratio_Column         : constant := 6;
   Ratio_Val_Column     : constant := 7;
   Foreground_Column    : constant := 8;
   Background_Column    : constant := 9;

   type Internal_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox70                    : Gtk_Hbox;
      Ok_Button                 : Gtk_Button;
      Cancel_Button             : Gtk_Button;
      Vbox16                    : Gtk_Vbox;
      Table1                    : Gtk_Table;
      Label183                  : Gtk_Label;
      Label184                  : Gtk_Label;
      Event_Name_Entry          : Gtk_Entry;
      Internal_Event_Type_Combo : Gtk_Combo;
      Listitem2048              : Gtk_List_Item;
      Timing_Table              : Gtk_Table;
      Timing_Label              : Gtk_Label;
      Add_Req_Button            : Gtk_Button;
      Remove_Req_Button         : Gtk_Button;
      Frame                     : Gtk_Frame;
      -------------------
      Tree_Store            : Gtk_Tree_Store;
      Tree_View             : Gtk_Tree_View;
      Scrolled              : Gtk_Scrolled_Window;
      Col, Ref_Event_Col    : Gtk_Tree_View_Column;
      Num                   : Gint;
      Text_Render           : Gtk_Cell_Renderer_Text;
      Deadline_Edit_Render  : Gtk_Cell_Renderer_Text;
      Ref_Event_Edit_Render : Gtk_Cell_Renderer_Text;
      Ratio_Edit_Render     : Gtk_Cell_Renderer_Text;

   end record;
   type Internal_Dialog_Access is access all Internal_Dialog_Record'Class;

   procedure Gtk_New (Internal_Dialog : out Internal_Dialog_Access);
   procedure Initialize
     (Internal_Dialog : access Internal_Dialog_Record'Class);

end Internal_Dialog_Pkg;
