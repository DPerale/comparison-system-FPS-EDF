with System; use System;
with Glib; use Glib;
with Gdk.Event; use Gdk.Event;
with Gdk.Types; use Gdk.Types;
with Gtk.Accel_Group; use Gtk.Accel_Group;
with Gtk.Object; use Gtk.Object;
with Gtk.Enums; use Gtk.Enums;
with Gtk.Style; use Gtk.Style;
with Gtk.Widget; use Gtk.Widget;
with Error_Window_Pkg; use Error_Window_Pkg;
with Help_Annealing_Pkg; use Help_Annealing_Pkg;
with Mast.Annealing_Parameters;
with Mast.Priority_Assignment_Parameters;
with Parameters_Handling;

package body Annealing_Window_Pkg.Callbacks is

   use Gtk.Arguments;

   ---------------------------
   -- On_Set_Button_Clicked --
   ---------------------------

   procedure On_Set_Button_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
      type Check_State is (M_Iter, O_Iter, ST_Analysis, ST_Audsley);
   begin
      declare
         Max_Iter : String:=Get_Text(Annealing_Window.Entry_Max_Iterations);
         Max_Iterations : Mast.Annealing_Parameters.Iteration_Type;
         Over_Iter : String:=Get_Text(Annealing_Window.Entry_Iterations_To_Op);
         Overiterations : Mast.Annealing_Parameters.Iteration_Type;
         Stop_Analysis_Time_Str : String:=
           Get_Text(Annealing_Window.Entry_Stop_Analysis);
         Stop_Audsley_Time_Str : String:=
           Get_Text(Annealing_Window.Entry_Stop_Audsley);
         Stop_Analysis_Time, Stop_Audsley_Time : Duration;
         State : Check_State :=M_Iter;
      begin
         Max_Iterations:=Mast.Annealing_Parameters.Iteration_Type'Value
           (Max_Iter);
         State:=O_Iter;
         Overiterations:=Mast.Annealing_Parameters.Iteration_Type'Value
           (Over_Iter);
         State:=St_Analysis;
         Stop_Analysis_Time:=Duration'Value(Stop_Analysis_Time_Str);
         State:=St_Audsley;
         Stop_Audsley_Time:=Duration'Value(Stop_Audsley_Time_Str);
         Mast.Annealing_Parameters.Set_Max_Iterations(Max_Iterations);
         Mast.Annealing_Parameters.Set_Overiterations(Overiterations);
         Mast.Annealing_Parameters.Set_Analysis_Stop_Time(Stop_Analysis_Time);
         Mast.Annealing_Parameters.Set_Audsley_Stop_Time(Stop_Audsley_Time);
         Mast.Priority_Assignment_Parameters.Store_Parameters;
         Destroy(Annealing_Window);
      exception
         when Constraint_Error =>
            Gtk_New (Error_Window);
            Set_Position(Error_Window,Win_Pos_Mouse);
            Show_All (Error_Window);
            case State is
               when M_Iter =>
                  Set_Text(Error_Window.Label_Error,
                          "Format Error in Max Iterations");
               when O_Iter =>
                  Set_Text(Error_Window.Label_Error,
                           "Format Error in Optimization Iterations");
               when St_Analysis =>
                  Set_Text(Error_Window.Label_Error,
                           "Format Error in Analysis Stop Time");
               when St_Audsley =>
                  Set_Text(Error_Window.Label_Error,
                           "Format Error in Audsley Stop Time");
            end case;
            Set_Modal(Error_Window,True);
      end;
   end On_Set_Button_Clicked;

   -------------------------------
   -- On_Default_Button_Clicked --
   -------------------------------

   procedure On_Default_Button_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Mast.Annealing_Parameters.Load_Default_Parameters;
      Parameters_Handling.Load_Annealing;
   end On_Default_Button_Clicked;

   --------------------------------
   -- On_Ann_Help_Button_Clicked --
   --------------------------------

   procedure On_Ann_Help_Button_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Gtk_New (Help_Annealing);
      Show_All (Help_Annealing);
   end On_Ann_Help_Button_Clicked;

   ------------------------------
   -- On_Cancel_Button_Clicked --
   ------------------------------

   procedure On_Cancel_Button_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Destroy(Annealing_Window);
   end On_Cancel_Button_Clicked;

end Annealing_Window_Pkg.Callbacks;
