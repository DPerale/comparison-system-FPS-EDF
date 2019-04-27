with System; use System;
with Glib; use Glib;
with Gdk.Event; use Gdk.Event;
with Gdk.Types; use Gdk.Types;
with Gtk.Accel_Group; use Gtk.Accel_Group;
with Gtk.Object; use Gtk.Object;
with Gtk.Enums; use Gtk.Enums;
with Gtk.Style; use Gtk.Style;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Gentry; use Gtk.Gentry;
with Mast.Transactions;
with Mast_Actions;
with Draw_Timing_Results;
with Clear_Timing_Results;
with Var_Strings; use Var_Strings;

package body Dialog_Event_Pkg.Callbacks is

   use Gtk.Arguments;

   --------------------------------
   -- On_Button_Close_Tr_Clicked --
   --------------------------------

   procedure On_Button_Close_Tr_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Set_Modal(Dialog_Event,False);
      Destroy(Dialog_Event);
   end On_Button_Close_Tr_Clicked;

   -------------------------------------
   -- On_Entry_Tr_Transaction_Changed --
   -------------------------------------

   procedure On_Entry_Tr_Transaction_Changed
     (Object : access Gtk_Entry_Record'Class)
   is
      Trans_Ref : Mast.Transactions.Transaction_Ref;
      Iterator : Mast.Transactions.Lists.Index;
   begin
      Clear_Timing_Results;
      declare
         Trans_Name : String:=Get_Text(Dialog_Event.Entry_Tr_Transaction);
      begin
         if Trans_Name="" then
            Mast.Transactions.Lists.Rewind
              (Mast_Actions.The_System.Transactions,Iterator);
            for I in 1..Mast.Transactions.Lists.Size
              (Mast_Actions.The_System.Transactions)
            loop
               Mast.Transactions.Lists.Get_Next_Item
                 (Trans_Ref,Mast_Actions.The_System.Transactions,Iterator);
               Draw_Timing_Results
                 (To_String(Mast.Transactions.Name(Trans_Ref)));
            end loop;
         else
            Draw_Timing_Results(Get_Text(Dialog_Event.Entry_Tr_Transaction));
         end if;
      end;
   end On_Entry_Tr_Transaction_Changed;

   ---------------------------
   -- On_Button_All_Clicked --
   ---------------------------

   procedure On_Button_All_Clicked
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Set_Text(Dialog_Event.Entry_Tr_Transaction,"");
   end On_Button_All_Clicked;

end Dialog_Event_Pkg.Callbacks;
