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

with Ada.Text_IO; use Ada.Text_IO;
with Mast_Parser, Mast_Results_Parser;
with Var_Strings; use Var_Strings;
with Ada.Characters.Handling; use Ada.Characters.Handling;

-- GNAT dependent module. If compiling with another compiler you
-- can delete this with claus and its associated code (see below)
-- and make the XML to text conversion offline
with Gnat.OS_Lib;
use type Gnat.OS_Lib.String_Access, Gnat.OS_Lib.String_List;

package body Mast_Actions is

   type String_Ptr is access String;

   System_Name, Results_Name : String_Ptr;
   System_Present, Results_Present : Boolean:=False;

   -----------------
   -- Has_Results --
   -----------------

   function Has_Results return Boolean is
   begin
      return Results_Present;
   end Has_Results;

   ----------------
   -- Has_System --
   ----------------

   function Has_System return Boolean is
   begin
      return System_Present;
   end Has_System;

   ---------------------
   -- Name_Of_Results --
   ---------------------

   function Name_Of_Results return String is
   begin
      if Results_Present then
         return Results_Name.all;
      else
         raise No_Results;
      end if;
   end Name_Of_Results;

   --------------------
   -- Name_Of_System --
   --------------------

   function Name_Of_System return String is
   begin
      if System_Present then
         return System_Name.all;
      else
         raise No_System;
      end if;
   end Name_Of_System;

   ------------------
   -- Read_Results --
   ------------------

   procedure Read_Results (Filename : String) is
      F : Ada.Text_IO.File_Type;
      Results_Filename : String:=Filename;
      Success : Boolean;
   begin
      if System_Name=null then
         raise No_System;
      end if;
      Results_Name:=new String'(Filename);
      if Results_Filename'Length>3 and then
        To_lower(Results_Filename
                 (Results_Filename'Length-3..Results_Filename'Length))=".xml"
      then
         -- The following code is dependent on the GNAT compiler.
         -- If compiling with some other compiler you can comment it out,
         -- and make the conversion from XML to text format offline.
         declare
            Res_filename, Res_Text_Filename, Program_Name,
              S_Filename : Gnat.OS_Lib.String_Access;
         begin
            Res_Filename:=new String'(Results_Filename);
            Res_Text_Filename:=new String'
              (Results_Filename(1..Results_Filename'Length-3)&"txt");
            S_Filename:=new String'(System_Name.all);
            Program_Name:=Gnat.Os_Lib.Locate_Exec_On_Path
              ("mast_xml_convert_results");
            if Program_Name=null then
               raise Program_Not_Found;
            end if;
            Gnat.OS_Lib.Spawn
              (Program_Name.all,S_Filename&Res_Filename&
               Res_Text_Filename, Success);
            if not Success then
               raise XML_Convert_Results_Error;
            end if;
            Results_Filename:=Res_Text_Filename.all;
         end;
      end if;
      Ada.Text_IO.Open(F,Ada.Text_IO.In_File,Results_Filename);
      Ada.Text_IO.Set_Input(F);
      Mast_Results_Parser(The_System);
      Close(F);
      Ada.Text_IO.Set_Input(Standard_Input);
      Results_Present:=True;
   exception
      when others =>
         if Is_Open(F) then
            Close(F);
         end if;
         Ada.Text_IO.Set_Input(Standard_Input);
         raise;
   end Read_Results;

   -----------------
   -- Read_System --
   -----------------

   procedure Read_System (Filename : String) is
      F : Ada.Text_IO.File_Type;
      Input_Filename : String:=Filename;
      Success : Boolean;
   begin
      System_Name:=new String'(Filename);
      if Input_Filename'Length>3 and then
        To_lower(Input_Filename
                 (Input_Filename'Length-3..Input_Filename'Length))=".xml"
      then
         -- The following code is dependent on the GNAT compiler.
         -- If compiling with some other compiler you can comment it out,
         -- and make the conversion from XML to text format offline.
         declare
            In_filename, In_Text_Filename, Program_Name :
              Gnat.OS_Lib.String_Access;
         begin
            In_Filename:=new String'(Input_Filename);
            In_Text_Filename:=new String'
              (Input_Filename(1..Input_Filename'Length-3)&"txt");
            Program_Name:=Gnat.Os_Lib.Locate_Exec_On_Path
              ("mast_xml_convert");
            if Program_Name=null then
               raise Program_Not_Found;
            end if;
            Gnat.OS_Lib.Spawn
              ("/bin/echo",In_Filename&In_Text_Filename, Success);
            Gnat.OS_Lib.Spawn
              (Program_Name.all,In_Filename&In_Text_Filename, Success);
            if not Success then
               raise XML_Convert_Error;
            end if;
            Input_Filename:=In_Text_Filename.all;
         end;
      end if;
      Ada.Text_IO.Open(F,Ada.Text_IO.In_File,Input_Filename);
      Ada.Text_IO.Set_Input(F);
      Mast_Parser(The_System);
      Close(F);
      Ada.Text_IO.Set_Input(Standard_Input);
      System_Present:=True;
   exception
      when others =>
         if Is_Open(F) then
            Close(F);
         end if;
         Ada.Text_IO.Set_Input(Standard_Input);
         raise;
   end Read_System;

   ------------------
   -- Save_Results --
   ------------------

   procedure Save_Results (Filename : String) is
      Out_Res : File_Type;
   begin
      Ada.Text_IO.Create(Out_Res,Ada.Text_IO.Out_File,Filename);
      if To_String
        (To_Lower(Slice(To_Var_String(Filename),
                        Length(To_Var_String(Filename))-3,
                        Length(To_Var_String(Filename))))) = ".xml"
      then
         Mast.Systems.Print_Xml_Results(Out_Res,The_System);
      else
         MAST.Systems.Print_Results(Out_Res,The_System);
      end if;
      Close(Out_Res);
   end Save_Results;

   -----------------
   -- Save_System --
   -----------------

   procedure Save_System (Filename : String) is
      Out_Res : File_Type;
   begin
      Ada.Text_IO.Create(Out_Res,Ada.Text_IO.Out_File,Filename);
      if To_String
        (To_Lower(Slice(To_Var_String(Filename),
                        Length(To_Var_String(Filename))-3,
                        Length(To_Var_String(Filename))))) = ".xml"
      then
         Mast.Systems.Print_Xml(Out_Res,The_System);
      else
         MAST.Systems.Print(Out_Res,The_System);
      end if;
      Close(Out_Res);
   end Save_System;

end Mast_Actions;
