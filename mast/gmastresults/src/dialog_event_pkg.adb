with Glib; use Glib;
with Gtk; use Gtk;
with Gdk.Types;       use Gdk.Types;
with Gtk.Widget;      use Gtk.Widget;
with Gtk.Enums;       use Gtk.Enums;
with Gtkada.Handlers; use Gtkada.Handlers;
with Callbacks_Gmastresults; use Callbacks_Gmastresults;
with Gmastresults_Intl; use Gmastresults_Intl;
with Dialog_Event_Pkg.Callbacks; use Dialog_Event_Pkg.Callbacks;

package body Dialog_Event_Pkg is

procedure Gtk_New (Dialog_Event : out Dialog_Event_Access) is
begin
   Dialog_Event := new Dialog_Event_Record;
   Dialog_Event_Pkg.Initialize (Dialog_Event);
end Gtk_New;

procedure Initialize (Dialog_Event : access Dialog_Event_Record'Class) is
   pragma Suppress (All_Checks);
   Combo_Tr_Transaction_Items : String_List.Glist;

begin
   Gtk.Dialog.Initialize (Dialog_Event);
   Set_Title (Dialog_Event, -"Timing Results");
   Set_Policy (Dialog_Event, False, True, False);
   Set_Position (Dialog_Event, Win_Pos_Center);
   Set_Modal (Dialog_Event, True);

   Dialog_Event.Dialog_Vbox1 := Get_Vbox (Dialog_Event);
   Set_Homogeneous (Dialog_Event.Dialog_Vbox1, False);
   Set_Spacing (Dialog_Event.Dialog_Vbox1, 0);

   Dialog_Event.Dialog_Action_Area1 := Get_Action_Area (Dialog_Event);
   Set_Border_Width (Dialog_Event.Dialog_Action_Area1, 10);
   Set_Homogeneous (Dialog_Event.Dialog_Action_Area1, True);
   Set_Spacing (Dialog_Event.Dialog_Action_Area1, 5);

   Gtk_New_From_Stock (Dialog_Event.Button_Close_Tr, "gtk-ok");
   Set_Relief (Dialog_Event.Button_Close_Tr, Relief_Normal);
   Button_Callback.Connect
     (Dialog_Event.Button_Close_Tr, "clicked",
      Button_Callback.To_Marshaller (On_Button_Close_Tr_Clicked'Access));

   Gtk_New_Vbox (Dialog_Event.Vbox4, False, 0);
   Pack_Start (Dialog_Event.Dialog_Vbox1, Dialog_Event.Vbox4, True, True, 0);

   Gtk_New
     (Dialog_Event.Alignment5, 0.5, 0.5, 0.25,
      0.25);
   Set_Border_Width (Dialog_Event.Alignment5, 5);
   Pack_Start (Dialog_Event.Vbox4, Dialog_Event.Alignment5, False, False, 0);

   Gtk_New_Hbox (Dialog_Event.Hbox3, False, 0);
   Add (Dialog_Event.Alignment5, Dialog_Event.Hbox3);

   Gtk_New (Dialog_Event.Label32, -("Transaction"));
   Set_Alignment (Dialog_Event.Label32, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label32, 2, 0);
   Set_Justify (Dialog_Event.Label32, Justify_Right);
   Set_Line_Wrap (Dialog_Event.Label32, False);
   Pack_Start (Dialog_Event.Hbox3, Dialog_Event.Label32, False, False, 0);

   Gtk_New (Dialog_Event.Combo_Tr_Transaction);
   Set_Case_Sensitive (Dialog_Event.Combo_Tr_Transaction, False);
   Set_Use_Arrows (Dialog_Event.Combo_Tr_Transaction, True);
   Set_Use_Arrows_Always (Dialog_Event.Combo_Tr_Transaction, False);
   String_List.Append (Combo_Tr_Transaction_Items, -"");
   Combo.Set_Popdown_Strings (Dialog_Event.Combo_Tr_Transaction, Combo_Tr_Transaction_Items);
   Free_String_List (Combo_Tr_Transaction_Items);
   Pack_Start (Dialog_Event.Hbox3, Dialog_Event.Combo_Tr_Transaction, True, True, 0);

   Dialog_Event.Entry_Tr_Transaction := Get_Entry (Dialog_Event.Combo_Tr_Transaction);
   Set_Editable (Dialog_Event.Entry_Tr_Transaction, False);
   Set_Max_Length (Dialog_Event.Entry_Tr_Transaction, 0);
   Set_Text (Dialog_Event.Entry_Tr_Transaction, -"");
   Set_Visibility (Dialog_Event.Entry_Tr_Transaction, True);
   Entry_Callback.Connect
     (Dialog_Event.Entry_Tr_Transaction, "changed",
      Entry_Callback.To_Marshaller (On_Entry_Tr_Transaction_Changed'Access));

   Gtk_New (Dialog_Event.Button_All, -"View All");
   Set_Border_Width (Dialog_Event.Button_All, 4);
   Pack_Start (Dialog_Event.Hbox3, Dialog_Event.Button_All, False, False, 0);
   Button_Callback.Connect
     (Dialog_Event.Button_All, "clicked",
      Button_Callback.To_Marshaller (On_Button_All_Clicked'Access));

   Gtk_New (Dialog_Event.Frame5);
   Set_Border_Width (Dialog_Event.Frame5, 6);
   Set_Shadow_Type (Dialog_Event.Frame5, Shadow_Etched_In);
   Set_USize (Dialog_Event.Frame5, 640, 300);
   Pack_Start (Dialog_Event.Vbox4, Dialog_Event.Frame5, True, True, 0);

   Gtk_New (Dialog_Event.Notebook2);
   Set_Scrollable (Dialog_Event.Notebook2, False);
   Set_Show_Border (Dialog_Event.Notebook2, True);
   Set_Show_Tabs (Dialog_Event.Notebook2, True);
   Set_Tab_Hborder (Dialog_Event.Notebook2, 2);
   Set_Tab_Vborder (Dialog_Event.Notebook2, 2);
   Set_Tab_Pos (Dialog_Event.Notebook2, Pos_Top);
   Add (Dialog_Event.Frame5, Dialog_Event.Notebook2);

   Gtk_New (Dialog_Event.Scrolledwindow3);
   Set_Policy (Dialog_Event.Scrolledwindow3, Policy_Always, Policy_Always);
   Add (Dialog_Event.Notebook2, Dialog_Event.Scrolledwindow3);

   Gtk_New (Dialog_Event.Clist_Global_Rt, 7);
   Set_Selection_Mode (Dialog_Event.Clist_Global_Rt, Selection_Single);
   Set_Shadow_Type (Dialog_Event.Clist_Global_Rt, Shadow_In);
   Set_Show_Titles (Dialog_Event.Clist_Global_Rt, True);
   Set_Column_Width (Dialog_Event.Clist_Global_Rt, 0, 95);
   Set_Column_Width (Dialog_Event.Clist_Global_Rt, 1, 54);
   Set_Column_Width (Dialog_Event.Clist_Global_Rt, 2, 99);
   Set_Column_Width (Dialog_Event.Clist_Global_Rt, 3, 118);
   Set_Column_Width (Dialog_Event.Clist_Global_Rt, 4, 95);
   Set_Column_Width (Dialog_Event.Clist_Global_Rt, 5, 80);
   Set_Column_Width (Dialog_Event.Clist_Global_Rt, 6, 80);
   Add (Dialog_Event.Scrolledwindow3, Dialog_Event.Clist_Global_Rt);

   Gtk_New (Dialog_Event.Labelt44, -("Transaction"));
   Set_Alignment (Dialog_Event.Labelt44, 0.5, 0.5);
   Set_Padding (Dialog_Event.Labelt44, 0, 0);
   Set_Justify (Dialog_Event.Labelt44, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Labelt44, False);
   Set_Column_Widget (Dialog_Event.Clist_Global_Rt, 0, Dialog_Event.Labelt44);

   Gtk_New (Dialog_Event.Label44, -("Event"));
   Set_Alignment (Dialog_Event.Label44, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label44, 0, 0);
   Set_Justify (Dialog_Event.Label44, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label44, False);
   Set_Column_Widget (Dialog_Event.Clist_Global_Rt, 1, Dialog_Event.Label44);

   Gtk_New (Dialog_Event.Label45, -("Referenced Event"));
   Set_Alignment (Dialog_Event.Label45, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label45, 0, 0);
   Set_Justify (Dialog_Event.Label45, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label45, False);
   Set_Column_Widget (Dialog_Event.Clist_Global_Rt, 2, Dialog_Event.Label45);

   Gtk_New (Dialog_Event.Label46, -("Best Response"));
   Set_Alignment (Dialog_Event.Label46, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label46, 0, 0);
   Set_Justify (Dialog_Event.Label46, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label46, False);
   Set_Column_Widget (Dialog_Event.Clist_Global_Rt, 3, Dialog_Event.Label46);

   Gtk_New (Dialog_Event.Label60, -("Avg Response"));                                 -- NEW
   Set_Alignment (Dialog_Event.Label60, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label60, 0, 0);
   Set_Justify (Dialog_Event.Label60, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label60, False);
   Set_Column_Widget (Dialog_Event.Clist_Global_Rt, 4, Dialog_Event.Label60);


   Gtk_New (Dialog_Event.Label47, -("Worst Response"));
   Set_Alignment (Dialog_Event.Label47, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label47, 0, 0);
   Set_Justify (Dialog_Event.Label47, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label47, False);
   Set_Column_Widget (Dialog_Event.Clist_Global_Rt, 5, Dialog_Event.Label47);

   Gtk_New (Dialog_Event.Label48, -("Hard Deadline"));
   Set_Alignment (Dialog_Event.Label48, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label48, 0, 0);
   Set_Justify (Dialog_Event.Label48, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label48, False);
   Set_Column_Widget (Dialog_Event.Clist_Global_Rt, 6, Dialog_Event.Label48);

   Gtk_New (Dialog_Event.Label40, -("Global Response"&ASCII.LF&"Times"));
   Set_Alignment (Dialog_Event.Label40, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label40, 0, 0);
   Set_Justify (Dialog_Event.Label40, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label40, False);
   Set_Tab (Dialog_Event.Notebook2, 0, Dialog_Event.Label40);


   Gtk_New (Dialog_Event.Scrolledwindow4);
   Set_Policy (Dialog_Event.Scrolledwindow4, Policy_Always, Policy_Always);
   Add (Dialog_Event.Notebook2, Dialog_Event.Scrolledwindow4);

   Gtk_New (Dialog_Event.Clist_Jitters, 5);
   Set_Selection_Mode (Dialog_Event.Clist_Jitters, Selection_Single);
   Set_Shadow_Type (Dialog_Event.Clist_Jitters, Shadow_In);
   Set_Show_Titles (Dialog_Event.Clist_Jitters, True);
   Set_Column_Width (Dialog_Event.Clist_Jitters, 0, 95);
   Set_Column_Width (Dialog_Event.Clist_Jitters, 1, 80);
   Set_Column_Width (Dialog_Event.Clist_Jitters, 2, 129);
   Set_Column_Width (Dialog_Event.Clist_Jitters, 3, 100);
   Set_Column_Width (Dialog_Event.Clist_Jitters, 4, 80);
   Add (Dialog_Event.Scrolledwindow4, Dialog_Event.Clist_Jitters);

   Gtk_New (Dialog_Event.Label49, -("Transaction"));
   Set_Alignment (Dialog_Event.Label49, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label49, 0, 0);
   Set_Justify (Dialog_Event.Label49, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label49, False);
   Set_Column_Widget (Dialog_Event.Clist_Jitters, 0, Dialog_Event.Label49);

   Gtk_New (Dialog_Event.Labelt49, -("Event"));
   Set_Alignment (Dialog_Event.Labelt49, 0.5, 0.5);
   Set_Padding (Dialog_Event.Labelt49, 0, 0);
   Set_Justify (Dialog_Event.Labelt49, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Labelt49, False);
   Set_Column_Widget (Dialog_Event.Clist_Jitters, 1, Dialog_Event.Labelt49);

   Gtk_New (Dialog_Event.Label50, -("Referenced Event"));
   Set_Alignment (Dialog_Event.Label50, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label50, 0, 0);
   Set_Justify (Dialog_Event.Label50, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label50, False);
   Set_Column_Widget (Dialog_Event.Clist_Jitters, 2, Dialog_Event.Label50);

   Gtk_New (Dialog_Event.Label51, -("Output Jitter"));
   Set_Alignment (Dialog_Event.Label51, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label51, 0, 0);
   Set_Justify (Dialog_Event.Label51, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label51, False);
   Set_Column_Widget (Dialog_Event.Clist_Jitters, 3, Dialog_Event.Label51);

   Gtk_New (Dialog_Event.Label52, -("Max Jitter Requirement"));
   Set_Alignment (Dialog_Event.Label52, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label52, 0, 0);
   Set_Justify (Dialog_Event.Label52, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label52, False);
   Set_Column_Widget (Dialog_Event.Clist_Jitters, 4, Dialog_Event.Label52);

   Gtk_New (Dialog_Event.Label43, -("Output Jitters"));
   Set_Alignment (Dialog_Event.Label43, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label43, 0, 0);
   Set_Justify (Dialog_Event.Label43, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label43, False);
   Set_Tab (Dialog_Event.Notebook2, 1, Dialog_Event.Label43);

   Gtk_New (Dialog_Event.Scrolledwindow5);
   Set_Policy (Dialog_Event.Scrolledwindow5, Policy_Always, Policy_Always);
   Add (Dialog_Event.Notebook2, Dialog_Event.Scrolledwindow5);

   Gtk_New (Dialog_Event.Clist_Blocking, 6);
   Set_Selection_Mode (Dialog_Event.Clist_Blocking, Selection_Single);
   Set_Shadow_Type (Dialog_Event.Clist_Blocking, Shadow_In);
   Set_Show_Titles (Dialog_Event.Clist_Blocking, True);
   Set_Column_Width (Dialog_Event.Clist_Blocking, 0, 95);
   Set_Column_Width (Dialog_Event.Clist_Blocking, 1, 80);
   Set_Column_Width (Dialog_Event.Clist_Blocking, 2, 80);
   Set_Column_Width (Dialog_Event.Clist_Blocking, 3, 80);
   Set_Column_Width (Dialog_Event.Clist_Blocking, 4, 80);
   Set_Column_Width (Dialog_Event.Clist_Blocking, 5, 80);
   Add (Dialog_Event.Scrolledwindow5, Dialog_Event.Clist_Blocking);

   Gtk_New (Dialog_Event.Labelt53, -("Transaction"));
   Set_Alignment (Dialog_Event.Labelt53, 0.5, 0.5);
   Set_Padding (Dialog_Event.Labelt53, 0, 0);
   Set_Justify (Dialog_Event.Labelt53, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Labelt53, False);
   Set_Column_Widget (Dialog_Event.Clist_Blocking, 0, Dialog_Event.Labelt53);

   Gtk_New (Dialog_Event.Label53, -("Event"));
   Set_Alignment (Dialog_Event.Label53, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label53, 0, 0);
   Set_Justify (Dialog_Event.Label53, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label53, False);
   Set_Column_Widget (Dialog_Event.Clist_Blocking, 1, Dialog_Event.Label53);

   Gtk_New (Dialog_Event.Label54, -("Avg"&ASCII.LF&"Blocking Time"));
   Set_Alignment (Dialog_Event.Label54, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label54, 0, 0);
   Set_Justify (Dialog_Event.Label54, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label54, False);
   Set_Column_Widget (Dialog_Event.Clist_Blocking, 2, Dialog_Event.Label54);

   Gtk_New (Dialog_Event.Label62, -("Worst"&ASCII.LF&"Blocking Time"));
   Set_Alignment (Dialog_Event.Label62, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label62, 0, 0);
   Set_Justify (Dialog_Event.Label62, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label62, False);
   Set_Column_Widget (Dialog_Event.Clist_Blocking, 3, Dialog_Event.Label62);


   Gtk_New (Dialog_Event.Label55, -("Num of Suspensions"));
   Set_Alignment (Dialog_Event.Label55, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label55, 0, 0);
   Set_Justify (Dialog_Event.Label55, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label55, False);
   Set_Column_Widget (Dialog_Event.Clist_Blocking, 4, Dialog_Event.Label55);

   Gtk_New (Dialog_Event.Label63, -("Max Preemption Time"));
   Set_Alignment (Dialog_Event.Label63, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label63, 0, 0);
   Set_Justify (Dialog_Event.Label63, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label63, False);
   Set_Column_Widget (Dialog_Event.Clist_Blocking, 5, Dialog_Event.Label63);



   Gtk_New (Dialog_Event.Label41, -("Blocking Times"));
   Set_Alignment (Dialog_Event.Label41, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label41, 0, 0);
   Set_Justify (Dialog_Event.Label41, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label41, False);
   Set_Tab (Dialog_Event.Notebook2, 2, Dialog_Event.Label41);

   Gtk_New (Dialog_Event.Scrolledwindow6);
   Set_Policy (Dialog_Event.Scrolledwindow6, Policy_Always, Policy_Always);
   Add (Dialog_Event.Notebook2, Dialog_Event.Scrolledwindow6);

   Gtk_New (Dialog_Event.Clist_Local_Rt, 6);
   Set_Selection_Mode (Dialog_Event.Clist_Local_Rt, Selection_Single);
   Set_Shadow_Type (Dialog_Event.Clist_Local_Rt, Shadow_In);
   Set_Show_Titles (Dialog_Event.Clist_Local_Rt, True);
   Set_Column_Width (Dialog_Event.Clist_Local_Rt, 0, 95);
   Set_Column_Width (Dialog_Event.Clist_Local_Rt, 1, 80);
   Set_Column_Width (Dialog_Event.Clist_Local_Rt, 2, 101);
   Set_Column_Width (Dialog_Event.Clist_Local_Rt, 3, 108);
   Set_Column_Width (Dialog_Event.Clist_Local_Rt, 4, 114);
   Set_Column_Width (Dialog_Event.Clist_Local_Rt, 5, 80);
   Add (Dialog_Event.Scrolledwindow6, Dialog_Event.Clist_Local_Rt);

   Gtk_New (Dialog_Event.Labelt56, -("Transaction"));
   Set_Alignment (Dialog_Event.Labelt56, 0.5, 0.5);
   Set_Padding (Dialog_Event.Labelt56, 0, 0);
   Set_Justify (Dialog_Event.Labelt56, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Labelt56, False);
   Set_Column_Widget (Dialog_Event.Clist_Local_Rt, 0, Dialog_Event.Labelt56);

   Gtk_New (Dialog_Event.Label56, -("Event"));
   Set_Alignment (Dialog_Event.Label56, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label56, 0, 0);
   Set_Justify (Dialog_Event.Label56, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label56, False);
   Set_Column_Widget (Dialog_Event.Clist_Local_Rt, 1, Dialog_Event.Label56);

   Gtk_New (Dialog_Event.Label57, -("Best Response"));
   Set_Alignment (Dialog_Event.Label57, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label57, 0, 0);
   Set_Justify (Dialog_Event.Label57, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label57, False);
   Set_Column_Widget (Dialog_Event.Clist_Local_Rt, 2, Dialog_Event.Label57);

   Gtk_New (Dialog_Event.Label61, -("Avg Response"));
   Set_Alignment (Dialog_Event.Label61, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label61, 0, 0);
   Set_Justify (Dialog_Event.Label61, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label61, False);
   Set_Column_Widget (Dialog_Event.Clist_Local_Rt, 3, Dialog_Event.Label61);


   Gtk_New (Dialog_Event.Label58, -("Worst Response"));
   Set_Alignment (Dialog_Event.Label58, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label58, 0, 0);
   Set_Justify (Dialog_Event.Label58, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label58, False);
   Set_Column_Widget (Dialog_Event.Clist_Local_Rt, 4, Dialog_Event.Label58);

   Gtk_New (Dialog_Event.Label59, -("Hard Deadline"));
   Set_Alignment (Dialog_Event.Label59, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label59, 0, 0);
   Set_Justify (Dialog_Event.Label59, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label59, False);
   Set_Column_Widget (Dialog_Event.Clist_Local_Rt, 5, Dialog_Event.Label59);

   Gtk_New (Dialog_Event.Label42, -("Local Response"&ASCII.LF&"Times"));
   Set_Alignment (Dialog_Event.Label42, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label42, 0, 0);
   Set_Justify (Dialog_Event.Label42, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label42, False);
   Set_Tab (Dialog_Event.Notebook2, 3, Dialog_Event.Label42);

   -- A partir de aqui es todo nuevo
   Gtk_New (Dialog_Event.Scrolledwindow7);
   Set_Policy (Dialog_Event.Scrolledwindow7, Policy_Always, Policy_Always);
   Add (Dialog_Event.Notebook2, Dialog_Event.Scrolledwindow7);

   Gtk_New (Dialog_Event.Clist_Suspensions, 4);
   Set_Selection_Mode (Dialog_Event.Clist_Suspensions, Selection_Single);
   Set_Shadow_Type (Dialog_Event.Clist_Suspensions, Shadow_In);
   Set_Show_Titles (Dialog_Event.Clist_Suspensions, True);
   Set_Column_Width (Dialog_Event.Clist_Suspensions, 0, 95);
   Set_Column_Width (Dialog_Event.Clist_Suspensions, 1, 80);
   Set_Column_Width (Dialog_Event.Clist_Suspensions, 2, 101);
   Set_Column_Width (Dialog_Event.Clist_Suspensions, 3, 108);
   Add (Dialog_Event.Scrolledwindow7, Dialog_Event.Clist_Suspensions);

   Gtk_New (Dialog_Event.Labelt64, -("Transaction"));
   Set_Alignment (Dialog_Event.Labelt64, 0.5, 0.5);
   Set_Padding (Dialog_Event.Labelt64, 0, 0);
   Set_Justify (Dialog_Event.Labelt64, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Labelt64, False);
   Set_Column_Widget (Dialog_Event.Clist_Suspensions, 0, Dialog_Event.Labelt64);

   Gtk_New (Dialog_Event.Label65, -("Event"));
   Set_Alignment (Dialog_Event.Label65, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label65, 0, 0);
   Set_Justify (Dialog_Event.Label65, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label65, False);
   Set_Column_Widget (Dialog_Event.Clist_Suspensions, 1, Dialog_Event.Label65);

   Gtk_New (Dialog_Event.Label66, -("Suspension Time"));
   Set_Alignment (Dialog_Event.Label66, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label66, 0, 0);
   Set_Justify (Dialog_Event.Label66, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label66, False);
   Set_Column_Widget (Dialog_Event.Clist_Suspensions, 2, Dialog_Event.Label66);

   Gtk_New (Dialog_Event.Label67, -("Queued Activations"));
   Set_Alignment (Dialog_Event.Label67, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label67, 0, 0);
   Set_Justify (Dialog_Event.Label67, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label67, False);
   Set_Column_Widget (Dialog_Event.Clist_Suspensions, 3, Dialog_Event.Label67);

   Gtk_New (Dialog_Event.Label68, -("Suspensions"));
   Set_Alignment (Dialog_Event.Label68, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label68, 0, 0);
   Set_Justify (Dialog_Event.Label68, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label68, False);
   Set_Tab (Dialog_Event.Notebook2, 4, Dialog_Event.Label68);

   -- Local miss ratios
   Gtk_New (Dialog_Event.Scrolledwindow8);
   Set_Policy (Dialog_Event.Scrolledwindow8, Policy_Always, Policy_Always);
   Add (Dialog_Event.Notebook2, Dialog_Event.Scrolledwindow8);

   Gtk_New (Dialog_Event.Clist_Local_Miss_Ratios, 5);
   Set_Selection_Mode (Dialog_Event.Clist_Local_Miss_Ratios, Selection_Single);
   Set_Shadow_Type (Dialog_Event.Clist_Local_Miss_Ratios, Shadow_In);
   Set_Show_Titles (Dialog_Event.Clist_Local_Miss_Ratios, True);
   Set_Column_Width (Dialog_Event.Clist_Local_Miss_Ratios, 0, 95);
   Set_Column_Width (Dialog_Event.Clist_Local_Miss_Ratios, 1, 80);
   Set_Column_Width (Dialog_Event.Clist_Local_Miss_Ratios, 2, 101);
   Set_Column_Width (Dialog_Event.Clist_Local_Miss_Ratios, 3, 108);
   Set_Column_Width (Dialog_Event.Clist_Local_Miss_Ratios, 4, 108);
   Add (Dialog_Event.Scrolledwindow8, Dialog_Event.Clist_Local_Miss_Ratios);

   Gtk_New (Dialog_Event.Labelt69, -("Transaction"));
   Set_Alignment (Dialog_Event.Labelt69, 0.5, 0.5);
   Set_Padding (Dialog_Event.Labelt69, 0, 0);
   Set_Justify (Dialog_Event.Labelt69, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Labelt69, False);
   Set_Column_Widget (Dialog_Event.Clist_Local_Miss_Ratios, 0, Dialog_Event.Labelt69);

   Gtk_New (Dialog_Event.Label70, -("Event"));
   Set_Alignment (Dialog_Event.Label70, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label70, 0, 0);
   Set_Justify (Dialog_Event.Label70, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label70, False);
   Set_Column_Widget (Dialog_Event.Clist_Local_Miss_Ratios, 1, Dialog_Event.Label70);

   Gtk_New (Dialog_Event.Label71, -("Deadline"));
   Set_Alignment (Dialog_Event.Label71, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label71,0, 0);
   Set_Justify (Dialog_Event.Label71,Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label71,False);
   Set_Column_Widget (Dialog_Event.Clist_Local_Miss_Ratios, 2, Dialog_Event.Label71);

   Gtk_New (Dialog_Event.Label71, -("Ratio"));
   Set_Alignment (Dialog_Event.Label71, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label71,0, 0);
   Set_Justify (Dialog_Event.Label71,Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label71,False);
   Set_Column_Widget (Dialog_Event.Clist_Local_Miss_Ratios, 3, Dialog_Event.Label71);


   Gtk_New (Dialog_Event.Label80, -("Required Ratio"));
   Set_Alignment (Dialog_Event.Label80,0.5, 0.5);
   Set_Padding (Dialog_Event.Label80,0, 0);
   Set_Justify (Dialog_Event.Label80,Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label80,False);
   Set_Column_Widget (Dialog_Event.Clist_Local_Miss_Ratios, 4, Dialog_Event.Label80);

   Gtk_New (Dialog_Event.Label73, -("Local Miss Ratios"));
   Set_Alignment (Dialog_Event.Label73, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label73, 0, 0);
   Set_Justify (Dialog_Event.Label73, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label73, False);
   Set_Tab (Dialog_Event.Notebook2, 5, Dialog_Event.Label73);


   -- Global miss ratios
   Gtk_New (Dialog_Event.Scrolledwindow9);
   Set_Policy (Dialog_Event.Scrolledwindow9, Policy_Always, Policy_Always);
   Add (Dialog_Event.Notebook2, Dialog_Event.Scrolledwindow9);

   Gtk_New (Dialog_Event.Clist_Global_Miss_Ratios, 6);
   Set_Selection_Mode (Dialog_Event.Clist_Global_Miss_Ratios, Selection_Single);
   Set_Shadow_Type (Dialog_Event.Clist_Global_Miss_Ratios, Shadow_In);
   Set_Show_Titles (Dialog_Event.Clist_Global_Miss_Ratios, True);
   Set_Column_Width (Dialog_Event.Clist_Global_Miss_Ratios, 0, 95);
   Set_Column_Width (Dialog_Event.Clist_Global_Miss_Ratios, 1, 80);
   Set_Column_Width (Dialog_Event.Clist_Global_Miss_Ratios, 2, 101);
   Set_Column_Width (Dialog_Event.Clist_Global_Miss_Ratios, 3, 108);
   Set_Column_Width (Dialog_Event.Clist_Global_Miss_Ratios, 4, 108);
   Set_Column_Width (Dialog_Event.Clist_Global_Miss_Ratios, 5, 108);
   Add (Dialog_Event.Scrolledwindow9, Dialog_Event.Clist_Global_Miss_Ratios);

   Gtk_New (Dialog_Event.Labelt74, -("Transaction"));
   Set_Alignment (Dialog_Event.Labelt74, 0.5, 0.5);
   Set_Padding (Dialog_Event.Labelt74, 0, 0);
   Set_Justify (Dialog_Event.Labelt74, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Labelt74, False);
   Set_Column_Widget (Dialog_Event.Clist_Global_Miss_Ratios, 0, Dialog_Event.Labelt74);

   Gtk_New (Dialog_Event.Label75, -("Event"));
   Set_Alignment (Dialog_Event.Label75, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label75, 0, 0);
   Set_Justify (Dialog_Event.Label75, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label75, False);
   Set_Column_Widget (Dialog_Event.Clist_Global_Miss_Ratios, 1, Dialog_Event.Label75);

   Gtk_New (Dialog_Event.Label76, -("Referenced Event"));
   Set_Alignment (Dialog_Event.Label76, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label76,0, 0);
   Set_Justify (Dialog_Event.Label76,Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label76,False);
   Set_Column_Widget (Dialog_Event.Clist_Global_Miss_Ratios, 2, Dialog_Event.Label76);


   Gtk_New (Dialog_Event.Label77, -("Deadline"));
   Set_Alignment (Dialog_Event.Label77, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label77,0, 0);
   Set_Justify (Dialog_Event.Label77,Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label77,False);
   Set_Column_Widget (Dialog_Event.Clist_Global_Miss_Ratios, 3, Dialog_Event.Label77);

   Gtk_New (Dialog_Event.Label81, -("Ratio"));
   Set_Alignment (Dialog_Event.Label81, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label81,0, 0);
   Set_Justify (Dialog_Event.Label81,Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label81,False);
   Set_Column_Widget (Dialog_Event.Clist_Global_Miss_Ratios, 4, Dialog_Event.Label81);



   Gtk_New (Dialog_Event.Label78,-("Required Ratio"));
   Set_Alignment (Dialog_Event.Label78, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label78,0, 0);
   Set_Justify (Dialog_Event.Label78,Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label78,False);
   Set_Column_Widget (Dialog_Event.Clist_Global_Miss_Ratios, 5, Dialog_Event.Label78);

   Gtk_New (Dialog_Event.Label79, -("Global Miss Ratios"));
   Set_Alignment (Dialog_Event.Label79, 0.5, 0.5);
   Set_Padding (Dialog_Event.Label79, 0, 0);
   Set_Justify (Dialog_Event.Label79, Justify_Center);
   Set_Line_Wrap (Dialog_Event.Label79, False);
   Set_Tab (Dialog_Event.Notebook2, 6, Dialog_Event.Label79);




end Initialize;

end Dialog_Event_Pkg;
