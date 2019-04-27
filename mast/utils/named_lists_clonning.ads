with Named_Lists,Var_Strings;
generic
   type Element is private;
   with function Name (E : Element ) return Var_Strings.Var_String;
   with package Lists is new Named_Lists(Element,Name);
   with procedure Clone(Original_Element : in Element; The_Copy : out Element);
package Named_Lists_Clonning is

   procedure Clone
     (Original_List : in Lists.List;
      The_Copy : out Lists.List);

end Named_Lists_Clonning;
