with Ada.Text_IO,Var_Strings,Indexed_Lists;
use Ada.Text_IO,Var_Strings;

package body Mast_XML_Exceptions is

   package Error_Lists is new Indexed_Lists(Var_String,"=");

   List : Error_Lists.List;

   ------------------
   -- Parser_Error --
   ------------------

   procedure Parser_Error (S : String) is
   begin
      Error_Lists.Add(To_Var_String(S),List);
   end Parser_Error;

   ------------------
   -- Clear_Errors --
   ------------------

   procedure Clear_Errors is
      Empty_List : Error_Lists.List;
   begin
      List:=Empty_List;
   end Clear_Errors;

   -----------------
   -- Report_Errors --
   -----------------

   procedure Report_Errors is
      Ind : Error_Lists.Index;
      Msg : Var_String;
   begin
      if Error_Lists.Size(List)>0 then
         Put_Line("Parser errors: ");
         New_Line;
         Error_Lists.Rewind(List,Ind);
         for I in 1..Error_Lists.Size(List) loop
            Error_Lists.Get_Next_Item(Msg,List,Ind);
            Put_Line(Msg);
         end loop;
         raise Parser_Detected_Error;
      end if;
   end Report_Errors;

end Mast_XML_Exceptions;
