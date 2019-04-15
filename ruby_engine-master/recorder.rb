#!/usr/bin/env ruby

#### AL MASSIMO CAMBIARE CARTELLA DI OUTPUT

class Recorder

   def initialize

   end

   def dataRegistration_short (edf_execs, edf_deads, edf_preem, fps_execs,
                     fps_deads, fps_preem)

      timeStamp = Time.now
      timeStampStr = timeStamp.strftime("%Y-%m-%d %H:%M:%S.%6L")
      timeStampStr.gsub! " ", "_"
      File.open(@results, 'a') do |out|

         out.puts "#{timeStampStr};DFP/IPCP;#{edf_execs};#{edf_deads};"\
                  "#{edf_preem};#{fps_execs};#{fps_deads};#{fps_preem};"
      end
   end

   def dataRegistration (timeStamp, mode, totalTasks, short, mid, long,
                     feasibilityEDF, maxLoadEDF, iterEDF, feasibilityFPS, iterFPS, arr )
                    # edf_execs, edf_deads, edf_preem, fps_execs, fps_deads,
                    # fps_preem, hash_edf_dead, hash_edf_map, hash_edf_exec,
                    # hash_fps_dead, hash_fps_map, hash_fps_exec)

      timeStampStr = timeStamp.strftime("%Y-%m-%d %H:%M:%S.%6L")
      timeStampStr.gsub! " ", "_"
      File.open("../workspace/results"+ timeStamp.to_s + ".csv", 'a') do |out|
         out.puts "timeStamp;mode;totalTasks;short;mid;long;feasibilityEDF;maxLoadEDF;iterEDF;feasibilityFPS;iterFPS"
         out.puts "#{timeStampStr};#{mode};#{totalTasks};#{short};#{mid};"\
                   "#{long};#{feasibilityEDF};#{maxLoadEDF};#{iterEDF};"\
                   "#{feasibilityFPS};#{iterFPS}"
              # #{edf_execs};#{edf_deads};"\ "#{edf_preem};#{fps_execs};#{fps_deads};#{fps_preem}"
         out.puts "numTask;DeadlineMiss;Executions"
         arr.each do |task|       
           out.puts "#{task[0]};#{task[1]};#{task[2]}"
         end
                   
      end

      #edf_temp = hash_edf_map.merge(hash_edf_dead){|key, old, new| Array(old).push(new) }
      #fps_temp = hash_fps_map.merge(hash_fps_dead){|key, old, new| Array(old).push(new) }

      #edf_temp = edf_temp.merge(hash_edf_exec){|key, old, new| Array(old).push(new) }
      #fps_temp = fps_temp.merge(hash_fps_exec){|key, old, new| Array(old).push(new) }

      #File.open("../workspace/result_detailed.csv", 'a') do |det|
      #   det.puts "TYPE;TIMESTAMP;EDF_ID;R_DEAD;DEADS;EXECS;#{feasibilityEDF};#{maxLoadEDF}"
      #   det.puts( edf_temp.map{ |k,v| "EDF;#{timeStampStr};#{k};#{v[0]};#{v[1]};#{v[2]};" }.sort )
      #   det.puts "TYPE;TIMESTAMP;FPS_ID;PRIO;DEADS;EXECS;#{feasibilityFPS}"
      #   det.puts( fps_temp.map{ |k,v| "FPS;#{timeStampStr};#{k};#{v[0]};#{v[1]};#{v[2]};" }.sort )
      #end
   end
end
