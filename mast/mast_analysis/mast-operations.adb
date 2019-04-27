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

with MAST.IO, List_Exceptions;
package body MAST.Operations is

   use type Results.Slack_Result_Ref;
   use type MAST.Scheduling_Parameters.Sched_Parameters_Ref;
   use type MAST.Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
   use type Shared_Resources_List.Index;
   use type Shared_Resources.Shared_Resource_Ref;
   use type Op_Lists.Index;
   use type Lists.Index;

   ----------------
   -- Add_Operation --
   ----------------

   procedure Add_Operation
     (Comp_Op : in out Composite_Operation;
      Op : Operation_Ref)
   is
   begin
      Op_Lists.Add(Op, Comp_Op.Op_List);
   end Add_Operation;

   -------------------------
   -- Add_Locked_Resource --
   -------------------------

   procedure Add_Locked_Resource
     (Op : in out Simple_Operation;
      Resource : MAST.Shared_Resources.Shared_Resource_Ref)
   is
   begin
      Shared_Resources_List.Add(Resource,Op.Locked_Shared_Resources);
   end Add_Locked_Resource;

   ---------------------------
   -- Add_Unlocked_Resource --
   ---------------------------

   procedure Add_Unlocked_Resource
     (Op : in out Simple_Operation;
      Resource : MAST.Shared_Resources.Shared_Resource_Ref)
   is
   begin
      Shared_Resources_List.Add(Resource,Op.Unlocked_Shared_Resources);
   end Add_Unlocked_Resource;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (The_List : in Lists.List;
      Res_List : in Shared_Resources.Lists.List)
   is
      Iterator : Lists.Iteration_Object;
      Op_Ref : Operation_Ref;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Op_Ref,The_List,Iterator);
         Adjust(Op_Ref.all,Res_List,The_List);
      end loop;
   end Adjust;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (Op : in out Simple_Operation;
      Res_List : in Shared_Resources.Lists.List;
      Op_List : in Lists.List)
   is
      Iterator : Shared_Resources_List.Iteration_Object;
      Sh_Ref : Shared_Resources.Shared_Resource_Ref;
      The_Index : Shared_Resources.Lists.Index;
      use type Shared_Resources.Lists.Index;
   begin
      -- adjust locked resources
      Shared_Resources_List.Rewind(Op.Locked_Shared_Resources,Iterator);
      for I in 1..Shared_Resources_List.Size(Op.Locked_Shared_Resources) loop
         Sh_Ref:=Shared_Resources_List.Item
           (Iterator,Op.Locked_Shared_Resources);
         The_Index:=Shared_Resources.Lists.Find
           (Shared_Resources.Name(Sh_Ref),Res_List);
         if The_Index=Shared_Resources.Lists.Null_Index then
            Set_Exception_Message
              ("Error in Operation "&Var_Strings.To_String(Op.Name)&
               ": Locked Shared_Resource "&
               Var_Strings.To_String(Shared_Resources.Name(Sh_Ref))&
               " not found");
            raise Object_Not_Found;
         else
            Shared_Resources_List.Update
              (Iterator,Shared_Resources.Lists.Item
               (The_Index,Res_List),Op.Locked_Shared_Resources);
         end if;
         Shared_Resources_List.Get_Next_Item
           (Sh_Ref,Op.Locked_Shared_Resources,Iterator);
      end loop;

      -- adjust unlocked resources
      Shared_Resources_List.Rewind(Op.Unlocked_Shared_Resources,Iterator);
      for I in 1..Shared_Resources_List.Size(Op.Unlocked_Shared_Resources) loop
         Sh_Ref:=Shared_Resources_List.Item
           (Iterator,Op.Unlocked_Shared_Resources);
         The_Index:=Shared_Resources.Lists.Find
           (Shared_Resources.Name(Sh_Ref),Res_List);
         if The_Index=Shared_Resources.Lists.Null_Index then
            Set_Exception_Message
              ("Error in Operation "&Var_Strings.To_String(Op.Name)&
               ": Unlocked Shared_Resource "&
               Var_Strings.To_String(Shared_Resources.Name(Sh_Ref))&
               " not found");
            raise Object_Not_Found;
         else
            Shared_Resources_List.Update
              (Iterator,Shared_Resources.Lists.Item
               (The_Index,Res_List),Op.Unlocked_Shared_Resources);
         end if;
         Shared_Resources_List.Get_Next_Item
           (Sh_Ref,Op.Unlocked_Shared_Resources,Iterator);
      end loop;
   end Adjust;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (Op : in out Composite_Operation;
      Res_List : in Shared_Resources.Lists.List;
      Op_List : in Lists.List)
   is
      Iterator : Op_Lists.Iteration_Object;
      Op_Ref : Operation_Ref;
   begin
      Op_Lists.Rewind(Op.Op_List,Iterator);
      for I in 1..Op_Lists.Size(Op.Op_List) loop
         Op_Ref:=Op_Lists.Item(Iterator,Op.Op_List);
         Adjust_Ref(Op_Ref,Op_List);
         Op_Lists.Update(Iterator,Op_Ref,Op.Op_List);
         Op_Lists.Get_Next_Item(Op_Ref,Op.Op_List,Iterator);
      end loop;
   exception
      when Object_Not_Found =>
         Set_Exception_Message
           ("Error in Composite_Operation "&Var_Strings.To_String(Op.Name)&
            ": "&Get_Exception_Message);
         raise;
   end Adjust;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (Op : in out Message_Transmission_Operation;
      Res_List : in Shared_Resources.Lists.List;
      Op_List : in Lists.List)
   is
   begin
      null; -- Message transmission ops have no objects requiring adjustment
   end Adjust;

   ----------------
   -- Adjust_Ref --
   ----------------

   procedure Adjust_Ref
     (Op_Ref : in out Operation_Ref;
      The_List : Lists.List)
   is
      Ind : Lists.Index;
   begin
      if Op_Ref/=null then
         Ind:=Lists.Find(Op_Ref.Name,The_List);
         if Ind=Lists.Null_Index then
            Set_Exception_Message
              ("Operation "&Var_Strings.To_String(Op_Ref.Name)&" not found");
            raise Object_Not_Found;
         else
            Op_Ref:=Lists.Item(Ind,The_List);
         end if;
      end if;
   end Adjust_Ref;

   -----------------------------
   -- Stack_Unlocked_Resource --
   -----------------------------

   procedure Stack_Unlocked_Resource
     (Op : in out Simple_Operation;
      Resource : MAST.Shared_Resources.Shared_Resource_Ref)
   is
   begin
      Shared_Resources_List.Stack
        (Resource,Op.Unlocked_Shared_Resources);
   end Stack_Unlocked_Resource;

   ------------------
   -- Add_Resource --
   ------------------

   procedure Add_Resource
     (Op : in out Simple_Operation;
      Resource : MAST.Shared_Resources.Shared_Resource_Ref)
   is
   begin
      Add_Locked_Resource(Op,Resource);
      Stack_Unlocked_Resource(Op,Resource);
   end Add_Resource;

   -----------------------------
   -- Avg_Case_Execution_Time --
   -----------------------------

   function Avg_Case_Execution_Time
     (Op : Simple_Operation;
      Throughput : Throughput_Value)
     return Normalized_Execution_Time
   is
   begin
      return Op.Avg_Case_Execution_Time*Op.Scale_Factor;
   end Avg_Case_Execution_Time;

   -----------------------------
   -- Avg_Case_Execution_Time --
   -----------------------------

   function Avg_Case_Execution_Time
     (Op : Enclosing_Operation;
      Throughput : Throughput_Value)
     return Normalized_Execution_Time
   is
   begin
      return Op.Avg_Case_Execution_Time*Op.Scale_Factor;
   end Avg_Case_Execution_Time;

   ------------------------
   -- Avg_Case_Execution_Time --
   ------------------------

   function Avg_Case_Execution_Time
     (Op : in Composite_Operation;
      Throughput : Throughput_Value)
     return Normalized_Execution_Time
   is
      Exec_Time : Normalized_Execution_Time:=0.0;
      An_Op : Operation_Ref;
      Iterator : Op_Lists.Index;
   begin
      Op_Lists.Rewind(Op.Op_List,Iterator);
      for I in 1..Op_Lists.Size(Op.Op_List) loop
         Op_Lists.Get_Next_Item(An_Op,Op.Op_List,Iterator);
         Exec_Time:=Exec_Time+Avg_Case_Execution_Time(An_Op.all,Throughput);
      end loop;
      return Exec_Time;
   end Avg_Case_Execution_Time;

   -----------------------------
   -- Avg_Case_Execution_Time --
   -----------------------------

   function Avg_Case_Execution_Time
     (Op : Message_Transmission_Operation;
      Throughput : Throughput_Value)
     return Normalized_Execution_Time
   is
   begin
      return (Op.Avg_Message_Size/Throughput)*Op.Scale_Factor;
   end Avg_Case_Execution_Time;

   ----------------------
   -- Avg_Message_Size --
   ----------------------

   function Avg_Message_Size
     (Op : Message_Transmission_Operation)
     return Bit_Count
   is
   begin
      return Op.Avg_Message_Size*Bit_Count(Op.Scale_Factor);
   end Avg_Message_Size;

   ------------------------------
   -- Best_Case_Execution_Time --
   ------------------------------

   function Best_Case_Execution_Time
     (Op : Simple_Operation;
      Throughput : Throughput_Value)
     return Normalized_Execution_Time
   is
   begin
      return Op.Best_Case_Execution_Time*Op.Scale_Factor;
   end Best_Case_Execution_Time;

   ------------------------------
   -- Best_Case_Execution_Time --
   ------------------------------

   function Best_Case_Execution_Time
     (Op : Enclosing_Operation;
      Throughput : Throughput_Value)
     return Normalized_Execution_Time
   is
   begin
      return Op.Best_Case_Execution_Time*Op.Scale_Factor;
   end Best_Case_Execution_Time;

   ------------------------------
   -- Best_Case_Execution_Time --
   ------------------------------

   function Best_Case_Execution_Time
     (Op : in Composite_Operation;
      Throughput : Throughput_Value)
     return Normalized_Execution_Time
   is
      Exec_Time : Normalized_Execution_Time:=0.0;
      An_Op : Operation_Ref;
      Iterator : Op_Lists.Index;
   begin
      Op_Lists.Rewind(Op.Op_List,Iterator);
      for I in 1..Op_Lists.Size(Op.Op_List) loop
         Op_Lists.Get_Next_Item(An_Op,Op.Op_List,Iterator);
         Exec_Time:=Exec_Time+Best_Case_Execution_Time(An_Op.all,Throughput);
      end loop;
      return Exec_Time;
   end Best_Case_Execution_Time;

   ------------------------------
   -- Best_Case_Execution_Time --
   ------------------------------

   function Best_Case_Execution_Time
     (Op : Message_Transmission_Operation;
      Throughput : Throughput_Value)
     return Normalized_Execution_Time
   is
   begin
      return (Op.Min_Message_Size/Throughput)*Op.Scale_Factor;
   end Best_Case_Execution_Time;

   -----------
   -- Clone --
   -----------
   -- Requires later adjustment

   function Clone
     (The_List : Shared_Resources_List.List)
     return Shared_Resources_List.List
   is
      The_Copy : Shared_Resources_List.List;
      Iterator : Shared_Resources_List.Iteration_Object;
      Res_Ref : Shared_Resources.Shared_Resource_Ref;
   begin
      Shared_Resources_List.Rewind(The_List,Iterator);
      for I in 1..Shared_Resources_List.Size(The_List) loop
         Shared_Resources_List.Get_Next_Item(Res_Ref,The_List,Iterator);
         Shared_Resources_List.Add(Res_Ref,The_Copy);
      end loop;
      return The_Copy;
   end Clone;

   -----------
   -- Clone --
   -----------
   -- Requires later adjustment

   function Clone
     (The_List : in Lists.List)
     return Lists.List
   is
      The_Copy : Lists.List;
      Iterator : Lists.Iteration_Object;
      Op_Ref, Op_Ref_Copy : Operation_Ref;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Op_Ref,The_List,Iterator);
         Op_Ref_Copy:=Clone(Op_Ref.all);
         Lists.Add(Op_Ref_Copy,The_Copy);
      end loop;
      return The_Copy;
   end Clone;

   -----------
   -- Clone --
   -----------
   -- Requires later adjustment

   function Clone
     (The_List : in Op_Lists.List)
     return Op_Lists.List
   is
      The_Copy : Op_Lists.List;
      Iterator : Op_Lists.Iteration_Object;
      Op_Ref : Operation_Ref;
   begin
      Op_Lists.Rewind(The_List,Iterator);
      for I in 1..Op_Lists.Size(The_List) loop
         Op_Lists.Get_Next_Item(Op_Ref,The_List,Iterator);
         Op_Lists.Add(Op_Ref,The_Copy);
      end loop;
      return The_Copy;
   end Clone;

   -----------
   -- Clone --
   -----------
   -- Requires later adjustment

   function Clone
     (Op : Simple_Operation)
     return  Operation_Ref
   is
      Op_Ref : Operation_Ref;
   begin
      Op_Ref:=new Simple_Operation'(Op);
      if Op.New_Sched_Parameters/=null then
         Simple_Operation(Op_Ref.all).New_Sched_Parameters:=
           Scheduling_Parameters.Clone(Op.New_Sched_Parameters.all);
      end if;
      Simple_Operation(Op_Ref.all).Locked_Shared_Resources:=
        Clone(Op.Locked_Shared_Resources);
      Simple_Operation(Op_Ref.all).Unlocked_Shared_Resources:=
        Clone(Op.Unlocked_Shared_Resources);
      return Op_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------
   -- Requires later adjustment

   function Clone
     (Op : Composite_Operation)
     return  Operation_Ref
   is
      Op_Ref : Operation_Ref;
   begin
      Op_Ref:=new Composite_Operation;
      Composite_Operation(Op_Ref.all).Name:=
        Op.Name;
      if Op.New_Sched_Parameters/=null then
         Composite_Operation(Op_Ref.all).New_Sched_Parameters:=
           Scheduling_Parameters.Clone(Op.New_Sched_Parameters.all);
      end if;
      Composite_Operation(Op_Ref.all).Op_List:=
        Clone(Op.Op_List);
      return Op_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------
   -- Requires later adjustment

   function Clone
     (Op : Enclosing_Operation)
     return  Operation_Ref
   is
      Op_Ref : Operation_Ref;
   begin
      Op_Ref:=new Enclosing_Operation;
      Enclosing_Operation(Op_Ref.all).Name:=
        Op.Name;
      if Op.New_Sched_Parameters/=null then
         Enclosing_Operation(Op_Ref.all).New_Sched_Parameters:=
           Scheduling_Parameters.Clone(Op.New_Sched_Parameters.all);
      end if;
      Enclosing_Operation(Op_Ref.all).Op_List:=
        Clone(Op.Op_List);
      Enclosing_Operation(Op_Ref.all).Worst_Case_Execution_Time:=
        Op.Worst_Case_Execution_Time;
      Enclosing_Operation(Op_Ref.all).Best_Case_Execution_Time:=
        Op.Best_Case_Execution_Time;
      Enclosing_Operation(Op_Ref.all).Avg_Case_Execution_Time:=
        Op.Avg_Case_Execution_Time;
      return Op_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Op : Message_Transmission_Operation)
     return Operation_Ref
   is
      Op_Ref : Operation_Ref;
   begin
      Op_Ref:=new Message_Transmission_Operation'(Op);
      return Op_Ref;
   end Clone;

   ---------------------
   -- Get_Next_Operation --
   ---------------------

   procedure Get_Next_Operation
     (Comp_Op : in Composite_Operation;
      Op : out Operation_Ref;
      Iterator : in out Operation_Iteration_Object)
   is
   begin
      Op_Lists.Get_Next_Item(Op,Comp_Op.Op_List,Op_Lists.Index(Iterator));
   end Get_Next_Operation;

   ------------------------------
   -- Get_Next_Locked_Resource --
   ------------------------------

   procedure Get_Next_Locked_Resource
     (Op : in Simple_Operation;
      Resource : out MAST.Shared_Resources.Shared_Resource_Ref;
      Iterator : in out Resource_Iteration_Object)
   is
   begin
      Shared_Resources_List.Get_Next_Item
        (Resource,Op.Locked_Shared_Resources,
         Shared_Resources_List.Index(Iterator));
   end Get_Next_Locked_Resource;

   --------------------------------
   -- Get_Next_Unlocked_Resource --
   --------------------------------

   procedure Get_Next_Unlocked_Resource
     (Op : in Simple_Operation;
      Resource : out MAST.Shared_Resources.Shared_Resource_Ref;
      Iterator : in out Resource_Iteration_Object)
   is
   begin
      Shared_Resources_List.Get_Next_Item
        (Resource,Op.Unlocked_Shared_Resources,
         Shared_Resources_List.Index(Iterator));
   end Get_Next_Unlocked_Resource;

   ----------
   -- Init --
   ----------

   procedure Init
     (Op : in out Operation;
      Name : Var_Strings.Var_String)
   is
   begin
      Op.Name:=Name;
   end Init;

   -------------------------------
   -- List_References_Operation --
   -------------------------------

   function List_References_Operation
     (Op_Ref : Operation_Ref;
      The_List : Lists.List)
     return Boolean
   is
      function Operation_References_Operation
        (Destination : Operation_Ref;
         Source      : Composite_Operation)
        return Boolean
      is
         Iterator : Op_Lists.Index;
         Op_List : Op_Lists.List;
         Oper_Ref : Operation_Ref;
      begin
         Op_List:=Source.Op_List;
         Op_Lists.Rewind(Op_List,Iterator);
         for I in 1..Op_Lists.Size(Op_List) loop
            Op_Lists.Get_Next_Item(Oper_Ref,Op_List,Iterator);
            if Oper_Ref.all in Composite_Operation'class and then
              Operation_References_Operation
              (Destination, Composite_Operation(Oper_Ref.all))
            then
               return True;
            else
               if Oper_Ref=Destination then
                  return True;
               end if;
            end if;
         end loop;
         return False;
      end Operation_References_Operation;

      Oper_Ref : Operation_Ref;
      Iterator : Lists.Index;

   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Oper_Ref,The_List,Iterator);
         if Oper_Ref.all in Composite_Operation'class and then
           Operation_References_Operation
           (Op_Ref, Composite_Operation(Oper_Ref.all))
         then
            return True;
         end if;
      end loop;
      return False;
   end List_References_Operation;

   -------------------------------------
   -- List_References_Shared_Resource --
   -------------------------------------

   function List_References_Shared_Resource
     (Sr_Ref : Shared_Resources.Shared_Resource_Ref;
      The_List : Lists.List)
     return Boolean
   is
      function List_References_Shared_Resource
        (Sr_Ref : Shared_Resources.Shared_Resource_Ref;
         Sr_List: Shared_Resources_List.List)
        return Boolean
      is
         Iterator : Shared_Resources_List.Index;
         Res_Ref : Shared_Resources.Shared_Resource_Ref;
      begin
         Shared_Resources_List.Rewind(Sr_List,Iterator);
         for I in 1..Shared_Resources_List.Size(Sr_List)
         loop
            Shared_Resources_List.Get_Next_Item(Res_Ref,Sr_List,Iterator);
            if Res_Ref=Sr_Ref then
               return True;
            end if;
         end loop;
         return False;
      end List_References_Shared_Resource;

      function Operation_References_Shared_Resource
        (Sr_Ref : Shared_Resources.Shared_Resource_Ref;
         Oper   : Operation'class)
        return Boolean
      is
         Iterator : Op_Lists.Index;
         Op_List : Op_Lists.List;
         Oper_Ref : Operation_Ref;
      begin
         if Oper in Simple_Operation'Class then
            return List_References_Shared_Resource
              (Sr_Ref,Simple_Operation(Oper).Locked_Shared_Resources) or else
              List_References_Shared_Resource
              (Sr_Ref,Simple_Operation(Oper).Unlocked_Shared_Resources);
         elsif Oper in Composite_Operation'Class then
            Op_List:=Composite_Operation(Oper).Op_List;
            Op_Lists.Rewind(Op_List,Iterator);
            for I in 1..Op_Lists.Size(Op_List) loop
               Op_Lists.Get_Next_Item(Oper_Ref,Op_List,Iterator);
               if Operation_References_Shared_Resource
                 (Sr_Ref, Oper_Ref.all)
               then
                  return True;
               end if;
            end loop;
            return False;
         else -- other operations do not use shared resources
            return False;
         end if;
      end Operation_References_Shared_Resource;

      Oper_Ref : Operation_Ref;
      Iterator : Lists.Index;

   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Oper_Ref,The_List,Iterator);
         if Operation_References_Shared_Resource
           (Sr_Ref, Oper_Ref.all)
         then
            return True;
         end if;
      end loop;
      return False;
   end List_References_Shared_Resource;


   ----------------------
   -- Max_Message_Size --
   ----------------------

   function Max_Message_Size
     (Op : Message_Transmission_Operation)
     return Bit_Count
   is
   begin
      return Op.Max_Message_Size*Bit_Count(Op.Scale_Factor);
   end Max_Message_Size;

   ----------------------
   -- Min_Message_Size --
   ----------------------

   function Min_Message_Size
     (Op : Message_Transmission_Operation)
     return Bit_Count
   is
   begin
      return Op.Min_Message_Size*Bit_Count(Op.Scale_Factor);
   end Min_Message_Size;

   ----------
   -- Name --
   ----------

   function Name
     (Op : Operation)
     return Var_Strings.Var_String
   is
   begin
      return Op.Name;
   end Name;

   ----------
   -- Name --
   ----------

   function Name
     (Op_Ref : Operation_Ref)
     return Var_Strings.Var_String
   is
   begin
      return Op_Ref.Name;
   end Name;

   --------------------------
   -- New_Sched_Parameters --
   --------------------------

   function New_Sched_Parameters
     (Op : Operation)
     return MAST.Scheduling_Parameters.Overridden_Sched_Parameters_Ref
   is
   begin
      return Op.New_Sched_Parameters;
   end New_Sched_Parameters;

   --------------------
   -- Num_Of_Operations --
   --------------------

   function Num_Of_Operations
     (Comp_Op : Composite_Operation)
     return Natural
   is
   begin
      return Op_Lists.Size(Comp_Op.Op_List);
   end Num_Of_Operations;

   -----------------------------
   -- Num_Of_Locked_Resources --
   -----------------------------

   function Num_Of_Locked_Resources
     (Op : Simple_Operation)
     return Natural
   is
   begin
      return Shared_Resources_List.Size(Op.Locked_Shared_Resources);
   end Num_Of_Locked_Resources;

   -------------------------------
   -- Num_Of_Unlocked_Resources --
   -------------------------------

   function Num_Of_Unlocked_Resources
     (Op : Simple_Operation)
     return Natural
   is
   begin
      return Shared_Resources_List.Size(Op.Unlocked_Shared_Resources);
   end Num_Of_Unlocked_Resources;


   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"Operation (");
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Simple_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True)
   is
      Names_Length : constant Positive := 26;
      Res_Ref : Shared_Resources.Shared_Resource_Ref;
      Iterator : Shared_Resources_List.Index;
   begin
      if Complete then
         Print(File,Operation(Res),Indentation);
      else
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put(File,"  (");
      end if;
      MAST.IO.Print_Arg
        (File,"Type",
         "Simple",Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Res.Name),Indentation+3,Names_Length);
      if Res.New_Sched_Parameters /= null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"New_Sched_Parameters","",
            Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File,"");
         MAST.Scheduling_Parameters.Print
           (File,Res.New_Sched_Parameters.all,Indentation+6);
      end if;
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Worst_Case_Execution_Time",
         IO.Execution_Time_Image(Res.Worst_Case_Execution_Time*
                                 Res.Scale_Factor),
         Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Avg_Case_Execution_Time",
         IO.Execution_Time_Image(Res.Avg_Case_Execution_Time*
                                 Res.Scale_Factor),
         Indentation+3,
         Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Best_Case_Execution_Time",
         IO.Execution_Time_Image(Res.Best_Case_Execution_Time*
                                 Res.Scale_Factor),
         Indentation+3,Names_Length);
      if Shared_Resources_List.Size(Res.Locked_Shared_Resources)>0 then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg(File,"Shared_Resources_To_Lock","",
                           Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File,MAST.IO.Nothing);
         MAST.IO.Print_List_Item(File,MAST.IO.Left_Paren,Indentation+6);
         Shared_Resources_List.Rewind(Res.Locked_Shared_Resources,Iterator);
         for I in 1..Shared_Resources_List.Size
           (Res.Locked_Shared_Resources)
         loop
            if I>1 then
               MAST.IO.Print_Separator(File);
            end if;
            Shared_Resources_List.Get_Next_Item
              (Res_Ref,Res.Locked_Shared_Resources,Iterator);
            MAST.IO.Print_List_Item
              (File,IO.Name_Image
               (MAST.Shared_Resources.Name(Res_Ref)),
               Indentation+8);
         end loop;
         Ada.Text_IO.Put(File,")");
      end if;
      if Shared_Resources_List.Size(Res.Unlocked_Shared_Resources)>0
      then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg(File,"Shared_Resources_To_Unlock","",
                           Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File,MAST.IO.Nothing);
         MAST.IO.Print_List_Item(File,MAST.IO.Left_Paren,
                                 Indentation+6);
         Shared_Resources_List.Rewind(Res.Unlocked_Shared_Resources,Iterator);
         for I in 1..Shared_Resources_List.Size
           (Res.Unlocked_Shared_Resources)
         loop
            if I>1 then
               MAST.IO.Print_Separator(File);
            end if;
            Shared_Resources_List.Get_Next_Item
              (Res_Ref,Res.Unlocked_Shared_Resources,Iterator);
            MAST.IO.Print_List_Item
              (File,IO.Name_Image
               (MAST.Shared_Resources.Name(Res_Ref)),
               Indentation+8);
         end loop;
         Ada.Text_IO.Put(File,")");
      end if;
      if Complete then
         MAST.IO.Print_Separator(File,MAST.IO.Comma,Finalize);
      else
         Ada.Text_IO.Put(File,")");
      end if;
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Composite_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True)
   is
      Names_Length : constant Positive := 24;
      Res_Ref : Operation_Ref;
      Iterator : Op_Lists.Index;
   begin
      Print(File,Operation(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Composite",Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Res.Name),Indentation+3,Names_Length);
      if Res.New_Sched_Parameters /= null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"New_Sched_Parameters","",
            Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File,"");
         MAST.Scheduling_Parameters.Print
           (File,Res.New_Sched_Parameters.all,Indentation+6);
      end if;
      if Op_Lists.Size(Res.Op_List) > 0 then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg(File,"Composite_Operation_List","",
                           Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File,MAST.IO.Nothing);
         MAST.IO.Print_List_Item(File,MAST.IO.Left_Paren,
                                 Indentation+6);
         Op_Lists.Rewind(Res.Op_List,Iterator);
         for I in 1..Op_Lists.Size(Res.Op_List) loop
            if I>1 then
               MAST.IO.Print_Separator(File);
            end if;
            Op_Lists.Get_Next_Item(Res_Ref,Res.Op_List,Iterator);
            MAST.IO.Print_List_Item
              (File,
               IO.Name_Image(MAST.Operations.Name(Res_Ref)),
               Indentation+8);
         end loop;
         Ada.Text_IO.Put(File,")");
      end if;
      MAST.IO.Print_Separator(File,MAST.IO.Comma,Finalize);
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Enclosing_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True)
   is
      Names_Length : constant Positive := 24;
      Res_Ref : Operation_Ref;
      Iterator : Op_Lists.Index;
   begin
      Print(File,Operation(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Enclosing",Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Res.Name),Indentation+3,Names_Length);
      if Res.New_Sched_Parameters /= null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"New_Sched_Parameters","",
            Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File,"");
         MAST.Scheduling_Parameters.Print
           (File,Res.New_Sched_Parameters.all,Indentation+6);
      end if;
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Worst_Case_Execution_Time",
         IO.Execution_Time_Image(Res.Worst_Case_Execution_Time*
                                 Res.Scale_Factor),
         Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Avg_Case_Execution_Time",
         IO.Execution_Time_Image(Res.Avg_Case_Execution_Time*
                                 Res.Scale_Factor),
         Indentation+3,
         Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Best_Case_Execution_Time",
         IO.Execution_Time_Image(Res.Best_Case_Execution_Time*
                                 Res.Scale_Factor),
         Indentation+3,Names_Length);
      if Op_Lists.Size(Res.Op_List) > 0 then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg(File,"Composite_Operation_List","",
                           Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File,MAST.IO.Nothing);
         MAST.IO.Print_List_Item(File,MAST.IO.Left_Paren,
                                 Indentation+6);
         Op_Lists.Rewind(Res.Op_List,Iterator);
         for I in 1..Op_Lists.Size(Res.Op_List) loop
            if I>1 then
               MAST.IO.Print_Separator(File);
            end if;
            Op_Lists.Get_Next_Item(Res_Ref,Res.Op_List,Iterator);
            MAST.IO.Print_List_Item
              (File,
               IO.Name_Image(MAST.Operations.Name(Res_Ref)),
               Indentation+8);
         end loop;
         Ada.Text_IO.Put(File,")");
      end if;
      MAST.IO.Print_Separator(File,MAST.IO.Comma,Finalize);
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Message_Transmission_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True)
   is
      Names_Length : constant Positive := 26;
   begin
      if Complete then
         Print(File,Operation(Res),Indentation);
      else
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put(File,"  (");
      end if;
      MAST.IO.Print_Arg
        (File,"Type",
         "Message_Transmission",Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Res.Name),Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Max_Message_Size",
         IO.Bit_Count_Image(Res.Max_Message_Size*
                            Bit_Count(Res.Scale_Factor)),
         Indentation+3,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Avg_Message_Size",
         IO.Bit_Count_Image(Res.Avg_Message_Size*
                            Bit_Count(Res.Scale_Factor)),
         Indentation+3,
         Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Min_Message_Size",
         IO.Bit_Count_Image(Res.Min_Message_Size*
                            Bit_Count(Res.Scale_Factor)),
         Indentation+3,Names_Length);
      if Complete then
         MAST.IO.Print_Separator(File,MAST.IO.Comma,Finalize);
      else
         Ada.Text_IO.Put(File,")");
      end if;
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Operation_Ref;
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
      Op : Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant := 8;
   begin
      -- Print only if there are results
      if Op.The_Slack_Result/=null then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put(File,"Operation (");
         MAST.IO.Print_Arg
           (File,"Name",
            IO.Name_Image(Op.Name),Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg
           (File,"Results","",Indentation+3,Names_Length);
         MAST.IO.Print_Separator(File,MAST.IO.Nothing);
         MAST.IO.Print_List_Item(File,MAST.IO.Left_Paren,
                                 Indentation+7);
         Results.Print(File,Op.The_Slack_Result.all,Indentation+8);
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
      Op_Ref : Operation_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Op_Ref,The_List,Iterator);
         Print_Results(File,Op_Ref.all,Indentation,True);
      end loop;
   end Print_Results;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Simple_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True)
   is
      Names_Length : constant Positive := 26;
      Res_Ref : Shared_Resources.Shared_Resource_Ref;
      Iterator : Shared_Resources_List.Index;
   begin
      if Complete then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put(File,"<mast_mdl:Simple_Operation ");
      end if;
      Ada.Text_IO.Put(File,"Name=""" & IO.Name_Image(Res.Name) & """ ");
      Ada.Text_IO.Put(File,"Worst_Case_Execution_Time=""" &
                      IO.Execution_Time_Image(Res.Worst_Case_Execution_Time*
                                              Res.Scale_Factor) & """ ");
      Ada.Text_IO.Put(File,"Average_Case_Execution_Time=""" &
                      IO.Execution_Time_Image(Res.Avg_Case_Execution_Time*
                                              Res.Scale_Factor) & """ ");
      Ada.Text_IO.Put_Line
        (File,"Best_Case_Execution_Time=""" &
         IO.Execution_Time_Image(Res.Best_Case_Execution_Time*
                                 Res.Scale_Factor) & """> ");
      if Res.New_Sched_Parameters /= null then
         MAST.Scheduling_Parameters.Print_XML
           (File,Res.New_Sched_Parameters.all,Indentation+3,False);
      end if;
      if Shared_Resources_List.Size(Res.Locked_Shared_Resources)>0 then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put(File,"<mast_mdl:Shared_Resources_To_Lock>");
         Shared_Resources_List.Rewind(Res.Locked_Shared_Resources,Iterator);
         for I in 1..Shared_Resources_List.Size
           (Res.Locked_Shared_Resources)
         loop
            Shared_Resources_List.Get_Next_Item
              (Res_Ref,Res.Locked_Shared_Resources,Iterator);
            Ada.Text_IO.Put(File,IO.Name_Image
                            (MAST.Shared_Resources.Name(Res_Ref)));
            if I/=Shared_Resources_List.Size(Res.Locked_Shared_Resources)
            then
               Ada.Text_IO.Put(File," ");
            end if;
         end loop;
         Ada.Text_IO.Put_Line(File,"</mast_mdl:Shared_Resources_To_Lock> ");
      end if;
      if Shared_Resources_List.Size(Res.Unlocked_Shared_Resources)>0
      then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put(File,"<mast_mdl:Shared_Resources_To_Unlock>");
         Shared_Resources_List.Rewind(Res.Unlocked_Shared_Resources,Iterator);
         for I in 1..Shared_Resources_List.Size
           (Res.UnLocked_Shared_Resources)
         loop
            Shared_Resources_List.Get_Next_Item
              (Res_Ref,Res.Unlocked_Shared_Resources,Iterator);
            Ada.Text_IO.Put(File,IO.Name_Image
                            (MAST.Shared_Resources.Name(Res_Ref)));
            if I/=Shared_Resources_List.Size(Res.Unlocked_Shared_Resources)
            then
               Ada.Text_IO.Put(File," ");
            end if;
         end loop;
         Ada.Text_IO.Put_Line(File,"</mast_mdl:Shared_Resources_To_Unlock> ");
      end if;
      if Complete then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put_Line(File,"</mast_mdl:Simple_Operation> ");
      end if;
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Composite_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True)
   is
      Names_Length : constant Positive := 24;
      Res_Ref : Operation_Ref;
      Iterator : Op_Lists.Index;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_mdl:Composite_Operation ");
      Ada.Text_IO.Put_Line(File,"Name=""" & IO.Name_Image(Res.Name) & """> ");
      if Res.New_Sched_Parameters /= null
      then
         MAST.Scheduling_Parameters.Print_XML
           (File,Res.New_Sched_Parameters.all,Indentation+3,False);
      end if;

      if Op_Lists.Size(Res.Op_List) > 0 then

         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put(File,"<mast_mdl:Operation_List>");
         Op_Lists.Rewind(Res.Op_List,Iterator);
         for I in 1..Op_Lists.Size(Res.Op_List) loop
            Op_Lists.Get_Next_Item(Res_Ref,Res.Op_List,Iterator);
            Ada.Text_IO.Put(File,IO.Name_Image
                            (MAST.Operations.Name(Res_Ref)));
            if I/=Op_Lists.Size(Res.Op_List)
            then
               Ada.Text_IO.Put(File," ");
            end if;
         end loop;
         Ada.Text_IO.Put_Line(File,"</mast_mdl:Operation_List> ");
      end if;
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
      Ada.Text_IO.Put_Line(File,"</mast_mdl:Composite_Operation> ");
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Enclosing_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True)
   is
      Names_Length : constant Positive := 24;
      Res_Ref : Operation_Ref;
      Iterator : Op_Lists.Index;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_mdl:Enclosing_Operation ");
      Ada.Text_IO.Put(File,"Name=""" & IO.Name_Image(Res.Name) & """ ");
      Ada.Text_IO.Put(File,"Worst_Case_Execution_Time=""" &
                      IO.Execution_Time_Image(Res.Worst_Case_Execution_Time*
                                              Res.Scale_Factor) & """ ");
      Ada.Text_IO.Put(File,"Average_Case_Execution_Time=""" &
                      IO.Execution_Time_Image(Res.Avg_Case_Execution_Time*
                                              Res.Scale_Factor) & """ ");
      Ada.Text_IO.Put_Line
        (File,"Best_Case_Execution_Time=""" &
         IO.Execution_Time_Image(Res.Best_Case_Execution_Time*
                                 Res.Scale_Factor) & """> ");

      if Res.New_Sched_Parameters /= null then
         MAST.Scheduling_Parameters.Print_XML
           (File,Res.New_Sched_Parameters.all,Indentation+3,False);
      end if;
      if Op_Lists.Size(Res.Op_List) > 0
      then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation+3));
         Ada.Text_IO.Put(File,"<mast_mdl:Operation_List>");
         Op_Lists.Rewind(Res.Op_List,Iterator);
         for I in 1..Op_Lists.Size(Res.Op_List) loop
            Op_Lists.Get_Next_Item(Res_Ref,Res.Op_List,Iterator);
            Ada.Text_IO.Put(File,IO.Name_Image
                            (MAST.Operations.Name(Res_Ref)));
            if I/=Op_Lists.Size(Res.Op_List)
            then
               Ada.Text_IO.Put(File," ");
            end if;
         end loop;
         Ada.Text_IO.Put_Line(File,"</mast_mdl:Operation_List> ");
      end if;
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put_Line(File,"</mast_mdl:Enclosing_Operation> ");
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Message_Transmission_Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Complete    : Boolean:=True)
   is
      Names_Length : constant Positive := 26;
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_mdl:Message_Transmission ");
      Ada.Text_IO.Put(File,"Name=""" & IO.Name_Image(Res.Name) & """ ");
      Ada.Text_IO.Put(File,"Max_Message_Size=""" &
                      IO.Bit_Count_Image
                      (Res.Max_Message_Size*
                       Bit_Count(Res.Scale_Factor)) & """ ");
      Ada.Text_IO.Put(File,"Avg_Message_Size=""" &
                      IO.Bit_Count_Image
                      (Res.Avg_Message_Size*
                       Bit_Count(Res.Scale_Factor)) & """ ");
      Ada.Text_IO.Put_Line(File,"Min_Message_Size=""" &
                           IO.Bit_Count_Image
                           (Res.Min_Message_Size*
                            Bit_Count(Res.Scale_Factor)) & """ >");
      if Res.New_Sched_Parameters /= null
      then
         MAST.Scheduling_Parameters.Print_XML
           (File,Res.New_Sched_Parameters.all,Indentation+3,False);
      end if;
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put_Line(File,"</mast_mdl:Message_Transmission> ");
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Operation_Ref;
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
   -- Print_XML_results          --
   --------------------------------

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      Op : Operation;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant := 8;
   begin

      -- Print only if there are results
      if Op.The_Slack_Result/=null then
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put_Line(File,"<mast_res:Operation Name="""&
                              IO.Name_Image(Op.Name)&""">");
         Results.Print_XML(File,Op.The_Slack_Result.all,Indentation+3,False);
         Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
         Ada.Text_IO.Put_Line(File,"</mast_res:Operation>");
         Ada.Text_IO.New_Line(File);
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
      Op_Ref : Operation_Ref;
      Iterator : Lists.Index;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Op_Ref,The_List,Iterator);
         Print_XML_Results(File,Op_Ref.all,Indentation,True);
      end loop;
   end Print_XML_Results;

   --------------------
   -- Relative_Scale --
   --------------------

   procedure Relative_Scale
     (The_List : in Lists.List; Factor : Normalized_Execution_Time)
   is
      Iterator : Lists.Iteration_Object;
      Op_Ref : Operation_Ref;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Op_Ref,The_List,Iterator);
         Relative_Scale(Op_Ref.all,Factor);
      end loop;
   end Relative_Scale;

   --------------------
   -- Relative_Scale --
   --------------------

   procedure Relative_Scale
     (Op : in out Simple_Operation; Factor : Normalized_Execution_Time)
   is
   begin
      Op.Worst_Case_Execution_Time :=Factor*Op.Worst_Case_Execution_Time;
   end Relative_Scale;

   --------------------
   -- Relative_Scale --
   --------------------

   procedure Relative_Scale
     (Op : in out Composite_Operation; Factor : Normalized_Execution_Time)
   is
      Simple_Op : Operation_Ref;
      Iterator : Op_Lists.Index;
   begin
      Op_Lists.Rewind(Op.Op_List,Iterator);
      for I in 1..Op_Lists.Size(Op.Op_List) loop
         Op_Lists.Get_Next_Item(Simple_Op,Op.Op_List,Iterator);
         Relative_Scale(Simple_Op.all,Factor);
      end loop;
   end Relative_Scale;

   --------------------
   -- Relative_Scale --
   --------------------

   procedure Relative_Scale
     (Op : in out Enclosing_Operation; Factor : Normalized_Execution_Time)
   is
   begin
      Op.Worst_Case_Execution_Time :=Factor*Op.Worst_Case_Execution_Time;
   end Relative_Scale;

   --------------------
   -- Relative_Scale --
   --------------------

   procedure Relative_Scale
     (Op : in out Message_Transmission_Operation;
      Factor : Normalized_Execution_Time)
   is
   begin
      Op.Max_Message_Size :=Bit_Count(Factor)*Op.Max_Message_Size;
   end Relative_Scale;

   ----------------------------
   -- Remove_Locked_Resource --
   ----------------------------

   procedure Remove_Locked_Resource
     (Op : in out Simple_Operation;
      Resource : MAST.Shared_Resources.Shared_Resource_Ref)
   is
      Ind : Shared_Resources_List.Index;
      Res_Ref : MAST.Shared_Resources.Shared_Resource_Ref;
   begin
      Ind:=Shared_Resources_List.Find(Resource,Op.Locked_Shared_Resources);
      if Ind=Shared_Resources_List.Null_Index then
         raise List_Exceptions.Not_Found;
      end if;
      Shared_Resources_List.Delete(Ind,Res_Ref,Op.Locked_Shared_Resources);
   end Remove_Locked_Resource;

   ----------------------
   -- Remove_Operation --
   ----------------------

   procedure Remove_Operation
     (Comp_Op : in out Composite_Operation;
      Op : Operation_Ref)
   is
      Ind : Op_Lists.Index;
      Op_Ref : Operation_Ref;
   begin
      Ind:=Op_Lists.Find(Op,Comp_Op.Op_List);
      if Ind=Op_Lists.Null_Index then
         raise List_Exceptions.Not_Found;
      end if;
      Op_Lists.Delete(Ind,Op_Ref,Comp_Op.Op_List);
   end Remove_Operation;


   ------------------------------
   -- Remove_Unlocked_Resource --
   ------------------------------

   procedure Remove_Unlocked_Resource
     (Op : in out Simple_Operation;
      Resource : MAST.Shared_Resources.Shared_Resource_Ref)
   is
      Ind : Shared_Resources_List.Index;
      Res_Ref : MAST.Shared_Resources.Shared_Resource_Ref;
   begin
      Ind:=Shared_Resources_List.Find(Resource,Op.Unlocked_Shared_Resources);
      if Ind=Shared_Resources_List.Null_Index then
         raise List_Exceptions.Not_Found;
      end if;
      Shared_Resources_List.Delete(Ind,Res_Ref,Op.Unlocked_Shared_Resources);
   end Remove_Unlocked_Resource;

   ---------------------
   -- Remove_Resource --
   ---------------------

   procedure Remove_Resource
     (Op : in out Simple_Operation;
      Resource : MAST.Shared_Resources.Shared_Resource_Ref)
   is
      Ind_Lock,Ind_Unlock : Shared_Resources_List.Index;
      Res_Ref : MAST.Shared_Resources.Shared_Resource_Ref;
   begin
      Ind_Lock:=Shared_Resources_List.Find
        (Resource,Op.Locked_Shared_Resources);
      Ind_Unlock:=Shared_Resources_List.Find
        (Resource,Op.Unlocked_Shared_Resources);
      if Ind_Lock=Shared_Resources_List.Null_Index or else
        Ind_Lock=Shared_Resources_List.Null_Index
      then
         raise List_Exceptions.Not_Found;
      end if;
      Shared_Resources_List.Delete
        (Ind_Lock,Res_Ref,Op.Locked_Shared_Resources);
      Shared_Resources_List.Delete
        (Ind_Unlock,Res_Ref,Op.Unlocked_Shared_Resources);
   end Remove_Resource;

   --------------------
   -- Rewind_Operations --
   --------------------

   procedure Rewind_Operations
     (Comp_Op : in Composite_Operation;
      Iterator : out Operation_Iteration_Object)
   is
   begin
      Op_Lists.Rewind(Comp_Op.Op_List,Op_Lists.Index(Iterator));
   end Rewind_Operations;

   -----------------------------
   -- Rewind_Locked_Resources --
   -----------------------------

   procedure Rewind_Locked_Resources
     (Op : in Simple_Operation;
      Iterator : out Resource_Iteration_Object)
   is
   begin
      Shared_Resources_List.Rewind
        (Op.Locked_Shared_Resources,
         Shared_Resources_List.Index(Iterator));
   end Rewind_Locked_Resources;

   -------------------------------
   -- Rewind_Unlocked_Resources --
   -------------------------------

   procedure Rewind_Unlocked_Resources
     (Op : in Simple_Operation;
      Iterator : out Resource_Iteration_Object)
   is
   begin
      Shared_Resources_List.Rewind
        (Op.Unlocked_Shared_Resources,
         Shared_Resources_List.Index(Iterator));
   end Rewind_Unlocked_Resources;

   -----------
   -- Scale --
   -----------

   procedure Scale
     (The_List : in Lists.List; Factor : Normalized_Execution_Time)
   is
      Iterator : Lists.Iteration_Object;
      Op_Ref : Operation_Ref;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Op_Ref,The_List,Iterator);
         Scale(Op_Ref.all,Factor);
      end loop;
   end Scale;

   -----------
   -- Scale --
   -----------

   procedure Scale
     (Op : in out Simple_Operation; Factor : Normalized_Execution_Time)
   is
   begin
      Op.Scale_Factor:=Factor;
   end Scale;

   -----------
   -- Scale --
   -----------

   procedure Scale
     (Op : in out Composite_Operation; Factor : Normalized_Execution_Time)
   is
      Simple_Op : Operation_Ref;
      Iterator : Op_Lists.Index;
   begin
      Op_Lists.Rewind(Op.Op_List,Iterator);
      for I in 1..Op_Lists.Size(Op.Op_List) loop
         Op_Lists.Get_Next_Item(Simple_Op,Op.Op_List,Iterator);
         Scale(Simple_Op.all,Factor);
      end loop;
   end Scale;

   -----------
   -- Scale --
   -----------

   procedure Scale
     (Op : in out Enclosing_Operation; Factor : Normalized_Execution_Time)
   is
   begin
      Op.Scale_Factor:=Factor;
   end Scale;

   -----------
   -- Scale --
   -----------

   procedure Scale
     (Op : in out Message_Transmission_Operation;
      Factor : Normalized_Execution_Time)
   is
   begin
      Op.Scale_Factor:=Factor;
   end Scale;

   ---------------------------------
   -- Set_Avg_Case_Execution_Time --
   ---------------------------------

   procedure Set_Avg_Case_Execution_Time
     (Op : in out Simple_Operation;
      Avg_Case_Execution_Time : Normalized_Execution_Time)
   is
   begin
      Op.Avg_Case_Execution_Time:=Avg_Case_Execution_Time;
   end Set_Avg_Case_Execution_Time;

   ---------------------------------
   -- Set_Avg_Case_Execution_Time --
   ---------------------------------

   procedure Set_Avg_Case_Execution_Time
     (Op : in out Enclosing_Operation;
      Avg_Case_Execution_Time : Normalized_Execution_Time)
   is
   begin
      Op.Avg_Case_Execution_Time:=Avg_Case_Execution_Time;
   end Set_Avg_Case_Execution_Time;

   --------------------------
   -- Set_Avg_Message_Size --
   --------------------------

   procedure Set_Avg_Message_Size
     (Op : in out Message_Transmission_Operation;
      Avg_Message_Size : Bit_Count)
   is
   begin
      Op.Avg_Message_Size:=Avg_Message_Size;
   end Set_Avg_Message_Size;

   ----------------------------------
   -- Set_Best_Case_Execution_Time --
   ----------------------------------

   procedure Set_Best_Case_Execution_Time
     (Op : in out Simple_Operation;
      Best_Case_Execution_Time : Normalized_Execution_Time)
   is
   begin
      Op.Best_Case_Execution_Time:=Best_Case_Execution_Time;
   end Set_Best_Case_Execution_Time;

   ----------------------------------
   -- Set_Best_Case_Execution_Time --
   ----------------------------------

   procedure Set_Best_Case_Execution_Time
     (Op : in out Enclosing_Operation;
      Best_Case_Execution_Time : Normalized_Execution_Time)
   is
   begin
      Op.Best_Case_Execution_Time:=Best_Case_Execution_Time;
   end Set_Best_Case_Execution_Time;

   --------------------------
   -- Set_Max_Message_Size --
   --------------------------

   procedure Set_Max_Message_Size
     (Op : in out Message_Transmission_Operation;
      Max_Message_Size : Bit_Count)
   is
   begin
      Op.Max_Message_Size:=Max_Message_Size;
   end Set_Max_Message_Size;

   --------------------------
   -- Set_Min_Message_Size --
   --------------------------

   procedure Set_Min_Message_Size
     (Op : in out Message_Transmission_Operation;
      Min_Message_Size : Bit_Count)
   is
   begin
      Op.Min_Message_Size:=Min_Message_Size;
   end Set_Min_Message_Size;

   ------------------------------
   -- Set_New_Sched_Parameters --
   ------------------------------

   procedure Set_New_Sched_Parameters
     (Op : in out Operation;
      Sched_Params :
      MAST.Scheduling_Parameters.Overridden_Sched_Parameters_Ref)
   is
   begin
      Op.New_Sched_Parameters:=Sched_Params;
   end Set_New_Sched_Parameters;


   -----------------------------------
   -- Set_Worst_Case_Execution_Time --
   -----------------------------------

   procedure Set_Worst_Case_Execution_Time
     (Op : in out Simple_Operation;
      Worst_Case_Execution_Time : Normalized_Execution_Time)
   is
   begin
      Op.Worst_Case_Execution_Time:=Worst_Case_Execution_Time;
   end Set_Worst_Case_Execution_Time;

   -----------------------------------
   -- Set_Worst_Case_Execution_Time --
   -----------------------------------

   procedure Set_Worst_Case_Execution_Time
     (Op : in out Enclosing_Operation;
      Worst_Case_Execution_Time : Normalized_Execution_Time)
   is
   begin
      Op.Worst_Case_Execution_Time:=Worst_Case_Execution_Time;
   end Set_Worst_Case_Execution_Time;


   ----------------------
   -- Set_Slack_Result --
   ----------------------

   procedure Set_Slack_Result
     (Op : in out Operation;
      Res : Results.Slack_Result_Ref)
   is
   begin
      Op.The_Slack_Result:=Res;
   end Set_Slack_Result;

   ----------------------
   -- Slack_Result     --
   ----------------------

   function Slack_Result
     (Op : Operation)
     return Results.Slack_Result_Ref
   is
   begin
      return Op.The_Slack_Result;
   end Slack_Result;

   ---------------------------
   -- Shared_Resources_Used --
   ---------------------------

   function Shared_Resources_Used
     (Op : Simple_Operation)
     return Boolean
   is
   begin
      return Num_Of_Locked_Resources(Op)+Num_Of_Unlocked_Resources(Op)>0;
   end Shared_Resources_Used;

   ------------------------------------------
   -- Operation_References_Shared_Resource --
   ------------------------------------------

   function Operation_References_Shared_Resource
     (Op     : Simple_Operation;
      Sr_Ref : Shared_Resources.Shared_Resource_Ref)
     return Boolean
   is
   begin
      if Shared_Resources_List.Find(Sr_Ref,Op.Locked_Shared_Resources)/=
        Shared_Resources_List.Null_Index
      then
         return True;
      end if;
      if Shared_Resources_List.Find(Sr_Ref,Op.Unlocked_Shared_Resources)/=
        Shared_Resources_List.Null_Index
      then
         return True;
      else
         return False;
      end if;
   end Operation_References_Shared_Resource;

   ---------------------------
   -- Shared_Resources_Used --
   ---------------------------

   function Shared_Resources_Used
     (Op : Composite_Operation)
     return Boolean
   is
      Iterator : Op_Lists.Iteration_Object;
      Op_Ref : Operation_Ref;
      Used : Boolean:=False;
   begin
      Op_Lists.Rewind(Op.Op_List,Iterator);
      for I in 1..Op_Lists.Size(Op.Op_List) loop
         Op_Lists.Get_Next_Item(Op_Ref,Op.Op_List,Iterator);
         Used := Used or Shared_Resources_Used(Op_Ref.all);
      end loop;
      return Used;
   end Shared_Resources_Used;


   ------------------------------------------
   -- Operation_References_Shared_Resource --
   ------------------------------------------

   function Operation_References_Shared_Resource
     (Op     : Composite_Operation;
      Sr_Ref : Shared_Resources.Shared_Resource_Ref)
     return Boolean
   is
      Iterator : Op_Lists.Iteration_Object;
      Op_Ref : Operation_Ref;
   begin
      Op_Lists.Rewind(Op.Op_List,Iterator);
      for I in 1..Op_Lists.Size(Op.Op_List) loop
         Op_Lists.Get_Next_Item(Op_Ref,Op.Op_List,Iterator);
         if Operation_References_Shared_Resource(Op_Ref.all,Sr_Ref) then
            return True;
         end if;
      end loop;
      return False;
   end Operation_References_Shared_Resource;

   ---------------------------
   -- Shared_Resources_Used --
   ---------------------------

   function Shared_Resources_Used
     (Op : Message_Transmission_Operation)
     return Boolean
   is
   begin
      return False;
   end Shared_Resources_Used;

   ------------------------------------------
   -- Operation_References_Shared_Resource --
   ------------------------------------------

   function Operation_References_Shared_Resource
     (Op     : Message_Transmission_Operation;
      Sr_Ref : Shared_Resources.Shared_Resource_Ref)
     return Boolean
   is
   begin
      return False;
   end Operation_References_Shared_Resource;

   -------------------------------
   -- Worst_Case_Execution_Time --
   -------------------------------

   function Worst_Case_Execution_Time
     (Op : Simple_Operation;
      Throughput : Throughput_Value)
     return Normalized_Execution_Time
   is
   begin
      return Op.Worst_Case_Execution_Time*Op.Scale_Factor;
   end Worst_Case_Execution_Time;

   -------------------------------
   -- Worst_Case_Execution_Time --
   -------------------------------

   function Worst_Case_Execution_Time
     (Op : Enclosing_Operation;
      Throughput : Throughput_Value)
     return Normalized_Execution_Time
   is
   begin
      return Op.Worst_Case_Execution_Time*Op.Scale_Factor;
   end Worst_Case_Execution_Time;

   -------------------------------
   -- Worst_Case_Execution_Time --
   -------------------------------

   function Worst_Case_Execution_Time
     (Op : in Composite_Operation;
      Throughput : Throughput_Value)
     return Normalized_Execution_Time
   is
      Exec_Time : Normalized_Execution_Time:=0.0;
      An_Op : Operation_Ref;
      Iterator : Op_Lists.Index;
   begin
      Op_Lists.Rewind(Op.Op_List,Iterator);
      for I in 1..Op_Lists.Size(Op.Op_List) loop
         Op_Lists.Get_Next_Item(An_Op,Op.Op_List,Iterator);
         Exec_Time:=Exec_Time+Worst_Case_Execution_Time(An_Op.all,Throughput);
      end loop;
      return Exec_Time;
   end Worst_Case_Execution_Time;

   -------------------------------
   -- Worst_Case_Execution_Time --
   -------------------------------

   function Worst_Case_Execution_Time
     (Op : Message_Transmission_Operation;
      Throughput : Throughput_Value)
     return Normalized_Execution_Time
   is
   begin
      return (Op.Max_Message_Size/Throughput)*Op.Scale_Factor;
   end Worst_Case_Execution_Time;

end MAST.Operations;
