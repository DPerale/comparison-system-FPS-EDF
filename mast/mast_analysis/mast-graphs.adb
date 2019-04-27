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
package body MAST.Graphs is

   use type Events.Event_Ref;

   Names_Length : constant Positive := 15;


   -----------
   -- Clone --
   -----------

   function Clone
     (The_List : Event_Handler_Lists.List)
     return Event_Handler_Lists.List
   is
      The_Copy : Event_Handler_Lists.List;
      Iterator : Event_Handler_Lists.Iteration_Object;
      EH_Ref, EH_Ref_Copy : Event_Handler_Ref;
   begin
      Event_Handler_Lists.Rewind(The_List,Iterator);
      for I in 1..Event_Handler_Lists.Size(The_List) loop
         Event_Handler_Lists.Get_Next_Item(EH_Ref,The_List,Iterator);
         EH_Ref_Copy:=Clone(EH_Ref.all);
         Event_Handler_Lists.Add(EH_Ref_Copy,The_Copy);
      end loop;
      return The_Copy;
   end Clone;


   -----------
   -- Clone --
   -----------

   function Clone
     (The_List : Link_Lists.List)
     return Link_Lists.List
   is
      The_Copy : Link_Lists.List;
      Iterator : Link_Lists.Iteration_Object;
      Lnk_Ref, Lnk_Ref_Copy : Link_Ref;
   begin
      Link_Lists.Rewind(The_List,Iterator);
      for I in 1..Link_Lists.Size(The_List) loop
         Link_Lists.Get_Next_Item(Lnk_Ref,The_List,Iterator);
         Lnk_Ref_Copy:=Clone(Lnk_Ref.all);
         Link_Lists.Add(Lnk_Ref_Copy,The_Copy);
      end loop;
      return The_Copy;
   end Clone;


   -----------
   -- Clone --
   -----------

   function Clone
     (The_Graph : Graph)
     return Graph
   is
      The_Copy : Graph;
   begin
      The_Copy.Event_Handler_List:=Clone(The_Graph.Event_Handler_List);
      The_Copy.Internal_Links_List:=Clone(The_Graph.Internal_Links_List);
      The_Copy.External_Links_List:=Clone(The_Graph.External_Links_List);
      return The_Copy;
   end Clone;

   --------------------------------
   -- Set_Event                  --
   --------------------------------

   procedure Set_Event
     (The_Link   : in out Link;
      The_Event  : Mast.Events.Event_Ref) is
   begin
      The_Link.Event:=The_Event;
   end Set_Event;

   --------------------------------
   -- Event_Of                   --
   --------------------------------

   function Event_Of
     (The_Link : Link) return Mast.Events.Event_Ref is
   begin
      return The_Link.Event;
   end Event_Of;

   --------------------------------
   -- Name                       --
   --------------------------------

   function Name
     (The_Link : Link) return Var_Strings.Var_String is
   begin
      return Mast.Events.Name(The_Link.Event);
   end Name;

   --------------------------------
   -- Name                       --
   --------------------------------

   function Name
     (The_Link_Ref : Link_Ref) return Var_Strings.Var_String is
   begin
      return Mast.Events.Name(The_Link_Ref.Event);
   end Name;

   --------------------------------
   -- Set_Input_Event_Handler    --
   --------------------------------

   procedure Set_Input_Event_Handler
     (The_Link : in out Link;
      The_Input_Event_Handler : Event_Handler_Ref)
   is
   begin
      The_Link.Input_Event_Handler:=The_Input_Event_Handler;
   end Set_Input_Event_Handler;

   --------------------------------
   -- Input_Event_Handler        --
   --------------------------------

   function Input_Event_Handler
     (The_Link : Link) return Event_Handler_Ref
   is
   begin
      return The_Link.Input_Event_Handler;
   end Input_Event_Handler;

   --------------------------------
   -- Set_Output_Event_Handler    --
   --------------------------------

   procedure Set_Output_Event_Handler
     (The_Link : in out Link;
      The_Output_Event_Handler : Event_Handler_Ref)
   is
   begin
      The_Link.Output_Event_Handler:=The_Output_Event_Handler;
   end Set_Output_Event_Handler;

   --------------------------------
   -- Output_Event_Handler        --
   --------------------------------

   function Output_Event_Handler
     (The_Link : Link) return Event_Handler_Ref
   is
   begin
      return The_Link.Output_Event_Handler;
   end Output_Event_Handler;


   --------------------------------
   -- has Results;               --
   --------------------------------

   function Has_Results (The_Link : Link) return Boolean is
   begin
      return False;
   end Has_Results;


   --------------------------------
   -- Has_Timing_Requirements    --
   --------------------------------

   function Has_Timing_Requirements (The_Link : Link) return Boolean is
   begin
      return False;
   end Has_Timing_Requirements;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Event_Handler_Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Event_Handler_Ref;
      Iterator : Event_Handler_Lists.Index;
   begin
      MAST.IO.Print_Arg
        (File,"Event_Handlers","",Indentation,Names_Length);
      Event_Handler_Lists.Rewind(The_List,Iterator);
      for I in 1..Event_Handler_Lists.Size(The_List) loop
         if I = 1 then
            MAST.IO.Print_Separator(File,MAST.IO.Nothing);
            MAST.IO.Print_List_Item(File,MAST.IO.Left_Paren,
                                    Indentation+3);
         end if;
         Event_Handler_Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print(File,Res_Ref.all,Indentation+5,False);
         if I = Event_Handler_Lists.Size(The_List) then
            Ada.Text_IO.Put(File,")");
         else
            MAST.IO.Print_Separator(File);
         end if;
      end loop;
   end Print;

   --------------------------------
   -- Print                      --
   --------------------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      The_List : in out Link_Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Link_Ref;
      Iterator : Link_Lists.Index;
   begin
      Link_Lists.Rewind(The_List,Iterator);
      for I in 1..Link_Lists.Size(The_List) loop
         if I = 1 then
            MAST.IO.Print_Separator(File,MAST.IO.Nothing);
            MAST.IO.Print_List_Item(File,MAST.IO.Left_Paren,
                                    Indentation+3);
         end if;
         Link_Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print(File,Res_Ref.all,Indentation+5,False);
         if I = Link_Lists.Size(The_List) then
            Ada.Text_IO.Put(File,")");
         else
            MAST.IO.Print_Separator(File);
         end if;
      end loop;
   end Print;

   --------------------------------
   -- Print_Results              --
   --------------------------------

   procedure Print_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Link_Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Link_Ref;
      Printed : Boolean:=False;
      Iterator : Link_Lists.Index;
   begin
      Link_Lists.Rewind(The_List,Iterator);
      for I in 1..Link_Lists.Size(The_List) loop
         Link_Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         if Has_Results(Res_Ref.all) then
            if Printed then
               MAST.IO.Print_Separator(File);
            end if;
            Printed:=True;
            Print_Results(File,Res_Ref.all,Indentation,False);
         end if;
      end loop;
   end Print_Results;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Event_Handler_Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Event_Handler_Ref;
      Iterator : Event_Handler_Lists.Index;
   begin
      Event_Handler_Lists.Rewind(The_List,Iterator);
      for I in 1..Event_Handler_Lists.Size(The_List) loop
         Event_Handler_Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print_XML(File,Res_Ref.all,Indentation,False);
      end loop;
   end Print_XML;

   --------------------------------
   -- Print_XML                  --
   --------------------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      The_List : in out Link_Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Link_Ref;
      Iterator : Link_Lists.Index;
   begin
      Link_Lists.Rewind(The_List,Iterator);
      for I in 1..Link_Lists.Size(The_List) loop
         Link_Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         Print_XML(File,Res_Ref.all,Indentation+5,False);
      end loop;
   end Print_XML;

   --------------------------------
   -- Print_XML_Results              --
   --------------------------------

   procedure Print_XML_Results
     (File : Ada.Text_IO.File_Type;
      The_List : in out Link_Lists.List;
      Indentation : Positive)
   is
      Res_Ref : Link_Ref;
      Iterator : Link_Lists.Index;
   begin
      Link_Lists.Rewind(The_List,Iterator);
      for I in 1..Link_Lists.Size(The_List) loop
         Link_Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         if Has_Results(Res_Ref.all) then
            Print_XML_Results(File,Res_Ref.all,Indentation,False);
         end if;
      end loop;
   end Print_XML_Results;


   ------------------------------
   -- References_Event         --
   ------------------------------

   function References_Event
     (Evnt : Mast.Events.Event_Ref;
      The_List : Link_Lists.List)
     return Boolean
   is
      Res_Ref : Link_Ref;
      Iterator : Link_Lists.Index;
   begin
      Link_Lists.Rewind(The_List,Iterator);
      for I in 1..Link_Lists.Size(The_List) loop
         Link_Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         if References_Event(Evnt,Res_Ref.all) then
            return True;
         end if;
      end loop;
      return False;
   end References_Event;


   -------------------------------------
   -- Remove_Event_Handler_From_List  --
   -------------------------------------

   procedure Remove_Event_Handler_From_List
     (The_List : Link_Lists.List;
      Eh_Ref : Event_Handler_Ref)
   is
      Res_Ref : Link_Ref;
      Iterator : Link_Lists.Index;
   begin
      Link_Lists.Rewind(The_List,Iterator);
      for I in 1..Link_Lists.Size(The_List) loop
         Link_Lists.Get_Next_Item(Res_Ref,The_List,Iterator);
         if Res_Ref.Input_Event_Handler=Eh_Ref then
            Res_Ref.Input_Event_Handler:=null;
         end if;
         if Res_Ref.Output_Event_Handler=Eh_Ref then
            Res_Ref.Output_Event_Handler:=null;
         end if;
      end loop;
   end Remove_Event_Handler_From_List;

   ----------------------------
   -- Remove_Link_From_List  --
   ----------------------------

   procedure Remove_Link_From_List
     (The_List : Event_Handler_Lists.List;
      Lnk_Ref  : Link_Ref)
   is
      Iterator : Event_Handler_Lists.Iteration_Object;
      EH_Ref   : Event_Handler_Ref;
   begin
      Event_Handler_Lists.Rewind(The_List,Iterator);
      for I in 1..Event_Handler_Lists.Size(The_List) loop
         Event_Handler_Lists.Get_Next_Item(EH_Ref,The_List,Iterator);
         Remove_Link_From_Handler(Eh_Ref.all,Lnk_Ref);
      end loop;
   end Remove_Link_From_List;

end MAST.Graphs;

