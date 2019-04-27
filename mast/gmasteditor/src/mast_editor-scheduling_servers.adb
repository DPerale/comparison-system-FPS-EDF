-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                           GMastEditor                             --
--          Graphical Editor for Modelling and Analysis              --
--                    of Real-Time Applications                      --
--                                                                   --
--                       Copyright (C) 2005-2008                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors : Pilar del Rio                                           --
--           Michael Gonzalez                                        --
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
with Ada.Tags;                use Ada.Tags;
with Ada.Text_IO;             use Ada.Text_IO;
with Ada.Characters.Handling;

with Callbacks_Mast_Editor; use Callbacks_Mast_Editor;
with Gdk.Color;             use Gdk.Color;
with Gdk.Drawable;          use Gdk.Drawable;
with Gdk.Font;              use Gdk.Font;
with Gdk.Rectangle;         use Gdk.Rectangle;
with Gtk.Alignment;         use Gtk.Alignment;
with Gtk.Box;               use Gtk.Box;
with Gtk.Button;            use Gtk.Button;
with Gtk.Combo;             use Gtk.Combo;
with Gtk.Frame;             use Gtk.Frame;
with Gtk.GEntry;            use Gtk.GEntry;
with Gtk.Handlers;          use Gtk.Handlers;
with Gtk.Label;             use Gtk.Label;
with Gtk.Scrolled_Window;   use Gtk.Scrolled_Window;
with Gtk.Separator;         use Gtk.Separator;
with Gtk.Table;             use Gtk.Table;
with Gtk.Widget;            use Gtk.Widget;
with Gtkada.Canvas;         use Gtkada.Canvas;
with Pango.Font;            use Pango.Font;
with Gtkada.Dialogs;        use Gtkada.Dialogs;

with List_Exceptions;                 use List_Exceptions;
with Mast;                            use Mast;
with Mast.IO;                         use Mast.IO;
with Mast.Schedulers;                 use Mast.Schedulers;
with Mast.Schedulers.Primary;         use Mast.Schedulers.Primary;
with Mast.Schedulers.Secondary;       use Mast.Schedulers.Secondary;
with Mast.Scheduling_Parameters;      use Mast.Scheduling_Parameters;
with Mast.Scheduling_Policies;        use Mast.Scheduling_Policies;
with Mast.Scheduling_Servers;         use Mast.Scheduling_Servers;
with Mast.Synchronization_Parameters; use Mast.Synchronization_Parameters;
with Mast.Transactions;
with Mast_Editor.Schedulers;          use Mast_Editor.Schedulers;
with Item_Menu_Pkg;                   use Item_Menu_Pkg;
with Editor_Error_Window_Pkg;         use Editor_Error_Window_Pkg;
with Sched_Server_Dialog_Pkg;         use Sched_Server_Dialog_Pkg;
with Editor_Actions;                  use Editor_Actions;
with Change_Control;

package body Mast_Editor.Scheduling_Servers is

   package Canvas_Cb is new Gtk.Handlers.Callback (
      Interactive_Canvas_Record);

   package Button_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Scheduling_Server_Ref);

   Zoom_Levels : constant array (Positive range <>) of Guint  :=
     (100,
      130,
      150);
   Font        : Pango_Font_Description;
   Font1       : Pango_Font_Description;
   Green_Gc    : Gdk.GC.Gdk_GC;

   -------------------------------------------------
   -- Types and packages used to handle dialogs info
   -------------------------------------------------

   type ME_Scheduling_Server_And_Dialog is record
      It  : ME_Scheduling_Server_Ref;
      Dia : Gtk_Dialog;
   end record;

   type ME_Scheduling_Server_And_Dialog_Ref is access all
     ME_Scheduling_Server_And_Dialog;

   package Me_Scheduling_Server_And_Dialog_Cb is new
     Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Scheduling_Server_And_Dialog_Ref);

   --------------
   -- Name     --
   --------------
   function Name (Item : in ME_Scheduling_Server) return Var_String is
   begin
      return Name (Item.Ser);
   end Name;

   --------------
   -- Name     --
   --------------
   function Name (Item_Ref : in ME_Scheduling_Server_Ref) return Var_String is
   begin
      return Name (Item_Ref.Ser);
   end Name;

   -----------------
   -- Print       --
   -----------------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Scheduling_Server;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Ada.Text_IO.Set_Col (File, Ada.Text_IO.Count (Indentation));
      Ada.Text_IO.Put (File, "ME_Scheduling_Server");
   end Print;

   -----------------
   -- Print       --
   -----------------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive)
   is
      Item_Ref : ME_Scheduling_Server_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind (The_List, Iterator);
      for I in 1 .. Lists.Size (The_List) loop
         Lists.Get_Next_Item (Item_Ref, The_List, Iterator);
         Print (File, Item_Ref.all, Indentation, True);
         Ada.Text_IO.New_Line (File);
      end loop;
   end Print;

   ----------------------
   -- Write Parameters --
   ----------------------
   procedure Write_Parameters
     (Item   : access ME_Server;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Serv_Ref            : Scheduling_Server_Ref      :=
        ME_Scheduling_Server_Ref (Item).Ser;
      Sche_Ref            : Mast.Schedulers.Scheduler_Ref;
      Sche_Name           : Var_String;
      Sche_Index          : Mast.Schedulers.Lists.Index;
      Sche_Param_Ref      : Mast.Scheduling_Parameters.Sched_Parameters_Ref;
      Sync_Param_Ref      :
        Mast.Synchronization_Parameters.Synch_Parameters_Ref;
      Sched_Server_Dialog : Sched_Server_Dialog_Access :=
         Sched_Server_Dialog_Access (Dialog);
   begin
      Change_Control.Changes_Made;
      Init
        (Serv_Ref.all,
         Var_Strings.To_Lower
            (To_Var_String
                (Get_Text (Sched_Server_Dialog.Server_Name_Entry))));
      Sche_Ref := Mast.Scheduling_Servers.Server_Scheduler (Serv_Ref.all);
      if (Get_Text (Get_Entry (Sched_Server_Dialog.Sched_Combo)) =
          "(NONE)")
      then
         Sche_Ref := null;
         Mast.Scheduling_Servers.Set_Server_Scheduler
           (Serv_Ref.all,
            Sche_Ref);
      else
         Sche_Name  :=
            To_Var_String
              (Get_Text (Get_Entry (Sched_Server_Dialog.Sched_Combo)));
         Sche_Index :=
            Mast.Schedulers.Lists.Find (Sche_Name, The_System.Schedulers);
         Sche_Ref   :=
            Mast.Schedulers.Lists.Item (Sche_Index, The_System.Schedulers);
         Mast.Scheduling_Servers.Set_Server_Scheduler
           (Serv_Ref.all,
            Sche_Ref);
      end if;

      Sche_Param_Ref := Server_Sched_Parameters (Serv_Ref.all);
      if (Get_Text (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo)) =
          "(NONE)")
      then
         Sche_Param_Ref := null;
      elsif (Get_Text (Get_Entry
                          (Sched_Server_Dialog.Policy_Type_Combo)) =
             "Non Preemptible Fixed Priority")
      then
         Sche_Param_Ref :=
           new Mast.Scheduling_Parameters.Non_Preemptible_FP_Policy;
         if (Get_Text (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo)) =
             "YES")
         then
            Set_Preassigned
              (Non_Preemptible_FP_Policy (Sche_Param_Ref.all),
               True);
         else
            Set_Preassigned
              (Non_Preemptible_FP_Policy (Sche_Param_Ref.all),
               False);
         end if;
         Set_The_Priority
           (Non_Preemptible_FP_Policy (Sche_Param_Ref.all),
            Priority'Value
               (Get_Text (Sched_Server_Dialog.Server_Priority_Entry)));
      elsif (Get_Text (Get_Entry
                          (Sched_Server_Dialog.Policy_Type_Combo)) =
             "Fixed Priority")
      then
         Sche_Param_Ref :=
           new Mast.Scheduling_Parameters.Fixed_Priority_Policy;
         if (Get_Text (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo)) =
             "YES")
         then
            Set_Preassigned
              (Mast.Scheduling_Parameters.Fixed_Priority_Policy (
              Sche_Param_Ref.all),
               True);
         else
            Set_Preassigned
              (Mast.Scheduling_Parameters.Fixed_Priority_Policy (
              Sche_Param_Ref.all),
               False);
         end if;
         Set_The_Priority
           (Mast.Scheduling_Parameters.Fixed_Priority_Policy
            (Sche_Param_Ref.all),
            Priority'Value
               (Get_Text (Sched_Server_Dialog.Server_Priority_Entry)));
      elsif (Get_Text (Get_Entry
                          (Sched_Server_Dialog.Policy_Type_Combo)) =
             "Interrupt Fixed Priority")
      then
         Sche_Param_Ref := new Mast.Scheduling_Parameters.Interrupt_FP_Policy;
         Set_The_Priority
           (Interrupt_FP_Policy (Sche_Param_Ref.all),
            Priority'Value
               (Get_Text (Sched_Server_Dialog.Server_Priority_Entry)));
      elsif (Get_Text (Get_Entry
                          (Sched_Server_Dialog.Policy_Type_Combo)) =
             "Polling")
      then
         Sche_Param_Ref := new Polling_Policy;
         if (Get_Text (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo)) =
             "YES")
         then
            Set_Preassigned (Polling_Policy (Sche_Param_Ref.all), True);
         else
            Set_Preassigned (Polling_Policy (Sche_Param_Ref.all), False);
         end if;
         Set_The_Priority
           (Polling_Policy (Sche_Param_Ref.all),
            Priority'Value
               (Get_Text (Sched_Server_Dialog.Server_Priority_Entry)));
         Set_Polling_Period
           (Polling_Policy (Sche_Param_Ref.all),
            Time'Value (Get_Text (Sched_Server_Dialog.Polling_Period_Entry)));
         Set_Polling_Worst_Overhead
           (Polling_Policy (Sche_Param_Ref.all),
            Normalized_Execution_Time'Value
               (Get_Text (Sched_Server_Dialog.Polling_Wor_Over_Entry)));
         Set_Polling_Best_Overhead
           (Polling_Policy (Sche_Param_Ref.all),
            Normalized_Execution_Time'Value
               (Get_Text (Sched_Server_Dialog.Polling_Bes_Over_Entry)));
         Set_Polling_Avg_Overhead
           (Polling_Policy (Sche_Param_Ref.all),
            Normalized_Execution_Time'Value
               (Get_Text (Sched_Server_Dialog.Polling_Avg_Over_Entry)));
      elsif (Get_Text (Get_Entry
                          (Sched_Server_Dialog.Policy_Type_Combo)) =
             "Sporadic Server")
      then
         Sche_Param_Ref :=
           new Mast.Scheduling_Parameters.Sporadic_Server_Policy;
         if (Get_Text (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo)) =
             "YES")
         then
            Set_Preassigned
              (Sporadic_Server_Policy (Sche_Param_Ref.all),
               True);
         else
            Set_Preassigned
              (Sporadic_Server_Policy (Sche_Param_Ref.all),
               False);
         end if;
         Set_The_Priority
           (Sporadic_Server_Policy (Sche_Param_Ref.all),
            Priority'Value
               (Get_Text (Sched_Server_Dialog.Server_Priority_Entry)));
         Set_Background_Priority
           (Sporadic_Server_Policy (Sche_Param_Ref.all),
            Priority'Value (Get_Text (Sched_Server_Dialog.Back_Prior_Entry)));
         Set_Initial_Capacity
           (Sporadic_Server_Policy (Sche_Param_Ref.all),
            Time'Value (Get_Text (Sched_Server_Dialog.Init_Capa_Entry)));
         Set_Replenishment_Period
           (Sporadic_Server_Policy (Sche_Param_Ref.all),
            Time'Value (Get_Text (Sched_Server_Dialog.Reple_Period_Entry)));
         Set_Max_Pending_Replenishments
           (Sporadic_Server_Policy (Sche_Param_Ref.all),
            Positive'Value
               (Get_Text (Sched_Server_Dialog.Max_Pend_Reple_Entry)));
      elsif (Get_Text (Get_Entry
                          (Sched_Server_Dialog.Policy_Type_Combo)) =
             "Earliest Deadline First")
      then
         Sche_Param_Ref := new Mast.Scheduling_Parameters.EDF_Policy;
         if (Get_Text (Get_Entry (Sched_Server_Dialog.Deadline_Combo)) =
             "YES")
         then
            Set_Preassigned
              (Mast.Scheduling_Parameters.EDF_Policy (Sche_Param_Ref.all),
               True);
         else
            Set_Preassigned
              (Mast.Scheduling_Parameters.EDF_Policy (Sche_Param_Ref.all),
               False);
         end if;
         Set_Deadline
           (Mast.Scheduling_Parameters.EDF_Policy (Sche_Param_Ref.all),
            Time'Value (Get_Text (Sched_Server_Dialog.Deadline_Entry)));
      end if;
      Mast.Scheduling_Servers.Set_Server_Sched_Parameters
        (Serv_Ref.all,
         Sche_Param_Ref);

      Sync_Param_Ref := Server_Synch_Parameters (Serv_Ref.all);
      if (Get_Text (Get_Entry (Sched_Server_Dialog.Sync_Type_Combo)) =
          "(NONE)")
      then
         Sync_Param_Ref := null;
      elsif (Get_Text (Get_Entry (Sched_Server_Dialog.Sync_Type_Combo)) =
             "Stack Resource Protocol")
      then
         Sync_Param_Ref := new SRP_Parameters;
         if (Get_Text (Get_Entry (Sched_Server_Dialog.Pre_Level_Combo)) =
             "YES")
         then
            Set_Preassigned (SRP_Parameters (Sync_Param_Ref.all), True);
         else
            Set_Preassigned (SRP_Parameters (Sync_Param_Ref.all), False);
         end if;
         Set_Preemption_Level
           (SRP_Parameters (Sync_Param_Ref.all),
            Preemption_Level'Value
               (Get_Text (Sched_Server_Dialog.Preemption_Level_Entry)));
      end if;
      Mast.Scheduling_Servers.Set_Server_Synch_Parameters
        (Serv_Ref.all,
         Sync_Param_Ref);

   exception
      when Invalid_Index =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "ERROR IN SCHEDULER ASSIGNMENT");
         Show_All (Editor_Error_Window);
         Destroy (Sched_Server_Dialog);
   end Write_Parameters;

   ---------------------
   -- Read Parameters --
   ---------------------
   procedure Read_Parameters
     (Item   : access ME_Server;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Serv_Ref            : Scheduling_Server_Ref      := Item.Ser;
      Serv_Name           : String                     :=
         Name_Image (Name (Serv_Ref));
      Sche_Ref            : Mast.Schedulers.Scheduler_Ref;
      Sche_Param_Ref      : Mast.Scheduling_Parameters.Sched_Parameters_Ref;
      Sync_Param_Ref      :
        Mast.Synchronization_Parameters.Synch_Parameters_Ref;
      Sched_Server_Dialog : Sched_Server_Dialog_Access :=
         Sched_Server_Dialog_Access (Dialog);
   begin
      Set_Text (Sched_Server_Dialog.Server_Name_Entry, Serv_Name);

      Sche_Ref := Mast.Scheduling_Servers.Server_Scheduler (Serv_Ref.all);
      if Sche_Ref = null then
         Set_Text (Get_Entry (Sched_Server_Dialog.Sched_Combo), "(NONE)");
      else
         Set_Text
           (Get_Entry (Sched_Server_Dialog.Sched_Combo),
            Name_Image (Name (Sche_Ref.all)));
      end if;

      Show_All (Sched_Server_Dialog);

      Sche_Param_Ref := Server_Sched_Parameters (Serv_Ref.all);
      if Sche_Param_Ref = null then
         Set_Text
           (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo),
            "(NONE)");
         Hide (Sched_Server_Dialog.Priority_Table);
         Hide (Sched_Server_Dialog.Polling_Table);
         Hide (Sched_Server_Dialog.Sporadic_Table);
         Hide (Sched_Server_Dialog.Edf_Table);
      else
         if Sche_Param_Ref.all'Tag =
            Mast.Scheduling_Parameters.Non_Preemptible_FP_Policy'Tag
         then
            Set_Text
              (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo),
               "Non Preemptible Fixed Priority");
            Set_Text
              (Sched_Server_Dialog.Server_Priority_Entry,
               Priority'Image
                  (The_Priority
                      (Mast.Scheduling_Parameters.Non_Preemptible_FP_Policy (
              Sche_Param_Ref.all))));
            if Preassigned
                 (Non_Preemptible_FP_Policy (Sche_Param_Ref.all))
            then
               Set_Text
                 (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo),
                  "YES");
            else
               Set_Text
                 (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo),
                  "NO");
            end if;
            Show_All (Sched_Server_Dialog.Priority_Table);
            Hide (Sched_Server_Dialog.Polling_Table);
            Hide (Sched_Server_Dialog.Sporadic_Table);
            Hide (Sched_Server_Dialog.Edf_Table);
         elsif Sche_Param_Ref.all'Tag =
               Mast.Scheduling_Parameters.Fixed_Priority_Policy'Tag
         then
            Set_Text
              (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo),
               "Fixed Priority");
            Set_Text
              (Sched_Server_Dialog.Server_Priority_Entry,
               Priority'Image
                  (The_Priority
                      (Mast.Scheduling_Parameters.Fixed_Priority_Policy (
              Sche_Param_Ref.all))));
            if Preassigned
                 (Mast.Scheduling_Parameters.Fixed_Priority_Policy (
                 Sche_Param_Ref.all))
            then
               Set_Text
                 (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo),
                  "YES");
            else
               Set_Text
                 (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo),
                  "NO");
            end if;
            Show_All (Sched_Server_Dialog.Priority_Table);
            Hide (Sched_Server_Dialog.Polling_Table);
            Hide (Sched_Server_Dialog.Sporadic_Table);
            Hide (Sched_Server_Dialog.Edf_Table);
         elsif Sche_Param_Ref.all'Tag =
               Mast.Scheduling_Parameters.Interrupt_FP_Policy'Tag
         then
            Set_Text
              (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo),
               "Interrupt Fixed Priority");
            Set_Text (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo), "YES");
            Set_Text
              (Sched_Server_Dialog.Server_Priority_Entry,
               Priority'Image
                  (The_Priority
                      (Mast.Scheduling_Parameters.Interrupt_FP_Policy (
              Sche_Param_Ref.all))));
            Show_All (Sched_Server_Dialog.Priority_Table);
            Hide (Sched_Server_Dialog.Polling_Table);
            Hide (Sched_Server_Dialog.Sporadic_Table);
            Hide (Sched_Server_Dialog.Edf_Table);
         elsif Sche_Param_Ref.all'Tag =
               Mast.Scheduling_Parameters.Polling_Policy'Tag
         then
            Set_Text
              (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo),
               "Polling");
            if Preassigned
                 (Mast.Scheduling_Parameters.Polling_Policy (Sche_Param_Ref.all
))
            then
               Set_Text
                 (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo),
                  "YES");
            else
               Set_Text
                 (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo),
                  "NO");
            end if;
            Set_Text
              (Sched_Server_Dialog.Server_Priority_Entry,
               Priority'Image
                  (The_Priority
                      (Mast.Scheduling_Parameters.Polling_Policy (
              Sche_Param_Ref.all))));
            Set_Text
              (Sched_Server_Dialog.Polling_Period_Entry,
               Time_Image
                  (Polling_Period
                      (Mast.Scheduling_Parameters.Polling_Policy (
              Sche_Param_Ref.all))));
            Set_Text
              (Sched_Server_Dialog.Polling_Wor_Over_Entry,
               Execution_Time_Image
                  (Polling_Worst_Overhead
                      (Mast.Scheduling_Parameters.Polling_Policy (
              Sche_Param_Ref.all))));
            Set_Text
              (Sched_Server_Dialog.Polling_Bes_Over_Entry,
               Execution_Time_Image
                  (Polling_Best_Overhead
                      (Mast.Scheduling_Parameters.Polling_Policy (
              Sche_Param_Ref.all))));
            Set_Text
              (Sched_Server_Dialog.Polling_Avg_Over_Entry,
               Execution_Time_Image
                  (Polling_Avg_Overhead
                      (Mast.Scheduling_Parameters.Polling_Policy (
              Sche_Param_Ref.all))));
            Show_All (Sched_Server_Dialog.Priority_Table);
            Show_All (Sched_Server_Dialog.Polling_Table);
            Hide (Sched_Server_Dialog.Sporadic_Table);
            Hide (Sched_Server_Dialog.Edf_Table);
         elsif Sche_Param_Ref.all'Tag =
               Mast.Scheduling_Parameters.Sporadic_Server_Policy'Tag
         then
            Set_Text
              (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo),
               "Sporadic Server");
            if Preassigned
                 (Mast.Scheduling_Parameters.Sporadic_Server_Policy (
                 Sche_Param_Ref.all))
            then
               Set_Text
                 (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo),
                  "YES");
            else
               Set_Text
                 (Get_Entry (Sched_Server_Dialog.Pre_Prior_Combo),
                  "NO");
            end if;
            Set_Text
              (Sched_Server_Dialog.Server_Priority_Entry,
               Priority'Image
                  (The_Priority
                      (Mast.Scheduling_Parameters.Sporadic_Server_Policy (
              Sche_Param_Ref.all))));
            Set_Text
              (Sched_Server_Dialog.Back_Prior_Entry,
               Priority'Image
                  (Background_Priority
                      (Mast.Scheduling_Parameters.Sporadic_Server_Policy (
              Sche_Param_Ref.all))));
            Set_Text
              (Sched_Server_Dialog.Init_Capa_Entry,
               Time_Image
                  (Initial_Capacity
                      (Mast.Scheduling_Parameters.Sporadic_Server_Policy (
              Sche_Param_Ref.all))));
            Set_Text
              (Sched_Server_Dialog.Reple_Period_Entry,
               Time_Image
                  (Replenishment_Period
                      (Mast.Scheduling_Parameters.Sporadic_Server_Policy (
              Sche_Param_Ref.all))));
            Set_Text
              (Sched_Server_Dialog.Max_Pend_Reple_Entry,
               Positive'Image
                  (Max_Pending_Replenishments
                      (Mast.Scheduling_Parameters.Sporadic_Server_Policy (
              Sche_Param_Ref.all))));
            Show_All (Sched_Server_Dialog.Priority_Table);
            Show_All (Sched_Server_Dialog.Sporadic_Table);
            Hide (Sched_Server_Dialog.Polling_Table);
            Hide (Sched_Server_Dialog.Edf_Table);
         elsif Sche_Param_Ref.all'Tag =
               Mast.Scheduling_Parameters.EDF_Policy'Tag
         then
            Set_Text
              (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo),
               "Earliest Deadline First");
            if Preassigned
                 (Mast.Scheduling_Parameters.EDF_Policy (Sche_Param_Ref.all))
            then
               Set_Text
                 (Get_Entry (Sched_Server_Dialog.Deadline_Combo),
                  "YES");
            else
               Set_Text
                 (Get_Entry (Sched_Server_Dialog.Deadline_Combo),
                  "NO");
            end if;
            Set_Text
              (Sched_Server_Dialog.Deadline_Entry,
               Time_Image
                  (Deadline
                   (Mast.Scheduling_Parameters.EDF_Policy
                    (Sche_Param_Ref.all))));
            Show_All (Sched_Server_Dialog.Edf_Table);
            Hide (Sched_Server_Dialog.Priority_Table);
            Hide (Sched_Server_Dialog.Polling_Table);
            Hide (Sched_Server_Dialog.Sporadic_Table);
         end if;
      end if;

      Sync_Param_Ref := Server_Synch_Parameters (Serv_Ref.all);
      if Sync_Param_Ref = null then
         Set_Text (Get_Entry (Sched_Server_Dialog.Sync_Type_Combo), "(NONE)");
         Hide (Sched_Server_Dialog.Srp_Table);
      else
         if Sync_Param_Ref.all'Tag = SRP_Parameters'Tag then
            Set_Text
              (Get_Entry (Sched_Server_Dialog.Sync_Type_Combo),
               "Stack Resource Protocol");
            Set_Text
              (Sched_Server_Dialog.Preemption_Level_Entry,
               Preemption_Level'Image
                  (The_Preemption_Level
                      (SRP_Parameters (Sync_Param_Ref.all))));
            if Preassigned (SRP_Parameters (Sync_Param_Ref.all)) then
               Set_Text
                 (Get_Entry (Sched_Server_Dialog.Pre_Level_Combo),
                  "YES");
            else
               Set_Text
                 (Get_Entry (Sched_Server_Dialog.Pre_Level_Combo),
                  "NO");
            end if;
            Show_All (Sched_Server_Dialog.Srp_Table);
         end if;
      end if;
   end Read_Parameters;

   ------------------
   -- Draw Server  --
   ------------------
   procedure Draw
     (Item         : access ME_Server;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint)
   is
      Rect           : constant Gdk_Rectangle := Get_Coord (Item);
      W              : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Width);
      H              : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Height);
      Serv_Ref       : Scheduling_Server_Ref  := Item.Ser;
      Serv_Name      : String                 :=
         Name_Image (Name (Serv_Ref));
      Sche_Ref       : Mast.Schedulers.Scheduler_Ref;
      Sche_Param_Ref : Mast.Scheduling_Parameters.Sched_Parameters_Ref;
      Color          : Gdk.Color.Gdk_Color;
   begin
      Color :=
         Parse (To_String (ME_Scheduling_Server_Ref (Item).Color_Name));
      Alloc (Gtk.Widget.Get_Default_Colormap, Color);
      Item.X_Coord := Gint (Get_Coord (Item).X);
      Item.Y_Coord := Gint (Get_Coord (Item).Y);
      Set_Foreground (GC, Color);
      Draw_Rectangle
        (Get_Window (Canvas),
         Gc     => GC,
         Filled => True,
         X      => Xdest,
         Y      => Ydest,
         Width  => W,
         Height => H);
      Set_Foreground (GC, Black (Get_Default_Colormap));
      Draw_Rectangle
        (Get_Window (Canvas),
         Gc     => GC,
         Filled => False,
         X      => Xdest,
         Y      => Ydest,
         Width  => W,
         Height => H);
      Draw_Line
        (Get_Window (Canvas),
         GC,
         Xdest,
         Ydest + H / 5,
         Xdest + W,
         Ydest + H / 5);
      if Get_Zoom (Canvas) = Zoom_Levels (1) then
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 20,
            Ydest + H / 6,
            Serv_Name);
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 5 * H / 10,
            Text => "REGULAR");
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 7 * H / 10,
            Text => "SERVER");
      elsif Get_Zoom (Canvas) = Zoom_Levels (2) then
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 20,
            Ydest + H / 7,
            Serv_Name);
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 20,
            Ydest + 4 * H / 10,
            Text => "REGULAR SERVER");
         Sche_Ref := Mast.Scheduling_Servers.Server_Scheduler (Serv_Ref.all);
         if Sche_Ref /= null then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 20,
               Ydest + 6 * H / 10,
               "Sched: " & Name_Image (Name (Sche_Ref.all)));
         end if;
      else
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font1),
            GC,
            Xdest + W / 10,
            Ydest + H / 8,
            Serv_Name);
         Draw_Text
           (Get_Window (Canvas),
            From_Description (Font),
            GC,
            Xdest + W / 10,
            Ydest + 4 * H / 10,
            Text => "REGULAR SERVER");
         Sche_Ref := Mast.Scheduling_Servers.Server_Scheduler (Serv_Ref.all);
         if Sche_Ref /= null then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 10,
               Ydest + 6 * H / 10,
               "Sched: " & Name_Image (Name (Sche_Ref.all)));
         end if;
         Sche_Param_Ref := Server_Sched_Parameters (Serv_Ref.all);
         if Sche_Param_Ref = null then
            null;
         elsif Sche_Param_Ref.all'Tag =
               Mast.Scheduling_Parameters.Non_Preemptible_FP_Policy'Tag
         then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 10,
               Ydest + 8 * H / 10,
               Text => "Policy: Non Preemptible Fixed Priority");
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 10,
               Ydest + 10 * H / 10,
               "Priority:" &
               Priority'Image
                  (The_Priority
                      (Mast.Scheduling_Parameters.Non_Preemptible_FP_Policy (
              Sche_Param_Ref.all))));
         elsif Sche_Param_Ref.all'Tag =
               Mast.Scheduling_Parameters.Fixed_Priority_Policy'Tag
         then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 10,
               Ydest + 8 * H / 10,
               Text => "Policy: Fixed Priority");
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 10,
               Ydest + 10 * H / 10,
               "Priority:" &
               Priority'Image
                  (The_Priority
                      (Mast.Scheduling_Parameters.Fixed_Priority_Policy (
              Sche_Param_Ref.all))));
         elsif Sche_Param_Ref.all'Tag =
               Mast.Scheduling_Parameters.Interrupt_FP_Policy'Tag
         then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 10,
               Ydest + 8 * H / 10,
               Text => "Policy: Interrupt Fixed Priority");
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 10,
               Ydest + 10 * H / 10,
               "Priority:" &
               Priority'Image
                  (The_Priority
                      (Mast.Scheduling_Parameters.Interrupt_FP_Policy (
              Sche_Param_Ref.all))));
         elsif Sche_Param_Ref.all'Tag =
               Mast.Scheduling_Parameters.Polling_Policy'Tag
         then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 10,
               Ydest + 8 * H / 10,
               Text => "Policy: Polling");
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 10,
               Ydest + 10 * H / 10,
               "Priority:" &
               Priority'Image
                  (The_Priority
                      (Mast.Scheduling_Parameters.Polling_Policy (
              Sche_Param_Ref.all))));
         elsif Sche_Param_Ref.all'Tag =
               Mast.Scheduling_Parameters.Sporadic_Server_Policy'Tag
         then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 10,
               Ydest + 8 * H / 10,
               Text => "Policy: Sporadic Server");
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 10,
               Ydest + 10 * H / 10,
               "Priority:" &
               Priority'Image
                  (The_Priority
                      (Mast.Scheduling_Parameters.Sporadic_Server_Policy (
              Sche_Param_Ref.all))));
         elsif Sche_Param_Ref.all'Tag =
               Mast.Scheduling_Parameters.EDF_Policy'Tag
         then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 10,
               Ydest + 8 * H / 10,
               Text => "Policy: Earliest Deadline First");
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 10,
               Ydest + 10 * H / 10,
               "Deadline:" &
               Time_Image
                  (Deadline
                   (Mast.Scheduling_Parameters.EDF_Policy
                    (Sche_Param_Ref.all))));
         end if;
      end if;
   end Draw;

   --------------------------------------
   -- Draw_Scheduler_In_Server_Canvas  --
   --------------------------------------
   procedure Draw_Scheduler_In_Server_Canvas
     (Item : ME_Scheduling_Server_Ref)
   is
      Sche_Ref         : Mast.Schedulers.Scheduler_Ref;
      Sche_Name        : Var_Strings.Var_String;
      Me_Sche_Iterator : Mast_Editor.Schedulers.Lists.Iteration_Object;
      Me_Sche_Ref      : Mast_Editor.Schedulers.ME_Scheduler_Ref;
   begin
      Editor_Actions.Remove_Old_Links (Sched_Server_Canvas, Item);
      -- we remove the old link to former Scheduler

      Sche_Ref := Mast.Scheduling_Servers.Server_Scheduler (Item.Ser.all);
      if Sche_Ref /= null then
         Sche_Name := Mast.Schedulers.Name (Sche_Ref);
         -- we search the scheduler in Me_Schedulers_In_Server_Canvas list
         Me_Sche_Iterator :=
            Mast_Editor.Schedulers.Lists.Find
              (Sche_Name,
               Editor_System.Me_Schedulers_In_Server_Canvas);
         Me_Sche_Ref      :=
            Mast_Editor.Schedulers.Lists.Item
              (Me_Sche_Iterator,
               Editor_System.Me_Schedulers_In_Server_Canvas);
         Add_Canvas_Link (Sched_Server_Canvas, Item, Me_Sche_Ref);
         Refresh_Canvas (Sched_Server_Canvas);
      end if;
   exception
      when Invalid_Index => -- scheduler not drawn in sched_server_canvas
         if Sche_Ref.all'Tag =
            Mast.Schedulers.Primary.Primary_Scheduler'Tag
         then
            Me_Sche_Ref            := new ME_Primary_Scheduler;
            Me_Sche_Ref.Color_Name := Prime_Color;
         elsif Sche_Ref.all'Tag =
               Mast.Schedulers.Secondary.Secondary_Scheduler'Tag
         then
            Me_Sche_Ref            := new ME_Secondary_Scheduler;
            Me_Sche_Ref.Color_Name := Second_Color;
         end if;
         Me_Sche_Ref.Name        := Sche_Name;
         Me_Sche_Ref.W           := Sche_Width;
         Me_Sche_Ref.H           := Sche_Height;
         Me_Sche_Ref.Canvas_Name := To_Var_String ("Sched_Server_Canvas");
         Me_Sche_Ref.Sche        := Sche_Ref;
         Mast_Editor.Schedulers.Lists.Add
           (Me_Sche_Ref,
            Editor_System.Me_Schedulers_In_Server_Canvas);
         Set_Screen_Size (Me_Sche_Ref, Me_Sche_Ref.W, Me_Sche_Ref.H);
         Put (Sched_Server_Canvas, Me_Sche_Ref);
         Show_Item (Sched_Server_Canvas, Me_Sche_Ref);
         Add_Canvas_Link (Sched_Server_Canvas, Item, Me_Sche_Ref);
         Refresh_Canvas (Sched_Server_Canvas);
   end Draw_Scheduler_In_Server_Canvas;

   ------------------
   -- Write Server -- (Write the params of an existing server and refresh the
   --canvas)
   ------------------
   procedure Write_Server
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Scheduling_Server_And_Dialog_Ref)
   is
      Item                : ME_Scheduling_Server_Ref   := Data.It;
      Sched_Server_Dialog : Sched_Server_Dialog_Access :=
         Sched_Server_Dialog_Access (Data.Dia);
      Sche_Name           : Var_String;
      Sche_Ref            : Mast.Schedulers.Scheduler_Ref;
      Sche_Index          : Mast.Schedulers.Lists.Index;
      Sche_Policy         : Mast.Scheduling_Policies.Scheduling_Policy_Ref;
      Not_Primary : exception;
      Wrong_Policy_Type : exception;
   begin
      if (Get_Text (Get_Entry (Sched_Server_Dialog.Sched_Combo)) =
          "(NONE)") or
         (Get_Text (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo)) =
          "(NONE)")
      then
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Scheduler and Policy Type can't be set to (NONE)!");
         Show_All (Editor_Error_Window);
      else
         -- we have to check if the type of scheduling parameters of server
         --(selected by user)
         -- is compatible with the type of scheduler and its scheduling policy
         Sche_Name   :=
            To_Var_String
              (Get_Text (Get_Entry (Sched_Server_Dialog.Sched_Combo)));
         Sche_Index  :=
            Mast.Schedulers.Lists.Find (Sche_Name, The_System.Schedulers);
         Sche_Ref    :=
            Mast.Schedulers.Lists.Item (Sche_Index, The_System.Schedulers);
         Sche_Policy := Mast.Schedulers.Scheduling_Policy (Sche_Ref.all);
         -- rule 21
         if (Get_Text (Get_Entry
                          (Sched_Server_Dialog.Policy_Type_Combo)) =
             "Interrupt Fixed Priority")
           and then Sche_Ref.all not  in
              Mast.Schedulers.Primary.Primary_Scheduler'Class
         then
            raise Not_Primary;
         end if;
         -- rules 19 & 20
         if Sche_Policy /= null then
            if Sche_Policy.all in
                 Mast.Scheduling_Policies.Fixed_Priority_Policy'Class
              and then (Get_Text
                           (Get_Entry
                               (Sched_Server_Dialog.Policy_Type_Combo)) =
                        "Earliest Deadline First")
            then
               raise Wrong_Policy_Type;
            end if;
            if Sche_Policy.all in Mast.Scheduling_Policies.EDF_Policy'Class
              and then
               --(Get_Text(Get_Entry(Sched_Server_Dialog.Policy_Type_Combo))/=
               --"Interrupt Fixed Priority")
               (Get_Text (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo)) /=
                "Earliest Deadline First")
            then
               raise Wrong_Policy_Type;
            end if;
         end if;

         if Id_Name_Is_Valid
              (Ada.Characters.Handling.To_Lower
                  (Get_Text (Sched_Server_Dialog.Server_Name_Entry)))
         then
            Write_Parameters (Item, Gtk_Dialog (Sched_Server_Dialog));
            Draw_Scheduler_In_Server_Canvas (Item);
            Refresh_Canvas (Sched_Server_Canvas);
            Destroy (Sched_Server_Dialog);
         else
            Gtk_New (Editor_Error_Window);
            Set_Text (Editor_Error_Window.Label, "Identifier not Valid!!!");
            Show_All (Editor_Error_Window);
         end if;
      end if;
   exception
      when Not_Primary =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Interrupt Fixed Policy requires primary scheduler!!!");
         Show_All (Editor_Error_Window);
      when Wrong_Policy_Type =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Scheduler's Policy and Server's Policy are incompatible!!!");
         Show_All (Editor_Error_Window);
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Invalid Value !!!");
         Show_All (Editor_Error_Window);
         Destroy (Sched_Server_Dialog);
   end Write_Server;

   ----------------
   -- New_Server -- (Add new server to canvas and to the lists of the systems)
   ----------------
   procedure New_Server
     (Widget : access Gtk_Widget_Record'Class;
      Data   : ME_Scheduling_Server_And_Dialog_Ref)
   is
      Item                : ME_Scheduling_Server_Ref   := Data.It;
      Sched_Server_Dialog : Sched_Server_Dialog_Access :=
         Sched_Server_Dialog_Access (Data.Dia);
      Sche_Name           : Var_String;
      Sche_Ref            : Mast.Schedulers.Scheduler_Ref;
      Sche_Index          : Mast.Schedulers.Lists.Index;
      Sche_Policy         : Mast.Scheduling_Policies.Scheduling_Policy_Ref;
      Not_Primary : exception;
      Wrong_Policy_Type : exception;
   begin
      if (Get_Text (Get_Entry (Sched_Server_Dialog.Sched_Combo)) =
          "(NONE)") or
         (Get_Text (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo)) =
          "(NONE)")
      then
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Scheduler and Policy Type can't be set to (NONE)!");
         Show_All (Editor_Error_Window);
      else
         -- we have to check if the type of scheduling parameters of server
         --(selected by user)
         -- is compatible with the type of scheduler and its scheduling policy
         Sche_Name   :=
            To_Var_String
              (Get_Text (Get_Entry (Sched_Server_Dialog.Sched_Combo)));
         Sche_Index  :=
            Mast.Schedulers.Lists.Find (Sche_Name, The_System.Schedulers);
         Sche_Ref    :=
            Mast.Schedulers.Lists.Item (Sche_Index, The_System.Schedulers);
         Sche_Policy := Mast.Schedulers.Scheduling_Policy (Sche_Ref.all);
         -- rule 21
         if (Get_Text (Get_Entry
                          (Sched_Server_Dialog.Policy_Type_Combo)) =
             "Interrupt Fixed Priority")
           and then Sche_Ref.all not  in
              Mast.Schedulers.Primary.Primary_Scheduler'Class
         then
            raise Not_Primary;
         end if;
         -- rules 19 & 20
         if Sche_Policy /= null then
            if Sche_Policy.all in
                 Mast.Scheduling_Policies.Fixed_Priority_Policy'Class
              and then (Get_Text
                           (Get_Entry
                               (Sched_Server_Dialog.Policy_Type_Combo)) =
                        "Earliest Deadline First")
            then
               raise Wrong_Policy_Type;
            end if;
            if Sche_Policy.all in Mast.Scheduling_Policies.EDF_Policy'Class
              and then
               --(Get_Text(Get_Entry(Sched_Server_Dialog.Policy_Type_Combo))/=
               --"Interrupt Fixed Priority")
               (Get_Text (Get_Entry (Sched_Server_Dialog.Policy_Type_Combo)) /=
                "Earliest Deadline First")
            then
               raise Wrong_Policy_Type;
            end if;
         end if;

         if Id_Name_Is_Valid
              (Ada.Characters.Handling.To_Lower
                  (Get_Text (Sched_Server_Dialog.Server_Name_Entry)))
         then
            Write_Parameters (Item, Gtk_Dialog (Sched_Server_Dialog));
            Mast.Scheduling_Servers.Lists.Add
              (Item.Ser,
               The_System.Scheduling_Servers);
            Mast_Editor.Scheduling_Servers.Lists.Add
              (Item,
               Editor_System.Me_Scheduling_Servers);
            Set_Screen_Size (Item, Item.W, Item.H);
            Put (Sched_Server_Canvas, Item);
            Refresh_Canvas (Sched_Server_Canvas);
            Show_Item (Sched_Server_Canvas, Item);
            Draw_Scheduler_In_Server_Canvas (Item);
            Destroy (Sched_Server_Dialog);
         else
            Gtk_New (Editor_Error_Window);
            Set_Text (Editor_Error_Window.Label, "Identifier not Valid!!!");
            Show_All (Editor_Error_Window);
         end if;
      end if;
   exception
      when Not_Primary =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Interrupt Fixed Policy requires primary scheduler!!!");
         Show_All (Editor_Error_Window);
      when Wrong_Policy_Type =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Scheduler's Policy and Server's Policy are incompatible!!!");
         Show_All (Editor_Error_Window);
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Invalid Value!!");
         Show_All (Editor_Error_Window);
         Destroy (Sched_Server_Dialog);
      when Already_Exists =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "The Server Already Exists!!");
         Show_All (Editor_Error_Window);
         Destroy (Sched_Server_Dialog);
      when Invalid_Index =>
         null;
   end New_Server;

   ------------------------
   -- Show Server Dialog -- (Show sched_server_dialog with the default params)
   ------------------------
   procedure Show_Server_Dialog (Widget : access Gtk_Button_Record'Class) is
      Item                : ME_Scheduling_Server_Ref            :=
         new ME_Server;
      Serv_Ref            : Scheduling_Server_Ref               :=
         new Scheduling_Server;
      Sched_Server_Dialog : Sched_Server_Dialog_Access;
      Me_Data             : ME_Scheduling_Server_And_Dialog_Ref :=
         new ME_Scheduling_Server_And_Dialog;
   begin
      Item.W           := Ser_Width;
      Item.H           := Ser_Height;
      Item.Canvas_Name := To_Var_String ("Sched_Server_Canvas");
      Item.Color_Name  := Ser_Color;
      Item.Ser         := Serv_Ref;

      Gtk_New (Sched_Server_Dialog);
      Read_Parameters (Item, Gtk_Dialog (Sched_Server_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Sched_Server_Dialog);

      Me_Scheduling_Server_And_Dialog_Cb.Connect
        (Sched_Server_Dialog.Server_Ok_Button,
         "clicked",
         Me_Scheduling_Server_And_Dialog_Cb.To_Marshaller (New_Server'Access),
         Me_Data);
   end Show_Server_Dialog;

   -----------------
   -- Remove_Ser  --
   -----------------
   procedure Remove_Ser
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Scheduling_Server_Ref)
   is
      Serv_Name       : Var_String;
      Serv_Index      : Mast.Scheduling_Servers.Lists.Index;
      Item_Deleted    : Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Me_Serv_Index   : Mast_Editor.Scheduling_Servers.Lists.Index;
      Me_Item_Deleted :
        Mast_Editor.Scheduling_Servers.ME_Scheduling_Server_Ref;
   begin
      Serv_Name    := Name (Item);
      Serv_Index   :=
         Mast.Scheduling_Servers.Lists.Find
           (Serv_Name,
            The_System.Scheduling_Servers);
      Item_Deleted :=
         Mast.Scheduling_Servers.Lists.Item
           (Serv_Index,
            The_System.Scheduling_Servers);

      if Mast.Transactions.List_References_Scheduling_Server
           (Item_Deleted,
            The_System.Transactions)
      then
         -- Scheduling server cannot be deleted
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "SCHEDULING SERVER IS REFERENCED BY AN ACTIVITY");
         Show_All (Editor_Error_Window);
         Destroy (Item_Menu);
      else
         if Message_Dialog
               (" Do you really want to remove this object? ",
                Confirmation,
                Button_Yes or Button_No,
                Button_Yes) =
            Button_Yes
         then
            Mast.Scheduling_Servers.Lists.Delete
              (Serv_Index,
               Item_Deleted,
               The_System.Scheduling_Servers);
            Me_Serv_Index   :=
               Mast_Editor.Scheduling_Servers.Lists.Find
                 (Serv_Name,
                  Editor_System.Me_Scheduling_Servers);
            Me_Item_Deleted :=
               Mast_Editor.Scheduling_Servers.Lists.Item
                 (Me_Serv_Index,
                  Editor_System.Me_Scheduling_Servers);
            Mast_Editor.Scheduling_Servers.Lists.Delete
              (Me_Serv_Index,
               Me_Item_Deleted,
               Editor_System.Me_Scheduling_Servers);
            Remove (Sched_Server_Canvas, Item);
            Refresh_Canvas (Sched_Server_Canvas);
            Change_Control.Changes_Made;
            Destroy (Item_Menu);
         end if;
      end if;
   exception
      when Invalid_Index =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "ERROR IN RESOURCE REMOVAL !!!");
         Show_All (Editor_Error_Window);
         Destroy (Item_Menu);
   end Remove_Ser;

   ---------------------
   -- Properties_Ser  --
   ---------------------
   procedure Properties_Ser
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Scheduling_Server_Ref)
   is
      Sched_Server_Dialog : Sched_Server_Dialog_Access;
      Me_Data             : ME_Scheduling_Server_And_Dialog_Ref :=
         new ME_Scheduling_Server_And_Dialog;
   begin
      Gtk_New (Sched_Server_Dialog);
      Read_Parameters (Item, Gtk_Dialog (Sched_Server_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (Sched_Server_Dialog);

      Me_Scheduling_Server_And_Dialog_Cb.Connect
        (Sched_Server_Dialog.Server_Ok_Button,
         "clicked",
         Me_Scheduling_Server_And_Dialog_Cb.To_Marshaller
            (Write_Server'Access),
         Me_Data);

      Refresh_Canvas (Sched_Server_Canvas);
      Destroy (Item_Menu);
   end Properties_Ser;

   ---------------------
   -- On Button Click --
   ---------------------
   procedure On_Button_Click
     (Item  : access ME_Server;
      Event : Gdk.Event.Gdk_Event_Button)
   is
      Num_Button          : Guint;
      Event_Type          : Gdk_Event_Type;
      Sched_Server_Dialog : Sched_Server_Dialog_Access;
      Me_Data             : ME_Scheduling_Server_And_Dialog_Ref :=
         new ME_Scheduling_Server_And_Dialog;
   begin
      if Event /= null then
         Event_Type := Get_Event_Type (Event);
         if Event_Type = Gdk_2button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (1) then

               Gtk_New (Sched_Server_Dialog);
               Read_Parameters (Item, Gtk_Dialog (Sched_Server_Dialog));
               Me_Data.It  := ME_Scheduling_Server_Ref (Item);
               Me_Data.Dia := Gtk_Dialog (Sched_Server_Dialog);

               Me_Scheduling_Server_And_Dialog_Cb.Connect
                 (Sched_Server_Dialog.Server_Ok_Button,
                  "clicked",
                  Me_Scheduling_Server_And_Dialog_Cb.To_Marshaller
                     (Write_Server'Access),
                  Me_Data);

            end if;
         elsif Event_Type = Button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (3) then
               Gtk_New (Item_Menu);
               Button_Cb.Connect
                 (Item_Menu.Remove,
                  "activate",
                  Button_Cb.To_Marshaller (Remove_Ser'Access),
                  ME_Scheduling_Server_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Properties,
                  "activate",
                  Button_Cb.To_Marshaller (Properties_Ser'Access),
                  ME_Scheduling_Server_Ref (Item));
            end if;
         end if;
      end if;
   exception
      when Storage_Error =>
         null;
   end On_Button_Click;

   -----------------
   -- Simple Mode --
   -----------------
   procedure Simple_Mode (Canvas : access Interactive_Canvas_Record'Class) is
   begin
      Zoom (Canvas, Zoom_Levels (1), 1);
   end Simple_Mode;

   -----------------------
   -- Complete Mode Non --
   -----------------------
   procedure Complete_Mode_Non
     (Canvas : access Interactive_Canvas_Record'Class)
   is
   begin
      Zoom (Canvas, Zoom_Levels (2), 1);
   end Complete_Mode_Non;

   -----------------------
   -- Complete Mode Exp --
   -----------------------
   procedure Complete_Mode_Exp
     (Canvas : access Interactive_Canvas_Record'Class)
   is
   begin
      Zoom (Canvas, Zoom_Levels (3), 1);
   end Complete_Mode_Exp;

   -----------
   -- Print --
   -----------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Server;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Mast_Editor.Scheduling_Servers.Print
        (File,
         ME_Scheduling_Server (Item),
         Indentation);
      Put (File, " ");
      Put (File, "Me_Server");
      Put (File, " ");
      Put (File, Mast.IO.Name_Image (Name (Item)));
      Put (File, " ");
      Put (File, Mast.IO.Name_Image (Item.Canvas_Name));
      if Item.X_Coord < 0 then
         Put (File, " ");
      end if;
      Put (File, Gint'Image (Item.X_Coord));
      if Item.Y_Coord < 0 then
         Put (File, " ");
      end if;
      Put (File, Gint'Image (Item.Y_Coord));
      Put (File, " ");
   end Print;

   ---------
   -- Run --
   ---------
   procedure Run (Frame : access Gtk.Frame.Gtk_Frame_Record'Class) is
      Box, Bbox, Cbox : Gtk_Box;
      Button          : Gtk_Button;
      Scrolled        : Gtk_Scrolled_Window;
      Vseparator      : Gtk_Vseparator;
      Alignment       : Gtk_Alignment;
   begin
      Gtk_New_Vbox (Box, Homogeneous => False);
      Add (Frame, Box);
      Gtk_New (Scrolled);
      Set_Border_Width (Scrolled, 5);
      Pack_Start (Box, Scrolled);
      Gtk_New_Hbox (Bbox, Homogeneous => False);
      Pack_Start (Box, Bbox, False, False, 4);

      Gtk_New_Hbox (Cbox, True, 10);
      Pack_Start (Bbox, Cbox, False, False, 4);

      Gtk_New (Sched_Server_Canvas);
      Configure
        (Sched_Server_Canvas,
         Grid_Size        => 0,
         Annotation_Font  => Pango.Font.From_String (Default_Annotation_Font),
         Arc_Link_Offset  => Default_Arc_Link_Offset,
         Arrow_Angle      => Default_Arrow_Angle,
         Arrow_Length     => Default_Arrow_Length,
         Motion_Threshold => Default_Motion_Threshold);
      Add (Scrolled, Sched_Server_Canvas);

      Gtk_New (Button, "Simple" & ASCII.LF & "Mode");
      Pack_Start (Cbox, Button, False, True, 0);
      Canvas_Cb.Object_Connect
        (Button,
         "clicked",
         Canvas_Cb.To_Marshaller (Simple_Mode'Access),
         Sched_Server_Canvas);

      Gtk_New (Button, "Complete Mode" & ASCII.LF & "(Non-Expanded)");
      Pack_Start (Cbox, Button, False, True, 0);
      Canvas_Cb.Object_Connect
        (Button,
         "clicked",
         Canvas_Cb.To_Marshaller (Complete_Mode_Non'Access),
         Sched_Server_Canvas);

      Gtk_New (Button, "Complete Mode" & ASCII.LF & "(Expanded)");
      Pack_Start (Cbox, Button, False, True, 0);
      Canvas_Cb.Object_Connect
        (Button,
         "clicked",
         Canvas_Cb.To_Marshaller (Complete_Mode_Exp'Access),
         Sched_Server_Canvas);

      Gtk_New_Vseparator (Vseparator);
      Pack_Start (Bbox, Vseparator, False, False, 10);

      Gtk_New (Button, "New Scheduling" & ASCII.LF & "Server");
      Pack_Start (Bbox, Button, True, True, 4);
      Button_Callback.Connect
        (Button,
         "clicked",
         Button_Callback.To_Marshaller (Show_Server_Dialog'Access));

      Gtk_New (Alignment, 0.5, 0.5, 1.0, 1.0);
      Pack_Start (Bbox, Alignment, True, True, 4);
      Gtk_New (Alignment, 0.5, 0.5, 1.0, 1.0);
      Pack_Start (Bbox, Alignment, True, True, 4);
      Gtk_New (Alignment, 0.5, 0.5, 1.0, 1.0);
      Pack_Start (Bbox, Alignment, True, True, 4);

      Realize (Sched_Server_Canvas);

      Gdk_New (Green_Gc, Get_Window (Sched_Server_Canvas));

      Editor_Actions.Load_System_Font (Font, Font1);

      Show_All (Frame);
   end Run;
end Mast_Editor.Scheduling_Servers;
