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

with MAST.IO, Mast.Graphs.Links, Mast.Graphs.Event_Handlers,
  Mast.Operations, List_Exceptions;
package body MAST.Transactions is

   use type Graphs.Link_Lists.Index;
   use type Graphs.Event_Handler_Lists.Index;
   use type Results.Slack_Result_Ref;
   use type Operations.Operation_Ref;
   use type Scheduling_Servers.Scheduling_Server_Ref;

   Names_Length : constant Positive := 15;

   -----------------------------
   -- Add_Internal_Event_Link --
   -----------------------------

   procedure Add_Internal_Event_Link
     (Trans : in out Transaction;
      The_Link : MAST.Graphs.Link_Ref)
   is
   begin
      Graphs.Link_Lists.Add
        (The_Link,Trans.Graph.Internal_Links_List);
   end Add_Internal_Event_Link;

   -----------------------
   -- Add_Event_Handler --
   -----------------------

   procedure Add_Event_Handler
     (Trans : in out Transaction;
      The_Event_Handler : MAST.Graphs.Event_Handler_Ref)
   is
   begin
      Graphs.Event_Handler_Lists.Add
        (The_Event_Handler,Trans.Graph.Event_Handler_List);
   end Add_Event_Handler;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (Trans : in out Transaction;
      Sched_Servers : Scheduling_Servers.Lists.List;
      Operats       : Operations.Lists.List)
   is
   begin
      Graphs.Links.Adjust_Timing_Requirements(Trans.Graph);
      Graphs.Event_Handlers.Adjust(Trans.Graph,Sched_Servers,Operats);
   exception
      when Object_Not_Found =>
         Set_Exception_Message
           ("Error in Transaction "&Var_Strings.To_String(Trans.Name)&": "&
            Get_Exception_Message);
         raise;
   end Adjust;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (The_List : in out Lists.List;
      Sched_Servers : Scheduling_Servers.Lists.List;
      Operats       : Operations.Lists.List)
   is
      Iterator : Lists.Iteration_Object;
      Trans_Ref : Transaction_Ref;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Trans_Ref,The_List,Iterator);
         Adjust(Trans_Ref.all,Sched_Servers,Operats);
      end loop;
   end Adjust;

   -----------
   -- Clone --
   -----------

   function Clone
     (The_List : in Lists.List)
     return Lists.List
   is
      The_Copy : Lists.List;
      Iterator : Lists.Iteration_Object;
      Trans_Ref, Trans_Ref_Copy : Transaction_Ref;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Trans_Ref,The_List,Iterator);
         Trans_Ref_Copy:=Clone(Trans_Ref.all);
         Lists.Add(Trans_Ref_Copy,The_Copy);
      end loop;
      return The_Copy;
   end Clone;


   -----------
   -- Clone --
   -----------

   function Clone
     (Trans : Regular_Transaction)
     return Transaction_Ref
   is
      Trans_Ref : Transaction_Ref;
   begin
      Trans_Ref:=new Regular_Transaction;
      Trans_Ref.Name:=Trans.Name;
      Trans_Ref.Graph:=Graphs.Clone(Trans.Graph);
      return Trans_Ref;
   end Clone;


   ------------------------------
   -- Find_Internal_Event_Link --
   ------------------------------

   function Find_Internal_Event_Link
     (Name : Var_Strings.Var_String;
      Trans : Transaction)
     return MAST.Graphs.Link_Ref
   is
      I : Graphs.Link_Lists.Index;
   begin
      I:=Graphs.Link_Lists.Find
        (Name,Trans.Graph.Internal_Links_List);
      if I=Graphs.Link_Lists.Null_Index then
         raise Link_Not_Found;
      else
         return Graphs.Link_Lists.Item
           (I,Trans.Graph.Internal_Links_List);
      end if;
   end Find_Internal_Event_Link;

   ------------------------------
   -- Find_Any_Link --
   ------------------------------

   function Find_Any_Link
     (Name : Var_Strings.Var_String;
      Trans : Transaction)
     return MAST.Graphs.Link_Ref
   is
      I : Graphs.Link_Lists.Index;
   begin
      I:=Graphs.Link_Lists.Find
        (Name,Trans.Graph.External_Links_List);
      if I=Graphs.Link_Lists.Null_Index then
         I:=Graphs.Link_Lists.Find
           (Name,Trans.Graph.Internal_Links_List);
         if I=Graphs.Link_Lists.Null_Index then
            raise Link_Not_Found;
         else
            return Graphs.Link_Lists.Item
              (I,Trans.Graph.Internal_Links_List);
         end if;
      else
         return Graphs.Link_Lists.Item
           (I,Trans.Graph.External_Links_List);
      end if;
   end Find_Any_Link;

   ------------------------------
   -- Find_Any_Event --
   ------------------------------

   function Find_Any_Event
     (Name : Var_Strings.Var_String;
      Trans : Transaction)
     return MAST.Events.Event_Ref
   is
      I : Graphs.Link_Lists.Index;
   begin
      I:=Graphs.Link_Lists.Find
        (Name,Trans.Graph.External_Links_List);
      if I=Graphs.Link_Lists.Null_Index then
         I:=Graphs.Link_Lists.Find
           (Name,Trans.Graph.Internal_Links_List);
         if I=Graphs.Link_Lists.Null_Index then
            raise Event_Not_Found;
         else
            return Graphs.Event_Of(Graphs.Link_Lists.Item
                                   (I,Trans.Graph.Internal_Links_List).all);
         end if;
      else
         return Graphs.Event_Of(Graphs.Link_Lists.Item
                                (I,Trans.Graph.External_Links_List).all);
      end if;
   end Find_Any_Event;

   ----------------------------------
   -- Get_Next_Internal_Event_Link --
   ----------------------------------

   procedure Get_Next_Internal_Event_Link
     (Trans : in Transaction;
      The_Link : out MAST.Graphs.Link_Ref;
      Iterator : in out Link_Iteration_Object)
   is
   begin
      Graphs.Link_Lists.Get_Next_Item
        (The_Link,Trans.Graph.Internal_Links_List,
         Graphs.Link_Lists.Index(Iterator));
   end Get_Next_Internal_Event_Link;

   ----------------------------
   -- Get_Next_Event_Handler --
   ----------------------------

   procedure Get_Next_Event_Handler
     (Trans : in Transaction;
      The_Event_Handler : out MAST.Graphs.Event_Handler_Ref;
      Iterator : in out Event_Handler_Iteration_Object)
   is
   begin
      Graphs.Event_Handler_Lists.Get_Next_Item
        (The_Event_Handler,Trans.Graph.Event_Handler_List,
         Graphs.Event_Handler_Lists.Index(Iterator));
   end Get_Next_Event_Handler;

   ----------
   -- Init --
   ----------

   procedure Init
     (Trans : in out Transaction;
      Name : Var_Strings.Var_String)
   is
   begin
      Trans.Name:=Name;
   end Init;

   ----------
   -- Name --
   ----------

   function Name
     (Trans : Transaction)
     return Var_Strings.Var_String
   is
   begin
      return Trans.Name;
   end Name;

   ----------
   -- Name --
   ----------

   function Name
     (Trans_Ref : Transaction_Ref)
     return Var_Strings.Var_String
   is
   begin
      return Trans_Ref.Name;
   end Name;

   ---------------------------------
   -- Num_Of_Internal_Event_Links --
   ---------------------------------

   function Num_Of_Internal_Event_Links
     (Trans : Transaction)
     return Natural
   is
   begin
      return Graphs.Link_Lists.Size
        (Trans.Graph.Internal_Links_List);
   end Num_Of_Internal_Event_Links;

   ---------------------------
   -- Num_Of_Event_Handlers --
   ---------------------------

   function Num_Of_Event_Handlers
     (Trans : Transaction)
     return Natural
   is
   begin
      return Graphs.Event_Handler_Lists.Size
        (Trans.Graph.Event_Handler_List);
   end Num_Of_Event_Handlers;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Regular_Transaction;
      Indentation : Positive;
      Finalize    : Boolean:=False) is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"Transaction (");
      MAST.IO.Print_Arg
        (File,"Type","regular",Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Res.Name),Indentation+3,Names_Length);
      if MAST.Graphs.Link_Lists.Size
        (Res.Graph.External_Links_List)>0
      then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"External_Events","",Indentation+3,Names_Length);
         MAST.Graphs.Print
           (File,Res.Graph.External_Links_List,Indentation+3);
      end if;
      if MAST.Graphs.Link_Lists.Size
        (Res.Graph.Internal_Links_List)>0
      then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Internal_Events","",Indentation+3,Names_Length);
         MAST.Graphs.Print
           (File,Res.Graph.Internal_Links_List,Indentation+3);
      end if;
      if MAST.Graphs.Event_Handler_Lists.Size
        (Res.Graph.Event_Handler_List)>0
      then
         MAST.IO.Print_Separator(File);
         MAST.Graphs.Print
           (File,Res.Graph.Event_Handler_List,Indentation+3);
      end if;
      MAST.IO.Print_Separator(File,MAST.IO.Nothing,Finalize);
   end Print;

   --------------------------------
   -- Print_Results              --
   --------------------------------

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      Res : in out Transaction;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant := 8;
      Has_Timing_Results : Boolean;
      Has_Results : Boolean:=False;
      Iter: Link_Iteration_Object;
      The_Link : MAST.Graphs.Link_Ref;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"Transaction (");
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Res.Name),Indentation+3,Names_Length);
      Has_Timing_Results:=
        MAST.Graphs.Link_Lists.Size(Res.Graph.Internal_Links_List)>0;
      MAST.Transactions.Rewind_Internal_Event_Links(Res,Iter);
      for I in 1..MAST.Transactions.Num_Of_Internal_Event_Links(Res)
      loop
         MAST.Transactions.Get_Next_Internal_Event_Link
           (Res, The_Link, Iter);
         Has_Results:= MAST.Graphs.Has_Results(The_Link.all);
         exit when Has_Results;
      end loop;
      if (Has_Timing_Results and Has_Results) or else
        Res.The_Slack_Result/=null
      then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Results","",Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File,MAST.IO.Nothing);
         MAST.IO.Print_List_Item(File,MAST.IO.Left_Paren,
                                 Indentation+7);
         if Res.The_Slack_Result/=null then
            Results.Print(File,Res.The_Slack_Result.all,Indentation+8);
            if Has_Timing_Results then
               MAST.IO.Print_Separator(File);
            end if;
         end if;
         if MAST.Graphs.Link_Lists.Size(Res.Graph.Internal_Links_List)>0 then
            MAST.Graphs.Print_Results
              (File,Res.Graph.Internal_Links_List,Indentation+8);
         end if;
         Ada.Text_IO.Put(File,")");
      end if;
      MAST.IO.Print_Separator(File,MAST.IO.Nothing,Finalize);
   end Print_Results;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Transaction_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print(File,Res_Ref.all,Indentation,True);
         Ada.Text_IO.New_Line(File);
      end loop;
   end Print;

   --------------------------------
   -- Print_Results              --
   --------------------------------

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Transaction_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print_Results(File,Res_Ref.all,Indentation,True);
         Ada.Text_IO.New_Line(File);
      end loop;
   end Print_Results;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Regular_Transaction;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_mdl:Regular_Transaction ");
      Ada.Text_Io.Put_Line(File,"Name=""" & Io.Name_Image(Res.Name) & """ >");
      if MAST.Graphs.Link_Lists.Size
        (Res.Graph.External_Links_List)>0
      then
         MAST.Graphs.Print_XML
           (File,Res.Graph.External_Links_List,Indentation+3);
      end if;
      if MAST.Graphs.Link_Lists.Size
        (Res.Graph.Internal_Links_List)>0
      then
         MAST.Graphs.Print_XML
           (File,Res.Graph.Internal_Links_List,Indentation+3);
      end if;
      if MAST.Graphs.Event_Handler_Lists.Size
        (Res.Graph.Event_Handler_List)>0
      then
         MAST.Graphs.Print_XML
           (File,Res.Graph.Event_Handler_List,Indentation+3);
      end if;
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"</mast_mdl:Regular_Transaction> ");
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Transaction_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print_XML(File,Res_Ref.all,Indentation,True);
         Ada.Text_IO.New_Line(File);
      end loop;
   end Print_XML;

   --------------------------------
   -- Print_XML_results          --
   --------------------------------

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      Res : in out Transaction;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant := 8;
      Has_Timing_Results : Boolean;
      Has_Results : Boolean:=False;
      Iter: Link_Iteration_Object;
      The_Link : MAST.Graphs.Link_Ref;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_res:Transaction ");
      Ada.Text_Io.Put_Line(File,"Name=""" & Io.Name_Image(Res.Name) & """ >");
      Has_Timing_Results:=
        MAST.Graphs.Link_Lists.Size(Res.Graph.Internal_Links_List)>0;
      MAST.Transactions.Rewind_Internal_Event_Links(Res,Iter);
      for I in 1..MAST.Transactions.Num_Of_Internal_Event_Links(Res)
      loop
         MAST.Transactions.Get_Next_Internal_Event_Link
           (Res, The_Link, Iter);
         Has_Results:= MAST.Graphs.Has_Results(The_Link.all);
         exit when Has_Results;
      end loop;
      if (Has_Timing_Results and Has_Results) or else
        Res.The_Slack_Result/=null
      then
         if Res.The_Slack_Result/=null then
            Results.Print_XML
              (File,Res.The_Slack_Result.all,Indentation+3,False);
            if Has_Timing_Results then
               null;
            end if;
         end if;
         if MAST.Graphs.Link_Lists.Size(Res.Graph.Internal_Links_List)>0 then
            MAST.Graphs.Print_XML_Results
              (File,Res.Graph.Internal_Links_List,Indentation+3);
         end if;
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put_Line(File,"</mast_res:Transaction> ");
      end if;
   end Print_XML_Results;

   --------------------------------
   -- Print_XML_Results          --
   --------------------------------

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Transaction_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print_XML_Results(File,Res_Ref.all,Indentation,True);
         Ada.Text_IO.New_Line(File);
      end loop;
   end Print_XML_Results;

   -------------------------
   -- Remove_Event_Handler--
   -------------------------

   procedure Remove_Event_Handler
     (Trans : in out Transaction;
      The_Event_Handler : MAST.Graphs.Event_Handler_Ref)
   is
      Ind : Graphs.Event_Handler_Lists.Index;
      Ev_Ref : Graphs.Event_Handler_Ref;
   begin
      -- Delete handler from list
      Ind:=Graphs.Event_Handler_Lists.Find
        (The_Event_Handler,Trans.Graph.Event_Handler_List);
      if Ind=Graphs.Event_Handler_Lists.Null_Index then
         raise List_Exceptions.Not_Found;
      end if;
      Graphs.Event_Handler_Lists.Delete
        (Ind,Ev_Ref,Trans.Graph.Event_Handler_List);

      -- Delete handler from links referencing it
      Mast.Graphs.Remove_Event_Handler_From_List
        (Trans.Graph.Internal_Links_List, The_Event_Handler);
      Mast.Graphs.Remove_Event_Handler_From_List
        (Trans.Graph.External_Links_List, The_Event_Handler);
   end Remove_Event_Handler;


   --------------------------------
   -- Remove_Internal_Event_Link --
   --------------------------------

   procedure Remove_Internal_Event_Link
     (Trans : in out Transaction;
      The_Link : MAST.Graphs.Link_Ref)
   is
      Ind : Graphs.Link_Lists.Index;
      Ln_Ref : Graphs.Link_Ref;
   begin
      -- Delete link from list
      Ind:=Graphs.Link_Lists.Find
        (Graphs.Name(The_Link),Trans.Graph.Internal_Links_List);
      if Ind=Graphs.Link_Lists.Null_Index then
         raise List_Exceptions.Not_Found;
      end if;
      Graphs.Link_Lists.Delete
        (Ind,Ln_Ref,Trans.Graph.Internal_Links_List);

      -- Delete link from handlers referencing it
      Graphs.Remove_Link_From_List(Trans.Graph.Event_Handler_List, The_Link);
   end Remove_Internal_Event_Link;

   --------------------------------
   -- Remove_External_Event_Link --
   --------------------------------

   procedure Remove_External_Event_Link
     (Trans : in out Transaction;
      The_Link : MAST.Graphs.Link_Ref)
   is
      Ind : Graphs.Link_Lists.Index;
      Ln_Ref : Graphs.Link_Ref;
   begin
      -- Delete link from list
      Ind:=Graphs.Link_Lists.Find
        (Graphs.Name(The_Link),Trans.Graph.External_Links_List);
      if Ind=Graphs.Link_Lists.Null_Index then
         raise List_Exceptions.Not_Found;
      end if;
      Graphs.Link_Lists.Delete
        (Ind,Ln_Ref,Trans.Graph.External_Links_List);

      -- Delete link from handlers referencing it
      Graphs.Remove_Link_From_List(Trans.Graph.Event_Handler_List,The_Link);
   end Remove_External_Event_Link;

   ---------------------------------
   -- Rewind_Internal_Event_Links --
   ---------------------------------

   procedure Rewind_Internal_Event_Links
     (Trans : in Transaction;
      Iterator : out Link_Iteration_Object)
   is
   begin
      Graphs.Link_Lists.Rewind
        (Trans.Graph.Internal_Links_List,
         Graphs.Link_Lists.Index(Iterator));
   end Rewind_Internal_Event_Links;

   ---------------------------
   -- Rewind_Event_Handlers --
   ---------------------------

   procedure Rewind_Event_Handlers
     (Trans : in Transaction;
      Iterator : out Event_Handler_Iteration_Object)
   is
   begin
      Graphs.Event_Handler_Lists.Rewind
        (Trans.Graph.Event_Handler_List,
         Graphs.Event_Handler_Lists.Index(Iterator));
   end Rewind_Event_Handlers;

   -----------
   -- Scale --
   -----------

   procedure Scale
     (Trans : Transaction; Factor : Normalized_Execution_Time)
   is
      Iterator : Graphs.Event_Handler_Lists.Iteration_Object;
      EH_REf : Graphs.Event_Handler_Ref;
   begin
      Graphs.Event_Handler_Lists.Rewind
        (Trans.Graph.Event_Handler_List,Iterator);
      for I in 1..Graphs.Event_Handler_Lists.Size
        (Trans.Graph.Event_Handler_List)
      loop
         Graphs.Event_Handler_Lists.Get_Next_Item
           (EH_Ref,Trans.Graph.Event_Handler_List,Iterator);
         if EH_Ref.all in Graphs.Event_Handlers.Activity'Class then
            Operations.Scale(Graphs.Event_Handlers.Activity_Operation
                             (Graphs.Event_Handlers.Activity'Class
                              (EH_Ref.all)).all,Factor);
         end if;
      end loop;
   end Scale;

   -----------------------------
   -- Add_External_Event_Link --
   -----------------------------

   procedure Add_External_Event_Link
     (Trans : in out Transaction;
      The_Link : MAST.Graphs.Link_Ref)
   is
   begin
      Graphs.Link_Lists.Add
        (The_Link,Trans.Graph.External_Links_List);
   end Add_External_Event_Link;

   ------------------------------
   -- Find_External_Event_Link --
   ------------------------------

   function Find_External_Event_Link
     (Name : Var_Strings.Var_String;
      Trans : Transaction)
     return MAST.Graphs.Link_Ref
   is
      I : Graphs.Link_Lists.Index;
   begin
      I:=Graphs.Link_Lists.Find
        (Name,Trans.Graph.External_Links_List);
      if I=Graphs.Link_Lists.Null_Index then
         raise Link_Not_Found;
      else
         return Graphs.Link_Lists.Item
           (I,Trans.Graph.External_Links_List);
      end if;
   end Find_External_Event_Link;

   ----------------------------------
   -- Get_Next_External_Event_Link --
   ----------------------------------

   procedure Get_Next_External_Event_Link
     (Trans : in Transaction;
      The_Link : out MAST.Graphs.Link_Ref;
      Iterator : in out Link_Iteration_Object)
   is
   begin
      Graphs.Link_Lists.Get_Next_Item
        (The_Link,Trans.Graph.External_Links_List,
         Graphs.Link_Lists.Index(Iterator));
   end Get_Next_External_Event_Link;

   ---------------------------------
   -- Num_Of_External_Event_Links --
   ---------------------------------

   function Num_Of_External_Event_Links
     (Trans : Transaction)
     return Natural
   is
   begin
      return Graphs.Link_Lists.Size
        (Trans.Graph.External_Links_List);
   end Num_Of_External_Event_Links;

   ----------------------
   -- Set_Slack_Result --
   ----------------------

   procedure Set_Slack_Result
     (Trans : in out Transaction; Res : Results.Slack_Result_Ref)
   is
   begin
      Trans.The_Slack_Result:=Res;
   end Set_Slack_Result;

   ----------------------
   -- Slack_Result     --
   ----------------------

   function Slack_Result
     (Trans : Transaction) return Results.Slack_Result_Ref
   is
   begin
      return Trans.The_Slack_Result;
   end Slack_Result;

   ---------------------------------
   -- Rewind_External_Event_Links --
   ---------------------------------

   procedure Rewind_External_Event_Links
     (Trans : in Transaction;
      Iterator : out Link_Iteration_Object)
   is
   begin
      Graphs.Link_Lists.Rewind
        (Trans.Graph.External_Links_List,
         Graphs.Link_Lists.Index(Iterator));
   end Rewind_External_Event_Links;

   ----------------------------------------
   -- List_References_Scheduling_Server  --
   ----------------------------------------

   function List_References_Scheduling_Server
     (Ss_Ref : Mast.Scheduling_Servers.Scheduling_Server_Ref;
      The_List : Graphs.Event_Handler_Lists.List)
     return Boolean
   is
      Eh_Ref : Graphs.Event_Handler_Ref;
      Iterator : Graphs.Event_Handler_Lists.Index;
   begin
      Graphs.Event_Handler_Lists.Rewind(The_List,Iterator);
      for I in 1..Graphs.Event_Handler_Lists.Size(The_List) loop
         Graphs.Event_Handler_Lists.Get_Next_Item(Eh_Ref,The_List,Iterator);
         if Eh_Ref.all in Graphs.Event_Handlers.Activity'Class and then
           Graphs.Event_Handlers.Activity_Server
           (Graphs.Event_Handlers.Activity'class(Eh_Ref.all))=Ss_Ref
         then
            return True;
         end if;
      end loop;
      return False;
   end List_References_Scheduling_Server;


   ---------------------------------------
   -- List_References_Scheduling_Server --
   ---------------------------------------

   function List_References_Scheduling_Server
     (Ss_Ref : Mast.Scheduling_Servers.Scheduling_Server_Ref;
      The_List : Lists.List)
     return Boolean
   is
      Trans_Ref : Transaction_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Trans_Ref,The_List,Iterator);
         if List_References_Scheduling_Server
           (Ss_Ref,Trans_Ref.Graph.Event_Handler_List)
         then
            return True;
         end if;
      end loop;
      return False;
   end List_References_Scheduling_Server;

   ----------------------------------------
   -- List_References_Operation          --
   ----------------------------------------

   function List_References_Operation
     (Op_Ref : Mast.Operations.Operation_Ref;
      The_List : Graphs.Event_Handler_Lists.List)
     return Boolean
   is
      Eh_Ref : Graphs.Event_Handler_Ref;
      Iterator : Graphs.Event_Handler_Lists.Index;
   begin
      Graphs.Event_Handler_Lists.Rewind(The_List,Iterator);
      for I in 1..Graphs.Event_Handler_Lists.Size(The_List) loop
         Graphs.Event_Handler_Lists.Get_Next_Item(Eh_Ref,The_List,Iterator);
         if Eh_Ref.all in Graphs.Event_Handlers.Activity'Class and then
           Graphs.Event_Handlers.Activity_Operation
           (Graphs.Event_Handlers.Activity'Class(Eh_Ref.all))=Op_Ref
         then
            return True;
         end if;
      end loop;
      return False;
   end List_References_Operation;

   ---------------------------------------
   -- List_References_Operation         --
   ---------------------------------------

   function List_References_Operation
     (Op_Ref : Mast.Operations.Operation_Ref;
      The_List : Lists.List)
     return Boolean
   is
      Trans_Ref : Transaction_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Trans_Ref,The_List,Iterator);
         if List_References_Operation
           (Op_Ref,Trans_Ref.Graph.Event_Handler_List)
         then
            return True;
         end if;
      end loop;
      return False;
   end List_References_Operation;

   ------------------------------
   -- References_Event         --
   ------------------------------

   function References_Event
     (Evnt : Mast.Events.Event_Ref;
      Trans : Transaction)
     return Boolean
   is
   begin
      return Mast.Graphs.References_Event
        (Evnt,Trans.Graph.Internal_Links_List);
   end References_Event;


end MAST.Transactions;
