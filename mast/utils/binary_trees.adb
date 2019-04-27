package body Binary_Trees is

   function Root (The_Tree : Binary_Tree) return Node is
   begin
      return The_Tree.Root;
   end Root;

   function Create
     (Root_Element : in Element;
      Left_Branch,
      Right_Branch : in Binary_Tree:=Null_Tree)
     return Binary_Tree is
      New_Tree : Binary_Tree;
   begin
      New_Tree.Root:=new Cell;
      New_Tree.Root.Left_Child:=Left_Branch.Root;
      New_Tree.Root.Right_Child:=Right_Branch.Root;
      New_Tree.Root.Parent:=null;
      New_Tree.Root.Contents:=Root_Element;
      if Right_Branch.Root /= Null_Node then
         Right_Branch.Root.Parent:=New_Tree.Root;
      end if;
      if Left_Branch.Root /= Null_Node then
         Left_Branch.Root.Parent:=New_Tree.Root;
      end if;
      return (New_Tree);
   end Create;

   function Parent (The_Node : Node; The_Tree : Binary_Tree)
                   return Node is
   begin
      if The_Node=Null_Node then
         raise Incorrect_Node;
      else
         return The_Node.Parent;
      end if;
   end Parent;

   function Left_Child
     (The_Node : Node; The_Tree : Binary_Tree)
     return Node is
   begin
      if The_Node=Null_Node then
         raise Incorrect_Node;
      else
         return The_Node.Left_Child;
      end if;
   end Left_Child;


   function Right_Child
     (The_Node : Node; The_Tree : Binary_Tree) return Node is
   begin
      if The_Node=Null_Node then
         raise Incorrect_Node;
      else
         return The_Node.Right_Child;
      end if;
   end Right_Child;

   function Item
     (The_Node : Node; The_Tree : Binary_Tree) return Element is
   begin
      if The_Node=Null_Node then
         raise Incorrect_Node;
      else
         return The_Node.Contents;
      end if;
   end Item;

   procedure Add_In_Order
     (The_Element   : Element;
      The_Tree      : in out Binary_Tree)
   is

      procedure Find_Node_And_Insert
        (The_Element   : Element;
         Starting_From : Node;
         The_Tree      : Binary_Tree)
      is
      begin
         if The_Element < Starting_From.Contents then
            if Starting_From.Left_Child=Null_Node then
               Starting_From.Left_Child:=new Cell'
                 (Left_Child  => null,
                  Right_Child => null,
                  Parent      => Starting_From,
                  Contents    => The_Element);
            else
               Find_Node_And_Insert
                 (The_Element,Starting_From.Left_Child,The_Tree);
            end if;
         else
            if Starting_From.Right_Child=Null_Node then
               Starting_From.Right_Child:=new Cell'
                 (Left_Child  => null,
                  Right_Child => null,
                  Parent      => Starting_From,
                  Contents    => The_Element);
            else
               Find_Node_And_Insert
                 (The_Element,Starting_From.Right_Child,The_Tree);
            end if;
         end if;
      end Find_Node_And_Insert;

   begin
      if The_Tree.Root=null then
         The_Tree.Root:=new Cell'
           (Left_Child  => null,
            Right_Child => null,
            Parent      => null,
            Contents    => The_Element);
      else
         Find_Node_And_Insert(The_Element,The_Tree.Root,The_Tree);
      end if;
   end Add_In_Order;

   function Find
     (The_Element   : Element;
      Starting_From : Node;
      The_Tree      : Binary_Tree) return Node
   is
   begin
      if Starting_From = Null_Node then
         return Null_Node;
      elsif The_Element=Starting_From.Contents then
         return Starting_From;
      elsif The_Element < Starting_From.Contents then
         return Find(The_Element,Starting_From.Left_Child,The_Tree);
      else
         return Find(The_Element,Starting_From.Right_Child,The_Tree);
      end if;
   end Find;

   function Find
     (The_Element   : Element;
      The_Tree      : Binary_Tree) return Node
   is
   begin
      return Find(The_Element,The_Tree.Root,The_Tree);
   end Find;

end Binary_Trees;
