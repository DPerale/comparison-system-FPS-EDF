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
with Ada.Text_IO;
with Mast_Editor.Processing_Resources;
with Mast_Editor.Scheduling_Servers;
with Mast_Editor.Shared_Resources;
with Mast_Editor.Operations;
with Mast_Editor.Transactions;
with Mast_Editor.Schedulers;
with Mast_Editor.Timers;
with Mast_Editor.Drivers;
with Mast_Editor.Links;
with Mast_Editor.Event_Handlers;
with Var_Strings;                      use Var_Strings;
with Mast;                             use Mast;

package Mast_Editor.Systems is

   type ME_System is tagged record
      Model_Name                     : Var_String := Null_Var_String;
      Model_Date                     : Date       := "                   ";
      Me_Processing_Resources        : 
        Mast_Editor.Processing_Resources.Lists.List;
      Me_Shared_Resources            : Mast_Editor.Shared_Resources.Lists.List;
      Me_Operations                  : Mast_Editor.Operations.Lists.List;
      Me_Transactions                : Mast_Editor.Transactions.Lists.List;
      Me_Scheduling_Servers          : 
        Mast_Editor.Scheduling_Servers.Lists.List;
      Me_Schedulers                  : Mast_Editor.Schedulers.Lists.List;
      Me_Timers                      : Mast_Editor.Timers.Lists.List;
      Me_Drivers                     : Mast_Editor.Drivers.Lists.List;
      Me_Schedulers_In_Server_Canvas : Mast_Editor.Schedulers.Lists.List;
      Me_Servers_In_Proc_Canvas      : 
        Mast_Editor.Scheduling_Servers.Lists.List;
      Me_Links                       : Mast_Editor.Links.Lists.List;
      Me_Event_Handlers              : Mast_Editor.Event_Handlers.Lists.List;
   end record;

   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_System  : in out ME_System;
      Indentation : Positive := 1);

end Mast_Editor.Systems;
