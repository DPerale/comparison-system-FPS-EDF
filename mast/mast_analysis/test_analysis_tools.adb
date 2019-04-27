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

with Ada.Text_IO,MAST_Parser,MAST.Systems,Ada.Command_Line,
  MAST.Consistency_Checks,Mast.Tools,
  Mast.Tool_Exceptions;
use Mast.Consistency_Checks,Mast.Tools,MAst.Tool_Exceptions,
  Ada.Text_IO,Ada.Command_Line;
procedure Test_Analysis_Tools is
   The_System : MAST.Systems.System;
   Desc : File_Type;
begin
   if Argument_Count>=1 then
      Ada.Text_IO.Open(Desc,In_File,Argument(1));
      Ada.Text_IO.Set_Input(Desc);
      MAST_Parser(The_System);
      Close(Desc);
      Ada.Text_IO.Set_Input(Standard_Input);
   else
      MAST_Parser(The_System);
   end if;

   if Consistent_Transaction_Graphs(The_System) then
      Put_Line("Consistent_Transaction_Graphs met");
   end if;

   if Consistent_Shared_Resource_Usage(The_System) then
      Put_Line("Consistent_Shared_Resource_Usage met");
   end if;

   --Calculate_Ceilings_For_PCP_Resources(The_System,True);
   Holistic_Analysis(The_System,True);
   Mast.Systems.Print_Results(Current_Output,The_System);

   Linear_Unoptimized_Analysis(The_System,True);
   Mast.Systems.Print_Results(Current_Output,The_System);

   Linear_Analysis(The_System,True);
   Mast.Systems.Print_Results(Current_Output,The_System);

exception

   when Tool_Failure =>
      Put_Line("Tool Failure exception");
      Put_Line(Tool_Failure_Message);
   when Restriction_Not_Met =>
      Put_Line("Restriction Not Met");
      Put_Line(Restriction_Message);

end Test_Analysis_Tools;
