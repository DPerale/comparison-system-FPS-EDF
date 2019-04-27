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
with Gtk.Dialog;      use Gtk.Dialog;
with Gtk.Button;      use Gtk.Button;
with Gtk.Object;      use Gtk.Object;
with Gtk.Box;         use Gtk.Box;
with Gtk.Alignment;   use Gtk.Alignment;
with Gtk.Image;       use Gtk.Image;
with Gtk.Label;       use Gtk.Label;
with Gtk.Table;       use Gtk.Table;
with Gtk.Text_View;   use Gtk.Text_View;
with Gtk.Text_Buffer; use Gtk.Text_Buffer;
with Gtk.Text_Iter;   use Gtk.Text_Iter;
package Wizard_Completed_Dialog_Pkg is

   type Wizard_Completed_Dialog_Record is new Gtk_Dialog_Record with record
      Cancel_Button : Gtk_Button;
      Alignment21   : Gtk_Alignment;
      Hbox97        : Gtk_Hbox;
      Image28       : Gtk_Image;
      Label604      : Gtk_Label;
      Back_Button   : Gtk_Button;
      Alignment22   : Gtk_Alignment;
      Hbox98        : Gtk_Hbox;
      Image29       : Gtk_Image;
      Label605      : Gtk_Label;
      Apply_Button  : Gtk_Button;
      Alignment23   : Gtk_Alignment;
      Hbox99        : Gtk_Hbox;
      Image30       : Gtk_Image;
      Label606      : Gtk_Label;
      Table1        : Gtk_Table;
      Label         : Gtk_Label;
      Textview      : Gtk_Text_View;
      Image         : Gtk_Image;
   end record;
   type Wizard_Completed_Dialog_Access is access 
     Wizard_Completed_Dialog_Record'Class;

   procedure Gtk_New
     (Wizard_Completed_Dialog : out Wizard_Completed_Dialog_Access);
   procedure Initialize
     (Wizard_Completed_Dialog : access Wizard_Completed_Dialog_Record'Class);

end Wizard_Completed_Dialog_Pkg;
