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

with Mast.Results, Ada.Text_IO,Var_Strings, Named_Lists;

package Mast.Processing_Resources is

   type Processing_Resource is abstract tagged private;

   procedure Init (Res : in out Processing_Resource;
                   Name : Var_Strings.Var_String);

   function Name (Res : Processing_Resource )
                 return Var_Strings.Var_String;

   procedure Set_Speed_Factor (Res : in out Processing_Resource;
                               The_Speed_Factor : Processor_Speed);
   function Speed_Factor (Res : Processing_Resource)
                         return Processor_Speed;

   procedure Scale (Res : in out Processing_Resource;
                    The_Factor : Processor_Speed);
   -- multiplies the original processor speed by the The_Factor

   procedure Set_Slack_Result
     (Proc_Res : in out Processing_Resource;
      Res : Results.Slack_Result_Ref);

   function Slack_Result
     (Proc_Res : Processing_Resource)
     return Results.Slack_Result_Ref;

   procedure Set_Utilization_Result
     (Proc_Res : in out Processing_Resource;
      Res : Results.Utilization_Result_Ref);

   function Utilization_Result
     (Proc_Res : Processing_Resource)
     return Results.Utilization_Result_Ref;

   procedure Set_Ready_Queue_Size_Result
     (Proc_Res : in out Processing_Resource;
      Res : Results.Ready_Queue_Size_Result_Ref);

   function Ready_Queue_Size_Result
     (Proc_Res : Processing_Resource)
     return Results.Ready_Queue_Size_Result_Ref;

   procedure Set_Scheduler_State
     (Proc_Res : in out Processing_Resource;
      Has_Scheduler : in Boolean);

   function Has_Scheduler
     (Proc_Res : Processing_Resource)
     return Boolean;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Processing_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Processing_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      Res  : Processing_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      Res  : Processing_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   type Processing_Resource_Ref is access all Processing_Resource'Class;

   function Clone
     (Res : Processing_Resource)
     return  Processing_Resource_Ref is abstract;

   function Name (Res_Ref : Processing_Resource_Ref )
                 return Var_Strings.Var_String;

   package Lists is new Named_Lists
     (Element => Processing_Resource_Ref,
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

private

   type Processing_Resource is abstract tagged
      record
         Name : Var_Strings.Var_String;
         Speed_Factor : Processor_Speed:=1.0;
         Original_Speed_Factor : Processor_Speed:=1.0;
         The_Slack_Result : Results.Slack_Result_Ref;
         The_Utilization_Result : Results.Utilization_Result_Ref;
         The_Ready_Queue_Size_Result : Results.Ready_Queue_Size_Result_Ref;
         Scheduler_Present : Boolean:=False;
      end record;

end Mast.Processing_Resources;
