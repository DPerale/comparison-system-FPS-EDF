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

with Ada.Text_IO, Mast.Timers;

package Mast.Processing_Resources.Processor is

   -----------------------
   -- Processor
   -----------------------

   type Processor is abstract new Processing_Resource with private;

   type Regular_Processor is new Processor with private;

   procedure Set_Max_Interrupt_Priority
     (Res : in out Regular_Processor;
      The_Priority : Priority);
   function Max_Interrupt_Priority
     (Res : Regular_Processor)
     return Priority;

   procedure Set_Min_Interrupt_Priority
     (Res : in out Regular_Processor;
      The_Priority : Priority);
   function Min_Interrupt_Priority
     (Res : Regular_Processor)
     return Priority;

   function Max_Any_Priority
     (Res : Regular_Processor)
     return Priority;

   procedure Set_Worst_ISR_Switch
     (CPU : in out Regular_Processor;
      The_Worst_ISR_Switch : Normalized_Execution_Time);
   procedure Set_Avg_ISR_Switch
     (CPU : in out Regular_Processor;
      The_Avg_ISR_Switch : Normalized_Execution_Time);
   procedure Set_Best_ISR_Switch
     (CPU : in out Regular_Processor;
      The_Best_ISR_Switch : Normalized_Execution_Time);
   function Worst_ISR_Switch
     (CPU : Regular_Processor) return Normalized_Execution_Time;
   function Avg_ISR_Switch
     (CPU : Regular_Processor) return Normalized_Execution_Time;
   function Best_ISR_Switch
     (CPU : Regular_Processor) return Normalized_Execution_Time;

   procedure Set_System_Timer
     (CPU : in out Regular_Processor;
      The_System_Timer : Timers.System_Timer_Ref);

   function The_System_Timer
     (CPU : Regular_Processor)
     return Timers.System_Timer_Ref;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Regular_Processor;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Regular_Processor;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (Res : Regular_Processor)
     return  Processing_Resource_Ref;

   type Processor_Ref is access all Processor'Class;

private

   type Processor is abstract new Processing_Resource with null record;

   type Regular_Processor is new Processor with record
        Worst_ISR_Switch,
        Avg_ISR_Switch,
        Best_ISR_Switch : Normalized_Execution_Time:=0.0;
        Max_Interrupt_Priority : Priority:=Priority'Last;
        Min_Interrupt_Priority : Priority:=Priority'First;
        The_System_Timer : Timers.System_Timer_Ref;
   end record;

end Mast.Processing_Resources.Processor;
