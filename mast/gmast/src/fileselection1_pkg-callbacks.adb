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
with Mast_Analysis_Pkg; Use Mast_Analysis_Pkg;

package body Fileselection1_Pkg.Callbacks is

   use Gtk.Arguments;

   ---------------------------
   -- On_Ok_Button1_Pressed --
   ---------------------------

   procedure On_Ok_Button1_Pressed
     (Object : access Gtk_Button_Record'Class)
   is

      function Find_Pos_Last_Char(Char : Character;Line : String)
                                  return Natural is
      begin
         for i in reverse 1..Line'Length loop
            if Line(i)=Char then
               return i;
            end if;
         end loop;
         return 0;
      end Find_Pos_Last_Char;

      Full_Input_Filename : String:=Get_Filename(Fileselection1);
      Pos_Slash : Natural;

   begin
      Pos_Slash:=Find_Pos_Last_Char('/',Full_Input_Filename);
      if Pos_Slash=0 then
         Pos_Slash:=Find_Pos_Last_Char('\',Full_Input_Filename);
      end if;
      if Pos_Slash=0 then
         Set_Text(Mast_Analysis.Directory_Entry,"");
         Set_Text(Mast_Analysis.Input_File,Full_Input_Filename);
      else
         Set_Text(Mast_Analysis.Directory_Entry,
                  Full_Input_Filename(1..Pos_Slash));
         Set_Text(Mast_Analysis.Input_File,
                  Full_Input_Filename(Pos_Slash+1..
                                      Full_Input_Filename'Length));
      end if;
      Set_Text(Mast_Analysis.Output_File,"");
      Destroy(Fileselection1);
   end On_Ok_Button1_Pressed;

   ---------------------
   -- Gtk_Widget_Hide --
   ---------------------

   procedure Gtk_Widget_Hide
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Destroy(Fileselection1);
   end Gtk_Widget_Hide;

end Fileselection1_Pkg.Callbacks;
