with Ada.Text_IO,Var_Strings;
use Ada.Text_IO,Var_Strings;
procedure Show_File (Name : String) is
   Help_File : File_Type;
   Line : Var_Strings.Var_String;
begin
   Open(Help_File,In_File,Name);
   while not End_Of_File(Help_File) loop
      Get_Line(Help_File,Line);
      Put_Line(Line);
   end loop;
   Close(Help_File);
exception
   when Name_Error | Use_Error =>
      Put_Line("Help file not found");
   when End_Error | Layout_Error =>
      null;
end Show_File;
