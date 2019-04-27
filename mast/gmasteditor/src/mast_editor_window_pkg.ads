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
with Gtk.Window;              use Gtk.Window;
with Gtk.Box;                 use Gtk.Box;
with Gtk.Menu_Bar;            use Gtk.Menu_Bar;
with Gtk.Menu_Item;           use Gtk.Menu_Item;
with Gtk.Menu;                use Gtk.Menu;
with Gtk.Accel_Group;         use Gtk.Accel_Group;
with Gdk.Types.Keysyms;       use Gdk.Types.Keysyms;
with Gtk.Tooltips;            use Gtk.Tooltips;
with Gtk.Separator_Menu_Item; use Gtk.Separator_Menu_Item;
with Gtk.Notebook;            use Gtk.Notebook;
with Gtk.Frame;               use Gtk.Frame;
with Gtk.Label;               use Gtk.Label;
with Gtk.Button;              use Gtk.Button;
package Mast_Editor_Window_Pkg is

   type Mast_Editor_Window_Record is new Gtk_Window_Record with record
      Vbox_Main_Window          : Gtk_Vbox;
      Menubar                   : Gtk_Menu_Bar;
      File                      : Gtk_Menu_Item;
      File_Menu                 : Gtk_Menu;
      New1                      : Gtk_Menu_Item;
      Open                      : Gtk_Menu_Item;
      Import                    : Gtk_Menu_Item;
      Save                      : Gtk_Menu_Item;
      Save_As                   : Gtk_Menu_Item;
      Separator1                : Gtk_Separator_Menu_Item;
      Quit                      : Gtk_Menu_Item;
      Edition_Tools             : Gtk_Menu_Item;
      Edition_Tools_Menu        : Gtk_Menu;
      Create_Simple_Transaction : Gtk_Menu_Item;
      --Create_Linear_Transaction : Gtk_Menu_Item;
      Analyze            : Gtk_Menu_Item;
      Analyze_Menu       : Gtk_Menu;
      Analysis           : Gtk_Menu_Item;
      Simulation         : Gtk_Menu_Item;
      Results            : Gtk_Menu_Item;
      Results_Menu       : Gtk_Menu;
      View_Results       : Gtk_Menu_Item;
      Help               : Gtk_Menu_Item;
      Help_Menu          : Gtk_Menu;
      About              : Gtk_Menu_Item;
      Notebook           : Gtk_Notebook;
      Vbox1_Notebook     : Gtk_Vbox;
      Proc_Res_Frame     : Gtk_Frame;
      Label1             : Gtk_Label;
      Vbox2_Notebook     : Gtk_Vbox;
      Sched_Server_Frame : Gtk_Frame;
      Label2             : Gtk_Label;
      Vbox3_Notebook     : Gtk_Vbox;
      Shared_Res_Frame   : Gtk_Frame;
      Label3             : Gtk_Label;
      Vbox4_Notebook     : Gtk_Vbox;
      Operations_Frame   : Gtk_Frame;
      Label4             : Gtk_Label;
      Vbox5_Notebook     : Gtk_Vbox;
      Transactions_Frame : Gtk_Frame;
      Label5             : Gtk_Label;
   end record;
   type Mast_Editor_Window_Access is access Mast_Editor_Window_Record'Class;

   procedure Gtk_New (Mast_Editor_Window : out Mast_Editor_Window_Access);
   procedure Initialize
     (Mast_Editor_Window : access Mast_Editor_Window_Record'Class);

   Mast_Editor_Window : Mast_Editor_Window_Access;

end Mast_Editor_Window_Pkg;
