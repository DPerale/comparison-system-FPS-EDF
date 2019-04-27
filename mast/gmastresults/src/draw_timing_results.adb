with Gtk.Clist; use Gtk.Clist;
with Gtk.Gentry; use Gtk.Gentry;
with Gdk.Color; use Gdk.Color;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Style; use Gtk.Style;
with Gtk.Enums; use Gtk.Enums;
with Gtk.Pixmap; use Gtk.Pixmap;
with Gtk.Scrolled_Window;use Gtk.Scrolled_Window;
with Glib; use Glib;
with Gtkada.Types; use Gtkada.Types;
with Dialog_Event_Pkg; use Dialog_Event_Pkg;
with Mast;
with Mast.Transactions;
with Mast.Graphs;
with Mast.Graphs.Links;
with Mast.Timing_Requirements;
with Mast.Results;
with Mast.Events;
with Mast.IO;
with Mast_Actions;
with Resize_Timing_Results;
with Var_Strings; use Var_Strings;
with Interfaces.C.Strings;
with Interfaces.C;
with List_Exceptions;
with Gtk.Notebook;use Gtk.Notebook;

with Ada.Text_IO;

procedure Draw_Timing_Results (Trans_Name : String) is

   Trans_Ref : Mast.Transactions.Transaction_Ref;
   Trans_Index : Mast.Transactions.Lists.Index;
   Evnt_Iterator : Mast.Transactions.Link_Iteration_Object;
   Link_Ref : Mast.Graphs.Link_Ref;
   Timing_Req : Mast.Timing_Requirements.Timing_Requirement_Ref;
   Res_Ref : Mast.Results.Timing_Result_Ref;
   Time_Iterator : Mast.Results.Time_Iteration_Object;

   package ICS renames Interfaces.C.Strings;
   package IC renames Interfaces.C;

   use type IC.Size_T;
   use type Mast.Results.Timing_Result_Ref;
   use type Mast.Timing_Requirements.Timing_Requirement_Ref;
   use type Mast.Time;

   subtype Byte is Integer range 0..255;

   function Color_Of (R,G,B : Byte) return Gdk_Color is
      Color   : Gdk_Color;
      Success : Boolean;
   begin
      Color:=Gdk.Color.Parse("Blue");
      Set_RGB(Color,Glib.Guint16(R*256),Glib.Guint16(G*256),
              Glib.Guint16(B*256));
      Alloc_Color (Colormap   => Gtk.Widget.Get_Default_Colormap,
                   Color      => Color,
                   Writeable  => False,
                   Best_Match => True,
                   Success    => Success);
      return Color;
   end Color_Of;

   Style : Gtk_Style:=Get_Style(Dialog_Event.Clist_Global_Rt);

   function Style_Of (OK : Boolean) return Gtk_Style is
      Style1 : Gtk_Style:=Copy(Style);
   begin
      if OK then
         Set_Base(Style1,State_Normal,Color_Of(60,200,60));
      else
         Set_Base(Style1,State_Normal,Color_Of(200,60,60));
      end if;
      return Style1;
   end Style_Of;

begin
   Trans_Index:=Mast.Transactions.Lists.Find
     (To_Var_String(Trans_Name),Mast_Actions.The_System.Transactions);
   Trans_Ref:=Mast.Transactions.Lists.Item
     (Trans_Index,Mast_Actions.The_System.Transactions);
   Mast.Transactions.Rewind_Internal_Event_Links
     (Trans_Ref.all,Evnt_Iterator);
   for I in 1..Mast.Transactions.Num_Of_Internal_Event_Links(Trans_Ref.all)
   loop
      Mast.Transactions.Get_Next_Internal_Event_Link
        (Trans_Ref.all,Link_Ref,Evnt_Iterator);
      Timing_Req:=Mast.Graphs.Links.Link_Timing_Requirements
        (Mast.Graphs.Links.Regular_Link(Link_Ref.all));
      Res_Ref:=Mast.Graphs.Links.Link_Time_Results
        (Mast.Graphs.Links.Regular_Link(Link_Ref.all));
      if Res_Ref/=null then
         -- Global response times:
         --   event, referenced_event, best,worst, deadline
         declare
            Columns : Gint:=Get_Columns
              (Dialog_Event.Clist_Global_Rt);
            Texts : Chars_Ptr_Array (0 .. IC.Size_T(Columns)-1):=
              (others => ICS.New_String(""));
            Row : Gint;
            GE_Ref : Mast.Events.Event_Ref;
            Params : Mast.Results.Timing_Parameters;
            Dline : Mast.Time;
            Is_Present,OK : Boolean;
         begin
            Texts(0):=ICS.New_String (Trans_Name);
            Texts(1):=ICS.New_String
              (To_String(Mast.Graphs.Name(Link_Ref)));
            -- iterate through global timing requirements
            Mast.Results.Rewind_Global_Timing_Parameters
              (Res_Ref.all,Time_Iterator);
            for J in 1..Mast.Results.Num_Of_Global_Timing_Parameters
              (Res_Ref.all)
            loop
               Mast.Results.Get_Next_Global_Timing_Parameters
                 (Res_Ref.all,GE_Ref,Params,Time_Iterator);
               Texts(2):=ICS.New_String
                 (To_String(Mast.Events.Name(GE_Ref)));
               Texts(3):=ICS.New_String
                 (Mast.IO.Time_Image(Params.Best_Response_Time));
               Row:=Append(Dialog_Event.Clist_Global_Rt,Texts);
               Set_Text (Dialog_Event.Clist_Global_Rt,
                         Row,5,Mast.IO.Time_Image(Params.Worst_Response_Time));
               Is_Present:=False;
               if Res_Ref.all in Mast.Results.Simulation_Timing_Result
               then
                  Set_Text
                    (Dialog_Event.Clist_Global_Rt,
                     Row,4,Mast.IO.Time_Image
                     (Mast.Results.Avg_Global_Response_Time
                      (Mast.Results.Simulation_Timing_Result(REs_Ref.all),
                       GE_Ref)));
               else
                  Set_Column_Visibility
                    (Dialog_Event.Clist_Global_Rt,4,False);
               end if;

               if Timing_Req/=null then
                  if Timing_Req.all in
                    Mast.Timing_Requirements.Hard_Global_Deadline'Class
                  then
                     Dline:=Mast.Timing_Requirements.The_Deadline
                       (Mast.Timing_Requirements.Deadline(Timing_Req.all));
                     Set_Text (Dialog_Event.Clist_Global_Rt,
                               Row,6,Mast.IO.Time_Image
                               (Dline));
                     Is_Present:=True;
                  elsif Timing_Req.all in
                    Mast.Timing_Requirements.Composite_Timing_Req'Class
                  then
                     Mast.Timing_Requirements.Find_Hard_Global_Deadline
                       (Mast.Timing_Requirements.Composite_Timing_Req
                        (Timing_Req.all),GE_Ref,Dline,Is_Present);
                     if Is_Present then
                        Set_Text (Dialog_Event.Clist_Global_Rt,
                                  Row,6,Mast.IO.Time_Image(Dline));
                     end if;
                  end if;
               end if;
               if Is_Present then
                  OK:=Params.Worst_Response_Time<=Dline;
                  Set_Cell_Style (Dialog_Event.Clist_Global_Rt,
                                  Row,5,Style_Of(OK));
               end if;
            end loop;
         end;

         -- Output jitters:
         --   event, referenced_event, jitter, req
         declare
            Columns : Gint:=Get_Columns
              (Dialog_Event.Clist_Jitters);
            Texts : Chars_Ptr_Array (0 .. IC.Size_T(Columns)-1):=
              (others => ICS.New_String(""));
            Row : Gint;
            GE_Ref : Mast.Events.Event_Ref;
            Params : Mast.Results.Timing_Parameters;
            Jitter_Req: Mast.Time;
            Is_Present,OK : Boolean;
         begin
            Texts(0):=ICS.New_String (Trans_Name);
            Texts(1):=ICS.New_String
              (To_String(Mast.Graphs.Name(Link_Ref)));
            -- iterate through global timing requirements
            Mast.Results.Rewind_Global_Timing_Parameters
              (Res_Ref.all,Time_Iterator);

            for J in 1..Mast.Results.Num_Of_Global_Timing_Parameters
              (Res_Ref.all)
            loop

               Mast.Results.Get_Next_Global_Timing_Parameters
                 (Res_Ref.all,GE_Ref,Params,Time_Iterator);

               Texts(2):=ICS.New_String
                 (To_String(Mast.Events.Name(GE_Ref)));
               Row:=Append(Dialog_Event.Clist_Jitters,Texts);
               Set_Text (Dialog_Event.Clist_Jitters,
                         Row,3,Mast.IO.Time_Image(Params.Jitter));
               Is_Present:=False;
               if Timing_Req/=null then
                  if Timing_Req.all in
                    Mast.Timing_Requirements.Max_Output_Jitter_Req'Class
                  then
                     Jitter_Req:=Mast.Timing_Requirements.Max_Output_Jitter
                       (Mast.Timing_Requirements.Max_Output_Jitter_Req
                        (Timing_Req.all));
                     Set_Text (Dialog_Event.Clist_Jitters,
                               Row,4,Mast.IO.Time_Image
                               (Jitter_Req));
                     Is_Present:=True;
                  elsif Timing_Req.all in
                    Mast.Timing_Requirements.Composite_Timing_Req'Class
                  then
                     Mast.Timing_Requirements.Find_Max_Output_Jitter_Req
                       (Mast.Timing_Requirements.Composite_Timing_Req
                        (Timing_Req.all),GE_Ref, Jitter_Req,Is_Present);
                     if Is_Present then
                        Set_Text (Dialog_Event.Clist_Jitters,
                                  Row,4,Mast.IO.Time_Image(Jitter_Req));
                     end if;
                  end if;
               end if;
               if Is_Present then
                  OK:=Params.Jitter<=Jitter_Req;
                  Set_Cell_Style (Dialog_Event.Clist_Jitters,
                                  Row,3,Style_Of(OK));
               end if;
            end loop;
         end;

         -- Blocking Times:
         --   event, blocking, num_of_suspensions
         declare
            Columns : Gint:=Get_Columns
              (Dialog_Event.Clist_Blocking);
            Texts : Chars_Ptr_Array (0 .. IC.Size_T(Columns)-1):=
              (others => ICS.New_String(""));
            Row : Gint;
            Blocking : Mast.Time;
            Num_Susp : Natural;
         begin
            Texts(0):=ICS.New_String (Trans_Name);
            Texts(1):=ICS.New_String
              (To_String(Mast.Graphs.Name(Link_Ref)));
            Blocking:=Mast.Results.Worst_Blocking_Time(Res_Ref.all);
            Num_Susp:=Mast.Results.Num_Of_Suspensions(Res_Ref.all);
            Texts(3):=ICS.New_String
              (Mast.Io.Time_Image(Blocking));
            Texts(4):=ICS.New_String
              (Integer'Image(Num_Susp));
            Row:=Append(Dialog_Event.Clist_Blocking,Texts);
            if Res_Ref.all in Mast.Results.Simulation_Timing_Result
            then
               Set_Text
                 (Dialog_Event.Clist_Blocking,
                  Row,2,Mast.IO.Time_Image
                  (Mast.Results.Avg_Blocking_Time
                   (Mast.Results.Simulation_Timing_Result(REs_Ref.all))));
               Set_Text
                 (Dialog_Event.Clist_Blocking,
                  Row,5,Mast.IO.Time_Image
                  (Mast.Results.Max_Preemption_Time
                   (Mast.Results.Simulation_Timing_Result(REs_Ref.all))));
            else
               Set_Column_Visibility
                 (Dialog_Event.Clist_Blocking,2,False);
               Set_Column_Visibility
                 (Dialog_Event.Clist_Blocking,5,False);


            end if;

         end;

         -- Local response times:
         --   event, best,worst, deadline
         declare
            Columns : Gint:=Get_Columns
              (Dialog_Event.Clist_Local_Rt);
            Texts : Chars_Ptr_Array (0 .. IC.Size_T(Columns)-1):=
              (others => ICS.New_String(""));
            Row : Gint;
            Worst_Resp, Best_Resp : Mast.Time;
            Dline : Mast.Time;
            Is_Present,OK : Boolean;
         begin
            Texts(0):=ICS.New_String (Trans_Name);
            Texts(1):=ICS.New_String
              (To_String(Mast.Graphs.Name(Link_Ref)));
            Worst_Resp:=Mast.Results.Worst_Local_Response_Time(Res_Ref.all);
            Best_Resp:=Mast.Results.Best_Local_Response_Time(Res_Ref.all);
            Row:=Append(Dialog_Event.Clist_Local_Rt,Texts);
            if Worst_Resp>0.0 then
               Set_Text (Dialog_Event.Clist_Local_Rt,
                         Row,2,Mast.IO.Time_Image(Best_Resp));
               Set_Text (Dialog_Event.Clist_Local_Rt,
                         Row,4,Mast.IO.Time_Image(Worst_Resp));
               Is_Present:=False;
               if Res_Ref.all in Mast.Results.Simulation_Timing_Result
               then
                  Set_Text
                    (Dialog_Event.Clist_Local_Rt,
                     Row,3,Mast.IO.Time_Image
                     (Mast.Results.Avg_Local_Response_Time
                      (Mast.Results.Simulation_Timing_Result(Res_Ref.all))));
               else
                  Set_Column_Visibility
                    (Dialog_Event.Clist_Local_Rt,3,False);
               end if;

               if Timing_Req/=null then
                  if Timing_Req.all in
                    Mast.Timing_Requirements.Hard_Local_Deadline'Class
                  then
                     Dline:=Mast.Timing_Requirements.The_Deadline
                       (Mast.Timing_Requirements.Deadline(Timing_Req.all));
                     Set_Text (Dialog_Event.Clist_Local_Rt,
                               Row,5,Mast.IO.Time_Image
                               (Dline));
                     Is_Present:=True;
                  elsif Timing_Req.all in
                    Mast.Timing_Requirements.Composite_Timing_Req'Class
                  then
                     Mast.Timing_Requirements.Find_Hard_Local_Deadline
                       (Mast.Timing_Requirements.Composite_Timing_Req
                        (Timing_Req.all),Dline,Is_Present);
                     if Is_Present then
                        Set_Text (Dialog_Event.Clist_Local_Rt,
                                  Row,5,Mast.IO.Time_Image(Dline));
                     end if;
                  end if;
               end if;
               if Is_Present then
                  OK:=Worst_Resp<=Dline;
                  Set_Cell_Style (Dialog_Event.Clist_Local_Rt,
                                  Row,4,Style_Of(OK));
               end if;
            end if;
         end;

         -- Suspensions :
         -- event, suspension time, queued activations
         -- Blocking Times:
         --   event, blocking, num_of_suspensions
         declare
            Columns : Gint:=Get_Columns
              (Dialog_Event.Clist_Suspensions);
            Texts : Chars_Ptr_Array (0 .. IC.Size_T(Columns)-1):=
              (others => ICS.New_String(""));
            Row : Gint;
         begin
            Texts(0):=ICS.New_String (Trans_Name);
            Texts(1):=ICS.New_String
              (To_String(Mast.Graphs.Name(Link_Ref)));
            Row:=Append(Dialog_Event.Clist_Suspensions,Texts);
            if Res_Ref.all in Mast.Results.Simulation_Timing_Result
            then
               Set_Text
                 (Dialog_Event.Clist_Suspensions,
                  Row,2,Mast.IO.Time_Image
                  (Mast.Results.Suspension_Time
                   (Mast.Results.Simulation_Timing_Result(REs_Ref.all))));
               Set_Text
                 (Dialog_Event.Clist_Suspensions,
                  Row,3,Natural'Image
                  (Mast.Results.Num_Of_Queued_Activations
                   (Mast.Results.Simulation_Timing_Result(REs_Ref.all))));
            else
               Set_Column_Visibility
                 (Dialog_Event.Clist_Suspensions,2,False);
               Set_Column_Visibility
                 (Dialog_Event.Clist_Suspensions,3,False);
            end if;
         end;

         -- Local_Miss_Ratios :
         -- event, deadline, ratio, required ratio

         declare
            procedure Set_Local_Miss_Ratio_Result
              (Req_Ref : Mast.Timing_Requirements.Local_Max_Miss_Ratio)
            is
               Columns : Gint:=Get_Columns
                 (Dialog_Event.Clist_Local_Miss_Ratios);
               Texts : Chars_Ptr_Array (0 .. IC.Size_T(Columns)-1):=
                 (others => ICS.New_String(""));
               Row : Gint;
               Ratio,Real_Ratio : MAst.Percentage;
               Dline: Mast.Time;
               OK : Boolean:=False;
            begin
               Texts(0):=ICS.New_String (Trans_Name);
               Texts(1):=ICS.New_String
                 (To_String(Mast.Graphs.Name(Link_Ref)));
               Row:=Append(Dialog_Event.Clist_Local_Miss_Ratios,Texts);

               Dline:=Mast.Timing_Requirements.The_Deadline
                 (Mast.Timing_Requirements.Deadline(Req_Ref));
               Set_Text (Dialog_Event.Clist_Local_Miss_Ratios,
                         Row,2,Mast.IO.Time_Image
                         (Dline));
               Ratio:=Mast.Timing_Requirements.Ratio
                 (Mast.Timing_Requirements.Local_Max_Miss_Ratio(Req_Ref));
               Set_Text (Dialog_Event.Clist_Local_Miss_Ratios,
                         Row,4,Mast.IO.Percentage_Image
                         (Ratio));
               Real_Ratio:=Mast.Results.Local_Miss_Ratio
                 (Mast.Results.Simulation_Timing_Result(Res_Ref.all),Dline);
               Set_Text (Dialog_Event.Clist_Local_Miss_Ratios,
                         Row,3,Mast.IO.Percentage_Image
                         (Real_Ratio));

               OK:= Real_Ratio < Ratio;
               Set_Cell_Style (Dialog_Event.Clist_Local_Miss_Ratios,
                               Row,3,Style_Of(OK));
            end Set_Local_Miss_Ratio_Result;

            Iterator : Mast.Timing_Requirements.Iteration_Object;
            Req_Ref : Mast.Timing_Requirements.Simple_Timing_Requirement_Ref;

         begin
            if Res_Ref.all in Mast.Results.Simulation_Timing_Result
            then
               Ada.Text_Io.Put_Line("es simulation timing result");
               if Timing_Req/=null
               then
                  if Timing_Req.all in
                    Mast.Timing_Requirements.Local_Max_Miss_Ratio'Class
                  then
                     Set_Local_Miss_Ratio_Result
                       (Mast.Timing_Requirements.Local_Max_Miss_Ratio
                        (Timing_Req.all));
                  elsif Timing_Req.all in
                    Mast.Timing_Requirements.Composite_Timing_Req'Class
                  then
                     Mast.Timing_Requirements.Rewind_Requirements
                       (Mast.Timing_Requirements.Composite_Timing_Req
                        (Timing_Req.all),Iterator);
                     for I in 1..Mast.Timing_Requirements.Num_Of_Requirements
                       (Mast.Timing_Requirements.Composite_Timing_Req
                        (Timing_Req.all))
                     loop
                        Mast.Timing_Requirements.Get_Next_Requirement
                          (Mast.Timing_Requirements.Composite_Timing_Req
                           (Timing_Req.all),Req_Ref,Iterator);
                        if Req_Ref.all in
                          Mast.Timing_Requirements.Local_Max_Miss_Ratio'Class
                        then
                           Set_Local_Miss_Ratio_Result
                             (Mast.Timing_Requirements.Local_Max_Miss_Ratio
                              (Req_Ref.all));
                        end if;
                     end loop;
                  end if;
               end if;
            end if;
         end;

         -- Global_Miss_Ratios :
         -- event, referenced event, deadline, ratio, required ratio

         declare
            procedure Set_Global_Miss_Ratio_Result
              (Timing_Req : Mast.Timing_Requirements.Global_Max_Miss_Ratio)
         is

               Columns : Gint:=Get_Columns
                 (Dialog_Event.Clist_Global_Miss_Ratios);
               Texts : Chars_Ptr_Array (0 .. IC.Size_T(Columns)-1):=
                 (others => ICS.New_String(""));
               Row : Gint;
               Ratio,Real_Ratio : MAst.Percentage;
               Dline: Mast.Time;
               Ev:MAst.Events.Event_Ref;
               OK : Boolean;

            begin
               Texts(0):=ICS.New_String (Trans_Name);
               Texts(1):=ICS.New_String
                 (To_String(Mast.Graphs.Name(Link_Ref)));
               Row:=Append(Dialog_Event.Clist_Global_Miss_Ratios,Texts);
               Ev :=Mast.Timing_Requirements.Event
                 (MASt.Timing_Requirements.Global_Deadline(Timing_Req));
               Set_Text (Dialog_Event.Clist_Global_Miss_Ratios,
                         Row,2,To_String(Mast.Events.Name(Ev)));
               Dline:=Mast.Timing_Requirements.The_Deadline
                 (Mast.Timing_Requirements.Deadline(Timing_Req));
               Set_Text (Dialog_Event.Clist_Global_Miss_Ratios,
                         Row,3,Mast.IO.Time_Image
                         (Dline));
               Ratio:=Mast.Timing_Requirements.Ratio
                 (Mast.Timing_Requirements.Global_Max_Miss_Ratio(Timing_Req));
               Set_Text (Dialog_Event.Clist_Global_Miss_Ratios,
                         Row,5,Mast.IO.Percentage_Image
                         (Ratio));
               Real_Ratio:=Mast.Results.Global_Miss_Ratio
                 (Mast.Results.Simulation_Timing_Result(Res_Ref.all),Dline,Ev);
               Set_Text (Dialog_Event.Clist_Global_Miss_Ratios,
                         Row,4,Mast.IO.Percentage_Image
                         (Real_Ratio));
               OK:= Real_Ratio<=Ratio;
               Set_Cell_Style (Dialog_Event.Clist_Global_Miss_Ratios,
                               Row,4,Style_Of(OK));
            end Set_Global_Miss_Ratio_Result;

            Iterator : Mast.Timing_Requirements.Iteration_Object;
            Req_Ref : Mast.Timing_Requirements.Simple_Timing_Requirement_Ref;

         begin
            if Res_Ref.all in Mast.Results.Simulation_Timing_Result
            then
               if Timing_Req/=null
               then
                  if Timing_Req.all in
                    Mast.Timing_Requirements.Global_Max_Miss_Ratio'Class
                  then
                     Set_Global_Miss_Ratio_Result
                       (Mast.Timing_Requirements.Global_Max_Miss_Ratio
                        (Timing_Req.all));
                  elsif Timing_Req.all in
                    Mast.Timing_Requirements.Composite_Timing_Req'Class
                  then
                     Mast.Timing_Requirements.Rewind_Requirements
                       (Mast.Timing_Requirements.Composite_Timing_Req
                        (Timing_Req.all),Iterator);

                     for I in 1..Mast.Timing_Requirements.Num_Of_Requirements
                       (Mast.Timing_Requirements.Composite_Timing_Req
                        (Timing_Req.all))
                     loop
                        Mast.Timing_Requirements.Get_Next_Requirement
                          (Mast.Timing_Requirements.Composite_Timing_Req
                           (Timing_Req.all), Req_Ref, Iterator);
                        if Req_Ref.all in
                          Mast.Timing_Requirements.Global_Max_Miss_Ratio'Class
                        then
                           Set_Global_Miss_Ratio_Result
                             (Mast.Timing_Requirements.Global_Max_Miss_Ratio
                              (Req_Ref.all));
                        end if;
                     end loop;
                  end if;
               end if;
            end if;
         end;
      end if;
   end loop;

   Resize_Timing_Results;
end Draw_Timing_Results;
