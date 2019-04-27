-----------------------------------------------------------------------
--                              Mast                                 --
--     Modelling and Analysis Suite for Real-Time Applications       --
--                                                                   --
--                       Copyright (C) 2000-2008                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
-- Authors: Michael Gonzalez       mgh@unican.es                     --
--          Jose Javier Gutierrez  gutierjj@unican.es                --
--          Jose Carlos Palencia   palencij@unican.es                --
--          Jose Maria Drake       drakej@unican.es                  --
--          Ola Redell                                               --
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

-- Changes: changed in initialize_response_times_and_jitter(x3)
-- cij and cbij into cijown, and cbijown, because the initial
-- values refer to the own analysis

-- Need to check if the holistic analysis is OK, because it does not
-- manage the Cij and Cijown in the same way as the other two analysis


with MAST.Systems,Mast.Processing_Resources,Mast.Timers,
  Mast.Linear_Translation, Mast.Max_Numbers, Ada.Text_IO;
use Ada.Text_IO;
use type Mast.Timers.System_Timer_Ref;

package body Mast.Linear_Analysis_Tools is

   type Processor_ID is new Natural;
   type Transaction_ID is new Natural;
   type Task_ID is new Natural;
   type Long_Int is range -(2**31-1)..2**31-2;
   -- This is to force the compiler to check the range

   ------------
   -- Modulus --
   ------------

   function Modulus(A,B:Time) return Time is
   begin
      return A-Floor(A/B)*B;
   end Modulus;

   ------------
   -- Ceil0 --
   ------------

   function Ceil0(X:Time) return Time is
   begin
      if X<0.0 then return 0.0;
      else return Ceiling(X);
      end if;
   end Ceil0;


   -----------------------
   -- Holistic_Analysis --
   -----------------------

   procedure Holistic_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True)
   is
      Max_Processors:constant Processor_ID:=Processor_ID
        (Processing_Resources.Lists.Size
         (The_System.Processing_Resources));
      Max_Transactions:constant Transaction_ID:=
        Transaction_Id((Mast.Max_Numbers.Calculate_Max_Transactions
                        (The_System)));
      Max_Tasks_Per_Transaction:constant Task_ID:=Task_ID
        (Mast.Max_Numbers.Calculate_Max_Tasks_Per_Transaction(The_System));

      subtype Processor_ID_Type is Processor_ID
        range 0..Max_Processors;
      subtype Transaction_ID_Type is Transaction_ID
        range 0..Max_Transactions;
      subtype Task_ID_Type is Task_ID
        range 0..Max_Tasks_Per_Transaction;

      package Translation is new Linear_Translation
        (Processor_ID_Type, Transaction_ID_Type, Task_ID_Type,
         Max_Processors, Max_Transactions, Max_Tasks_Per_Transaction);

      use Translation;

      --------------
      -- WTindell --
      --------------

      function WTindell
        (Ta:Transaction_ID_Type;
         K:Task_ID_Type;
         Q:Long_Int;
         Transaction : in Linear_Transaction_System)
        return Time
      is
         Wc,Wcant,Jitter:Time;
         Prio:Priority;
         Proc:Processor_ID_Type;
         Done:Boolean;
      begin
         Proc:=Transaction(Ta).The_Task(K).Procij;
         Prio:=Transaction(Ta).The_Task(K).Prioij;
         Wcant:=Time(Q)*Transaction(Ta).The_Task(K).Cijown
           +Transaction(Ta).The_Task(K).Bij;
         for I in Transaction_ID_Type range 1..Max_Transactions
         loop
            exit when Transaction(I).Ni=0;
            for J in 1..Transaction(I).Ni
            loop
               if (Transaction(I).The_Task(J).Procij=Proc)
                 and (Transaction(I).The_Task(J).Prioij>=Prio)
                 and not((I=Ta)and(J=K))
               then
                  Wcant:=Wcant+Transaction(I).The_Task(J).Cij;
               end if;
            end loop;
         end loop;


         loop

            Wc:=Time(Q)*Transaction(Ta).The_Task(K).Cijown
              +Transaction(Ta).The_Task(K).Bij;

            for I in Transaction_ID_Type range 1..Max_Transactions
            loop
               exit when Transaction(I).Ni=0;
               for J in 1..Transaction(I).Ni
               loop
                  if (Transaction(I).The_Task(J).Procij=Proc)
                    and (Transaction(I).The_Task(J).Prioij>=Prio)
                    and not((I=Ta)and(J=K))
                  then
                     if Transaction(I).The_Task(J).Model=Unbounded_Effects then
                        return Large_Time;
                     elsif
                       Transaction(I).The_Task(J).Jitter_Avoidance then
                        Jitter:=0.0;
                     else
                        Jitter:=Transaction(I).The_Task(J).Jij;
                     end if;
                     Wc:=Wc+Ceiling((Wcant+Jitter)/
                                    Transaction(I).The_Task(J).Tij)*
                       Transaction(I).The_Task(J).Cij;
                  end if;
               end loop;
            end loop;
            Done:=Wc=Wcant;
            Wcant:=Wc;
            exit when Done;
         end loop;
         return Wc;
      end WTindell;

      procedure Initialize_Response_Times_And_Jitter
        (Transaction : in out Linear_Transaction_System)
      is
         Act_B,Act_W:Time;
      begin
         for I in 1..Max_Transactions
         loop
            exit when Transaction(I).Ni=0;
            if Transaction(I).Trans_Input_Type=Internal then
               Act_B:=Time'Max
                 (Transaction(I).The_Task(1).Oijmin,
                  Transaction(I-1).The_Task(Transaction(I-1).Ni).Rbij
                  +Transaction(I).The_Task(1).Delayijmin);
               Act_W:=Time'Max
                 (Transaction(I).The_Task(1).Oijmax,
                  Transaction(I-1).The_Task(Transaction(I-1).Ni).Rij
                  +Transaction(I).The_Task(1).Delayijmax)
                 +Transaction(I).The_Task(1).Jinit;
            else
               Act_B:=Time'Max(Transaction(I).The_Task(1).Oijmin,
                               Transaction(I).The_Task(1).Delayijmin);
               Act_W:=Time'Max(Transaction(I).The_Task(1).Oijmax,
                               Transaction(I).The_Task(1).Delayijmax)
                 +Transaction(I).The_Task(1).Jinit;
            end if;

            Transaction(I).The_Task(1).Oij:=Act_B;
            Transaction(I).The_Task(1).Jij:=Act_W-Act_B;
            Transaction(I).The_Task(1).Rbij:=
              Act_B+Transaction(I).The_Task(1).Cbijown;
            Transaction(I).The_Task(1).Rij :=
              Act_W+Transaction(I).The_Task(1).Cijown;

            for L in 2..Transaction(I).Ni loop
               Act_B:=Time'max(Transaction(I).The_Task(L).Oijmin,
                               Transaction(I).The_Task(L-1).Rbij
                               +Transaction(I).The_Task(L).Delayijmin);
               Act_W:=Time'Max(Transaction(I).The_Task(L).Oijmax,
                               Transaction(I).The_Task(L-1).Rij
                               +Transaction(I).The_Task(L).Delayijmax)
                 +Transaction(I).The_Task(L).Jinit;
               Transaction(I).The_Task(L).Oij:=Act_B;
               Transaction(I).The_Task(L).Jij:=Act_W-Act_B;
               Transaction(I).The_Task(L).Rbij:=
                 Act_B+Transaction(I).The_Task(L).Cbijown;
               Transaction(I).The_Task(L).Rij :=
                 Act_W+Transaction(I).The_Task(L).Cijown;
            end loop;
         end loop;
      end Initialize_Response_Times_and_Jitter;


      Q:Long_Int;
      R_Ij,W_Ij,Rmax:Time;
      Done:Boolean;
      Transaction : Linear_Transaction_System;

   begin
      if Verbose then
         New_Line;Put_Line("Holistic Analysis");
      end if;
      Translate_Linear_System(The_System,Transaction,Verbose);


      Initialize_Response_Times_and_Jitter(Transaction);

      loop
         Done:=True;
         for I in 1..Max_Transactions
         loop
            exit when Transaction(I).Ni=0;
            for J in 1..Transaction(I).Ni
            loop
               if Transaction(I).The_Task(J).Model /= Unbounded_Response
                 and Transaction(I).The_Task(J).Model /= Unbounded_Effects
               then
                  Q:=0;Rmax:=0.0;
                  loop
                     Q:=Q+1;
                     W_Ij:=WTindell(I,J,Q,Transaction);
                     R_Ij:=W_Ij+Transaction(I).The_Task(J).Jij-Time(Q-1)*
                       Transaction(I).The_Task(J).Tijown
                       +Transaction(I).The_Task(J).Oij;
                     if R_Ij>Rmax then Rmax:=R_Ij; end if;
                     if Rmax>Analysis_Bound then
                        Done:=False;
                        for K in J..Transaction(I).Ni loop
                           Transaction(I).The_Task(K).Model:=Unbounded_Effects;
                           Transaction(I).The_Task(K).Rij:=Large_Time;
                        end loop;
                     end if;
                     exit when
                       (W_Ij<=Time(Q)*Transaction(I).The_Task(J).Tijown)
                       or Transaction(I).The_Task(J).Model=Unbounded_Effects;
                  end loop;
                  if Rmax>Transaction(I).The_Task(J).Rij
                  then
                     Done:=False;
                     Transaction(I).The_Task(J).Rij:=Rmax;
                     if J<Transaction(I).Ni then
                        Transaction(I).The_Task(J+1).Jij:=
                          Time'Max(Transaction(I).The_Task(J+1).Oijmax,
                                   Rmax+
                                   Transaction(I).The_Task(J+1).Delayijmax)
                          +Transaction(I).The_Task(J+1).Jinit
                          -Transaction(I).The_Task(J+1).Oij;

                     elsif I<Max_Transactions and then
                       Transaction(I+1).Trans_Input_Type=Internal
                     then
                        Transaction(I+1).The_Task(1).Jij:=
                          Time'Max(Transaction(I+1).The_Task(1).Oijmax,
                                   Rmax+
                                   Transaction(I+1).The_Task(1).Delayijmax)
                          +Transaction(I+1).The_Task(1).Jinit
                          -Transaction(I+1).The_Task(1).Oij;
                     end if;
                  end if;
               end if;
            end loop;
         end loop;
         exit when Done;
      end loop;

      Translate_Linear_Analysis_Results(Transaction,The_System);
   end Holistic_Analysis;


   procedure Offset_Based_Unoptimized_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True)
   is

      Max_Processors:constant Processor_ID:=Processor_ID
        (Processing_Resources.Lists.Size
         (The_System.Processing_Resources));
      Max_Transactions:constant Transaction_ID:=
        Transaction_Id((Mast.Max_Numbers.Calculate_Max_Transactions
                        (The_System)));
      Max_Tasks_Per_Transaction:constant Task_ID:=Task_ID
        (Mast.Max_Numbers.Calculate_Max_Tasks_Per_Transaction(The_System));

      subtype Processor_ID_Type is Processor_ID
        range 0..Max_Processors;
      subtype Transaction_ID_Type is Transaction_ID
        range 0..Max_Transactions;
      subtype Task_ID_Type is Task_ID
        range 0..Max_Tasks_Per_Transaction;

      package Translation is new Linear_Translation
        (Processor_ID_Type, Transaction_ID_Type, Task_ID_Type,
         Max_Processors, Max_Transactions,Max_Tasks_Per_Transaction);

      use Translation;

      Transaction : Linear_Transaction_System;

      ----------
      -- Fijk --
      ----------

      function Fijk
        (I:Transaction_ID_Type;
         J,K:Task_ID_Type) return Time
      is
      begin
         return Transaction(I).The_Task(J).Tij-
           Modulus(Transaction(I).The_Task(K).Oij+
                   Transaction(I).The_Task(K).Jij-
                   Transaction(I).The_Task(J).Oij,
                   Transaction(I).The_Task(J).Tij);
      end Fijk;


      ----------
      -- Wik --
      ----------

      function Wik
        (I:Transaction_ID_Type;
         K:Task_ID_Type;
         T:Time;
         A:Transaction_ID_Type;
         B:Task_ID_Type) return Time

      is
         Acum:Time:=0.0;
         Prio:Priority;
         Proc:Processor_ID_Type;
         Aux_Jitters : array (Task_ID_Type range 1..Max_Tasks_Per_Transaction)
           of Time;


      begin
         if T=0.0 then return Transaction(I).The_Task(K).Cij;end if;
         -- Copy jitter terms into an auxiliar transaction
         -- to make zero all those marked as jitter_avoidance.
         -- Recover the original values at the end of the procedure.
         for J in 1..Transaction(I).Ni loop
            Aux_Jitters(J):=Transaction(I).The_Task(J).Jij;
            if Transaction(I).The_Task(J).Jitter_Avoidance then
               Transaction(I).The_Task(J).Jij:=0.0;
            end if;
         end loop;


         Proc:=Transaction(A).The_Task(B).Procij;
         Prio:=Transaction(A).The_Task(B).Prioij;
         for J in 1..Transaction(I).Ni
         loop
            if (Transaction(I).The_Task(J).Procij=Proc)
              and (Transaction(I).The_Task(J).Prioij>=Prio)
              and not((I=A)and(J=B))
            then
               if Transaction(I).The_Task(J).Model=Unbounded_Effects then
                  return Large_Time;
               else
                  Acum:=Acum+(Floor
                              ((Transaction(I).The_Task(J).Jij+
                                Fijk(I,J,K))/
                               Transaction(I).The_Task(J).Tij)+
                              Ceiling((T-Fijk(I,J,K))/
                                      Transaction(I).The_Task(J).Tij))*
                    Transaction(I).The_Task(J).Cij;
               end if;
            end if;
         end loop;

         for J in 1..Transaction(I).Ni loop
            Transaction(I).The_Task(J).Jij:=Aux_Jitters(J);
         end loop;

         return Acum;
      end Wik;

      ----------
      -- W_DO --
      ----------

      function W_DO
        (A:Transaction_ID_Type;
         B,C:Task_ID_Type;
         Q:Long_Int) return Time
      is
         Wc,Wcant,Wc_Ik,MaxWik:Time;
         Prio:Priority;
         Proc:Processor_ID_Type;
         Done:Boolean;
      begin
         Proc:=Transaction(A).The_Task(B).Procij;
         Prio:=Transaction(A).The_Task(B).Prioij;
         Wcant:=Time(Q)*Transaction(A).The_Task(B).Cijown
           +Transaction(A).The_Task(B).Bij;
         loop
            Wc:=Time(Q)*Transaction(A).The_Task(B).Cijown
              +Transaction(A).The_Task(B).Bij
              +Wik(A,C,Wcant,A,B);
            for I in 1..Max_Transactions
            loop
               exit when Transaction(I).Ni=0;
               if I/=A then
                  MaxWik:=0.0;
                  for K in 1..Transaction(I).Ni
                  loop
                     Wc_IK:=0.0;
                     if (Transaction(I).The_Task(K).Procij=Proc)
                       and(Transaction(I).The_Task(K).Prioij>=Prio)
                       and not((I=A)and(K=B))
                     then
                        if Transaction(I).The_Task(K).Model=Unbounded_Effects
                        then
                           return Large_Time;
                        else
                           Wc_Ik:=Wc_IK+Wik(I,K,Wcant,A,B);
                        end if;

                        if Wc_Ik>MaxWik then MaxWik:=Wc_Ik;end if;
                     end if;
                  end loop;
                  Wc:=Wc+MaxWik;
               end if;
            end loop;
            Done:=(Wc=Wcant);
            Wcant:=Wc;
            exit when Done;
         end loop;
         return Wc;
      end W_DO;

      procedure Initialize_Response_Times_And_Jitter
        (Transaction : in out Linear_Transaction_System)
      is
         Act_B,Act_W:Time;
      begin
         for I in 1..Max_Transactions
         loop
            exit when Transaction(I).Ni=0;
            if Transaction(I).Trans_Input_Type=Internal then
               Act_B:=Time'Max
                 (Transaction(I).The_Task(1).Oijmin,
                  Transaction(I-1).The_Task(Transaction(I-1).Ni).Rbij
                  +Transaction(I).The_Task(1).Delayijmin);
               Act_W:=Time'Max
                 (Transaction(I).The_Task(1).Oijmax,
                  Transaction(I-1).The_Task(Transaction(I-1).Ni).Rij
                  +Transaction(I).The_Task(1).Delayijmax)
                 +Transaction(I).The_Task(1).Jinit;
            else
               Act_B:=Time'Max(Transaction(I).The_Task(1).Oijmin,
                               Transaction(I).The_Task(1).Delayijmin);
               Act_W:=Time'Max(Transaction(I).The_Task(1).Oijmax,
                               Transaction(I).The_Task(1).Delayijmax)
                 +Transaction(I).The_Task(1).Jinit;
            end if;

            Transaction(I).The_Task(1).Oij:=Act_B;
            Transaction(I).The_Task(1).Jij:=Act_W-Act_B;
            Transaction(I).The_Task(1).Rbij:=
              Act_B+Transaction(I).The_Task(1).Cbijown;
            Transaction(I).The_Task(1).Rij :=
              Act_W+Transaction(I).The_Task(1).Cijown;

            for L in 2..Transaction(I).Ni loop
               Act_B:=Time'Max(Transaction(I).The_Task(L).Oijmin,
                               Transaction(I).The_Task(L-1).Rbij
                               +Transaction(I).The_Task(L).Delayijmin);
               Act_W:=Time'Max(Transaction(I).The_Task(L).Oijmax,
                               Transaction(I).The_Task(L-1).Rij
                               +Transaction(I).The_Task(L).Delayijmax)
                 +Transaction(I).The_Task(L).Jinit;
               Transaction(I).The_Task(L).Oij:=Act_B;
               Transaction(I).The_Task(L).Jij:=Act_W-Act_B;
               Transaction(I).The_Task(L).Rbij:=
                 Act_B+Transaction(I).The_Task(L).Cbijown;
               Transaction(I).The_Task(L).Rij :=
                 Act_W+Transaction(I).The_Task(L).Cijown;
            end loop;
         end loop;
      end Initialize_Response_Times_and_Jitter;

      P,P0:Long_Int;
      R_Abc,W_Abc,Rmax:Time;
      Done:Boolean;
      Aux_Tij,Aux_Cij,Aux_Cbij :
        array (Task_ID_Type range 1..Max_Tasks_Per_Transaction)
        of Time;

   begin
      if Verbose then
         New_Line;Put_Line("Offset Based Unoptimized Analysis");
      end if;
      Translate_Linear_System(The_System,Transaction,Verbose);
      Initialize_Response_Times_and_Jitter(Transaction);

      loop
         Done:=True;
         for A in 1..Max_Transactions
         loop
            exit when Transaction(A).Ni=0;
            for B in 1..Transaction(A).Ni loop
               Aux_Tij(B):=Transaction(A).The_Task(B).Tij;
               Transaction(A).The_Task(B).Tij:=
                 Transaction(A).The_Task(B).Tijown;
               Aux_Cij(B):=Transaction(A).The_Task(B).Cij;
               Transaction(A).The_Task(B).Cij:=
                 Transaction(A).The_Task(B).Cijown;
               Aux_Cbij(B):=Transaction(A).The_Task(B).Cbij;
               Transaction(A).The_Task(B).Cbij:=
                 Transaction(A).The_Task(B).Cbijown;
            end loop;

            for B in 1..Transaction(A).Ni
            loop
               if Transaction(A).The_Task(B).Model /= Unbounded_Response
                 and Transaction(A).The_Task(B).Model /= Unbounded_Effects then
                  Rmax:=0.0;
                  for C in 1..Transaction(A).Ni
                  loop
                     if (Transaction(A).The_Task(C).Prioij>=
                         Transaction(A).The_Task(B).Prioij)
                       and (Transaction(A).The_Task(C).Procij=
                            Transaction(A).The_Task(B).Procij)
                       and  Transaction(A).The_Task(B).Model /=
                       Unbounded_Effects
                     then
                        P0:=-Long_Int
                          (Floor((Transaction(A).The_Task(B).Jij+
                                  Fijk(A,B,C))/
                                 Transaction(A).The_Task(B).Tijown))+1;
                        P:=P0-1;
                        loop
                           P:=P+1;
                           W_Abc:=W_DO(A,B,C,P-P0+1);
                           R_Abc:=-Fijk(A,B,C)-Time(P-1)*
                             Transaction(A).The_Task(B).Tijown+W_Abc+
                             Transaction(A).The_Task(B).Oij;
                           if R_Abc>Rmax then Rmax:=R_Abc;end if;
                           if Rmax>Analysis_Bound then
                              Done:=False;
                              for K in B..Transaction(A).Ni loop
                                 Transaction(A).The_Task(K).Model:=
                                   Unbounded_Effects;
                                 Transaction(A).The_Task(K).Rij:=Large_Time;
                              end loop;
                           end if;
                           exit when R_Abc<=Transaction(A).The_Task(B).Tijown+
                             Transaction(A).The_Task(B).Oij
                             or Transaction(A).The_Task(B).Model=
                             Unbounded_Effects;
                        end loop;
                     end if;
                  end loop;
                  if Rmax>Transaction(A).The_Task(B).Rij
                  then
                     Done:=False;
                     Transaction(A).The_Task(B).Rij:=Rmax;
                     if B<Transaction(A).Ni then
                        Transaction(A).The_Task(B+1).Jij:=
                          Time'Max(Transaction(A).The_Task(B+1).Oijmax,
                                   Rmax+
                                   Transaction(A).The_Task(B+1).Delayijmax)
                          +Transaction(A).The_Task(B+1).Jinit
                          -Transaction(A).The_Task(B+1).Oij;

                     elsif A<Max_Transactions and then
                       Transaction(A+1).Trans_Input_Type=Internal
                     then
                        Transaction(A+1).The_Task(1).Jij:=
                          Time'Max(Transaction(A+1).The_Task(1).Oijmax,
                                   Rmax+
                                   Transaction(A+1).The_Task(1).Delayijmax)
                          +Transaction(A+1).The_Task(1).Jinit
                          -Transaction(A+1).The_Task(1).Oij;
                     end if;
                  end if;
               end if;
            end loop;

            for B in 1..Transaction(A).Ni loop
               Transaction(A).The_Task(B).Tij:=Aux_Tij(B);
               Transaction(A).The_Task(B).Cij:=Aux_Cij(B);
               Transaction(A).The_Task(B).Cbij:=Aux_Cbij(B);
            end loop;

         end loop;
         exit when Done;
      end loop;

      Translate_Linear_Analysis_Results(Transaction,The_System);
   end Offset_Based_Unoptimized_Analysis;



   procedure Offset_Based_Optimized_Analysis
     (The_System : in out MAST.Systems.System;
      Verbose : in Boolean:=True)
   is

      Max_Processors:constant Processor_ID:=Processor_ID
        (Processing_Resources.Lists.Size
         (The_System.Processing_Resources));
      Max_Transactions:constant Transaction_ID:=
        Transaction_Id((Mast.Max_Numbers.Calculate_Max_Transactions
                        (The_System)));
      Max_Tasks_Per_Transaction:constant Task_ID:=Task_ID
        (Mast.Max_Numbers.Calculate_Max_Tasks_Per_Transaction(The_System));

      subtype Processor_ID_Type is Processor_ID
        range 0..Max_Processors;
      subtype Transaction_ID_Type is Transaction_ID
        range 0..Max_Transactions;
      subtype Task_ID_Type is Task_ID
        range 0..Max_Tasks_Per_Transaction;

      package Translation is new Linear_Translation
        (Processor_ID_Type, Transaction_ID_Type, Task_ID_Type,
         Max_Processors, Max_Transactions,Max_Tasks_Per_Transaction);

      use Translation;
      Transaction : Linear_Transaction_System;

      function FTijk
        (I:Transaction_ID_Type;
         J,K:Task_ID_Type) return Time is
      begin
         return Transaction(I).The_Task(K).Tij-
           Modulus(Transaction(I).The_Task(K).Oij+
                   Transaction(I).The_Task(K).Jij,
                   Transaction(I).The_Task(K).Tij)+
           Transaction(I).The_Task(J).Oij;
      end FTijk;

      ------------
      -- Same_H --
      ------------

      function Same_H
        (I:Transaction_ID_Type;
         J,K:Task_ID_Type;
         Prio:Priority) return Boolean
      is
         Jj,Kk:Task_ID_Type;
      begin
         if J>K then Jj:=K;Kk:=J; else Jj:=J;Kk:=K;end if;
         for L in Jj..Kk
         loop
            if (Transaction(I).The_Task(L).Procij=
                Transaction(I).The_Task(Jj).Procij)
              and(Transaction(I).The_Task(L).Prioij<Prio)
            then
               return False;
            end if;
         end loop;
         return True;
      end Same_H;

      -----------
      -- In_MP --
      -----------

      function In_MP
        (I:Transaction_ID_Type;
         J:Task_ID_Type;
         Prio:Priority;
         Proc:Processor_ID_Type) return Boolean
      is
      begin
         for L in 1..J loop
            if (Transaction(I).The_Task(L).Procij=Proc)
              and(Transaction(I).The_Task(L).Prioij<Prio)
            then
               return False;
            end if;
         end loop;
         return True;
      end In_MP;

      -------------------
      -- First_In_Hseg --
      -------------------

      function First_In_Hseg
        (I:Transaction_ID_Type;
         J:Task_ID_Type;
         Prio:Priority;
         Proc:Processor_ID_Type) return Task_ID_Type
      is
         H:Task_ID_Type;
      begin
         H:=J;
         loop
            exit when (H=1)
              or else ((Transaction(I).The_Task(H-1).Prioij<Prio)
                       or (Transaction(I).The_Task(H-1).Procij/=Proc));
            H:=H-1;
         end loop;
         return H;
      end First_In_Hseg;

      -----------------------
      -- Resolve_Conflicts --
      -----------------------

      function Resolve_Conflicts
        (I:Transaction_ID_Type;
         K:Task_ID_Type;
         T:Time;
         A:Transaction_ID_Type;
         B:Task_ID_Type) return Time
      is
         The_First_P,P0,P0kk:Long_Int;
         Proc:Processor_ID_Type;
         Prio:Priority;
         J,H:Task_ID_Type;
         Total,PLinkial,Sum,Cell:Time;
      begin
         Total:=0.0;
         Proc:=Transaction(A).The_Task(B).Procij;
         Prio:=Transaction(A).The_Task(B).Prioij;
         J:=Transaction(I).Ni;
         loop
            exit when (Transaction(I).The_Task(J).Procij=Proc)
              and(Transaction(I).The_Task(J).Prioij>=Prio);
            J:=J-1;
         end loop;
         H:=First_In_Hseg(I,J,Prio,Proc);
         The_First_P:=Long_Int
           (-Floor
            ((Transaction(I).The_Task(H).Jij+FTijk(I,H,K))
             /Transaction(I).The_Task(K).Tij)+Time'(1.0));
         P0kk:=Long_Int
           (-Floor
            ((Transaction(I).The_Task(K).Jij+FTijk(I,K,K))
             /Transaction(I).The_Task(K).Tij)+Time'(1.0));
         for P in The_First_P..0
         loop
            PLinkial:=0.0;
            Sum:=0.0;
            for J in 1..Transaction(I).Ni
            loop
               if Transaction(I).The_Task(J).Procij=Proc then
                  if Transaction(I).The_Task(J).Prioij>=Prio then
                     Cell:=0.0;
                     H:=First_In_Hseg(I,J,Prio,Proc);
                     P0:=Long_Int
                       (-Floor
                        ((Transaction(I).The_Task(H).Jij+
                          FTijk(I,H,K))
                         /Transaction(I).The_Task(K).Tij)+Time'(1.0));
                     if (P>=P0)and
                       (T>FTijk(I,H,K)+
                        Time(P-1)*Transaction(I).The_Task(K).Tij)
                     then
                        Cell:=Transaction(I).The_Task(J).Cij;
                     end if;
                     if (J>K and P>=P0kk and not
                         Same_H(I,J,K,Prio))
                     then
                        Cell:=0.0;
                     end if;
                     Sum:=Sum+Cell;
                  else
                     Sum:=0.0;
                  end if;
                  if Sum>PLinkial then PLinkial:=Sum;end if;
               end if;
            end loop;
            Total:=Total+PLinkial;
         end loop;
         return Total;
      end;

      ----------------------------
      -- Resolve_Self_Conflicts --
      ----------------------------

      function Resolve_Self_Conflicts
        (A:Transaction_ID_Type;
         B,C:Task_ID_Type;
         T:Time;
         Pa:Long_Int) return Time
      is
         The_First_P,P0,P0cc:Long_Int;
         Proc:Processor_ID_Type;
         Prio:Priority;
         J,H:Task_ID_Type;
         Total,PLinkial,Sum,Cell:Time;
      begin
         Total:=0.0;
         Proc:=Transaction(A).The_Task(B).Procij;
         Prio:=Transaction(A).The_Task(B).Prioij;
         J:=Transaction(A).Ni;
         loop
            exit when (Transaction(A).The_Task(J).Procij=Proc) and
              (Transaction(A).The_Task(J).Prioij>=Prio);
            J:=J-1;
         end loop;
         H:=First_In_Hseg(A,J,Prio,Proc);
         The_First_P:=Long_Int
           (-Floor((Transaction(A).The_Task(H).Jij+
                    FTijk(A,H,C))
                   /Transaction(A).The_Task(C).Tij)+Time'(1.0));
         P0cc:=Long_Int
           (-Floor((Transaction(A).The_Task(C).Jij+
                    FTijk(A,C,C))
                   /Transaction(A).The_Task(C).Tij)+Time'(1.0));
         for P in The_First_P..0
         loop
            PLinkial:=0.0;
            Sum:=0.0;
            for J in 1..Transaction(A).Ni
            loop
               if Transaction(A).The_Task(J).Procij=Proc then
                  if Transaction(A).The_Task(J).Prioij>=Prio then
                     Cell:=0.0;
                     H:=First_In_Hseg(A,J,Prio,Proc);
                     P0:=Long_Int
                       (-Floor
                        ((Transaction(A).The_Task(H).Jij+
                          FTijk(A,H,C))
                         /Transaction(A).The_Task(C).Tij)+Time'(1.0));
                     if (P>=P0)and
                       (T>FTijk(A,H,C)+
                        Time(P-1)*Transaction(A).The_Task(C).Tij)
                     then
                        Cell:=Transaction(A).The_Task(J).Cij;
                     end if;
                     if (J>C) and (P>=P0cc) and not
                       Same_H(A,J,C,Prio)
                     then
                        Cell:=0.0;
                     end if;
                     if (J<B) and (P<=Pa) and not
                       Same_H(A,J,B,Prio)
                     then
                        Cell:=0.0;
                     end if;
                     if ((J>=B)and(P>Pa)) or ((J>B)and(P=Pa)) then
                        Cell:=0.0;
                     end if;
                     Sum:=Sum+Cell;
                  else
                     Sum:=0.0;
                  end if;
                  if Sum>PLinkial then
                     PLinkial:=Sum;
                  end if;
               end if;
            end loop;
            Total:=Total+PLinkial;
         end loop;
         return Total;
      end;

      ------------
      -- Wik_LH --
      ------------

      function Wik_LH
        (I:Transaction_ID_Type;
         K:Task_ID_Type;
         T:Time;
         A:Transaction_ID_Type;
         B:Task_ID_Type) return Time
      is
         Acum:Time;
         Prio:Priority;
         Proc:Processor_ID_Type;
         H:Task_ID_Type;
         Aux_Jitters :
           array (Task_ID_Type range 1..Max_Tasks_Per_Transaction) of Time;
      begin
         if T=0.0 then return Transaction(I).The_Task(K).Cij;end if;

         -- Copy jitter terms into an auxiliar transaction
         -- to make zero all those marked as jitter_avoidance.
         -- Recover the original values at the end of the procedure.
         for J in 1..Transaction(I).Ni loop
            Aux_Jitters(J):=Transaction(I).The_Task(J).Jij;
            if Transaction(I).The_Task(J).Jitter_Avoidance then
               Transaction(I).The_Task(J).Jij:=0.0;
            end if;
         end loop;

         Acum:=Resolve_Conflicts(I,K,T,A,B);
         Proc:=Transaction(A).The_Task(B).Procij;
         Prio:=Transaction(A).The_Task(B).Prioij;
         for J in 1..Transaction(I).Ni
         loop
            if (Transaction(I).The_Task(J).Procij=Proc) and
              In_MP(I,J,Prio,Proc)
            then
               if Transaction(I).The_Task(J).Model=Unbounded_Effects then
                  return Large_Time;
               else
                  H:=First_In_Hseg(I,J,Prio,Proc);
                  Acum:=Acum+Ceil0((T-FTijk(I,H,K))/
                                   Transaction(I).The_Task(J).Tij)*
                    Transaction(I).The_Task(J).Cij;
               end if;
            end if;

         end loop;

         for J in 1..Transaction(I).Ni loop
            Transaction(I).The_Task(J).Jij:=Aux_Jitters(J);
         end loop;

         return Acum;
      end Wik_LH;

      ------------
      -- Wac_LH --
      ------------

      function Wac_LH
        (A:Transaction_ID_Type;
         B,C:Task_ID_Type;
         T:Time;
         P:Long_Int) return Time
      is
         Acum,Post:Time;
         Prio:Priority;
         Proc:Processor_ID_Type;
         H:Task_ID_Type;
         Aux_Jitters : array (Task_ID_Type range 1..Max_Tasks_Per_Transaction)
           of Time;
      begin
         -- Copy jitter terms into an auxiliar transaction
         -- to make zero all those marked as jitter_avoidance.
         -- Recover the original values at the end of the procedure.
         for J in 1..Transaction(A).Ni loop
            Aux_Jitters(J):=Transaction(A).The_Task(J).Jij;
            if Transaction(A).The_Task(J).Jitter_Avoidance then
               Transaction(A).The_Task(J).Jij:=0.0;
            end if;
         end loop;

         Acum:=Resolve_Self_Conflicts(A,B,C,T,P);
         Proc:=Transaction(A).The_Task(B).Procij;
         Prio:=Transaction(A).The_Task(B).Prioij;
         Post:=Time(P)*Transaction(A).The_Task(B).Cijown;
         for J in 1..Transaction(A).Ni
         loop
            if (Transaction(A).The_Task(J).Procij=Proc) and
              In_MP(A,J,Prio,Proc)
            then
               if Transaction(A).The_Task(J).Model=Unbounded_Effects then
                  return Large_Time;
               else
                  H:=First_In_Hseg(A,B,Prio,Proc);
                  if J<B then
                     Acum:=Acum+Ceil0((T-FTijk(A,H,C))/
                                      Transaction(A).The_Task(J).Tij)*
                       Transaction(A).The_Task(J).Cij;
                  end if;
                  if J>B then
                     Post:=Post+Time'Min
                       (Time(P-1),Ceil0((T-FTijk(A,H,C))/
                                        Transaction(A).The_Task(J).Tij))*
                       Transaction(A).The_Task(J).Cij;
                  end if;
               end if;
            end if;
         end loop;

         for J in 1..Transaction(A).Ni loop
            Transaction(A).The_Task(J).Jij:=Aux_Jitters(J);
         end loop;

         return Acum+Time'Max(0.0,Post);
      end Wac_LH;

      -------------
      -- W_DO_LH --
      -------------

      function W_DO_LH
        (A:Transaction_ID_Type;
         B,C:Task_ID_Type;
         P:Long_Int) return Time
      is
         Wc,Wcant,Wc_Ik,MaxWik:Time;
         Prio:Priority;
         Proc:Processor_ID_Type;
         Done:Boolean;
         P0:Long_Int;
      begin
         Proc:=Transaction(A).The_Task(B).Procij;
         Prio:=Transaction(A).The_Task(B).Prioij;
         P0:=-Long_Int(Floor(
                             (Transaction(A).The_Task(B).Jij+
                              FTijk(A,B,C))/
                             Transaction(A).The_Task(B).Tij))+1;
         Wcant:=Time(P-P0+1)*Transaction(A).The_Task(B).Cijown
           +Transaction(A).The_Task(B).Bij;

         --if wcant=0.0 then wcant:=2.0*epsilon;end if;
         loop
            Wc:=Wac_LH(A,B,C,Wcant,P)
              +Transaction(A).The_Task(B).Bij;
            for I in 1..Max_Transactions
            loop
               exit when Transaction(I).Ni=0;
               if I/=A then
                  MaxWik:=0.0;
                  for K in 1..Transaction(I).Ni
                  loop
                     if (Transaction(I).The_Task(K).Procij=Proc)
                       and(Transaction(I).The_Task(K).Prioij>=Prio)
                       and not((I=A)and(K=B))
                       and
                       ((K=1)or else
                        (Transaction(I).The_Task(K-1).Procij/=Proc)
                        or else(Transaction(I).The_Task(K-1).Prioij<Prio))
                     then
                        Wc_Ik:=Wik_LH(I,K,Wcant,A,B);
                        if Wc_Ik>MaxWik then
                           MaxWik:=Wc_Ik;
                        end if;
                     end if;
                  end loop;
                  Wc:=Wc+MaxWik;
               end if;
            end loop;
            Done:=(Wc=Wcant);
            Wcant:=Wc;
            exit when Done;
         end loop;
         return Wc;
      end W_DO_LH;

      -----------------
      -- Busy_Period --
      -----------------

      function Busy_Period
        (A:Transaction_ID_Type;
         B,C:Task_ID_Type) return Time
      is
         Wc,Wcant,Wc_Ik,MaxWik:Time;
         Prio:Priority;
         Proc:Processor_ID_Type;
         Done:Boolean;
      begin
         Proc:=Transaction(A).The_Task(B).Procij;
         Prio:=Transaction(A).The_Task(B).Prioij;
         Wcant:=Transaction(A).The_Task(B).Cijown
           +Transaction(A).The_Task(B).Bij;
         loop
            Wc:=Wik_LH(A,C,Wcant,A,B)
              +Transaction(A).The_Task(B).Bij;
            for I in 1..Max_Transactions
            loop
               exit when Transaction(I).Ni=0;
               if I/=A then
                  MaxWik:=0.0;
                  for K in 1..Transaction(I).Ni
                  loop
                     if (Transaction(I).The_Task(K).Procij=Proc)
                       and(Transaction(I).The_Task(K).Prioij>=Prio)
                       and not((I=A)and(K=B))
                       and ((K=1)or else
                            (Transaction(I).The_Task(K).Delayijmin/=0.0)
                            or else (Transaction(I).The_Task(K).Oijmin/=0.0)
                            or else
                            (Transaction(I).The_Task(K-1).Procij/=Proc)
                            or else(Transaction(I).The_Task(K-1).Prioij<Prio))
                     then
                        Wc_Ik:=Wik_LH(I,K,Wcant,A,B);
                        if Wc_Ik>MaxWik then MaxWik:=Wc_Ik;end if;
                     end if;
                  end loop;
                  Wc:=Wc+MaxWik;
               end if;
            end loop;
            Done:=(Wc=Wcant);
            Wcant:=Wc;
            exit when Done;
         end loop;
         return Wc;
      end Busy_Period;

      ------------------
      -- Calculate_PL --
      ------------------

      function Calculate_PL
        (A:Transaction_ID_Type;
         B,C:Task_ID_Type) return Long_Int
      is
         Prio:Priority;
         Proc:Processor_ID_Type;
         H:Task_ID_Type;
      begin
         Prio:=Transaction(A).The_Task(B).Prioij;
         Proc:=Transaction(A).The_Task(B).Procij;
         H:=First_In_Hseg(A,B,Prio,Proc);
         if In_MP(A,B,Prio,Proc)
         then
            return Long_Int
              (Ceil0((Busy_Period(A,B,C)-
                      FTijk(A,H,C))/
                     Transaction(A).The_Task(C).Tij));
         elsif (C<B) and not Same_H(A,B,C,Prio) then
            return Long_Int
              (-Floor
               ((Transaction(A).The_Task(C).Jij+
                 FTijk(A,C,C))/Transaction(A).The_Task(C).Tij));
         else return 0;
         end if;
      exception
         when Constraint_Error => return Long_Int'Last;
      end Calculate_PL;

      procedure Initialize_Response_Times_And_Jitter
        (Transaction : in out Linear_Transaction_System)
      is
         Act_B,Act_W:Time;
      begin
         for I in 1..Max_Transactions
         loop
            exit when Transaction(I).Ni=0;
            if Transaction(I).Trans_Input_Type=Internal then
               Act_B:=Time'Max
                 (Transaction(I).The_Task(1).Oijmin,
                  Transaction(I-1).The_Task(Transaction(I-1).Ni).Rbij
                  +Transaction(I).The_Task(1).Delayijmin);
               Act_W:=Time'Max
                 (Transaction(I).The_Task(1).Oijmax,
                  Transaction(I-1).The_Task(Transaction(I-1).Ni).Rij
                  +Transaction(I).The_Task(1).Delayijmax)
                 +Transaction(I).The_Task(1).Jinit;
            else
               Act_B:=Time'Max(Transaction(I).The_Task(1).Oijmin,
                               Transaction(I).The_Task(1).Delayijmin);
               Act_W:=Time'Max(Transaction(I).The_Task(1).Oijmax,
                               Transaction(I).The_Task(1).Delayijmax)
                 +Transaction(I).The_Task(1).Jinit;
            end if;

            Transaction(I).The_Task(1).Oij:=Act_B;
            Transaction(I).The_Task(1).Jij:=Act_W-Act_B;
            Transaction(I).The_Task(1).Rbij:=
              Act_B+Transaction(I).The_Task(1).Cbijown;
            Transaction(I).The_Task(1).Rij :=
              Act_W+Transaction(I).The_Task(1).Cijown;

            for L in 2..Transaction(I).Ni loop
               Act_B:=Time'Max(Transaction(I).The_Task(L).Oijmin,
                               Transaction(I).The_Task(L-1).Rbij
                               +Transaction(I).The_Task(L).Delayijmin);
               Act_W:=Time'Max(Transaction(I).The_Task(L).Oijmax,
                               Transaction(I).The_Task(L-1).Rij
                               +Transaction(I).The_Task(L).Delayijmax)
                 +Transaction(I).The_Task(L).Jinit;
               Transaction(I).The_Task(L).Oij:=Act_B;
               Transaction(I).The_Task(L).Jij:=Act_W-Act_B;
               Transaction(I).The_Task(L).Rbij:=
                 Act_B+Transaction(I).The_Task(L).Cbijown;
               Transaction(I).The_Task(L).Rij :=
                 Act_W+Transaction(I).The_Task(L).Cijown;
            end loop;
         end loop;
      end Initialize_Response_Times_and_Jitter;

      P0,PL:Long_Int;
      R_Abc,W_Abc,Rmax:Time;
      Done:Boolean;
      H:Task_ID_Type;
      Old:array(1..Max_Tasks_Per_Transaction) of Time;
      Aux_Tij,Aux_Cij,Aux_Cbij :
        array (Task_ID_Type range 1..Max_Tasks_Per_Transaction)
        of Time;

   begin
      if Verbose then
         New_Line;Put_Line("Offset Based Analysis");
      end if;
      Translate_Linear_System(The_System,Transaction,Verbose);

      Initialize_Response_Times_and_Jitter(Transaction);

      loop
         Done:=True;
         for A in 1..Max_Transactions
         loop
            exit when Transaction(A).Ni=0;
            for B in 1..Transaction(A).Ni loop
               Aux_Tij(B):=Transaction(A).The_Task(B).Tij;
               Transaction(A).The_Task(B).Tij:=
                 Transaction(A).The_Task(B).Tijown;
               Aux_Cij(B):=Transaction(A).The_Task(B).Cij;
               Transaction(A).The_Task(B).Cij:=
                 Transaction(A).The_Task(B).Cijown;
               Aux_Cbij(B):=Transaction(A).The_Task(B).Cbij;
               Transaction(A).The_Task(B).Cbij:=
                 Transaction(A).The_Task(B).Cbijown;
            end loop;
            for B in 1..Transaction(A).Ni loop
               Old(B):=Transaction(A).The_Task(B).Rij;
            end loop;
            for B in 1..Transaction(A).Ni
            loop
               Transaction(A).The_Task(B).Tij:=
                 Transaction(A).The_Task(B).Tijown;
               if Transaction(A).The_Task(B).Model /= Unbounded_Response
                 and Transaction(A).The_Task(B).Model /= Unbounded_Effects
               then
                  H:=First_In_Hseg
                    (A,B,Transaction(A).The_Task(B).Prioij,
                     Transaction(A).The_Task(B).Procij);
                  Rmax:=0.0;
                  for C in 1..Transaction(A).Ni
                  loop

                     if (Transaction(A).The_Task(C).Prioij>=
                         Transaction(A).The_Task(B).Prioij)
                       and(Transaction(A).The_Task(C).Procij=
                           Transaction(A).The_Task(B).Procij)
                       and Transaction(A).The_Task(B).Model /=
                       Unbounded_Effects
                       and
                       ((C=1) or else
                        (Transaction(A).The_Task(C).Delayijmin/=0.0) or else
                        (Transaction(A).The_Task(C).Oijmin/=0.0) or else
                        (Transaction(A).The_Task(C-1).Procij/=
                         Transaction(A).The_Task(B).Procij)
                        or else (Transaction(A).The_Task(C-1).Prioij<
                                 Transaction(A).The_Task(B).Prioij))
                     then
                        P0:=Long_Int
                          (-Floor
                           ((Transaction(A).The_Task(H).Jij+
                             FTijk(A,H,C))/
                            Transaction(A).The_Task(B).Tijown)+Time'(1.0));
                        PL:=Calculate_PL(A,B,C);
                        if PL=Long_Int'Last then
                           for K in B..Transaction(A).Ni loop
                              Transaction(A).The_Task(K).Model:=
                                Unbounded_Effects;
                              Transaction(A).The_Task(K).Rij:=Large_Time;
                           end loop;
                        else
                           for P in P0..PL
                           loop
                              if Transaction(A).The_Task(B).Model/=
                                Unbounded_Effects then
                                 W_Abc:=W_DO_LH(A,B,C,P);

                                 R_Abc:=W_Abc-FTijk(A,B,C)-
                                   Time(P-1)*Transaction(A).The_Task(B).Tijown
                                   +Transaction(A).The_Task(B).Oij;
                                 if R_Abc>Rmax then Rmax:=R_Abc;end if;
                                 if Rmax>Analysis_Bound
                                 then
                                    for K in B..Transaction(A).Ni loop
                                       Transaction(A).The_Task(K).Model:=
                                         Unbounded_Effects;
                                       Transaction(A).The_Task(K).Rij:=
                                         Large_Time;
                                    end loop;
                                 end if;
                              end if;
                           end loop;
                        end if;
                     end if;
                  end loop;
                  if Rmax>Transaction(A).The_Task(B).Rij then
                     Transaction(A).The_Task(B).Rij:=Rmax;
                  end if;

                  -------------------------------------------------
                  -- The analysis needs Oij+Jij to be in non
                  -- decreasing order for the tasks in a transaction
                  -- If we find that case we estimate for the second
                  -- task an Rij equal to the last task's Rij plus
                  -- its own Cij
                  for L in B+1..Transaction(A).Ni
                  loop
                     if Transaction(A).The_Task(L).Rij<
                       Transaction(A).The_Task(L-1).Rij then
                        Transaction(A).The_Task(L).Rij:=
                          Transaction(A).The_Task(L-1).Rij+
                          Transaction(A).The_Task(L).Cij;
                     end if;
                  end loop;
                  -- As a result of applying Lemma 1, the estimation
                  -- for a task ij may be better than for the previous
                  -- task, because the Lemma may be applicable to that
                  -- task ij but not to the preceding one
                  -- In this case, we obtain a worst-case estimation for
                  -- task ij-1 making its response time equal to
                  -- Rij-1 = Rij-Cij}
                  for L in reverse 1..B-1
                  loop
                     if Transaction(A).The_Task(L).Rij>
                       Transaction(A).The_Task(L+1).Rij then
                        Transaction(A).The_Task(L).Rij:=
                          Transaction(A).The_Task(L+1).Rij-
                          Transaction(A).The_Task(L+1).Cij;
                     end if;
                  end loop;

                  -- Reevaluate Jitters
                  for L in 2..Transaction(A).Ni loop
                     Transaction(A).The_Task(L).Jij:=
                       Time'Max(Transaction(A).The_Task(L).Oijmax,
                                Transaction(A).The_Task(L-1).Rij
                                +Transaction(A).The_Task(L).Delayijmax)
                       +Transaction(A).The_Task(L).Jinit
                       -Transaction(A).The_Task(L).Oij ;
                  end loop;

                  if A<Max_Transactions and then
                    Transaction(A+1).Trans_Input_Type=Internal
                  then
                     Transaction(A+1).The_Task(1).Jij:=
                       Time'Max(Transaction(A+1).The_Task(1).Oijmax,
                                Transaction(A).The_Task(Transaction(A).Ni).Rij
                                +Transaction(A+1).The_Task(1).Delayijmax)
                       +Transaction(A+1).The_Task(1).Jinit
                       -Transaction(A+1).The_Task(1).Oij ;
                     for L in 2..Transaction(A+1).Ni loop
                        Transaction(A+1).The_Task(L).Jij:=
                          Time'Max(Transaction(A+1).The_Task(L).Oijmax,
                                   Transaction(A+1).The_Task(L-1).Rij
                                   +Transaction(A+1).The_Task(L).Delayijmax)
                          +Transaction(A+1).The_Task(L).Jinit
                          -Transaction(A+1).The_Task(L).Oij ;
                     end loop;
                  end if;

               end if;

            end loop;

            for B in 1..Transaction(A).Ni loop
               Transaction(A).The_Task(B).Tij:=Aux_Tij(B);
               Transaction(A).The_Task(B).Cij:=Aux_Cij(B);
               Transaction(A).The_Task(B).Cbij:=Aux_Cbij(B);
            end loop;

            for B in 1..Transaction(A).Ni
            loop
               if Old(B)/=Transaction(A).The_Task(B).Rij then
                  Done:=False;
               end if;
            end loop;
         end loop;
         exit when Done;
      end loop;

      Translate_Linear_Analysis_Results(Transaction,The_System);
   end Offset_Based_Optimized_Analysis;

end Mast.Linear_Analysis_Tools;
