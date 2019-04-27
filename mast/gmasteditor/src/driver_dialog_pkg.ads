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
with Gtk.Combo;     use Gtk.Combo;
with Gtk.GEntry;    use Gtk.GEntry;
with Glib.Unicode;  use Glib.Unicode;
with Gtk.List_Item; use Gtk.List_Item;
with Gtk.Label;     use Gtk.Label;

package Driver_Dialog_Pkg is

   type Driver_Dialog_Record is new Gtk_Dialog_Record with record
      Hbox27                            : Gtk_Hbox;
      Driver_Ok_Button                  : Gtk_Button;
      Driver_Cancel_Button              : Gtk_Button;
      Packet_Server_Table               : Gtk_Table;
      New_Operation_Button              : Gtk_Button;
      New_Server_Button                 : Gtk_Button;
      Packet_Server_Combo               : Gtk_Combo;
      Listitem3082                      : Gtk_List_Item;
      Packet_Send_Op_Combo              : Gtk_Combo;
      Listitem3083                      : Gtk_List_Item;
      Packet_Rece_Op_Combo              : Gtk_Combo;
      Listitem3084                      : Gtk_List_Item;
      Driver_Type_Combo                 : Gtk_Combo;
      Listitem3079                      : Gtk_List_Item;
      Listitem3080                      : Gtk_List_Item;
      Listitem3081                      : Gtk_List_Item;
      Message_Partitioning_Combo        : Gtk_Combo;
      Listitem3089                      : Gtk_List_Item;
      Listitem3090                      : Gtk_List_Item;
      Rta_Overhead_Model_Combo          : Gtk_Combo;
      Listitem3100                      : Gtk_List_Item;
      Listitem3101                      : Gtk_List_Item;
      Label621                          : Gtk_Label;
      Label620                          : Gtk_Label;
      Label89                           : Gtk_Label;
      Label90                           : Gtk_Label;
      Label91                           : Gtk_Label;
      Label92                           : Gtk_Label;
      Character_Server_Table            : Gtk_Table;
      Char_Tx_Time_Entry                : Gtk_Entry;
      Char_Rece_Op_Combo                : Gtk_Combo;
      Listitem3087                      : Gtk_List_Item;
      Char_Send_Op_Combo                : Gtk_Combo;
      Listitem3086                      : Gtk_List_Item;
      Char_Server_Combo                 : Gtk_Combo;
      Listitem3085                      : Gtk_List_Item;
      Label102                          : Gtk_Label;
      Label103                          : Gtk_Label;
      Label104                          : Gtk_Label;
      Label478                          : Gtk_Label;
      Rtep_Table                        : Gtk_Table;
      Num_Of_Stations_Entry             : Gtk_Entry;
      Token_Delay_Entry                 : Gtk_Entry;
      Failure_Timeout_Entry             : Gtk_Entry;
      Label624                          : Gtk_Label;
      Label623                          : Gtk_Label;
      Label622                          : Gtk_Label;
      Token_Transmission_Retries_Entry  : Gtk_Entry;
      Packet_Transmission_Retries_Entry : Gtk_Entry;
      Label629                          : Gtk_Label;
      Label630                          : Gtk_Label;
      Label631                          : Gtk_Label;
      Label632                          : Gtk_Label;
      Label633                          : Gtk_Label;
      Packet_Interrupt_Server_Combo     : Gtk_Combo;
      Listitem3102                      : Gtk_List_Item;
      Packet_Isr_Op_Combo               : Gtk_Combo;
      Listitem3109                      : Gtk_List_Item;
      Token_Check_Op_Combo              : Gtk_Combo;
      Listitem3110                      : Gtk_List_Item;
      Token_Manage_Op_Combo             : Gtk_Combo;
      Listitem3111                      : Gtk_List_Item;
      Packet_Discard_Op_Combo           : Gtk_Combo;
      Listitem3112                      : Gtk_List_Item;
      Token_Retransmission_Op_Combo     : Gtk_Combo;
      Listitem3113                      : Gtk_List_Item;
      Packet_Retransmission_Op_Combo    : Gtk_Combo;
      Listitem3114                      : Gtk_List_Item;
      Label628                          : Gtk_Label;
      Label627                          : Gtk_Label;
      Label626                          : Gtk_Label;
      Label625                          : Gtk_Label;
   end record;
   type Driver_Dialog_Access is access all Driver_Dialog_Record'Class;

   procedure Gtk_New (Driver_Dialog : out Driver_Dialog_Access);
   procedure Initialize (Driver_Dialog : access Driver_Dialog_Record'Class);

end Driver_Dialog_Pkg;
