with Glib; use Glib;
with Gtk; use Gtk;
with Gdk.Types;       use Gdk.Types;
with Gtk.Widget;      use Gtk.Widget;
with Gtk.Enums;       use Gtk.Enums;
with Gtkada.Handlers; use Gtkada.Handlers;
with Gdk.Font; use Gdk.Font;
with Callbacks_Gmast_Analysis; use Callbacks_Gmast_Analysis;
with Gmast_Analysis_Intl; use Gmast_Analysis_Intl;
with Help_Pkg.Callbacks; use Help_Pkg.Callbacks;
with Ada.Characters.Latin_1;
with Pango.Font; use Pango.Font;

package body Help_Pkg is

procedure Gtk_New (Help : out Help_Access) is
begin
   Help := new Help_Record;
   Help_Pkg.Initialize (Help);
end Gtk_New;

procedure Initialize (Help : access Help_Record'Class) is

   BF,HF,TF : Pango_Font_Description;
   NL : Character := Ada.Characters.Latin_1.LF;

   pragma Suppress (All_Checks);

begin
   Gtk.Window.Initialize (Help, Window_TopLevel);
   Set_Title (Help, -"Help");
   Set_Policy (Help, False, True, False);
   Set_Position (Help, Win_Pos_None);
   Set_Modal (Help, True);
   Set_Default_Size (Help, 600, 400);

   Gtk_New_Vbox (Help.Vbox7, False, 0);
   Add (Help, Help.Vbox7);

   Gtk_New (Help.Scrolledwindow1);
   Set_Policy (Help.Scrolledwindow1, Policy_Always, Policy_Always);
   Pack_Start (Help.Vbox7, Help.Scrolledwindow1, True, True, 0);

   Gtk_New (Help.Text1);
   Set_Editable (Help.Text1, False);
   Add (Help.Scrolledwindow1, Help.Text1);

   Gtk_New
     (Help.Alignment4, 0.5, 0.5, 0.0100005,
      0.0100005);
   Pack_Start (Help.Vbox7, Help.Alignment4, False, False, 0);

   Gtk_New_From_Stock (Help.Help_Ok, "gtk-close");
   Set_Border_Width (Help.Help_Ok, 6);
   Set_Relief (Help.Help_Ok, Relief_Normal);
   Button_Callback.Connect
     (Help.Help_Ok, "clicked",
      Button_Callback.To_Marshaller (On_Help_Ok_Clicked'Access));
   Add (Help.Alignment4, Help.Help_Ok);
   Set_Border_Width (Help.Help_Ok, 6);

   BF := From_String("Times Bold 14");
   HF := From_String("Times Bold 18");
   TF := From_String("Times Bold 32");

   Insert(Text=>Help.Text1,Font=>From_Description(TF),Chars=>"Mast"&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Font=>From_Description(HF),Chars=>"Modelling and Analysis Suite for Real-Time Applications"&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Font=>From_Description(HF),Chars=>"Tool Description"&NL);
   Insert(Text=>Help.Text1,Chars=>"     "&NL);
   Insert(Text=>Help.Text1,Chars=>"      Once you press the 'GO' button, the tool parses the input"&NL);
   Insert(Text=>Help.Text1,Chars=>"      file. If it finds errors it reports them and stops. The list of"&NL);
   Insert(Text=>Help.Text1,Chars=>"      errors can be found in the file 'mast_parser.lis'. If there are"&NL);
   Insert(Text=>Help.Text1,Chars=>"      no errors, the real-time system description is transformed"&NL);
   Insert(Text=>Help.Text1,Chars=>"      according to the options specified, the analysis is performed,"&NL);
   Insert(Text=>Help.Text1,Chars=>"      and the results are output to the output file."&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Font=>From_Description(BF),Chars=>"      Tool: ");
   Insert(Text=>Help.Text1,Chars=>" is one of the following (more to come)"&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Chars=>"                      parse    : does not make the analysis"&NL);
   Insert(Text=>Help.Text1,Chars=>"                      classic_rm : classic response time analysis for"&NL);
   Insert(Text=>Help.Text1,Chars=>"                                   fixed-priority systems with arbitrary deadlines"&NL);
   Insert(Text=>Help.Text1,Chars=>"                      varying_priorities : varying priorities analysis for"&NL);
   Insert(Text=>Help.Text1,Chars=>"                                           linear fixed-priority monoprocessor systems"&NL);
   Insert(Text=>Help.Text1,Chars=>"                      edf_monoprocessor : response time analysis for EDF"&NL);
   Insert(Text=>Help.Text1,Chars=>"                                          monoprocessor systems"&NL);
   Insert(Text=>Help.Text1,Chars=>"                      edf_within_priorities : response time analysis for EDF systems"&NL);
   Insert(Text=>Help.Text1,Chars=>"                                              with edf within priorities hierarchical"&NL);
   Insert(Text=>Help.Text1,Chars=>"                                              scheduling"&NL);
   Insert(Text=>Help.Text1,Chars=>"                      holistic : holistic linear analysis"&NL);
   Insert(Text=>Help.Text1,Chars=>"                      offset_based : offset-based linear analysis"&NL);
   Insert(Text=>Help.Text1,Chars=>"                      offset_based_optimized : offset-based unoptimized"&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Chars=>"           The 'Offset_Based' analyses always provide the same or better"&NL);
   Insert(Text=>Help.Text1,Chars=>"           results than the holistic analysis, which is provided for"&NL);
   Insert(Text=>Help.Text1,Chars=>"           testing and comparison purposes."&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Font=>From_Description(BF),Chars=>"      Directory: ");
   Insert(Text=>Help.Text1,Chars=>"this is the directory used for the input, output, and"&NL);
   Insert(Text=>Help.Text1,Chars=>"                   description files (see below). It is set when the "&NL);
   Insert(Text=>Help.Text1,Chars=>"                  'File...' button is used to browse the file system."&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Font=>From_Description(BF),Chars=>"      Input File: ");
   Insert(Text=>Help.Text1,Chars=>"needs to be defined using the Mast file format"&NL);
   Insert(Text=>Help.Text1,Chars=>"                  (see the Mast file format definition)"&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Font=>From_Description(BF),Chars=>"      Output File: ");
   Insert(Text=>Help.Text1,Chars=>"will contain the results of the analysis"&NL);
   Insert(Text=>Help.Text1,Chars=>"                   if not specified, then output goes to standard"&NL);
   Insert(Text=>Help.Text1,Chars=>"                   output."&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Chars=>"                   The 'Default' button will provide an automatic file"&NL);
   Insert(Text=>Help.Text1,Chars=>"                   name for this field."&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Chars=>"                   The 'Blank' button will make this field blank"&NL);
   Insert(Text=>Help.Text1,Chars=>"  "&NL);
   Insert(Text=>Help.Text1,Font=>From_Description(BF),Chars=>"      Options: ");
   Insert(Text=>Help.Text1,Chars=>"the following options are defined:"&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Chars=>"        Verbose:"&NL);
   Insert(Text=>Help.Text1,Chars=>"              enable the verbose option"&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Chars=>"        Calculate Ceilings"&NL);
   Insert(Text=>Help.Text1,Chars=>"              calculate ceilings for priority ceiling resources before"&NL);
   Insert(Text=>Help.Text1,Chars=>"              the analysis"&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Chars=>"        Assign Priorities"&NL);
   Insert(Text=>Help.Text1,Chars=>"              make an optimum priority assignment before the analysis,"&NL);
   Insert(Text=>Help.Text1,Chars=>"              using the specified assignment technique"&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Chars=>"              The technique specifies the priority assignment technique"&NL);
   Insert(Text=>Help.Text1,Chars=>"              named with 'name'; it can be one of the following:"&NL);
   Insert(Text=>Help.Text1,Chars=>"                   default"&NL);
   Insert(Text=>Help.Text1,Chars=>"                   hopa          (default for multiprocessors)"&NL);
   Insert(Text=>Help.Text1,Chars=>"                   annealing"&NL);
   Insert(Text=>Help.Text1,Chars=>"                   deadline_distribution"&NL);
   Insert(Text=>Help.Text1,Chars=>"                   monoprocessor (default for monoprocessors)"&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Chars=>"        Source Dest. file"&NL);
   Insert(Text=>Help.Text1,Chars=>"               if this option is specified, after parsing the file and,"&NL);
   Insert(Text=>Help.Text1,Chars=>"               if required, calculating the ceilings and priorities, a"&NL);
   Insert(Text=>Help.Text1,Chars=>"               description of the system is written to the filename"&NL);
   Insert(Text=>Help.Text1,Chars=>"               specified in the option. "&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Chars=>"        Calculate Slacks"&NL);
   Insert(Text=>Help.Text1,Chars=>"               if this option is specified, the analysis is iterated"&NL);
   Insert(Text=>Help.Text1,Chars=>"               to obtain the system slack, the processing resource slacks and"&NL);
   Insert(Text=>Help.Text1,Chars=>"               the transaction slacks."&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);
   Insert(Text=>Help.Text1,Chars=>"        Calc. Operation Slack"&NL);
   Insert(Text=>Help.Text1,Chars=>"              if this option is specified, the analysis is iterated to obtain"&NL);
   Insert(Text=>Help.Text1,Chars=>"              the operation slack associated with the operation whose"&NL);
   Insert(Text=>Help.Text1,Chars=>"              name appears in the entry box placed to the right of the option"&NL);
   Insert(Text=>Help.Text1,Chars=>""&NL);

end Initialize;

end Help_Pkg;
