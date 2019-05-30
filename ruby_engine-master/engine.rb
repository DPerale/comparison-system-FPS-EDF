#!/usr/bin/env ruby

#### APPOSTO

require_relative 'helper'
require_relative 'looper'
# require 'pry'

#####################################################################
##
##  Main loop:
##
#####################################################################

$tot_schedulable = Array.new
$s_For_taskset = Array.new


help = Helper.new
looper = Looper.new


case ARGV[0]
when "-a"
   looper.cleaner ARGV[1].to_s
when "-c"
   looper.cloneIstances
when "-h"
   help.printHelp
else
   if ARGV[1].nil? || ARGV[3].nil? || ARGV[5].nil? then
      help.printHelp
   else
      case ARGV[0]
      when "-l"
            looper.looperForLocalTests ARGV[1].to_i, ARGV[3].to_s, ARGV[5].to_s, true
      when "-lb"
            looper.looperForLocalTests_withBlock ARGV[1].to_i, ARGV[3].to_s, ARGV[5].to_s
      when "-t"
            looper.looperForLocalTests ARGV[1].to_i, ARGV[3].to_s, ARGV[5].to_s, false
      when "-tb"
            looper.testSets_withBlock ARGV[1].to_i, ARGV[3].to_s, ARGV[5].to_s
      else
         help.printHelp
      end
   end
end
