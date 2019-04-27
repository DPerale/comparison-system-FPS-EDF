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

with Ada.Text_IO,Mast_Parser,MAST_Results_Parser,
  MAST.Systems,Ada.Command_Line;
use Ada.Text_IO,Ada.Command_Line;
procedure Mast_Read_Results is

   The_System : MAST.Systems.System;
   Desc, Res, Out_Res : File_Type;
begin
   if Argument_Count<2 then
      Put_Line("Usage: mast_read_results model_filename "&
               "results_filename [results_output]");
   else
      Ada.Text_IO.Open(Desc,In_File,Argument(1));
      Ada.Text_IO.Set_Input(Desc);
      Mast_Parser(The_System);
      Close(Desc);
      Ada.Text_IO.Set_Input(Standard_Input);

      Ada.Text_IO.Open(Res,In_File,Argument(2));
      Ada.Text_IO.Set_Input(Res);
      Mast_Results_Parser(The_System);
      Close(Res);
      Ada.Text_IO.Set_Input(Standard_Input);

      if Argument_Count>=3 then
         Ada.Text_IO.Put_Line("Printing results:");
         Ada.Text_IO.Create(Out_Res,Out_File,Argument(3));
         MAST.Systems.Print_Results(Out_Res,The_System);
         Close(Out_Res);
      else
         MAST.Systems.Print_Results(Standard_Output,The_System);
      end if;
   end if;
end Mast_Read_results;
