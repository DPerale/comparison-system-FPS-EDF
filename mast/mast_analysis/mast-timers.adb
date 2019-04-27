-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2004                     --
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

with Mast.IO;

package body Mast.Timers is

   ------------------
   -- Avg_Overhead --
   ------------------

   function Avg_Overhead
     (Timer : System_Timer)
     return Normalized_Execution_Time
   is
   begin
      return Timer.Avg_Overhead;
   end Avg_Overhead;

   -------------------
   -- Best_Overhead --
   -------------------

   function Best_Overhead
     (Timer : System_Timer)
     return Normalized_Execution_Time
   is
   begin
      return Timer.Best_Overhead;
   end Best_Overhead;

   ------------
   -- Clone --
   ------------

   function Clone
     (Timer : Alarm_Clock)
     return System_Timer_Ref
   is
      Timer_Ref : System_Timer_Ref;
   begin
      Timer_Ref:=new Alarm_Clock'(Timer);
      return Timer_Ref;
   end Clone;

   ------------
   -- Clone --
   ------------

   function Clone
     (Timer : Ticker)
     return System_Timer_Ref
   is
      Timer_Ref : System_Timer_Ref;
   begin
      Timer_Ref:=new Ticker'(Timer);
      return Timer_Ref;
   end Clone;


   ------------
   -- Period --
   ------------

   function Period
     (Timer : Ticker)
     return Time
   is
   begin
      return Timer.Period;
   end Period;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Timer : in out System_Timer;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"(");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Timer : in out Alarm_Clock;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant := 14;
   begin
      Print(File,System_Timer(Timer),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Alarm_Clock",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Worst_Overhead",
         IO.Execution_Time_Image
         (Timer.Worst_Overhead),Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Avg_Overhead",
         IO.Execution_Time_Image
         (Timer.Avg_Overhead),Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Best_Overhead",
         IO.Execution_Time_Image
         (Timer.Best_Overhead),Indentation+2,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Timer : in out Ticker;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant := 14;
   begin
      Print(File,System_Timer(Timer),Indentation);
      MAST.IO.Print_Arg
        (File,"Type",
         "Ticker",Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Worst_Overhead",
         IO.Execution_Time_Image
         (Timer.Worst_Overhead),Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Avg_Overhead",
         IO.Execution_Time_Image
         (Timer.Avg_Overhead),Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Best_Overhead",
         IO.Execution_Time_Image
         (Timer.Best_Overhead),Indentation+2,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Period",
         IO.Time_Image(Timer.Period),Indentation+2,Names_Length);
      Ada.Text_IO.Put(File,")");
   end Print;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Timer : in out Alarm_Clock;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_mdl:Alarm_Clock_System_Timer");
      Ada.Text_IO.Put
        (File," Worst_Overhead=" & """" &
         IO.Execution_Time_Image(Timer.Worst_Overhead) & """");
      Ada.Text_IO.Put
        (File," Avg_Overhead=" & """" &
         IO.Execution_Time_Image(Timer.Avg_Overhead)& """");
      Ada.Text_IO.Put
        (File," Best_Overhead=" & """" &
         IO.Execution_Time_Image(Timer.Best_Overhead)& """");
      Ada.Text_IO.Put_Line(File,"/>");
   end Print_XML;

   ---------------
   -- Print_XML --
   ---------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Timer : in out Ticker;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put(File,"<mast_mdl:Ticker_System_Timer");
      Ada.Text_IO.Put
        (File," Worst_Overhead=" & """" &
         IO.Execution_Time_Image(Timer.Worst_Overhead) & """");
      Ada.Text_IO.Put
        (File," Avg_Overhead=" & """" &
         IO.Execution_Time_Image(Timer.Avg_Overhead)& """");
      Ada.Text_IO.Put
        (File," Best_Overhead=" & """" &
         IO.Execution_Time_Image(Timer.Best_Overhead)& """");
      Ada.Text_IO.Put
        (File," Period=" & """" & IO.Time_Image(Timer.Period) & """");
      Ada.Text_IO.Put_Line(File,"/>");
   end Print_XML;

   ----------------------
   -- Set_Avg_Overhead --
   ----------------------

   procedure Set_Avg_Overhead
     (Timer : in out System_Timer;
      Overhead : in Normalized_Execution_Time)
   is
   begin
      Timer.Avg_Overhead:=Overhead;
   end Set_Avg_Overhead;

   -----------------------
   -- Set_Best_Overhead --
   -----------------------

   procedure Set_Best_Overhead
     (Timer : in out System_Timer;
      Overhead : in Normalized_Execution_Time)
   is
   begin
      Timer.Best_Overhead:=Overhead;
   end Set_Best_Overhead;

   ----------------
   -- Set_Period --
   ----------------

   procedure Set_Period
     (Timer : in out Ticker;
      The_Period : in Time)
   is
   begin
      Timer.Period:=The_Period;
   end Set_Period;

   ------------------------
   -- Set_Worst_Overhead --
   ------------------------

   procedure Set_Worst_Overhead
     (Timer : in out System_Timer;
      Overhead : in Normalized_Execution_Time)
   is
   begin
      Timer.Worst_Overhead:=Overhead;
   end Set_Worst_Overhead;

   --------------------
   -- Worst_Overhead --
   --------------------

   function Worst_Overhead
     (Timer : System_Timer)
     return Normalized_Execution_Time
   is
   begin
      return Timer.Worst_Overhead;
   end Worst_Overhead;

end Mast.Timers;
