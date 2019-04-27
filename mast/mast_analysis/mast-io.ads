-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2002                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors: Michael Gonzalez       mgh@unican.es                     --
--          Jose Javier Gutierrez  gutierjj@unican.es                --
--          Jose Carlos Palencia   palencij@unican.es                --
--          Jose Maria Drake       drakej@unican.es                  --
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

with Ada.Text_IO,Var_Strings;
package MAST.IO is

   Nothing : constant String := "";
   Comma : constant String := ",";
   Left_Paren : constant String := "(";
   Right_Paren : constant String := ")";

   package Time_IO is new Ada.Text_IO.Float_IO(Time);
   package Execution_Time_IO is new Ada.Text_IO.Float_IO
     (Normalized_Execution_Time);
   package Speed_IO is new Ada.Text_IO.Float_IO(Processor_Speed);
   package Bit_Count_IO is new Ada.Text_IO.Float_IO(Bit_Count);

   function Time_Image(T : Time) return String;

   function Bit_Count_Image(B : Bit_Count) return String;

   function Execution_Time_Image(T : Normalized_Execution_Time)
                                return String;

   function Speed_Image(S : Processor_Speed) return String;

   function Float_Image(X : Float) return String;

   function Slack_Image(X : Float) return String;

   function Percentage_Image(X : Float) return String;

   function Name_Image (V : Var_Strings.Var_String) return String;

   function XML_Enum_Image (S : String) return String;

   function Boolean_Image (Flag : Boolean) return String;

   function Date_Image (D : Date) return String;

   function Integer_Image (I : Integer) return String;

   function Priority_Image (P : Priority) return String;

   function Preemption_Level_Image (P : Preemption_Level) return String;

   function Today return String;

   procedure Print_Arg
     (File : Ada.Text_IO.File_Type;
      Arg_Name  : String;
      Arg_Value : String;
      Indentation : Positive;
      Max_Arg_Name_Length : Positive);

   procedure Print_Separator
     (File : Ada.Text_IO.File_Type;
      Separator : String :=Comma;
      Finalize  : Boolean :=False);

   procedure Print_List_Item
     (File : Ada.Text_IO.File_Type;
      Item_Value : String;
      Indentation : Positive);

   function Is_Date_OK (The_Date : Date) return Boolean;

end MAST.IO;
