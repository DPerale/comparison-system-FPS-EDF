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

with Ada.Text_IO; use Ada.Text_IO;
with Mast.Tool_Exceptions,Mast.Annealing_Parameters,
  MAST.Hopa_Parameters;

package body Mast.Priority_Assignment_Parameters is

   ----------------------
   -- Store_Parameters --
   ----------------------

   procedure Store_Parameters
     (File_Name : in String := "priority_assignment_parameters.txt")
   is
      Parameters_File : Ada.Text_IO.File_Type;
   begin
      Ada.Text_IO.Create (Parameters_File,Out_File,File_Name);

      Annealing_Parameters.Store_Parameters(Parameters_File);
      HOPA_Parameters.Store_Parameters(Parameters_File);
      Ada.Text_IO.Close(Parameters_File);
   exception
      when Use_Error =>
         raise Tool_Exceptions.Parameters_Not_Stored;
   end Store_Parameters;

end Mast.Priority_Assignment_Parameters;
