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
with Glib;                    use Glib;
with Gtk;                     use Gtk;
with Gdk.Types;               use Gdk.Types;
with Gtk.Widget;              use Gtk.Widget;
with Gtk.Enums;               use Gtk.Enums;
with Gtkada.Handlers;         use Gtkada.Handlers;
with Callbacks_Mast_Editor;   use Callbacks_Mast_Editor;
with Item_Menu_Pkg.Callbacks; use Item_Menu_Pkg.Callbacks;

package body Item_Menu_Pkg is

   procedure Gtk_New (Item_Menu : out Item_Menu_Access) is
   begin
      Item_Menu := new Item_Menu_Record;
      Item_Menu_Pkg.Initialize (Item_Menu);
   end Gtk_New;

   procedure Initialize (Item_Menu : access Item_Menu_Record'Class) is
      pragma Suppress (All_Checks);
   begin
      Gtk.Menu.Initialize (Item_Menu);
      Set_Border_Width (Item_Menu, 0);

      Gtk_New (Item_Menu.Properties, "Properties");
      Set_Right_Justify (Item_Menu.Properties, False);
      Append (Item_Menu, Item_Menu.Properties);
      Show (Item_Menu.Properties);

      Gtk_New (Item_Menu.Remove, "Remove");
      Set_Right_Justify (Item_Menu.Remove, False);
      Append (Item_Menu, Item_Menu.Remove);
      Show (Item_Menu.Remove);

      Gtk_New (Item_Menu.Separador1);
      Set_Right_Justify (Item_Menu.Separador1, False);
      Append (Item_Menu, Item_Menu.Separador1);
      Show (Item_Menu.Separador1);

      Gtk_New (Item_Menu.About, "About...");
      Set_Right_Justify (Item_Menu.About, False);
      Menu_Item_Callback.Connect
        (Item_Menu.About,
         "activate",
         Menu_Item_Callback.To_Marshaller (On_About_Activate'Access));
      Append (Item_Menu, Item_Menu.About);
      Show (Item_Menu.About);

      Gtk_New (Item_Menu.Separador2);
      Set_Right_Justify (Item_Menu.Separador2, False);
      Append (Item_Menu, Item_Menu.Separador2);
      Show (Item_Menu.Separador2);

      Gtk_New (Item_Menu.Quit, "Quit");
      Set_Right_Justify (Item_Menu.Quit, False);
      Menu_Item_Callback.Connect
        (Item_Menu.Quit,
         "activate",
         Menu_Item_Callback.To_Marshaller (On_Quit_Activate'Access));
      Append (Item_Menu, Item_Menu.Quit);
      Show (Item_Menu.Quit);

      Popup (Item_Menu);

   end Initialize;

end Item_Menu_Pkg;
