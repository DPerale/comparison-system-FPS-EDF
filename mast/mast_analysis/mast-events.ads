-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2005                     --
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

with Ada.Text_IO, Named_Lists, Var_Strings;

package MAST.Events is

   type Event is abstract tagged private;

   procedure Init
     (Evnt : in out Event;
      Name : Var_Strings.Var_String);

   function Name (Evnt : Event)
                 return Var_Strings.Var_String;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Event;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Event;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   type Event_Ref is access Event'Class;

   function Clone
     (Evnt : Event)
     return Event_Ref is abstract;

   function Name (Evnt_Ref : Event_Ref )
                 return Var_Strings.Var_String;

   package Lists is new Named_Lists
     (Element => Event_Ref,
      Name    => Name);
   -- used only for clonning, not in the MAST data structure itself

   ------------------------
   -- Internal Event
   ------------------------

   type Internal_Event is new Event with private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Internal_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Internal_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Evnt : Internal_Event)
     return Event_Ref;

   ------------------------
   -- External Event
   ------------------------

   type External_Event is abstract new Event with private;

   type External_Event_Ref is access all External_Event'Class;

   function Name (Evnt_Ref : External_Event_Ref )
                 return Var_Strings.Var_String;


   ------------------------
   -- Periodic Event
   ------------------------

   type Periodic_Event is new External_Event with private;

   procedure Set_Period
     (Evnt : in out Periodic_Event;
      The_Period : Time);
   function Period
     (Evnt : Periodic_Event) return Time;

   procedure Set_Max_Jitter
     (Evnt : in out Periodic_Event;
      The_Jitter : Time);
   function Max_Jitter
     (Evnt : Periodic_Event) return Time;

   procedure Set_Phase
     (Evnt : in out Periodic_Event;
      The_Phase : Absolute_Time);
   function Phase
     (Evnt : Periodic_Event) return Absolute_Time;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Periodic_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Periodic_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Evnt : Periodic_Event)
     return Event_Ref;

   ------------------------
   -- Singular Event
   ------------------------

   type Singular_Event is new External_Event with private;

   procedure Set_Phase
     (Evnt : in out Singular_Event;
      The_Phase : Absolute_Time);
   function Phase
     (Evnt : Singular_Event) return Absolute_Time;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Singular_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Singular_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Evnt : Singular_Event)
     return Event_Ref;

   -----------------
   -- Aperiodic Event
   -----------------

   type Aperiodic_Event is abstract new External_Event with private;

   procedure Set_Avg_Interarrival
     (Evnt : in out Aperiodic_Event;
      The_Avg_Interarrival : Time);
   function Avg_Interarrival
     (Evnt : Aperiodic_Event) return Time;

   procedure Set_Distribution
     (Evnt : in out Aperiodic_Event;
      The_Distribution : Distribution_Function);
   function Distribution
     (Evnt : Aperiodic_Event) return Distribution_Function;

   -----------------
   -- Sporadic Event
   -----------------

   type Sporadic_Event is new Aperiodic_Event with private;

   procedure Set_Min_Interarrival
     (Evnt : in out Sporadic_Event;
      The_Min_Interarrival : Time);
   function Min_Interarrival
     (Evnt : Sporadic_Event) return Time;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Sporadic_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Sporadic_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Evnt : Sporadic_Event)
     return Event_Ref;

   ----------------------------
   -- Unbounded Event
   ----------------------------

   type Unbounded_Event is new Aperiodic_Event with private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Unbounded_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Unbounded_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Evnt : Unbounded_Event)
     return Event_Ref;

   ----------------------------
   -- Bursty Event
   ----------------------------

   type Bursty_Event is new Aperiodic_Event with private;

   procedure Set_Bound_Interval
     (Evnt : in out Bursty_Event;
      The_Bound_Interval : Time);
   function Bound_Interval
     (Evnt : Bursty_Event) return Time;

   procedure Set_Max_Arrivals
     (Evnt : in out Bursty_Event;
      The_Max_Arrivals : Positive);
   function Max_Arrivals
     (Evnt : Bursty_Event) return Positive;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Bursty_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Bursty_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Evnt : Bursty_Event)
     return Event_Ref;

private

   type Event is abstract tagged record
      Name : Var_Strings.Var_String;
   end record;

   type Internal_Event is new Event with null record;

   type External_Event is abstract new Event with null record;

   type Periodic_Event is new External_Event with record
      Period,
      Max_Jitter : Time :=0.0;
      Phase : Absolute_Time:=0.0;
   end record;

   type Singular_Event is new External_Event with record
      Phase : Absolute_Time:=0.0;
   end record;

   type Aperiodic_Event is abstract new External_Event with record
      Avg_Interarrival : Time:=0.0;
      Distribution : Distribution_Function:=Uniform;
   end record;

   type Sporadic_Event is new Aperiodic_Event with record
      Min_Interarrival : Time:=0.0;
   end record;

   type Unbounded_Event is new Aperiodic_Event with null record;

   type Bursty_Event is new Aperiodic_Event with record
      Bound_Interval : Time:=0.0;
      Max_Arrivals : Positive:=1;
   end record;

end MAST.Events;
