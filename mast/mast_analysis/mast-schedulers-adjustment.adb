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

with Mast.Schedulers.Primary, Mast.Schedulers.Secondary,
  Mast.Processing_Resources.Processor, Ada.Text_IO;

package body Mast.Schedulers.Adjustment is

   use type Scheduling_Servers.Scheduling_Server_Ref;
   use type Processing_Resources.Processing_Resource_Ref;
   use type Lists.Index;

   ------------
   -- Adjust --
   ------------

   procedure Adjust
     (The_List : in Lists.List;
      Proc_List : in Mast.Processing_Resources.Lists.List;
      Sched_Server_List : in Mast.Scheduling_Servers.Lists.List)
   is
      Iterator : Lists.Iteration_Object;
      Sch_Ref : Scheduler_Ref;
   begin
      Lists.Rewind(The_List,Iterator);
      for I in 1..Lists.Size(The_List) loop
         Lists.Get_Next_Item(Sch_Ref,The_List,Iterator);
         if Sch_Ref.all in Primary.Primary_Scheduler'Class then
            Primary.Adjust(Primary.Primary_Scheduler'Class(Sch_Ref.all),
                           Proc_List);
         elsif Sch_Ref.all in Secondary.Secondary_Scheduler'Class then
            Secondary.Adjust(Secondary.Secondary_Scheduler'Class(Sch_Ref.all),
                             Sched_Server_List);
         else
            raise Incorrect_Object;
         end if;
      end loop;
   end Adjust;

end Mast.Schedulers.Adjustment;

