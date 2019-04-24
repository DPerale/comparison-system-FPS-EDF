#!/usr/bin/env ruby


##### DFP TEST DA CAMBIARE

require_relative 'basictask'
require_relative 'parameters_extended'
require_relative 'rta_calculus'
# require_relative 'parameters_limited'

class Generator
   # It applies RTA algorithm: in this way task periods are computed
   # as power of 2 to perform a quickly computation of the hyperPeriod
   attr_accessor :taskset
   attr_accessor :param

   def initialize
      @taskset = Array.new
      @param = Parameters_Extended.new
   end

   def generateDataset_withBlock mode, type, nums
      # Generates the new Dataset and return set summary data.
      # It writes the basic data_struct01.ads in the main directory
      timeStamp = Time.now
      num_of_short, num_of_mid, num_of_long = taskTypeNum nums
      case mode
      when "i" # implicit
         generateImplicitTaskset num_of_short, num_of_mid, num_of_long, type
      when "c" # constrained
         generateConstrainedTaskset num_of_short, num_of_mid, num_of_long, type
      when "a" # arbitrary
         generateArbitraryTaskset num_of_short, num_of_mid, num_of_long, type
      when "m" # mixed
         # if none of them is specified, we generate a mixed deadlines taskset
         shortImp = rand 1..(num_of_short - 1)
         shortImp = 0 if shortImp.nil?
         shortCon = rand 1..(num_of_short - shortImp - 1).to_i
         shortCon = 0 if shortCon.nil?
         shortArb = num_of_short - shortImp - shortCon
         shortArb = 0 if shortArb.nil?
         midImp = rand 1..(num_of_mid - 1).to_i
         midImp = 0 if midImp.nil?
         midCon = rand 1..(num_of_mid - midImp - 1).to_i
         midCon = 0 if midCon.nil?
         midArb = num_of_mid - midImp - midCon
         midArb = 0 if midArb.nil?
         longImp = rand 1..(num_of_long - 1).to_i
         longImp = 0 if longImp.nil?
         longCon = rand 1..(num_of_long - longImp - 1).to_i
         longCon = 0 if longCon.nil?
         longArb = num_of_long - longImp - longCon
         longArb = 0 if longArb.nil?
         generateImplicitTaskset shortImp, midImp, longImp, type
         generateConstrainedTaskset shortCon, midCon, longCon, type
         generateArbitraryTaskset shortArb, midArb, longArb, type
      else
         raise 'Error size in generateDataset'
      end
      rta_calculus = RTA_Calculus.new @taskset
      feasibilityEDF, maxLoadEDF, hyperperiod = rta_calculus.computeRTAforEDF_withBlock
      feasibilityFPS = rta_calculus.computeRTAforFPS_withBlock
      printDataFile_withBlock
      totalTasks = num_of_short + num_of_mid + num_of_long
      maxPrio, minDead = Extact_MaxPrio_MinDead
      return timeStamp, totalTasks, num_of_short, num_of_mid, num_of_long, feasibilityEDF, maxLoadEDF, hyperperiod, feasibilityFPS, maxPrio, minDead
   end

   def generateDataset mode, type
      # Generates the new Dataset and return set summary data.
      # It writes the basic data_struct01.ads in the main directory
      timeStamp = Time.now
      num_of_short, num_of_mid, num_of_long = taskTypeNum type
      case mode
      when "i" # implicit
         generateImplicitTaskset num_of_short, num_of_mid, num_of_long, type
      when "c" # constrained
         generateConstrainedTaskset num_of_short, num_of_mid, num_of_long, type
      when "a" # arbitrary
         generateArbitraryTaskset num_of_short, num_of_mid, num_of_long, type
      when "m" # mixed
         # if none of them is specified, we generate a mixed deadlines taskset
         shortImp = rand 1..(num_of_short - 1)
         shortImp = 0 if shortImp.nil?
         shortCon = rand 1..(num_of_short - shortImp - 1).to_i
         shortCon = 0 if shortCon.nil?
         shortArb = num_of_short - shortImp - shortCon
         shortArb = 0 if shortArb.nil?
         midImp = rand 1..(num_of_mid - 1).to_i
         midImp = 0 if midImp.nil?
         midCon = rand 1..(num_of_mid - midImp - 1).to_i
         midCon = 0 if midCon.nil?
         midArb = num_of_mid - midImp - midCon
         midArb = 0 if midArb.nil?
         longImp = rand 1..(num_of_long - 1).to_i
         longImp = 0 if longImp.nil?
         longCon = rand 1..(num_of_long - longImp - 1).to_i
         longCon = 0 if longCon.nil?
         longArb = num_of_long - longImp - longCon
         longArb = 0 if longArb.nil?
         generateImplicitTaskset shortImp, midImp, longImp, type
         generateConstrainedTaskset shortCon, midCon, longCon, type
         generateArbitraryTaskset shortArb, midArb, longArb, type
      else
         raise 'Error size in generateDataset'
      end
      rta_calculus = RTA_Calculus.new @taskset
      feasibilityEDF, maxLoadEDF, iterEDF, hyperPeriod = rta_calculus.computeRTAforEDF
      feasibilityFPS, iterFPS = rta_calculus.computeRTAforFPS
      printDataFile hyperPeriod
      totalTasks = num_of_short + num_of_mid + num_of_long
      return timeStamp, totalTasks, num_of_short, num_of_mid, num_of_long,
               feasibilityEDF, maxLoadEDF, iterEDF, hyperPeriod, feasibilityFPS, iterFPS
   end

   def taskTypeNum type
      # Here we generate numerosity of the taskset so we can create
      # different tasksets with different charateristics
      case type
      when "1"
         a = rand @param.short_num_task_range_1
         b = rand @param.mid_num_task_range_1
         c = rand @param.long_num_task_range_1
      when "2"
         a = rand @param.short_num_task_range_2
         b = rand @param.mid_num_task_range_2
         c = rand @param.long_num_task_range_2
      when "3"
         a = rand @param.short_num_task_range_3
         b = rand @param.mid_num_task_range_3
         c = rand @param.long_num_task_range_3
      when "4"
         a = rand @param.short_num_task_range_4
         b = rand @param.mid_num_task_range_4
         c = rand @param.long_num_task_range_4
      when "5"
         a = rand @param.short_num_task_range_5
         b = rand @param.mid_num_task_range_5
         c = rand @param.long_num_task_range_5
      when "6"
         a = rand @param.short_num_task_range_6
         b = rand @param.mid_num_task_range_6
         c = rand @param.long_num_task_range_6
      when "7"
         a = rand @param.short_num_task_range_7
         b = rand @param.mid_num_task_range_7
         c = rand @param.long_num_task_range_7
      else
         raise 'Error in numbering taskTypeNum'
      end
      return a, b, c
   end

   
   
   def generateSingleTask (size, mode, alreadyPicked)
      # Generates the task modality
      ret = 0
      case mode      
      when "implicit"
         case size
         when "short"             
            p = rand @param.short_period_demo_mixed
            while alreadyPicked.include? p
              p = rand @param.short_period_demo_mixed
            end
            ret = p
            e = rand @param.short_impl_exec_range
         when "mid"
            p = rand @param.mid_period_demo_mixed
            while alreadyPicked.include? p
              p = rand @param.short_period_demo_mixed
            end
            ret = p
            e = rand @param.mid_impl_exec_range
         when "long"
            p = rand @param.long_period_demo_mixed
            while alreadyPicked.include? p
              p = rand @param.long_period_demo_mixed
            end
            ret = p
            e = rand @param.long_impl_exec_range
         else
            raise 'Error size in generateSingleTask'
         end
         d = p
      when "constrained"
         case size
         when "short"
            p = rand @param.short_period_demo_mixed
            e = rand @param.short_constr_exec_range
            begin
               d = rand @param.short_constr_dead_demo_mixed
            end while d >= p
         when "mid"
            p = rand @param.mid_period_demo_mixed
            e = rand @param.mid_constr_exec_range
            begin
               d = rand @param.mid_constr_dead_demo_mixed
            end while d >= p
         when "long"
            p = rand @param.long_period_demo_mixed
            e = rand @param.long_constr_exec_range
            begin
               d = rand @param.long_constr_dead_demo_mixed
            end while d >= p
         else
            raise 'Error size in generateSingleTask'
         end
      else
         raise 'Error size in generateSingleTask'
      end

      dead = expSolver (d)
      period = expSolver (p)
      t = BasicTask.new 0, dead, period, 0, e

      @taskset.push t
      return ret
   end

   def expSolver (code)
      puts code
      code = code - 1
      a = Array.new
      a = @param.exponentsDemo.to_a.product([code])
      # puts a
      # puts "2 ^ #{a[code][0][0][0]} * 3 ^ #{a[code][0][0][1]} "\
      #      "5 ^ #{a[code][0][0][2]} * 7 ^ #{a[code][0][0][3]}"
      print "ciao      "
      print a[code][0][0][0]
      print "      "
      print a[code][0][0][1]
      print "      "
      print a[code][0][0][2]
      print "      "
      puts a[code][0][0][3]
      value = 2 ** a[code][0][0][0] *
              3 ** a[code][0][0][1] *
              5 ** a[code][0][0][2] *
              7 ** a[code][0][0][3]
      return value
   end

   def generateImplicitTaskset (short, mid, long, type)
      alreadyPicked = []
      for i in 0..short-1
         n = generateSingleTask "short", "implicit", alreadyPicked
         alreadyPicked.push(n)
      end
      for i in 0..mid-1
         n = generateSingleTask "mid", "implicit", alreadyPicked
         alreadyPicked.push(n)
      end
      for i in 0..long-1
         n = generateSingleTask "long", "implicit", alreadyPicked
         alreadyPicked.push(n)
      end
      alreadyPicked.clear
   end

   def generateConstrainedTaskset (short, mid, long, type)
      for i in 0..short
         generateSingleTask "short", "constrained"
      end
      for i in 0..mid
         generateSingleTask "mid", "constrained"
      end
      for i in 0..long
         generateSingleTask "long", "constrained"
      end
   end

   def generateArbitraryTaskset (short, mid, long, type)
      for i in 0..short
         generateSingleTask "short", "arbitrary"
      end
      for i in 0..mid
         generateSingleTask "mid", "arbitrary"
      end
      for i in 0..long
         generateSingleTask "long", "arbitrary"
      end
   end

   def forcedTaskset
      t1 = BasicTask.new 0, 16, 2, 1, 1.8
      @taskset.push t1
      t2 = BasicTask.new 0, 17, 80, 2, 14.4
      @taskset.push t2
   end

   def forcedTaskset2
      t1 = BasicTask.new 0,  8000000,  8000000, 1, 3000000
      @taskset.push t1
      t2 = BasicTask.new 0, 12000000, 12000000, 2, 3000000
      @taskset.push t2
      t3 = BasicTask.new 0, 20000000, 20000000, 3, 5000000
      @taskset.push t3
   end

   def forcedTaskset3Unfeasible
      t1 = BasicTask.new 1, 4000000, 4000000, 1, 2000000
      t2 = BasicTask.new 2, 5000000, 5000000, 2, 2000000
      t3 = BasicTask.new 3, 7000000, 7000000, 3, 1000000
      t4 = BasicTask.new 4, 8000000, 8000000, 4, 1000000
      t5 = BasicTask.new 5, 9000000, 9000000, 5, 3000000
      @taskset.push t1
      @taskset.push t2
      @taskset.push t3
      @taskset.push t4
      @taskset.push t5
   end

   def datasetReplacement (timeStamp)
      # This procedure replace the old data_struct01.ads file and puts it
      # in a specific directory
      timeStampStr = timeStamp.strftime("%Y-%m-%d %H:%M:%S.%6L")
      timeStampStr.gsub! " ", "_"
      Open3.popen3("cp ../cyclic_tasks.adb ../workspace/"\
                   "autoruby/taskset/#{timeStampStr}") do |stdin, stdout, stderr, thread|
         thread.value
      end
      Open3.popen3("cp ../cyclic_tasks.adb ../edf-ravenscar-arm/src/") do |stdin, stdout, stderr, thread|
         thread.value
      end
      Open3.popen3("mv ../cyclic_tasks.adb ../prio-ravenscar-arm/src/") do |stdin, stdout, stderr, thread|
         thread.value
      end
      puts "Datasets #{timeStampStr} Timestamped and Storaged."
   end

   def datasetReplacement_withBlock timeStamp, maxPrio, minDead
      # This procedure replace the old data_struct01.ads file and puts it
      # in a specific directory
      timeStampStr = timeStamp.strftime("%Y-%m-%d %H:%M:%S.%6L")
      timeStampStr.gsub! " ", "_"
      Open3.popen3("cp ../dfp_data_struct01.ads ../workspace/"\
                   "autoruby/taskset/#{timeStampStr}") do |stdin, stdout, stderr, thread|
         thread.value
      end
      Open3.popen3("cp ../dfp_data_struct01.ads ../edf-ravenscar-arm/src/") do |stdin, stdout, stderr, thread|
         thread.value
      end
      Open3.popen3("mv ../dfp_data_struct01.ads ../prio-ravenscar-arm/src/") do |stdin, stdout, stderr, thread|
         thread.value
      end

      ##################################################33
      ##################################################33
      ### va modificato il file contenente i dati di definizione degli oggetti protetti ovvero
      ### dfp_test_procedure.ads

      lines = File.readlines('../edf-ravenscar-arm/src/dfp_test_procedure.ads')
      lines[11] = "\t\tpragma Priority (#{minDead});" << $/
      File.open('../edf-ravenscar-arm/src/dfp_test_procedure.ads', 'w') { |f| f.write(lines.join) }

      lines = File.readlines('../prio-ravenscar-arm/src/dfp_test_procedure.ads')
      lines[11] = "\t\tpragma Priority (#{maxPrio});" << $/
      File.open('../prio-ravenscar-arm/src/dfp_test_procedure.ads', 'w') { |f| f.write(lines.join) }

      puts "Datasets #{timeStampStr} Timestamped and Storaged."
   end

   def printDataFile (hyperPeriod)
      # It generates the output file which will be the input for
      # the next procedure.
      i = 1;
      ofile = "../cyclic_tasks.adb"
      File.open(ofile, 'w') do |out|
        out.puts "with Ada.Real_Time; use Ada.Real_Time;"
        out.puts "with System_Time;"
        out.puts "with System.Task_Primitives.Operations;"
        out.puts "with System.BB.Time;"
        out.puts "with System.BB.Threads;"
        out.puts "with System.BB.Threads.Queues;"
        out.puts "with Print_Task;"
        out.puts ""
        out.puts "package body Cyclic_Tasks is"
        out.puts ""
        out.puts "   task body Cyclic is"
        out.puts "      Task_Static_Offset : constant Time_Span :="
        out.puts "               Ada.Real_Time.Microseconds (500000);"
        out.puts ""
        out.puts "      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time"
        out.puts "            + System_Time.Task_Activation_Delay + Task_Static_Offset;"
        out.puts ""
        out.puts "      Period : constant Ada.Real_Time.Time_Span :="
        out.puts "               Ada.Real_Time.Microseconds (Cycle_Time);"
        out.puts ""
        out.puts "--      type Proc_Access is access procedure (X : in out Integer);"
        out.puts ""
        out.puts "--    function Time_It (Action : Proc_Access; Arg : Integer) return Duration;"
        out.puts "--    function Time_It (Action : Proc_Access; Arg : Integer) return Duration is"
        out.puts "--         Start_Time : constant Time := Clock;"
        out.puts "--         Finis_Time : Time;"
        out.puts "--         Func_Arg : Integer := Arg;"
        out.puts "--      begin"
        out.puts "--         Action (Func_Arg);"
        out.puts "--         Finis_Time := Clock;"
        out.puts "--         return To_Duration (Finis_Time - Start_Time);"
        out.puts "--      end Time_It;"
        out.puts ""
        out.puts "      procedure Gauss (Times : Integer);"
        out.puts "      procedure Gauss (Times : Integer) is"
        out.puts "         Num : Integer := 0;"
        out.puts "      begin"
        out.puts "         for I in 1 .. Times loop"
        out.puts "            Num := Num + I;"
        out.puts "         end loop;"
        out.puts "      end Gauss;"
        out.puts "--    Gauss_Access : constant Proc_Access := Gauss'Access;"   
        out.puts "      Temp : Integer;"
        out.puts ""
        out.puts "   begin"
        out.puts "      System.Task_Primitives.Operations.Set_Relative_Deadline"
        out.puts "         (System.Task_Primitives.Operations.Self,"
        out.puts "          System.BB.Time.Microseconds (Dead));"
        out.puts "      System.BB.Threads.Set_Fake_Number_ID (T_Num);"
        out.puts "      System.BB.Threads.Queues.Initialize_Task_Table (T_Num);"
        out.puts ""
        out.puts "      loop"
        out.puts "         delay until Next_Period;"
        out.puts ""
        out.puts "--       System.IO.Put_Line (\"Gauss(\" & Integer'Image (Gauss_Num) & \") takes\""
        out.puts "--              & Duration'Image (Time_It (Gauss_Access, Gauss_Num))"
        out.puts "--                    & \" seconds\");"
        out.puts "         Temp := Gauss_Num;"
        out.puts "         Gauss (Temp);"
        out.puts ""
        out.puts "         Next_Period := Next_Period + Period;"
        out.puts "      end loop;"
        out.puts "   end Cyclic;"
        out.puts ""
        out.puts "   procedure Init is"
        out.puts "   begin"
        out.puts "      System.Task_Primitives.Operations.Set_Relative_Deadline"
        out.puts "        (System.Task_Primitives.Operations.Self,"
        out.puts "          System.BB.Time.Milliseconds (Integer'Last));"
        out.puts "      loop"
        out.puts "         null;"
        out.puts "      end loop;"
        out.puts "   end Init;"
        out.puts ""
        out.puts "   P1 : Print_Task.Print (240, -"+(hyperPeriod/1000).to_s+", " + (hyperPeriod/1000).to_s + "); -- period in milliseconds"
        
          
        

         # @taskset.each do |t|
         #    puts "Prio: #{t.prio}\t Dead: #{t.dead} => #{t.deadInMicroseconds}\t"\
         #         " Period: #{t.period} => #{t.periodInMicroseconds}\t Exec: "\
         #         "#{t.exec} => #{t.execInOperations}"
         # end

         @taskset.each do |t|
            print t.deadInMicroseconds
            print ", "
            str = "   C#{i} : Cyclic (#{t.prio}, #{t.deadInMicroseconds},"\
                  " #{t.periodInMicroseconds}, #{i}, #{t.execInOperations});"
            out.puts str
            i += 1;
         end
         out.puts "end Cyclic_Tasks;"
      end
   end

   def printDataFile_withBlock
      # It generates the output file which will be the input for
      # the next procedure.
      i = 1;
      ofile = "../dfp_data_struct01.ads"
      File.open(ofile, 'w') do |out|
         out.puts "with DFP_Test_Procedure; use DFP_Test_Procedure;"
         out.puts ""
         out.puts "package DFP_Data_Struct01 is"

         # @taskset.each do |t|
         #    puts "Prio: #{t.prio}\t Dead: #{t.dead} => #{t.deadInMicroseconds}\t"\
         #         " Period: #{t.period} => #{t.periodInMicroseconds}\t Exec: "\
         #         "#{t.exec} => #{t.execInOperations}"
         # end
         @taskset.each do |t|
            if i == 1 or i == @taskset.length then
               str = "   C#{i} : Cyclic_Protection (#{t.prio}, #{t.deadInMicroseconds},"\
                     " #{t.periodInMicroseconds}, #{i}, #{t.execInOperations});"
               out.puts str
            else
               str = "   C#{i} : Cyclic (#{t.prio}, #{t.deadInMicroseconds},"\
                     " #{t.periodInMicroseconds}, #{i}, #{t.execInOperations});"
               out.puts str
            end
            i += 1;
         end
         out.puts "end DFP_Data_Struct01;"
         out.puts ""
      end
   end
end



#############
### DEBUG ###
#############

# gen = Generator.new
# gen.expSolver 10
# num_of_short, num_of_mid, num_of_long = gen.taskTypeNum "1"
# gen.generateImplicitTaskset num_of_short, num_of_mid, num_of_long, "mix"
# # puts "Implicit"
# # gen.generateArbitraryTaskset num_of_short, num_of_mid, num_of_long
# # puts "Arbitrary"
# # gen.generateConstrainedTaskset num_of_short, num_of_mid, num_of_long
# # puts "Constrained"
# gen.forcedTaskset3Unfeasible
# gen.Extact_MaxPrio_MinDead
# aaa, maxL = gen.computeRTAforEDF_withBlock
# puts "----- #{gen.taskset.length} -----"
# bbb = gen.computeRTAforFPS_withBlock
# puts "----- #{gen.taskset.length} -----"
# gen.printDataFile
# puts "EDF: #{aaa} - LOAD: #{maxL} - FPS: #{bbb}"
