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
package Mast.Synchronization_Parameters is

   type Synch_Parameters is abstract tagged private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Synch_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False);

  procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Synch_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl") is abstract;

   type Synch_Parameters_Ref is access Synch_Parameters'Class;

   function Clone
     (Parameters : Synch_Parameters)
     return  Synch_Parameters_Ref is abstract;

   --------------------------------------
   -- Stack_Resource_Protocol_Parameters
   --------------------------------------

   type SRP_Parameters is new Synch_Parameters with private;

   procedure Set_Preemption_Level
     (Parameters : in out SRP_Parameters;
      Level      : Preemption_Level);
   function The_Preemption_Level
     (Parameters : SRP_Parameters) return Preemption_Level;

   procedure Set_Preassigned
     (Parameters : in out SRP_Parameters;
      Is_Preassigned : Boolean);
   function Preassigned
     (Parameters : SRP_Parameters) return Boolean;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out SRP_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False);

  procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out SRP_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl");

   function Clone
     (Parameters : SRP_Parameters)
     return  Synch_Parameters_Ref;

private

   type Synch_Parameters is abstract tagged null record;

   type SRP_Parameters is new Synch_Parameters with
      record
         The_Level : Preemption_Level:=Preemption_Level'First;
         Preassigned : Boolean:=False;
      end record;

end Mast.Synchronization_Parameters;
