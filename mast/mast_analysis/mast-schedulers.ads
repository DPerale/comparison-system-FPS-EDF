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

with Ada.Text_IO,Var_Strings, Named_Lists, Mast.Scheduling_Policies,
  Mast.Processing_Resources;

package Mast.Schedulers is

   type Scheduler is abstract tagged private;

   procedure Init
     (Sch : in out Scheduler;
      Name : Var_Strings.Var_String);

   function Name
     (Sch : Scheduler )
     return Var_Strings.Var_String;

   procedure Set_Scheduling_Policy
     (Sch : in out Scheduler;
      The_Policy : Mast.Scheduling_Policies.Scheduling_Policy_Ref);
   function Scheduling_Policy
     (Sch : Scheduler)
     return Mast.Scheduling_Policies.Scheduling_Policy_Ref;

   function Max_Priority
     (Sch : Scheduler) return Priority is abstract;
   function Min_Priority
     (Sch : Scheduler) return Priority is abstract;

   function Host
     (Sch : Scheduler)
     return Mast.Processing_Resources.Processing_Resource_Ref is abstract;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Sch : in out Scheduler;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Sch : in out Scheduler;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   type Scheduler_Ref is access Scheduler'Class;

   function Clone
     (Sch : Scheduler)
     return  Scheduler_Ref is abstract;

   function Name
     (Sch_Ref : Scheduler_Ref )
     return Var_Strings.Var_String;

   package Lists is new Named_Lists
     (Element => Scheduler_Ref,
      Name    => Name);

   function Clone
     (The_List : in Lists.List)
     return Lists.List;
   -- needs adjustment after clonning

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive);

   function List_References_Processing_Resource
     (Pr_Ref : Mast.Processing_Resources.Processing_Resource_Ref;
      The_List : Lists.List)
     return Boolean;
     -- indicates whether the list contains primary schedulers with
     -- a reference to the
     -- processing resource pointed to by Pr_Ref or not


private

   type Scheduler is abstract tagged
      record
         Name : Var_Strings.Var_String;
         Policy : Scheduling_Policies.Scheduling_Policy_Ref;
      end record;

end Mast.Schedulers;
