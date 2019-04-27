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
package Processor_Dialog_Pkg is

   type Processor_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox23                    : Gtk_Hbox;
      Proc_Dialog_Ok_Button     : Gtk_Button;
      Proc_Dialog_Cancel_Button : Gtk_Button;
      Hbox18                    : Gtk_Hbox;
      Table1                    : Gtk_Table;
      Label26                   : Gtk_Label;
      Label68                   : Gtk_Label;
      Label29                   : Gtk_Label;
      Label30                   : Gtk_Label;
      Label31                   : Gtk_Label;
      Label35                   : Gtk_Label;
      Label36                   : Gtk_Label;
      Label37                   : Gtk_Label;
      Proc_Speed_Entry          : Gtk_Entry;
      Proc_Name_Entry           : Gtk_Entry;
      Proc_Max_Int_Pri_Entry    : Gtk_Entry;
      Proc_Min_Int_Pri_Entry    : Gtk_Entry;
      Proc_Wor_Isr_Swi_Entry    : Gtk_Entry;
      Proc_Avg_Isr_Swi_Entry    : Gtk_Entry;
      Proc_Bes_Isr_Swi_Entry    : Gtk_Entry;
      Proc_Type_Combo           : Gtk_Combo;
      Listitem1833              : Gtk_List_Item;
      Vseparator1               : Gtk_Vseparator;
      Vbox3                     : Gtk_Vbox;
      Table2                    : Gtk_Table;
      System_Timer_Type_Combo   : Gtk_Combo;
      Listitem1830              : Gtk_List_Item;
      Listitem1831              : Gtk_List_Item;
      Listitem1832              : Gtk_List_Item;
      Label59                   : Gtk_Label;
      Label55                   : Gtk_Label;
      Timer_Table               : Gtk_Table;
      Label56                   : Gtk_Label;
      Label57                   : Gtk_Label;
      Label58                   : Gtk_Label;
      Proc_Period_Label         : Gtk_Label;
      Proc_Wor_Over_Entry       : Gtk_Entry;
      Proc_Avg_Over_Entry       : Gtk_Entry;
      Proc_Bes_Over_Entry       : Gtk_Entry;
      Proc_Period_Entry         : Gtk_Entry;
      New_Primary_Button        : Gtk_Button;
   end record;
   type Processor_Dialog_Access is access all Processor_Dialog_Record'Class;

   procedure Gtk_New (Processor_Dialog : out Processor_Dialog_Access);
   procedure Initialize
     (Processor_Dialog : access Processor_Dialog_Record'Class);

end Processor_Dialog_Pkg;
