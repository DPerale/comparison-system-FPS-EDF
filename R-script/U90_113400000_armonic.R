taskset_0_2_jitter = array (integer(), dim = c(4,500,20))

for (i in 1:500){
  file_name <- paste("../taskset-experiments/U_90_hyper_113400000_0_2_armonic_10_100/U_90_hyper_113400000_0_2_armonic_10_100_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  print(i)
  for (j in 1:20){
    # response FPS
    taskset_0_2_jitter [1,i,j]  <- (((strtoi(file_to_open[j,17]) - strtoi(file_to_open[j,16]))/180)/strtoi(file_to_open[j,3]))
    # release FPS
    taskset_0_2_jitter [2,i,j]  <- (((strtoi(file_to_open[j,19]) - strtoi(file_to_open[j,18]))/180)/strtoi(file_to_open[j,3]))
    # response EDF
    taskset_0_2_jitter [3,i,j]  <- (((strtoi(file_to_open[j,22]) - strtoi(file_to_open[j,21]))/180)/strtoi(file_to_open[j,3]))
    # release EDF
    taskset_0_2_jitter [4,i,j]  <- (((strtoi(file_to_open[j,24]) - strtoi(file_to_open[j,23]))/180)/strtoi(file_to_open[j,3]))
  }
}

taskset_0_2_jitter_avarages = array (integer(), dim = c(4,20))
for (i in 1:20){
  taskset_0_2_jitter_avarages [1,i] <- mean (taskset_0_2_jitter [1,,i])
  taskset_0_2_jitter_avarages [2,i] <- mean (taskset_0_2_jitter [2,,i])
  taskset_0_2_jitter_avarages [3,i] <- mean (taskset_0_2_jitter [3,,i])
  taskset_0_2_jitter_avarages [4,i] <- mean (taskset_0_2_jitter [4,,i])
}

X <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20)
print(taskset_0_2_jitter_avarages[2,])

plot(X, taskset_0_2_jitter_avarages [2,], xlab="Tasks", ylab="Normalized Release Jitter",  col="red",type="o", pch="*", lty=1)
lines(X, taskset_0_2_jitter_avarages [4,], col="blue",type="o",lty=2)
legend("topleft",legend=c("EDF","FPS"), col=c("blue","red"), pch=c("o","*"),lty=c(1,2), ncol=1)

plot(X, taskset_0_2_jitter_avarages [1,], xlab="Tasks", ylab="Normalized Response Jitter", col="red",type="o", pch="*", lty=1)
lines(X, taskset_0_2_jitter_avarages [3,], col="blue", type="o",lty=2)
legend("topleft",legend=c("EDF","FPS"), col=c("blue","red"), pch=c("o","*"),lty=c(1,2), ncol=1)

for(i in 1:50){
  plot(X, taskset_0_2_jitter [2,i,], xlab="Tasks", ylab="Normalized Release Jitter",  col="red",type="o", pch="*", lty=1)
  lines(X, taskset_0_2_jitter [4,i,], col="blue",type="o",lty=2)
  legend("topleft",legend=c("EDF","FPS"), col=c("blue","red"), pch=c("o","*"),lty=c(1,2), ncol=1)
}


######################################################

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
                names=c("1-g1","1-g2","1-g3","1-g4","1-g5", "2-g1","2-g2","2-g3","2-g4","2-g5", "3-g1","3-g2","3-g3","3-g4","3-g5"), scipen=5, xlab="Taskset", ylab="FPS preemption")
abline(h = 0.36, col = "red")
abline(h = 0.40, col = "red")
res$stats

# Iperperiodo
res <- boxplot (taskset_0_2[1,,9], taskset_0_2[2,,9], taskset_0_2[3,,9], taskset_0_2[4,,9], taskset_0_2[5,,9],taskset_3_6[1,,9], taskset_3_6[2,,9], taskset_3_6[3,,9], taskset_3_6[4,,9], taskset_3_6[5,,9], taskset_7_20[1,,9], taskset_7_20[2,,9], taskset_7_20[3,,9], taskset_7_20[4,,9], taskset_7_20[5,,9],
                names=c("1-g1","1-g2","1-g3","1-g4","1-g5", "2-g1","2-g2","2-g3","2-g4","2-g5", "3-g1","3-g2","3-g3","3-g4","3-g5"), scipen=5, xlab="Taskset", ylab="Hyperperiod")

# Armonicità %
res <- boxplot (taskset_0_2[1,,8], taskset_0_2[2,,8], taskset_0_2[3,,8], taskset_0_2[4,,8], taskset_0_2[5,,8],taskset_3_6[1,,8], taskset_3_6[2,,8], taskset_3_6[3,,8], taskset_3_6[4,,8], taskset_3_6[5,,8], taskset_7_20[1,,8], taskset_7_20[2,,8], taskset_7_20[3,,8], taskset_7_20[4,,8], taskset_7_20[5,,8],
                names=c("1-g1","1-g2","1-g3","1-g4","1-g5", "2-g1","2-g2","2-g3","2-g4","2-g5", "3-g1","3-g2","3-g3","3-g4","3-g5"), scipen=5, xlab="Taskset", ylab="(Simultaneos Releases) / (Possible Releases)")
abline(h = 0.36, col = "red")
abline(h = 0.40, col = "red")
res$stats

# Media periodi per gruppo
res <- boxplot (taskset_0_2[1,,5], taskset_0_2[2,,5], taskset_0_2[3,,5], taskset_0_2[4,,5], taskset_0_2[5,,5],taskset_3_6[1,,5], taskset_3_6[2,,5], taskset_3_6[3,,5], taskset_3_6[4,,5], taskset_3_6[5,,5], taskset_7_20[1,,5], taskset_7_20[2,,5], taskset_7_20[3,,5], taskset_7_20[4,,5], taskset_7_20[5,,5],
                names=c("1-g1","1-g2","1-g3","1-g4","1-g5", "2-g1","2-g2","2-g3","2-g4","2-g5", "3-g1","3-g2","3-g3","3-g4","3-g5"), scipen=5, xlab="Taskset", ylab="Avarage Periods")

# FPS-EDF preemptions %
res <- boxplot (taskset_0_2[1,,7], taskset_0_2[2,,7], taskset_0_2[3,,7], taskset_0_2[4,,7], taskset_0_2[5,,7],taskset_3_6[1,,7], taskset_3_6[2,,7], taskset_3_6[3,,7], taskset_3_6[4,,7], taskset_3_6[5,,7], taskset_7_20[1,,7], taskset_7_20[2,,7], taskset_7_20[3,,7], taskset_7_20[4,,7], taskset_7_20[5,,7],
                names=c("1-g1","1-g2","1-g3","1-g4","1-g5", "2-g1","2-g2","2-g3","2-g4","2-g5", "3-g1","3-g2","3-g3","3-g4","3-g5"), scipen=5, xlab="Taskset", ylab="(P-FPS  Minus  P-EDF) / (P-FPS)")

lines(1:15, res$stats[1,], col="blue", lwd=2)
lines(1:15, res$stats[3,], col="red", lwd=2)
lines(1:15, res$stats[5,], col="green", lwd=2)

#############################################################


taskset_0_2_200 = array (integer(), dim = c(5,1000,10))

for (i in 1:500){
  file_name <- paste("../taskset-experiments/U_90_hyper_113400000_0_2_armonic_10_200/U_90_hyper_113400000_0_2_armonic_10_200_", c(i), ".csv", sep = "")
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
  taskset_0_2_200 [tn,i,1]  <- file_to_open[21,8]
  taskset_0_2_200 [tn,i,2]  <- file_to_open[21,12]
  taskset_0_2_200 [tn,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
  taskset_0_2_200 [tn,i,4]  <- i
  taskset_0_2_200 [tn,i,5]  <- sumperiod/20
  taskset_0_2_200 [tn,i,6] <- armonicity_number
  taskset_0_2_200 [tn,i,7] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
  taskset_0_2_200 [tn,i,8] <- (armonicity_number / dimensions)
  taskset_0_2_200 [tn,i,9] <- file_to_open[21,3]
  taskset_0_2_200 [tn,i,10] <- counter
}



taskset_3_6_200 = array (integer(), dim = c(5,1000,10))

for (i in 1:500){
  file_name <- paste("../taskset-experiments/U_90_hyper_113400000_3_6_armonic_10_200/U_90_hyper_113400000_3_6_armonic_10_200_", c(i), ".csv", sep = "")
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
  taskset_3_6_200 [tn,i,1]  <- file_to_open[21,8]
  taskset_3_6_200 [tn,i,2]  <- file_to_open[21,12]
  taskset_3_6_200 [tn,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
  taskset_3_6_200 [tn,i,4]  <- i
  taskset_3_6_200 [tn,i,5]  <- sumperiod/20
  taskset_3_6_200 [tn,i,6] <- armonicity_number
  taskset_3_6_200 [tn,i,7] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
  taskset_3_6_200 [tn,i,8] <- (armonicity_number / dimensions)
  taskset_3_6_200 [tn,i,9] <- file_to_open[21,3]
  taskset_3_6_200 [tn,i,10] <- counter

}

taskset_7_20_200 = array (integer(), dim = c(5,1000,10))

for (i in 1:500){
  file_name <- paste("../taskset-experiments/U_90_hyper_113400000_7_20_armonic_10_200/U_90_hyper_113400000_7_20_armonic_10_200_", c(i), ".csv", sep = "")
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
  taskset_7_20_200 [tn,i,1]  <- file_to_open[21,8]
  taskset_7_20_200 [tn,i,2]  <- file_to_open[21,12]
  taskset_7_20_200 [tn,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
  taskset_7_20_200 [tn,i,4]  <- i
  taskset_7_20_200 [tn,i,5]  <- sumperiod/20
  taskset_7_20_200 [tn,i,6] <- armonicity_number
  taskset_7_20_200 [tn,i,7] <- ((strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8]))
  taskset_7_20_200 [tn,i,8] <- (armonicity_number / dimensions)
  taskset_7_20_200 [tn,i,9] <- file_to_open[21,3]
  taskset_7_20_200 [tn,i,10] <- counter

}


#############################################################

# Numero preemption per gruppo
res <- boxplot (taskset_0_2_200[1,,1], taskset_0_2_200[2,,1], taskset_0_2_200[3,,1], taskset_0_2_200[4,,1], taskset_0_2_200[5,,1],taskset_3_6_200[1,,1], taskset_3_6_200[2,,1], taskset_3_6_200[3,,1], taskset_3_6_200[4,,1], taskset_3_6_200[5,,1], taskset_7_20_200[1,,1], taskset_7_20_200[2,,1], taskset_7_20_200[3,,1], taskset_7_20_200[4,,1], taskset_7_20_200[5,,1],
                names=c("4-g1","4-g2","4-g3","4-g4","4-g5", "5-g1","5-g2","5-g3","5-g4","5-g5", "6-g1","6-g2","6-g3","6-g4","6-g5"), scipen=5, xlab="Taskset", ylab="FPS preemption")
abline(h = 10000, col = "red")
abline(h = 15000, col = "red")
abline(h = 20000, col = "red")
abline(h = 25000, col = "red")
res$stats

# Iperperiodo
res <- boxplot (taskset_0_2_200[1,,9], taskset_0_2_200[2,,9], taskset_0_2_200[3,,9], taskset_0_2_200[4,,9], taskset_0_2_200[5,,9],taskset_3_6_200[1,,9], taskset_3_6_200[2,,9], taskset_3_6_200[3,,9], taskset_3_6_200[4,,9], taskset_3_6_200[5,,9], taskset_7_20_200[1,,9], taskset_7_20_200[2,,9], taskset_7_20_200[3,,9], taskset_7_20_200[4,,9], taskset_7_20_200[5,,9],
                names=c("4-g1","4-g2","4-g3","4-g4","4-g5", "5-g1","5-g2","5-g3","5-g4","5-g5", "6-g1","6-g2","6-g3","6-g4","6-g5"), scipen=5, xlab="Taskset", ylab="Hyperperiod")

# Armonicità %
res <- boxplot (taskset_0_2_200[1,,8], taskset_0_2_200[2,,8], taskset_0_2_200[3,,8], taskset_0_2_200[4,,8], taskset_0_2_200[5,,8],taskset_3_6_200[1,,8], taskset_3_6_200[2,,8], taskset_3_6_200[3,,8], taskset_3_6_200[4,,8], taskset_3_6_200[5,,8], taskset_7_20_200[1,,8], taskset_7_20_200[2,,8], taskset_7_20_200[3,,8], taskset_7_20_200[4,,8], taskset_7_20_200[5,,8],
                names=c("4-g1","4-g2","4-g3","4-g4","4-g5", "5-g1","5-g2","5-g3","5-g4","5-g5", "6-g1","6-g2","6-g3","6-g4","6-g5"), scipen=5, xlab="Taskset", ylab="(Simultaneos Releases) / (Possible Releases)")
abline(h = 0.36, col = "red")
abline(h = 0.40, col = "red")
res$stats

# Media periodi per gruppo
res <- boxplot (taskset_0_2_200[1,,5], taskset_0_2_200[2,,5], taskset_0_2_200[3,,5], taskset_0_2_200[4,,5], taskset_0_2_200[5,,5],taskset_3_6_200[1,,5], taskset_3_6_200[2,,5], taskset_3_6_200[3,,5], taskset_3_6_200[4,,5], taskset_3_6_200[5,,5], taskset_7_20_200[1,,5], taskset_7_20_200[2,,5], taskset_7_20_200[3,,5], taskset_7_20_200[4,,5], taskset_7_20_200[5,,5],
                names=c("4-g1","4-g2","4-g3","4-g4","4-g5", "5-g1","5-g2","5-g3","5-g4","5-g5", "6-g1","6-g2","6-g3","6-g4","6-g5"), scipen=5, xlab="Taskset", ylab="Avarage Periods")

# FPS-EDF preemptions %
res <- boxplot (taskset_0_2_200[1,,7], taskset_0_2_200[2,,7], taskset_0_2_200[3,,7], taskset_0_2_200[4,,7], taskset_0_2_200[5,,7],taskset_3_6_200[1,,7], taskset_3_6_200[2,,7], taskset_3_6_200[3,,7], taskset_3_6_200[4,,7], taskset_3_6_200[5,,7], taskset_7_20_200[1,,7], taskset_7_20_200[2,,7], taskset_7_20_200[3,,7], taskset_7_20_200[4,,7], taskset_7_20_200[5,,7],
                names=c("4-g1","4-g2","4-g3","4-g4","4-g5", "5-g1","5-g2","5-g3","5-g4","5-g5", "6-g1","6-g2","6-g3","6-g4","6-g5"), scipen=5, xlab="Taskset", ylab="(P-FPS  Minus  P-EDF) / (P-FPS)")

lines(1:15, res$stats[1,], col="blue", lwd=2)
lines(1:15, res$stats[3,], col="red", lwd=2)
lines(1:15, res$stats[5,], col="green", lwd=2)

res <- boxplot (taskset_0_2[1,,7], taskset_0_2[2,,7], taskset_0_2[3,,7], taskset_0_2[4,,7], taskset_0_2[5,,7],taskset_3_6[1,,7], taskset_3_6[2,,7], taskset_3_6[3,,7], taskset_3_6[4,,7], taskset_3_6[5,,7], taskset_7_20[1,,7], taskset_7_20[2,,7], taskset_7_20[3,,7], taskset_7_20[4,,7], taskset_7_20[5,,7], taskset_0_2_200[1,,7], taskset_0_2_200[2,,7], taskset_0_2_200[3,,7], taskset_0_2_200[4,,7], taskset_0_2_200[5,,7],taskset_3_6_200[1,,7], taskset_3_6_200[2,,7], taskset_3_6_200[3,,7], taskset_3_6_200[4,,7], taskset_3_6_200[5,,7], taskset_7_20_200[1,,7], taskset_7_20_200[2,,7], taskset_7_20_200[3,,7], taskset_7_20_200[4,,7], taskset_7_20_200[5,,7],
                names=c("1-g1","1-g2","1-g3","1-g4","1-g5", "2-g1","2-g2","2-g3","2-g4","2-g5", "3-g1","3-g2","3-g3","3-g4","3-g5","4-g1","4-g2","4-g3","4-g4","4-g5", "5-g1","5-g2","5-g3","5-g4","5-g5", "6-g1","6-g2","6-g3","6-g4","6-g5"), scipen=5, xlab="Taskset", ylab="(P-FPS  Minus  P-EDF) / (P-FPS)")

lines(1:30, res$stats[1,], col="blue", lwd=2)
lines(1:30, res$stats[3,], col="red", lwd=2)
lines(1:30, res$stats[5,], col="green", lwd=2)

