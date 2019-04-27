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

with MAST.Operations, MAST.Events, MAST.Scheduling_Servers;

package MAST.Graphs.Event_Handlers is

   procedure Adjust
     (The_Graph : in out Graph;
      Sched_Servers : Scheduling_Servers.Lists.List;
      Operats       : Operations.Lists.List);
   -- calls Adjust for all the event handlers in the graph

   ---------------------------
   -- Regular_Event_Handler --
   ---------------------------

   type Regular_Event_Handler is abstract new Event_Handler with null record;

   procedure Adjust
     (Ev_Hdlr : in out Regular_Event_Handler;
      The_Graph : Graph) is abstract;
   -- used to adjust the pointers to the links, and
   -- the pointers from the links to the event handler,

   ------------------------
   -- Simple Event_Handler
   ------------------------

   type Simple_Event_Handler is abstract new Regular_Event_Handler
     with private;

   procedure Set_Input_Link
     (The_Event_Handler : in out Simple_Event_Handler;
      The_Input_Link : Link_Ref);
   function Input_Link
     (The_Event_Handler : Simple_Event_Handler) return Link_Ref;

   procedure Set_Output_Link
     (The_Event_Handler : in out Simple_Event_Handler;
      The_Output_Link : Link_Ref);
   function Output_Link
     (The_Event_Handler : Simple_Event_Handler) return Link_Ref;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Simple_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Simple_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Adjust
     (Ev_Hdlr : in out Simple_Event_Handler;
      The_Graph : Graph);
   -- used to adjust the pointers to the links,
   -- and the pointers from the links to the event handler

   procedure Remove_Link_From_Handler
     (Handler : in out Simple_Event_Handler;
      Lnk_Ref: Link_Ref);

   ------------------------
   -- Activity
   ------------------------

   type Activity is new Simple_Event_Handler with private;

   procedure Set_Activity_Operation
     (The_Event_Handler : in out Activity;
      The_Activity_Operation : MAST.Operations.Operation_Ref);

   function Activity_Operation
     (The_Event_Handler : Activity)
     return MAST.Operations.Operation_Ref;

   procedure Set_Activity_Server
     (The_Event_Handler : in out Activity;
      The_Activity_Server :
      Scheduling_Servers.Scheduling_Server_Ref);

   function Activity_Server
     (The_Event_Handler : Activity)
     return Scheduling_Servers.Scheduling_Server_Ref;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Activity;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Activity;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Ev_Hdlr : Activity)
     return Event_Handler_Ref;
   -- Clone is incomplete. Internal references point at old system.
   -- Internal reference fields need later adjustment

   procedure Adjust
     (Ev_Hdlr : in out Activity;
      Sched_Servers : Scheduling_Servers.Lists.List;
      Operats       : Operations.Lists.List);
   -- additional adjustment to adjusts pointers to
   -- scheduling servers and operations

   ------------------------
   -- System_Timed_Activity
   ------------------------

   type System_Timed_Activity is new Activity with private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out System_Timed_Activity;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out System_Timed_Activity;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Ev_Hdlr : System_Timed_Activity)
     return Event_Handler_Ref;
   -- Clone is incomplete. Internal references point at old system.
   -- Internal reference fields need later adjustment

   ------------------------
   -- Input Event_Handler
   ------------------------

   type Input_Event_Handler is abstract new Regular_Event_Handler
     with private;

   type Iteration_Object is private;

   procedure Add_Input_Link
     (The_Event_Handler : in out Input_Event_Handler;
      The_Link : Link_Ref);

   procedure Remove_Input_Link
     (The_Event_Handler : in out Input_Event_Handler;
      The_Link : Link_Ref);
   -- Raises List_Exceptions.Not_Found if not found

   function Num_Of_Input_Links
     (The_Event_Handler : Input_Event_Handler)
     return Natural;

   procedure Rewind_Input_Links
     (The_Event_Handler : in Input_Event_Handler;
      Iterator : out Iteration_Object);

   procedure Get_Next_Input_Link
     (The_Event_Handler : in Input_Event_Handler;
      The_Link : out Link_Ref;
      Iterator : in out Iteration_Object);

   procedure Set_Output_Link
     (The_Event_Handler : in out Input_Event_Handler;
      The_Output_Link : Link_Ref);
   function Output_Link
     (The_Event_Handler : Input_Event_Handler) return Link_Ref;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Input_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Input_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Adjust
     (Ev_Hdlr : in out Input_Event_Handler;
      The_Graph : Graph);
   -- used to adjust the pointers to the links, and
   -- the pointers from the links to the event handler

   procedure Remove_Link_From_Handler
     (Handler : in out Input_Event_Handler;
      Lnk_Ref: Link_Ref);

   ------------------------
   -- Concentrator
   ------------------------

   type Concentrator is new Input_Event_Handler with private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Concentrator;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Concentrator;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Ev_Hdlr : Concentrator)
     return Event_Handler_Ref;
   -- Clone is incomplete. Internal references point at old system.
   -- Internal reference fields need later adjustment

   ------------------------
   -- Barrier
   ------------------------

   type Barrier is new Input_Event_Handler with private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Barrier;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Barrier;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Ev_Hdlr : Barrier)
     return Event_Handler_Ref;
   -- Clone is incomplete. Internal references point at old system.
   -- Internal reference fields need later adjustment

   ------------------------
   -- Output Event_Handler
   ------------------------

   type Output_Event_Handler is abstract new Regular_Event_Handler
     with private;

   procedure Add_Output_Link
     (The_Event_Handler : in out Output_Event_Handler;
      The_Link : Link_Ref);

   procedure Remove_Output_Link
     (The_Event_Handler : in out Output_Event_Handler;
      The_Link : Link_Ref);
   -- Raises List_Exceptions.Not_Found if not found

   function Num_Of_Output_Links
     (The_Event_Handler : Output_Event_Handler)
     return Natural;

   procedure Rewind_Output_Links
     (The_Event_Handler : in Output_Event_Handler;
      Iterator : out Iteration_Object);

   procedure Get_Next_Output_Link
     (The_Event_Handler : in Output_Event_Handler;
      The_Link : out Link_Ref;
      Iterator : in out Iteration_Object);

   procedure Set_Input_Link
     (The_Event_Handler : in out Output_Event_Handler;
      The_Input_Link : Link_Ref);
   function Input_Link
     (The_Event_Handler : Output_Event_Handler) return Link_Ref;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Output_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Output_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Adjust
     (Ev_Hdlr : in out Output_Event_Handler;
      The_Graph : Graph);
   -- used to adjust the pointers to the links, and
   -- the pointers from the links to the event handler

   procedure Remove_Link_From_Handler
     (Handler : in out Output_Event_Handler;
      Lnk_Ref: Link_Ref);

   ------------------------
   -- Delivery_server
   ------------------------

   type Delivery_Server is new Output_Event_Handler with private;

   procedure Set_Policy
     (The_Event_Handler : in out Delivery_Server;
      The_Policy : Mast.Delivery_Policy);
   function Policy
     (The_Event_Handler : Delivery_Server)
     return Mast.Delivery_Policy;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Delivery_Server;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Delivery_Server;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Ev_Hdlr : Delivery_Server)
     return Event_Handler_Ref;
   -- Clone is incomplete. Internal references point at old system.
   -- Internal reference fields need later adjustment

   ------------------------
   -- Query_server
   ------------------------

   type Query_Server is new Output_Event_Handler with private;

   procedure Set_Policy
     (The_Event_Handler : in out Query_Server;
      The_Policy : Mast.Request_Policy);
   function Policy
     (The_Event_Handler : Query_Server)
     return Mast.Request_Policy;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Query_Server;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Query_Server;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Ev_Hdlr : Query_Server)
     return Event_Handler_Ref;
   -- Clone is incomplete. Internal references point at old system.
   -- Internal reference fields need later adjustment

   ------------------------
   -- Multicast
   ------------------------

   type Multicast is new Output_Event_Handler with private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Multicast;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Multicast;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Ev_Hdlr : Multicast)
     return Event_Handler_Ref;
   -- Clone is incomplete. Internal references point at old system.
   -- Internal reference fields need later adjustment

   ------------------------
   -- Rate Divisor
   ------------------------

   type Rate_Divisor is new Simple_Event_Handler with private;

   procedure Set_Rate_Factor
     (The_Event_Handler : in out Rate_Divisor;
      The_Rate_Factor : Positive);
   function Rate_Factor
     (The_Event_Handler : Rate_Divisor) return Positive;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Rate_Divisor;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Rate_Divisor;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Ev_Hdlr : Rate_Divisor)
     return Event_Handler_Ref;
   -- Clone is incomplete. Internal references point at old system.
   -- Internal reference fields need later adjustment

   ------------------------
   -- Delay_Event_Handler
   ------------------------

   type Delay_Event_Handler is new
     Simple_Event_Handler with private;

   procedure Set_Delay_Max_Interval
     (The_Event_Handler : in out Delay_Event_Handler;
      The_Delay_Max_Interval : Time);
   function Delay_Max_Interval
     (The_Event_Handler : Delay_Event_Handler) return Time;

   procedure Set_Delay_Min_Interval
     (The_Event_Handler : in out Delay_Event_Handler;
      The_Delay_Min_Interval : Time);
   function Delay_Min_Interval
     (The_Event_Handler : Delay_Event_Handler) return Time;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Delay_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Delay_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Ev_Hdlr : Delay_Event_Handler)
     return Event_Handler_Ref;
   -- Clone is incomplete. Internal references point at old system.
   -- Internal reference fields need later adjustment

   ------------------------
   -- Offset_Event_Handler
   ------------------------

   type Offset_Event_Handler is new Delay_Event_Handler
     with private;

   procedure Set_Referenced_Event
     (The_Event_Handler : in out Offset_Event_Handler;
      The_Referenced_Event : MAST.Events.Event_Ref);
   function Referenced_Event
     (The_Event_Handler : Offset_Event_Handler)
     return MAST.Events.Event_Ref;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Offset_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Offset_Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Ev_Hdlr : Offset_Event_Handler)
     return Event_Handler_Ref;
   -- Clone is incomplete. Internal references point at old system.
   -- Internal reference fields need later adjustment

   procedure Adjust
     (Ev_Hdlr : in out Offset_Event_Handler;
      The_Graph : Graph);
   -- used to adjust the pointers to the links,
   -- the pointers from the links to the event handler,
   -- and the pointer to the referenced event


private

   type Simple_Event_Handler is abstract new Regular_Event_Handler with
      record
         Input_Link,
         Output_Link : Link_Ref;
      end record;

   type Activity is new Simple_Event_Handler with record
      Activity_Operation : MAST.Operations.Operation_Ref;
      Activity_Server    : Scheduling_Servers.Scheduling_Server_Ref;
   end record;

   type System_Timed_Activity is new Activity with null record;

   type Input_Event_Handler is abstract new Regular_Event_Handler with record
      Input_Links : Link_Lists.List;
      Output_Link : Link_Ref;
   end record;

   type Iteration_Object is new Link_Lists.Index;

   type Concentrator is new Input_Event_Handler with null record;

   type Barrier is new Input_Event_Handler with null record;

   type Output_Event_Handler is abstract new Regular_Event_Handler with
      record
         Input_Link : Link_Ref;
         Output_Links : Link_Lists.List;
      end record;

   type Delivery_Server is new Output_Event_Handler with record
      Policy : Mast.Delivery_Policy:=Random;
   end record;

   type Query_Server is new Output_Event_Handler with record
      Policy : Mast.Request_Policy:=Scan;
   end record;

   type Multicast is new Output_Event_Handler with null record;

   type Rate_Divisor is new Simple_Event_Handler with record
      Rate_Factor : Positive:=1;
   end record;

   type Delay_Event_Handler is new Simple_Event_Handler with record
      Delay_Max_Interval,
      Delay_Min_Interval : Time:=0.0;
   end record;

   type Offset_Event_Handler is new Delay_Event_Handler with record
      Referenced_Event : MAST.Events.Event_Ref;
   end record;

end MAST.Graphs.Event_Handlers;
