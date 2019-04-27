with Glib; use Glib;
with Gtk; use Gtk;
with Gdk.Types;       use Gdk.Types;
with Gtk.Widget;      use Gtk.Widget;
with Gtk.Enums;       use Gtk.Enums;
with Gtk.Pixmap;     use Gtk.Pixmap;
with Gtkada.Handlers; use Gtkada.Handlers;
with Callbacks_Gmastresults; use Callbacks_Gmastresults;
with Gmastresults_Intl; use Gmastresults_Intl;
with Gmast_Results_Pkg.Callbacks; use Gmast_Results_Pkg.Callbacks;
with Gmastresults_Pixmaps;

package body Gmast_Results_Pkg is

procedure Gtk_New (Gmast_Results : out Gmast_Results_Access) is
begin
   Gmast_Results := new Gmast_Results_Record;
   Gmast_Results_Pkg.Initialize (Gmast_Results);
end Gtk_New;

procedure Initialize (Gmast_Results : access Gmast_Results_Record'Class) is
   pragma Suppress (All_Checks);
begin
   Gtk.Window.Initialize (Gmast_Results, Window_Toplevel);
   Set_Title (Gmast_Results, -"GMAST Results");
   Set_Policy (Gmast_Results, False, True, False);
   Set_Position (Gmast_Results, Win_Pos_None);
   Set_Modal (Gmast_Results, False);
   Return_Callback.Connect
     (Gmast_Results, "delete_event", On_Gmast_Results_Delete_Event'Access, False);

   Gtk_New_Vbox (Gmast_Results.Vbox1, False, 0);
   Add (Gmast_Results, Gmast_Results.Vbox1);

   Gtk_New_Hbox (Gmast_Results.Hbox1, False, 0);
   Pack_Start
     (Gmast_Results.Vbox1,
      Gmast_Results.Hbox1,
      Expand  => True,
      Fill    => True,
      Padding => 0);

   Gtk_New
     (Gmast_Results.Alignment1, 0.0, 0.0, 1.0,
      1.0);
   Pack_Start
     (Gmast_Results.Hbox1,
      Gmast_Results.Alignment1,
      Expand  => False,
      Fill    => False,
      Padding => 0);

   Gtk_New_Vbox (Gmast_Results.Vbox2, False, 0);
   Add (Gmast_Results.Alignment1, Gmast_Results.Vbox2);

   Gtk_New (Gmast_Results.Handlebox1);
   Set_Shadow_Type (Gmast_Results.Handlebox1, Shadow_Out);
   Set_Handle_Position (Gmast_Results.Handlebox1, Pos_Left);
   Set_Snap_Edge (Gmast_Results.Handlebox1, Pos_Top);
   Pack_Start
     (Gmast_Results.Vbox2,
      Gmast_Results.Handlebox1,
      Expand  => True,
      Fill    => True,
      Padding => 0);

   Gtk_New (Gmast_Results.Mainmenubar);
   Add (Gmast_Results.Handlebox1, Gmast_Results.Mainmenubar);

   Gtk_New_With_Mnemonic (Gmast_Results.Systemfile, -("System-file"));
   Append (Gmast_Results.Mainmenubar, Gmast_Results.Systemfile);

   Gtk_New (Gmast_Results.Systemfile_Menu);
   Set_Submenu (Gmast_Results.Systemfile, Gmast_Results.Systemfile_Menu);

   Gtk_New (Gmast_Results.System_Open, -"Open...");
   Gtk_New (Gmast_Results.Image7 , "gtk-open", Gtk_Icon_Size'Val (1));
   Set_Alignment (Gmast_Results.Image7, 0.5, 0.5);
   Set_Padding (Gmast_Results.Image7, 0, 0);
   Set_Image (Gmast_Results.System_Open, Gmast_Results.Image7);
   Image_Menu_Item_Callback.Connect
     (Gmast_Results.System_Open, "activate",
      Image_Menu_Item_Callback.To_Marshaller (On_System_Open_Activate'Access), False);
   Append (Gmast_Results.Systemfile_Menu, Gmast_Results.System_Open);

   Gtk_New (Gmast_Results.System_Save_As, -"Save As...");
   Gtk_New (Gmast_Results.Image8 , "gtk-save-as", Gtk_Icon_Size'Val (1));
   Set_Alignment (Gmast_Results.Image8, 0.5, 0.5);
   Set_Padding (Gmast_Results.Image8, 0, 0);
   Set_Image (Gmast_Results.System_Save_As, Gmast_Results.Image8);
   Image_Menu_Item_Callback.Connect
     (Gmast_Results.System_Save_As, "activate",
      Image_Menu_Item_Callback.To_Marshaller (On_System_Save_As_Activate'Access), False);
   Append (Gmast_Results.Systemfile_Menu, Gmast_Results.System_Save_As);


   Gtk_New (Gmast_Results.Exit1, -"Exit");
   Gtk_New (Gmast_Results.Image9 , "gtk-quit", Gtk_Icon_Size'Val (1));
   Set_Alignment (Gmast_Results.Image9, 0.5, 0.5);
   Set_Padding (Gmast_Results.Image9, 0, 0);
   Set_Image (Gmast_Results.Exit1, Gmast_Results.Image9);
   Image_Menu_Item_Callback.Connect
     (Gmast_Results.Exit1, "activate",
      Image_Menu_Item_Callback.To_Marshaller (On_Exit1_Activate'Access), False);
   Append (Gmast_Results.Systemfile_Menu, Gmast_Results.Exit1);


   Gtk_New_With_Mnemonic (Gmast_Results.Resultsfile, -("Results-file"));
   Append (Gmast_Results.Mainmenubar, Gmast_Results.Resultsfile);

   Gtk_New (Gmast_Results.Resultsfile_Menu);
   Set_Submenu (Gmast_Results.Resultsfile, Gmast_Results.Resultsfile_Menu);

   Gtk_New (Gmast_Results.Results_Open, -"Open...");
   Gtk_New (Gmast_Results.Image10 , "gtk-open", Gtk_Icon_Size'Val (1));
   Set_Alignment (Gmast_Results.Image10, 0.5, 0.5);
   Set_Padding (Gmast_Results.Image10, 0, 0);
   Set_Image (Gmast_Results.Results_Open, Gmast_Results.Image10);
   Image_Menu_Item_Callback.Connect
     (Gmast_Results.Results_Open, "activate",
      Image_Menu_Item_Callback.To_Marshaller (On_Results_Open_Activate'Access), False);
   Append (Gmast_Results.Resultsfile_Menu, Gmast_Results.Results_Open);


   Gtk_New (Gmast_Results.Results_Save_As, -"Save As...");
   Gtk_New (Gmast_Results.Image11 , "gtk-save-as", Gtk_Icon_Size'Val (1));
   Set_Alignment (Gmast_Results.Image11, 0.5, 0.5);
   Set_Padding (Gmast_Results.Image11, 0, 0);
   Set_Image (Gmast_Results.Results_Save_As, Gmast_Results.Image11);
   Image_Menu_Item_Callback.Connect
     (Gmast_Results.Results_Save_As, "activate",
      Image_Menu_Item_Callback.To_Marshaller (On_Results_Save_As_Activate'Access), False);
   Append (Gmast_Results.Resultsfile_Menu, Gmast_Results.Results_Save_As);


   Gtk_New_With_Mnemonic (Gmast_Results.Help1, -("Help"));
   Append (Gmast_Results.Mainmenubar, Gmast_Results.Help1);

   Gtk_New (Gmast_Results.Help1_Menu);
   Set_Submenu (Gmast_Results.Help1, Gmast_Results.Help1_Menu);

   Gtk_New (Gmast_Results.Contents, -"Contents...");
   Gtk_New (Gmast_Results.Image12 , "gtk-help", Gtk_Icon_Size'Val (1));
   Set_Alignment (Gmast_Results.Image12, 0.5, 0.5);
   Set_Padding (Gmast_Results.Image12, 0, 0);
   Set_Image (Gmast_Results.Contents, Gmast_Results.Image12);
   Image_Menu_Item_Callback.Connect
     (Gmast_Results.Contents, "activate",
      Image_Menu_Item_Callback.To_Marshaller (On_Contents_Activate'Access), False);
   Append (Gmast_Results.Help1_Menu, Gmast_Results.Contents);


   Gtk_New (Gmast_Results.About, -"About...");
   Gtk_New (Gmast_Results.Image13 , "gnome-stock-about", Gtk_Icon_Size'Val (1));
   Set_Alignment (Gmast_Results.Image13, 0.5, 0.5);
   Set_Padding (Gmast_Results.Image13, 0, 0);
   Set_Image (Gmast_Results.About, Gmast_Results.Image13);
   Image_Menu_Item_Callback.Connect
     (Gmast_Results.About, "activate",
      Image_Menu_Item_Callback.To_Marshaller (On_About_Activate'Access), False);
   Append (Gmast_Results.Help1_Menu, Gmast_Results.About);


   Gtk_New (Gmast_Results.Frame3);
   Set_Border_Width (Gmast_Results.Frame3, 4);
   Set_Label_Align (Gmast_Results.Frame3, 0.0, 0.5);
   Set_Shadow_Type (Gmast_Results.Frame3, Shadow_Etched_In);
   Pack_Start
     (Gmast_Results.Vbox2,
      Gmast_Results.Frame3,
      Expand  => False,
      Fill    => False,
      Padding => 0);


   Gtk_New (Gmast_Results.Label30, -("Modeling and Analysis Suite for Real-Time Applications"));
   Set_Alignment (Gmast_Results.Label30, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label30, 0, 0);
   Set_Justify (Gmast_Results.Label30, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label30, False);
   Set_Selectable (Gmast_Results.Label30, False);
   Set_Use_Markup (Gmast_Results.Label30, False);
   Set_Use_Underline (Gmast_Results.Label30, False);
   Add (Gmast_Results.Frame3, Gmast_Results.Label30);

   Gtk_New (Gmast_Results.Frame4);
   Set_Border_Width (Gmast_Results.Frame4, 4);
   Set_Label_Align (Gmast_Results.Frame4, 0.0, 0.5);
   Set_Shadow_Type (Gmast_Results.Frame4, Shadow_Etched_In);
   Pack_Start
     (Gmast_Results.Vbox2,
      Gmast_Results.Frame4,
      Expand  => True,
      Fill    => True,
      Padding => 0);

   Gtk_New_Hbox (Gmast_Results.Hbox2, False, 0);
   Add (Gmast_Results.Frame4, Gmast_Results.Hbox2);

   Gtk_New (Gmast_Results.Label31, -("Current System"));
   Set_Alignment (Gmast_Results.Label31, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label31, 0, 0);
   Set_Justify (Gmast_Results.Label31, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label31, False);
   Set_Selectable (Gmast_Results.Label31, False);
   Set_Use_Markup (Gmast_Results.Label31, False);
   Set_Use_Underline (Gmast_Results.Label31, False);
   Pack_Start
     (Gmast_Results.Hbox2,
      Gmast_Results.Label31,
      Expand  => False,
      Fill    => False,
      Padding => 0);


   Gtk_New (Gmast_Results.Entry_Current_System);
   Set_Editable (Gmast_Results.Entry_Current_System, False);
   Set_Max_Length (Gmast_Results.Entry_Current_System, 0);
   Set_Text (Gmast_Results.Entry_Current_System, -(""));
   Set_Visibility (Gmast_Results.Entry_Current_System, True);
   Set_Invisible_Char (Gmast_Results.Entry_Current_System, UTF8_Get_Char ("*"));
   Pack_Start
     (Gmast_Results.Hbox2,
      Gmast_Results.Entry_Current_System,
      Expand  => True,
      Fill    => True,
      Padding => 0);

   Gtk_New
     (Gmast_Results.Alignment2, 1.0, 0.5, 0.0,
      0.0);
   Pack_Start
     (Gmast_Results.Hbox1,
      Gmast_Results.Alignment2,
      Expand  => True,
      Fill    => True,
      Padding => 0);

   Gtk_New (Gmast_Results.Frame1);
   Set_Border_Width (Gmast_Results.Frame1, 2);
   Set_Label_Align (Gmast_Results.Frame1, 0.0, 0.5);
   Set_Shadow_Type (Gmast_Results.Frame1, Shadow_Etched_In);
   Add (Gmast_Results.Alignment2, Gmast_Results.Frame1);

   Gmast_Results.Pixmap_Logo := Create_Pixmap
     (Gmastresults_Pixmaps.Mast_Logo_Str, Gmast_Results);
   Set_Alignment (Gmast_Results.Pixmap_Logo, 1.0, 0.0);
   Set_Padding (Gmast_Results.Pixmap_Logo, 0, 0);
   Add (Gmast_Results.Frame1, Gmast_Results.Pixmap_Logo);

   Gmast_Results.Pixmap1 := Create_Pixmap
     (Gmastresults_Pixmaps.mast_name_str, Gmast_Results);
   Set_Alignment (Gmast_Results.Pixmap1, 0.5, 0.5);
   Set_Padding (Gmast_Results.Pixmap1, 14, 0);
   Pack_Start
     (Gmast_Results.Hbox1,
      Gmast_Results.Pixmap1,
      Expand  => False,
      Fill    => True,
      Padding => 0);


   Gtk_New (Gmast_Results.Notebook1);
   Set_Scrollable (Gmast_Results.Notebook1, False);
   Set_Show_Border (Gmast_Results.Notebook1, True);
   Set_Show_Tabs (Gmast_Results.Notebook1, True);
   Set_Tab_Hborder (Gmast_Results.Notebook1, 2);
   Set_Tab_Vborder (Gmast_Results.Notebook1, 2);
   Set_Tab_Pos (Gmast_Results.Notebook1, Pos_Top);
   Set_USize (Gmast_Results.Notebook1, 640, 400);
   Pack_Start
     (Gmast_Results.Vbox1,
      Gmast_Results.Notebook1,
      Expand  => True,
      Fill    => True,
      Padding => 0);

   Gtk_New (Gmast_Results.Frame2);
   Set_Border_Width (Gmast_Results.Frame2, 10);
   Set_Label_Align (Gmast_Results.Frame2, 0.0, 0.5);
   Set_Shadow_Type (Gmast_Results.Frame2, Shadow_Etched_In);
   Append_Page (Gmast_Results.Notebook1, Gmast_Results.Frame2);
   Set_Tab_Label_Packing (Gmast_Results.Notebook1, Gmast_Results.Frame2, False, True, Pack_Start);

   Gtk_New
     (Gmast_Results.Alignment3, 0.5, 0.5, 0.8,
      0.8);
   Add (Gmast_Results.Frame2, Gmast_Results.Alignment3);

   Gtk_New (Gmast_Results.Table1, 6, 2, False);
   Set_Border_Width (Gmast_Results.Table1, 2);
   Set_Row_Spacings (Gmast_Results.Table1, 0);
   Set_Col_Spacings (Gmast_Results.Table1, 0);
   Add (Gmast_Results.Alignment3, Gmast_Results.Table1);

   Gtk_New (Gmast_Results.Label8, -("Model Name"));
   Set_Alignment (Gmast_Results.Label8, 1.0, 0.5);
   Set_Padding (Gmast_Results.Label8, 2, 0);
   Set_Justify (Gmast_Results.Label8, Justify_Right);
   Set_Line_Wrap (Gmast_Results.Label8, False);
   Set_Selectable (Gmast_Results.Label8, False);
   Set_Use_Markup (Gmast_Results.Label8, False);
   Set_Use_Underline (Gmast_Results.Label8, False);
   Attach
     (Gmast_Results.Table1,
       Gmast_Results.Label8,      Left_Attach  => 0,
      Right_Attach  => 1,
      Top_Attach  => 0,
      Bottom_Attach  => 1,
      Xoptions  => Fill,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Gmast_Results.Label9, -("Model Date"));
   Set_Alignment (Gmast_Results.Label9, 1.0, 0.5);
   Set_Padding (Gmast_Results.Label9, 2, 0);
   Set_Justify (Gmast_Results.Label9, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label9, False);
   Set_Selectable (Gmast_Results.Label9, False);
   Set_Use_Markup (Gmast_Results.Label9, False);
   Set_Use_Underline (Gmast_Results.Label9, False);
   Attach
     (Gmast_Results.Table1,
       Gmast_Results.Label9,      Left_Attach  => 0,
      Right_Attach  => 1,
      Top_Attach  => 1,
      Bottom_Attach  => 2,
      Xoptions  => Fill,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Gmast_Results.Label10, -("Generation Tool"));
   Set_Alignment (Gmast_Results.Label10, 1.0, 0.5);
   Set_Padding (Gmast_Results.Label10, 2, 0);
   Set_Justify (Gmast_Results.Label10, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label10, False);
   Set_Selectable (Gmast_Results.Label10, False);
   Set_Use_Markup (Gmast_Results.Label10, False);
   Set_Use_Underline (Gmast_Results.Label10, False);
   Attach
     (Gmast_Results.Table1,
       Gmast_Results.Label10,      Left_Attach  => 0,
      Right_Attach  => 1,
      Top_Attach  => 2,
      Bottom_Attach  => 3,
      Xoptions  => Fill,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Gmast_Results.Label11, -("Generation Profile"));
   Set_Alignment (Gmast_Results.Label11, 1.0, 0.5);
   Set_Padding (Gmast_Results.Label11, 2, 0);
   Set_Justify (Gmast_Results.Label11, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label11, False);
   Set_Selectable (Gmast_Results.Label11, False);
   Set_Use_Markup (Gmast_Results.Label11, False);
   Set_Use_Underline (Gmast_Results.Label11, False);
   Attach
     (Gmast_Results.Table1,
       Gmast_Results.Label11,      Left_Attach  => 0,
      Right_Attach  => 1,
      Top_Attach  => 3,
      Bottom_Attach  => 4,
      Xoptions  => Fill,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Gmast_Results.Label12, -("Generation Date"));
   Set_Alignment (Gmast_Results.Label12, 1.0, 0.5);
   Set_Padding (Gmast_Results.Label12, 2, 0);
   Set_Justify (Gmast_Results.Label12, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label12, False);
   Set_Selectable (Gmast_Results.Label12, False);
   Set_Use_Markup (Gmast_Results.Label12, False);
   Set_Use_Underline (Gmast_Results.Label12, False);
   Attach
     (Gmast_Results.Table1,
       Gmast_Results.Label12,      Left_Attach  => 0,
      Right_Attach  => 1,
      Top_Attach  => 4,
      Bottom_Attach  => 5,
      Xoptions  => Fill,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Gmast_Results.Label13, -("Slack"));
   Set_Alignment (Gmast_Results.Label13, 1.0, 0.5);
   Set_Padding (Gmast_Results.Label13, 2, 0);
   Set_Justify (Gmast_Results.Label13, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label13, False);
   Set_Selectable (Gmast_Results.Label13, False);
   Set_Use_Markup (Gmast_Results.Label13, False);
   Set_Use_Underline (Gmast_Results.Label13, False);
   Attach
     (Gmast_Results.Table1,
       Gmast_Results.Label13,      Left_Attach  => 0,
      Right_Attach  => 1,
      Top_Attach  => 5,
      Bottom_Attach  => 6,
      Xoptions  => Fill,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Gmast_Results.Entry_Model_Name);
   Set_Editable (Gmast_Results.Entry_Model_Name, False);
   Set_Max_Length (Gmast_Results.Entry_Model_Name, 0);
   Set_Text (Gmast_Results.Entry_Model_Name, -(""));
   Set_Visibility (Gmast_Results.Entry_Model_Name, True);
   Set_Invisible_Char (Gmast_Results.Entry_Model_Name, UTF8_Get_Char ("*"));
   Attach
     (Gmast_Results.Table1,
       Gmast_Results.Entry_Model_Name,      Left_Attach  => 1,
      Right_Attach  => 2,
      Top_Attach  => 0,
      Bottom_Attach  => 1,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Gmast_Results.Entry_Model_Date);
   Set_Editable (Gmast_Results.Entry_Model_Date, False);
   Set_Max_Length (Gmast_Results.Entry_Model_Date, 0);
   Set_Text (Gmast_Results.Entry_Model_Date, -(""));
   Set_Visibility (Gmast_Results.Entry_Model_Date, True);
   Set_Invisible_Char (Gmast_Results.Entry_Model_Date, UTF8_Get_Char ("*"));
   Attach
     (Gmast_Results.Table1,
       Gmast_Results.Entry_Model_Date,      Left_Attach  => 1,
      Right_Attach  => 2,
      Top_Attach  => 1,
      Bottom_Attach  => 2,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Gmast_Results.Entry_Generation_Tool);
   Set_Editable (Gmast_Results.Entry_Generation_Tool, False);
   Set_Max_Length (Gmast_Results.Entry_Generation_Tool, 0);
   Set_Text (Gmast_Results.Entry_Generation_Tool, -(""));
   Set_Visibility (Gmast_Results.Entry_Generation_Tool, True);
   Set_Invisible_Char (Gmast_Results.Entry_Generation_Tool, UTF8_Get_Char ("*"));
   Attach
     (Gmast_Results.Table1,
       Gmast_Results.Entry_Generation_Tool,      Left_Attach  => 1,
      Right_Attach  => 2,
      Top_Attach  => 2,
      Bottom_Attach  => 3,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Gmast_Results.Entry_Generation_Profile);
   Set_Editable (Gmast_Results.Entry_Generation_Profile, False);
   Set_Max_Length (Gmast_Results.Entry_Generation_Profile, 0);
   Set_Text (Gmast_Results.Entry_Generation_Profile, -(""));
   Set_Visibility (Gmast_Results.Entry_Generation_Profile, True);
   Set_Invisible_Char (Gmast_Results.Entry_Generation_Profile, UTF8_Get_Char ("*"));
   Attach
     (Gmast_Results.Table1,
       Gmast_Results.Entry_Generation_Profile,      Left_Attach  => 1,
      Right_Attach  => 2,
      Top_Attach  => 3,
      Bottom_Attach  => 4,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Gmast_Results.Entry_Generation_Date);
   Set_Editable (Gmast_Results.Entry_Generation_Date, False);
   Set_Max_Length (Gmast_Results.Entry_Generation_Date, 0);
   Set_Text (Gmast_Results.Entry_Generation_Date, -(""));
   Set_Visibility (Gmast_Results.Entry_Generation_Date, True);
   Set_Invisible_Char (Gmast_Results.Entry_Generation_Date, UTF8_Get_Char ("*"));
   Attach
     (Gmast_Results.Table1,
       Gmast_Results.Entry_Generation_Date,      Left_Attach  => 1,
      Right_Attach  => 2,
      Top_Attach  => 4,
      Bottom_Attach  => 5,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Gmast_Results.Text_System_Slack);
   Set_Editable (Gmast_Results.Text_System_Slack, True);
   Set_Max_Length (Gmast_Results.Text_System_Slack, 0);
   Set_Text (Gmast_Results.Text_System_Slack, -(""));
   Set_Visibility (Gmast_Results.Text_System_Slack, True);
   Set_Invisible_Char (Gmast_Results.Text_System_Slack, UTF8_Get_Char ("*"));
   Attach
     (Gmast_Results.Table1,
       Gmast_Results.Text_System_Slack,      Left_Attach  => 1,
      Right_Attach  => 2,
      Top_Attach  => 5,
      Bottom_Attach  => 6,
      Xpadding  => 0,
      Ypadding  => 0);

   Gtk_New (Gmast_Results.Label1, -("System"));
   Set_Alignment (Gmast_Results.Label1, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label1, 0, 0);
   Set_Justify (Gmast_Results.Label1, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label1, False);
   Set_Selectable (Gmast_Results.Label1, False);
   Set_Use_Markup (Gmast_Results.Label1, False);
   Set_Use_Underline (Gmast_Results.Label1, False);
   Set_Tab (Gmast_Results.Notebook1, 0, Gmast_Results.Label1);

   Gtk_New (Gmast_Results.Scrolledwindow1);
   Set_Policy (Gmast_Results.Scrolledwindow1, Policy_Always, Policy_Always);
   Set_Shadow_Type (Gmast_Results.Scrolledwindow1, Shadow_In);
   Append_Page (Gmast_Results.Notebook1, Gmast_Results.Scrolledwindow1);
   Set_Tab_Label_Packing (Gmast_Results.Notebook1, Gmast_Results.Scrolledwindow1, False, True, Pack_Start);

   Gtk_New (Gmast_Results.Clist_Processing_Resources, 9);
   Set_Selection_Mode (Gmast_Results.Clist_Processing_Resources, Selection_Single);
   Set_Shadow_Type (Gmast_Results.Clist_Processing_Resources, Shadow_In);
   Set_Show_Titles (Gmast_Results.Clist_Processing_Resources, True);
   Set_Column_Width (Gmast_Results.Clist_Processing_Resources, 0, 75);
   Set_Column_Width (Gmast_Results.Clist_Processing_Resources, 1, 75);
   Set_Column_Width (Gmast_Results.Clist_Processing_Resources, 2, 75);
   Set_Column_Width (Gmast_Results.Clist_Processing_Resources, 3, 75);
   Set_Column_Width (Gmast_Results.Clist_Processing_Resources, 4, 75);
   Set_Column_Width (Gmast_Results.Clist_Processing_Resources, 5, 75);
   Set_Column_Width (Gmast_Results.Clist_Processing_Resources, 6, 75);
   Set_Column_Width (Gmast_Results.Clist_Processing_Resources, 7, 75);
   Set_Column_Width (Gmast_Results.Clist_Processing_Resources, 8, 75);
   Add (Gmast_Results.Scrolledwindow1, Gmast_Results.Clist_Processing_Resources);

   Gtk_New (Gmast_Results.Label17, -("Name"));
   Set_Alignment (Gmast_Results.Label17, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label17, 0, 0);
   Set_Justify (Gmast_Results.Label17, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label17, False);
   Set_Selectable (Gmast_Results.Label17, False);
   Set_Use_Markup (Gmast_Results.Label17, False);
   Set_Use_Underline (Gmast_Results.Label17, False);
   Set_Column_Widget (Gmast_Results.Clist_Processing_Resources, 0, Gmast_Results.Label17);

   Gtk_New (Gmast_Results.Label18, -("Type"));
   Set_Alignment (Gmast_Results.Label18, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label18, 0, 0);
   Set_Justify (Gmast_Results.Label18, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label18, False);
   Set_Selectable (Gmast_Results.Label18, False);
   Set_Use_Markup (Gmast_Results.Label18, False);
   Set_Use_Underline (Gmast_Results.Label18, False);
   Set_Column_Widget (Gmast_Results.Clist_Processing_Resources, 1, Gmast_Results.Label18);

   Gtk_New (Gmast_Results.Label19, -("Slack"));
   Set_Alignment (Gmast_Results.Label19, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label19, 0, 0);
   Set_Justify (Gmast_Results.Label19, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label19, False);
   Set_Selectable (Gmast_Results.Label19, False);
   Set_Use_Markup (Gmast_Results.Label19, False);
   Set_Use_Underline (Gmast_Results.Label19, False);
   Set_Column_Widget (Gmast_Results.Clist_Processing_Resources, 2, Gmast_Results.Label19);

   Gtk_New (Gmast_Results.Label20, -("Total" & ASCII.LF & "Utilization"));
   Set_Alignment (Gmast_Results.Label20, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label20, 0, 0);
   Set_Justify (Gmast_Results.Label20, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label20, False);
   Set_Selectable (Gmast_Results.Label20, False);
   Set_Use_Markup (Gmast_Results.Label20, False);
   Set_Use_Underline (Gmast_Results.Label20, False);
   Set_Column_Widget (Gmast_Results.Clist_Processing_Resources, 3, Gmast_Results.Label20);

   Gtk_New (Gmast_Results.Label21, -("Application" & ASCII.LF & "Utilization"));
   Set_Alignment (Gmast_Results.Label21, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label21, 0, 0);
   Set_Justify (Gmast_Results.Label21, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label21, False);
   Set_Selectable (Gmast_Results.Label21, False);
   Set_Use_Markup (Gmast_Results.Label21, False);
   Set_Use_Underline (Gmast_Results.Label21, False);
   Set_Column_Widget (Gmast_Results.Clist_Processing_Resources, 4, Gmast_Results.Label21);

   Gtk_New (Gmast_Results.Label22, -("Switch / Sincronize*" & ASCII.LF & "Utilization"));
   Set_Alignment (Gmast_Results.Label22, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label22, 0, 0);
   Set_Justify (Gmast_Results.Label22, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label22, False);
   Set_Selectable (Gmast_Results.Label22, False);
   Set_Use_Markup (Gmast_Results.Label22, False);
   Set_Use_Underline (Gmast_Results.Label22, False);
   Set_Column_Widget (Gmast_Results.Clist_Processing_Resources, 5, Gmast_Results.Label22);

   Gtk_New (Gmast_Results.Label23, -("Timer" & ASCII.LF & "Utilization"));
   Set_Alignment (Gmast_Results.Label23, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label23, 0, 0);
   Set_Justify (Gmast_Results.Label23, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label23, False);
   Set_Selectable (Gmast_Results.Label23, False);
   Set_Use_Markup (Gmast_Results.Label23, False);
   Set_Use_Underline (Gmast_Results.Label23, False);
   Set_Column_Widget (Gmast_Results.Clist_Processing_Resources, 6, Gmast_Results.Label23);

   Gtk_New (Gmast_Results.Label24, -("Driver" & ASCII.LF & "Utilization"));
   Set_Alignment (Gmast_Results.Label24, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label24, 0, 0);
   Set_Justify (Gmast_Results.Label24, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label24, False);
   Set_Selectable (Gmast_Results.Label24, False);
   Set_Use_Markup (Gmast_Results.Label24, False);
   Set_Use_Underline (Gmast_Results.Label24, False);
   Set_Column_Widget (Gmast_Results.Clist_Processing_Resources, 7, Gmast_Results.Label24);

   Gtk_New (Gmast_Results.Label25, -("Ready Queue" & ASCII.LF & "Size"));
   Set_Alignment (Gmast_Results.Label25, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label25, 0, 0);
   Set_Justify (Gmast_Results.Label25, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label25, False);
   Set_Selectable (Gmast_Results.Label25, False);
   Set_Use_Markup (Gmast_Results.Label25, False);
   Set_Use_Underline (Gmast_Results.Label25, False);
   Set_Column_Widget (Gmast_Results.Clist_Processing_Resources, 8, Gmast_Results.Label25);

   Gtk_New (Gmast_Results.Label2, -("Processing Resources"));
   Set_Alignment (Gmast_Results.Label2, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label2, 0, 0);
   Set_Justify (Gmast_Results.Label2, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label2, False);
   Set_Selectable (Gmast_Results.Label2, False);
   Set_Use_Markup (Gmast_Results.Label2, False);
   Set_Use_Underline (Gmast_Results.Label2, False);
   Set_Tab (Gmast_Results.Notebook1, 1, Gmast_Results.Label2);

   Gtk_New (Gmast_Results.Scrolledwindow2);
   Set_Policy (Gmast_Results.Scrolledwindow2, Policy_Always, Policy_Always);
   Set_Shadow_Type (Gmast_Results.Scrolledwindow2, Shadow_In);
   Append_Page (Gmast_Results.Notebook1, Gmast_Results.Scrolledwindow2);
   Set_Tab_Label_Packing (Gmast_Results.Notebook1, Gmast_Results.Scrolledwindow2, False, True, Pack_Start);

   Gtk_New (Gmast_Results.Clist_Transactions, 4);
   Set_Selection_Mode (Gmast_Results.Clist_Transactions, Selection_Single);
   Set_Shadow_Type (Gmast_Results.Clist_Transactions, Shadow_In);
   Set_Show_Titles (Gmast_Results.Clist_Transactions, True);
   Set_Column_Width (Gmast_Results.Clist_Transactions, 0, 80);
   Set_Column_Width (Gmast_Results.Clist_Transactions, 1, 80);
   Set_Column_Width (Gmast_Results.Clist_Transactions, 2, 80);
   Set_Column_Width (Gmast_Results.Clist_Transactions, 3, 80);
   C_List_Callback.Connect
     (Gmast_Results.Clist_Transactions, "select_row", On_Clist_Transactions_Select_Row'Access);
   C_List_Callback.Connect
     (Gmast_Results.Clist_Transactions, "click_column", On_Clist_Transactions_Click_Column'Access);
   Add (Gmast_Results.Scrolledwindow2, Gmast_Results.Clist_Transactions);

   Gtk_New (Gmast_Results.Label26, -("Name"));
   Set_Alignment (Gmast_Results.Label26, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label26, 0, 0);
   Set_Justify (Gmast_Results.Label26, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label26, False);
   Set_Selectable (Gmast_Results.Label26, False);
   Set_Use_Markup (Gmast_Results.Label26, False);
   Set_Use_Underline (Gmast_Results.Label26, False);
   Set_Column_Widget (Gmast_Results.Clist_Transactions, 0, Gmast_Results.Label26);

   Gtk_New (Gmast_Results.Label27, -("Type"));
   Set_Alignment (Gmast_Results.Label27, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label27, 0, 0);
   Set_Justify (Gmast_Results.Label27, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label27, False);
   Set_Selectable (Gmast_Results.Label27, False);
   Set_Use_Markup (Gmast_Results.Label27, False);
   Set_Use_Underline (Gmast_Results.Label27, False);
   Set_Column_Widget (Gmast_Results.Clist_Transactions, 1, Gmast_Results.Label27);

   Gtk_New (Gmast_Results.Label28, -("Slack"));
   Set_Alignment (Gmast_Results.Label28, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label28, 0, 0);
   Set_Justify (Gmast_Results.Label28, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label28, False);
   Set_Selectable (Gmast_Results.Label28, False);
   Set_Use_Markup (Gmast_Results.Label28, False);
   Set_Use_Underline (Gmast_Results.Label28, False);
   Set_Column_Widget (Gmast_Results.Clist_Transactions, 2, Gmast_Results.Label28);

   Gtk_New (Gmast_Results.Label_Timing_Results, -("Timing Results"));
   Set_Alignment (Gmast_Results.Label_Timing_Results, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label_Timing_Results, 0, 0);
   Set_Justify (Gmast_Results.Label_Timing_Results, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label_Timing_Results, False);
   Set_Selectable (Gmast_Results.Label_Timing_Results, False);
   Set_Use_Markup (Gmast_Results.Label_Timing_Results, False);
   Set_Use_Underline (Gmast_Results.Label_Timing_Results, False);
   Set_Column_Widget (Gmast_Results.Clist_Transactions, 3, Gmast_Results.Label_Timing_Results);

   Gtk_New (Gmast_Results.Label3, -("Transactions"));
   Set_Alignment (Gmast_Results.Label3, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label3, 0, 0);
   Set_Justify (Gmast_Results.Label3, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label3, False);
   Set_Selectable (Gmast_Results.Label3, False);
   Set_Use_Markup (Gmast_Results.Label3, False);
   Set_Use_Underline (Gmast_Results.Label3, False);
   Set_Tab (Gmast_Results.Notebook1, 2, Gmast_Results.Label3);

   Gtk_New (Gmast_Results.Scrolledwindow3);
   Set_Policy (Gmast_Results.Scrolledwindow3, Policy_Always, Policy_Always);
   Set_Shadow_Type (Gmast_Results.Scrolledwindow3, Shadow_In);
   Append_Page (Gmast_Results.Notebook1, Gmast_Results.Scrolledwindow3);
   Set_Tab_Label_Packing (Gmast_Results.Notebook1, Gmast_Results.Scrolledwindow3, False, True, Pack_Start);

   Gtk_New (Gmast_Results.Clist_Shared_Resources, 5);
   Set_Selection_Mode (Gmast_Results.Clist_Shared_Resources, Selection_Single);
   Set_Shadow_Type (Gmast_Results.Clist_Shared_Resources, Shadow_In);
   Set_Show_Titles (Gmast_Results.Clist_Shared_Resources, True);
   Set_Column_Width (Gmast_Results.Clist_Shared_Resources, 0, 80);
   Set_Column_Width (Gmast_Results.Clist_Shared_Resources, 1, 80);
   Set_Column_Width (Gmast_Results.Clist_Shared_Resources, 2, 80);
   Set_Column_Width (Gmast_Results.Clist_Shared_Resources, 3, 100);
   Set_Column_Width (Gmast_Results.Clist_Shared_Resources, 4, 80);
   Add (Gmast_Results.Scrolledwindow3, Gmast_Results.Clist_Shared_Resources);

   Gtk_New (Gmast_Results.Label29, -("Name"));
   Set_Alignment (Gmast_Results.Label29, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label29, 0, 0);
   Set_Justify (Gmast_Results.Label29, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label29, False);
   Set_Selectable (Gmast_Results.Label29, False);
   Set_Use_Markup (Gmast_Results.Label29, False);
   Set_Use_Underline (Gmast_Results.Label29, False);
   Set_Column_Widget (Gmast_Results.Clist_Shared_Resources, 0, Gmast_Results.Label29);

   Gtk_New (Gmast_Results.Label30, -("Type"));
   Set_Alignment (Gmast_Results.Label30, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label30, 0, 0);
   Set_Justify (Gmast_Results.Label30, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label30, False);
   Set_Selectable (Gmast_Results.Label30, False);
   Set_Use_Markup (Gmast_Results.Label30, False);
   Set_Use_Underline (Gmast_Results.Label30, False);
   Set_Column_Widget (Gmast_Results.Clist_Shared_Resources, 1, Gmast_Results.Label30);

   Gtk_New (Gmast_Results.Label35, -("Ceiling"));
   Set_Alignment (Gmast_Results.Label35, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label35, 0, 0);
   Set_Justify (Gmast_Results.Label35, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label35, False);
   Set_Selectable (Gmast_Results.Label35, False);
   Set_Use_Markup (Gmast_Results.Label35, False);
   Set_Use_Underline (Gmast_Results.Label35, False);
   Set_Column_Widget (Gmast_Results.Clist_Shared_Resources, 2, Gmast_Results.Label35);


   Gtk_New (Gmast_Results.Label31, -("Total Utilization"));
   Set_Alignment (Gmast_Results.Label31, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label31, 0, 0);
   Set_Justify (Gmast_Results.Label31, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label31, False);
   Set_Selectable (Gmast_Results.Label31, False);
   Set_Use_Markup (Gmast_Results.Label31, False);
   Set_Use_Underline (Gmast_Results.Label31, False);
   Set_Column_Widget (Gmast_Results.Clist_Shared_Resources, 3, Gmast_Results.Label31);

   Gtk_New (Gmast_Results.Label32, -("Queue Size"));
   Set_Alignment (Gmast_Results.Label32, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label32, 0, 0);
   Set_Justify (Gmast_Results.Label32, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label32, False);
   Set_Selectable (Gmast_Results.Label32, False);
   Set_Use_Markup (Gmast_Results.Label23, False);
   Set_Use_Underline (Gmast_Results.Label32, False);
   Set_Column_Widget (Gmast_Results.Clist_Shared_Resources, 4, Gmast_Results.Label32);

   Gtk_New (Gmast_Results.Label5, -("Shared Resources"));
   Set_Alignment (Gmast_Results.Label5, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label5, 0, 0);
   Set_Justify (Gmast_Results.Label5, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label5, False);
   Set_Selectable (Gmast_Results.Label5, False);
   Set_Use_Markup (Gmast_Results.Label5, False);
   Set_Use_Underline (Gmast_Results.Label5, False);
   Set_Tab (Gmast_Results.Notebook1, 3, Gmast_Results.Label5);

   Gtk_New (Gmast_Results.Label4, -("Operations"));
   Set_Alignment (Gmast_Results.Label4, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label4, 0, 0);
   Set_Justify (Gmast_Results.Label4, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label4, False);
   Set_Selectable (Gmast_Results.Label4, False);
   Set_Use_Markup (Gmast_Results.Label4, False);
   Set_Use_Underline (Gmast_Results.Label4, False);
   Set_Tab (Gmast_Results.Notebook1, 4, Gmast_Results.Label4);


   Gtk_New (Gmast_Results.Label6, -("Scheduling Servers"));
   Set_Alignment (Gmast_Results.Label6, 0.5, 0.5);
   Set_Padding (Gmast_Results.Label6, 0, 0);
   Set_Justify (Gmast_Results.Label6, Justify_Center);
   Set_Line_Wrap (Gmast_Results.Label6, False);
   Set_Selectable (Gmast_Results.Label6, False);
   Set_Use_Markup (Gmast_Results.Label6, False);
   Set_Use_Underline (Gmast_Results.Label6, False);
   Set_Tab (Gmast_Results.Notebook1, 5, Gmast_Results.Label6);

end Initialize;

end Gmast_Results_Pkg;
