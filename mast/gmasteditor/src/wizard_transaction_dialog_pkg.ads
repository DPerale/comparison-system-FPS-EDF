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
package Wizard_Transaction_Dialog_Pkg is

   type Wizard_Transaction_Dialog_Record is new Gtk_Dialog_Record with record
      Cancel_Button    : Gtk_Button;
      Alignment9       : Gtk_Alignment;
      Hbox84           : Gtk_Hbox;
      Image12          : Gtk_Image;
      Label538         : Gtk_Label;
      Back_Button      : Gtk_Button;
      Alignment10      : Gtk_Alignment;
      Hbox85           : Gtk_Hbox;
      Image13          : Gtk_Image;
      Label539         : Gtk_Label;
      Next_Button      : Gtk_Button;
      Alignment11      : Gtk_Alignment;
      Hbox86           : Gtk_Hbox;
      Image14          : Gtk_Image;
      Label540         : Gtk_Label;
      Table2           : Gtk_Table;
      Image            : Gtk_Image;
      Label            : Gtk_Label;
      Frame2           : Gtk_Frame;
      Hbox87           : Gtk_Hbox;
      Name_Label       : Gtk_Label;
      Trans_Name_Entry : Gtk_Entry;
   end record;
   type Wizard_Transaction_Dialog_Access is access 
     Wizard_Transaction_Dialog_Record'Class;

   procedure Gtk_New
     (Wizard_Transaction_Dialog : out Wizard_Transaction_Dialog_Access);
   procedure Initialize
     (Wizard_Transaction_Dialog : access Wizard_Transaction_Dialog_Record'
     Class);

end Wizard_Transaction_Dialog_Pkg;
