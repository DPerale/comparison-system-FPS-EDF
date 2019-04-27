
-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2003-2005                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors: Michael Gonzalez          mgh@unican.es                  --
--          Jose Javier Gutierrez     gutierjj@unican.es             --
--          Jose Carlos Palencia      palencij@unican.es             --
--          Jose Maria Drake          drakej@unican.es               --
--          Patricia López Martínez   lopezpa@unican.es              --
--          Yago Pereiro Estevan                                     --
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

package Mast_XML_Exceptions is

   Not_A_Mast_XML_File : exception;
   -- The file is not recognized as a MAST XML file

   Incorrect_Version : exception;
   -- The XML input file has an unsupported version tag

   Syntax_Error : exception;
   -- There is a syntax error in the Mast_Model file.

   Parser_Detected_Error : exception;
   -- There is an error in the Mast_Model file, detected by the parser

   procedure Parser_Error (S : String);

   procedure Report_Errors;

   procedure Clear_Errors;

end Mast_XML_Exceptions;
