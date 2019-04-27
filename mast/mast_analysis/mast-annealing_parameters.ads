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
with Ada.Text_IO; use Ada;

package Mast.Annealing_Parameters is

   subtype Iteration_Type is Long_Integer range 0..Long_Integer'Last;

   -- Load and store Annealing parameters
   -- Load is made from the specified file.
   -- If the specified file does not exist or the parameters file
   -- format is not correct, default parameters are loaded, and
   -- in the second case an exception is raised.
   -- Store is made to the specified file.

   procedure Load_Parameters
     (File_Name : in String := "priority_assignment_parameters.txt");
   -- may raise File_Does_Not_Exist or Invalid_Format

   procedure Store_Parameters
     (Parameters_File : in out Text_IO.File_Type);

   procedure Load_Default_Parameters;

   function Get_Max_Iterations return Iteration_Type;
   procedure Set_Max_Iterations (Iter : Iteration_Type);

   -- Overiteration in optimization

   function Get_Overiterations return Iteration_Type;
   procedure Set_Overiterations (Iter : in Iteration_Type);

   -- Maximum time to run the analysis tool

   function Get_Analysis_Stop_Time return Duration;
   procedure Set_Analysis_Stop_Time (Stop_Time : in Duration);

   -- Maximum time to run the analysis tool when Audsley algorithm is applied
   -- A value of 0.0 means that the algorithm will not be applied

   function Get_Audsley_Stop_Time return Duration;
   procedure Set_Audsley_Stop_Time (Stop_Time : in Duration);

end Mast.Annealing_Parameters;
