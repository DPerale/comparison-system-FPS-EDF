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

with MAST.Systems,MAST.Transactions, Mast.Processing_Resources;

package MAST.Miscelaneous_Tools is

   procedure Calculate_Ceilings_And_Levels
     (The_System : in out Mast.Systems.System;
      Verbose : in Boolean:=True);

   procedure Calculate_Blocking_Times
     (The_System : in out Mast.Systems.System;
      Verbose : in Boolean:=True);
   -- Restrictions :
   --   consistent shared resource usage
   --   all ceilings are consistent
   --   consistent shared resource usage for segments (i.e., all task
   --       segments unlock their locked resources)

   procedure Utilization_Test
     (The_System : in MAST.Systems.System;
      Suceeds : out Boolean;
      Verbose : in Boolean:=True);

   procedure Check_Shared_Resources_Total_Ordering
     (The_System : in MAST.Systems.System;
      Ordered : out Boolean;
      Verbose : in Boolean:=True);

   procedure Check_Transaction_Schedulability
     (Trans_Ref : MAST.Transactions.Transaction_Ref;
      Is_Schedulable : out Boolean;
      Verbose : in Boolean:=True);

   procedure Check_System_Schedulability
     (The_System : MAST.Systems.System;
      Is_Schedulable : out Boolean;
      Verbose : in Boolean:=True);

   function Calculate_Processing_Resource_Utilization
     (The_System : MAST.Systems.System;
      The_Pr : Mast.Processing_Resources.Processing_Resource_Ref;
      Verbose : Boolean := True) return Float;

   function Calculate_System_Utilization
     (The_System : MAST.Systems.System;
      Verbose : Boolean := True) return Float;

end MAST.Miscelaneous_Tools;
