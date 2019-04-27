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

with Mast.Timing_Requirements,Mast.Results,Ada.Text_IO;

package MAST.Graphs.Links is

   type Regular_Link is new Link with private;

   procedure Set_Link_Timing_Requirements
     (The_Link : in out Regular_Link;
      Timing_Reqs : Timing_Requirements.Timing_Requirement_Ref);

   function Link_Timing_Requirements
     (The_Link : Regular_Link)
     return Timing_Requirements.Timing_Requirement_Ref;

   function Has_Timing_Requirements
     (The_Link : Regular_Link) return Boolean;

   function Has_Results
     (The_Link : Regular_Link) return Boolean;

   procedure Set_Link_Time_Results
     (The_Link : in out Regular_Link;
      Time_Res : Results.Timing_Result_Ref);

   function Link_Time_Results
     (The_Link : Regular_Link)
     return Results.Timing_Result_Ref;

   function References_Event
     (Evnt : Mast.Events.Event_Ref;
      The_Link : Regular_Link)
     return Boolean;
   -- Indicates whether the timing requirements of the link
   -- reference the event specified by Evnt

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_Link : in out Regular_Link;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_Link : in out Regular_Link;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      The_Link : in out Regular_Link;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      The_Link : in out Regular_Link;
      Indentation : Positive;
      Finalize    : Boolean:=False);

   function Clone
     (The_Link : Regular_Link)
     return Link_Ref;
   -- Clone is incomplete. Input & output_event_handler references point at
   -- the old system. Later adjustment of these fields is required
   -- In addition, Results are not copied.

   procedure Adjust_Timing_Requirements
     (The_Graph : Graph);
   -- adjusts the events referenced by all the timing requirements
   -- in regular links
   -- the input & output event handlers are adjusted from the event handlers
   -- themselves
   -- it may raise object not found

private

   type Regular_Link is new Link with record
      Link_Timing_Requirements :
        Timing_Requirements.Timing_Requirement_Ref;
      Link_Time_Results : Results.Timing_Result_Ref;
   end record;

end MAST.Graphs.Links;
