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

with Binary_Trees,Mast_Parser_Tokens,Ada.Strings,Ada.Strings.Fixed,
  Ada.Characters.Handling,Ada.Float_Text_IO, Ada.Calendar;
use  Ada,Ada.Strings,Ada.Strings.Fixed,Ada.Characters.Handling;
use type Mast_Parser_Tokens.Token;

package body MAST.IO is

   type String_Ref is access all String;

   function "=" (S1,S2 : String_Ref) return Boolean is
   begin
      return S1.all=S2.all;
   end "=";

   function "<" (S1,S2 : String_Ref) return Boolean is
   begin
      return S1.all<S2.all;
   end "<";

   package Trees_Of_Tokens is new Binary_Trees
     (Element => String_Ref,
        "="     => "=",
        "<"     => "<");

   Tree_Of_Tokens:Trees_Of_Tokens.Binary_Tree:=
     Trees_Of_Tokens.Null_Tree;

   use type Trees_Of_Tokens.Node;

   ----------------
   -- Is_Date_OK --
   ----------------

   function Is_Date_OK (The_Date : Date) return Boolean is

      D : String:=Trim(The_Date,Both);
      Year   : Integer range 1900..2100;
      Month  : Integer range 1..12;
      Day    : Integer range 1..31;
      Hour   : Integer range 0..23;
      Minute : Integer range 0..59;
      Second : Integer range 0..59;
      Days_In_Month : array (1..12) of Integer:=
        (31,28,31,30,31,30,31,31,30,31,30,31);

      function Is_Leap (Y : Integer) return Boolean is
      begin
         if Y mod 4 = 0 then
            if Y mod 100 = 0 then
               if Y mod 400 =0 then
                  return True;
               else
                  return False;
               end if;
            else
               return True;
            end if;
         else
            return False;
         end if;
      end Is_Leap;

   begin
      Year :=Integer'Value(D(1..4));
      Month:=Integer'Value(D(6..7));
      Day  :=Integer'Value(D(9..10));
      if D(5)/='-' or D(8)/='-' then
         return False;
      end if;
      if Is_Leap(Year) then
         Days_In_Month(2):=29;
      end if;
      if Day>Days_In_Month(Month) then
         return False;
      end if;
      if D'Length>10 then
         if D(11)/='T' or D(14)/=':' then
            return False;
         end if;
         Hour  :=Integer'Value(D(12..13));
         Minute:=Integer'Value(D(15..16));
      end if;
      if D'Length>16 then
         if D(17)/=':' then
            return False;
         end if;
         Second  :=Integer'Value(D(18..19));
      end if;
      return True;
   exception
      when Constraint_Error =>
         return False;
   end Is_Date_OK;

   ---------------------
   -- Bit_Count_Image --
   ---------------------

   function Bit_Count_Image(B : Bit_Count) return String is
      Str : String(1..60);
   begin
      if abs(B)>=1.0E12 then
         Bit_Count_IO.Put(Str,B,3);
      elsif abs(B)>=1000.0 then
         Bit_Count_IO.Put(Str,B,1,0);
      elsif abs(B)>=1.0 then
         Bit_Count_IO.Put(Str,B,2,0);
      elsif abs(B)>=0.001 then
         Bit_Count_IO.Put(Str,B,6,0);
      elsif B=0.0 then
         Bit_Count_IO.Put(Str,B,2,0);
      else
         Bit_Count_IO.Put(Str,B,3);
      end if;
      return Trim(Str,Both);
   end Bit_Count_Image;

   ----------------
   -- Time_Image --
   ----------------

   function Time_Image(T : Time) return String is
      Str : String(1..60);
   begin
      if abs(T)>=1.0E12 then
         Time_IO.Put(Str,T,3);
      elsif abs(T)>=1000.0 then
         Time_IO.Put(Str,T,2,0);
      elsif abs(T)>=1.0 then
         Time_IO.Put(Str,T,3,0);
      elsif abs(T)>=0.001 then
         Time_IO.Put(Str,T,6,0);
      elsif T=0.0 then
         Time_IO.Put(Str,T,3,0);
      else
         Time_IO.Put(Str,T,3);
      end if;
      return Trim(Str,Both);
   end Time_Image;

   --------------------------
   -- Execution_Time_Image --
   --------------------------

   function Execution_Time_Image(T : Normalized_Execution_Time)
                                return String
   is
      Str : String(1..60);
   begin
      if abs(T)>=1.0E12 then
         Execution_Time_IO.Put(Str,T,3);
      elsif abs(T)>=1000.0 then
         Execution_Time_IO.Put(Str,T,1,0);
      elsif abs(T)>=1.0 then
         Execution_Time_IO.Put(Str,T,2,0);
      elsif abs(T)>=0.001 then
         Execution_Time_IO.Put(Str,T,6,0);
      elsif T=0.0 then
         Execution_Time_IO.Put(Str,T,2,0);
      else
         Execution_Time_IO.Put(Str,T,3);
      end if;
      return Trim(Str,Both);
   end Execution_Time_Image;


   ----------------
   -- Speed_Image --
   ----------------

   function Speed_Image(S : Processor_Speed) return String is
      Str : String(1..60);
   begin
      if abs(S)>=1.0E12 then
         Speed_IO.Put(Str,S,3);
      elsif abs(S)>=1000.0 then
         Speed_IO.Put(Str,S,1,0);
      elsif abs(S)>=1.0 then
         Speed_IO.Put(Str,S,2,0);
      elsif abs(S)>=0.001 then
         Speed_IO.Put(Str,S,6,0);
      elsif abs(S)=0.0 then
         Speed_IO.Put(Str,S,2,0);
      else
         Speed_IO.Put(Str,S,3);
      end if;
      return Trim(Str,Both);
   end Speed_Image;

   -----------------
   -- Float_Image --
   -----------------

   function Float_Image(X : Float) return String is
      Str : String(1..60);
   begin
      if abs(X)>=1.0E12 then
         Ada.Float_Text_IO.Put(Str,X,3);
      elsif abs(X)>=1000.0 then
         Ada.Float_Text_IO.Put(Str,X,1,0);
      elsif abs(X)>=1.0 then
         Ada.Float_Text_IO.Put(Str,X,2,0);
      elsif abs(X)>=0.001 then
         Ada.Float_Text_IO.Put(Str,X,6,0);
      elsif abs(X)=0.0 then
         Ada.Float_Text_IO.Put(Str,X,2,0);
      else
         Ada.Float_Text_IO.Put(Str,X,3);
      end if;
      return Trim(Str,Both);
   end Float_Image;

   ----------------------
   -- Percentage_Image --
   ----------------------

   function Percentage_Image(X : Float) return String is
   begin
      return Float_Image(X)&"%";
   end Percentage_Image;

   -------------------
   -- Integer_Image --
   -------------------

   function Integer_Image (I : Integer) return String is
   begin
      return Trim(Integer'Image(I),Both);
   end Integer_Image;

   --------------------
   -- Priority_Image --
   --------------------

   function Priority_Image (P : Priority) return String is
   begin
      return Trim(Priority'Image(P),Both);
   end Priority_Image;

   ----------------------------
   -- Preemption_Level_Image --
   ----------------------------

   function Preemption_Level_Image (P : Preemption_Level) return String is
   begin
      return Trim(Preemption_Level'Image(P),Both);
   end Preemption_Level_Image;

   ----------------
   -- Slack_Image --
   ----------------

   function Slack_Image(X : Float) return String is
      Max_Slack:constant Float:=100000.0;
   begin
      if X>=Max_Slack then
         return ">=100000.0%";
      else
         return Float_Image(X)&"%";
      end if;
   end Slack_Image;

   ----------------
   -- Date_Image --
   ----------------

   function Date_Image (D : Date) return String
   is
   begin
      return Trim(D,Both);
   end Date_Image;

   ----------------
   -- Today      --
   ----------------

   function Today return String
   is
      function Double_Digit_Image (I : Integer) return String is
      begin
         if I>9 then
            return Trim(Integer'Image(I),Both);
         else
            return "0"&Trim(Integer'Image(I),Both);
         end if;
      end Double_Digit_Image;

      Now  : Calendar.Time:=Calendar.Clock;
      Sec  : Integer:=Integer(Calendar.Seconds(Now));
      Hour : Integer:=Sec/3600;
      Min  : Integer:=(Sec-Hour*3600)/60;
   begin
      return Trim(Integer'Image(Calendar.Year(Now)),Both)&"-"&
        Double_Digit_Image(Calendar.Month(Now))&"-"&
        Double_Digit_Image(Calendar.Day(Now))&"T"&
        Double_Digit_Image(Hour)&":"&
        Double_Digit_Image(Min)&":"&
        Double_Digit_Image(Sec-Hour*3600-Min*60);
   end Today;

   ----------------
   -- Name_Image --
   ----------------

   function Name_Image (V : Var_Strings.Var_String) return String
   is
      Name_Ref : String_Ref:= new String'(Var_Strings.To_String(V));
   begin
      if Trees_Of_Tokens.Find(Name_Ref,Tree_Of_Tokens)=
        Trees_Of_Tokens.Null_Node
      then
         return Name_Ref.all;
      else
         return """"&Name_Ref.all&"""";
      end if;
   end Name_Image;

   --------------------
   -- XML_Enum_Image --
   --------------------

   function XML_Enum_Image (S : String) return String
   is
   begin
      return To_Upper(Trim(S,Both));
   end XML_Enum_Image;

     -------------------
   -- Boolean_Image --
   -------------------

   function Boolean_Image (Flag : Boolean) return String
   is
   begin
      if Flag then
         return "YES";
      else
         return"NO";
      end if;
   end Boolean_Image;

   ---------------
   -- Print_Arg --
   ---------------

   procedure Print_Arg
     (File : Ada.Text_IO.File_Type;
      Arg_Name  : String;
      Arg_Value : String;
      Indentation : Positive;
      Max_Arg_Name_Length : Positive)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,Arg_Name);
      Ada.Text_IO.Set_Col
        (File,Ada.Text_IO.Count(Indentation+Max_Arg_Name_Length+1));
      Ada.Text_IO.Put(File,"=> "&Trim(Arg_Value,Left));
   end Print_Arg;

   procedure Print_Separator
     (File : Ada.Text_IO.File_Type;
      Separator : String :=Comma;
      Finalize  : Boolean :=False)
   is
   begin
      if Finalize then
         Ada.Text_IO.Put_Line(File,");");
      else
         Ada.Text_IO.Put_Line(File,Separator);
      end if;
   end Print_Separator;

   procedure Print_List_Item
     (File : Ada.Text_IO.File_Type;
      Item_Value : String;
      Indentation : Positive)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,Trim(Item_Value,Left));
   end Print_List_Item;

begin
   declare
      Name : String_Ref;
   begin
      for T in Mast_Parser_Tokens.Token loop
         Name:=new String'(To_Lower(Mast_Parser_Tokens.Token'Image(T)));
         Trees_Of_Tokens.Add_In_Order
           (Name,Tree_Of_Tokens);
      end loop;
   end;
end MAST.IO;
