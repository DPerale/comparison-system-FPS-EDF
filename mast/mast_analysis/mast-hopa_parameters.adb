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

with Ada.Float_Text_IO,Ada.Text_IO,
  Ada.Strings.Unbounded,Ada.Characters.Handling,Dynamic_Lists,
  Mast.Tool_Exceptions;


use Ada.Float_Text_IO,Ada.Text_IO,
  Ada.Strings.Unbounded,Ada.Characters.Handling;

package body Mast.HOPA_Parameters is

   package K_Lists is new Dynamic_Lists
     (Element => K_Pair,
        "=" => "=");
   package Iterations_Lists is new Dynamic_Lists
     (Element => Integer,
        "=" => "=");

   Iter_List : Iterations_Lists.List;
   K_List : K_Lists.List;
   Iter_K : K_Lists.Index;
   Iter_It : Iterations_Lists.Index;
   Overiterations : Iteration_Type := 0;
   Analysis_Stop_Time : Duration;
   Audsley_Stop_Time : Duration;

   ----------------------------
   -- Get_Analysis_Stop_Time --
   ----------------------------

   function Get_Analysis_Stop_Time return Duration is
   begin
      return Analysis_Stop_Time;
   end Get_Analysis_Stop_Time;

   ---------------------------
   -- Get_Audsley_Stop_Time --
   ---------------------------

   function Get_Audsley_Stop_Time return Duration is
   begin
      return Audsley_Stop_Time;
   end Get_Audsley_Stop_Time;

   ------------
   -- Get_Ka --
   ------------

   function Get_Ka (K : K_Pair) return K_Type is
   begin
      return K.Ka;
   end Get_Ka;

   ------------
   -- Get_Kr --
   ------------

   function Get_Kr (K : K_Pair) return K_Type is
   begin
      return K.Kr;
   end Get_Kr;

   -------------------------
   -- Get_Next_Iterations --
   -------------------------

   function Get_Next_Iterations return Iteration_Type is
      It : Iteration_Type;
   begin
      Iterations_Lists.Get_Next_Item(It,Iter_List,Iter_It);
      return It;
   end Get_Next_Iterations;

   ---------------------
   -- Get_Next_K_Pair --
   ---------------------

   function Get_Next_K_Pair return K_Pair is
      K  : K_Pair;
   begin
      K_Lists.Get_Next_Item(K,K_List,Iter_K);
      return K;
   end Get_Next_K_Pair;

   ------------------------
   -- Get_Overiterations --
   ------------------------

   function Get_Overiterations return Iteration_Type is
   begin
      return Overiterations;
   end Get_Overiterations;

   --------------------------
   -- Init_Iterations_List --
   --------------------------

   procedure Init_Iterations_List is
   begin
      Iterations_Lists.Init(Iter_List);
   end Init_Iterations_List;

   -----------------
   -- Init_K_List --
   -----------------

   procedure Init_K_List is
   begin
      K_Lists.Init(K_List);
   end Init_K_List;

   -----------------------------
   -- Load_Default_Parameters --
   -----------------------------

   procedure Load_Default_Parameters is
      K : K_Pair;
   begin

      -- Kr : 1.5,2.0,3.0
      -- Ka : 1.5,2.0,3.0
      Init_K_List;
      K := (Ka=>1.5,Kr=>1.5);
      Set_Next_K_Pair(K);
      K := (Ka=>2.0,Kr=>2.0);
      Set_Next_K_Pair(K);
      K := (Ka=>3.0,Kr=>3.0);
      Set_Next_K_Pair(K);

      -- Iterations list : 10,20,30
      Init_Iterations_List;
      Set_Next_Iterations(10);
      Set_Next_Iterations(20);
      Set_Next_Iterations(30);

      -- Not optimize by default
      Set_Overiterations(0);

      -- 5.0 seconds to analyze and Ausley algorithm is not applied
      Set_Analysis_Stop_Time(5.0);
      Set_Audsley_Stop_Time(0.0);

   end Load_Default_Parameters;

   ---------------------
   -- Load_Parameters --
   ---------------------

   procedure Load_Parameters
     (File_Name : in String := "priority_assignment_parameters.txt")
   is

      type State is (Starting,Waiting_K_Size,Waiting_Ka,Waiting_Kr,
                     Waiting_It_Size,Waiting_It,Waiting_Overit,
                     Waiting_Analysis_ST,Waiting_Audsley_ST,Finished);

      Parameters_File : Ada.Text_IO.File_Type;
      U_Str : Unbounded_String;
      Str : String(1..255);
      Length, Position, Comma_Position, Parenthesis_Position : Natural;
      Actual_State : State := Starting;

      K_Size, It_Size : Integer;
      K_Temp : array (1..100) of K_Pair;
      K : Float;
      It : Integer;
      Overit : Iteration_Type;
      Stop_Time : Duration;

   begin
      -- Read parameters
      Ada.Text_IO.Open(Parameters_File,In_File,File_Name);
      while (Actual_State /= Finished) and
        not Ada.Text_IO.End_Of_File(Parameters_File)
      loop
         Ada.Text_IO.Get_Line(Parameters_File,Str,Length);
         Str := To_Upper(Str);
         for I in (Length+1)..255
         loop
            Str(I) := ' ';
         end loop;
         U_Str := To_Unbounded_String(Str);
         case Actual_State is
            when Starting =>
               Position := Index(U_Str,"HOPA_PARAMETERS");
               if Position /= 0 then
                  Position := Index(U_Str,"(");
                  if Position /= 0 then
                     Actual_State := Waiting_K_Size;
                  else
                     raise Tool_Exceptions.Invalid_Format;
                  end if;
               end if;

            when Waiting_K_Size =>
               Position := Index(U_Str,"SIZE_OF_K_LIST");
               if Position /= 0 then
                  Position := Index(U_Str,"=>");
                  Comma_Position := Index(U_Str,",");
                  if (Position /= 0) and (Comma_Position /= 0) then
                     K_Size := Integer'Value
                       (Slice(U_Str,Position+2,Comma_Position-1));
                     Init_K_List;
                     Actual_State := Waiting_Ka;
                  else
                     raise Tool_Exceptions.Invalid_Format;
                  end if;
               end if;

            when Waiting_Ka =>
               Position := Index(U_Str,"KA_LIST");
               if Position /= 0 then
                  Position := Index(U_Str,"(");
                  if Position /= 0 then
                     U_Str := Delete(U_Str,1,Position);
                     for I in 1..(K_Size-1)
                     loop
                        Comma_Position := Index(U_Str,",");
                        if Comma_Position /= 0 then
                           K := Float'Value(Slice(U_Str,1,Comma_Position-1));
                           Set_Ka(K,K_Temp(I));
                           U_Str := Delete(U_Str,1,Comma_Position);
                        else
                           raise Tool_Exceptions.Invalid_Format;
                        end if;
                     end loop;
                     Parenthesis_Position := Index(U_Str,")");
                     if Parenthesis_Position /= 0 then
                        K := Float'Value
                          (Slice(U_Str,1,Parenthesis_Position-1));
                        Set_Ka(K,K_Temp(K_Size));
                        U_Str := Delete(U_Str,1,Parenthesis_Position);
                     else
                        raise Tool_Exceptions.Invalid_Format;
                     end if;
                     Position := Index(U_Str,",");
                     if Position = 0 then
                        raise Tool_Exceptions.Invalid_Format;
                     end if;
                     Actual_State := Waiting_Kr;
                  else
                     raise Tool_Exceptions.Invalid_Format;
                  end if;
               end if;

            when Waiting_Kr =>
               Position := Index(U_Str,"KR_LIST");
               if Position /= 0 then
                  Position := Index(U_Str,"(");
                  if Position /= 0 then
                     U_Str := Delete(U_Str,1,Position);
                     for I in 1..(K_Size-1)
                     loop
                        Comma_Position := Index(U_Str,",");
                        if Comma_Position /= 0 then
                           K := Float'Value(Slice(U_Str,1,Comma_Position-1));
                           Set_Kr(K,K_Temp(I));
                           Set_Next_K_Pair(K_Temp(I));
                           U_Str := Delete(U_Str,1,Comma_Position);
                        else
                           raise Tool_Exceptions.Invalid_Format;
                        end if;
                     end loop;
                     Parenthesis_Position := Index(U_Str,")");
                     if Parenthesis_Position /= 0 then
                        K := Float'Value
                          (Slice(U_Str,1,Parenthesis_Position-1));
                        Set_Kr(K,K_Temp(K_Size));
                        Set_Next_K_Pair(K_Temp(K_Size));
                        U_Str := Delete(U_Str,1,Parenthesis_Position);
                     else
                        raise Tool_Exceptions.Invalid_Format;
                     end if;
                     Position := Index(U_Str,",");
                     if Position = 0 then
                        raise Tool_Exceptions.Invalid_Format;
                     end if;
                     Actual_State := Waiting_It_Size;
                  else
                     raise Tool_Exceptions.Invalid_Format;
                  end if;
               end if;

            when Waiting_It_Size =>
               Position := Index(U_Str,"SIZE_OF_ITERATIONS_LIST");
               if Position /= 0 then
                  Position := Index(U_Str,"=>");
                  Comma_Position := Index(U_Str,",");
                  if (Position /= 0) and (Comma_Position /= 0) then
                     It_Size := Integer'Value
                       (Slice(U_Str,Position+2,Comma_Position-1));
                     Init_Iterations_List;
                     Actual_State := Waiting_It;
                  else
                     raise Tool_Exceptions.Invalid_Format;
                  end if;
               end if;

            when Waiting_It =>
               Position := Index(U_Str,"ITERATIONS_LIST");
               if Position /= 0 then
                  Position := Index(U_Str,"(");
                  if Position /= 0 then
                     U_Str := Delete(U_Str,1,Position);
                     for I in 1..(It_Size-1)
                     loop
                        Comma_Position := Index(U_Str,",");
                        if Comma_Position /= 0 then
                           It := Integer'Value
                             (Slice(U_Str,1,Comma_Position-1));
                           Set_Next_Iterations(It);
                           U_Str := Delete(U_Str,1,Comma_Position);
                        else
                           raise Tool_Exceptions.Invalid_Format;
                        end if;
                     end loop;
                     Parenthesis_Position := Index(U_Str,")");
                     if Parenthesis_Position /= 0 then
                        It := Integer'Value
                          (Slice(U_Str,1,Parenthesis_Position-1));
                        Set_Next_Iterations(It);
                        U_Str := Delete(U_Str,1,Parenthesis_Position);
                     else
                        raise Tool_Exceptions.Invalid_Format;
                     end if;
                     Position := Index(U_Str,",");
                     if Position = 0 then
                        raise Tool_Exceptions.Invalid_Format;
                     end if;
                     Actual_State := Waiting_Overit;
                  else
                     raise Tool_Exceptions.Invalid_Format;
                  end if;
               end if;

            when Waiting_Overit =>
               Position := Index(U_Str,"ITERATIONS_TO_OPTIMIZE");
               if Position /= 0 then
                  Position := Index(U_Str,"=>");
                  Comma_Position := Index(U_Str,",");
                  if (Position /= 0) and (Comma_Position /= 0) then
                     Overit := Integer'Value
                       (Slice(U_Str,Position+2,Comma_Position-1));
                     Set_Overiterations(Overit);
                     Actual_State := Waiting_Analysis_ST;
                  else
                     raise Tool_Exceptions.Invalid_Format;
                  end if;
               end if;

            when Waiting_Analysis_ST =>
               Position := Index(U_Str,"ANALYSIS_STOP_TIME");
               if Position /= 0 then
                  Position := Index(U_Str,"=>");
                  Comma_Position := Index(U_Str,",");
                  if (Position /= 0) and (Comma_Position /= 0) then
                     Stop_Time := Duration'Value
                       (Slice(U_Str,Position+2,Comma_Position-1));
                     Set_Analysis_Stop_Time(Stop_Time);
                     Actual_State := Waiting_Audsley_ST;
                  else
                     raise Tool_Exceptions.Invalid_Format;
                  end if;
               end if;

            when Waiting_Audsley_ST =>
               Position := Index(U_Str,"AUDSLEY_STOP_TIME");
               if Position /= 0 then
                  Position := Index(U_Str,"=>");
                  Parenthesis_Position := Index(U_Str,")");
                  if (Position /= 0) and (Parenthesis_Position /= 0) then
                     Stop_Time := Duration'Value
                       (Slice(U_Str,Position+2,Parenthesis_Position-1));
                     Set_Audsley_Stop_Time(Stop_Time);
                  else
                     raise Tool_Exceptions.Invalid_Format;
                  end if;
                  Position := Index(U_Str,";");
                  if Position = 0 then
                     raise Tool_Exceptions.Invalid_Format;
                  end if;
                  Actual_State := Finished;
               end if;

            when others => null;
         end case;
      end loop;

      Ada.Text_IO.Close(Parameters_File);

   exception
      when Ada.Text_IO.Name_Error | Ada.Text_IO.Use_Error =>
         Load_Default_Parameters;
         if Ada.Text_IO.Is_Open(Parameters_File) then
            Ada.Text_IO.Close(Parameters_File);
         end if;
      when Tool_Exceptions.Invalid_Format | Constraint_Error =>
         Load_Default_Parameters;
         if Ada.Text_IO.Is_Open(Parameters_File) then
            Ada.Text_IO.Close(Parameters_File);
         end if;
         raise Tool_Exceptions.Invalid_Format;
   end Load_Parameters;

   ----------------------
   -- Store_Parameters --
   ----------------------

   procedure Store_Parameters
     (Parameters_File : in out Text_IO.File_Type)
   is
      Dec : constant Integer := 2;
      Size : Integer;
      Pair : K_Pair;
   begin
      Ada.Text_IO.Put_Line
        (Parameters_File,
         "HOPA_Parameters (");

      Size := Size_Of_K_List;
      Ada.Text_IO.Put_Line
        (Parameters_File,
         "    Size_Of_K_List          => "&Integer'Image(Size)&",");

      Ada.Text_IO.Put
        (Parameters_File,
         "    Ka_List                 => (");
      Rewind_K_List;
      for I in 1..(Size-1)
      loop
         Pair := Get_Next_K_Pair;
         Ada.Float_Text_IO.Put(Parameters_File,Get_Ka(Pair),1,Dec,0);
         Ada.Text_IO.Put(Parameters_File,",");
      end loop;
      Pair := Get_Next_K_Pair;
      Ada.Float_Text_IO.Put(Parameters_File,Get_Ka(Pair),1,Dec,0);
      Ada.Text_IO.Put_Line(Parameters_File,"),");

      Ada.Text_IO.Put
        (Parameters_File,
         "    Kr_List                 => (");
      Rewind_K_List;
      for I in 1..(Size-1)
      loop
         Pair := Get_Next_K_Pair;
         Ada.Float_Text_IO.Put(Parameters_File,Get_Kr(Pair),1,Dec,0);
         Ada.Text_IO.Put(Parameters_File,",");
      end loop;
      Pair := Get_Next_K_Pair;
      Ada.Float_Text_IO.Put(Parameters_File,Get_Kr(Pair),1,Dec,0);
      Ada.Text_IO.Put_Line(Parameters_File,"),");

      Size := Size_Of_Iterations_List;
      Ada.Text_IO.Put_Line
        (Parameters_File,
         "    Size_Of_Iterations_List => "&Integer'Image(Size)&",");

      Ada.Text_IO.Put
        (Parameters_File,
         "    Iterations_List         => (");
      Rewind_Iterations_List;
      for I in 1..(Size-1)
      loop
         Ada.Text_IO.Put
           (Parameters_File,
            Integer'Image(Get_Next_Iterations)&",");
      end loop;
      Ada.Text_IO.Put_Line
        (Parameters_File,
         Integer'Image(Get_Next_Iterations)&"),");

      Ada.Text_IO.Put_Line
        (Parameters_File,
         "    Iterations_To_Optimize  => "&
         Integer'Image(Get_Overiterations)&",");

      Ada.Text_IO.Put_Line
        (Parameters_File,
         "    Analysis_Stop_Time      => "&
         Duration'Image(Get_Analysis_Stop_Time)&",");

      Ada.Text_IO.Put_Line
        (Parameters_File,
         "    Audsley_Stop_Time       => "&
         Duration'Image(Get_Audsley_Stop_Time)&");");



   end Store_Parameters;

   ----------------------------
   -- Rewind_Iterations_List --
   ----------------------------

   procedure Rewind_Iterations_List is
   begin
      Iterations_Lists.Rewind(Iter_List,Iter_It);
   end Rewind_Iterations_List;

   -------------------
   -- Rewind_K_List --
   -------------------

   procedure Rewind_K_List is
   begin
      K_Lists.Rewind(K_List,Iter_K);
   end Rewind_K_List;

   ----------------------------
   -- Set_Analysis_Stop_Time --
   ----------------------------

   procedure Set_Analysis_Stop_Time (Stop_Time : in Duration) is
   begin
      Analysis_Stop_Time := Stop_Time;
   end Set_Analysis_Stop_Time;


   ---------------------------
   -- Set_Audsley_Stop_Time --
   ---------------------------

   procedure Set_Audsley_Stop_Time (Stop_Time : in Duration) is
   begin
      Audsley_Stop_Time := Stop_Time;
   end Set_Audsley_Stop_Time;

   ------------
   -- Set_Ka --
   ------------

   procedure Set_Ka
     (Ka : in K_Type;
      K : in out K_Pair)
   is
   begin
      K.Ka := Ka;
   end Set_Ka;

   ------------
   -- Set_Kr --
   ------------

   procedure Set_Kr
     (Kr : in K_Type;
      K : in out K_Pair)
   is
   begin
      K.Kr := Kr;
   end Set_Kr;

   -------------------------
   -- Set_Next_Iterations --
   -------------------------

   procedure Set_Next_Iterations (Iter : in Iteration_Type) is
   begin
      Iterations_Lists.Add(Iter,Iter_List);
   end Set_Next_Iterations;

   ---------------------
   -- Set_Next_K_Pair --
   ---------------------

   procedure Set_Next_K_Pair (K : in K_Pair) is
   begin
      K_Lists.Add(K,K_List);
   end Set_Next_K_Pair;

   ------------------------
   -- Set_Overiterations --
   ------------------------

   procedure Set_Overiterations (Iter : in Iteration_Type) is
   begin
      Overiterations := Iter;
   end Set_Overiterations;

   -----------------------------
   -- Size_Of_Iterations_List --
   -----------------------------

   function Size_Of_Iterations_List return Natural is
   begin
      return Iterations_Lists.Size(Iter_List);
   end Size_Of_Iterations_List;

   --------------------
   -- Size_Of_K_List --
   --------------------

   function Size_Of_K_List return Natural is
   begin
      return K_Lists.Size(K_List);
   end Size_Of_K_List;

begin
   Load_Default_Parameters;
end Mast.HOPA_Parameters;

