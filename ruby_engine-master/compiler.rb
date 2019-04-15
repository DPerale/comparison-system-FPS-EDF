#!/usr/bin/env ruby

#### MODIFICATO, CONTROLLARE SE FUNZIONA


require 'open3'

class Compiler

   def cleanAll
      Open3.popen3("make clean -C ../edf-ravenscar-arm") do |stdin, stdout, stderr, thread|
         thread.value
         puts "EDF Libraries Cleaning Complete."
      end
      Open3.popen3("make clean -C ../prio-ravenscar-arm") do |stdin, stdout, stderr, thread|
         thread.value
         puts "FPS Libraries Cleaning Complete."
      end
   end

   def compileLibs
      Open3.popen3("make libs -C ../edf-ravenscar-arm") do |stdin, stdout, stderr, thread|
         thread.value
         puts "EDF Libs Compilation Complete."
      end
      Open3.popen3("make libs -C ../prio-ravenscar-arm") do |stdin, stdout, stderr, thread|
         thread.value
         puts "FPS Libs Compilation Complete."
      end
   end

  # gprbuild --target=arm-eabi -d -P/home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01.gpr /home/aquox/Scrivania/Arm/edf-ravenscar-arm/src/unit01.adb -largs -Wl,-Map=map.txt
   
   def compileUnit unit
      Open3.popen3("gprbuild --target=arm-eabi -d -P/home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01.gpr /home/aquox/Scrivania/Arm/edf-ravenscar-arm/src/" + unit +".adb -largs -Wl,-Map=map.txt") do |stdin, stdout, stderr, thread|
         thread.value
         puts "EDF Unit01 Compilation Complete."
      end
 #     Open3.popen3("gprbuild --target=arm-eabi -d -P/home/aquox/Scrivania/Arm/prio-ravenscar-arm/unit01.gpr /home/aquox/Scrivania/Arm/prio-ravenscar-arm/src/" + unit +".adb -largs -Wl,-Map=map.txt") do |stdin, stdout, stderr, thread|
 #        thread.value
 #        puts "FPS Unit01 Compilation Complete."
 #     end
   end

end
