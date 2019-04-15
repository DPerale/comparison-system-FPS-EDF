#!/usr/bin/env ruby

##### DA MODIFICARE SIMULATORE PER TENERE PIU TASK

class Parameters_Limited

   attr_accessor :short_period_range
   attr_accessor :mid_period_range
   attr_accessor :long_period_range
   attr_accessor :short_period_demo_mixed
   attr_accessor :mid_period_demo_mixed
   attr_accessor :long_period_demo_mixed
   attr_accessor :short_constr_dead_range
   attr_accessor :mid_constr_dead_range
   attr_accessor :long_constr_dead_range
   attr_accessor :short_arbit_dead_range
   attr_accessor :mid_arbit_dead_range
   attr_accessor :long_arbit_dead_range
   attr_accessor :short_constr_dead_demo_mixed
   attr_accessor :mid_constr_dead_demo_mixed
   attr_accessor :long_constr_dead_demo_mixed
   attr_accessor :short_arbit_dead_demo_mixed
   attr_accessor :mid_arbit_dead_demo_mixed
   attr_accessor :long_arbit_dead_demo_mixed
   attr_accessor :short_impl_exec_range
   attr_accessor :mid_impl_exec_range
   attr_accessor :long_impl_exec_range
   attr_accessor :short_constr_exec_range
   attr_accessor :mid_constr_exec_range
   attr_accessor :long_constr_exec_range
   attr_accessor :short_arbit_exec_range
   attr_accessor :mid_arbit_exec_range
   attr_accessor :long_arbit_exec_range
   attr_accessor :taskset
   attr_accessor :exponentsDemo
   attr_accessor :exponentsFull

   attr_accessor :short_num_task_range_1
   attr_accessor :mid_num_task_range_1
   attr_accessor :long_num_task_range_1
   attr_accessor :short_num_task_range_2
   attr_accessor :mid_num_task_range_2
   attr_accessor :long_num_task_range_2
   attr_accessor :short_num_task_range_3
   attr_accessor :mid_num_task_range_3
   attr_accessor :long_num_task_range_3
   attr_accessor :short_num_task_range_4
   attr_accessor :mid_num_task_range_4
   attr_accessor :long_num_task_range_4
   attr_accessor :short_num_task_range_5
   attr_accessor :mid_num_task_range_5
   attr_accessor :long_num_task_range_5
   attr_accessor :short_num_task_range_6
   attr_accessor :mid_num_task_range_6
   attr_accessor :long_num_task_range_6
   attr_accessor :short_num_task_range_7
   attr_accessor :mid_num_task_range_7
   attr_accessor :long_num_task_range_7

   def initialize
      # Here we define the environment variables which we use to
      # generate various tasksets. In this way we can replace wrong
      # values with corrected ones quickly

      ###################
      ##    PERIODS    ##
      ###################
      @short_period_range      = 23..25 # 20..23 # 21..23 # 22..24 # 23..25 #
      @mid_period_range        = 26..28 # 24..27 # 24..26 # 25..27 # 26..28 #
      @long_period_range       = 29..31 # 28..31 # 27..29 # 28..30 # 29..31 #

      # Wrong hyperperiod
      # @short_period_demo_mixed = 255..290 #   6.350.400 -->  17.287.200
      # @mid_period_demo_mixed   = 300..325 #  24.696.000 -->  66.679.200
      # @long_period_demo_mixed  = 340..355 # 166.698.000 --> 777.924.000

      @short_period_demo_mixed = 274..310 #   6.350.400 -->  17.781.120
      @mid_period_demo_mixed   = 321..345 #  24.696.000 -->  66.679.200
      @long_period_demo_mixed  = 361..374 # 166.698.000 --> 800.150.400

      #####################
      ##    DEADLINES    ##
      #####################
      @short_constr_dead_range = 21..23 # 23..25
      @mid_constr_dead_range   = 24..26 # 26..28
      @long_constr_dead_range  = 27..29 # 29..31

      @short_arbit_dead_range  = 21..24 # 23..25
      @mid_arbit_dead_range    = 25..28 # 26..28
      @long_arbit_dead_range   = 29..32 # 29..31

      # Wrong hyperperiod
      # @short_constr_dead_demo_mixed = 220..265 # 2.593.080  8.232.000
      # @mid_constr_dead_demo_mixed   = 285..310 # 14.817.600  34.574.400
      # @long_constr_dead_demo_mixed  = 335..350 # 116.688.600  388.962.000

      @short_constr_dead_demo_mixed = 236..284 #   2.540.160 -->   8.232.000
      @mid_constr_dead_demo_mixed   = 304..329 #  14.288.400 -->  33.339.600
      @long_constr_dead_demo_mixed  = 355..368 # 114.307.200 --> 333.396.000

      @short_arbit_dead_demo_mixed = 239..271 #
      @mid_arbit_dead_demo_mixed   = 313..332 #
      @long_arbit_dead_demo_mixed  = 351..360 #

      #################
      ##    EXECS    ##
      #################
      @short_impl_exec_range   =   10000..30000   #   10000..25000
      @mid_impl_exec_range     =   60000..180000  #  100000..250000
      @long_impl_exec_range    =  360000..1180000 # 1000000..2500000

      @short_constr_exec_range =   10000..25000   #   10000..25000
      @mid_constr_exec_range   =   50000..150000  #  100000..250000
      @long_constr_exec_range  =  300000..750000 # 1000000..2500000

      @short_arbit_exec_range  =   100000..250000
      @mid_arbit_exec_range    =  1000000..2500000
      @long_arbit_exec_range   = 10000000..25000000

      #########################################
      ##    TASK NUMS   (183 Tasks Limit)    ##
      #########################################

      ## 1) Short, Mid & Long to Reach 100%
      @short_num_task_range_1    = 25..60 # bell 50 tasks low 25 high 75
      @mid_num_task_range_1      = 25..60 #
      @long_num_task_range_1     = 25..60 #

      ## 2) Short & Long for Performance  near 100 %
      @short_num_task_range_2    = 30..65 # bell 100 tasks low 30 high 65
      @mid_num_task_range_2      = 0..0   #
      @long_num_task_range_2     = 30..65 #

      ## 3) Long Task only for Performance near 100 %
      @short_num_task_range_3    = 0..0     # bell 350 tasks low 200 high 500
      @mid_num_task_range_3      = 0..0     #
      @long_num_task_range_3     = 100..250 #

      ## 4) Short and Mid only for Performance near 100 %
      @short_num_task_range_4    = 25..75    # bell 350 tasks low 200 high 500
      @mid_num_task_range_4      = 25..75    #
      @long_num_task_range_4     = 0..0      #

      ## 5) Short only high density tasks for Performance near 100 %
      @short_num_task_range_5    = 30..60    # bell 350 tasks low 200 high 500
      @mid_num_task_range_5      = 0..0      #
      @long_num_task_range_5     = 0..0      #

      ## 6) Mid and Long high density tasks for Performance near 100 %
      @short_num_task_range_6    = 10..15         # bell 350 tasks low 200 high 500
      @mid_num_task_range_6      = 70..120      #
      @long_num_task_range_6     = 70..90      #

      ## 7) Mid only high density tasks for Performance near 100 %
      @short_num_task_range_7    = 0..0         # bell 350 tasks low 200 high 500
      @mid_num_task_range_7      = 120..170     #
      @long_num_task_range_7     = 0..0         #

      @taskset = Array.new

      @exponentsDemo = Hash.new
      @exponentsDemo[[1, 1, 1, 1]] = 1    # => 210
      @exponentsDemo[[2, 1, 1, 1]] = 2    # => 420
      @exponentsDemo[[1, 2, 1, 1]] = 3    # => 630
      @exponentsDemo[[3, 1, 1, 1]] = 4    # => 840
      @exponentsDemo[[1, 1, 2, 1]] = 5    # => 1.050
      @exponentsDemo[[2, 2, 1, 1]] = 6    # => 1.260
      @exponentsDemo[[1, 1, 1, 2]] = 7    # => 1.470
      @exponentsDemo[[4, 1, 1, 1]] = 8    # => 1.680
      @exponentsDemo[[1, 3, 1, 1]] = 9    # => 1.890
      @exponentsDemo[[2, 1, 2, 1]] = 10   # => 2.100
      @exponentsDemo[[3, 2, 1, 1]] = 11   # => 2.520
      @exponentsDemo[[2, 1, 1, 2]] = 12   # => 2.940
      @exponentsDemo[[1, 2, 2, 1]] = 13   # => 3.150
      @exponentsDemo[[5, 1, 1, 1]] = 14   # => 3.360
      @exponentsDemo[[2, 3, 1, 1]] = 15   # => 3.780
      @exponentsDemo[[3, 1, 2, 1]] = 16   # => 4.200
      @exponentsDemo[[1, 2, 1, 2]] = 17   # => 4.410
      @exponentsDemo[[4, 2, 1, 1]] = 18   # => 5.040
      @exponentsDemo[[1, 1, 3, 1]] = 19   # => 5.250
      @exponentsDemo[[1, 4, 1, 1]] = 20   # => 5.670
      @exponentsDemo[[3, 1, 1, 2]] = 21   # => 5.880
      @exponentsDemo[[2, 2, 2, 1]] = 22   # => 6.300
      @exponentsDemo[[6, 1, 1, 1]] = 23   # => 6.720
      @exponentsDemo[[1, 1, 2, 2]] = 24   # => 7.350
      @exponentsDemo[[3, 3, 1, 1]] = 25   # => 7.560
      @exponentsDemo[[4, 1, 2, 1]] = 26   # => 8.400
      @exponentsDemo[[2, 2, 1, 2]] = 27   # => 8.820
      @exponentsDemo[[1, 3, 2, 1]] = 28   # => 9.450
      @exponentsDemo[[5, 2, 1, 1]] = 29   # => 10.080
      @exponentsDemo[[1, 1, 1, 3]] = 30   # => 10.290
      @exponentsDemo[[2, 1, 3, 1]] = 31   # => 10.500
      @exponentsDemo[[2, 4, 1, 1]] = 32   # => 11.340
      @exponentsDemo[[4, 1, 1, 2]] = 33   # => 11.760
      @exponentsDemo[[3, 2, 2, 1]] = 34   # => 12.600
      @exponentsDemo[[1, 3, 1, 2]] = 35   # => 13.230
      @exponentsDemo[[7, 1, 1, 1]] = 36   # => 13.440
      @exponentsDemo[[2, 1, 2, 2]] = 37   # => 14.700
      @exponentsDemo[[4, 3, 1, 1]] = 38   # => 15.120
      @exponentsDemo[[1, 2, 3, 1]] = 39   # => 15.750
      @exponentsDemo[[5, 1, 2, 1]] = 40   # => 16.800
      @exponentsDemo[[1, 5, 1, 1]] = 41   # => 17.010
      @exponentsDemo[[3, 2, 1, 2]] = 42   # => 17.640
      @exponentsDemo[[2, 3, 2, 1]] = 43   # => 18.900
      @exponentsDemo[[6, 2, 1, 1]] = 44   # => 20.160
      @exponentsDemo[[2, 1, 1, 3]] = 45   # => 20.580
      @exponentsDemo[[3, 1, 3, 1]] = 46   # => 21.000
      @exponentsDemo[[1, 2, 2, 2]] = 47   # => 22.050
      @exponentsDemo[[3, 4, 1, 1]] = 48   # => 22.680
      @exponentsDemo[[5, 1, 1, 2]] = 49   # => 23.520
      @exponentsDemo[[4, 2, 2, 1]] = 50   # => 25.200
      @exponentsDemo[[2, 3, 1, 2]] = 51   # => 26.460
      @exponentsDemo[[1, 4, 2, 1]] = 52   # => 28.350
      @exponentsDemo[[3, 1, 2, 2]] = 53   # => 29.400
      @exponentsDemo[[5, 3, 1, 1]] = 54   # => 30.240
      @exponentsDemo[[1, 2, 1, 3]] = 55   # => 30.870
      @exponentsDemo[[2, 2, 3, 1]] = 56   # => 31.500
      @exponentsDemo[[6, 1, 2, 1]] = 57   # => 33.600
      @exponentsDemo[[2, 5, 1, 1]] = 58   # => 34.020
      @exponentsDemo[[4, 2, 1, 2]] = 59   # => 35.280
      @exponentsDemo[[1, 1, 3, 2]] = 60   # => 36.750
      @exponentsDemo[[3, 3, 2, 1]] = 61   # => 37.800
      @exponentsDemo[[1, 4, 1, 2]] = 62   # => 39.690
      @exponentsDemo[[7, 2, 1, 1]] = 63   # => 40.320
      @exponentsDemo[[3, 1, 1, 3]] = 64   # => 41.160
      @exponentsDemo[[4, 1, 3, 1]] = 65   # => 42.000
      @exponentsDemo[[2, 2, 2, 2]] = 66   # => 44.100
      @exponentsDemo[[4, 4, 1, 1]] = 67   # => 45.360
      @exponentsDemo[[6, 1, 1, 2]] = 68   # => 47.040
      @exponentsDemo[[1, 3, 3, 1]] = 69   # => 47.250
      @exponentsDemo[[5, 2, 2, 1]] = 70   # => 50.400
      @exponentsDemo[[1, 6, 1, 1]] = 71   # => 51.030
      @exponentsDemo[[1, 1, 2, 3]] = 72   # => 51.450
      @exponentsDemo[[3, 3, 1, 2]] = 73   # => 52.920
      @exponentsDemo[[2, 4, 2, 1]] = 74   # => 56.700
      @exponentsDemo[[4, 1, 2, 2]] = 75   # => 58.800
      @exponentsDemo[[6, 3, 1, 1]] = 76   # => 60.480
      @exponentsDemo[[2, 2, 1, 3]] = 77   # => 61.740
      @exponentsDemo[[3, 2, 3, 1]] = 78   # => 63.000
      @exponentsDemo[[1, 3, 2, 2]] = 79   # => 66.150
      @exponentsDemo[[7, 1, 2, 1]] = 80   # => 67.200
      @exponentsDemo[[3, 5, 1, 1]] = 81   # => 68.040
      @exponentsDemo[[5, 2, 1, 2]] = 82   # => 70.560
      @exponentsDemo[[2, 1, 3, 2]] = 83   # => 73.500
      @exponentsDemo[[4, 3, 2, 1]] = 84   # => 75.600
      @exponentsDemo[[2, 4, 1, 2]] = 85   # => 79.380
      @exponentsDemo[[4, 1, 1, 3]] = 86   # => 82.320
      @exponentsDemo[[5, 1, 3, 1]] = 87   # => 84.000
      @exponentsDemo[[1, 5, 2, 1]] = 88   # => 85.050
      @exponentsDemo[[3, 2, 2, 2]] = 89   # => 88.200
      @exponentsDemo[[5, 4, 1, 1]] = 90   # => 90.720
      @exponentsDemo[[1, 3, 1, 3]] = 91   # => 92.610
      @exponentsDemo[[7, 1, 1, 2]] = 92   # => 94.080
      @exponentsDemo[[2, 3, 3, 1]] = 93   # => 94.500
      @exponentsDemo[[6, 2, 2, 1]] = 94   # => 100.800
      @exponentsDemo[[2, 6, 1, 1]] = 95   # => 102.060
      @exponentsDemo[[2, 1, 2, 3]] = 96   # => 102.900
      @exponentsDemo[[4, 3, 1, 2]] = 97   # => 105.840
      @exponentsDemo[[1, 2, 3, 2]] = 98   # => 110.250
      @exponentsDemo[[3, 4, 2, 1]] = 99   # => 113.400
      @exponentsDemo[[5, 1, 2, 2]] = 100  # => 117.600
      @exponentsDemo[[1, 5, 1, 2]] = 101  # => 119.070
      @exponentsDemo[[7, 3, 1, 1]] = 102  # => 120.960
      @exponentsDemo[[3, 2, 1, 3]] = 103  # => 123.480
      @exponentsDemo[[4, 2, 3, 1]] = 104  # => 126.000
      @exponentsDemo[[2, 3, 2, 2]] = 105  # => 132.300
      @exponentsDemo[[4, 5, 1, 1]] = 106  # => 136.080
      @exponentsDemo[[6, 2, 1, 2]] = 107  # => 141.120
      @exponentsDemo[[1, 4, 3, 1]] = 108  # => 141.750
      @exponentsDemo[[3, 1, 3, 2]] = 109  # => 147.000
      @exponentsDemo[[5, 3, 2, 1]] = 110  # => 151.200
      @exponentsDemo[[1, 2, 2, 3]] = 111  # => 154.350
      @exponentsDemo[[3, 4, 1, 2]] = 112  # => 158.760
      @exponentsDemo[[5, 1, 1, 3]] = 113  # => 164.640
      @exponentsDemo[[6, 1, 3, 1]] = 114  # => 168.000
      @exponentsDemo[[2, 5, 2, 1]] = 115  # => 170.100
      @exponentsDemo[[4, 2, 2, 2]] = 116  # => 176.400
      @exponentsDemo[[6, 4, 1, 1]] = 117  # => 181.440
      @exponentsDemo[[2, 3, 1, 3]] = 118  # => 185.220
      @exponentsDemo[[3, 3, 3, 1]] = 119  # => 189.000
      @exponentsDemo[[1, 4, 2, 2]] = 120  # => 198.450
      @exponentsDemo[[7, 2, 2, 1]] = 121  # => 201.600
      @exponentsDemo[[3, 6, 1, 1]] = 122  # => 204.120
      @exponentsDemo[[3, 1, 2, 3]] = 123  # => 205.800
      @exponentsDemo[[5, 3, 1, 2]] = 124  # => 211.680
      @exponentsDemo[[2, 2, 3, 2]] = 125  # => 220.500
      @exponentsDemo[[4, 4, 2, 1]] = 126  # => 226.800
      @exponentsDemo[[6, 1, 2, 2]] = 127  # => 235.200
      @exponentsDemo[[2, 5, 1, 2]] = 128  # => 238.140
      @exponentsDemo[[4, 2, 1, 3]] = 129  # => 246.960
      @exponentsDemo[[5, 2, 3, 1]] = 130  # => 252.000
      @exponentsDemo[[1, 6, 2, 1]] = 131  # => 255.150
      @exponentsDemo[[1, 1, 3, 3]] = 132  # => 257.250
      @exponentsDemo[[3, 3, 2, 2]] = 133  # => 264.600
      @exponentsDemo[[5, 5, 1, 1]] = 134  # => 272.160
      @exponentsDemo[[1, 4, 1, 3]] = 135  # => 277.830
      @exponentsDemo[[7, 2, 1, 2]] = 136  # => 282.240
      @exponentsDemo[[2, 4, 3, 1]] = 137  # => 283.500
      @exponentsDemo[[4, 1, 3, 2]] = 138  # => 294.000
      @exponentsDemo[[6, 3, 2, 1]] = 139  # => 302.400
      @exponentsDemo[[2, 2, 2, 3]] = 140  # => 308.700
      @exponentsDemo[[4, 4, 1, 2]] = 141  # => 317.520
      @exponentsDemo[[6, 1, 1, 3]] = 142  # => 329.280
      @exponentsDemo[[1, 3, 3, 2]] = 143  # => 330.750
      @exponentsDemo[[7, 1, 3, 1]] = 144  # => 336.000
      @exponentsDemo[[3, 5, 2, 1]] = 145  # => 340.200
      @exponentsDemo[[5, 2, 2, 2]] = 146  # => 352.800
      @exponentsDemo[[1, 6, 1, 2]] = 147  # => 357.210
      @exponentsDemo[[7, 4, 1, 1]] = 148  # => 362.880
      @exponentsDemo[[3, 3, 1, 3]] = 149  # => 370.440
      @exponentsDemo[[4, 3, 3, 1]] = 150  # => 378.000
      @exponentsDemo[[2, 4, 2, 2]] = 151  # => 396.900
      @exponentsDemo[[4, 6, 1, 1]] = 152  # => 408.240
      @exponentsDemo[[4, 1, 2, 3]] = 153  # => 411.600
      @exponentsDemo[[6, 3, 1, 2]] = 154  # => 423.360
      @exponentsDemo[[1, 5, 3, 1]] = 155  # => 425.250
      @exponentsDemo[[3, 2, 3, 2]] = 156  # => 441.000
      @exponentsDemo[[5, 4, 2, 1]] = 157  # => 453.600
      @exponentsDemo[[1, 3, 2, 3]] = 158  # => 463.050
      @exponentsDemo[[7, 1, 2, 2]] = 159  # => 470.400
      @exponentsDemo[[3, 5, 1, 2]] = 160  # => 476.280
      @exponentsDemo[[5, 2, 1, 3]] = 161  # => 493.920
      @exponentsDemo[[6, 2, 3, 1]] = 162  # => 504.000
      @exponentsDemo[[2, 6, 2, 1]] = 163  # => 510.300
      @exponentsDemo[[2, 1, 3, 3]] = 164  # => 514.500
      @exponentsDemo[[4, 3, 2, 2]] = 165  # => 529.200
      @exponentsDemo[[6, 5, 1, 1]] = 166  # => 544.320
      @exponentsDemo[[2, 4, 1, 3]] = 167  # => 555.660
      @exponentsDemo[[3, 4, 3, 1]] = 168  # => 567.000
      @exponentsDemo[[5, 1, 3, 2]] = 169  # => 588.000
      @exponentsDemo[[1, 5, 2, 2]] = 170  # => 595.350
      @exponentsDemo[[7, 3, 2, 1]] = 171  # => 604.800
      @exponentsDemo[[3, 2, 2, 3]] = 172  # => 617.400
      @exponentsDemo[[5, 4, 1, 2]] = 173  # => 635.040
      @exponentsDemo[[7, 1, 1, 3]] = 174  # => 658.560
      @exponentsDemo[[2, 3, 3, 2]] = 175  # => 661.500
      @exponentsDemo[[4, 5, 2, 1]] = 176  # => 680.400
      @exponentsDemo[[6, 2, 2, 2]] = 177  # => 705.600
      @exponentsDemo[[2, 6, 1, 2]] = 178  # => 714.420
      @exponentsDemo[[4, 3, 1, 3]] = 179  # => 740.880
      @exponentsDemo[[5, 3, 3, 1]] = 180  # => 756.000
      @exponentsDemo[[1, 2, 3, 3]] = 181  # => 771.750
      @exponentsDemo[[3, 4, 2, 2]] = 182  # => 793.800
      @exponentsDemo[[5, 6, 1, 1]] = 183  # => 816.480
      @exponentsDemo[[5, 1, 2, 3]] = 184  # => 823.200
      @exponentsDemo[[1, 5, 1, 3]] = 185  # => 833.490
      @exponentsDemo[[7, 3, 1, 2]] = 186  # => 846.720
      @exponentsDemo[[2, 5, 3, 1]] = 187  # => 850.500
      @exponentsDemo[[4, 2, 3, 2]] = 188  # => 882.000
      @exponentsDemo[[6, 4, 2, 1]] = 189  # => 907.200
      @exponentsDemo[[2, 3, 2, 3]] = 190  # => 926.100
      @exponentsDemo[[4, 5, 1, 2]] = 191  # => 952.560
      @exponentsDemo[[6, 2, 1, 3]] = 192  # => 987.840
      @exponentsDemo[[1, 4, 3, 2]] = 193  # => 992.250
      @exponentsDemo[[7, 2, 3, 1]] = 194  # => 1.008.000
      @exponentsDemo[[3, 6, 2, 1]] = 195  # => 1.020.600
      @exponentsDemo[[3, 1, 3, 3]] = 196  # => 1.029.000
      @exponentsDemo[[5, 3, 2, 2]] = 197  # => 1.058.400
      @exponentsDemo[[7, 5, 1, 1]] = 198  # => 1.088.640
      @exponentsDemo[[3, 4, 1, 3]] = 199  # => 1.111.320
      @exponentsDemo[[4, 4, 3, 1]] = 200  # => 1.134.000
      @exponentsDemo[[6, 1, 3, 2]] = 201  # => 1.176.000
      @exponentsDemo[[2, 5, 2, 2]] = 202  # => 1.190.700
      @exponentsDemo[[4, 2, 2, 3]] = 203  # => 1.234.800
      @exponentsDemo[[6, 4, 1, 2]] = 204  # => 1.270.080
      @exponentsDemo[[1, 6, 3, 1]] = 205  # => 1.275.750
      @exponentsDemo[[3, 3, 3, 2]] = 206  # => 1.323.000
      @exponentsDemo[[5, 5, 2, 1]] = 207  # => 1.360.800
      @exponentsDemo[[1, 4, 2, 3]] = 208  # => 1.389.150
      @exponentsDemo[[7, 2, 2, 2]] = 209  # => 1.411.200
      @exponentsDemo[[3, 6, 1, 2]] = 210  # => 1.428.840
      @exponentsDemo[[5, 3, 1, 3]] = 211  # => 1.481.760
      @exponentsDemo[[6, 3, 3, 1]] = 212  # => 1.512.000
      @exponentsDemo[[2, 2, 3, 3]] = 213  # => 1.543.500
      @exponentsDemo[[4, 4, 2, 2]] = 214  # => 1.587.600
      @exponentsDemo[[6, 6, 1, 1]] = 215  # => 1.632.960
      @exponentsDemo[[6, 1, 2, 3]] = 216  # => 1.646.400
      @exponentsDemo[[2, 5, 1, 3]] = 217  # => 1.666.980
      @exponentsDemo[[3, 5, 3, 1]] = 218  # => 1.701.000
      @exponentsDemo[[5, 2, 3, 2]] = 219  # => 1.764.000
      @exponentsDemo[[1, 6, 2, 2]] = 220  # => 1.786.050
      @exponentsDemo[[7, 4, 2, 1]] = 221  # => 1.814.400
      @exponentsDemo[[3, 3, 2, 3]] = 222  # => 1.852.200
      @exponentsDemo[[5, 5, 1, 2]] = 223  # => 1.905.120
      @exponentsDemo[[7, 2, 1, 3]] = 224  # => 1.975.680
      @exponentsDemo[[2, 4, 3, 2]] = 225  # => 1.984.500
      @exponentsDemo[[4, 6, 2, 1]] = 226  # => 2.041.200
      @exponentsDemo[[4, 1, 3, 3]] = 227  # => 2.058.000
      @exponentsDemo[[6, 3, 2, 2]] = 228  # => 2.116.800
      @exponentsDemo[[4, 4, 1, 3]] = 229  # => 2.222.640
      @exponentsDemo[[5, 4, 3, 1]] = 230  # => 2.268.000
      @exponentsDemo[[1, 3, 3, 3]] = 231  # => 2.315.250
      @exponentsDemo[[7, 1, 3, 2]] = 232  # => 2.352.000
      @exponentsDemo[[3, 5, 2, 2]] = 233  # => 2.381.400
      @exponentsDemo[[5, 2, 2, 3]] = 234  # => 2.469.600
      @exponentsDemo[[1, 6, 1, 3]] = 235  # => 2.500.470
      @exponentsDemo[[7, 4, 1, 2]] = 236  # => 2.540.160
      @exponentsDemo[[2, 6, 3, 1]] = 237  # => 2.551.500
      @exponentsDemo[[4, 3, 3, 2]] = 238  # => 2.646.000
      @exponentsDemo[[6, 5, 2, 1]] = 239  # => 2.721.600
      @exponentsDemo[[2, 4, 2, 3]] = 240  # => 2.778.300
      @exponentsDemo[[4, 6, 1, 2]] = 241  # => 2.857.680
      @exponentsDemo[[6, 3, 1, 3]] = 242  # => 2.963.520
      @exponentsDemo[[1, 5, 3, 2]] = 243  # => 2.976.750
      @exponentsDemo[[7, 3, 3, 1]] = 244  # => 3.024.000
      @exponentsDemo[[3, 2, 3, 3]] = 245  # => 3.087.000
      @exponentsDemo[[5, 4, 2, 2]] = 246  # => 3.175.200
      @exponentsDemo[[7, 6, 1, 1]] = 247  # => 3.265.920
      @exponentsDemo[[7, 1, 2, 3]] = 248  # => 3.292.800
      @exponentsDemo[[3, 5, 1, 3]] = 249  # => 3.333.960
      @exponentsDemo[[4, 5, 3, 1]] = 250  # => 3.402.000
      @exponentsDemo[[6, 2, 3, 2]] = 251  # => 3.528.000
      @exponentsDemo[[2, 6, 2, 2]] = 252  # => 3.572.100
      @exponentsDemo[[4, 3, 2, 3]] = 253  # => 3.704.400
      @exponentsDemo[[6, 5, 1, 2]] = 254  # => 3.810.240
      @exponentsDemo[[3, 4, 3, 2]] = 255  # => 3.969.000
      @exponentsDemo[[5, 6, 2, 1]] = 256  # => 4.082.400
      @exponentsDemo[[5, 1, 3, 3]] = 257  # => 4.116.000
      @exponentsDemo[[1, 5, 2, 3]] = 258  # => 4.167.450
      @exponentsDemo[[7, 3, 2, 2]] = 259  # => 4.233.600
      @exponentsDemo[[5, 4, 1, 3]] = 260  # => 4.445.280
      @exponentsDemo[[6, 4, 3, 1]] = 261  # => 4.536.000
      @exponentsDemo[[2, 3, 3, 3]] = 262  # => 4.630.500
      @exponentsDemo[[4, 5, 2, 2]] = 263  # => 4.762.800
      @exponentsDemo[[6, 2, 2, 3]] = 264  # => 4.939.200
      @exponentsDemo[[2, 6, 1, 3]] = 265  # => 5.000.940
      @exponentsDemo[[3, 6, 3, 1]] = 266  # => 5.103.000
      @exponentsDemo[[5, 3, 3, 2]] = 267  # => 5.292.000
      @exponentsDemo[[7, 5, 2, 1]] = 268  # => 5.443.200
      @exponentsDemo[[3, 4, 2, 3]] = 269  # => 5.556.600
      @exponentsDemo[[5, 6, 1, 2]] = 270  # => 5.715.360
      @exponentsDemo[[7, 3, 1, 3]] = 271  # => 5.927.040
      @exponentsDemo[[2, 5, 3, 2]] = 272  # => 5.953.500
      @exponentsDemo[[4, 2, 3, 3]] = 273  # => 6.174.000
      @exponentsDemo[[6, 4, 2, 2]] = 274  # => 6.350.400     +=> SHORT
      @exponentsDemo[[4, 5, 1, 3]] = 275  # => 6.667.920
      @exponentsDemo[[5, 5, 3, 1]] = 276  # => 6.804.000
      @exponentsDemo[[1, 4, 3, 3]] = 277  # => 6.945.750
      @exponentsDemo[[7, 2, 3, 2]] = 278  # => 7.056.000
      @exponentsDemo[[3, 6, 2, 2]] = 279  # => 7.144.200
      @exponentsDemo[[5, 3, 2, 3]] = 280  # => 7.408.800
      @exponentsDemo[[7, 5, 1, 2]] = 281  # => 7.620.480
      @exponentsDemo[[4, 4, 3, 2]] = 282  # => 7.938.000
      @exponentsDemo[[6, 6, 2, 1]] = 283  # => 8.164.800
      @exponentsDemo[[6, 1, 3, 3]] = 284  # => 8.232.000
      @exponentsDemo[[2, 5, 2, 3]] = 285  # => 8.334.900
      @exponentsDemo[[6, 4, 1, 3]] = 286  # => 8.890.560
      @exponentsDemo[[1, 6, 3, 2]] = 287  # => 8.930.250
      @exponentsDemo[[7, 4, 3, 1]] = 288  # => 9.072.000
      @exponentsDemo[[3, 3, 3, 3]] = 289  # => 9.261.000
      @exponentsDemo[[5, 5, 2, 2]] = 290  # => 9.525.600
      @exponentsDemo[[7, 2, 2, 3]] = 291  # => 9.878.400
      @exponentsDemo[[3, 6, 1, 3]] = 292  # => 10.001.880
      @exponentsDemo[[4, 6, 3, 1]] = 293  # => 10.206.000
      @exponentsDemo[[6, 3, 3, 2]] = 294  # => 10.584.000
      @exponentsDemo[[4, 4, 2, 3]] = 295  # => 11.113.200
      @exponentsDemo[[6, 6, 1, 2]] = 296  # => 11.430.720
      @exponentsDemo[[3, 5, 3, 2]] = 297  # => 11.907.000
      @exponentsDemo[[5, 2, 3, 3]] = 298  # => 12.348.000
      @exponentsDemo[[1, 6, 2, 3]] = 299  # => 12.502.350
      @exponentsDemo[[7, 4, 2, 2]] = 300  # => 12.700.800
      @exponentsDemo[[5, 5, 1, 3]] = 301  # => 13.335.840
      @exponentsDemo[[6, 5, 3, 1]] = 302  # => 13.608.000
      @exponentsDemo[[2, 4, 3, 3]] = 303  # => 13.891.500
      @exponentsDemo[[4, 6, 2, 2]] = 304  # => 14.288.400
      @exponentsDemo[[6, 3, 2, 3]] = 305  # => 14.817.600
      @exponentsDemo[[5, 4, 3, 2]] = 306  # => 15.876.000
      @exponentsDemo[[7, 6, 2, 1]] = 307  # => 16.329.600
      @exponentsDemo[[7, 1, 3, 3]] = 308  # => 16.464.000
      @exponentsDemo[[3, 5, 2, 3]] = 309  # => 16.669.800
      @exponentsDemo[[7, 4, 1, 3]] = 310  # => 17.781.120
      @exponentsDemo[[2, 6, 3, 2]] = 311  # => 17.860.500
      @exponentsDemo[[4, 3, 3, 3]] = 312  # => 18.522.000
      @exponentsDemo[[6, 5, 2, 2]] = 313  # => 19.051.200
      @exponentsDemo[[4, 6, 1, 3]] = 314  # => 20.003.760
      @exponentsDemo[[5, 6, 3, 1]] = 315  # => 20.412.000
      @exponentsDemo[[1, 5, 3, 3]] = 316  # => 20.837.250
      @exponentsDemo[[7, 3, 3, 2]] = 317  # => 21.168.000
      @exponentsDemo[[5, 4, 2, 3]] = 318  # => 22.226.400
      @exponentsDemo[[7, 6, 1, 2]] = 319  # => 22.861.440
      @exponentsDemo[[4, 5, 3, 2]] = 320  # => 23.814.000
      @exponentsDemo[[6, 2, 3, 3]] = 321  # => 24.696.000
      @exponentsDemo[[2, 6, 2, 3]] = 322  # => 25.004.700
      @exponentsDemo[[6, 5, 1, 3]] = 323  # => 26.671.680
      @exponentsDemo[[7, 5, 3, 1]] = 324  # => 27.216.000
      @exponentsDemo[[3, 4, 3, 3]] = 325  # => 27.783.000
      @exponentsDemo[[5, 6, 2, 2]] = 326  # => 28.576.800
      @exponentsDemo[[7, 3, 2, 3]] = 327  # => 29.635.200
      @exponentsDemo[[6, 4, 3, 2]] = 328  # => 31.752.000
      @exponentsDemo[[4, 5, 2, 3]] = 329  # => 33.339.600
      @exponentsDemo[[3, 6, 3, 2]] = 330  # => 35.721.000
      @exponentsDemo[[5, 3, 3, 3]] = 331  # => 37.044.000
      @exponentsDemo[[7, 5, 2, 2]] = 332  # => 38.102.400
      @exponentsDemo[[5, 6, 1, 3]] = 333  # => 40.007.520
      @exponentsDemo[[6, 6, 3, 1]] = 334  # => 40.824.000
      @exponentsDemo[[2, 5, 3, 3]] = 335  # => 41.674.500
      @exponentsDemo[[6, 4, 2, 3]] = 336  # => 44.452.800
      @exponentsDemo[[5, 5, 3, 2]] = 337  # => 47.628.000
      @exponentsDemo[[7, 2, 3, 3]] = 338  # => 49.392.000
      @exponentsDemo[[3, 6, 2, 3]] = 339  # => 50.009.400
      @exponentsDemo[[7, 5, 1, 3]] = 340  # => 53.343.360
      @exponentsDemo[[4, 4, 3, 3]] = 341  # => 55.566.000
      @exponentsDemo[[6, 6, 2, 2]] = 342  # => 57.153.600
      @exponentsDemo[[1, 6, 3, 3]] = 343  # => 62.511.750
      @exponentsDemo[[7, 4, 3, 2]] = 344  # => 63.504.000
      @exponentsDemo[[5, 5, 2, 3]] = 345  # => 66.679.200
      @exponentsDemo[[4, 6, 3, 2]] = 346  # => 71.442.000
      @exponentsDemo[[6, 3, 3, 3]] = 347  # => 74.088.000
      @exponentsDemo[[6, 6, 1, 3]] = 348  # => 80.015.040
      @exponentsDemo[[7, 6, 3, 1]] = 349  # => 81.648.000
      @exponentsDemo[[3, 5, 3, 3]] = 350  # => 83.349.000
      @exponentsDemo[[7, 4, 2, 3]] = 351  # => 88.905.600
      @exponentsDemo[[6, 5, 3, 2]] = 352  # => 95.256.000
      @exponentsDemo[[4, 6, 2, 3]] = 353  # => 100.018.800
      @exponentsDemo[[5, 4, 3, 3]] = 354  # => 111.132.000
      @exponentsDemo[[7, 6, 2, 2]] = 355  # => 114.307.200
      @exponentsDemo[[2, 6, 3, 3]] = 356  # => 125.023.500
      @exponentsDemo[[6, 5, 2, 3]] = 357  # => 133.358.400
      @exponentsDemo[[5, 6, 3, 2]] = 358  # => 142.884.000
      @exponentsDemo[[7, 3, 3, 3]] = 359  # => 148.176.000
      @exponentsDemo[[7, 6, 1, 3]] = 360  # => 160.030.080
      @exponentsDemo[[4, 5, 3, 3]] = 361  # => 166.698.000
      @exponentsDemo[[7, 5, 3, 2]] = 362  # => 190.512.000
      @exponentsDemo[[5, 6, 2, 3]] = 363  # => 200.037.600
      @exponentsDemo[[6, 4, 3, 3]] = 364  # => 222.264.000
      @exponentsDemo[[3, 6, 3, 3]] = 365  # => 250.047.000
      @exponentsDemo[[7, 5, 2, 3]] = 366  # => 266.716.800
      @exponentsDemo[[6, 6, 3, 2]] = 367  # => 285.768.000
      @exponentsDemo[[5, 5, 3, 3]] = 368  # => 333.396.000
      @exponentsDemo[[6, 6, 2, 3]] = 369  # => 400.075.200
      @exponentsDemo[[7, 4, 3, 3]] = 370  # => 444.528.000
      @exponentsDemo[[4, 6, 3, 3]] = 371  # => 500.094.000
      @exponentsDemo[[7, 6, 3, 2]] = 372  # => 571.536.000
      @exponentsDemo[[6, 5, 3, 3]] = 373  # => 666.792.000
      @exponentsDemo[[7, 6, 2, 3]] = 374  # => 800.150.400
      @exponentsDemo[[5, 6, 3, 3]] = 375  # => 1.000.188.000
      @exponentsDemo[[7, 5, 3, 3]] = 376  # => 1.333.584.000
      @exponentsDemo[[6, 6, 3, 3]] = 377  # => 2.000.376.000
      @exponentsDemo[[7, 6, 3, 3]] = 378  # => 4.000.752.000
   end
end
