-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2004                     --
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

with Ada.Text_IO;
package Mast.Scheduling_Parameters is

   type Sched_Parameters is abstract tagged private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Sched_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Sched_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl") is abstract;

   type Sched_Parameters_Ref is access Sched_Parameters'Class;

   function Clone
     (Parameters : Sched_Parameters)
     return  Sched_Parameters_Ref is abstract;

   type Overridden_Sched_Parameters is abstract tagged private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Overridden_Sched_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Overridden_Sched_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;


   type Overridden_Sched_Parameters_Ref is access
     Overridden_Sched_Parameters'Class;

   function Clone
     (Parameters : Overridden_Sched_Parameters)
     return  Overridden_Sched_Parameters_Ref is abstract;

   -----------------------------
   -- Fixed_Priority_Parameters
   -----------------------------

   type Fixed_Priority_Parameters is abstract new
     Sched_Parameters with private;

   procedure Set_The_Priority
     (Parameters : in out Fixed_Priority_Parameters;
      The_Priority : Priority);
   function The_Priority
     (Parameters : Fixed_Priority_Parameters) return Priority;

   procedure Set_Preassigned
     (Parameters : in out Fixed_Priority_Parameters;
      Is_Preassigned : Boolean);
   function Preassigned
     (Parameters : Fixed_Priority_Parameters) return Boolean;

   ---------------------------------------
   -- Overridden Fixed_Priority_Parameters
   ---------------------------------------

   type Overridden_FP_Parameters is new
     Overridden_Sched_Parameters with private;

   procedure Set_The_Priority
     (Parameters : in out Overridden_FP_Parameters;
      The_Priority : Priority);
   function The_Priority
     (Parameters : Overridden_FP_Parameters) return Priority;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Overridden_FP_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Overridden_FP_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Parameters : Overridden_FP_Parameters)
     return  Overridden_Sched_Parameters_Ref;

   -------------------------------------------------
   -- Overridden Permanent Fixed_Priority_Parameters
   -------------------------------------------------

   type Overridden_Permanent_FP_Parameters is new
     Overridden_FP_Parameters with private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Overridden_Permanent_FP_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Overridden_Permanent_FP_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Parameters : Overridden_Permanent_FP_Parameters)
     return  Overridden_Sched_Parameters_Ref;


   -----------------------------
   -- Fixed_Priority_Policy
   -----------------------------

   type Fixed_Priority_Policy is new
     Fixed_Priority_Parameters with private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Fixed_Priority_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Fixed_Priority_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl");

   function Clone
     (Parameters : Fixed_Priority_Policy)
     return  Sched_Parameters_Ref;

   -----------------------------
   -- Non_Preemptible_FP_Policy
   -----------------------------

   type Non_Preemptible_FP_Policy is new
     Fixed_Priority_Parameters with private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Non_Preemptible_FP_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Non_Preemptible_FP_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl");

   function Clone
     (Parameters : Non_Preemptible_FP_Policy)
     return  Sched_Parameters_Ref;

   -----------------------------
   -- Interrupt_FP_Policy
   -----------------------------

   type Interrupt_FP_Policy is new
     Fixed_Priority_Parameters with private;

   function Preassigned
     (Parameters : Interrupt_FP_Policy) return Boolean;
   -- The preassigned field is always true in interrupt_FP_policy

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Interrupt_FP_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Interrupt_FP_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl");

   function Clone
     (Parameters : Interrupt_FP_Policy)
     return  Sched_Parameters_Ref;


   -----------------------------
   -- Polling_Policy
   -----------------------------

   type Polling_Policy is new Fixed_Priority_Parameters
     with private;

   procedure Set_Polling_Period
     (Parameters : in out Polling_Policy;
      The_Polling_Period : Time);
   function Polling_Period
     (Parameters : Polling_Policy) return Time;

   procedure Set_Polling_Worst_Overhead
     (Parameters : in out Polling_Policy;
      The_Polling_Worst_Overhead : Normalized_Execution_Time);
   function Polling_Worst_Overhead
     (Parameters : Polling_Policy)
     return Normalized_Execution_Time;
   procedure Set_Polling_Best_Overhead
     (Parameters : in out Polling_Policy;
      The_Polling_Best_Overhead : Normalized_Execution_Time);
   function Polling_Best_Overhead
     (Parameters : Polling_Policy)
     return Normalized_Execution_Time;
   procedure Set_Polling_Avg_Overhead
     (Parameters : in out Polling_Policy;
      The_Polling_Avg_Overhead : Normalized_Execution_Time);
   function Polling_Avg_Overhead
     (Parameters : Polling_Policy)
     return Normalized_Execution_Time;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Polling_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Polling_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl");


   function Clone
     (Parameters : Polling_Policy)
     return  Sched_Parameters_Ref;

   -----------------------------
   -- Sporadic_Server_Policy
   -----------------------------

   type Sporadic_Server_Policy is new Fixed_Priority_Parameters
     with private;

   procedure Set_Background_Priority
     (Parameters : in out Sporadic_Server_Policy;
      The_Background_Priority : Priority);
   procedure Set_Initial_Capacity
     (Parameters : in out Sporadic_Server_Policy;
      The_Initial_Capacity : Time);
   procedure Set_Replenishment_Period
     (Parameters : in out Sporadic_Server_Policy;
      The_Replenishment_Period : Time);
   procedure Set_Max_Pending_Replenishments
     (Parameters : in out Sporadic_Server_Policy;
      The_Replenishments : Positive);
   function Background_Priority
     (Parameters : Sporadic_Server_Policy) return Priority;
   function Initial_Capacity
     (Parameters : Sporadic_Server_Policy) return Time;
   function Replenishment_Period
     (Parameters : Sporadic_Server_Policy) return Time;
   function Max_Pending_Replenishments
     (Parameters : Sporadic_Server_Policy) return Positive;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Sporadic_Server_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Sporadic_Server_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl");

   function Clone
     (Parameters : Sporadic_Server_Policy)
     return  Sched_Parameters_Ref;

   ---------------------------------------
   -- Earliest_Deadline First_Parameters
   ---------------------------------------

   type EDF_Parameters is abstract new
     Sched_Parameters with private;

   procedure Set_Deadline
     (Parameters : in out EDF_Parameters;
      The_Deadline : Time);
   function Deadline
     (Parameters : EDF_Parameters)
     return Time;

   procedure Set_Preassigned
     (Parameters : in out EDF_Parameters;
      Is_Preassigned : Boolean);
   function Preassigned
     (Parameters : EDF_Parameters)
     return Boolean;

   type EDF_Policy is new
     EDF_Parameters with private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out EDF_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out EDF_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl");

   function Clone
     (Parameters : EDF_Policy)
     return  Sched_Parameters_Ref;

private

   type Sched_Parameters is abstract tagged null record;

   type Overridden_Sched_Parameters is abstract tagged null record;

   type Fixed_Priority_Parameters is abstract new
     Sched_Parameters with record
        Prio : Priority:=Priority'First;
        Preassigned : Boolean:=False;
   end record;

   type Overridden_FP_Parameters is new Overridden_Sched_Parameters
     with record
        Prio : Priority:=Priority'First;
   end record;

   type Overridden_Permanent_FP_Parameters is new
     Overridden_FP_Parameters with null record;

   type Fixed_Priority_Policy is new Fixed_Priority_Parameters
     with null record;

   type Non_Preemptible_FP_Policy is new
     Fixed_Priority_Parameters with null record;

   type Interrupt_FP_Policy is new
     Fixed_Priority_Parameters with null record;

   type Polling_Policy is new Fixed_Priority_Parameters with
      record
         Polling_Period : Time:=0.0;
         Polling_Worst_Overhead,
         Polling_Best_Overhead,
         Polling_Avg_Overhead : Normalized_Execution_Time:=0.0;
      end record;

   type Sporadic_Server_Policy is new Fixed_Priority_Parameters with
      record
         Background_Priority : Priority:=Priority'First;
         Initial_Capacity,
         Replenishment_Period : Time:=0.0;
         Max_Pending_Replenishments : Positive:=1;
      end record;

   type EDF_Parameters is abstract new Sched_Parameters with
      record
         Deadline : Time:=Large_Time;
         Preassigned : Boolean:=False;
      end record;

   type EDF_Policy is new EDF_Parameters with null record;

end Mast.Scheduling_Parameters;
