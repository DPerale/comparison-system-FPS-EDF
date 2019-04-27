with Gtkada.Intl; use Gtkada.Intl;

package body Gmastresults_Intl is

   function "-" (Msg : String) return String is
   begin
      return Dgettext ("Gmastresults", Msg);
   end "-";

end Gmastresults_Intl;
