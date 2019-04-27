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

with Ada.Text_IO,MAST.Graphs,MAST.Events, Mast.Operations,
  Mast.Results, Mast.Scheduling_Servers, Named_Lists, Var_Strings;

package MAST.Transactions is

   Link_Not_Found : exception; -- raised by Find_*_Link

   Event_Not_Found : exception; -- raised by Find_Any_Event

   type Event_Handler_Iteration_Object is private;
   type Link_Iteration_Object is private;

   type Transaction is abstract tagged private;

   procedure Init
     (Trans : in out Transaction;
      Name : Var_Strings.Var_String);
   function Name (Trans : Transaction)
                 return Var_Strings.Var_String;

   procedure Add_Event_Handler
     (Trans : in out Transaction;
      The_Event_Handler : MAST.Graphs.Event_Handler_Ref);

   procedure Remove_Event_Handler
     (Trans : in out Transaction;
      The_Event_Handler : MAST.Graphs.Event_Handler_Ref);
   -- Raises List_Exceptions.Not_Found if not found

   function Num_Of_Event_Handlers
     (Trans : Transaction )
     return Natural;

   procedure Rewind_Event_Handlers
     (Trans : in Transaction;
      Iterator : out Event_Handler_Iteration_Object);

   procedure Get_Next_Event_Handler
     (Trans : in Transaction;
      The_Event_Handler : out MAST.Graphs.Event_Handler_Ref;
      Iterator : in out Event_Handler_Iteration_Object);

   procedure Add_Internal_Event_Link
     (Trans : in out Transaction;
      The_Link : MAST.Graphs.Link_Ref);

   procedure Remove_Internal_Event_Link
     (Trans : in out Transaction;
      The_Link : MAST.Graphs.Link_Ref);
   -- Raises List_Exceptions.Not_Found if not found

   function Num_Of_Internal_Event_Links
     (Trans : Transaction )
     return Natural;

   function Find_Internal_Event_Link
     (Name : Var_Strings.Var_String;
      Trans : Transaction)
     return MAST.Graphs.Link_Ref;
   -- raises Link_Not_Found if link not found

   procedure Rewind_Internal_Event_Links
     (Trans : in Transaction;
      Iterator : out Link_Iteration_Object);

   procedure Get_Next_Internal_Event_Link
     (Trans : in Transaction;
      The_Link : out MAST.Graphs.Link_Ref;
      Iterator : in out Link_Iteration_Object);

   procedure Add_External_Event_Link
     (Trans : in out Transaction;
      The_Link : MAST.Graphs.Link_Ref);

   procedure Remove_External_Event_Link
     (Trans : in out Transaction;
      The_Link : MAST.Graphs.Link_Ref);
   -- Raises List_Exceptions.Not_Found if not found

   function Num_Of_External_Event_Links
     (Trans : Transaction )
     return Natural;

   function Find_External_Event_Link
     (Name : Var_Strings.Var_String;
      Trans : Transaction)
     return MAST.Graphs.Link_Ref;
   -- raises Link_Not_Found if link not found

   procedure Rewind_External_Event_Links
     (Trans : in Transaction;
      Iterator : out Link_Iteration_Object);

   procedure Get_Next_External_Event_Link
     (Trans : in Transaction;
      The_Link : out MAST.Graphs.Link_Ref;
      Iterator : in out Link_Iteration_Object);

   function Find_Any_Link
     (Name : Var_Strings.Var_String;
      Trans : Transaction)
     return MAST.Graphs.Link_Ref;
   -- raises Link_Not_Found if link not found

   function Find_Any_Event
     (Name : Var_Strings.Var_String;
      Trans : Transaction)
     return MAST.Events.Event_Ref;
   -- raises Event_Not_Found if link not found

   procedure Scale
     (Trans : Transaction; Factor : Normalized_Execution_Time);
   -- Scales the execution times of all operations in the transaction

   procedure Set_Slack_Result
     (Trans : in out Transaction; Res : Results.Slack_Result_Ref);

   function Slack_Result
     (Trans : Transaction) return Results.Slack_Result_Ref;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Transaction;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

  procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Transaction;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      Res : in out Transaction;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      Res : in out Transaction;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function References_Event
     (Evnt : Mast.Events.Event_Ref;
      Trans : Transaction)
     return Boolean;
   -- Indicates whether the timing requirements of the transaction
   -- reference the event specified by Evnt

   type Transaction_Ref is access Transaction'Class;

   function Clone
     (Trans : Transaction)
     return Transaction_Ref is abstract;

   procedure Adjust
     (Trans : in out Transaction;
      Sched_Servers : Scheduling_Servers.Lists.List;
      Operats       : Operations.Lists.List);
   -- adjusts internal pointers referencing event handlers and events
   -- may raise Object_Not_Found

   function Name (Trans_Ref : Transaction_Ref )
                 return Var_Strings.Var_String;

   package Lists is new Named_Lists
     (Element => Transaction_Ref,
      Name    => Name);

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   function Clone
     (The_List : Lists.List)
     return Lists.List;

   procedure Adjust
     (The_List : in out Lists.List;
      Sched_Servers : Scheduling_Servers.Lists.List;
      Operats       : Operations.Lists.List);
   -- adjusts internal pointers referencing event handlers and events
   -- may raise Object_Not_Found

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   function List_References_Scheduling_Server
     (Ss_Ref : Mast.Scheduling_Servers.Scheduling_Server_Ref;
      The_List : Lists.List)
     return Boolean;
     -- indicates whether the list contains activities with
     -- a reference to the
     -- scheduling server pointed to by Ss_Ref or not

   function List_References_Operation
     (Op_Ref : Mast.Operations.Operation_Ref;
      The_List : Lists.List)
     return Boolean;
     -- indicates whether the list contains activities with
     -- a reference to the
     -- operation pointed to by Op_Ref or not

   type Regular_Transaction is new Transaction with private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Regular_Transaction;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Regular_Transaction;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Trans : Regular_Transaction)
     return Transaction_Ref;

private

   type Transaction is abstract tagged record
      Name : Var_Strings.Var_String;
      Graph : MAST.Graphs.Graph;
      The_Slack_Result : Results.Slack_Result_Ref;
   end record;

   type Event_Handler_Iteration_Object is new
     Graphs.Event_Handler_Lists.Index;
   type Link_Iteration_Object is new
     Graphs.Link_Lists.Index;

   type Regular_Transaction is new Transaction with null record;

end MAST.Transactions;
