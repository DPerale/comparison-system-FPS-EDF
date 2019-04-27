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
with Gtk.Button;    use Gtk.Button;
with Gtk.Object;    use Gtk.Object;
with Gtk.Box;       use Gtk.Box;
with Gtk.Alignment; use Gtk.Alignment;
with Gtk.Image;     use Gtk.Image;
with Gtk.Label;     use Gtk.Label;
with Gtk.Table;     use Gtk.Table;
with Gtk.Frame;     use Gtk.Frame;
with Gtk.GEntry;    use Gtk.GEntry;
with Glib.Unicode;  use Glib.Unicode;
package Wizard_Output_Dialog_Pkg is

   type Wizard_Output_Dialog_Record is new Gtk_Dialog_Record with record
      Cancel_Button    : Gtk_Button;
      Alignment18      : Gtk_Alignment;
      Hbox94           : Gtk_Hbox;
      Image23          : Gtk_Image;
      Label588         : Gtk_Label;
      Back_Button      : Gtk_Button;
      Alignment19      : Gtk_Alignment;
      Hbox95           : Gtk_Hbox;
      Image24          : Gtk_Image;
      Label589         : Gtk_Label;
      Next_Button      : Gtk_Button;
      Alignment20      : Gtk_Alignment;
      Hbox96           : Gtk_Hbox;
      Image25          : Gtk_Image;
      Label590         : Gtk_Label;
      Table5           : Gtk_Table;
      Image            : Gtk_Image;
      Label            : Gtk_Label;
      Frame5           : Gtk_Frame;
      Vbox51           : Gtk_Vbox;
      Table1           : Gtk_Table;
      Label600         : Gtk_Label;
      Event_Name_Entry : Gtk_Entry;
      Label611         : Gtk_Label;
      Deadline_Entry   : Gtk_Entry;
      Frame_Label      : Gtk_Label;
   end record;
   type Wizard_Output_Dialog_Access is access Wizard_Output_Dialog_Record'
     Class;

   procedure Gtk_New
     (Wizard_Output_Dialog : out Wizard_Output_Dialog_Access);
   procedure Initialize
     (Wizard_Output_Dialog : access Wizard_Output_Dialog_Record'Class);

end Wizard_Output_Dialog_Pkg;
