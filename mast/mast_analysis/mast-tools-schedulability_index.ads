-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2002                     --
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

with MAST.Systems;

package MAST.Tools.Schedulability_Index is

   type Index is private;
   -- Higher indexes correspond to better systems

   Lower_Index : constant Index;

   procedure Calculate_Schedulability_Index
     (The_System : in out MAST.Systems.System;
      The_Index : out Index;
      Verbose : in Boolean:=True);
   -- It only works if the analysis or simulation results have been
   -- obtained previously, and the system is schedulable.
   -- In other cases the results are unpredictable

   function ">" (Left, Rigth : Index) return Boolean;

   function "<=" (Left, Rigth : Index) return Boolean;

   function To_Float (Ind : Index) return Float;

   procedure Print (The_Index : Index);

   Inconclusive : exception;

private

   type Index is new Float;

   Lower_Index : constant Index:= 0.0;

end MAST.Tools.Schedulability_Index;
