

with Text_IO;
With  text_io;
Use  text_io;

package body Mast_Parser_Error_Report is

    The_File : Text_io.File_Type;

procedure Initialize_User_Error_Report is
begin
     put_line("Initializing error report...");
end;


procedure Terminate_User_Error_Report is
begin
    if Total_Errors > 0 then
       Text_IO.Put_Line("******************************************");
       Text_IO.Put_Line("Error list output in file: mast_parser.lis");
       Text_IO.Put_Line("******************************************");
    end if;
end;


procedure Report_Continuable_Error 
    (Line_Number : in Natural;
    Offset      : in Natural;
    Finish      : in Natural;
    Message     : in String;
    Error       : in Boolean)  is
    Msg : String:="  Error at line"&Integer'Image(line_number)&
              " Col:"&Integer'Image(Offset)&"-"&Integer'Image(Finish)
              &": "&message;
begin
     Text_IO.put_line(Msg);
     Put_Line("");
     Put_Line(Msg);
end;


    procedure Initialize_Output is
      begin
        Text_io.Create(The_File, Text_io.Out_File, "mast_parser.lis");
        initialize_user_error_report;
      end Initialize_Output;

    procedure Finish_Output is
      begin
        Text_io.Close(The_File);
        terminate_user_error_report;
      end Finish_Output;

    procedure Put(S: in String) is
    begin
      Text_io.put(The_File, S);
    end Put;

    procedure Put(C: in Character) is
    begin
      Text_io.put(The_File, C);
    end Put;

    procedure Put_Line(S: in String) is
    begin
      Text_io.put_Line(The_File, S);
    end Put_Line;


end Mast_Parser_Error_Report;
