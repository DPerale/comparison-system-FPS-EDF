with Glib; use Glib;
with Gtkada.types; use Gtkada.types;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Text; use Gtk.Text;
with Gdk.Color; use Gdk.Color;
with Gdk.Pixmap;
with Gdk.Bitmap;
with Gtk.Clist; use Gtk.Clist;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Style; use Gtk.Style;
with Gtk.Enums; use Gtk.Enums;
with Gtk.Pixmap; use Gtk.Pixmap;
with Gmast_Results_Pkg; use Gmast_Results_Pkg;
with Mast_Actions; use Mast_Actions;
with Mast.Processing_Resources;
with Mast.Processing_Resources.Processor;
with Mast.Processing_Resources.Network;
with Mast.Shared_Resources; use Mast.Shared_Resources;
with Var_Strings; use Var_Strings;
with Mast.IO, MAST.Systems, Mast.Results, Mast.Transactions;
with Interfaces.C.Strings;
with Interfaces.C;
with Gmastresults_Pixmaps;
with Clear_Results;
with Mast.Tools;

procedure Draw_Results is

   use type Mast.Results.Slack_Result_Ref;
   use type Mast.Results.Utilization_Result_Ref;
   use type Mast.Results.Ready_Queue_Size_Result_Ref;
   use type Mast.Results.Queue_Size_Result_Ref;
   use type Mast.Results.Ceiling_Result_ref;
   package ICS renames Interfaces.C.Strings;
   package IC renames Interfaces.C;
   use type IC.Size_T;

   subtype Byte is Integer range 0..255;

   function Color_Of (R,G,B : byte) return Gdk_Color is
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

   function Color_Of (Slack : Float) return Gdk_Color is
   begin
      if Slack<-10.0 then
         return Color_Of(200,60,60);
      elsif Slack<0.0 then
         return Color_Of(200,128,128);
      elsif Slack<10.0 then
         return Color_Of(128,200,128);
      else
         return Color_Of(60,200,60);
      end if;
   end Color_Of;

   Style : Gtk_Style:=Get_Style(Gmast_Results.Clist_Processing_Resources);

   function Style_Of (Slack : Float) return Gtk_Style is
      Style1 : Gtk_Style:=Copy(Style);
   begin
      Set_Base(Style1,State_Normal,Color_Of(Slack));
      return Style1;
   end Style_Of;

   System_Slack : Float;
   Res : Mast.Results.Slack_Result_Ref;
   Width : Gint;
   Schedulable : Boolean;

begin
   Clear_Results;

   -- System Results
   Set_Text(Gmast_Results.Entry_Model_Name,To_String(The_System.Model_Name));
   Set_Text(Gmast_Results.Entry_Model_Date,The_System.Model_Date);
   Set_Text(Gmast_Results.Entry_Generation_Tool,
            To_String(The_System.Generation_Tool));
   Set_Text(Gmast_Results.Entry_Generation_Profile,
            To_String(The_System.Generation_Profile));
   Set_Text(Gmast_Results.Entry_Generation_Date,The_System.Generation_Date);
   Res:=Mast.Systems.Slack_Result(The_System);
   if Res/=null then
      System_Slack:=Mast.Results.Slack(Res.all);
      if System_Slack>=0.0 then
         Set_Text (Gmast_Results.Text_System_Slack,
                   Mast.IO.Slack_Image(System_Slack)&
                  " -> The system is schedulable");
      else
         Set_Text (Gmast_Results.Text_System_Slack,
                   Mast.IO.Slack_Image(System_Slack)&
                  " -> The system is NOT schedulable");
      end if;
      Set_Style (Gmast_Results.Text_System_Slack,
                 Style_Of(System_Slack));
   else
      Mast.Tools.Check_System_Schedulability(The_System,Schedulable,False);
      if Schedulable then
         Set_Text (Gmast_Results.Text_System_Slack,
                   "The system is schedulable");
         Set_Style (Gmast_Results.Text_System_Slack,
                    Style_Of(100.0));
      else
         Set_Text (Gmast_Results.Text_System_Slack,
                   "The system is NOT schedulable");
         Set_Style (Gmast_Results.Text_System_Slack,
                    Style_Of(-100.0));
      end if;
   end if;

   -- Processing Resource Results
   declare
      Res_Ref : Mast.Processing_Resources.Processing_Resource_Ref;
      Iterator : Mast.Processing_Resources.Lists.Index;
      Columns : Gint:=Get_Columns(Gmast_Results.Clist_Processing_Resources);
      Texts : Chars_Ptr_Array (0 .. IC.Size_T(Columns)-1):=
        (others => ICS.New_String(""));
      Row : Gint;
      The_Slack : Float;
      URes : Mast.Results.Utilization_Result_Ref;
      QRes : Mast.Results.Ready_Queue_Size_Result_Ref;
   begin
      Mast.Processing_Resources.Lists.Rewind
        (The_System.Processing_Resources,Iterator);
      for I in 1..Mast.Processing_Resources.Lists.Size
        (The_System.Processing_Resources)
      loop
         Mast.Processing_Resources.Lists.Get_Next_Item
           (Res_Ref,The_System.Processing_Resources,Iterator);
         Texts(0):=ICS.New_String
           (To_String(Mast.Processing_Resources.Name(Res_Ref)));
         if Res_Ref.all in
           Mast.Processing_Resources.Processor.Processor'Class
         then
            Texts(1):=ICS.New_String ("Processor");
         elsif Res_Ref.all in
           Mast.Processing_Resources.Network.Network'Class
         then
            Texts(1):=ICS.New_String ("Network");
         end if;
         Row:=Append(Gmast_Results.Clist_Processing_Resources,texts);
         Res:=Mast.Processing_Resources.Slack_Result(Res_Ref.all);
         if Res/=null then
            The_Slack:=Mast.Results.Slack(Res.all);
            Set_Text (Gmast_Results.Clist_Processing_Resources,
                      Row,2,Mast.IO.Slack_Image(The_Slack));
            Set_Cell_Style (Gmast_Results.Clist_Processing_Resources,
                            Row,2,Style_Of(The_Slack));
         else
            Set_Column_Visibility
              (Gmast_Results.Clist_Processing_Resources,2,False);
         end if;
         URes:= Mast.Processing_Resources.Utilization_Result(Res_Ref.all);
         if URes=null then
            for Col in Gint range 3..7 loop
               Set_Column_Visibility
                 (Gmast_Results.Clist_Processing_Resources,col,False);
            end loop;
         else
           Set_Text (Gmast_Results.Clist_Processing_Resources,
                      Row,3,Mast.IO.Percentage_Image(
                                    Mast.results.Total(URes.all)));
           Set_Text (Gmast_Results.Clist_Processing_Resources,
                      Row,4,Mast.IO.Percentage_Image
                     (Mast.Results.Application
                      (Mast.Results.Detailed_Utilization_Result(URes.all))));
           if Res_Ref.all in
              Mast.Processing_Resources.Processor.Processor'Class
           then

               Set_Text (Gmast_Results.Clist_Processing_Resources,
                      Row,5,Mast.IO.Percentage_Image
                         (Mast.Results.Context_Switch
                          (Mast.Results.Detailed_Utilization_Result
                           (URes.all))));
               Set_Text (Gmast_Results.Clist_Processing_Resources,
                      Row,6,Mast.IO.Percentage_Image
                         (Mast.Results.Timer
                          (Mast.Results.Detailed_Utilization_Result
                           (URes.all))));
               Set_Text (Gmast_Results.Clist_Processing_Resources,
                      Row,7,Mast.IO.Percentage_Image
                         (Mast.Results.Driver
                          (Mast.Results.Detailed_Utilization_Result
                           (URes.all))));
           elsif Res_Ref.all in
                 Mast.Processing_Resources.Network.Network'Class
           then
              Set_Text (Gmast_Results.Clist_Processing_Resources,
                      Row,5,Mast.IO.Percentage_Image
                        (Mast.Results.Context_Switch
                         (Mast.Results.Detailed_Utilization_Result
                          (URes.all)))&" *");
           end if;
         end if;

         QRes:=Mast.Processing_Resources.Ready_Queue_Size_Result(Res_Ref.all);
         if QRes=null then
            Set_Column_Visibility
              (Gmast_Results.Clist_Processing_Resources,8,False);
         else
            Set_Text (Gmast_Results.Clist_Processing_Resources,
                      Row,8,Natural'Image(Mast.Results.Max_Num(QRes.all)));
          end if;
      end loop;
      Width:=Columns_Autosize(Gmast_Results.Clist_Processing_Resources);
   end;

   -- Transaction results
   declare
      Trans_Ref : Mast.Transactions.Transaction_Ref;
      Iterator : Mast.Transactions.Lists.Index;
      Columns : Gint:=Get_Columns(Gmast_Results.Clist_Transactions);
      Texts : Chars_Ptr_Array (0 .. IC.Size_T(Columns)-1):=
        (others => ICS.New_String(""));
      Row : Gint;
      The_Slack : Float;
      Pixmap_View : Gtk_Pixmap;
      Gdk_Pixmap_View : Gdk.Pixmap.Gdk_Pixmap;
      Mask_Pixmap_View : Gdk.Bitmap.Gdk_Bitmap;
   begin
      Set_Row_Height(Gmast_Results.Clist_Transactions,22);
      Pixmap_View:=Create_Pixmap(Gmastresults_Pixmaps.View_Str, Gmast_Results);
      Set_Alignment (Pixmap_View, 0.5, 0.5);
      Set_Padding (Pixmap_View, 0, 0);

      Mast.Transactions.Lists.Rewind
        (The_System.Transactions,Iterator);
      for I in 1..Mast.Transactions.Lists.Size
        (The_System.Transactions)
      loop
         Mast.Transactions.Lists.Get_Next_Item
           (Trans_Ref,The_System.Transactions,Iterator);
         Texts(0):=ICS.New_String
           (To_String(Mast.Transactions.Name(Trans_Ref)));
         if Trans_Ref.all in
           Mast.Transactions.Regular_Transaction
         then
            Texts(1):=ICS.New_String ("Regular_Transaction");
         end if;
         Row:=Append(Gmast_Results.Clist_Transactions,texts);
         Res:=Mast.Transactions.Slack_Result(Trans_Ref.all);
         if Res/=null then
            The_Slack:=Mast.Results.Slack(Res.all);
            Set_Text (Gmast_Results.Clist_Transactions,
                      Row,2,Mast.IO.Slack_Image(The_Slack));
            Set_Cell_Style (Gmast_Results.Clist_Transactions,
                            Row,2,Style_Of(The_Slack));
         else
            Set_Column_Visibility
              (Gmast_Results.Clist_Transactions,2,False);
         end if;
         Get(Pixmap_View,Gdk_Pixmap_View,Mask_Pixmap_View);
         Set_Pixmap(Gmast_Results.Clist_Transactions,
                    Row,3,Gdk_Pixmap_View,Mask_Pixmap_View);
      end loop;
      Width:=Columns_Autosize(Gmast_Results.Clist_Transactions);
   end;

   -- Shared Resource Results
   declare
      Res_Ref : Mast.Shared_Resources.Shared_Resource_Ref;
      Iterator : Mast.Shared_Resources.Lists.Index;
      Columns : Gint:=Get_Columns(Gmast_Results.Clist_Shared_Resources);
      Texts : Chars_Ptr_Array (0 .. IC.Size_T(Columns)-1):=
        (others => ICS.New_String(""));
      Row : Gint;
      URes : Mast.Results.Utilization_Result_Ref;
      QRes : Mast.Results.Queue_Size_Result_Ref;
      CRes : MAst.Results.Ceiling_Result_ref;
   begin
      Mast.Shared_Resources.Lists.Rewind
        (The_System.Shared_Resources,Iterator);
      for I in 1..Mast.Shared_Resources.Lists.Size
        (The_System.Shared_Resources)
      loop
         Mast.Shared_Resources.Lists.Get_Next_Item
           (Res_Ref,The_System.Shared_Resources,Iterator);
         Texts(0):=ICS.New_String
           (To_String(Mast.Shared_Resources.Name(Res_Ref)));
         if Res_Ref.all in
           Mast.Shared_Resources.Immediate_Ceiling_Resource
         then
            Texts(1):=ICS.New_String ("Inmediate Ceiling Resource");
         elsif Res_Ref.all in
           Mast.Shared_Resources.Priority_Inheritance_Resource
         then
            Texts(1):=ICS.New_String ("Priority Inheritance Resource");
         end if;
         Row:=Append(Gmast_Results.Clist_Shared_Resources,texts);

         CRes:= Mast.Shared_Resources.Ceiling_Result(REs_REf.all);
         if CRes=null then
           Set_Column_Visibility
                 (Gmast_Results.Clist_Shared_Resources,2,False);
         else
           Set_Text (Gmast_Results.Clist_Shared_Resources,
                      Row,2,Mast.Priority'Image(
                                    Mast.results.Ceiling(CRes.all)));
         end if;



         URes:= Mast.Shared_Resources.Utilization_Result(Res_Ref.all);
         if URes=null then
           Set_Column_Visibility
                 (Gmast_Results.Clist_Shared_Resources,3,False);
         else
           Set_Text (Gmast_Results.Clist_Shared_Resources,
                      Row,3,Mast.IO.Percentage_Image(
                                    Mast.results.Total(URes.all)));
         end if;

         QRes:=Mast.Shared_Resources.Queue_Size_Result(Res_Ref.all);
         if QRes=null then
            Set_Column_Visibility
              (Gmast_Results.Clist_Shared_Resources,4,False);
         else
            Set_Text (Gmast_Results.Clist_Shared_Resources,
                      Row,4,Natural'Image(Mast.Results.Max_Num(QRes.all)));

         end if;
      end loop;
      Width:=Columns_Autosize(Gmast_Results.Clist_Shared_Resources);
   end;


end Draw_Results;
