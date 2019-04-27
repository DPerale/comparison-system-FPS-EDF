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

with Var_Strings;
package body MAST.Tool_Exceptions is

   The_Restriction_Message : Var_Strings.Var_String;
   The_Tool_Failure_Message : Var_Strings.Var_String;

   -------------------------
   -- Restriction_Message --
   -------------------------

   function Restriction_Message return String is
   begin
      return Var_Strings.To_String(The_Restriction_Message);
   end Restriction_Message;

   -----------------------------
   -- Set_Restriction_Message --
   -----------------------------

   procedure Set_Restriction_Message (Message : String) is
   begin
      The_Restriction_Message:=Var_Strings.To_Var_String(Message);
   end Set_Restriction_Message;

   ------------------------------
   -- Set_Tool_Failure_Message --
   ------------------------------

   procedure Set_Tool_Failure_Message (Message : String) is
   begin
      The_Tool_Failure_Message:=Var_Strings.To_Var_String(Message);
   end Set_Tool_Failure_Message;

   --------------------------
   -- Tool_Failure_Message --
   --------------------------

   function Tool_Failure_Message return String is
   begin
      return Var_Strings.To_String(The_Tool_Failure_Message);
   end Tool_Failure_Message;

end MAST.Tool_Exceptions;

