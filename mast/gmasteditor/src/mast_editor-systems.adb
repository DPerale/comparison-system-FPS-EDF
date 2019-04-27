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
with Mast.IO;
package body Mast_Editor.Systems is

   -----------
   -- Print --
   -----------
   procedure Print
     (File        : Ada.Text_IO.File_Type;
      The_System  : in out ME_System;
      Indentation : Positive := 1)
   is
   begin
      if The_System.Model_Name /= Null_Var_String or
         The_System.Model_Date /= "                   "
      then
         Ada.Text_IO.Set_Col (File, Ada.Text_IO.Count (Indentation));
         if The_System.Model_Name /= Null_Var_String then
            Ada.Text_IO.Put
              (File,
               Mast.IO.Name_Image (The_System.Model_Name));
         end if;
         if The_System.Model_Date /= "                   " then
            Ada.Text_IO.Put (File, " ");
            Ada.Text_IO.Put
              (File,
               Mast.IO.Date_Image (The_System.Model_Date));
         end if;
         Ada.Text_IO.Put (File, " ");
         Ada.Text_IO.New_Line (File);
      else
         Ada.Text_IO.Set_Col (File, Ada.Text_IO.Count (Indentation));
         Ada.Text_IO.Put (File, " ");
         Ada.Text_IO.New_Line (File);
      end if;

      Mast_Editor.Processing_Resources.Print
        (File,
         The_System.Me_Processing_Resources,
         Indentation);
      Mast_Editor.Timers.Print (File, The_System.Me_Timers, Indentation);
      Mast_Editor.Drivers.Print (File, The_System.Me_Drivers, Indentation);
      Mast_Editor.Schedulers.Print
        (File,
         The_System.Me_Schedulers,
         Indentation);
      Mast_Editor.Schedulers.Print
        (File,
         The_System.Me_Schedulers_In_Server_Canvas,
         Indentation);
      Mast_Editor.Scheduling_Servers.Print
        (File,
         The_System.Me_Scheduling_Servers,
         Indentation);
      Mast_Editor.Scheduling_Servers.Print
        (File,
         The_System.Me_Servers_In_Proc_Canvas,
         Indentation);
      Mast_Editor.Shared_Resources.Print
        (File,
         The_System.Me_Shared_Resources,
         Indentation);
      Mast_Editor.Operations.Print
        (File,
         The_System.Me_Operations,
         Indentation);
      Mast_Editor.Transactions.Print
        (File,
         The_System.Me_Transactions,
         Indentation);
      Mast_Editor.Links.Print (File, The_System.Me_Links, Indentation);
      Mast_Editor.Event_Handlers.Print
        (File,
         The_System.Me_Event_Handlers,
         Indentation);

   end Print;

end Mast_Editor.Systems;
