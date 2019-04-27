with Gtk; use Gtk;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Combo; use Gtk.Combo;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Button; use Gtk.Button;
with Gtk.Check_Button; use Gtk.Check_Button;
with Gtk.Toggle_Button; use Gtk.Toggle_Button;
with Mast_Analysis_Pkg; use Mast_Analysis_Pkg;
with Var_Strings; use Var_Strings;
with Ada.Text_IO; use Ada.Text_IO;

procedure Read_Past_Values is

   function Find_Pos_Char_Unquoted(Char : Character;Line : Var_String)
              return Natural is
      Within_Quotes : Boolean:=False;
   begin
      for i in 1..Length(Line) loop
         if Element(Line,i)='"' then
            Within_Quotes:=not Within_Quotes;
         end if;
         if not Within_Quotes and then Element(Line,i)=Char then
            return i;
         end if;
      end loop;
      return 0;
   end Find_Pos_Char_Unquoted;


   function Find_Pos_Last_Char(Char : Character;Line : Var_String)
              return Natural is
   begin
      for i in reverse 1..Length(Line) loop
         if Element(Line,i)=Char then
            return i;
         end if;
      end loop;
      return 0;
   end Find_Pos_Last_Char;

   function No_Quotes (S : Var_String) return Var_String is
   begin
      if Length(S)>=2 and then
        (Element(S,1)='"' and then Element(S,Length(S))='"')
      then
         return Slice(S,2,Length(S)-1);
      else
         return S;
      end if;
   end No_Quotes;


   function First_Word (Line : Var_String)
                        return Var_string is
      no_spaces : var_String;
      pos_sp : Natural;
   begin
      for i in 1..Length(Line) loop
         if Element(Line,i)/=' ' then
            No_spaces:=slice(line,i,length(line));
            pos_sp := Find_Pos_Char_Unquoted(' ',No_spaces);
            if pos_sp=0 then
               return No_Quotes(No_Spaces);
            else
               return No_Quotes(Slice (No_spaces,1,pos_sp-1));
            end if;
         end if;
      end loop;
      return Null_Var_String;
   end First_Word;

   function Delete_First_word (Line : Var_String)
                              return Var_string is
      No_Spaces : Var_String;
      Pos_Sp : Natural;
   begin
      for i in 1..Length(Line) loop
         if Element(Line,i)/=' ' then
            No_Spaces:=slice(line,i,length(line));
            Pos_Sp:=Find_Pos_Char_Unquoted(' ',No_Spaces);
            if Pos_Sp=0 then
               return Null_Var_String;
            else
               return slice(No_Spaces,Pos_Sp,length(No_Spaces));
            end if;
         end if;
      end loop;
      return Null_Var_String;
   end Delete_First_Word;

   Line,Tool,Arg,Full_Arg,Directory,Input_Filename,Output_Filename,
     Full_Input_Filename,Full_Output_Filename : Var_String;
   Command_File : File_Type;
   Pos_Slash : Natural;


begin
   Open(Command_File,In_File,"mast_command");
   Get_Line(Command_File,Line);
   Close(Command_File);
   if First_Word(Line)=To_Var_String("mast_analysis") then
      Line:=Delete_First_Word(Line);
      Tool:=First_Word(Line);
      if To_String(Tool)/="parse" or else
        To_String(Tool)/="classic_rm" or else
        To_String(Tool)/="varying_priorities" or else
        To_String(Tool)/="holistic" or else
        To_String(Tool)/="offset_based_unoptimized" or else
        To_String(Tool)/="offset_based"
      then
         Set_Text(Get_Entry(Mast_Analysis.Tool),To_String(Tool));
         Line:=Delete_First_Word(Line);
         -- options and file names
         while Line/=Null_Var_String loop
            Arg:=First_Word(Line);
            if To_String(Arg)="-v" or else To_String(Arg)="-verbose" then
               Set_Active(Mast_Analysis.Verbose,True);
            elsif To_String(Arg)="-c" or else To_String(Arg)="-ceilings" then
               Set_Active(Mast_Analysis.Ceilings,True);
            elsif To_String(Arg)="-p" or else To_String(Arg)="-priorities" then
               Set_Active(Mast_Analysis.Priorities,True);
            elsif To_String(Arg)="-t" or else To_String(Arg)="-technique" then
               Line:=Delete_First_Word(Line);
               Arg:=First_Word(Line);
               if To_String(Arg)="hopa" or else
                 To_String(Arg)="annealing" or else
                 To_String(Arg)="monoprocessor"
               then
                  Set_Text(Get_Entry(Mast_Analysis.Prio_Assign_Technique),
                                     To_String(Arg));
               end if;
            elsif To_String(Arg)="-o" or else To_String(Arg)="-ordering" then
               null;
            elsif To_String(Arg)="-os" or else
              To_String(Arg)="-operation_slack"
            then
               Set_Active(Mast_Analysis.Operation_Slack,True);
               Line:=Delete_First_Word(Line);
               Arg:=To_Lower(First_Word(Line));
               Set_Text(Mast_Analysis.Operation_Name,To_String(Arg));
            elsif To_String(Arg)="-d" or else
              To_String(Arg)="-description"
            then
               Set_Active(Mast_Analysis.Destination,True);
               Line:=Delete_First_Word(Line);
               Full_Arg:=First_Word(Line);
               Pos_Slash:=Find_Pos_Last_Char('/',Full_Arg);
               if Pos_Slash=0 then
                  Pos_Slash:=Find_Pos_Last_Char('\',Full_Arg);
               end if;
               if Pos_Slash=0 then
                  Arg:=Full_Arg;
               else
                  Arg:=Slice(Full_Arg,Pos_Slash+1,
                             Length(Full_Arg));
               end if;
               Set_Text(Mast_Analysis.Destination_file,To_String(Arg));
            elsif To_String(Arg)="-s" or else To_String(Arg)="-slack" then
               Set_Active(Mast_Analysis.Slacks,True);
            else
               exit;
            end if;
            Line:=Delete_First_Word(Line);
         end loop;
         Full_Input_Filename:=First_Word(Line);
         Pos_Slash:=Find_Pos_Last_Char('/',Full_Input_Filename);
         if Pos_Slash=0 then
            Pos_Slash:=Find_Pos_Last_Char('\',Full_Input_Filename);
         end if;
         if Pos_Slash=0 then
            Directory:=Null_Var_String;
            Input_Filename:=Full_Input_Filename;
         else
            Directory:=Slice(Full_Input_Filename,1,Pos_Slash);
            Input_Filename:=Slice(Full_Input_Filename,Pos_Slash+1,
                                  Length(Full_Input_Filename));
         end if;
         Set_Text(Mast_Analysis.Directory_Entry,To_String(Directory));
         Set_Text(Mast_Analysis.Input_file,To_String(Input_Filename));
         Full_Output_Filename:=First_Word(Delete_First_Word(Line));
         if Full_Output_Filename/=Null_Var_String then
            Pos_Slash:=Find_Pos_Last_Char('/',Full_Output_Filename);
            if Pos_Slash=0 then
               Pos_Slash:=Find_Pos_Last_Char('\',Full_Output_Filename);
            end if;
            if Pos_Slash=0 then
               Output_Filename:=Full_Output_Filename;
            elsif Pos_Slash=Length(Full_Output_Filename) then
               Output_Filename:=Null_Var_String;
            else
               Output_Filename:=Slice(Full_Output_Filename,Pos_Slash+1,
                                  Length(Full_Output_Filename));
            end if;
            Set_Text(Mast_Analysis.Output_file,To_String(Output_Filename));
         end if;
      end if;
   end if;
exception

   when Name_Error => null;

end Read_Past_Values;
