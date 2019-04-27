with System; use System;
with Glib; use Glib;
with Gdk.Event; use Gdk.Event;
with Gdk.Types; use Gdk.Types;
with Gtk.Accel_Group; use Gtk.Accel_Group;
with Gtk.Object; use Gtk.Object;
with Gtk.Enums; use Gtk.Enums;
with Gtk.Style; use Gtk.Style;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Main; use Gtk.Main;
with Fileselection1_Pkg; use Fileselection1_Pkg;
with Error_Window_Pkg; use Error_Window_Pkg;
with Error_InputFile_Pkg; use Error_InputFile_Pkg;
with Help_Pkg; use Help_Pkg;
with Annealing_Window_Pkg; use Annealing_Window_Pkg;
with Hopa_Window_Pkg; use Hopa_Window_Pkg;
with Check_Spaces;
with Parameters_Handling;
with Mast.Annealing_Parameters;
with Mast.Hopa_Parameters;
with Mast.Tool_Exceptions;
with Var_Strings; use Var_Strings;
with Ada.Text_IO; use Ada.Text_IO;

package body Mast_Analysis_Pkg.Callbacks is

   use Gtk.Arguments;

   -----------------------------------
   -- On_Mast_Analysis_Delete_Event --
   -----------------------------------

   function On_Mast_Analysis_Delete_Event
     (Object : access Gtk_Widget_Record'Class;
      Params : Gtk.Arguments.Gtk_Args) return Boolean
   is
      Arg1 : Gdk_Event := To_Event (Params, 1);
   begin
      Gtk.Main.Gtk_Exit(1);
      return False;
   end On_Mast_Analysis_Delete_Event;

   ----------------------------
   -- On_Output_File_Changed --
   ----------------------------

   procedure On_Output_File_Changed
     (Object : access Gtk_Entry_Record'Class)
   is
   begin
      if Get_Text(Mast_Analysis.Output_File)="" or else
        Get_Text(Get_Entry(Mast_Analysis.Tool))="Parse"
      then
         Set_Active(Mast_Analysis.View_Results,False);
         Set_Sensitive(Mast_Analysis.View_Results,False);
      else
         Set_Sensitive(Mast_Analysis.View_Results,True);
         Set_Active(Mast_Analysis.View_Results,True);
      end if;
   end On_Output_File_Changed;

   ------------------------
   -- On_Default_Clicked --
   ------------------------

   procedure On_Default_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
      Out_Name : Var_String;
      Long : Natural;
   begin
      Out_Name :=To_Var_String(Get_Text(Mast_Analysis.Input_File));
      Long:=Length(Out_Name);
      if Long>3 and then Element(Out_Name,Long-3)='.' then
         Out_Name:=Slice(Out_Name,1,Long-3)&"out";
      else
         Out_Name:=Out_Name&".out";
      end if;
      Set_Text(Mast_Analysis.Output_File,To_String(Out_Name));
   end On_Default_Clicked;

   ----------------------
   -- On_Blank_Clicked --
   ----------------------

   procedure On_Blank_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Set_Text(Mast_Analysis.Output_File,"");
   end On_Blank_Clicked;

   -------------------------------------
   -- On_Input_File_Selection_Clicked --
   -------------------------------------

   procedure On_Input_File_Selection_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Gtk_New (Fileselection1);
      Show_All (Fileselection1);
   end On_Input_File_Selection_Clicked;

   ---------------------------
   -- On_Tool_Entry_Changed --
   ---------------------------

   procedure On_Tool_Entry_Changed
     (Object : access Gtk_Entry_Record'Class)
   is
   begin
      if Get_Text(Mast_Analysis.Output_File)="" or else
        Get_Text(Get_Entry(Mast_Analysis.Tool))="Parse"
      then
         Set_Active(Mast_Analysis.View_Results,False);
         Set_Sensitive(Mast_Analysis.View_Results,False);
      else
         Set_Sensitive(Mast_Analysis.View_Results,True);
         Set_Active(Mast_Analysis.View_Results,True);
      end if;
   end On_Tool_Entry_Changed;

   -------------------------
   -- On_Ceilings_Toggled --
   -------------------------

   procedure On_Ceilings_Toggled
     (Object : access Gtk_Check_Button_Record'Class)
   is
   begin
      if not Get_Active(Object) and then Get_Active(Mast_Analysis.Priorities)
      then
          Set_Active(Object,True);
      end if;
   end On_Ceilings_Toggled;

   ---------------------------
   -- On_Priorities_Toggled --
   ---------------------------

   procedure On_Priorities_Toggled
     (Object : access Gtk_Check_Button_Record'Class)
   is
   begin
      if Get_Active(Object) then
         Set_Active(Mast_Analysis.Ceilings,True);
      end if;
   end On_Priorities_Toggled;

   --------------------------------
   -- On_Technique_Entry_Changed --
   --------------------------------

   procedure On_Technique_Entry_Changed
     (Object : access Gtk_Entry_Record'Class)
   is
   begin
      Set_Active(Mast_Analysis.Priorities,True);
   exception
      when Constraint_Error => null;
   end On_Technique_Entry_Changed;

   ---------------------------------
   -- On_Destination_File_Changed --
   ---------------------------------

   procedure On_Destination_File_Changed
     (Object : access Gtk_Entry_Record'Class)
   is
   begin
      Set_Active(Mast_Analysis.Destination,True);
   exception
      when Constraint_Error => null;
   end On_Destination_File_Changed;

   -------------------------------
   -- On_Operation_Name_Changed --
   -------------------------------

   procedure On_Operation_Name_Changed
     (Object : access Gtk_Entry_Record'Class)
   is
   begin
      Set_Active(Mast_Analysis.Operation_Slack,True);
   exception
      when Constraint_Error => null;
   end On_Operation_Name_Changed;

   --------------------------
   -- On_Go_Button_Clicked --
   --------------------------

   procedure On_Go_Button_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
      Command_File,Results_File : File_Type;
      Command_String : Var_String:=To_Var_String("mast_analysis ");
      Results_String : Var_String;
      View_Results : Boolean:=False;
      Technique, Destination, Op_Name, Input_File, Output_File : Var_String;
      Parent : Gtk_Widget :=Get_Toplevel(Object);
      Empty_Destination,Empty_Input,Invalid_Op_Name,Same_Name : exception;


      function Has_Spaces(Line : Var_String)
              return Boolean is
      begin
         for i in 1..Length(Line) loop
            if Element(Line,i)=' ' then
               return true;
            end if;
         end loop;
         return false;
      end Has_Spaces;

   begin
      Create(Command_File,Out_File,"mast_command");
      Create(Results_File,Out_File,"mast_results_command");
      -- tool
      Command_String:=Command_String&
                      To_Lower(To_Var_String(
                       Get_Text(Get_Entry(Mast_Analysis.Tool))))&' ';
      -- options
      if Get_Active(Mast_Analysis.Verbose) then
         Command_String:=Command_String&"-v ";
      end if;
      if Get_Active(Mast_Analysis.Ceilings) then
         Command_String:=Command_String&"-c ";
      end if;
      if Get_Active(Mast_Analysis.Priorities) then
         Command_String:=Command_String&"-p ";
         Technique:=To_Lower
           (To_Var_String(Get_Text
                          (Get_Entry(Mast_Analysis.Prio_Assign_Technique))));
         if Technique/=To_Var_String("default") then
              Command_String:=Command_String&"-t "&Technique&' ';
         end if;
      end if;
      if Get_Active(Mast_Analysis.Operation_Slack) then
         Op_Name:=To_Lower
           (To_Var_String(Get_Text(Mast_Analysis.Operation_Name)));
         if Op_Name=Null_Var_String or else Has_Spaces(Op_Name) then
              raise Invalid_Op_Name;
         end if;
         Command_String:=Command_String&"-os "&
                         Op_Name&' ';
      end if;
      if Get_Active(Mast_Analysis.Destination) then
         Destination:=To_Var_String
           (Check_Spaces(Get_Text(Mast_Analysis.Directory_Entry)&
              Get_Text(Mast_Analysis.Destination_File)));
         if Get_Text(Mast_Analysis.Destination_File)="" then
              raise Empty_Destination;
         end if;
         Command_String:=Command_String&"-d "&
                         Destination&' ';
      end if;
      if Get_Active(Mast_Analysis.Slacks) then
         Command_String:=Command_String&"-s ";
      end if;

      -- files
      if Get_Text(Mast_Analysis.Input_File)="" then
         raise Empty_Input;
      end if;
      Input_File:=To_Var_String
        (Check_Spaces(Get_Text(Mast_Analysis.Directory_Entry)&
                      Get_Text(Mast_Analysis.Input_File)));
      Command_String:=Command_String&Input_File&' ';
      if Get_Text(Mast_Analysis.Output_File)/="" then
         Output_File:=To_Var_String
           (Check_Spaces(Get_Text(Mast_Analysis.Directory_Entry)&
                         Get_Text(Mast_Analysis.Output_File)));
         Command_String:=Command_String&Output_File;
         if Get_Active(Mast_Analysis.View_Results) then
            if Input_File=Output_File then
               raise Same_Name;
            end if;
            View_Results:=True;
            Results_String:=To_Var_String("gmastresults ")&
              Input_File&" "&Output_File;
         end if;
      end if;
      Put_Line(Command_File,Command_String);
      if View_Results then
         Put_Line(Results_File,Results_String);
      end if;
      Close(Command_File);
      Close(Results_File);
      Gtk.Main.Gtk_Exit(0);
   exception
      when Empty_Destination =>
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,"Empty Destination File");
         Set_Modal(Error_Window,True);
         Close(Command_File);
         Close(Results_File);
      when Invalid_Op_Name =>
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,"Empty or Invalid Operation Name");
         Set_Modal(Error_Window,True);
         Close(Command_File);
         Close(Results_File);
      when Empty_Input =>
         Gtk_New (Error_InputFile);
         Set_Position(Error_InputFile,Win_Pos_Mouse);
         Show_All (Error_InputFile);
         Set_Modal(Error_InputFile,True);
         Close(Command_File);
         Close(Results_File);
      when Same_Name =>
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Show_All (Error_Window);
         Set_Text(Error_Window.Label_Error,
                  "Results file cannot be the same as input file");
         Set_Modal(Error_Window,True);
         Close(Command_File);
         Close(Results_File);
   end On_Go_Button_Clicked;

   -------------------
   -- Gtk_Main_Quit --
   -------------------

   procedure Gtk_Main_Quit
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Gtk.Main.Gtk_Exit(1);
   end Gtk_Main_Quit;

   ----------------------------
   -- On_Hopa_Params_Clicked --
   ----------------------------

   procedure On_Hopa_Params_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Gtk_New (HOPA_Window);
      Set_Position(HOPA_Window,Win_Pos_Mouse);
      Show_All (HOPA_Window);
      Set_Modal(HOPA_Window,True);
      begin
         Mast.Hopa_Parameters.Load_Parameters;
      exception
         when Mast.Tool_Exceptions.Invalid_Format =>
            null;
      end;
      Parameters_Handling.Load_Hopa;
   end On_Hopa_Params_Clicked;

   ---------------------------------
   -- On_Annealing_Params_Clicked --
   ---------------------------------

   procedure On_Annealing_Params_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Gtk_New (Annealing_Window);
      Set_Position(Annealing_Window,Win_Pos_Mouse);
      Show_All (Annealing_Window);
      Set_Modal(Annealing_Window,True);
      begin
         Mast.Annealing_Parameters.Load_Parameters;
      exception
         when Mast.Tool_Exceptions.Invalid_Format =>
            null;
      end;
      Parameters_Handling.Load_Annealing;
   end On_Annealing_Params_Clicked;

   ----------------------------
   -- On_Help_Button_Clicked --
   ----------------------------

   procedure On_Help_Button_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Gtk_New (Help);
      Show_All (Help);
      Set_Modal(Help,True);
   end On_Help_Button_Clicked;

end Mast_Analysis_Pkg.Callbacks;
