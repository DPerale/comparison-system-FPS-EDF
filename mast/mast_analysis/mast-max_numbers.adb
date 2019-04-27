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

with MAST.Systems,
  MAST.Transactions,
  Mast.Processing_Resources,
  Mast.Processing_Resources.Processor,
  Mast.Processing_Resources.Network,
  Mast.Scheduling_Parameters,
  Mast.Scheduling_Servers,
  Mast.Graphs,
  Mast.Graphs.Event_Handlers,
  Mast.Timers,
  Mast.Drivers;
use type Mast.Timers.System_Timer_Ref;

package body Mast.Max_Numbers is

   -----------------------------------------
   -- Calculate_Max_Transactions --
   -----------------------------------------

   function Calculate_Max_Transactions
     (The_System : Systems.System) return Natural
   is
      Max,Index :Natural;
      Proc_Ref : Processing_Resources.Processing_Resource_Ref;
      Proc_Iterator : Processing_Resources.Lists.Iteration_Object;
      Drv_Iterator : Processing_Resources.Network.Driver_Iteration_Object;
      Drv_Ref : Drivers.Driver_Ref;
   begin
      -- real transactions:
      Max:=Transactions.Lists.Size(The_System.Transactions);

      -- transactions caused by processing resource overheads
      Processing_Resources.Lists.Rewind
        (The_System.Processing_Resources,Proc_Iterator);
      for I in 1..Processing_Resources.Lists.Size
        (The_System.Processing_Resources)
      loop
         Processing_Resources.Lists.Get_Next_Item
           (Proc_Ref,The_System.Processing_Resources,Proc_Iterator);
         if Proc_Ref.all in
           Processing_Resources.Network.Network'Class
         then
            -- add the transactions associated with the network drivers
            case Processing_Resources.Network.Transmission_Mode
              (Processing_Resources.Network.Network'Class
               (Proc_Ref.all)) is
               when Simplex | Half_Duplex=>
                  Index:=1;
               when Full_Duplex =>
                  Index:=2;
            end case;
            Processing_Resources.Network.Rewind_Drivers
              (Processing_Resources.Network.Network'class(Proc_Ref.all),
               Drv_Iterator);
            for D in 1..Processing_Resources.Network.Num_Of_Drivers
              (Processing_Resources.Network.Network'Class(Proc_Ref.all))
            loop
               Processing_Resources.Network.Get_Next_Driver
                 (Processing_Resources.Network.Network'Class(Proc_Ref.all),
                  Drv_Ref,Drv_Iterator);
               if Drv_Ref.all in Drivers.Packet_Driver'Class then
                  if Drv_Ref.all in Drivers.Character_Packet_Driver'Class then
                     Max:=Max+2*Index;
                  elsif Drv_Ref.all in Drivers.RTEP_Packet_Driver'Class then
                     Max:=Max+4*Index;
                  else
                     Max:=Max+Index;
                  end if;
               end if;
            end loop;
         elsif Proc_Ref.all in
           Processing_Resources.Processor.Regular_Processor'Class
         then
            --add the transactions caused by Ticker system timers
            if Processing_Resources.Processor.The_System_Timer
              (Processing_Resources.Processor.Regular_Processor'Class
               (Proc_Ref.all))/=null and then
              Processing_Resources.Processor.The_System_Timer
              (Processing_Resources.Processor.Regular_Processor'Class
               (Proc_Ref.all)).all in Timers.Ticker'Class
            then
               Max:=Max+1;
            end if;
         else
            raise Incorrect_Object;
         end if;
      end loop;

      -- Transactions caused by independent tasks originated by
      -- actions with sporadic servers
      -- Also, transactions caused by rate divisors
      -- Also, transactions caused by polling scheduler overheads

      declare
         Trans_Ref : Transactions.Transaction_Ref;
         T_Iterator : Transactions.Lists.Iteration_Object;
         An_Event_Handler_Ref : Graphs.Event_Handler_Ref;
         Iterator : Transactions.Event_Handler_Iteration_Object;
         Sch_Server_Ref: Scheduling_Servers.Scheduling_Server_Ref;
         Counter : Integer;
         Has_SS : Boolean;

      begin
         Transactions.Lists.Rewind(The_System.Transactions,T_Iterator);
         for I in 1..Transactions.Lists.Size(The_System.Transactions)
         loop
            Transactions.Lists.Get_Next_Item
              (Trans_Ref,The_System.Transactions,T_Iterator);
            Transactions.Rewind_Event_Handlers(Trans_Ref.all,Iterator);
            Counter:=0;
            Has_SS :=False;
            for I in 1..Transactions.Num_Of_Event_Handlers(Trans_Ref.all)
            loop
               Transactions.Get_Next_Event_Handler
                 (Trans_Ref.all,An_Event_Handler_Ref,Iterator);
               if An_Event_Handler_Ref.all in
                 Graphs.Event_Handlers.Activity'Class
               then
                  Sch_Server_Ref:=Graphs.Event_Handlers.Activity_Server
                    (Graphs.Event_Handlers.Activity'Class
                     (An_Event_Handler_Ref.all));
                  -- Polling servers
                  if Scheduling_Servers.Server_Sched_Parameters
                    (Sch_Server_Ref.all).all in
                    Scheduling_Parameters.Polling_Policy'Class
                  then
                     Counter:=Counter+1;
                  end if;
                  -- Sporadic servers
                  if Has_SS then
                     Counter:=Counter+1;
                  else
                     if Scheduling_Servers.Server_Sched_Parameters
                       (Sch_Server_Ref.all).all in
                       Scheduling_Parameters.Sporadic_Server_Policy'Class
                     then
                        Has_SS:=True;
                        Counter:=Counter+1;
                     end if;
                  end if;
               elsif An_Event_Handler_Ref.all in
                 Graphs.Event_Handlers.Rate_Divisor'Class
               then
                  Counter:=Counter+1;
               end if;
            end loop;
            Max:=Max+Counter;
         end loop;
      end;

      return Max;

   end Calculate_Max_Transactions;

   -----------------------------------------
   -- Calculate_Max_Tasks_Per_Transaction --
   -----------------------------------------

   function Calculate_Max_Tasks_Per_Transaction
     (The_System : Systems.System) return Natural
   is
      Max: Natural:=0;
      Current : Natural;
      Trans_Ref : Transactions.Transaction_Ref;
      Iterator : Transactions.Lists.Iteration_Object;
   begin
      Transactions.Lists.Rewind(The_System.Transactions,Iterator);
      for I in 1..Transactions.Lists.Size(The_System.Transactions)
      loop
         Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Iterator);
         Current:=Transactions.Num_Of_Event_Handlers(Trans_Ref.all);
         if Current>Max then
            Max:=Current;
         end if;
      end loop;
      -- use double the number to take into account timer actions
      return 2*Max;
   end Calculate_Max_Tasks_Per_Transaction;

end Mast.Max_Numbers;
