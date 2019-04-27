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

with MAST.IO;
package body Mast.Shared_Resources is

   use type Results.Ceiling_Result_Ref;
   use type Results.Preemption_Level_Result_Ref;
   use type Results.Utilization_Result_Ref;
   use type Results.Queue_Size_Result_Ref;

   -------------
   -- Ceiling --
   -------------

   function Ceiling (Res : Immediate_Ceiling_Resource)
                    return Priority is
   begin
      return Res.Ceiling;
   end Ceiling;

   ----------------------
   -- Ceiling_Result   --
   ----------------------

   function Ceiling_Result
     (Sh_Res : Shared_Resource)
     return Results.Ceiling_Result_Ref
   is
   begin
      return Sh_Res.The_Ceiling_Result;
   end Ceiling_Result;

   -----------
   -- Clone --
   -----------

   function Clone
     (The_List : in Lists.List)
     return Lists.List
   is
      The_Copy : Lists.List;
      Iterator : Lists.Iteration_Object;
      Res_Ref, Res_Ref_Copy : Shared_Resource_Ref;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Res_Ref_Copy:=Clone(Res_Ref.all);
         Lists.Add(Res_Ref_Copy,The_Copy);
      end loop;
      return The_Copy;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Res : Priority_Inheritance_Resource)
     return  Shared_Resource_Ref
   is
      Res_Ref : Shared_Resource_Ref;
   begin
      Res_Ref:=new Priority_Inheritance_Resource'
        ((Name                        => Res.Name,
          The_Utilization_Result      => null,
          The_Queue_Size_Result       => null,
          The_Ceiling_Result          => null,
          The_Preemption_Level_Result => null));
      return Res_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Res : Immediate_Ceiling_Resource)
     return  Shared_Resource_Ref
   is
      Res_Ref : Shared_Resource_Ref;
   begin
      Res_Ref:=new Immediate_Ceiling_Resource'
        ((Name                        => Res.Name,
          The_Utilization_Result      => null,
          The_Queue_Size_Result       => null,
          The_Ceiling_Result          => null,
          The_Preemption_Level_Result => null,
          Ceiling                     => Res.Ceiling,
          Preassigned                 => Res.Preassigned));
      return Res_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Res : SRP_Resource)
     return  Shared_Resource_Ref
   is
      Res_Ref : Shared_Resource_Ref;
   begin
      Res_Ref:=new SRP_Resource'
        ((Name                        => Res.Name,
          The_Utilization_Result      => null,
          The_Queue_Size_Result       => null,
          The_Ceiling_Result          => null,
          The_Preemption_Level_Result => null,
          Level                       => Res.Level,
          Preassigned                 => Res.Preassigned));
      return Res_Ref;
   end Clone;

   ----------
   -- Init --
   ----------

   procedure Init
     (Res : in out Shared_Resource;
      Name : Var_Strings.Var_String)
   is
   begin
      Res.Name:=Name;
   end Init;

   -------------
   -- Level --
   -------------

   function Level (Res : SRP_Resource)
                  return Preemption_Level is
   begin
      return Res.Level;
   end Level;

   ----------
   -- Name --
   ----------

   function Name
     (Res : Shared_Resource)
     return Var_Strings.Var_String
   is
   begin
      return Res.Name;
   end Name;

   ----------
   -- Name --
   ----------

   function Name
     (Res_Ref : Shared_Resource_Ref)
     return Var_Strings.Var_String
   is
   begin
      return Res_Ref.Name;
   end Name;

   -----------------
   -- Preassigned --
   -----------------

   function Preassigned (Res : Immediate_Ceiling_Resource)
                        return Boolean is
   begin
      return Res.Preassigned;
   end Preassigned;

   -----------------
   -- Preassigned --
   -----------------

   function Preassigned (Res : SRP_Resource)
                        return Boolean is
   begin
      return Res.Preassigned;
   end Preassigned;

   -------------------------------
   -- Preemption_Level_Result   --
   -------------------------------

   function Preemption_Level_Result
     (Sh_Res : Shared_Resource)
     return Results.Preemption_Level_Result_Ref
   is
   begin
      return Sh_Res.The_Preemption_Level_Result;
   end Preemption_Level_Result;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Shared_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False) is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put_Line(File,"Shared_Resource (");
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Priority_Inheritance_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False) is
   begin
      Print(File,Shared_Resource(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Priority_Inheritance_Resource",Indentation+3,8);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Res.Name),Indentation+3,8);
      MAST.IO.Print_Separator(File,MAST.IO.Comma,Finalize);
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Immediate_Ceiling_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False) is
   begin
      Print(File,Shared_Resource(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Immediate_Ceiling_Resource",Indentation+3,11);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Res.Name),Indentation+3,11);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Ceiling",
         Priority'Image(Res.Ceiling),Indentation+3,11);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Preassigned",
         Mast.IO.Boolean_Image(Res.Preassigned),Indentation+3,11);
      MAST.IO.Print_Separator(File,MAST.IO.Comma,Finalize);
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out SRP_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 16;
   begin
      Print(File,Shared_Resource(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "SRP_Resource",Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Res.Name),Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Preemption_Level",
         Preemption_Level'Image(Res.Level),Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Preassigned",
         Mast.IO.Boolean_Image(Res.Preassigned),Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File,MAST.IO.Comma,Finalize);
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Shared_Resource_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print(File,Res_Ref.all,Indentation,True);
         Ada.Text_IO.New_Line(File);
      end loop;
   end Print;

   --------------------------------
   -- Print_results              --
   --------------------------------

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      Res : Shared_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant := 8;
      First_Item : Boolean:=True;
   begin
      -- Print only if there are results
      if Res.The_Ceiling_Result/=null or else
        Res.The_Preemption_Level_Result/=null or else
        Res.The_Utilization_Result/=null or else
        Res.The_Queue_Size_Result/=null
      then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put(File,"Shared_Resource (");
         MAST.IO.Print_Arg
           (File,"Name",
            IO.Name_Image(Res.Name),Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Results","",Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File,MAST.IO.Nothing);
         MAST.IO.Print_List_Item(File,MAST.IO.Left_Paren,
                                 Indentation+7);
         if Res.The_Ceiling_Result/=null then
            if not First_Item then
               MAST.IO.Print_Separator(File);
            end if;
            Results.Print(File,Res.The_Ceiling_Result.all,Indentation+8);
            First_Item:=False;
         end if;
         if Res.The_Preemption_Level_Result/=null then
            if not First_Item then
               MAST.IO.Print_Separator(File);
            end if;
            Results.Print(File,Res.The_Preemption_Level_Result.all,
                          Indentation+8);
            First_Item:=False;
         end if;
         if Res.The_Utilization_Result/=null then
            if not First_Item then
               MAST.IO.Print_Separator(File);
            end if;
            Results.Print(File,Res.The_Utilization_Result.all,Indentation+8);
            First_Item:=False;
         end if;
         if Res.The_Queue_Size_Result/=null then
            if not First_Item then
               MAST.IO.Print_Separator(File);
            end if;
            Results.Print
              (File,Res.The_Queue_Size_Result.all,Indentation+8);
            First_Item:=False;
         end if;
         Ada.Text_IO.Put(File,")");
         MAST.IO.Print_Separator(File,MAST.IO.Nothing,Finalize);
         Ada.Text_IO.New_Line(File);
      end if;
   end Print_Results;

   --------------------------------
   -- Print_Results              --
   --------------------------------

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Shared_Resource_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print_Results(File,Res_Ref.all,Indentation,True);
      end loop;
   end Print_Results;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Priority_Inheritance_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False) is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:Priority_Inheritance_Resource ");
      Ada.Text_Io.Put_Line(File,"Name=""" & IO.Name_Image(Res.Name) & """ />");
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Immediate_Ceiling_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False) is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:Immediate_Ceiling_Resource ");
      Ada.Text_Io.Put(File,"Name=""" & Io.Name_Image(Res.Name) & """ ");
      Ada.Text_Io.Put(File,"Ceiling=""" & IO.Priority_Image(Res.Ceiling) &
                      """ ");
      Ada.Text_Io.Put_Line
        (File,"Preassigned=""" &
         Mast.IO.Boolean_Image(Res.Preassigned) & """ />");
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out SRP_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False) is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_mdl:SRP_Resource ");
      Ada.Text_Io.Put(File,"Name=""" & Io.Name_Image(Res.Name) & """ ");
      Ada.Text_Io.Put
        (File,"Preemption_Level=""" &
         IO.Preemption_Level_Image(Res.Level) & """ ");
      Ada.Text_Io.Put_Line
        (File,"Preassigned=""" &
         Mast.IO.Boolean_Image(Res.Preassigned) & """ />");
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Shared_Resource_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print_XML(File,Res_Ref.all,Indentation,True);
         Ada.Text_IO.New_Line(File);
      end loop;
   end Print_XML;

   --------------------------------
   -- Print__XML_Results         --
   --------------------------------

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      Res : Shared_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant := 8;
      First_Item : Boolean:=True;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put(File,"<mast_res:Shared_Resource ");
      Ada.Text_Io.Put(File,"Name=""" & Io.Name_Image(Res.Name) & """ >");
      if Res.The_Utilization_Result/=null then
         Results.Print_XML(File,Res.The_Utilization_Result.all,Indentation+8);
         First_Item:=False;
      end if;
      if Res.The_Queue_Size_Result/=null then
         Results.Print_XML(File,Res.The_Queue_Size_Result.all,Indentation+8);
         First_Item:=False;
      end if;
       if Res.The_Ceiling_Result/=null then
          Results.Print_XML(File,Res.The_Ceiling_Result.all,Indentation+8);
       end if;
       if Res.The_Preemption_Level_Result/=null then
          Results.Print_XML
            (File,Res.The_Preemption_Level_Result.all,Indentation+8);
       end if;
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put_Line(File,"</mast_res:Shared_Resource>");
   end Print_XML_Results;

   --------------------------------
   -- Print_XML_Results          --
   --------------------------------

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Shared_Resource_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print_XML_Results(File,Res_Ref.all,Indentation,True);
      end loop;
   end Print_XML_Results;

   ---------------------------------
   -- QueueSize_Result     --
   ---------------------------------

   function Queue_Size_Result
     (Sh_Res : Shared_Resource)
     return Results.Queue_Size_Result_Ref
   is
   begin
      return Sh_Res.The_Queue_Size_Result;
   end Queue_Size_Result;

   -----------------
   -- Set_Ceiling --
   -----------------

   procedure Set_Ceiling
     (Res : in out Immediate_Ceiling_Resource;
      New_Ceiling : Priority)
   is
   begin
      Res.Ceiling:=New_Ceiling;
   end Set_Ceiling;

   ------------------------
   -- Set_Ceiling_Result --
   ------------------------

   procedure Set_Ceiling_Result
     (Sh_Res : in out Shared_Resource;
      Res : Results.Ceiling_Result_Ref)
   is
   begin
      Sh_Res.The_Ceiling_Result:=Res;
   end Set_Ceiling_Result;

   -----------------
   -- Set_Level --
   -----------------

   procedure Set_Level
     (Res : in out SRP_Resource;
      New_Level : Preemption_Level)
   is
   begin
      Res.Level:=New_Level;
   end Set_Level;

   ---------------------
   -- Set_Preassigned --
   ---------------------

   procedure Set_Preassigned
     (Res : in out Immediate_Ceiling_Resource;
      Is_Preassigned : Boolean)
   is
   begin
      Res.Preassigned:=Is_Preassigned;
   end Set_Preassigned;

   ---------------------
   -- Set_Preassigned --
   ---------------------

   procedure Set_Preassigned
     (Res : in out SRP_Resource;
      Is_Preassigned : Boolean)
   is
   begin
      Res.Preassigned:=Is_Preassigned;
   end Set_Preassigned;

   -----------------------------------
   -- Set_Preemption_Level_Result   --
   -----------------------------------

   procedure Set_Preemption_Level_Result
     (Sh_Res : in out Shared_Resource;
      Res : Results.Preemption_Level_Result_Ref)
   is
   begin
      Sh_Res.The_Preemption_Level_Result :=Res;
   end Set_Preemption_Level_Result;

   ---------------------------------
   -- Set_Queue_Size_Result --
   ---------------------------------

   procedure Set_Queue_Size_Result
     (Sh_Res : in out Shared_Resource;
      Res : Results.Queue_Size_Result_Ref)
   is
   begin
      Sh_Res.The_Queue_Size_Result:=Res;
   end Set_Queue_Size_Result;

   ----------------------------
   -- Set_Utilization_Result --
   ----------------------------

   procedure Set_Utilization_Result
     (Sh_Res : in out Shared_Resource;
      Res : Results.Utilization_Result_Ref)
   is
   begin
      Sh_Res.The_Utilization_Result:=Res;
   end Set_Utilization_Result;

   ------------------------
   -- Utilization_Result --
   ------------------------

   function Utilization_Result
     (Sh_Res : Shared_Resource)
     return Results.Utilization_Result_Ref
   is
   begin
      return Sh_Res.The_Utilization_Result;
   end Utilization_Result;

end Mast.Shared_Resources;
