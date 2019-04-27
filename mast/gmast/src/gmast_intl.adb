with Gtkada.Intl; use Gtkada.Intl;

package body Gmast_Intl is

   function "-" (Msg : String) return String is
   begin
      return Dgettext ("Gmast", Msg);
   end "-";

end Gmast_Intl;
