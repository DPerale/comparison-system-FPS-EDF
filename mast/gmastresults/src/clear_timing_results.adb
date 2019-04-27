with Gtk.Clist; use Gtk.Clist;
with Dialog_Event_Pkg; use Dialog_Event_Pkg;

procedure Clear_Timing_Results is
begin
   Clear(Dialog_Event.Clist_Global_Rt);
   Clear(Dialog_Event.Clist_Jitters);
   Clear(Dialog_Event.Clist_Blocking);
   Clear(Dialog_Event.Clist_Local_Rt);
   Clear(Dialog_Event.Clist_Suspensions);
   Clear(Dialog_Event.Clist_Local_Miss_Ratios);
   Clear(Dialog_Event.Clist_Global_Miss_Ratios);
end Clear_Timing_Results;
