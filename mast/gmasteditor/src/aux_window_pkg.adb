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
with Glib;                  use Glib;
with Gtk;                   use Gtk;
with Gdk.Types;             use Gdk.Types;
with Gtk.Widget;            use Gtk.Widget;
with Gtk.Enums;             use Gtk.Enums;
with Gtkada.Handlers;       use Gtkada.Handlers;
with Callbacks_Mast_Editor; use Callbacks_Mast_Editor;
with Mast_Editor_Intl;      use Mast_Editor_Intl;
with Pango.Font;            use Pango.Font;

package body Aux_Window_Pkg is

   procedure Gtk_New (Aux_Window : out Aux_Window_Access) is
   begin
      Aux_Window := new Aux_Window_Record;
      Aux_Window_Pkg.Initialize (Aux_Window);
   end Gtk_New;

   procedure Initialize (Aux_Window : access Aux_Window_Record'Class) is
      pragma Suppress (All_Checks);
      Pixmaps_Dir : constant String := "pixmaps/";
   begin
      Gtk.Window.Initialize (Aux_Window, Window_Toplevel);
      Set_Title (Aux_Window, -"Auxiliar Window");
      Set_Position (Aux_Window, Win_Pos_Center);
      Set_Modal (Aux_Window, False);
      Set_Default_Size (Aux_Window, 500, 400);

      Gtk_New (Aux_Window.Frame);
      Set_Border_Width (Aux_Window.Frame, 5);
      Set_Label_Align (Aux_Window.Frame, 0.0, 0.5);
      Set_Shadow_Type (Aux_Window.Frame, Shadow_None);
      Add (Aux_Window, Aux_Window.Frame);

      Gtk_New (Aux_Window.Scrolled);
      Set_Policy (Aux_Window.Scrolled, Policy_Always, Policy_Always);
      Set_Shadow_Type (Aux_Window.Scrolled, Shadow_None);
      Add (Aux_Window.Frame, Aux_Window.Scrolled);

      -- We add Canvas to the Frame
      Gtk_New (Aux_Window.Aux_Canvas);
      Configure
        (Aux_Window.Aux_Canvas,
         Grid_Size        => 0,
         Annotation_Font  => Pango.Font.From_String (Default_Annotation_Font),
         Arc_Link_Offset  => Default_Arc_Link_Offset,
         Arrow_Angle      => Default_Arrow_Angle,
         Arrow_Length     => Default_Arrow_Length,
         Motion_Threshold => Default_Motion_Threshold);
      Add (Aux_Window.Scrolled, Aux_Window.Aux_Canvas);

   end Initialize;

end Aux_Window_Pkg;
