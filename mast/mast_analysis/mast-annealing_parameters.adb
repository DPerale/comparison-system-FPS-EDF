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

with Ada.Text_IO, Ada.Strings.Unbounded,Ada.Characters.Handling,
  Mast.Tool_Exceptions;

use Ada.Text_IO, Ada.Strings.Unbounded,Ada.Characters.Handling;

package body Mast.Annealing_Parameters is

   Max_Iterations : Iteration_Type;
   Overiterations : Iteration_Type;
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

   ------------------------
   -- Get_Max_Iterations --
   ------------------------

   function Get_Max_Iterations return Iteration_Type is
   begin
      return Max_Iterations;
   end Get_Max_Iterations;

   ------------------------
   -- Get_Overiterations --
   ------------------------

   function Get_Overiterations return Iteration_Type is
   begin
      return Overiterations;
   end Get_Overiterations;

   -----------------------------
   -- Load_Default_Parameters --
   -----------------------------

   procedure Load_Default_Parameters is
   begin
      Max_Iterations := 100000;
      Overiterations := 0;
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

      type State is (Starting,Waiting_Max_Iterations,
                     Waiting_Overiterations,Waiting_Analysis_ST,
                     Waiting_Audsley_ST,Finished);

      Parameters_File : Ada.Text_IO.File_Type;
      U_Str : Unbounded_String;
      Str : String(1..255);
      Length, Position, Comma_Position, Parenthesis_Position : Natural;
      Actual_State : State := Starting;

      Iter : Iteration_Type;
      Stop_Time : Duration;

   begin
      -- Reads parameters
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
               Position := Index(U_Str,"ANNEALING_PARAMETERS");
               if Position /= 0 then
                  Position := Index(U_Str,"(");
                  if Position /= 0 then
                     Actual_State := Waiting_Max_Iterations;
                  else
                     raise Tool_Exceptions.Invalid_Format;
                  end if;
               end if;

            when Waiting_Max_Iterations =>
               Position := Index(U_Str,"MAX_ITERATIONS");
               if Position /= 0 then
                  Position := Index(U_Str,"=>");
                  Comma_Position := Index(U_Str,",");
                  if (Position /= 0) and (Comma_Position /= 0) then
                     Iter := Long_Integer'Value
                       (Slice(U_Str,Position+2,Comma_Position-1));
                     Set_Max_Iterations(Iter);
                     Actual_State := Waiting_Overiterations;
                  else
                     raise Tool_Exceptions.Invalid_Format;
                  end if;
               end if;

            when Waiting_Overiterations =>
               Position := Index(U_Str,"ITERATIONS_TO_OPTIMIZE");
               if Position /= 0 then
                  Position := Index(U_Str,"=>");
                  Comma_Position := Index(U_Str,",");
                  if (Position /= 0) and (Comma_Position /= 0) then
                     Iter := Long_Integer'Value
                       (Slice(U_Str,Position+2,Comma_Position-1));
                     Set_Overiterations(Iter);
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
   begin
      Ada.Text_IO.Put_Line
        (Parameters_File,
         "Annealing_Parameters (");

      Ada.Text_IO.Put_Line
        (Parameters_File,
         "    Max_Iterations          => "&
         Long_Integer'Image(Get_Max_Iterations)&",");

      Ada.Text_IO.Put_Line
        (Parameters_File,
         "    Iterations_To_Optimize  => "&
         Long_Integer'Image(Get_Overiterations)&",");

      Ada.Text_IO.Put_Line
        (Parameters_File,
         "    Analysis_Stop_Time      => "&
         Duration'Image(Get_Analysis_Stop_Time)&",");

      Ada.Text_IO.Put_Line
        (Parameters_File,
         "    Audsley_Stop_Time       => "&
         Duration'Image(Get_Audsley_Stop_Time)&");");

      Ada.Text_IO.New_Line(Parameters_File,2);

   end Store_Parameters;

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

   ------------------------
   -- Set_Max_Iterations --
   ------------------------

   procedure Set_Max_Iterations (Iter : Iteration_Type) is
   begin
      Max_Iterations := Iter;
   end Set_Max_Iterations;

   ------------------------
   -- Set_Overiterations --
   ------------------------

   procedure Set_Overiterations (Iter : in Iteration_Type) is
   begin
      Overiterations := Iter;
   end Set_Overiterations;

begin
   Load_Default_Parameters;
end Mast.Annealing_Parameters;

