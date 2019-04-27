with Gtk.Arguments;
with Gtk.Widget; use Gtk.Widget;

package Gmast_Results_Pkg.Callbacks is
   function On_Gmast_Results_Delete_Event
     (Object : access Gtk_Widget_Record'Class;
      Params : Gtk.Arguments.Gtk_Args) return Boolean;

   procedure On_System_Open_Activate
     (Object : access Gtk_Image_Menu_Item_Record'Class);

   procedure On_System_Save_As_Activate
     (Object : access Gtk_Image_Menu_Item_Record'Class);

   procedure On_Exit1_Activate
     (Object : access Gtk_Image_Menu_Item_Record'Class);

   procedure On_Results_Open_Activate
     (Object : access Gtk_Image_Menu_Item_Record'Class);

   procedure On_Results_Save_As_Activate
     (Object : access Gtk_Image_Menu_Item_Record'Class);

   procedure On_Contents_Activate
     (Object : access Gtk_Image_Menu_Item_Record'Class);

   procedure On_About_Activate
     (Object : access Gtk_Image_Menu_Item_Record'Class);

   procedure On_Clist_Transactions_Select_Row
     (Object : access Gtk_Clist_Record'Class;
      Params : Gtk.Arguments.Gtk_Args);

   procedure On_Clist_Transactions_Click_Column
     (Object : access Gtk_Clist_Record'Class;
      Params : Gtk.Arguments.Gtk_Args);

end Gmast_Results_Pkg.Callbacks;
