with Gtk.Handlers;
pragma Elaborate_All (Gtk.Handlers);
with Gtk.Clist; use Gtk.Clist;
with Gtk.Image_Menu_Item; use Gtk.Image_Menu_Item;
with Gtk.Button; use Gtk.Button;
with Gtk.GEntry; use Gtk.GEntry;

package Callbacks_Gmastresults is

   package Image_Menu_Item_Callback is new
     Gtk.Handlers.Callback (Gtk_Image_Menu_Item_Record);

   package C_List_Callback is new
     Gtk.Handlers.Callback (Gtk_Clist_Record);

   package Button_Callback is new
     Gtk.Handlers.Callback (Gtk_Button_Record);

   package Entry_Callback is new
     Gtk.Handlers.Callback (Gtk_Entry_Record);

end Callbacks_Gmastresults;
