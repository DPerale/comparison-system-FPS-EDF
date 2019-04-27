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
package body Mast.Synchronization_Parameters is

   -----------
   -- Clone --
   -----------

   function Clone
     (Parameters : SRP_Parameters)
     return  Synch_Parameters_Ref
   is
      Param_Ref : Synch_Parameters_Ref;
   begin
      Param_Ref:=new SRP_Parameters'(Parameters);
      return Param_Ref;
   end Clone;

   -----------------
   -- Preassigned --
   -----------------

   function Preassigned
     (Parameters : SRP_Parameters) return Boolean
   is
   begin
      return Parameters.Preassigned;
   end Preassigned;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Synch_Parameters;
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
      Res : in out SRP_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 16;
   begin
      Print(File,Synch_Parameters(Res),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "SRP_Parameters",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Preemption_Level",
         Preemption_Level'Image(Res.The_Level),Indentation+2,Names_Length);
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
      Res : in out SRP_Parameters;
      Indentation : Positive;
      Finalize    : Boolean:=False;
      Domain      : String:="mast_mdl")
   is
      Names_Length : constant Positive := 12;
   begin

      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put(File,"<"&Domain&":SRP_Parameters ");
      Ada.Text_Io.Put
        (File,"Preemption_Level=""" &
         IO.Preemption_Level_Image(Res.The_Level) & """ ");
      Ada.Text_Io.Put_Line
        (File,"Preassigned=""" &
         MAST.IO.Boolean_Image(Res.Preassigned) & """ />");
   end Print_XML;

   ---------------------
   -- Set_Preassigned --
   ---------------------

   procedure Set_Preassigned
     (Parameters : in out SRP_Parameters;
      Is_Preassigned : Boolean)
   is
   begin
      Parameters.Preassigned := Is_Preassigned;
   end Set_Preassigned;

   --------------------------
   -- Set_Preemption_Level --
   --------------------------

   procedure Set_Preemption_Level
     (Parameters : in out SRP_Parameters;
      Level : Preemption_Level)
   is
   begin
      Parameters.The_Level := Level;
   end Set_Preemption_Level;

   --------------------------
   -- The_Preemption_Level --
   --------------------------

   function The_Preemption_Level
     (Parameters : SRP_Parameters) return Preemption_Level
   is
   begin
      return Parameters.The_Level;
   end The_Preemption_Level;

end Mast.Synchronization_Parameters;
