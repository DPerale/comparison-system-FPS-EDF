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
with Gtk.Arguments;
with Gtk.Widget; use Gtk.Widget;

with Gdk.Event;
with Glib.Object;              use Glib.Object;
with Glib.Values;              use Glib.Values;
with Gtk.Tree_Model;           use Gtk.Tree_Model;
with Mast.Timing_Requirements; use Mast.Timing_Requirements;
with Mast_Editor.Links;        use Mast_Editor.Links;

package Internal_Dialog_Pkg.Callbacks is

   -- Cells in the tree can be defined as editable. In this case,
   -- the user needs to double click on the cell, and an entry
   -- widget is then displayed in which the text can be modified

   procedure Deadline_Edited_Callback
     (Tree_Store : access GObject_Record'Class;
      Params     : Glib.Values.GValues);
   --  Called when the user clicks on a cell to edit the text it contains

   procedure Ratio_Edited_Callback
     (Tree_Store : access GObject_Record'Class;
      Params     : Glib.Values.GValues);

   function Func_Ref_Event_Column_Double_Click
     (Object : access Internal_Dialog_Record'Class;
      Event  : Gdk.Event.Gdk_Event)
      return   Boolean;

   procedure Add_Line
     (Tree_Store : access Gtk_Tree_Store_Record'Class;
      Req_Ref    : access Mast.Timing_Requirements.Timing_Requirement'Class;
      Parent     : Gtk_Tree_Iter := Null_Iter);
   --  Insert a new line in the tree with Timing_Req attributes

   procedure Assign_Requirement
     (Tree_Store : access Gtk_Tree_Store_Record'Class;
      Item       : access ME_Internal_Link);
   -- Read Timing_Req Attributes from tree view

   procedure On_Cancel_Button_Clicked
     (Object : access Gtk_Dialog_Record'Class);

   procedure On_Add_Req_Button_Clicked
     (Object : access Internal_Dialog_Record'Class);

   procedure On_Remove_Req_Button_Clicked
     (Object : access Internal_Dialog_Record'Class);

end Internal_Dialog_Pkg.Callbacks;
