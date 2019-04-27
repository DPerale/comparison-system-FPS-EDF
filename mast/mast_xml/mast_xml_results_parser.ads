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

with Dom.Core;
with Mast.Systems;
with Ada.Text_Io;

package Mast_XML_Results_Parser is

   --    Mast_XML_Results_Parser parses a Mast_Results file, reading from an
   --    XML format into a Mast_System data structure in Ada.
   --    It may raise the following exceptions:
   --    <Mast_XML_Exceptions.Syntax_Error>:
   --         there has been a problem during de parsing.
   --
   procedure Parse
     (Mast_System : in out Mast.Systems.System;
      File: in out Ada.Text_IO.File_Type);

private

   procedure Add_Shared_Resource
     (Mast_System:in out Mast.Systems.System;
      Shared_Res_List: Dom.Core.Node_List);

   procedure Add_Transaction
     (Mast_System:in out Mast.Systems.System;
      Trans_Node_List: in Dom.Core.Node_List);

   procedure Add_Operation
     (Mast_System:in out Mast.Systems.System;
      Operation_List: Dom.Core.Node_List);

   procedure Add_Scheduling_Server
     (Mast_System:in out Mast.Systems.System;
      Sched_Serv_Node_List: in Dom.Core.Node_List);

   procedure Add_Processing_Resource
     (Mast_System:in out Mast.Systems.System;
      Processors_List: in Dom.Core.Node_List);

end Mast_XML_Results_Parser;
