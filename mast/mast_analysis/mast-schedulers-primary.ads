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

with Ada.Text_IO,
  Mast.Processing_Resources;

package Mast.Schedulers.Primary is

   type Primary_Scheduler is new Scheduler with private;

   procedure Set_Host
     (Sch : in out Primary_Scheduler;
      The_Host: Mast.Processing_Resources.Processing_Resource_Ref);

   function Host
     (Sch : Primary_Scheduler)
     return Mast.Processing_Resources.Processing_Resource_Ref;

   function Max_Priority
     (Sch : Primary_Scheduler) return Priority;
   function Min_Priority
     (Sch : Primary_Scheduler) return Priority;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Sch : in out Primary_Scheduler;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Sch : in out Primary_Scheduler;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Sch : Primary_Scheduler)
     return  Scheduler_Ref;

   procedure Adjust
     (Sch : in out Primary_Scheduler;
      Proc_List : in Processing_Resources.Lists.List);
   -- To adjust internal pointers to pint to objects in Proc_List
   -- it may raise Object_Not_Found

   type Primary_Scheduler_Ref is access all Primary_Scheduler'Class;

private

   type Primary_Scheduler is new Scheduler with
      record
         Host: Mast.Processing_Resources.Processing_Resource_Ref;
      end record;

end Mast.Schedulers.Primary;
