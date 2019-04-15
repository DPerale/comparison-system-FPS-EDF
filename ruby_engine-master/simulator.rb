require 'open3'

### DA MODIFICARE TEMPO SE NECESSARIO, PARTE DA RIMUOVERE

class Simulator

   def execGlobalTestLocal str, totalTasks
      # Executes a single test for the EDF environment
      execs = deads = preem = 0
      a = Time.now
      hash_dead = Hash.new
      hash_exec = Hash.new
      hash_map = Hash.new
      stop = false
      stopBefore = 0
      stopAfter = 0
      arr = []
      Open3.popen3 (str) do |stdin, stdout, stderr, thread|
         i = 0
         Thread.new do
               stdout.each do |str|
                  #if (Time.now - a) > 20 then
                  #  Process.kill("KILL",thread.pid)
                  #end
                  #t = (i / 200).to_i
                  #print "\r#{t}% achieved..."
                  l = str.split(";")
                  # puts "#{l[0]} -- #{l[1]} -- #{l[2]} "
                  #if l[0].include?"Setting" then
                  #   hash_map[l[4].chomp] = l[1].chomp
                  #   hash_dead[l[4].chomp] = 0
                  #   hash_exec[l[4].chomp] = 0
                  #end
                  #if l[0].include?"EXECUTED" then execs += 1; hash_exec[l[2].chomp] += 1 end
                  #if l[0].include?"PREEMPT" then preem += 1 end #; hash[l[1]] += 1 end
                  #if l[0].include?"DEADLINE" then deads += 1; hash_dead[l[2].chomp] += 1 end
                  #i += 1
                  if l[0].include?"Tab" then 
                    g = l[1].split(" ") 
                    arr.push([g[0],g[1],g[2]])
                    if g[0].to_i == totalTasks then 
                      stdin.puts [0x0001].pack("U") + [0x0078].pack("U")
                      #Process.kill("KILL",thread.pid)
                    end
                  end                        
               end
         end
         #stdin.puts "go"
         #stdin.close
         #Thread.new do
         #   stderr.each do |s|
         #      puts s
         #   end
         #end
         thread.value
      end
      b = Time.now
      puts "\nExecution Time: #{b-a}"
      return arr
   end

   def execGlobalTestLocal_withBlock str
      # Executes a single test for the EDF environment
      edf_execs = edf_deads = edf_preem = 0
      a = Time.now
      hash = Hash.new
      Open3.popen3 (str) do |stdin, stdout, stderr, thread|
         i = 0
         Thread.new do
            stdout.each do |str|
               if (Time.now - a) > 2 then
                  Process.kill("KILL",thread.pid)
               end
               t = (i / 200).to_i
               print "\r#{t}% achieved..."
               l = str.split(";")
               if l[0].include?"Setting" then hash[l[2]] = 0 end
               if l[0].include?"EXECUTED" then edf_execs += 1 end #; hash[l[1]] += 1 end
               if l[0].include?"PREEMPT" then edf_preem += 1 end #; hash[l[1]] += 1 end
               if l[0].include?"DEADLINE" then edf_deads += 1; hash[l[2]] += 1 end
               i += 1
            end
         end
         stdin.puts "go"
         stdin.close
         Thread.new do
            stderr.each do |s|
               puts s
            end
         end
         thread.value
      end
      b = Time.now
      puts "\nEDF Time: #{b-a}"
      return edf_execs, edf_deads, edf_preem, hash
   end

   
   ##### DA RIMUOVERE O CAMBIARE
   #def uploadExecsToRemote
   #   Net::SCP.start("ebano.datsi.fi.upm.es", "mbordin", :password => 'pa6ahShi') do |scp|
   #      scp.upload! "../edf-ravenscar/unit01", "raven_bench/unit01_edf"
   #      scp.upload! "../prio-ravenscar/unit01", "raven_bench/unit01_fps"
   #      puts "EDF Unit01 Upload Completed."
   #   end
   #end

end
