with Gtkada.Intl; use Gtkada.Intl;

package body Gmast_Analysis_Intl is

   function "-" (Msg : String) return String is
   begin
      return Dgettext ("Gmast_Analysis", Msg);
   end "-";

end Gmast_Analysis_Intl;
