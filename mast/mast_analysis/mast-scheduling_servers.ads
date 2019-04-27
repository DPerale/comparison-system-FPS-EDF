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
--          Julio Luis Medina      medinajl@unican.es                --
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

with MAST.Scheduling_Parameters, Mast.Processing_Resources,
  MAST.Synchronization_Parameters, MAST.Schedulers,
  MAST.Results, Named_Lists, Var_Strings, Ada.Text_IO;

package MAST.Scheduling_Servers is

   type Scheduling_Server is tagged private;

   procedure Init (Srvr : in out Scheduling_Server;
                   Name : Var_Strings.Var_String);
   function Name (Srvr : Scheduling_Server)
                 return Var_Strings.Var_String;

   function Server_Processing_Resource
     (Srvr : Scheduling_Server)
     return MAST.Processing_Resources.Processing_Resource_Ref;
   -- Returns the processor of the underlying primary scheduler

   procedure Set_Server_Sched_Parameters
     (Srvr : in out Scheduling_Server;
      The_Server_Sched_Parameters :
      MAST.Scheduling_Parameters.Sched_Parameters_Ref);
   function Server_Sched_Parameters
     (Srvr : Scheduling_Server)
     return MAST.Scheduling_Parameters.Sched_Parameters_Ref;

   procedure Set_Sched_Params_Result
     (Sch : in out Scheduling_Server;
      Res : Results.Sched_Params_Result_Ref);

   function Sched_Params_Result
     (Sch : Scheduling_Server)
     return Results.Sched_Params_Result_Ref;

   procedure Set_Server_Synch_Parameters
     (Srvr : in out Scheduling_Server;
      The_Server_Synch_Parameters :
      MAST.Synchronization_Parameters.Synch_Parameters_Ref);
   function Server_Synch_Parameters
     (Srvr : Scheduling_Server)
     return MAST.Synchronization_Parameters.Synch_Parameters_Ref;

   procedure Set_Synch_Params_Result
     (Sch : in out Scheduling_Server;
      Res : Results.Synch_Params_Result_Ref);
   function Synch_Params_Result
     (Sch : Scheduling_Server)
     return Results.Synch_Params_Result_Ref;

   procedure Set_Server_Scheduler
     (Srvr : in out Scheduling_Server;
      The_Server_Scheduler :
      MAST.Schedulers.Scheduler_Ref);
   function Server_Scheduler
     (Srvr : Scheduling_Server)
     return MAST.Schedulers.Scheduler_Ref;

   function Base_Priority
     (Srvr : Scheduling_Server)
     return Priority;
   -- returns the priority of the underlying scheduling server
   --   (Priority'First for servers with EDF parameters)

   function Base_Level
     (Srvr : Scheduling_Server)
     return Preemption_Level;
   -- returns the preemption_level of the underlying scheduling server
   --   (Preemption_Level'First for servers with non-EDF parameters)

   procedure Set_Scheduler_State
     (Srvr : in out Scheduling_Server;
      Has_Scheduler : in Boolean);

   function Has_Scheduler
     (Srvr : Scheduling_Server)
     return Boolean;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Scheduling_Server;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Scheduling_Server;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True);

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      Sch  : Scheduling_Server;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      Sch  : Scheduling_Server;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   type Scheduling_Server_Ref is access Scheduling_Server'Class;

   function Clone
     (Srvr : Scheduling_Server)
     return  Scheduling_Server_Ref;
   -- Clone is incomplete. References point at the old system
   -- Needs later adjustment

   procedure Adjust
     (Srvr : in out Scheduling_Server;
      Scheduler_List : in Schedulers.Lists.List);
   -- To adjust internal pointers to point to the list elements
   -- it may raise Object_Not_Found

   function Name (Srvr_Ref : Scheduling_Server_Ref )
                 return Var_Strings.Var_String;

   package Lists is new Named_Lists
     (Element => Scheduling_Server_Ref,
      Name    => Name);

   function Clone
     (The_List : in Lists.List)
     return Lists.List;

   procedure Adjust
     (The_List : in Lists.List;
      Scheduler_List : in Schedulers.Lists.List);
   -- To adjust internal pointers to point to the list elements
   -- it may raise Object_Not_Found

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   function Get_Min_System_Priority
     (The_List : Lists.List)
     return Priority;
   -- raises Incorrect object if schedulers are not Fixed_Priority_Policy

   function List_References_Scheduler
     (Sched_Ref : Mast.Schedulers.Scheduler_Ref;
      The_List : Lists.List)
     return Boolean;
   -- indicates whether the list contains a reference to the
   -- scheduler pointed to by Sched_Ref or not

   procedure Adjust_Ref
     (Srvr_Ref : in out Scheduling_Server_Ref;
      The_List : in Lists.List);
   -- changes the srvr_ref to point to the object of the same name in The_List
   -- it may raise Object_Not_Found

private

   type Scheduling_Server is tagged record
      Name : Var_Strings.Var_String;
      Server_Scheduler :
        MAST.Schedulers.Scheduler_Ref;
      Server_Sched_Parameters :
        MAST.Scheduling_Parameters.Sched_Parameters_Ref;
      Server_Synch_Parameters :
        MAST.Synchronization_Parameters.Synch_Parameters_Ref;
      The_Sched_Params_Result : Results.Sched_Params_Result_Ref;
      The_Synch_Params_Result : Results.Synch_Params_Result_Ref;
      Scheduler_Present : Boolean:=False;
   end record;

end MAST.Scheduling_Servers;
