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
with Gtk.Combo;     use Gtk.Combo;
with Gtk.List_Item; use Gtk.List_Item;
package Wizard_Input_Dialog_Pkg is

   type Wizard_Input_Dialog_Record is new Gtk_Dialog_Record with record
      Cancel_Button             : Gtk_Button;
      Alignment12               : Gtk_Alignment;
      Hbox88                    : Gtk_Hbox;
      Image15                   : Gtk_Image;
      Label542                  : Gtk_Label;
      Back_Button               : Gtk_Button;
      Alignment13               : Gtk_Alignment;
      Hbox89                    : Gtk_Hbox;
      Image16                   : Gtk_Image;
      Label543                  : Gtk_Label;
      Next_Button               : Gtk_Button;
      Alignment14               : Gtk_Alignment;
      Hbox90                    : Gtk_Hbox;
      Image17                   : Gtk_Image;
      Label544                  : Gtk_Label;
      Table3                    : Gtk_Table;
      Image                     : Gtk_Image;
      Label                     : Gtk_Label;
      Frame3                    : Gtk_Frame;
      Vbox31                    : Gtk_Vbox;
      Table1                    : Gtk_Table;
      Label546                  : Gtk_Label;
      Label547                  : Gtk_Label;
      External_Event_Name_Entry : Gtk_Entry;
      External_Event_Type_Combo : Gtk_Combo;
      Listitem2971              : Gtk_List_Item;
      Listitem2972              : Gtk_List_Item;
      Listitem2973              : Gtk_List_Item;
      Listitem2974              : Gtk_List_Item;
      Listitem2975              : Gtk_List_Item;
      Periodic_Table            : Gtk_Table;
      Label548                  : Gtk_Label;
      Label549                  : Gtk_Label;
      Label550                  : Gtk_Label;
      Max_Jitter_Entry          : Gtk_Entry;
      Period_Entry              : Gtk_Entry;
      Per_Phase_Entry           : Gtk_Entry;
      Singular_Table            : Gtk_Table;
      Label551                  : Gtk_Label;
      Sing_Phase_Entry          : Gtk_Entry;
      Sporadic_Table            : Gtk_Table;
      Label552                  : Gtk_Label;
      Label553                  : Gtk_Label;
      Spo_Avg_Entry             : Gtk_Entry;
      Spo_Min_Entry             : Gtk_Entry;
      Spo_Dist_Func_Combo       : Gtk_Combo;
      Listitem2967              : Gtk_List_Item;
      Listitem2968              : Gtk_List_Item;
      Label554                  : Gtk_Label;
      Unbounded_Table           : Gtk_Table;
      Unb_Avg_Entry             : Gtk_Entry;
      Label555                  : Gtk_Label;
      Unb_Dist_Func_Combo       : Gtk_Combo;
      Listitem2978              : Gtk_List_Item;
      Listitem2979              : Gtk_List_Item;
      Label556                  : Gtk_Label;
      Bursty_Table              : Gtk_Table;
      Label557                  : Gtk_Label;
      Label558                  : Gtk_Label;
      Bur_Avg_Entry             : Gtk_Entry;
      Bur_Bound_Entry           : Gtk_Entry;
      Bur_Dist_Func_Combo       : Gtk_Combo;
      Listitem2969              : Gtk_List_Item;
      Listitem2970              : Gtk_List_Item;
      Label559                  : Gtk_Label;
      Label560                  : Gtk_Label;
      Max_Arrival_Entry         : Gtk_Entry;
      Frame_Label               : Gtk_Label;
   end record;
   type Wizard_Input_Dialog_Access is access Wizard_Input_Dialog_Record'Class;

   procedure Gtk_New (Wizard_Input_Dialog : out Wizard_Input_Dialog_Access);
   procedure Initialize
     (Wizard_Input_Dialog : access Wizard_Input_Dialog_Record'Class);

end Wizard_Input_Dialog_Pkg;
