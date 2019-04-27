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
with Glib;                             use Glib;
with Gtk;                              use Gtk;
with Gdk.Types;                        use Gdk.Types;
with Gtk.Widget;                       use Gtk.Widget;
with Gtk.Enums;                        use Gtk.Enums;
with Gtkada.Handlers;                  use Gtkada.Handlers;
with Callbacks_Mast_Editor;            use Callbacks_Mast_Editor;
with Mast_Editor_Intl;                 use Mast_Editor_Intl;
with Mast_Editor_Window_Pkg.Callbacks; use Mast_Editor_Window_Pkg.Callbacks;

with Gtk.Handlers;
with Gtk.Main;
with Mast_Editor.Processing_Resources;
with Mast_Editor.Schedulers;
with Mast_Editor.Scheduling_Servers;
with Mast_Editor.Shared_Resources;
with Mast_Editor.Operations;
with Mast_Editor.Transactions;

package body Mast_Editor_Window_Pkg is

   package Window_Cb is new Handlers.Callback (Gtk_Widget_Record);
   package Return_Window_Cb is new Handlers.Return_Callback (
      Gtk_Widget_Record,
      Boolean);

   procedure Exit_Main (Object : access Gtk_Widget_Record'Class);

   -----------------
   --  Exit_Main  --
   -----------------
   procedure Exit_Main (Object : access Gtk_Widget_Record'Class) is
   begin
      Gtk.Main.Main_Quit;
   end Exit_Main;

   -------------
   -- Gtk_New --
   -------------
   procedure Gtk_New (Mast_Editor_Window : out Mast_Editor_Window_Access) is
   begin
      Mast_Editor_Window := new Mast_Editor_Window_Record;
      Mast_Editor_Window_Pkg.Initialize (Mast_Editor_Window);
   end Gtk_New;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Mast_Editor_Window : access Mast_Editor_Window_Record'Class)
   is
      pragma Suppress (All_Checks);
      Pixmaps_Dir     : constant String := "/";
      The_Accel_Group : Gtk_Accel_Group;
      Tooltips        : Gtk_Tooltips;

   begin
      Gtk.Window.Initialize (Mast_Editor_Window, Window_Toplevel);
      Set_Title (Mast_Editor_Window, -"gMAST: (untitled)");
      Set_Policy (Mast_Editor_Window, False, True, False);
      Set_Position (Mast_Editor_Window, Win_Pos_Center);
      Set_Modal (Mast_Editor_Window, False);
      Set_USize (Mast_Editor_Window, 750, 525);

      Return_Callback.Connect
        (Mast_Editor_Window,
         "delete_event",
         On_Main_Window_Delete_Event'Access,
         False);

      Window_Cb.Connect
        (Mast_Editor_Window,
         "destroy",
         Window_Cb.To_Marshaller (Exit_Main'Access));
      --------------------------------
      Gtk_New_Vbox (Mast_Editor_Window.Vbox_Main_Window, False, 0);

      Gtk_New (Mast_Editor_Window.Menubar);

      Gtk_New_With_Mnemonic (Mast_Editor_Window.File, -("File"));

      Gtk_New (Mast_Editor_Window.File_Menu);

      Gtk_New_With_Mnemonic (Mast_Editor_Window.New1, -("New"));

      Gtk_New (The_Accel_Group);
      Add_Accel_Group (Mast_Editor_Window, The_Accel_Group);
      Add_Accelerator
        (Mast_Editor_Window.New1,
         "activate",
         The_Accel_Group,
         Gdk.Types.Keysyms.GDK_N,
         Gdk.Types.Control_Mask,
         Accel_Visible);
      Gtk_New (Tooltips);
      Set_Tip (Tooltips, Mast_Editor_Window.New1, -"Create new file");
      Menu_Item_Callback.Connect
        (Mast_Editor_Window.New1,
         "activate",
         Menu_Item_Callback.To_Marshaller (On_New_Activate'Access),
         False);
      Append (Mast_Editor_Window.File_Menu, Mast_Editor_Window.New1);
      Gtk_New_With_Mnemonic (Mast_Editor_Window.Open, -("Open..."));

      Add_Accelerator
        (Mast_Editor_Window.Open,
         "activate",
         The_Accel_Group,
         Gdk.Types.Keysyms.GDK_O,
         Gdk.Types.Control_Mask,
         Accel_Visible);
      Set_Tip (Tooltips, Mast_Editor_Window.Open, -"Open an existing file");
      Menu_Item_Callback.Connect
        (Mast_Editor_Window.Open,
         "activate",
         Menu_Item_Callback.To_Marshaller (On_Open_Activate'Access),
         False);
      Append (Mast_Editor_Window.File_Menu, Mast_Editor_Window.Open);
      Gtk_New_With_Mnemonic (Mast_Editor_Window.Import, -("Import..."));

      Set_Tip
        (Tooltips,
         Mast_Editor_Window.Import,
         -"Import system components from another file");
      Menu_Item_Callback.Connect
        (Mast_Editor_Window.Import,
         "activate",
         Menu_Item_Callback.To_Marshaller (On_Import_Activate'Access),
         False);
      Append (Mast_Editor_Window.File_Menu, Mast_Editor_Window.Import);
      Gtk_New_With_Mnemonic (Mast_Editor_Window.Save, -("Save"));

      Add_Accelerator
        (Mast_Editor_Window.Save,
         "activate",
         The_Accel_Group,
         Gdk.Types.Keysyms.GDK_S,
         Gdk.Types.Control_Mask,
         Accel_Visible);
      Set_Tip (Tooltips, Mast_Editor_Window.Save, -"Save current file");
      Menu_Item_Callback.Connect
        (Mast_Editor_Window.Save,
         "activate",
         Menu_Item_Callback.To_Marshaller (On_Save_Activate'Access),
         False);
      Append (Mast_Editor_Window.File_Menu, Mast_Editor_Window.Save);
      Gtk_New_With_Mnemonic (Mast_Editor_Window.Save_As, -("Save As..."));

      Set_Tip
        (Tooltips,
         Mast_Editor_Window.Save_As,
         -"Save current file as...");
      Menu_Item_Callback.Connect
        (Mast_Editor_Window.Save_As,
         "activate",
         Menu_Item_Callback.To_Marshaller (On_Save_As_Activate'Access),
         False);
      Append (Mast_Editor_Window.File_Menu, Mast_Editor_Window.Save_As);
      Gtk_New (Mast_Editor_Window.Separator1);

      Append (Mast_Editor_Window.File_Menu, Mast_Editor_Window.Separator1);
      Gtk_New_With_Mnemonic (Mast_Editor_Window.Quit, -("Quit"));

      Add_Accelerator
        (Mast_Editor_Window.Quit,
         "activate",
         The_Accel_Group,
         Gdk.Types.Keysyms.GDK_Q,
         Gdk.Types.Control_Mask,
         Accel_Visible);
      Set_Tip (Tooltips, Mast_Editor_Window.Quit, -"Quit application");
      Menu_Item_Callback.Connect
        (Mast_Editor_Window.Quit,
         "activate",
         Menu_Item_Callback.To_Marshaller (On_Quit_Activate'Access),
         False);
      Append (Mast_Editor_Window.File_Menu, Mast_Editor_Window.Quit);
      Set_Submenu (Mast_Editor_Window.File, Mast_Editor_Window.File_Menu);
      Append (Mast_Editor_Window.Menubar, Mast_Editor_Window.File);
      Gtk_New_With_Mnemonic (Mast_Editor_Window.Edition_Tools, -("Tools"));

      Gtk_New (Mast_Editor_Window.Edition_Tools_Menu);

      Gtk_New_With_Mnemonic
        (Mast_Editor_Window.Create_Simple_Transaction,
         -("Create Simple Transaction ..."));

      Set_Tip
        (Tooltips,
         Mast_Editor_Window.Create_Simple_Transaction,
         -"Launch Simple Transaction Wizard Tool");
      Menu_Item_Callback.Connect
        (Mast_Editor_Window.Create_Simple_Transaction,
         "activate",
         Menu_Item_Callback.To_Marshaller
            (On_Create_Simple_Transaction_Activate'Access),
         False);
      Append
        (Mast_Editor_Window.Edition_Tools_Menu,
         Mast_Editor_Window.Create_Simple_Transaction);
      --     Gtk_New_With_Mnemonic
      --(Mast_Editor_Window.Create_Linear_Transaction, -("Create Linear
      --Transaction ..."));

      --     Set_Tip (Tooltips, Mast_Editor_Window.Create_Linear_Transaction,
      ---"Launch Linear Transaction Wizard Tool");
      --     Menu_Item_Callback.Connect
      --       (Mast_Editor_Window.Create_Linear_Transaction, "activate",
      --        Menu_Item_Callback.To_Marshaller
      --(On_Create_Linear_Transaction_Activate'Access), False);
      --     Append (Mast_Editor_Window.Edition_Tools_Menu,
      --Mast_Editor_Window.Create_Linear_Transaction);
      Set_Submenu
        (Mast_Editor_Window.Edition_Tools,
         Mast_Editor_Window.Edition_Tools_Menu);
      Append (Mast_Editor_Window.Menubar, Mast_Editor_Window.Edition_Tools);
      Gtk_New_With_Mnemonic (Mast_Editor_Window.Analyze, -("Analyze"));

      Gtk_New (Mast_Editor_Window.Analyze_Menu);

      Gtk_New_With_Mnemonic
        (Mast_Editor_Window.Analysis,
         -("Worst-Case RTA"));

      Set_Tip
        (Tooltips,
         Mast_Editor_Window.Analysis,
         -"Show Worst-Case Real Time Analysis screen");
      Menu_Item_Callback.Connect
        (Mast_Editor_Window.Analysis,
         "activate",
         Menu_Item_Callback.To_Marshaller (On_Analysis_Activate'Access),
         False);
      Append (Mast_Editor_Window.Analyze_Menu, Mast_Editor_Window.Analysis);
      ---------
      Set_Sensitive (Mast_Editor_Window.Analysis, False);
      ---------
      Gtk_New_With_Mnemonic
        (Mast_Editor_Window.Simulation,
         -("Simulation"));

      Set_Tip
        (Tooltips,
         Mast_Editor_Window.Simulation,
         -"Launch Simulation Tool");
      Menu_Item_Callback.Connect
        (Mast_Editor_Window.Simulation,
         "activate",
         Menu_Item_Callback.To_Marshaller (On_Simulation_Activate'Access),
         False);
      Append (Mast_Editor_Window.Analyze_Menu, Mast_Editor_Window.Simulation);
      ---------
      Set_Sensitive (Mast_Editor_Window.Simulation, False);
      ---------
      Set_Submenu
        (Mast_Editor_Window.Analyze,
         Mast_Editor_Window.Analyze_Menu);
      Append (Mast_Editor_Window.Menubar, Mast_Editor_Window.Analyze);
      Gtk_New_With_Mnemonic (Mast_Editor_Window.Results, -("Results"));

      Gtk_New (Mast_Editor_Window.Results_Menu);

      Gtk_New_With_Mnemonic
        (Mast_Editor_Window.View_Results,
         -("View Results"));

      Set_Tip
        (Tooltips,
         Mast_Editor_Window.View_Results,
         -"Show analysis results screen");
      Menu_Item_Callback.Connect
        (Mast_Editor_Window.View_Results,
         "activate",
         Menu_Item_Callback.To_Marshaller (On_View_Results_Activate'Access),
         False);
      Append
        (Mast_Editor_Window.Results_Menu,
         Mast_Editor_Window.View_Results);
      Set_Submenu
        (Mast_Editor_Window.Results,
         Mast_Editor_Window.Results_Menu);
      Set_Tip
        (Tooltips,
         Mast_Editor_Window.Results,
         -"Show results screen");
      Append (Mast_Editor_Window.Menubar, Mast_Editor_Window.Results);
      Gtk_New_With_Mnemonic (Mast_Editor_Window.Help, -("Help"));

      Gtk_New (Mast_Editor_Window.Help_Menu);

      Gtk_New_With_Mnemonic (Mast_Editor_Window.About, -("About..."));

      Set_Tip
        (Tooltips,
         Mast_Editor_Window.About,
         -"About this application");
      Menu_Item_Callback.Connect
        (Mast_Editor_Window.About,
         "activate",
         Menu_Item_Callback.To_Marshaller (On_About_Activate'Access),
         False);
      Append (Mast_Editor_Window.Help_Menu, Mast_Editor_Window.About);
      Set_Submenu (Mast_Editor_Window.Help, Mast_Editor_Window.Help_Menu);
      Append (Mast_Editor_Window.Menubar, Mast_Editor_Window.Help);
      Pack_Start
        (Mast_Editor_Window.Vbox_Main_Window,
         Mast_Editor_Window.Menubar,
         Expand  => False,
         Fill    => True,
         Padding => 0);
      Gtk_New (Mast_Editor_Window.Notebook);
      Set_Scrollable (Mast_Editor_Window.Notebook, False);
      Set_Show_Border (Mast_Editor_Window.Notebook, True);
      Set_Show_Tabs (Mast_Editor_Window.Notebook, True);
      Set_Tab_Pos (Mast_Editor_Window.Notebook, Pos_Top);

      Gtk_New_Vbox (Mast_Editor_Window.Vbox1_Notebook, False, 0);

      Gtk_New (Mast_Editor_Window.Proc_Res_Frame);
      Set_Label_Align (Mast_Editor_Window.Proc_Res_Frame, 0.0, 0.5);
      Set_Shadow_Type (Mast_Editor_Window.Proc_Res_Frame, Shadow_Etched_In);

      Pack_Start
        (Mast_Editor_Window.Vbox1_Notebook,
         Mast_Editor_Window.Proc_Res_Frame,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Append_Page
        (Mast_Editor_Window.Notebook,
         Mast_Editor_Window.Vbox1_Notebook);
      Set_Tab_Label_Packing
        (Mast_Editor_Window.Notebook,
         Mast_Editor_Window.Vbox1_Notebook,
         False,
         True,
         Pack_Start);
      Gtk_New
        (Mast_Editor_Window.Label1,
         -("Processing Resources" & ASCII.LF & "And Schedulers"));
      Set_Alignment (Mast_Editor_Window.Label1, 0.5, 0.5);
      Set_Padding (Mast_Editor_Window.Label1, 0, 0);
      Set_Justify (Mast_Editor_Window.Label1, Justify_Center);
      Set_Line_Wrap (Mast_Editor_Window.Label1, False);
      Set_Selectable (Mast_Editor_Window.Label1, False);
      Set_Use_Markup (Mast_Editor_Window.Label1, False);
      Set_Use_Underline (Mast_Editor_Window.Label1, False);
      Set_Tab (Mast_Editor_Window.Notebook, 0, Mast_Editor_Window.Label1);

      Gtk_New_Vbox (Mast_Editor_Window.Vbox2_Notebook, False, 0);

      Gtk_New (Mast_Editor_Window.Sched_Server_Frame);
      Set_Label_Align (Mast_Editor_Window.Sched_Server_Frame, 0.0, 0.5);
      Set_Shadow_Type
        (Mast_Editor_Window.Sched_Server_Frame,
         Shadow_Etched_In);

      Pack_Start
        (Mast_Editor_Window.Vbox2_Notebook,
         Mast_Editor_Window.Sched_Server_Frame,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Append_Page
        (Mast_Editor_Window.Notebook,
         Mast_Editor_Window.Vbox2_Notebook);
      Set_Tab_Label_Packing
        (Mast_Editor_Window.Notebook,
         Mast_Editor_Window.Vbox2_Notebook,
         False,
         True,
         Pack_Start);
      Gtk_New
        (Mast_Editor_Window.Label2,
         -("Scheduling" & ASCII.LF & "Servers"));
      Set_Alignment (Mast_Editor_Window.Label2, 0.5, 0.5);
      Set_Padding (Mast_Editor_Window.Label2, 0, 0);
      Set_Justify (Mast_Editor_Window.Label2, Justify_Center);
      Set_Line_Wrap (Mast_Editor_Window.Label2, False);
      Set_Selectable (Mast_Editor_Window.Label2, False);
      Set_Use_Markup (Mast_Editor_Window.Label2, False);
      Set_Use_Underline (Mast_Editor_Window.Label2, False);
      Set_Tab (Mast_Editor_Window.Notebook, 1, Mast_Editor_Window.Label2);

      Gtk_New_Vbox (Mast_Editor_Window.Vbox3_Notebook, False, 0);

      Gtk_New (Mast_Editor_Window.Shared_Res_Frame);
      Set_Label_Align (Mast_Editor_Window.Shared_Res_Frame, 0.0, 0.5);
      Set_Shadow_Type (Mast_Editor_Window.Shared_Res_Frame, Shadow_Etched_In);

      Pack_Start
        (Mast_Editor_Window.Vbox3_Notebook,
         Mast_Editor_Window.Shared_Res_Frame,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Append_Page
        (Mast_Editor_Window.Notebook,
         Mast_Editor_Window.Vbox3_Notebook);
      Set_Tab_Label_Packing
        (Mast_Editor_Window.Notebook,
         Mast_Editor_Window.Vbox3_Notebook,
         False,
         True,
         Pack_Start);
      Gtk_New
        (Mast_Editor_Window.Label3,
         -("Shared" & ASCII.LF & "Resources"));
      Set_Alignment (Mast_Editor_Window.Label3, 0.5, 0.5);
      Set_Padding (Mast_Editor_Window.Label3, 0, 0);
      Set_Justify (Mast_Editor_Window.Label3, Justify_Center);
      Set_Line_Wrap (Mast_Editor_Window.Label3, False);
      Set_Selectable (Mast_Editor_Window.Label3, False);
      Set_Use_Markup (Mast_Editor_Window.Label3, False);
      Set_Use_Underline (Mast_Editor_Window.Label3, False);
      Set_Tab (Mast_Editor_Window.Notebook, 2, Mast_Editor_Window.Label3);

      Gtk_New_Vbox (Mast_Editor_Window.Vbox4_Notebook, False, 0);

      Gtk_New (Mast_Editor_Window.Operations_Frame);
      Set_Label_Align (Mast_Editor_Window.Operations_Frame, 0.0, 0.5);
      Set_Shadow_Type (Mast_Editor_Window.Operations_Frame, Shadow_Etched_In);

      Pack_Start
        (Mast_Editor_Window.Vbox4_Notebook,
         Mast_Editor_Window.Operations_Frame,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Append_Page
        (Mast_Editor_Window.Notebook,
         Mast_Editor_Window.Vbox4_Notebook);
      Set_Tab_Label_Packing
        (Mast_Editor_Window.Notebook,
         Mast_Editor_Window.Vbox4_Notebook,
         False,
         True,
         Pack_Start);
      Gtk_New (Mast_Editor_Window.Label4, -("Operations"));
      Set_Alignment (Mast_Editor_Window.Label4, 0.5, 0.5);
      Set_Padding (Mast_Editor_Window.Label4, 0, 0);
      Set_Justify (Mast_Editor_Window.Label4, Justify_Center);
      Set_Line_Wrap (Mast_Editor_Window.Label4, False);
      Set_Selectable (Mast_Editor_Window.Label4, False);
      Set_Use_Markup (Mast_Editor_Window.Label4, False);
      Set_Use_Underline (Mast_Editor_Window.Label4, False);
      Set_Tab (Mast_Editor_Window.Notebook, 3, Mast_Editor_Window.Label4);

      Gtk_New_Vbox (Mast_Editor_Window.Vbox5_Notebook, False, 0);

      Gtk_New (Mast_Editor_Window.Transactions_Frame);
      Set_Label_Align (Mast_Editor_Window.Transactions_Frame, 0.0, 0.5);
      Set_Shadow_Type
        (Mast_Editor_Window.Transactions_Frame,
         Shadow_Etched_In);

      Pack_Start
        (Mast_Editor_Window.Vbox5_Notebook,
         Mast_Editor_Window.Transactions_Frame,
         Expand  => True,
         Fill    => True,
         Padding => 0);

      Append_Page
        (Mast_Editor_Window.Notebook,
         Mast_Editor_Window.Vbox5_Notebook);
      Set_Tab_Label_Packing
        (Mast_Editor_Window.Notebook,
         Mast_Editor_Window.Vbox5_Notebook,
         False,
         True,
         Pack_Start);
      Gtk_New (Mast_Editor_Window.Label5, -("Transactions"));
      Set_Alignment (Mast_Editor_Window.Label5, 0.5, 0.5);
      Set_Padding (Mast_Editor_Window.Label5, 0, 0);
      Set_Justify (Mast_Editor_Window.Label5, Justify_Center);
      Set_Line_Wrap (Mast_Editor_Window.Label5, False);
      Set_Selectable (Mast_Editor_Window.Label5, False);
      Set_Use_Markup (Mast_Editor_Window.Label5, False);
      Set_Use_Underline (Mast_Editor_Window.Label5, False);
      Set_Tab (Mast_Editor_Window.Notebook, 4, Mast_Editor_Window.Label5);

      Pack_Start
        (Mast_Editor_Window.Vbox_Main_Window,
         Mast_Editor_Window.Notebook,
         Expand  => True,
         Fill    => True,
         Padding => 0);
      Add (Mast_Editor_Window, Mast_Editor_Window.Vbox_Main_Window);
      --     Return_Callback.Connect
      --       (Mast_Editor_Window, "delete_event",
      --On_Main_Window_Delete_Event'Access, False);

      --------------------------------
      Mast_Editor.Processing_Resources.Run
        (Mast_Editor_Window.Proc_Res_Frame);
      Mast_Editor.Scheduling_Servers.Run
        (Mast_Editor_Window.Sched_Server_Frame);
      Mast_Editor.Shared_Resources.Run (Mast_Editor_Window.Shared_Res_Frame);
      Mast_Editor.Operations.Run (Mast_Editor_Window.Operations_Frame);
      Mast_Editor.Transactions.Run (Mast_Editor_Window.Transactions_Frame);
      --------------------------------
   end Initialize;

end Mast_Editor_Window_Pkg;
