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
with Gtk.Combo;     use Gtk.Combo;
with Gtk.GEntry;    use Gtk.GEntry;
with Glib.Unicode;  use Glib.Unicode;
with Gtk.List_Item; use Gtk.List_Item;
package Wizard_Activity_Dialog_Pkg is

   type Wizard_Activity_Dialog_Record is new Gtk_Dialog_Record with record
      Cancel_Button         : Gtk_Button;
      Alignment15           : Gtk_Alignment;
      Hbox91                : Gtk_Hbox;
      Image19               : Gtk_Image;
      Label561              : Gtk_Label;
      Back_Button           : Gtk_Button;
      Alignment16           : Gtk_Alignment;
      Hbox92                : Gtk_Hbox;
      Image20               : Gtk_Image;
      Label562              : Gtk_Label;
      Next_Button           : Gtk_Button;
      Alignment17           : Gtk_Alignment;
      Hbox93                : Gtk_Hbox;
      Image21               : Gtk_Image;
      Label563              : Gtk_Label;
      Table4                : Gtk_Table;
      Image                 : Gtk_Image;
      Label                 : Gtk_Label;
      Frame4                : Gtk_Frame;
      Vbox41                : Gtk_Vbox;
      Table1                : Gtk_Table;
      Label581              : Gtk_Label;
      Seh_Type_Combo        : Gtk_Combo;
      Listitem2976          : Gtk_List_Item;
      Listitem2977          : Gtk_List_Item;
      Op_Frame              : Gtk_Frame;
      Op_Table              : Gtk_Table;
      Label583              : Gtk_Label;
      Label582              : Gtk_Label;
      Wor_Exec_Time_Entry   : Gtk_Entry;
      Op_Name_Entry         : Gtk_Entry;
      Op_Frame_Label        : Gtk_Label;
      Serv_Frame            : Gtk_Frame;
      Serv_Table            : Gtk_Table;
      Label609              : Gtk_Label;
      Label610              : Gtk_Label;
      Server_Name_Entry     : Gtk_Entry;
      Server_Priority_Entry : Gtk_Entry;
      Serv_Frame_Label      : Gtk_Label;
      Frame_Label           : Gtk_Label;
   end record;
   type Wizard_Activity_Dialog_Access is access Wizard_Activity_Dialog_Record'
     Class;

   procedure Gtk_New
     (Wizard_Activity_Dialog : out Wizard_Activity_Dialog_Access);
   procedure Initialize
     (Wizard_Activity_Dialog : access Wizard_Activity_Dialog_Record'Class);

end Wizard_Activity_Dialog_Pkg;
