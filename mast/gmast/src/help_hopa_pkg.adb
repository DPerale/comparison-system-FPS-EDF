with Glib; use Glib;
with Gtk; use Gtk;
with Gdk.Types;       use Gdk.Types;
with Gtk.Widget;      use Gtk.Widget;
with Gtk.Enums;       use Gtk.Enums;
with Gdk.Font; use Gdk.Font;
with Gtkada.Handlers; use Gtkada.Handlers;
with Callbacks_Gmast_Analysis; use Callbacks_Gmast_Analysis;
with Gmast_Analysis_Intl; use Gmast_Analysis_Intl;
with Help_Hopa_Pkg.Callbacks; use Help_Hopa_Pkg.Callbacks;
with Ada.Characters.Latin_1;
with Pango.Font; use Pango.Font;

package body Help_Hopa_Pkg is

procedure Gtk_New (Help_Hopa : out Help_Hopa_Access) is
begin
   Help_Hopa := new Help_Hopa_Record;
   Help_Hopa_Pkg.Initialize (Help_Hopa);
end Gtk_New;

procedure Initialize (Help_Hopa : access Help_Hopa_Record'Class) is

   BF,HF,TF : Pango_Font_Description;
   NL : Character := Ada.Characters.Latin_1.LF;

   pragma Suppress (All_Checks);

begin
   Gtk.Window.Initialize (Help_Hopa, Window_TopLevel);
   Set_Title (Help_Hopa, -"Help on the HOPA Parameters");
   Set_Policy (Help_Hopa, False, True, False);
   Set_Position (Help_Hopa, Win_Pos_Mouse);
   Set_Modal (Help_Hopa, True);
   Set_Default_Size (Help_Hopa, 600, 400);

   Gtk_New_Vbox (Help_Hopa.Vbox10, False, 0);
   Add (Help_Hopa, Help_Hopa.Vbox10);

   Gtk_New (Help_Hopa.Scrolledwindow2);
   Set_Policy (Help_Hopa.Scrolledwindow2, Policy_Always, Policy_Always);
   Pack_Start (Help_Hopa.Vbox10, Help_Hopa.Scrolledwindow2, True, True, 0);

   Gtk_New (Help_Hopa.Text2);
   Set_Editable (Help_Hopa.Text2, False);
   Add (Help_Hopa.Scrolledwindow2, Help_Hopa.Text2);

   Gtk_New
     (Help_Hopa.Alignment11, 0.5, 0.5, 0.0100005,
      0.0100005);
   Pack_Start (Help_Hopa.Vbox10, Help_Hopa.Alignment11, False, False, 0);

   Gtk_New_From_Stock (Help_Hopa.Help_Hopa_Ok_Button, "gtk-close");
   Set_Border_Width (Help_Hopa.Help_Hopa_Ok_Button, 6);
   Set_Relief (Help_Hopa.Help_Hopa_Ok_Button, Relief_Normal);
   Button_Callback.Connect
     (Help_Hopa.Help_Hopa_Ok_Button, "clicked",
      Button_Callback.To_Marshaller (On_Help_Hopa_Ok_Button_Clicked'Access));
   Add (Help_Hopa.Alignment11, Help_Hopa.Help_Hopa_Ok_Button);
   Set_Border_Width (Help_Hopa.Help_Hopa_Ok_Button, 6);

   BF := From_String("Times Bold 14");
   HF := From_String("Times Bold 18");
   TF := From_String("Times Bold 32");

   Insert(Text=>Help_Hopa.Text2,Font=>From_Description(TF),Chars=>"Mast"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Font=>From_Description(HF),Chars=>"Priority assignment parameters"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"    The priority assignment parameters allow the configuration of the"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"    priority assignment tools in order to determine two main aspects:"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"       a) bounding the number of iterations performed by the algorithm to"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"       reach a priority assignment that makes the system schedulable"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"       b) bounding the number of iterations to optimize, which are used"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"       after a feasible solution has been obtained to optimize and try"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"       reaching a better assignment."&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"    The priority assignment algorithm for single processors does not need"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"    any parameter, but the simulated annealing and HOPA algorithms work"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"    according to the values of several parameters that define their"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"    performance."&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Font=>From_Description(HF),Chars=>"HOPA parameters:"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"The maximum number of iterations for this algorithm is not explicit,"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"and depends on the size of the List of K-pairs and the values for the"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"number of iterations declared in the iterations list."&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>" - List of K-pairs: K values are heuristic constants used to modify"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"   the internal deadlines that are the basis of the algorithm. Normal"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"   values for these constant are between 1.0 and 3.0, and the usual"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"   number of different values that HOPA may attempt is between 3 and 5."&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"    - Size_Of_K_List: number of K-pairs"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"    - Ka_List: list of constants for varying the priorities according"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"      to the response times of the activities in a transaction"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"    - Kr_List: list of constants for varying the priorities according"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"      to the response times of the activities in a processing resource"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>" - List of number of iterations to perform for each K-pair:"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"   Usually, this is a list with increasing values, starting for"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"   example with 10. Each value represents an attempt to find better "&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"   solutions for all values of the list of K-pairs."&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"    - Size_Of_Iterations_List: size of the iterations list"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"    - Iterations_List: list with the numbers of iterations to be"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"      performed by the algorithm for each K-pair"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>" - Iterations_To_Optimize: maximum number of iterations to be"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"   performed by the algorithm after the first feasible solution has"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"   been reached. "&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>" - Analysis stop time: maximum time to perform analysis for each"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"   algorithm iteration; if the analysis is stopped another"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"   solution is tried. Only works if tasking is enabled."&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>" - Audsley stop time: maximum time to perform Audsley's priority"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"   assignment at each algorithm iteration; if the assignment is stopped a"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"   simpler assignment is tried. If thye value is 0, only the simple"&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>"   assignment is used. Only works if tasking is enabled."&NL);
   Insert(Text=>Help_Hopa.Text2,Chars=>""&NL);

end Initialize;

end Help_Hopa_Pkg;
