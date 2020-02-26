high_utilization = 0.045
low_priority = 15
taskset_0_2 = array (integer(), dim = c(5,1000,10))

for (i in 1:500){
  file_name <- paste("../taskset-experiments/U_90_hyper_113400000_0_2_armonic_10_100/U_90_hyper_113400000_0_2_armonic_10_100_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  print(i)

  dimensions = 0
  for (l in 1:20){
    dimensions <- dimensions + ((file_to_open[21,3]/file_to_open[l,3]))
  }
  list_of_wake_up = array(integer(), dim = c(dimensions))
  armonicity_number = 0
  counter = 1
  for (l in 1:20){
    temp = file_to_open[l,3]
    while (temp < file_to_open [21,3]){
      list_of_wake_up [counter] <- temp
      temp <- temp + file_to_open[l,3]
      counter <- counter + 1
    }
  }
  armonicity_number <- length(list_of_wake_up) - length(unique(list_of_wake_up))
  
  sumperiod = 0
  for (l in 20:1){
    sumperiod = sumperiod + strtoi(file_to_open[l,3])
  }
  tn = 0
  if (strtoi(file_to_open[21,8]) <= 10000){
    tn = 1
  }
  if (strtoi(file_to_open[21,8]) > 10000 & strtoi(file_to_open[21,8]) <= 15000){
    tn = 2
  }
  if (strtoi(file_to_open[21,8]) > 15000 & strtoi(file_to_open[21,8]) <= 20000){
    tn = 3
  }
  if (strtoi(file_to_open[21,8]) > 20000 & strtoi(file_to_open[21,8]) <= 25000){
    tn = 4
  }
  if (strtoi(file_to_open[21,8]) > 25000){
    tn = 5
  }
  taskset_0_2 [tn,i,1]  <- file_to_open[21,8]
  taskset_0_2 [tn,i,2]  <- file_to_open[21,12]
  taskset_0_2 [tn,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
  taskset_0_2 [tn,i,4]  <- i
  taskset_0_2 [tn,i,5]  <- sumperiod/20
  taskset_0_2 [tn,i,6] <- armonicity_number
  taskset_0_2 [tn,i,7] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
  taskset_0_2 [tn,i,8] <- (armonicity_number / dimensions)
  taskset_0_2 [tn,i,9] <- file_to_open[21,3]
  taskset_0_2 [tn,i,10] <- counter
}



taskset_3_6 = array (integer(), dim = c(5,1000,10))

for (i in 1:500){
  file_name <- paste("../taskset-experiments/U_90_hyper_113400000_3_6_armonic_10_100/U_90_hyper_113400000_3_6_armonic_10_100_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  print(i)
  
  dimensions = 0
  for (l in 1:20){
    dimensions <- dimensions + ((file_to_open[21,3]/file_to_open[l,3]))
  }
  list_of_wake_up = array(integer(), dim = c(dimensions))
  armonicity_number = 0
  counter = 1
  for (l in 1:20){
    temp = file_to_open[l,3]
    while (temp < file_to_open [21,3]){
      list_of_wake_up [counter] <- temp
      temp <- temp + file_to_open[l,3]
      counter <- counter + 1
    }
  }
  armonicity_number <- length(list_of_wake_up) - length(unique(list_of_wake_up))
  
  sumperiod = 0
  for (l in 20:1){
    sumperiod = sumperiod + strtoi(file_to_open[l,3])
  }
  tn = 0
  if (strtoi(file_to_open[21,8]) <= 10000){
    tn = 1
  }
  if (strtoi(file_to_open[21,8]) > 10000 & strtoi(file_to_open[21,8]) <= 15000){
    tn = 2
  }
  if (strtoi(file_to_open[21,8]) > 15000 & strtoi(file_to_open[21,8]) <= 20000){
    tn = 3
  }
  if (strtoi(file_to_open[21,8]) > 20000 & strtoi(file_to_open[21,8]) <= 25000){
    tn = 4
  }
  if (strtoi(file_to_open[21,8]) > 25000){
    tn = 5
  }
  taskset_3_6 [tn,i,1]  <- file_to_open[21,8]
  taskset_3_6 [tn,i,2]  <- file_to_open[21,12]
  taskset_3_6 [tn,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
  taskset_3_6 [tn,i,4]  <- i
  taskset_3_6 [tn,i,5]  <- sumperiod/20
  taskset_3_6 [tn,i,6] <- armonicity_number
  taskset_3_6 [tn,i,7] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
  taskset_3_6 [tn,i,8] <- (armonicity_number / dimensions)
  taskset_3_6 [tn,i,9] <- file_to_open[21,3]
  taskset_3_6 [tn,i,10] <- counter
  
}

taskset_7_20 = array (integer(), dim = c(5,1000,10))

for (i in 1:500){
  file_name <- paste("../taskset-experiments/U_90_hyper_113400000_7_20_armonic_10_100/U_90_hyper_113400000_7_20_armonic_10_100_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  print(i)
  
  dimensions = 0
  for (l in 1:20){
    dimensions <- dimensions + ((file_to_open[21,3]/file_to_open[l,3]))
  }
  list_of_wake_up = array(integer(), dim = c(dimensions))
  armonicity_number = 0
  counter = 1
  for (l in 1:20){
    temp = file_to_open[l,3]
    while (temp < file_to_open [21,3]){
      list_of_wake_up [counter] <- temp
      temp <- temp + file_to_open[l,3]
      counter <- counter + 1
    }
  }
  armonicity_number <- length(list_of_wake_up) - length(unique(list_of_wake_up))
  
  sumperiod = 0
  for (l in 20:1){
    sumperiod = sumperiod + strtoi(file_to_open[l,3])
  }
  tn = 0
  if (strtoi(file_to_open[21,8]) <= 10000){
    tn = 1
  }
  if (strtoi(file_to_open[21,8]) > 10000 & strtoi(file_to_open[21,8]) <= 15000){
    tn = 2
  }
  if (strtoi(file_to_open[21,8]) > 15000 & strtoi(file_to_open[21,8]) <= 20000){
    tn = 3
  }
  if (strtoi(file_to_open[21,8]) > 20000 & strtoi(file_to_open[21,8]) <= 25000){
    tn = 4
  }
  if (strtoi(file_to_open[21,8]) > 25000){
    tn = 5
  }
  taskset_7_20 [tn,i,1]  <- file_to_open[21,8]
  taskset_7_20 [tn,i,2]  <- file_to_open[21,12]
  taskset_7_20 [tn,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
  taskset_7_20 [tn,i,4]  <- i
  taskset_7_20 [tn,i,5]  <- sumperiod/20
  taskset_7_20 [tn,i,6] <- armonicity_number
  taskset_7_20 [tn,i,7] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
  taskset_7_20 [tn,i,8] <- (armonicity_number / dimensions)
  taskset_7_20 [tn,i,9] <- file_to_open[21,3]
  taskset_7_20 [tn,i,10] <- counter
  
}


#############################################################

# Numero preemption per gruppo
res <- boxplot (taskset_0_2[1,,1], taskset_0_2[2,,1], taskset_0_2[3,,1], taskset_0_2[4,,1], taskset_0_2[5,,1],taskset_3_6[1,,1], taskset_3_6[2,,1], taskset_3_6[3,,1], taskset_3_6[4,,1], taskset_3_6[5,,1], taskset_7_20[1,,1], taskset_7_20[2,,1], taskset_7_20[3,,1], taskset_7_20[4,,1], taskset_7_20[5,,1], 
                names=c("1-g1","1-g2","1-g3","1-g4","1-g5", "2-g1","2-g2","2-g3","2-g4","2-g5", "3-g1","3-g2","3-g3","3-g4","3-g5"), scipen=5, main="FPS preemtpion per gruppo", xlab="Taskset", ylab="FPS preemption")
abline(h = 0.36, col = "red")
abline(h = 0.40, col = "red")
res$stats

# Iperperiodo
res <- boxplot (taskset_0_2[1,,9], taskset_0_2[2,,9], taskset_0_2[3,,9], taskset_0_2[4,,9], taskset_0_2[5,,9],taskset_3_6[1,,9], taskset_3_6[2,,9], taskset_3_6[3,,9], taskset_3_6[4,,9], taskset_3_6[5,,9], taskset_7_20[1,,9], taskset_7_20[2,,9], taskset_7_20[3,,9], taskset_7_20[4,,9], taskset_7_20[5,,9], 
                names=c("1-g1","1-g2","1-g3","1-g4","1-g5", "2-g1","2-g2","2-g3","2-g4","2-g5", "3-g1","3-g2","3-g3","3-g4","3-g5"), scipen=5, main="Iperperiodi", xlab="Taskset", ylab="Iperperiodo")

# Armonicità %
res <- boxplot (taskset_0_2[1,,8], taskset_0_2[2,,8], taskset_0_2[3,,8], taskset_0_2[4,,8], taskset_0_2[5,,8],taskset_3_6[1,,8], taskset_3_6[2,,8], taskset_3_6[3,,8], taskset_3_6[4,,8], taskset_3_6[5,,8], taskset_7_20[1,,8], taskset_7_20[2,,8], taskset_7_20[3,,8], taskset_7_20[4,,8], taskset_7_20[5,,8],
                names=c("1-g1","1-g2","1-g3","1-g4","1-g5", "2-g1","2-g2","2-g3","2-g4","2-g5", "3-g1","3-g2","3-g3","3-g4","3-g5"), scipen=5, main="Armonicità", xlab="Taskset", ylab="(Numero rilasci simultanei) / (Rilasci possibili)")
abline(h = 0.36, col = "red")
abline(h = 0.40, col = "red")
res$stats

# Media periodi per gruppo
res <- boxplot (taskset_0_2[1,,5], taskset_0_2[2,,5], taskset_0_2[3,,5], taskset_0_2[4,,5], taskset_0_2[5,,5],taskset_3_6[1,,5], taskset_3_6[2,,5], taskset_3_6[3,,5], taskset_3_6[4,,5], taskset_3_6[5,,5], taskset_7_20[1,,5], taskset_7_20[2,,5], taskset_7_20[3,,5], taskset_7_20[4,,5], taskset_7_20[5,,5],
                names=c("1-g1","1-g2","1-g3","1-g4","1-g5", "2-g1","2-g2","2-g3","2-g4","2-g5", "3-g1","3-g2","3-g3","3-g4","3-g5"), scipen=5, main="Somma Periodi", xlab="Taskset", ylab="Somma Periodi")

# FPS-EDF preemptions %
res <- boxplot (taskset_0_2[1,,7], taskset_0_2[2,,7], taskset_0_2[3,,7], taskset_0_2[4,,7], taskset_0_2[5,,7],taskset_3_6[1,,7], taskset_3_6[2,,7], taskset_3_6[3,,7], taskset_3_6[4,,7], taskset_3_6[5,,7], taskset_7_20[1,,7], taskset_7_20[2,,7], taskset_7_20[3,,7], taskset_7_20[4,,7], taskset_7_20[5,,7], 
                names=c("1-g1","1-g2","1-g3","1-g4","1-g5", "2-g1","2-g2","2-g3","2-g4","2-g5", "3-g1","3-g2","3-g3","3-g4","3-g5"), scipen=5, main="FPS-EDF preemption %", xlab="Taskset", ylab="(FPS - EDF) / (FPS)")


#############################################################
# 
# 
# taskset_0_2_200 = array (integer(), dim = c(5,1000,13))
# 
# task_fps_win_0_2_200 = matrix(list(), nrow = 10000, ncol = 1)
# index_0_2_200  = 1
# armonic_0_2_200 = vector()
# work_0_2_200 = vector ()
# priority_0_2_200 = vector ()
# 
# fps_preemptions_0_2_200 = vector()
# armonicity_0_2_200 = array(integer(), dim = c(500))
# 
# for (i in 1:500){
#   file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/U_90_hyper_113400000_0_2_armonic_10_200/U_90_hyper_113400000_0_2_armonic_10_200_", c(i), ".csv", sep = "")
#   file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
# 
#   print(i)
# 
#   dimensions = 0
#   for (l in 1:20){
#     dimensions <- dimensions + ((file_to_open[21,3]/file_to_open[l,3]))
#   }
#   list_of_wake_up = array(integer(), dim = c(dimensions))
#   armonicity_number = 0
#   counter = 1
#   for (l in 1:20){
#     temp = file_to_open[l,3]
#     while (temp < file_to_open [21,3]){
#       list_of_wake_up [counter] <- temp
#       temp <- temp + file_to_open[l,3]
#       counter <- counter + 1
#     }
#   }
#   armonicity_number <- length(list_of_wake_up) - length(unique(list_of_wake_up))
#   armonicity_0_2_200 [i] <- armonicity_number
# 
#   fps_preemptions_0_2_200 <- append (fps_preemptions_0_2_200, file_to_open[21,8])
# 
#   for (l in 1:20){
#     if (file_to_open[l,9]<0){
#       temp = vector()
#       temp <- append (file_to_open[l,], i)
#       task_fps_win_0_2_200 [[index_0_2_200,1]] <- temp
#       work_0_2_200 <- append(work_0_2_200, file_to_open[l,13])
#       priority_0_2_200 <- append(priority_0_2_200, file_to_open[l,2])
#       index_0_2_200 <- index_0_2_200 + 1
#     }
#   }
#   armonic = vector()
#   for (l in 20:2){
#     for (m in 1:(l-1)){
#       if ((file_to_open[l,3]%%file_to_open[m,3]) == 0){
#         armonic <- append(armonic, file_to_open[l,3])
#         armonic <- append(armonic, file_to_open[m,3])
#       }
#     }
#   }
#   armonic_0_2_200 <- append (armonic_0_2_200, length(unique(armonic)))
# 
#   long = 0
#   medium = 0
#   short = 0
#   sumperiod = 0
#   for (l in 20:1){
#     sumperiod = sumperiod + strtoi(file_to_open[l,3])
#     if (file_to_open[l,3] <= 40000){
#       short = short + 1
#     }else{
#       if (file_to_open[l,3] >= 70000){
#         long = long + 1
#       }else{
#         medium = medium + 1
#       }
#     }
#   }
# 
#   if (strtoi(file_to_open[21,8]) <= 10000){
#     taskset_0_2_200 [1,i,1]  <- file_to_open[21,8]
#     taskset_0_2_200 [1,i,2]  <- file_to_open[21,12]
#     taskset_0_2_200 [1,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
#     taskset_0_2_200 [1,i,4]  <- i
#     taskset_0_2_200 [1,i,5]  <- length(unique(armonic))
#     taskset_0_2_200 [1,i,6]  <- short
#     taskset_0_2_200 [1,i,7]  <- medium
#     taskset_0_2_200 [1,i,8]  <- long
#     taskset_0_2_200 [1,i,9]  <- sumperiod
#     taskset_0_2_200 [1,i,10] <- armonicity_number
#     taskset_0_2_200 [1,i,11] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
#     taskset_0_2_200 [1,i,12] <- (armonicity_number / dimensions)
#     taskset_0_2_200 [1,i,13] <- file_to_open[21,3]
#   }
#   if (strtoi(file_to_open[21,8]) > 10000 & strtoi(file_to_open[21,8]) <= 15000){
#     taskset_0_2_200 [2,i,1]  <- file_to_open[21,8]
#     taskset_0_2_200 [2,i,2]  <- file_to_open[21,12]
#     taskset_0_2_200 [2,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
#     taskset_0_2_200 [2,i,4]  <- i
#     taskset_0_2_200 [2,i,5]  <- length(unique(armonic))
#     taskset_0_2_200 [2,i,6]  <- short
#     taskset_0_2_200 [2,i,7]  <- medium
#     taskset_0_2_200 [2,i,8]  <- long
#     taskset_0_2_200 [2,i,9]  <- sumperiod
#     taskset_0_2_200 [2,i,10] <- armonicity_number
#     taskset_0_2_200 [2,i,11] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
#     taskset_0_2_200 [2,i,12] <- (armonicity_number / dimensions)
#     taskset_0_2_200 [2,i,13] <- file_to_open[21,3]
#   }
#   if (strtoi(file_to_open[21,8]) > 15000 & strtoi(file_to_open[21,8]) <= 20000){
#     taskset_0_2_200 [3,i,1]  <- file_to_open[21,8]
#     taskset_0_2_200 [3,i,2]  <- file_to_open[21,12]
#     taskset_0_2_200 [3,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
#     taskset_0_2_200 [3,i,4]  <- i
#     taskset_0_2_200 [3,i,5]  <- length(unique(armonic))
#     taskset_0_2_200 [3,i,6]  <- short
#     taskset_0_2_200 [3,i,7]  <- medium
#     taskset_0_2_200 [3,i,8]  <- long
#     taskset_0_2_200 [3,i,9]  <- sumperiod
#     taskset_0_2_200 [3,i,10] <- armonicity_number
#     taskset_0_2_200 [3,i,11] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
#     taskset_0_2_200 [3,i,12] <- (armonicity_number / dimensions)
#     taskset_0_2_200 [3,i,13] <- file_to_open[21,3]
#   }
#   if (strtoi(file_to_open[21,8]) > 20000 & strtoi(file_to_open[21,8]) <= 25000){
#     taskset_0_2_200 [4,i,1]  <- file_to_open[21,8]
#     taskset_0_2_200 [4,i,2]  <- file_to_open[21,12]
#     taskset_0_2_200 [4,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
#     taskset_0_2_200 [4,i,4]  <- i
#     taskset_0_2_200 [4,i,5]  <- length(unique(armonic))
#     taskset_0_2_200 [4,i,6]  <- short
#     taskset_0_2_200 [4,i,7]  <- medium
#     taskset_0_2_200 [4,i,8]  <- long
#     taskset_0_2_200 [4,i,9]  <- sumperiod
#     taskset_0_2_200 [4,i,10] <- armonicity_number
#     taskset_0_2_200 [4,i,11] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
#     taskset_0_2_200 [4,i,12] <- (armonicity_number / dimensions)
#     taskset_0_2_200 [4,i,13] <- file_to_open[21,3]
#   }
#   if (strtoi(file_to_open[21,8]) > 25000){
#     taskset_0_2_200 [5,i,1]  <- file_to_open[21,8]
#     taskset_0_2_200 [5,i,2]  <- file_to_open[21,12]
#     taskset_0_2_200 [5,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
#     taskset_0_2_200 [5,i,4]  <- i
#     taskset_0_2_200 [5,i,5]  <- length(unique(armonic))
#     taskset_0_2_200 [5,i,6]  <- short
#     taskset_0_2_200 [5,i,7]  <- medium
#     taskset_0_2_200 [5,i,8]  <- long
#     taskset_0_2_200 [5,i,9]  <- sumperiod
#     taskset_0_2_200 [5,i,10] <- armonicity_number
#     taskset_0_2_200 [5,i,11] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
#     taskset_0_2_200 [5,i,12] <- (armonicity_number / dimensions)
#     taskset_0_2_200 [5,i,13] <- file_to_open[21,3]
#   }
# 
# }
# 
# # res <- boxplot (fps_preemptions_0_2_200, names=c("fps pree"), scipen=5, main="Armonicità", xlab="Task", ylab="Numero rilasci uguali")
# # abline(h = 15, col = "red")
# # res$stats
# #
# #
# # print(armonicity_0_2_200)
# #
# # # short mid long
# # res <- boxplot (taskset_0_2_200[1,,6], taskset_0_2_200[1,,7], taskset_0_2_200[1,,8], taskset_0_2_200[2,,6], taskset_0_2_200[2,,7], taskset_0_2_200[2,,8], taskset_0_2_200[3,,6], taskset_0_2_200[3,,7], taskset_0_2_200[3,,8], taskset_0_2_200[4,,6], taskset_0_2_200[4,,7], taskset_0_2_200[4,,8], taskset_0_2_200[5,,6], taskset_0_2_200[5,,7], taskset_0_2_200[5,,8], names=c("short g1","medium g1","long g1", "short g2","medium g2","long g2", "short g3","medium g3","long g3", "short g4","medium g4","long g4", "short g5","medium g5","long g5"), scipen=5, main="tipo task per gruppo", xlab="Task", ylab="quantità")
# # abline(h = 7, col = "red")
# # res$stats
# #
# # # short mid long
# # res <- boxplot (taskset_0_2_200[1,,9], taskset_0_2_200[2,,9], taskset_0_2_200[3,,9], taskset_0_2_200[4,,9], taskset_0_2_200[5,,9], names=c("g1","g2","g3", "g4","g5"), scipen=5, main="tipo task per gruppo", xlab="Task", ylab="quantità")
# # abline(h = 7, col = "red")
# # res$stats
# #
# # res <- boxplot (taskset_0_2_200[1,,10], taskset_0_2_200[2,,10], taskset_0_2_200[3,,10], taskset_0_2_200[4,,10], taskset_0_2_200[5,,10], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5"), scipen=5, main="Armonicità", xlab="Task", ylab="Numero rilasci uguali")
# # abline(h = 15, col = "red")
# # res$stats
# #
# # # fps preemption - edf preemption
# # res <- boxplot (taskset_0_2_200[1,,3], taskset_0_2_200[2,,3], taskset_0_2_200[3,,3], taskset_0_2_200[4,,3], taskset_0_2_200[5,,3], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5"), scipen=5, main="FPS Preemtpion - EDF Preemption", xlab="Task", ylab="Differenza preemption")
# # abline(h = 15, col = "red")
# # res$stats
# #
# # res <- boxplot (taskset_0_2_200[1,,12], taskset_0_2_200[2,,12], taskset_0_2_200[3,,12], taskset_0_2_200[4,,12], taskset_0_2_200[5,,12], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5"), scipen=5, main="Armonicità", xlab="Task", ylab="Numero rilasci uguali")
# # abline(h = 15, col = "red")
# # res$stats
# #
# # # fps preemption - edf preemption
# # res <- boxplot (taskset_0_2_200[1,,11], taskset_0_2_200[2,,11], taskset_0_2_200[3,,11], taskset_0_2_200[4,,11], taskset_0_2_200[5,,11], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5"), scipen=5, main="FPS Preemtpion - EDF Preemption", xlab="Task", ylab="Differenza preemption")
# # abline(h = 15, col = "red")
# # res$stats
# #
# #
# # res <- boxplot (taskset_0_2[1,,12], taskset_0_2[2,,12], taskset_0_2[3,,12], taskset_0_2[4,,12], taskset_0_2[5,,12], taskset_0_2_200[1,,12], taskset_0_2_200[2,,12], taskset_0_2_200[3,,12], taskset_0_2_200[4,,12], taskset_0_2_200[5,,12], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5", "gruppo 12","gruppo 22","gruppo 32","gruppo 42","gruppo 52"), scipen=5, main="Armonicità", xlab="Task", ylab="Numero rilasci uguali")
# # abline(h = 0.36, col = "red")
# # res$stats
# 
# 
# 
# taskset_3_6_200 = array (integer(), dim = c(5,1000,13))
# 
# task_fps_win_3_6_200 = matrix(list(), nrow = 10000, ncol = 1)
# index_3_6_200  = 1
# armonic_3_6_200 = vector()
# work_3_6_200 = vector ()
# priority_3_6_200 = vector ()
# 
# fps_preemptions_3_6_200 = vector()
# armonicity_3_6_200 = array(integer(), dim = c(500))
# 
# for (i in 1:500){
#   file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/U_90_hyper_113400000_3_6_armonic_10_200/U_90_hyper_113400000_3_6_armonic_10_200_", c(i), ".csv", sep = "")
#   file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
# 
#   print(i)
# 
#   dimensions = 0
#   for (l in 1:20){
#     dimensions <- dimensions + ((file_to_open[21,3]/file_to_open[l,3]))
#   }
#   list_of_wake_up = array(integer(), dim = c(dimensions))
#   armonicity_number = 0
#   counter = 1
#   for (l in 1:20){
#     temp = file_to_open[l,3]
#     while (temp < file_to_open [21,3]){
#       list_of_wake_up [counter] <- temp
#       temp <- temp + file_to_open[l,3]
#       counter <- counter + 1
#     }
#   }
#   armonicity_number <- length(list_of_wake_up) - length(unique(list_of_wake_up))
#   armonicity_3_6_200 [i] <- armonicity_number
# 
#   fps_preemptions_3_6_200 <- append (fps_preemptions_3_6_200, file_to_open[21,8])
# 
#   for (l in 1:20){
#     if (file_to_open[l,9]<0){
#       temp = vector()
#       temp <- append (file_to_open[l,], i)
#       task_fps_win_3_6_200 [[index_3_6_200,1]] <- temp
#       work_3_6_200 <- append(work_3_6_200, file_to_open[l,13])
#       priority_3_6_200 <- append(priority_3_6_200, file_to_open[l,2])
#       index_3_6_200 <- index_3_6_200 + 1
#     }
#   }
#   armonic = vector()
#   for (l in 20:2){
#     for (m in 1:(l-1)){
#       if ((file_to_open[l,3]%%file_to_open[m,3]) == 0){
#         armonic <- append(armonic, file_to_open[l,3])
#         armonic <- append(armonic, file_to_open[m,3])
#       }
#     }
#   }
#   armonic_3_6_200 <- append (armonic_3_6_200, length(unique(armonic)))
# 
#   long = 0
#   medium = 0
#   short = 0
#   sumperiod = 0
#   for (l in 20:1){
#     sumperiod = sumperiod + strtoi(file_to_open[l,3])
#     if (file_to_open[l,3] <= 40000){
#       short = short + 1
#     }else{
#       if (file_to_open[l,3] >= 70000){
#         long = long + 1
#       }else{
#         medium = medium + 1
#       }
#     }
#   }
# 
#   if (strtoi(file_to_open[21,8]) <= 10000){
#     taskset_3_6_200 [1,i,1]  <- file_to_open[21,8]
#     taskset_3_6_200 [1,i,2]  <- file_to_open[21,12]
#     taskset_3_6_200 [1,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
#     taskset_3_6_200 [1,i,4]  <- i
#     taskset_3_6_200 [1,i,5]  <- length(unique(armonic))
#     taskset_3_6_200 [1,i,6]  <- short
#     taskset_3_6_200 [1,i,7]  <- medium
#     taskset_3_6_200 [1,i,8]  <- long
#     taskset_3_6_200 [1,i,9]  <- sumperiod
#     taskset_3_6_200 [1,i,10] <- armonicity_number
#     taskset_3_6_200 [1,i,11] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
#     taskset_3_6_200 [1,i,12] <- (armonicity_number / dimensions)
#     taskset_3_6_200 [1,i,13] <- file_to_open[21,3]
#   }
#   if (strtoi(file_to_open[21,8]) > 10000 & strtoi(file_to_open[21,8]) <= 15000){
#     taskset_3_6_200 [2,i,1]  <- file_to_open[21,8]
#     taskset_3_6_200 [2,i,2]  <- file_to_open[21,12]
#     taskset_3_6_200 [2,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
#     taskset_3_6_200 [2,i,4]  <- i
#     taskset_3_6_200 [2,i,5]  <- length(unique(armonic))
#     taskset_3_6_200 [2,i,6]  <- short
#     taskset_3_6_200 [2,i,7]  <- medium
#     taskset_3_6_200 [2,i,8]  <- long
#     taskset_3_6_200 [2,i,9]  <- sumperiod
#     taskset_3_6_200 [2,i,10] <- armonicity_number
#     taskset_3_6_200 [2,i,11] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
#     taskset_3_6_200 [2,i,12] <- (armonicity_number / dimensions)
#     taskset_3_6_200 [2,i,13] <- file_to_open[21,3]
#   }
#   if (strtoi(file_to_open[21,8]) > 15000 & strtoi(file_to_open[21,8]) <= 20000){
#     taskset_3_6_200 [3,i,1]  <- file_to_open[21,8]
#     taskset_3_6_200 [3,i,2]  <- file_to_open[21,12]
#     taskset_3_6_200 [3,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
#     taskset_3_6_200 [3,i,4]  <- i
#     taskset_3_6_200 [3,i,5]  <- length(unique(armonic))
#     taskset_3_6_200 [3,i,6]  <- short
#     taskset_3_6_200 [3,i,7]  <- medium
#     taskset_3_6_200 [3,i,8]  <- long
#     taskset_3_6_200 [3,i,9]  <- sumperiod
#     taskset_3_6_200 [3,i,10] <- armonicity_number
#     taskset_3_6_200 [3,i,11] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
#     taskset_3_6_200 [3,i,12] <- (armonicity_number / dimensions)
#     taskset_3_6_200 [3,i,13] <- file_to_open[21,3]
#   }
#   if (strtoi(file_to_open[21,8]) > 20000 & strtoi(file_to_open[21,8]) <= 25000){
#     taskset_3_6_200 [4,i,1]  <- file_to_open[21,8]
#     taskset_3_6_200 [4,i,2]  <- file_to_open[21,12]
#     taskset_3_6_200 [4,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
#     taskset_3_6_200 [4,i,4]  <- i
#     taskset_3_6_200 [4,i,5]  <- length(unique(armonic))
#     taskset_3_6_200 [4,i,6]  <- short
#     taskset_3_6_200 [4,i,7]  <- medium
#     taskset_3_6_200 [4,i,8]  <- long
#     taskset_3_6_200 [4,i,9]  <- sumperiod
#     taskset_3_6_200 [4,i,10] <- armonicity_number
#     taskset_3_6_200 [4,i,11] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
#     taskset_3_6_200 [4,i,12] <- (armonicity_number / dimensions)
#     taskset_3_6_200 [4,i,13] <- file_to_open[21,3]
#   }
#   if (strtoi(file_to_open[21,8]) > 25000){
#     taskset_3_6_200 [5,i,1]  <- file_to_open[21,8]
#     taskset_3_6_200 [5,i,2]  <- file_to_open[21,12]
#     taskset_3_6_200 [5,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
#     taskset_3_6_200 [5,i,4]  <- i
#     taskset_3_6_200 [5,i,5]  <- length(unique(armonic))
#     taskset_3_6_200 [5,i,6]  <- short
#     taskset_3_6_200 [5,i,7]  <- medium
#     taskset_3_6_200 [5,i,8]  <- long
#     taskset_3_6_200 [5,i,9]  <- sumperiod
#     taskset_3_6_200 [5,i,10] <- armonicity_number
#     taskset_3_6_200 [5,i,11] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
#     taskset_3_6_200 [5,i,12] <- (armonicity_number / dimensions)
#     taskset_3_6_200 [5,i,13] <- file_to_open[21,3]
#   }
# }
# 
# 
# # res <- boxplot (fps_preemptions_3_6_200, names=c("fps pree"), scipen=5, main="Armonicità", xlab="Task", ylab="Numero rilasci uguali")
# # abline(h = 15, col = "red")
# # res$stats
# #
# #
# # print(armonicity_3_6_200)
# #
# # # short mid long
# # res <- boxplot (taskset_3_6_200[1,,6], taskset_3_6_200[1,,7], taskset_3_6_200[1,,8], taskset_3_6_200[2,,6], taskset_3_6_200[2,,7], taskset_3_6_200[2,,8], taskset_3_6_200[3,,6], taskset_3_6_200[3,,7], taskset_3_6_200[3,,8], taskset_3_6_200[4,,6], taskset_3_6_200[4,,7], taskset_3_6_200[4,,8], taskset_3_6_200[5,,6], taskset_3_6_200[5,,7], taskset_3_6_200[5,,8], names=c("short g1","medium g1","long g1", "short g2","medium g2","long g2", "short g3","medium g3","long g3", "short g4","medium g4","long g4", "short g5","medium g5","long g5"), scipen=5, main="tipo task per gruppo", xlab="Task", ylab="quantità")
# # abline(h = 7, col = "red")
# # res$stats
# #
# # # short mid long
# # res <- boxplot (taskset_3_6_200[1,,9], taskset_3_6_200[2,,9], taskset_3_6_200[3,,9], taskset_3_6_200[4,,9], taskset_3_6_200[5,,9], names=c("g1","g2","g3", "g4","g5"), scipen=5, main="tipo task per gruppo", xlab="Task", ylab="quantità")
# # abline(h = 7, col = "red")
# # res$stats
# #
# # res <- boxplot (taskset_3_6_200[1,,10], taskset_3_6_200[2,,10], taskset_3_6_200[3,,10], taskset_3_6_200[4,,10], taskset_3_6_200[5,,10], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5"), scipen=5, main="Armonicità", xlab="Task", ylab="Numero rilasci uguali")
# # abline(h = 15, col = "red")
# # res$stats
# #
# # # fps preemption - edf preemption
# # res <- boxplot (taskset_3_6_200[1,,3], taskset_3_6_200[2,,3], taskset_3_6_200[3,,3], taskset_3_6_200[4,,3], taskset_3_6_200[5,,3], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5"), scipen=5, main="FPS Preemtpion - EDF Preemption", xlab="Task", ylab="Differenza preemption")
# # abline(h = 15, col = "red")
# # res$stats
# #
# # res <- boxplot (taskset_3_6_200[1,,12], taskset_3_6_200[2,,12], taskset_3_6_200[3,,12], taskset_3_6_200[4,,12], taskset_3_6_200[5,,12], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5"), scipen=5, main="Armonicità", xlab="Task", ylab="Numero rilasci uguali")
# # abline(h = 15, col = "red")
# # res$stats
# #
# # # fps preemption - edf preemption
# # res <- boxplot (taskset_3_6_200[1,,11], taskset_3_6_200[2,,11], taskset_3_6_200[3,,11], taskset_3_6_200[4,,11], taskset_3_6_200[5,,11], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5"), scipen=5, main="FPS Preemtpion - EDF Preemption", xlab="Task", ylab="Differenza preemption")
# # abline(h = 15, col = "red")
# # res$stats
# #
# #
# # res <- boxplot (taskset_0_2[1,,12], taskset_0_2[2,,12], taskset_0_2[3,,12], taskset_0_2[4,,12], taskset_0_2[5,,12], taskset_3_6_200[1,,12], taskset_3_6_200[2,,12], taskset_3_6_200[3,,12], taskset_3_6_200[4,,12], taskset_3_6_200[5,,12], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5", "gruppo 12","gruppo 22","gruppo 32","gruppo 42","gruppo 52"), scipen=5, main="Armonicità", xlab="Task", ylab="Numero rilasci uguali")
# # abline(h = 0.36, col = "red")
# # res$stats
# 
# 
# 
# taskset_7_20_200 = array (integer(), dim = c(5,1000,13))
# 
# task_fps_win_7_20_200 = matrix(list(), nrow = 10000, ncol = 1)
# index_7_20_200  = 1
# armonic_7_20_200 = vector()
# work_7_20_200 = vector ()
# priority_7_20_200 = vector ()
# 
# fps_preemptions_7_20_200 = vector()
# armonicity_7_20_200 = array(integer(), dim = c(500))
# 
# for (i in 1:500){
#   file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/U_90_hyper_113400000_with_some_long/U_90_hyper_113400000_with_some_long_", c(i), ".csv", sep = "")
#   file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
#   
#   print(i)
#   
#   dimensions = 0
#   for (l in 1:20){
#     dimensions <- dimensions + ((file_to_open[21,3]/file_to_open[l,3]))
#   }
#   list_of_wake_up = array(integer(), dim = c(dimensions))
#   armonicity_number = 0
#   counter = 1
#   for (l in 1:20){
#     temp = file_to_open[l,3]
#     while (temp < file_to_open [21,3]){
#       list_of_wake_up [counter] <- temp
#       temp <- temp + file_to_open[l,3]
#       counter <- counter + 1
#     }
#   }
#   armonicity_number <- length(list_of_wake_up) - length(unique(list_of_wake_up))
#   armonicity_7_20_200 [i] <- armonicity_number
#   
#   fps_preemptions_7_20_200 <- append (fps_preemptions_7_20_200, file_to_open[21,8])
#   
#   for (l in 1:20){
#     if (file_to_open[l,9]<0){
#       temp = vector()
#       temp <- append (file_to_open[l,], i)
#       task_fps_win_7_20_200 [[index_7_20_200,1]] <- temp
#       work_7_20_200 <- append(work_7_20_200, file_to_open[l,13])
#       priority_7_20_200 <- append(priority_7_20_200, file_to_open[l,2])
#       index_7_20_200 <- index_7_20_200 + 1
#     }
#   }
#   armonic = vector()
#   for (l in 20:2){
#     for (m in 1:(l-1)){
#       if ((file_to_open[l,3]%%file_to_open[m,3]) == 0){
#         armonic <- append(armonic, file_to_open[l,3])
#         armonic <- append(armonic, file_to_open[m,3])
#       }
#     }
#   }
#   armonic_7_20_200 <- append (armonic_7_20_200, length(unique(armonic)))
#   
#   long = 0
#   medium = 0
#   short = 0
#   sumperiod = 0
#   for (l in 20:1){
#     sumperiod = sumperiod + strtoi(file_to_open[l,3])
#     if (file_to_open[l,3] <= 40000){
#       short = short + 1
#     }else{
#       if (file_to_open[l,3] >= 70000){
#         long = long + 1
#       }else{
#         medium = medium + 1
#       }
#     }
#   }
#   
#   if (strtoi(file_to_open[21,8]) <= 10000){
#     taskset_7_20_200 [1,i,1]  <- file_to_open[21,8]
#     taskset_7_20_200 [1,i,2]  <- file_to_open[21,12]
#     taskset_7_20_200 [1,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
#     taskset_7_20_200 [1,i,4]  <- i
#     taskset_7_20_200 [1,i,5]  <- length(unique(armonic))
#     taskset_7_20_200 [1,i,6]  <- short
#     taskset_7_20_200 [1,i,7]  <- medium
#     taskset_7_20_200 [1,i,8]  <- long
#     taskset_7_20_200 [1,i,9]  <- sumperiod
#     taskset_7_20_200 [1,i,10] <- armonicity_number
#     taskset_7_20_200 [1,i,11] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
#     taskset_7_20_200 [1,i,12] <- (armonicity_number / dimensions)
#     taskset_7_20_200 [1,i,13] <- file_to_open[21,3]
#   }
#   if (strtoi(file_to_open[21,8]) > 10000 & strtoi(file_to_open[21,8]) <= 15000){
#     taskset_7_20_200 [2,i,1]  <- file_to_open[21,8]
#     taskset_7_20_200 [2,i,2]  <- file_to_open[21,12]
#     taskset_7_20_200 [2,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
#     taskset_7_20_200 [2,i,4]  <- i
#     taskset_7_20_200 [2,i,5]  <- length(unique(armonic))
#     taskset_7_20_200 [2,i,6]  <- short
#     taskset_7_20_200 [2,i,7]  <- medium
#     taskset_7_20_200 [2,i,8]  <- long
#     taskset_7_20_200 [2,i,9]  <- sumperiod
#     taskset_7_20_200 [2,i,10] <- armonicity_number
#     taskset_7_20_200 [2,i,11] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
#     taskset_7_20_200 [2,i,12] <- (armonicity_number / dimensions)
#     taskset_7_20_200 [2,i,13] <- file_to_open[21,3]
#   }
#   if (strtoi(file_to_open[21,8]) > 15000 & strtoi(file_to_open[21,8]) <= 20000){
#     taskset_7_20_200 [3,i,1]  <- file_to_open[21,8]
#     taskset_7_20_200 [3,i,2]  <- file_to_open[21,12]
#     taskset_7_20_200 [3,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
#     taskset_7_20_200 [3,i,4]  <- i
#     taskset_7_20_200 [3,i,5]  <- length(unique(armonic))
#     taskset_7_20_200 [3,i,6]  <- short
#     taskset_7_20_200 [3,i,7]  <- medium
#     taskset_7_20_200 [3,i,8]  <- long
#     taskset_7_20_200 [3,i,9]  <- sumperiod
#     taskset_7_20_200 [3,i,10] <- armonicity_number
#     taskset_7_20_200 [3,i,11] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
#     taskset_7_20_200 [3,i,12] <- (armonicity_number / dimensions)
#     taskset_7_20_200 [3,i,13] <- file_to_open[21,3]
#   }
#   if (strtoi(file_to_open[21,8]) > 20000 & strtoi(file_to_open[21,8]) <= 25000){
#     taskset_7_20_200 [4,i,1]  <- file_to_open[21,8]
#     taskset_7_20_200 [4,i,2]  <- file_to_open[21,12]
#     taskset_7_20_200 [4,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
#     taskset_7_20_200 [4,i,4]  <- i
#     taskset_7_20_200 [4,i,5]  <- length(unique(armonic))
#     taskset_7_20_200 [4,i,6]  <- short
#     taskset_7_20_200 [4,i,7]  <- medium
#     taskset_7_20_200 [4,i,8]  <- long
#     taskset_7_20_200 [4,i,9]  <- sumperiod
#     taskset_7_20_200 [4,i,10] <- armonicity_number
#     taskset_7_20_200 [4,i,11] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
#     taskset_7_20_200 [4,i,12] <- (armonicity_number / dimensions)
#     taskset_7_20_200 [4,i,13] <- file_to_open[21,3]
#   }
#   if (strtoi(file_to_open[21,8]) > 25000){
#     taskset_7_20_200 [5,i,1]  <- file_to_open[21,8]
#     taskset_7_20_200 [5,i,2]  <- file_to_open[21,12]
#     taskset_7_20_200 [5,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
#     taskset_7_20_200 [5,i,4]  <- i
#     taskset_7_20_200 [5,i,5]  <- length(unique(armonic))
#     taskset_7_20_200 [5,i,6]  <- short
#     taskset_7_20_200 [5,i,7]  <- medium
#     taskset_7_20_200 [5,i,8]  <- long
#     taskset_7_20_200 [5,i,9]  <- sumperiod
#     taskset_7_20_200 [5,i,10] <- armonicity_number
#     taskset_7_20_200 [5,i,11] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
#     taskset_7_20_200 [5,i,12] <- (armonicity_number / dimensions)
#     taskset_7_20_200 [5,i,13] <- file_to_open[21,3]
#   }
# }
# 
# # res <- boxplot (fps_preemptions_7_20_200, names=c("fps pree"), scipen=5, main="Armonicità", xlab="Task", ylab="Numero rilasci uguali")
# # abline(h = 15, col = "red")
# # res$stats
# # 
# # 
# # print(armonicity_7_20_200)
# # 
# # # short mid long
# # res <- boxplot (taskset_7_20_200[1,,6], taskset_7_20_200[1,,7], taskset_7_20_200[1,,8], taskset_7_20_200[2,,6], taskset_7_20_200[2,,7], taskset_7_20_200[2,,8], taskset_7_20_200[3,,6], taskset_7_20_200[3,,7], taskset_7_20_200[3,,8], taskset_7_20_200[4,,6], taskset_7_20_200[4,,7], taskset_7_20_200[4,,8], taskset_7_20_200[5,,6], taskset_7_20_200[5,,7], taskset_7_20_200[5,,8], names=c("short g1","medium g1","long g1", "short g2","medium g2","long g2", "short g3","medium g3","long g3", "short g4","medium g4","long g4", "short g5","medium g5","long g5"), scipen=5, main="tipo task per gruppo", xlab="Task", ylab="quantità")
# # abline(h = 7, col = "red")
# # res$stats
# # 
# # # short mid long
# # res <- boxplot (taskset_7_20_200[1,,9], taskset_7_20_200[2,,9], taskset_7_20_200[3,,9], taskset_7_20_200[4,,9], taskset_7_20_200[5,,9], names=c("g1","g2","g3", "g4","g5"), scipen=5, main="tipo task per gruppo", xlab="Task", ylab="quantità")
# # abline(h = 7, col = "red")
# # res$stats
# # 
# # res <- boxplot (taskset_7_20_200[1,,10], taskset_7_20_200[2,,10], taskset_7_20_200[3,,10], taskset_7_20_200[4,,10], taskset_7_20_200[5,,10], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5"), scipen=5, main="Armonicità", xlab="Task", ylab="Numero rilasci uguali")
# # abline(h = 15, col = "red")
# # res$stats
# # 
# # # fps preemption - edf preemption
# # res <- boxplot (taskset_7_20_200[1,,3], taskset_7_20_200[2,,3], taskset_7_20_200[3,,3], taskset_7_20_200[4,,3], taskset_7_20_200[5,,3], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5"), scipen=5, main="FPS Preemtpion - EDF Preemption", xlab="Task", ylab="Differenza preemption")
# # abline(h = 15, col = "red")
# # res$stats
# # 
# # res <- boxplot (taskset_7_20_200[1,,12], taskset_7_20_200[2,,12], taskset_7_20_200[3,,12], taskset_7_20_200[4,,12], taskset_7_20_200[5,,12], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5"), scipen=5, main="Armonicità", xlab="Task", ylab="Numero rilasci uguali")
# # abline(h = 15, col = "red")
# # res$stats
# # 
# # # fps preemption - edf preemption
# # res <- boxplot (taskset_7_20_200[1,,11], taskset_7_20_200[2,,11], taskset_7_20_200[3,,11], taskset_7_20_200[4,,11], taskset_7_20_200[5,,11], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5"), scipen=5, main="FPS Preemtpion - EDF Preemption", xlab="Task", ylab="Differenza preemption")
# # abline(h = 15, col = "red")
# # res$stats
# # 
# # 
# # res <- boxplot (taskset_0_2[1,,12], taskset_0_2[2,,12], taskset_0_2[3,,12], taskset_0_2[4,,12], taskset_0_2[5,,12], taskset_7_20_200[1,,12], taskset_7_20_200[2,,12], taskset_7_20_200[3,,12], taskset_7_20_200[4,,12], taskset_7_20_200[5,,12], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5", "gruppo 12","gruppo 22","gruppo 32","gruppo 42","gruppo 52"), scipen=5, main="Armonicità", xlab="Task", ylab="Numero rilasci uguali")
# # abline(h = 0.36, col = "red")
# # res$stats
# 
# 
# 
# 
# # Numero preemption per gruppo
# res <- boxplot (taskset_0_2[1,,1], taskset_0_2[2,,1], taskset_0_2[3,,1], taskset_0_2[4,,1], taskset_0_2[5,,1],taskset_3_6[1,,1], taskset_3_6[2,,1], taskset_3_6[3,,1], taskset_3_6[4,,1], taskset_3_6[5,,1], taskset_7_20[1,,1], taskset_7_20[2,,1], taskset_7_20[3,,1], taskset_7_20[4,,1], taskset_7_20[5,,1],taskset_0_2_200[1,,1], taskset_0_2_200[2,,1], taskset_0_2_200[3,,1], taskset_0_2_200[4,,1], taskset_0_2_200[5,,1],taskset_3_6_200[1,,1], taskset_3_6_200[2,,1], taskset_3_6_200[3,,1], taskset_3_6_200[4,,1], taskset_3_6_200[5,,1], taskset_7_20_200[1,,1], taskset_7_20_200[2,,1], taskset_7_20_200[3,,1], taskset_7_20_200[4,,1], taskset_7_20_200[5,,1], 
#                 names=c("g1 0-2","g2 0-2","g3 0-2","g4 0-2","g5 0-2", "g1 3-6","g2 3-6","g3 3-6","g4 3-6","g5 3-6", "g1 7-20","g2 7-20","g3 7-20","g4 7-20","g5 7-20","g1 0-2_200","g2 0-2_200","g3 0-2_200","g4 0-2_200","g5 0-2_200", "g1 3-6_200","g2 3-6_200","g3 3-6_200","g4 3-6_200","g5 3-6_200", "g1 7-6_200","g2 7-6_200","g3 7-6_200","g4 7-6_200","g5 7-6_200"), scipen=5, main="FPS preemtpion per gruppo", xlab="Taskset", ylab="FPS preemption")
# abline(h = 0.36, col = "red")
# abline(h = 0.40, col = "red")
# res$stats
# 
# # Iperperiodo
# res <- boxplot (taskset_0_2[1,,13], taskset_0_2[2,,13], taskset_0_2[3,,13], taskset_0_2[4,,13], taskset_0_2[5,,13],taskset_3_6[1,,13], taskset_3_6[2,,13], taskset_3_6[3,,13], taskset_3_6[4,,13], taskset_3_6[5,,13], taskset_7_20[1,,13], taskset_7_20[2,,13], taskset_7_20[3,,13], taskset_7_20[4,,13], taskset_7_20[5,,13],taskset_0_2_200[1,,13], taskset_0_2_200[2,,13], taskset_0_2_200[3,,13], taskset_0_2_200[4,,13], taskset_0_2_200[5,,13],taskset_3_6_200[1,,13], taskset_3_6_200[2,,13], taskset_3_6_200[3,,13], taskset_3_6_200[4,,13], taskset_3_6_200[5,,13], taskset_7_20_200[1,,13], taskset_7_20_200[2,,13], taskset_7_20_200[3,,13], taskset_7_20_200[4,,13], taskset_7_20_200[5,,13], 
#                 names=c("g1 0-2","g2 0-2","g3 0-2","g4 0-2","g5 0-2", "g1 3-6","g2 3-6","g3 3-6","g4 3-6","g5 3-6", "g1 7-20","g2 7-20","g3 7-20","g4 7-20","g5 7-20","g1 0-2_200","g2 0-2_200","g3 0-2_200","g4 0-2_200","g5 0-2_200", "g1 3-6_200","g2 3-6_200","g3 3-6_200","g4 3-6_200","g5 3-6_200", "g1 7-6_200","g2 7-6_200","g3 7-6_200","g4 7-6_200","g5 7-6_200"), scipen=5, main="Iperperiodi", xlab="Taskset", ylab="Iperperiodo")
# 
# # Armonicità %
# res <- boxplot (taskset_0_2[1,,12], taskset_0_2[2,,12], taskset_0_2[3,,12], taskset_0_2[4,,12], taskset_0_2[5,,12],taskset_3_6[1,,12], taskset_3_6[2,,12], taskset_3_6[3,,12], taskset_3_6[4,,12], taskset_3_6[5,,12], taskset_7_20[1,,12], taskset_7_20[2,,12], taskset_7_20[3,,12], taskset_7_20[4,,12], taskset_7_20[5,,12],taskset_0_2_200[1,,12], taskset_0_2_200[2,,12], taskset_0_2_200[3,,12], taskset_0_2_200[4,,12], taskset_0_2_200[5,,12],taskset_3_6_200[1,,12], taskset_3_6_200[2,,12], taskset_3_6_200[3,,12], taskset_3_6_200[4,,12], taskset_3_6_200[5,,12], taskset_7_20_200[1,,12], taskset_7_20_200[2,,12], taskset_7_20_200[3,,12], taskset_7_20_200[4,,12], taskset_7_20_200[5,,12], 
#                 names=c("g1 0-2","g2 0-2","g3 0-2","g4 0-2","g5 0-2", "g1 3-6","g2 3-6","g3 3-6","g4 3-6","g5 3-6", "g1 7-20","g2 7-20","g3 7-20","g4 7-20","g5 7-20","g1 0-2_200","g2 0-2_200","g3 0-2_200","g4 0-2_200","g5 0-2_200", "g1 3-6_200","g2 3-6_200","g3 3-6_200","g4 3-6_200","g5 3-6_200", "g1 7-6_200","g2 7-6_200","g3 7-6_200","g4 7-6_200","g5 7-6_200"), scipen=5, main="Armonicità", xlab="Taskset", ylab="(Numero rilasci simultanei) / (Rilasci possibili)")
# abline(h = 0.36, col = "red")
# abline(h = 0.40, col = "red")
# res$stats
# # Armonicità assoluta
# res <- boxplot (taskset_0_2[1,,10], taskset_0_2[2,,10], taskset_0_2[3,,10], taskset_0_2[4,,10], taskset_0_2[5,,10],taskset_3_6[1,,10], taskset_3_6[2,,10], taskset_3_6[3,,10], taskset_3_6[4,,10], taskset_3_6[5,,10], taskset_7_20[1,,10], taskset_7_20[2,,10], taskset_7_20[3,,10], taskset_7_20[4,,10], taskset_7_20[5,,10],taskset_0_2_200[1,,10], taskset_0_2_200[2,,10], taskset_0_2_200[3,,10], taskset_0_2_200[4,,10], taskset_0_2_200[5,,10],taskset_3_6_200[1,,10], taskset_3_6_200[2,,10], taskset_3_6_200[3,,10], taskset_3_6_200[4,,10], taskset_3_6_200[5,,10], taskset_7_20_200[1,,10], taskset_7_20_200[2,,10], taskset_7_20_200[3,,10], taskset_7_20_200[4,,10], taskset_7_20_200[5,,10], 
#                 names=c("g1 0-2","g2 0-2","g3 0-2","g4 0-2","g5 0-2", "g1 3-6","g2 3-6","g3 3-6","g4 3-6","g5 3-6", "g1 7-20","g2 7-20","g3 7-20","g4 7-20","g5 7-20","g1 0-2_200","g2 0-2_200","g3 0-2_200","g4 0-2_200","g5 0-2_200", "g1 3-6_200","g2 3-6_200","g3 3-6_200","g4 3-6_200","g5 3-6_200", "g1 7-6_200","g2 7-6_200","g3 7-6_200","g4 7-6_200","g5 7-6_200"), scipen=5, main="Armonicità", xlab="Taskset", ylab="Numero rilasci simultanei")
# 
# # # Tipo task per gruppo
# # res <- boxplot (taskset_0_2[1,,6], taskset_0_2[1,,7], taskset_0_2[1,,8], taskset_0_2[2,,6], taskset_0_2[2,,7], taskset_0_2[2,,8], taskset_0_2[3,,6], taskset_0_2[3,,7], taskset_0_2[3,,8], taskset_0_2[4,,6], taskset_0_2[4,,7], taskset_0_2[4,,8], taskset_0_2[5,,6], taskset_0_2[5,,7], taskset_0_2[5,,8], taskset_3_6[1,,6], taskset_3_6[1,,7], taskset_3_6[1,,8], taskset_3_6[2,,6], taskset_3_6[2,,7], taskset_3_6[2,,8], taskset_3_6[3,,6], taskset_3_6[3,,7], taskset_3_6[3,,8], taskset_3_6[4,,6], taskset_3_6[4,,7], taskset_3_6[4,,8], taskset_3_6[5,,6], taskset_3_6[5,,7], taskset_3_6[5,,8], taskset_7_20[1,,6], taskset_7_20[1,,7], taskset_7_20[1,,8], taskset_7_20[2,,6], taskset_7_20[2,,7], taskset_7_20[2,,8], taskset_7_20[3,,6], taskset_7_20[3,,7], taskset_7_20[3,,8], taskset_7_20[4,,6], taskset_7_20[4,,7], taskset_7_20[4,,8], taskset_7_20[5,,6], taskset_7_20[5,,7], taskset_7_20[5,,8],
# #                 names=c("s g1 0_2","m g1 0_2","l g1 0_2", "s g2 0_2","m g2 0_2","l g2 0_2", "s g3 0_2","m g3 0_2","l g3 0_2", "s g4 0_2","m g4 0_2","l g4 0_2", "s g5 0_2","m g5 0_2","l g5 0_2", "s g1 3_6","m g1 3_6","l g1 3_6", "s g2 3_6","m g2 3_6","l g2 3_6", "s g3 3_6","m g3 3_6","l g3 3_6", "s g4 3_6","m g4 3_6","l g4 3_6", "s g5 3_6","m g5 3_6","l g5 3_6", "s g1 7_20","m g1 7_20","l g1 7_20", "s g2 7_20","m g2 7_20","l g2 7_20", "s g3 7_20","m g3 7_20","l g3 7_20", "s g4 7_20","m g4 7_20","l g4 7_20", "s g5 7_20","m g5 7_20","l g5 7_20"), scipen=5, main="tipo task per gruppo", xlab="Task", ylab="quantità")
# # abline(h = 7, col = "red")
# # # Tipo task per gruppo %
# # res <- boxplot (taskset_0_2[1,,6]/20, taskset_0_2[1,,7]/20, taskset_0_2[1,,8]/20, taskset_0_2[2,,6]/20, taskset_0_2[2,,7]/20, taskset_0_2[2,,8]/20, taskset_0_2[3,,6]/20, taskset_0_2[3,,7]/20, taskset_0_2[3,,8]/20, taskset_0_2[4,,6]/20, taskset_0_2[4,,7]/20, taskset_0_2[4,,8]/20, taskset_0_2[5,,6]/20, taskset_0_2[5,,7]/20, taskset_0_2[5,,8]/20, taskset_3_6[1,,6]/20, taskset_3_6[1,,7]/20, taskset_3_6[1,,8]/20, taskset_3_6[2,,6]/20, taskset_3_6[2,,7]/20, taskset_3_6[2,,8]/20, taskset_3_6[3,,6]/20, taskset_3_6[3,,7]/20, taskset_3_6[3,,8]/20, taskset_3_6[4,,6]/20, taskset_3_6[4,,7]/20, taskset_3_6[4,,8]/20, taskset_3_6[5,,6]/20, taskset_3_6[5,,7]/20, taskset_3_6[5,,8]/20, taskset_7_20[1,,6]/20, taskset_7_20[1,,7]/20, taskset_7_20[1,,8]/20, taskset_7_20[2,,6]/20, taskset_7_20[2,,7]/20, taskset_7_20[2,,8]/20, taskset_7_20[3,,6]/20, taskset_7_20[3,,7]/20, taskset_7_20[3,,8]/20, taskset_7_20[4,,6]/20, taskset_7_20[4,,7]/20, taskset_7_20[4,,8]/20, taskset_7_20[5,,6]/20, taskset_7_20[5,,7]/20, taskset_7_20[5,,8]/20,
# #                 names=c("s g1 0_2","m g1 0_2","l g1 0_2", "s g2 0_2","m g2 0_2","l g2 0_2", "s g3 0_2","m g3 0_2","l g3 0_2", "s g4 0_2","m g4 0_2","l g4 0_2", "s g5 0_2","m g5 0_2","l g5 0_2", "s g1 3_6","m g1 3_6","l g1 3_6", "s g2 3_6","m g2 3_6","l g2 3_6", "s g3 3_6","m g3 3_6","l g3 3_6", "s g4 3_6","m g4 3_6","l g4 3_6", "s g5 3_6","m g5 3_6","l g5 3_6", "s g1 7_20","m g1 7_20","l g1 7_20", "s g2 7_20","m g2 7_20","l g2 7_20", "s g3 7_20","m g3 7_20","l g3 7_20", "s g4 7_20","m g4 7_20","l g4 7_20", "s g5 7_20","m g5 7_20","l g5 7_20"), scipen=5, main="tipo task per gruppo", xlab="Task", ylab="quantità %")
# # abline(h = 7, col = "red")
# 
# # Somma periodi per gruppo
# res <- boxplot (taskset_0_2[1,,9], taskset_0_2[2,,9], taskset_0_2[3,,9], taskset_0_2[4,,9], taskset_0_2[5,,9],taskset_3_6[1,,9], taskset_3_6[2,,9], taskset_3_6[3,,9], taskset_3_6[4,,9], taskset_3_6[5,,9], taskset_7_20[1,,9], taskset_7_20[2,,9], taskset_7_20[3,,9], taskset_7_20[4,,9], taskset_7_20[5,,9],taskset_0_2_200[1,,9], taskset_0_2_200[2,,9], taskset_0_2_200[3,,9], taskset_0_2_200[4,,9], taskset_0_2_200[5,,9],taskset_3_6_200[1,,9], taskset_3_6_200[2,,9], taskset_3_6_200[3,,9], taskset_3_6_200[4,,9], taskset_3_6_200[5,,9], taskset_7_20_200[1,,9], taskset_7_20_200[2,,9], taskset_7_20_200[3,,9], taskset_7_20_200[4,,9], taskset_7_20_200[5,,9], 
#                 names=c("g1 0-2","g2 0-2","g3 0-2","g4 0-2","g5 0-2", "g1 3-6","g2 3-6","g3 3-6","g4 3-6","g5 3-6", "g1 7-20","g2 7-20","g3 7-20","g4 7-20","g5 7-20","g1 0-2_200","g2 0-2_200","g3 0-2_200","g4 0-2_200","g5 0-2_200", "g1 3-6_200","g2 3-6_200","g3 3-6_200","g4 3-6_200","g5 3-6_200", "g1 7-6_200","g2 7-6_200","g3 7-6_200","g4 7-6_200","g5 7-6_200"), scipen=5, main="Somma Periodi", xlab="Taskset", ylab="Somma Periodi")
# 
# # FPS-EDF preemptions %
# res <- boxplot (taskset_0_2[1,,11], taskset_0_2[2,,11], taskset_0_2[3,,11], taskset_0_2[4,,11], taskset_0_2[5,,11],taskset_3_6[1,,11], taskset_3_6[2,,11], taskset_3_6[3,,11], taskset_3_6[4,,11], taskset_3_6[5,,11], taskset_7_20[1,,11], taskset_7_20[2,,11], taskset_7_20[3,,11], taskset_7_20[4,,11], taskset_7_20[5,,11],taskset_0_2_200[1,,11], taskset_0_2_200[2,,11], taskset_0_2_200[3,,11], taskset_0_2_200[4,,11], taskset_0_2_200[5,,11],taskset_3_6_200[1,,11], taskset_3_6_200[2,,11], taskset_3_6_200[3,,11], taskset_3_6_200[4,,11], taskset_3_6_200[5,,11], taskset_7_20_200[1,,11], taskset_7_20_200[2,,11], taskset_7_20_200[3,,11], taskset_7_20_200[4,,11], taskset_7_20_200[5,,11], 
#                 names=c("g1 0-2","g2 0-2","g3 0-2","g4 0-2","g5 0-2", "g1 3-6","g2 3-6","g3 3-6","g4 3-6","g5 3-6", "g1 7-20","g2 7-20","g3 7-20","g4 7-20","g5 7-20","g1 0-2_200","g2 0-2_200","g3 0-2_200","g4 0-2_200","g5 0-2_200", "g1 3-6_200","g2 3-6_200","g3 3-6_200","g4 3-6_200","g5 3-6_200", "g1 7-6_200","g2 7-6_200","g3 7-6_200","g4 7-6_200","g5 7-6_200"), scipen=5, main="FPS-EDF preemption %", xlab="Taskset", ylab="(FPS - EDF) / (FPS)")
# # FPS-EDF preemptions
# res <- boxplot (taskset_0_2[1,,3], taskset_0_2[2,,3], taskset_0_2[3,,3], taskset_0_2[4,,3], taskset_0_2[5,,3],taskset_3_6[1,,3], taskset_3_6[2,,3], taskset_3_6[3,,3], taskset_3_6[4,,3], taskset_3_6[5,,3], taskset_7_20[1,,3], taskset_7_20[2,,3], taskset_7_20[3,,3], taskset_7_20[4,,3], taskset_7_20[5,,3],taskset_0_2_200[1,,3], taskset_0_2_200[2,,3], taskset_0_2_200[3,,3], taskset_0_2_200[4,,3], taskset_0_2_200[5,,3],taskset_3_6_200[1,,3], taskset_3_6_200[2,,3], taskset_3_6_200[3,,3], taskset_3_6_200[4,,3], taskset_3_6_200[5,,3], taskset_7_20_200[1,,3], taskset_7_20_200[2,,3], taskset_7_20_200[3,,3], taskset_7_20_200[4,,3], taskset_7_20_200[5,,3], 
#                 names=c("g1 0-2","g2 0-2","g3 0-2","g4 0-2","g5 0-2", "g1 3-6","g2 3-6","g3 3-6","g4 3-6","g5 3-6", "g1 7-20","g2 7-20","g3 7-20","g4 7-20","g5 7-20","g1 0-2_200","g2 0-2_200","g3 0-2_200","g4 0-2_200","g5 0-2_200", "g1 3-6_200","g2 3-6_200","g3 3-6_200","g4 3-6_200","g5 3-6_200", "g1 7-6_200","g2 7-6_200","g3 7-6_200","g4 7-6_200","g5 7-6_200"), scipen=5, main="FPS - EDF preemption", xlab="Taskset", ylab="FPS - EDF")
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# # print(min(armonic_0_2))
# # print(mean(armonic_0_2))
# # print(median(armonic_0_2))
# # print(max(armonic_0_2))
# # 
# # print(min(armonic_3_6))
# # print(mean(armonic_3_6))
# # print(median(armonic_3_6))
# # print(max(armonic_3_6))
# # 
# # print(min(armonic_7_20))
# # print(mean(armonic_7_20))
# # print(median(armonic_7_20))
# # print(max(armonic_7_20))
# # 
# # 
# # print(min(armonic_0_2_200))
# # print(mean(armonic_0_2_200))
# # print(median(armonic_0_2_200))
# # print(max(armonic_0_2_200))
# # 
# # print(min(armonic_3_6))
# # print(mean(armonic_3_6))
# # print(median(armonic_3_6))
# # print(max(armonic_3_6))
# # 
# # print(min(armonic_7_20_200))
# # print(mean(armonic_7_20_200))
# # print(median(armonic_7_20_200))
# # print(max(armonic_7_20_200))
# # 
# # 
# # 
# # res <- boxplot (work_0_2, work_3_6, work_7_20, work_0_2_200, work_3_6_200, work_7_20_200, names=c("0..2 armonici 10..100","3..6 armonici 10..100","7..20 armonici 10..100","0..2 armonici 10..200", "3_6 armonici 10..200", "7..20 armonici 10..200"), scipen=5, main="Utilizzazione Task con FPS Preemtpion < EDF Preemption", xlab="Task", ylab="Utilizzazione")
# # abline(h = 0.045, col = "red")
# # res$stats
# # 
# # 
# # 
# # res <- boxplot (priority_0_2, priority_3_6, priority_7_20, priority_0_2_200, priority_3_6_200, priority_7_20_200, names=c("0..2 armonici 10..100","3..6 armonici 10..100","7..20 armonici 10..100","0..2 armonici 10..200", "3_6 armonici 10..200", "7..20 armonici 10..200"), scipen=5, main="Priorità Task con FPS Preemtpion < EDF Preemption", xlab="Task", ylab="Priorità")
# # res$stats
# # 
# # 
# # 
# # 
# # max_priority = 10
# # min_utilization = 0.045
# # 
# # 
# # task_low_priority_high_work_0_2 = matrix(list(), nrow = index_0_2, ncol = 1)
# # index_lp_hw_0_2 = 1
# # number_jitter_fps_lower_edf_0_2 = 0
# # number_jitter_fps_higher_edf_0_2 = 0
# # list_jitter_fps_sub_edf_0_2 = vector()
# # number_jitter_fps_lower_edf_lp_hw_0_2 = 0
# # number_jitter_fps_higher_edf_lp_hw_0_2 = 0
# # list_jitter_fps_sub_edf_lp_hw_0_2 = vector()
# # for (i in 1:(index_0_2-1)){
# #   if (task_fps_win_0_2[[i,1]][2] <= max_priority  &  task_fps_win_0_2[[i,1]][13] >= min_utilization) {
# #     task_low_priority_high_work_0_2[[index_lp_hw_0_2,1]] <- task_fps_win_0_2[[i, 1]]
# #     index_lp_hw_0_2 <- index_lp_hw_0_2 + 1
# #     if (strtoi(task_fps_win_0_2[[i,1]][20], base = 0L) < strtoi(task_fps_win_0_2[[i,1]][25], base = 0L)){
# #       number_jitter_fps_lower_edf_lp_hw_0_2 <- number_jitter_fps_lower_edf_lp_hw_0_2 + 1
# #     }else{
# #       number_jitter_fps_higher_edf_lp_hw_0_2 <- number_jitter_fps_higher_edf_lp_hw_0_2 + 1
# #     }
# #     list_jitter_fps_sub_edf_lp_hw_0_2 <- append (list_jitter_fps_sub_edf_lp_hw_0_2, (strtoi(task_fps_win_0_2[[i,1]][25], base = 0L) - strtoi(task_fps_win_0_2[[i,1]][20], base = 0L)))
# #   }
# #   # }else{
# #   #   if (task_fps_win_70[[i,1]][13] <= avarage_work_time[2]){
# #   #     task_low_priority_low_work_70 [[index_lp_lw_70,1]] <- task_fps_win_70[[i, 1]]
# #   #     index_lp_lw_70 <- index_lp_lw_70 + 1
# #   #   }else{
# #   #     task_low_priority_high_work_70 [[index_lp_hw_70,1]] <- task_fps_win_70[[i, 1]]
# #   #     index_lp_hw_70 <- index_lp_hw_70 + 1
# #   #   }
# #   # }
# #   if (strtoi(task_fps_win_0_2[[i,1]][20], base = 0L) < strtoi(task_fps_win_0_2[[i,1]][25], base = 0L)){
# #     number_jitter_fps_lower_edf_0_2 <- number_jitter_fps_lower_edf_0_2 + 1
# #   }else{
# #     number_jitter_fps_higher_edf_0_2 <- number_jitter_fps_higher_edf_0_2 + 1
# #   }
# #   list_jitter_fps_sub_edf_0_2 <- append (list_jitter_fps_sub_edf_0_2, (strtoi(task_fps_win_0_2[[i,1]][25], base = 0L) - strtoi(task_fps_win_0_2[[i,1]][20], base = 0L)))
# # }
# # 
# # cat(sprintf("FPS 0_2 low priority high work: %s\n", index_lp_hw_0_2-1))
# # cat(sprintf("FPS avarage jitter for 0_2 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_0_2, number_jitter_fps_higher_edf_0_2, mean(list_jitter_fps_sub_edf_0_2), min (list_jitter_fps_sub_edf_0_2), max(list_jitter_fps_sub_edf_0_2)))
# # cat(sprintf("FPS avarage jitter for 0_2 group with low priority high utilization, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_lp_hw_0_2, number_jitter_fps_higher_edf_lp_hw_0_2, mean(list_jitter_fps_sub_edf_lp_hw_0_2), min (list_jitter_fps_sub_edf_lp_hw_0_2), max(list_jitter_fps_sub_edf_lp_hw_0_2)))
# # 
# # 
# # task_low_priority_high_work_3_6 = matrix(list(), nrow = index_3_6, ncol = 1)
# # index_lp_hw_3_6 = 1
# # number_jitter_fps_lower_edf_3_6 = 0
# # number_jitter_fps_higher_edf_3_6 = 0
# # list_jitter_fps_sub_edf_3_6 = vector()
# # number_jitter_fps_lower_edf_lp_hw_3_6 = 0
# # number_jitter_fps_higher_edf_lp_hw_3_6= 0
# # list_jitter_fps_sub_edf_lp_hw_3_6 = vector()
# # for (i in 1:(index_3_6-1)){
# #   if (task_fps_win_3_6[[i,1]][2] <= max_priority  &  task_fps_win_3_6[[i,1]][13] >= min_utilization) {
# #     task_low_priority_high_work_3_6[[index_lp_hw_3_6,1]] <- task_fps_win_3_6[[i, 1]]
# #     index_lp_hw_3_6 <- index_lp_hw_3_6 + 1
# #     if (strtoi(task_fps_win_3_6[[i,1]][20], base = 0L) < strtoi(task_fps_win_3_6[[i,1]][25], base = 0L)){
# #       number_jitter_fps_lower_edf_lp_hw_3_6 <- number_jitter_fps_lower_edf_lp_hw_3_6 + 1
# #     }else{
# #       number_jitter_fps_higher_edf_lp_hw_3_6 <- number_jitter_fps_higher_edf_lp_hw_3_6 + 1
# #     }
# #     list_jitter_fps_sub_edf_lp_hw_3_6 <- append (list_jitter_fps_sub_edf_lp_hw_3_6, (strtoi(task_fps_win_3_6[[i,1]][25], base = 0L) - strtoi(task_fps_win_3_6[[i,1]][20], base = 0L)))
# #   }
# #   # }else{
# #   #   if (task_fps_win_70[[i,1]][13] <= avarage_work_time[2]){
# #   #     task_low_priority_low_work_70 [[index_lp_lw_70,1]] <- task_fps_win_70[[i, 1]]
# #   #     index_lp_lw_70 <- index_lp_lw_70 + 1
# #   #   }else{
# #   #     task_low_priority_high_work_70 [[index_lp_hw_70,1]] <- task_fps_win_70[[i, 1]]
# #   #     index_lp_hw_70 <- index_lp_hw_70 + 1
# #   #   }
# #   # }
# #   if (strtoi(task_fps_win_3_6[[i,1]][20], base = 0L) < strtoi(task_fps_win_3_6[[i,1]][25], base = 0L)){
# #     number_jitter_fps_lower_edf_3_6 <- number_jitter_fps_lower_edf_3_6 + 1
# #   }else{
# #     number_jitter_fps_higher_edf_3_6 <- number_jitter_fps_higher_edf_3_6 + 1
# #   }
# #   list_jitter_fps_sub_edf_3_6 <- append (list_jitter_fps_sub_edf_3_6, (strtoi(task_fps_win_3_6[[i,1]][25], base = 0L) - strtoi(task_fps_win_3_6[[i,1]][20], base = 0L)))
# # }
# # cat(sprintf("FPS 3_6 low priority high work: %s\n", index_lp_hw_3_6-1))
# # cat(sprintf("FPS avarage jitter for 3_6 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_3_6, number_jitter_fps_higher_edf_3_6, mean(list_jitter_fps_sub_edf_3_6), min (list_jitter_fps_sub_edf_3_6), max(list_jitter_fps_sub_edf_3_6)))
# # cat(sprintf("FPS avarage jitter for 3_6 group with low priority high utilization, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_lp_hw_3_6, number_jitter_fps_higher_edf_lp_hw_3_6, mean(list_jitter_fps_sub_edf_lp_hw_3_6), min (list_jitter_fps_sub_edf_lp_hw_3_6), max(list_jitter_fps_sub_edf_lp_hw_3_6)))
# # 
# # 
# # task_low_priority_high_work_7_20 = matrix(list(), nrow = index_7_20, ncol = 1)
# # index_lp_hw_7_20 = 1
# # number_jitter_fps_lower_edf_7_20 = 0
# # number_jitter_fps_higher_edf_7_20 = 0
# # list_jitter_fps_sub_edf_7_20 = vector()
# # number_jitter_fps_lower_edf_lp_hw_7_20 = 0
# # number_jitter_fps_higher_edf_lp_hw_7_20= 0
# # list_jitter_fps_sub_edf_lp_hw_7_20 = vector()
# # for (i in 1:(index_7_20-1)){
# #   if (task_fps_win_7_20[[i,1]][2] <= max_priority  &  task_fps_win_7_20[[i,1]][13] >= min_utilization) { # 0.05175) {
# #     task_low_priority_high_work_7_20[[index_lp_hw_7_20,1]] <- task_fps_win_7_20[[i, 1]]
# #     index_lp_hw_7_20 <- index_lp_hw_7_20 + 1
# #     if (strtoi(task_fps_win_7_20[[i,1]][20], base = 0L) < strtoi(task_fps_win_7_20[[i,1]][25], base = 0L)){
# #       number_jitter_fps_lower_edf_lp_hw_7_20 <- number_jitter_fps_lower_edf_lp_hw_7_20 + 1
# #     }else{
# #       number_jitter_fps_higher_edf_lp_hw_7_20 <- number_jitter_fps_higher_edf_lp_hw_7_20 + 1
# #     }
# #     list_jitter_fps_sub_edf_lp_hw_7_20 <- append (list_jitter_fps_sub_edf_lp_hw_7_20, (strtoi(task_fps_win_7_20[[i,1]][25], base = 0L) - strtoi(task_fps_win_7_20[[i,1]][20], base = 0L)))
# #   }
# #   # }else{
# #   #   if (task_fps_win_70[[i,1]][13] <= avarage_work_time[2]){
# #   #     task_low_priority_low_work_70 [[index_lp_lw_70,1]] <- task_fps_win_70[[i, 1]]
# #   #     index_lp_lw_70 <- index_lp_lw_70 + 1
# #   #   }else{
# #   #     task_low_priority_high_work_70 [[index_lp_hw_70,1]] <- task_fps_win_70[[i, 1]]
# #   #     index_lp_hw_70 <- index_lp_hw_70 + 1
# #   #   }
# #   # }
# #   if (strtoi(task_fps_win_7_20[[i,1]][20], base = 0L) < strtoi(task_fps_win_7_20[[i,1]][25], base = 0L)){
# #     number_jitter_fps_lower_edf_7_20 <- number_jitter_fps_lower_edf_7_20 + 1
# #   }else{
# #     number_jitter_fps_higher_edf_7_20 <- number_jitter_fps_higher_edf_7_20 + 1
# #   }
# #   list_jitter_fps_sub_edf_7_20 <- append (list_jitter_fps_sub_edf_7_20, (strtoi(task_fps_win_7_20[[i,1]][25], base = 0L) - strtoi(task_fps_win_7_20[[i,1]][20], base = 0L)))
# # }
# # cat(sprintf("FPS 7_20 low priority high work: %s\n", index_lp_hw_7_20-1))
# # cat(sprintf("FPS avarage jitter for 7_20 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_7_20, number_jitter_fps_higher_edf_7_20, mean(list_jitter_fps_sub_edf_7_20), min (list_jitter_fps_sub_edf_7_20), max(list_jitter_fps_sub_edf_7_20)))
# # cat(sprintf("FPS avarage jitter for 7_20 group with low priority high utilization, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_lp_hw_7_20, number_jitter_fps_higher_edf_lp_hw_7_20, mean(list_jitter_fps_sub_edf_lp_hw_7_20), min (list_jitter_fps_sub_edf_lp_hw_7_20), max(list_jitter_fps_sub_edf_lp_hw_7_20)))
# # 
# # 
# # 
# # task_low_priority_high_work_0_2_200 = matrix(list(), nrow = index_0_2_200, ncol = 1)
# # index_lp_hw_0_2_200 = 1
# # number_jitter_fps_lower_edf_0_2_200 = 0
# # number_jitter_fps_higher_edf_0_2_200 = 0
# # list_jitter_fps_sub_edf_0_2_200 = vector()
# # number_jitter_fps_lower_edf_lp_hw_0_2_200 = 0
# # number_jitter_fps_higher_edf_lp_hw_0_2_200 = 0
# # list_jitter_fps_sub_edf_lp_hw_0_2_200 = vector()
# # for (i in 1:(index_0_2_200-1)){
# #   if (task_fps_win_0_2_200[[i,1]][2] <= max_priority  &  task_fps_win_0_2_200[[i,1]][13] >= min_utilization) {
# #     task_low_priority_high_work_0_2_200[[index_lp_hw_0_2_200,1]] <- task_fps_win_0_2_200[[i, 1]]
# #     index_lp_hw_0_2_200 <- index_lp_hw_0_2_200 + 1
# #     if (strtoi(task_fps_win_0_2_200[[i,1]][20], base = 0L) < strtoi(task_fps_win_0_2_200[[i,1]][25], base = 0L)){
# #       number_jitter_fps_lower_edf_lp_hw_0_2_200 <- number_jitter_fps_lower_edf_lp_hw_0_2_200 + 1
# #     }else{
# #       number_jitter_fps_higher_edf_lp_hw_0_2_200 <- number_jitter_fps_higher_edf_lp_hw_0_2_200 + 1
# #     }
# #     list_jitter_fps_sub_edf_lp_hw_0_2_200 <- append (list_jitter_fps_sub_edf_lp_hw_0_2_200, (strtoi(task_fps_win_0_2_200[[i,1]][25], base = 0L) - strtoi(task_fps_win_0_2_200[[i,1]][20], base = 0L)))
# #   }
# #   # }else{
# #   #   if (task_fps_win_70[[i,1]][13] <= avarage_work_time[2]){
# #   #     task_low_priority_low_work_70 [[index_lp_lw_70,1]] <- task_fps_win_70[[i, 1]]
# #   #     index_lp_lw_70 <- index_lp_lw_70 + 1
# #   #   }else{
# #   #     task_low_priority_high_work_70 [[index_lp_hw_70,1]] <- task_fps_win_70[[i, 1]]
# #   #     index_lp_hw_70 <- index_lp_hw_70 + 1
# #   #   }
# #   # }
# #   if (strtoi(task_fps_win_0_2_200[[i,1]][20], base = 0L) < strtoi(task_fps_win_0_2_200[[i,1]][25], base = 0L)){
# #     number_jitter_fps_lower_edf_0_2_200 <- number_jitter_fps_lower_edf_0_2_200 + 1
# #   }else{
# #     number_jitter_fps_higher_edf_0_2_200 <- number_jitter_fps_higher_edf_0_2_200 + 1
# #   }
# #   list_jitter_fps_sub_edf_0_2_200 <- append (list_jitter_fps_sub_edf_0_2_200, (strtoi(task_fps_win_0_2_200[[i,1]][25], base = 0L) - strtoi(task_fps_win_0_2_200[[i,1]][20], base = 0L)))
# # }
# # 
# # cat(sprintf("FPS 0_2_200 low priority high work: %s\n", index_lp_hw_0_2_200-1))
# # cat(sprintf("FPS avarage jitter for 0_2_200 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_0_2_200, number_jitter_fps_higher_edf_0_2_200, mean(list_jitter_fps_sub_edf_0_2_200), min (list_jitter_fps_sub_edf_0_2_200), max(list_jitter_fps_sub_edf_0_2_200)))
# # cat(sprintf("FPS avarage jitter for 0_2_200 group with low priority high utilization, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_lp_hw_0_2_200, number_jitter_fps_higher_edf_lp_hw_0_2_200, mean(list_jitter_fps_sub_edf_lp_hw_0_2_200), min (list_jitter_fps_sub_edf_lp_hw_0_2_200), max(list_jitter_fps_sub_edf_lp_hw_0_2_200)))
# # 
# # 
# # task_low_priority_high_work_3_6_200 = matrix(list(), nrow = index_3_6_200, ncol = 1)
# # index_lp_hw_3_6_200 = 1
# # number_jitter_fps_lower_edf_3_6_200 = 0
# # number_jitter_fps_higher_edf_3_6_200 = 0
# # list_jitter_fps_sub_edf_3_6_200 = vector()
# # number_jitter_fps_lower_edf_lp_hw_3_6_200 = 0
# # number_jitter_fps_higher_edf_lp_hw_3_6_200 = 0
# # list_jitter_fps_sub_edf_lp_hw_3_6_200 = vector()
# # for (i in 1:(index_3_6_200-1)){
# #   if (task_fps_win_3_6_200[[i,1]][2] <= max_priority  &  task_fps_win_3_6_200[[i,1]][13] >= min_utilization) {
# #     task_low_priority_high_work_3_6_200[[index_lp_hw_3_6_200,1]] <- task_fps_win_3_6_200[[i, 1]]
# #     index_lp_hw_3_6_200 <- index_lp_hw_3_6_200 + 1
# #     if (strtoi(task_fps_win_3_6_200[[i,1]][20], base = 0L) < strtoi(task_fps_win_3_6_200[[i,1]][25], base = 0L)){
# #       number_jitter_fps_lower_edf_lp_hw_3_6_200 <- number_jitter_fps_lower_edf_lp_hw_3_6_200 + 1
# #     }else{
# #       number_jitter_fps_higher_edf_lp_hw_3_6_200 <- number_jitter_fps_higher_edf_lp_hw_3_6_200 + 1
# #     }
# #     list_jitter_fps_sub_edf_lp_hw_3_6_200 <- append (list_jitter_fps_sub_edf_lp_hw_3_6_200, (strtoi(task_fps_win_3_6_200[[i,1]][25], base = 0L) - strtoi(task_fps_win_3_6_200[[i,1]][20], base = 0L)))
# #   }
# #   # }else{
# #   #   if (task_fps_win_70[[i,1]][13] <= avarage_work_time[2]){
# #   #     task_low_priority_low_work_70 [[index_lp_lw_70,1]] <- task_fps_win_70[[i, 1]]
# #   #     index_lp_lw_70 <- index_lp_lw_70 + 1
# #   #   }else{
# #   #     task_low_priority_high_work_70 [[index_lp_hw_70,1]] <- task_fps_win_70[[i, 1]]
# #   #     index_lp_hw_70 <- index_lp_hw_70 + 1
# #   #   }
# #   # }
# #   if (strtoi(task_fps_win_3_6_200[[i,1]][20], base = 0L) < strtoi(task_fps_win_3_6_200[[i,1]][25], base = 0L)){
# #     number_jitter_fps_lower_edf_3_6_200 <- number_jitter_fps_lower_edf_3_6_200 + 1
# #   }else{
# #     number_jitter_fps_higher_edf_3_6_200 <- number_jitter_fps_higher_edf_3_6_200 + 1
# #   }
# #   list_jitter_fps_sub_edf_3_6_200 <- append (list_jitter_fps_sub_edf_3_6_200, (strtoi(task_fps_win_3_6_200[[i,1]][25], base = 0L) - strtoi(task_fps_win_3_6_200[[i,1]][20], base = 0L)))
# # }
# # 
# # cat(sprintf("FPS 3_6_200 low priority high work: %s\n", index_lp_hw_3_6_200-1))
# # cat(sprintf("FPS avarage jitter for 3_6_200 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_3_6_200, number_jitter_fps_higher_edf_3_6_200, mean(list_jitter_fps_sub_edf_3_6_200), min (list_jitter_fps_sub_edf_3_6_200), max(list_jitter_fps_sub_edf_3_6_200)))
# # cat(sprintf("FPS avarage jitter for 3_6_200 group with low priority high utilization, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_lp_hw_3_6_200, number_jitter_fps_higher_edf_lp_hw_3_6_200, mean(list_jitter_fps_sub_edf_lp_hw_3_6_200), min (list_jitter_fps_sub_edf_lp_hw_3_6_200), max(list_jitter_fps_sub_edf_lp_hw_3_6_200)))
# # 
# # 
# # 
# # task_low_priority_high_work_7_20_200 = matrix(list(), nrow = index_7_20_200, ncol = 1)
# # index_lp_hw_7_20_200 = 1
# # number_jitter_fps_lower_edf_7_20_200 = 0
# # number_jitter_fps_higher_edf_7_20_200 = 0
# # list_jitter_fps_sub_edf_7_20_200 = vector()
# # number_jitter_fps_lower_edf_lp_hw_7_20_200 = 0
# # number_jitter_fps_higher_edf_lp_hw_7_20_200 = 0
# # list_jitter_fps_sub_edf_lp_hw_7_20_200 = vector()
# # for (i in 1:(index_7_20_200-1)){
# #   if (task_fps_win_7_20_200[[i,1]][2] <= max_priority  &  task_fps_win_7_20_200[[i,1]][13] >= min_utilization) {
# #     task_low_priority_high_work_7_20_200[[index_lp_hw_7_20_200,1]] <- task_fps_win_7_20_200[[i, 1]]
# #     index_lp_hw_7_20_200 <- index_lp_hw_7_20_200 + 1
# #     if (strtoi(task_fps_win_7_20_200[[i,1]][20], base = 0L) < strtoi(task_fps_win_7_20_200[[i,1]][25], base = 0L)){
# #       number_jitter_fps_lower_edf_lp_hw_7_20_200 <- number_jitter_fps_lower_edf_lp_hw_7_20_200 + 1
# #     }else{
# #       number_jitter_fps_higher_edf_lp_hw_7_20_200 <- number_jitter_fps_higher_edf_lp_hw_7_20_200 + 1
# #     }
# #     list_jitter_fps_sub_edf_lp_hw_7_20_200 <- append (list_jitter_fps_sub_edf_lp_hw_7_20_200, (strtoi(task_fps_win_7_20_200[[i,1]][25], base = 0L) - strtoi(task_fps_win_7_20_200[[i,1]][20], base = 0L)))
# #   }
# #   # }else{
# #   #   if (task_fps_win_70[[i,1]][13] <= avarage_work_time[2]){
# #   #     task_low_priority_low_work_70 [[index_lp_lw_70,1]] <- task_fps_win_70[[i, 1]]
# #   #     index_lp_lw_70 <- index_lp_lw_70 + 1
# #   #   }else{
# #   #     task_low_priority_high_work_70 [[index_lp_hw_70,1]] <- task_fps_win_70[[i, 1]]
# #   #     index_lp_hw_70 <- index_lp_hw_70 + 1
# #   #   }
# #   # }
# #   if (strtoi(task_fps_win_7_20_200[[i,1]][20], base = 0L) < strtoi(task_fps_win_7_20_200[[i,1]][25], base = 0L)){
# #     number_jitter_fps_lower_edf_7_20_200 <- number_jitter_fps_lower_edf_7_20_200 + 1
# #   }else{
# #     number_jitter_fps_higher_edf_7_20_200 <- number_jitter_fps_higher_edf_7_20_200 + 1
# #   }
# #   list_jitter_fps_sub_edf_7_20_200 <- append (list_jitter_fps_sub_edf_7_20_200, (strtoi(task_fps_win_7_20_200[[i,1]][25], base = 0L) - strtoi(task_fps_win_7_20_200[[i,1]][20], base = 0L)))
# # }
# # 
# # cat(sprintf("FPS 7_20_200 low priority high work: %s\n", index_lp_hw_7_20_200-1))
# # cat(sprintf("FPS avarage jitter for 7_20_200 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_7_20_200, number_jitter_fps_higher_edf_7_20_200, mean(list_jitter_fps_sub_edf_7_20_200), min (list_jitter_fps_sub_edf_7_20_200), max(list_jitter_fps_sub_edf_7_20_200)))
# # cat(sprintf("FPS avarage jitter for 7_20_200 group with low priority high utilization, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_lp_hw_7_20_200, number_jitter_fps_higher_edf_lp_hw_7_20_200, mean(list_jitter_fps_sub_edf_lp_hw_7_20_200), min (list_jitter_fps_sub_edf_lp_hw_7_20_200), max(list_jitter_fps_sub_edf_lp_hw_7_20_200)))
# # 
# # 
# # 
# # res <- boxplot (list_jitter_fps_sub_edf_lp_hw_0_2, list_jitter_fps_sub_edf_lp_hw_3_6, list_jitter_fps_sub_edf_lp_hw_7_20, list_jitter_fps_sub_edf_lp_hw_0_2_200, list_jitter_fps_sub_edf_lp_hw_3_6_200, list_jitter_fps_sub_edf_lp_hw_7_20_200, names=c("0..2 armonici 10..100","3..6 armonici 10..100","7..20 armonici 10..100","0..2 armonici 10..200", "3_6 armonici 10..200", "7..20 armonici 10..200"), scipen=20, main="Confronto Jitter medio Task con FPS Preemtpion < EDF Preemption: Priorità 1, Utilizzazione 1", xlab="Task", ylab="Jitter EDF medio - Jitter FPS medio", ylim = c(-500000,500000))
# # abline(h = 0, col = "red")
# # res$stats