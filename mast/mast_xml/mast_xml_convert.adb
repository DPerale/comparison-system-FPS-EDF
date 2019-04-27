-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2005                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors: Michael Gonzalez       mgh@unican.es                     --
--          Jose Javier Gutierrez  gutierjj@unican.es                --
--          Jose Carlos Palencia   palencij@unican.es                --
--          Jose Maria Drake       drakej@unican.es                  --
--          Yago Pereiro                                             --
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

with Ada.Text_IO,MAST.Systems,Ada.Command_Line;
with Ada.Characters.Handling;
with Var_Strings;use Var_Strings;
with Mast_Parser, Mast_Parser_Error_Report;
with Mast_Xml_Parser, Mast_XML_Exceptions;
use Ada.Text_Io,Ada.Command_Line, Ada.Characters.Handling;

procedure Mast_XML_Convert is

   The_System : MAST.Systems.System;
   Desc, New_Desc : File_Type;
   Desc_Opened, New_Desc_Opened : Boolean:=False;
   type Kind_Of_Conversion is (To_Xml, To_Text);
   Conversion : Kind_Of_Conversion;

   Unrecognizable : exception;

   procedure Usage is
   begin
      Ada.Text_IO.Put_Line("Usage: mast_xml_convert input-file <output-file>");
      Ada.Text_IO.Put_Line("   or: mast_xml_convert -help");
   end Usage;

   procedure Close_Files is
   begin
      if Desc_Opened and then Is_Open(Desc) then
         Ada.Text_IO.Set_Input(Standard_Input);
         Close(Desc);
      end if;
      if New_Desc_Opened and then Is_Open(New_Desc) then
         Close(New_Desc);
      end if;
   end Close_Files;

   procedure Write_Output_File
     (File : in Ada.Text_IO.File_Type;
      Conversion : Kind_Of_Conversion;
      The_System : in out Mast.Systems.System)
   is
   begin
      case Conversion is
         when To_Text =>
            Mast.Systems.Print(File, The_System);
         when To_XML =>
            Mast.Systems.Print_XML(File, The_System);
      end case;
   end Write_Output_File;


begin
   if Argument_Count<1 or else Argument_Count>2 then
      Usage;
   else
      if Argument(1)="-help" or else Argument(1)="-h" then
         Ada.Text_IO.Put_Line("This program makes conversions between the "&
                              "XML and text MAST formats");
         Ada.Text_IO.Put_Line
           ("XML files are identified with the '.xml' extension");
         Usage;
      else
         -- Read the input file
         declare
            Input_Filename : String:=Argument(1);
         begin
            if Input_Filename'Length>3 and then
              To_lower(Input_Filename(Input_Filename'Length-3..
                                      Input_Filename'Length))=
              ".xml"
            then
               Conversion:=To_Text;
               Ada.Text_IO.Open(Desc,In_File,Input_Filename);
               Mast_XML_Parser.Parse(The_System,Desc);
            else
               Conversion:=To_Xml;
               Ada.Text_IO.Open(Desc,In_File,Input_Filename);
               Desc_Opened:=True;
               Ada.Text_IO.Set_Input(Desc);
               begin
                  MAST_Parser(The_System);
                  Ada.Text_IO.Set_Input(Standard_Input);
               exception
                  when Constraint_Error =>
                     raise Unrecognizable;
               end;
            end if;
         end;
         -- write the output file
         if Argument_Count=1 then
            Write_Output_File
              (Ada.Text_IO.Standard_Output,Conversion, The_System);
         else
            declare
               Output_Filename : String:=Argument(2);
            begin
               if Conversion=To_XML and then
                 (Output_Filename'Length<=3 or else
                  To_Lower(Output_Filename(Output_Filename'Length-3..
                                           Output_Filename'Length))/=
                  ".xml")
               then
                  Ada.Text_IO.Put_Line
                    ("Error: For conversion to XML, the output file name "&
                     "should have the '.xml' extension");
               elsif Conversion=To_Text and then
                 Output_Filename'Length>3 and then
                 To_Lower(Output_Filename(Output_Filename'Length-3..
                                          Output_Filename'Length))=
                 ".xml"
               then
                  Ada.Text_IO.Put_Line
                    ("Error: For conversion to text, the output file name "&
                     "should not have the '.xml' extension");
               else
                  Ada.Text_IO.Create(New_Desc,Out_File,Output_Filename);
                  New_Desc_Opened:=True;
                  Write_Output_File(New_Desc,Conversion,The_System);
               end if;
            end;
         end if;
         Close_Files;
      end if;
   end if;
exception
   when Mast_Parser_Error_Report.Syntax_Error |
     Mast_XML_Exceptions.Syntax_Error =>
      Ada.Text_IO.Put_Line("Syntax Error. Conversion not done");
      Close_Files;
      Set_Exit_Status(Failure);
   when Ada.Text_IO.Name_Error =>
      Ada.Text_IO.Put_Line("Error: Input file not found");
      Close_Files;
      Set_Exit_Status(Failure);
   when Unrecognizable | End_Error | Layout_Error =>
      Put_Line("Input file has unrecognizable format");
      Close_Files;
      Set_Exit_Status(Failure);
end Mast_XML_Convert;
