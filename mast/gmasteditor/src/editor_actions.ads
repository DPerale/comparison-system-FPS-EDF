-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                           GMastEditor                             --
--          Graphical Editor for Modelling and Analysis              --
--                    of Real-Time Applications                      --
--                                                                   --
--                       Copyright (C) 2005-2008                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors : Pilar del Rio                                           --
--                                                                   --
-- Contact info: Michael Gonzalez       mgh@unican.es                --
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
with Glib;                   use Glib;
with Gtkada.Canvas;          use Gtkada.Canvas;
with Pango.Font;
with Mast.Systems;
with Mast_Editor.Systems;
with Mast_Editor;
with GNAT.OS_Lib;
with Var_Strings;            use Var_Strings;

package Editor_Actions is

   --  This is the filename of the file currently being edited.
   Current_Filename : GNAT.OS_Lib.String_Access;

   Editor_System : Mast_Editor.Systems.ME_System;

   The_System : Mast.Systems.System;

   Delimiter : constant String := ",";

   type Me_Arguments is array (1 .. 6) of Var_String;
   type Me_Arguments_Ref is access Me_Arguments;

   type Matrix is array (Integer range <>, Integer range <>) of Boolean;

   function Id_Name_Is_Valid (Id : String) return Boolean;

   procedure Clear_Canvas (Canvas : access Interactive_Canvas_Record'Class);

   procedure Clear_All_Canvas;

   procedure Add_Canvas_Link
     (Canvas : access Interactive_Canvas_Record'Class;
      Item1  : access Canvas_Item_Record'Class;
      Item2  : access Canvas_Item_Record'Class);

   procedure Remove_Links
     (Canvas   : access Interactive_Canvas_Record'Class;
      Item1    : access Canvas_Item_Record'Class;
      Item2    : access Canvas_Item_Record'Class;
      Outgoing : Boolean := True);

   procedure Remove_Old_Links
     (Canvas   : access Interactive_Canvas_Record'Class;
      Item     : access Canvas_Item_Record'Class;
      Outgoing : Boolean := True);

   procedure New_File;

   procedure Set_Window_Title;

   procedure Load_System_Font
     (Font_Normal : in out Pango.Font.Pango_Font_Description;
      Font_Bold   : in out Pango.Font.Pango_Font_Description);

   procedure Reset_Editor_System
     (The_Editor_System : in out Mast_Editor.Systems.ME_System);

   procedure Reset_Mast_System
     (The_Mast_System : in out Mast.Systems.System);

   function Get_Number_Of_Items
     (Canvas : access Interactive_Canvas_Record'Class)
      return   Glib.Guint;

   procedure Show_Left_Top_Item
     (Canvas : access Interactive_Canvas_Record'Class);

   procedure Show_All_Left_Top_Items;

   procedure Show_Central_Item
     (Canvas : access Interactive_Canvas_Record'Class);

   procedure Show_All_Central_Items;

   function Number_Of_Input_Links
     (Canvas : access Interactive_Canvas_Record'Class;
      Item   : access Canvas_Item_Record'Class)
      return   Guint;

   function Number_Of_Output_Links
     (Canvas : access Interactive_Canvas_Record'Class;
      Item   : access Canvas_Item_Record'Class)
      return   Guint;

   function Search_Next_Zero_Input_Item
     (Canvas : access Interactive_Canvas_Record'Class)
      return   Canvas_Item;

   procedure Move_Item_To_Index_Position
     (Canvas       : access Interactive_Canvas_Record'Class;
      Item         : access Canvas_Item_Record'Class;
      Column_Index : in Integer;
      Row_Index    : in Integer);

   procedure Draw_Input_Items
     (Canvas          : access Interactive_Canvas_Record'Class;
      Item            : access Canvas_Item_Record'Class;
      Row_Index       : in Integer;
      Column_Index    : in Integer;
      Position_Matrix : in out Matrix;
      Max_Row_Index   : in out Integer);

   procedure Draw_Output_Items
     (Canvas          : access Interactive_Canvas_Record'Class;
      Item            : access Canvas_Item_Record'Class;
      Row_Index       : in Integer;
      Column_Index    : in Integer;
      Position_Matrix : in out Matrix;
      Max_Row_Index   : in out Integer);

   procedure Show_TXT_Graphs
     (Canvas : access Interactive_Canvas_Record'Class);

   procedure Show_TXT_Items
     (Canvas : access Interactive_Canvas_Record'Class);

   procedure Put_TXT_Item
     (Canvas : access Interactive_Canvas_Record'Class;
      Item   : Mast_Editor.ME_Object_Ref);

   procedure Put_Item_In_Canvas (Item : Mast_Editor.ME_Object_Ref);

   procedure Draw_TXT_File_System
     (TXT_File_System : Mast.Systems.System := The_System;
      MSS_File_Exists : Boolean             := False);

   procedure Read_Editor_System
     (Filename         : String;
      Importing_System : Boolean := False);

   procedure Extract_Delimiter
     (Composite_Name : in Var_String;
      First_Name     : out Var_String;
      Second_Name    : out Var_String);

   procedure Read_Common_Params
     (Item      : Mast_Editor.ME_Object_Ref;
      Arguments : Me_Arguments_Ref);

   procedure Save_Editor_System
     (Filename  : String;
      Saving_As : Boolean := False);

   --function Has_Results return Boolean;

   function Has_System return Boolean;

   function Has_Editor_System return Boolean;

   procedure Import_System
     (Filename        : String;
      System_Imported : in out Mast.Systems.System);

   procedure Adjust_System_Lists (System_Imported : Mast.Systems.System);
   -- may raise adjust_system_lists if duplicate objects are found;
   -- non duplicates are added in any case

   procedure Read_System (Filename : String);

   procedure Save_System (Filename : String);

   function Name_Of_System return String;

   -----------------------------------------------------------
   -- Register the names of an empty system, for future use --
   ------------------------------------------------------------
   procedure Register_names (Filename : String; ME_Filename : String);

   --procedure Read_Results(Filename : String);

   --procedure Save_Results(Filename : String);

   --function Name_Of_Results return String;

   No_System : exception;
   -- raised by Name_of_System if no system was read

   Duplicates : exception;
   -- raised by adjust_system_lists if duplicate objects are found

   --No_Results : exception;
   -- raised by Name_of_Results if no results file was read

end Editor_Actions;
