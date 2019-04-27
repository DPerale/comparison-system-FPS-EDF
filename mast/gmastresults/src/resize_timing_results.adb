with Glib; use Glib;
with Gtk.Clist; use Gtk.Clist;
with Dialog_Event_Pkg; use Dialog_Event_Pkg;

procedure Resize_Timing_Results is

   Width : Gint;

begin
   Width:=Columns_Autosize(Dialog_Event.Clist_Jitters);
   Width:=Columns_Autosize(Dialog_Event.Clist_Global_Rt);
   Width:=Columns_Autosize(Dialog_Event.Clist_Local_Rt);
   Width:=Columns_Autosize(Dialog_Event.Clist_Blocking);
   Width:=Columns_Autosize(Dialog_Event.Clist_Suspensions);
   Width:=Columns_Autosize(Dialog_Event.Clist_Local_Miss_Ratios);
   Width:=Columns_Autosize(Dialog_Event.Clist_Global_Miss_Ratios);

end Resize_Timing_Results;
