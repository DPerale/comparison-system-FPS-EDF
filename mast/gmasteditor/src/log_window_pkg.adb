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

package body Log_Window_Pkg is

   procedure Gtk_New (Log_Window : out Log_Window_Access) is
   begin
      Log_Window := new Log_Window_Record;
      Log_Window_Pkg.Initialize (Log_Window);
   end Gtk_New;

   procedure Initialize (Log_Window : access Log_Window_Record'Class) is
      pragma Suppress (All_Checks);
      Pixmaps_Dir : constant String := "pixmaps/";
   begin
      Gtk.Window.Initialize (Log_Window, Window_Toplevel);
      Set_Title (Log_Window, -"gMAST Log");
      Set_Position (Log_Window, Win_Pos_Center_Always);
      Set_Modal (Log_Window, False);
      Set_Default_Size (Log_Window, 600, 400);

      Gtk_New (Log_Window.Frame);
      Set_Border_Width (Log_Window.Frame, 5);
      Set_Label_Align (Log_Window.Frame, 0.0, 0.5);
      Set_Shadow_Type (Log_Window.Frame, Shadow_None);
      Add (Log_Window, Log_Window.Frame);

      Gtk_New (Log_Window.Scrolledwindow);
      Set_Policy (Log_Window.Scrolledwindow, Policy_Always, Policy_Always);
      Set_Shadow_Type (Log_Window.Scrolledwindow, Shadow_None);
      Add (Log_Window.Frame, Log_Window.Scrolledwindow);

      Gtk_New (Log_Window.Textview);
      Set_Editable (Log_Window.Textview, False);
      Set_Justification (Log_Window.Textview, Justify_Left);
      Set_Wrap_Mode (Log_Window.Textview, Wrap_None);
      Set_Cursor_Visible (Log_Window.Textview, True);
      Set_Pixels_Above_Lines (Log_Window.Textview, 0);
      Set_Pixels_Below_Lines (Log_Window.Textview, 0);
      Set_Pixels_Inside_Wrap (Log_Window.Textview, 0);
      Set_Left_Margin (Log_Window.Textview, 5);
      Set_Right_Margin (Log_Window.Textview, 0);
      Set_Indent (Log_Window.Textview, 0);
      declare
         Iter : Gtk_Text_Iter;
      begin
         Get_Iter_At_Line (Get_Buffer (Log_Window.Textview), Iter, 0);
         Insert (Get_Buffer (Log_Window.Textview), Iter, -(""));
      end;
      Add (Log_Window.Scrolledwindow, Log_Window.Textview);

   end Initialize;

end Log_Window_Pkg;
