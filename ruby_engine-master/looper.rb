#!/usr/bin/env ruby

require_relative 'compiler'
require_relative 'generator'
require_relative 'simulator'
require_relative 'recorder'


#### VERIFICARE CARTELLA RISULTATI, AGGIUNGERE IL RESTO DELLE UNIT SUL PROGETTO

class Looper

   # def initialize
   #    @compiler = Compiler.new
   # end

   #### DEBUGGED
   def looperForLocalTests loops, mode, type, flag
      i=1;
      if flag then
       compiler = Compiler.new
       puts "0) Cleaning Environment."
       #compiler.cleanAll
       puts "0) Compiling Libraries."
       #compiler.compileLibs
      end
      puts "\n"
      loops.times do
         generator = Generator.new
         timeStamp, totalTasks, short, mid, long, feasibilityEDF,
         maxLoadEDF, iterEDF, hyperPeriod, feasibilityFPS, iterFPS = generator.generateDataset mode, type
         puts "#{i}/#{loops}) Dataset Generated. Total: #{totalTasks}."
         puts "Shorts: #{short}\t Mids: #{mid}\t Long: #{long}"
         generator.datasetReplacement timeStamp
         puts "#{i}/#{loops}) Dataset Replaced."
         if not flag then
            compiler.compileUnit "unit01"
            puts "#{i}/#{loops}) Units Compiled."
            puts "#{i}/#{loops}) Registering Data: EDF Feasibility: #{feasibilityEDF.to_s.upcase} "\
            "with: #{maxLoadEDF} %."
            simulator = Simulator.new
            #arm-eabi-gnatemu -P/home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01.gpr /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01
            arr =
               simulator.execGlobalTestLocal "arm-eabi-gnatemu -P/home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01.gpr /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01", totalTasks   
            #puts "#{i}/#{loops}) EDF Test Completed."
            #puts "#{i}/#{loops}) Execs: #{edf_execs}\t Deads: #{edf_deads}\t Preemps: #{edf_preem}"
            #puts "#{i}/#{loops}) Registering Data: FPS Feasibility: #{feasibilityFPS.to_s.upcase}."            
 #           fps_execs, fps_deads, fps_preem, hash_fps_dead, hash_fps_map, hash_fps_exec =
 #              simulator.execGlobalTestLocal "arm-eabi-gnatemu -P/home/aquox/Scrivania/Arm/prio-ravenscar-arm/unit01.gpr /home/aquox/Scrivania/Arm/prio-ravenscar-arm/unit01"
 #           puts "#{i}/#{loops}) FPS Test Completed."
 #           puts "#{i}/#{loops}) Execs: #{fps_execs}\t Deads: #{fps_deads}\t Preemps: #{fps_preem}"
            recorder = Recorder.new
            recorder.dataRegistration timeStamp, mode, totalTasks, short, mid, long,
               feasibilityEDF, maxLoadEDF, iterEDF, feasibilityFPS, iterFPS, arr 
               #edf_execs, edf_deads, edf_preem, fps_execs, fps_deads, fps_preem, hash_edf_dead,
               #hash_edf_map, hash_edf_exec, hash_fps_dead, hash_fps_map, hash_fps_exec
            puts "#{i}/#{loops}) Data Registered Correctly."
         else
#            puts "#{i}/#{loops}) Testing EDF Dataset: EDF Feasibility: "\
#            "#{feasibilityEDF.to_s.upcase} with: #{maxLoadEDF} %."
#            puts "#{i}/#{loops}) Testing FPS Dataset: FPS Feasibility: "\
#            "#{feasibilityFPS.to_s.upcase}."
#            puts "#{i}/#{loops}) Test Ended Correctly."
         end
         puts "\n"
         i +=1
      end
      puts $tot_schedulable
      puts $s_For_taskset
   end

   #################################3
   ## Used only for manual executions: it does not enable any automatic
   ## modification but compiles and executes code
   ##################################
   def looperForLocalTests_short
      puts "0) Cleaning Environment."
      cleanAll
      puts "0) Compiling Libraries."
      compileLibs
      compileUnit05
      puts "0) Units Compiled."
      edf_execs, edf_deads, edf_preem, hash_fps =
         execGlobalTestLocal_withBlock "arm-eabi-gnatemu --board=stm32f4 ../edf-ravenscar-arm/unit05"
      puts "0) EDF Test Completed."
      puts "0) Execs: #{edf_execs}\t Deads: #{edf_deads}\t Preemps: #{edf_preem}"
      fps_execs, fps_deads, fps_preem, hash_fps =
         execGlobalTestLocal_withBlock "arm-eabi-gnatemu --board=stm32f4 ../prio-ravenscar-arm/unit05"
      puts "0) FPS Test Completed."
      puts "0) Execs: #{fps_execs}\t Deads: #{fps_deads}\t Preemps: #{fps_preem}"
      dataRegistration_short edf_execs, edf_deads, edf_preem, fps_execs, fps_deads, fps_preem
      puts "0) Data Registered Correctly."
      puts "\n"
   end

   def testSets_withBlock loops, mode
      i=1;
      puts "\n"
      loops.times do
         timeStamp, totalTasks, short, mid, long, feasibilityEDF,
         maxLoadEDF, feasibilityFPS = generateDataset_withBlock mode
         puts "#{i}/#{loops}) Dataset Generated. Total: #{totalTasks}."
         puts "Shorts: #{short}\t Mids: #{mid}\t Long: #{long}"
         puts "#{i}/#{loops}) Testing EDF Dataset: EDF Feasibility: "\
         "#{feasibilityEDF.to_s.upcase} with: #{maxLoadEDF} %."
         puts "#{i}/#{loops}) Testing FPS Dataset: FPS Feasibility: "\
         "#{feasibilityFPS.to_s.upcase}."
         puts "#{i}/#{loops}) Test Ended Correctly."
         puts "\n"
         i +=1
      end
   end

   def looperForLocalTests_withBlock loops, mode, type
      i=1;
      puts "0) Cleaning Environment."
      cleanAll
      puts "0) Compiling Libraries."
      compileLibs
      puts "\n"
      loops.times do
         timeStamp, totalTasks, short, mid, long, feasibilityEDF,
         maxLoadEDF, feasibilityFPS, maxPrio, minDead = generateDataset_withBlock mode, type
         puts "#{i}/#{loops}) Dataset Generated. Total: #{totalTasks}."
         puts "Shorts: #{short}\t Mids: #{mid}\t Long: #{long}"
         datasetReplacement_withBlock timeStamp, maxPrio, minDead
         puts "#{i}/#{loops}) Dataset Replaced."
         compileUnit05
         puts "#{i}/#{loops}) Units Compiled."
         puts "#{i}/#{loops}) Registering Data: EDF Feasibility: #{feasibilityEDF.to_s.upcase} "\
         "with: #{maxLoadEDF} %."
         edf_execs, edf_deads, edf_preem, hash_edf =
            execGlobalTestLocal_withBlock "arm-eabi-gnatemu --board=stm32f4 ../edf-ravenscar-arm/unit05"
         puts "#{i}/#{loops}) EDF Test Completed."
         puts "#{i}/#{loops}) Execs: #{edf_execs}\t Deads: #{edf_deads}\t Preemps: #{edf_preem}"
         puts "#{i}/#{loops}) Registering Data: FPS Feasibility: #{feasibilityFPS.to_s.upcase}."
         fps_execs, fps_deads, fps_preem, hash_fps =
            execGlobalTestLocal_withBlock "arm-eabi-gnatemu --board=stm32f4 ../prio-ravenscar-arm/unit05"
         puts "#{i}/#{loops}) FPS Test Completed."
         puts "#{i}/#{loops}) Execs: #{fps_execs}\t Deads: #{fps_deads}\t Preemps: #{fps_preem}"
         dataRegistration timeStamp, mode, totalTasks, short, mid, long,
         feasibilityEDF, maxLoadEDF, feasibilityFPS, edf_execs,
         edf_deads, edf_preem, fps_execs, fps_deads, fps_preem
         puts "#{i}/#{loops}) Data Registered Correctly."
         puts "\n"
         i +=1
      end
   end

   def cleaner (argument)
      timeStamp = ((Time.now).strftime("%Y-%m-%d %H:%M:%S.%6L")).gsub! " ", "_"
      Open3.popen3("mv ../results.csv history_data/#{timeStamp}_#{argument}.csv") do |stdin, stdout, stderr, thread|
         thread.value
      end
      Open3.popen3("cat ../workspace2/results.csv >> ../workspace/ruby_engine/history_data/#{timeStamp}_#{argument}.csv; rm ../workspace2/results.csv") do |stdin, stdout, stderr, thread|
         thread.value
      end
      Open3.popen3("cat ../workspace3/results.csv >> ../workspace/ruby_engine/history_data/#{timeStamp}_#{argument}.csv; rm ../workspace3/results.csv") do |stdin, stdout, stderr, thread|
         thread.value
      end
      Open3.popen3("cat ../workspace4/results.csv >> ../workspace/ruby_engine/history_data/#{timeStamp}_#{argument}.csv; rm ../workspace4/results.csv") do |stdin, stdout, stderr, thread|
         thread.value
      end
      puts "Backup Done. Cleaning Operations Terminated."
   end

   def cloneIstances
      Open3.popen3("cp *.rb ../workspace2/ruby_engine/") do |stdin, stdout, stderr, thread|
         thread.value
      end
      Open3.popen3("cp *.rb ../workspace3/ruby_engine/") do |stdin, stdout, stderr, thread|
         thread.value
      end
      Open3.popen3("cp *.rb ../workspace4/ruby_engine/") do |stdin, stdout, stderr, thread|
         thread.value
      end
      puts "Programs Duplicated."
   end

end
