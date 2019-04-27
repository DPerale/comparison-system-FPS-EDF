with System; use System;
with Glib; use Glib;
with Gdk.Event; use Gdk.Event;
with Gdk.Types; use Gdk.Types;
with Gtk.Accel_Group; use Gtk.Accel_Group;
with Gtk.Object; use Gtk.Object;
with Gtk.Enums; use Gtk.Enums;
with Gtk.Style; use Gtk.Style;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Clist; use Gtk.Clist;
with Gtk.Combo; use Gtk.Combo;
with Gtk.Main;
with Mast_Actions;
with Mast.Transactions;
with Fileselection_System_Pkg; use Fileselection_System_Pkg;
with Fileselection_Savesystem_Pkg; use Fileselection_Savesystem_Pkg;
with Error_Window_Pkg; use Error_Window_Pkg;
with Fileselection_Results_Pkg; use Fileselection_Results_Pkg;
with Fileselection_Saveresults_Pkg; use Fileselection_Saveresults_Pkg;
with Dialog_Event_Pkg; use Dialog_Event_Pkg;
with Draw_Timing_Results;
with Clear_Timing_Results;
with Resize_Timing_Results;
with Ada.Text_IO; use Ada.Text_IO;
with Var_Strings; use Var_Strings;

package body Gmast_Results_Pkg.Callbacks is

   use Gtk.Arguments;

   -----------------------------------
   -- On_Gmast_Results_Delete_Event --
   -----------------------------------

   function On_Gmast_Results_Delete_Event
     (Object : access Gtk_Widget_Record'Class;
      Params : Gtk.Arguments.Gtk_Args) return Boolean
   is
      Arg1 : Gdk_Event := To_Event (Params, 1);
   begin
      Gtk.Main.Gtk_Exit(1);
      return False;
   end On_Gmast_Results_Delete_Event;

   -----------------------------
   -- On_System_Open_Activate --
   -----------------------------

   procedure On_System_Open_Activate
     (Object : access Gtk_Image_Menu_Item_Record'Class)
   is
   begin
      Gtk_New(Fileselection_System);
      if Mast_Actions.Has_System then
         Set_Filename(Fileselection_System,Mast_Actions.Name_Of_System);
      end if;
      Show_All(Fileselection_System);
   end On_System_Open_Activate;

   --------------------------------
   -- On_System_Save_As_Activate --
   --------------------------------

   procedure On_System_Save_As_Activate
     (Object : access Gtk_Image_Menu_Item_Record'Class)
   is
   begin
      declare
         Name : String:=Mast_Actions.Name_Of_System;
      begin
         Gtk_New(Fileselection_Savesystem);
         Set_Filename(Fileselection_Savesystem,Name&".bak");
         Show_All(Fileselection_Savesystem);
      end;
   exception
      when Mast_Actions.No_System =>
         Gtk_New (Error_Window);
         Set_Position(Error_Window,Win_Pos_Mouse);
         Set_Text(Error_Window.Label_Error,"No opened system");
         Set_Modal(Error_Window,True);
         Show_All (Error_Window);
   end On_System_Save_As_Activate;

   -----------------------
   -- On_Exit1_Activate --
   -----------------------

   procedure On_Exit1_Activate
     (Object : access Gtk_Image_Menu_Item_Record'Class)
   is
   begin
      Gtk.Main.Gtk_Exit(0);
   end On_Exit1_Activate;

   ------------------------------
   -- On_Results_Open_Activate --
   ------------------------------

   procedure On_Results_Open_Activate
     (Object : access Gtk_Image_Menu_Item_Record'Class)
   is
   begin
      Gtk_New(Fileselection_Results);
      if Mast_Actions.Has_Results then
         Set_Filename(Fileselection_Results,Mast_Actions.Name_Of_Results);
      end if;
      Show_All(Fileselection_Results);
   end On_Results_Open_Activate;

   ---------------------------------
   -- On_Results_Save_As_Activate --
   ---------------------------------

   procedure On_Results_Save_As_Activate
     (Object : access Gtk_Image_Menu_Item_Record'Class)
   is
   begin
      declare
         Name : String:=Mast_Actions.Name_Of_Results;
      begin
         Gtk_New(Fileselection_Saveresults);
         Set_Filename(Fileselection_Saveresults,Name&".bak");
         Show_All(Fileselection_Saveresults);
      end;
   end On_Results_Save_As_Activate;

   --------------------------
   -- On_Contents_Activate --
   --------------------------

   procedure On_Contents_Activate
     (Object : access Gtk_Image_Menu_Item_Record'Class)
   is
   begin
      null;
   end On_Contents_Activate;

   -----------------------
   -- On_About_Activate --
   -----------------------

   procedure On_About_Activate
     (Object : access Gtk_Image_Menu_Item_Record'Class)
   is
   begin
      null;
   end On_About_Activate;

   ----------------------
   -- Create dialog event
   ----------------------

   procedure Create_Dialog_Event(Trans_Name : String) is
      Trans_Ref : Mast.Transactions.Transaction_Ref;
      Iterator : Mast.Transactions.Lists.Index;
      Items : String_List.Glist;
   begin
      Gtk_New(Dialog_Event);
      Mast.Transactions.Lists.Rewind
        (Mast_Actions.The_System.Transactions,Iterator);
      for I in 1..Mast.Transactions.Lists.Size
        (Mast_Actions.The_System.Transactions)
      loop
         Mast.Transactions.Lists.Get_Next_Item
           (Trans_Ref,Mast_Actions.The_System.Transactions,Iterator);
         String_List.Append (Items, To_String
                             (Mast.Transactions.Name(Trans_Ref)));
      end loop;
      Set_Popdown_Strings (Dialog_Event.Combo_Tr_Transaction, Items);
      Set_Text(Dialog_Event.Entry_Tr_Transaction,Trans_Name);
      Show_All(Dialog_Event);
      Resize_Timing_Results;
   end Create_Dialog_Event;

   --------------------------------------
   -- On_Clist_Transactions_Select_Row --
   --------------------------------------

   procedure On_Clist_Transactions_Select_Row
     (Object : access Gtk_Clist_Record'Class;
      Params : Gtk.Arguments.Gtk_Args)
   is
      Arg1 : Gint := To_Gint (Params, 1);
      Arg2 : Gint := To_Gint (Params, 2);
      Arg3 : Gdk_Event := To_Event (Params, 3);
      Row : Gint:=Arg1;
      Col : Gint:=Arg2;
   begin
      if Col=3 then
         Create_Dialog_Event(Get_Text(Gmast_Results.Clist_Transactions,Row,0));
      end if;
   end On_Clist_Transactions_Select_Row;

   ----------------------------------------
   -- On_Clist_Transactions_Click_Column --
   ----------------------------------------

   procedure On_Clist_Transactions_Click_Column
     (Object : access Gtk_Clist_Record'Class;
      Params : Gtk.Arguments.Gtk_Args)
   is
      Arg1 : Gint := To_Gint (Params, 1);
   begin
      if Arg1=3 then
         Create_Dialog_Event("");
      end if;
   end On_Clist_Transactions_Click_Column;

end Gmast_Results_Pkg.Callbacks;
