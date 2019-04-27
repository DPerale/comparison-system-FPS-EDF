-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2004                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors: Michael Gonzalez       mgh@unican.es                     --
--          Jose Javier Gutierrez  gutierjj@unican.es                --
--          Jose Carlos Palencia   palencij@unican.es                --
--          Jose Maria Drake       drakej@unican.es                  --
--                                                                   --
-- This program is free software; you can redistribute it and/or     --
-- modify it under the terms of the GNU General Public               --
-- License as published by the Free Software Foundation; either      --
-- version 2 of the License, or (at your option) any later version.  --
--                                                                   --
-- This program is distributed in the hope that it will be useful,   --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of    --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU --
-- General Public License for more details.                          --
--                                                                   --
-- You should have received a copy of the GNU General Public         --
-- License along with this program; if not, write to the             --
-- Free Software Foundation, Inc., 59 Temple Place - Suite 330,      --
-- Boston, MA 02111-1307, USA.                                       --
--                                                                   --
-----------------------------------------------------------------------
--                            PACKAGE PRIORITY_QUEUE
--                            ======================
--
-- This package defines a priority queue type and the operations that
-- can be performed on this type:
--
--     Empty and Full queue functions.
--     Enqueue : insert in the queue, in priority order.
--     Dequeue : extract the highest priority element from the queue.
--               No particular order is imposed on equal priority
--               elements.
--     Dequeue_Middle : extract the queue element that matches the
--                      supplied argument.
--     Read_First : return the value of the highest priority element
--                  in the queue, without extracting it from the queue.
--
-- It is written as a generic package, in which the generic parameters
-- are:
--
--     Element : type of the queue elements
--     Priority : type of the priority used for ordering the queue
--                elements
--     ">" : Function used to order the priorities.
--     "=" : Used by dequeue_middle to compare the queue elements with
--           the element supplied by the caller.
-------------------------------------------------------------------------------

generic
   type Element is private;
   type Priority is private;
   with function ">" (Left,Right : in Priority) return BOOLEAN;
   with function "=" (Left,Right : in Element) return Boolean;

package Priority_Queues is

   type Queue is private;

   procedure Init(Q   : in out Queue);

   function Empty (Q : Queue) return Boolean;

   procedure Enqueue(E : in Element;
                     P : in Priority;
                     Q : in out Queue);


   procedure Dequeue(E : out Element;
                     P : out Priority;
                     Q : in out Queue);
   -- may raise List_Exceptions.Empty


   procedure Set_Prio(E : in Element;
                      P : in Priority;
                      Q : in out Queue);
   -- may raise List_Exceptions.Not_Found


   procedure Dequeue_Middle(E : in out Element;
                            P : out Priority;
                            Q : in out Queue;
                            Found : out Boolean);


   procedure Dequeue_Middle(E : in out Element;
                            P : out Priority;
                            Q : in out Queue);
   -- may raise List_Exceptions.Not_Found


   procedure Read_First (E : out Element;
                         P : out Priority;
                         Q : in Queue);
   -- may raise List_Exceptions.Empty

private

   Initial_Size : constant Integer:=1024;

   type Cell is record
      E : Element;
      Pri : Priority;
   end record;

   type Storing_Space is array (Positive range <>) of Cell;

   type Storing_Space_Ref is access Storing_Space;

   type Queue is record
      Length : Natural := 0;
      Q : Storing_Space_Ref;
   end record;

end Priority_Queues;
