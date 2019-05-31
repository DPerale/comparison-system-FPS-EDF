#!/usr/bin/env ruby

#####  NON SERVE CAMBIARE NULLA

class RTA_Calculus

   def initialize taskset
      @taskset = taskset
   end
   

   def setPriorityLevelsRateMonotonic
      i=1;
      @taskset.sort_by! {|t| t.period}.reverse!
      @taskset.each_cons(2).map do |t,n|
         t.prio = i
         if taskset.last == n then
            if t.period == n.period then
               n.prio = i
            else
               n.prio = i + 1
            end
         end
         if t.period == n.period then i else (i += 1) end
      end
   end

   def setPriorityLevelsDeadlineMonotonic
      i=1;
      @taskset.sort_by! {|t| t.dead}.reverse!
      @taskset.each_cons(2).map do |t,n|
         t.prio = i
         if @taskset.last == n then
            if t.dead == n.dead then
               n.prio = i
            else
               n.prio = i + 1
            end
         end
         if t.dead == n.dead then i else (i += 1) end
      end
   end

   def computeRTAforFPS_withBlock
      # Method that compute the feasibility for a taskset under
      # FPS policy with Rate Monotonic method. It computes the same
      # taskset computed by the Baruah rule to test the exact feasibility.

      # setPriorityLevelsRateMonotonic
      setPriorityLevelsDeadlineMonotonic

      @taskset.sort_by! {|t| t.prio}.reverse!
      # @taskset.each do |t|
      #    puts "Prio: #{t.prio}\t Dead: #{t.dead}\t Period: #{t.period}\t Exec: #{t.exec}"
      # end
      i=1
      @taskset.each do |t|
         n = 0
         w = t.exec + t.FPS_InitCost + t.IPCP_BlockValue
         while true
            parts = 0
            @taskset.each do |tt|
               break if tt == t
               parts += (w / tt.period.to_f).ceil *
                        (tt.exec + tt.FPS_CS1 + tt.FPS_CS2)
                        # (tt.exec + tt.FPS_CS)
            end
            w_next = t.exec + parts
            # puts w_next
            if w_next == w then
               if w_next > t.period then
                  return false
               end
               break if true
            end
            if w_next > t.period then
               return false
            end
            w = w_next
            n += 1
         end
      end
      return true
   end

   def computeRTAforEDF_withBlock
      # Now it's time to apply the Baruah extended model to compute
      # the real elaboration load that system can sustain before
      # a crash.
      # We work with Implicit deadlines actually, so our

      maxLoad = 0.0
      dfpWorks = true
      # hyperPeriod = (@taskset.max_by &:period).period
      print @taskset

      periodicArray = @taskset.map(&:period)
      hyperPeriod = periodicArray.reduce(:lcm)

      # @taskset.each do |t|
      #    puts "Prio: #{t.prio}\t Dead: #{t.dead}\t Period: #{t.period}\t Exec: #{t.exec}"
      # end

      # puts "hyperPeriod: " + hyperPeriod.to_s
      @taskset.sort_by! {|t| t.dead}

      @taskset.each do |taskForDead|
         maxH = 0.to_f
         @taskset.each do |task|
            comp = task.EDF_CS1 + task.exec + task.EDF_CS2 # used in original computation
            # comp = task.exec # used for test in forcedTasksets
            val = [0, (((taskForDead.dead - task.dead) / task.period).floor) * comp + comp].max
            maxH = maxH + val
         end
         if taskForDead.dead < (maxH + taskForDead.DFP_BlockValue) then dfpWorks = false end
      end

      @taskset.each do |taskForDead|
         loopTimes = hyperPeriod / taskForDead.dead
         # puts "loopTimes: #{loopTimes}"
         for iter in 1..loopTimes do
            t = (iter * taskForDead.period) - taskForDead.dead
            if t == 0 then t = 1 end
            maxH = 0.to_f
            @taskset.each do |task|
               comp = task.EDF_CS1 + task.exec + task.EDF_CS2 # used in original computation
               # comp = task.exec # used for test in forcedTasksets
               val = [0, (((t - task.dead) / task.period).floor) * comp + comp].max
               maxH = maxH + val
            end
            maxLoad = [maxLoad, (maxH / t)].max
            if maxLoad > 1 then return false, maxLoad end
         end
      end
      if dfpWorks
         return true, maxLoad, hyperPeriod
      else
         return false, maxLoad, hyperPeriod
      end
   end

   def computeRTAforFPS
      # Method that compute the feasibility for a taskset under
      # FPS policy with Rate Monotonic method. It computes the same
      # taskset computed by the Baruah rule to test the exact feasibility.

      # setPriorityLevelsRateMonotonic
      setPriorityLevelsDeadlineMonotonic

      @taskset.sort_by! {|t| t.prio}.reverse!
      # @taskset.each do |t|
      #    puts "Prio: #{t.prio}\t Dead: #{t.dead}\t Period: #{t.period}\t Exec: #{t.exec}"
      # end
      i, x = 1, 1
      @taskset.each do |t|
         n = 0
         w = t.exec + t.FPS_CS1
         while true
            parts = 0
            @taskset.each do |tt|
               break if tt == t
               x += 1
               parts += (w / tt.period.to_f).ceil *
                     (tt.exec + tt.FPS_CS1 + tt.FPS_CS2)
                  #   (tt.exec + tt.FPS_CS)
            end
            w_next = t.exec + parts
            # puts w_next
            if w_next == w then
               if w_next > t.period then
                  return false, x
               end
               break if true
            end
            if w_next > t.period then
               return false, x
            end
            w = w_next
            n += 1
         end
      end
      return true, x
   end

   def computeRTAforEDF
      # Now it's time to apply the Baruah extended model to compute
      # the real elaboration load that system can sustain before
      # a crash.
      # We work with Implicit deadlines actually, so our

      x = 1
      maxLoad = 0.0
      # hyperPeriod = (@taskset.max_by &:period).period
      periodicArray = @taskset.map(&:period)
      hyperPeriod = periodicArray.reduce(:lcm)   

      # @taskset.each do |t|
      #    puts "Prio: #{t.prio}\t Dead: #{t.dead}\t Period: #{t.period}\t Exec: #{t.exec}"
      # end

      # puts "hyperPeriod: " + hyperPeriod.to_s
      @taskset.sort_by! {|t| t.dead}
      @taskset.each do |taskForDead|
         loopTimes = hyperPeriod / taskForDead.dead
         puts "loopTimes: #{loopTimes}\n"
         for iter in 1..loopTimes do
            t = (iter * taskForDead.period) - taskForDead.dead
            if t == 0 then t = 1 end
            maxH = 0.to_f
            @taskset.each do |task|
               x += 1
               # comp = task.EDF_CS + task.exec # used in original computation
               comp = task.EDF_CS1 + task.exec + task.EDF_CS2 # used in original computation
               # comp = task.exec # used for test in forcedTasksets
               val = [0, (((t - task.dead) / task.period).floor) * comp + comp].max
               maxH = maxH + val
            end
            maxLoad = [maxLoad, (maxH / t)].max
            # print t.to_s + ": " + maxLoad.to_s + "\r"
            if maxLoad > 1 then return false, maxLoad, x, hyperPeriod end
         end
      end
      return true, maxLoad, x, hyperPeriod
   end

   
   
   def computeRTAforEDFexact
      arrS = []
      @taskset.sort_by! {|t| t.dead}
      @taskset.each do |task|
        arrS[task] = -1
      end
      
      @taskset.each do |task|
      end
   end
   
   
   def MASTcomputeEDF
      puts "calculating RTA EDF with MAST"
      createMASTinputFILE
      str = "../mast/mast_analysis/mast_analysis edf_monoprocessor ../MASTinput.txt ../MASTinput.out"
      utilization = 0
      minTimeNoDeadlines = 0
      schedulable = 0
      l = 0
      Open3.popen3(str) do |stdin, stdout, stderr, thread|
        stdout.each do |output|
          if output.include?"Utilization" then                     
            s = output.split(" ")
            utilization = s[1].to_f            
          end          
          if output.include?"FirstDeadlineMissAfter" then           
            s = output.split(" ")
            minTimeNoDeadlines = s[1].to_f                       
          end  
          if output.include?"Schedulable" then           
            s = output.split(" ")
            schedulable = s[1].to_i                       
          end      
          if output.include?"L:" then           
            s = output.split(" ")
            l = s[1].to_f                       
          end                   
        end
        
      end
      puts "L: " + l.to_s
      puts "Deadline Miss After: " + minTimeNoDeadlines.to_s
      puts "Schedulable: " + schedulable.to_s
      
      $tot_schedulable.push minTimeNoDeadlines
      $s_For_taskset.push schedulable
      
      periodicArray = @taskset.map(&:period)
      hyperPeriod = periodicArray.reduce(:lcm) 
      maxLoad = 1
      x = 1
      
      recorder = Recorder.new
      recorder.dataRegistrationSoglia((minTimeNoDeadlines.to_f/hyperPeriod.to_f),@taskset)
      
      return true, utilization, x, hyperPeriod
   end


   def createMASTinputFILE     
      ofile = "../MASTinput.txt"
      File.open(ofile, 'w') do |out|
          out.puts "Model ("
          out.puts "   Model_Name  => EDF_RTA_CALCULUS,"
          out.puts "   Model_Date  => 2019-01-01);"
          out.puts ""
          out.puts "Processing_Resource ("
          out.puts "        Type => Regular_Processor,"
          out.puts "        Name => Processor_1);"
          out.puts ""
          out.puts "Scheduler ("
          out.puts "        Type  => Primary_Scheduler,"
          out.puts "        Name  => EDF_Scheduler,"
          out.puts "        Host  => Processor_1,"
          out.puts "        Policy =>"
          out.puts "           (Type => EDF,"
          out.puts "      Worst_Context_Switch => 9));"
          
          i = 1
          @taskset.sort_by! {|t| t.dead}
          
          @taskset.each do |task|          
              out.puts "Scheduling_Server ("
              out.puts "        Type                    => Regular,"
              out.puts "        Name                    => SC"+i.to_s+","
              out.puts "        Server_Sched_Parameters => ("
              out.puts "                Type        => EDF_policy,"
              out.puts "                Deadline    => "+task.dead.to_s+","
              out.puts "                Preassigned => No),"
              out.puts "        Scheduler               => EDF_Scheduler);"
              i = i + 1
          end
              
          i = 1    
          @taskset.each do |task| 
              out.puts "Operation ("
              out.puts "        Type    => Simple,"
              out.puts "        Name    => C"+i.to_s+","
              out.puts "        Worst_Case_Execution_Time => "+task.exec.to_s+");"
              i = i + 1
          end
          
          i = 1    
          @taskset.each do |task| 
              out.puts "Transaction ("
              out.puts "        Type    => Regular,"
              out.puts "        Name    => T"+i.to_s+","
              out.puts "        External_Events => ("
              out.puts "                (Type   => Periodic,"          
              out.puts "                 Name   => E"+i.to_s+","
              out.puts "                 Period => "+task.period.to_s+")),"
              out.puts "        Internal_Events => ("
              out.puts "                (Type   => regular,"
              out.puts "                 name   => O"+i.to_s+","
              out.puts "                 Timing_Requirements => ("
              out.puts "                         Type             => Hard_Global_Deadline,"
              out.puts "                         Deadline         => "+task.dead.to_s+","
              out.puts "                         referenced_event => E"+i.to_s+"))),"
              out.puts "        Event_Handlers => ("
              out.puts "                (Type                => Activity,"
              out.puts "                 Input_Event         => E"+i.to_s+","
              out.puts "                 Output_Event        => O"+i.to_s+","
              out.puts "                 Activity_Operation  => C"+i.to_s+","
              out.puts "                 Activity_Server     => SC"+i.to_s+")));"
              i = i + 1
          end
      end
   end
     
   
   
   
   def Extact_MaxPrio_MinDead
      return @taskset.max_by(&:prio).prio, @taskset.min_by(&:dead).dead
   end
end
