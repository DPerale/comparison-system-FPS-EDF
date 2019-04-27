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

with MAST.IO;
package body MAST.Events is

   ----------------------
   -- Avg_Interarrival --
   ----------------------

   function Avg_Interarrival
     (Evnt : Aperiodic_Event)
     return Time
   is
   begin
      return Evnt.Avg_Interarrival;
   end Avg_Interarrival;

   --------------------
   -- Bound_Interval --
   --------------------

   function Bound_Interval
     (Evnt : Bursty_Event)
     return Time
   is
   begin
      return Evnt.Bound_Interval;
   end Bound_Interval;

   -----------
   -- Clone --
   -----------

   function Clone
     (Evnt : Internal_Event)
     return Event_Ref
   is
      Ev_Ref : Event_Ref;
   begin
      Ev_Ref:=new Internal_Event'(Evnt);
      return Ev_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Evnt : Periodic_Event)
     return Event_Ref
   is
      Ev_Ref : Event_Ref;
   begin
      Ev_Ref:=new Periodic_Event'(Evnt);
      return Ev_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Evnt : Singular_Event)
     return Event_Ref
   is
      Ev_Ref : Event_Ref;
   begin
      Ev_Ref:=new Singular_Event'(Evnt);
      return Ev_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Evnt : Sporadic_Event)
     return Event_Ref
   is
      Ev_Ref : Event_Ref;
   begin
      Ev_Ref:=new Sporadic_Event'(Evnt);
      return Ev_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Evnt : Unbounded_Event)
     return Event_Ref
   is
      Ev_Ref : Event_Ref;
   begin
      Ev_Ref:=new Unbounded_Event'(Evnt);
      return Ev_Ref;
   end Clone;

   -----------
   -- Clone --
   -----------

   function Clone
     (Evnt : Bursty_Event)
     return Event_Ref
   is
      Ev_Ref : Event_Ref;
   begin
      Ev_Ref:=new Bursty_Event'(Evnt);
      return Ev_Ref;
   end Clone;

   ------------------
   -- Distribution --
   ------------------

   function Distribution
     (Evnt : Aperiodic_Event)
     return Distribution_Function
   is
   begin
      return Evnt.Distribution;
   end Distribution;

   ----------
   -- Init --
   ----------

   procedure Init
     (Evnt : in out Event;
      Name : Var_Strings.Var_String)
   is
   begin
      Evnt.Name:=Name;
   end Init;

   ------------------
   -- Max_Arrivals --
   ------------------

   function Max_Arrivals
     (Evnt : Bursty_Event)
     return Positive
   is
   begin
      return Evnt.Max_Arrivals;
   end Max_Arrivals;

   ----------------
   -- Max_Jitter --
   ----------------

   function Max_Jitter
     (Evnt : Periodic_Event)
     return Time
   is
   begin
      return Evnt.Max_Jitter;
   end Max_Jitter;

   ----------------------
   -- Min_Interarrival --
   ----------------------

   function Min_Interarrival
     (Evnt : Sporadic_Event)
     return Time
   is
   begin
      return Evnt.Min_Interarrival;
   end Min_Interarrival;

   ----------
   -- Name --
   ----------

   function Name
     (Evnt : Event)
     return Var_Strings.Var_String
   is
   begin
      return Evnt.Name;
   end Name;

   ----------
   -- Name --
   ----------

   function Name
     (Evnt_Ref : Event_Ref)
     return Var_Strings.Var_String
   is
   begin
      return Evnt_Ref.Name;
   end Name;

   ----------
   -- Name --
   ----------

   function Name
     (Evnt_Ref : External_Event_Ref)
     return Var_Strings.Var_String
   is
   begin
      return Evnt_Ref.Name;
   end Name;

   ------------
   -- Period --
   ------------

   function Period
     (Evnt : Periodic_Event)
     return Time
   is
   begin
      return Evnt.Period;
   end Period;

   -----------
   -- Phase --
   -----------

   function Phase
     (Evnt : Periodic_Event)
     return Absolute_Time
   is
   begin
      return Evnt.Phase;
   end Phase;

   -----------
   -- Phase --
   -----------

   function Phase
     (Evnt : Singular_Event)
     return Absolute_Time
   is
   begin
      return Evnt.Phase;
   end Phase;

   ----------------------
   -- Print            --
   ----------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Internal_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant :=4;
   begin
      MAST.IO.Print_Arg(File,"Type","Regular",Indentation,
                        Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Evnt.Name),Indentation,Names_Length);
   end Print;

   ----------------------
   -- Print            --
   ----------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Periodic_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant :=10;
   begin
      MAST.IO.Print_Arg
        (File,"Type",
         "Periodic",Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Evnt.Name),Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Period",
         IO.Time_Image(Evnt.Period),Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Max_Jitter",
         IO.Time_Image(Evnt.Max_Jitter),Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Phase",
         IO.Time_Image(Time(Evnt.Phase)),Indentation,Names_Length);
   end Print;

   ----------------------
   -- Print            --
   ----------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Singular_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant :=5;
   begin
      MAST.IO.Print_Arg
        (File,"Type",
         "Singular",Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Evnt.Name),Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Phase",
         IO.Time_Image(Time(Evnt.Phase)),Indentation,Names_Length);
   end Print;

   ----------------------
   -- Print            --
   ----------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Sporadic_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant :=16;
   begin
      MAST.IO.Print_Arg
        (File,"Type",
         "Sporadic",Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Evnt.Name),Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Avg_Interarrival",
         IO.Time_Image(Evnt.Avg_Interarrival),Indentation,
         Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Distribution",
         Distribution_Function'Image(Evnt.Distribution),
         Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Min_Interarrival",
         IO.Time_Image(Evnt.Min_Interarrival),
         Indentation,Names_Length);
   end Print;

   ----------------------
   -- Print            --
   ----------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Unbounded_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant :=16;
   begin
      MAST.IO.Print_Arg
        (File,"Type",
         "Unbounded",Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Evnt.Name),Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Avg_Interarrival",
         IO.Time_Image(Evnt.Avg_Interarrival),Indentation,
         Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Distribution",
         Distribution_Function'Image(Evnt.Distribution),
         Indentation,Names_Length);
   end Print;

   ----------------------
   -- Print            --
   ----------------------

   procedure Print
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Bursty_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
      Names_Length : constant :=16;
   begin
      MAST.IO.Print_Arg
        (File,"Type",
         "Bursty",Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Name",
         IO.Name_Image(Evnt.Name),Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Avg_Interarrival",
         IO.Time_Image(Evnt.Avg_Interarrival),Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Distribution",
         Distribution_Function'Image(Evnt.Distribution),
         Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Bound_Interval",
         IO.Time_Image(Evnt.Bound_Interval),Indentation,Names_Length);
      MAST.IO.Print_Separator(File);
      MAST.IO.Print_Arg
        (File,"Max_Arrivals",
         Positive'Image(Evnt.Max_Arrivals),
         Indentation,Names_Length);
   end Print;

   ----------------------
   -- Print_XML        --
   ----------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Internal_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_IO.Put
        (File,"<mast_mdl:Regular_Event Event=""" &
         IO.Name_Image(Evnt.Name) & """ >");
   end Print_XML;

   ----------------------
   -- Print_XML        --
   ----------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Periodic_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is

   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put
        (File,"<mast_mdl:Periodic_External_Event Name=""" &
         Io.Name_Image(Evnt.Name) & """ ");
      Ada.Text_Io.Put(File,"Period=""" & IO.Time_Image(Evnt.Period) & """ ");
      Ada.Text_Io.Put
        (File,"Max_Jitter=""" & IO.Time_Image(Evnt.Max_Jitter) & """ ");
      Ada.Text_Io.Put_Line
        (File,"Phase=""" & Io.Time_Image(Time(Evnt.Phase)) & """ />");
   end Print_XML;

   ----------------------
   -- Print_XML        --
   ----------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Singular_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put
        (File,"<mast_mdl:Singular_External_Event Name=""" &
         Io.Name_Image(Evnt.Name) & """ ");
      Ada.Text_Io.Put_Line
        (File,"Phase=""" & Io.Time_Image(Time(Evnt.Phase)) & """ />");
   end Print_XML;

   ----------------------
   -- Print_XML        --
   ----------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Sporadic_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put
        (File,"<mast_mdl:Sporadic_External_Event Name=""" &
         Io.Name_Image(Evnt.Name) & """ ");
      Ada.Text_Io.Put
        (File,"Avg_Interarrival=""" &
         IO.Time_Image(Evnt.Avg_Interarrival) & """ ");
      Ada.Text_Io.Put
        (File,"Distribution=""" &
         IO.XML_Enum_Image
         (Distribution_Function'Image(Evnt.Distribution)) & """ ");
      Ada.Text_Io.Put_Line
        (File,"Min_Interarrival=""" &
         IO.Time_Image(Evnt.Min_Interarrival) & """ />");
   end Print_XML;

   ----------------------
   -- Print_XML        --
   ----------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Unbounded_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put
        (File,"<mast_mdl:Unbounded_External_Event Name=""" &
         Io.Name_Image(Evnt.Name) & """ ");
      Ada.Text_Io.Put
        (File,"Avg_Interarrival=""" &
         IO.Time_Image(Evnt.Avg_Interarrival) & """ ");
      Ada.Text_Io.Put_Line
        (File,"Distribution=""" &
         IO.XML_Enum_Image
         (Distribution_Function'Image(Evnt.Distribution)) & """ />");
   end Print_XML;

   ----------------------
   -- Print_XML        --
   ----------------------

   procedure Print_XML
     (File : Ada.Text_IO.File_Type;
      Evnt : in out Bursty_Event;
      Indentation : Positive;
      Finalize    : Boolean:=False)
   is
   begin
      Ada.Text_IO.Set_Col(File,Ada.Text_IO.Count(Indentation));
      Ada.Text_Io.Put
        (File,"<mast_mdl:Bursty_External_Event Name=""" &
         Io.Name_Image(Evnt.Name) & """ ");
      Ada.Text_Io.Put
        (File,"Avg_Interarrival=""" &
         IO.Time_Image(Evnt.Avg_Interarrival) & """ ");
      Ada.Text_Io.Put
        (File,"Distribution=""" &
         IO.XML_Enum_Image
         (Distribution_Function'Image(Evnt.Distribution)) & """ ");
      Ada.Text_Io.Put
        (File,"Bound_Interval=""" &
         IO.Time_Image(Evnt.Bound_Interval) & """ ");
      Ada.Text_Io.Put_Line
        (File,"Max_Arrivals=""" &
         IO.Integer_Image(Evnt.Max_Arrivals) & """ />");
   end Print_XML;

   --------------------------
   -- Set_Avg_Interarrival --
   --------------------------

   procedure Set_Avg_Interarrival
     (Evnt : in out Aperiodic_Event;
      The_Avg_Interarrival : Time)
   is
   begin
      Evnt.Avg_Interarrival:=The_Avg_Interarrival;
   end Set_Avg_Interarrival;

   ------------------------
   -- Set_Bound_Interval --
   ------------------------

   procedure Set_Bound_Interval
     (Evnt : in out Bursty_Event;
      The_Bound_Interval : Time)
   is
   begin
      Evnt.Bound_Interval:=The_Bound_Interval;
   end Set_Bound_Interval;

   ----------------------
   -- Set_Distribution --
   ----------------------

   procedure Set_Distribution
     (Evnt : in out Aperiodic_Event;
      The_Distribution : Distribution_Function)
   is
   begin
      Evnt.Distribution:=The_Distribution;
   end Set_Distribution;

   ----------------------
   -- Set_Max_Arrivals --
   ----------------------

   procedure Set_Max_Arrivals
     (Evnt : in out Bursty_Event;
      The_Max_Arrivals : Positive)
   is
   begin
      Evnt.Max_Arrivals:=The_Max_Arrivals;
   end Set_Max_Arrivals;

   --------------------
   -- Set_Max_Jitter --
   --------------------

   procedure Set_Max_Jitter
     (Evnt : in out Periodic_Event;
      The_Jitter : Time)
   is
   begin
      Evnt.Max_Jitter:=The_Jitter;
   end Set_Max_Jitter;

   --------------------------
   -- Set_Min_Interarrival --
   --------------------------

   procedure Set_Min_Interarrival
     (Evnt : in out Sporadic_Event;
      The_Min_Interarrival : Time)
   is
   begin
      Evnt.Min_Interarrival:=The_Min_Interarrival;
   end Set_Min_Interarrival;

   ----------------
   -- Set_Period --
   ----------------

   procedure Set_Period
     (Evnt : in out Periodic_Event;
      The_Period : Time)
   is
   begin
      Evnt.Period:=The_Period;
   end Set_Period;

   ---------------
   -- Set_Phase --
   ---------------

   procedure Set_Phase
     (Evnt : in out Periodic_Event;
      The_Phase : Absolute_Time)
   is
   begin
      Evnt.Phase:=The_Phase;
   end Set_Phase;

   ---------------
   -- Set_Phase --
   ---------------

   procedure Set_Phase
     (Evnt : in out Singular_Event;
      The_Phase : Absolute_Time)
   is
   begin
      Evnt.Phase:=The_Phase;
   end Set_Phase;

end MAST.Events;
