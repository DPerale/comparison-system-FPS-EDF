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
--          Julio Medina Pasaje    medinajl@unican.es                --
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

package body Mast.Processing_Resources is

   use type Results.Slack_Result_Ref;
   use type Results.Utilization_Result_Ref;
   use type Results.Ready_Queue_Size_Result_Ref;

   -----------
   -- Clone --
   -----------

   function Clone
     (The_List : in Lists.List)
     return Lists.List
   is
      The_Copy : Lists.List;
      Iterator : Lists.Iteration_Object;
      Res_Ref, Res_Ref_Copy : Processing_Resource_Ref;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Res_Ref_Copy:=Clone(Res_Ref.all);
         Lists.Add(Res_Ref_Copy,The_Copy);
      end loop;
      return The_Copy;
   end Clone;

   --------------------------------
   -- Has_Scheduler              --
   --------------------------------

   function Has_Scheduler
     (Proc_Res : Processing_Resource)
     return Boolean
   is
   begin
      return Proc_Res.Scheduler_Present;
   end Has_Scheduler;

   ----------
   -- Init --
   ----------

   procedure Init
     (Res : in out Processing_Resource;
      Name : Var_Strings.Var_String)
   is
   begin
      Res.Name:=Name;
   end Init;

   ----------
   -- Name --
   ----------

   function Name
     (Res : Processing_Resource)
     return Var_Strings.Var_String
   is
   begin
      return Res.Name;
   end Name;

   ----------
   -- Name --
   ----------

   function Name
     (Res_Ref : Processing_Resource_Ref)
     return Var_Strings.Var_String
   is
   begin
      return Res_Ref.Name;
   end Name;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Processing_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False) is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"Processing_Resource (");
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Processing_Resource_Ref;
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
   -- Print_Results              --
   --------------------------------

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      Res : Processing_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant := 8;
      First_Item : Boolean:=True;
   begin
      -- Print only if there are results
      if Res.The_Slack_Result/=null or else
        Res.The_Utilization_Result/=null or else
        Res.The_Ready_Queue_Size_Result/=null
      then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put(File,"Processing_Resource (");
         MAST.IO.Print_Arg
           (File,"Name",
            IO.Name_Image(Res.Name),Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Results","",Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File,MAST.IO.Nothing);
         MAST.IO.Print_List_Item(File,MAST.IO.Left_Paren,
                                 Indentation+7);
         if Res.The_Slack_Result/=null then
            Results.Print(File,Res.The_Slack_Result.all,Indentation+8);
            First_Item:=False;
         end if;
         if Res.The_Utilization_Result/=null then
            if not First_Item then
               MAST.IO.Print_Separator(File);
            end if;
            Results.Print(File,Res.The_Utilization_Result.all,Indentation+8);
            First_Item:=False;
         end if;
         if Res.The_Ready_Queue_Size_Result/=null then
            if not First_Item then
               MAST.IO.Print_Separator(File);
            end if;
            Results.Print
              (File,Res.The_Ready_Queue_Size_Result.all,Indentation+8);
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
      Res_Ref : Processing_Resource_Ref;
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
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Processing_Resource_Ref;
      Iterator : LIsts.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print_Xml(File,Res_Ref.all,Indentation,True);
      end loop;
   end Print_XML;

   --------------------------------
   -- Print_XML_results              --
   --------------------------------

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      Res : Processing_Resource;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant := 8;
      First_Item : Boolean:=True;
   begin
      -- Print only if there are results
      if Res.The_Slack_Result/=null or else
        Res.The_Utilization_Result/=null or else
        Res.The_Ready_Queue_Size_Result/=null
      then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put_Line
           (File,"<mast_res:Processing_Resource Name="""&
            IO.Name_Image(Res.Name)&""">");
         if Res.The_Slack_Result/=null then
            Results.Print_XML
              (File,Res.The_Slack_Result.all,Indentation+3,False);
         end if;
         if Res.The_Utilization_Result/=null then
            Results.Print_XML
              (File,Res.The_Utilization_Result.all,Indentation+3,False);
         end if;
         if Res.The_Ready_Queue_Size_Result/=null then
            Results.Print_XML
              (File,Res.The_Ready_Queue_Size_Result.all,Indentation+3,False);
         end if;
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put_Line(File,"</mast_res:Processing_Resource>");
      end if;
   end Print_XML_Results;

   --------------------------------
   -- Print_XML_Results          --
   --------------------------------

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Processing_Resource_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print_XML_Results(File,Res_Ref.all,Indentation,True);
      end loop;
   end Print_XML_Results;

   ---------------------------------
   -- Ready_Queue_Size_Result     --
   ---------------------------------

   function Ready_Queue_Size_Result
     (Proc_Res : Processing_Resource)
     return Results.Ready_Queue_Size_Result_Ref
   is
   begin
      return Proc_Res.The_Ready_Queue_Size_Result;
   end Ready_Queue_Size_Result;

   -----------
   -- Scale --
   -----------
   -- multiplies the original processor speed by the The_Factor

   procedure Scale (Res : in out Processing_Resource;
                    The_Factor : Processor_Speed)
   is
   begin
      Res.Speed_Factor:=The_Factor*Res.Original_Speed_Factor;
   end Scale;

   --------------------------------
   -- Set_Scheduler_State        --
   --------------------------------

   procedure Set_Scheduler_State
     (Proc_Res : in out Processing_Resource;
      Has_Scheduler : in Boolean)
   is
   begin
      Proc_Res.Scheduler_Present:=Has_Scheduler;
   end Set_Scheduler_State;

   ---------------------------------
   -- Set_Ready_Queue_Size_Result --
   ---------------------------------

   procedure Set_Ready_Queue_Size_Result
     (Proc_Res : in out Processing_Resource;
      Res : Results.Ready_Queue_Size_Result_Ref)
   is
   begin
      Proc_Res.The_Ready_Queue_Size_Result:=Res;
   end Set_Ready_Queue_Size_Result;

   ------------------------------------
   -- Set_Speed_Factor --
   ------------------------------------

   procedure Set_Speed_Factor (Res : in out Processing_Resource;
                               The_Speed_Factor : Processor_Speed)
   is
   begin
      Res.Speed_Factor:=The_Speed_Factor;
      Res.Original_Speed_Factor:=The_Speed_Factor;
   end Set_Speed_Factor;

   ----------------------
   -- Set_Slack_Result --
   ----------------------

   procedure Set_Slack_Result
     (Proc_Res : in out Processing_Resource;
      Res : Results.Slack_Result_Ref)
   is
   begin
      Proc_Res.The_Slack_Result:=Res;
   end Set_Slack_Result;

   ----------------------------
   -- Set_Utilization_Result --
   ----------------------------

   procedure Set_Utilization_Result
     (Proc_Res : in out Processing_Resource;
      Res : Results.Utilization_Result_Ref)
   is
   begin
      Proc_Res.The_Utilization_Result:=Res;
   end Set_Utilization_Result;

   ----------------------
   -- Slack_Result     --
   ----------------------

   function Slack_Result
     (Proc_Res : Processing_Resource)
     return Results.Slack_Result_Ref
   is
   begin
      return Proc_Res.The_Slack_Result;
   end Slack_Result;

   ------------------------------------
   -- Speed_Factor --
   ------------------------------------

   function Speed_Factor (Res : Processing_Resource)
                         return Processor_Speed
   is
   begin
      return Res.Speed_Factor;
   end Speed_Factor;

   ------------------------
   -- Utilization_Result --
   ------------------------

   function Utilization_Result
     (Proc_Res : Processing_Resource)
     return Results.Utilization_Result_Ref
   is
   begin
      return Proc_Res.The_Utilization_Result;
   end Utilization_Result;

end Mast.Processing_Resources;
