-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2004                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors: Michael Gonzalez       mgh@ctr.unican.es                 --
--          Jose Javier Gutierrez  gutierjj@ctr.unican.es            --
--          Jose Carlos Palencia   palencij@ctr.unican.es            --
--          Jose Maria Drake       drakej@ctr.unican.es              --
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

with Gtk; use Gtk;
with Gtk.Main;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Check_Button; use Gtk.Check_Button;
with Mast_Analysis_Pkg; use Mast_Analysis_Pkg;
with Fileselection1_Pkg; use Fileselection1_Pkg;
with Error_Window_Pkg; use Error_Window_Pkg;
with Error_Inputfile_Pkg; use Error_Inputfile_Pkg;
with Read_Past_Values;
with Help_Pkg; use Help_Pkg;
with Annealing_Window_Pkg; use Annealing_Window_Pkg;
with Hopa_Window_Pkg; use Hopa_Window_Pkg;
with Help_Hopa_Pkg; use Help_Hopa_Pkg;
with Help_Annealing_Pkg; use Help_Annealing_Pkg;
with Gnat.Float_Control;

procedure Gmast_Analysis is
begin
   Gtk.Main.Set_Locale;
   Gtk.Main.Init;
   Gnat.Float_Control.Reset;
   -- This is required because of a bug in some Windows 2000 drivers
   -- delete if using another compiler
   Gtk_New (Mast_Analysis);
   Show_All (Mast_Analysis);
   Set_Active(Mast_Analysis.View_Results,False);
   Set_Sensitive(Mast_Analysis.View_Results,False);
   Read_Past_Values;
--   Gtk_New (Fileselection1);
--   Show_All (Fileselection1);
--   Gtk_New (Error_Window);
--   Show_All (Error_Window);
--   Gtk_New (Error_Inputfile);
--   Show_All (Error_Inputfile);
--   Gtk_New (Help);
--   Show_All (Help);
--   Gtk_New (Annealing_Window);
--   Show_All (Annealing_Window);
--   Gtk_New (Hopa_Window);
--   Show_All (Hopa_Window);
--   Gtk_New (Help_Hopa);
--   Show_All (Help_Hopa);
--   Gtk_New (Help_Annealing);
--   Show_All (Help_Annealing);
   Gtk.Main.Main;
end Gmast_Analysis;
