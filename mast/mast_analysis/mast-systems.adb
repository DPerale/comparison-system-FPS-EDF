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

with Ada.Text_IO,Mast.Processing_Resources.Network,
  Mast.Schedulers.Primary,
  Mast.Schedulers.Adjustment;

package body Mast.Systems is

   use type Results.Slack_Result_Ref;
   use type Results.Trace_Result_Ref;
   use type Processing_Resources.Processing_Resource_Ref;

   ------------
   -- Adjust --
   ------------

   procedure Adjust(The_System : in out System) is
   begin
      -- shared resources need no adjustment

      -- rearrange all the internal pointers in operations
      Operations.Adjust(The_System.Operations,The_System.Shared_Resources);

      -- rearrange all the internal pointers in scheduling servers
      Scheduling_Servers.Adjust(The_System.Scheduling_Servers,
                                The_System.Schedulers);

      -- rearrange all the internal pointers in network drivers:
      Processing_Resources.Network.Adjust
        (The_System.Processing_Resources,The_System.Scheduling_Servers,
         The_System.Operations);

      -- rearrange all the internal pointers in schedulers:
      Schedulers.Adjustment.Adjust
        (The_System.Schedulers,The_System.Processing_Resources,
         The_System.Scheduling_Servers);

      -- rearrange all the internal pointers in transactions:
      --       timing requirements, links, event handlers
      Transactions.Adjust
        (The_System.Transactions,The_System.Scheduling_Servers,
         The_System.Operations);
end Adjust;

   -----------
   -- Clone --
   -----------

   function Clone(The_System : System) return System
   is
      The_Copy : System;
   begin
      -- Clone the basic objects.
      -- Internal pointers will continue pointing at the old system
      The_Copy:=
        (Model_Name           => The_System.Model_Name,
         Model_Date           => The_System.Model_Date,
         System_Pip_Behaviour  => The_System.System_Pip_Behaviour,
         Generation_Tool      => The_System.Generation_Tool,
         Generation_Profile   => The_System.Generation_Profile,
         Generation_Date      => The_System.Generation_Date,
         Processing_Resources =>
           Processing_Resources.Clone(The_System.Processing_Resources),
         Schedulers =>
           Schedulers.Clone(The_System.Schedulers),
         Shared_Resources     =>
           Shared_Resources.Clone(The_System.Shared_Resources),
         Operations           =>
           Operations.Clone(The_System.Operations),
         Transactions         =>
           Transactions.Clone(The_System.Transactions),
         Scheduling_Servers   =>
           Scheduling_Servers.Clone(The_System.Scheduling_Servers),
         The_Slack_Result     => null,
         The_Trace_Result     => null);

      Adjust(The_Copy);

      return The_Copy;

   end Clone;


   ---------------
   -- Is_In_Use --
   ---------------

   function Is_In_Use
     (Proc_Ref : Mast.Processing_Resources.Processing_Resource_Ref;
      Sys : in System)
     return Boolean
   is
      Sch_Ref : Schedulers.Scheduler_Ref;
      Iterator : Schedulers.Lists.Index;
   begin
      -- check whether the processing resource is being used in a
      -- primary scheduler in the system
      Schedulers.Lists.Rewind(Sys.Schedulers,Iterator);
      for I in 1..Schedulers.Lists.Size(Sys.Schedulers) loop
         Schedulers.Lists.Get_Next_Item(Sch_Ref,Sys.Schedulers,Iterator);
         if Sch_Ref.all in Schedulers.Primary.Primary_Scheduler'Class and then
           Schedulers.Primary.Host
           (Schedulers.Primary.Primary_Scheduler'Class(Sch_Ref.all))=Proc_Ref
         then
            return True;
         end if;
      end loop;
      return False; -- not being used
   end Is_In_Use;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_System : in out System;
      Indentation : Positive:=1)
   is
      Name_Length : constant := 19;
      First_Arg : Boolean:=True;
   begin
      if The_System.Model_Name/=Null_Var_String or
        The_System.Model_Date/="                   " or
        The_System.System_Pip_Behaviour /=Strict
      then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put(File,"Model (");
         if The_System.Model_Name/=Null_Var_String then
            MAST.IO.Print_Arg
              (File,"Model_Name",
               IO.Name_Image(The_System.Model_Name),Indentation+3,Name_Length);
            First_Arg:=False;
         end if;
         if The_System.Model_Date/="                   " then
            if not First_Arg then
               MAST.IO.Print_Separator(File);
            end if;
            MAST.IO.Print_Arg
              (File,"Model_Date",MAST.IO.Date_Image(The_System.Model_Date),
               Indentation+3,Name_Length);
            First_Arg:=False;
         end if;
         if not First_Arg then
            MAST.IO.Print_Separator(File);
         end if;
         MAST.IO.Print_Arg
           (File,"System_Pip_Behaviour",
            Pip_Behaviour'Image(The_System.System_Pip_Behaviour),
            Indentation+3,Name_Length);
         MAST.IO.Print_Separator(File,",",True);
         Ada.Text_IO.New_Line(File);
      end if;
      MAST.Processing_Resources.Print
        (File,The_System.Processing_Resources,Indentation);
      MAST.Schedulers.Print
        (File,The_System.Schedulers, Indentation);
      MAST.Scheduling_Servers.Print
        (File,The_System.Scheduling_Servers,Indentation);
      MAST.Shared_Resources.Print
        (File,The_System.Shared_Resources,Indentation);
      MAST.Operations.Print
        (File,The_System.Operations,Indentation);
      MAST.Transactions.Print
        (File,The_System.Transactions,Indentation);
   end Print;

   -------------------
   -- Print_Results --
   -------------------

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      The_System : in out System;
      Indentation : Positive:=1)
   is
      Names_Length : constant := 18;
   begin

      -- Print system-specific results

      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"Real_Time_Situation (");
      if The_System.Model_Name/=Null_Var_String then
         MAST.IO.Print_Arg
           (File,"Model_Name",
            IO.Name_Image(The_System.Model_Name),Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File);
      end if;
      if The_System.Model_Date/="                   " then
         MAST.IO.Print_Arg
           (File,"Model_Date",
            IO.Date_Image(The_System.Model_Date),Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File);
      end if;
      MAST.IO.Print_Arg
        (File,"Generation_Tool",
         """"&To_String(The_System.Generation_Tool)&"""",
         Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Generation_Profile",
         """"&To_String(The_System.Generation_Profile)&"""",
         Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Generation_Date",
         MAST.IO.Date_Image(The_System.Generation_Date),
         Indentation+3,Names_Length);
      if The_System.The_Trace_Result/=null or else
        The_System.The_Slack_Result/=null
      then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Results","",Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File,MAST.IO.Nothing);
         MAST.IO.Print_List_Item(File,MAST.IO.Left_Paren,
                                 Indentation+7);
         if The_System.The_Slack_Result/=null then
            Results.Print(File,The_System.The_Slack_Result.all,Indentation+8);
            if The_System.The_Trace_Result/=null then
               MAST.IO.Print_Separator(File);
            end if;
         end if;
         if The_System.The_Trace_Result/=null then
            Results.Print(File,The_System.The_Trace_Result.all,Indentation+8);
         end if;
         Ada.Text_IO.Put(File,")");
      end if;
      MAST.IO.Print_Separator(File,MAST.IO.Nothing,True);
      Ada.Text_IO.New_Line(File);

      -- Now print rest of results

      MAST.Transactions.Print_Results
        (File,The_System.Transactions,Indentation);

      MAST.Processing_Resources.Print_Results
        (File,The_System.Processing_Resources,Indentation);

      MAST.Operations.Print_Results
        (File,The_System.Operations,Indentation);

      MAST.Shared_Resources.Print_Results
        (File,The_System.Shared_Resources,Indentation);

      MAST.Scheduling_Servers.Print_Results
        (File,The_System.Scheduling_Servers,Indentation);

   end Print_Results;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_System : in out System;
      Indentation : Positive:=1)
   is

   begin
      Ada.Text_IO.Put_Line
        (File,"<?xml version="&"""1.0"" encoding=""UTF-8""?>");
      Ada.Text_IO.Put_Line
        (File,"<?mast fileType=""XML-Mast-Model-File"" version=""1.1""?>");
      Ada.Text_IO.Put_Line(File,"<mast_mdl:MAST_MODEL ");
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
      Ada.Text_IO.Put_Line
        (File,"xmlns:mast_mdl=""http://mast.unican.es/xmlmast/model"" ");
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
      Ada.Text_IO.Put_Line
        (File,"xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" ");
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
      Ada.Text_IO.Put_Line
        (File,"xsi:schemaLocation=""http://mast.unican.es/xmlmast/model "&
         "Mast_Model.xsd"" ");
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
      if The_System.Model_Name=Null_Var_String then
         Ada.Text_IO.Put_Line
           (File,"Model_Name=""Unknown"" " );
      else
         Ada.Text_IO.Put_Line
           (File,"Model_Name=""" &
            IO.Name_Image(The_System.Model_Name) &""" " );
      end if;
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
      if The_System.Model_Date="                   " then
         Ada.Text_IO.Put_Line
           (File,"Model_Date=""" &
            MAST.IO.Today& """>");
      elsif MAST.IO.Date_Image(The_System.Model_Date)'Length<11 then
         Ada.Text_IO.Put_Line
           (File,"Model_Date=""" & MAST.IO.Date_Image(The_System.Model_Date) &
            "T00:00:00"">");
      else
         Ada.Text_IO.Put_Line
           (File,"Model_Date=""" &
            MAST.IO.Date_Image(The_System.Model_Date) & """>");
      end if;
      MAST.Processing_Resources.Print_XML
        (File,The_System.Processing_Resources,Indentation+3);
      Ada.Text_IO.New_Line(File);
      Mast.Schedulers.Print_XML(File,The_System.Schedulers,Indentation+3);
      MAST.Shared_Resources.Print_XML
        (File,The_System.Shared_Resources,Indentation+3);
      Ada.Text_IO.New_Line(File);
      MAST.Operations.Print_XML
        (File,The_System.Operations,Indentation+3);
      Ada.Text_IO.New_Line(File);
      MAST.Scheduling_Servers.Print_XML
        (File,The_System.Scheduling_Servers,Indentation+3);
      Ada.Text_IO.New_Line(File);
      MAST.Transactions.Print_XML
        (File,The_System.Transactions,Indentation+3);
      Ada.Text_IO.New_Line(File);
      Ada.Text_IO.Put_Line(File,"</mast_mdl:MAST_MODEL> ");
   end Print_XML;

   -----------------------
   -- Print_XML_Results --
   -----------------------

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      The_System : in out System;
      Indentation : Positive:=1)
   is
      --   Names_Length : constant := 18;
   begin
      Ada.Text_IO.Put_Line
        (File,"<?xml version="&"""1.0"" encoding=""UTF-8""?>");
      Ada.Text_IO.Put_Line
        (File,"<?mast fileType=""XML-Mast-Result-File"" version=""1.1""?>");
      Ada.Text_IO.Put_Line(File,"<mast_res:REAL_TIME_SITUATION ");
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
      Ada.Text_IO.Put_Line
        (File,"xmlns:mast_res=""http://mast.unican.es/xmlmast/result"" ");
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
      Ada.Text_IO.Put_Line
        (File,"xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" ");
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
      Ada.Text_IO.Put_Line
        (File,"xsi:schemaLocation=""http://mast.unican.es/xmlmast/result "&
         "Mast_Result.xsd"" ");
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
      if The_System.Model_Name=Null_Var_String then
         Ada.Text_IO.Put_Line
           (File,"Model_Name=""Unknown"" " );
      else
         Ada.Text_IO.Put_Line
           (File,"Model_Name=""" &
            IO.Name_Image(The_System.Model_Name) &""" " );
      end if;
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
      if The_System.Model_Date="                   " then
         Ada.Text_IO.Put_Line
           (File,"Model_Date=""" &
            MAST.IO.Today& """ ");
      elsif MAST.IO.Date_Image(The_System.Model_Date)'Length<11 then
         Ada.Text_IO.Put_Line
           (File,"Model_Date=""" & MAST.IO.Date_Image(The_System.Model_Date) &
            "T00:00:00"" ");
      else
         Ada.Text_IO.Put_Line
           (File,"Model_Date=""" &
            MAST.IO.Date_Image(The_System.Model_Date) & """ ");
      end if;
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
      Ada.Text_IO.Put_Line
        (File,"Generation_Tool=""" &
         To_String(The_System.Generation_Tool) & """ ");
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
      Ada.Text_IO.Put_Line
        (File,"Generation_Profile=""" &
         To_String(The_System.Generation_Profile) & """ ");
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
      Ada.Text_IO.Put_Line
        (File,"Generation_Date=""" &
         MAST.IO.Date_Image(The_System.Generation_Date) & """>");

      -- Now print rest of results

      if The_System.The_Slack_Result/=null then
         Results.Print_XML
           (File,The_System.The_Slack_Result.all,Indentation+8,False);
      end if;
      MAST.Transactions.Print_XML_Results
        (File,The_System.Transactions,Indentation+6);
      MAST.Processing_Resources.Print_XML_Results
        (File,The_System.Processing_Resources,Indentation+6);
      MAST.Operations.Print_XML_Results
        (File,The_System.Operations,Indentation+6);
      MAST.Shared_Resources.Print_XML_Results
        (File,The_System.Shared_Resources,Indentation+6);
      MAST.Scheduling_Servers.Print_XML_Results
        (File,The_System.Scheduling_Servers,Indentation+6);
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
      Ada.Text_IO.Put_Line(File,"</mast_res:REAL_TIME_SITUATION>");
   end Print_XML_Results;

   ----------------------
   -- Set_Slack_Result --
   ----------------------

   procedure Set_Slack_Result
     (Sys : in out System; Res : Results.Slack_Result_Ref)
   is
   begin
      Sys.The_Slack_Result:=Res;
   end Set_Slack_Result;

   ----------------------
   -- Slack_Result     --
   ----------------------

   function Slack_Result
     (Sys : System) return Results.Slack_Result_Ref
   is
   begin
      return Sys.The_Slack_Result;
   end Slack_Result;

   ----------------------
   -- Set_Trace_Result --
   ----------------------

   procedure Set_Trace_Result
     (Sys : in out System; Res : Results.Trace_Result_Ref)
   is
   begin
      Sys.The_Trace_Result:=Res;
   end Set_Trace_Result;

   ----------------------
   -- Trace_Result     --
   ----------------------

   function Trace_Result
     (Sys : System) return Results.Trace_Result_Ref
   is
   begin
      return Sys.The_Trace_Result;
   end Trace_Result;


end Mast.Systems;
