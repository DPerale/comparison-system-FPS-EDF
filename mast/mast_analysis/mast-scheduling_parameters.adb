-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2004                     --
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
package body Mast.Scheduling_Parameters is

   -----------------------------
   -- Background_Priority --
   -----------------------------

   function Background_Priority
     (Parameters : Sporadic_Server_Policy)
     return Priority
   is
   begin
      return Parameters.Background_Priority;
   end Background_Priority;

   -----------
   -- Clone --
   -----------

   function Clone
     (Parameters : Fixed_Priority_Policy)
     return  Sched_Parameters_Ref
   is
      Param_Ref : Sched_Parameters_Ref;
   begin
      Param_Ref:=new Fixed_Priority_Policy'(Parameters);
      return Param_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Parameters : Non_Preemptible_FP_Policy)
     return  Sched_Parameters_Ref
   is
      Param_Ref : Sched_Parameters_Ref;
   begin
      Param_Ref:=new Non_Preemptible_FP_Policy'(Parameters);
      return Param_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Parameters : Interrupt_FP_Policy)
     return  Sched_Parameters_Ref
   is
      Param_Ref : Sched_Parameters_Ref;
   begin
      Param_Ref:=new Interrupt_FP_Policy'(Parameters);
      return Param_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Parameters : Polling_Policy)
     return  Sched_Parameters_Ref
   is
      Param_Ref : Sched_Parameters_Ref;
   begin
      Param_Ref:=new Polling_Policy'(Parameters);
      return Param_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Parameters : Sporadic_Server_Policy)
     return  Sched_Parameters_Ref
   is
      Param_Ref : Sched_Parameters_Ref;
   begin
      Param_Ref:=new Sporadic_Server_Policy'(Parameters);
      return Param_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Parameters : Overridden_FP_Parameters)
     return  Overridden_Sched_Parameters_Ref
   is
      Param_Ref : Overridden_Sched_Parameters_Ref;
   begin
      Param_Ref:=new Overridden_FP_Parameters'(Parameters);
      return Param_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Parameters : Overridden_Permanent_FP_Parameters)
     return  Overridden_Sched_Parameters_Ref
   is
      Param_Ref : Overridden_Sched_Parameters_Ref;
   begin
      Param_Ref:=new Overridden_Permanent_FP_Parameters'(Parameters);
      return Param_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Parameters : EDF_Policy)
     return  Sched_Parameters_Ref
   is
      Param_Ref : Sched_Parameters_Ref;
   begin
      Param_Ref:=new EDF_Policy'(Parameters);
      return Param_Ref;
   end Clone;

   ------------------
   -- Deadline --
   ------------------

   function Deadline
     (Parameters : EDF_Parameters)
     return Time
   is
   begin
      return Parameters.Deadline;
   end Deadline;

   ------------------------------------
   -- Max_Pending_Replenishments --
   ------------------------------------

   function Max_Pending_Replenishments
     (Parameters : Sporadic_Server_Policy)
     return Positive
   is
   begin
      return Parameters.Max_Pending_Replenishments;
   end Max_Pending_Replenishments;


   ------------------------
   -- Polling_Period --
   ------------------------

   function Polling_Period
     (Parameters : Polling_Policy)
     return Time
   is
   begin
      return Parameters.Polling_Period;
   end Polling_Period;

   -----------------
   -- Preassigned --
   -----------------

   function Preassigned
     (Parameters : Fixed_Priority_Parameters)
     return Boolean
   is
   begin
      return Parameters.Preassigned;
   end Preassigned;

   -----------------
   -- Preassigned --
   -----------------

   function Preassigned
     (Parameters : Interrupt_FP_Policy)
     return Boolean
   is
   begin
      return True;
   end Preassigned;

   -----------------
   -- Preassigned --
   -----------------

   function Preassigned
     (Parameters : EDF_Parameters)
     return Boolean
   is
   begin
      return Parameters.Preassigned;
   end Preassigned;

   ------------------
   -- The_Priority --
   ------------------

   function The_Priority
     (Parameters : Fixed_Priority_Parameters)
     return Priority
   is
   begin
      return Parameters.Prio;
   end The_Priority;

   ------------------
   -- The_Priority --
   ------------------

   function The_Priority
     (Parameters : Overridden_FP_Parameters)
     return Priority
   is
   begin
      return Parameters.Prio;
   end The_Priority;

   ------------------------------
   -- Initial_Capacity         --
   ------------------------------

   function Initial_Capacity
     (Parameters : Sporadic_Server_Policy)
     return Time
   is
   begin
      return Parameters.Initial_Capacity;
   end Initial_Capacity;

   ------------------------------
   -- Replenishment_Period --
   ------------------------------

   function Replenishment_Period
     (Parameters : Sporadic_Server_Policy)
     return Time
   is
   begin
      return Parameters.Replenishment_Period;
   end Replenishment_Period;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Sched_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Overridden_Sched_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Fixed_Priority_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 12;
   begin
      Print(File,Sched_Parameters(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Fixed_Priority_Policy",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"The_Priority",
         Priority'Image(Res.Prio),Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Preassigned",
         MAST.IO.Boolean_Image(Res.Preassigned),Indentation+2,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Overridden_FP_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 12;
   begin
      Print(File,Overridden_Sched_Parameters(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Overridden_Fixed_Priority",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"The_Priority",
         Priority'Image(Res.Prio),Indentation+2,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Overridden_Permanent_FP_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 12;
   begin
      Print(File,Overridden_Sched_Parameters(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Overridden_Permanent_FP",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"The_Priority",
         Priority'Image(Res.Prio),Indentation+2,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Non_Preemptible_FP_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 12;
   begin
      Print(File,Sched_Parameters(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Non_Preemptible_FP_Policy",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"The_Priority",
         Priority'Image(Res.Prio),Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Preassigned",
         MAST.IO.Boolean_Image(Res.Preassigned),Indentation+2,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Interrupt_FP_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 12;
   begin
      Print(File,Sched_Parameters(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Interrupt_FP_Policy",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"The_Priority",
         Priority'Image(Res.Prio),Indentation+2,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Polling_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 22;
   begin
      Print(File,Sched_Parameters(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Polling_Policy",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"The_Priority",
         Priority'Image(Res.Prio),Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Preassigned",
         MAST.IO.Boolean_Image(Res.Preassigned),Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Polling_Period",
         IO.Time_Image(Res.Polling_Period),Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Polling_Worst_Overhead",
         IO.Execution_Time_Image(Res.Polling_Worst_Overhead),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Polling_Best_Overhead",
         IO.Execution_Time_Image(Res.Polling_Best_Overhead),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Polling_Avg_Overhead",
         IO.Execution_Time_Image(Res.Polling_Avg_Overhead),
         Indentation+2,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Sporadic_Server_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 26;
   begin
      Print(File,Sched_Parameters(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Sporadic_Server_Policy",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Normal_Priority",
         Priority'Image(Res.Prio),Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Preassigned",
         MAST.IO.Boolean_Image(Res.Preassigned),Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Background_Priority",
         Priority'Image(Res.Background_Priority),Indentation+2,
         Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Initial_Capacity",
         IO.Time_Image(Res.Initial_Capacity),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Replenishment_Period",
         IO.Time_Image(Res.Replenishment_Period),
         Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Max_Pending_Replenishments",
         Positive'Image(Res.Max_Pending_Replenishments),
         Indentation+2,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out EDF_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 12;
   begin
      Print(File,Sched_Parameters(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "EDF_Policy",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Deadline",
         IO.Time_Image(Res.Deadline),Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Preassigned",
         MAST.IO.Boolean_Image(Res.Preassigned),Indentation+2,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Fixed_Priority_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl")
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<"&Domain&":Fixed_Priority_Policy ");
      Ada.Text_IO.Put
        (File,"The_Priority=""" & IO.Priority_Image(Res.Prio) & """ " );
      Ada.Text_IO.Put_Line
        (File,"Preassigned=""" &
         MAST.IO.Boolean_Image(Res.Preassigned) & """/>" );
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Overridden_FP_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 12;

   begin

      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_mdl:Overridden_Fixed_Priority ");
      Ada.Text_Io.Put_Line
        (File,"The_Priority=""" &
         IO.Priority_Image(Res.Prio) & """/>" );
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Overridden_Permanent_FP_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_Io.Set_Col(File,Ada.Text_Io.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_mdl:Overridden_Permanent_FP ");
      Ada.Text_IO.Put_Line
        (File,"The_Priority=""" & IO.Priority_Image(Res.Prio) & """/>" );
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Non_Preemptible_FP_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl")
   is

   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<"&Domain&":Non_Preemptible_FP_Policy ");
      Ada.Text_IO.Put
        (File,"The_Priority=""" & IO.Priority_Image(Res.Prio) & """ " );
      Ada.Text_IO.Put_Line
        (File,"Preassigned=""" &
         MAST.IO.Boolean_Image(Res.Preassigned) & """/>" );
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Interrupt_FP_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl")
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<"&Domain&":Interrupt_FP_Policy ");
      Ada.Text_IO.Put_Line
        (File,"The_Priority=""" & IO.Priority_Image(Res.Prio) & """/>" );
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Polling_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl")
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<"&Domain&":Polling_Policy ");
      Ada.Text_IO.Put
        (File,"The_Priority=""" & IO.Priority_Image(Res.Prio) & """ " );
      Ada.Text_IO.Put
        (File,"Preassigned=""" &
         MAST.IO.Boolean_Image(Res.Preassigned) & """ " );
      Ada.Text_IO.Put
        (File,"Polling_Period=""" &
         IO.Time_Image(Res.Polling_Period) & """ " );
      Ada.Text_IO.Put
        (File,"Polling_Worst_Overhead=""" &
         IO.Execution_Time_Image(Res.Polling_Worst_Overhead) & """ " );
      Ada.Text_IO.Put
        (File,"Polling_Best_Overhead=""" &
         IO.Execution_Time_Image(Res.Polling_Best_Overhead) & """ " );
      Ada.Text_IO.Put
        (File,"Polling_Avg_Overhead=""" &
         IO.Execution_Time_Image(Res.Polling_Avg_Overhead) & """/> " );
   end Print_XML;


   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Sporadic_Server_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl")
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<"&Domain&":Sporadic_Server_Policy ");
      Ada.Text_IO.Put
        (File,"Normal_Priority=""" & IO.Priority_Image(Res.Prio) & """ " );
      Ada.Text_IO.Put
        (File,"Preassigned=""" &
         MAST.IO.Boolean_Image(Res.Preassigned) & """ " );
      Ada.Text_IO.Put
        (File,"Background_Priority=""" &
         IO.Priority_Image(Res.Background_Priority) & """ " );
      Ada.Text_IO.Put
        (File,"Initial_Capacity=""" &
         IO.Time_Image(Res.Initial_Capacity) & """ " );
      Ada.Text_IO.Put
        (File,"Replenishment_Period=""" &
         IO.Time_Image(Res.Replenishment_Period) & """ " );
      Ada.Text_IO.Put_Line
        (File,"Max_Pending_Replenishments=""" &
         IO.Integer_Image(Res.Max_Pending_Replenishments) & """/>" );
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out EDF_Policy;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl")
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<"&Domain&":EDF_Policy ");
      Ada.Text_IO.Put(File,"Deadline=""" & IO.Time_Image(Res.Deadline) &
                      """ " );
      Ada.Text_IO.Put
        (File,"Preassigned=""" &
         MAST.IO.Boolean_Image(Res.Preassigned) & """ />" );
   end Print_XML;

   -----------------------------
   -- Set_Background_Priority --
   -----------------------------

   procedure Set_Background_Priority
     (Parameters : in out Sporadic_Server_Policy;
      The_Background_Priority : Priority)
   is
   begin
      Parameters.Background_Priority := The_Background_Priority;
   end Set_Background_Priority;

   ----------------------
   -- Set_Deadline --
   ----------------------

   procedure Set_Deadline
     (Parameters : in out EDF_Parameters;
      The_Deadline : Time)
   is
   begin
      Parameters.Deadline := The_Deadline;
   end Set_Deadline;

   ------------------------------------
   -- Set_Max_Pending_Replenishments --
   ------------------------------------

   procedure Set_Max_Pending_Replenishments
     (Parameters : in out Sporadic_Server_Policy;
      The_Replenishments : Positive)
   is
   begin
      Parameters.Max_Pending_Replenishments := The_Replenishments;
   end Set_Max_Pending_Replenishments;


   ------------------------
   -- Set_Polling_Period --
   ------------------------

   procedure Set_Polling_Period
     (Parameters : in out Polling_Policy;
      The_Polling_Period : Time)
   is
   begin
      Parameters.Polling_Period := The_Polling_Period;
   end Set_Polling_Period;

   ---------------------
   -- Set_Preassigned --
   ---------------------

   procedure Set_Preassigned
     (Parameters : in out Fixed_Priority_Parameters;
      Is_Preassigned : Boolean)
   is
   begin
      Parameters.Preassigned := Is_Preassigned;
   end Set_Preassigned;

   ---------------------
   -- Set_Preassigned --
   ---------------------

   procedure Set_Preassigned
     (Parameters : in out EDF_Parameters;
      Is_Preassigned : Boolean)
   is
   begin
      Parameters.Preassigned := Is_Preassigned;
   end Set_Preassigned;

   ---------------------
   -- Set_The_Priority --
   ----------------------

   procedure Set_The_Priority
     (Parameters : in out Fixed_Priority_Parameters;
      The_Priority : Priority)
   is
   begin
      Parameters.Prio := The_Priority;
   end Set_The_Priority;

   ----------------------
   -- Set_The_Priority --
   ----------------------

   procedure Set_The_Priority
     (Parameters : in out Overridden_FP_Parameters;
      The_Priority : Priority)
   is
   begin
      Parameters.Prio := The_Priority;
   end Set_The_Priority;


   ------------------------------
   -- Set_Initial_Capacity --
   ------------------------------

   procedure Set_Initial_Capacity
     (Parameters : in out Sporadic_Server_Policy;
      The_Initial_Capacity : Time)
   is
   begin
      Parameters.Initial_Capacity := The_Initial_Capacity;
   end Set_Initial_Capacity;

   ------------------------------
   -- Set_Replenishment_Period --
   ------------------------------

   procedure Set_Replenishment_Period
     (Parameters : in out Sporadic_Server_Policy;
      The_Replenishment_Period : Time)
   is
   begin
      Parameters.Replenishment_Period := The_Replenishment_Period;
   end Set_Replenishment_Period;

   --------------------------------
   -- Set_Polling_Worst_Overhead --
   --------------------------------

   procedure Set_Polling_Worst_Overhead
     (Parameters : in out Polling_Policy;
      The_Polling_Worst_Overhead : Normalized_Execution_Time) is
   begin
      Parameters.Polling_Worst_Overhead:=The_Polling_Worst_Overhead;
   end Set_Polling_Worst_Overhead;


   --------------------------------
   -- Set_Polling_Best_Overhead --
   --------------------------------

   procedure Set_Polling_Best_Overhead
     (Parameters : in out Polling_Policy;
      The_Polling_Best_Overhead : Normalized_Execution_Time) is
   begin
      Parameters.Polling_Best_Overhead:=The_Polling_Best_Overhead;
   end Set_Polling_Best_Overhead;

   --------------------------------
   -- Set_Polling_Avg_Overhead --
   --------------------------------

   procedure Set_Polling_Avg_Overhead
     (Parameters : in out Polling_Policy;
      The_Polling_Avg_Overhead : Normalized_Execution_Time) is
   begin
      Parameters.Polling_Avg_Overhead:=The_Polling_Avg_Overhead;
   end Set_Polling_Avg_Overhead;

   ------------------------------
   -- Polling_Worst_Overhead --
   ------------------------------

   function Polling_Worst_Overhead
     (Parameters : Polling_Policy)
     return Normalized_Execution_Time
   is
   begin
      return Parameters.Polling_Worst_Overhead;
   end Polling_Worst_Overhead;

   ------------------------------
   -- Polling_Worst_Overhead --
   ------------------------------

   function Polling_Best_Overhead
     (Parameters : Polling_Policy)
     return Normalized_Execution_Time
   is
   begin
      return Parameters.Polling_Best_Overhead;
   end Polling_Best_Overhead;

   ------------------------------
   -- Polling_Worst_Overhead --
   ------------------------------

   function Polling_Avg_Overhead
     (Parameters : Polling_Policy)
     return Normalized_Execution_Time
   is
   begin
      return Parameters.Polling_Avg_Overhead;
   end Polling_Avg_Overhead;

end Mast.Scheduling_Parameters;
