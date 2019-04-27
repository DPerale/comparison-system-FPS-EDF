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

with Mast.Events,
  Ada.Text_IO,Indexed_Lists, Named_Lists,Var_Strings;

package MAST.Graphs is

   type Graph;

   type Event_Handler is abstract tagged null record;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Ev_Hdlr : in out Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Ev_Hdlr : in out Event_Handler;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   type Event_Handler_Ref is access all Event_Handler'Class;

   function Clone
     (Ev_Hdlr : Event_Handler)
     return Event_Handler_Ref is abstract;

   package Event_Handler_Lists is new Indexed_Lists
     (Element => Event_Handler_Ref,
        "="     => "=");

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Event_Handler_Lists.List;
      Indentation : Positive);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Event_Handler_Lists.List;
      Indentation : Positive);

   function Clone
     (The_List : Event_Handler_Lists.List)
     return Event_Handler_Lists.List;

   type Link is abstract tagged private;

   procedure Set_Event
     (The_Link   : in out Link;
      The_Event  : Mast.Events.Event_Ref);
   function Event_Of
     (The_Link : Link) return Mast.Events.Event_Ref;
   function Name
     (The_Link : Link) return Var_Strings.Var_String;
   -- returns the event name

   procedure Set_Input_Event_Handler
     (The_Link : in out Link;
      The_Input_Event_Handler : Event_Handler_Ref);
   function Input_Event_Handler
     (The_Link : Link) return Event_Handler_Ref;

   procedure Set_Output_Event_Handler
     (The_Link : in out Link;
      The_Output_Event_Handler : Event_Handler_Ref);
   function Output_Event_Handler
     (The_Link : Link) return Event_Handler_Ref;

   function Has_Timing_Requirements (The_Link : Link) return Boolean;

   function Has_Results (The_Link : Link) return Boolean;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Res : in out Link;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Res : in out Link;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      Res : in out Link;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      Res : in out Link;
      Indentation : Positive;
      Finalize    : Boolean:=False) is abstract;

   function References_Event
     (Evnt : Mast.Events.Event_Ref;
      The_Link : Link)
     return Boolean is abstract;
   -- Indicates whether the timing requirements of the link
   -- reference the event specified by Evnt

   type Link_Ref is access Link'Class;

   function Clone
     (The_Link : Link)
     return Link_Ref is abstract;

   function Name (The_Link_Ref : Link_Ref )
                 return Var_Strings.Var_String;

   package Link_Lists is new Named_Lists
     (Element => Link_Ref,
      Name    => Name);

   function Clone
     (The_List : Link_Lists.List)
     return Link_Lists.List;

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Link_Lists.List;
      Indentation : Positive);

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Link_Lists.List;
      Indentation : Positive);

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Link_Lists.List;
      Indentation : Positive);

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Link_Lists.List;
      Indentation : Positive);

   function References_Event
     (Evnt : Mast.Events.Event_Ref;
      The_List : Link_Lists.List)
     return Boolean;
   -- Indicates whether the timing requirements of the links
   -- in the list reference the event specified by Evnt

   procedure Remove_Event_Handler_From_List
     (The_List : Link_Lists.List;
      Eh_Ref : Event_Handler_Ref);

   procedure Remove_Link_From_List
     (The_List : Event_Handler_Lists.List;
      Lnk_Ref  : Link_Ref);

   procedure Remove_Link_From_Handler
     (Handler : in out Event_Handler;
      Lnk_Ref: Link_Ref) is abstract;

   type Graph is tagged record
      Event_Handler_List : Event_Handler_Lists.List;
      Internal_Links_List : Link_Lists.List;
      External_Links_List : Link_Lists.List;
   end record;

   function Clone
     (The_Graph : Graph)
     return Graph;

   Invalid_Link_Type : exception;

private

  type Link is abstract tagged record
      Event : Mast.Events.Event_Ref;
      Input_Event_Handler,
      Output_Event_Handler : Event_Handler_Ref;
   end record;

end MAST.Graphs;
