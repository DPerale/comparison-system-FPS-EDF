with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Text; use Gtk.Text;
with Gtk.Clist; use Gtk.Clist;
with Gmast_Results_Pkg; use Gmast_Results_Pkg;

procedure Clear_Results is

begin
   -- Clear windows
   Delete_Text(Gmast_Results.Entry_Model_Name);
   Delete_Text(Gmast_Results.Entry_Model_Date);
   Delete_Text(Gmast_Results.Entry_Generation_Tool);
   Delete_Text(Gmast_Results.Entry_Generation_Profile);
   Delete_Text(Gmast_Results.Entry_Generation_Date);
   Delete_Text(Gmast_Results.Text_System_Slack);

   Clear(Gmast_Results.Clist_Processing_Resources);
   Clear(Gmast_Results.Clist_Transactions);
   Clear(Gmast_Results.Clist_Shared_Resources);

end Clear_Results;
