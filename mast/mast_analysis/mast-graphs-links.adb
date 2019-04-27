-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2008                     --
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

with MAST.IO;
package body MAST.Graphs.Links is

   use type Mast.Results.Timing_Result_Ref;
   use type Mast.Timing_Requirements.Timing_Requirement_Ref;
   use type Mast.Events.Event_Ref;

   --------------------------------
   -- Adjust_Timing_Requirements --
   --------------------------------

   procedure Adjust_Timing_Requirements
     (The_Graph : Graph)
   is
      Events_List : Events.Lists.List;
      Iterator : Link_Lists.Iteration_Object;
      Lnk_Ref : Link_Ref;
   begin
      -- add all external events to the list
      Link_Lists.Rewind(The_Graph.External_Links_List,Iterator);
      for I in 1..Link_Lists.Size(The_Graph.External_Links_List) loop
         Link_Lists.Get_Next_Item
           (Lnk_Ref,The_Graph.External_Links_List,Iterator);
         Events.Lists.Add(Lnk_Ref.Event,Events_List);
      end loop;

      -- add all internal events to the list
      Link_Lists.Rewind(The_Graph.Internal_Links_List,Iterator);
      for I in 1..Link_Lists.Size(The_Graph.Internal_Links_List) loop
         Link_Lists.Get_Next_Item
           (Lnk_Ref,The_Graph.Internal_Links_List,Iterator);
         Events.Lists.Add(Lnk_Ref.Event,Events_List);
      end loop;

      -- adjust all timing requirements of external events
      Link_Lists.Rewind(The_Graph.External_Links_List,Iterator);
      for I in 1..Link_Lists.Size(The_Graph.External_Links_List) loop
         Link_Lists.Get_Next_Item
           (Lnk_Ref,The_Graph.External_Links_List,Iterator);
         if Regular_Link'Class(Lnk_Ref.all).Link_Timing_Requirements /=null
         then
            Timing_Requirements.Adjust
              (Regular_Link'Class(Lnk_Ref.all).Link_Timing_Requirements.all,
               Events_List);
         end if;
      end loop;

      -- adjust all timing requirements of internal events
      Link_Lists.Rewind(The_Graph.Internal_Links_List,Iterator);
      for I in 1..Link_Lists.Size(The_Graph.Internal_Links_List) loop
         Link_Lists.Get_Next_Item
           (Lnk_Ref,The_Graph.Internal_Links_List,Iterator);
         if Regular_Link'Class(Lnk_Ref.all).Link_Timing_Requirements /=null
         then
            Timing_Requirements.Adjust
              (Regular_Link'Class(Lnk_Ref.all).Link_Timing_Requirements.all,
               Events_List);
         end if;
      end loop;
   exception
      when Object_Not_Found =>
         Set_Exception_Message
           ("in Event "&Var_Strings.To_String(Name(Lnk_Ref))&" "&
            Get_Exception_Message);
         raise;
   end Adjust_Timing_Requirements;

   -----------
   -- Clone --
   -----------

   function Clone
     (The_Link : Regular_Link)
     return Link_Ref
   is
      The_Link_Ref : Link_Ref;
   begin
      The_Link_Ref:=new Regular_Link'(The_Link);
      if The_Link.Event/= null then
         The_Link_Ref.Event:=Events.Clone(The_Link.Event.all);
      end if;
      if The_Link.Link_Timing_Requirements/=null then
         Regular_Link(The_Link_Ref.all).Link_Timing_Requirements:=
           Timing_Requirements.Clone(The_Link.Link_Timing_Requirements.all);
      end if;
      Regular_Link(The_Link_Ref.all).Link_Time_Results:=null;
      return The_Link_Ref;
   end Clone;


   -----------------
   -- Has_Results --
   -----------------

   function Has_Results
     (The_Link : Regular_Link) return Boolean is
   begin
      return The_Link.Link_Time_Results/=null;
   end Has_Results;

   -----------------------------
   -- Has_Timing_Requirements --
   -----------------------------

   function Has_Timing_Requirements
     (The_Link : Regular_Link) return Boolean is
   begin
      return The_Link.Link_Timing_Requirements/=null;
   end Has_Timing_Requirements;

   ------------------------------------
   -- Set_Link_Timing_Requirements --
   ------------------------------------

   procedure Set_Link_Timing_Requirements
     (The_Link : in out Regular_Link;
      Timing_Reqs : Timing_Requirements.Timing_Requirement_Ref)
   is
   begin
      The_Link.Link_Timing_Requirements:=Timing_Reqs;
   end Set_Link_Timing_Requirements;

   ------------------------------------
   -- Link_Timing_Requirements --
   ------------------------------------

   function Link_Timing_Requirements
     (The_Link : Regular_Link)
     return Timing_Requirements.Timing_Requirement_Ref
   is
   begin
      return The_Link.Link_Timing_Requirements;
   end Link_Timing_Requirements;

   ------------------------------------
   -- Set_Link_Time_Results --
   ------------------------------------

   procedure Set_Link_Time_Results
     (The_Link : in out Regular_Link;
      Time_Res : Results.Timing_Result_Ref)
   is
   begin
      The_Link.Link_Time_Results:=Time_Res;
   end Set_Link_Time_Results;

   ------------------------------------
   -- Link_Time_Results --
   ------------------------------------

   function Link_Time_Results
     (The_Link : Regular_Link)
     return Results.Timing_Result_Ref
   is
   begin
      return The_Link.Link_Time_Results;
   end Link_Time_Results;


   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_Link : in out Regular_Link;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 19;
   begin
      Mast.IO.Print_List_Item(File,"(",Indentation);
      if The_Link.Event /= null then
         Events.Print(File,The_Link.Event.all,Indentation+2,Finalize);
      end if;
      if The_Link.Link_Timing_Requirements /= null then
         MAST.IO.Print_Separator(File);
         MAST.IO.Print_Arg(File,"Timing_Requirements","",
                           Indentation+2,Names_Length);
         MAST.IO.Print_Separator(File,MAST.IO.Nothing);
         MAST.Timing_Requirements.Print
           (File,The_Link.Link_Timing_Requirements.all,
            Indentation+4);
      end if;
      Ada.Text_IO.Put(File,")");
   end Print;

   --------------------------------
   -- Print_Results              --
   --------------------------------

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      The_Link : in out Regular_Link;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      if The_Link.Link_Time_Results/=null then
         Results.Print(File,The_Link.Link_Time_Results.all,
                       Indentation,Finalize);
      end if;
   end Print_Results;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_Link : in out Regular_Link;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant Positive := 19;
   begin
      if The_Link.Event /= null then
         Events.Print_XML(File,The_Link.Event.all,Indentation,Finalize);
      end if;
      if The_Link.Event.all in Mast.Events.Internal_Event
      then
         if The_Link.Link_Timing_Requirements /= null
         then
            MAST.Timing_Requirements.Print_XML
              (File,The_Link.Link_Timing_Requirements.all,
               Indentation+3,False);
            Ada.Text_Io.Set_Col(File,Ada.Text_Io.Count(Indentation));
         end if;
         Ada.Text_IO.Put_Line(File,"</mast_mdl:Regular_Event>");
      end if;
   end Print_XML;

   --------------------------------
   -- Print_XML_Results          --
   --------------------------------

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      The_Link : in out Regular_Link;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      if The_Link.Link_Time_Results/=null then
         Results.Print_XML(File,The_Link.Link_Time_Results.all,
                           Indentation,Finalize);
      end if;
   end Print_XML_Results;

   ------------------------------
   -- References_Event         --
   ------------------------------

   function References_Event
     (Evnt : Mast.Events.Event_Ref;
      The_Link : Regular_Link)
     return Boolean
   is
   begin
      if The_Link.Link_Timing_Requirements=null then
         return False;
      else
         return Timing_Requirements.References_Event
           (Evnt,The_Link.Link_Timing_Requirements.all);
      end if;
   end References_Event;

end MAST.Graphs.Links;
