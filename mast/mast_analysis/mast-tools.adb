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

with Mast.Restrictions,Mast.Miscelaneous_Tools,
  Mast.Linear_Analysis_Tools,Mast.Tool_Exceptions,
  Mast.Linear_Priority_Assignment_Tools,
  Mast.Monoprocessor_Tools, Mast.Results,
  Mast.EDF_Tools,
  Mast.Consistency_Checks,Ada.Text_IO,Var_Strings;
use Ada.Text_IO,Var_Strings;

package body MAST.Tools is


   use type Results.Slack_Result_Ref;

   ------------------------------
   -- Calculate_Blocking_Times --
   ------------------------------

   procedure Calculate_Blocking_Times
     (The_System : in out Mast.Systems.System;
      Verbose : in Boolean:=True)
   is
   begin
      if not MAST.Restrictions.PCP_SRP_Or_Priority_Inheritance_Only
        (The_System,Verbose)
      then
         if Verbose then
            Put_Line("PCP_SRP_or_Priority_Inheritance_Only restriction "&
                     "not met");
         end if;
         Tool_Exceptions.Set_Restriction_Message
           ("Shared Resources not consistent");
         raise Tool_Exceptions.Restriction_Not_Met;
      end if;
      if not Consistency_Checks.Consistent_Shared_Resource_Usage
        (The_System,Verbose)
      then
         if Verbose then
            Put_Line("Consistent shared resource check not met");
         end if;
         Tool_Exceptions.Set_Restriction_Message
           ("Shared Resources not consistent");
         raise Tool_Exceptions.Restriction_Not_Met;
      end if;
      if not Consistency_Checks.Consistent_Shared_Resource_Usage_For_Segments
        (The_System,Verbose)
      then
         if Verbose then
            Put_Line("Consistent shared resource usage for segments"&
                     " check not met");
         end if;
         Tool_Exceptions.Set_Restriction_Message
           ("Shared Resources not consistent for segment");
         raise Tool_Exceptions.Restriction_Not_Met;
      end if;
      Mast.Miscelaneous_Tools.Calculate_Blocking_Times (The_System,Verbose);
   end Calculate_Blocking_Times;

   -----------------------------------
   -- Calculate_Ceilings_And_Levels --
   -----------------------------------

   procedure Calculate_Ceilings_And_Levels
     (The_System : in out Mast.Systems.System;
      Verbose : in Boolean:=True)
   is
   begin
      if not MAST.Restrictions.PCP_SRP_Or_Priority_Inheritance_Only
        (The_System,Verbose)
      then
         if Verbose then
            Put_Line("PCP_SRP_or_Priority_Inheritance_Only restriction "&
                     "not met");
         end if;
         Tool_Exceptions.Set_Restriction_Message
           ("Shared Resources not consistent");
         raise Tool_Exceptions.Restriction_Not_Met;
      end if;
      if not Consistency_Checks.Consistent_Shared_Resource_Usage
        (The_System,Verbose)
      then
         if Verbose then
            Put_Line("Consistent shared resource check not met");
         end if;
         Tool_Exceptions.Set_Restriction_Message
           ("Shared Resources not consistent");
         raise Tool_Exceptions.Restriction_Not_Met;
      end if;
      if not Consistency_Checks.Consistent_Shared_Resource_Usage_For_Segments
        (The_System,Verbose)
      then
         if Verbose then
            Put_Line("Consistent shared resource usage for segments"&
                     " check not met");
         end if;
         Tool_Exceptions.Set_Restriction_Message
           ("Shared Resources not consistent for segment");
         raise Tool_Exceptions.Restriction_Not_Met;
      end if;
      Mast.Miscelaneous_Tools.Calculate_Ceilings_And_Levels
        (The_System,Verbose);
   end Calculate_Ceilings_And_Levels;

   --------------------------------------------
   -- Calculate_System_Slack --
   --------------------------------------------

   procedure Calculate_System_Slack
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True)
   is
      Max_Factor : constant Normalized_Execution_Time := 2.0**10;
      Small_Step : constant Normalized_Execution_Time := 0.01;
      Factor,Initial : Normalized_Execution_Time:=1.0;

      function Is_Schedulable return Boolean is
         Schedulable : Boolean;
      begin
         if Restrictions.Max_Processor_Utilization
           (The_System,False)>=1.0-Float(Small_Step)/2.0
         then
            return False;
         else
            The_Tool(The_System,False);
            Check_System_Schedulability(The_System,Schedulable,False);
            return Schedulable;
         end if;
      exception
         when Tool_Exceptions.Restriction_Not_Met =>
            return False;
      end Is_Schedulable;

      function Find_Factor_In_Interval
        (Initial,Final : Normalized_Execution_Time)
        return Normalized_Execution_Time
      is
         Half : Normalized_Execution_Time:=(Initial+Final)/2.0;
      begin
         Operations.Scale(The_System.Operations,Half);
         if Is_Schedulable then
            if Final-Half<Small_Step then
               return Half;
            else
               return Find_Factor_In_Interval(Half,Final);
            end if;
         else -- not schedulable
            if Half-Initial<Small_Step then
               return Initial;
            else
               return Find_Factor_In_Interval(Initial,Half);
            end if;
         end if;
      end Find_Factor_In_Interval;

      The_Slack : Float;
      Res : Results.Slack_Result_Ref;

   begin
      -- Initial analysis
      if Is_Schedulable then
         -- duplicate times until not schedulable
         loop
            Initial:=Factor;
            Factor:=Factor*2.0;
            Operations.Scale(The_System.Operations,Factor);
            if not Is_Schedulable then
               Factor:=Find_Factor_In_Interval(Initial,Factor);
               exit;
            end if;
            exit when Factor>=Max_Factor;
         end loop;
      else  -- not schedulable
         Operations.Scale(The_System.Operations,0.0);
         if Is_Schedulable then
            Factor:=Find_Factor_In_Interval(0.0,1.0);
         else
            Factor:=0.0;
         end if;
      end if;
      The_Slack:=Float(Factor-1.0)*100.0;
      Res:=Systems.Slack_Result(The_System);
      if Res=null then
         Res:= new Results.Slack_Result;
      end if;
      Results.Set_Slack(Res.all,The_Slack);
      Systems.Set_Slack_Result(The_System,Res);
      Operations.Scale(The_System.Operations,1.0);
   end Calculate_System_Slack;

   ---------------------------------
   -- Calculate_Transaction_Slack --
   ---------------------------------
   -- calculates the relative amount that the execution times of the
   -- actions of the transaction referenced by Trans_Ref may grow
   -- (or may need decreasing) for the system to continue
   -- being (or become) schedulable
   -- Ci* = Ci * (1+The_Slack) for all actions in the transaction

   procedure Calculate_Transaction_Slack
     (Trans_Ref : in MAST.Transactions.Transaction_Ref;
      The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True)
   is
      Max_Factor : constant Normalized_Execution_Time := 2.0**10;
      Small_Step : constant Normalized_Execution_Time := 0.01;
      Factor,Initial : Normalized_Execution_Time:=1.0;

      function Is_Schedulable return Boolean is
         Schedulable : Boolean;
      begin
         if Restrictions.Max_Processor_Utilization
           (The_System,False)>=10.0-Float(Small_Step)/2.0
         then
            return False;
         else
            The_Tool(The_System,False);
            Check_System_Schedulability(The_System,Schedulable,False);
            return Schedulable;
         end if;
      exception
         when Tool_Exceptions.Restriction_Not_Met =>
            return False;
      end Is_Schedulable;

      function Find_Factor_In_Interval
        (Initial,Final : Normalized_Execution_Time)
        return Normalized_Execution_Time
      is
         Half : Normalized_Execution_Time:=(Initial+Final)/2.0;
      begin
         Transactions.Scale(Trans_Ref.all,Half);
         if Is_Schedulable then
            if Final-Half<Small_Step then
               return Half;
            else
               return Find_Factor_In_Interval(Half,Final);
            end if;
         else -- not schedulable
            if Half-Initial<Small_Step then
               return Initial;
            else
               return Find_Factor_In_Interval(Initial,Half);
            end if;
         end if;
      end Find_Factor_In_Interval;

      The_Slack : Float;
      Res : Results.Slack_Result_Ref;

   begin
      -- Initial analysis
      if Is_Schedulable then
         -- duplicate times until not schedulable
         loop
            Initial:=Factor;
            Factor:=Factor*2.0;
            Transactions.Scale(Trans_Ref.all,Factor);
            if not Is_Schedulable then
               Factor:=Find_Factor_In_Interval(Initial,Factor);
               exit;
            end if;
            exit when Factor>=Max_Factor;
         end loop;
      else  -- not schedulable
         Transactions.Scale(Trans_Ref.all,0.0);
         if Is_Schedulable then
            Factor:=Find_Factor_In_Interval(0.0,1.0);
         else
            Factor:=0.0;
         end if;
      end if;
      The_Slack:=Float(Factor-1.0)*100.0;
      Res:=Transactions.Slack_Result(Trans_Ref.all);
      if Res=null then
         Res:= new Results.Slack_Result;
      end if;
      Results.Set_Slack(Res.all,The_Slack);
      Transactions.Set_Slack_Result(Trans_Ref.all,Res);
      Transactions.Scale(Trans_Ref.all,1.0);
   end Calculate_Transaction_Slack;

   ----------------------------------
   -- Calculate_Transaction_Slacks --
   ----------------------------------
   -- Invokes Calculate_Transaction_Slack for all transactions in the system
   -- and stores the slacks in the results

   procedure Calculate_Transaction_Slacks
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True)
   is
      Trans_Ref : Transactions.Transaction_Ref;
      Iterator : Transactions.Lists.Index;
   begin
      Transactions.Lists.Rewind(The_System.Transactions,Iterator);
      for I in 1..Transactions.Lists.Size(The_System.Transactions) loop
         Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Iterator);
         if Verbose then
            Put_Line("Calculating Transaction Slack for "&
                     Transactions.Name(Trans_Ref));
         end if;
         Calculate_Transaction_Slack
           (Trans_Ref,The_System,The_Tool,Verbose);
      end loop;
   end Calculate_Transaction_Slacks;

   -----------------------------------------
   -- Calculate_Processing_Resource_Slack --
   -----------------------------------------
   -- calculates the relative amount that the speed of the processing
   -- resource referenced by Res_Ref may be decreased
   -- (or may need inreasing) for the system to continue
   -- being (or become) schedulable
   -- Speed* = Speed * (1-The_Slack/100) for the processing resource

   procedure Calculate_Processing_Resource_Slack
     (Res_Ref : in MAST.Processing_Resources.Processing_Resource_Ref;
      The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True)
   is
      Max_Factor : constant Processor_Speed := 2.0**6;
      Small_Step : constant Processor_Speed := 0.005;
      Factor,Initial : Processor_Speed:=1.0;

      function Is_Schedulable return Boolean is
         Schedulable : Boolean;
      begin
         if Restrictions.Max_Processor_Utilization
           (The_System,False)>=1.0-Float(Small_Step)/2.0
         then
            return False;
         else
            The_Tool(The_System,False);
            Check_System_Schedulability(The_System,Schedulable,False);
            return Schedulable;
         end if;
      exception
         when Tool_Exceptions.Restriction_Not_Met =>
            return False;
      end Is_Schedulable;

      function Find_Factor_In_Interval
        (Initial,Final : Processor_Speed)
        return Processor_Speed
      is
         Half : Processor_Speed:=(Initial+Final)/2.0;
      begin
         Processing_Resources.Scale(Res_Ref.all,Half);
         if not Is_Schedulable then
            if Final-Half<Small_Step then
               return Half;
            else
               return Find_Factor_In_Interval(Half,Final);
            end if;
         else -- schedulable
            if Half-Initial<Small_Step then
               return Initial;
            else
               return Find_Factor_In_Interval(Initial,Half);
            end if;
         end if;
      end Find_Factor_In_Interval;

      The_Slack : Float;
      Res : Results.Slack_Result_Ref;

   begin
      -- Initial analysis
      if not Is_Schedulable then
         -- duplicate speed until schedulable
         loop
            Initial:=Factor;
            Factor:=Factor*2.0;
            Processing_Resources.Scale(Res_Ref.all,Factor);
            if Is_Schedulable then
               Factor:=Find_Factor_In_Interval(Initial,Factor);
               exit;
            end if;
            exit when Factor>=Max_Factor;
         end loop;
      else  -- schedulable
            -- reduce speed until not schedulable
         Processing_Resources.Scale(Res_Ref.all,Small_Step);
         if not Is_Schedulable then
            Factor:=Find_Factor_In_Interval(Small_Step,1.0);
         else
            Factor:=Small_Step;
         end if;
      end if;
      The_Slack:=(1.0/Float(Factor)-1.0)*100.0;
      Res:=Processing_Resources.Slack_Result(Res_Ref.all);
      if Res=null then
         Res:= new Results.Slack_Result;
      end if;
      Results.Set_Slack(Res.all,The_Slack);
      Processing_Resources.Set_Slack_Result(Res_Ref.all,Res);
      Processing_Resources.Scale(Res_Ref.all,1.0);
      Put("Utilization:  ");
      Put_Line(Float'Image((Float(100)/(((Float(100)+The_Slack))/Float(100)))));
   end Calculate_Processing_Resource_Slack;

   ------------------------------------------
   -- Calculate_Processing_Resource_Slacks --
   ------------------------------------------
   -- Invokes Calculate_Processing_Resource_Slack for all processing
   -- resources in the system

   procedure Calculate_Processing_Resource_Slacks
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True)
   is
      Res_Ref : Processing_Resources.Processing_Resource_Ref;
      Iterator : Processing_Resources.Lists.Index;
   begin
      Processing_Resources.Lists.Rewind
        (The_System.Processing_Resources,Iterator);
      for I in 1..Processing_Resources.Lists.Size
        (The_System.Processing_Resources)
      loop
         Processing_Resources.Lists.Get_Next_Item
           (Res_Ref,The_System.Processing_Resources,Iterator);
         if Verbose then
            Put_Line("Calculating Processing Resource Slack for "&
                     Processing_Resources.Name(Res_Ref));
         end if;
         Calculate_Processing_Resource_Slack
           (Res_Ref,The_System,The_Tool,Verbose);
      end loop;
   end Calculate_Processing_Resource_Slacks;


   -------------------------------
   -- Calculate_Operation_Slack --
   -------------------------------
   -- calculates the relative amount that the execution time of the
   -- operation referenced by Op_Ref may grow
   -- (or may need decreasing) for the system to continue
   -- being (or become) schedulable
   -- Ci* = Ci * (1+The_Slack/100) for that operation

   procedure Calculate_Operation_Slack
     (Op_Ref : in MAST.Operations.Operation_Ref;
      The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True)
   is
      Max_Factor : constant Normalized_Execution_Time := 2.0**10;
      Small_Step : constant Normalized_Execution_Time := 0.01;
      Factor,Initial : Normalized_Execution_Time:=1.0;

      function Is_Schedulable return Boolean is
         Schedulable : Boolean;
      begin
         if Restrictions.Max_Processor_Utilization
           (The_System,False)>=1.0-Float(Small_Step)/2.0
         then
            return False;
         else
            The_Tool(The_System,False);
            Check_System_Schedulability(The_System,Schedulable,False);
            return Schedulable;
         end if;
      exception
         when Tool_Exceptions.Restriction_Not_Met =>
            return False;
      end Is_Schedulable;

      function Find_Factor_In_Interval
        (Initial,Final : Normalized_Execution_Time)
        return Normalized_Execution_Time
      is
         Half : Normalized_Execution_Time:=(Initial+Final)/2.0;
      begin
         Operations.Scale(Op_Ref.all,Half);
         if Is_Schedulable then
            if Final-Half<Small_Step then
               return Half;
            else
               return Find_Factor_In_Interval(Half,Final);
            end if;
         else -- not schedulable
            if Half-Initial<Small_Step then
               return Initial;
            else
               return Find_Factor_In_Interval(Initial,Half);
            end if;
         end if;
      end Find_Factor_In_Interval;

      The_Slack : Float;
      Res : Results.Slack_Result_Ref;

   begin
      -- Initial analysis
      if Is_Schedulable then
         -- duplicate times until not schedulable
         loop
            Initial:=Factor;
            Factor:=Factor*2.0;
            Operations.Scale(Op_Ref.all,Factor);
            if not Is_Schedulable then
               Factor:=Find_Factor_In_Interval(Initial,Factor);
               exit;
            end if;
            exit when Factor>=Max_Factor;
         end loop;
      else  -- not schedulable
         Operations.Scale(Op_Ref.all,0.0);
         if Is_Schedulable then
            Factor:=Find_Factor_In_Interval(0.0,1.0);
         else
            Factor:=0.0;
         end if;
      end if;
      The_Slack:=Float(Factor-1.0)*100.0;
      Res:=Operations.Slack_Result(Op_Ref.all);
      if Res=null then
         Res:= new Results.Slack_Result;
      end if;
      Results.Set_Slack(Res.all,The_Slack);
      Operations.Set_Slack_Result(Op_Ref.all,Res);
      Operations.Scale(Op_Ref.all,1.0);
   end Calculate_Operation_Slack;


   -------------------------------------------
   -- Check_Shared_Resources_Total_Ordering --
   -------------------------------------------

   procedure Check_Shared_Resources_Total_Ordering
     (The_System : in MAST.Systems.System;
      Ordered : out Boolean;
      Verbose : in Boolean:=True) renames
     Mast.Miscelaneous_Tools.Check_Shared_Resources_Total_Ordering;

   -------------------------
   -- Classic_RM_Analysis --
   -------------------------

   procedure Classic_RM_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False)
   is
   begin
      if Mast.Restrictions.Feasible_Processing_Load
        (The_System,Verbose)
      then
         if MAST.Restrictions.Fixed_Priority_Only
           (The_System,Verbose)
           and then MAST.Restrictions.Monoprocessor_Only
           (The_System,Verbose)
           and then MAST.Restrictions.Simple_Transactions_Only
           (The_System,Verbose)
           and then Mast.Restrictions.Referenced_Events_Are_External_Only
           (The_System,Verbose)
           and then Mast.Restrictions.No_Permanent_Overridden_Priorities
           (The_System,Verbose)
         then
            if not Only_Check_Restrictions then
               Calculate_Blocking_Times(The_System,Verbose);
               Mast.Monoprocessor_Tools.RM_Analysis (The_System,Verbose);
            end if;
         else
            if Verbose then
               Put_Line("Classic Rate Monotonic Analysis");
               Put_Line("  Analysis not valid for this kind of system");
            end if;
            Tool_Exceptions.Set_Restriction_Message
              ("Classic Rate Monotonic Analysis Restrictions not met");
            raise Tool_Exceptions.Restriction_Not_Met;
         end if;
      else
         Tool_Exceptions.Set_Restriction_Message("Utilization_Too_High");
         raise Tool_Exceptions.Restriction_Not_Met ;
      end if;
   end Classic_RM_Analysis;

   ---------------------------------
   -- Check_System_Schedulability --
   ---------------------------------

   procedure Check_System_Schedulability
     (The_System : MAST.Systems.System;
      Is_Schedulable : out Boolean;
      Verbose : in Boolean:=True) renames
     Mast.Miscelaneous_Tools.Check_System_Schedulability;

   --------------------------------------
   -- Check_Transaction_Schedulability --
   --------------------------------------

   procedure Check_Transaction_Schedulability
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Is_Schedulable : out Boolean;
      Verbose : in Boolean:=True) renames
     Mast.Miscelaneous_Tools.Check_Transaction_Schedulability;

   --------------------------------
   -- EDF_Monoprocessor_Analysis --
   --------------------------------

   procedure EDF_Monoprocessor_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False)
   is
   begin
      if Mast.Restrictions.Feasible_Processing_Load
        (The_System,Verbose)
      then
         if MAST.Restrictions.EDF_Only
           (The_System,Verbose)
           and then Mast.Restrictions.SRP_Only
           (The_System,Verbose)
           and then MAST.Restrictions.Monoprocessor_Only
           (The_System,Verbose)
           and then MAST.Restrictions.Simple_Transactions_Only
           (The_System,Verbose)
           and then Mast.Restrictions.Referenced_Events_Are_External_Only
           (The_System,Verbose)
         then
            if not Only_Check_Restrictions then
               Calculate_Blocking_Times(The_System,Verbose);
               Mast.EDF_Tools.EDF_Monoprocessor_Analysis (The_System,Verbose);
            end if;
         else
            if Verbose then
               Put_Line("EDF Monoprocessor Analysis");
               Put_Line("  Analysis not valid for this kind of system");
            end if;
            Tool_Exceptions.Set_Restriction_Message
              ("EDF Monoprocessor Analysis Restrictions not met");
            raise Tool_Exceptions.Restriction_Not_Met;
         end if;
      else
         Tool_Exceptions.Set_Restriction_Message("Utilization_Too_High");
         raise Tool_Exceptions.Restriction_Not_Met ;
      end if;
   end EDF_Monoprocessor_Analysis;

   ------------------------------------
   -- EDF_Within_Priorities_Analysis --
   ------------------------------------

   procedure EDF_Within_Priorities_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False)
   is
   begin
      if Mast.Restrictions.Feasible_Processing_Load
        (The_System,Verbose)
      then
         if MAST.Restrictions.EDF_Within_Priorities_Only
           (The_System,Verbose)
           and then MAST.Restrictions.Monoprocessor_Only
           (The_System,Verbose)
           and then MAST.Restrictions.Simple_Transactions_Only
           (The_System,Verbose)
           and then Mast.Restrictions.Referenced_Events_Are_External_Only
           (The_System,Verbose)
         then
            if not Only_Check_Restrictions then
               Calculate_Blocking_Times(The_System,Verbose);
               Mast.EDF_Tools.EDF_Within_Priorities_Analysis
                 (The_System,Verbose);
            end if;
         else
            if Verbose then
               Put_Line("EDF Within Priorities Analysis");
               Put_Line("  Analysis not valid for this kind of system");
            end if;
            Tool_Exceptions.Set_Restriction_Message
              ("EDF Within Priorities Analysis Restrictions not met");
            raise Tool_Exceptions.Restriction_Not_Met;
         end if;
      else
         Tool_Exceptions.Set_Restriction_Message("Utilization_Too_High");
         raise Tool_Exceptions.Restriction_Not_Met ;
      end if;
   end EDF_Within_Priorities_Analysis;

   -----------------
   -- Linear_HOPA --
   -----------------

   procedure Linear_HOPA
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True)
   is
   begin
      if Mast.Restrictions.Feasible_Processing_Load
        (The_System,Verbose)
      then
         if MAST.Restrictions.Fixed_Priority_Only
           (The_System,Verbose)
           and then MAST.Restrictions.Linear_Plus_Transactions_Only
           (The_System,Verbose)
         then
            if (The_Tool = Holistic_Analysis'Access)
              or (The_Tool = Classic_RM_Analysis'Access)
              or (The_Tool = Varying_Priorities_Analysis'Access)
              or (The_Tool = Offset_Based_Analysis'Access)
              or (The_Tool = Offset_Based_Optimized_Analysis'Access)then
               if Verbose then
                  Put_Line("Linear HOPA running...");
               end if;
               Mast.Linear_Priority_Assignment_Tools.HOPA
                 (The_System,The_Tool,Verbose);
            else
               if Verbose then
                  Put_Line("Linear HOPA");
                  Put_Line("  Incorrect analysis tool for Linear HOPA");
               end if;
               Tool_Exceptions.Set_Tool_Failure_Message
                 ("Incorrect analysis tool for Linear HOPA");
               raise Tool_Exceptions.Tool_Failure;
            end if;
         else
            if Verbose then
               Put_Line("Linear HOPA");
               Put_Line("  Priority assignment tool not valid for "&
                        "this kind of system");
            end if;
            Tool_Exceptions.Set_Restriction_Message
              ("Linear HOPA Restrictions not met");
            raise Tool_Exceptions.Restriction_Not_Met;
         end if;
      else
         Tool_Exceptions.Set_Restriction_Message("Utilization_Too_High");
         raise Tool_Exceptions.Restriction_Not_Met;
      end if;
   end Linear_HOPA;

   -------------------------
   -- Multiple_Event_HOPA --
   -------------------------

   procedure Multiple_Event_HOPA
     (The_System : in out MAST.Systems.System;
      The_Tool: in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True)
   is
   begin
      null;
   end Multiple_Event_HOPA;

   -----------------------
   -- Holistic_Analysis --
   -----------------------

   procedure Holistic_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False)
   is
   begin
      if Mast.Restrictions.Feasible_Processing_Load
        (The_System,Verbose)
      then
         if MAST.Restrictions.Fixed_Priority_Only
           (The_System,Verbose)
           and then MAST.Restrictions.Linear_Plus_Transactions_Only
           (The_System,Verbose)
           and then Mast.Restrictions.Referenced_Events_Are_External_Only
           (The_System,Verbose)
           and then Mast.Restrictions.No_Permanent_Overridden_Priorities
           (The_System,Verbose)
         then
            if not Only_Check_Restrictions then
               Calculate_Blocking_Times(The_System,Verbose);
               Linear_Analysis_Tools.Holistic_Analysis(The_System,Verbose);
            end if;
         else
            if Verbose then
               Put_Line("Holistic Analysis");
               Put_Line("  Analysis not valid for this kind of system");
            end if;
            Tool_Exceptions.Set_Restriction_Message
              ("Holistic Analysis Restrictions not met");
            raise Tool_Exceptions.Restriction_Not_Met;
         end if;
      else
         Tool_Exceptions.Set_Restriction_Message("Utilization_Too_High");
         raise Tool_Exceptions.Restriction_Not_Met;
      end if;
   end Holistic_Analysis;

   ---------------------------------------
   -- Offset_Based_Analysis --
   ---------------------------------------

   procedure Offset_Based_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False)
   is
   begin
      if Mast.Restrictions.Feasible_Processing_Load
        (The_System,Verbose)
      then
         if MAST.Restrictions.Fixed_Priority_Only
           (The_System,Verbose)
           and then MAST.Restrictions.Linear_Plus_Transactions_Only
           (The_System,Verbose)
           and then Mast.Restrictions.Referenced_Events_Are_External_Only
           (The_System,Verbose)
           and then Mast.Restrictions.No_Permanent_Overridden_Priorities
           (The_System,Verbose)
         then
            if not Only_Check_Restrictions then
               Calculate_Blocking_Times(The_System,Verbose);
               Linear_Analysis_Tools.Offset_Based_Unoptimized_Analysis
                 (The_System,Verbose);
            end if;
         else
            if Verbose then
               Put_Line("Offset_Based_Analysis");
               Put_Line("  Analysis not valid for this kind of system");
            end if;
            Tool_Exceptions.Set_Restriction_Message
              ("Offset_Based analysis Restrictions not met");
            raise Tool_Exceptions.Restriction_Not_Met;
         end if;
      else
         Tool_Exceptions.Set_Restriction_Message("Utilization_Too_High");
         raise Tool_Exceptions.Restriction_Not_Met;
      end if;
   end Offset_Based_Analysis;

   -------------------------------------
   -- Offset_Based_Optimized_Analysis --
   -------------------------------------

   procedure Offset_Based_Optimized_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False)
   is
   begin
      if Mast.Restrictions.Feasible_Processing_Load
        (The_System,Verbose)
      then
         if MAST.Restrictions.Fixed_Priority_Only
           (The_System,Verbose)
           and then MAST.Restrictions.Linear_Plus_Transactions_Only
           (The_System,Verbose)
           and then Mast.Restrictions.Referenced_Events_Are_External_Only
           (The_System,Verbose)
           and then Mast.Restrictions.No_Permanent_Overridden_Priorities
           (The_System,Verbose)
         then
            if not Only_Check_Restrictions then
               Calculate_Blocking_Times(The_System,Verbose);
               Linear_Analysis_Tools.Offset_Based_Optimized_Analysis
                 (The_System,Verbose);
            end if;
         else
            if Verbose then
               Put_Line("Offset_Based_Optimized_Analysis");
               Put_Line("  Analysis not valid for this kind of system");
            end if;
            Tool_Exceptions.Set_Restriction_Message
              ("Offset_Based_Optimized Analysis Restrictions not met");
            raise Tool_Exceptions.Restriction_Not_Met;
         end if;
      else
         Tool_Exceptions.Set_Restriction_Message("Utilization_Too_High");
         raise Tool_Exceptions.Restriction_Not_Met;
      end if;
   end Offset_Based_Optimized_Analysis;

   ------------------------------
   -- Monoprocessor_Assignment --
   ------------------------------

   procedure Monoprocessor_Assignment
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True)
   is
   begin
      if Mast.Restrictions.Feasible_Processing_Load
        (The_System,Verbose)
      then
         if MAST.Restrictions.Monoprocessor_Only
           (The_System,Verbose)
           and then MAST.Restrictions.Simple_Transactions_Only
           (The_System,Verbose)
         then
            if MAST.Restrictions.Fixed_Priority_Only (The_System,Verbose)
            then
               if (The_Tool = Classic_RM_Analysis'Access)
                 or (The_Tool = Varying_Priorities_Analysis'Access)
                 or (The_Tool = Holistic_Analysis'Access)
                 or (The_Tool = Offset_Based_Analysis'Access)
                 or (The_Tool = Offset_Based_Optimized_Analysis'Access)
               then
                  if Verbose then
                     Put_Line("Monoprocessor Priority Assignment running...");
                  end if;
                  Mast.Monoprocessor_Tools.Priority_Assignment
                    (The_System,The_Tool,Verbose);
               else
                  if Verbose then
                     Put_Line("Monoprocessor Priority Assignment");
                     Put_Line("  Incorrect analysis tool for "&
                              "Monoprocessor Priority Assignment");
                  end if;
                  Tool_Exceptions.Set_Tool_Failure_Message
                    ("Incorrect analysis tool for "&
                     "Monoprocessor Priority Assignment");
                  raise Tool_Exceptions.Tool_Failure;
               end if;
            elsif MAST.Restrictions.EDF_Only (The_System,Verbose) or else
              MAST.Restrictions.EDF_Within_Priorities_Only (The_System,Verbose)
            then
               if (The_Tool = EDF_Monoprocessor_Analysis'Access)
                 or (The_Tool = EDF_Within_Priorities_Analysis'Access)
                 or (The_Tool = Holistic_Analysis'Access)
                 or (The_Tool = Offset_Based_Analysis'Access)
                 or (The_Tool = Offset_Based_Optimized_Analysis'Access)
               then
                  if Verbose then
                     Put_Line("Monoprocessor Deadline Assignment running...");
                  end if;
                  Mast.EDF_Tools.Deadline_Assignment (The_System,Verbose);
               else
                  if Verbose then
                     Put_Line("Monoprocessor Deadline Assignment");
                     Put_Line("  Incorrect analysis tool for "&
                              "Monoprocessor Deadline Assignment");
                  end if;
                  Tool_Exceptions.Set_Tool_Failure_Message
                    ("Incorrect analysis tool for "&
                     "Monoprocessor Deadline Assignment");
                  raise Tool_Exceptions.Tool_Failure;
               end if;
            else
               if Verbose then
                  Put_Line("Monoprocessor Assignment");
                  Put_Line("  Assignment tool not valid for "&
                           "this kind of system");
               end if;
               Tool_Exceptions.Set_Restriction_Message
                 ("Linear Monoprocessor Assigment Restrictions"&
                  " not met");
               raise Tool_Exceptions.Restriction_Not_Met;
            end if;
         else
            if Verbose then
               Put_Line("Monoprocessor Assignment");
               Put_Line("  Assignment tool not valid for "&
                        "this kind of system");
            end if;
            Tool_Exceptions.Set_Restriction_Message
              ("Linear Monoprocessor Assigment Restrictions"&
               " not met");
            raise Tool_Exceptions.Restriction_Not_Met;
         end if;

      else
         Tool_Exceptions.Set_Restriction_Message("Utilization_Too_High");
         raise Tool_Exceptions.Restriction_Not_Met;
      end if;
   end Monoprocessor_Assignment;

   ----------------------------------
   -- Linear_Deadline_Distribution --
   ----------------------------------

   procedure Linear_Deadline_Distribution
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True)
   is
   begin
      if Mast.Restrictions.Feasible_Processing_Load
        (The_System,Verbose)
      then
         if MAST.Restrictions.Flat_FP_Or_EDF_Only
           (The_System,Verbose)
           and then MAST.Restrictions.Linear_Plus_Transactions_Only
           (The_System,Verbose)
         then
            if (The_Tool = EDF_Monoprocessor_Analysis'Access)
              or (The_Tool = EDF_Within_Priorities_Analysis'Access)
              or (The_Tool = Holistic_Analysis'Access)
              or (The_Tool = Offset_Based_Analysis'Access)
              or (The_Tool = Offset_Based_Optimized_Analysis'Access)
            then
               if Verbose then
                  Put_Line("Linear Deadline Distribution running...");
               end if;
               Mast.EDF_Tools.Linear_Deadline_Distribution
                 (The_System,Verbose);
            else
               if Verbose then
                  Put_Line("Linear Deadline Distribution");
                  Put_Line("  Incorrect analysis tool for "&
                           "Linear Deadline Distribution");
               end if;
               Tool_Exceptions.Set_Tool_Failure_Message
                 ("Incorrect analysis tool for "&
                  "Linear Deadline Distribution");
               raise Tool_Exceptions.Tool_Failure;
            end if;
         else
            if Verbose then
               Put_Line("Linear Deadline Distribution");
               Put_Line("  Tool not valid for "&
                        "this kind of system");
            end if;
            Tool_Exceptions.Set_Restriction_Message
              ("Linear Deadline Distribution Restrictions not met");
            raise Tool_Exceptions.Restriction_Not_Met;
         end if;
      else
         Tool_Exceptions.Set_Restriction_Message("Utilization_Too_High");
         raise Tool_Exceptions.Restriction_Not_Met;
      end if;
   end Linear_Deadline_Distribution;

   -----------------------------
   -- Multiple_Event_Analysis --
   -----------------------------

   procedure Multiple_Event_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False)
   is
   begin
      null;
   end Multiple_Event_Analysis;

   -------------------------------------------
   -- Linear_Simulated_Annealing_Assignment --
   -------------------------------------------

   procedure Linear_Simulated_Annealing_Assignment
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True)
   is
   begin
      if Mast.Restrictions.Feasible_Processing_Load
        (The_System,Verbose)
      then
         if MAST.Restrictions.Fixed_Priority_Only
           (The_System,Verbose)
           and then MAST.Restrictions.Linear_Plus_Transactions_Only
           (The_System,Verbose)
         then
            if (The_Tool = Holistic_Analysis'Access)
              or (The_Tool = Classic_RM_Analysis'Access)
              or (The_Tool = Varying_Priorities_Analysis'Access)
              or (The_Tool = Offset_Based_Analysis'Access)
              or (The_Tool = Offset_Based_Optimized_Analysis'Access)then
               if Verbose then
                  Put_Line("Linear Simulated Annealing running...");
               end if;
               Mast.Linear_Priority_Assignment_Tools.Simulated_Annealing
                 (The_System,The_Tool,Verbose);
            else
               if Verbose then
                  Put_Line("Linear Simulated Annealing");
                  Put_Line("  Incorrect analysis tool for"&
                           " Linear Simulated Annealing");
               end if;
               Tool_Exceptions.Set_Tool_Failure_Message
                 ("Incorrect analysis tool for Linear Simulated Annealing");
               raise Tool_Exceptions.Tool_Failure;
            end if;
         else
            if Verbose then
               Put_Line("Linear Simulated Annealing");
               Put_Line("  Priority assignment tool not valid for "&
                        "this kind of system");
            end if;
            Tool_Exceptions.Set_Restriction_Message
              ("Linear Simulated Annealing Restrictions not met");
            raise Tool_Exceptions.Restriction_Not_Met;
         end if;
      else
         Tool_Exceptions.Set_Restriction_Message("Utilization_Too_High");
         raise Tool_Exceptions.Restriction_Not_Met;
      end if;
   end Linear_Simulated_Annealing_Assignment;

   ---------------------------------------------------
   -- Multiple_Event_Simulated_Annealing_Assignment --
   ---------------------------------------------------

   procedure Multiple_Event_Simulated_Annealing_Assignment
     (The_System : in out MAST.Systems.System;
      The_Tool : in Worst_Case_Analysis_Tool;
      Verbose : in Boolean:=True)
   is
   begin
      null;
   end Multiple_Event_Simulated_Annealing_Assignment;

   ----------------------
   -- Utilization_Test --
   ----------------------

   procedure Utilization_Test
     (The_System : MAST.Systems.System;
      Suceeds : out Boolean;
      Verbose : in Boolean:=True) renames
     Mast.Miscelaneous_Tools.Utilization_Test;

   ---------------------------------
   -- Varying_Priorities_Analysis --
   ---------------------------------

   procedure Varying_Priorities_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True;
      Only_Check_Restrictions : in Boolean:=False;
      Stop_When_Not_Schedulable : in Boolean:=False)
   is
   begin
      if Mast.Restrictions.Feasible_Processing_Load
        (The_System,Verbose)
      then
         if MAST.Restrictions.Fixed_Priority_Only
           (The_System,Verbose)
           and then MAST.Restrictions.Monoprocessor_Only
           (The_System,Verbose)
           and then MAST.Restrictions.Simple_Transactions_Only
           (The_System,Verbose)
           and then Mast.Restrictions.Referenced_Events_Are_External_Only
           (The_System,Verbose)
           and then Mast.Restrictions.No_Intermediate_Timing_Requirements
           (The_System,Verbose)
           and then Mast.Restrictions.
           No_Permanent_FP_Inside_Composite_Operations
           (The_System,Verbose)
         then
            if not Only_Check_Restrictions then
               Calculate_Blocking_Times(The_System,Verbose);
               Mast.Monoprocessor_Tools.Varying_Priorities_Analysis
                 (The_System,Verbose);
            end if;
         else
            if Verbose then
               Put_Line("Varying Priorities Analysis");
               Put_Line("  Analysis not valid for this kind of system");
            end if;
            Tool_Exceptions.Set_Restriction_Message
              ("Varying Priorities Analysis Restrictions not met");
            raise Tool_Exceptions.Restriction_Not_Met;
         end if;
      else
         Tool_Exceptions.Set_Restriction_Message("Utilization_Too_High");
         raise Tool_Exceptions.Restriction_Not_Met ;
      end if;
   end Varying_Priorities_Analysis;

   -----------------------------------------------
   -- Calculate_Processing_Resource_Utilization --
   -----------------------------------------------

   function Calculate_Processing_Resource_Utilization
     (The_System : MAST.Systems.System;
      The_PR : Mast.Processing_Resources.Processing_Resource_Ref;
      Verbose : Boolean := True) return Float

   is
   begin
      if Mast.Restrictions.
        Linear_Plus_Transactions_Only (The_System,False) then
         return Mast.Miscelaneous_Tools.
           Calculate_Processing_Resource_Utilization
           (The_System,The_PR,Verbose);
      else
         if Verbose then
            Put_Line("Calculate_Processing_Resource_Utilization"&
                     " not yet implemented for"&
                     " Multiple-Event systems");
         end if;
         Tool_Exceptions.Set_Tool_Failure_Message
           ("Calculate_Processing_Resource_Utilization"&
            " not yet implemented for"&
            " Multiple-Event systems");
         raise Tool_Exceptions.Tool_Failure;
      end if;
   end Calculate_Processing_Resource_Utilization;

   ----------------------------------
   -- Calculate_System_Utilization --
   ----------------------------------

   function Calculate_System_Utilization
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Float

   is
   begin
      if Mast.Restrictions.
        Linear_Plus_Transactions_Only (The_System,False) then
         return Mast.Miscelaneous_Tools.Calculate_System_Utilization
           (The_System,Verbose);
      else
         if Verbose then
            Put_Line("Calculate_System_Utilization not yet implemented for"&
                     " Multiple-Event systems");
         end if;
         Tool_Exceptions.Set_Tool_Failure_Message
           ("Calculate_System_Utilization not yet implemented for"&
            " Multiple-Event systems");
         raise Tool_Exceptions.Tool_Failure;
      end if;

   end Calculate_System_Utilization;

end MAST.Tools;
