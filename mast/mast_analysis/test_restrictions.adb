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
  MAST_Put_Results,MAST.Consistency_Checks,Mast.Restrictions;
use Mast.Consistency_Checks,Mast.Restrictions,Ada.Text_IO,Ada.Command_Line;
procedure Test_Restrictions is
   The_System : MAST.Systems.System;
   Desc : File_Type;
   Verbose : Boolean:=False;
begin
   if Argument_Count>=1 then
      if Argument_Count>=2 then
         if Argument(1)="-v" then
            Verbose:=True;
            Ada.Text_IO.Open(Desc,In_File,Argument(2));
         else
            Put_Line("Usage: test_restrictions [-v] input_file");
            return;
         end if;
      else
         Ada.Text_IO.Open(Desc,In_File,Argument(1));
      end if;
      Ada.Text_IO.Set_Input(Desc);
      MAST_Parser(The_System);
      Close(Desc);
      Ada.Text_IO.Set_Input(Standard_Input);
   else
      Put_Line("Usage: test_restrictions [-v] input_file");
      return;
   end if;

   if Consistent_Transaction_Graphs(The_System) then
      Put_Line("Consistent_Transaction_Graphs met");
      if Consistent_Shared_Resource_Usage(The_System) then
         Put_Line("Consistent_Shared_Resource_Usage met");
         if Consistent_Shared_Resource_Usage_For_Segments(The_System) then
            Put_Line("Consistent_Shared_Resource_Usage_For_Segments met");
         else
            return;
         end if;
      else
         return;
      end if;
   else
      return;
   end if;

   Put_Line ("Monoprocessor_Only is : "&Boolean'Image
             (Monoprocessor_Only(The_System,Verbose)));

   Put_Line ("Fixed_Priority_Only is : "&Boolean'Image
             (Fixed_Priority_Only(The_System,Verbose)));

   Put_Line ("EDF_Only is : "&Boolean'Image
             (EDF_Only(The_System,Verbose)));

   Put_Line ("EDF_Within_Priorities_Only is : "&Boolean'Image
             (EDF_Within_Priorities_Only(The_System,Verbose)));

   Put_Line ("Flat_FP_Or_EDF_Only is : "&Boolean'Image
             (Flat_FP_Or_EDF_Only(The_System,Verbose)));

   Put_Line ("PCP_Only is : "&Boolean'Image
             (PCP_Only(The_System,Verbose)));

   Put_Line ("PCP_or_Priority_Inheritance_Only is : "&Boolean'Image
             (PCP_Or_Priority_Inheritance_Only(The_System,Verbose)));

   Put_Line ("PCP_SRP_or_Priority_Inheritance_Only is : "&Boolean'Image
             (PCP_SRP_Or_Priority_Inheritance_Only(The_System,Verbose)));

   Put_Line ("SRP_Only is : "&Boolean'Image
             (SRP_Only(The_System,Verbose)));

   Put_Line ("Referenced_Events_Are_External_Only is : "&Boolean'Image
             (Referenced_Events_Are_External_Only(The_System,Verbose)));

   Put_Line ("Simple_Transactions_Only is : "&Boolean'Image
             (Simple_Transactions_Only(The_System,Verbose)));

   Put_Line ("Linear_Transactions_Only is : "&Boolean'Image
             (Linear_Transactions_Only(The_System,Verbose)));

   Put_Line ("Linear_Plus_Transactions_Only is : "&Boolean'Image
             (Linear_Plus_Transactions_Only(The_System,Verbose)));

   Put_Line ("Multiple_Event_Transactions_Only is : "&Boolean'Image
             (Multiple_Event_Transactions_Only(The_System,Verbose)));

end Test_Restrictions;
