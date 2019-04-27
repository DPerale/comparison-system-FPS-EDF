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
with Ada.Characters.Handling;
with Ada.Tags;                use Ada.Tags;
with Glib;                    use Glib;
with Gtk.Combo;               use Gtk.Combo;
with Gtk.GEntry;              use Gtk.GEntry;
with Gtk.Handlers;            use Gtk.Handlers;
with Gtk.Label;               use Gtk.Label;
with Gtk.Notebook;            use Gtk.Notebook;
with Gtk.Table;               use Gtk.Table;
with Gtk.Widget;              use Gtk.Widget;
with Gtkada.Dialogs;          use Gtkada.Dialogs;
with Gtkada.Canvas;           use Gtkada.Canvas;

with Mast;                                use Mast;
with Mast.Events;                         use Mast.Events;
with Mast.Graphs;                         use Mast.Graphs;
with Mast.Graphs.Event_Handlers;          use Mast.Graphs.Event_Handlers;
with Mast.Graphs.Links;                   use Mast.Graphs.Links;
with Mast.Operations;                     use Mast.Operations;
with Mast.Processing_Resources;           use Mast.Processing_Resources;
with Mast.Processing_Resources.Processor;
with Mast.Schedulers;                     use Mast.Schedulers;
with Mast.Schedulers.Primary;             use Mast.Schedulers.Primary;
with Mast.Scheduling_Parameters;          use Mast.Scheduling_Parameters;
with Mast.Scheduling_Servers;             use Mast.Scheduling_Servers;
with Mast.Timing_Requirements;            use Mast.Timing_Requirements;
with Mast.Transactions;                   use Mast.Transactions;

with Mast_Editor.Event_Handlers;     use Mast_Editor.Event_Handlers;
with Mast_Editor.Links;              use Mast_Editor.Links;
with Mast_Editor.Operations;         use Mast_Editor.Operations;
with Mast_Editor.Scheduling_Servers; use Mast_Editor.Scheduling_Servers;
with Mast_Editor.Transactions;       use Mast_Editor.Transactions;

with Wizard_Welcome_Dialog_Pkg;     use Wizard_Welcome_Dialog_Pkg;
with Wizard_Transaction_Dialog_Pkg; use Wizard_Transaction_Dialog_Pkg;
with Wizard_Input_Dialog_Pkg;       use Wizard_Input_Dialog_Pkg;
with Wizard_Activity_Dialog_Pkg;    use Wizard_Activity_Dialog_Pkg;
with Wizard_Output_Dialog_Pkg;      use Wizard_Output_Dialog_Pkg;
with Wizard_Completed_Dialog_Pkg;   use Wizard_Completed_Dialog_Pkg;

with Callbacks_Mast_Editor;   use Callbacks_Mast_Editor;
with Editor_Error_Window_Pkg; use Editor_Error_Window_Pkg;
with Mast_Editor_Window_Pkg;  use Mast_Editor_Window_Pkg;
with Trans_Dialog_Pkg;        use Trans_Dialog_Pkg;
with Change_Control;
with Editor_Actions;          use Editor_Actions;
with Var_Strings;             use Var_Strings;

with Named_Lists;

package body Simple_Transaction_Wizard_Control is

   package Simple_Transaction_Wizard_Cb is new Gtk.Handlers.User_Callback (
      Widget_Type => Gtk_Widget_Record,
      User_Type => Simple_Transaction_Wizard_Access);

   package Return_Window_Cb is new Gtk.Handlers.User_Return_Callback (
      Widget_Type => Gtk_Widget_Record,
      Return_Type => Boolean,
      User_Type => Simple_Transaction_Wizard_Access);

   function On_Simple_Transaction_Wizard_Delete_Event
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access)
      return   Boolean;

   procedure Cancel_Simple_Transaction_Wizard
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access);

   procedure Show_Wizard_Welcome_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access);

   procedure Show_Wizard_Transaction_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access);

   procedure Show_Wizard_Input_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access);

   procedure Show_Wizard_Activity_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access);

   procedure Show_Wizard_Output_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access);

   procedure Show_Wizard_Completed_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access);

   procedure On_Apply_Button_Clicked
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access);

   --------------------------------------
   -- Create_Simple_Transaction_Wizard --
   --------------------------------------
   procedure Create_Simple_Transaction_Wizard is
      Wizard : Simple_Transaction_Wizard_Access;
   begin
      if Mast.Schedulers.Lists.Size (The_System.Schedulers) > 0 then

         Wizard := new Simple_Transaction_Wizard_Record;
         Gtk_New (Wizard.Wizard_Welcome_Dialog);
         Gtk_New (Wizard.Wizard_Transaction_Dialog);
         Gtk_New (Wizard.Wizard_Input_Dialog);
         Gtk_New (Wizard.Wizard_Activity_Dialog);
         Gtk_New (Wizard.Wizard_Output_Dialog);
         Gtk_New (Wizard.Wizard_Completed_Dialog);

         -- Wizard_Welcome_Dialog Callbacks

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Welcome_Dialog.Next_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Show_Wizard_Transaction_Dialog'Access),
            Wizard);

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Welcome_Dialog.Cancel_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Cancel_Simple_Transaction_Wizard'Access),
            Wizard);

         Return_Window_Cb.Connect
           (Wizard.Wizard_Welcome_Dialog,
            "delete_event",
            Return_Window_Cb.To_Marshaller
               (On_Simple_Transaction_Wizard_Delete_Event'Access),
            Wizard);

         -- Wizard_Transaction_Dialog_Callbacks

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Transaction_Dialog.Next_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Show_Wizard_Input_Dialog'Access),
            Wizard);

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Transaction_Dialog.Back_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Show_Wizard_Welcome_Dialog'Access),
            Wizard);

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Transaction_Dialog.Cancel_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Cancel_Simple_Transaction_Wizard'Access),
            Wizard);

         Return_Window_Cb.Connect
           (Wizard.Wizard_Transaction_Dialog,
            "delete_event",
            Return_Window_Cb.To_Marshaller
               (On_Simple_Transaction_Wizard_Delete_Event'Access),
            Wizard);

         -- Wizard_Input_Dialog_Callbacks

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Input_Dialog.Next_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Show_Wizard_Activity_Dialog'Access),
            Wizard);

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Input_Dialog.Back_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Show_Wizard_Transaction_Dialog'Access),
            Wizard);

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Input_Dialog.Cancel_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Cancel_Simple_Transaction_Wizard'Access),
            Wizard);

         Return_Window_Cb.Connect
           (Wizard.Wizard_Input_Dialog,
            "delete_event",
            Return_Window_Cb.To_Marshaller
               (On_Simple_Transaction_Wizard_Delete_Event'Access),
            Wizard);

         -- Wizard_Activity_Dialog_Callbacks

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Activity_Dialog.Next_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Show_Wizard_Output_Dialog'Access),
            Wizard);

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Activity_Dialog.Back_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Show_Wizard_Input_Dialog'Access),
            Wizard);

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Activity_Dialog.Cancel_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Cancel_Simple_Transaction_Wizard'Access),
            Wizard);

         Return_Window_Cb.Connect
           (Wizard.Wizard_Activity_Dialog,
            "delete_event",
            Return_Window_Cb.To_Marshaller
               (On_Simple_Transaction_Wizard_Delete_Event'Access),
            Wizard);

         -- Wizard_Output_Dialog_Callbacks

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Output_Dialog.Next_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Show_Wizard_Completed_Dialog'Access),
            Wizard);

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Output_Dialog.Back_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Show_Wizard_Activity_Dialog'Access),
            Wizard);

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Output_Dialog.Cancel_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Cancel_Simple_Transaction_Wizard'Access),
            Wizard);

         Return_Window_Cb.Connect
           (Wizard.Wizard_Output_Dialog,
            "delete_event",
            Return_Window_Cb.To_Marshaller
               (On_Simple_Transaction_Wizard_Delete_Event'Access),
            Wizard);

         -- Wizard_Completed_Dialog_Callbacks

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Completed_Dialog.Apply_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (On_Apply_Button_Clicked'Access),
            Wizard);

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Completed_Dialog.Back_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Show_Wizard_Output_Dialog'Access),
            Wizard);

         Simple_Transaction_Wizard_Cb.Connect
           (Wizard.Wizard_Completed_Dialog.Cancel_Button,
            "clicked",
            Simple_Transaction_Wizard_Cb.To_Marshaller
               (Cancel_Simple_Transaction_Wizard'Access),
            Wizard);

         Return_Window_Cb.Connect
           (Wizard.Wizard_Completed_Dialog,
            "delete_event",
            Return_Window_Cb.To_Marshaller
               (On_Simple_Transaction_Wizard_Delete_Event'Access),
            Wizard);

         Show_All (Wizard.Wizard_Welcome_Dialog);
         Wizard.Previous_Win := Welcome_Win;

      else
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "There must be, at least, one scheduler and one processor");
         Set_Text
           (Editor_Error_Window.Down_Label,
            " in the system to launch this wizard !!!");
         Show_All (Editor_Error_Window);
      end if;
   end Create_Simple_Transaction_Wizard;

   --------------------------------------
   -- Cancel_Simple_Transaction_Wizard --
   --------------------------------------
   procedure Cancel_Simple_Transaction_Wizard
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access)
   is
   begin
      Destroy (Wizard.Wizard_Welcome_Dialog);
      Destroy (Wizard.Wizard_Transaction_Dialog);
      Destroy (Wizard.Wizard_Input_Dialog);
      Destroy (Wizard.Wizard_Activity_Dialog);
      Destroy (Wizard.Wizard_Output_Dialog);
      Destroy (Wizard.Wizard_Completed_Dialog);
   end Cancel_Simple_Transaction_Wizard;

   -----------------------------------------------
   -- On_Simple_Transaction_Wizard_Delete_Event --
   -----------------------------------------------

   function On_Simple_Transaction_Wizard_Delete_Event
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access)
      return   Boolean
   is
   begin
      if Message_Dialog
            (" Do you really want to quit this wizard ? ",
             Confirmation,
             Button_Yes or Button_No,
             Button_Yes) =
         Button_Yes
      then
         Destroy (Wizard.Wizard_Welcome_Dialog);
         Destroy (Wizard.Wizard_Transaction_Dialog);
         Destroy (Wizard.Wizard_Input_Dialog);
         Destroy (Wizard.Wizard_Activity_Dialog);
         Destroy (Wizard.Wizard_Output_Dialog);
         Destroy (Wizard.Wizard_Completed_Dialog);
      end if;
      return True;
   end On_Simple_Transaction_Wizard_Delete_Event;

   --------------------------------
   -- Show_Wizard_Welcome_Dialog --
   --------------------------------
   procedure Show_Wizard_Welcome_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access)
   is
   begin
      Hide (Wizard.Wizard_Transaction_Dialog);
      Hide (Wizard.Wizard_Input_Dialog);
      Hide (Wizard.Wizard_Activity_Dialog);
      Hide (Wizard.Wizard_Output_Dialog);
      Hide (Wizard.Wizard_Completed_Dialog);

      Show_All (Wizard.Wizard_Welcome_Dialog);
      Wizard.Previous_Win := Welcome_Win;

   end Show_Wizard_Welcome_Dialog;

   ------------------------------------
   -- Show_Wizard_Transaction_Dialog --
   ------------------------------------
   procedure Show_Wizard_Transaction_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access)
   is
   begin
      Hide (Wizard.Wizard_Welcome_Dialog);
      Hide (Wizard.Wizard_Input_Dialog);
      Hide (Wizard.Wizard_Activity_Dialog);
      Hide (Wizard.Wizard_Output_Dialog);
      Hide (Wizard.Wizard_Completed_Dialog);

      Show_All (Wizard.Wizard_Transaction_Dialog);
      Wizard.Previous_Win := Transaction_Win;

   end Show_Wizard_Transaction_Dialog;

   ------------------------------
   -- Show_Wizard_Input_Dialog --
   ------------------------------
   procedure Show_Wizard_Input_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access)
   is
      use Mast.Transactions.Lists;
      External_Type : String :=
         String (Get_Text
                    (Get_Entry
                        (Wizard.Wizard_Input_Dialog.External_Event_Type_Combo))
);
      Transaction_Name_Not_Valid, Transaction_Name_Duplicated : exception;
   begin
      if Wizard.Previous_Win = Transaction_Win then
         if (not Id_Name_Is_Valid
                   (Ada.Characters.Handling.To_Lower
                       (Get_Text
                           (Wizard.Wizard_Transaction_Dialog.Trans_Name_Entry))
))
         then
            raise Transaction_Name_Not_Valid;
         end if;
         if (Mast.Transactions.Lists.Find
                (Var_Strings.To_Lower
                    (To_Var_String
                        (Get_Text
                            (Wizard.Wizard_Transaction_Dialog.Trans_Name_Entry)
)),
                 The_System.Transactions) /=
             Mast.Transactions.Lists.Null_Index)
         then
            raise Transaction_Name_Duplicated;
         end if;
      end if;

      Hide (Wizard.Wizard_Welcome_Dialog);
      Hide (Wizard.Wizard_Transaction_Dialog);
      Hide (Wizard.Wizard_Activity_Dialog);
      Hide (Wizard.Wizard_Output_Dialog);
      Hide (Wizard.Wizard_Completed_Dialog);

      Show_All (Wizard.Wizard_Input_Dialog);
      Wizard.Previous_Win := Input_Event_Win;

      if External_Type = "Periodic" then
         Hide (Wizard.Wizard_Input_Dialog.Singular_Table);
         Hide (Wizard.Wizard_Input_Dialog.Sporadic_Table);
         Hide (Wizard.Wizard_Input_Dialog.Unbounded_Table);
         Hide (Wizard.Wizard_Input_Dialog.Bursty_Table);
      elsif External_Type = "Singular" then
         Hide (Wizard.Wizard_Input_Dialog.Periodic_Table);
         Hide (Wizard.Wizard_Input_Dialog.Sporadic_Table);
         Hide (Wizard.Wizard_Input_Dialog.Unbounded_Table);
         Hide (Wizard.Wizard_Input_Dialog.Bursty_Table);
      elsif External_Type = "Sporadic" then
         Hide (Wizard.Wizard_Input_Dialog.Periodic_Table);
         Hide (Wizard.Wizard_Input_Dialog.Singular_Table);
         Hide (Wizard.Wizard_Input_Dialog.Unbounded_Table);
         Hide (Wizard.Wizard_Input_Dialog.Bursty_Table);
      elsif External_Type = "Unbounded" then
         Hide (Wizard.Wizard_Input_Dialog.Periodic_Table);
         Hide (Wizard.Wizard_Input_Dialog.Singular_Table);
         Hide (Wizard.Wizard_Input_Dialog.Sporadic_Table);
         Hide (Wizard.Wizard_Input_Dialog.Bursty_Table);
      elsif External_Type = "Bursty" then
         Hide (Wizard.Wizard_Input_Dialog.Periodic_Table);
         Hide (Wizard.Wizard_Input_Dialog.Singular_Table);
         Hide (Wizard.Wizard_Input_Dialog.Sporadic_Table);
         Hide (Wizard.Wizard_Input_Dialog.Unbounded_Table);
      end if;

      -- Set the names values of next screen (if the are empty)
      if Get_Text (Wizard.Wizard_Activity_Dialog.Op_Name_Entry) = "" then
         Set_Text
           (Wizard.Wizard_Activity_Dialog.Op_Name_Entry,
            Get_Text (Wizard.Wizard_Transaction_Dialog.Trans_Name_Entry));
      end if;
      if Get_Text (Wizard.Wizard_Activity_Dialog.Server_Name_Entry) =
         ""
      then
         Set_Text
           (Wizard.Wizard_Activity_Dialog.Server_Name_Entry,
            Get_Text (Wizard.Wizard_Transaction_Dialog.Trans_Name_Entry));
      end if;

   exception
      when Transaction_Name_Not_Valid =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " Transaction Name Not Valid!!!");
         Show_All (Editor_Error_Window);
      when Transaction_Name_Duplicated =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " A transaction with the same name already exists !!!");
         Show_All (Editor_Error_Window);
   end Show_Wizard_Input_Dialog;

   ---------------------------------
   -- Show_Wizard_Activity_Dialog --
   ---------------------------------
   procedure Show_Wizard_Activity_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access)
   is
      Input_Event_Name_Not_Valid, Period_Not_Valid, Max_Jitter_Not_Valid, 
Phase_Not_Valid, Avg_Interarrival_Not_Valid, Min_Interarrival_Not_Valid, 
Bound_Interval_Not_Valid, Max_Arrivals_Not_Valid : exception;
      Time_Check          : Mast.Time;
      Absolute_Time_Check : Mast.Absolute_Time;
      Positive_Check      : Positive;
   begin
      if Wizard.Previous_Win = Input_Event_Win then
         if not Id_Name_Is_Valid
                  (Ada.Characters.Handling.To_Lower
                      (Get_Text
                          (Wizard.Wizard_Input_Dialog.
              External_Event_Name_Entry)))
         then
            raise Input_Event_Name_Not_Valid;
         end if;

         if (Get_Text
                (Get_Entry
                    (Wizard.Wizard_Input_Dialog.External_Event_Type_Combo)) =
             "Periodic")
         then
            begin
               Time_Check :=
                  Time'Value
                    (Get_Text (Wizard.Wizard_Input_Dialog.Period_Entry));
            exception
               when Constraint_Error =>
                  raise Period_Not_Valid;
            end;
            begin
               Time_Check :=
                  Time'Value
                    (Get_Text (Wizard.Wizard_Input_Dialog.Max_Jitter_Entry));
            exception
               when Constraint_Error =>
                  raise Max_Jitter_Not_Valid;
            end;
            begin
               Absolute_Time_Check :=
                  Absolute_Time'Value
                    (Get_Text (Wizard.Wizard_Input_Dialog.Per_Phase_Entry));
            exception
               when Constraint_Error =>
                  raise Phase_Not_Valid;
            end;
         elsif (Get_Text
                   (Get_Entry
                       (Wizard.Wizard_Input_Dialog.External_Event_Type_Combo))
                =
                "Singular")
         then
            begin
               Absolute_Time_Check :=
                  Absolute_Time'Value
                    (Get_Text (Wizard.Wizard_Input_Dialog.Sing_Phase_Entry));
            exception
               when Constraint_Error =>
                  raise Phase_Not_Valid;
            end;
         elsif (Get_Text
                   (Get_Entry
                       (Wizard.Wizard_Input_Dialog.External_Event_Type_Combo))
                =
                "Sporadic")
         then
            begin
               Time_Check :=
                  Time'Value
                    (Get_Text (Wizard.Wizard_Input_Dialog.Spo_Avg_Entry));
            exception
               when Constraint_Error =>
                  raise Avg_Interarrival_Not_Valid;
            end;
            begin
               Time_Check :=
                  Time'Value
                    (Get_Text (Wizard.Wizard_Input_Dialog.Spo_Min_Entry));
            exception
               when Constraint_Error =>
                  raise Min_Interarrival_Not_Valid;
            end;
         elsif (Get_Text
                   (Get_Entry
                       (Wizard.Wizard_Input_Dialog.External_Event_Type_Combo))
                =
                "Unbounded")
         then
            begin
               Time_Check :=
                  Time'Value
                    (Get_Text (Wizard.Wizard_Input_Dialog.Unb_Avg_Entry));
            exception
               when Constraint_Error =>
                  raise Avg_Interarrival_Not_Valid;
            end;
         elsif (Get_Text
                   (Get_Entry
                       (Wizard.Wizard_Input_Dialog.External_Event_Type_Combo))
                =
                "Bursty")
         then
            begin
               Time_Check :=
                  Time'Value
                    (Get_Text (Wizard.Wizard_Input_Dialog.Bur_Avg_Entry));
            exception
               when Constraint_Error =>
                  raise Avg_Interarrival_Not_Valid;
            end;
            begin
               Time_Check :=
                  Time'Value
                    (Get_Text (Wizard.Wizard_Input_Dialog.Bur_Bound_Entry));
            exception
               when Constraint_Error =>
                  raise Bound_Interval_Not_Valid;
            end;
            begin
               Positive_Check :=
                  Positive'Value
                    (Get_Text (Wizard.Wizard_Input_Dialog.Max_Arrival_Entry));
            exception
               when Constraint_Error =>
                  raise Max_Arrivals_Not_Valid;
            end;
         end if;
      end if;

      Hide (Wizard.Wizard_Welcome_Dialog);
      Hide (Wizard.Wizard_Transaction_Dialog);
      Hide (Wizard.Wizard_Input_Dialog);
      Hide (Wizard.Wizard_Output_Dialog);
      Hide (Wizard.Wizard_Completed_Dialog);

      Show_All (Wizard.Wizard_Activity_Dialog);
      Wizard.Previous_Win := Activity_Win;
   exception
      when Input_Event_Name_Not_Valid =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " Input Event Name Not Valid!!!");
         Show_All (Editor_Error_Window);
      when Period_Not_Valid =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, " Period Value Not Valid!!!");
         Show_All (Editor_Error_Window);
      when Max_Jitter_Not_Valid =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " Max Jitter Value Not Valid!!!");
         Show_All (Editor_Error_Window);
      when Phase_Not_Valid =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, " Phase Value Not Valid!!!");
         Show_All (Editor_Error_Window);
      when Avg_Interarrival_Not_Valid =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " Avg Interarrival Value Not Valid!!!");
         Show_All (Editor_Error_Window);
      when Min_Interarrival_Not_Valid =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " Min Interarrival Value Not Valid!!!");
         Show_All (Editor_Error_Window);
      when Bound_Interval_Not_Valid =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " Bound Interval Value Not Valid!!!");
         Show_All (Editor_Error_Window);
      when Max_Arrivals_Not_Valid =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " Max Arrivals Value Not Valid!!!");
         Show_All (Editor_Error_Window);
   end Show_Wizard_Activity_Dialog;

   -------------------------------
   -- Show_Wizard_Output_Dialog --
   -------------------------------
   procedure Show_Wizard_Output_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access)
   is
      use Mast.Operations.Lists;
      use Mast.Scheduling_Servers.Lists;
      Server_Name_Not_Valid, Operation_Name_Not_Valid, 
Operation_Name_Duplicated, Server_Name_Duplicated, Worst_Exec_Time_Not_Valid, 
Priority_Not_Valid : exception;
      Norm_Time_Check : Mast.Normalized_Execution_Time;
      Priority_Check  : Mast.Priority;
   begin
      if Wizard.Previous_Win = Activity_Win then
         if not Id_Name_Is_Valid
                  (Ada.Characters.Handling.To_Lower
                      (Get_Text
                          (Wizard.Wizard_Activity_Dialog.Op_Name_Entry)))
         then
            raise Operation_Name_Not_Valid;
         end if;
         if (Mast.Operations.Lists.Find
                (Var_Strings.To_Lower
                    (To_Var_String
                        (Get_Text
                            (Wizard.Wizard_Activity_Dialog.Op_Name_Entry))),
                 The_System.Operations) /=
             Mast.Operations.Lists.Null_Index)
         then
            raise Operation_Name_Duplicated;
         end if;
         if not Id_Name_Is_Valid
                  (Ada.Characters.Handling.To_Lower
                      (Get_Text
                          (Wizard.Wizard_Activity_Dialog.Server_Name_Entry)))
         then
            raise Server_Name_Not_Valid;
         end if;
         if (Mast.Scheduling_Servers.Lists.Find
                (Var_Strings.To_Lower
                    (To_Var_String
                        (Get_Text
                            (Wizard.Wizard_Activity_Dialog.Server_Name_Entry)))
,
                 The_System.Scheduling_Servers) /=
             Mast.Scheduling_Servers.Lists.Null_Index)
         then
            raise Server_Name_Duplicated;
         end if;
         begin
            Norm_Time_Check :=
               Normalized_Execution_Time'Value
                 (Get_Text
                     (Wizard.Wizard_Activity_Dialog.Wor_Exec_Time_Entry));
         exception
            when Constraint_Error =>
               raise Worst_Exec_Time_Not_Valid;
         end;
         begin
            Priority_Check :=
               Priority'Value
                 (Get_Text
                     (Wizard.Wizard_Activity_Dialog.Server_Priority_Entry));
         exception
            when Constraint_Error =>
               raise Priority_Not_Valid;
         end;
      end if;

      Hide (Wizard.Wizard_Welcome_Dialog);
      Hide (Wizard.Wizard_Transaction_Dialog);
      Hide (Wizard.Wizard_Input_Dialog);
      Hide (Wizard.Wizard_Activity_Dialog);
      Hide (Wizard.Wizard_Completed_Dialog);

      Show_All (Wizard.Wizard_Output_Dialog);
      Wizard.Previous_Win := Output_Event_Win;

   exception
      when Operation_Name_Not_Valid =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, " Operation Name Not Valid!!!");
         Show_All (Editor_Error_Window);
      when Operation_Name_Duplicated =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " An operation with the same name already exists !!!");
         Show_All (Editor_Error_Window);
      when Server_Name_Not_Valid =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, " Server Name Not Valid!!!");
         Show_All (Editor_Error_Window);
      when Server_Name_Duplicated =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " A server with the same name already exists !!!");
         Show_All (Editor_Error_Window);
      when Worst_Exec_Time_Not_Valid =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " Worst Execution Time Not Valid!!!");
         Show_All (Editor_Error_Window);
      when Priority_Not_Valid =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, " Priority Value Not Valid!!!");
         Show_All (Editor_Error_Window);
   end Show_Wizard_Output_Dialog;

   ----------------------------------
   -- Show_Wizard_Completed_Dialog --
   ----------------------------------
   procedure Show_Wizard_Completed_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access)
   is
      Output_Event_Name_Not_Valid, Output_Event_Name_Duplicated, 
Deadline_Not_Valid : exception;
      Time_Check : Mast.Time;
   begin
      if not Id_Name_Is_Valid
               (Ada.Characters.Handling.To_Lower
                   (Get_Text (Wizard.Wizard_Output_Dialog.Event_Name_Entry)))
      then
         raise Output_Event_Name_Not_Valid;
      end if;
      if Get_Text (Wizard.Wizard_Output_Dialog.Event_Name_Entry) =
         Get_Text (Wizard.Wizard_Input_Dialog.External_Event_Name_Entry)
      then
         raise Output_Event_Name_Duplicated;
      end if;
      begin
         Time_Check :=
            Time'Value
              (Get_Text (Wizard.Wizard_Output_Dialog.Deadline_Entry));
      exception
         when Constraint_Error =>
            raise Deadline_Not_Valid;
      end;

      Hide (Wizard.Wizard_Welcome_Dialog);
      Hide (Wizard.Wizard_Transaction_Dialog);
      Hide (Wizard.Wizard_Input_Dialog);
      Hide (Wizard.Wizard_Activity_Dialog);
      Hide (Wizard.Wizard_Output_Dialog);

      Show_All (Wizard.Wizard_Completed_Dialog);
      Wizard.Previous_Win := Complete_Win;

   exception
      when Output_Event_Name_Not_Valid =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " Output Event Name Not Valid!!!");
         Show_All (Editor_Error_Window);
      when Output_Event_Name_Duplicated =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            " An event with the same name already exists!!!");
         Show_All (Editor_Error_Window);
      when Deadline_Not_Valid =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, " Deadline Value Not Valid!!!");
         Show_All (Editor_Error_Window);
   end Show_Wizard_Completed_Dialog;

   ------------------------------
   -- On_Apply_Button_Clicked  --
   ------------------------------
   procedure On_Apply_Button_Clicked
     (Widget : access Gtk_Widget_Record'Class;
      Wizard : Simple_Transaction_Wizard_Access)
   is
      Temp_ME_Transaction   : Mast_Editor.Transactions.ME_Transaction_Ref;
      Temp_Transaction      : Mast.Transactions.Transaction_Ref;
      Temp_ME_Input_Event   : Mast_Editor.Links.ME_Link_Ref;
      Temp_Input_Event      : Mast.Graphs.Link_Ref;
      Temp_Input_Eve_Ref    : Mast.Events.Event_Ref;
      Temp_Input_X_Coord    : constant Glib.Gint := 70;
      Temp_Input_Y_Coord    : constant Glib.Gint := 100;
      Temp_ME_Activity      : Mast_Editor.Event_Handlers.ME_Event_Handler_Ref;
      Temp_Activity         : Mast.Graphs.Event_Handler_Ref;
      Temp_Activity_X_Coord : constant Glib.Gint := 170;
      Temp_Activity_Y_Coord : constant Glib.Gint := 85;
      Temp_ME_Server        :
        Mast_Editor.Scheduling_Servers.ME_Scheduling_Server_Ref;
      Temp_Server           : Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Sche_Iterator         : Mast.Schedulers.Lists.Iteration_Object;
      Sche_Ref              : Mast.Schedulers.Scheduler_Ref;
      Sche_Name             : Var_Strings.Var_String;
      Sche_Index            : Mast.Schedulers.Lists.Index;
      Sche_Param_Ref        : Mast.Scheduling_Parameters.Sched_Parameters_Ref;
      Temp_ME_Operation     : Mast_Editor.Operations.ME_Operation_Ref;
      Temp_Operation        : Mast.Operations.Operation_Ref;
      Temp_ME_Output_Event  : Mast_Editor.Links.ME_Link_Ref;
      Temp_Output_Event     : Mast.Graphs.Link_Ref;
      Temp_Output_Eve_Ref   : Mast.Events.Event_Ref;
      Req_Ref               : Mast.Timing_Requirements.Timing_Requirement_Ref;
      Temp_Output_X_Coord   : constant Glib.Gint := 350;
      Temp_Output_Y_Coord   : constant Glib.Gint := 100;

   begin

      -----------------------
      -- Transaction
      -----------------------
      Temp_ME_Transaction             := new ME_Regular_Transaction;
      Temp_Transaction                := new Regular_Transaction;
      Temp_ME_Transaction.W           := Tran_Width;
      Temp_ME_Transaction.H           := Tran_Height;
      Temp_ME_Transaction.Canvas_Name := To_Var_String ("Transaction_Canvas");
      Temp_ME_Transaction.Color_Name  := Tran_Color;
      Temp_ME_Transaction.Tran        := Temp_Transaction;

      Gtk_New (Temp_ME_Transaction.Dialog);

      Init
        (Temp_Transaction.all,
         Var_Strings.To_Lower
            (To_Var_String
                (Get_Text
                    (Wizard.Wizard_Transaction_Dialog.Trans_Name_Entry))));

      ------------------------
      -- Input Event
      ------------------------
      Temp_ME_Input_Event             := new ME_External_Link;
      Temp_Input_Event                := new Regular_Link;
      Temp_ME_Input_Event.W           := Link_Width;
      Temp_ME_Input_Event.H           := Link_Height;
      Temp_ME_Input_Event.Canvas_Name := Name (Temp_ME_Transaction);
      Temp_ME_Input_Event.Color_Name  := Ext_Link_Color;
      Temp_ME_Input_Event.Lin         := Temp_Input_Event;
      Temp_ME_Input_Event.ME_Tran     := Temp_ME_Transaction;

      -- Extenal_Event is an abstract type so we must init Eve_Ref with
      --non-abstract derivated types
      if (Get_Text
             (Get_Entry
                 (Wizard.Wizard_Input_Dialog.External_Event_Type_Combo)) =
          "Periodic")
      then
         Temp_Input_Eve_Ref := new Mast.Events.Periodic_Event;
         Init
           (Temp_Input_Eve_Ref.all,
            Var_Strings.To_Lower
               (To_Var_String
                   (Get_Text
                       (Wizard.Wizard_Input_Dialog.External_Event_Name_Entry)))
);
         Set_Period
           (Periodic_Event (Temp_Input_Eve_Ref.all),
            Time'Value (Get_Text (Wizard.Wizard_Input_Dialog.Period_Entry)));
         Set_Max_Jitter
           (Periodic_Event (Temp_Input_Eve_Ref.all),
            Time'Value
               (Get_Text (Wizard.Wizard_Input_Dialog.Max_Jitter_Entry)));
         Set_Phase
           (Periodic_Event (Temp_Input_Eve_Ref.all),
            Absolute_Time'Value
               (Get_Text (Wizard.Wizard_Input_Dialog.Per_Phase_Entry)));
      elsif (Get_Text
                (Get_Entry
                    (Wizard.Wizard_Input_Dialog.External_Event_Type_Combo)) =
             "Singular")
      then
         Temp_Input_Eve_Ref := new Mast.Events.Singular_Event;
         Init
           (Temp_Input_Eve_Ref.all,
            Var_Strings.To_Lower
               (To_Var_String
                   (Get_Text
                       (Wizard.Wizard_Input_Dialog.External_Event_Name_Entry)))
);
         Set_Phase
           (Singular_Event (Temp_Input_Eve_Ref.all),
            Absolute_Time'Value
               (Get_Text (Wizard.Wizard_Input_Dialog.Sing_Phase_Entry)));
      elsif (Get_Text
                (Get_Entry
                    (Wizard.Wizard_Input_Dialog.External_Event_Type_Combo)) =
             "Sporadic")
      then
         Temp_Input_Eve_Ref := new Mast.Events.Sporadic_Event;
         Init
           (Temp_Input_Eve_Ref.all,
            Var_Strings.To_Lower
               (To_Var_String
                   (Get_Text
                       (Wizard.Wizard_Input_Dialog.External_Event_Name_Entry)))
);
         Set_Avg_Interarrival
           (Aperiodic_Event (Temp_Input_Eve_Ref.all),
            Time'Value (Get_Text (Wizard.Wizard_Input_Dialog.Spo_Avg_Entry)));
         Set_Distribution
           (Aperiodic_Event (Temp_Input_Eve_Ref.all),
            Distribution_Function'Value
               (Get_Text
                   (Get_Entry
                       (Wizard.Wizard_Input_Dialog.Spo_Dist_Func_Combo))));
         Set_Min_Interarrival
           (Sporadic_Event (Temp_Input_Eve_Ref.all),
            Time'Value (Get_Text (Wizard.Wizard_Input_Dialog.Spo_Min_Entry)));
      elsif (Get_Text
                (Get_Entry
                    (Wizard.Wizard_Input_Dialog.External_Event_Type_Combo)) =
             "Unbounded")
      then
         Temp_Input_Eve_Ref := new Mast.Events.Unbounded_Event;
         Init
           (Temp_Input_Eve_Ref.all,
            Var_Strings.To_Lower
               (To_Var_String
                   (Get_Text
                       (Wizard.Wizard_Input_Dialog.External_Event_Name_Entry)))
);
         Set_Avg_Interarrival
           (Aperiodic_Event (Temp_Input_Eve_Ref.all),
            Time'Value (Get_Text (Wizard.Wizard_Input_Dialog.Unb_Avg_Entry)));
         Set_Distribution
           (Aperiodic_Event (Temp_Input_Eve_Ref.all),
            Distribution_Function'Value
               (Get_Text
                   (Get_Entry
                       (Wizard.Wizard_Input_Dialog.Unb_Dist_Func_Combo))));
      elsif (Get_Text
                (Get_Entry
                    (Wizard.Wizard_Input_Dialog.External_Event_Type_Combo)) =
             "Bursty")
      then
         Temp_Input_Eve_Ref := new Mast.Events.Bursty_Event;
         Init
           (Temp_Input_Eve_Ref.all,
            Var_Strings.To_Lower
               (To_Var_String
                   (Get_Text
                       (Wizard.Wizard_Input_Dialog.External_Event_Name_Entry)))
);
         Set_Avg_Interarrival
           (Aperiodic_Event (Temp_Input_Eve_Ref.all),
            Time'Value (Get_Text (Wizard.Wizard_Input_Dialog.Bur_Avg_Entry)));
         Set_Distribution
           (Aperiodic_Event (Temp_Input_Eve_Ref.all),
            Distribution_Function'Value
               (Get_Text
                   (Get_Entry
                       (Wizard.Wizard_Input_Dialog.Bur_Dist_Func_Combo))));
         Set_Bound_Interval
           (Bursty_Event (Temp_Input_Eve_Ref.all),
            Time'Value
               (Get_Text (Wizard.Wizard_Input_Dialog.Bur_Bound_Entry)));
         Set_Max_Arrivals
           (Bursty_Event (Temp_Input_Eve_Ref.all),
            Positive'Value
               (Get_Text (Wizard.Wizard_Input_Dialog.Max_Arrival_Entry)));
      else
         null;
      end if;

      Mast.Graphs.Set_Event (Temp_Input_Event.all, Temp_Input_Eve_Ref);

      Mast.Transactions.Add_External_Event_Link
        (Temp_ME_Input_Event.ME_Tran.Tran.all,
         Temp_ME_Input_Event.Lin);
      Mast_Editor.Links.Lists.Add
        (Temp_ME_Input_Event,
         Editor_System.Me_Links);
      Set_Screen_Size
        (Temp_ME_Input_Event,
         To_Canvas_Coordinates
            (Temp_ME_Input_Event.ME_Tran.Dialog.Trans_Canvas,
             Temp_ME_Input_Event.W),
         To_Canvas_Coordinates
            (Temp_ME_Input_Event.ME_Tran.Dialog.Trans_Canvas,
             Temp_ME_Input_Event.H));
      Put
        (Temp_ME_Input_Event.ME_Tran.Dialog.Trans_Canvas,
         Temp_ME_Input_Event,
         Temp_Input_X_Coord,
         Temp_Input_Y_Coord);

      ------------------------
      -- Activity
      ------------------------
      Temp_ME_Activity             := new ME_Simple_Event_Handler;
      Temp_ME_Activity.W           := Handler_Width;
      Temp_ME_Activity.H           := Handler_Height;
      Temp_ME_Activity.Canvas_Name := Name (Temp_ME_Transaction);
      Temp_ME_Activity.Color_Name  := Handler_Color;
      Temp_ME_Activity.ME_Tran     := Temp_ME_Transaction;

      if (Get_Text
             (Get_Entry (Wizard.Wizard_Activity_Dialog.Seh_Type_Combo)) =
          "Activity")
      then
         Temp_Activity := new Activity;
      elsif (Get_Text
                (Get_Entry (Wizard.Wizard_Activity_Dialog.Seh_Type_Combo)) =
             "System Timed Activity")
      then
         Temp_Activity := new System_Timed_Activity;
      end if;

      Temp_ME_Activity.Han := Temp_Activity;

      -- Server

      Temp_ME_Server             := new ME_Server;
      Temp_Server                := new Scheduling_Server;
      Temp_ME_Server.W           := Ser_Width;
      Temp_ME_Server.H           := Ser_Height;
      Temp_ME_Server.Canvas_Name := To_Var_String ("Sched_Server_Canvas");
      Temp_ME_Server.Color_Name  := Ser_Color;
      Temp_ME_Server.Ser         := Temp_Server;

      Init
        (Temp_Server.all,
         Var_Strings.To_Lower
            (To_Var_String
                (Get_Text (Wizard.Wizard_Activity_Dialog.Server_Name_Entry))));

      Sche_Name  :=
         To_Var_String
           (Get_Text
               (Get_Entry (Wizard.Wizard_Activity_Dialog.Scheduler_Combo)));
      Sche_Index :=
         Mast.Schedulers.Lists.Find (Sche_Name, The_System.Schedulers);
      Sche_Ref   :=
         Mast.Schedulers.Lists.Item (Sche_Index, The_System.Schedulers);
      Mast.Scheduling_Servers.Set_Server_Scheduler
        (Temp_Server.all,
         Sche_Ref);

      --        -- If there is only one scheduler assigned to the only one
      --processor of the system
      --        -- we associate it (by default) to the server
      --        if Mast.Schedulers.Lists.Size (The_System.Schedulers)= 1 then
      --           Mast.Schedulers.Lists.Rewind (The_System.Schedulers,
      --Sche_Iterator);
      --           Sche_Ref := Mast.Schedulers.Lists.Item (Sche_Iterator,
      --The_System.Schedulers);
      --           if (Sche_Ref.all'Tag =
      --Mast.Schedulers.Primary.Primary_Scheduler'Tag) and then
      --                (Mast.Schedulers.Primary.Host(Primary_Scheduler(Sche_Re
      --f.all)) /= null) and then
      --                (Mast.Schedulers.Primary.Host(Primary_Scheduler(Sche_Re
      --f.all)).all'Tag =
      --Mast.Processing_Resources.Processor.Regular_Processor'Tag) then
      --              MAST.Scheduling_Servers.Set_Server_Scheduler
      --(Temp_Server.all, Sche_Ref);
      --           end if;
      --        end if;

      Sche_Param_Ref := new Mast.Scheduling_Parameters.Fixed_Priority_Policy;
      Set_The_Priority
        (Mast.Scheduling_Parameters.Fixed_Priority_Policy (Sche_Param_Ref.all),
         Priority'Value
            (Get_Text (Wizard.Wizard_Activity_Dialog.Server_Priority_Entry)));
      Mast.Scheduling_Servers.Set_Server_Sched_Parameters
        (Temp_Server.all,
         Sche_Param_Ref);

      Mast.Scheduling_Servers.Lists.Add
        (Temp_ME_Server.Ser,
         The_System.Scheduling_Servers);
      Mast_Editor.Scheduling_Servers.Lists.Add
        (Temp_ME_Server,
         Editor_System.Me_Scheduling_Servers);
      Set_Screen_Size
        (Temp_ME_Server,
         To_Canvas_Coordinates (Sched_Server_Canvas, Temp_ME_Server.W),
         To_Canvas_Coordinates (Sched_Server_Canvas, Temp_ME_Server.H));
      Put (Sched_Server_Canvas, Temp_ME_Server);
      Draw_Scheduler_In_Server_Canvas (Temp_ME_Server);
      Refresh_Canvas (Sched_Server_Canvas);

      Set_Activity_Server (Activity (Temp_Activity.all), Temp_Server);

      -- Operation

      Temp_ME_Operation             := new ME_Simple_Operation;
      Temp_Operation                := new Simple_Operation;
      Temp_ME_Operation.W           := Op_Width;
      Temp_ME_Operation.H           := Op_Height;
      Temp_ME_Operation.Canvas_Name := To_Var_String ("Operation_Canvas");
      Temp_ME_Operation.Color_Name  := Sop_Color;
      Temp_ME_Operation.Op          := Temp_Operation;

      Init
        (Temp_Operation.all,
         Var_Strings.To_Lower
            (To_Var_String
                (Get_Text (Wizard.Wizard_Activity_Dialog.Op_Name_Entry))));
      Set_Worst_Case_Execution_Time
        (Simple_Operation (Temp_Operation.all),
         Normalized_Execution_Time'Value
            (Get_Text (Wizard.Wizard_Activity_Dialog.Wor_Exec_Time_Entry)));

      Mast.Operations.Lists.Add (Temp_ME_Operation.Op, The_System.Operations);
      Mast_Editor.Operations.Lists.Add
        (Temp_ME_Operation,
         Editor_System.Me_Operations);
      Set_Screen_Size
        (Temp_ME_Operation,
         To_Canvas_Coordinates (Operation_Canvas, Temp_ME_Operation.W),
         To_Canvas_Coordinates (Operation_Canvas, Temp_ME_Operation.H));
      Put (Operation_Canvas, Temp_ME_Operation);
      Refresh_Canvas (Operation_Canvas);

      Set_Activity_Operation (Activity (Temp_Activity.all), Temp_Operation);

      -- Draw activity and add it to system
      Mast.Transactions.Add_Event_Handler
        (Temp_ME_Activity.ME_Tran.Tran.all,
         Temp_ME_Activity.Han);
      Temp_ME_Activity.Id :=
         Mast.Transactions.Num_Of_Event_Handlers
           (Temp_ME_Activity.ME_Tran.Tran.all);
      Mast_Editor.Event_Handlers.Lists.Add
        (Temp_ME_Activity,
         Editor_System.Me_Event_Handlers);
      Set_Screen_Size
        (Temp_ME_Activity,
         To_Canvas_Coordinates
            (Temp_ME_Activity.ME_Tran.Dialog.Trans_Canvas,
             Temp_ME_Activity.W),
         To_Canvas_Coordinates
            (Temp_ME_Activity.ME_Tran.Dialog.Trans_Canvas,
             Temp_ME_Activity.H));
      Put
        (Temp_ME_Activity.ME_Tran.Dialog.Trans_Canvas,
         Temp_ME_Activity,
         Temp_Activity_X_Coord,
         Temp_Activity_Y_Coord);

      ------------------------
      -- Output Event
      ------------------------
      Temp_ME_Output_Event             := new ME_Internal_Link;
      Temp_Output_Event                := new Regular_Link;
      Temp_ME_Output_Event.W           := Link_Width;
      Temp_ME_Output_Event.H           := Link_Height;
      Temp_ME_Output_Event.Canvas_Name := Name (Temp_ME_Transaction);
      Temp_ME_Output_Event.Color_Name  := Int_Link_Color;
      Temp_ME_Output_Event.Lin         := Temp_Output_Event;
      Temp_ME_Output_Event.ME_Tran     := Temp_ME_Transaction;

      Temp_Output_Eve_Ref := new Mast.Events.Internal_Event;
      Init
        (Temp_Output_Eve_Ref.all,
         Var_Strings.To_Lower
            (To_Var_String
                (Get_Text (Wizard.Wizard_Output_Dialog.Event_Name_Entry))));
      Mast.Graphs.Set_Event (Temp_Output_Event.all, Temp_Output_Eve_Ref);

      -- Timing Requirement type is Hard_Local_Deadline
      Req_Ref := new Hard_Global_Deadline;
      Set_The_Deadline
        (Mast.Timing_Requirements.Deadline (Req_Ref.all),
         Time'Value (Get_Text (Wizard.Wizard_Output_Dialog.Deadline_Entry)));
      Mast.Timing_Requirements.Set_Event
        (Mast.Timing_Requirements.Global_Deadline (Req_Ref.all),
         Temp_Input_Eve_Ref);
      Mast.Graphs.Links.Set_Link_Timing_Requirements
        (Regular_Link (Temp_Output_Event.all),
         Req_Ref);

      Mast.Transactions.Add_Internal_Event_Link
        (Temp_ME_Output_Event.ME_Tran.Tran.all,
         Temp_ME_Output_Event.Lin);
      Mast_Editor.Links.Lists.Add
        (Temp_ME_Output_Event,
         Editor_System.Me_Links);
      Set_Screen_Size
        (Temp_ME_Output_Event,
         To_Canvas_Coordinates
            (Temp_ME_Output_Event.ME_Tran.Dialog.Trans_Canvas,
             Temp_ME_Output_Event.W),
         To_Canvas_Coordinates
            (Temp_ME_Output_Event.ME_Tran.Dialog.Trans_Canvas,
             Temp_ME_Output_Event.H));
      Put
        (Temp_ME_Output_Event.ME_Tran.Dialog.Trans_Canvas,
         Temp_ME_Output_Event,
         Temp_Output_X_Coord,
         Temp_Output_Y_Coord);

      -- Set Input and Output Links of the Activity
      Set_Input_Link
        (Simple_Event_Handler (Temp_Activity.all),
         Temp_Input_Event);
      Set_Output_Link
        (Simple_Event_Handler (Temp_Activity.all),
         Temp_Output_Event);

      --- Show Transactions Tab in Mast_Editor_Window.Notebook
      Set_Current_Page (Mast_Editor_Window.Notebook, 4);

      -- Draw transaction and its elements and add it to system
      Add_Canvas_Link
        (Temp_ME_Transaction.Dialog.Trans_Canvas,
         Temp_ME_Input_Event,
         Temp_ME_Activity);
      Add_Canvas_Link
        (Temp_ME_Transaction.Dialog.Trans_Canvas,
         Temp_ME_Activity,
         Temp_ME_Output_Event);
      Refresh_Canvas (Temp_ME_Transaction.Dialog.Trans_Canvas);

      Mast.Transactions.Lists.Add
        (Temp_ME_Transaction.Tran,
         The_System.Transactions);
      Mast_Editor.Transactions.Lists.Add
        (Temp_ME_Transaction,
         Editor_System.Me_Transactions);
      Set_Screen_Size
        (Temp_ME_Transaction,
         To_Canvas_Coordinates (Transaction_Canvas, Temp_ME_Transaction.W),
         To_Canvas_Coordinates (Transaction_Canvas, Temp_ME_Transaction.H));
      Put (Transaction_Canvas, Temp_ME_Transaction);
      Refresh_Canvas (Transaction_Canvas);
      Show_Item (Transaction_Canvas, Temp_ME_Transaction);

      Change_Control.Changes_Made;

      -- Destroy all dialogs
      Destroy (Wizard.Wizard_Welcome_Dialog);
      Destroy (Wizard.Wizard_Transaction_Dialog);
      Destroy (Wizard.Wizard_Input_Dialog);
      Destroy (Wizard.Wizard_Activity_Dialog);
      Destroy (Wizard.Wizard_Output_Dialog);
      Destroy (Wizard.Wizard_Completed_Dialog);
   exception
      when others =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Can't Create Simple Transaction !!!");
         Show_All (Editor_Error_Window);
   end On_Apply_Button_Clicked;

end Simple_Transaction_Wizard_Control;
