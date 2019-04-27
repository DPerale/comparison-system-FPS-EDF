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

with Ada.Text_IO; use Ada;
package Var_Strings is

   Max_Length : constant Integer := 512;

   type Var_String is private;

   Null_Var_String : constant Var_String;

   function To_String     (V : Var_String) return String;
   function To_Var_String (S : String)     return Var_String;

   function Length (V : Var_String) return Natural;

   procedure Get_Line (V : out Var_String);
   procedure Put_Line (V : in Var_String);
   procedure Put      (V : in Var_String);

   procedure Get_Line (F : in out Text_IO.File_Type; V : out Var_String);
   procedure Put_Line (F : in out Text_IO.File_Type; V : in Var_String);
   procedure Put      (F : in out Text_IO.File_Type; V : in Var_String);


   function "&" (V1,V2 : Var_String) return Var_String;
   function "&" (V : Var_String; S : String) return Var_String;
   function "&" (S : String; V : Var_String) return Var_String;
   function "&" (V : Var_String; C : Character) return Var_String;

   function "=" (V1,V2 : Var_String) return Boolean;
   function ">" (V1,V2 : Var_String) return Boolean;
   function "<" (V1,V2 : Var_String) return Boolean;
   function ">=" (V1,V2 : Var_String) return Boolean;
   function "<=" (V1,V2 : Var_String) return Boolean;

   function Element (V : Var_String; Index : Positive) return Character;

   function Slice (V : Var_String; Index1 : Positive; Index2 : Natural)
                  return Var_String;

   function To_Upper (V : Var_String) return Var_String;
   function To_Lower (V : Var_String) return Var_String;

   procedure Translate_To_Upper (V : in out Var_String);
   procedure Translate_To_Lower (V : in out Var_String);

private

   type Var_String is record
      Str : String (1..Max_Length);
      Num : Integer range 0..Max_Length:=0;
   end record;

   Null_Var_String : constant Var_String :=
     (Str => (others => ' '), Num => 0);

end Var_Strings;

