-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2003-2005                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors: Michael Gonzalez          mgh@unican.es                  --
--          Jose Javier Gutierrez     gutierjj@unican.es             --
--          Jose Carlos Palencia      palencij@unican.es             --
--          Jose Maria Drake          drakej@unican.es               --
--          Patricia López Martínez   lopezpa@unican.es              --
--          Yago Pereiro Estevan                                     --
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
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Maps;
with Dom.Core;
with Dom.Core.Nodes;
with Dom.Core.Processing_Instructions;
with Mast_XML_Exceptions;

package body Mast_XML_Parser_Extension is

   use type Dom.Core.Node_Types;

   function Trim_Quotes (S  :Ada.Strings.Unbounded.Unbounded_String )
                        return Ada.Strings.Unbounded.Unbounded_String
   is
      First : Integer:=1;
      Last : Integer:=Ada.Strings.Unbounded.Length(S);
   begin
      if Ada.Strings.Unbounded.Element(S,1)='"' then
         First:=2;
      end if;
      if Ada.Strings.Unbounded.Element(S,Last)='"' then
         Last:=Last-1;
      end if;
      return Ada.Strings.Unbounded.Unbounded_Slice(S,First,Last);
   end Trim_Quotes;

   procedure Get_Kind_Of_Xml_File
     (Document_Node: Dom.Core.Document;
      FileType: out Ada.Strings.Unbounded.Unbounded_String;
      Version: out Ada.Strings.Unbounded.Unbounded_String)
   is
      Command             : Ada.Strings.Unbounded.Unbounded_String;
      Node_Kind           : Dom.Core.Node_Types;
      Go                  : Boolean:=False;
      Node_P_I            : Dom.Core.Node;
      V_Pos               : Natural;
   begin
      FileType:=Ada.Strings.Unbounded.Null_Unbounded_String;
      Node_P_I:=Dom.Core.Nodes.Item
        (Dom.Core.Nodes.Child_Nodes(Document_Node),0);
      Node_Kind:=Node_P_I.all.Node_Type;
      if Node_Kind=Dom.Core.Processing_Instruction_Node
      then
         Command:=Ada.Strings.Unbounded.To_Unbounded_String
           (Dom.Core.Nodes.Node_Value(Node_P_I));
         if Dom.Core.Nodes.Node_Name(Node_P_I)="mast"
         then
            if Ada.Strings.Unbounded.Slice(Command,1,9)="fileType="
            then
               V_Pos:=Ada.Strings.Unbounded.Index
                 (Command,"version=",
                  Ada.Strings.Forward,Ada.Strings.Maps.Identity);
               if V_Pos /=0 --Version appears in the string.
               then
                  FileType:=Trim_Quotes
                    (Ada.Strings.Unbounded.To_Unbounded_String
                     (Ada.Strings.Unbounded.Slice(Command,10,V_Pos-2)));
                  Version:=Trim_Quotes
                    (Ada.Strings.Unbounded.To_Unbounded_String
                     (Ada.Strings.Unbounded.Slice
                      (Command,V_Pos+8,To_String(Command)'Last)));
                  GO:=True;
               end if;
            end if;
         end if;
      end if;
      if Go=False then
         raise Mast_XML_Exceptions.Not_A_Mast_XML_File;
      end if;
   end Get_Kind_Of_Xml_File;

end Mast_XML_Parser_Extension;
