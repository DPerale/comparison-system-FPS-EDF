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
      @short_period_demo_mixed = 288..454  # 274..310 #   6.350.400 -->  17.781.120
      @mid_period_demo_mixed   = 522..568  # 321..345 #  24.696.000 -->  66.679.200
      @long_period_demo_mixed  = 580..612 # 361..374 # 166.698.000 --> 800.150.400

      #####################
      ##    DEADLINES    ##
      #####################
      @short_constr_dead_demo_mixed = 120..195 #   2.540.160 -->   8.232.000
      @mid_constr_dead_demo_mixed   = 265..335 #  14.288.400 -->  33.339.600
      @long_constr_dead_demo_mixed  = 395..470 # 114.307.200 --> 333.396.000

      #################
      ##    EXECS    ##
      #################
      # They do not need to be extended because timings for computation is
      # corrected

      @short_impl_exec_range   =   1000..3000   #   10000..25000
      @mid_impl_exec_range     =   6000..18000  #  100000..250000
      @long_impl_exec_range    =  36000..118000 # 1000000..2500000

      @short_constr_exec_range =   1000..2500    #   10000..25000
      @mid_constr_exec_range   =  10000..25000   #  100000..250000
      @long_constr_exec_range  = 100000..250000  # 1000000..2500000

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
      
     @exponentsDemo[[0, 0, 0, 0]] = 1 # =>  1
     @exponentsDemo[[1, 0, 0, 0]] =  2 # =>  2
     @exponentsDemo[[0, 1, 0, 0]] =  3 # =>  3
     @exponentsDemo[[2, 0, 0, 0]] =  4 # =>  4
     @exponentsDemo[[0, 0, 1, 0]] =  5 # =>  5
     @exponentsDemo[[1, 1, 0, 0]] =  6 # =>  6
     @exponentsDemo[[0, 0, 0, 1]] =  7 # =>  7
     @exponentsDemo[[3, 0, 0, 0]] =  8 # =>  8
     @exponentsDemo[[0, 2, 0, 0]] =  9 # =>  9
     @exponentsDemo[[1, 0, 1, 0]] =  10  # =>  10
     @exponentsDemo[[2, 1, 0, 0]] =  11  # =>  12
     @exponentsDemo[[1, 0, 0, 1]] =  12  # =>  14
     @exponentsDemo[[0, 1, 1, 0]] =  13  # =>  15
     @exponentsDemo[[4, 0, 0, 0]] =  14  # =>  16
     @exponentsDemo[[1, 2, 0, 0]] =  15  # =>  18
     @exponentsDemo[[2, 0, 1, 0]] =  16  # =>  20
     @exponentsDemo[[0, 1, 0, 1]] =  17  # =>  21
     @exponentsDemo[[3, 1, 0, 0]] =  18  # =>  24
     @exponentsDemo[[0, 0, 2, 0]] =  19  # =>  25
     @exponentsDemo[[0, 3, 0, 0]] =  20  # =>  27
     @exponentsDemo[[2, 0, 0, 1]] =  21  # =>  28
     @exponentsDemo[[1, 1, 1, 0]] =  22  # =>  30
     @exponentsDemo[[5, 0, 0, 0]] =  23  # =>  32
     @exponentsDemo[[0, 0, 1, 1]] =  24  # =>  35
     @exponentsDemo[[2, 2, 0, 0]] =  25  # =>  36
     @exponentsDemo[[3, 0, 1, 0]] =  26  # =>  40
     @exponentsDemo[[1, 1, 0, 1]] =  27  # =>  42
     @exponentsDemo[[0, 2, 1, 0]] =  28  # =>  45
     @exponentsDemo[[4, 1, 0, 0]] =  29  # =>  48
     @exponentsDemo[[0, 0, 0, 2]] =  30  # =>  49
     @exponentsDemo[[1, 0, 2, 0]] =  31  # =>  50
     @exponentsDemo[[1, 3, 0, 0]] =  32  # =>  54
     @exponentsDemo[[3, 0, 0, 1]] =  33  # =>  56
     @exponentsDemo[[2, 1, 1, 0]] =  34  # =>  60
     @exponentsDemo[[0, 2, 0, 1]] =  35  # =>  63
     @exponentsDemo[[6, 0, 0, 0]] =  36  # =>  64
     @exponentsDemo[[1, 0, 1, 1]] =  37  # =>  70
     @exponentsDemo[[3, 2, 0, 0]] =  38  # =>  72
     @exponentsDemo[[0, 1, 2, 0]] =  39  # =>  75
     @exponentsDemo[[4, 0, 1, 0]] =  40  # =>  80
     @exponentsDemo[[0, 4, 0, 0]] =  41  # =>  81
     @exponentsDemo[[2, 1, 0, 1]] =  42  # =>  84
     @exponentsDemo[[1, 2, 1, 0]] =  43  # =>  90
     @exponentsDemo[[5, 1, 0, 0]] =  44  # =>  96
     @exponentsDemo[[1, 0, 0, 2]] =  45  # =>  98
     @exponentsDemo[[2, 0, 2, 0]] =  46  # =>  100
     @exponentsDemo[[0, 1, 1, 1]] =  47  # =>  105
     @exponentsDemo[[2, 3, 0, 0]] =  48  # =>  108
     @exponentsDemo[[4, 0, 0, 1]] =  49  # =>  112
     @exponentsDemo[[3, 1, 1, 0]] =  50  # =>  120
     @exponentsDemo[[0, 0, 3, 0]] =  51  # =>  125
     @exponentsDemo[[1, 2, 0, 1]] =  52  # =>  126
     @exponentsDemo[[7, 0, 0, 0]] =  53  # =>  128
     @exponentsDemo[[0, 3, 1, 0]] =  54  # =>  135
     @exponentsDemo[[2, 0, 1, 1]] =  55  # =>  140
     @exponentsDemo[[4, 2, 0, 0]] =  56  # =>  144
     @exponentsDemo[[0, 1, 0, 2]] =  57  # =>  147
     @exponentsDemo[[1, 1, 2, 0]] =  58  # =>  150
     @exponentsDemo[[5, 0, 1, 0]] =  59  # =>  160
     @exponentsDemo[[1, 4, 0, 0]] =  60  # =>  162
     @exponentsDemo[[3, 1, 0, 1]] =  61  # =>  168
     @exponentsDemo[[0, 0, 2, 1]] =  62  # =>  175
     @exponentsDemo[[2, 2, 1, 0]] =  63  # =>  180
     @exponentsDemo[[0, 3, 0, 1]] =  64  # =>  189
     @exponentsDemo[[6, 1, 0, 0]] =  65  # =>  192
     @exponentsDemo[[2, 0, 0, 2]] =  66  # =>  196
     @exponentsDemo[[3, 0, 2, 0]] =  67  # =>  200
     @exponentsDemo[[1, 1, 1, 1]] =  68  # =>  210
     @exponentsDemo[[3, 3, 0, 0]] =  69  # =>  216
     @exponentsDemo[[5, 0, 0, 1]] =  70  # =>  224
     @exponentsDemo[[0, 2, 2, 0]] =  71  # =>  225
     @exponentsDemo[[4, 1, 1, 0]] =  72  # =>  240
     @exponentsDemo[[0, 5, 0, 0]] =  73  # =>  243
     @exponentsDemo[[0, 0, 1, 2]] =  74  # =>  245
     @exponentsDemo[[1, 0, 3, 0]] =  75  # =>  250
     @exponentsDemo[[2, 2, 0, 1]] =  76  # =>  252
     @exponentsDemo[[8, 0, 0, 0]] =  77  # =>  256
     @exponentsDemo[[1, 3, 1, 0]] =  78  # =>  270
     @exponentsDemo[[3, 0, 1, 1]] =  79  # =>  280
     @exponentsDemo[[5, 2, 0, 0]] =  80  # =>  288
     @exponentsDemo[[1, 1, 0, 2]] =  81  # =>  294
     @exponentsDemo[[2, 1, 2, 0]] =  82  # =>  300
     @exponentsDemo[[0, 2, 1, 1]] =  83  # =>  315
     @exponentsDemo[[6, 0, 1, 0]] =  84  # =>  320
     @exponentsDemo[[2, 4, 0, 0]] =  85  # =>  324
     @exponentsDemo[[4, 1, 0, 1]] =  86  # =>  336
     @exponentsDemo[[1, 0, 2, 1]] =  87  # =>  350
     @exponentsDemo[[3, 2, 1, 0]] =  88  # =>  360
     @exponentsDemo[[0, 1, 3, 0]] =  89  # =>  375
     @exponentsDemo[[1, 3, 0, 1]] =  90  # =>  378
     @exponentsDemo[[7, 1, 0, 0]] =  91  # =>  384
     @exponentsDemo[[3, 0, 0, 2]] =  92  # =>  392
     @exponentsDemo[[4, 0, 2, 0]] =  93  # =>  400
     @exponentsDemo[[0, 4, 1, 0]] =  94  # =>  405
     @exponentsDemo[[2, 1, 1, 1]] =  95  # =>  420
     @exponentsDemo[[4, 3, 0, 0]] =  96  # =>  432
     @exponentsDemo[[0, 2, 0, 2]] =  97  # =>  441
     @exponentsDemo[[6, 0, 0, 1]] =  98  # =>  448
     @exponentsDemo[[1, 2, 2, 0]] =  99  # =>  450
     @exponentsDemo[[5, 1, 1, 0]] =  100 # =>  480
     @exponentsDemo[[1, 5, 0, 0]] =  101 # =>  486
     @exponentsDemo[[1, 0, 1, 2]] =  102 # =>  490
     @exponentsDemo[[2, 0, 3, 0]] =  103 # =>  500
     @exponentsDemo[[3, 2, 0, 1]] =  104 # =>  504
     @exponentsDemo[[0, 1, 2, 1]] =  105 # =>  525
     @exponentsDemo[[2, 3, 1, 0]] =  106 # =>  540
     @exponentsDemo[[4, 0, 1, 1]] =  107 # =>  560
     @exponentsDemo[[0, 4, 0, 1]] =  108 # =>  567
     @exponentsDemo[[6, 2, 0, 0]] =  109 # =>  576
     @exponentsDemo[[2, 1, 0, 2]] =  110 # =>  588
     @exponentsDemo[[3, 1, 2, 0]] =  111 # =>  600
     @exponentsDemo[[0, 0, 4, 0]] =  112 # =>  625
     @exponentsDemo[[1, 2, 1, 1]] =  113 # =>  630
     @exponentsDemo[[7, 0, 1, 0]] =  114 # =>  640
     @exponentsDemo[[3, 4, 0, 0]] =  115 # =>  648
     @exponentsDemo[[5, 1, 0, 1]] =  116 # =>  672
     @exponentsDemo[[0, 3, 2, 0]] =  117 # =>  675
     @exponentsDemo[[2, 0, 2, 1]] =  118 # =>  700
     @exponentsDemo[[4, 2, 1, 0]] =  119 # =>  720
     @exponentsDemo[[0, 1, 1, 2]] =  120 # =>  735
     @exponentsDemo[[1, 1, 3, 0]] =  121 # =>  750
     @exponentsDemo[[2, 3, 0, 1]] =  122 # =>  756
     @exponentsDemo[[8, 1, 0, 0]] =  123 # =>  768
     @exponentsDemo[[4, 0, 0, 2]] =  124 # =>  784
     @exponentsDemo[[5, 0, 2, 0]] =  125 # =>  800
     @exponentsDemo[[1, 4, 1, 0]] =  126 # =>  810
     @exponentsDemo[[3, 1, 1, 1]] =  127 # =>  840
     @exponentsDemo[[5, 3, 0, 0]] =  128 # =>  864
     @exponentsDemo[[0, 0, 3, 1]] =  129 # =>  875
     @exponentsDemo[[1, 2, 0, 2]] =  130 # =>  882
     @exponentsDemo[[7, 0, 0, 1]] =  131 # =>  896
     @exponentsDemo[[2, 2, 2, 0]] =  132 # =>  900
     @exponentsDemo[[0, 3, 1, 1]] =  133 # =>  945
     @exponentsDemo[[6, 1, 1, 0]] =  134 # =>  960
     @exponentsDemo[[2, 5, 0, 0]] =  135 # =>  972
     @exponentsDemo[[2, 0, 1, 2]] =  136 # =>  980
     @exponentsDemo[[3, 0, 3, 0]] =  137 # =>  1000
     @exponentsDemo[[4, 2, 0, 1]] =  138 # =>  1008
     @exponentsDemo[[1, 1, 2, 1]] =  139 # =>  1050
     @exponentsDemo[[3, 3, 1, 0]] =  140 # =>  1080
     @exponentsDemo[[5, 0, 1, 1]] =  141 # =>  1120
     @exponentsDemo[[0, 2, 3, 0]] =  142 # =>  1125
     @exponentsDemo[[1, 4, 0, 1]] =  143 # =>  1134
     @exponentsDemo[[7, 2, 0, 0]] =  144 # =>  1152
     @exponentsDemo[[3, 1, 0, 2]] =  145 # =>  1176
     @exponentsDemo[[4, 1, 2, 0]] =  146 # =>  1200
     @exponentsDemo[[0, 5, 1, 0]] =  147 # =>  1215
     @exponentsDemo[[0, 0, 2, 2]] =  148 # =>  1225
     @exponentsDemo[[1, 0, 4, 0]] =  149 # =>  1250
     @exponentsDemo[[2, 2, 1, 1]] =  150 # =>  1260
     @exponentsDemo[[8, 0, 1, 0]] =  151 # =>  1280
     @exponentsDemo[[4, 4, 0, 0]] =  152 # =>  1296
     @exponentsDemo[[0, 3, 0, 2]] =  153 # =>  1323
     @exponentsDemo[[6, 1, 0, 1]] =  154 # =>  1344
     @exponentsDemo[[1, 3, 2, 0]] =  155 # =>  1350
     @exponentsDemo[[3, 0, 2, 1]] =  156 # =>  1400
     @exponentsDemo[[5, 2, 1, 0]] =  157 # =>  1440
     @exponentsDemo[[1, 1, 1, 2]] =  158 # =>  1470
     @exponentsDemo[[2, 1, 3, 0]] =  159 # =>  1500
     @exponentsDemo[[3, 3, 0, 1]] =  160 # =>  1512
     @exponentsDemo[[5, 0, 0, 2]] =  161 # =>  1568
     @exponentsDemo[[0, 2, 2, 1]] =  162 # =>  1575
     @exponentsDemo[[6, 0, 2, 0]] =  163 # =>  1600
     @exponentsDemo[[2, 4, 1, 0]] =  164 # =>  1620
     @exponentsDemo[[4, 1, 1, 1]] =  165 # =>  1680
     @exponentsDemo[[0, 5, 0, 1]] =  166 # =>  1701
     @exponentsDemo[[6, 3, 0, 0]] =  167 # =>  1728
     @exponentsDemo[[1, 0, 3, 1]] =  168 # =>  1750
     @exponentsDemo[[2, 2, 0, 2]] =  169 # =>  1764
     @exponentsDemo[[8, 0, 0, 1]] =  170 # =>  1792
     @exponentsDemo[[3, 2, 2, 0]] =  171 # =>  1800
     @exponentsDemo[[0, 1, 4, 0]] =  172 # =>  1875
     @exponentsDemo[[1, 3, 1, 1]] =  173 # =>  1890
     @exponentsDemo[[7, 1, 1, 0]] =  174 # =>  1920
     @exponentsDemo[[3, 5, 0, 0]] =  175 # =>  1944
     @exponentsDemo[[3, 0, 1, 2]] =  176 # =>  1960
     @exponentsDemo[[4, 0, 3, 0]] =  177 # =>  2000
     @exponentsDemo[[5, 2, 0, 1]] =  178 # =>  2016
     @exponentsDemo[[0, 4, 2, 0]] =  179 # =>  2025
     @exponentsDemo[[2, 1, 2, 1]] =  180 # =>  2100
     @exponentsDemo[[4, 3, 1, 0]] =  181 # =>  2160
     @exponentsDemo[[0, 2, 1, 2]] =  182 # =>  2205
     @exponentsDemo[[6, 0, 1, 1]] =  183 # =>  2240
     @exponentsDemo[[1, 2, 3, 0]] =  184 # =>  2250
     @exponentsDemo[[2, 4, 0, 1]] =  185 # =>  2268
     @exponentsDemo[[8, 2, 0, 0]] =  186 # =>  2304
     @exponentsDemo[[4, 1, 0, 2]] =  187 # =>  2352
     @exponentsDemo[[5, 1, 2, 0]] =  188 # =>  2400
     @exponentsDemo[[1, 5, 1, 0]] =  189 # =>  2430
     @exponentsDemo[[1, 0, 2, 2]] =  190 # =>  2450
     @exponentsDemo[[2, 0, 4, 0]] =  191 # =>  2500
     @exponentsDemo[[3, 2, 1, 1]] =  192 # =>  2520
     @exponentsDemo[[5, 4, 0, 0]] =  193 # =>  2592
     @exponentsDemo[[0, 1, 3, 1]] =  194 # =>  2625
     @exponentsDemo[[1, 3, 0, 2]] =  195 # =>  2646
     @exponentsDemo[[7, 1, 0, 1]] =  196 # =>  2688
     @exponentsDemo[[2, 3, 2, 0]] =  197 # =>  2700
     @exponentsDemo[[4, 0, 2, 1]] =  198 # =>  2800
     @exponentsDemo[[0, 4, 1, 1]] =  199 # =>  2835
     @exponentsDemo[[6, 2, 1, 0]] =  200 # =>  2880
     @exponentsDemo[[2, 1, 1, 2]] =  201 # =>  2940
     @exponentsDemo[[3, 1, 3, 0]] =  202 # =>  3000
     @exponentsDemo[[4, 3, 0, 1]] =  203 # =>  3024
     @exponentsDemo[[6, 0, 0, 2]] =  204 # =>  3136
     @exponentsDemo[[1, 2, 2, 1]] =  205 # =>  3150
     @exponentsDemo[[7, 0, 2, 0]] =  206 # =>  3200
     @exponentsDemo[[3, 4, 1, 0]] =  207 # =>  3240
     @exponentsDemo[[5, 1, 1, 1]] =  208 # =>  3360
     @exponentsDemo[[0, 3, 3, 0]] =  209 # =>  3375
     @exponentsDemo[[1, 5, 0, 1]] =  210 # =>  3402
     @exponentsDemo[[7, 3, 0, 0]] =  211 # =>  3456
     @exponentsDemo[[2, 0, 3, 1]] =  212 # =>  3500
     @exponentsDemo[[3, 2, 0, 2]] =  213 # =>  3528
     @exponentsDemo[[4, 2, 2, 0]] =  214 # =>  3600
     @exponentsDemo[[0, 1, 2, 2]] =  215 # =>  3675
     @exponentsDemo[[1, 1, 4, 0]] =  216 # =>  3750
     @exponentsDemo[[2, 3, 1, 1]] =  217 # =>  3780
     @exponentsDemo[[8, 1, 1, 0]] =  218 # =>  3840
     @exponentsDemo[[4, 5, 0, 0]] =  219 # =>  3888
     @exponentsDemo[[4, 0, 1, 2]] =  220 # =>  3920
     @exponentsDemo[[0, 4, 0, 2]] =  221 # =>  3969
     @exponentsDemo[[5, 0, 3, 0]] =  222 # =>  4000
     @exponentsDemo[[6, 2, 0, 1]] =  223 # =>  4032
     @exponentsDemo[[1, 4, 2, 0]] =  224 # =>  4050
     @exponentsDemo[[3, 1, 2, 1]] =  225 # =>  4200
     @exponentsDemo[[5, 3, 1, 0]] =  226 # =>  4320
     @exponentsDemo[[0, 0, 4, 1]] =  227 # =>  4375
     @exponentsDemo[[1, 2, 1, 2]] =  228 # =>  4410
     @exponentsDemo[[7, 0, 1, 1]] =  229 # =>  4480
     @exponentsDemo[[2, 2, 3, 0]] =  230 # =>  4500
     @exponentsDemo[[3, 4, 0, 1]] =  231 # =>  4536
     @exponentsDemo[[5, 1, 0, 2]] =  232 # =>  4704
     @exponentsDemo[[0, 3, 2, 1]] =  233 # =>  4725
     @exponentsDemo[[6, 1, 2, 0]] =  234 # =>  4800
     @exponentsDemo[[2, 5, 1, 0]] =  235 # =>  4860
     @exponentsDemo[[2, 0, 2, 2]] =  236 # =>  4900
     @exponentsDemo[[3, 0, 4, 0]] =  237 # =>  5000
     @exponentsDemo[[4, 2, 1, 1]] =  238 # =>  5040
     @exponentsDemo[[6, 4, 0, 0]] =  239 # =>  5184
     @exponentsDemo[[1, 1, 3, 1]] =  240 # =>  5250
     @exponentsDemo[[2, 3, 0, 2]] =  241 # =>  5292
     @exponentsDemo[[8, 1, 0, 1]] =  242 # =>  5376
     @exponentsDemo[[3, 3, 2, 0]] =  243 # =>  5400
     @exponentsDemo[[5, 0, 2, 1]] =  244 # =>  5600
     @exponentsDemo[[0, 2, 4, 0]] =  245 # =>  5625
     @exponentsDemo[[1, 4, 1, 1]] =  246 # =>  5670
     @exponentsDemo[[7, 2, 1, 0]] =  247 # =>  5760
     @exponentsDemo[[3, 1, 1, 2]] =  248 # =>  5880
     @exponentsDemo[[4, 1, 3, 0]] =  249 # =>  6000
     @exponentsDemo[[5, 3, 0, 1]] =  250 # =>  6048
     @exponentsDemo[[0, 5, 2, 0]] =  251 # =>  6075
     @exponentsDemo[[0, 0, 3, 2]] =  252 # =>  6125
     @exponentsDemo[[7, 0, 0, 2]] =  253 # =>  6272
     @exponentsDemo[[2, 2, 2, 1]] =  254 # =>  6300
     @exponentsDemo[[8, 0, 2, 0]] =  255 # =>  6400
     @exponentsDemo[[4, 4, 1, 0]] =  256 # =>  6480
     @exponentsDemo[[0, 3, 1, 2]] =  257 # =>  6615
     @exponentsDemo[[6, 1, 1, 1]] =  258 # =>  6720
     @exponentsDemo[[1, 3, 3, 0]] =  259 # =>  6750
     @exponentsDemo[[2, 5, 0, 1]] =  260 # =>  6804
     @exponentsDemo[[8, 3, 0, 0]] =  261 # =>  6912
     @exponentsDemo[[3, 0, 3, 1]] =  262 # =>  7000
     @exponentsDemo[[4, 2, 0, 2]] =  263 # =>  7056
     @exponentsDemo[[5, 2, 2, 0]] =  264 # =>  7200
     @exponentsDemo[[1, 1, 2, 2]] =  265 # =>  7350
     @exponentsDemo[[2, 1, 4, 0]] =  266 # =>  7500
     @exponentsDemo[[3, 3, 1, 1]] =  267 # =>  7560
     @exponentsDemo[[5, 5, 0, 0]] =  268 # =>  7776
     @exponentsDemo[[5, 0, 1, 2]] =  269 # =>  7840
     @exponentsDemo[[0, 2, 3, 1]] =  270 # =>  7875
     @exponentsDemo[[1, 4, 0, 2]] =  271 # =>  7938
     @exponentsDemo[[6, 0, 3, 0]] =  272 # =>  8000
     @exponentsDemo[[7, 2, 0, 1]] =  273 # =>  8064
     @exponentsDemo[[2, 4, 2, 0]] =  274 # =>  8100
     @exponentsDemo[[4, 1, 2, 1]] =  275 # =>  8400
     @exponentsDemo[[0, 5, 1, 1]] =  276 # =>  8505
     @exponentsDemo[[6, 3, 1, 0]] =  277 # =>  8640
     @exponentsDemo[[1, 0, 4, 1]] =  278 # =>  8750
     @exponentsDemo[[2, 2, 1, 2]] =  279 # =>  8820
     @exponentsDemo[[8, 0, 1, 1]] =  280 # =>  8960
     @exponentsDemo[[3, 2, 3, 0]] =  281 # =>  9000
     @exponentsDemo[[4, 4, 0, 1]] =  282 # =>  9072
     @exponentsDemo[[6, 1, 0, 2]] =  283 # =>  9408
     @exponentsDemo[[1, 3, 2, 1]] =  284 # =>  9450
     @exponentsDemo[[7, 1, 2, 0]] =  285 # =>  9600
     @exponentsDemo[[3, 5, 1, 0]] =  286 # =>  9720
     @exponentsDemo[[3, 0, 2, 2]] =  287 # =>  9800
     @exponentsDemo[[4, 0, 4, 0]] =  288 # =>  10000    STARTING SHORTS
     @exponentsDemo[[5, 2, 1, 1]] =  289 # =>  10080
     @exponentsDemo[[0, 4, 3, 0]] =  290 # =>  10125
     @exponentsDemo[[7, 4, 0, 0]] =  291 # =>  10368
     @exponentsDemo[[2, 1, 3, 1]] =  292 # =>  10500
     @exponentsDemo[[3, 3, 0, 2]] =  293 # =>  10584
     @exponentsDemo[[4, 3, 2, 0]] =  294 # =>  10800
     @exponentsDemo[[0, 2, 2, 2]] =  295 # =>  11025
     @exponentsDemo[[6, 0, 2, 1]] =  296 # =>  11200
     @exponentsDemo[[1, 2, 4, 0]] =  297 # =>  11250
     @exponentsDemo[[2, 4, 1, 1]] =  298 # =>  11340
     @exponentsDemo[[8, 2, 1, 0]] =  299 # =>  11520
     @exponentsDemo[[4, 1, 1, 2]] =  300 # =>  11760
     @exponentsDemo[[0, 5, 0, 2]] =  301 # =>  11907
     @exponentsDemo[[5, 1, 3, 0]] =  302 # =>  12000
     @exponentsDemo[[6, 3, 0, 1]] =  303 # =>  12096
     @exponentsDemo[[1, 5, 2, 0]] =  304 # =>  12150
     @exponentsDemo[[1, 0, 3, 2]] =  305 # =>  12250
     @exponentsDemo[[8, 0, 0, 2]] =  306 # =>  12544
     @exponentsDemo[[3, 2, 2, 1]] =  307 # =>  12600
     @exponentsDemo[[5, 4, 1, 0]] =  308 # =>  12960
     @exponentsDemo[[0, 1, 4, 1]] =  309 # =>  13125
     @exponentsDemo[[1, 3, 1, 2]] =  310 # =>  13230
     @exponentsDemo[[7, 1, 1, 1]] =  311 # =>  13440
     @exponentsDemo[[2, 3, 3, 0]] =  312 # =>  13500
     @exponentsDemo[[3, 5, 0, 1]] =  313 # =>  13608
     @exponentsDemo[[4, 0, 3, 1]] =  314 # =>  14000
     @exponentsDemo[[5, 2, 0, 2]] =  315 # =>  14112
     @exponentsDemo[[0, 4, 2, 1]] =  316 # =>  14175
     @exponentsDemo[[6, 2, 2, 0]] =  317 # =>  14400
     @exponentsDemo[[2, 1, 2, 2]] =  318 # =>  14700
     @exponentsDemo[[3, 1, 4, 0]] =  319 # =>  15000
     @exponentsDemo[[4, 3, 1, 1]] =  320 # =>  15120
     @exponentsDemo[[6, 5, 0, 0]] =  321 # =>  15552
     @exponentsDemo[[6, 0, 1, 2]] =  322 # =>  15680
     @exponentsDemo[[1, 2, 3, 1]] =  323 # =>  15750
     @exponentsDemo[[2, 4, 0, 2]] =  324 # =>  15876
     @exponentsDemo[[7, 0, 3, 0]] =  325 # =>  16000
     @exponentsDemo[[8, 2, 0, 1]] =  326 # =>  16128
     @exponentsDemo[[3, 4, 2, 0]] =  327 # =>  16200
     @exponentsDemo[[5, 1, 2, 1]] =  328 # =>  16800
     @exponentsDemo[[0, 3, 4, 0]] =  329 # =>  16875
     @exponentsDemo[[1, 5, 1, 1]] =  330 # =>  17010
     @exponentsDemo[[7, 3, 1, 0]] =  331 # =>  17280
     @exponentsDemo[[2, 0, 4, 1]] =  332 # =>  17500
     @exponentsDemo[[3, 2, 1, 2]] =  333 # =>  17640
     @exponentsDemo[[4, 2, 3, 0]] =  334 # =>  18000
     @exponentsDemo[[5, 4, 0, 1]] =  335 # =>  18144
     @exponentsDemo[[0, 1, 3, 2]] =  336 # =>  18375
     @exponentsDemo[[7, 1, 0, 2]] =  337 # =>  18816
     @exponentsDemo[[2, 3, 2, 1]] =  338 # =>  18900
     @exponentsDemo[[8, 1, 2, 0]] =  339 # =>  19200
     @exponentsDemo[[4, 5, 1, 0]] =  340 # =>  19440
     @exponentsDemo[[4, 0, 2, 2]] =  341 # =>  19600
     @exponentsDemo[[0, 4, 1, 2]] =  342 # =>  19845
     @exponentsDemo[[5, 0, 4, 0]] =  343 # =>  20000
     @exponentsDemo[[6, 2, 1, 1]] =  344 # =>  20160
     @exponentsDemo[[1, 4, 3, 0]] =  345 # =>  20250
     @exponentsDemo[[8, 4, 0, 0]] =  346 # =>  20736
     @exponentsDemo[[3, 1, 3, 1]] =  347 # =>  21000
     @exponentsDemo[[4, 3, 0, 2]] =  348 # =>  21168
     @exponentsDemo[[5, 3, 2, 0]] =  349 # =>  21600
     @exponentsDemo[[1, 2, 2, 2]] =  350 # =>  22050
     @exponentsDemo[[7, 0, 2, 1]] =  351 # =>  22400
     @exponentsDemo[[2, 2, 4, 0]] =  352 # =>  22500
     @exponentsDemo[[3, 4, 1, 1]] =  353 # =>  22680
     @exponentsDemo[[5, 1, 1, 2]] =  354 # =>  23520
     @exponentsDemo[[0, 3, 3, 1]] =  355 # =>  23625
     @exponentsDemo[[1, 5, 0, 2]] =  356 # =>  23814
     @exponentsDemo[[6, 1, 3, 0]] =  357 # =>  24000
     @exponentsDemo[[7, 3, 0, 1]] =  358 # =>  24192
     @exponentsDemo[[2, 5, 2, 0]] =  359 # =>  24300
     @exponentsDemo[[2, 0, 3, 2]] =  360 # =>  24500
     @exponentsDemo[[4, 2, 2, 1]] =  361 # =>  25200
     @exponentsDemo[[6, 4, 1, 0]] =  362 # =>  25920
     @exponentsDemo[[1, 1, 4, 1]] =  363 # =>  26250
     @exponentsDemo[[2, 3, 1, 2]] =  364 # =>  26460
     @exponentsDemo[[8, 1, 1, 1]] =  365 # =>  26880
     @exponentsDemo[[3, 3, 3, 0]] =  366 # =>  27000
     @exponentsDemo[[4, 5, 0, 1]] =  367 # =>  27216
     @exponentsDemo[[5, 0, 3, 1]] =  368 # =>  28000
     @exponentsDemo[[6, 2, 0, 2]] =  369 # =>  28224
     @exponentsDemo[[1, 4, 2, 1]] =  370 # =>  28350
     @exponentsDemo[[7, 2, 2, 0]] =  371 # =>  28800
     @exponentsDemo[[3, 1, 2, 2]] =  372 # =>  29400
     @exponentsDemo[[4, 1, 4, 0]] =  373 # =>  30000
     @exponentsDemo[[5, 3, 1, 1]] =  374 # =>  30240
     @exponentsDemo[[0, 5, 3, 0]] =  375 # =>  30375
     @exponentsDemo[[0, 0, 4, 2]] =  376 # =>  30625
     @exponentsDemo[[7, 5, 0, 0]] =  377 # =>  31104
     @exponentsDemo[[7, 0, 1, 2]] =  378 # =>  31360
     @exponentsDemo[[2, 2, 3, 1]] =  379 # =>  31500
     @exponentsDemo[[3, 4, 0, 2]] =  380 # =>  31752
     @exponentsDemo[[8, 0, 3, 0]] =  381 # =>  32000
     @exponentsDemo[[4, 4, 2, 0]] =  382 # =>  32400
     @exponentsDemo[[0, 3, 2, 2]] =  383 # =>  33075
     @exponentsDemo[[6, 1, 2, 1]] =  384 # =>  33600
     @exponentsDemo[[1, 3, 4, 0]] =  385 # =>  33750
     @exponentsDemo[[2, 5, 1, 1]] =  386 # =>  34020
     @exponentsDemo[[8, 3, 1, 0]] =  387 # =>  34560
     @exponentsDemo[[3, 0, 4, 1]] =  388 # =>  35000
     @exponentsDemo[[4, 2, 1, 2]] =  389 # =>  35280
     @exponentsDemo[[5, 2, 3, 0]] =  390 # =>  36000
     @exponentsDemo[[6, 4, 0, 1]] =  391 # =>  36288
     @exponentsDemo[[1, 1, 3, 2]] =  392 # =>  36750
     @exponentsDemo[[8, 1, 0, 2]] =  393 # =>  37632
     @exponentsDemo[[3, 3, 2, 1]] =  394 # =>  37800
     @exponentsDemo[[5, 5, 1, 0]] =  395 # =>  38880
     @exponentsDemo[[5, 0, 2, 2]] =  396 # =>  39200
     @exponentsDemo[[0, 2, 4, 1]] =  397 # =>  39375
     @exponentsDemo[[1, 4, 1, 2]] =  398 # =>  39690
     @exponentsDemo[[6, 0, 4, 0]] =  399 # =>  40000
     @exponentsDemo[[7, 2, 1, 1]] =  400 # =>  40320
     @exponentsDemo[[2, 4, 3, 0]] =  401 # =>  40500
     @exponentsDemo[[4, 1, 3, 1]] =  402 # =>  42000
     @exponentsDemo[[5, 3, 0, 2]] =  403 # =>  42336
     @exponentsDemo[[0, 5, 2, 1]] =  404 # =>  42525
     @exponentsDemo[[6, 3, 2, 0]] =  405 # =>  43200
     @exponentsDemo[[2, 2, 2, 2]] =  406 # =>  44100
     @exponentsDemo[[8, 0, 2, 1]] =  407 # =>  44800
     @exponentsDemo[[3, 2, 4, 0]] =  408 # =>  45000
     @exponentsDemo[[4, 4, 1, 1]] =  409 # =>  45360
     @exponentsDemo[[6, 1, 1, 2]] =  410 # =>  47040
     @exponentsDemo[[1, 3, 3, 1]] =  411 # =>  47250
     @exponentsDemo[[2, 5, 0, 2]] =  412 # =>  47628
     @exponentsDemo[[7, 1, 3, 0]] =  413 # =>  48000
     @exponentsDemo[[8, 3, 0, 1]] =  414 # =>  48384
     @exponentsDemo[[3, 5, 2, 0]] =  415 # =>  48600
     @exponentsDemo[[3, 0, 3, 2]] =  416 # =>  49000
     @exponentsDemo[[5, 2, 2, 1]] =  417 # =>  50400
     @exponentsDemo[[0, 4, 4, 0]] =  418 # =>  50625
     @exponentsDemo[[7, 4, 1, 0]] =  419 # =>  51840
     @exponentsDemo[[2, 1, 4, 1]] =  420 # =>  52500
     @exponentsDemo[[3, 3, 1, 2]] =  421 # =>  52920
     @exponentsDemo[[4, 3, 3, 0]] =  422 # =>  54000
     @exponentsDemo[[5, 5, 0, 1]] =  423 # =>  54432
     @exponentsDemo[[0, 2, 3, 2]] =  424 # =>  55125
     @exponentsDemo[[6, 0, 3, 1]] =  425 # =>  56000
     @exponentsDemo[[7, 2, 0, 2]] =  426 # =>  56448
     @exponentsDemo[[2, 4, 2, 1]] =  427 # =>  56700
     @exponentsDemo[[8, 2, 2, 0]] =  428 # =>  57600
     @exponentsDemo[[4, 1, 2, 2]] =  429 # =>  58800
     @exponentsDemo[[0, 5, 1, 2]] =  430 # =>  59535
     @exponentsDemo[[5, 1, 4, 0]] =  431 # =>  60000
     @exponentsDemo[[6, 3, 1, 1]] =  432 # =>  60480
     @exponentsDemo[[1, 5, 3, 0]] =  433 # =>  60750
     @exponentsDemo[[1, 0, 4, 2]] =  434 # =>  61250
     @exponentsDemo[[8, 5, 0, 0]] =  435 # =>  62208
     @exponentsDemo[[8, 0, 1, 2]] =  436 # =>  62720
     @exponentsDemo[[3, 2, 3, 1]] =  437 # =>  63000
     @exponentsDemo[[4, 4, 0, 2]] =  438 # =>  63504
     @exponentsDemo[[5, 4, 2, 0]] =  439 # =>  64800
     @exponentsDemo[[1, 3, 2, 2]] =  440 # =>  66150
     @exponentsDemo[[7, 1, 2, 1]] =  441 # =>  67200
     @exponentsDemo[[2, 3, 4, 0]] =  442 # =>  67500
     @exponentsDemo[[3, 5, 1, 1]] =  443 # =>  68040
     @exponentsDemo[[4, 0, 4, 1]] =  444 # =>  70000
     @exponentsDemo[[5, 2, 1, 2]] =  445 # =>  70560
     @exponentsDemo[[0, 4, 3, 1]] =  446 # =>  70875
     @exponentsDemo[[6, 2, 3, 0]] =  447 # =>  72000
     @exponentsDemo[[7, 4, 0, 1]] =  448 # =>  72576
     @exponentsDemo[[2, 1, 3, 2]] =  449 # =>  73500
     @exponentsDemo[[4, 3, 2, 1]] =  450 # =>  75600
     @exponentsDemo[[6, 5, 1, 0]] =  451 # =>  77760
     @exponentsDemo[[6, 0, 2, 2]] =  452 # =>  78400
     @exponentsDemo[[1, 2, 4, 1]] =  453 # =>  78750
     @exponentsDemo[[2, 4, 1, 2]] =  454 # =>  79380    FINISH SHORTS
     @exponentsDemo[[7, 0, 4, 0]] =  455 # =>  80000 
     @exponentsDemo[[8, 2, 1, 1]] =  456 # =>  80640
     @exponentsDemo[[3, 4, 3, 0]] =  457 # =>  81000
     @exponentsDemo[[5, 1, 3, 1]] =  458 # =>  84000
     @exponentsDemo[[6, 3, 0, 2]] =  459 # =>  84672
     @exponentsDemo[[1, 5, 2, 1]] =  460 # =>  85050
     @exponentsDemo[[7, 3, 2, 0]] =  461 # =>  86400
     @exponentsDemo[[3, 2, 2, 2]] =  462 # =>  88200
     @exponentsDemo[[4, 2, 4, 0]] =  463 # =>  90000
     @exponentsDemo[[5, 4, 1, 1]] =  464 # =>  90720
     @exponentsDemo[[0, 1, 4, 2]] =  465 # =>  91875
     @exponentsDemo[[7, 1, 1, 2]] =  466 # =>  94080
     @exponentsDemo[[2, 3, 3, 1]] =  467 # =>  94500
     @exponentsDemo[[3, 5, 0, 2]] =  468 # =>  95256
     @exponentsDemo[[8, 1, 3, 0]] =  469 # =>  96000
     @exponentsDemo[[4, 5, 2, 0]] =  470 # =>  97200
     @exponentsDemo[[4, 0, 3, 2]] =  471 # =>  98000
     @exponentsDemo[[0, 4, 2, 2]] =  472 # =>  99225
     @exponentsDemo[[6, 2, 2, 1]] =  473 # =>  100800
     @exponentsDemo[[1, 4, 4, 0]] =  474 # =>  101250
     @exponentsDemo[[8, 4, 1, 0]] =  475 # =>  103680
     @exponentsDemo[[3, 1, 4, 1]] =  476 # =>  105000
     @exponentsDemo[[4, 3, 1, 2]] =  477 # =>  105840
     @exponentsDemo[[5, 3, 3, 0]] =  478 # =>  108000
     @exponentsDemo[[6, 5, 0, 1]] =  479 # =>  108864
     @exponentsDemo[[1, 2, 3, 2]] =  480 # =>  110250
     @exponentsDemo[[7, 0, 3, 1]] =  481 # =>  112000
     @exponentsDemo[[8, 2, 0, 2]] =  482 # =>  112896
     @exponentsDemo[[3, 4, 2, 1]] =  483 # =>  113400
     @exponentsDemo[[5, 1, 2, 2]] =  484 # =>  117600
     @exponentsDemo[[0, 3, 4, 1]] =  485 # =>  118125
     @exponentsDemo[[1, 5, 1, 2]] =  486 # =>  119070
     @exponentsDemo[[6, 1, 4, 0]] =  487 # =>  120000
     @exponentsDemo[[7, 3, 1, 1]] =  488 # =>  120960
     @exponentsDemo[[2, 5, 3, 0]] =  489 # =>  121500
     @exponentsDemo[[2, 0, 4, 2]] =  490 # =>  122500
     @exponentsDemo[[4, 2, 3, 1]] =  491 # =>  126000
     @exponentsDemo[[5, 4, 0, 2]] =  492 # =>  127008
     @exponentsDemo[[6, 4, 2, 0]] =  493 # =>  129600
     @exponentsDemo[[2, 3, 2, 2]] =  494 # =>  132300
     @exponentsDemo[[8, 1, 2, 1]] =  495 # =>  134400
     @exponentsDemo[[3, 3, 4, 0]] =  496 # =>  135000
     @exponentsDemo[[4, 5, 1, 1]] =  497 # =>  136080
     @exponentsDemo[[5, 0, 4, 1]] =  498 # =>  140000
     @exponentsDemo[[6, 2, 1, 2]] =  499 # =>  141120
     @exponentsDemo[[1, 4, 3, 1]] =  500 # =>  141750
     @exponentsDemo[[7, 2, 3, 0]] =  501 # =>  144000
     @exponentsDemo[[8, 4, 0, 1]] =  502 # =>  145152
     @exponentsDemo[[3, 1, 3, 2]] =  503 # =>  147000
     @exponentsDemo[[5, 3, 2, 1]] =  504 # =>  151200
     @exponentsDemo[[0, 5, 4, 0]] =  505 # =>  151875
     @exponentsDemo[[7, 5, 1, 0]] =  506 # =>  155520
     @exponentsDemo[[7, 0, 2, 2]] =  507 # =>  156800
     @exponentsDemo[[2, 2, 4, 1]] =  508 # =>  157500
     @exponentsDemo[[3, 4, 1, 2]] =  509 # =>  158760
     @exponentsDemo[[8, 0, 4, 0]] =  510 # =>  160000
     @exponentsDemo[[4, 4, 3, 0]] =  511 # =>  162000
     @exponentsDemo[[0, 3, 3, 2]] =  512 # =>  165375
     @exponentsDemo[[6, 1, 3, 1]] =  513 # =>  168000
     @exponentsDemo[[7, 3, 0, 2]] =  514 # =>  169344
     @exponentsDemo[[2, 5, 2, 1]] =  515 # =>  170100
     @exponentsDemo[[8, 3, 2, 0]] =  516 # =>  172800
     @exponentsDemo[[4, 2, 2, 2]] =  517 # =>  176400
     @exponentsDemo[[5, 2, 4, 0]] =  518 # =>  180000
     @exponentsDemo[[6, 4, 1, 1]] =  519 # =>  181440
     @exponentsDemo[[1, 1, 4, 2]] =  520 # =>  183750
     @exponentsDemo[[8, 1, 1, 2]] =  521 # =>  188160
     @exponentsDemo[[3, 3, 3, 1]] =  522 # =>  189000     STARTING MEDIUM
     @exponentsDemo[[4, 5, 0, 2]] =  523 # =>  190512
     @exponentsDemo[[5, 5, 2, 0]] =  524 # =>  194400
     @exponentsDemo[[5, 0, 3, 2]] =  525 # =>  196000
     @exponentsDemo[[1, 4, 2, 2]] =  526 # =>  198450
     @exponentsDemo[[7, 2, 2, 1]] =  527 # =>  201600
     @exponentsDemo[[2, 4, 4, 0]] =  528 # =>  202500
     @exponentsDemo[[4, 1, 4, 1]] =  529 # =>  210000
     @exponentsDemo[[5, 3, 1, 2]] =  530 # =>  211680
     @exponentsDemo[[0, 5, 3, 1]] =  531 # =>  212625
     @exponentsDemo[[6, 3, 3, 0]] =  532 # =>  216000
     @exponentsDemo[[7, 5, 0, 1]] =  533 # =>  217728
     @exponentsDemo[[2, 2, 3, 2]] =  534 # =>  220500
     @exponentsDemo[[8, 0, 3, 1]] =  535 # =>  224000
     @exponentsDemo[[4, 4, 2, 1]] =  536 # =>  226800
     @exponentsDemo[[6, 1, 2, 2]] =  537 # =>  235200
     @exponentsDemo[[1, 3, 4, 1]] =  538 # =>  236250
     @exponentsDemo[[2, 5, 1, 2]] =  539 # =>  238140
     @exponentsDemo[[7, 1, 4, 0]] =  540 # =>  240000
     @exponentsDemo[[8, 3, 1, 1]] =  541 # =>  241920
     @exponentsDemo[[3, 5, 3, 0]] =  542 # =>  243000
     @exponentsDemo[[3, 0, 4, 2]] =  543 # =>  245000
     @exponentsDemo[[5, 2, 3, 1]] =  544 # =>  252000
     @exponentsDemo[[6, 4, 0, 2]] =  545 # =>  254016
     @exponentsDemo[[7, 4, 2, 0]] =  546 # =>  259200
     @exponentsDemo[[3, 3, 2, 2]] =  547 # =>  264600
     @exponentsDemo[[4, 3, 4, 0]] =  548 # =>  270000
     @exponentsDemo[[5, 5, 1, 1]] =  549 # =>  272160
     @exponentsDemo[[0, 2, 4, 2]] =  550 # =>  275625
     @exponentsDemo[[6, 0, 4, 1]] =  551 # =>  280000
     @exponentsDemo[[7, 2, 1, 2]] =  552 # =>  282240
     @exponentsDemo[[2, 4, 3, 1]] =  553 # =>  283500
     @exponentsDemo[[8, 2, 3, 0]] =  554 # =>  288000
     @exponentsDemo[[4, 1, 3, 2]] =  555 # =>  294000
     @exponentsDemo[[0, 5, 2, 2]] =  556 # =>  297675
     @exponentsDemo[[6, 3, 2, 1]] =  557 # =>  302400
     @exponentsDemo[[1, 5, 4, 0]] =  558 # =>  303750
     @exponentsDemo[[8, 5, 1, 0]] =  559 # =>  311040
     @exponentsDemo[[8, 0, 2, 2]] =  560 # =>  313600
     @exponentsDemo[[3, 2, 4, 1]] =  561 # =>  315000
     @exponentsDemo[[4, 4, 1, 2]] =  562 # =>  317520
     @exponentsDemo[[5, 4, 3, 0]] =  563 # =>  324000
     @exponentsDemo[[1, 3, 3, 2]] =  564 # =>  330750
     @exponentsDemo[[7, 1, 3, 1]] =  565 # =>  336000
     @exponentsDemo[[8, 3, 0, 2]] =  566 # =>  338688
     @exponentsDemo[[3, 5, 2, 1]] =  567 # =>  340200
     @exponentsDemo[[5, 2, 2, 2]] =  568 # =>  352800   FINISH MEDIUM
     @exponentsDemo[[0, 4, 4, 1]] =  569 # =>  354375
     @exponentsDemo[[6, 2, 4, 0]] =  570 # =>  360000
     @exponentsDemo[[7, 4, 1, 1]] =  571 # =>  362880
     @exponentsDemo[[2, 1, 4, 2]] =  572 # =>  367500
     @exponentsDemo[[4, 3, 3, 1]] =  573 # =>  378000
     @exponentsDemo[[5, 5, 0, 2]] =  574 # =>  381024
     @exponentsDemo[[6, 5, 2, 0]] =  575 # =>  388800
     @exponentsDemo[[6, 0, 3, 2]] =  576 # =>  392000
     @exponentsDemo[[2, 4, 2, 2]] =  577 # =>  396900
     @exponentsDemo[[8, 2, 2, 1]] =  578 # =>  403200
     @exponentsDemo[[3, 4, 4, 0]] =  579 # =>  405000
     @exponentsDemo[[5, 1, 4, 1]] =  580 # =>  420000   STARTING LONG
     @exponentsDemo[[6, 3, 1, 2]] =  581 # =>  423360
     @exponentsDemo[[1, 5, 3, 1]] =  582 # =>  425250
     @exponentsDemo[[7, 3, 3, 0]] =  583 # =>  432000   
     @exponentsDemo[[8, 5, 0, 1]] =  584 # =>  435456
     @exponentsDemo[[3, 2, 3, 2]] =  585 # =>  441000
     @exponentsDemo[[5, 4, 2, 1]] =  586 # =>  453600
     @exponentsDemo[[7, 1, 2, 2]] =  587 # =>  470400
     @exponentsDemo[[2, 3, 4, 1]] =  588 # =>  472500
     @exponentsDemo[[3, 5, 1, 2]] =  589 # =>  476280
     @exponentsDemo[[8, 1, 4, 0]] =  590 # =>  480000
     @exponentsDemo[[4, 5, 3, 0]] =  591 # =>  486000
     @exponentsDemo[[4, 0, 4, 2]] =  592 # =>  490000
     @exponentsDemo[[0, 4, 3, 2]] =  593 # =>  496125
     @exponentsDemo[[6, 2, 3, 1]] =  594 # =>  504000
     @exponentsDemo[[7, 4, 0, 2]] =  595 # =>  508032
     @exponentsDemo[[8, 4, 2, 0]] =  596 # =>  518400
     @exponentsDemo[[4, 3, 2, 2]] =  597 # =>  529200
     @exponentsDemo[[5, 3, 4, 0]] =  598 # =>  540000
     @exponentsDemo[[6, 5, 1, 1]] =  599 # =>  544320
     @exponentsDemo[[1, 2, 4, 2]] =  600 # =>  551250
     @exponentsDemo[[7, 0, 4, 1]] =  601 # =>  560000
     @exponentsDemo[[8, 2, 1, 2]] =  602 # =>  564480
     @exponentsDemo[[3, 4, 3, 1]] =  603 # =>  567000
     @exponentsDemo[[5, 1, 3, 2]] =  604 # =>  588000
     @exponentsDemo[[1, 5, 2, 2]] =  605 # =>  595350
     @exponentsDemo[[7, 3, 2, 1]] =  606 # =>  604800
     @exponentsDemo[[2, 5, 4, 0]] =  607 # =>  607500 
     @exponentsDemo[[4, 2, 4, 1]] =  608 # =>  630000
     @exponentsDemo[[5, 4, 1, 2]] =  609 # =>  635040
     @exponentsDemo[[6, 4, 3, 0]] =  610 # =>  648000
     @exponentsDemo[[2, 3, 3, 2]] =  611 # =>  661500
     @exponentsDemo[[8, 1, 3, 1]] =  612 # =>  672000   FINISH LONG
     @exponentsDemo[[4, 5, 2, 1]] =  613 # =>  680400
     @exponentsDemo[[6, 2, 2, 2]] =  614 # =>  705600
     @exponentsDemo[[1, 4, 4, 1]] =  615 # =>  708750
     @exponentsDemo[[7, 2, 4, 0]] =  616 # =>  720000
     @exponentsDemo[[8, 4, 1, 1]] =  617 # =>  725760
     @exponentsDemo[[3, 1, 4, 2]] =  618 # =>  735000
     @exponentsDemo[[5, 3, 3, 1]] =  619 # =>  756000
     @exponentsDemo[[6, 5, 0, 2]] =  620 # =>  762048
     @exponentsDemo[[7, 5, 2, 0]] =  621 # =>  777600
     @exponentsDemo[[7, 0, 3, 2]] =  622 # =>  784000
     @exponentsDemo[[3, 4, 2, 2]] =  623 # =>  793800
     @exponentsDemo[[4, 4, 4, 0]] =  624 # =>  810000
     @exponentsDemo[[0, 3, 4, 2]] =  625 # =>  826875
     @exponentsDemo[[6, 1, 4, 1]] =  626 # =>  840000
     @exponentsDemo[[7, 3, 1, 2]] =  627 # =>  846720
     @exponentsDemo[[2, 5, 3, 1]] =  628 # =>  850500
     @exponentsDemo[[8, 3, 3, 0]] =  629 # =>  864000
     @exponentsDemo[[4, 2, 3, 2]] =  630 # =>  882000
     @exponentsDemo[[6, 4, 2, 1]] =  631 # =>  907200
     @exponentsDemo[[8, 1, 2, 2]] =  632 # =>  940800
     @exponentsDemo[[3, 3, 4, 1]] =  633 # =>  945000
     @exponentsDemo[[4, 5, 1, 2]] =  634 # =>  952560
     @exponentsDemo[[5, 5, 3, 0]] =  635 # =>  972000
     @exponentsDemo[[5, 0, 4, 2]] =  636 # =>  980000
     @exponentsDemo[[1, 4, 3, 2]] =  637 # =>  992250
     @exponentsDemo[[7, 2, 3, 1]] =  638 # =>  1008000
     @exponentsDemo[[8, 4, 0, 2]] =  639 # =>  1016064
     @exponentsDemo[[5, 3, 2, 2]] =  640 # =>  1058400
     @exponentsDemo[[0, 5, 4, 1]] =  641 # =>  1063125
     @exponentsDemo[[6, 3, 4, 0]] =  642 # =>  1080000
     @exponentsDemo[[7, 5, 1, 1]] =  643 # =>  1088640
     @exponentsDemo[[2, 2, 4, 2]] =  644 # =>  1102500
     @exponentsDemo[[8, 0, 4, 1]] =  645 # =>  1120000
     @exponentsDemo[[4, 4, 3, 1]] =  646 # =>  1134000
     @exponentsDemo[[6, 1, 3, 2]] =  647 # =>  1176000
     @exponentsDemo[[2, 5, 2, 2]] =  648 # =>  1190700
     @exponentsDemo[[8, 3, 2, 1]] =  649 # =>  1209600
     @exponentsDemo[[3, 5, 4, 0]] =  650 # =>  1215000
     @exponentsDemo[[5, 2, 4, 1]] =  651 # =>  1260000
     @exponentsDemo[[6, 4, 1, 2]] =  652 # =>  1270080
     @exponentsDemo[[7, 4, 3, 0]] =  653 # =>  1296000
     @exponentsDemo[[3, 3, 3, 2]] =  654 # =>  1323000
     @exponentsDemo[[5, 5, 2, 1]] =  655 # =>  1360800
     @exponentsDemo[[7, 2, 2, 2]] =  656 # =>  1411200
     @exponentsDemo[[2, 4, 4, 1]] =  657 # =>  1417500
     @exponentsDemo[[8, 2, 4, 0]] =  658 # =>  1440000
     @exponentsDemo[[4, 1, 4, 2]] =  659 # =>  1470000
     @exponentsDemo[[0, 5, 3, 2]] =  660 # =>  1488375
     @exponentsDemo[[6, 3, 3, 1]] =  661 # =>  1512000
     @exponentsDemo[[7, 5, 0, 2]] =  662 # =>  1524096
     @exponentsDemo[[8, 5, 2, 0]] =  663 # =>  1555200
     @exponentsDemo[[8, 0, 3, 2]] =  664 # =>  1568000
     @exponentsDemo[[4, 4, 2, 2]] =  665 # =>  1587600
     @exponentsDemo[[5, 4, 4, 0]] =  666 # =>  1620000
     @exponentsDemo[[1, 3, 4, 2]] =  667 # =>  1653750
     @exponentsDemo[[7, 1, 4, 1]] =  668 # =>  1680000
     @exponentsDemo[[8, 3, 1, 2]] =  669 # =>  1693440
     @exponentsDemo[[3, 5, 3, 1]] =  670 # =>  1701000
     @exponentsDemo[[5, 2, 3, 2]] =  671 # =>  1764000
     @exponentsDemo[[7, 4, 2, 1]] =  672 # =>  1814400
     @exponentsDemo[[4, 3, 4, 1]] =  673 # =>  1890000
     @exponentsDemo[[5, 5, 1, 2]] =  674 # =>  1905120
     @exponentsDemo[[6, 5, 3, 0]] =  675 # =>  1944000
     @exponentsDemo[[6, 0, 4, 2]] =  676 # =>  1960000
     @exponentsDemo[[2, 4, 3, 2]] =  677 # =>  1984500
     @exponentsDemo[[8, 2, 3, 1]] =  678 # =>  2016000
     @exponentsDemo[[6, 3, 2, 2]] =  679 # =>  2116800
     @exponentsDemo[[1, 5, 4, 1]] =  680 # =>  2126250
     @exponentsDemo[[7, 3, 4, 0]] =  681 # =>  2160000
     @exponentsDemo[[8, 5, 1, 1]] =  682 # =>  2177280
     @exponentsDemo[[3, 2, 4, 2]] =  683 # =>  2205000
     @exponentsDemo[[5, 4, 3, 1]] =  684 # =>  2268000
     @exponentsDemo[[7, 1, 3, 2]] =  685 # =>  2352000
     @exponentsDemo[[3, 5, 2, 2]] =  686 # =>  2381400
     @exponentsDemo[[4, 5, 4, 0]] =  687 # =>  2430000
     @exponentsDemo[[0, 4, 4, 2]] =  688 # =>  2480625
     @exponentsDemo[[6, 2, 4, 1]] =  689 # =>  2520000
     @exponentsDemo[[7, 4, 1, 2]] =  690 # =>  2540160
     @exponentsDemo[[8, 4, 3, 0]] =  691 # =>  2592000
     @exponentsDemo[[4, 3, 3, 2]] =  692 # =>  2646000
     @exponentsDemo[[6, 5, 2, 1]] =  693 # =>  2721600
     @exponentsDemo[[8, 2, 2, 2]] =  694 # =>  2822400
     @exponentsDemo[[3, 4, 4, 1]] =  695 # =>  2835000
     @exponentsDemo[[5, 1, 4, 2]] =  696 # =>  2940000
     @exponentsDemo[[1, 5, 3, 2]] =  697 # =>  2976750
     @exponentsDemo[[7, 3, 3, 1]] =  698 # =>  3024000
     @exponentsDemo[[8, 5, 0, 2]] =  699 # =>  3048192
     @exponentsDemo[[5, 4, 2, 2]] =  700 # =>  3175200
     @exponentsDemo[[6, 4, 4, 0]] =  701 # =>  3240000
     @exponentsDemo[[2, 3, 4, 2]] =  702 # =>  3307500
     @exponentsDemo[[8, 1, 4, 1]] =  703 # =>  3360000
     @exponentsDemo[[4, 5, 3, 1]] =  704 # =>  3402000
     @exponentsDemo[[6, 2, 3, 2]] =  705 # =>  3528000
     @exponentsDemo[[8, 4, 2, 1]] =  706 # =>  3628800
     @exponentsDemo[[5, 3, 4, 1]] =  707 # =>  3780000
     @exponentsDemo[[6, 5, 1, 2]] =  708 # =>  3810240
     @exponentsDemo[[7, 5, 3, 0]] =  709 # =>  3888000
     @exponentsDemo[[7, 0, 4, 2]] =  710 # =>  3920000
     @exponentsDemo[[3, 4, 3, 2]] =  711 # =>  3969000
     @exponentsDemo[[7, 3, 2, 2]] =  712 # =>  4233600
     @exponentsDemo[[2, 5, 4, 1]] =  713 # =>  4252500
     @exponentsDemo[[8, 3, 4, 0]] =  714 # =>  4320000
     @exponentsDemo[[4, 2, 4, 2]] =  715 # =>  4410000
     @exponentsDemo[[6, 4, 3, 1]] =  716 # =>  4536000
     @exponentsDemo[[8, 1, 3, 2]] =  717 # =>  4704000
     @exponentsDemo[[4, 5, 2, 2]] =  718 # =>  4762800
     @exponentsDemo[[5, 5, 4, 0]] =  719 # =>  4860000
     @exponentsDemo[[1, 4, 4, 2]] =  720 # =>  4961250
     @exponentsDemo[[7, 2, 4, 1]] =  721 # =>  5040000
     @exponentsDemo[[8, 4, 1, 2]] =  722 # =>  5080320
     @exponentsDemo[[5, 3, 3, 2]] =  723 # =>  5292000
     @exponentsDemo[[7, 5, 2, 1]] =  724 # =>  5443200
     @exponentsDemo[[4, 4, 4, 1]] =  725 # =>  5670000
     @exponentsDemo[[6, 1, 4, 2]] =  726 # =>  5880000
     @exponentsDemo[[2, 5, 3, 2]] =  727 # =>  5953500
     @exponentsDemo[[8, 3, 3, 1]] =  728 # =>  6048000
     @exponentsDemo[[6, 4, 2, 2]] =  729 # =>  6350400
     @exponentsDemo[[7, 4, 4, 0]] =  730 # =>  6480000
     @exponentsDemo[[3, 3, 4, 2]] =  731 # =>  6615000
     @exponentsDemo[[5, 5, 3, 1]] =  732 # =>  6804000
     @exponentsDemo[[7, 2, 3, 2]] =  733 # =>  7056000
     @exponentsDemo[[0, 5, 4, 2]] =  734 # =>  7441875
     @exponentsDemo[[6, 3, 4, 1]] =  735 # =>  7560000
     @exponentsDemo[[7, 5, 1, 2]] =  736 # =>  7620480
     @exponentsDemo[[8, 5, 3, 0]] =  737 # =>  7776000
     @exponentsDemo[[8, 0, 4, 2]] =  738 # =>  7840000
     @exponentsDemo[[4, 4, 3, 2]] =  739 # =>  7938000
     @exponentsDemo[[8, 3, 2, 2]] =  740 # =>  8467200
     @exponentsDemo[[3, 5, 4, 1]] =  741 # =>  8505000
     @exponentsDemo[[5, 2, 4, 2]] =  742 # =>  8820000
     @exponentsDemo[[7, 4, 3, 1]] =  743 # =>  9072000
     @exponentsDemo[[5, 5, 2, 2]] =  744 # =>  9525600
     @exponentsDemo[[6, 5, 4, 0]] =  745 # =>  9720000
     @exponentsDemo[[2, 4, 4, 2]] =  746 # =>  9922500
     @exponentsDemo[[8, 2, 4, 1]] =  747 # =>  10080000
     @exponentsDemo[[6, 3, 3, 2]] =  748 # =>  10584000
     @exponentsDemo[[8, 5, 2, 1]] =  749 # =>  10886400
     @exponentsDemo[[5, 4, 4, 1]] =  750 # =>  11340000
     @exponentsDemo[[7, 1, 4, 2]] =  751 # =>  11760000
     @exponentsDemo[[3, 5, 3, 2]] =  752 # =>  11907000
     @exponentsDemo[[7, 4, 2, 2]] =  753 # =>  12700800
     @exponentsDemo[[8, 4, 4, 0]] =  754 # =>  12960000
     @exponentsDemo[[4, 3, 4, 2]] =  755 # =>  13230000
     @exponentsDemo[[6, 5, 3, 1]] =  756 # =>  13608000
     @exponentsDemo[[8, 2, 3, 2]] =  757 # =>  14112000
     @exponentsDemo[[1, 5, 4, 2]] =  758 # =>  14883750
     @exponentsDemo[[7, 3, 4, 1]] =  759 # =>  15120000
     @exponentsDemo[[8, 5, 1, 2]] =  760 # =>  15240960
     @exponentsDemo[[5, 4, 3, 2]] =  761 # =>  15876000
     @exponentsDemo[[4, 5, 4, 1]] =  762 # =>  17010000
     @exponentsDemo[[6, 2, 4, 2]] =  763 # =>  17640000
     @exponentsDemo[[8, 4, 3, 1]] =  764 # =>  18144000
     @exponentsDemo[[6, 5, 2, 2]] =  765 # =>  19051200
     @exponentsDemo[[7, 5, 4, 0]] =  766 # =>  19440000
     @exponentsDemo[[3, 4, 4, 2]] =  767 # =>  19845000
     @exponentsDemo[[7, 3, 3, 2]] =  768 # =>  21168000
     @exponentsDemo[[6, 4, 4, 1]] =  769 # =>  22680000
     @exponentsDemo[[8, 1, 4, 2]] =  770 # =>  23520000
     @exponentsDemo[[4, 5, 3, 2]] =  771 # =>  23814000
     @exponentsDemo[[8, 4, 2, 2]] =  772 # =>  25401600
     @exponentsDemo[[5, 3, 4, 2]] =  773 # =>  26460000
     @exponentsDemo[[7, 5, 3, 1]] =  774 # =>  27216000
     @exponentsDemo[[2, 5, 4, 2]] =  775 # =>  29767500
     @exponentsDemo[[8, 3, 4, 1]] =  776 # =>  30240000
     @exponentsDemo[[6, 4, 3, 2]] =  777 # =>  31752000
     @exponentsDemo[[5, 5, 4, 1]] =  778 # =>  34020000
     @exponentsDemo[[7, 2, 4, 2]] =  779 # =>  35280000
     @exponentsDemo[[7, 5, 2, 2]] =  780 # =>  38102400
     @exponentsDemo[[8, 5, 4, 0]] =  781 # =>  38880000
     @exponentsDemo[[4, 4, 4, 2]] =  782 # =>  39690000
     @exponentsDemo[[8, 3, 3, 2]] =  783 # =>  42336000
     @exponentsDemo[[7, 4, 4, 1]] =  784 # =>  45360000
     @exponentsDemo[[5, 5, 3, 2]] =  785 # =>  47628000
     @exponentsDemo[[6, 3, 4, 2]] =  786 # =>  52920000
     @exponentsDemo[[8, 5, 3, 1]] =  787 # =>  54432000
     @exponentsDemo[[3, 5, 4, 2]] =  788 # =>  59535000
     @exponentsDemo[[7, 4, 3, 2]] =  789 # =>  63504000
     @exponentsDemo[[6, 5, 4, 1]] =  790 # =>  68040000
     @exponentsDemo[[8, 2, 4, 2]] =  791 # =>  70560000
     @exponentsDemo[[8, 5, 2, 2]] =  792 # =>  76204800
     @exponentsDemo[[5, 4, 4, 2]] =  793 # =>  79380000
     @exponentsDemo[[8, 4, 4, 1]] =  794 # =>  90720000
     @exponentsDemo[[6, 5, 3, 2]] =  795 # =>  95256000
     @exponentsDemo[[7, 3, 4, 2]] =  796 # =>  105840000
     @exponentsDemo[[4, 5, 4, 2]] =  797 # =>  119070000
     @exponentsDemo[[8, 4, 3, 2]] =  798 # =>  127008000
     @exponentsDemo[[7, 5, 4, 1]] =  799 # =>  136080000
     @exponentsDemo[[6, 4, 4, 2]] =  800 # =>  158760000
     @exponentsDemo[[7, 5, 3, 2]] =  801 # =>  190512000
     @exponentsDemo[[8, 3, 4, 2]] =  802 # =>  211680000
     @exponentsDemo[[5, 5, 4, 2]] =  803 # =>  238140000
     @exponentsDemo[[8, 5, 4, 1]] =  804 # =>  272160000
     @exponentsDemo[[7, 4, 4, 2]] =  805 # =>  317520000
     @exponentsDemo[[8, 5, 3, 2]] =  806 # =>  381024000
     @exponentsDemo[[6, 5, 4, 2]] =  807 # =>  476280000
     @exponentsDemo[[8, 4, 4, 2]] =  808 # =>  635040000
     @exponentsDemo[[7, 5, 4, 2]] =  809 # =>  952560000
     @exponentsDemo[[8, 5, 4, 2]] =  810 # =>  1905120000

      
     
   end
end
