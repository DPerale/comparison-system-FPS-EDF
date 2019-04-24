#!/usr/bin/env ruby

###### APPOSTO


class BasicTask

   # la classe contiene la struttura base per la creazione del
   # task base da aggiungere al taskset
   attr_accessor :prio
   attr_accessor :dead
   attr_accessor :period
   attr_accessor :id
   attr_accessor :exec
   attr_accessor :EDF_CS1
   attr_accessor :EDF_CS2
   attr_accessor :FPS_CS1
   attr_accessor :FPS_CS2

   # All the attributes are expressed in cycles to perform
   # easily all time constraints. Then the
   def initialize (prio, dead, period, id, exec)
      @prio = prio
      @dead = dead
      @period = period
      @id = id
      @exec = exec
      @EDF_CS1 = 67996 # 251552
      @EDF_CS2 = 56214 # 182851
      @FPS_CS1 = 65364
      @FPS_CS2 = 54052
   end

   def periodInMicroseconds
      return (@period ).to_i
   end

   def deadInMicroseconds
      return (@dead ).to_i
   end

   ## Da vedere quanti cicli fa un'operazione
   def execInOperations
      return (((@exec - 117) / 168) * 36).to_i
   end

   def EDF_InitCost (taskNumber)
      return ((67573 * taskNumber) + 86366270)
   end

   ## Capire perchè usato su RTA FPS
   def FPS_InitCost (taskNumber)
      return ((65520 * taskNumber) + 86364541)
   end

   def DFP_BlockValue
      return (650000 + 282352 + 64209 + 146333)
   end

   def IPCP_BlockValue
      return (650000 + 274477 + 59269 + 71571)
   end

   def computeDeadlineFloor (int)
      return int * 50
   end
end
