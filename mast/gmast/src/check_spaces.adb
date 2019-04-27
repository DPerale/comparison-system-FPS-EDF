with Var_Strings;
use Var_Strings;

function Check_Spaces(S : String) return String is

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

begin
   if Find_Pos_Last_Char(' ',S)=0 then
      return S;
   else
      return """"&S&"""";
   end if;
end Check_Spaces;

