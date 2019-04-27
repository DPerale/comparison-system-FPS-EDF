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

with Mast.Systems;
package Mast_Actions is

   The_System : Mast.Systems.System;

   function Has_Results return Boolean;

   function Has_System return Boolean;

   procedure Read_System(Filename : String);

   procedure Save_System(Filename : String);

   function Name_Of_System return String;

   procedure Read_Results(Filename : String);

   procedure Save_Results(Filename : String);

   function Name_Of_Results return String;

   No_System : exception;
   -- raised by Read_Results or name_of_system if no system was read

   No_Results : exception;
   -- raised by Name_of_Results if no results file was read

   XML_Convert_Error : exception;
   -- raised by Read_System if an XML conversion was incorrect

   XML_Convert_Results_Error : exception;
   -- raised by Read_Results if an XML results conversion was incorrect

   Program_Not_Found : exception;
   -- raised by Read_System or Read_Results if the corresponding
   -- xml conversion program was not found

end Mast_Actions;
