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
with Gtk.Handlers;
pragma Elaborate_All (Gtk.Handlers);
with Gtk.Menu_Item;              use Gtk.Menu_Item;
with Gtk.Button;                 use Gtk.Button;
with Gtk.GEntry;                 use Gtk.GEntry;
with Gtk.Dialog;                 use Gtk.Dialog;
with Gtk.Window;                 use Gtk.Window;
with Driver_Dialog_Pkg;          use Driver_Dialog_Pkg;
with Cop_Dialog_Pkg;             use Cop_Dialog_Pkg;
with External_Dialog_Pkg;        use External_Dialog_Pkg;
with Internal_Dialog_Pkg;        use Internal_Dialog_Pkg;
with Import_File_Selection_Pkg;  use Import_File_Selection_Pkg;
with Message_Tx_Dialog_Pkg;      use Message_Tx_Dialog_Pkg;
with Mieh_Dialog_Pkg;            use Mieh_Dialog_Pkg;
with Moeh_Dialog_Pkg;            use Moeh_Dialog_Pkg;
with Network_Dialog_Pkg;         use Network_Dialog_Pkg;
with Open_File_Selection_Pkg;    use Open_File_Selection_Pkg;
with Prime_Sched_Dialog_Pkg;     use Prime_Sched_Dialog_Pkg;
with Processor_Dialog_Pkg;       use Processor_Dialog_Pkg;
with Save_Changes_Dialog_Pkg;    use Save_Changes_Dialog_Pkg;
with Save_File_Selection_Pkg;    use Save_File_Selection_Pkg;
with Shared_Resource_Dialog_Pkg; use Shared_Resource_Dialog_Pkg;
with Sched_Server_Dialog_Pkg;    use Sched_Server_Dialog_Pkg;
with Second_Sched_Dialog_Pkg;    use Second_Sched_Dialog_Pkg;
with Seh_Dialog_Pkg;             use Seh_Dialog_Pkg;
with Sop_Dialog_Pkg;             use Sop_Dialog_Pkg;
with Timer_Dialog_Pkg;           use Timer_Dialog_Pkg;
with Wizard_Input_Dialog_Pkg;    use Wizard_Input_Dialog_Pkg;

package Callbacks_Mast_Editor is

   package Menu_Item_Callback is new Gtk.Handlers.Callback (
      Gtk_Menu_Item_Record);

   package Button_Callback is new Gtk.Handlers.Callback (Gtk_Button_Record);

   package Entry_Callback is new Gtk.Handlers.Callback (Gtk_Entry_Record);

   package Dialog_Callback is new Gtk.Handlers.Callback (Gtk_Dialog_Record);

   package Cop_Dialog_Callback is new Gtk.Handlers.Callback (
      Cop_Dialog_Record);

   package Sop_Dialog_Callback is new Gtk.Handlers.Callback (
      Sop_Dialog_Record);

   package Message_Tx_Dialog_Callback is new Gtk.Handlers.Callback (
      Message_Tx_Dialog_Record);

   package Shared_Resource_Dialog_Callback is new Gtk.Handlers.Callback (
      Shared_Resource_Dialog_Record);

   package Processor_Dialog_Callback is new Gtk.Handlers.Callback (
      Processor_Dialog_Record);

   package Network_Dialog_Callback is new Gtk.Handlers.Callback (
      Network_Dialog_Record);

   package Sched_Server_Dialog_Callback is new Gtk.Handlers.Callback (
      Sched_Server_Dialog_Record);

   package Prime_Sched_Dialog_Callback is new Gtk.Handlers.Callback (
      Prime_Sched_Dialog_Record);

   package Second_Sched_Dialog_Callback is new Gtk.Handlers.Callback (
      Second_Sched_Dialog_Record);

   package External_Dialog_Callback is new Gtk.Handlers.Callback (
      External_Dialog_Record);

   package Internal_Dialog_Callback is new Gtk.Handlers.Callback (
      Internal_Dialog_Record);

   --MGH

   package F_Internal_Dialog_Callback is new Gtk.Handlers.Return_Callback (
      Internal_Dialog_Record,
      Boolean);

   package Seh_Dialog_Callback is new Gtk.Handlers.Callback (
      Seh_Dialog_Record);

   package Mieh_Dialog_Callback is new Gtk.Handlers.Callback (
      Mieh_Dialog_Record);

   package Moeh_Dialog_Callback is new Gtk.Handlers.Callback (
      Moeh_Dialog_Record);

   package Driver_Dialog_Callback is new Gtk.Handlers.Callback (
      Driver_Dialog_Record);

   package Save_Changes_Dialog_Callback is new Gtk.Handlers.Callback (
      Save_Changes_Dialog_Record);

   package Open_File_Selection_Callback is new Gtk.Handlers.Callback (
      Open_File_Selection_Record);

   package Save_File_Selection_Callback is new Gtk.Handlers.Callback (
      Save_File_Selection_Record);

   package Import_File_Selection_Callback is new Gtk.Handlers.Callback (
      Import_File_Selection_Record);

   package Wizard_Input_Dialog_Callback is new Gtk.Handlers.Callback (
      Wizard_Input_Dialog_Record);

   package Timer_Dialog_Callback is new Gtk.Handlers.Callback (
      Timer_Dialog_Record);

end Callbacks_Mast_Editor;
