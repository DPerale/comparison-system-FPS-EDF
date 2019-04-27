generic
   type Element is private;
   with function "=" (E1,E2 : Element) return Boolean;
   with function "<" (E1,E2 : Element) return Boolean;
package Binary_Trees is

   type Node is private;
   type Binary_Tree is private;
   Null_Node : constant Node;
   Null_Tree : constant Binary_Tree;
   Incorrect_Node : exception;

   function Create
     (Root_Element : in Element;
      Left_Branch,
      Right_Branch : in Binary_Tree:=Null_Tree)
     return Binary_Tree;

   function Root
     (The_Tree : Binary_Tree) return Node;

   function Parent
     (The_Node : Node;
      The_Tree : Binary_Tree) return Node;

   function Left_Child
     (The_Node : Node;
      The_Tree : Binary_Tree) return Node;

   function Right_Child
     (The_Node : Node;
      The_Tree : Binary_Tree) return Node;

   function Item
     (The_Node : Node;
      The_Tree : Binary_Tree) return Element;

   procedure Add_In_Order
     (The_Element   : Element;
      The_Tree      : in out Binary_Tree);

   function Find
     (The_Element   : Element;
      Starting_From : Node;
      The_Tree      : Binary_Tree) return Node;
   -- returns Null_Node if not found

   function Find
     (The_Element   : Element;
      The_Tree      : Binary_Tree) return Node;
   -- starts from the root; returns Null_Node if not found

private

   type Cell;
   type Node is access Cell;
   Null_Node : constant Node := null;
   type Cell is record
      Left_Child,
      Right_Child,
      Parent     : Node;
      Contents : Element;
   end record;
   type Binary_Tree is record
      Root : Node;
   end record;
   Null_Tree : constant Binary_Tree:=(Root => Null_Node);

end Binary_Trees;
