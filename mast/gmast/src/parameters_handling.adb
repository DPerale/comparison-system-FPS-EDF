with System; use System;
with Glib; use Glib;
with Gdk.Event; use Gdk.Event;
with Gdk.Types; use Gdk.Types;
with Gtk.Accel_Group; use Gtk.Accel_Group;
with Gtk.Object; use Gtk.Object;
with Gtk.Enums; use Gtk.Enums;
with Gtk.Style; use Gtk.Style;
with Gtk.Widget; use Gtk.Widget;
with Gtk.GEntry; use Gtk.GEntry;
with Annealing_Window_Pkg;
use  Annealing_Window_Pkg;
with HOPA_Window_Pkg;
use HOPA_Window_Pkg;
with Var_Strings; use Var_Strings;
with Ada.Strings,Ada.Strings.Fixed,
     Ada.Characters.Handling,Ada.Float_Text_IO;
use  Ada.Strings,Ada.Strings.Fixed,Ada.Characters.Handling;

package body Parameters_Handling is

   -----------------
   -- Float_Image --
   -----------------

   function Float_Image(X : Float) return String is
      Str : String(1..60);
   begin
      if abs(X)>=1.0E12 then
         Ada.Float_Text_IO.Put(Str,X,3);
      elsif abs(X)>=1000.0 then
         Ada.Float_Text_IO.Put(Str,X,1,0);
      elsif abs(X)>=1.0 then
         Ada.Float_Text_IO.Put(Str,X,2,0);
      elsif abs(X)>=0.001 then
         Ada.Float_Text_IO.Put(Str,X,6,0);
      elsif abs(X)=0.0 then
         Ada.Float_Text_IO.Put(Str,X,2,0);
      else
         Ada.Float_Text_IO.Put(Str,X,3);
      end if;
      return Trim(Str,Both);
   end Float_Image;


   --------------------
   -- Load_Annealing --
   --------------------

   procedure Load_Annealing is
   begin
      Set_Text(Annealing_Window.Entry_Max_Iterations,
               Mast.Annealing_Parameters.Iteration_Type'Image
                  (Mast.Annealing_Parameters.Get_Max_Iterations));
      Set_Text(Annealing_Window.Entry_Iterations_To_Op,
               Mast.Annealing_Parameters.Iteration_Type'Image
                  (Mast.Annealing_Parameters.Get_Overiterations));
      Set_Text(Annealing_Window.Entry_Stop_Analysis,
               Duration'Image
                  (Mast.Annealing_Parameters.Get_Analysis_Stop_Time));
      Set_Text(Annealing_Window.Entry_Stop_Audsley,
               Duration'Image
                  (Mast.Annealing_Parameters.Get_Audsley_Stop_Time));
   end Load_Annealing;

   ---------------
   -- Load_Hopa --
   ---------------

   procedure Load_Hopa is
      Kr_List, Ka_List, Iter_List : Var_String;
      Pair : Mast.Hopa_Parameters.K_Pair;
   begin
      Mast.Hopa_Parameters.Rewind_K_List;
      for I in 1..Mast.Hopa_Parameters.Size_Of_K_List loop
         if I=1 then
            Ka_List:=To_Var_String("(");
            Kr_List:=To_Var_String("(");
         else
            Ka_List:=Ka_List&",";
            Kr_List:=Kr_List&",";
         end if;
         Pair:=Mast.Hopa_Parameters.Get_Next_K_Pair;
         Ka_List:=Ka_List&Float_Image
           (Mast.Hopa_Parameters.Get_Ka(Pair));
         Kr_List:=Kr_List&Float_Image
           (Mast.Hopa_Parameters.Get_Kr(Pair));
      end loop;
      Ka_List:=Ka_List&")";
      Kr_List:=Kr_List&")";
      Set_Text(HOPA_Window.Kr_Entry,To_String(Kr_List));
      Set_Text(HOPA_Window.Ka_Entry,To_String(Ka_List));

      Mast.Hopa_Parameters.Rewind_Iterations_List;
      for I in 1..Mast.Hopa_Parameters.Size_Of_Iterations_List loop
         if I=1 then
            Iter_List:=To_Var_String("(");
         else
            Iter_List:=Iter_List&",";
         end if;
         Iter_List:=Iter_List&Mast.Hopa_Parameters.Iteration_Type'Image
           (Mast.Hopa_Parameters.Get_Next_Iterations);
      end loop;
      Iter_List:=Iter_List&")";
      Set_Text(HOPA_Window.Iter_List_Entry,To_String(Iter_List));

      Set_Text(HOPA_Window.Opiter_Entry,
               Mast.HOPA_Parameters.Iteration_Type'Image
                  (Mast.HOPA_Parameters.Get_Overiterations));
      Set_Text(HOPA_Window.Entry_H_Stop_Analysis,
               Duration'Image
                  (Mast.HOPA_Parameters.Get_Analysis_Stop_Time));
      Set_Text(HOPA_Window.Entry_H_Stop_Audsley,
               Duration'Image
                  (Mast.HOPA_Parameters.Get_Audsley_Stop_Time));
   end Load_Hopa;

end Parameters_Handling;

