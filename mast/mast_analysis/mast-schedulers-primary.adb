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

with MAST.IO;
package body Mast.Schedulers.Primary is

   use type Mast.Scheduling_Policies.Scheduling_Policy_Ref;
   use type Mast.Processing_Resources.Processing_Resource_Ref;
   use type Mast.Processing_Resources.Lists.Index;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (Sch : in out Primary_Scheduler;
      Proc_List : in Processing_Resources.Lists.List)
   is
      The_Index : Processing_Resources.Lists.Index;
   begin
      if Sch.Host/=null then
         The_Index:=Processing_Resources.Lists.Find
           (Processing_Resources.Name(Sch.Host),
            Proc_List);
         if The_Index=Processing_Resources.Lists.Null_Index then
            Set_Exception_Message
              ("Error in Primary_Scheduler "&Var_Strings.To_String(Sch.Name)&
               ": Processing_Resource "&
               Var_Strings.To_String(Processing_Resources.Name(Sch.Host))&
               " not found");
            raise Object_Not_Found;
         else
            Sch.Host:=Processing_Resources.Lists.Item(The_Index,Proc_List);
         end if;
      end if;
   end Adjust;

   ------------------
   -- Max_Priority --
   ------------------

   function Max_Priority
     (Sch : Primary_Scheduler) return Priority
   is
   begin
      if Sch.Policy.all in Scheduling_Policies.Fixed_Priority_Policy'Class
      then
         return Scheduling_Policies.Max_Priority
           (Scheduling_Policies.Fixed_Priority_Policy'Class(Sch.Policy.all));
      else
         return Priority'First;
      end if;
   end Max_Priority;

   ------------------
   -- Min_Priority --
   ------------------

   function Min_Priority
     (Sch : Primary_Scheduler) return Priority
   is
   begin
      if Sch.Policy.all in Scheduling_Policies.Fixed_Priority_Policy'Class
      then
         return Scheduling_Policies.Min_Priority
           (Scheduling_Policies.Fixed_Priority_Policy'Class(Sch.Policy.all));
      else
         return Priority'First;
      end if;
   end Min_Priority;

   --------------
   -- Set_Host --
   --------------

   procedure Set_Host
     (Sch : in out Primary_Scheduler;
      The_Host: Mast.Processing_Resources.Processing_Resource_Ref)
   is
   begin
      if Sch.Host/=null then
         Processing_Resources.Set_Scheduler_State(Sch.Host.all,False);
      end if;
      Sch.Host := The_Host;
      Processing_Resources.Set_Scheduler_State(The_Host.all,True);
   end Set_Host;

   ----------
   -- Host --
   ----------

   function Host
     (Sch : Primary_Scheduler)
     return Mast.Processing_Resources.Processing_Resource_Ref
   is
   begin
      return Sch.Host;
   end Host;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Sch : in out Primary_Scheduler;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Name_Length : constant := 15;
   begin
      Print(File, Scheduler(Sch),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Primary_Scheduler",Indentation+3,Name_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Sch.Name),Indentation+3,Name_Length);
      if Sch.Host/=null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Host",
            IO.Name_Image(Mast.Processing_Resources.Name(Sch.Host)),
            Indentation+3,Name_Length);
      end if;
      if Sch.Policy /= null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Policy","",
            Indentation+3,Name_Length);
         Mast.Scheduling_Policies.Print(File,Sch.Policy.all,Indentation+6);
      end if;
      MAST.IO.Print_Separator(File,",",Finalize);
   end Print;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Sch : in out Primary_Scheduler;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Name_Length : constant := 15;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:Primary_Scheduler ");
      Ada.Text_IO.Put(File,"Name=""" & IO.Name_Image(Sch.Name) & """ ");
      if Sch.Host/=null then
         Ada.Text_IO.Put
           (File,"Host=""" &
            IO.Name_Image(Mast.Processing_Resources.Name(Sch.Host)) & """ ");
      end if;
      Ada.Text_IO.Put_Line(File," >");
      if Sch.Policy /= null then
         Mast.Scheduling_Policies.Print_XML
           (File,Sch.Policy.all,Indentation+3,False);
      end if;
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put_Line(File,"</mast_mdl:Primary_Scheduler> ");
   end Print_XML;

   ------------
   -- Clone  --
   ------------

   function Clone
     (Sch : Primary_Scheduler)
     return  Scheduler_Ref
   is
      Sch_Ref : Scheduler_Ref;
   begin
      Sch_Ref:=new Primary_Scheduler'(Sch);
      return Sch_Ref;
   end Clone;

end Mast.Schedulers.Primary;
