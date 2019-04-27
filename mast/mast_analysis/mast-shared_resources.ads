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

with MAST.Results, Ada.Text_IO,Var_Strings, Named_Lists;

package Mast.Shared_Resources is

   type Shared_Resource is abstract tagged private;

   procedure Init (Res : in out Shared_Resource;
                   Name : Var_Strings.Var_String);

   function Name (Res : Shared_Resource )
                 return Var_Strings.Var_String;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Shared_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Shared_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   procedure Set_Utilization_Result
     (Sh_Res : in out Shared_Resource;
      Res : Results.Utilization_Result_Ref);

   function Utilization_Result
     (Sh_Res : Shared_Resource)
     return Results.Utilization_Result_Ref;

   procedure Set_Queue_Size_Result
     (Sh_Res : in out Shared_Resource;
      Res : Results.Queue_Size_Result_Ref);

   function Queue_Size_Result
     (Sh_Res : Shared_Resource)
     return Results.Queue_Size_Result_Ref;

   procedure Set_Ceiling_Result
     (Sh_Res : in out Shared_Resource;
      Res : Results.Ceiling_Result_Ref);

   function Ceiling_Result
     (Sh_Res : Shared_Resource)
     return Results.Ceiling_Result_Ref;

   procedure Set_Preemption_Level_Result
     (Sh_Res : in out Shared_Resource;
      Res : Results.Preemption_Level_Result_Ref);

   function Preemption_Level_Result
     (Sh_Res : Shared_Resource)
     return Results.Preemption_Level_Result_Ref;

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      Res  : Shared_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      Res  : Shared_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   type Shared_Resource_Ref is access Shared_Resource'Class;

   function Clone
     (Res : Shared_Resource)
     return  Shared_Resource_Ref is abstract;

   function Name (Res_Ref : Shared_Resource_Ref )
                 return Var_Strings.Var_String;

   package Lists is new Named_Lists
     (Element => Shared_Resource_Ref,
      Name    => Name);

   function Clone
     (The_List : in Lists.List)
     return Lists.List;

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

   -----------------------
   -- Priority Inheritance
   -----------------------

   type Priority_Inheritance_Resource is
     new Shared_Resource with private;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Priority_Inheritance_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Priority_Inheritance_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Res : Priority_Inheritance_Resource)
     return  Shared_Resource_Ref;

   ----------------------------
   -- Immediate Ceiling Resource
   ----------------------------

   type Immediate_Ceiling_Resource is new Shared_Resource
     with private;

   procedure Set_Ceiling
     (Res : in out Immediate_Ceiling_Resource;
      New_Ceiling : Priority);
   function Ceiling
     (Res : Immediate_Ceiling_Resource)
     return Priority;

   procedure Set_Preassigned
     (Res : in out Immediate_Ceiling_Resource;
      Is_Preassigned : Boolean);
   function Preassigned
     (Res : Immediate_Ceiling_Resource)
     return Boolean;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Immediate_Ceiling_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Immediate_Ceiling_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Res : Immediate_Ceiling_Resource)
     return  Shared_Resource_Ref;

   ----------------------------
   -- Stack Resource Policy
   ----------------------------

   type SRP_Resource is new Shared_Resource
     with private;

   procedure Set_Level
     (Res : in out SRP_Resource;
      New_Level : Preemption_Level);
   function Level
     (Res : SRP_Resource)
     return Preemption_Level;

   procedure Set_Preassigned
     (Res : in out SRP_Resource;
      Is_Preassigned : Boolean);
   function Preassigned
     (Res : SRP_Resource)
     return Boolean;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out SRP_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out SRP_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Res : SRP_Resource)
     return  Shared_Resource_Ref;


private

   type Shared_Resource is abstract tagged record
      Name : Var_Strings.Var_String;
      The_Utilization_Result : Results.Utilization_Result_Ref;
      The_Queue_Size_Result : Results.Queue_Size_Result_Ref;
      The_Ceiling_Result : Results.Ceiling_Result_Ref;
      The_Preemption_Level_Result : Results.Preemption_Level_Result_Ref;
   end record;

   type Immediate_Ceiling_Resource is new Shared_Resource with record
      Ceiling : Priority:=Priority'Last;
      Preassigned : Boolean:=False;
   end record;

   type Priority_Inheritance_Resource is
     new Shared_Resource with null record;

   type SRP_Resource is new Shared_Resource with record
      Level : Preemption_Level:=Preemption_Level'Last;
      Preassigned : Boolean:=False;
   end record;

end Mast.Shared_Resources;
