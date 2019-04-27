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

with Ada.Text_IO, Ada.Characters.Handling;
use Ada;

package body Var_Strings is

   function To_String     (V : Var_String) return String is
   begin
      return V.Str(1..V.Num);
   end To_String;

   function To_Var_String (S : String)     return Var_String is
      V : Var_String;
   begin
      if S'Length>=Max_Length then
         V.Str:=S(S'First..S'First+Max_Length-1);
         V.Num:=Max_Length;
      else
         V.Str(1..S'Length):=S;
         V.Num:=S'Length;
      end if;
      return V;
   end To_Var_String;

   function Length (V : Var_String) return Natural is
   begin
      return V.Num;
   end Length;

   procedure Get_Line (V : out Var_String) is
   begin
      Text_IO.Get_Line(V.Str,V.Num);
   end Get_Line;

   procedure Put_Line (V : in Var_String) is
   begin
      Text_IO.Put_Line(V.Str(1..V.Num));
   end Put_Line;

   procedure Put (V : in Var_String) is
   begin
      Text_IO.Put(V.Str(1..V.Num));
   end Put;

   procedure Get_Line (F : in out Text_IO.File_Type; V : out Var_String) is
   begin
      Text_IO.Get_Line(F,V.Str,V.Num);
   end Get_Line;

   procedure Put_Line (F : in out Text_IO.File_Type; V : in Var_String) is
   begin
      Text_IO.Put_Line(F,V.Str(1..V.Num));
   end Put_Line;

   procedure Put (F : in out Text_IO.File_Type; V : in Var_String) is
   begin
      Text_IO.Put(F,V.Str(1..V.Num));
   end Put;

   function "&" (V1,V2 : Var_String) return Var_String is
      Res : Var_String;
   begin
      if V1.Num+V2.Num>Max_Length then
         Res.Str:=V1.Str(1..V1.Num)&V2.Str(1..Max_Length-V1.Num);
         Res.Num:=Max_Length;
      else
         Res.Str(1..V1.Num+V2.Num):=V1.Str(1..V1.Num)&V2.Str(1..V2.Num);
         Res.Num:=V1.Num+V2.Num;
      end if;
      return Res;
   end "&";

   function "&" (V : Var_String; S : String) return Var_String is
      Res : Var_String;
   begin
      if V.Num+S'Length>Max_Length then
         Res.Str:=V.Str(1..V.Num)&S(1..Max_Length-V.Num);
         Res.Num:=Max_Length;
      else
         Res.Str(1..V.Num+S'Length):=V.Str(1..V.Num)&S;
         Res.Num:=V.Num+S'Length;
      end if;
      return Res;
   end "&";

   function "&" (S : String; V : Var_String) return Var_String is
      Res : Var_String;
   begin
      if S'Length>=Max_Length then
         Res.Str:=S(S'First..S'First+Max_Length-1);
         Res.Num:=Max_Length;
      elsif V.Num+S'Length>Max_Length then
         Res.Str:=S&V.Str(1..Max_Length-S'Length);
         Res.Num:=Max_Length;
      else
         Res.Str(1..V.Num+S'Length):=S&V.Str(1..V.Num);
         Res.Num:=V.Num+S'Length;
      end if;
      return Res;
   end "&";

   function "&" (V : Var_String; C : Character) return Var_String is
      Res : Var_String;
   begin
      if V.Num=Max_Length then
         return V;
      else
         Res.Str(1..V.Num+1):=V.Str(1..V.Num)&C;
         Res.Num:=V.Num+1;
         return Res;
      end if;
   end "&";


   function "=" (V1,V2 : Var_String) return Boolean is
   begin
      return V1.Num=V2.Num and then V1.Str(1..V1.Num)=V2.Str(1..V2.Num);
   end "=";

   function ">" (V1,V2 : Var_String) return Boolean is
   begin
      return V1.Str(1..V1.Num)>V2.Str(1..V2.Num);
   end ">";

   function "<" (V1,V2 : Var_String) return Boolean is
   begin
      return V1.Str(1..V1.Num)<V2.Str(1..V2.Num);
   end "<";

   function ">=" (V1,V2 : Var_String) return Boolean is
   begin
      return V1.Str(1..V1.Num)>=V2.Str(1..V2.Num);
   end ">=";

   function "<=" (V1,V2 : Var_String) return Boolean is
   begin
      return V1.Str(1..V1.Num)<=V2.Str(1..V2.Num);
   end "<=";


   function Element (V : Var_String; Index : Positive) return Character is
   begin
      if Index>V.Num then
         raise Constraint_Error;
      end if;
      return V.Str(Index);
   end Element;


   function Slice (V : Var_String; Index1: Positive; Index2 : Natural)
                  return Var_String is
      Res : Var_String;
   begin
      if Index1>V.Num or Index2>V.Num then
         raise Constraint_Error;
      end if;
      if Index2<Index1 then
         return Null_Var_String;
      else
         Res.Num:=Index2-Index1+1;
         Res.Str(1..Res.Num):=V.Str(Index1..Index2);
         return Res;
      end if;
   end Slice;


   function To_Upper (V : Var_String) return Var_String is
      Res : Var_String;
   begin
      Res.Num:=V.Num;
      Res.Str(1..Res.Num):=Characters.Handling.To_Upper(V.Str(1..V.Num));
      return Res;
   end To_Upper;

   function To_Lower (V : Var_String) return Var_String is
      Res : Var_String;
   begin
      Res.Num:=V.Num;
      Res.Str(1..Res.Num):=Characters.Handling.To_Lower(V.Str(1..V.Num));
      return Res;
   end To_Lower;


   procedure Translate_To_Upper (V : in out Var_String) is
   begin
      V.Str(1..V.Num):=Characters.Handling.To_Upper(V.Str(1..V.Num));
   end Translate_To_Upper;

   procedure Translate_To_Lower (V : in out Var_String) is
   begin
      V.Str(1..V.Num):=Characters.Handling.To_Lower(V.Str(1..V.Num));
   end Translate_To_Lower;


end Var_Strings;
