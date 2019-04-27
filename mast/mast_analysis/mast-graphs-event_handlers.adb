-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2008                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors: Michael Gonzalez       mgh@unican.es                     --
--          Jose Javier Gutierrez  gutierjj@unican.es                --
--          Jose Carlos Palencia   palencij@unican.es                --
--          Jose Maria Drake       drakej@unican.es                  --
--          Yago Pereiro                                             --
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

with MAST.IO, List_Exceptions;
package body MAST.Graphs.Event_Handlers is

   use type MAST.Operations.Operation_Ref;
   use type MAST.Scheduling_Servers.Scheduling_Server_Ref;
   use type MAST.Events.Event_Ref;
   use type Link_Lists.Index;
   use type Operations.Lists.Index;
   use type Scheduling_Servers.Lists.Index;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (The_Graph : in out Graph;
      Sched_Servers : Scheduling_Servers.Lists.List;
      Operats       : Operations.Lists.List)
   is
      Iterator : Event_Handler_Lists.Iteration_Object;
      EH_Ref : Event_Handler_Ref;
   begin
      Event_Handler_Lists.Rewind(The_Graph.Event_Handler_List,Iterator);
      for I in 1..Event_Handler_Lists.Size(The_Graph.Event_Handler_List) loop
         Event_Handler_Lists.Get_Next_Item
           (EH_Ref,The_Graph.Event_Handler_List,Iterator);
         Adjust(Regular_Event_Handler'Class(EH_Ref.all),The_Graph);
         if EH_Ref.all in Activity'Class then
            Adjust(Activity'Class(EH_Ref.all),Sched_Servers, Operats);
         end if;
      end loop;
   end Adjust;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (Ev_Hdlr : in out Simple_Event_Handler;
      The_Graph : Graph)
   is
      Lnk_Index : Link_Lists.Index;
      Lnk_Ref : Link_Ref;
   begin
      -- adjust input link
      if Ev_Hdlr.Input_Link/=null then
         Lnk_Index:=Link_Lists.Find
           (Name(Ev_Hdlr.Input_Link),The_Graph.External_Links_List);
         if Lnk_Index/=Link_Lists.Null_Index then
            Lnk_Ref:=Link_Lists.Item(Lnk_Index,The_Graph.External_Links_List);
         else
            Lnk_Index:=Link_Lists.Find
              (Name(Ev_Hdlr.Input_Link),The_Graph.Internal_Links_List);
            if Lnk_Index/=Link_Lists.Null_Index then
               Lnk_Ref:=Link_Lists.Item
                 (Lnk_Index,The_Graph.Internal_Links_List);
               Ev_Hdlr.Input_Link:=Lnk_Ref;
            else
               Set_Exception_Message
                 ("Simple_Event_Handler reference to Input_Event "&
                  Var_Strings.To_String(Name(Ev_Hdlr.Input_Link))&
                  " not found");
               raise Object_Not_Found;
            end if;
         end if;
         -- adjust the reference to the event handler in the link
         Lnk_Ref.Output_Event_Handler:=Ev_Hdlr'Unchecked_Access;
      end if;

      -- adjust output link
      if Ev_Hdlr.Output_Link/=null then
         Lnk_Index:=Link_Lists.Find
           (Name(Ev_Hdlr.Output_Link),The_Graph.External_Links_List);
         if Lnk_Index/=Link_Lists.Null_Index then
            Lnk_Ref:=Link_Lists.Item(Lnk_Index,The_Graph.External_Links_List);
         else
            Lnk_Index:=Link_Lists.Find
              (Name(Ev_Hdlr.Output_Link),The_Graph.Internal_Links_List);
            if Lnk_Index/=Link_Lists.Null_Index then
               Lnk_Ref:=Link_Lists.Item
                 (Lnk_Index,The_Graph.Internal_Links_List);
               Ev_Hdlr.Output_Link:=Lnk_Ref;
            else
               Set_Exception_Message
                 ("Simple_Event_Handler reference to Output_Event "&
                  Var_Strings.To_String(Name(Ev_Hdlr.Output_Link))&
                  " not found");
               raise Object_Not_Found;
            end if;
         end if;
         -- adjust the reference to the event handler in the link
         Lnk_Ref.Input_Event_Handler:=Ev_Hdlr'Unchecked_Access;
      end if;
   end Adjust;


   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (Ev_Hdlr : in out Input_Event_Handler;
      The_Graph : Graph)
   is
      Iterator : Link_Lists.Iteration_Object;
      Lnk_Index : Link_Lists.Index;
      Lnk_Ref, Orig_Lnk_Ref : Link_Ref;
   begin
      -- adjust input links
      Link_Lists.Rewind(Ev_Hdlr.Input_Links,Iterator);
      for I in 1..Link_Lists.Size(Ev_Hdlr.Input_Links) loop
         Orig_Lnk_Ref:=Link_Lists.Item(Iterator,Ev_Hdlr.Input_Links);
         Lnk_Index:=Link_Lists.Find
           (Name(Orig_Lnk_Ref),The_Graph.External_Links_List);
         if Lnk_Index/=Link_Lists.Null_Index then
            Lnk_Ref:=Link_Lists.Item(Lnk_Index,The_Graph.External_Links_List);
         else
            Lnk_Index:=Link_Lists.Find
              (Name(Orig_Lnk_Ref),The_Graph.Internal_Links_List);
            if Lnk_Index/=Link_Lists.Null_Index then
               Lnk_Ref:=Link_Lists.Item
                 (Lnk_Index,The_Graph.Internal_Links_List);
            else
               Set_Exception_Message
                 ("Multi_Input_Event_Handler reference to Input_Event "&
                  Var_Strings.To_String(Name(Orig_Lnk_Ref))&" not found");
               raise Object_Not_Found;
            end if;
         end if;
         Link_Lists.Update(Iterator,Lnk_Ref,Ev_Hdlr.Input_Links);

         -- adjust the reference to the event handler in the link
         Lnk_Ref.Output_Event_Handler:=Ev_Hdlr'Unchecked_Access;

         --advance to the next item
         Link_Lists.Get_Next_Item(Orig_Lnk_Ref,Ev_Hdlr.Input_Links,Iterator);
      end loop;

      -- adjust output link
      if  Ev_Hdlr.Output_Link/=null then
         Lnk_Index:=Link_Lists.Find
           (Name(Ev_Hdlr.Output_Link),The_Graph.External_Links_List);
         if Lnk_Index/=Link_Lists.Null_Index then
            Lnk_Ref:=Link_Lists.Item(Lnk_Index,The_Graph.External_Links_List);
         else
            Lnk_Index:=Link_Lists.Find
              (Name(Ev_Hdlr.Output_Link),The_Graph.Internal_Links_List);
            if Lnk_Index/=Link_Lists.Null_Index then
               Lnk_Ref:=Link_Lists.Item
                 (Lnk_Index,The_Graph.Internal_Links_List);
            else
               Set_Exception_Message
                 ("Multi_Input_Event_Handler reference to Output_Event "&
                  Var_Strings.To_String(Name(Ev_Hdlr.Output_Link))&
                  " not found");
               raise Object_Not_Found;
            end if;
         end if;
         Ev_Hdlr.Output_Link:=Lnk_Ref;
         -- adjust the reference to the event handler in the link
         Lnk_Ref.Input_Event_Handler:=Ev_Hdlr'Unchecked_Access;
      end if;
   end Adjust;


   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (Ev_Hdlr : in out Output_Event_Handler;
      The_Graph : Graph)
   is
      Iterator : Link_Lists.Iteration_Object;
      Lnk_Index : Link_Lists.Index;
      Lnk_Ref, Orig_Lnk_Ref : Link_Ref;
   begin
      -- adjust input link
      if Ev_Hdlr.Input_Link/=null then
         Lnk_Index:=Link_Lists.Find
           (Name(Ev_Hdlr.Input_Link),The_Graph.External_Links_List);
         if Lnk_Index/=Link_Lists.Null_Index then
            Lnk_Ref:=Link_Lists.Item(Lnk_Index,The_Graph.External_Links_List);
         else
            Lnk_Index:=Link_Lists.Find
              (Name(Ev_Hdlr.Input_Link),The_Graph.Internal_Links_List);
            if Lnk_Index/=Link_Lists.Null_Index then
               Lnk_Ref:=Link_Lists.Item
                 (Lnk_Index,The_Graph.Internal_Links_List);
            else
               Set_Exception_Message
                 ("Multi_Output_Event_Handler reference to Input_Event "&
                  Var_Strings.To_String(Name(Ev_Hdlr.Input_Link))&
                  " not found");
               raise Object_Not_Found;
            end if;
         end if;
         Ev_Hdlr.Input_Link:=Lnk_Ref;
         -- adjust the reference to the event handler in the link
         Lnk_Ref.Output_Event_Handler:=Ev_Hdlr'Unchecked_Access;
      end if;

      -- adjust output links
      Link_Lists.Rewind(Ev_Hdlr.Output_Links,Iterator);
      for I in 1..Link_Lists.Size(Ev_Hdlr.Output_Links) loop
         Orig_Lnk_Ref:=Link_Lists.Item(Iterator,Ev_Hdlr.Output_Links);
         Lnk_Index:=Link_Lists.Find
           (Name(Orig_Lnk_Ref),The_Graph.External_Links_List);
         if Lnk_Index/=Link_Lists.Null_Index then
            Lnk_Ref:=Link_Lists.Item(Lnk_Index,The_Graph.External_Links_List);
         else
            Lnk_Index:=Link_Lists.Find
              (Name(Orig_Lnk_Ref),The_Graph.Internal_Links_List);
            if Lnk_Index/=Link_Lists.Null_Index then
               Lnk_Ref:=Link_Lists.Item
                 (Lnk_Index,The_Graph.Internal_Links_List);
            else
               Set_Exception_Message
                 ("Multi_Output_Event_Handler reference to Output_Event "&
                  Var_Strings.To_String(Name(Orig_Lnk_Ref))&" not found");
               raise Object_Not_Found;
            end if;
         end if;
         Link_Lists.Update(Iterator,Lnk_Ref,Ev_Hdlr.Output_Links);

         -- adjust the reference to the event handler in the link
         Lnk_Ref.Input_Event_Handler:=Ev_Hdlr'Unchecked_Access;

         --advance to the next item
         Link_Lists.Get_Next_Item(Orig_Lnk_Ref,Ev_Hdlr.Output_Links,Iterator);
      end loop;

   end Adjust;


   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (Ev_Hdlr : in out Offset_Event_Handler;
      The_Graph : Graph)
   is
      The_Index : Link_Lists.Index;
   begin
      Adjust(Simple_Event_Handler(Ev_Hdlr),The_Graph);

      -- adjust the referenced event
      if Ev_Hdlr.Referenced_Event/=null then
         The_Index:=Link_Lists.Find
           (Events.Name(Ev_Hdlr.Referenced_Event),
            The_Graph.External_Links_List);
         if The_Index/=Link_Lists.Null_Index then
            Ev_Hdlr.Referenced_Event:=Link_Lists.Item
              (The_Index,The_Graph.External_Links_List).Event;
         else
            The_Index:=Link_Lists.Find
              (Events.Name(Ev_Hdlr.Referenced_Event),
               The_Graph.Internal_Links_List);
            if The_Index/=Link_Lists.Null_Index then
               Ev_Hdlr.Referenced_Event:=Link_Lists.Item
                 (The_Index,The_Graph.Internal_Links_List).Event;
            else
               Set_Exception_Message
                 ("Offset_Event_Handler reference to Referenced_Event "&
                  Var_Strings.To_String(Events.Name(Ev_Hdlr.Referenced_Event))&
                  " not found");
               raise Object_Not_Found;
            end if;
         end if;
      end if;
   end Adjust;


   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (Ev_Hdlr : in out Activity;
      Sched_Servers : Scheduling_Servers.Lists.List;
      Operats       : Operations.Lists.List)
   is
      Srv_Index : Scheduling_Servers.Lists.Index;
      Op_Index : Operations.Lists.Index;
   begin
      Scheduling_Servers.Adjust_Ref(Ev_Hdlr.Activity_Server,Sched_Servers);
      Operations.Adjust_Ref(Ev_Hdlr.Activity_Operation,Operats);
   exception
      when Object_Not_Found =>
         Set_Exception_Message(" in Activity "&Get_Exception_Message);
         raise;
   end Adjust;

   ----------------------
   -- Clone --
   ----------------------

   function Clone
     (The_List : Link_Lists.List)
     return Link_Lists.List
   is
      The_Copy : Link_Lists.List;
      Iterator : Link_Lists.Iteration_Object;
      Lnk_Ref  : Link_Ref;
   begin
      Link_Lists.Rewind(The_List,Iterator);
      for I in 1..Link_Lists.Size(The_List) loop
         Link_Lists.Get_Next_Item(Lnk_Ref,The_List,Iterator);
         Link_Lists.Add(Lnk_Ref,The_Copy);
      end loop;
      return The_Copy;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Ev_Hdlr : Activity)
     return Event_Handler_Ref
   is
      Ev_Ref : Event_Handler_Ref;
   begin
      Ev_Ref:=new Activity'(Ev_Hdlr);
      return Ev_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Ev_Hdlr : System_Timed_Activity)
     return Event_Handler_Ref
   is
      Ev_Ref : Event_Handler_Ref;
   begin
      Ev_Ref:=new System_Timed_Activity'(Ev_Hdlr);
      return Ev_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Ev_Hdlr : Concentrator)
     return Event_Handler_Ref
   is
      Ev_Ref : Event_Handler_Ref;
   begin
      Ev_Ref:=new Concentrator'(Ev_Hdlr);
      Concentrator(Ev_Ref.all).Input_Links:=Clone(Ev_Hdlr.Input_Links);
      return Ev_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Ev_Hdlr : Barrier)
     return Event_Handler_Ref
   is
      Ev_Ref : Event_Handler_Ref;
   begin
      Ev_Ref:=new Barrier'(Ev_Hdlr);
      Barrier(Ev_Ref.all).Input_Links:=Clone(Ev_Hdlr.Input_Links);
      return Ev_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Ev_Hdlr : Delivery_Server)
     return Event_Handler_Ref
   is
      Ev_Ref : Event_Handler_Ref;
   begin
      Ev_Ref:=new Delivery_Server'(Ev_Hdlr);
      Delivery_Server(Ev_Ref.all).Output_Links:=Clone(Ev_Hdlr.Output_Links);
      return Ev_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Ev_Hdlr : Query_Server)
     return Event_Handler_Ref
   is
      Ev_Ref : Event_Handler_Ref;
   begin
      Ev_Ref:=new Query_Server'(Ev_Hdlr);
      Query_Server(Ev_Ref.all).Output_Links:=Clone(Ev_Hdlr.Output_Links);
      return Ev_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Ev_Hdlr : Multicast)
     return Event_Handler_Ref
   is
      Ev_Ref : Event_Handler_Ref;
   begin
      Ev_Ref:=new Multicast'(Ev_Hdlr);
      Multicast(Ev_Ref.all).Output_Links:=Clone(Ev_Hdlr.Output_Links);
      return Ev_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Ev_Hdlr : Rate_Divisor)
     return Event_Handler_Ref
   is
      Ev_Ref : Event_Handler_Ref;
   begin
      Ev_Ref:=new Rate_Divisor'(Ev_Hdlr);
      return Ev_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Ev_Hdlr : Delay_Event_Handler)
     return Event_Handler_Ref
   is
      Ev_Ref : Event_Handler_Ref;
   begin
      Ev_Ref:=new Delay_Event_Handler'(Ev_Hdlr);
      return Ev_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Ev_Hdlr : Offset_Event_Handler)
     return Event_Handler_Ref
   is
      Ev_Ref : Event_Handler_Ref;
   begin
      Ev_Ref:=new Offset_Event_Handler'(Ev_Hdlr);
      return Ev_Ref;
   end Clone;

   -----------------------
   -- Set_Activity_Server --
   -----------------------

   procedure Set_Activity_Server
     (The_Event_Handler : in out Activity;
      The_Activity_Server : Scheduling_Servers.Scheduling_Server_Ref)
   is
   begin
      The_Event_Handler.Activity_Server:=The_Activity_Server;
   end Set_Activity_Server;

   -------------------
   -- Activity_Server --
   -------------------

   function Activity_Server
     (The_Event_Handler : Activity)
     return Scheduling_Servers.Scheduling_Server_Ref
   is
   begin
      return The_Event_Handler.Activity_Server;
   end Activity_Server;

   -------------------
   -- Add_Input_Link --
   -------------------

   procedure Add_Input_Link
     (The_Event_Handler : in out Input_Event_Handler;
      The_Link : Link_Ref)
   is
   begin
      Link_Lists.Add(The_Link,The_Event_Handler.Input_Links);
   end Add_Input_Link;

   --------------------
   -- Add_Output_Link --
   --------------------

   procedure Add_Output_Link
     (The_Event_Handler : in out Output_Event_Handler;
      The_Link : Link_Ref)
   is
   begin
      Link_Lists.Add(The_Link,The_Event_Handler.Output_Links);
   end Add_Output_Link;

   ------------------------
   -- Delay_Max_Interval --
   ------------------------

   function Delay_Max_Interval
     (The_Event_Handler : Delay_Event_Handler)
     return Time
   is
   begin
      return The_Event_Handler.Delay_Max_Interval;
   end Delay_Max_Interval;

   ------------------------
   -- Delay_Min_Interval --
   ------------------------

   function Delay_Min_Interval
     (The_Event_Handler : Delay_Event_Handler)
     return Time
   is
   begin
      return The_Event_Handler.Delay_Min_Interval;
   end Delay_Min_Interval;

   --------------------
   -- Referenced_Event --
   --------------------

   function Referenced_Event
     (The_Event_Handler : Offset_Event_Handler)
     return MAST.Events.Event_Ref
   is
   begin
      return The_Event_Handler.Referenced_Event;
   end Referenced_Event;

   ------------------------
   -- Get_Next_Input_Link --
   ------------------------

   procedure Get_Next_Input_Link
     (The_Event_Handler : in Input_Event_Handler;
      The_Link : out Link_Ref;
      Iterator : in out Iteration_Object)
   is
   begin
      Link_Lists.Get_Next_Item
        (The_Link,The_Event_Handler.Input_Links,
         Link_Lists.Index(Iterator));
   end Get_Next_Input_Link;

   -------------------------
   -- Get_Next_Output_Link --
   -------------------------

   procedure Get_Next_Output_Link
     (The_Event_Handler : in Output_Event_Handler;
      The_Link : out Link_Ref;
      Iterator : in out Iteration_Object)
   is
   begin
      Link_Lists.Get_Next_Item
        (The_Link,The_Event_Handler.Output_Links,
         Link_Lists.Index(Iterator));
   end Get_Next_Output_Link;

   ---------------
   -- Input_Link --
   ---------------

   function Input_Link
     (The_Event_Handler : Simple_Event_Handler)
     return Link_Ref
   is
   begin
      return The_Event_Handler.Input_Link;
   end Input_Link;

   ---------------
   -- Input_Link --
   ---------------

   function Input_Link
     (The_Event_Handler : Output_Event_Handler)
     return Link_Ref
   is
   begin
      return The_Event_Handler.Input_Link;
   end Input_Link;

   -----------------
   -- Activity_Operation --
   -----------------

   function Activity_Operation
     (The_Event_Handler : Activity)
     return MAST.Operations.Operation_Ref
   is
   begin
      return The_Event_Handler.Activity_Operation;
   end Activity_Operation;

   -----------------------
   -- Num_Of_Input_Links --
   -----------------------

   function Num_Of_Input_Links
     (The_Event_Handler : Input_Event_Handler)
     return Natural
   is
   begin
      return Link_Lists.Size(The_Event_Handler.Input_Links);
   end Num_Of_Input_Links;

   ------------------------
   -- Num_Of_Output_Links --
   ------------------------

   function Num_Of_Output_Links
     (The_Event_Handler : Output_Event_Handler)
     return Natural
   is
   begin
      return Link_Lists.Size(The_Event_Handler.Output_Links);
   end Num_Of_Output_Links;

   ----------------
   -- Output_Link --
   ----------------

   function Output_Link
     (The_Event_Handler : Simple_Event_Handler)
     return Link_Ref
   is
   begin
      return The_Event_Handler.Output_Link;
   end Output_Link;

   ----------------
   -- Output_Link --
   ----------------

   function Output_Link
     (The_Event_Handler : Input_Event_Handler)
     return Link_Ref
   is
   begin
      return The_Event_Handler.Output_Link;
   end Output_Link;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Simple_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 19;
   begin
      if Res.Input_Link/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Input_Event",
            IO.Name_Image(MAST.Graphs.Name(Res.Input_Link)),
            Indentation+1,Names_Length-1);
      end if;
      if Res.Output_Link/= null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Output_Event",
            IO.Name_Image(MAST.Graphs.Name(Res.Output_Link)),
            Indentation+1,Names_Length-1);
      end if;
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Activity;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 19;
   begin
      MAST.IO.Print_Arg(File,"(Type","Activity",
                        Indentation,Names_Length);
      Print(File,Simple_Event_Handler(Res),Indentation);
      if Res.Activity_Operation /= null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Activity_Operation",
            IO.Name_Image(MAST.Operations.Name
                          (Res.Activity_Operation)),
            Indentation+1,Names_Length-1);
      end if;
      if Res.Activity_Server /= null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Activity_Server",
            IO.Name_Image(MAST.Scheduling_Servers.Name
                          (Res.Activity_Server)),
            Indentation+1,Names_Length-1);
      end if;
      Ada.Text_IO.Put(File,")");
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out System_Timed_Activity;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 19;
   begin
      MAST.IO.Print_Arg(File,"(Type","System_Timed_Activity",
                        Indentation,Names_Length);
      Print(File,Simple_Event_Handler(Res),Indentation);
      if Res.Activity_Operation /= null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Activity_Operation",
            IO.Name_Image(MAST.Operations.Name
                          (Res.Activity_Operation)),
            Indentation+1,Names_Length-1);
      end if;
      if Res.Activity_Server /= null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Activity_Server",
            IO.Name_Image(MAST.Scheduling_Servers.Name
                          (Res.Activity_Server)),
            Indentation+1,Names_Length-1);
      end if;
      Ada.Text_IO.Put(File,")");
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Input_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 17;
      Res_Ref : Link_Ref;
      Iterator : Link_Lists.Index;
   begin
      if Res.Output_Link/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Output_Event",
            IO.Name_Image(MAST.Graphs.Name(Res.Output_Link)),
            Indentation+1,Names_Length-1);
      end if;
      if Link_Lists.Size(Res.Input_Links)>0 then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg(File,"Input_Events_List","",
                           Indentation+1,Names_Length-1);
         Link_Lists.Rewind(Res.Input_Links,Iterator);
         for I in 1..Link_Lists.Size(Res.Input_Links) loop
            if I = 1 then
               MAST.IO.Print_Separator(File,MAST.IO.Nothing);
               MAST.IO.Print_List_Item
                 (File,MAST.IO.Left_Paren,Indentation+4);
            end if;
            Link_Lists.Get_Next_Item(Res_Ref,Res.Input_Links,Iterator);
            MAST.IO.Print_List_Item
              (File, IO.Name_Image
               (MAST.Graphs.Name(Res_Ref)),Indentation+6);
            if I = Link_Lists.Size(Res.Input_Links) then
               Ada.Text_IO.Put(File,")");
            else
               MAST.IO.Print_Separator(File);
            end if;
         end loop;
      end if;
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Concentrator;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 17;
   begin
      MAST.IO.Print_Arg(File,"(Type","Concentrator",
                        Indentation,Names_Length);
      Print(File,Input_Event_Handler(Res),Indentation);
      Ada.Text_IO.Put(File,")");
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Barrier;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 17;
   begin
      MAST.IO.Print_Arg(File,"(Type","Barrier",
                        Indentation,Names_Length);
      Print(File,Input_Event_Handler(Res),Indentation);
      Ada.Text_IO.Put(File,")");
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Output_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 18;
      Res_Ref : Link_Ref;
      Iterator : Link_Lists.Index;
   begin
      if Res.Input_Link/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Input_Event",
            IO.Name_Image(MAST.Graphs.Name(Res.Input_Link)),
            Indentation+1,Names_Length-1);
      end if;
      if Link_Lists.Size(Res.Output_Links)>0 then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg(File,"Output_Events_List","",
                           Indentation+1,Names_Length-1);
         Link_Lists.Rewind(Res.Output_Links,Iterator);
         for I in 1..Link_Lists.Size(Res.Output_Links) loop
            if I = 1 then
               MAST.IO.Print_Separator(File,MAST.IO.Nothing);
               MAST.IO.Print_List_Item
                 (File,MAST.IO.Left_Paren,Indentation+4);
            end if;
            Link_Lists.Get_Next_Item(Res_Ref,Res.Output_Links,Iterator);
            MAST.IO.Print_List_Item
              (File,IO.Name_Image
               (MAST.Graphs.Name(Res_Ref)),Indentation+6);
            if I = Link_Lists.Size(Res.Output_Links) then
               Ada.Text_IO.Put(File,")");
            else
               MAST.IO.Print_Separator(File);
            end if;
         end loop;
      end if;
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Delivery_Server;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 18;
   begin
      MAST.IO.Print_Arg(File,"(Type","Delivery_Server",
                        Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg(File,"Delivery_Policy",
                        Delivery_Policy'Image(Res.Policy),
                        Indentation+1,Names_Length-1);
      Print(File,Output_Event_Handler(Res),Indentation);
      Ada.Text_IO.Put(File,")");
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Query_Server;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 18;
   begin
      MAST.IO.Print_Arg(File,"(Type","Query_Server",
                        Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg(File,"Request_Policy",
                        Request_Policy'Image(Res.Policy),
                        Indentation+1,Names_Length-1);
      Print(File,Output_Event_Handler(Res),Indentation);
      Ada.Text_IO.Put(File,")");
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Multicast;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 18;
   begin
      MAST.IO.Print_Arg(File,"(Type","Multicast",
                        Indentation,Names_Length);
      Print(File,Output_Event_Handler(Res),Indentation);
      Ada.Text_IO.Put(File,")");
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Rate_Divisor;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 19;
   begin
      MAST.IO.Print_Arg(File,"(Type","Rate_Divisor",
                        Indentation,Names_Length);
      Print(File,Simple_Event_Handler(Res),Indentation);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg(File,"Rate_Factor",
                        Positive'Image(Res.Rate_Factor),
                        Indentation+1,Names_Length-1);
      Ada.Text_IO.Put(File,")");
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Delay_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 19;
   begin
      MAST.IO.Print_Arg(File,"(Type","Delay",
                        Indentation,Names_Length);
      Print(File,Simple_Event_Handler(Res),Indentation);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg(File,"Delay_Max_Interval",
                        IO.Time_Image(Res.Delay_Max_Interval),
                        Indentation+1,Names_Length-1);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg(File,"Delay_Min_Interval",
                        IO.Time_Image(Res.Delay_Min_Interval),
                        Indentation+1,Names_Length-1);
      Ada.Text_IO.Put(File,")");
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Offset_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 19;
   begin
      MAST.IO.Print_Arg(File,"(Type","Offset",
                        Indentation,Names_Length);
      Print(File,Simple_Event_Handler(Res),Indentation);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg(File,"Delay_Max_Interval",
                        IO.Time_Image(Res.Delay_Max_Interval),
                        Indentation+1,Names_Length-1);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg(File,"Delay_Min_Interval",
                        IO.Time_Image(Res.Delay_Min_Interval),
                        Indentation+1,Names_Length-1);
      if Res.Referenced_Event/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Referenced_Event",
            IO.Name_Image(MAST.Events.Name
                          (Res.Referenced_Event)),
            Indentation+1,Names_Length-1);
      end if;
      Ada.Text_IO.Put(File,")");
   end Print;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File        : Ada.Text_Io.File_Type;
      Res         : in out Simple_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:= False )
   is
      Names_Length : constant Positive := 19;
   begin
      if Res.Input_Link/=null then
         Ada.Text_Io.Put
           (File," Input_Event=""" &
            Io.Name_Image(Mast.Graphs.Name(Res.Input_Link)) & """");
      end if;
      if Res.Output_Link/= null then
         Ada.Text_Io.Put
           (File," Output_Event=""" &
            Io.Name_Image(Mast.Graphs.Name(Res.Output_Link)) & """");
      end if;
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File        : Ada.Text_Io.File_Type;
      Res         : in out Activity;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
      Names_Length : constant Positive := 19;
   begin

      Ada.Text_Io.Set_Col(File,Ada.Text_Io.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:Activity ");
      Print_XML(File,Simple_Event_Handler(Res),Indentation,False);
      if Res.Activity_Operation /= null then
         Ada.Text_Io.Put
           (File," Activity_Operation= """ &
            Io.Name_Image(Mast.Operations.Name(Res.Activity_Operation)) &
            """");
      end if;
      if Res.Activity_Server /= null then
         Ada.Text_Io.Put
           (File," Activity_Server= """ &
            Io.Name_Image(Mast.Scheduling_Servers.Name (Res.Activity_Server)) &
            """");
      end if;
      Ada.Text_Io.Put_Line(File,"/>");
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File        : Ada.Text_Io.File_Type;
      Res         : in out System_Timed_Activity;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
      Names_Length : constant Positive := 19;
   begin
      Ada.Text_Io.Set_Col(File,Ada.Text_Io.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:System_Timed_Activity ");
      Print_XML(File,Simple_Event_Handler(Res),Indentation,False);
      if Res.Activity_Operation /= null then
         Ada.Text_Io.Put
           (File," Activity_Operation=""" &
            Io.Name_Image(Mast.Operations.Name(Res.Activity_Operation)) &
            """");
      end if;
      if Res.Activity_Server /= null then
         Ada.Text_Io.Put
           (File," Activity_Server=""" &
            Io.Name_Image(Mast.Scheduling_Servers.Name(Res.Activity_Server)) &
            """");
      end if;
      Ada.Text_Io.Put_Line(File,"/>");
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File        : Ada.Text_Io.File_Type;
      Res         : in out Input_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
      Names_Length : constant Positive := 17;
      Res_Ref      :          Link_Ref;
      Iterator     :          Link_Lists.Index;
   begin

      if Res.Output_Link/=null then
         Ada.Text_Io.Put
           (File," Output_Event=""" &
            Io.Name_Image(Mast.Graphs.Name(Res.Output_Link)) & """");
      end if;
      if Link_Lists.Size(Res.Input_Links)>0 then
         Ada.Text_Io.Put(File," Input_Events_List=""");
         Link_Lists.Rewind(Res.Input_Links,Iterator);
         for I in 1..Link_Lists.Size(Res.Input_Links) loop
            Link_Lists.Get_Next_Item(Res_Ref,Res.Input_Links,Iterator);
            Ada.Text_Io.Put
              (File,Io.Name_Image(Mast.Graphs.Name(Res_Ref)));
            if I/=Link_Lists.Size(Res.Input_Links) then
               Ada.Text_Io.Put(File," ");
            end if;
         end loop;
         Ada.Text_Io.Put(File,"""");
      end if;
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File        : Ada.Text_Io.File_Type;
      Res         : in out Concentrator;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
      Names_Length : constant Positive := 17;
   begin
      Ada.Text_Io.Set_Col(File,Ada.Text_Io.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:Concentrator ");
      Print_XML(File,Input_Event_Handler(Res),Indentation,False);
      Ada.Text_Io.Put_Line(File," />");
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File        : Ada.Text_Io.File_Type;
      Res         : in out Barrier;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
      Names_Length : constant Positive := 17;
   begin
      Ada.Text_Io.Set_Col(File,Ada.Text_Io.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:Barrier ");
      Print_XML(File,Input_Event_Handler(Res),Indentation,False);
      Ada.Text_Io.Put_Line(File," />");
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File        : Ada.Text_Io.File_Type;
      Res         : in out Output_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean := False  )
   is
      Names_Length : constant Positive := 18;
      Res_Ref      : Link_Ref;
      Iterator     : Link_Lists.Index;
   begin

      if Res.Input_Link/=null then
         Ada.Text_Io.Put
           (File," Input_Event=""" &
            Io.Name_Image(Mast.Graphs.Name(Res.Input_Link)) & """");
      end if;
      if Link_Lists.Size(Res.Output_Links)>0 then
         Ada.Text_Io.Put(File," Output_Events_List=""");
         Link_Lists.Rewind(Res.Output_Links,Iterator);
         for I in 1..Link_Lists.Size(Res.Output_Links) loop
            Link_Lists.Get_Next_Item(Res_Ref,Res.Output_Links,Iterator);
            Ada.Text_Io.Put
              (File,Io.Name_Image(Mast.Graphs.Name(Res_Ref)));
            if I/=Link_Lists.Size(Res.Output_Links) then
               Ada.Text_Io.Put(File," ");
            end if;
         end loop;
         Ada.Text_Io.Put(File,"""");
      end if;
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File        : Ada.Text_Io.File_Type;
      Res         : in out Delivery_Server;
      Indentation : Positive;
      Finalize    : Boolean := False  )
   is
      Names_Length : constant Positive := 18;
   begin
      Ada.Text_Io.Set_Col(File,Ada.Text_Io.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:Delivery_Server ");
      Print_XML(File,Output_Event_Handler(Res),Indentation,False);
      Ada.Text_Io.Put
        (File," Delivery_Policy=""" &
         IO.XML_Enum_Image(Delivery_Policy'Image(Res.Policy)) & """");
      Ada.Text_Io.Put_Line(File," />");
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File        : Ada.Text_Io.File_Type;
      Res         : in out Query_Server;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
      Names_Length : constant Positive := 18;
   begin
      Ada.Text_Io.Set_Col(File,Ada.Text_Io.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:Query_Server ");
      Print_XML(File,Output_Event_Handler(Res),Indentation,False);
      Ada.Text_Io.Put
        (File," Request_Policy=""" &
         IO.XML_Enum_Image(Request_Policy'Image(Res.Policy)) & """");
      Ada.Text_Io.Put_Line(File," />");
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File        : Ada.Text_Io.File_Type;
      Res         : in out Multicast;
      Indentation : Positive;
      Finalize    : Boolean := False )
   is
      Names_Length : constant Positive := 18;
   begin
      Ada.Text_Io.Set_Col(File,Ada.Text_Io.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:Multicast ");
      Print_XML(File,Output_Event_Handler(Res),Indentation,False);
      Ada.Text_Io.Put_Line(File," />");
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File        : Ada.Text_Io.File_Type;
      Res         : in out Rate_Divisor;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
      Names_Length : constant Positive := 19;
   begin
      Ada.Text_Io.Set_Col(File,Ada.Text_Io.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:Rate_Divisor ");
      Print_XML(File,Simple_Event_Handler(Res),Indentation,False);
      Ada.Text_Io.Put
        (File," Rate_Factor=""" & IO.Integer_Image(Res.Rate_Factor) & """");
      Ada.Text_Io.Put_Line(File," />");
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File        : Ada.Text_Io.File_Type;
      Res         : in out Delay_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean := False)
   is
      Names_Length : constant Positive := 19;
   begin
      Ada.Text_Io.Set_Col(File,Ada.Text_Io.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:Delay ");
      Print_XML(File,Simple_Event_Handler(Res),Indentation,False);
      Ada.Text_Io.Put
        (File," Delay_Max_Interval=""" &
         Io.Time_Image(Res.Delay_Max_Interval) & """");
      Ada.Text_Io.Put
        (File," Delay_Min_Interval=""" &
         Io.Time_Image(Res.Delay_Min_Interval) & """");
      Ada.Text_Io.Put_Line(File," />");
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File        : Ada.Text_Io.File_Type;
      Res         : in out Offset_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean := False )
   is
      Names_Length : constant Positive := 19;
   begin
      Ada.Text_Io.Set_Col(File,Ada.Text_Io.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:Offset ");
      Print_XML
        (File,Simple_Event_Handler(Res),Indentation,False);
      Ada.Text_Io.Put
        (File," Delay_Max_Interval=""" &
         Io.Time_Image(Res.Delay_Max_Interval) & """");
      Ada.Text_Io.Put
        (File," Delay_Min_Interval=""" &
         Io.Time_Image(Res.Delay_Min_Interval) & """");
      if Res.Referenced_Event/=null then
         Ada.Text_Io.Put
           (File," Referenced_Event=""" &
            Io.Name_Image(Mast.Events.Name(Res.Referenced_Event)) & """");
      end if;
      Ada.Text_Io.Put_Line(File," />");
   end Print_XML;

   -----------------
   -- Rate_Factor --
   -----------------

   function Rate_Factor
     (The_Event_Handler : Rate_Divisor)
     return Positive
   is
   begin
      return The_Event_Handler.Rate_Factor;
   end Rate_Factor;

   -----------------------
   -- Remove_Input_Link --
   -----------------------

   procedure Remove_Input_Link
     (The_Event_Handler : in out Input_Event_Handler;
      The_Link : Link_Ref)
   is
      Ind : Link_Lists.Index;
      Ln_Ref : Link_Ref;
   begin
      Ind:=Link_Lists.Find(Name(The_Link),The_Event_Handler.Input_Links);
      if Ind=Link_Lists.Null_Index then
         raise List_Exceptions.Not_Found;
      end if;
      Link_Lists.Delete(Ind,Ln_Ref,The_Event_Handler.Input_Links);
   end Remove_Input_Link;

   ------------------------
   -- Remove_Output_Link --
   ------------------------

   procedure Remove_Output_Link
     (The_Event_Handler : in out Output_Event_Handler;
      The_Link : Link_Ref)
   is
      Ind : Link_Lists.Index;
      Ln_Ref : Link_Ref;
   begin
      Ind:=Link_Lists.Find(Name(The_Link),The_Event_Handler.Output_Links);
      if Ind=Link_Lists.Null_Index then
         raise List_Exceptions.Not_Found;
      end if;
      Link_Lists.Delete(Ind,Ln_Ref,The_Event_Handler.Output_Links);
   end Remove_Output_Link;

   -----------------------
   -- Rewind_Input_Links --
   -----------------------

   procedure Rewind_Input_Links
     (The_Event_Handler : in Input_Event_Handler;
      Iterator : out Iteration_Object)
   is
   begin
      Link_Lists.Rewind
        (The_Event_Handler.Input_Links,Link_Lists.Index(Iterator));
   end Rewind_Input_Links;

   ------------------------
   -- Rewind_Output_Links --
   ------------------------

   procedure Rewind_Output_Links
     (The_Event_Handler : in Output_Event_Handler;
      Iterator : out Iteration_Object)
   is
   begin
      Link_Lists.Rewind
        (The_Event_Handler.Output_Links,Link_Lists.Index(Iterator));
   end Rewind_Output_Links;

   ----------------------------
   -- Set_Delay_Max_Interval --
   ----------------------------

   procedure Set_Delay_Max_Interval
     (The_Event_Handler : in out Delay_Event_Handler;
      The_Delay_Max_Interval : Time)
   is
   begin
      The_Event_Handler.Delay_Max_Interval:=The_Delay_Max_Interval;
   end Set_Delay_Max_Interval;

   ----------------------------
   -- Set_Delay_Min_Interval --
   ----------------------------

   procedure Set_Delay_Min_Interval
     (The_Event_Handler : in out Delay_Event_Handler;
      The_Delay_Min_Interval : Time)
   is
   begin
      The_Event_Handler.Delay_Min_Interval:=The_Delay_Min_Interval;
   end Set_Delay_Min_Interval;

   ------------------------
   -- Set_Referenced_Event --
   ------------------------

   procedure Set_Referenced_Event
     (The_Event_Handler : in out Offset_Event_Handler;
      The_Referenced_Event : MAST.Events.Event_Ref)
   is
   begin
      The_Event_Handler.Referenced_Event:=The_Referenced_Event;
   end Set_Referenced_Event;

   -------------------
   -- Set_Input_Link --
   -------------------

   procedure Set_Input_Link
     (The_Event_Handler : in out Simple_Event_Handler;
      The_Input_Link : Link_Ref)
   is
   begin
      The_Event_Handler.Input_Link:=The_Input_Link;
   end Set_Input_Link;

   -------------------
   -- Set_Input_Link --
   -------------------

   procedure Set_Input_Link
     (The_Event_Handler : in out Output_Event_Handler;
      The_Input_Link : Link_Ref)
   is
   begin
      The_Event_Handler.Input_Link:=The_Input_Link;
   end Set_Input_Link;

   ---------------------
   -- Set_Activity_Operation --
   ---------------------

   procedure Set_Activity_Operation
     (The_Event_Handler : in out Activity;
      The_Activity_Operation : MAST.Operations.Operation_Ref)
   is
   begin
      The_Event_Handler.Activity_Operation:=The_Activity_Operation;
   end Set_Activity_Operation;

   --------------------
   -- Set_Output_Link --
   --------------------

   procedure Set_Output_Link
     (The_Event_Handler : in out Simple_Event_Handler;
      The_Output_Link : Link_Ref)
   is
   begin
      The_Event_Handler.Output_Link:=The_Output_Link;
   end Set_Output_Link;

   --------------------
   -- Set_Output_Link --
   --------------------

   procedure Set_Output_Link
     (The_Event_Handler : in out Input_Event_Handler;
      The_Output_Link : Link_Ref)
   is
   begin
      The_Event_Handler.Output_Link:=The_Output_Link;
   end Set_Output_Link;

   ---------------------
   -- Set_Rate_Factor --
   ---------------------

   procedure Set_Rate_Factor
     (The_Event_Handler : in out Rate_Divisor;
      The_Rate_Factor : Positive)
   is
   begin
      The_Event_Handler.Rate_Factor:=The_Rate_Factor;
   end Set_Rate_Factor;

   ---------------------
   -- Set_Policy --
   ---------------------

   procedure Set_Policy
     (The_Event_Handler : in out Delivery_Server;
      The_Policy : Mast.Delivery_Policy)
   is
   begin
      The_Event_Handler.Policy:=The_Policy;
   end Set_Policy;

   ---------------------
   -- Policy --
   ---------------------

   function Policy
     (The_Event_Handler : Delivery_Server)
     return Mast.Delivery_Policy
   is
   begin
      return The_Event_Handler.Policy;
   end Policy;

   ---------------------
   -- Set_Policy --
   ---------------------

   procedure Set_Policy
     (The_Event_Handler : in out Query_Server;
      The_Policy : Mast.Request_Policy)
   is
   begin
      The_Event_Handler.Policy:=The_Policy;
   end Set_Policy;

   ---------------------
   -- Policy --
   ---------------------

   function Policy
     (The_Event_Handler : Query_Server)
     return Mast.Request_Policy
   is
   begin
      return The_Event_Handler.Policy;
   end Policy;

   ------------------------------
   -- Remove_Link_From_Handler --
   ------------------------------

   procedure Remove_Link_From_Handler
     (Handler : in out Simple_Event_Handler;
      Lnk_Ref: Link_Ref)
   is
   begin
      if Handler.Input_Link=Lnk_Ref then
         Handler.Input_Link:=null;
      end if;
      if Handler.Output_Link=Lnk_Ref then
         Handler.Output_Link:=null;
      end if;
   end Remove_Link_From_Handler;

   ------------------------------
   -- Remove_Link_From_Handler --
   ------------------------------

   procedure Remove_Link_From_Handler
     (Handler : in out Input_Event_Handler;
      Lnk_Ref: Link_Ref)
   is
      Indx : Link_Lists.Index;
      Deleted_Item : Link_Ref;
   begin
      if Handler.Output_Link=Lnk_Ref then
         Handler.Output_Link:=null;
      end if;
      Indx:=Link_Lists.Find(Name(Lnk_Ref),Handler.Input_Links);
      if Indx/=Link_Lists.Null_Index then
         Link_Lists.Delete(Indx,Deleted_Item,Handler.Input_Links);
      end if;
   end Remove_Link_From_Handler;

   ------------------------------
   -- Remove_Link_From_Handler --
   ------------------------------

   procedure Remove_Link_From_Handler
     (Handler : in out Output_Event_Handler;
      Lnk_Ref: Link_Ref)
   is
      Indx : Link_Lists.Index;
      Deleted_Item : Link_Ref;
   begin
      if Handler.Input_Link=Lnk_Ref then
         Handler.Input_Link:=null;
      end if;
      Indx:=Link_Lists.Find(Name(Lnk_Ref),Handler.Output_Links);
      if Indx/=Link_Lists.Null_Index then
         Link_Lists.Delete(Indx,Deleted_Item,Handler.Output_Links);
      end if;
   end Remove_Link_From_Handler;

end MAST.Graphs.Event_Handlers;
