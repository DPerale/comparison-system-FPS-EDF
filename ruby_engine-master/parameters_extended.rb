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
      @short_period_demo_mixed = 278..430  # 274..310 #   6.350.400 -->  17.781.120
      @mid_period_demo_mixed   = 489..529  # 321..345 #  24.696.000 -->  66.679.200
      @long_period_demo_mixed  = 540..568 # 361..374 # 166.698.000 --> 800.150.400

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
      
      @short_impl_exec_range   =  120..210  # 120..210   
      @mid_impl_exec_range     =  2200..3900 # 2200..3900 
      @long_impl_exec_range    =  5200..7200 # 5200..7200 

      @short_constr_exec_range =   1000..2500    #   10000..25000
      @mid_constr_exec_range   =  10000..25000   #  100000..250000
      @long_constr_exec_range  = 100000..250000  # 1000000..2500000

      #########################################
      ##    TASK NUMS   (183 Tasks Limit)    ##
      #########################################

      ## 1) Short, Mid & Long to Reach 100%
      @short_num_task_range_1    = 16..18    # bell 50 tasks low 25 high 75
      @mid_num_task_range_1      = 16..18    #
      @long_num_task_range_1     = 16..18    #

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
     @exponentsDemo[[1, 3, 1, 0]] =  77  # =>  270 
     @exponentsDemo[[3, 0, 1, 1]] =  78  # =>  280 
     @exponentsDemo[[5, 2, 0, 0]] =  79  # =>  288 
     @exponentsDemo[[1, 1, 0, 2]] =  80  # =>  294 
     @exponentsDemo[[2, 1, 2, 0]] =  81  # =>  300 
     @exponentsDemo[[0, 2, 1, 1]] =  82  # =>  315 
     @exponentsDemo[[6, 0, 1, 0]] =  83  # =>  320 
     @exponentsDemo[[2, 4, 0, 0]] =  84  # =>  324 
     @exponentsDemo[[4, 1, 0, 1]] =  85  # =>  336 
     @exponentsDemo[[1, 0, 2, 1]] =  86  # =>  350 
     @exponentsDemo[[3, 2, 1, 0]] =  87  # =>  360 
     @exponentsDemo[[0, 1, 3, 0]] =  88  # =>  375 
     @exponentsDemo[[1, 3, 0, 1]] =  89  # =>  378 
     @exponentsDemo[[7, 1, 0, 0]] =  90  # =>  384 
     @exponentsDemo[[3, 0, 0, 2]] =  91  # =>  392 
     @exponentsDemo[[4, 0, 2, 0]] =  92  # =>  400 
     @exponentsDemo[[0, 4, 1, 0]] =  93  # =>  405 
     @exponentsDemo[[2, 1, 1, 1]] =  94  # =>  420 
     @exponentsDemo[[4, 3, 0, 0]] =  95  # =>  432 
     @exponentsDemo[[0, 2, 0, 2]] =  96  # =>  441 
     @exponentsDemo[[6, 0, 0, 1]] =  97  # =>  448 
     @exponentsDemo[[1, 2, 2, 0]] =  98  # =>  450 
     @exponentsDemo[[5, 1, 1, 0]] =  99  # =>  480 
     @exponentsDemo[[1, 5, 0, 0]] =  100 # =>  486 
     @exponentsDemo[[1, 0, 1, 2]] =  101 # =>  490 
     @exponentsDemo[[2, 0, 3, 0]] =  102 # =>  500 
     @exponentsDemo[[3, 2, 0, 1]] =  103 # =>  504 
     @exponentsDemo[[0, 1, 2, 1]] =  104 # =>  525 
     @exponentsDemo[[2, 3, 1, 0]] =  105 # =>  540 
     @exponentsDemo[[4, 0, 1, 1]] =  106 # =>  560 
     @exponentsDemo[[0, 4, 0, 1]] =  107 # =>  567 
     @exponentsDemo[[6, 2, 0, 0]] =  108 # =>  576 
     @exponentsDemo[[2, 1, 0, 2]] =  109 # =>  588 
     @exponentsDemo[[3, 1, 2, 0]] =  110 # =>  600 
     @exponentsDemo[[0, 0, 4, 0]] =  111 # =>  625 
     @exponentsDemo[[1, 2, 1, 1]] =  112 # =>  630 
     @exponentsDemo[[7, 0, 1, 0]] =  113 # =>  640 
     @exponentsDemo[[3, 4, 0, 0]] =  114 # =>  648 
     @exponentsDemo[[5, 1, 0, 1]] =  115 # =>  672 
     @exponentsDemo[[0, 3, 2, 0]] =  116 # =>  675 
     @exponentsDemo[[2, 0, 2, 1]] =  117 # =>  700 
     @exponentsDemo[[4, 2, 1, 0]] =  118 # =>  720 
     @exponentsDemo[[0, 1, 1, 2]] =  119 # =>  735 
     @exponentsDemo[[1, 1, 3, 0]] =  120 # =>  750 
     @exponentsDemo[[2, 3, 0, 1]] =  121 # =>  756 
     @exponentsDemo[[4, 0, 0, 2]] =  122 # =>  784 
     @exponentsDemo[[5, 0, 2, 0]] =  123 # =>  800 
     @exponentsDemo[[1, 4, 1, 0]] =  124 # =>  810 
     @exponentsDemo[[3, 1, 1, 1]] =  125 # =>  840 
     @exponentsDemo[[5, 3, 0, 0]] =  126 # =>  864 
     @exponentsDemo[[0, 0, 3, 1]] =  127 # =>  875 
     @exponentsDemo[[1, 2, 0, 2]] =  128 # =>  882 
     @exponentsDemo[[7, 0, 0, 1]] =  129 # =>  896 
     @exponentsDemo[[2, 2, 2, 0]] =  130 # =>  900 
     @exponentsDemo[[0, 3, 1, 1]] =  131 # =>  945 
     @exponentsDemo[[6, 1, 1, 0]] =  132 # =>  960 
     @exponentsDemo[[2, 5, 0, 0]] =  133 # =>  972 
     @exponentsDemo[[2, 0, 1, 2]] =  134 # =>  980 
     @exponentsDemo[[3, 0, 3, 0]] =  135 # =>  1000  
     @exponentsDemo[[4, 2, 0, 1]] =  136 # =>  1008  
     @exponentsDemo[[1, 1, 2, 1]] =  137 # =>  1050  
     @exponentsDemo[[3, 3, 1, 0]] =  138 # =>  1080  
     @exponentsDemo[[5, 0, 1, 1]] =  139 # =>  1120  
     @exponentsDemo[[0, 2, 3, 0]] =  140 # =>  1125  
     @exponentsDemo[[1, 4, 0, 1]] =  141 # =>  1134  
     @exponentsDemo[[7, 2, 0, 0]] =  142 # =>  1152  
     @exponentsDemo[[3, 1, 0, 2]] =  143 # =>  1176  
     @exponentsDemo[[4, 1, 2, 0]] =  144 # =>  1200  
     @exponentsDemo[[0, 5, 1, 0]] =  145 # =>  1215  
     @exponentsDemo[[0, 0, 2, 2]] =  146 # =>  1225  
     @exponentsDemo[[1, 0, 4, 0]] =  147 # =>  1250  
     @exponentsDemo[[2, 2, 1, 1]] =  148 # =>  1260  
     @exponentsDemo[[4, 4, 0, 0]] =  149 # =>  1296  
     @exponentsDemo[[0, 3, 0, 2]] =  150 # =>  1323  
     @exponentsDemo[[6, 1, 0, 1]] =  151 # =>  1344  
     @exponentsDemo[[1, 3, 2, 0]] =  152 # =>  1350  
     @exponentsDemo[[3, 0, 2, 1]] =  153 # =>  1400  
     @exponentsDemo[[5, 2, 1, 0]] =  154 # =>  1440  
     @exponentsDemo[[1, 1, 1, 2]] =  155 # =>  1470  
     @exponentsDemo[[2, 1, 3, 0]] =  156 # =>  1500  
     @exponentsDemo[[3, 3, 0, 1]] =  157 # =>  1512  
     @exponentsDemo[[5, 0, 0, 2]] =  158 # =>  1568  
     @exponentsDemo[[0, 2, 2, 1]] =  159 # =>  1575  
     @exponentsDemo[[6, 0, 2, 0]] =  160 # =>  1600  
     @exponentsDemo[[2, 4, 1, 0]] =  161 # =>  1620  
     @exponentsDemo[[4, 1, 1, 1]] =  162 # =>  1680  
     @exponentsDemo[[0, 5, 0, 1]] =  163 # =>  1701  
     @exponentsDemo[[6, 3, 0, 0]] =  164 # =>  1728  
     @exponentsDemo[[1, 0, 3, 1]] =  165 # =>  1750  
     @exponentsDemo[[2, 2, 0, 2]] =  166 # =>  1764  
     @exponentsDemo[[3, 2, 2, 0]] =  167 # =>  1800  
     @exponentsDemo[[0, 1, 4, 0]] =  168 # =>  1875  
     @exponentsDemo[[1, 3, 1, 1]] =  169 # =>  1890  
     @exponentsDemo[[7, 1, 1, 0]] =  170 # =>  1920  
     @exponentsDemo[[3, 5, 0, 0]] =  171 # =>  1944  
     @exponentsDemo[[3, 0, 1, 2]] =  172 # =>  1960  
     @exponentsDemo[[4, 0, 3, 0]] =  173 # =>  2000  
     @exponentsDemo[[5, 2, 0, 1]] =  174 # =>  2016  
     @exponentsDemo[[0, 4, 2, 0]] =  175 # =>  2025  
     @exponentsDemo[[2, 1, 2, 1]] =  176 # =>  2100  
     @exponentsDemo[[4, 3, 1, 0]] =  177 # =>  2160  
     @exponentsDemo[[0, 2, 1, 2]] =  178 # =>  2205  
     @exponentsDemo[[6, 0, 1, 1]] =  179 # =>  2240  
     @exponentsDemo[[1, 2, 3, 0]] =  180 # =>  2250  
     @exponentsDemo[[2, 4, 0, 1]] =  181 # =>  2268  
     @exponentsDemo[[4, 1, 0, 2]] =  182 # =>  2352  
     @exponentsDemo[[5, 1, 2, 0]] =  183 # =>  2400  
     @exponentsDemo[[1, 5, 1, 0]] =  184 # =>  2430  
     @exponentsDemo[[1, 0, 2, 2]] =  185 # =>  2450  
     @exponentsDemo[[2, 0, 4, 0]] =  186 # =>  2500  
     @exponentsDemo[[3, 2, 1, 1]] =  187 # =>  2520  
     @exponentsDemo[[5, 4, 0, 0]] =  188 # =>  2592  
     @exponentsDemo[[0, 1, 3, 1]] =  189 # =>  2625  
     @exponentsDemo[[1, 3, 0, 2]] =  190 # =>  2646  
     @exponentsDemo[[7, 1, 0, 1]] =  191 # =>  2688  
     @exponentsDemo[[2, 3, 2, 0]] =  192 # =>  2700  
     @exponentsDemo[[4, 0, 2, 1]] =  193 # =>  2800  
     @exponentsDemo[[0, 4, 1, 1]] =  194 # =>  2835  
     @exponentsDemo[[6, 2, 1, 0]] =  195 # =>  2880  
     @exponentsDemo[[2, 1, 1, 2]] =  196 # =>  2940  
     @exponentsDemo[[3, 1, 3, 0]] =  197 # =>  3000  
     @exponentsDemo[[4, 3, 0, 1]] =  198 # =>  3024  
     @exponentsDemo[[6, 0, 0, 2]] =  199 # =>  3136  
     @exponentsDemo[[1, 2, 2, 1]] =  200 # =>  3150  
     @exponentsDemo[[7, 0, 2, 0]] =  201 # =>  3200  
     @exponentsDemo[[3, 4, 1, 0]] =  202 # =>  3240  
     @exponentsDemo[[5, 1, 1, 1]] =  203 # =>  3360  
     @exponentsDemo[[0, 3, 3, 0]] =  204 # =>  3375  
     @exponentsDemo[[1, 5, 0, 1]] =  205 # =>  3402  
     @exponentsDemo[[7, 3, 0, 0]] =  206 # =>  3456  
     @exponentsDemo[[2, 0, 3, 1]] =  207 # =>  3500  
     @exponentsDemo[[3, 2, 0, 2]] =  208 # =>  3528  
     @exponentsDemo[[4, 2, 2, 0]] =  209 # =>  3600  
     @exponentsDemo[[0, 1, 2, 2]] =  210 # =>  3675  
     @exponentsDemo[[1, 1, 4, 0]] =  211 # =>  3750  
     @exponentsDemo[[2, 3, 1, 1]] =  212 # =>  3780  
     @exponentsDemo[[4, 5, 0, 0]] =  213 # =>  3888  
     @exponentsDemo[[4, 0, 1, 2]] =  214 # =>  3920  
     @exponentsDemo[[0, 4, 0, 2]] =  215 # =>  3969  
     @exponentsDemo[[5, 0, 3, 0]] =  216 # =>  4000  
     @exponentsDemo[[6, 2, 0, 1]] =  217 # =>  4032  
     @exponentsDemo[[1, 4, 2, 0]] =  218 # =>  4050  
     @exponentsDemo[[3, 1, 2, 1]] =  219 # =>  4200  
     @exponentsDemo[[5, 3, 1, 0]] =  220 # =>  4320  
     @exponentsDemo[[0, 0, 4, 1]] =  221 # =>  4375  
     @exponentsDemo[[1, 2, 1, 2]] =  222 # =>  4410  
     @exponentsDemo[[7, 0, 1, 1]] =  223 # =>  4480  
     @exponentsDemo[[2, 2, 3, 0]] =  224 # =>  4500  
     @exponentsDemo[[3, 4, 0, 1]] =  225 # =>  4536  
     @exponentsDemo[[5, 1, 0, 2]] =  226 # =>  4704  
     @exponentsDemo[[0, 3, 2, 1]] =  227 # =>  4725  
     @exponentsDemo[[6, 1, 2, 0]] =  228 # =>  4800  
     @exponentsDemo[[2, 5, 1, 0]] =  229 # =>  4860  
     @exponentsDemo[[2, 0, 2, 2]] =  230 # =>  4900  
     @exponentsDemo[[3, 0, 4, 0]] =  231 # =>  5000  
     @exponentsDemo[[4, 2, 1, 1]] =  232 # =>  5040  
     @exponentsDemo[[6, 4, 0, 0]] =  233 # =>  5184  
     @exponentsDemo[[1, 1, 3, 1]] =  234 # =>  5250  
     @exponentsDemo[[2, 3, 0, 2]] =  235 # =>  5292  
     @exponentsDemo[[3, 3, 2, 0]] =  236 # =>  5400  
     @exponentsDemo[[5, 0, 2, 1]] =  237 # =>  5600  
     @exponentsDemo[[0, 2, 4, 0]] =  238 # =>  5625  
     @exponentsDemo[[1, 4, 1, 1]] =  239 # =>  5670  
     @exponentsDemo[[7, 2, 1, 0]] =  240 # =>  5760  
     @exponentsDemo[[3, 1, 1, 2]] =  241 # =>  5880  
     @exponentsDemo[[4, 1, 3, 0]] =  242 # =>  6000  
     @exponentsDemo[[5, 3, 0, 1]] =  243 # =>  6048  
     @exponentsDemo[[0, 5, 2, 0]] =  244 # =>  6075  
     @exponentsDemo[[0, 0, 3, 2]] =  245 # =>  6125  
     @exponentsDemo[[7, 0, 0, 2]] =  246 # =>  6272  
     @exponentsDemo[[2, 2, 2, 1]] =  247 # =>  6300  
     @exponentsDemo[[4, 4, 1, 0]] =  248 # =>  6480  
     @exponentsDemo[[0, 3, 1, 2]] =  249 # =>  6615  
     @exponentsDemo[[6, 1, 1, 1]] =  250 # =>  6720  
     @exponentsDemo[[1, 3, 3, 0]] =  251 # =>  6750  
     @exponentsDemo[[2, 5, 0, 1]] =  252 # =>  6804  
     @exponentsDemo[[3, 0, 3, 1]] =  253 # =>  7000  
     @exponentsDemo[[4, 2, 0, 2]] =  254 # =>  7056  
     @exponentsDemo[[5, 2, 2, 0]] =  255 # =>  7200  
     @exponentsDemo[[1, 1, 2, 2]] =  256 # =>  7350  
     @exponentsDemo[[2, 1, 4, 0]] =  257 # =>  7500  
     @exponentsDemo[[3, 3, 1, 1]] =  258 # =>  7560  
     @exponentsDemo[[5, 5, 0, 0]] =  259 # =>  7776  
     @exponentsDemo[[5, 0, 1, 2]] =  260 # =>  7840  
     @exponentsDemo[[0, 2, 3, 1]] =  261 # =>  7875  
     @exponentsDemo[[1, 4, 0, 2]] =  262 # =>  7938  
     @exponentsDemo[[6, 0, 3, 0]] =  263 # =>  8000  
     @exponentsDemo[[7, 2, 0, 1]] =  264 # =>  8064  
     @exponentsDemo[[2, 4, 2, 0]] =  265 # =>  8100  
     @exponentsDemo[[4, 1, 2, 1]] =  266 # =>  8400  
     @exponentsDemo[[0, 5, 1, 1]] =  267 # =>  8505  
     @exponentsDemo[[6, 3, 1, 0]] =  268 # =>  8640  
     @exponentsDemo[[1, 0, 4, 1]] =  269 # =>  8750  
     @exponentsDemo[[2, 2, 1, 2]] =  270 # =>  8820  
     @exponentsDemo[[3, 2, 3, 0]] =  271 # =>  9000  
     @exponentsDemo[[4, 4, 0, 1]] =  272 # =>  9072  
     @exponentsDemo[[6, 1, 0, 2]] =  273 # =>  9408  
     @exponentsDemo[[1, 3, 2, 1]] =  274 # =>  9450  
     @exponentsDemo[[7, 1, 2, 0]] =  275 # =>  9600  
     @exponentsDemo[[3, 5, 1, 0]] =  276 # =>  9720  
     @exponentsDemo[[3, 0, 2, 2]] =  277 # =>  9800  
     @exponentsDemo[[4, 0, 4, 0]] =  278 # =>  10000 STARTING SHORTS
     @exponentsDemo[[5, 2, 1, 1]] =  279 # =>  10080 
     @exponentsDemo[[0, 4, 3, 0]] =  280 # =>  10125 
     @exponentsDemo[[7, 4, 0, 0]] =  281 # =>  10368 
     @exponentsDemo[[2, 1, 3, 1]] =  282 # =>  10500 
     @exponentsDemo[[3, 3, 0, 2]] =  283 # =>  10584 
     @exponentsDemo[[4, 3, 2, 0]] =  284 # =>  10800 
     @exponentsDemo[[0, 2, 2, 2]] =  285 # =>  11025 
     @exponentsDemo[[6, 0, 2, 1]] =  286 # =>  11200 
     @exponentsDemo[[1, 2, 4, 0]] =  287 # =>  11250 
     @exponentsDemo[[2, 4, 1, 1]] =  288 # =>  11340 
     @exponentsDemo[[4, 1, 1, 2]] =  289 # =>  11760 
     @exponentsDemo[[0, 5, 0, 2]] =  290 # =>  11907 
     @exponentsDemo[[5, 1, 3, 0]] =  291 # =>  12000 
     @exponentsDemo[[6, 3, 0, 1]] =  292 # =>  12096 
     @exponentsDemo[[1, 5, 2, 0]] =  293 # =>  12150 
     @exponentsDemo[[1, 0, 3, 2]] =  294 # =>  12250 
     @exponentsDemo[[3, 2, 2, 1]] =  295 # =>  12600 
     @exponentsDemo[[5, 4, 1, 0]] =  296 # =>  12960 
     @exponentsDemo[[0, 1, 4, 1]] =  297 # =>  13125 
     @exponentsDemo[[1, 3, 1, 2]] =  298 # =>  13230 
     @exponentsDemo[[7, 1, 1, 1]] =  299 # =>  13440 
     @exponentsDemo[[2, 3, 3, 0]] =  300 # =>  13500 
     @exponentsDemo[[3, 5, 0, 1]] =  301 # =>  13608 
     @exponentsDemo[[4, 0, 3, 1]] =  302 # =>  14000 
     @exponentsDemo[[5, 2, 0, 2]] =  303 # =>  14112 
     @exponentsDemo[[0, 4, 2, 1]] =  304 # =>  14175 
     @exponentsDemo[[6, 2, 2, 0]] =  305 # =>  14400 
     @exponentsDemo[[2, 1, 2, 2]] =  306 # =>  14700 
     @exponentsDemo[[3, 1, 4, 0]] =  307 # =>  15000 
     @exponentsDemo[[4, 3, 1, 1]] =  308 # =>  15120 
     @exponentsDemo[[6, 5, 0, 0]] =  309 # =>  15552 
     @exponentsDemo[[6, 0, 1, 2]] =  310 # =>  15680 
     @exponentsDemo[[1, 2, 3, 1]] =  311 # =>  15750 
     @exponentsDemo[[2, 4, 0, 2]] =  312 # =>  15876 
     @exponentsDemo[[7, 0, 3, 0]] =  313 # =>  16000 
     @exponentsDemo[[3, 4, 2, 0]] =  314 # =>  16200 
     @exponentsDemo[[5, 1, 2, 1]] =  315 # =>  16800 
     @exponentsDemo[[0, 3, 4, 0]] =  316 # =>  16875 
     @exponentsDemo[[1, 5, 1, 1]] =  317 # =>  17010 
     @exponentsDemo[[7, 3, 1, 0]] =  318 # =>  17280 
     @exponentsDemo[[2, 0, 4, 1]] =  319 # =>  17500 
     @exponentsDemo[[3, 2, 1, 2]] =  320 # =>  17640 
     @exponentsDemo[[4, 2, 3, 0]] =  321 # =>  18000 
     @exponentsDemo[[5, 4, 0, 1]] =  322 # =>  18144 
     @exponentsDemo[[0, 1, 3, 2]] =  323 # =>  18375 
     @exponentsDemo[[7, 1, 0, 2]] =  324 # =>  18816 
     @exponentsDemo[[2, 3, 2, 1]] =  325 # =>  18900 
     @exponentsDemo[[4, 5, 1, 0]] =  326 # =>  19440 
     @exponentsDemo[[4, 0, 2, 2]] =  327 # =>  19600 
     @exponentsDemo[[0, 4, 1, 2]] =  328 # =>  19845 
     @exponentsDemo[[5, 0, 4, 0]] =  329 # =>  20000 
     @exponentsDemo[[6, 2, 1, 1]] =  330 # =>  20160 
     @exponentsDemo[[1, 4, 3, 0]] =  331 # =>  20250 
     @exponentsDemo[[3, 1, 3, 1]] =  332 # =>  21000 
     @exponentsDemo[[4, 3, 0, 2]] =  333 # =>  21168 
     @exponentsDemo[[5, 3, 2, 0]] =  334 # =>  21600 
     @exponentsDemo[[1, 2, 2, 2]] =  335 # =>  22050 
     @exponentsDemo[[7, 0, 2, 1]] =  336 # =>  22400 
     @exponentsDemo[[2, 2, 4, 0]] =  337 # =>  22500 
     @exponentsDemo[[3, 4, 1, 1]] =  338 # =>  22680 
     @exponentsDemo[[5, 1, 1, 2]] =  339 # =>  23520 
     @exponentsDemo[[0, 3, 3, 1]] =  340 # =>  23625 
     @exponentsDemo[[1, 5, 0, 2]] =  341 # =>  23814 
     @exponentsDemo[[6, 1, 3, 0]] =  342 # =>  24000 
     @exponentsDemo[[7, 3, 0, 1]] =  343 # =>  24192 
     @exponentsDemo[[2, 5, 2, 0]] =  344 # =>  24300 
     @exponentsDemo[[2, 0, 3, 2]] =  345 # =>  24500 
     @exponentsDemo[[4, 2, 2, 1]] =  346 # =>  25200 
     @exponentsDemo[[6, 4, 1, 0]] =  347 # =>  25920 
     @exponentsDemo[[1, 1, 4, 1]] =  348 # =>  26250 
     @exponentsDemo[[2, 3, 1, 2]] =  349 # =>  26460 
     @exponentsDemo[[3, 3, 3, 0]] =  350 # =>  27000 
     @exponentsDemo[[4, 5, 0, 1]] =  351 # =>  27216 
     @exponentsDemo[[5, 0, 3, 1]] =  352 # =>  28000 
     @exponentsDemo[[6, 2, 0, 2]] =  353 # =>  28224 
     @exponentsDemo[[1, 4, 2, 1]] =  354 # =>  28350 
     @exponentsDemo[[7, 2, 2, 0]] =  355 # =>  28800 
     @exponentsDemo[[3, 1, 2, 2]] =  356 # =>  29400 
     @exponentsDemo[[4, 1, 4, 0]] =  357 # =>  30000 
     @exponentsDemo[[5, 3, 1, 1]] =  358 # =>  30240 
     @exponentsDemo[[0, 5, 3, 0]] =  359 # =>  30375 
     @exponentsDemo[[0, 0, 4, 2]] =  360 # =>  30625 
     @exponentsDemo[[7, 5, 0, 0]] =  361 # =>  31104 
     @exponentsDemo[[7, 0, 1, 2]] =  362 # =>  31360 
     @exponentsDemo[[2, 2, 3, 1]] =  363 # =>  31500 
     @exponentsDemo[[3, 4, 0, 2]] =  364 # =>  31752 
     @exponentsDemo[[4, 4, 2, 0]] =  365 # =>  32400 
     @exponentsDemo[[0, 3, 2, 2]] =  366 # =>  33075 
     @exponentsDemo[[6, 1, 2, 1]] =  367 # =>  33600 
     @exponentsDemo[[1, 3, 4, 0]] =  368 # =>  33750 
     @exponentsDemo[[2, 5, 1, 1]] =  369 # =>  34020 
     @exponentsDemo[[3, 0, 4, 1]] =  370 # =>  35000 
     @exponentsDemo[[4, 2, 1, 2]] =  371 # =>  35280 
     @exponentsDemo[[5, 2, 3, 0]] =  372 # =>  36000 
     @exponentsDemo[[6, 4, 0, 1]] =  373 # =>  36288 
     @exponentsDemo[[1, 1, 3, 2]] =  374 # =>  36750 
     @exponentsDemo[[3, 3, 2, 1]] =  375 # =>  37800 
     @exponentsDemo[[5, 5, 1, 0]] =  376 # =>  38880 
     @exponentsDemo[[5, 0, 2, 2]] =  377 # =>  39200 
     @exponentsDemo[[0, 2, 4, 1]] =  378 # =>  39375 
     @exponentsDemo[[1, 4, 1, 2]] =  379 # =>  39690 
     @exponentsDemo[[6, 0, 4, 0]] =  380 # =>  40000 
     @exponentsDemo[[7, 2, 1, 1]] =  381 # =>  40320 
     @exponentsDemo[[2, 4, 3, 0]] =  382 # =>  40500 
     @exponentsDemo[[4, 1, 3, 1]] =  383 # =>  42000 
     @exponentsDemo[[5, 3, 0, 2]] =  384 # =>  42336 
     @exponentsDemo[[0, 5, 2, 1]] =  385 # =>  42525 
     @exponentsDemo[[6, 3, 2, 0]] =  386 # =>  43200 
     @exponentsDemo[[2, 2, 2, 2]] =  387 # =>  44100 
     @exponentsDemo[[3, 2, 4, 0]] =  388 # =>  45000 
     @exponentsDemo[[4, 4, 1, 1]] =  389 # =>  45360 
     @exponentsDemo[[6, 1, 1, 2]] =  390 # =>  47040 
     @exponentsDemo[[1, 3, 3, 1]] =  391 # =>  47250 
     @exponentsDemo[[2, 5, 0, 2]] =  392 # =>  47628 
     @exponentsDemo[[7, 1, 3, 0]] =  393 # =>  48000 
     @exponentsDemo[[3, 5, 2, 0]] =  394 # =>  48600 
     @exponentsDemo[[3, 0, 3, 2]] =  395 # =>  49000 
     @exponentsDemo[[5, 2, 2, 1]] =  396 # =>  50400 
     @exponentsDemo[[0, 4, 4, 0]] =  397 # =>  50625 
     @exponentsDemo[[7, 4, 1, 0]] =  398 # =>  51840 
     @exponentsDemo[[2, 1, 4, 1]] =  399 # =>  52500 
     @exponentsDemo[[3, 3, 1, 2]] =  400 # =>  52920 
     @exponentsDemo[[4, 3, 3, 0]] =  401 # =>  54000 
     @exponentsDemo[[5, 5, 0, 1]] =  402 # =>  54432 
     @exponentsDemo[[0, 2, 3, 2]] =  403 # =>  55125 
     @exponentsDemo[[6, 0, 3, 1]] =  404 # =>  56000 
     @exponentsDemo[[7, 2, 0, 2]] =  405 # =>  56448 
     @exponentsDemo[[2, 4, 2, 1]] =  406 # =>  56700 
     @exponentsDemo[[4, 1, 2, 2]] =  407 # =>  58800 
     @exponentsDemo[[0, 5, 1, 2]] =  408 # =>  59535 
     @exponentsDemo[[5, 1, 4, 0]] =  409 # =>  60000 
     @exponentsDemo[[6, 3, 1, 1]] =  410 # =>  60480 
     @exponentsDemo[[1, 5, 3, 0]] =  411 # =>  60750 
     @exponentsDemo[[1, 0, 4, 2]] =  412 # =>  61250 
     @exponentsDemo[[3, 2, 3, 1]] =  413 # =>  63000 
     @exponentsDemo[[4, 4, 0, 2]] =  414 # =>  63504 
     @exponentsDemo[[5, 4, 2, 0]] =  415 # =>  64800 
     @exponentsDemo[[1, 3, 2, 2]] =  416 # =>  66150 
     @exponentsDemo[[7, 1, 2, 1]] =  417 # =>  67200 
     @exponentsDemo[[2, 3, 4, 0]] =  418 # =>  67500 
     @exponentsDemo[[3, 5, 1, 1]] =  419 # =>  68040 
     @exponentsDemo[[4, 0, 4, 1]] =  420 # =>  70000 
     @exponentsDemo[[5, 2, 1, 2]] =  421 # =>  70560 
     @exponentsDemo[[0, 4, 3, 1]] =  422 # =>  70875 
     @exponentsDemo[[6, 2, 3, 0]] =  423 # =>  72000 
     @exponentsDemo[[7, 4, 0, 1]] =  424 # =>  72576 
     @exponentsDemo[[2, 1, 3, 2]] =  425 # =>  73500 
     @exponentsDemo[[4, 3, 2, 1]] =  426 # =>  75600 
     @exponentsDemo[[6, 5, 1, 0]] =  427 # =>  77760 
     @exponentsDemo[[6, 0, 2, 2]] =  428 # =>  78400 
     @exponentsDemo[[1, 2, 4, 1]] =  429 # =>  78750 
     @exponentsDemo[[2, 4, 1, 2]] =  430 # =>  79380 FINISH SHORTS
     @exponentsDemo[[7, 0, 4, 0]] =  431 # =>  80000 
     @exponentsDemo[[3, 4, 3, 0]] =  432 # =>  81000 
     @exponentsDemo[[5, 1, 3, 1]] =  433 # =>  84000 
     @exponentsDemo[[6, 3, 0, 2]] =  434 # =>  84672 
     @exponentsDemo[[1, 5, 2, 1]] =  435 # =>  85050 
     @exponentsDemo[[7, 3, 2, 0]] =  436 # =>  86400 
     @exponentsDemo[[3, 2, 2, 2]] =  437 # =>  88200 
     @exponentsDemo[[4, 2, 4, 0]] =  438 # =>  90000 
     @exponentsDemo[[5, 4, 1, 1]] =  439 # =>  90720 
     @exponentsDemo[[0, 1, 4, 2]] =  440 # =>  91875 
     @exponentsDemo[[7, 1, 1, 2]] =  441 # =>  94080 
     @exponentsDemo[[2, 3, 3, 1]] =  442 # =>  94500 
     @exponentsDemo[[3, 5, 0, 2]] =  443 # =>  95256 
     @exponentsDemo[[4, 5, 2, 0]] =  444 # =>  97200 
     @exponentsDemo[[4, 0, 3, 2]] =  445 # =>  98000 
     @exponentsDemo[[0, 4, 2, 2]] =  446 # =>  99225 
     @exponentsDemo[[6, 2, 2, 1]] =  447 # =>  100800  
     @exponentsDemo[[1, 4, 4, 0]] =  448 # =>  101250  
     @exponentsDemo[[3, 1, 4, 1]] =  449 # =>  105000  
     @exponentsDemo[[4, 3, 1, 2]] =  450 # =>  105840  
     @exponentsDemo[[5, 3, 3, 0]] =  451 # =>  108000  
     @exponentsDemo[[6, 5, 0, 1]] =  452 # =>  108864  
     @exponentsDemo[[1, 2, 3, 2]] =  453 # =>  110250  
     @exponentsDemo[[7, 0, 3, 1]] =  454 # =>  112000  
     @exponentsDemo[[3, 4, 2, 1]] =  455 # =>  113400  
     @exponentsDemo[[5, 1, 2, 2]] =  456 # =>  117600  
     @exponentsDemo[[0, 3, 4, 1]] =  457 # =>  118125  
     @exponentsDemo[[1, 5, 1, 2]] =  458 # =>  119070  
     @exponentsDemo[[6, 1, 4, 0]] =  459 # =>  120000  
     @exponentsDemo[[7, 3, 1, 1]] =  460 # =>  120960  
     @exponentsDemo[[2, 5, 3, 0]] =  461 # =>  121500  
     @exponentsDemo[[2, 0, 4, 2]] =  462 # =>  122500  
     @exponentsDemo[[4, 2, 3, 1]] =  463 # =>  126000  
     @exponentsDemo[[5, 4, 0, 2]] =  464 # =>  127008  
     @exponentsDemo[[6, 4, 2, 0]] =  465 # =>  129600  
     @exponentsDemo[[2, 3, 2, 2]] =  466 # =>  132300  
     @exponentsDemo[[3, 3, 4, 0]] =  467 # =>  135000  
     @exponentsDemo[[4, 5, 1, 1]] =  468 # =>  136080  
     @exponentsDemo[[5, 0, 4, 1]] =  469 # =>  140000  
     @exponentsDemo[[6, 2, 1, 2]] =  470 # =>  141120  
     @exponentsDemo[[1, 4, 3, 1]] =  471 # =>  141750  
     @exponentsDemo[[7, 2, 3, 0]] =  472 # =>  144000  
     @exponentsDemo[[3, 1, 3, 2]] =  473 # =>  147000  
     @exponentsDemo[[5, 3, 2, 1]] =  474 # =>  151200  
     @exponentsDemo[[0, 5, 4, 0]] =  475 # =>  151875  
     @exponentsDemo[[7, 5, 1, 0]] =  476 # =>  155520  
     @exponentsDemo[[7, 0, 2, 2]] =  477 # =>  156800  
     @exponentsDemo[[2, 2, 4, 1]] =  478 # =>  157500  
     @exponentsDemo[[3, 4, 1, 2]] =  479 # =>  158760  
     @exponentsDemo[[4, 4, 3, 0]] =  480 # =>  162000  
     @exponentsDemo[[0, 3, 3, 2]] =  481 # =>  165375  
     @exponentsDemo[[6, 1, 3, 1]] =  482 # =>  168000  
     @exponentsDemo[[7, 3, 0, 2]] =  483 # =>  169344  
     @exponentsDemo[[2, 5, 2, 1]] =  484 # =>  170100  
     @exponentsDemo[[4, 2, 2, 2]] =  485 # =>  176400  
     @exponentsDemo[[5, 2, 4, 0]] =  486 # =>  180000  
     @exponentsDemo[[6, 4, 1, 1]] =  487 # =>  181440  
     @exponentsDemo[[1, 1, 4, 2]] =  488 # =>  183750  
     @exponentsDemo[[3, 3, 3, 1]] =  489 # =>  189000  STARTING MEDIUM
     @exponentsDemo[[4, 5, 0, 2]] =  490 # =>  190512  
     @exponentsDemo[[5, 5, 2, 0]] =  491 # =>  194400  
     @exponentsDemo[[5, 0, 3, 2]] =  492 # =>  196000  
     @exponentsDemo[[1, 4, 2, 2]] =  493 # =>  198450  
     @exponentsDemo[[7, 2, 2, 1]] =  494 # =>  201600  
     @exponentsDemo[[2, 4, 4, 0]] =  495 # =>  202500  
     @exponentsDemo[[4, 1, 4, 1]] =  496 # =>  210000  
     @exponentsDemo[[5, 3, 1, 2]] =  497 # =>  211680  
     @exponentsDemo[[0, 5, 3, 1]] =  498 # =>  212625  
     @exponentsDemo[[6, 3, 3, 0]] =  499 # =>  216000  
     @exponentsDemo[[7, 5, 0, 1]] =  500 # =>  217728  
     @exponentsDemo[[2, 2, 3, 2]] =  501 # =>  220500  
     @exponentsDemo[[4, 4, 2, 1]] =  502 # =>  226800  
     @exponentsDemo[[6, 1, 2, 2]] =  503 # =>  235200  
     @exponentsDemo[[1, 3, 4, 1]] =  504 # =>  236250  
     @exponentsDemo[[2, 5, 1, 2]] =  505 # =>  238140  
     @exponentsDemo[[7, 1, 4, 0]] =  506 # =>  240000  
     @exponentsDemo[[3, 5, 3, 0]] =  507 # =>  243000  
     @exponentsDemo[[3, 0, 4, 2]] =  508 # =>  245000  
     @exponentsDemo[[5, 2, 3, 1]] =  509 # =>  252000  
     @exponentsDemo[[6, 4, 0, 2]] =  510 # =>  254016  
     @exponentsDemo[[7, 4, 2, 0]] =  511 # =>  259200  
     @exponentsDemo[[3, 3, 2, 2]] =  512 # =>  264600  
     @exponentsDemo[[4, 3, 4, 0]] =  513 # =>  270000  
     @exponentsDemo[[5, 5, 1, 1]] =  514 # =>  272160  
     @exponentsDemo[[0, 2, 4, 2]] =  515 # =>  275625  
     @exponentsDemo[[6, 0, 4, 1]] =  516 # =>  280000  
     @exponentsDemo[[7, 2, 1, 2]] =  517 # =>  282240  
     @exponentsDemo[[2, 4, 3, 1]] =  518 # =>  283500  
     @exponentsDemo[[4, 1, 3, 2]] =  519 # =>  294000  
     @exponentsDemo[[0, 5, 2, 2]] =  520 # =>  297675  
     @exponentsDemo[[6, 3, 2, 1]] =  521 # =>  302400  
     @exponentsDemo[[1, 5, 4, 0]] =  522 # =>  303750  
     @exponentsDemo[[3, 2, 4, 1]] =  523 # =>  315000  
     @exponentsDemo[[4, 4, 1, 2]] =  524 # =>  317520  
     @exponentsDemo[[5, 4, 3, 0]] =  525 # =>  324000  
     @exponentsDemo[[1, 3, 3, 2]] =  526 # =>  330750  
     @exponentsDemo[[7, 1, 3, 1]] =  527 # =>  336000  
     @exponentsDemo[[3, 5, 2, 1]] =  528 # =>  340200  
     @exponentsDemo[[5, 2, 2, 2]] =  529 # =>  352800  FINISH MEDIUM
     @exponentsDemo[[0, 4, 4, 1]] =  530 # =>  354375  
     @exponentsDemo[[6, 2, 4, 0]] =  531 # =>  360000  
     @exponentsDemo[[7, 4, 1, 1]] =  532 # =>  362880  
     @exponentsDemo[[2, 1, 4, 2]] =  533 # =>  367500  
     @exponentsDemo[[4, 3, 3, 1]] =  534 # =>  378000  
     @exponentsDemo[[5, 5, 0, 2]] =  535 # =>  381024  
     @exponentsDemo[[6, 5, 2, 0]] =  536 # =>  388800  
     @exponentsDemo[[6, 0, 3, 2]] =  537 # =>  392000  
     @exponentsDemo[[2, 4, 2, 2]] =  538 # =>  396900  
     @exponentsDemo[[3, 4, 4, 0]] =  539 # =>  405000  
     @exponentsDemo[[5, 1, 4, 1]] =  540 # =>  420000  STARTING LONG
     @exponentsDemo[[6, 3, 1, 2]] =  541 # =>  423360  
     @exponentsDemo[[1, 5, 3, 1]] =  542 # =>  425250  
     @exponentsDemo[[7, 3, 3, 0]] =  543 # =>  432000  
     @exponentsDemo[[3, 2, 3, 2]] =  544 # =>  441000  
     @exponentsDemo[[5, 4, 2, 1]] =  545 # =>  453600  
     @exponentsDemo[[7, 1, 2, 2]] =  546 # =>  470400  
     @exponentsDemo[[2, 3, 4, 1]] =  547 # =>  472500  
     @exponentsDemo[[3, 5, 1, 2]] =  548 # =>  476280  
     @exponentsDemo[[4, 5, 3, 0]] =  549 # =>  486000  
     @exponentsDemo[[4, 0, 4, 2]] =  550 # =>  490000  
     @exponentsDemo[[0, 4, 3, 2]] =  551 # =>  496125  
     @exponentsDemo[[6, 2, 3, 1]] =  552 # =>  504000  
     @exponentsDemo[[7, 4, 0, 2]] =  553 # =>  508032  
     @exponentsDemo[[4, 3, 2, 2]] =  554 # =>  529200  
     @exponentsDemo[[5, 3, 4, 0]] =  555 # =>  540000  
     @exponentsDemo[[6, 5, 1, 1]] =  556 # =>  544320  
     @exponentsDemo[[1, 2, 4, 2]] =  557 # =>  551250  
     @exponentsDemo[[7, 0, 4, 1]] =  558 # =>  560000  
     @exponentsDemo[[3, 4, 3, 1]] =  559 # =>  567000  
     @exponentsDemo[[5, 1, 3, 2]] =  560 # =>  588000  
     @exponentsDemo[[1, 5, 2, 2]] =  561 # =>  595350  
     @exponentsDemo[[7, 3, 2, 1]] =  562 # =>  604800  
     @exponentsDemo[[2, 5, 4, 0]] =  563 # =>  607500  
     @exponentsDemo[[4, 2, 4, 1]] =  564 # =>  630000  
     @exponentsDemo[[5, 4, 1, 2]] =  565 # =>  635040  
     @exponentsDemo[[6, 4, 3, 0]] =  566 # =>  648000  
     @exponentsDemo[[2, 3, 3, 2]] =  567 # =>  661500  
     @exponentsDemo[[4, 5, 2, 1]] =  568 # =>  680400  FINISH LONG
     @exponentsDemo[[6, 2, 2, 2]] =  569 # =>  705600  
     @exponentsDemo[[1, 4, 4, 1]] =  570 # =>  708750  
     @exponentsDemo[[7, 2, 4, 0]] =  571 # =>  720000  
     @exponentsDemo[[3, 1, 4, 2]] =  572 # =>  735000  
     @exponentsDemo[[5, 3, 3, 1]] =  573 # =>  756000  
     @exponentsDemo[[6, 5, 0, 2]] =  574 # =>  762048  
     @exponentsDemo[[7, 5, 2, 0]] =  575 # =>  777600  
     @exponentsDemo[[7, 0, 3, 2]] =  576 # =>  784000  
     @exponentsDemo[[3, 4, 2, 2]] =  577 # =>  793800  
     @exponentsDemo[[4, 4, 4, 0]] =  578 # =>  810000  
     @exponentsDemo[[0, 3, 4, 2]] =  579 # =>  826875  
     @exponentsDemo[[6, 1, 4, 1]] =  580 # =>  840000  
     @exponentsDemo[[7, 3, 1, 2]] =  581 # =>  846720  
     @exponentsDemo[[2, 5, 3, 1]] =  582 # =>  850500  
     @exponentsDemo[[4, 2, 3, 2]] =  583 # =>  882000  
     @exponentsDemo[[6, 4, 2, 1]] =  584 # =>  907200  
     @exponentsDemo[[3, 3, 4, 1]] =  585 # =>  945000  
     @exponentsDemo[[4, 5, 1, 2]] =  586 # =>  952560  
     @exponentsDemo[[5, 5, 3, 0]] =  587 # =>  972000  
     @exponentsDemo[[5, 0, 4, 2]] =  588 # =>  980000  
     @exponentsDemo[[1, 4, 3, 2]] =  589 # =>  992250  
     @exponentsDemo[[7, 2, 3, 1]] =  590 # =>  1008000 
     @exponentsDemo[[5, 3, 2, 2]] =  591 # =>  1058400 
     @exponentsDemo[[0, 5, 4, 1]] =  592 # =>  1063125 
     @exponentsDemo[[6, 3, 4, 0]] =  593 # =>  1080000 
     @exponentsDemo[[7, 5, 1, 1]] =  594 # =>  1088640 
     @exponentsDemo[[2, 2, 4, 2]] =  595 # =>  1102500 
     @exponentsDemo[[4, 4, 3, 1]] =  596 # =>  1134000 
     @exponentsDemo[[6, 1, 3, 2]] =  597 # =>  1176000 
     @exponentsDemo[[2, 5, 2, 2]] =  598 # =>  1190700 
     @exponentsDemo[[3, 5, 4, 0]] =  599 # =>  1215000 
     @exponentsDemo[[5, 2, 4, 1]] =  600 # =>  1260000 
     @exponentsDemo[[6, 4, 1, 2]] =  601 # =>  1270080 
     @exponentsDemo[[7, 4, 3, 0]] =  602 # =>  1296000 
     @exponentsDemo[[3, 3, 3, 2]] =  603 # =>  1323000 
     @exponentsDemo[[5, 5, 2, 1]] =  604 # =>  1360800 
     @exponentsDemo[[7, 2, 2, 2]] =  605 # =>  1411200 
     @exponentsDemo[[2, 4, 4, 1]] =  606 # =>  1417500 
     @exponentsDemo[[4, 1, 4, 2]] =  607 # =>  1470000 
     @exponentsDemo[[0, 5, 3, 2]] =  608 # =>  1488375 
     @exponentsDemo[[6, 3, 3, 1]] =  609 # =>  1512000 
     @exponentsDemo[[7, 5, 0, 2]] =  610 # =>  1524096 
     @exponentsDemo[[4, 4, 2, 2]] =  611 # =>  1587600 
     @exponentsDemo[[5, 4, 4, 0]] =  612 # =>  1620000 
     @exponentsDemo[[1, 3, 4, 2]] =  613 # =>  1653750 
     @exponentsDemo[[7, 1, 4, 1]] =  614 # =>  1680000 
     @exponentsDemo[[3, 5, 3, 1]] =  615 # =>  1701000 
     @exponentsDemo[[5, 2, 3, 2]] =  616 # =>  1764000 
     @exponentsDemo[[7, 4, 2, 1]] =  617 # =>  1814400 
     @exponentsDemo[[4, 3, 4, 1]] =  618 # =>  1890000 
     @exponentsDemo[[5, 5, 1, 2]] =  619 # =>  1905120 
     @exponentsDemo[[6, 5, 3, 0]] =  620 # =>  1944000 
     @exponentsDemo[[6, 0, 4, 2]] =  621 # =>  1960000 
     @exponentsDemo[[2, 4, 3, 2]] =  622 # =>  1984500 
     @exponentsDemo[[6, 3, 2, 2]] =  623 # =>  2116800 
     @exponentsDemo[[1, 5, 4, 1]] =  624 # =>  2126250 
     @exponentsDemo[[7, 3, 4, 0]] =  625 # =>  2160000 
     @exponentsDemo[[3, 2, 4, 2]] =  626 # =>  2205000 
     @exponentsDemo[[5, 4, 3, 1]] =  627 # =>  2268000 
     @exponentsDemo[[7, 1, 3, 2]] =  628 # =>  2352000 
     @exponentsDemo[[3, 5, 2, 2]] =  629 # =>  2381400 
     @exponentsDemo[[4, 5, 4, 0]] =  630 # =>  2430000 
     @exponentsDemo[[0, 4, 4, 2]] =  631 # =>  2480625 
     @exponentsDemo[[6, 2, 4, 1]] =  632 # =>  2520000 
     @exponentsDemo[[7, 4, 1, 2]] =  633 # =>  2540160 
     @exponentsDemo[[4, 3, 3, 2]] =  634 # =>  2646000 
     @exponentsDemo[[6, 5, 2, 1]] =  635 # =>  2721600 
     @exponentsDemo[[3, 4, 4, 1]] =  636 # =>  2835000 
     @exponentsDemo[[5, 1, 4, 2]] =  637 # =>  2940000 
     @exponentsDemo[[1, 5, 3, 2]] =  638 # =>  2976750 
     @exponentsDemo[[7, 3, 3, 1]] =  639 # =>  3024000 
     @exponentsDemo[[5, 4, 2, 2]] =  640 # =>  3175200 
     @exponentsDemo[[6, 4, 4, 0]] =  641 # =>  3240000 
     @exponentsDemo[[2, 3, 4, 2]] =  642 # =>  3307500 
     @exponentsDemo[[4, 5, 3, 1]] =  643 # =>  3402000 
     @exponentsDemo[[6, 2, 3, 2]] =  644 # =>  3528000 
     @exponentsDemo[[5, 3, 4, 1]] =  645 # =>  3780000 
     @exponentsDemo[[6, 5, 1, 2]] =  646 # =>  3810240 
     @exponentsDemo[[7, 5, 3, 0]] =  647 # =>  3888000 
     @exponentsDemo[[7, 0, 4, 2]] =  648 # =>  3920000 
     @exponentsDemo[[3, 4, 3, 2]] =  649 # =>  3969000 
     @exponentsDemo[[7, 3, 2, 2]] =  650 # =>  4233600 
     @exponentsDemo[[2, 5, 4, 1]] =  651 # =>  4252500 
     @exponentsDemo[[4, 2, 4, 2]] =  652 # =>  4410000 
     @exponentsDemo[[6, 4, 3, 1]] =  653 # =>  4536000 
     @exponentsDemo[[4, 5, 2, 2]] =  654 # =>  4762800 
     @exponentsDemo[[5, 5, 4, 0]] =  655 # =>  4860000 
     @exponentsDemo[[1, 4, 4, 2]] =  656 # =>  4961250 
     @exponentsDemo[[7, 2, 4, 1]] =  657 # =>  5040000 
     @exponentsDemo[[5, 3, 3, 2]] =  658 # =>  5292000 
     @exponentsDemo[[7, 5, 2, 1]] =  659 # =>  5443200 
     @exponentsDemo[[4, 4, 4, 1]] =  660 # =>  5670000 
     @exponentsDemo[[6, 1, 4, 2]] =  661 # =>  5880000 
     @exponentsDemo[[2, 5, 3, 2]] =  662 # =>  5953500 
     @exponentsDemo[[6, 4, 2, 2]] =  663 # =>  6350400 
     @exponentsDemo[[7, 4, 4, 0]] =  664 # =>  6480000 
     @exponentsDemo[[3, 3, 4, 2]] =  665 # =>  6615000 
     @exponentsDemo[[5, 5, 3, 1]] =  666 # =>  6804000 
     @exponentsDemo[[7, 2, 3, 2]] =  667 # =>  7056000 
     @exponentsDemo[[0, 5, 4, 2]] =  668 # =>  7441875 
     @exponentsDemo[[6, 3, 4, 1]] =  669 # =>  7560000 
     @exponentsDemo[[7, 5, 1, 2]] =  670 # =>  7620480 
     @exponentsDemo[[4, 4, 3, 2]] =  671 # =>  7938000 
     @exponentsDemo[[3, 5, 4, 1]] =  672 # =>  8505000 
     @exponentsDemo[[5, 2, 4, 2]] =  673 # =>  8820000 
     @exponentsDemo[[7, 4, 3, 1]] =  674 # =>  9072000 
     @exponentsDemo[[5, 5, 2, 2]] =  675 # =>  9525600 
     @exponentsDemo[[6, 5, 4, 0]] =  676 # =>  9720000 
     @exponentsDemo[[2, 4, 4, 2]] =  677 # =>  9922500 
     @exponentsDemo[[6, 3, 3, 2]] =  678 # =>  10584000  
     @exponentsDemo[[5, 4, 4, 1]] =  679 # =>  11340000  
     @exponentsDemo[[7, 1, 4, 2]] =  680 # =>  11760000  
     @exponentsDemo[[3, 5, 3, 2]] =  681 # =>  11907000  
     @exponentsDemo[[7, 4, 2, 2]] =  682 # =>  12700800  
     @exponentsDemo[[4, 3, 4, 2]] =  683 # =>  13230000  
     @exponentsDemo[[6, 5, 3, 1]] =  684 # =>  13608000  
     @exponentsDemo[[1, 5, 4, 2]] =  685 # =>  14883750  
     @exponentsDemo[[7, 3, 4, 1]] =  686 # =>  15120000  
     @exponentsDemo[[5, 4, 3, 2]] =  687 # =>  15876000  
     @exponentsDemo[[4, 5, 4, 1]] =  688 # =>  17010000  
     @exponentsDemo[[6, 2, 4, 2]] =  689 # =>  17640000  
     @exponentsDemo[[6, 5, 2, 2]] =  690 # =>  19051200  
     @exponentsDemo[[7, 5, 4, 0]] =  691 # =>  19440000  
     @exponentsDemo[[3, 4, 4, 2]] =  692 # =>  19845000  
     @exponentsDemo[[7, 3, 3, 2]] =  693 # =>  21168000  
     @exponentsDemo[[6, 4, 4, 1]] =  694 # =>  22680000  
     @exponentsDemo[[4, 5, 3, 2]] =  695 # =>  23814000  
     @exponentsDemo[[5, 3, 4, 2]] =  696 # =>  26460000  
     @exponentsDemo[[7, 5, 3, 1]] =  697 # =>  27216000  
     @exponentsDemo[[2, 5, 4, 2]] =  698 # =>  29767500  
     @exponentsDemo[[6, 4, 3, 2]] =  699 # =>  31752000  
     @exponentsDemo[[5, 5, 4, 1]] =  700 # =>  34020000  
     @exponentsDemo[[7, 2, 4, 2]] =  701 # =>  35280000  
     @exponentsDemo[[7, 5, 2, 2]] =  702 # =>  38102400  
     @exponentsDemo[[4, 4, 4, 2]] =  703 # =>  39690000  
     @exponentsDemo[[7, 4, 4, 1]] =  704 # =>  45360000  
     @exponentsDemo[[5, 5, 3, 2]] =  705 # =>  47628000  
     @exponentsDemo[[6, 3, 4, 2]] =  706 # =>  52920000  
     @exponentsDemo[[3, 5, 4, 2]] =  707 # =>  59535000  
     @exponentsDemo[[7, 4, 3, 2]] =  708 # =>  63504000  
     @exponentsDemo[[6, 5, 4, 1]] =  709 # =>  68040000  
     @exponentsDemo[[5, 4, 4, 2]] =  710 # =>  79380000  
     @exponentsDemo[[6, 5, 3, 2]] =  711 # =>  95256000  
     @exponentsDemo[[7, 3, 4, 2]] =  712 # =>  105840000 
     @exponentsDemo[[4, 5, 4, 2]] =  713 # =>  119070000 
     @exponentsDemo[[7, 5, 4, 1]] =  714 # =>  136080000 
     @exponentsDemo[[6, 4, 4, 2]] =  715 # =>  158760000 
     @exponentsDemo[[7, 5, 3, 2]] =  716 # =>  190512000 
     @exponentsDemo[[5, 5, 4, 2]] =  717 # =>  238140000 
     @exponentsDemo[[7, 4, 4, 2]] =  718 # =>  317520000 
     @exponentsDemo[[6, 5, 4, 2]] =  719 # =>  476280000 
     @exponentsDemo[[7, 5, 4, 2]] =  720 # =>  952560000 

      
     
   end
end
