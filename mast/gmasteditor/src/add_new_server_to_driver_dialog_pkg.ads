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
with Gtk.Dialog;       use Gtk.Dialog;
with Gtk.Box;          use Gtk.Box;
with Gtk.Button;       use Gtk.Button;
with Gtk.Table;        use Gtk.Table;
with Gtk.Check_Button; use Gtk.Check_Button;
with Gtk.Label;        use Gtk.Label;
package Add_New_Server_To_Driver_Dialog_Pkg is

   type Add_New_Server_To_Driver_Dialog_Record is new Gtk_Dialog_Record with
      record
         Hbox3                    : Gtk_Hbox;
         Ok_Button                : Gtk_Button;
         Cancel_Button            : Gtk_Button;
         Table1                   : Gtk_Table;
         Packet_Server_Button     : Gtk_Check_Button;
         Character_Server_Button  : Gtk_Check_Button;
         Label1                   : Gtk_Label;
         Packet_Int_Server_Button : Gtk_Check_Button;
      end record;
   type Add_New_Server_To_Driver_Dialog_Access is access all 
     Add_New_Server_To_Driver_Dialog_Record'Class;

   procedure Gtk_New
     (Add_New_Server_To_Driver_Dialog : out
     Add_New_Server_To_Driver_Dialog_Access);
   procedure Initialize
     (Add_New_Server_To_Driver_Dialog : access 
     Add_New_Server_To_Driver_Dialog_Record'Class);

end Add_New_Server_To_Driver_Dialog_Pkg;
