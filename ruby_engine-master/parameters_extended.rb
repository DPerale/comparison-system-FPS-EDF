#!/usr/bin/env ruby


##### DA MODIFICARE SIMULATORE PER TENERE PIU TASK

class Parameters_Extended

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
      @short_period_demo_mixed = 300..450  # 274..310 #   6.350.400 -->  17.781.120
      @mid_period_demo_mixed   = 590..730  # 321..345 #  24.696.000 -->  66.679.200
      @long_period_demo_mixed  = 850..1000 # 361..374 # 166.698.000 --> 800.150.400

      #####################
      ##    DEADLINES    ##
      #####################
      @short_constr_dead_demo_mixed = 240..390 #   2.540.160 -->   8.232.000
      @mid_constr_dead_demo_mixed   = 530..670 #  14.288.400 -->  33.339.600
      @long_constr_dead_demo_mixed  = 790..940 # 114.307.200 --> 333.396.000

      #################
      ##    EXECS    ##
      #################
      # They do not need to be extended because timings for computation is
      # corrected

      @short_impl_exec_range   =   10000..30000   #   10000..25000
      @mid_impl_exec_range     =   60000..180000  #  100000..250000
      @long_impl_exec_range    =  360000..1180000 # 1000000..2500000

      @short_constr_exec_range =   10000..25000    #   10000..25000
      @mid_constr_exec_range   =  100000..250000   #  100000..250000
      @long_constr_exec_range  = 1000000..2500000  # 1000000..2500000

      #########################################
      ##    TASK NUMS   (183 Tasks Limit)    ##
      #########################################

      ## 1) Short, Mid & Long to Reach 100%
      @short_num_task_range_1    = 20..22    # bell 50 tasks low 25 high 75
      @mid_num_task_range_1      = 20..22    #
      @long_num_task_range_1     = 20..21    #

      ## 2) Short & Long for Performance  near 100 %
      @short_num_task_range_2    = 30..65    # bell 100 tasks low 30 high 65
      @mid_num_task_range_2      = 0..0      #
      @long_num_task_range_2     = 30..65    #

      ## 3) Long Task only for Performance near 100 %
      @short_num_task_range_3    = 0..0      # bell 350 tasks low 200 high 500
      @mid_num_task_range_3      = 0..0      #
      @long_num_task_range_3     = 100..250  #

      ## 4) Short and Mid only for Performance near 100 %
      @short_num_task_range_4    = 25..75    # bell 350 tasks low 200 high 500
      @mid_num_task_range_4      = 25..75    #
      @long_num_task_range_4     = 0..0      #

      ## 5) Short only high density tasks for Performance near 100 %
      @short_num_task_range_5    = 30..60    # bell 350 tasks low 200 high 500
      @mid_num_task_range_5      = 0..0      #
      @long_num_task_range_5     = 0..0      #

      ## 6) Mid and Long high density tasks for Performance near 100 %
      @short_num_task_range_6    = 10..15    # bell 350 tasks low 200 high 500
      @mid_num_task_range_6      = 70..120   #
      @long_num_task_range_6     = 70..90    #

      ## 7) Mid only high density tasks for Performance near 100 %
      @short_num_task_range_7    = 0..0      # bell 350 tasks low 200 high 500
      @mid_num_task_range_7      = 120..170  #
      @long_num_task_range_7     = 0..0      #

      @taskset = Array.new

      @exponentsDemo = Hash.new
      @exponentsDemo[[1, 1, 1, 1]] = 1  # => 210
      @exponentsDemo[[2, 1, 1, 1]] = 2  # => 420
      @exponentsDemo[[1, 2, 1, 1]] = 3  # => 630
      @exponentsDemo[[3, 1, 1, 1]] = 4  # => 840
      @exponentsDemo[[1, 1, 2, 1]] = 5  # => 1.050
      @exponentsDemo[[2, 2, 1, 1]] = 6  # => 1.260
      @exponentsDemo[[1, 1, 1, 2]] = 7  # => 1.470
      @exponentsDemo[[4, 1, 1, 1]] = 8  # => 1.680
      @exponentsDemo[[1, 3, 1, 1]] = 9  # => 1.890
      @exponentsDemo[[2, 1, 2, 1]] = 10  # => 2.100
      @exponentsDemo[[3, 2, 1, 1]] = 11  # => 2.520
      @exponentsDemo[[2, 1, 1, 2]] = 12  # => 2.940
      @exponentsDemo[[1, 2, 2, 1]] = 13  # => 3.150
      @exponentsDemo[[5, 1, 1, 1]] = 14  # => 3.360
      @exponentsDemo[[2, 3, 1, 1]] = 15  # => 3.780
      @exponentsDemo[[3, 1, 2, 1]] = 16  # => 4.200
      @exponentsDemo[[1, 2, 1, 2]] = 17  # => 4.410
      @exponentsDemo[[4, 2, 1, 1]] = 18  # => 5.040
      @exponentsDemo[[1, 1, 3, 1]] = 19  # => 5.250
      @exponentsDemo[[1, 4, 1, 1]] = 20  # => 5.670
      @exponentsDemo[[3, 1, 1, 2]] = 21  # => 5.880
      @exponentsDemo[[2, 2, 2, 1]] = 22  # => 6.300
      @exponentsDemo[[6, 1, 1, 1]] = 23  # => 6.720
      @exponentsDemo[[1, 1, 2, 2]] = 24  # => 7.350
      @exponentsDemo[[3, 3, 1, 1]] = 25  # => 7.560
      @exponentsDemo[[4, 1, 2, 1]] = 26  # => 8.400
      @exponentsDemo[[2, 2, 1, 2]] = 27  # => 8.820
      @exponentsDemo[[1, 3, 2, 1]] = 28  # => 9.450
      @exponentsDemo[[5, 2, 1, 1]] = 29  # => 10.080
      @exponentsDemo[[1, 1, 1, 3]] = 30  # => 10.290
      @exponentsDemo[[2, 1, 3, 1]] = 31  # => 10.500
      @exponentsDemo[[2, 4, 1, 1]] = 32  # => 11.340
      @exponentsDemo[[4, 1, 1, 2]] = 33  # => 11.760
      @exponentsDemo[[3, 2, 2, 1]] = 34  # => 12.600
      @exponentsDemo[[1, 3, 1, 2]] = 35  # => 13.230
      @exponentsDemo[[7, 1, 1, 1]] = 36  # => 13.440
      @exponentsDemo[[2, 1, 2, 2]] = 37  # => 14.700
      @exponentsDemo[[4, 3, 1, 1]] = 38  # => 15.120
      @exponentsDemo[[1, 2, 3, 1]] = 39  # => 15.750
      @exponentsDemo[[5, 1, 2, 1]] = 40  # => 16.800
      @exponentsDemo[[1, 5, 1, 1]] = 41  # => 17.010
      @exponentsDemo[[3, 2, 1, 2]] = 42  # => 17.640
      @exponentsDemo[[2, 3, 2, 1]] = 43  # => 18.900
      @exponentsDemo[[6, 2, 1, 1]] = 44  # => 20.160
      @exponentsDemo[[2, 1, 1, 3]] = 45  # => 20.580
      @exponentsDemo[[3, 1, 3, 1]] = 46  # => 21.000
      @exponentsDemo[[1, 2, 2, 2]] = 47  # => 22.050
      @exponentsDemo[[3, 4, 1, 1]] = 48  # => 22.680
      @exponentsDemo[[5, 1, 1, 2]] = 49  # => 23.520
      @exponentsDemo[[4, 2, 2, 1]] = 50  # => 25.200
      @exponentsDemo[[1, 1, 4, 1]] = 51  # => 26.250
      @exponentsDemo[[2, 3, 1, 2]] = 52  # => 26.460
      @exponentsDemo[[8, 1, 1, 1]] = 53  # => 26.880
      @exponentsDemo[[1, 4, 2, 1]] = 54  # => 28.350
      @exponentsDemo[[3, 1, 2, 2]] = 55  # => 29.400
      @exponentsDemo[[5, 3, 1, 1]] = 56  # => 30.240
      @exponentsDemo[[1, 2, 1, 3]] = 57  # => 30.870
      @exponentsDemo[[2, 2, 3, 1]] = 58  # => 31.500
      @exponentsDemo[[6, 1, 2, 1]] = 59  # => 33.600
      @exponentsDemo[[2, 5, 1, 1]] = 60  # => 34.020
      @exponentsDemo[[4, 2, 1, 2]] = 61  # => 35.280
      @exponentsDemo[[1, 1, 3, 2]] = 62  # => 36.750
      @exponentsDemo[[3, 3, 2, 1]] = 63  # => 37.800
      @exponentsDemo[[1, 4, 1, 2]] = 64  # => 39.690
      @exponentsDemo[[7, 2, 1, 1]] = 65  # => 40.320
      @exponentsDemo[[3, 1, 1, 3]] = 66  # => 41.160
      @exponentsDemo[[4, 1, 3, 1]] = 67  # => 42.000
      @exponentsDemo[[2, 2, 2, 2]] = 68  # => 44.100
      @exponentsDemo[[4, 4, 1, 1]] = 69  # => 45.360
      @exponentsDemo[[6, 1, 1, 2]] = 70  # => 47.040
      @exponentsDemo[[1, 3, 3, 1]] = 71  # => 47.250
      @exponentsDemo[[5, 2, 2, 1]] = 72  # => 50.400
      @exponentsDemo[[1, 6, 1, 1]] = 73  # => 51.030
      @exponentsDemo[[1, 1, 2, 3]] = 74  # => 51.450
      @exponentsDemo[[2, 1, 4, 1]] = 75  # => 52.500
      @exponentsDemo[[3, 3, 1, 2]] = 76  # => 52.920
      @exponentsDemo[[9, 1, 1, 1]] = 77  # => 53.760
      @exponentsDemo[[2, 4, 2, 1]] = 78  # => 56.700
      @exponentsDemo[[4, 1, 2, 2]] = 79  # => 58.800
      @exponentsDemo[[6, 3, 1, 1]] = 80  # => 60.480
      @exponentsDemo[[2, 2, 1, 3]] = 81  # => 61.740
      @exponentsDemo[[3, 2, 3, 1]] = 82  # => 63.000
      @exponentsDemo[[1, 3, 2, 2]] = 83  # => 66.150
      @exponentsDemo[[7, 1, 2, 1]] = 84  # => 67.200
      @exponentsDemo[[3, 5, 1, 1]] = 85  # => 68.040
      @exponentsDemo[[5, 2, 1, 2]] = 86  # => 70.560
      @exponentsDemo[[1, 1, 1, 4]] = 87  # => 72.030
      @exponentsDemo[[2, 1, 3, 2]] = 88  # => 73.500
      @exponentsDemo[[4, 3, 2, 1]] = 89  # => 75.600
      @exponentsDemo[[1, 2, 4, 1]] = 90  # => 78.750
      @exponentsDemo[[2, 4, 1, 2]] = 91  # => 79.380
      @exponentsDemo[[8, 2, 1, 1]] = 92  # => 80.640
      @exponentsDemo[[4, 1, 1, 3]] = 93  # => 82.320
      @exponentsDemo[[5, 1, 3, 1]] = 94  # => 84.000
      @exponentsDemo[[1, 5, 2, 1]] = 95  # => 85.050
      @exponentsDemo[[3, 2, 2, 2]] = 96  # => 88.200
      @exponentsDemo[[5, 4, 1, 1]] = 97  # => 90.720
      @exponentsDemo[[1, 3, 1, 3]] = 98  # => 92.610
      @exponentsDemo[[7, 1, 1, 2]] = 99  # => 94.080
      @exponentsDemo[[2, 3, 3, 1]] = 100  # => 94.500
      @exponentsDemo[[6, 2, 2, 1]] = 101  # => 100.800
      @exponentsDemo[[2, 6, 1, 1]] = 102  # => 102.060
      @exponentsDemo[[2, 1, 2, 3]] = 103  # => 102.900
      @exponentsDemo[[3, 1, 4, 1]] = 104  # => 105.000
      @exponentsDemo[[4, 3, 1, 2]] = 105  # => 105.840
      @exponentsDemo[[1, 2, 3, 2]] = 106  # => 110.250
      @exponentsDemo[[3, 4, 2, 1]] = 107  # => 113.400
      @exponentsDemo[[5, 1, 2, 2]] = 108  # => 117.600
      @exponentsDemo[[1, 5, 1, 2]] = 109  # => 119.070
      @exponentsDemo[[7, 3, 1, 1]] = 110  # => 120.960
      @exponentsDemo[[3, 2, 1, 3]] = 111  # => 123.480
      @exponentsDemo[[4, 2, 3, 1]] = 112  # => 126.000
      @exponentsDemo[[1, 1, 5, 1]] = 113  # => 131.250
      @exponentsDemo[[2, 3, 2, 2]] = 114  # => 132.300
      @exponentsDemo[[8, 1, 2, 1]] = 115  # => 134.400
      @exponentsDemo[[4, 5, 1, 1]] = 116  # => 136.080
      @exponentsDemo[[6, 2, 1, 2]] = 117  # => 141.120
      @exponentsDemo[[1, 4, 3, 1]] = 118  # => 141.750
      @exponentsDemo[[2, 1, 1, 4]] = 119  # => 144.060
      @exponentsDemo[[3, 1, 3, 2]] = 120  # => 147.000
      @exponentsDemo[[5, 3, 2, 1]] = 121  # => 151.200
      @exponentsDemo[[1, 7, 1, 1]] = 122  # => 153.090
      @exponentsDemo[[1, 2, 2, 3]] = 123  # => 154.350
      @exponentsDemo[[2, 2, 4, 1]] = 124  # => 157.500
      @exponentsDemo[[3, 4, 1, 2]] = 125  # => 158.760
      @exponentsDemo[[9, 2, 1, 1]] = 126  # => 161.280
      @exponentsDemo[[5, 1, 1, 3]] = 127  # => 164.640
      @exponentsDemo[[6, 1, 3, 1]] = 128  # => 168.000
      @exponentsDemo[[2, 5, 2, 1]] = 129  # => 170.100
      @exponentsDemo[[4, 2, 2, 2]] = 130  # => 176.400
      @exponentsDemo[[6, 4, 1, 1]] = 131  # => 181.440
      @exponentsDemo[[1, 1, 4, 2]] = 132  # => 183.750
      @exponentsDemo[[2, 3, 1, 3]] = 133  # => 185.220
      @exponentsDemo[[8, 1, 1, 2]] = 134  # => 188.160
      @exponentsDemo[[3, 3, 3, 1]] = 135  # => 189.000
      @exponentsDemo[[1, 4, 2, 2]] = 136  # => 198.450
      @exponentsDemo[[7, 2, 2, 1]] = 137  # => 201.600
      @exponentsDemo[[3, 6, 1, 1]] = 138  # => 204.120
      @exponentsDemo[[3, 1, 2, 3]] = 139  # => 205.800
      @exponentsDemo[[4, 1, 4, 1]] = 140  # => 210.000
      @exponentsDemo[[5, 3, 1, 2]] = 141  # => 211.680
      @exponentsDemo[[1, 2, 1, 4]] = 142  # => 216.090
      @exponentsDemo[[2, 2, 3, 2]] = 143  # => 220.500
      @exponentsDemo[[4, 4, 2, 1]] = 144  # => 226.800
      @exponentsDemo[[6, 1, 2, 2]] = 145  # => 235.200
      @exponentsDemo[[1, 3, 4, 1]] = 146  # => 236.250
      @exponentsDemo[[2, 5, 1, 2]] = 147  # => 238.140
      @exponentsDemo[[8, 3, 1, 1]] = 148  # => 241.920
      @exponentsDemo[[4, 2, 1, 3]] = 149  # => 246.960
      @exponentsDemo[[5, 2, 3, 1]] = 150  # => 252.000
      @exponentsDemo[[1, 6, 2, 1]] = 151  # => 255.150
      @exponentsDemo[[1, 1, 3, 3]] = 152  # => 257.250
      @exponentsDemo[[2, 1, 5, 1]] = 153  # => 262.500
      @exponentsDemo[[3, 3, 2, 2]] = 154  # => 264.600
      @exponentsDemo[[9, 1, 2, 1]] = 155  # => 268.800
      @exponentsDemo[[5, 5, 1, 1]] = 156  # => 272.160
      @exponentsDemo[[1, 4, 1, 3]] = 157  # => 277.830
      @exponentsDemo[[7, 2, 1, 2]] = 158  # => 282.240
      @exponentsDemo[[2, 4, 3, 1]] = 159  # => 283.500
      @exponentsDemo[[3, 1, 1, 4]] = 160  # => 288.120
      @exponentsDemo[[4, 1, 3, 2]] = 161  # => 294.000
      @exponentsDemo[[6, 3, 2, 1]] = 162  # => 302.400
      @exponentsDemo[[2, 7, 1, 1]] = 163  # => 306.180
      @exponentsDemo[[2, 2, 2, 3]] = 164  # => 308.700
      @exponentsDemo[[3, 2, 4, 1]] = 165  # => 315.000
      @exponentsDemo[[4, 4, 1, 2]] = 166  # => 317.520
      @exponentsDemo[[6, 1, 1, 3]] = 167  # => 329.280
      @exponentsDemo[[1, 3, 3, 2]] = 168  # => 330.750
      @exponentsDemo[[7, 1, 3, 1]] = 169  # => 336.000
      @exponentsDemo[[3, 5, 2, 1]] = 170  # => 340.200
      @exponentsDemo[[5, 2, 2, 2]] = 171  # => 352.800
      @exponentsDemo[[1, 6, 1, 2]] = 172  # => 357.210
      @exponentsDemo[[1, 1, 2, 4]] = 173  # => 360.150
      @exponentsDemo[[7, 4, 1, 1]] = 174  # => 362.880
      @exponentsDemo[[2, 1, 4, 2]] = 175  # => 367.500
      @exponentsDemo[[3, 3, 1, 3]] = 176  # => 370.440
      @exponentsDemo[[9, 1, 1, 2]] = 177  # => 376.320
      @exponentsDemo[[4, 3, 3, 1]] = 178  # => 378.000
      @exponentsDemo[[1, 2, 5, 1]] = 179  # => 393.750
      @exponentsDemo[[2, 4, 2, 2]] = 180  # => 396.900
      @exponentsDemo[[8, 2, 2, 1]] = 181  # => 403.200
      @exponentsDemo[[4, 6, 1, 1]] = 182  # => 408.240
      @exponentsDemo[[4, 1, 2, 3]] = 183  # => 411.600
      @exponentsDemo[[5, 1, 4, 1]] = 184  # => 420.000
      @exponentsDemo[[6, 3, 1, 2]] = 185  # => 423.360
      @exponentsDemo[[1, 5, 3, 1]] = 186  # => 425.250
      @exponentsDemo[[2, 2, 1, 4]] = 187  # => 432.180
      @exponentsDemo[[3, 2, 3, 2]] = 188  # => 441.000
      @exponentsDemo[[5, 4, 2, 1]] = 189  # => 453.600
      @exponentsDemo[[1, 8, 1, 1]] = 190  # => 459.270
      @exponentsDemo[[1, 3, 2, 3]] = 191  # => 463.050
      @exponentsDemo[[7, 1, 2, 2]] = 192  # => 470.400
      @exponentsDemo[[2, 3, 4, 1]] = 193  # => 472.500
      @exponentsDemo[[3, 5, 1, 2]] = 194  # => 476.280
      @exponentsDemo[[9, 3, 1, 1]] = 195  # => 483.840
      @exponentsDemo[[5, 2, 1, 3]] = 196  # => 493.920
      @exponentsDemo[[6, 2, 3, 1]] = 197  # => 504.000
      @exponentsDemo[[2, 6, 2, 1]] = 198  # => 510.300
      @exponentsDemo[[2, 1, 3, 3]] = 199  # => 514.500
      @exponentsDemo[[3, 1, 5, 1]] = 200  # => 525.000
      @exponentsDemo[[4, 3, 2, 2]] = 201  # => 529.200
      @exponentsDemo[[6, 5, 1, 1]] = 202  # => 544.320
      @exponentsDemo[[1, 2, 4, 2]] = 203  # => 551.250
      @exponentsDemo[[2, 4, 1, 3]] = 204  # => 555.660
      @exponentsDemo[[8, 2, 1, 2]] = 205  # => 564.480
      @exponentsDemo[[3, 4, 3, 1]] = 206  # => 567.000
      @exponentsDemo[[4, 1, 1, 4]] = 207  # => 576.240
      @exponentsDemo[[5, 1, 3, 2]] = 208  # => 588.000
      @exponentsDemo[[1, 5, 2, 2]] = 209  # => 595.350
      @exponentsDemo[[7, 3, 2, 1]] = 210  # => 604.800
      @exponentsDemo[[3, 7, 1, 1]] = 211  # => 612.360
      @exponentsDemo[[3, 2, 2, 3]] = 212  # => 617.400
      @exponentsDemo[[4, 2, 4, 1]] = 213  # => 630.000
      @exponentsDemo[[5, 4, 1, 2]] = 214  # => 635.040
      @exponentsDemo[[1, 3, 1, 4]] = 215  # => 648.270
      @exponentsDemo[[7, 1, 1, 3]] = 216  # => 658.560
      @exponentsDemo[[2, 3, 3, 2]] = 217  # => 661.500
      @exponentsDemo[[8, 1, 3, 1]] = 218  # => 672.000
      @exponentsDemo[[4, 5, 2, 1]] = 219  # => 680.400
      @exponentsDemo[[6, 2, 2, 2]] = 220  # => 705.600
      @exponentsDemo[[1, 4, 4, 1]] = 221  # => 708.750
      @exponentsDemo[[2, 6, 1, 2]] = 222  # => 714.420
      @exponentsDemo[[2, 1, 2, 4]] = 223  # => 720.300
      @exponentsDemo[[8, 4, 1, 1]] = 224  # => 725.760
      @exponentsDemo[[3, 1, 4, 2]] = 225  # => 735.000
      @exponentsDemo[[4, 3, 1, 3]] = 226  # => 740.880
      @exponentsDemo[[5, 3, 3, 1]] = 227  # => 756.000
      @exponentsDemo[[1, 7, 2, 1]] = 228  # => 765.450
      @exponentsDemo[[1, 2, 3, 3]] = 229  # => 771.750
      @exponentsDemo[[2, 2, 5, 1]] = 230  # => 787.500
      @exponentsDemo[[3, 4, 2, 2]] = 231  # => 793.800
      @exponentsDemo[[9, 2, 2, 1]] = 232  # => 806.400
      @exponentsDemo[[5, 6, 1, 1]] = 233  # => 816.480
      @exponentsDemo[[5, 1, 2, 3]] = 234  # => 823.200
      @exponentsDemo[[1, 5, 1, 3]] = 235  # => 833.490
      @exponentsDemo[[6, 1, 4, 1]] = 236  # => 840.000
      @exponentsDemo[[7, 3, 1, 2]] = 237  # => 846.720
      @exponentsDemo[[2, 5, 3, 1]] = 238  # => 850.500
      @exponentsDemo[[3, 2, 1, 4]] = 239  # => 864.360
      @exponentsDemo[[4, 2, 3, 2]] = 240  # => 882.000
      @exponentsDemo[[6, 4, 2, 1]] = 241  # => 907.200
      @exponentsDemo[[2, 8, 1, 1]] = 242  # => 918.540
      @exponentsDemo[[1, 1, 5, 2]] = 243  # => 918.750
      @exponentsDemo[[2, 3, 2, 3]] = 244  # => 926.100
      @exponentsDemo[[8, 1, 2, 2]] = 245  # => 940.800
      @exponentsDemo[[3, 3, 4, 1]] = 246  # => 945.000
      @exponentsDemo[[4, 5, 1, 2]] = 247  # => 952.560
      @exponentsDemo[[6, 2, 1, 3]] = 248  # => 987.840
      @exponentsDemo[[1, 4, 3, 2]] = 249  # => 992.250
      @exponentsDemo[[7, 2, 3, 1]] = 250  # => 1.008.000
      @exponentsDemo[[3, 6, 2, 1]] = 251  # => 1.020.600
      @exponentsDemo[[3, 1, 3, 3]] = 252  # => 1.029.000
      @exponentsDemo[[4, 1, 5, 1]] = 253  # => 1.050.000
      @exponentsDemo[[5, 3, 2, 2]] = 254  # => 1.058.400
      @exponentsDemo[[1, 7, 1, 2]] = 255  # => 1.071.630
      @exponentsDemo[[1, 2, 2, 4]] = 256  # => 1.080.450
      @exponentsDemo[[7, 5, 1, 1]] = 257  # => 1.088.640
      @exponentsDemo[[2, 2, 4, 2]] = 258  # => 1.102.500
      @exponentsDemo[[3, 4, 1, 3]] = 259  # => 1.111.320
      @exponentsDemo[[9, 2, 1, 2]] = 260  # => 1.128.960
      @exponentsDemo[[4, 4, 3, 1]] = 261  # => 1.134.000
      @exponentsDemo[[5, 1, 1, 4]] = 262  # => 1.152.480
      @exponentsDemo[[6, 1, 3, 2]] = 263  # => 1.176.000
      @exponentsDemo[[1, 3, 5, 1]] = 264  # => 1.181.250
      @exponentsDemo[[2, 5, 2, 2]] = 265  # => 1.190.700
      @exponentsDemo[[8, 3, 2, 1]] = 266  # => 1.209.600
      @exponentsDemo[[4, 7, 1, 1]] = 267  # => 1.224.720
      @exponentsDemo[[4, 2, 2, 3]] = 268  # => 1.234.800
      @exponentsDemo[[5, 2, 4, 1]] = 269  # => 1.260.000
      @exponentsDemo[[6, 4, 1, 2]] = 270  # => 1.270.080
      @exponentsDemo[[1, 6, 3, 1]] = 271  # => 1.275.750
      @exponentsDemo[[1, 1, 4, 3]] = 272  # => 1.286.250
      @exponentsDemo[[2, 3, 1, 4]] = 273  # => 1.296.540
      @exponentsDemo[[8, 1, 1, 3]] = 274  # => 1.317.120
      @exponentsDemo[[3, 3, 3, 2]] = 275  # => 1.323.000
      @exponentsDemo[[9, 1, 3, 1]] = 276  # => 1.344.000
      @exponentsDemo[[5, 5, 2, 1]] = 277  # => 1.360.800
      @exponentsDemo[[1, 4, 2, 3]] = 278  # => 1.389.150
      @exponentsDemo[[7, 2, 2, 2]] = 279  # => 1.411.200
      @exponentsDemo[[2, 4, 4, 1]] = 280  # => 1.417.500
      @exponentsDemo[[3, 6, 1, 2]] = 281  # => 1.428.840
      @exponentsDemo[[3, 1, 2, 4]] = 282  # => 1.440.600
      @exponentsDemo[[9, 4, 1, 1]] = 283  # => 1.451.520
      @exponentsDemo[[4, 1, 4, 2]] = 284  # => 1.470.000
      @exponentsDemo[[5, 3, 1, 3]] = 285  # => 1.481.760
      @exponentsDemo[[6, 3, 3, 1]] = 286  # => 1.512.000
      @exponentsDemo[[2, 7, 2, 1]] = 287  # => 1.530.900
      @exponentsDemo[[2, 2, 3, 3]] = 288  # => 1.543.500
      @exponentsDemo[[3, 2, 5, 1]] = 289  # => 1.575.000
      @exponentsDemo[[4, 4, 2, 2]] = 290  # => 1.587.600
      @exponentsDemo[[6, 6, 1, 1]] = 291  # => 1.632.960
      @exponentsDemo[[6, 1, 2, 3]] = 292  # => 1.646.400
      @exponentsDemo[[1, 3, 4, 2]] = 293  # => 1.653.750
      @exponentsDemo[[2, 5, 1, 3]] = 294  # => 1.666.980
      @exponentsDemo[[7, 1, 4, 1]] = 295  # => 1.680.000
      @exponentsDemo[[8, 3, 1, 2]] = 296  # => 1.693.440
      @exponentsDemo[[3, 5, 3, 1]] = 297  # => 1.701.000
      @exponentsDemo[[4, 2, 1, 4]] = 298  # => 1.728.720
      @exponentsDemo[[5, 2, 3, 2]] = 299  # => 1.764.000 # ==> SHORT
      @exponentsDemo[[1, 6, 2, 2]] = 300  # => 1.786.050 # ==> SHORT
      @exponentsDemo[[1, 1, 3, 4]] = 301  # => 1.800.750 # ==> SHORT
      @exponentsDemo[[7, 4, 2, 1]] = 302  # => 1.814.400 # ==> SHORT
      @exponentsDemo[[3, 8, 1, 1]] = 303  # => 1.837.080 # ==> SHORT
      @exponentsDemo[[2, 1, 5, 2]] = 304  # => 1.837.500 # ==> SHORT
      @exponentsDemo[[3, 3, 2, 3]] = 305  # => 1.852.200 # ==> SHORT
      @exponentsDemo[[9, 1, 2, 2]] = 306  # => 1.881.600 # ==> SHORT
      @exponentsDemo[[4, 3, 4, 1]] = 307  # => 1.890.000 # ==> SHORT
      @exponentsDemo[[5, 5, 1, 2]] = 308  # => 1.905.120 # ==> SHORT
      @exponentsDemo[[1, 4, 1, 4]] = 309  # => 1.944.810 # ==> SHORT
      @exponentsDemo[[7, 2, 1, 3]] = 310  # => 1.975.680 # ==> SHORT
      @exponentsDemo[[2, 4, 3, 2]] = 311  # => 1.984.500 # ==> SHORT
      @exponentsDemo[[8, 2, 3, 1]] = 312  # => 2.016.000 # ==> SHORT
      @exponentsDemo[[4, 6, 2, 1]] = 313  # => 2.041.200 # ==> SHORT
      @exponentsDemo[[4, 1, 3, 3]] = 314  # => 2.058.000 # ==> SHORT
      @exponentsDemo[[5, 1, 5, 1]] = 315  # => 2.100.000 # ==> SHORT
      @exponentsDemo[[6, 3, 2, 2]] = 316  # => 2.116.800 # ==> SHORT
      @exponentsDemo[[1, 5, 4, 1]] = 317  # => 2.126.250 # ==> SHORT
      @exponentsDemo[[2, 7, 1, 2]] = 318  # => 2.143.260 # ==> SHORT
      @exponentsDemo[[2, 2, 2, 4]] = 319  # => 2.160.900 # ==> SHORT
      @exponentsDemo[[8, 5, 1, 1]] = 320  # => 2.177.280 # ==> SHORT
      @exponentsDemo[[3, 2, 4, 2]] = 321  # => 2.205.000 # ==> SHORT
      @exponentsDemo[[4, 4, 1, 3]] = 322  # => 2.222.640 # ==> SHORT
      @exponentsDemo[[5, 4, 3, 1]] = 323  # => 2.268.000 # ==> SHORT
      @exponentsDemo[[1, 8, 2, 1]] = 324  # => 2.296.350 # ==> SHORT
      @exponentsDemo[[6, 1, 1, 4]] = 325  # => 2.304.960 # ==> SHORT
      @exponentsDemo[[1, 3, 3, 3]] = 326  # => 2.315.250 # ==> SHORT
      @exponentsDemo[[7, 1, 3, 2]] = 327  # => 2.352.000 # ==> SHORT
      @exponentsDemo[[2, 3, 5, 1]] = 328  # => 2.362.500 # ==> SHORT
      @exponentsDemo[[3, 5, 2, 2]] = 329  # => 2.381.400 # ==> SHORT
      @exponentsDemo[[9, 3, 2, 1]] = 330  # => 2.419.200 # ==> SHORT
      @exponentsDemo[[5, 7, 1, 1]] = 331  # => 2.449.440 # ==> SHORT
      @exponentsDemo[[5, 2, 2, 3]] = 332  # => 2.469.600 # ==> SHORT
      @exponentsDemo[[1, 6, 1, 3]] = 333  # => 2.500.470 # ==> SHORT
      @exponentsDemo[[6, 2, 4, 1]] = 334  # => 2.520.000 # ==> SHORT
      @exponentsDemo[[7, 4, 1, 2]] = 335  # => 2.540.160 # ==> SHORT
      @exponentsDemo[[2, 6, 3, 1]] = 336  # => 2.551.500 # ==> SHORT
      @exponentsDemo[[2, 1, 4, 3]] = 337  # => 2.572.500 # ==> SHORT
      @exponentsDemo[[3, 3, 1, 4]] = 338  # => 2.593.080 # ==> SHORT
      @exponentsDemo[[9, 1, 1, 3]] = 339  # => 2.634.240 # ==> SHORT
      @exponentsDemo[[4, 3, 3, 2]] = 340  # => 2.646.000 # ==> SHORT
      @exponentsDemo[[6, 5, 2, 1]] = 341  # => 2.721.600 # ==> SHORT
      @exponentsDemo[[1, 2, 5, 2]] = 342  # => 2.756.250 # ==> SHORT
      @exponentsDemo[[2, 4, 2, 3]] = 343  # => 2.778.300 # ==> SHORT
      @exponentsDemo[[8, 2, 2, 2]] = 344  # => 2.822.400 # ==> SHORT
      @exponentsDemo[[3, 4, 4, 1]] = 345  # => 2.835.000 # ==> SHORT
      @exponentsDemo[[4, 6, 1, 2]] = 346  # => 2.857.680 # ==> SHORT
      @exponentsDemo[[4, 1, 2, 4]] = 347  # => 2.881.200 # ==> SHORT
      @exponentsDemo[[5, 1, 4, 2]] = 348  # => 2.940.000 # ==> SHORT
      @exponentsDemo[[6, 3, 1, 3]] = 349  # => 2.963.520 # ==> SHORT
      @exponentsDemo[[1, 5, 3, 2]] = 350  # => 2.976.750 # ==> SHORT
      @exponentsDemo[[7, 3, 3, 1]] = 351  # => 3.024.000 # ==> SHORT
      @exponentsDemo[[3, 7, 2, 1]] = 352  # => 3.061.800 # ==> SHORT
      @exponentsDemo[[3, 2, 3, 3]] = 353  # => 3.087.000 # ==> SHORT
      @exponentsDemo[[4, 2, 5, 1]] = 354  # => 3.150.000 # ==> SHORT
      @exponentsDemo[[5, 4, 2, 2]] = 355  # => 3.175.200 # ==> SHORT
      @exponentsDemo[[1, 8, 1, 2]] = 356  # => 3.214.890 # ==> SHORT
      @exponentsDemo[[1, 3, 2, 4]] = 357  # => 3.241.350 # ==> SHORT
      @exponentsDemo[[7, 6, 1, 1]] = 358  # => 3.265.920 # ==> SHORT
      @exponentsDemo[[7, 1, 2, 3]] = 359  # => 3.292.800 # ==> SHORT
      @exponentsDemo[[2, 3, 4, 2]] = 360  # => 3.307.500 # ==> SHORT
      @exponentsDemo[[3, 5, 1, 3]] = 361  # => 3.333.960 # ==> SHORT
      @exponentsDemo[[8, 1, 4, 1]] = 362  # => 3.360.000 # ==> SHORT
      @exponentsDemo[[9, 3, 1, 2]] = 363  # => 3.386.880 # ==> SHORT
      @exponentsDemo[[4, 5, 3, 1]] = 364  # => 3.402.000 # ==> SHORT
      @exponentsDemo[[5, 2, 1, 4]] = 365  # => 3.457.440 # ==> SHORT
      @exponentsDemo[[6, 2, 3, 2]] = 366  # => 3.528.000 # ==> SHORT
      @exponentsDemo[[1, 4, 5, 1]] = 367  # => 3.543.750 # ==> SHORT
      @exponentsDemo[[2, 6, 2, 2]] = 368  # => 3.572.100 # ==> SHORT
      @exponentsDemo[[2, 1, 3, 4]] = 369  # => 3.601.500 # ==> SHORT
      @exponentsDemo[[8, 4, 2, 1]] = 370  # => 3.628.800 # ==> SHORT
      @exponentsDemo[[4, 8, 1, 1]] = 371  # => 3.674.160 # ==> SHORT
      @exponentsDemo[[3, 1, 5, 2]] = 372  # => 3.675.000 # ==> SHORT
      @exponentsDemo[[4, 3, 2, 3]] = 373  # => 3.704.400 # ==> SHORT
      @exponentsDemo[[5, 3, 4, 1]] = 374  # => 3.780.000 # ==> SHORT
      @exponentsDemo[[6, 5, 1, 2]] = 375  # => 3.810.240 # ==> SHORT
      @exponentsDemo[[1, 7, 3, 1]] = 376  # => 3.827.250 # ==> SHORT
      @exponentsDemo[[1, 2, 4, 3]] = 377  # => 3.858.750 # ==> SHORT
      @exponentsDemo[[2, 4, 1, 4]] = 378  # => 3.889.620 # ==> SHORT
      @exponentsDemo[[8, 2, 1, 3]] = 379  # => 3.951.360 # ==> SHORT
      @exponentsDemo[[3, 4, 3, 2]] = 380  # => 3.969.000 # ==> SHORT
      @exponentsDemo[[9, 2, 3, 1]] = 381  # => 4.032.000 # ==> SHORT
      @exponentsDemo[[5, 6, 2, 1]] = 382  # => 4.082.400 # ==> SHORT
      @exponentsDemo[[5, 1, 3, 3]] = 383  # => 4.116.000 # ==> SHORT
      @exponentsDemo[[1, 5, 2, 3]] = 384  # => 4.167.450 # ==> SHORT
      @exponentsDemo[[6, 1, 5, 1]] = 385  # => 4.200.000 # ==> SHORT
      @exponentsDemo[[7, 3, 2, 2]] = 386  # => 4.233.600 # ==> SHORT
      @exponentsDemo[[2, 5, 4, 1]] = 387  # => 4.252.500 # ==> SHORT
      @exponentsDemo[[3, 7, 1, 2]] = 388  # => 4.286.520 # ==> SHORT
      @exponentsDemo[[3, 2, 2, 4]] = 389  # => 4.321.800 # ==> SHORT
      @exponentsDemo[[9, 5, 1, 1]] = 390  # => 4.354.560 # ==> SHORT
      @exponentsDemo[[4, 2, 4, 2]] = 391  # => 4.410.000 # ==> SHORT
      @exponentsDemo[[5, 4, 1, 3]] = 392  # => 4.445.280 # ==> SHORT
      @exponentsDemo[[6, 4, 3, 1]] = 393  # => 4.536.000 # ==> SHORT
      @exponentsDemo[[2, 8, 2, 1]] = 394  # => 4.592.700 # ==> SHORT
      @exponentsDemo[[7, 1, 1, 4]] = 395  # => 4.609.920 # ==> SHORT
      @exponentsDemo[[2, 3, 3, 3]] = 396  # => 4.630.500 # ==> SHORT
      @exponentsDemo[[8, 1, 3, 2]] = 397  # => 4.704.000 # ==> SHORT
      @exponentsDemo[[3, 3, 5, 1]] = 398  # => 4.725.000 # ==> SHORT
      @exponentsDemo[[4, 5, 2, 2]] = 399  # => 4.762.800 # ==> SHORT
      @exponentsDemo[[6, 7, 1, 1]] = 400  # => 4.898.880 # ==> SHORT
      @exponentsDemo[[6, 2, 2, 3]] = 401  # => 4.939.200 # ==> SHORT
      @exponentsDemo[[1, 4, 4, 2]] = 402  # => 4.961.250 # ==> SHORT
      @exponentsDemo[[2, 6, 1, 3]] = 403  # => 5.000.940 # ==> SHORT
      @exponentsDemo[[7, 2, 4, 1]] = 404  # => 5.040.000 # ==> SHORT
      @exponentsDemo[[8, 4, 1, 2]] = 405  # => 5.080.320 # ==> SHORT
      @exponentsDemo[[3, 6, 3, 1]] = 406  # => 5.103.000 # ==> SHORT
      @exponentsDemo[[3, 1, 4, 3]] = 407  # => 5.145.000 # ==> SHORT
      @exponentsDemo[[4, 3, 1, 4]] = 408  # => 5.186.160 # ==> SHORT
      @exponentsDemo[[5, 3, 3, 2]] = 409  # => 5.292.000 # ==> SHORT
      @exponentsDemo[[1, 7, 2, 2]] = 410  # => 5.358.150 # ==> SHORT
      @exponentsDemo[[1, 2, 3, 4]] = 411  # => 5.402.250 # ==> SHORT
      @exponentsDemo[[7, 5, 2, 1]] = 412  # => 5.443.200 # ==> SHORT
      @exponentsDemo[[2, 2, 5, 2]] = 413  # => 5.512.500 # ==> SHORT
      @exponentsDemo[[3, 4, 2, 3]] = 414  # => 5.556.600 # ==> SHORT
      @exponentsDemo[[9, 2, 2, 2]] = 415  # => 5.644.800 # ==> SHORT
      @exponentsDemo[[4, 4, 4, 1]] = 416  # => 5.670.000 # ==> SHORT
      @exponentsDemo[[5, 6, 1, 2]] = 417  # => 5.715.360 # ==> SHORT
      @exponentsDemo[[5, 1, 2, 4]] = 418  # => 5.762.400 # ==> SHORT
      @exponentsDemo[[1, 5, 1, 4]] = 419  # => 5.834.430 # ==> SHORT
      @exponentsDemo[[6, 1, 4, 2]] = 420  # => 5.880.000 # ==> SHORT
      @exponentsDemo[[7, 3, 1, 3]] = 421  # => 5.927.040 # ==> SHORT
      @exponentsDemo[[2, 5, 3, 2]] = 422  # => 5.953.500 # ==> SHORT
      @exponentsDemo[[8, 3, 3, 1]] = 423  # => 6.048.000 # ==> SHORT
      @exponentsDemo[[4, 7, 2, 1]] = 424  # => 6.123.600 # ==> SHORT
      @exponentsDemo[[4, 2, 3, 3]] = 425  # => 6.174.000 # ==> SHORT
      @exponentsDemo[[5, 2, 5, 1]] = 426  # => 6.300.000 # ==> SHORT
      @exponentsDemo[[6, 4, 2, 2]] = 427  # => 6.350.400 # ==> SHORT
      @exponentsDemo[[1, 6, 4, 1]] = 428  # => 6.378.750 # ==> SHORT
      @exponentsDemo[[2, 8, 1, 2]] = 429  # => 6.429.780 # ==> SHORT
      @exponentsDemo[[1, 1, 5, 3]] = 430  # => 6.431.250 # ==> SHORT
      @exponentsDemo[[2, 3, 2, 4]] = 431  # => 6.482.700 # ==> SHORT
      @exponentsDemo[[8, 6, 1, 1]] = 432  # => 6.531.840 # ==> SHORT
      @exponentsDemo[[8, 1, 2, 3]] = 433  # => 6.585.600 # ==> SHORT
      @exponentsDemo[[3, 3, 4, 2]] = 434  # => 6.615.000 # ==> SHORT
      @exponentsDemo[[4, 5, 1, 3]] = 435  # => 6.667.920 # ==> SHORT
      @exponentsDemo[[9, 1, 4, 1]] = 436  # => 6.720.000 # ==> SHORT
      @exponentsDemo[[5, 5, 3, 1]] = 437  # => 6.804.000 # ==> SHORT
      @exponentsDemo[[6, 2, 1, 4]] = 438  # => 6.914.880 # ==> SHORT
      @exponentsDemo[[1, 4, 3, 3]] = 439  # => 6.945.750 # ==> SHORT
      @exponentsDemo[[7, 2, 3, 2]] = 440  # => 7.056.000 # ==> SHORT
      @exponentsDemo[[2, 4, 5, 1]] = 441  # => 7.087.500 # ==> SHORT
      @exponentsDemo[[3, 6, 2, 2]] = 442  # => 7.144.200 # ==> SHORT
      @exponentsDemo[[3, 1, 3, 4]] = 443  # => 7.203.000 # ==> SHORT
      @exponentsDemo[[9, 4, 2, 1]] = 444  # => 7.257.600 # ==> SHORT
      @exponentsDemo[[5, 8, 1, 1]] = 445  # => 7.348.320 # ==> SHORT
      @exponentsDemo[[4, 1, 5, 2]] = 446  # => 7.350.000 # ==> SHORT
      @exponentsDemo[[5, 3, 2, 3]] = 447  # => 7.408.800 # ==> SHORT
      @exponentsDemo[[1, 7, 1, 3]] = 448  # => 7.501.410 # ==> SHORT
      @exponentsDemo[[6, 3, 4, 1]] = 449  # => 7.560.000 # ==> SHORT
      @exponentsDemo[[7, 5, 1, 2]] = 450  # => 7.620.480 # ==> SHORT
      @exponentsDemo[[2, 7, 3, 1]] = 451  # => 7.654.500
      @exponentsDemo[[2, 2, 4, 3]] = 452  # => 7.717.500
      @exponentsDemo[[3, 4, 1, 4]] = 453  # => 7.779.240
      @exponentsDemo[[9, 2, 1, 3]] = 454  # => 7.902.720
      @exponentsDemo[[4, 4, 3, 2]] = 455  # => 7.938.000
      @exponentsDemo[[6, 6, 2, 1]] = 456  # => 8.164.800
      @exponentsDemo[[6, 1, 3, 3]] = 457  # => 8.232.000
      @exponentsDemo[[1, 3, 5, 2]] = 458  # => 8.268.750
      @exponentsDemo[[2, 5, 2, 3]] = 459  # => 8.334.900
      @exponentsDemo[[7, 1, 5, 1]] = 460  # => 8.400.000
      @exponentsDemo[[8, 3, 2, 2]] = 461  # => 8.467.200
      @exponentsDemo[[3, 5, 4, 1]] = 462  # => 8.505.000
      @exponentsDemo[[4, 7, 1, 2]] = 463  # => 8.573.040
      @exponentsDemo[[4, 2, 2, 4]] = 464  # => 8.643.600
      @exponentsDemo[[5, 2, 4, 2]] = 465  # => 8.820.000
      @exponentsDemo[[6, 4, 1, 3]] = 466  # => 8.890.560
      @exponentsDemo[[1, 6, 3, 2]] = 467  # => 8.930.250
      @exponentsDemo[[1, 1, 4, 4]] = 468  # => 9.003.750
      @exponentsDemo[[7, 4, 3, 1]] = 469  # => 9.072.000
      @exponentsDemo[[3, 8, 2, 1]] = 470  # => 9.185.400
      @exponentsDemo[[8, 1, 1, 4]] = 471  # => 9.219.840
      @exponentsDemo[[3, 3, 3, 3]] = 472  # => 9.261.000
      @exponentsDemo[[9, 1, 3, 2]] = 473  # => 9.408.000
      @exponentsDemo[[4, 3, 5, 1]] = 474  # => 9.450.000
      @exponentsDemo[[5, 5, 2, 2]] = 475  # => 9.525.600
      @exponentsDemo[[1, 4, 2, 4]] = 476  # => 9.724.050
      @exponentsDemo[[7, 7, 1, 1]] = 477  # => 9.797.760
      @exponentsDemo[[7, 2, 2, 3]] = 478  # => 9.878.400
      @exponentsDemo[[2, 4, 4, 2]] = 479  # => 9.922.500
      @exponentsDemo[[3, 6, 1, 3]] = 480  # => 10.001.880
      @exponentsDemo[[8, 2, 4, 1]] = 481  # => 10.080.000
      @exponentsDemo[[9, 4, 1, 2]] = 482  # => 10.160.640
      @exponentsDemo[[4, 6, 3, 1]] = 483  # => 10.206.000
      @exponentsDemo[[4, 1, 4, 3]] = 484  # => 10.290.000
      @exponentsDemo[[5, 3, 1, 4]] = 485  # => 10.372.320
      @exponentsDemo[[6, 3, 3, 2]] = 486  # => 10.584.000
      @exponentsDemo[[1, 5, 5, 1]] = 487  # => 10.631.250
      @exponentsDemo[[2, 7, 2, 2]] = 488  # => 10.716.300
      @exponentsDemo[[2, 2, 3, 4]] = 489  # => 10.804.500
      @exponentsDemo[[8, 5, 2, 1]] = 490  # => 10.886.400
      @exponentsDemo[[3, 2, 5, 2]] = 491  # => 11.025.000
      @exponentsDemo[[4, 4, 2, 3]] = 492  # => 11.113.200
      @exponentsDemo[[5, 4, 4, 1]] = 493  # => 11.340.000
      @exponentsDemo[[6, 6, 1, 2]] = 494  # => 11.430.720
      @exponentsDemo[[1, 8, 3, 1]] = 495  # => 11.481.750
      @exponentsDemo[[6, 1, 2, 4]] = 496  # => 11.524.800
      @exponentsDemo[[1, 3, 4, 3]] = 497  # => 11.576.250
      @exponentsDemo[[2, 5, 1, 4]] = 498  # => 11.668.860
      @exponentsDemo[[7, 1, 4, 2]] = 499  # => 11.760.000
      @exponentsDemo[[8, 3, 1, 3]] = 500  # => 11.854.080
      @exponentsDemo[[3, 5, 3, 2]] = 501  # => 11.907.000
      @exponentsDemo[[9, 3, 3, 1]] = 502  # => 12.096.000
      @exponentsDemo[[5, 7, 2, 1]] = 503  # => 12.247.200
      @exponentsDemo[[5, 2, 3, 3]] = 504  # => 12.348.000
      @exponentsDemo[[1, 6, 2, 3]] = 505  # => 12.502.350
      @exponentsDemo[[6, 2, 5, 1]] = 506  # => 12.600.000
      @exponentsDemo[[7, 4, 2, 2]] = 507  # => 12.700.800
      @exponentsDemo[[2, 6, 4, 1]] = 508  # => 12.757.500
      @exponentsDemo[[3, 8, 1, 2]] = 509  # => 12.859.560
      @exponentsDemo[[2, 1, 5, 3]] = 510  # => 12.862.500
      @exponentsDemo[[3, 3, 2, 4]] = 511  # => 12.965.400
      @exponentsDemo[[9, 6, 1, 1]] = 512  # => 13.063.680
      @exponentsDemo[[9, 1, 2, 3]] = 513  # => 13.171.200
      @exponentsDemo[[4, 3, 4, 2]] = 514  # => 13.230.000
      @exponentsDemo[[5, 5, 1, 3]] = 515  # => 13.335.840
      @exponentsDemo[[6, 5, 3, 1]] = 516  # => 13.608.000
      @exponentsDemo[[7, 2, 1, 4]] = 517  # => 13.829.760
      @exponentsDemo[[2, 4, 3, 3]] = 518  # => 13.891.500
      @exponentsDemo[[8, 2, 3, 2]] = 519  # => 14.112.000
      @exponentsDemo[[3, 4, 5, 1]] = 520  # => 14.175.000
      @exponentsDemo[[4, 6, 2, 2]] = 521  # => 14.288.400
      @exponentsDemo[[4, 1, 3, 4]] = 522  # => 14.406.000
      @exponentsDemo[[6, 8, 1, 1]] = 523  # => 14.696.640
      @exponentsDemo[[5, 1, 5, 2]] = 524  # => 14.700.000
      @exponentsDemo[[6, 3, 2, 3]] = 525  # => 14.817.600
      @exponentsDemo[[1, 5, 4, 2]] = 526  # => 14.883.750
      @exponentsDemo[[2, 7, 1, 3]] = 527  # => 15.002.820
      @exponentsDemo[[7, 3, 4, 1]] = 528  # => 15.120.000
      @exponentsDemo[[8, 5, 1, 2]] = 529  # => 15.240.960
      @exponentsDemo[[3, 7, 3, 1]] = 530  # => 15.309.000
      @exponentsDemo[[3, 2, 4, 3]] = 531  # => 15.435.000
      @exponentsDemo[[4, 4, 1, 4]] = 532  # => 15.558.480
      @exponentsDemo[[5, 4, 3, 2]] = 533  # => 15.876.000
      @exponentsDemo[[1, 8, 2, 2]] = 534  # => 16.074.450
      @exponentsDemo[[1, 3, 3, 4]] = 535  # => 16.206.750
      @exponentsDemo[[7, 6, 2, 1]] = 536  # => 16.329.600
      @exponentsDemo[[7, 1, 3, 3]] = 537  # => 16.464.000
      @exponentsDemo[[2, 3, 5, 2]] = 538  # => 16.537.500
      @exponentsDemo[[3, 5, 2, 3]] = 539  # => 16.669.800
      @exponentsDemo[[8, 1, 5, 1]] = 540  # => 16.800.000
      @exponentsDemo[[9, 3, 2, 2]] = 541  # => 16.934.400
      @exponentsDemo[[4, 5, 4, 1]] = 542  # => 17.010.000
      @exponentsDemo[[5, 7, 1, 2]] = 543  # => 17.146.080
      @exponentsDemo[[5, 2, 2, 4]] = 544  # => 17.287.200
      @exponentsDemo[[1, 6, 1, 4]] = 545  # => 17.503.290
      @exponentsDemo[[6, 2, 4, 2]] = 546  # => 17.640.000
      @exponentsDemo[[7, 4, 1, 3]] = 547  # => 17.781.120
      @exponentsDemo[[2, 6, 3, 2]] = 548  # => 17.860.500
      @exponentsDemo[[2, 1, 4, 4]] = 549  # => 18.007.500
      @exponentsDemo[[8, 4, 3, 1]] = 550  # => 18.144.000
      @exponentsDemo[[4, 8, 2, 1]] = 551  # => 18.370.800
      @exponentsDemo[[9, 1, 1, 4]] = 552  # => 18.439.680
      @exponentsDemo[[4, 3, 3, 3]] = 553  # => 18.522.000
      @exponentsDemo[[5, 3, 5, 1]] = 554  # => 18.900.000
      @exponentsDemo[[6, 5, 2, 2]] = 555  # => 19.051.200
      @exponentsDemo[[1, 7, 4, 1]] = 556  # => 19.136.250
      @exponentsDemo[[1, 2, 5, 3]] = 557  # => 19.293.750
      @exponentsDemo[[2, 4, 2, 4]] = 558  # => 19.448.100
      @exponentsDemo[[8, 7, 1, 1]] = 559  # => 19.595.520
      @exponentsDemo[[8, 2, 2, 3]] = 560  # => 19.756.800
      @exponentsDemo[[3, 4, 4, 2]] = 561  # => 19.845.000
      @exponentsDemo[[4, 6, 1, 3]] = 562  # => 20.003.760
      @exponentsDemo[[9, 2, 4, 1]] = 563  # => 20.160.000
      @exponentsDemo[[5, 6, 3, 1]] = 564  # => 20.412.000
      @exponentsDemo[[5, 1, 4, 3]] = 565  # => 20.580.000
      @exponentsDemo[[6, 3, 1, 4]] = 566  # => 20.744.640
      @exponentsDemo[[1, 5, 3, 3]] = 567  # => 20.837.250
      @exponentsDemo[[7, 3, 3, 2]] = 568  # => 21.168.000
      @exponentsDemo[[2, 5, 5, 1]] = 569  # => 21.262.500
      @exponentsDemo[[3, 7, 2, 2]] = 570  # => 21.432.600
      @exponentsDemo[[3, 2, 3, 4]] = 571  # => 21.609.000
      @exponentsDemo[[9, 5, 2, 1]] = 572  # => 21.772.800
      @exponentsDemo[[4, 2, 5, 2]] = 573  # => 22.050.000
      @exponentsDemo[[5, 4, 2, 3]] = 574  # => 22.226.400
      @exponentsDemo[[1, 8, 1, 3]] = 575  # => 22.504.230
      @exponentsDemo[[6, 4, 4, 1]] = 576  # => 22.680.000
      @exponentsDemo[[7, 6, 1, 2]] = 577  # => 22.861.440
      @exponentsDemo[[2, 8, 3, 1]] = 578  # => 22.963.500
      @exponentsDemo[[7, 1, 2, 4]] = 579  # => 23.049.600
      @exponentsDemo[[2, 3, 4, 3]] = 580  # => 23.152.500
      @exponentsDemo[[3, 5, 1, 4]] = 581  # => 23.337.720
      @exponentsDemo[[8, 1, 4, 2]] = 582  # => 23.520.000
      @exponentsDemo[[9, 3, 1, 3]] = 583  # => 23.708.160
      @exponentsDemo[[4, 5, 3, 2]] = 584  # => 23.814.000
      @exponentsDemo[[6, 7, 2, 1]] = 585  # => 24.494.400
      @exponentsDemo[[6, 2, 3, 3]] = 586  # => 24.696.000
      @exponentsDemo[[1, 4, 5, 2]] = 587  # => 24.806.250
      @exponentsDemo[[2, 6, 2, 3]] = 588  # => 25.004.700
      @exponentsDemo[[7, 2, 5, 1]] = 589  # => 25.200.000
      @exponentsDemo[[8, 4, 2, 2]] = 590  # => 25.401.600 # ==> MID
      @exponentsDemo[[3, 6, 4, 1]] = 591  # => 25.515.000 # ==> MID
      @exponentsDemo[[4, 8, 1, 2]] = 592  # => 25.719.120 # ==> MID
      @exponentsDemo[[3, 1, 5, 3]] = 593  # => 25.725.000 # ==> MID
      @exponentsDemo[[4, 3, 2, 4]] = 594  # => 25.930.800 # ==> MID
      @exponentsDemo[[5, 3, 4, 2]] = 595  # => 26.460.000 # ==> MID
      @exponentsDemo[[6, 5, 1, 3]] = 596  # => 26.671.680 # ==> MID
      @exponentsDemo[[1, 7, 3, 2]] = 597  # => 26.790.750 # ==> MID
      @exponentsDemo[[1, 2, 4, 4]] = 598  # => 27.011.250 # ==> MID
      @exponentsDemo[[7, 5, 3, 1]] = 599  # => 27.216.000 # ==> MID
      @exponentsDemo[[8, 2, 1, 4]] = 600  # => 27.659.520 # ==> MID
      @exponentsDemo[[3, 4, 3, 3]] = 601  # => 27.783.000 # ==> MID
      @exponentsDemo[[9, 2, 3, 2]] = 602  # => 28.224.000 # ==> MID
      @exponentsDemo[[4, 4, 5, 1]] = 603  # => 28.350.000 # ==> MID
      @exponentsDemo[[5, 6, 2, 2]] = 604  # => 28.576.800 # ==> MID
      @exponentsDemo[[5, 1, 3, 4]] = 605  # => 28.812.000 # ==> MID
      @exponentsDemo[[1, 5, 2, 4]] = 606  # => 29.172.150 # ==> MID
      @exponentsDemo[[7, 8, 1, 1]] = 607  # => 29.393.280 # ==> MID
      @exponentsDemo[[6, 1, 5, 2]] = 608  # => 29.400.000 # ==> MID
      @exponentsDemo[[7, 3, 2, 3]] = 609  # => 29.635.200 # ==> MID
      @exponentsDemo[[2, 5, 4, 2]] = 610  # => 29.767.500 # ==> MID
      @exponentsDemo[[3, 7, 1, 3]] = 611  # => 30.005.640 # ==> MID
      @exponentsDemo[[8, 3, 4, 1]] = 612  # => 30.240.000 # ==> MID
      @exponentsDemo[[9, 5, 1, 2]] = 613  # => 30.481.920 # ==> MID
      @exponentsDemo[[4, 7, 3, 1]] = 614  # => 30.618.000 # ==> MID
      @exponentsDemo[[4, 2, 4, 3]] = 615  # => 30.870.000 # ==> MID
      @exponentsDemo[[5, 4, 1, 4]] = 616  # => 31.116.960 # ==> MID
      @exponentsDemo[[6, 4, 3, 2]] = 617  # => 31.752.000 # ==> MID
      @exponentsDemo[[1, 6, 5, 1]] = 618  # => 31.893.750 # ==> MID
      @exponentsDemo[[2, 8, 2, 2]] = 619  # => 32.148.900 # ==> MID
      @exponentsDemo[[2, 3, 3, 4]] = 620  # => 32.413.500 # ==> MID
      @exponentsDemo[[8, 6, 2, 1]] = 621  # => 32.659.200 # ==> MID
      @exponentsDemo[[8, 1, 3, 3]] = 622  # => 32.928.000 # ==> MID
      @exponentsDemo[[3, 3, 5, 2]] = 623  # => 33.075.000 # ==> MID
      @exponentsDemo[[4, 5, 2, 3]] = 624  # => 33.339.600 # ==> MID
      @exponentsDemo[[9, 1, 5, 1]] = 625  # => 33.600.000 # ==> MID
      @exponentsDemo[[5, 5, 4, 1]] = 626  # => 34.020.000 # ==> MID
      @exponentsDemo[[6, 7, 1, 2]] = 627  # => 34.292.160 # ==> MID
      @exponentsDemo[[6, 2, 2, 4]] = 628  # => 34.574.400 # ==> MID
      @exponentsDemo[[1, 4, 4, 3]] = 629  # => 34.728.750 # ==> MID
      @exponentsDemo[[2, 6, 1, 4]] = 630  # => 35.006.580 # ==> MID
      @exponentsDemo[[7, 2, 4, 2]] = 631  # => 35.280.000 # ==> MID
      @exponentsDemo[[8, 4, 1, 3]] = 632  # => 35.562.240 # ==> MID
      @exponentsDemo[[3, 6, 3, 2]] = 633  # => 35.721.000 # ==> MID
      @exponentsDemo[[3, 1, 4, 4]] = 634  # => 36.015.000 # ==> MID
      @exponentsDemo[[9, 4, 3, 1]] = 635  # => 36.288.000 # ==> MID
      @exponentsDemo[[5, 8, 2, 1]] = 636  # => 36.741.600 # ==> MID
      @exponentsDemo[[5, 3, 3, 3]] = 637  # => 37.044.000 # ==> MID
      @exponentsDemo[[1, 7, 2, 3]] = 638  # => 37.507.050 # ==> MID
      @exponentsDemo[[6, 3, 5, 1]] = 639  # => 37.800.000 # ==> MID
      @exponentsDemo[[7, 5, 2, 2]] = 640  # => 38.102.400 # ==> MID
      @exponentsDemo[[2, 7, 4, 1]] = 641  # => 38.272.500 # ==> MID
      @exponentsDemo[[2, 2, 5, 3]] = 642  # => 38.587.500 # ==> MID
      @exponentsDemo[[3, 4, 2, 4]] = 643  # => 38.896.200 # ==> MID
      @exponentsDemo[[9, 7, 1, 1]] = 644  # => 39.191.040 # ==> MID
      @exponentsDemo[[9, 2, 2, 3]] = 645  # => 39.513.600 # ==> MID
      @exponentsDemo[[4, 4, 4, 2]] = 646  # => 39.690.000 # ==> MID
      @exponentsDemo[[5, 6, 1, 3]] = 647  # => 40.007.520 # ==> MID
      @exponentsDemo[[6, 6, 3, 1]] = 648  # => 40.824.000 # ==> MID
      @exponentsDemo[[6, 1, 4, 3]] = 649  # => 41.160.000 # ==> MID
      @exponentsDemo[[7, 3, 1, 4]] = 650  # => 41.489.280 # ==> MID
      @exponentsDemo[[2, 5, 3, 3]] = 651  # => 41.674.500 # ==> MID
      @exponentsDemo[[8, 3, 3, 2]] = 652  # => 42.336.000 # ==> MID
      @exponentsDemo[[3, 5, 5, 1]] = 653  # => 42.525.000 # ==> MID
      @exponentsDemo[[4, 7, 2, 2]] = 654  # => 42.865.200 # ==> MID
      @exponentsDemo[[4, 2, 3, 4]] = 655  # => 43.218.000 # ==> MID
      @exponentsDemo[[5, 2, 5, 2]] = 656  # => 44.100.000 # ==> MID
      @exponentsDemo[[6, 4, 2, 3]] = 657  # => 44.452.800 # ==> MID
      @exponentsDemo[[1, 6, 4, 2]] = 658  # => 44.651.250 # ==> MID
      @exponentsDemo[[2, 8, 1, 3]] = 659  # => 45.008.460 # ==> MID
      @exponentsDemo[[1, 1, 5, 4]] = 660  # => 45.018.750 # ==> MID
      @exponentsDemo[[7, 4, 4, 1]] = 661  # => 45.360.000 # ==> MID
      @exponentsDemo[[8, 6, 1, 2]] = 662  # => 45.722.880 # ==> MID
      @exponentsDemo[[3, 8, 3, 1]] = 663  # => 45.927.000 # ==> MID
      @exponentsDemo[[8, 1, 2, 4]] = 664  # => 46.099.200 # ==> MID
      @exponentsDemo[[3, 3, 4, 3]] = 665  # => 46.305.000 # ==> MID
      @exponentsDemo[[4, 5, 1, 4]] = 666  # => 46.675.440 # ==> MID
      @exponentsDemo[[9, 1, 4, 2]] = 667  # => 47.040.000 # ==> MID
      @exponentsDemo[[5, 5, 3, 2]] = 668  # => 47.628.000 # ==> MID
      @exponentsDemo[[1, 4, 3, 4]] = 669  # => 48.620.250 # ==> MID
      @exponentsDemo[[7, 7, 2, 1]] = 670  # => 48.988.800 # ==> MID
      @exponentsDemo[[7, 2, 3, 3]] = 671  # => 49.392.000 # ==> MID
      @exponentsDemo[[2, 4, 5, 2]] = 672  # => 49.612.500 # ==> MID
      @exponentsDemo[[3, 6, 2, 3]] = 673  # => 50.009.400 # ==> MID
      @exponentsDemo[[8, 2, 5, 1]] = 674  # => 50.400.000 # ==> MID
      @exponentsDemo[[9, 4, 2, 2]] = 675  # => 50.803.200 # ==> MID
      @exponentsDemo[[4, 6, 4, 1]] = 676  # => 51.030.000 # ==> MID
      @exponentsDemo[[5, 8, 1, 2]] = 677  # => 51.438.240 # ==> MID
      @exponentsDemo[[4, 1, 5, 3]] = 678  # => 51.450.000 # ==> MID
      @exponentsDemo[[5, 3, 2, 4]] = 679  # => 51.861.600 # ==> MID
      @exponentsDemo[[1, 7, 1, 4]] = 680  # => 52.509.870 # ==> MID
      @exponentsDemo[[6, 3, 4, 2]] = 681  # => 52.920.000 # ==> MID
      @exponentsDemo[[7, 5, 1, 3]] = 682  # => 53.343.360 # ==> MID
      @exponentsDemo[[2, 7, 3, 2]] = 683  # => 53.581.500 # ==> MID
      @exponentsDemo[[2, 2, 4, 4]] = 684  # => 54.022.500 # ==> MID
      @exponentsDemo[[8, 5, 3, 1]] = 685  # => 54.432.000 # ==> MID
      @exponentsDemo[[9, 2, 1, 4]] = 686  # => 55.319.040 # ==> MID
      @exponentsDemo[[4, 4, 3, 3]] = 687  # => 55.566.000 # ==> MID
      @exponentsDemo[[5, 4, 5, 1]] = 688  # => 56.700.000 # ==> MID
      @exponentsDemo[[6, 6, 2, 2]] = 689  # => 57.153.600 # ==> MID
      @exponentsDemo[[1, 8, 4, 1]] = 690  # => 57.408.750 # ==> MID
      @exponentsDemo[[6, 1, 3, 4]] = 691  # => 57.624.000 # ==> MID
      @exponentsDemo[[1, 3, 5, 3]] = 692  # => 57.881.250 # ==> MID
      @exponentsDemo[[2, 5, 2, 4]] = 693  # => 58.344.300 # ==> MID
      @exponentsDemo[[8, 8, 1, 1]] = 694  # => 58.786.560 # ==> MID
      @exponentsDemo[[7, 1, 5, 2]] = 695  # => 58.800.000 # ==> MID
      @exponentsDemo[[8, 3, 2, 3]] = 696  # => 59.270.400 # ==> MID
      @exponentsDemo[[3, 5, 4, 2]] = 697  # => 59.535.000 # ==> MID
      @exponentsDemo[[4, 7, 1, 3]] = 698  # => 60.011.280 # ==> MID
      @exponentsDemo[[9, 3, 4, 1]] = 699  # => 60.480.000 # ==> MID
      @exponentsDemo[[5, 7, 3, 1]] = 700  # => 61.236.000 # ==> MID
      @exponentsDemo[[5, 2, 4, 3]] = 701  # => 61.740.000 # ==> MID
      @exponentsDemo[[6, 4, 1, 4]] = 702  # => 62.233.920 # ==> MID
      @exponentsDemo[[1, 6, 3, 3]] = 703  # => 62.511.750 # ==> MID
      @exponentsDemo[[7, 4, 3, 2]] = 704  # => 63.504.000 # ==> MID
      @exponentsDemo[[2, 6, 5, 1]] = 705  # => 63.787.500 # ==> MID
      @exponentsDemo[[3, 8, 2, 2]] = 706  # => 64.297.800 # ==> MID
      @exponentsDemo[[3, 3, 3, 4]] = 707  # => 64.827.000 # ==> MID
      @exponentsDemo[[9, 6, 2, 1]] = 708  # => 65.318.400 # ==> MID
      @exponentsDemo[[9, 1, 3, 3]] = 709  # => 65.856.000 # ==> MID
      @exponentsDemo[[4, 3, 5, 2]] = 710  # => 66.150.000 # ==> MID
      @exponentsDemo[[5, 5, 2, 3]] = 711  # => 66.679.200 # ==> MID
      @exponentsDemo[[6, 5, 4, 1]] = 712  # => 68.040.000 # ==> MID
      @exponentsDemo[[7, 7, 1, 2]] = 713  # => 68.584.320 # ==> MID
      @exponentsDemo[[7, 2, 2, 4]] = 714  # => 69.148.800 # ==> MID
      @exponentsDemo[[2, 4, 4, 3]] = 715  # => 69.457.500 # ==> MID
      @exponentsDemo[[3, 6, 1, 4]] = 716  # => 70.013.160 # ==> MID
      @exponentsDemo[[8, 2, 4, 2]] = 717  # => 70.560.000 # ==> MID
      @exponentsDemo[[9, 4, 1, 3]] = 718  # => 71.124.480 # ==> MID
      @exponentsDemo[[4, 6, 3, 2]] = 719  # => 71.442.000 # ==> MID
      @exponentsDemo[[4, 1, 4, 4]] = 720  # => 72.030.000 # ==> MID
      @exponentsDemo[[6, 8, 2, 1]] = 721  # => 73.483.200 # ==> MID
      @exponentsDemo[[6, 3, 3, 3]] = 722  # => 74.088.000 # ==> MID
      @exponentsDemo[[1, 5, 5, 2]] = 723  # => 74.418.750 # ==> MID
      @exponentsDemo[[2, 7, 2, 3]] = 724  # => 75.014.100 # ==> MID
      @exponentsDemo[[7, 3, 5, 1]] = 725  # => 75.600.000 # ==> MID
      @exponentsDemo[[8, 5, 2, 2]] = 726  # => 76.204.800 # ==> MID
      @exponentsDemo[[3, 7, 4, 1]] = 727  # => 76.545.000 # ==> MID
      @exponentsDemo[[3, 2, 5, 3]] = 728  # => 77.175.000 # ==> MID
      @exponentsDemo[[4, 4, 2, 4]] = 729  # => 77.792.400 # ==> MID
      @exponentsDemo[[5, 4, 4, 2]] = 730  # => 79.380.000 # ==> MID
      @exponentsDemo[[6, 6, 1, 3]] = 731  # => 80.015.040
      @exponentsDemo[[1, 8, 3, 2]] = 732  # => 80.372.250
      @exponentsDemo[[1, 3, 4, 4]] = 733  # => 81.033.750
      @exponentsDemo[[7, 6, 3, 1]] = 734  # => 81.648.000
      @exponentsDemo[[7, 1, 4, 3]] = 735  # => 82.320.000
      @exponentsDemo[[8, 3, 1, 4]] = 736  # => 82.978.560
      @exponentsDemo[[3, 5, 3, 3]] = 737  # => 83.349.000
      @exponentsDemo[[9, 3, 3, 2]] = 738  # => 84.672.000
      @exponentsDemo[[4, 5, 5, 1]] = 739  # => 85.050.000
      @exponentsDemo[[5, 7, 2, 2]] = 740  # => 85.730.400
      @exponentsDemo[[5, 2, 3, 4]] = 741  # => 86.436.000
      @exponentsDemo[[1, 6, 2, 4]] = 742  # => 87.516.450
      @exponentsDemo[[6, 2, 5, 2]] = 743  # => 88.200.000
      @exponentsDemo[[7, 4, 2, 3]] = 744  # => 88.905.600
      @exponentsDemo[[2, 6, 4, 2]] = 745  # => 89.302.500
      @exponentsDemo[[3, 8, 1, 3]] = 746  # => 90.016.920
      @exponentsDemo[[2, 1, 5, 4]] = 747  # => 90.037.500
      @exponentsDemo[[8, 4, 4, 1]] = 748  # => 90.720.000
      @exponentsDemo[[9, 6, 1, 2]] = 749  # => 91.445.760
      @exponentsDemo[[4, 8, 3, 1]] = 750  # => 91.854.000
      @exponentsDemo[[9, 1, 2, 4]] = 751  # => 92.198.400
      @exponentsDemo[[4, 3, 4, 3]] = 752  # => 92.610.000
      @exponentsDemo[[5, 5, 1, 4]] = 753  # => 93.350.880
      @exponentsDemo[[6, 5, 3, 2]] = 754  # => 95.256.000
      @exponentsDemo[[1, 7, 5, 1]] = 755  # => 95.681.250
      @exponentsDemo[[2, 4, 3, 4]] = 756  # => 97.240.500
      @exponentsDemo[[8, 7, 2, 1]] = 757  # => 97.977.600
      @exponentsDemo[[8, 2, 3, 3]] = 758  # => 98.784.000
      @exponentsDemo[[3, 4, 5, 2]] = 759  # => 99.225.000
      @exponentsDemo[[4, 6, 2, 3]] = 760  # => 100.018.800
      @exponentsDemo[[9, 2, 5, 1]] = 761  # => 100.800.000
      @exponentsDemo[[5, 6, 4, 1]] = 762  # => 102.060.000
      @exponentsDemo[[6, 8, 1, 2]] = 763  # => 102.876.480
      @exponentsDemo[[5, 1, 5, 3]] = 764  # => 102.900.000
      @exponentsDemo[[6, 3, 2, 4]] = 765  # => 103.723.200
      @exponentsDemo[[1, 5, 4, 3]] = 766  # => 104.186.250
      @exponentsDemo[[2, 7, 1, 4]] = 767  # => 105.019.740
      @exponentsDemo[[7, 3, 4, 2]] = 768  # => 105.840.000
      @exponentsDemo[[8, 5, 1, 3]] = 769  # => 106.686.720
      @exponentsDemo[[3, 7, 3, 2]] = 770  # => 107.163.000
      @exponentsDemo[[3, 2, 4, 4]] = 771  # => 108.045.000
      @exponentsDemo[[9, 5, 3, 1]] = 772  # => 108.864.000
      @exponentsDemo[[5, 4, 3, 3]] = 773  # => 111.132.000
      @exponentsDemo[[1, 8, 2, 3]] = 774  # => 112.521.150
      @exponentsDemo[[6, 4, 5, 1]] = 775  # => 113.400.000
      @exponentsDemo[[7, 6, 2, 2]] = 776  # => 114.307.200
      @exponentsDemo[[2, 8, 4, 1]] = 777  # => 114.817.500
      @exponentsDemo[[7, 1, 3, 4]] = 778  # => 115.248.000
      @exponentsDemo[[2, 3, 5, 3]] = 779  # => 115.762.500
      @exponentsDemo[[3, 5, 2, 4]] = 780  # => 116.688.600
      @exponentsDemo[[9, 8, 1, 1]] = 781  # => 117.573.120
      @exponentsDemo[[8, 1, 5, 2]] = 782  # => 117.600.000
      @exponentsDemo[[9, 3, 2, 3]] = 783  # => 118.540.800
      @exponentsDemo[[4, 5, 4, 2]] = 784  # => 119.070.000
      @exponentsDemo[[5, 7, 1, 3]] = 785  # => 120.022.560
      @exponentsDemo[[6, 7, 3, 1]] = 786  # => 122.472.000
      @exponentsDemo[[6, 2, 4, 3]] = 787  # => 123.480.000
      @exponentsDemo[[7, 4, 1, 4]] = 788  # => 124.467.840
      @exponentsDemo[[2, 6, 3, 3]] = 789  # => 125.023.500
      @exponentsDemo[[8, 4, 3, 2]] = 790  # => 127.008.000
      @exponentsDemo[[3, 6, 5, 1]] = 791  # => 127.575.000
      @exponentsDemo[[4, 8, 2, 2]] = 792  # => 128.595.600
      @exponentsDemo[[4, 3, 3, 4]] = 793  # => 129.654.000
      @exponentsDemo[[5, 3, 5, 2]] = 794  # => 132.300.000
      @exponentsDemo[[6, 5, 2, 3]] = 795  # => 133.358.400
      @exponentsDemo[[1, 7, 4, 2]] = 796  # => 133.953.750
      @exponentsDemo[[1, 2, 5, 4]] = 797  # => 135.056.250
      @exponentsDemo[[7, 5, 4, 1]] = 798  # => 136.080.000
      @exponentsDemo[[8, 7, 1, 2]] = 799  # => 137.168.640
      @exponentsDemo[[8, 2, 2, 4]] = 800  # => 138.297.600
      @exponentsDemo[[3, 4, 4, 3]] = 801  # => 138.915.000
      @exponentsDemo[[4, 6, 1, 4]] = 802  # => 140.026.320
      @exponentsDemo[[9, 2, 4, 2]] = 803  # => 141.120.000
      @exponentsDemo[[5, 6, 3, 2]] = 804  # => 142.884.000
      @exponentsDemo[[5, 1, 4, 4]] = 805  # => 144.060.000
      @exponentsDemo[[1, 5, 3, 4]] = 806  # => 145.860.750
      @exponentsDemo[[7, 8, 2, 1]] = 807  # => 146.966.400
      @exponentsDemo[[7, 3, 3, 3]] = 808  # => 148.176.000
      @exponentsDemo[[2, 5, 5, 2]] = 809  # => 148.837.500
      @exponentsDemo[[3, 7, 2, 3]] = 810  # => 150.028.200
      @exponentsDemo[[8, 3, 5, 1]] = 811  # => 151.200.000
      @exponentsDemo[[9, 5, 2, 2]] = 812  # => 152.409.600
      @exponentsDemo[[4, 7, 4, 1]] = 813  # => 153.090.000
      @exponentsDemo[[4, 2, 5, 3]] = 814  # => 154.350.000
      @exponentsDemo[[5, 4, 2, 4]] = 815  # => 155.584.800
      @exponentsDemo[[1, 8, 1, 4]] = 816  # => 157.529.610
      @exponentsDemo[[6, 4, 4, 2]] = 817  # => 158.760.000
      @exponentsDemo[[7, 6, 1, 3]] = 818  # => 160.030.080
      @exponentsDemo[[2, 8, 3, 2]] = 819  # => 160.744.500
      @exponentsDemo[[2, 3, 4, 4]] = 820  # => 162.067.500
      @exponentsDemo[[8, 6, 3, 1]] = 821  # => 163.296.000
      @exponentsDemo[[8, 1, 4, 3]] = 822  # => 164.640.000
      @exponentsDemo[[9, 3, 1, 4]] = 823  # => 165.957.120
      @exponentsDemo[[4, 5, 3, 3]] = 824  # => 166.698.000
      @exponentsDemo[[5, 5, 5, 1]] = 825  # => 170.100.000
      @exponentsDemo[[6, 7, 2, 2]] = 826  # => 171.460.800
      @exponentsDemo[[6, 2, 3, 4]] = 827  # => 172.872.000
      @exponentsDemo[[1, 4, 5, 3]] = 828  # => 173.643.750
      @exponentsDemo[[2, 6, 2, 4]] = 829  # => 175.032.900
      @exponentsDemo[[7, 2, 5, 2]] = 830  # => 176.400.000
      @exponentsDemo[[8, 4, 2, 3]] = 831  # => 177.811.200
      @exponentsDemo[[3, 6, 4, 2]] = 832  # => 178.605.000
      @exponentsDemo[[4, 8, 1, 3]] = 833  # => 180.033.840
      @exponentsDemo[[3, 1, 5, 4]] = 834  # => 180.075.000
      @exponentsDemo[[9, 4, 4, 1]] = 835  # => 181.440.000
      @exponentsDemo[[5, 8, 3, 1]] = 836  # => 183.708.000
      @exponentsDemo[[5, 3, 4, 3]] = 837  # => 185.220.000
      @exponentsDemo[[6, 5, 1, 4]] = 838  # => 186.701.760
      @exponentsDemo[[1, 7, 3, 3]] = 839  # => 187.535.250
      @exponentsDemo[[7, 5, 3, 2]] = 840  # => 190.512.000
      @exponentsDemo[[2, 7, 5, 1]] = 841  # => 191.362.500
      @exponentsDemo[[3, 4, 3, 4]] = 842  # => 194.481.000
      @exponentsDemo[[9, 7, 2, 1]] = 843  # => 195.955.200
      @exponentsDemo[[9, 2, 3, 3]] = 844  # => 197.568.000
      @exponentsDemo[[4, 4, 5, 2]] = 845  # => 198.450.000
      @exponentsDemo[[5, 6, 2, 3]] = 846  # => 200.037.600
      @exponentsDemo[[6, 6, 4, 1]] = 847  # => 204.120.000
      @exponentsDemo[[7, 8, 1, 2]] = 848  # => 205.752.960
      @exponentsDemo[[6, 1, 5, 3]] = 849  # => 205.800.000
      @exponentsDemo[[7, 3, 2, 4]] = 850  # => 207.446.400 # ==> LONG
      @exponentsDemo[[2, 5, 4, 3]] = 851  # => 208.372.500 # ==> LONG
      @exponentsDemo[[3, 7, 1, 4]] = 852  # => 210.039.480 # ==> LONG
      @exponentsDemo[[8, 3, 4, 2]] = 853  # => 211.680.000 # ==> LONG
      @exponentsDemo[[9, 5, 1, 3]] = 854  # => 213.373.440 # ==> LONG
      @exponentsDemo[[4, 7, 3, 2]] = 855  # => 214.326.000 # ==> LONG
      @exponentsDemo[[4, 2, 4, 4]] = 856  # => 216.090.000 # ==> LONG
      @exponentsDemo[[6, 4, 3, 3]] = 857  # => 222.264.000 # ==> LONG
      @exponentsDemo[[1, 6, 5, 2]] = 858  # => 223.256.250 # ==> LONG
      @exponentsDemo[[2, 8, 2, 3]] = 859  # => 225.042.300 # ==> LONG
      @exponentsDemo[[7, 4, 5, 1]] = 860  # => 226.800.000 # ==> LONG
      @exponentsDemo[[8, 6, 2, 2]] = 861  # => 228.614.400 # ==> LONG
      @exponentsDemo[[3, 8, 4, 1]] = 862  # => 229.635.000 # ==> LONG
      @exponentsDemo[[8, 1, 3, 4]] = 863  # => 230.496.000 # ==> LONG
      @exponentsDemo[[3, 3, 5, 3]] = 864  # => 231.525.000 # ==> LONG
      @exponentsDemo[[4, 5, 2, 4]] = 865  # => 233.377.200 # ==> LONG
      @exponentsDemo[[9, 1, 5, 2]] = 866  # => 235.200.000 # ==> LONG
      @exponentsDemo[[5, 5, 4, 2]] = 867  # => 238.140.000 # ==> LONG
      @exponentsDemo[[6, 7, 1, 3]] = 868  # => 240.045.120 # ==> LONG
      @exponentsDemo[[1, 4, 4, 4]] = 869  # => 243.101.250 # ==> LONG
      @exponentsDemo[[7, 7, 3, 1]] = 870  # => 244.944.000 # ==> LONG
      @exponentsDemo[[7, 2, 4, 3]] = 871  # => 246.960.000 # ==> LONG
      @exponentsDemo[[8, 4, 1, 4]] = 872  # => 248.935.680 # ==> LONG
      @exponentsDemo[[3, 6, 3, 3]] = 873  # => 250.047.000 # ==> LONG
      @exponentsDemo[[9, 4, 3, 2]] = 874  # => 254.016.000 # ==> LONG
      @exponentsDemo[[4, 6, 5, 1]] = 875  # => 255.150.000 # ==> LONG
      @exponentsDemo[[5, 8, 2, 2]] = 876  # => 257.191.200 # ==> LONG
      @exponentsDemo[[5, 3, 3, 4]] = 877  # => 259.308.000 # ==> LONG
      @exponentsDemo[[1, 7, 2, 4]] = 878  # => 262.549.350 # ==> LONG
      @exponentsDemo[[6, 3, 5, 2]] = 879  # => 264.600.000 # ==> LONG
      @exponentsDemo[[7, 5, 2, 3]] = 880  # => 266.716.800 # ==> LONG
      @exponentsDemo[[2, 7, 4, 2]] = 881  # => 267.907.500 # ==> LONG
      @exponentsDemo[[2, 2, 5, 4]] = 882  # => 270.112.500 # ==> LONG
      @exponentsDemo[[8, 5, 4, 1]] = 883  # => 272.160.000 # ==> LONG
      @exponentsDemo[[9, 7, 1, 2]] = 884  # => 274.337.280 # ==> LONG
      @exponentsDemo[[9, 2, 2, 4]] = 885  # => 276.595.200 # ==> LONG
      @exponentsDemo[[4, 4, 4, 3]] = 886  # => 277.830.000 # ==> LONG
      @exponentsDemo[[5, 6, 1, 4]] = 887  # => 280.052.640 # ==> LONG
      @exponentsDemo[[6, 6, 3, 2]] = 888  # => 285.768.000 # ==> LONG
      @exponentsDemo[[1, 8, 5, 1]] = 889  # => 287.043.750 # ==> LONG
      @exponentsDemo[[6, 1, 4, 4]] = 890  # => 288.120.000 # ==> LONG
      @exponentsDemo[[2, 5, 3, 4]] = 891  # => 291.721.500 # ==> LONG
      @exponentsDemo[[8, 8, 2, 1]] = 892  # => 293.932.800 # ==> LONG
      @exponentsDemo[[8, 3, 3, 3]] = 893  # => 296.352.000 # ==> LONG
      @exponentsDemo[[3, 5, 5, 2]] = 894  # => 297.675.000 # ==> LONG
      @exponentsDemo[[4, 7, 2, 3]] = 895  # => 300.056.400 # ==> LONG
      @exponentsDemo[[9, 3, 5, 1]] = 896  # => 302.400.000 # ==> LONG
      @exponentsDemo[[5, 7, 4, 1]] = 897  # => 306.180.000 # ==> LONG
      @exponentsDemo[[5, 2, 5, 3]] = 898  # => 308.700.000 # ==> LONG
      @exponentsDemo[[6, 4, 2, 4]] = 899  # => 311.169.600 # ==> LONG
      @exponentsDemo[[1, 6, 4, 3]] = 900  # => 312.558.750 # ==> LONG
      @exponentsDemo[[2, 8, 1, 4]] = 901  # => 315.059.220 # ==> LONG
      @exponentsDemo[[7, 4, 4, 2]] = 902  # => 317.520.000 # ==> LONG
      @exponentsDemo[[8, 6, 1, 3]] = 903  # => 320.060.160 # ==> LONG
      @exponentsDemo[[3, 8, 3, 2]] = 904  # => 321.489.000 # ==> LONG
      @exponentsDemo[[3, 3, 4, 4]] = 905  # => 324.135.000 # ==> LONG
      @exponentsDemo[[9, 6, 3, 1]] = 906  # => 326.592.000 # ==> LONG
      @exponentsDemo[[9, 1, 4, 3]] = 907  # => 329.280.000 # ==> LONG
      @exponentsDemo[[5, 5, 3, 3]] = 908  # => 333.396.000 # ==> LONG
      @exponentsDemo[[6, 5, 5, 1]] = 909  # => 340.200.000 # ==> LONG
      @exponentsDemo[[7, 7, 2, 2]] = 910  # => 342.921.600 # ==> LONG
      @exponentsDemo[[7, 2, 3, 4]] = 911  # => 345.744.000 # ==> LONG
      @exponentsDemo[[2, 4, 5, 3]] = 912  # => 347.287.500 # ==> LONG
      @exponentsDemo[[3, 6, 2, 4]] = 913  # => 350.065.800 # ==> LONG
      @exponentsDemo[[8, 2, 5, 2]] = 914  # => 352.800.000 # ==> LONG
      @exponentsDemo[[9, 4, 2, 3]] = 915  # => 355.622.400 # ==> LONG
      @exponentsDemo[[4, 6, 4, 2]] = 916  # => 357.210.000 # ==> LONG
      @exponentsDemo[[5, 8, 1, 3]] = 917  # => 360.067.680 # ==> LONG
      @exponentsDemo[[4, 1, 5, 4]] = 918  # => 360.150.000 # ==> LONG
      @exponentsDemo[[6, 8, 3, 1]] = 919  # => 367.416.000 # ==> LONG
      @exponentsDemo[[6, 3, 4, 3]] = 920  # => 370.440.000 # ==> LONG
      @exponentsDemo[[7, 5, 1, 4]] = 921  # => 373.403.520 # ==> LONG
      @exponentsDemo[[2, 7, 3, 3]] = 922  # => 375.070.500 # ==> LONG
      @exponentsDemo[[8, 5, 3, 2]] = 923  # => 381.024.000 # ==> LONG
      @exponentsDemo[[3, 7, 5, 1]] = 924  # => 382.725.000 # ==> LONG
      @exponentsDemo[[4, 4, 3, 4]] = 925  # => 388.962.000 # ==> LONG
      @exponentsDemo[[5, 4, 5, 2]] = 926  # => 396.900.000 # ==> LONG
      @exponentsDemo[[6, 6, 2, 3]] = 927  # => 400.075.200 # ==> LONG
      @exponentsDemo[[1, 8, 4, 2]] = 928  # => 401.861.250 # ==> LONG
      @exponentsDemo[[1, 3, 5, 4]] = 929  # => 405.168.750 # ==> LONG
      @exponentsDemo[[7, 6, 4, 1]] = 930  # => 408.240.000 # ==> LONG
      @exponentsDemo[[8, 8, 1, 2]] = 931  # => 411.505.920 # ==> LONG
      @exponentsDemo[[7, 1, 5, 3]] = 932  # => 411.600.000 # ==> LONG
      @exponentsDemo[[8, 3, 2, 4]] = 933  # => 414.892.800 # ==> LONG
      @exponentsDemo[[3, 5, 4, 3]] = 934  # => 416.745.000 # ==> LONG
      @exponentsDemo[[4, 7, 1, 4]] = 935  # => 420.078.960 # ==> LONG
      @exponentsDemo[[9, 3, 4, 2]] = 936  # => 423.360.000 # ==> LONG
      @exponentsDemo[[5, 7, 3, 2]] = 937  # => 428.652.000 # ==> LONG
      @exponentsDemo[[5, 2, 4, 4]] = 938  # => 432.180.000 # ==> LONG
      @exponentsDemo[[1, 6, 3, 4]] = 939  # => 437.582.250 # ==> LONG
      @exponentsDemo[[7, 4, 3, 3]] = 940  # => 444.528.000 # ==> LONG
      @exponentsDemo[[2, 6, 5, 2]] = 941  # => 446.512.500 # ==> LONG
      @exponentsDemo[[3, 8, 2, 3]] = 942  # => 450.084.600 # ==> LONG
      @exponentsDemo[[8, 4, 5, 1]] = 943  # => 453.600.000 # ==> LONG
      @exponentsDemo[[9, 6, 2, 2]] = 944  # => 457.228.800 # ==> LONG
      @exponentsDemo[[4, 8, 4, 1]] = 945  # => 459.270.000 # ==> LONG
      @exponentsDemo[[9, 1, 3, 4]] = 946  # => 460.992.000 # ==> LONG
      @exponentsDemo[[4, 3, 5, 3]] = 947  # => 463.050.000 # ==> LONG
      @exponentsDemo[[5, 5, 2, 4]] = 948  # => 466.754.400 # ==> LONG
      @exponentsDemo[[6, 5, 4, 2]] = 949  # => 476.280.000 # ==> LONG
      @exponentsDemo[[7, 7, 1, 3]] = 950  # => 480.090.240 # ==> LONG
      @exponentsDemo[[2, 4, 4, 4]] = 951  # => 486.202.500 # ==> LONG
      @exponentsDemo[[8, 7, 3, 1]] = 952  # => 489.888.000 # ==> LONG
      @exponentsDemo[[8, 2, 4, 3]] = 953  # => 493.920.000 # ==> LONG
      @exponentsDemo[[9, 4, 1, 4]] = 954  # => 497.871.360 # ==> LONG
      @exponentsDemo[[4, 6, 3, 3]] = 955  # => 500.094.000 # ==> LONG
      @exponentsDemo[[5, 6, 5, 1]] = 956  # => 510.300.000 # ==> LONG
      @exponentsDemo[[6, 8, 2, 2]] = 957  # => 514.382.400 # ==> LONG
      @exponentsDemo[[6, 3, 3, 4]] = 958  # => 518.616.000 # ==> LONG
      @exponentsDemo[[1, 5, 5, 3]] = 959  # => 520.931.250 # ==> LONG
      @exponentsDemo[[2, 7, 2, 4]] = 960  # => 525.098.700 # ==> LONG
      @exponentsDemo[[7, 3, 5, 2]] = 961  # => 529.200.000 # ==> LONG
      @exponentsDemo[[8, 5, 2, 3]] = 962  # => 533.433.600 # ==> LONG
      @exponentsDemo[[3, 7, 4, 2]] = 963  # => 535.815.000 # ==> LONG
      @exponentsDemo[[3, 2, 5, 4]] = 964  # => 540.225.000 # ==> LONG
      @exponentsDemo[[9, 5, 4, 1]] = 965  # => 544.320.000 # ==> LONG
      @exponentsDemo[[5, 4, 4, 3]] = 966  # => 555.660.000 # ==> LONG
      @exponentsDemo[[6, 6, 1, 4]] = 967  # => 560.105.280 # ==> LONG
      @exponentsDemo[[1, 8, 3, 3]] = 968  # => 562.605.750 # ==> LONG
      @exponentsDemo[[7, 6, 3, 2]] = 969  # => 571.536.000 # ==> LONG
      @exponentsDemo[[2, 8, 5, 1]] = 970  # => 574.087.500 # ==> LONG
      @exponentsDemo[[7, 1, 4, 4]] = 971  # => 576.240.000 # ==> LONG
      @exponentsDemo[[3, 5, 3, 4]] = 972  # => 583.443.000 # ==> LONG
      @exponentsDemo[[9, 8, 2, 1]] = 973  # => 587.865.600 # ==> LONG
      @exponentsDemo[[9, 3, 3, 3]] = 974  # => 592.704.000 # ==> LONG
      @exponentsDemo[[4, 5, 5, 2]] = 975  # => 595.350.000 # ==> LONG
      @exponentsDemo[[5, 7, 2, 3]] = 976  # => 600.112.800 # ==> LONG
      @exponentsDemo[[6, 7, 4, 1]] = 977  # => 612.360.000 # ==> LONG
      @exponentsDemo[[6, 2, 5, 3]] = 978  # => 617.400.000 # ==> LONG
      @exponentsDemo[[7, 4, 2, 4]] = 979  # => 622.339.200 # ==> LONG
      @exponentsDemo[[2, 6, 4, 3]] = 980  # => 625.117.500 # ==> LONG
      @exponentsDemo[[3, 8, 1, 4]] = 981  # => 630.118.440 # ==> LONG
      @exponentsDemo[[8, 4, 4, 2]] = 982  # => 635.040.000 # ==> LONG
      @exponentsDemo[[9, 6, 1, 3]] = 983  # => 640.120.320 # ==> LONG
      @exponentsDemo[[4, 8, 3, 2]] = 984  # => 642.978.000 # ==> LONG
      @exponentsDemo[[4, 3, 4, 4]] = 985  # => 648.270.000 # ==> LONG
      @exponentsDemo[[6, 5, 3, 3]] = 986  # => 666.792.000 # ==> LONG
      @exponentsDemo[[1, 7, 5, 2]] = 987  # => 669.768.750 # ==> LONG
      @exponentsDemo[[7, 5, 5, 1]] = 988  # => 680.400.000 # ==> LONG
      @exponentsDemo[[8, 7, 2, 2]] = 989  # => 685.843.200 # ==> LONG
      @exponentsDemo[[8, 2, 3, 4]] = 990  # => 691.488.000 # ==> LONG
      @exponentsDemo[[3, 4, 5, 3]] = 991  # => 694.575.000 # ==> LONG
      @exponentsDemo[[4, 6, 2, 4]] = 992  # => 700.131.600 # ==> LONG
      @exponentsDemo[[9, 2, 5, 2]] = 993  # => 705.600.000 # ==> LONG
      @exponentsDemo[[5, 6, 4, 2]] = 994  # => 714.420.000 # ==> LONG
      @exponentsDemo[[6, 8, 1, 3]] = 995  # => 720.135.360 # ==> LONG
      @exponentsDemo[[5, 1, 5, 4]] = 996  # => 720.300.000 # ==> LONG
      @exponentsDemo[[1, 5, 4, 4]] = 997  # => 729.303.750 # ==> LONG
      @exponentsDemo[[7, 8, 3, 1]] = 998  # => 734.832.000 # ==> LONG
      @exponentsDemo[[7, 3, 4, 3]] = 999  # => 740.880.000 # ==> LONG
      @exponentsDemo[[8, 5, 1, 4]] = 1000  # => 746.807.040
      @exponentsDemo[[3, 7, 3, 3]] = 1001  # => 750.141.000
      @exponentsDemo[[9, 5, 3, 2]] = 1002  # => 762.048.000
      @exponentsDemo[[4, 7, 5, 1]] = 1003  # => 765.450.000
      @exponentsDemo[[5, 4, 3, 4]] = 1004  # => 777.924.000
      @exponentsDemo[[1, 8, 2, 4]] = 1005  # => 787.648.050
      @exponentsDemo[[6, 4, 5, 2]] = 1006  # => 793.800.000
      @exponentsDemo[[7, 6, 2, 3]] = 1007  # => 800.150.400
      @exponentsDemo[[2, 8, 4, 2]] = 1008  # => 803.722.500
      @exponentsDemo[[2, 3, 5, 4]] = 1009  # => 810.337.500
      @exponentsDemo[[8, 6, 4, 1]] = 1010  # => 816.480.000
      @exponentsDemo[[9, 8, 1, 2]] = 1011  # => 823.011.840
      @exponentsDemo[[8, 1, 5, 3]] = 1012  # => 823.200.000
      @exponentsDemo[[9, 3, 2, 4]] = 1013  # => 829.785.600
      @exponentsDemo[[4, 5, 4, 3]] = 1014  # => 833.490.000
      @exponentsDemo[[5, 7, 1, 4]] = 1015  # => 840.157.920
      @exponentsDemo[[6, 7, 3, 2]] = 1016  # => 857.304.000
      @exponentsDemo[[6, 2, 4, 4]] = 1017  # => 864.360.000
      @exponentsDemo[[2, 6, 3, 4]] = 1018  # => 875.164.500
      @exponentsDemo[[8, 4, 3, 3]] = 1019  # => 889.056.000
      @exponentsDemo[[3, 6, 5, 2]] = 1020  # => 893.025.000
      @exponentsDemo[[4, 8, 2, 3]] = 1021  # => 900.169.200
      @exponentsDemo[[9, 4, 5, 1]] = 1022  # => 907.200.000
      @exponentsDemo[[5, 8, 4, 1]] = 1023  # => 918.540.000
      @exponentsDemo[[5, 3, 5, 3]] = 1024  # => 926.100.000
      @exponentsDemo[[6, 5, 2, 4]] = 1025  # => 933.508.800
      @exponentsDemo[[1, 7, 4, 3]] = 1026  # => 937.676.250
      @exponentsDemo[[7, 5, 4, 2]] = 1027  # => 952.560.000
      @exponentsDemo[[8, 7, 1, 3]] = 1028  # => 960.180.480
      @exponentsDemo[[3, 4, 4, 4]] = 1029  # => 972.405.000
      @exponentsDemo[[9, 7, 3, 1]] = 1030  # => 979.776.000
      @exponentsDemo[[9, 2, 4, 3]] = 1031  # => 987.840.000
      @exponentsDemo[[5, 6, 3, 3]] = 1032  # => 1.000.188.000
      @exponentsDemo[[6, 6, 5, 1]] = 1033  # => 1.020.600.000
      @exponentsDemo[[7, 8, 2, 2]] = 1034  # => 1.028.764.800
      @exponentsDemo[[7, 3, 3, 4]] = 1035  # => 1.037.232.000
      @exponentsDemo[[2, 5, 5, 3]] = 1036  # => 1.041.862.500
      @exponentsDemo[[3, 7, 2, 4]] = 1037  # => 1.050.197.400
      @exponentsDemo[[8, 3, 5, 2]] = 1038  # => 1.058.400.000
      @exponentsDemo[[9, 5, 2, 3]] = 1039  # => 1.066.867.200
      @exponentsDemo[[4, 7, 4, 2]] = 1040  # => 1.071.630.000
      @exponentsDemo[[4, 2, 5, 4]] = 1041  # => 1.080.450.000
      @exponentsDemo[[6, 4, 4, 3]] = 1042  # => 1.111.320.000
      @exponentsDemo[[7, 6, 1, 4]] = 1043  # => 1.120.210.560
      @exponentsDemo[[2, 8, 3, 3]] = 1044  # => 1.125.211.500
      @exponentsDemo[[8, 6, 3, 2]] = 1045  # => 1.143.072.000
      @exponentsDemo[[3, 8, 5, 1]] = 1046  # => 1.148.175.000
      @exponentsDemo[[8, 1, 4, 4]] = 1047  # => 1.152.480.000
      @exponentsDemo[[4, 5, 3, 4]] = 1048  # => 1.166.886.000
      @exponentsDemo[[5, 5, 5, 2]] = 1049  # => 1.190.700.000
      @exponentsDemo[[6, 7, 2, 3]] = 1050  # => 1.200.225.600
      @exponentsDemo[[1, 4, 5, 4]] = 1051  # => 1.215.506.250
      @exponentsDemo[[7, 7, 4, 1]] = 1052  # => 1.224.720.000
      @exponentsDemo[[7, 2, 5, 3]] = 1053  # => 1.234.800.000
      @exponentsDemo[[8, 4, 2, 4]] = 1054  # => 1.244.678.400
      @exponentsDemo[[3, 6, 4, 3]] = 1055  # => 1.250.235.000
      @exponentsDemo[[4, 8, 1, 4]] = 1056  # => 1.260.236.880
      @exponentsDemo[[9, 4, 4, 2]] = 1057  # => 1.270.080.000
      @exponentsDemo[[5, 8, 3, 2]] = 1058  # => 1.285.956.000
      @exponentsDemo[[5, 3, 4, 4]] = 1059  # => 1.296.540.000
      @exponentsDemo[[1, 7, 3, 4]] = 1060  # => 1.312.746.750
      @exponentsDemo[[7, 5, 3, 3]] = 1061  # => 1.333.584.000
      @exponentsDemo[[2, 7, 5, 2]] = 1062  # => 1.339.537.500
      @exponentsDemo[[8, 5, 5, 1]] = 1063  # => 1.360.800.000
      @exponentsDemo[[9, 7, 2, 2]] = 1064  # => 1.371.686.400
      @exponentsDemo[[9, 2, 3, 4]] = 1065  # => 1.382.976.000
      @exponentsDemo[[4, 4, 5, 3]] = 1066  # => 1.389.150.000
      @exponentsDemo[[5, 6, 2, 4]] = 1067  # => 1.400.263.200
      @exponentsDemo[[6, 6, 4, 2]] = 1068  # => 1.428.840.000
      @exponentsDemo[[7, 8, 1, 3]] = 1069  # => 1.440.270.720
      @exponentsDemo[[6, 1, 5, 4]] = 1070  # => 1.440.600.000
      @exponentsDemo[[2, 5, 4, 4]] = 1071  # => 1.458.607.500
      @exponentsDemo[[8, 8, 3, 1]] = 1072  # => 1.469.664.000
      @exponentsDemo[[8, 3, 4, 3]] = 1073  # => 1.481.760.000
      @exponentsDemo[[9, 5, 1, 4]] = 1074  # => 1.493.614.080
      @exponentsDemo[[4, 7, 3, 3]] = 1075  # => 1.500.282.000
      @exponentsDemo[[5, 7, 5, 1]] = 1076  # => 1.530.900.000
      @exponentsDemo[[6, 4, 3, 4]] = 1077  # => 1.555.848.000
      @exponentsDemo[[1, 6, 5, 3]] = 1078  # => 1.562.793.750
      @exponentsDemo[[2, 8, 2, 4]] = 1079  # => 1.575.296.100
      @exponentsDemo[[7, 4, 5, 2]] = 1080  # => 1.587.600.000
      @exponentsDemo[[8, 6, 2, 3]] = 1081  # => 1.600.300.800
      @exponentsDemo[[3, 8, 4, 2]] = 1082  # => 1.607.445.000
      @exponentsDemo[[3, 3, 5, 4]] = 1083  # => 1.620.675.000
      @exponentsDemo[[9, 6, 4, 1]] = 1084  # => 1.632.960.000
      @exponentsDemo[[9, 1, 5, 3]] = 1085  # => 1.646.400.000
      @exponentsDemo[[5, 5, 4, 3]] = 1086  # => 1.666.980.000
      @exponentsDemo[[6, 7, 1, 4]] = 1087  # => 1.680.315.840
      @exponentsDemo[[7, 7, 3, 2]] = 1088  # => 1.714.608.000
      @exponentsDemo[[7, 2, 4, 4]] = 1089  # => 1.728.720.000
      @exponentsDemo[[3, 6, 3, 4]] = 1090  # => 1.750.329.000
      @exponentsDemo[[9, 4, 3, 3]] = 1091  # => 1.778.112.000
      @exponentsDemo[[4, 6, 5, 2]] = 1092  # => 1.786.050.000
      @exponentsDemo[[5, 8, 2, 3]] = 1093  # => 1.800.338.400
      @exponentsDemo[[6, 8, 4, 1]] = 1094  # => 1.837.080.000
      @exponentsDemo[[6, 3, 5, 3]] = 1095  # => 1.852.200.000
      @exponentsDemo[[7, 5, 2, 4]] = 1096  # => 1.867.017.600
      @exponentsDemo[[2, 7, 4, 3]] = 1097  # => 1.875.352.500
      @exponentsDemo[[8, 5, 4, 2]] = 1098  # => 1.905.120.000
      @exponentsDemo[[9, 7, 1, 3]] = 1099  # => 1.920.360.960
      @exponentsDemo[[4, 4, 4, 4]] = 1100  # => 1.944.810.000
      @exponentsDemo[[6, 6, 3, 3]] = 1101  # => 2.000.376.000
      @exponentsDemo[[1, 8, 5, 2]] = 1102  # => 2.009.306.250
      @exponentsDemo[[7, 6, 5, 1]] = 1103  # => 2.041.200.000
      @exponentsDemo[[8, 8, 2, 2]] = 1104  # => 2.057.529.600
      @exponentsDemo[[8, 3, 3, 4]] = 1105  # => 2.074.464.000
      @exponentsDemo[[3, 5, 5, 3]] = 1106  # => 2.083.725.000
      @exponentsDemo[[4, 7, 2, 4]] = 1107  # => 2.100.394.800
      @exponentsDemo[[9, 3, 5, 2]] = 1108  # => 2.116.800.000
      @exponentsDemo[[5, 7, 4, 2]] = 1109  # => 2.143.260.000
      @exponentsDemo[[5, 2, 5, 4]] = 1110  # => 2.160.900.000
      @exponentsDemo[[1, 6, 4, 4]] = 1111  # => 2.187.911.250
      @exponentsDemo[[7, 4, 4, 3]] = 1112  # => 2.222.640.000
      @exponentsDemo[[8, 6, 1, 4]] = 1113  # => 2.240.421.120
      @exponentsDemo[[3, 8, 3, 3]] = 1114  # => 2.250.423.000
      @exponentsDemo[[9, 6, 3, 2]] = 1115  # => 2.286.144.000
      @exponentsDemo[[4, 8, 5, 1]] = 1116  # => 2.296.350.000
      @exponentsDemo[[9, 1, 4, 4]] = 1117  # => 2.304.960.000
      @exponentsDemo[[5, 5, 3, 4]] = 1118  # => 2.333.772.000
      @exponentsDemo[[6, 5, 5, 2]] = 1119  # => 2.381.400.000
      @exponentsDemo[[7, 7, 2, 3]] = 1120  # => 2.400.451.200
      @exponentsDemo[[2, 4, 5, 4]] = 1121  # => 2.431.012.500
      @exponentsDemo[[8, 7, 4, 1]] = 1122  # => 2.449.440.000
      @exponentsDemo[[8, 2, 5, 3]] = 1123  # => 2.469.600.000
      @exponentsDemo[[9, 4, 2, 4]] = 1124  # => 2.489.356.800
      @exponentsDemo[[4, 6, 4, 3]] = 1125  # => 2.500.470.000
      @exponentsDemo[[5, 8, 1, 4]] = 1126  # => 2.520.473.760
      @exponentsDemo[[6, 8, 3, 2]] = 1127  # => 2.571.912.000
      @exponentsDemo[[6, 3, 4, 4]] = 1128  # => 2.593.080.000
      @exponentsDemo[[2, 7, 3, 4]] = 1129  # => 2.625.493.500
      @exponentsDemo[[8, 5, 3, 3]] = 1130  # => 2.667.168.000
      @exponentsDemo[[3, 7, 5, 2]] = 1131  # => 2.679.075.000
      @exponentsDemo[[9, 5, 5, 1]] = 1132  # => 2.721.600.000
      @exponentsDemo[[5, 4, 5, 3]] = 1133  # => 2.778.300.000
      @exponentsDemo[[6, 6, 2, 4]] = 1134  # => 2.800.526.400
      @exponentsDemo[[1, 8, 4, 3]] = 1135  # => 2.813.028.750
      @exponentsDemo[[7, 6, 4, 2]] = 1136  # => 2.857.680.000
      @exponentsDemo[[8, 8, 1, 3]] = 1137  # => 2.880.541.440
      @exponentsDemo[[7, 1, 5, 4]] = 1138  # => 2.881.200.000
      @exponentsDemo[[3, 5, 4, 4]] = 1139  # => 2.917.215.000
      @exponentsDemo[[9, 8, 3, 1]] = 1140  # => 2.939.328.000
      @exponentsDemo[[9, 3, 4, 3]] = 1141  # => 2.963.520.000
      @exponentsDemo[[5, 7, 3, 3]] = 1142  # => 3.000.564.000
      @exponentsDemo[[6, 7, 5, 1]] = 1143  # => 3.061.800.000
      @exponentsDemo[[7, 4, 3, 4]] = 1144  # => 3.111.696.000
      @exponentsDemo[[2, 6, 5, 3]] = 1145  # => 3.125.587.500
      @exponentsDemo[[3, 8, 2, 4]] = 1146  # => 3.150.592.200
      @exponentsDemo[[8, 4, 5, 2]] = 1147  # => 3.175.200.000
      @exponentsDemo[[9, 6, 2, 3]] = 1148  # => 3.200.601.600
      @exponentsDemo[[4, 8, 4, 2]] = 1149  # => 3.214.890.000
      @exponentsDemo[[4, 3, 5, 4]] = 1150  # => 3.241.350.000
      @exponentsDemo[[6, 5, 4, 3]] = 1151  # => 3.333.960.000
      @exponentsDemo[[7, 7, 1, 4]] = 1152  # => 3.360.631.680
      @exponentsDemo[[8, 7, 3, 2]] = 1153  # => 3.429.216.000
      @exponentsDemo[[8, 2, 4, 4]] = 1154  # => 3.457.440.000
      @exponentsDemo[[4, 6, 3, 4]] = 1155  # => 3.500.658.000
      @exponentsDemo[[5, 6, 5, 2]] = 1156  # => 3.572.100.000
      @exponentsDemo[[6, 8, 2, 3]] = 1157  # => 3.600.676.800
      @exponentsDemo[[1, 5, 5, 4]] = 1158  # => 3.646.518.750
      @exponentsDemo[[7, 8, 4, 1]] = 1159  # => 3.674.160.000
      @exponentsDemo[[7, 3, 5, 3]] = 1160  # => 3.704.400.000
      @exponentsDemo[[8, 5, 2, 4]] = 1161  # => 3.734.035.200
      @exponentsDemo[[3, 7, 4, 3]] = 1162  # => 3.750.705.000
      @exponentsDemo[[9, 5, 4, 2]] = 1163  # => 3.810.240.000
      @exponentsDemo[[5, 4, 4, 4]] = 1164  # => 3.889.620.000
      @exponentsDemo[[1, 8, 3, 4]] = 1165  # => 3.938.240.250
      @exponentsDemo[[7, 6, 3, 3]] = 1166  # => 4.000.752.000
      @exponentsDemo[[2, 8, 5, 2]] = 1167  # => 4.018.612.500
      @exponentsDemo[[8, 6, 5, 1]] = 1168  # => 4.082.400.000
      @exponentsDemo[[9, 8, 2, 2]] = 1169  # => 4.115.059.200
      @exponentsDemo[[9, 3, 3, 4]] = 1170  # => 4.148.928.000
      @exponentsDemo[[4, 5, 5, 3]] = 1171  # => 4.167.450.000
      @exponentsDemo[[5, 7, 2, 4]] = 1172  # => 4.200.789.600
      @exponentsDemo[[6, 7, 4, 2]] = 1173  # => 4.286.520.000
      @exponentsDemo[[6, 2, 5, 4]] = 1174  # => 4.321.800.000
      @exponentsDemo[[2, 6, 4, 4]] = 1175  # => 4.375.822.500
      @exponentsDemo[[8, 4, 4, 3]] = 1176  # => 4.445.280.000
      @exponentsDemo[[9, 6, 1, 4]] = 1177  # => 4.480.842.240
      @exponentsDemo[[4, 8, 3, 3]] = 1178  # => 4.500.846.000
      @exponentsDemo[[5, 8, 5, 1]] = 1179  # => 4.592.700.000
      @exponentsDemo[[6, 5, 3, 4]] = 1180  # => 4.667.544.000
      @exponentsDemo[[1, 7, 5, 3]] = 1181  # => 4.688.381.250
      @exponentsDemo[[7, 5, 5, 2]] = 1182  # => 4.762.800.000
      @exponentsDemo[[8, 7, 2, 3]] = 1183  # => 4.800.902.400
      @exponentsDemo[[3, 4, 5, 4]] = 1184  # => 4.862.025.000
      @exponentsDemo[[9, 7, 4, 1]] = 1185  # => 4.898.880.000
      @exponentsDemo[[9, 2, 5, 3]] = 1186  # => 4.939.200.000
      @exponentsDemo[[5, 6, 4, 3]] = 1187  # => 5.000.940.000
      @exponentsDemo[[6, 8, 1, 4]] = 1188  # => 5.040.947.520
      @exponentsDemo[[7, 8, 3, 2]] = 1189  # => 5.143.824.000
      @exponentsDemo[[7, 3, 4, 4]] = 1190  # => 5.186.160.000
      @exponentsDemo[[3, 7, 3, 4]] = 1191  # => 5.250.987.000
      @exponentsDemo[[9, 5, 3, 3]] = 1192  # => 5.334.336.000
      @exponentsDemo[[4, 7, 5, 2]] = 1193  # => 5.358.150.000
      @exponentsDemo[[6, 4, 5, 3]] = 1194  # => 5.556.600.000
      @exponentsDemo[[7, 6, 2, 4]] = 1195  # => 5.601.052.800
      @exponentsDemo[[2, 8, 4, 3]] = 1196  # => 5.626.057.500
      @exponentsDemo[[8, 6, 4, 2]] = 1197  # => 5.715.360.000
      @exponentsDemo[[9, 8, 1, 3]] = 1198  # => 5.761.082.880
      @exponentsDemo[[8, 1, 5, 4]] = 1199  # => 5.762.400.000
      @exponentsDemo[[4, 5, 4, 4]] = 1200  # => 5.834.430.000
      @exponentsDemo[[6, 7, 3, 3]] = 1201  # => 6.001.128.000
      @exponentsDemo[[7, 7, 5, 1]] = 1202  # => 6.123.600.000
      @exponentsDemo[[8, 4, 3, 4]] = 1203  # => 6.223.392.000
      @exponentsDemo[[3, 6, 5, 3]] = 1204  # => 6.251.175.000
      @exponentsDemo[[4, 8, 2, 4]] = 1205  # => 6.301.184.400
      @exponentsDemo[[9, 4, 5, 2]] = 1206  # => 6.350.400.000
      @exponentsDemo[[5, 8, 4, 2]] = 1207  # => 6.429.780.000
      @exponentsDemo[[5, 3, 5, 4]] = 1208  # => 6.482.700.000
      @exponentsDemo[[1, 7, 4, 4]] = 1209  # => 6.563.733.750
      @exponentsDemo[[7, 5, 4, 3]] = 1210  # => 6.667.920.000
      @exponentsDemo[[8, 7, 1, 4]] = 1211  # => 6.721.263.360
      @exponentsDemo[[9, 7, 3, 2]] = 1212  # => 6.858.432.000
      @exponentsDemo[[9, 2, 4, 4]] = 1213  # => 6.914.880.000
      @exponentsDemo[[5, 6, 3, 4]] = 1214  # => 7.001.316.000
      @exponentsDemo[[6, 6, 5, 2]] = 1215  # => 7.144.200.000
      @exponentsDemo[[7, 8, 2, 3]] = 1216  # => 7.201.353.600
      @exponentsDemo[[2, 5, 5, 4]] = 1217  # => 7.293.037.500
      @exponentsDemo[[8, 8, 4, 1]] = 1218  # => 7.348.320.000
      @exponentsDemo[[8, 3, 5, 3]] = 1219  # => 7.408.800.000
      @exponentsDemo[[9, 5, 2, 4]] = 1220  # => 7.468.070.400
      @exponentsDemo[[4, 7, 4, 3]] = 1221  # => 7.501.410.000
      @exponentsDemo[[6, 4, 4, 4]] = 1222  # => 7.779.240.000
      @exponentsDemo[[2, 8, 3, 4]] = 1223  # => 7.876.480.500
      @exponentsDemo[[8, 6, 3, 3]] = 1224  # => 8.001.504.000
      @exponentsDemo[[3, 8, 5, 2]] = 1225  # => 8.037.225.000
      @exponentsDemo[[9, 6, 5, 1]] = 1226  # => 8.164.800.000
      @exponentsDemo[[5, 5, 5, 3]] = 1227  # => 8.334.900.000
      @exponentsDemo[[6, 7, 2, 4]] = 1228  # => 8.401.579.200
      @exponentsDemo[[7, 7, 4, 2]] = 1229  # => 8.573.040.000
      @exponentsDemo[[7, 2, 5, 4]] = 1230  # => 8.643.600.000
      @exponentsDemo[[3, 6, 4, 4]] = 1231  # => 8.751.645.000
      @exponentsDemo[[9, 4, 4, 3]] = 1232  # => 8.890.560.000
      @exponentsDemo[[5, 8, 3, 3]] = 1233  # => 9.001.692.000
      @exponentsDemo[[6, 8, 5, 1]] = 1234  # => 9.185.400.000
      @exponentsDemo[[7, 5, 3, 4]] = 1235  # => 9.335.088.000
      @exponentsDemo[[2, 7, 5, 3]] = 1236  # => 9.376.762.500
      @exponentsDemo[[8, 5, 5, 2]] = 1237  # => 9.525.600.000
      @exponentsDemo[[9, 7, 2, 3]] = 1238  # => 9.601.804.800
      @exponentsDemo[[4, 4, 5, 4]] = 1239  # => 9.724.050.000
      @exponentsDemo[[6, 6, 4, 3]] = 1240  # => 10.001.880.000
      @exponentsDemo[[7, 8, 1, 4]] = 1241  # => 10.081.895.040
      @exponentsDemo[[8, 8, 3, 2]] = 1242  # => 10.287.648.000
      @exponentsDemo[[8, 3, 4, 4]] = 1243  # => 10.372.320.000
      @exponentsDemo[[4, 7, 3, 4]] = 1244  # => 10.501.974.000
      @exponentsDemo[[5, 7, 5, 2]] = 1245  # => 10.716.300.000
      @exponentsDemo[[1, 6, 5, 4]] = 1246  # => 10.939.556.250
      @exponentsDemo[[7, 4, 5, 3]] = 1247  # => 11.113.200.000
      @exponentsDemo[[8, 6, 2, 4]] = 1248  # => 11.202.105.600
      @exponentsDemo[[3, 8, 4, 3]] = 1249  # => 11.252.115.000
      @exponentsDemo[[9, 6, 4, 2]] = 1250  # => 11.430.720.000
      @exponentsDemo[[9, 1, 5, 4]] = 1251  # => 11.524.800.000
      @exponentsDemo[[5, 5, 4, 4]] = 1252  # => 11.668.860.000
      @exponentsDemo[[7, 7, 3, 3]] = 1253  # => 12.002.256.000
      @exponentsDemo[[8, 7, 5, 1]] = 1254  # => 12.247.200.000
      @exponentsDemo[[9, 4, 3, 4]] = 1255  # => 12.446.784.000
      @exponentsDemo[[4, 6, 5, 3]] = 1256  # => 12.502.350.000
      @exponentsDemo[[5, 8, 2, 4]] = 1257  # => 12.602.368.800
      @exponentsDemo[[6, 8, 4, 2]] = 1258  # => 12.859.560.000
      @exponentsDemo[[6, 3, 5, 4]] = 1259  # => 12.965.400.000
      @exponentsDemo[[2, 7, 4, 4]] = 1260  # => 13.127.467.500
      @exponentsDemo[[8, 5, 4, 3]] = 1261  # => 13.335.840.000
      @exponentsDemo[[9, 7, 1, 4]] = 1262  # => 13.442.526.720
      @exponentsDemo[[6, 6, 3, 4]] = 1263  # => 14.002.632.000
      @exponentsDemo[[1, 8, 5, 3]] = 1264  # => 14.065.143.750
      @exponentsDemo[[7, 6, 5, 2]] = 1265  # => 14.288.400.000
      @exponentsDemo[[8, 8, 2, 3]] = 1266  # => 14.402.707.200
      @exponentsDemo[[3, 5, 5, 4]] = 1267  # => 14.586.075.000
      @exponentsDemo[[9, 8, 4, 1]] = 1268  # => 14.696.640.000
      @exponentsDemo[[9, 3, 5, 3]] = 1269  # => 14.817.600.000
      @exponentsDemo[[5, 7, 4, 3]] = 1270  # => 15.002.820.000
      @exponentsDemo[[7, 4, 4, 4]] = 1271  # => 15.558.480.000
      @exponentsDemo[[3, 8, 3, 4]] = 1272  # => 15.752.961.000
      @exponentsDemo[[9, 6, 3, 3]] = 1273  # => 16.003.008.000
      @exponentsDemo[[4, 8, 5, 2]] = 1274  # => 16.074.450.000
      @exponentsDemo[[6, 5, 5, 3]] = 1275  # => 16.669.800.000
      @exponentsDemo[[7, 7, 2, 4]] = 1276  # => 16.803.158.400
      @exponentsDemo[[8, 7, 4, 2]] = 1277  # => 17.146.080.000
      @exponentsDemo[[8, 2, 5, 4]] = 1278  # => 17.287.200.000
      @exponentsDemo[[4, 6, 4, 4]] = 1279  # => 17.503.290.000
      @exponentsDemo[[6, 8, 3, 3]] = 1280  # => 18.003.384.000
      @exponentsDemo[[7, 8, 5, 1]] = 1281  # => 18.370.800.000
      @exponentsDemo[[8, 5, 3, 4]] = 1282  # => 18.670.176.000
      @exponentsDemo[[3, 7, 5, 3]] = 1283  # => 18.753.525.000
      @exponentsDemo[[9, 5, 5, 2]] = 1284  # => 19.051.200.000
      @exponentsDemo[[5, 4, 5, 4]] = 1285  # => 19.448.100.000
      @exponentsDemo[[1, 8, 4, 4]] = 1286  # => 19.691.201.250
      @exponentsDemo[[7, 6, 4, 3]] = 1287  # => 20.003.760.000
      @exponentsDemo[[8, 8, 1, 4]] = 1288  # => 20.163.790.080
      @exponentsDemo[[9, 8, 3, 2]] = 1289  # => 20.575.296.000
      @exponentsDemo[[9, 3, 4, 4]] = 1290  # => 20.744.640.000
      @exponentsDemo[[5, 7, 3, 4]] = 1291  # => 21.003.948.000
      @exponentsDemo[[6, 7, 5, 2]] = 1292  # => 21.432.600.000
      @exponentsDemo[[2, 6, 5, 4]] = 1293  # => 21.879.112.500
      @exponentsDemo[[8, 4, 5, 3]] = 1294  # => 22.226.400.000
      @exponentsDemo[[9, 6, 2, 4]] = 1295  # => 22.404.211.200
      @exponentsDemo[[4, 8, 4, 3]] = 1296  # => 22.504.230.000
      @exponentsDemo[[6, 5, 4, 4]] = 1297  # => 23.337.720.000
      @exponentsDemo[[8, 7, 3, 3]] = 1298  # => 24.004.512.000
      @exponentsDemo[[9, 7, 5, 1]] = 1299  # => 24.494.400.000
      @exponentsDemo[[5, 6, 5, 3]] = 1300  # => 25.004.700.000
      @exponentsDemo[[6, 8, 2, 4]] = 1301  # => 25.204.737.600
      @exponentsDemo[[7, 8, 4, 2]] = 1302  # => 25.719.120.000
      @exponentsDemo[[7, 3, 5, 4]] = 1303  # => 25.930.800.000
      @exponentsDemo[[3, 7, 4, 4]] = 1304  # => 26.254.935.000
      @exponentsDemo[[9, 5, 4, 3]] = 1305  # => 26.671.680.000
      @exponentsDemo[[7, 6, 3, 4]] = 1306  # => 28.005.264.000
      @exponentsDemo[[2, 8, 5, 3]] = 1307  # => 28.130.287.500
      @exponentsDemo[[8, 6, 5, 2]] = 1308  # => 28.576.800.000
      @exponentsDemo[[9, 8, 2, 3]] = 1309  # => 28.805.414.400
      @exponentsDemo[[4, 5, 5, 4]] = 1310  # => 29.172.150.000
      @exponentsDemo[[6, 7, 4, 3]] = 1311  # => 30.005.640.000
      @exponentsDemo[[8, 4, 4, 4]] = 1312  # => 31.116.960.000
      @exponentsDemo[[4, 8, 3, 4]] = 1313  # => 31.505.922.000
      @exponentsDemo[[5, 8, 5, 2]] = 1314  # => 32.148.900.000
      @exponentsDemo[[1, 7, 5, 4]] = 1315  # => 32.818.668.750
      @exponentsDemo[[7, 5, 5, 3]] = 1316  # => 33.339.600.000
      @exponentsDemo[[8, 7, 2, 4]] = 1317  # => 33.606.316.800
      @exponentsDemo[[9, 7, 4, 2]] = 1318  # => 34.292.160.000
      @exponentsDemo[[9, 2, 5, 4]] = 1319  # => 34.574.400.000
      @exponentsDemo[[5, 6, 4, 4]] = 1320  # => 35.006.580.000
      @exponentsDemo[[7, 8, 3, 3]] = 1321  # => 36.006.768.000
      @exponentsDemo[[8, 8, 5, 1]] = 1322  # => 36.741.600.000
      @exponentsDemo[[9, 5, 3, 4]] = 1323  # => 37.340.352.000
      @exponentsDemo[[4, 7, 5, 3]] = 1324  # => 37.507.050.000
      @exponentsDemo[[6, 4, 5, 4]] = 1325  # => 38.896.200.000
      @exponentsDemo[[2, 8, 4, 4]] = 1326  # => 39.382.402.500
      @exponentsDemo[[8, 6, 4, 3]] = 1327  # => 40.007.520.000
      @exponentsDemo[[9, 8, 1, 4]] = 1328  # => 40.327.580.160
      @exponentsDemo[[6, 7, 3, 4]] = 1329  # => 42.007.896.000
      @exponentsDemo[[7, 7, 5, 2]] = 1330  # => 42.865.200.000
      @exponentsDemo[[3, 6, 5, 4]] = 1331  # => 43.758.225.000
      @exponentsDemo[[9, 4, 5, 3]] = 1332  # => 44.452.800.000
      @exponentsDemo[[5, 8, 4, 3]] = 1333  # => 45.008.460.000
      @exponentsDemo[[7, 5, 4, 4]] = 1334  # => 46.675.440.000
      @exponentsDemo[[9, 7, 3, 3]] = 1335  # => 48.009.024.000
      @exponentsDemo[[6, 6, 5, 3]] = 1336  # => 50.009.400.000
      @exponentsDemo[[7, 8, 2, 4]] = 1337  # => 50.409.475.200
      @exponentsDemo[[8, 8, 4, 2]] = 1338  # => 51.438.240.000
      @exponentsDemo[[8, 3, 5, 4]] = 1339  # => 51.861.600.000
      @exponentsDemo[[4, 7, 4, 4]] = 1340  # => 52.509.870.000
      @exponentsDemo[[8, 6, 3, 4]] = 1341  # => 56.010.528.000
      @exponentsDemo[[3, 8, 5, 3]] = 1342  # => 56.260.575.000
      @exponentsDemo[[9, 6, 5, 2]] = 1343  # => 57.153.600.000
      @exponentsDemo[[5, 5, 5, 4]] = 1344  # => 58.344.300.000
      @exponentsDemo[[7, 7, 4, 3]] = 1345  # => 60.011.280.000
      @exponentsDemo[[9, 4, 4, 4]] = 1346  # => 62.233.920.000
      @exponentsDemo[[5, 8, 3, 4]] = 1347  # => 63.011.844.000
      @exponentsDemo[[6, 8, 5, 2]] = 1348  # => 64.297.800.000
      @exponentsDemo[[2, 7, 5, 4]] = 1349  # => 65.637.337.500
      @exponentsDemo[[8, 5, 5, 3]] = 1350  # => 66.679.200.000
      @exponentsDemo[[9, 7, 2, 4]] = 1351  # => 67.212.633.600
      @exponentsDemo[[6, 6, 4, 4]] = 1352  # => 70.013.160.000
      @exponentsDemo[[8, 8, 3, 3]] = 1353  # => 72.013.536.000
      @exponentsDemo[[9, 8, 5, 1]] = 1354  # => 73.483.200.000
      @exponentsDemo[[5, 7, 5, 3]] = 1355  # => 75.014.100.000
      @exponentsDemo[[7, 4, 5, 4]] = 1356  # => 77.792.400.000
      @exponentsDemo[[3, 8, 4, 4]] = 1357  # => 78.764.805.000
      @exponentsDemo[[9, 6, 4, 3]] = 1358  # => 80.015.040.000
      @exponentsDemo[[7, 7, 3, 4]] = 1359  # => 84.015.792.000
      @exponentsDemo[[8, 7, 5, 2]] = 1360  # => 85.730.400.000
      @exponentsDemo[[4, 6, 5, 4]] = 1361  # => 87.516.450.000
      @exponentsDemo[[6, 8, 4, 3]] = 1362  # => 90.016.920.000
      @exponentsDemo[[8, 5, 4, 4]] = 1363  # => 93.350.880.000
      @exponentsDemo[[1, 8, 5, 4]] = 1364  # => 98.456.006.250
      @exponentsDemo[[7, 6, 5, 3]] = 1365  # => 100.018.800.000
      @exponentsDemo[[8, 8, 2, 4]] = 1366  # => 100.818.950.400
      @exponentsDemo[[9, 8, 4, 2]] = 1367  # => 102.876.480.000
      @exponentsDemo[[9, 3, 5, 4]] = 1368  # => 103.723.200.000
      @exponentsDemo[[5, 7, 4, 4]] = 1369  # => 105.019.740.000
      @exponentsDemo[[9, 6, 3, 4]] = 1370  # => 112.021.056.000
      @exponentsDemo[[4, 8, 5, 3]] = 1371  # => 112.521.150.000
      @exponentsDemo[[6, 5, 5, 4]] = 1372  # => 116.688.600.000
      @exponentsDemo[[8, 7, 4, 3]] = 1373  # => 120.022.560.000
      @exponentsDemo[[6, 8, 3, 4]] = 1374  # => 126.023.688.000
      @exponentsDemo[[7, 8, 5, 2]] = 1375  # => 128.595.600.000
      @exponentsDemo[[3, 7, 5, 4]] = 1376  # => 131.274.675.000
      @exponentsDemo[[9, 5, 5, 3]] = 1377  # => 133.358.400.000
      @exponentsDemo[[7, 6, 4, 4]] = 1378  # => 140.026.320.000
      @exponentsDemo[[9, 8, 3, 3]] = 1379  # => 144.027.072.000
      @exponentsDemo[[6, 7, 5, 3]] = 1380  # => 150.028.200.000
      @exponentsDemo[[8, 4, 5, 4]] = 1381  # => 155.584.800.000
      @exponentsDemo[[4, 8, 4, 4]] = 1382  # => 157.529.610.000
      @exponentsDemo[[8, 7, 3, 4]] = 1383  # => 168.031.584.000
      @exponentsDemo[[9, 7, 5, 2]] = 1384  # => 171.460.800.000
      @exponentsDemo[[5, 6, 5, 4]] = 1385  # => 175.032.900.000
      @exponentsDemo[[7, 8, 4, 3]] = 1386  # => 180.033.840.000
      @exponentsDemo[[9, 5, 4, 4]] = 1387  # => 186.701.760.000
      @exponentsDemo[[2, 8, 5, 4]] = 1388  # => 196.912.012.500
      @exponentsDemo[[8, 6, 5, 3]] = 1389  # => 200.037.600.000
      @exponentsDemo[[9, 8, 2, 4]] = 1390  # => 201.637.900.800
      @exponentsDemo[[6, 7, 4, 4]] = 1391  # => 210.039.480.000
      @exponentsDemo[[5, 8, 5, 3]] = 1392  # => 225.042.300.000
      @exponentsDemo[[7, 5, 5, 4]] = 1393  # => 233.377.200.000
      @exponentsDemo[[9, 7, 4, 3]] = 1394  # => 240.045.120.000
      @exponentsDemo[[7, 8, 3, 4]] = 1395  # => 252.047.376.000
      @exponentsDemo[[8, 8, 5, 2]] = 1396  # => 257.191.200.000
      @exponentsDemo[[4, 7, 5, 4]] = 1397  # => 262.549.350.000
      @exponentsDemo[[8, 6, 4, 4]] = 1398  # => 280.052.640.000
      @exponentsDemo[[7, 7, 5, 3]] = 1399  # => 300.056.400.000
      @exponentsDemo[[9, 4, 5, 4]] = 1400  # => 311.169.600.000
      @exponentsDemo[[5, 8, 4, 4]] = 1401  # => 315.059.220.000
      @exponentsDemo[[9, 7, 3, 4]] = 1402  # => 336.063.168.000
      @exponentsDemo[[6, 6, 5, 4]] = 1403  # => 350.065.800.000
      @exponentsDemo[[8, 8, 4, 3]] = 1404  # => 360.067.680.000
      @exponentsDemo[[3, 8, 5, 4]] = 1405  # => 393.824.025.000
      @exponentsDemo[[9, 6, 5, 3]] = 1406  # => 400.075.200.000
      @exponentsDemo[[7, 7, 4, 4]] = 1407  # => 420.078.960.000
      @exponentsDemo[[6, 8, 5, 3]] = 1408  # => 450.084.600.000
      @exponentsDemo[[8, 5, 5, 4]] = 1409  # => 466.754.400.000
      @exponentsDemo[[8, 8, 3, 4]] = 1410  # => 504.094.752.000
      @exponentsDemo[[9, 8, 5, 2]] = 1411  # => 514.382.400.000
      @exponentsDemo[[5, 7, 5, 4]] = 1412  # => 525.098.700.000
      @exponentsDemo[[9, 6, 4, 4]] = 1413  # => 560.105.280.000
      @exponentsDemo[[8, 7, 5, 3]] = 1414  # => 600.112.800.000
      @exponentsDemo[[6, 8, 4, 4]] = 1415  # => 630.118.440.000
      @exponentsDemo[[7, 6, 5, 4]] = 1416  # => 700.131.600.000
      @exponentsDemo[[9, 8, 4, 3]] = 1417  # => 720.135.360.000
      @exponentsDemo[[4, 8, 5, 4]] = 1418  # => 787.648.050.000
      @exponentsDemo[[8, 7, 4, 4]] = 1419  # => 840.157.920.000
      @exponentsDemo[[7, 8, 5, 3]] = 1420  # => 900.169.200.000
      @exponentsDemo[[9, 5, 5, 4]] = 1421  # => 933.508.800.000
      @exponentsDemo[[9, 8, 3, 4]] = 1422  # => 1.008.189.504.000
      @exponentsDemo[[6, 7, 5, 4]] = 1423  # => 1.050.197.400.000
      @exponentsDemo[[9, 7, 5, 3]] = 1424  # => 1.200.225.600.000
      @exponentsDemo[[7, 8, 4, 4]] = 1425  # => 1.260.236.880.000
      @exponentsDemo[[8, 6, 5, 4]] = 1426  # => 1.400.263.200.000
      @exponentsDemo[[5, 8, 5, 4]] = 1427  # => 1.575.296.100.000
      @exponentsDemo[[9, 7, 4, 4]] = 1428  # => 1.680.315.840.000
      @exponentsDemo[[8, 8, 5, 3]] = 1429  # => 1.800.338.400.000
      @exponentsDemo[[7, 7, 5, 4]] = 1430  # => 2.100.394.800.000
      @exponentsDemo[[8, 8, 4, 4]] = 1431  # => 2.520.473.760.000
      @exponentsDemo[[9, 6, 5, 4]] = 1432  # => 2.800.526.400.000
      @exponentsDemo[[6, 8, 5, 4]] = 1433  # => 3.150.592.200.000
      @exponentsDemo[[9, 8, 5, 3]] = 1434  # => 3.600.676.800.000
      @exponentsDemo[[8, 7, 5, 4]] = 1435  # => 4.200.789.600.000
      @exponentsDemo[[9, 8, 4, 4]] = 1436  # => 5.040.947.520.000
      @exponentsDemo[[7, 8, 5, 4]] = 1437  # => 6.301.184.400.000
      @exponentsDemo[[9, 7, 5, 4]] = 1438  # => 8.401.579.200.000
      @exponentsDemo[[8, 8, 5, 4]] = 1439  # => 12.602.368.800.000
      @exponentsDemo[[9, 8, 5, 4]] = 1440  # => 25.204.737.600.000
   end
end
