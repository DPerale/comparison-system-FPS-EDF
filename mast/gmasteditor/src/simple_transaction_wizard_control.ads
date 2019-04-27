-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                           GMastEditor                             --
--          Graphical Editor for Modelling and Analysis              --
--                    of Real-Time Applications                      --
--                                                                   --
--                       Copyright (C) 2005                          --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors : Pilar del Rio                                           --
--                                                                   --
-- Contact info: Michael Gonzalez       mgh@unican.es                --
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
with Wizard_Welcome_Dialog_Pkg;     use Wizard_Welcome_Dialog_Pkg;
with Wizard_Transaction_Dialog_Pkg; use Wizard_Transaction_Dialog_Pkg;
with Wizard_Input_Dialog_Pkg;       use Wizard_Input_Dialog_Pkg;
with Wizard_Activity_Dialog_Pkg;    use Wizard_Activity_Dialog_Pkg;
with Wizard_Output_Dialog_Pkg;      use Wizard_Output_Dialog_Pkg;
with Wizard_Completed_Dialog_Pkg;   use Wizard_Completed_Dialog_Pkg;

package Simple_Transaction_Wizard_Control is

   type Previous_Window is (
      Welcome_Win,
      Transaction_Win,
      Input_Event_Win,
      Activity_Win,
      Output_Event_Win,
      Complete_Win);

   type Simple_Transaction_Wizard_Record is record
      Previous_Win              : Previous_Window;
      Wizard_Welcome_Dialog     : Wizard_Welcome_Dialog_Access;
      Wizard_Transaction_Dialog : Wizard_Transaction_Dialog_Access;
      Wizard_Input_Dialog       : Wizard_Input_Dialog_Access;
      Wizard_Activity_Dialog    : Wizard_Activity_Dialog_Access;
      Wizard_Output_Dialog      : Wizard_Output_Dialog_Access;
      Wizard_Completed_Dialog   : Wizard_Completed_Dialog_Access;

   end record;

   type Simple_Transaction_Wizard_Access is access all
     Simple_Transaction_Wizard_Record;

   procedure Create_Simple_Transaction_Wizard;

end Simple_Transaction_Wizard_Control;
