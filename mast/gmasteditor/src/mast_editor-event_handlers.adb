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
with Ada.Text_IO;             use Ada.Text_IO;
with Ada.Characters.Handling;
with Ada.Tags;                use Ada.Tags;
with Gdk.Color;               use Gdk.Color;
with Gdk.Font;                use Gdk.Font;
with Gdk.Drawable;            use Gdk.Drawable;
with Gdk.Rectangle;           use Gdk.Rectangle;
with Gtk.Button;              use Gtk.Button;
with Gtk.Combo;               use Gtk.Combo;
with Gtk.Enums;               use Gtk.Enums;
with Gtk.GEntry;              use Gtk.GEntry;
with Gtk.Handlers;            use Gtk.Handlers;
with Gtk.Label;               use Gtk.Label;
with Gtk.Menu_Item;           use Gtk.Menu_Item;
with Gtk.Scrolled_Window;     use Gtk.Scrolled_Window;
with Gtk.Table;               use Gtk.Table;
with Pango.Font;              use Pango.Font;
with Gtkada.Dialogs;          use Gtkada.Dialogs;

with List_Exceptions;            use List_Exceptions;
with Mast;                       use Mast;
with Mast.IO;                    use Mast.IO;
with Mast.Events;                use Mast.Events;
with Mast.Timing_Requirements;   use Mast.Timing_Requirements;
with Mast.Graphs;                use Mast.Graphs;
with Mast.Graphs.Event_Handlers; use Mast.Graphs.Event_Handlers;
with Mast.Transactions;          use Mast.Transactions;
with Mast.Operations;            use Mast.Operations;
with Mast.Scheduling_Servers;    use Mast.Scheduling_Servers;

with Mast_Editor.Links;       use Mast_Editor.Links;
with Item_Menu_Pkg;           use Item_Menu_Pkg;
with Editor_Error_Window_Pkg; use Editor_Error_Window_Pkg;
with Seh_Dialog_Pkg;          use Seh_Dialog_Pkg;
with Mieh_Dialog_Pkg;         use Mieh_Dialog_Pkg;
with Moeh_Dialog_Pkg;         use Moeh_Dialog_Pkg;
with Add_Link_Dialog_Pkg;     use Add_Link_Dialog_Pkg;
with Editor_Actions;          use Editor_Actions;
with Change_Control;

package body Mast_Editor.Event_Handlers is

   package Button_Cb is new Gtk.Handlers.User_Callback
     (Widget_Type => Gtk_Widget_Record,
      User_Type => ME_Event_Handler_Ref);

   Font  : Pango_Font_Description;
   Font1 : Pango_Font_Description;

   -------------------------------------------------
   -- Types and packages used to handle dialogs info
   -------------------------------------------------

   type Me_Event_Handler_And_Dialog is record
      It  : ME_Event_Handler_Ref;
      Dia : Gtk_Dialog;
   end record;

   type Me_Event_Handler_And_Dialog_Ref is access all
     Me_Event_Handler_And_Dialog;

   package Me_Event_Handler_And_Dialog_Cb is new Gtk.Handlers.User_Callback
     (Widget_Type => Gtk_Widget_Record,
      User_Type => Me_Event_Handler_And_Dialog_Ref);

   --------------
   -- Name     --
   --------------
   function Name (Item : in ME_Event_Handler) return Var_String is
   begin
      return (Natural'Image (Item.Id) & Delimiter & Name (Item.ME_Tran));
   end Name;

   --------------
   -- Name     --
   --------------
   function Name (Item_Ref : in ME_Event_Handler_Ref) return Var_String is
   begin
      return (Natural'Image (Item_Ref.Id) &
              Delimiter &
              Name (Item_Ref.ME_Tran));
   end Name;

   -----------------
   -- Print       --
   -----------------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Ada.Text_IO.Set_Col (File, Ada.Text_IO.Count (Indentation));
      Ada.Text_IO.Put (File, "ME_Event_Handler");
   end Print;

   -----------------
   -- Print       --
   -----------------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_List    : in out Lists.List;
      Indentation : Positive)
   is
      Item_Ref : ME_Event_Handler_Ref;
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
     (Item   : access ME_Simple_Event_Handler;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Han_Ref                      : Event_Handler_Ref :=
        ME_Event_Handler_Ref (Item).Han;
      Han_Ref_Old                  : Event_Handler_Ref := Han_Ref;
      Serv_Index                   : Mast.Scheduling_Servers.Lists.Index;
      Op_Index                     : Mast.Operations.Lists.Index;
      Serv_Name, Op_Name, Eve_Name : Var_Strings.Var_String;
      Serv_Ref                     :
        Mast.Scheduling_Servers.Scheduling_Server_Ref;
      Op_Ref                       : Mast.Operations.Operation_Ref;
      Eve_Ref                      : Mast.Events.Event_Ref;
      SEH_Dialog                   : Seh_Dialog_Access :=
         Seh_Dialog_Access (Dialog);
   begin
      Change_Control.Changes_Made;
      if (Get_Text (Get_Entry (SEH_Dialog.Seh_Type_Combo)) =
          "Activity")
      then
         Han_Ref := new Activity;
         if Han_Ref_Old /=null then
            Mast.Graphs.Event_Handlers.Simple_Event_Handler (Han_Ref.all) :=
              Mast.Graphs.Event_Handlers.Simple_Event_Handler
              (Han_Ref_Old.all);
         end if;
         if (Get_Text (Get_Entry (SEH_Dialog.Ser_Combo)) /= "(NONE)") then
            Serv_Name  :=
               To_Var_String (Get_Text (Get_Entry (SEH_Dialog.Ser_Combo)));
            Serv_Index :=
               Mast.Scheduling_Servers.Lists.Find
                 (Serv_Name,
                  The_System.Scheduling_Servers);
            Serv_Ref   :=
               Mast.Scheduling_Servers.Lists.Item
                 (Serv_Index,
                  The_System.Scheduling_Servers);
            Set_Activity_Server (Activity (Han_Ref.all), Serv_Ref);
         end if;
         if (Get_Text (Get_Entry (SEH_Dialog.Op_Combo)) /= "(NONE)") then
            Op_Name  :=
               To_Var_String (Get_Text (Get_Entry (SEH_Dialog.Op_Combo)));
            Op_Index :=
               Mast.Operations.Lists.Find (Op_Name, The_System.Operations);
            Op_Ref   :=
               Mast.Operations.Lists.Item (Op_Index, The_System.Operations);
            Set_Activity_Operation (Activity (Han_Ref.all), Op_Ref);
         end if;
      elsif (Get_Text (Get_Entry (SEH_Dialog.Seh_Type_Combo)) =
             "System Timed Activity")
      then
         Han_Ref                                                       :=
           new System_Timed_Activity;
         if Han_Ref_Old /=null then
            Mast.Graphs.Event_Handlers.Simple_Event_Handler (Han_Ref.all) :=
              Mast.Graphs.Event_Handlers.Simple_Event_Handler
              (Han_Ref_Old.all);
         end if;
         if (Get_Text (Get_Entry (SEH_Dialog.Ser_Combo)) /= "(NONE)") then
            Serv_Name  :=
               To_Var_String (Get_Text (Get_Entry (SEH_Dialog.Ser_Combo)));
            Serv_Index :=
               Mast.Scheduling_Servers.Lists.Find
                 (Serv_Name,
                  The_System.Scheduling_Servers);
            Serv_Ref   :=
               Mast.Scheduling_Servers.Lists.Item
                 (Serv_Index,
                  The_System.Scheduling_Servers);
            Set_Activity_Server (Activity (Han_Ref.all), Serv_Ref);
         end if;
         if (Get_Text (Get_Entry (SEH_Dialog.Op_Combo)) /= "(NONE)") then
            Op_Name  :=
               To_Var_String (Get_Text (Get_Entry (SEH_Dialog.Op_Combo)));
            Op_Index :=
               Mast.Operations.Lists.Find (Op_Name, The_System.Operations);
            Op_Ref   :=
               Mast.Operations.Lists.Item (Op_Index, The_System.Operations);
            Set_Activity_Operation (Activity (Han_Ref.all), Op_Ref);
         end if;
      elsif (Get_Text (Get_Entry (SEH_Dialog.Seh_Type_Combo)) =
             "Rate Divisor")
      then
         Han_Ref                                                       :=
           new Rate_Divisor;
         if Han_Ref_Old /=null then
            Mast.Graphs.Event_Handlers.Simple_Event_Handler (Han_Ref.all) :=
              Mast.Graphs.Event_Handlers.Simple_Event_Handler
              (Han_Ref_Old.all);
         end if;
         Set_Rate_Factor
           (Rate_Divisor (Han_Ref.all),
            Positive'Value (Get_Text (SEH_Dialog.Rate_Entry)));
      elsif (Get_Text (Get_Entry (SEH_Dialog.Seh_Type_Combo)) =
             "Delay")
      then
         Han_Ref                                                       :=
           new Delay_Event_Handler;
         if Han_Ref_Old /=null then
            Mast.Graphs.Event_Handlers.Simple_Event_Handler (Han_Ref.all) :=
              Mast.Graphs.Event_Handlers.Simple_Event_Handler
              (Han_Ref_Old.all);
         end if;
         Set_Delay_Max_Interval
           (Delay_Event_Handler (Han_Ref.all),
            Time'Value (Get_Text (SEH_Dialog.Delay_Max_Entry)));
         Set_Delay_Min_Interval
           (Delay_Event_Handler (Han_Ref.all),
            Time'Value (Get_Text (SEH_Dialog.Delay_Min_Entry)));
      elsif (Get_Text (Get_Entry (SEH_Dialog.Seh_Type_Combo)) =
             "Offset")
      then
         Han_Ref                                                       :=
           new Offset_Event_Handler;
         if Han_Ref_Old /=null then
            Mast.Graphs.Event_Handlers.Simple_Event_Handler (Han_Ref.all) :=
              Mast.Graphs.Event_Handlers.Simple_Event_Handler
              (Han_Ref_Old.all);
         end if;
         Set_Delay_Max_Interval
           (Delay_Event_Handler (Han_Ref.all),
            Time'Value (Get_Text (SEH_Dialog.Delay_Max_Entry)));
         Set_Delay_Min_Interval
           (Delay_Event_Handler (Han_Ref.all),
            Time'Value (Get_Text (SEH_Dialog.Delay_Min_Entry)));
         Eve_Name :=
            To_Var_String
              (Get_Text (Get_Entry (SEH_Dialog.Ref_Event_Combo)));
         if Item.ME_Tran.Tran /= null
           and then (Get_Text (Get_Entry (SEH_Dialog.Ref_Event_Combo))) /=
                    "(NONE)"
         then
            Eve_Ref :=
               Mast.Transactions.Find_Any_Event
                 (Eve_Name,
                  Item.ME_Tran.Tran.all);
            Set_Referenced_Event
              (Offset_Event_Handler (Han_Ref.all),
               Eve_Ref);
         end if;
      else
         null;
      end if;
      ME_Event_Handler_Ref (Item).Han := Han_Ref;
   exception
      when Invalid_Index =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Error writing Activity parameters !!!");
         Show_All (Editor_Error_Window);
         Destroy (SEH_Dialog);
      when Event_Not_Found =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Error while searching Referenced Event !!!");
         Show_All (Editor_Error_Window);
         Destroy (SEH_Dialog);
   end Write_Parameters;

   ----------------------
   -- Write Parameters --
   ----------------------
   procedure Write_Parameters
     (Item   : access ME_Multi_Input_Event_Handler;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Han_Ref     : Event_Handler_Ref  := ME_Event_Handler_Ref (Item).Han;
      Han_Ref_old : Event_Handler_Ref  := Han_Ref;
      MIEH_Dialog : Mieh_Dialog_Access := Mieh_Dialog_Access (Dialog);
   begin
      Change_Control.Changes_Made;
      if (Get_Text (Get_Entry (MIEH_Dialog.Minput_Type_Combo)) =
          "Concentrator")
      then
         Han_Ref                                                      :=
           new Concentrator;
         if Han_Ref_Old /=null then
            Mast.Graphs.Event_Handlers.Input_Event_Handler (Han_Ref.all) :=
              Mast.Graphs.Event_Handlers.Input_Event_Handler
              (Han_Ref_old.all);
         end if;
      elsif (Get_Text (Get_Entry (MIEH_Dialog.Minput_Type_Combo)) =
             "Barrier")
      then
         Han_Ref                                                      :=
           new Barrier;
         if Han_Ref_Old /=null then
            Mast.Graphs.Event_Handlers.Input_Event_Handler (Han_Ref.all) :=
              Mast.Graphs.Event_Handlers.Input_Event_Handler (Han_Ref_old.all);
         end if;
      else
         null;
      end if;
      ME_Event_Handler_Ref (Item).Han := Han_Ref;
   end Write_Parameters;

   ----------------------
   -- Write Parameters --
   ----------------------
   procedure Write_Parameters
     (Item   : access ME_Multi_Output_Event_Handler;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Han_Ref     : Event_Handler_Ref  := ME_Event_Handler_Ref (Item).Han;
      Han_Ref_Old : Event_Handler_Ref  := Han_Ref;
      MOEH_Dialog : Moeh_Dialog_Access := Moeh_Dialog_Access (Dialog);
   begin
      Change_Control.Changes_Made;
      if (Get_Text (Get_Entry (MOEH_Dialog.Moutput_Type_Combo)) =
          "Delivery Server")
      then
         Han_Ref                                                       :=
           new Delivery_Server;
         if Han_Ref_Old /=null then
            Mast.Graphs.Event_Handlers.Output_Event_Handler (Han_Ref.all) :=
              Mast.Graphs.Event_Handlers.Output_Event_Handler
              (Han_Ref_Old.all);
         end if;
         Set_Policy
           (Delivery_Server (Han_Ref.all),
            Delivery_Policy'Value
               (Get_Text (Get_Entry (MOEH_Dialog.Del_Policy_Combo))));
      elsif (Get_Text (Get_Entry (MOEH_Dialog.Moutput_Type_Combo)) =
             "Query Server")
      then
         Han_Ref                                                       :=
           new Query_Server;
         if Han_Ref_Old /=null then
            Mast.Graphs.Event_Handlers.Output_Event_Handler (Han_Ref.all) :=
              Mast.Graphs.Event_Handlers.Output_Event_Handler
              (Han_Ref_Old.all);
         end if;
         Set_Policy
           (Query_Server (Han_Ref.all),
            Request_Policy'Value
               (Get_Text (Get_Entry (MOEH_Dialog.Que_Policy_Combo))));
      elsif (Get_Text (Get_Entry (MOEH_Dialog.Moutput_Type_Combo)) =
             "Multicast")
      then
         Han_Ref                                                       :=
           new Multicast;
         if Han_Ref_Old /=null then
            Mast.Graphs.Event_Handlers.Output_Event_Handler (Han_Ref.all) :=
              Mast.Graphs.Event_Handlers.Output_Event_Handler
              (Han_Ref_Old.all);
         end if;
      end if;
      ME_Event_Handler_Ref (Item).Han := Han_Ref;
   end Write_Parameters;

   ---------------------
   -- Read Parameters --
   ---------------------
   procedure Read_Parameters
     (Item   : access ME_Simple_Event_Handler;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Han_Ref    : Event_Handler_Ref := ME_Event_Handler_Ref (Item).Han;
      Eve_Ref    : Mast.Graphs.Link_Ref;
      Eve_Index  : Mast.Transactions.Link_Iteration_Object;
      Eve_Name   : Var_Strings.Var_String;
      SEH_Dialog : Seh_Dialog_Access := Seh_Dialog_Access (Dialog);
   begin
      -- We search Events (External and Internal) of the transaction
      -- and show them in Ref_Event_Combo
      Mast.Transactions.Rewind_External_Event_Links
        (Item.ME_Tran.Tran.all,
         Eve_Index);
      for I in
            1 ..
            Mast.Transactions.Num_Of_External_Event_Links
               (Item.ME_Tran.Tran.all)
      loop
         Mast.Transactions.Get_Next_External_Event_Link
           (Item.ME_Tran.Tran.all,
            Eve_Ref,
            Eve_Index);
         Eve_Name := Mast.Graphs.Name (Eve_Ref.all);
         String_List.Append (Ref_Event_Combo_Items, Name_Image (Eve_Name));
      end loop;
      Mast.Transactions.Rewind_Internal_Event_Links
        (Item.ME_Tran.Tran.all,
         Eve_Index);
      for I in
            1 ..
            Mast.Transactions.Num_Of_Internal_Event_Links
               (Item.ME_Tran.Tran.all)
      loop
         Mast.Transactions.Get_Next_Internal_Event_Link
           (Item.ME_Tran.Tran.all,
            Eve_Ref,
            Eve_Index);
         Eve_Name := Mast.Graphs.Name (Eve_Ref.all);
         String_List.Append (Ref_Event_Combo_Items, Name_Image (Eve_Name));
      end loop;

      Show_All (SEH_Dialog);
      Hide (SEH_Dialog.Rate_Table);
      Hide (SEH_Dialog.Delay_Table);
      Hide (SEH_Dialog.Ref_Table);
      if Han_Ref /= null then
         if Han_Ref.all'Tag = Mast.Graphs.Event_Handlers.Activity'Tag then
            Set_Text (Get_Entry (SEH_Dialog.Seh_Type_Combo), "Activity");
            if Mast.Graphs.Event_Handlers.Activity_Server
                  (Activity (Han_Ref.all)) /=
               null
            then
               Set_Text
                 (Get_Entry (SEH_Dialog.Op_Combo),
                  Name_Image
                     (Name
                         (Mast.Graphs.Event_Handlers.Activity_Operation
                             (Activity (Han_Ref.all)))));
            else
               Set_Text (Get_Entry (SEH_Dialog.Op_Combo), "(NONE)");
            end if;
            if Mast.Graphs.Event_Handlers.Activity_Server
                  (Activity (Han_Ref.all)) /=
               null
            then
               Set_Text
                 (Get_Entry (SEH_Dialog.Ser_Combo),
                  Name_Image
                     (Name
                         (Mast.Graphs.Event_Handlers.Activity_Server
                             (Activity (Han_Ref.all)))));
            else
               Set_Text (Get_Entry (SEH_Dialog.Ser_Combo), "(NONE)");
            end if;
            Show (SEH_Dialog.Table1);
            Show (SEH_Dialog.Activity_Table);
         elsif Han_Ref.all'Tag =
               Mast.Graphs.Event_Handlers.System_Timed_Activity'Tag
         then
            Set_Text
              (Get_Entry (SEH_Dialog.Seh_Type_Combo),
               "System Timed Activity");
            if Mast.Graphs.Event_Handlers.Activity_Server
                  (Activity (Han_Ref.all)) /=
               null
            then
               Set_Text
                 (Get_Entry (SEH_Dialog.Op_Combo),
                  Name_Image
                     (Name
                         (Mast.Graphs.Event_Handlers.Activity_Operation
                             (Activity (Han_Ref.all)))));
            else
               Set_Text (Get_Entry (SEH_Dialog.Op_Combo), "(NONE)");
            end if;
            if Mast.Graphs.Event_Handlers.Activity_Server
                  (Activity (Han_Ref.all)) /=
               null
            then
               Set_Text
                 (Get_Entry (SEH_Dialog.Ser_Combo),
                  Name_Image
                     (Name
                         (Mast.Graphs.Event_Handlers.Activity_Server
                             (Activity (Han_Ref.all)))));
            else
               Set_Text (Get_Entry (SEH_Dialog.Ser_Combo), "(NONE)");
            end if;
            Show (SEH_Dialog.Table1);
            Show (SEH_Dialog.Activity_Table);
         elsif Han_Ref.all'Tag =
               Mast.Graphs.Event_Handlers.Rate_Divisor'Tag
         then
            Set_Text (Get_Entry (SEH_Dialog.Seh_Type_Combo), "Rate Divisor");
            Set_Text
              (SEH_Dialog.Rate_Entry,
               Positive'Image
                  (Mast.Graphs.Event_Handlers.Rate_Factor
                      (Rate_Divisor (Han_Ref.all))));
            Show (SEH_Dialog.Table1);
            Show (SEH_Dialog.Rate_Table);
         elsif Han_Ref.all'Tag =
               Mast.Graphs.Event_Handlers.Delay_Event_Handler'Tag
         then
            Set_Text (Get_Entry (SEH_Dialog.Seh_Type_Combo), "Delay");
            Set_Text
              (SEH_Dialog.Delay_Max_Entry,
               Time_Image
                  (Mast.Graphs.Event_Handlers.Delay_Max_Interval
                      (Delay_Event_Handler (Han_Ref.all))));
            Set_Text
              (SEH_Dialog.Delay_Min_Entry,
               Time_Image
                  (Mast.Graphs.Event_Handlers.Delay_Min_Interval
                      (Delay_Event_Handler (Han_Ref.all))));
            Show (SEH_Dialog.Table1);
            Show (SEH_Dialog.Delay_Table);
         elsif Han_Ref.all'Tag =
               Mast.Graphs.Event_Handlers.Offset_Event_Handler'Tag
         then
            Set_Text (Get_Entry (SEH_Dialog.Seh_Type_Combo), "Offset");
            Set_Text
              (SEH_Dialog.Delay_Max_Entry,
               Time_Image
                  (Mast.Graphs.Event_Handlers.Delay_Max_Interval
                      (Delay_Event_Handler (Han_Ref.all))));
            Set_Text
              (SEH_Dialog.Delay_Min_Entry,
               Time_Image
                  (Mast.Graphs.Event_Handlers.Delay_Min_Interval
                      (Delay_Event_Handler (Han_Ref.all))));
            if Mast.Graphs.Event_Handlers.Referenced_Event
                  (Offset_Event_Handler (Han_Ref.all)) /=
               null
            then
               Set_Text
                 (Get_Entry (SEH_Dialog.Ref_Event_Combo),
                  Name_Image
                     (Name
                         (Mast.Graphs.Event_Handlers.Referenced_Event
                             (Offset_Event_Handler (Han_Ref.all)))));
            else
               Set_Text (Get_Entry (SEH_Dialog.Ref_Event_Combo), "(NONE)");
            end if;
            Show (SEH_Dialog.Table1);
            Show (SEH_Dialog.Delay_Table);
            Show (SEH_Dialog.Ref_Table);
         else
            null;
         end if;
      end if;
   end Read_Parameters;

   ---------------------
   -- Read Parameters --
   ---------------------
   procedure Read_Parameters
     (Item   : access ME_Multi_Input_Event_Handler;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Han_Ref     : Event_Handler_Ref  := ME_Event_Handler_Ref (Item).Han;
      MIEH_Dialog : Mieh_Dialog_Access := Mieh_Dialog_Access (Dialog);
   begin
      Show_All (MIEH_Dialog);
      if Han_Ref /= null then
         if Han_Ref.all'Tag =
            Mast.Graphs.Event_Handlers.Concentrator'Tag
         then
            Set_Text
              (Get_Entry (MIEH_Dialog.Minput_Type_Combo),
               "Concentrator");
         elsif Han_Ref.all'Tag = Mast.Graphs.Event_Handlers.Barrier'Tag then
            Set_Text (Get_Entry (MIEH_Dialog.Minput_Type_Combo), "Barrier");
         else
            null;
         end if;
      end if;
   end Read_Parameters;

   ---------------------
   -- Read Parameters --
   ---------------------
   procedure Read_Parameters
     (Item   : access ME_Multi_Output_Event_Handler;
      Dialog : access Gtk_Dialog_Record'Class)
   is
      Han_Ref     : Event_Handler_Ref  := ME_Event_Handler_Ref (Item).Han;
      MOEH_Dialog : Moeh_Dialog_Access := Moeh_Dialog_Access (Dialog);
   begin
      Show_All (MOEH_Dialog);
      Hide (MOEH_Dialog.Delivery_Table);
      Hide (MOEH_Dialog.Query_Table);
      if Han_Ref /= null then
         if Han_Ref.all'Tag =
            Mast.Graphs.Event_Handlers.Delivery_Server'Tag
         then
            Set_Text
              (Get_Entry (MOEH_Dialog.Moutput_Type_Combo),
               "Delivery Server");
            Set_Text
              (Get_Entry (MOEH_Dialog.Del_Policy_Combo),
               Delivery_Policy'Image
                  (Policy (Delivery_Server (Han_Ref.all))));
            Show_All (MOEH_Dialog);
            Hide (MOEH_Dialog.Query_Table);
         elsif Han_Ref.all'Tag =
               Mast.Graphs.Event_Handlers.Query_Server'Tag
         then
            Set_Text
              (Get_Entry (MOEH_Dialog.Moutput_Type_Combo),
               "Query Server");
            Set_Text
              (Get_Entry (MOEH_Dialog.Que_Policy_Combo),
               Request_Policy'Image (Policy (Query_Server (Han_Ref.all))));
            Show_All (MOEH_Dialog);
            Hide (MOEH_Dialog.Delivery_Table);
         elsif Han_Ref.all'Tag =
               Mast.Graphs.Event_Handlers.Multicast'Tag
         then
            Set_Text
              (Get_Entry (MOEH_Dialog.Moutput_Type_Combo),
               "Multicast");
            Show_All (MOEH_Dialog);
            Hide (MOEH_Dialog.Delivery_Table);
            Hide (MOEH_Dialog.Query_Table);
         else
            null;
         end if;
      end if;
   end Read_Parameters;

   --------------------------
   -- Draw Simple Handler  --
   --------------------------
   procedure Draw
     (Item         : access ME_Simple_Event_Handler;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint)
   is
      Rect    : constant Gdk_Rectangle := Get_Coord (Item);
      W       : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Width);
      H       : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Height);
      Han_Ref : Event_Handler_Ref      := ME_Event_Handler_Ref (Item).Han;
      Color   : Gdk.Color.Gdk_Color;
   begin
      Editor_Actions.Load_System_Font (Font1, Font);
      Color := Parse (To_String (ME_Event_Handler_Ref (Item).Color_Name));
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
         Ydest + H / 4,
         Xdest + W,
         Ydest + H / 4);
      if Han_Ref /= null then
         if Han_Ref.all'Tag = Mast.Graphs.Event_Handlers.Activity'Tag then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 50,
               Ydest + H / 5,
               Text => "Activity");
            if Mast.Graphs.Event_Handlers.Activity_Server
                  (Activity (Han_Ref.all)) /=
               null
            then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font1),
                  GC,
                  Xdest + W / 30,
                  Ydest + H / 2,
                  "Op:" &
                  Name_Image
                     (Name
                         (Mast.Graphs.Event_Handlers.Activity_Operation
                             (Activity (Han_Ref.all)))));
            else
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font1),
                  GC,
                  Xdest + W / 30,
                  Ydest + H / 2,
                  Text => "Op: (NOT ASSIGNED)");
            end if;
            if Mast.Graphs.Event_Handlers.Activity_Server
                  (Activity (Han_Ref.all)) /=
               null
            then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font1),
                  GC,
                  Xdest + W / 30,
                  Ydest + 5 * H / 6,
                  "Serv:" &
                  Name_Image
                     (Name
                         (Mast.Graphs.Event_Handlers.Activity_Server
                             (Activity (Han_Ref.all)))));
            else
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font1),
                  GC,
                  Xdest + W / 30,
                  Ydest + 5 * H / 6,
                  Text => "Serv: (NOT ASSIGNED)");
            end if;
         elsif Han_Ref.all'Tag =
               Mast.Graphs.Event_Handlers.System_Timed_Activity'Tag
         then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 50,
               Ydest + H / 5,
               Text => "Timed Activity");
            if Mast.Graphs.Event_Handlers.Activity_Server
                  (Activity (Han_Ref.all)) /=
               null
            then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font1),
                  GC,
                  Xdest + W / 30,
                  Ydest + H / 2,
                  "Op:" &
                  Name_Image
                     (Name
                         (Mast.Graphs.Event_Handlers.Activity_Operation
                             (Activity (Han_Ref.all)))));
            else
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font1),
                  GC,
                  Xdest + W / 30,
                  Ydest + H / 2,
                  Text => "Op: (NOT ASSIGNED)");
            end if;
            if Mast.Graphs.Event_Handlers.Activity_Server
                  (Activity (Han_Ref.all)) /=
               null
            then
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font1),
                  GC,
                  Xdest + W / 30,
                  Ydest + 5 * H / 6,
                  "Serv:" &
                  Name_Image
                     (Name
                         (Mast.Graphs.Event_Handlers.Activity_Server
                             (Activity (Han_Ref.all)))));
            else
               Draw_Text
                 (Get_Window (Canvas),
                  From_Description (Font1),
                  GC,
                  Xdest + W / 30,
                  Ydest + 5 * H / 6,
                  Text => "Serv: (NOT ASSIGNED)");
            end if;
         elsif Han_Ref.all'Tag =
               Mast.Graphs.Event_Handlers.Rate_Divisor'Tag
         then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 50,
               Ydest + H / 5,
               Text => "Rate Divisor");
         elsif Han_Ref.all'Tag =
               Mast.Graphs.Event_Handlers.Delay_Event_Handler'Tag
         then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 50,
               Ydest + H / 5,
               Text => "Delay");
         elsif Han_Ref.all'Tag =
               Mast.Graphs.Event_Handlers.Offset_Event_Handler'Tag
         then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 50,
               Ydest + H / 5,
               Text => "Offset");
         end if;
      end if;
   end Draw;

   -------------------------
   -- Draw Minput Handler --
   -------------------------
   procedure Draw
     (Item         : access ME_Multi_Input_Event_Handler;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint)
   is
      Rect    : constant Gdk_Rectangle := Get_Coord (Item);
      W       : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Width);
      H       : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Height);
      Han_Ref : Event_Handler_Ref      := ME_Event_Handler_Ref (Item).Han;
      Color   : Gdk.Color.Gdk_Color;
   begin
      Editor_Actions.Load_System_Font (Font1, Font);
      Color := Parse (To_String (ME_Event_Handler_Ref (Item).Color_Name));
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
         Ydest + H / 4,
         Xdest + W,
         Ydest + H / 4);
      if Han_Ref /= null then
         if Han_Ref.all'Tag =
            Mast.Graphs.Event_Handlers.Concentrator'Tag
         then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 50,
               Ydest + H / 5,
               Text => "Concentrator");
         elsif Han_Ref.all'Tag = Mast.Graphs.Event_Handlers.Barrier'Tag then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 50,
               Ydest + H / 5,
               Text => "Barrier");
         else
            null;
         end if;
      end if;
   end Draw;

   -------------------------
   -- Draw Moutput Handler --
   -------------------------
   procedure Draw
     (Item         : access ME_Multi_Output_Event_Handler;
      Canvas       : access Interactive_Canvas_Record'Class;
      GC           : Gdk.GC.Gdk_GC;
      Xdest, Ydest : Gint)
   is
      Rect    : constant Gdk_Rectangle := Get_Coord (Item);
      W       : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Width);
      H       : constant Gint          :=
         To_Canvas_Coordinates (Canvas, Rect.Height);
      Han_Ref : Event_Handler_Ref      := ME_Event_Handler_Ref (Item).Han;
      Color   : Gdk.Color.Gdk_Color;
   begin
      Editor_Actions.Load_System_Font (Font1, Font);
      Color := Parse (To_String (ME_Event_Handler_Ref (Item).Color_Name));
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
         Ydest + H / 4,
         Xdest + W,
         Ydest + H / 4);
      if Han_Ref /= null then
         if Han_Ref.all'Tag =
            Mast.Graphs.Event_Handlers.Delivery_Server'Tag
         then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 50,
               Ydest + H / 5,
               Text => "Delivery Server");
         elsif Han_Ref.all'Tag =
               Mast.Graphs.Event_Handlers.Query_Server'Tag
         then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 50,
               Ydest + H / 5,
               Text => "Query Server");
         elsif Han_Ref.all'Tag =
               Mast.Graphs.Event_Handlers.Multicast'Tag
         then
            Draw_Text
              (Get_Window (Canvas),
               From_Description (Font),
               GC,
               Xdest + W / 50,
               Ydest + H / 5,
               Text => "Multicast");
         else
            null;
         end if;
      end if;
   end Draw;

   procedure Remove_Handler_From_Transaction
     (Name    : Var_String;
      Han     : Mast.Graphs.Event_Handler_Ref;
      ME_Tran : Mast_Editor.Transactions.ME_Transaction_Ref;
      Han_Id  : Natural)
   is
      Me_Han_Index                  : Mast_Editor.Event_Handlers.Lists.Index;
      Me_Item_Deleted, Me_Temp_Item : ME_Event_Handler_Ref;
   begin
      -- Remove Han from the list of handlers of the transaction
      Mast.Transactions.Remove_Event_Handler (ME_Tran.Tran.all, Han);
      -- Remove Handler from Editor_System.Me_Event_Handlers list
      Me_Han_Index    :=
         Mast_Editor.Event_Handlers.Lists.Find
           (Name,
            Editor_System.Me_Event_Handlers);
      Mast_Editor.Event_Handlers.Lists.Delete
        (Me_Han_Index,
         Me_Item_Deleted,
         Editor_System.Me_Event_Handlers);

      -- Change Id of the elements of Editor_System.Me_Event_Handlers list
      -- of the affected transaction, following Item removed =>
      -- New_Id := Old_Id-1

      Mast_Editor.Event_Handlers.Lists.Rewind
        (Editor_System.Me_Event_Handlers,
         Me_Han_Index);
      for I in
            1 ..
            Mast_Editor.Event_Handlers.Lists.Size
               (Editor_System.Me_Event_Handlers)
      loop
         Mast_Editor.Event_Handlers.Lists.Get_Next_Item
           (Me_Temp_Item,
            Editor_System.Me_Event_Handlers,
            Me_Han_Index);
         if Me_Temp_Item.ME_Tran=ME_Tran and then Me_Temp_Item.Id > Han_Id
         then
            Me_Temp_Item.Id := Me_Temp_Item.Id - 1;
         end if;
      end loop;
   end Remove_Handler_From_Transaction;

   ------------------
   -- Write Simple --
   -- (Writes the params of an existing Event Handler and
   -- refreshes the canvas)
   ------------------
   procedure Write_Simple
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Me_Event_Handler_And_Dialog_Ref)
   is
      Item             : ME_Event_Handler_Ref                        :=
        Data.It;
      Item_Old_Han     : Mast.Graphs.Event_Handler_Ref               :=
        Item.Han;
      Item_Old_ME_Tran : Mast_Editor.Transactions.ME_Transaction_Ref :=
        Item.ME_Tran;
      Item_Old_Id      : Natural                                     :=
        Item.Id;
      Item_Old_Name    : Var_String                                  :=
        Name(Item);
      SEH_Dialog       : Seh_Dialog_Access                           :=
         Seh_Dialog_Access (Data.Dia);
   begin
      if ((Get_Text (Get_Entry (SEH_Dialog.Seh_Type_Combo)) = "Activity") or
          (Get_Text (Get_Entry (SEH_Dialog.Seh_Type_Combo)) =
           "System Timed Activity"))
        and then ((Get_Text (Get_Entry (SEH_Dialog.Ser_Combo)) = "(NONE)") or
                  (Get_Text (Get_Entry (SEH_Dialog.Op_Combo)) = "(NONE)"))
      then
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Server and Operation can't be set to (NONE)!");
         Show_All (Editor_Error_Window);
      else
         Write_Parameters (Item, Gtk_Dialog (SEH_Dialog));
         -- we now delete the old item from the transaction
         Remove_Handler_From_Transaction
           (Item_Old_Name,
            Item_Old_Han,
            Item_Old_ME_Tran,
            Item_Old_Id);
         -- and add the new one
         Mast.Transactions.Add_Event_Handler
           (Item.ME_Tran.Tran.all,
            Item.Han);
         Item.Id :=
            Mast.Transactions.Num_Of_Event_Handlers (Item.ME_Tran.Tran.all);
         Mast_Editor.Event_Handlers.Lists.Add
           (Item,
            Editor_System.Me_Event_Handlers);

         Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
         Destroy (SEH_Dialog);
      end if;
   exception
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, " Invalid Value !!!");
         Show_All (Editor_Error_Window);
         Destroy (SEH_Dialog);
   end Write_Simple;

   ------------------
   -- Write Minput --  (Writes the params of an existing Event Handler and
   --refreshes the canvas)
   ------------------
   procedure Write_Minput
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Me_Event_Handler_And_Dialog_Ref)
   is
      Item             : ME_Event_Handler_Ref := Data.It;
      Item_Old_Han     : Mast.Graphs.Event_Handler_Ref               :=
        Item.Han;
      Item_Old_ME_Tran : Mast_Editor.Transactions.ME_Transaction_Ref :=
        Item.ME_Tran;
      Item_Old_Id      : Natural                                     :=
        Item.Id;
      Item_Old_Name    : Var_String                                  :=
        Name(Item);
      MIEH_Dialog : Mieh_Dialog_Access   := Mieh_Dialog_Access (Data.Dia);
   begin
      Write_Parameters (Item, Gtk_Dialog (MIEH_Dialog));

      -- we now delete the old item from the transaction
      Remove_Handler_From_Transaction
        (Item_Old_Name,
         Item_Old_Han,
         Item_Old_ME_Tran,
         Item_Old_Id);
      -- and add the new one
      Mast.Transactions.Add_Event_Handler
        (Item.ME_Tran.Tran.all,
         Item.Han);
      Item.Id :=
        Mast.Transactions.Num_Of_Event_Handlers (Item.ME_Tran.Tran.all);
      Mast_Editor.Event_Handlers.Lists.Add
        (Item,
         Editor_System.Me_Event_Handlers);

      Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
      Destroy (MIEH_Dialog);
   exception
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, " Invalid Value !!!");
         Show_All (Editor_Error_Window);
         Destroy (MIEH_Dialog);
   end Write_Minput;

   -------------------
   -- Write Moutput --  (Writes the params of an existing Event Handler and
   --refreshes the canvas)
   -------------------
   procedure Write_Moutput
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Me_Event_Handler_And_Dialog_Ref)
   is
      Item        : ME_Event_Handler_Ref := Data.It;
      Item_Old_Han     : Mast.Graphs.Event_Handler_Ref               :=
        Item.Han;
      Item_Old_ME_Tran : Mast_Editor.Transactions.ME_Transaction_Ref :=
        Item.ME_Tran;
      Item_Old_Id      : Natural                                     :=
        Item.Id;
      Item_Old_Name    : Var_String                                  :=
        Name(Item);
      MOEH_Dialog : Moeh_Dialog_Access   := Moeh_Dialog_Access (Data.Dia);
   begin
      Write_Parameters (Item, Gtk_Dialog (MOEH_Dialog));

      -- we now delete the old item from the transaction
      Remove_Handler_From_Transaction
        (Item_Old_Name,
         Item_Old_Han,
         Item_Old_ME_Tran,
         Item_Old_Id);
      -- and add the new one
      Mast.Transactions.Add_Event_Handler
        (Item.ME_Tran.Tran.all,
         Item.Han);
      Item.Id :=
        Mast.Transactions.Num_Of_Event_Handlers (Item.ME_Tran.Tran.all);
      Mast_Editor.Event_Handlers.Lists.Add
        (Item,
         Editor_System.Me_Event_Handlers);

      Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
      Destroy (MOEH_Dialog);
   exception
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, " Invalid Value !!!");
         Show_All (Editor_Error_Window);
         Destroy (MOEH_Dialog);
   end Write_Moutput;

   ----------------
   -- New Simple
   -- (Add new Simple event handler to canvas and to the transaction)
   ----------------
   procedure New_Simple
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Me_Event_Handler_And_Dialog_Ref)
   is
      Item       : ME_Event_Handler_Ref := Data.It;
      SEH_Dialog : Seh_Dialog_Access    := Seh_Dialog_Access (Data.Dia);
   begin
      if ((Get_Text (Get_Entry (SEH_Dialog.Seh_Type_Combo)) = "Activity") or
          (Get_Text (Get_Entry (SEH_Dialog.Seh_Type_Combo)) =
           "System Timed Activity"))
        and then ((Get_Text (Get_Entry (SEH_Dialog.Ser_Combo)) = "(NONE)") or
                  (Get_Text (Get_Entry (SEH_Dialog.Op_Combo)) = "(NONE)"))
      then
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Server and Operation can't be set to (NONE)!");
         Show_All (Editor_Error_Window);
      else
         Write_Parameters (Item, Gtk_Dialog (SEH_Dialog));
         Mast.Transactions.Add_Event_Handler
           (Item.ME_Tran.Tran.all,
            Item.Han);
         Item.Id :=
            Mast.Transactions.Num_Of_Event_Handlers (Item.ME_Tran.Tran.all);
         Mast_Editor.Event_Handlers.Lists.Add
           (Item,
            Editor_System.Me_Event_Handlers);
         Set_Screen_Size (Item, Item.W, Item.H);
         Put (Item.ME_Tran.Dialog.Trans_Canvas, Item);
         Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
         Show_Item (Item.ME_Tran.Dialog.Trans_Canvas, Item);
         Destroy (SEH_Dialog);
      end if;
   exception
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Invalid Value !!!");
         Show_All (Editor_Error_Window);
         Destroy (SEH_Dialog);
      when Already_Exists =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Event Handler Already Exists !!!");
         Show_All (Editor_Error_Window);
         Destroy (SEH_Dialog);
   end New_Simple;

   ----------------
   -- New Minput -- (Add new Minput event handler to canvas and to the
   --transaction)
   ----------------
   procedure New_Minput
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Me_Event_Handler_And_Dialog_Ref)
   is
      Item        : ME_Event_Handler_Ref := Data.It;
      MIEH_Dialog : Mieh_Dialog_Access   := Mieh_Dialog_Access (Data.Dia);
   begin
      Write_Parameters (Item, Gtk_Dialog (MIEH_Dialog));
      Mast.Transactions.Add_Event_Handler (Item.ME_Tran.Tran.all, Item.Han);
      Item.Id :=
         Mast.Transactions.Num_Of_Event_Handlers (Item.ME_Tran.Tran.all);
      Mast_Editor.Event_Handlers.Lists.Add
        (Item,
         Editor_System.Me_Event_Handlers);
      Set_Screen_Size (Item, Item.W, Item.H);
      Put (Item.ME_Tran.Dialog.Trans_Canvas, Item);
      Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
      Show_Item (Item.ME_Tran.Dialog.Trans_Canvas, Item);
      Destroy (MIEH_Dialog);
   exception
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Invalid Value !!!");
         Show_All (Editor_Error_Window);
         Destroy (MIEH_Dialog);
      when Already_Exists =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Event Handler Already Exists !!!");
         Show_All (Editor_Error_Window);
         Destroy (MIEH_Dialog);
   end New_Minput;

   -----------------
   -- New Moutput -- (Add new Moutput event handler to canvas and to the
   --transaction)
   -----------------
   procedure New_Moutput
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Me_Event_Handler_And_Dialog_Ref)
   is
      Item        : ME_Event_Handler_Ref := Data.It;
      MOEH_Dialog : Moeh_Dialog_Access   := Moeh_Dialog_Access (Data.Dia);
   begin
      Write_Parameters (Item, Gtk_Dialog (MOEH_Dialog));
      Mast.Transactions.Add_Event_Handler (Item.ME_Tran.Tran.all, Item.Han);
      Item.Id :=
         Mast.Transactions.Num_Of_Event_Handlers (Item.ME_Tran.Tran.all);
      Mast_Editor.Event_Handlers.Lists.Add
        (Item,
         Editor_System.Me_Event_Handlers);
      Set_Screen_Size (Item, Item.W, Item.H);
      Put (Item.ME_Tran.Dialog.Trans_Canvas, Item);
      Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
      Show_Item (Item.ME_Tran.Dialog.Trans_Canvas, Item);
      Destroy (MOEH_Dialog);
   exception
      when Constraint_Error =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "Invalid Value !!!");
         Show_All (Editor_Error_Window);
         Destroy (MOEH_Dialog);
      when Already_Exists =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Event Handler Already Exists !!!");
         Show_All (Editor_Error_Window);
         Destroy (MOEH_Dialog);
   end New_Moutput;

   --------------------------------------
   -- Show Simple Event Handler Dialog --
   --------------------------------------
   procedure Show_Simple_Event_Handler_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Res    : ME_Transaction_Ref)
   is
      Item       : ME_Event_Handler_Ref            :=
         new ME_Simple_Event_Handler;
      SEH_Dialog : Seh_Dialog_Access;
      Me_Data    : Me_Event_Handler_And_Dialog_Ref :=
         new Me_Event_Handler_And_Dialog;
   begin
      Item.W           := Handler_Width;
      Item.H           := Handler_Height;
      Item.Canvas_Name := Name (Res);
      Item.Color_Name  := Handler_Color;
      Item.ME_Tran     := Res;

      Gtk_New (SEH_Dialog);
      Read_Parameters (Item, Gtk_Dialog (SEH_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (SEH_Dialog);

      Me_Event_Handler_And_Dialog_Cb.Connect
        (SEH_Dialog.Ok_Button,
         "clicked",
         Me_Event_Handler_And_Dialog_Cb.To_Marshaller (New_Simple'Access),
         Me_Data);

   end Show_Simple_Event_Handler_Dialog;

   -------------------------------------------
   -- Show Multi-Input Event Handler Dialog --
   -------------------------------------------
   procedure Show_Multi_Input_Event_Handler_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Res    : ME_Transaction_Ref)
   is
      Item        : ME_Event_Handler_Ref            :=
         new ME_Multi_Input_Event_Handler;
      MIEH_Dialog : Mieh_Dialog_Access;
      Me_Data     : Me_Event_Handler_And_Dialog_Ref :=
         new Me_Event_Handler_And_Dialog;
   begin
      Item.W           := Handler_Width;
      Item.H           := Handler_Height;
      Item.Canvas_Name := Name (Res);
      Item.Color_Name  := Handler_Color;
      Item.ME_Tran     := Res;

      Gtk_New (MIEH_Dialog);
      Read_Parameters (Item, Gtk_Dialog (MIEH_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (MIEH_Dialog);

      Me_Event_Handler_And_Dialog_Cb.Connect
        (MIEH_Dialog.Ok_Button,
         "clicked",
         Me_Event_Handler_And_Dialog_Cb.To_Marshaller (New_Minput'Access),
         Me_Data);

   end Show_Multi_Input_Event_Handler_Dialog;

   --------------------------------------------
   -- Show Multi-Output Event Handler Dialog --
   --------------------------------------------
   procedure Show_Multi_Output_Event_Handler_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Res    : ME_Transaction_Ref)
   is
      Item        : ME_Event_Handler_Ref            :=
         new ME_Multi_Output_Event_Handler;
      MOEH_Dialog : Moeh_Dialog_Access;
      Me_Data     : Me_Event_Handler_And_Dialog_Ref :=
         new Me_Event_Handler_And_Dialog;
   begin
      Item.W           := Handler_Width;
      Item.H           := Handler_Height;
      Item.Canvas_Name := Name (Res);
      Item.Color_Name  := Handler_Color;
      Item.ME_Tran     := Res;

      Gtk_New (MOEH_Dialog);
      Read_Parameters (Item, Gtk_Dialog (MOEH_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (MOEH_Dialog);

      Me_Event_Handler_And_Dialog_Cb.Connect
        (MOEH_Dialog.Ok_Button,
         "clicked",
         Me_Event_Handler_And_Dialog_Cb.To_Marshaller (New_Moutput'Access),
         Me_Data);

   end Show_Multi_Output_Event_Handler_Dialog;

   --------------------
   -- Remove_Handler --
   --------------------
   procedure Remove_Handler
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Event_Handler_Ref)
   is
   begin
      if Message_Dialog
            (" Do you really want to remove this object? ",
             Confirmation,
             Button_Yes or Button_No,
             Button_Yes) =
         Button_Yes
      then
         Remove_Handler_From_Transaction
           (Name (Item),
            Item.Han,
            Item.ME_Tran,
            Item.Id);
         Remove (Item.ME_Tran.Dialog.Trans_Canvas, Item);
         Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
         Change_Control.Changes_Made;
         Destroy (Item_Menu);
      end if;
   exception
      when others =>
         Gtk_New (Editor_Error_Window);
         Set_Text (Editor_Error_Window.Label, "ERROR IN HANDLER REMOVAL !!!");
         Show_All (Editor_Error_Window);
         Destroy (Item_Menu);
   end Remove_Handler;

   -----------------------
   -- Properties_Simple --
   -----------------------
   procedure Properties_Simple
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Event_Handler_Ref)
   is
      SEH_Dialog : Seh_Dialog_Access;
      Me_Data    : Me_Event_Handler_And_Dialog_Ref :=
         new Me_Event_Handler_And_Dialog;
   begin
      Gtk_New (SEH_Dialog);
      Read_Parameters (Item, Gtk_Dialog (SEH_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (SEH_Dialog);

      Me_Event_Handler_And_Dialog_Cb.Connect
        (SEH_Dialog.Ok_Button,
         "clicked",
         Me_Event_Handler_And_Dialog_Cb.To_Marshaller (Write_Simple'Access),
         Me_Data);

      Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
      Destroy (Item_Menu);
   end Properties_Simple;

   ------------------------
   -- Properties_Minput  --
   ------------------------
   procedure Properties_Minput
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Event_Handler_Ref)
   is
      MIEH_Dialog : Mieh_Dialog_Access;
      Me_Data     : Me_Event_Handler_And_Dialog_Ref :=
         new Me_Event_Handler_And_Dialog;
   begin
      Gtk_New (MIEH_Dialog);
      Read_Parameters (Item, Gtk_Dialog (MIEH_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (MIEH_Dialog);

      Me_Event_Handler_And_Dialog_Cb.Connect
        (MIEH_Dialog.Ok_Button,
         "clicked",
         Me_Event_Handler_And_Dialog_Cb.To_Marshaller (Write_Minput'Access),
         Me_Data);

      Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
      Destroy (Item_Menu);
   end Properties_Minput;

   -------------------------
   -- Properties_Moutput  --
   -------------------------
   procedure Properties_Moutput
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Event_Handler_Ref)
   is
      MOEH_Dialog : Moeh_Dialog_Access;
      Me_Data     : Me_Event_Handler_And_Dialog_Ref :=
         new Me_Event_Handler_And_Dialog;
   begin
      Gtk_New (MOEH_Dialog);
      Read_Parameters (Item, Gtk_Dialog (MOEH_Dialog));
      Me_Data.It  := Item;
      Me_Data.Dia := Gtk_Dialog (MOEH_Dialog);

      Me_Event_Handler_And_Dialog_Cb.Connect
        (MOEH_Dialog.Ok_Button,
         "clicked",
         Me_Event_Handler_And_Dialog_Cb.To_Marshaller (Write_Moutput'Access),
         Me_Data);

      Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
      Destroy (Item_Menu);
   end Properties_Moutput;

   --------------------------------
   -- Add_Link_To_Internal_Event --
   --------------------------------
   procedure Add_Link_To_Internal_Event
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Me_Event_Handler_And_Dialog_Ref)
   is
      Item            : ME_Event_Handler_Ref   := Data.It;
      Add_Link_Dialog : Add_Link_Dialog_Access :=
         Add_Link_Dialog_Access (Data.Dia);

      Han_Ref         : Mast.Graphs.Event_Handler_Ref := Item.Han;
      Old_Han_Ref     : Mast.Graphs.Event_Handler_Ref;
      Lin_Ref         : Mast.Graphs.Link_Ref;
      Old_Lin_Ref     : Mast.Graphs.Link_Ref;
      Lin_Index       : Mast.Transactions.Link_Iteration_Object;
      Lin_Name        : Var_Strings.Var_String;
      Me_Lin_Name     : Var_String;
      Me_Lin_Iterator : Mast_Editor.Links.Lists.Iteration_Object;
      Me_Lin_Ref      : ME_Link_Ref;
   begin
      Lin_Name :=
         To_Var_String (Get_Text (Get_Entry (Add_Link_Dialog.Combo)));
      if (Item.ME_Tran.Tran /= null)
        and then ((Get_Text (Get_Entry (Add_Link_Dialog.Combo))) /= "")
        and then (Han_Ref /= null)
      then
         Lin_Ref :=
            Mast.Transactions.Find_Internal_Event_Link
              (Lin_Name,
               Item.ME_Tran.Tran.all);
         if Han_Ref.all in Mast.Graphs.Event_Handlers.Simple_Event_Handler'
              Class
         then
            Old_Han_Ref := Mast.Graphs.Input_Event_Handler (Lin_Ref.all);
            if Old_Han_Ref = null then

               -- we should free old input link pointer to old event
               Old_Lin_Ref :=
                  Mast.Graphs.Event_Handlers.Output_Link
                    (Simple_Event_Handler (Han_Ref.all));
               if Old_Lin_Ref /= null then
                  Mast.Graphs.Set_Input_Event_Handler (Old_Lin_Ref.all, null);
               end if;

               Mast.Graphs.Event_Handlers.Set_Output_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler (Han_Ref.all)
,
                  Lin_Ref);
               Mast.Graphs.Set_Input_Event_Handler (Lin_Ref.all, Item.Han);
               Editor_Actions.Remove_Old_Links
                 (Item.ME_Tran.Dialog.Trans_Canvas,
                  Item);   -- we should remove the old link to former event
                           -- we search the link in Me_Links list
               Me_Lin_Name     := Lin_Name & Delimiter & Name (Item.ME_Tran);
               Me_Lin_Iterator :=
                  Mast_Editor.Links.Lists.Find
                    (Me_Lin_Name,
                     Editor_System.Me_Links);
               Me_Lin_Ref      :=
                  Mast_Editor.Links.Lists.Item
                    (Me_Lin_Iterator,
                     Editor_System.Me_Links);
               Add_Canvas_Link
                 (Item.ME_Tran.Dialog.Trans_Canvas,
                  Item,
                  Me_Lin_Ref);
               Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
            else
               Gtk_New (Editor_Error_Window);
               Set_Text
                 (Editor_Error_Window.Label,
                  "Internal Event Has Another Input Link!!!");
               Show_All (Editor_Error_Window);
            end if;
         elsif Han_Ref.all in Mast.Graphs.Event_Handlers.Input_Event_Handler'
              Class
         then
            Old_Han_Ref := Mast.Graphs.Input_Event_Handler (Lin_Ref.all);
            if Old_Han_Ref = null then

               -- we should free old input link pointer to old event
               Old_Lin_Ref :=
                  Mast.Graphs.Event_Handlers.Output_Link
                    (Mast.Graphs.Event_Handlers.Input_Event_Handler (Han_Ref.
all));
               if Old_Lin_Ref /= null then
                  Mast.Graphs.Set_Input_Event_Handler (Old_Lin_Ref.all, null);
               end if;

               Mast.Graphs.Event_Handlers.Set_Output_Link
                 (Mast.Graphs.Event_Handlers.Input_Event_Handler (Han_Ref.all),
                  Lin_Ref);
               Mast.Graphs.Set_Input_Event_Handler (Lin_Ref.all, Item.Han);
               Editor_Actions.Remove_Old_Links
                 (Item.ME_Tran.Dialog.Trans_Canvas,
                  Item); -- we should remove the old link to former event
               Me_Lin_Name     := Lin_Name & Delimiter & Name (Item.ME_Tran);
               Me_Lin_Iterator :=
                  Mast_Editor.Links.Lists.Find
                    (Me_Lin_Name,
                     Editor_System.Me_Links);
               Me_Lin_Ref      :=
                  Mast_Editor.Links.Lists.Item
                    (Me_Lin_Iterator,
                     Editor_System.Me_Links);
               Add_Canvas_Link
                 (Item.ME_Tran.Dialog.Trans_Canvas,
                  Item,
                  Me_Lin_Ref);
               Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
            else
               Gtk_New (Editor_Error_Window);
               Set_Text
                 (Editor_Error_Window.Label,
                  "Internal Event Has Another Input Link!!!");
               Show_All (Editor_Error_Window);
            end if;
         elsif Han_Ref.all in Mast.Graphs.Event_Handlers.Output_Event_Handler'
              Class
         then
            Old_Han_Ref := Mast.Graphs.Input_Event_Handler (Lin_Ref.all);
            if Old_Han_Ref = null then
               Mast.Graphs.Event_Handlers.Add_Output_Link
                 (Mast.Graphs.Event_Handlers.Output_Event_Handler (Han_Ref.all)
,
                  Lin_Ref);
               Mast.Graphs.Set_Input_Event_Handler (Lin_Ref.all, Item.Han);
               Me_Lin_Name     := Lin_Name & Delimiter & Name (Item.ME_Tran);
               Me_Lin_Iterator :=
                  Mast_Editor.Links.Lists.Find
                    (Me_Lin_Name,
                     Editor_System.Me_Links);
               Me_Lin_Ref      :=
                  Mast_Editor.Links.Lists.Item
                    (Me_Lin_Iterator,
                     Editor_System.Me_Links);
               Add_Canvas_Link
                 (Item.ME_Tran.Dialog.Trans_Canvas,
                  Item,
                  Me_Lin_Ref);
               Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
            else
               Gtk_New (Editor_Error_Window);
               Set_Text
                 (Editor_Error_Window.Label,
                  "Internal Event Has Another Input Link!!!");
               Show_All (Editor_Error_Window);
            end if;
         end if;
      end if;
      Destroy (Add_Link_Dialog);
   exception
      when Link_Not_Found =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Error while searching Internal Event !!!");
         Show_All (Editor_Error_Window);
         Destroy (Add_Link_Dialog);
      when Already_Exists =>
         Destroy (Add_Link_Dialog);
      when Invalid_Index => -- internal event not found
         null;
   end Add_Link_To_Internal_Event;

   -------------------------
   -- Add_Link_From_Event --
   -------------------------
   procedure Add_Link_From_Event
     (Widget : access Gtk_Widget_Record'Class;
      Data   : Me_Event_Handler_And_Dialog_Ref)
   is
      Item            : ME_Event_Handler_Ref   := Data.It;
      Add_Link_Dialog : Add_Link_Dialog_Access :=
         Add_Link_Dialog_Access (Data.Dia);

      Han_Ref         : Mast.Graphs.Event_Handler_Ref := Item.Han;
      Old_Han_Ref     : Mast.Graphs.Event_Handler_Ref;
      Lin_Ref         : Mast.Graphs.Link_Ref;
      Old_Lin_Ref     : Mast.Graphs.Link_Ref;
      Lin_Index       : Mast.Transactions.Link_Iteration_Object;
      Lin_Name        : Var_Strings.Var_String;
      Me_Lin_Name     : Var_String;
      Me_Lin_Iterator : Mast_Editor.Links.Lists.Iteration_Object;
      Me_Lin_Ref      : ME_Link_Ref;
   begin
      Lin_Name :=
         To_Var_String (Get_Text (Get_Entry (Add_Link_Dialog.Combo)));
      if (Item.ME_Tran.Tran /= null)
        and then ((Get_Text (Get_Entry (Add_Link_Dialog.Combo))) /= "")
        and then (Han_Ref /= null)
      then
         Lin_Ref :=
            Mast.Transactions.Find_Any_Link (Lin_Name, Item.ME_Tran.Tran.all);
         if Han_Ref.all in Mast.Graphs.Event_Handlers.Simple_Event_Handler'
              Class
         then
            Old_Han_Ref := Mast.Graphs.Output_Event_Handler (Lin_Ref.all);
            if Old_Han_Ref = null then
               -- we should free old input link from old event
               Old_Lin_Ref :=
                  Mast.Graphs.Event_Handlers.Input_Link
                    (Simple_Event_Handler (Han_Ref.all));
               if Old_Lin_Ref /= null then
                  Mast.Graphs.Set_Output_Event_Handler
                    (Old_Lin_Ref.all,
                     null);
               end if;
               Mast.Graphs.Event_Handlers.Set_Input_Link
                 (Mast.Graphs.Event_Handlers.Simple_Event_Handler (Han_Ref.all)
,
                  Lin_Ref);
               Mast.Graphs.Set_Output_Event_Handler (Lin_Ref.all, Item.Han);
               Editor_Actions.Remove_Old_Links
                 (Item.ME_Tran.Dialog.Trans_Canvas,
                  Item,
                  False);  -- we should remove old link from former event
                           -- we search the link in Me_Links list
               Me_Lin_Name     := Lin_Name & Delimiter & Name (Item.ME_Tran);
               Me_Lin_Iterator :=
                  Mast_Editor.Links.Lists.Find
                    (Me_Lin_Name,
                     Editor_System.Me_Links);
               Me_Lin_Ref      :=
                  Mast_Editor.Links.Lists.Item
                    (Me_Lin_Iterator,
                     Editor_System.Me_Links);
               Add_Canvas_Link
                 (Item.ME_Tran.Dialog.Trans_Canvas,
                  Me_Lin_Ref,
                  Item);
               Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
            else
               Gtk_New (Editor_Error_Window);
               Set_Text
                 (Editor_Error_Window.Label,
                  "Event Has Another Output Link!!!");
               Show_All (Editor_Error_Window);
            end if;
         elsif Han_Ref.all in Mast.Graphs.Event_Handlers.Input_Event_Handler'
              Class
         then
            Old_Han_Ref := Mast.Graphs.Output_Event_Handler (Lin_Ref.all);
            if Old_Han_Ref = null then
               Mast.Graphs.Event_Handlers.Add_Input_Link
                 (Mast.Graphs.Event_Handlers.Input_Event_Handler (Han_Ref.all),
                  Lin_Ref);
               Mast.Graphs.Set_Output_Event_Handler (Lin_Ref.all, Item.Han);
               Me_Lin_Name     := Lin_Name & Delimiter & Name (Item.ME_Tran);
               Me_Lin_Iterator :=
                  Mast_Editor.Links.Lists.Find
                    (Me_Lin_Name,
                     Editor_System.Me_Links);
               Me_Lin_Ref      :=
                  Mast_Editor.Links.Lists.Item
                    (Me_Lin_Iterator,
                     Editor_System.Me_Links);
               Add_Canvas_Link
                 (Item.ME_Tran.Dialog.Trans_Canvas,
                  Me_Lin_Ref,
                  Item);
               Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
            else
               Gtk_New (Editor_Error_Window);
               Set_Text
                 (Editor_Error_Window.Label,
                  "Event Has Another Output Link!!!");
               Show_All (Editor_Error_Window);
            end if;
         elsif Han_Ref.all in Mast.Graphs.Event_Handlers.Output_Event_Handler'
              Class
         then
            Old_Han_Ref := Mast.Graphs.Output_Event_Handler (Lin_Ref.all);
            if Old_Han_Ref = null then
               -- we should free old input link from old event
               Old_Lin_Ref :=
                  Mast.Graphs.Event_Handlers.Input_Link
                    (Mast.Graphs.Event_Handlers.Output_Event_Handler (Han_Ref.
all));
               if Old_Lin_Ref /= null then
                  Mast.Graphs.Set_Output_Event_Handler
                    (Old_Lin_Ref.all,
                     null);
               end if;
               Mast.Graphs.Event_Handlers.Set_Input_Link
                 (Mast.Graphs.Event_Handlers.Output_Event_Handler (Han_Ref.all)
,
                  Lin_Ref);
               Mast.Graphs.Set_Output_Event_Handler (Lin_Ref.all, Item.Han);
               Editor_Actions.Remove_Old_Links
                 (Item.ME_Tran.Dialog.Trans_Canvas,
                  Item,
                  False);  -- we should remove old link from former event
                           -- we search the link in Me_Links list
               Me_Lin_Name     := Lin_Name & Delimiter & Name (Item.ME_Tran);
               Me_Lin_Iterator :=
                  Mast_Editor.Links.Lists.Find
                    (Me_Lin_Name,
                     Editor_System.Me_Links);
               Me_Lin_Ref      :=
                  Mast_Editor.Links.Lists.Item
                    (Me_Lin_Iterator,
                     Editor_System.Me_Links);
               Add_Canvas_Link
                 (Item.ME_Tran.Dialog.Trans_Canvas,
                  Me_Lin_Ref,
                  Item);
               Refresh_Canvas (Item.ME_Tran.Dialog.Trans_Canvas);
            else
               Gtk_New (Editor_Error_Window);
               Set_Text
                 (Editor_Error_Window.Label,
                  "Event Has Another Input Link!!!");
               Show_All (Editor_Error_Window);
            end if;
         end if;
      end if;
      Destroy (Add_Link_Dialog);
   exception
      when Link_Not_Found =>
         Gtk_New (Editor_Error_Window);
         Set_Text
           (Editor_Error_Window.Label,
            "Error while searching Event !!!");
         Show_All (Editor_Error_Window);
         Destroy (Add_Link_Dialog);
      when Already_Exists =>
         Destroy (Add_Link_Dialog);
      when Invalid_Index => -- internal event not found
         null;
   end Add_Link_From_Event;

   --------------------------------------
   -- Show_Internal_Events_List_Dialog --
   --------------------------------------
   procedure Show_Internal_Events_List_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Event_Handler_Ref)
   is
      Eve_Ref         : Mast.Graphs.Link_Ref;
      Eve_Index       : Mast.Transactions.Link_Iteration_Object;
      Eve_Name        : Var_Strings.Var_String;
      Add_Link_Dialog : Add_Link_Dialog_Access;
      Data            : Me_Event_Handler_And_Dialog_Ref :=
         new Me_Event_Handler_And_Dialog;
   begin
      -- We search Internal Events of the transaction and show them in Combo
      Mast.Transactions.Rewind_Internal_Event_Links
        (Item.ME_Tran.Tran.all,
         Eve_Index);
      for I in
            1 ..
            Mast.Transactions.Num_Of_Internal_Event_Links
               (Item.ME_Tran.Tran.all)
      loop
         Mast.Transactions.Get_Next_Internal_Event_Link
           (Item.ME_Tran.Tran.all,
            Eve_Ref,
            Eve_Index);
         Eve_Name := Mast.Graphs.Name (Eve_Ref.all);
         String_List.Append (Combo_Items, Name_Image (Eve_Name));
      end loop;

      Gtk_New (Add_Link_Dialog);
      Set_Text (Add_Link_Dialog.Label, "Internal Events List");
      Show_All (Add_Link_Dialog);

      Data.It  := Item;
      Data.Dia := Gtk_Dialog (Add_Link_Dialog);

      Me_Event_Handler_And_Dialog_Cb.Connect
        (Add_Link_Dialog.Ok_Button,
         "clicked",
         Me_Event_Handler_And_Dialog_Cb.To_Marshaller
            (Add_Link_To_Internal_Event'Access),
         Data);

      Destroy (Item_Menu);
   end Show_Internal_Events_List_Dialog;

   -----------------------------
   -- Show_Events_List_Dialog --
   -----------------------------
   procedure Show_Events_List_Dialog
     (Widget : access Gtk_Widget_Record'Class;
      Item   : ME_Event_Handler_Ref)
   is
      Eve_Ref         : Mast.Graphs.Link_Ref;
      Eve_Index       : Mast.Transactions.Link_Iteration_Object;
      Eve_Name        : Var_Strings.Var_String;
      Add_Link_Dialog : Add_Link_Dialog_Access;
      Data            : Me_Event_Handler_And_Dialog_Ref :=
         new Me_Event_Handler_And_Dialog;
   begin
      -- We search Internal Events of the transaction and show them in Combo
      Mast.Transactions.Rewind_Internal_Event_Links
        (Item.ME_Tran.Tran.all,
         Eve_Index);
      for I in
            1 ..
            Mast.Transactions.Num_Of_Internal_Event_Links
               (Item.ME_Tran.Tran.all)
      loop
         Mast.Transactions.Get_Next_Internal_Event_Link
           (Item.ME_Tran.Tran.all,
            Eve_Ref,
            Eve_Index);
         Eve_Name := Mast.Graphs.Name (Eve_Ref.all);
         String_List.Append (Combo_Items, Name_Image (Eve_Name));
      end loop;

      -- We search External Events of the transaction and show them in Combo
      Mast.Transactions.Rewind_External_Event_Links
        (Item.ME_Tran.Tran.all,
         Eve_Index);
      for I in
            1 ..
            Mast.Transactions.Num_Of_External_Event_Links
               (Item.ME_Tran.Tran.all)
      loop
         Mast.Transactions.Get_Next_External_Event_Link
           (Item.ME_Tran.Tran.all,
            Eve_Ref,
            Eve_Index);
         Eve_Name := Mast.Graphs.Name (Eve_Ref.all);
         String_List.Append (Combo_Items, Name_Image (Eve_Name));
      end loop;

      Gtk_New (Add_Link_Dialog);
      Set_Text (Add_Link_Dialog.Label, "Events List");
      Show_All (Add_Link_Dialog);

      Data.It  := Item;
      Data.Dia := Gtk_Dialog (Add_Link_Dialog);

      Me_Event_Handler_And_Dialog_Cb.Connect
        (Add_Link_Dialog.Ok_Button,
         "clicked",
         Me_Event_Handler_And_Dialog_Cb.To_Marshaller
            (Add_Link_From_Event'Access),
         Data);

      Destroy (Item_Menu);
   end Show_Events_List_Dialog;

   ---------------------
   -- On Button Click --
   ---------------------
   procedure On_Button_Click
     (Item  : access ME_Simple_Event_Handler;
      Event : Gdk.Event.Gdk_Event_Button)
   is
      Num_Button                : Guint;
      Event_Type                : Gdk_Event_Type;
      Set_Out_Link, Set_In_Link : Gtk_Menu_Item;
      SEH_Dialog                : Seh_Dialog_Access;
      Me_Data                   : Me_Event_Handler_And_Dialog_Ref :=
         new Me_Event_Handler_And_Dialog;
   begin
      if Event /= null then
         Event_Type := Get_Event_Type (Event);
         if Event_Type = Gdk_2button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (1) then

               Gtk_New (SEH_Dialog);
               Read_Parameters (Item, Gtk_Dialog (SEH_Dialog));
               Me_Data.It  := ME_Event_Handler_Ref (Item);
               Me_Data.Dia := Gtk_Dialog (SEH_Dialog);

               Me_Event_Handler_And_Dialog_Cb.Connect
                 (SEH_Dialog.Ok_Button,
                  "clicked",
                  Me_Event_Handler_And_Dialog_Cb.To_Marshaller
                     (Write_Simple'Access),
                  Me_Data);

            end if;
         elsif Event_Type = Button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (3) then
               Gtk_New (Item_Menu);
               --We add new options to item_menu
               Gtk_New (Set_Out_Link, "Set Output Link...");
               Set_Right_Justify (Set_Out_Link, False);
               Prepend (Item_Menu, Set_Out_Link);
               Show (Set_Out_Link);
               Gtk_New (Set_In_Link, "Set Input Link...");
               Set_Right_Justify (Set_In_Link, False);
               Prepend (Item_Menu, Set_In_Link);
               Show (Set_In_Link);
               -------------------
               Button_Cb.Connect
                 (Set_Out_Link,
                  "activate",
                  Button_Cb.To_Marshaller
                     (Show_Internal_Events_List_Dialog'Access),
                  ME_Event_Handler_Ref (Item));
               Button_Cb.Connect
                 (Set_In_Link,
                  "activate",
                  Button_Cb.To_Marshaller (Show_Events_List_Dialog'Access),
                  ME_Event_Handler_Ref (Item));
               -------------------
               Button_Cb.Connect
                 (Item_Menu.Remove,
                  "activate",
                  Button_Cb.To_Marshaller (Remove_Handler'Access),
                  ME_Event_Handler_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Properties,
                  "activate",
                  Button_Cb.To_Marshaller (Properties_Simple'Access),
                  ME_Event_Handler_Ref (Item));
            end if;
         end if;
      end if;
   exception
      when Storage_Error =>
         null;
   end On_Button_Click;

   ---------------------
   -- On Button Click --
   ---------------------
   procedure On_Button_Click
     (Item  : access ME_Multi_Input_Event_Handler;
      Event : Gdk.Event.Gdk_Event_Button)
   is
      Num_Button                : Guint;
      Event_Type                : Gdk_Event_Type;
      Set_Out_Link, Set_In_Link : Gtk_Menu_Item;
      MIEH_Dialog               : Mieh_Dialog_Access;
      Me_Data                   : Me_Event_Handler_And_Dialog_Ref :=
         new Me_Event_Handler_And_Dialog;
   begin
      if Event /= null then
         Event_Type := Get_Event_Type (Event);
         if Event_Type = Gdk_2button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (1) then

               Gtk_New (MIEH_Dialog);
               Read_Parameters (Item, Gtk_Dialog (MIEH_Dialog));
               Me_Data.It  := ME_Event_Handler_Ref (Item);
               Me_Data.Dia := Gtk_Dialog (MIEH_Dialog);

               Me_Event_Handler_And_Dialog_Cb.Connect
                 (MIEH_Dialog.Ok_Button,
                  "clicked",
                  Me_Event_Handler_And_Dialog_Cb.To_Marshaller
                     (Write_Minput'Access),
                  Me_Data);

            end if;
         elsif Event_Type = Button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (3) then
               Gtk_New (Item_Menu);
               --We add new options to item_menu
               Gtk_New (Set_Out_Link, "Set Output Link...");
               Set_Right_Justify (Set_Out_Link, False);
               Prepend (Item_Menu, Set_Out_Link);
               Show (Set_Out_Link);
               Gtk_New (Set_In_Link, "Add Input Link...");
               Set_Right_Justify (Set_In_Link, False);
               Prepend (Item_Menu, Set_In_Link);
               Show (Set_In_Link);
               -------------------
               Button_Cb.Connect
                 (Set_Out_Link,
                  "activate",
                  Button_Cb.To_Marshaller
                     (Show_Internal_Events_List_Dialog'Access),
                  ME_Event_Handler_Ref (Item));
               Button_Cb.Connect
                 (Set_In_Link,
                  "activate",
                  Button_Cb.To_Marshaller (Show_Events_List_Dialog'Access),
                  ME_Event_Handler_Ref (Item));
               -------------------
               Button_Cb.Connect
                 (Item_Menu.Remove,
                  "activate",
                  Button_Cb.To_Marshaller (Remove_Handler'Access),
                  ME_Event_Handler_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Properties,
                  "activate",
                  Button_Cb.To_Marshaller (Properties_Minput'Access),
                  ME_Event_Handler_Ref (Item));
            end if;
         end if;
      end if;
   exception
      when Storage_Error =>
         null;
   end On_Button_Click;

   ---------------------
   -- On Button Click --
   ---------------------
   procedure On_Button_Click
     (Item  : access ME_Multi_Output_Event_Handler;
      Event : Gdk.Event.Gdk_Event_Button)
   is
      Num_Button                : Guint;
      Event_Type                : Gdk_Event_Type;
      Set_Out_Link, Set_In_Link : Gtk_Menu_Item;
      MOEH_Dialog               : Moeh_Dialog_Access;
      Me_Data                   : Me_Event_Handler_And_Dialog_Ref :=
         new Me_Event_Handler_And_Dialog;
   begin
      if Event /= null then
         Event_Type := Get_Event_Type (Event);
         if Event_Type = Gdk_2button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (1) then

               Gtk_New (MOEH_Dialog);
               Read_Parameters (Item, Gtk_Dialog (MOEH_Dialog));
               Me_Data.It  := ME_Event_Handler_Ref (Item);
               Me_Data.Dia := Gtk_Dialog (MOEH_Dialog);

               Me_Event_Handler_And_Dialog_Cb.Connect
                 (MOEH_Dialog.Ok_Button,
                  "clicked",
                  Me_Event_Handler_And_Dialog_Cb.To_Marshaller
                     (Write_Moutput'Access),
                  Me_Data);

            end if;
         elsif Event_Type = Button_Press then
            Num_Button := Get_Button (Event);
            if Num_Button = Guint (3) then
               Gtk_New (Item_Menu);
               --We add new options to item_menu
               Gtk_New (Set_Out_Link, "Add Output Link...");
               Set_Right_Justify (Set_Out_Link, False);
               Prepend (Item_Menu, Set_Out_Link);
               Show (Set_Out_Link);
               Gtk_New (Set_In_Link, "Set Input Link...");
               Set_Right_Justify (Set_In_Link, False);
               Prepend (Item_Menu, Set_In_Link);
               Show (Set_In_Link);
               -------------------
               Button_Cb.Connect
                 (Set_Out_Link,
                  "activate",
                  Button_Cb.To_Marshaller
                     (Show_Internal_Events_List_Dialog'Access),
                  ME_Event_Handler_Ref (Item));
               Button_Cb.Connect
                 (Set_In_Link,
                  "activate",
                  Button_Cb.To_Marshaller (Show_Events_List_Dialog'Access),
                  ME_Event_Handler_Ref (Item));
               -------------------
               Button_Cb.Connect
                 (Item_Menu.Remove,
                  "activate",
                  Button_Cb.To_Marshaller (Remove_Handler'Access),
                  ME_Event_Handler_Ref (Item));
               Button_Cb.Connect
                 (Item_Menu.Properties,
                  "activate",
                  Button_Cb.To_Marshaller (Properties_Moutput'Access),
                  ME_Event_Handler_Ref (Item));
            end if;
         end if;
      end if;
   exception
      when Storage_Error =>
         null;
   end On_Button_Click;

   -----------
   -- Print --
   -----------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Simple_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Mast_Editor.Event_Handlers.Print
        (File,
         ME_Event_Handler (Item),
         Indentation);
      Put (File, " ");
      Put (File, "Me_Simple_Event_Handler");
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

   -----------
   -- Print --
   -----------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Multi_Input_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Mast_Editor.Event_Handlers.Print
        (File,
         ME_Event_Handler (Item),
         Indentation);
      Put (File, " ");
      Put (File, "Me_Multi_Input_Event_Handler");
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

   -----------
   -- Print --
   -----------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      Item        : in out ME_Multi_Output_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
   begin
      Mast_Editor.Event_Handlers.Print
        (File,
         ME_Event_Handler (Item),
         Indentation);
      Put (File, " ");
      Put (File, "Me_Multi_Output_Event_Handler");
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

end Mast_Editor.Event_Handlers;
