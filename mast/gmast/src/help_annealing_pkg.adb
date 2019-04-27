with Glib; use Glib;
with Gtk; use Gtk;
with Gdk.Types;       use Gdk.Types;
with Gtk.Widget;      use Gtk.Widget;
with Gtk.Enums;       use Gtk.Enums;
with Gdk.Font; use Gdk.Font;
with Gtkada.Handlers; use Gtkada.Handlers;
with Callbacks_Gmast_Analysis; use Callbacks_Gmast_Analysis;
with Gmast_Analysis_Intl; use Gmast_Analysis_Intl;
with Help_Annealing_Pkg.Callbacks; use Help_Annealing_Pkg.Callbacks;
with Ada.Characters.Latin_1;
with Pango.Font; use Pango.Font;

package body Help_Annealing_Pkg is

procedure Gtk_New (Help_Annealing : out Help_Annealing_Access) is
begin
   Help_Annealing := new Help_Annealing_Record;
   Help_Annealing_Pkg.Initialize (Help_Annealing);
end Gtk_New;

procedure Initialize (Help_Annealing : access Help_Annealing_Record'Class) is

   BF,HF,TF : Pango_Font_Description;
   NL : Character := Ada.Characters.Latin_1.LF;

   pragma Suppress (All_Checks);
begin
   Gtk.Window.Initialize (Help_Annealing, Window_TopLevel);
   Set_Title (Help_Annealing, -"Help on Annealing Parameters");
   Set_Policy (Help_Annealing, False, True, False);
   Set_Position (Help_Annealing, Win_Pos_Mouse);
   Set_Modal (Help_Annealing, True);
   Set_Default_Size (Help_Annealing, 600, 400);

   Gtk_New_Vbox (Help_Annealing.Vbox11, False, 0);
   Add (Help_Annealing, Help_Annealing.Vbox11);

   Gtk_New (Help_Annealing.Scrolledwindow3);
   Set_Policy (Help_Annealing.Scrolledwindow3, Policy_Always, Policy_Always);
   Pack_Start (Help_Annealing.Vbox11, Help_Annealing.Scrolledwindow3, True, True, 0);

   Gtk_New (Help_Annealing.Text3);
   Set_Editable (Help_Annealing.Text3, False);
   Add (Help_Annealing.Scrolledwindow3, Help_Annealing.Text3);

   Gtk_New
     (Help_Annealing.Alignment12, 0.5, 0.5, 0.0100005,
      0.0100005);
   Pack_Start (Help_Annealing.Vbox11, Help_Annealing.Alignment12, False, False, 0);

   Gtk_New_From_Stock (Help_Annealing.Help_Ann_Ok_Button, "gtk-close");
   Set_Border_Width (Help_Annealing.Help_Ann_Ok_Button, 6);
   Set_Relief (Help_Annealing.Help_Ann_Ok_Button, Relief_Normal);
   Button_Callback.Connect
     (Help_Annealing.Help_Ann_Ok_Button, "clicked",
      Button_Callback.To_Marshaller (On_Help_Ann_Ok_Button_Clicked'Access));
   Add (Help_Annealing.Alignment12, Help_Annealing.Help_Ann_Ok_Button);
   Set_Border_Width (Help_Annealing.Help_Ann_Ok_Button, 6);

   BF := From_String("Times Bold 14");
   HF := From_String("Times Bold 18");
   TF := From_String("Times Bold 32");

   Insert(Text=>Help_Annealing.Text3,Font=>From_Description(TF),Chars=>"Mast"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>""&NL);
   Insert(Text=>Help_Annealing.Text3,Font=>From_Description(HF),Chars=>"Priority assignment parameters"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>""&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"    The priority assignment parameters allow the configuration of the"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"    priority assignment tools in order to determine two main aspects:"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>""&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"       a) bounding the number of iterations performed by the algorithm to"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"       reach a priority assignment that makes the system schedulable"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>""&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"       b) bounding the number of iterations to optimize, which are used"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"       after a feasible solution has been obtained to optimize and try"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"       reaching a better assignment."&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>""&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"    The priority assignment algorithm for single processors does not need"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"    any parameter, but the simulated annealing and HOPA algorithms work"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"    according to the values of several parameters that define their"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"    performance."&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>""&NL);
   Insert(Text=>Help_Annealing.Text3,Font=>From_Description(HF),Chars=>"Simulated annealing parameters:"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>""&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>" - Max_Iterations: maximum number of iterations to be performed by"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"   the algorithm."&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>""&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>" - Iterations_To_Optimize: maximum number of iterations to be"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"   performed by the algorithm after the first feasible solution has"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"   been reached."&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>""&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>" - Analysis stop time: maximum time to perform analysis for each"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"   algorithm iteration; if the analysis is stopped another"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"   solution is tried. Only works if tasking is enabled."&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>""&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>" - Audsley stop time: maximum time to perform Audsley's priority"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"   assignment at each algorithm iteration; if the assignment is stopped a"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"   simpler assignment is tried. If thye value is 0, only the simple"&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>"   assignment is used. Only works if tasking is enabled."&NL);
   Insert(Text=>Help_Annealing.Text3,Chars=>""&NL);

end Initialize;

end Help_Annealing_Pkg;
