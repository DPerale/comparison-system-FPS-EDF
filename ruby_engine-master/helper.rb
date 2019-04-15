#!/usr/bin/env ruby

#### APPOSTO

class Helper

   def printHelp
      puts "Please use labels as explained:"
      puts ""
      puts "-h: print this help"
      puts "-l xxx -d zzz -x yyy: test locally"
      puts "-lb xxx -d zzz -x yyy: test dfp locally with a single protected object"
      puts "-t xxx -d zzz -x yyy: peforms a static test without execute it on the simulator"
      puts "-tb xxx -d zzz -x yyy: test environment with block."
      puts "-a bbb: to clean of the stored results and archive with argument bbb."
      puts "-c to duplicate main Ruby programs in the other workspaces."
      puts ""
      puts "xxx: number of random taskset to test"
      puts "zzz: type of deadlines (i, c, a, m)"
      puts "yyy: kind of experiment (1: fr; 2: sl; 3: lo; 4: sm; 5: so; 6: ml; 7: mo)"
   end

end
