package body Named_Lists_Clonning is

   -----------
   -- Clone --
   -----------

   procedure Clone
     (Original_List : in Lists.List;
      The_Copy : out Lists.List)
   is
      Iterator : Lists.Iteration_Object;
      E, Copy_Of_E : Element;

   begin
      Lists.Rewind(Original_List,Iterator);
      for I in 1..Lists.Size(Original_List) loop
         Lists.Get_Next_Item(E,Original_List,Iterator);
         Clone(E,Copy_Of_E);
         Lists.Add(Copy_Of_E,The_Copy);
      end loop;
   end Clone;

end Named_Lists_Clonning;

