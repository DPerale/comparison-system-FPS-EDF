taskset = array (integer(), dim = c(5,1000,9))


task_fps_win_0_2 = matrix(list(), nrow = 10000, ncol = 1)
index_0_2  = 1
armonic_0_2 = vector()
work_0_2 = vector ()
priority_0_2 = vector ()
for (i in 1:500){
  file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/U_90_hyper_113400000_0_2_armonic_10_100/U_90_hyper_113400000_0_2_armonic_10_100_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  for (l in 1:20){
    if (file_to_open[l,9]<0){
      temp = vector()
      temp <- append (file_to_open[l,], i)
      task_fps_win_0_2 [[index_0_2,1]] <- temp
      work_0_2 <- append(work_0_2, file_to_open[l,13]) 
      priority_0_2 <- append(priority_0_2, file_to_open[l,2])
      index_0_2 <- index_0_2 + 1
    }
  }
  armonic = vector()
  for (l in 20:2){
    for (m in 1:(l-1)){
      if ((file_to_open[l,3]%%file_to_open[m,3]) == 0){
        armonic <- append(armonic, file_to_open[l,3])  
        armonic <- append(armonic, file_to_open[m,3])  
      }
    }
  }
  armonic_0_2 <- append (armonic_0_2, length(unique(armonic)))
  
  long = 0
  medium = 0
  short = 0
  sumperiod = 0
  for (l in 20:1){
    sumperiod = sumperiod + strtoi(file_to_open[l,3])
    if (file_to_open[l,3] <= 40000){
      short = short + 1
    }else{
      if (file_to_open[l,3] >= 70000){
        long = long + 1
      }else{
        medium = medium + 1
      }
    }
  }
  if (strtoi(file_to_open[21,8]) < 10874){
    taskset [1,i,1]  <- file_to_open[21,8]
    taskset [1,i,2]  <- file_to_open[21,12]
    taskset [1,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
    taskset [1,i,4]  <- i
    taskset [1,i,5]  <- length(unique(armonic))
    taskset [1,i,6]  <- short
    taskset [1,i,7]  <- medium
    taskset [1,i,8]  <- long
    taskset [1,i,9]  <- sumperiod
  }
  if (strtoi(file_to_open[21,8]) > 10874 & strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) <= 14874){
    taskset [2,i,1]  <- file_to_open[21,8]
    taskset [2,i,2]  <- file_to_open[21,12]
    taskset [2,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
    taskset [2,i,4]  <- i
    taskset [2,i,5]  <- length(unique(armonic))
    taskset [2,i,6]  <- short
    taskset [2,i,7]  <- medium
    taskset [2,i,8]  <- long
    taskset [2,i,9]  <- sumperiod
  }
  if (strtoi(file_to_open[21,8]) > 14874 & strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) <= 18874){
    taskset [3,i,1]  <- file_to_open[21,8]
    taskset [3,i,2]  <- file_to_open[21,12]
    taskset [3,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
    taskset [3,i,4]  <- i
    taskset [3,i,5]  <- length(unique(armonic))
    taskset [3,i,6]  <- short
    taskset [3,i,7]  <- medium
    taskset [3,i,8]  <- long
    taskset [3,i,9]  <- sumperiod  
  }
  if (strtoi(file_to_open[21,8]) > 18874 & strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) <= 22874){
    taskset [4,i,1]  <- file_to_open[21,8]
    taskset [4,i,2]  <- file_to_open[21,12]
    taskset [4,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
    taskset [4,i,4]  <- i
    taskset [4,i,5]  <- length(unique(armonic))
    taskset [4,i,6]  <- short
    taskset [4,i,7]  <- medium
    taskset [4,i,8]  <- long
    taskset [4,i,9]  <- sumperiod
  }
  if (strtoi(file_to_open[21,8]) > 22874){
    taskset [5,i,1]  <- file_to_open[21,8]
    taskset [5,i,2]  <- file_to_open[21,12]
    taskset [5,i,3]  <- (strtoi(file_to_open[21,8]) - strtoi(file_to_open[21,12]))
    taskset [5,i,4]  <- i
    taskset [5,i,5]  <- length(unique(armonic))
    taskset [5,i,6]  <- short
    taskset [5,i,7]  <- medium
    taskset [5,i,8]  <- long
    taskset [5,i,9]  <- sumperiod
  }
  
}

# # short mid long
# res <- boxplot (taskset[1,,6], taskset[1,,7], taskset[1,,8], taskset[2,,6], taskset[2,,7], taskset[2,,8], taskset[3,,6], taskset[3,,7], taskset[3,,8], taskset[4,,6], taskset[4,,7], taskset[4,,8], taskset[5,,6], taskset[5,,7], taskset[5,,8], names=c("short g1","medium g1","long g1", "short g2","medium g2","long g2", "short g3","medium g3","long g3", "short g4","medium g4","long g4", "short g5","medium g5","long g5"), scipen=5, main="tipo task per gruppo", xlab="Task", ylab="quantità")
# abline(h = 7, col = "red")
# res$stats

# # short mid long
# res <- boxplot (taskset[1,,9], taskset[2,,9], taskset[3,,9], taskset[4,,9], taskset[5,,9], names=c("g1","g2","g3", "g4","g5"), scipen=5, main="tipo task per gruppo", xlab="Task", ylab="quantità")
# abline(h = 7, col = "red")
# res$stats

# fps preemption - edf preemption
res <- boxplot (taskset[1,,3], taskset[2,,3], taskset[3,,3], taskset[4,,3], taskset[5,,3], names=c("gruppo 1","gruppo 2","gruppo 3","gruppo 4","gruppo 5"), scipen=5, main="FPS Preemtpion - EDF Preemption", xlab="Task", ylab="Differenza preemption")
abline(h = 15, col = "red")
res$stats


task_fps_win_3_6 = matrix(list(), nrow = 10000, ncol = 1)
index_3_6  = 1
armonic_3_6 = vector()
work_3_6 = vector ()
priority_3_6 = vector ()
for (i in 1:500){
  file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/U_90_hyper_113400000_3_6_armonic_10_100/U_90_hyper_113400000_3_6_armonic_10_100_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  for (l in 1:20){
    if (file_to_open[l,9]<0){
      temp = vector()
      temp <- append (file_to_open[l,], i)
      task_fps_win_3_6 [[index_3_6,1]] <- temp
      work_3_6 <- append(work_3_6, file_to_open[l,13]) 
      priority_3_6 <- append(priority_3_6, file_to_open[l,2])
      index_3_6 <- index_3_6 + 1
    }
  }
  armonic = vector()
  for (l in 20:2){
    for (m in 1:(l-1)){
      if ((file_to_open[l,3]%%file_to_open[m,3]) == 0){
        armonic <- append(armonic, file_to_open[l,3])  
        armonic <- append(armonic, file_to_open[m,3])  
      }
    }
  }
  armonic_3_6 <- append (armonic_3_6, length(unique(armonic)))
}


task_fps_win_7_20 = matrix(list(), nrow = 10000, ncol = 1)
index_7_20  = 1
armonic_7_20 = vector()
work_7_20 = vector ()
priority_7_20 = vector ()
for (i in 1:500){
  file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/U_90_hyper_113400000_7_20_armonic_10_100/U_90_hyper_113400000_7_20_armonic_10_100_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  for (l in 1:20){
    if (file_to_open[l,9]<0){
      temp = vector()
      temp <- append (file_to_open[l,], i)
      task_fps_win_7_20 [[index_7_20,1]] <- temp
      work_7_20 <- append(work_7_20, file_to_open[l,13]) 
      priority_7_20 <- append(priority_7_20, file_to_open[l,2])
      index_7_20 <- index_7_20 + 1
    }
  }
  armonic = vector()
  for (l in 20:2){
    for (m in 1:(l-1)){
      if ((file_to_open[l,3]%%file_to_open[m,3]) == 0){
        armonic <- append(armonic, file_to_open[l,3])  
        armonic <- append(armonic, file_to_open[m,3])  
      }
    }
  }
  armonic_7_20 <- append (armonic_7_20, length(unique(armonic)))
}


task_fps_win_0_2_200 = matrix(list(), nrow = 10000, ncol = 1)
index_0_2_200  = 1
armonic_0_2_200 = vector()
work_0_2_200 = vector ()
priority_0_2_200 = vector ()
for (i in 1:500){
  file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/U_90_hyper_113400000_0_2_armonic_10_200/U_90_hyper_113400000_0_2_armonic_10_200_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  for (l in 1:20){
    if (file_to_open[l,9]<0){
      temp = vector()
      temp <- append (file_to_open[l,], i)
      task_fps_win_0_2_200 [[index_0_2_200,1]] <- temp
      work_0_2_200 <- append(work_0_2_200, file_to_open[l,13]) 
      priority_0_2_200 <- append(priority_0_2_200, file_to_open[l,2])
      index_0_2_200 <- index_0_2_200 + 1
    }
  }
  armonic = vector()
  for (l in 20:2){
    for (m in 1:(l-1)){
      if ((file_to_open[l,3]%%file_to_open[m,3]) == 0){
        armonic <- append(armonic, file_to_open[l,3])  
        armonic <- append(armonic, file_to_open[m,3])  
      }
    }
  }
  armonic_0_2_200 <- append (armonic_0_2_200, length(unique(armonic)))
}


task_fps_win_3_6_200 = matrix(list(), nrow = 10000, ncol = 1)
index_3_6_200  = 1
armonic_3_6_200 = vector()
work_3_6_200 = vector ()
priority_3_6_200 = vector ()
for (i in 1:500){
  file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/U_90_hyper_113400000_3_6_armonic_10_200/U_90_hyper_113400000_3_6_armonic_10_200_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  for (l in 1:20){
    if (file_to_open[l,9]<0){
      temp = vector()
      temp <- append (file_to_open[l,], i)
      task_fps_win_3_6_200 [[index_3_6_200,1]] <- temp
      work_3_6_200 <- append(work_3_6_200, file_to_open[l,13])
      priority_3_6_200 <- append(priority_3_6_200, file_to_open[l,2])
      index_3_6_200 <- index_3_6_200 + 1
    }
  }
  armonic = vector()
  for (l in 20:2){
    for (m in 1:(l-1)){
      if ((file_to_open[l,3]%%file_to_open[m,3]) == 0){
        armonic <- append(armonic, file_to_open[l,3])
        armonic <- append(armonic, file_to_open[m,3])
      }
    }
  }
  armonic_3_6_200 <- append (armonic_3_6_200, length(unique(armonic)))
}


task_fps_win_7_20_200 = matrix(list(), nrow = 10000, ncol = 1)
index_7_20_200  = 1
armonic_7_20_200 = vector()
work_7_20_200 = vector ()
priority_7_20_200 = vector ()
for (i in 1:500){
  file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/U_90_hyper_113400000_with_some_long/U_90_hyper_113400000_with_some_long_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  for (l in 1:20){
    if (file_to_open[l,9]<0){
      temp = vector()
      temp <- append (file_to_open[l,], i)
      task_fps_win_7_20_200 [[index_7_20_200,1]] <- temp
      work_7_20_200 <- append(work_7_20_200, file_to_open[l,13]) 
      priority_7_20_200 <- append(priority_7_20_200, file_to_open[l,2])
      index_7_20_200 <- index_7_20_200 + 1
    }
  }
  armonic = vector()
  for (l in 20:2){
    for (m in 1:(l-1)){
      if ((file_to_open[l,3]%%file_to_open[m,3]) == 0){
        armonic <- append(armonic, file_to_open[l,3])  
        armonic <- append(armonic, file_to_open[m,3])  
      }
    }
  }
  armonic_7_20_200 <- append (armonic_7_20_200, length(unique(armonic)))
}



print(min(armonic_0_2))
print(mean(armonic_0_2))
print(median(armonic_0_2))
print(max(armonic_0_2))

print(min(armonic_3_6))
print(mean(armonic_3_6))
print(median(armonic_3_6))
print(max(armonic_3_6))

print(min(armonic_7_20))
print(mean(armonic_7_20))
print(median(armonic_7_20))
print(max(armonic_7_20))


print(min(armonic_0_2_200))
print(mean(armonic_0_2_200))
print(median(armonic_0_2_200))
print(max(armonic_0_2_200))

print(min(armonic_3_6))
print(mean(armonic_3_6))
print(median(armonic_3_6))
print(max(armonic_3_6))

print(min(armonic_7_20_200))
print(mean(armonic_7_20_200))
print(median(armonic_7_20_200))
print(max(armonic_7_20_200))



res <- boxplot (work_0_2, work_3_6, work_7_20, work_0_2_200, work_3_6_200, work_7_20_200, names=c("0..2 armonici 10..100","3..6 armonici 10..100","7..20 armonici 10..100","0..2 armonici 10..200", "3_6 armonici 10..200", "7..20 armonici 10..200"), scipen=5, main="Utilizzazione Task con FPS Preemtpion < EDF Preemption", xlab="Task", ylab="Utilizzazione")
abline(h = 0.045, col = "red")
res$stats



res <- boxplot (priority_0_2, priority_3_6, priority_7_20, priority_0_2_200, priority_3_6_200, priority_7_20_200, names=c("0..2 armonici 10..100","3..6 armonici 10..100","7..20 armonici 10..100","0..2 armonici 10..200", "3_6 armonici 10..200", "7..20 armonici 10..200"), scipen=5, main="Priorità Task con FPS Preemtpion < EDF Preemption", xlab="Task", ylab="Priorità")
res$stats




max_priority = 10
min_utilization = 0.045


task_low_priority_high_work_0_2 = matrix(list(), nrow = index_0_2, ncol = 1)
index_lp_hw_0_2 = 1
number_jitter_fps_lower_edf_0_2 = 0
number_jitter_fps_higher_edf_0_2 = 0
list_jitter_fps_sub_edf_0_2 = vector()
number_jitter_fps_lower_edf_lp_hw_0_2 = 0
number_jitter_fps_higher_edf_lp_hw_0_2 = 0
list_jitter_fps_sub_edf_lp_hw_0_2 = vector()
for (i in 1:(index_0_2-1)){
  if (task_fps_win_0_2[[i,1]][2] <= max_priority  &  task_fps_win_0_2[[i,1]][13] >= min_utilization) {
    task_low_priority_high_work_0_2[[index_lp_hw_0_2,1]] <- task_fps_win_0_2[[i, 1]]
    index_lp_hw_0_2 <- index_lp_hw_0_2 + 1
    if (strtoi(task_fps_win_0_2[[i,1]][20], base = 0L) < strtoi(task_fps_win_0_2[[i,1]][25], base = 0L)){
      number_jitter_fps_lower_edf_lp_hw_0_2 <- number_jitter_fps_lower_edf_lp_hw_0_2 + 1
    }else{
      number_jitter_fps_higher_edf_lp_hw_0_2 <- number_jitter_fps_higher_edf_lp_hw_0_2 + 1
    }
    list_jitter_fps_sub_edf_lp_hw_0_2 <- append (list_jitter_fps_sub_edf_lp_hw_0_2, (strtoi(task_fps_win_0_2[[i,1]][25], base = 0L) - strtoi(task_fps_win_0_2[[i,1]][20], base = 0L)))
  }
  # }else{
  #   if (task_fps_win_70[[i,1]][13] <= avarage_work_time[2]){
  #     task_low_priority_low_work_70 [[index_lp_lw_70,1]] <- task_fps_win_70[[i, 1]]
  #     index_lp_lw_70 <- index_lp_lw_70 + 1
  #   }else{
  #     task_low_priority_high_work_70 [[index_lp_hw_70,1]] <- task_fps_win_70[[i, 1]]
  #     index_lp_hw_70 <- index_lp_hw_70 + 1
  #   }
  # }
  if (strtoi(task_fps_win_0_2[[i,1]][20], base = 0L) < strtoi(task_fps_win_0_2[[i,1]][25], base = 0L)){
    number_jitter_fps_lower_edf_0_2 <- number_jitter_fps_lower_edf_0_2 + 1
  }else{
    number_jitter_fps_higher_edf_0_2 <- number_jitter_fps_higher_edf_0_2 + 1
  }
  list_jitter_fps_sub_edf_0_2 <- append (list_jitter_fps_sub_edf_0_2, (strtoi(task_fps_win_0_2[[i,1]][25], base = 0L) - strtoi(task_fps_win_0_2[[i,1]][20], base = 0L)))
}

cat(sprintf("FPS 0_2 low priority high work: %s\n", index_lp_hw_0_2-1))
cat(sprintf("FPS avarage jitter for 0_2 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_0_2, number_jitter_fps_higher_edf_0_2, mean(list_jitter_fps_sub_edf_0_2), min (list_jitter_fps_sub_edf_0_2), max(list_jitter_fps_sub_edf_0_2)))
cat(sprintf("FPS avarage jitter for 0_2 group with low priority high utilization, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_lp_hw_0_2, number_jitter_fps_higher_edf_lp_hw_0_2, mean(list_jitter_fps_sub_edf_lp_hw_0_2), min (list_jitter_fps_sub_edf_lp_hw_0_2), max(list_jitter_fps_sub_edf_lp_hw_0_2)))


task_low_priority_high_work_3_6 = matrix(list(), nrow = index_3_6, ncol = 1)
index_lp_hw_3_6 = 1
number_jitter_fps_lower_edf_3_6 = 0
number_jitter_fps_higher_edf_3_6 = 0
list_jitter_fps_sub_edf_3_6 = vector()
number_jitter_fps_lower_edf_lp_hw_3_6 = 0
number_jitter_fps_higher_edf_lp_hw_3_6= 0
list_jitter_fps_sub_edf_lp_hw_3_6 = vector()
for (i in 1:(index_3_6-1)){
  if (task_fps_win_3_6[[i,1]][2] <= max_priority  &  task_fps_win_3_6[[i,1]][13] >= min_utilization) {
    task_low_priority_high_work_3_6[[index_lp_hw_3_6,1]] <- task_fps_win_3_6[[i, 1]]
    index_lp_hw_3_6 <- index_lp_hw_3_6 + 1
    if (strtoi(task_fps_win_3_6[[i,1]][20], base = 0L) < strtoi(task_fps_win_3_6[[i,1]][25], base = 0L)){
      number_jitter_fps_lower_edf_lp_hw_3_6 <- number_jitter_fps_lower_edf_lp_hw_3_6 + 1
    }else{
      number_jitter_fps_higher_edf_lp_hw_3_6 <- number_jitter_fps_higher_edf_lp_hw_3_6 + 1
    }
    list_jitter_fps_sub_edf_lp_hw_3_6 <- append (list_jitter_fps_sub_edf_lp_hw_3_6, (strtoi(task_fps_win_3_6[[i,1]][25], base = 0L) - strtoi(task_fps_win_3_6[[i,1]][20], base = 0L)))
  }
  # }else{
  #   if (task_fps_win_70[[i,1]][13] <= avarage_work_time[2]){
  #     task_low_priority_low_work_70 [[index_lp_lw_70,1]] <- task_fps_win_70[[i, 1]]
  #     index_lp_lw_70 <- index_lp_lw_70 + 1
  #   }else{
  #     task_low_priority_high_work_70 [[index_lp_hw_70,1]] <- task_fps_win_70[[i, 1]]
  #     index_lp_hw_70 <- index_lp_hw_70 + 1
  #   }
  # }
  if (strtoi(task_fps_win_3_6[[i,1]][20], base = 0L) < strtoi(task_fps_win_3_6[[i,1]][25], base = 0L)){
    number_jitter_fps_lower_edf_3_6 <- number_jitter_fps_lower_edf_3_6 + 1
  }else{
    number_jitter_fps_higher_edf_3_6 <- number_jitter_fps_higher_edf_3_6 + 1
  }
  list_jitter_fps_sub_edf_3_6 <- append (list_jitter_fps_sub_edf_3_6, (strtoi(task_fps_win_3_6[[i,1]][25], base = 0L) - strtoi(task_fps_win_3_6[[i,1]][20], base = 0L)))
}
cat(sprintf("FPS 3_6 low priority high work: %s\n", index_lp_hw_3_6-1))
cat(sprintf("FPS avarage jitter for 3_6 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_3_6, number_jitter_fps_higher_edf_3_6, mean(list_jitter_fps_sub_edf_3_6), min (list_jitter_fps_sub_edf_3_6), max(list_jitter_fps_sub_edf_3_6)))
cat(sprintf("FPS avarage jitter for 3_6 group with low priority high utilization, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_lp_hw_3_6, number_jitter_fps_higher_edf_lp_hw_3_6, mean(list_jitter_fps_sub_edf_lp_hw_3_6), min (list_jitter_fps_sub_edf_lp_hw_3_6), max(list_jitter_fps_sub_edf_lp_hw_3_6)))


task_low_priority_high_work_7_20 = matrix(list(), nrow = index_7_20, ncol = 1)
index_lp_hw_7_20 = 1
number_jitter_fps_lower_edf_7_20 = 0
number_jitter_fps_higher_edf_7_20 = 0
list_jitter_fps_sub_edf_7_20 = vector()
number_jitter_fps_lower_edf_lp_hw_7_20 = 0
number_jitter_fps_higher_edf_lp_hw_7_20= 0
list_jitter_fps_sub_edf_lp_hw_7_20 = vector()
for (i in 1:(index_7_20-1)){
  if (task_fps_win_7_20[[i,1]][2] <= max_priority  &  task_fps_win_7_20[[i,1]][13] >= min_utilization) { # 0.05175) {
    task_low_priority_high_work_7_20[[index_lp_hw_7_20,1]] <- task_fps_win_7_20[[i, 1]]
    index_lp_hw_7_20 <- index_lp_hw_7_20 + 1
    if (strtoi(task_fps_win_7_20[[i,1]][20], base = 0L) < strtoi(task_fps_win_7_20[[i,1]][25], base = 0L)){
      number_jitter_fps_lower_edf_lp_hw_7_20 <- number_jitter_fps_lower_edf_lp_hw_7_20 + 1
    }else{
      number_jitter_fps_higher_edf_lp_hw_7_20 <- number_jitter_fps_higher_edf_lp_hw_7_20 + 1
    }
    list_jitter_fps_sub_edf_lp_hw_7_20 <- append (list_jitter_fps_sub_edf_lp_hw_7_20, (strtoi(task_fps_win_7_20[[i,1]][25], base = 0L) - strtoi(task_fps_win_7_20[[i,1]][20], base = 0L)))
  }
  # }else{
  #   if (task_fps_win_70[[i,1]][13] <= avarage_work_time[2]){
  #     task_low_priority_low_work_70 [[index_lp_lw_70,1]] <- task_fps_win_70[[i, 1]]
  #     index_lp_lw_70 <- index_lp_lw_70 + 1
  #   }else{
  #     task_low_priority_high_work_70 [[index_lp_hw_70,1]] <- task_fps_win_70[[i, 1]]
  #     index_lp_hw_70 <- index_lp_hw_70 + 1
  #   }
  # }
  if (strtoi(task_fps_win_7_20[[i,1]][20], base = 0L) < strtoi(task_fps_win_7_20[[i,1]][25], base = 0L)){
    number_jitter_fps_lower_edf_7_20 <- number_jitter_fps_lower_edf_7_20 + 1
  }else{
    number_jitter_fps_higher_edf_7_20 <- number_jitter_fps_higher_edf_7_20 + 1
  }
  list_jitter_fps_sub_edf_7_20 <- append (list_jitter_fps_sub_edf_7_20, (strtoi(task_fps_win_7_20[[i,1]][25], base = 0L) - strtoi(task_fps_win_7_20[[i,1]][20], base = 0L)))
}
cat(sprintf("FPS 7_20 low priority high work: %s\n", index_lp_hw_7_20-1))
cat(sprintf("FPS avarage jitter for 7_20 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_7_20, number_jitter_fps_higher_edf_7_20, mean(list_jitter_fps_sub_edf_7_20), min (list_jitter_fps_sub_edf_7_20), max(list_jitter_fps_sub_edf_7_20)))
cat(sprintf("FPS avarage jitter for 7_20 group with low priority high utilization, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_lp_hw_7_20, number_jitter_fps_higher_edf_lp_hw_7_20, mean(list_jitter_fps_sub_edf_lp_hw_7_20), min (list_jitter_fps_sub_edf_lp_hw_7_20), max(list_jitter_fps_sub_edf_lp_hw_7_20)))



task_low_priority_high_work_0_2_200 = matrix(list(), nrow = index_0_2_200, ncol = 1)
index_lp_hw_0_2_200 = 1
number_jitter_fps_lower_edf_0_2_200 = 0
number_jitter_fps_higher_edf_0_2_200 = 0
list_jitter_fps_sub_edf_0_2_200 = vector()
number_jitter_fps_lower_edf_lp_hw_0_2_200 = 0
number_jitter_fps_higher_edf_lp_hw_0_2_200 = 0
list_jitter_fps_sub_edf_lp_hw_0_2_200 = vector()
for (i in 1:(index_0_2_200-1)){
  if (task_fps_win_0_2_200[[i,1]][2] <= max_priority  &  task_fps_win_0_2_200[[i,1]][13] >= min_utilization) {
    task_low_priority_high_work_0_2_200[[index_lp_hw_0_2_200,1]] <- task_fps_win_0_2_200[[i, 1]]
    index_lp_hw_0_2_200 <- index_lp_hw_0_2_200 + 1
    if (strtoi(task_fps_win_0_2_200[[i,1]][20], base = 0L) < strtoi(task_fps_win_0_2_200[[i,1]][25], base = 0L)){
      number_jitter_fps_lower_edf_lp_hw_0_2_200 <- number_jitter_fps_lower_edf_lp_hw_0_2_200 + 1
    }else{
      number_jitter_fps_higher_edf_lp_hw_0_2_200 <- number_jitter_fps_higher_edf_lp_hw_0_2_200 + 1
    }
    list_jitter_fps_sub_edf_lp_hw_0_2_200 <- append (list_jitter_fps_sub_edf_lp_hw_0_2_200, (strtoi(task_fps_win_0_2_200[[i,1]][25], base = 0L) - strtoi(task_fps_win_0_2_200[[i,1]][20], base = 0L)))
  }
  # }else{
  #   if (task_fps_win_70[[i,1]][13] <= avarage_work_time[2]){
  #     task_low_priority_low_work_70 [[index_lp_lw_70,1]] <- task_fps_win_70[[i, 1]]
  #     index_lp_lw_70 <- index_lp_lw_70 + 1
  #   }else{
  #     task_low_priority_high_work_70 [[index_lp_hw_70,1]] <- task_fps_win_70[[i, 1]]
  #     index_lp_hw_70 <- index_lp_hw_70 + 1
  #   }
  # }
  if (strtoi(task_fps_win_0_2_200[[i,1]][20], base = 0L) < strtoi(task_fps_win_0_2_200[[i,1]][25], base = 0L)){
    number_jitter_fps_lower_edf_0_2_200 <- number_jitter_fps_lower_edf_0_2_200 + 1
  }else{
    number_jitter_fps_higher_edf_0_2_200 <- number_jitter_fps_higher_edf_0_2_200 + 1
  }
  list_jitter_fps_sub_edf_0_2_200 <- append (list_jitter_fps_sub_edf_0_2_200, (strtoi(task_fps_win_0_2_200[[i,1]][25], base = 0L) - strtoi(task_fps_win_0_2_200[[i,1]][20], base = 0L)))
}

cat(sprintf("FPS 0_2_200 low priority high work: %s\n", index_lp_hw_0_2_200-1))
cat(sprintf("FPS avarage jitter for 0_2_200 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_0_2_200, number_jitter_fps_higher_edf_0_2_200, mean(list_jitter_fps_sub_edf_0_2_200), min (list_jitter_fps_sub_edf_0_2_200), max(list_jitter_fps_sub_edf_0_2_200)))
cat(sprintf("FPS avarage jitter for 0_2_200 group with low priority high utilization, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_lp_hw_0_2_200, number_jitter_fps_higher_edf_lp_hw_0_2_200, mean(list_jitter_fps_sub_edf_lp_hw_0_2_200), min (list_jitter_fps_sub_edf_lp_hw_0_2_200), max(list_jitter_fps_sub_edf_lp_hw_0_2_200)))


task_low_priority_high_work_3_6_200 = matrix(list(), nrow = index_3_6_200, ncol = 1)
index_lp_hw_3_6_200 = 1
number_jitter_fps_lower_edf_3_6_200 = 0
number_jitter_fps_higher_edf_3_6_200 = 0
list_jitter_fps_sub_edf_3_6_200 = vector()
number_jitter_fps_lower_edf_lp_hw_3_6_200 = 0
number_jitter_fps_higher_edf_lp_hw_3_6_200 = 0
list_jitter_fps_sub_edf_lp_hw_3_6_200 = vector()
for (i in 1:(index_3_6_200-1)){
  if (task_fps_win_3_6_200[[i,1]][2] <= max_priority  &  task_fps_win_3_6_200[[i,1]][13] >= min_utilization) {
    task_low_priority_high_work_3_6_200[[index_lp_hw_3_6_200,1]] <- task_fps_win_3_6_200[[i, 1]]
    index_lp_hw_3_6_200 <- index_lp_hw_3_6_200 + 1
    if (strtoi(task_fps_win_3_6_200[[i,1]][20], base = 0L) < strtoi(task_fps_win_3_6_200[[i,1]][25], base = 0L)){
      number_jitter_fps_lower_edf_lp_hw_3_6_200 <- number_jitter_fps_lower_edf_lp_hw_3_6_200 + 1
    }else{
      number_jitter_fps_higher_edf_lp_hw_3_6_200 <- number_jitter_fps_higher_edf_lp_hw_3_6_200 + 1
    }
    list_jitter_fps_sub_edf_lp_hw_3_6_200 <- append (list_jitter_fps_sub_edf_lp_hw_3_6_200, (strtoi(task_fps_win_3_6_200[[i,1]][25], base = 0L) - strtoi(task_fps_win_3_6_200[[i,1]][20], base = 0L)))
  }
  # }else{
  #   if (task_fps_win_70[[i,1]][13] <= avarage_work_time[2]){
  #     task_low_priority_low_work_70 [[index_lp_lw_70,1]] <- task_fps_win_70[[i, 1]]
  #     index_lp_lw_70 <- index_lp_lw_70 + 1
  #   }else{
  #     task_low_priority_high_work_70 [[index_lp_hw_70,1]] <- task_fps_win_70[[i, 1]]
  #     index_lp_hw_70 <- index_lp_hw_70 + 1
  #   }
  # }
  if (strtoi(task_fps_win_3_6_200[[i,1]][20], base = 0L) < strtoi(task_fps_win_3_6_200[[i,1]][25], base = 0L)){
    number_jitter_fps_lower_edf_3_6_200 <- number_jitter_fps_lower_edf_3_6_200 + 1
  }else{
    number_jitter_fps_higher_edf_3_6_200 <- number_jitter_fps_higher_edf_3_6_200 + 1
  }
  list_jitter_fps_sub_edf_3_6_200 <- append (list_jitter_fps_sub_edf_3_6_200, (strtoi(task_fps_win_3_6_200[[i,1]][25], base = 0L) - strtoi(task_fps_win_3_6_200[[i,1]][20], base = 0L)))
}

cat(sprintf("FPS 3_6_200 low priority high work: %s\n", index_lp_hw_3_6_200-1))
cat(sprintf("FPS avarage jitter for 3_6_200 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_3_6_200, number_jitter_fps_higher_edf_3_6_200, mean(list_jitter_fps_sub_edf_3_6_200), min (list_jitter_fps_sub_edf_3_6_200), max(list_jitter_fps_sub_edf_3_6_200)))
cat(sprintf("FPS avarage jitter for 3_6_200 group with low priority high utilization, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_lp_hw_3_6_200, number_jitter_fps_higher_edf_lp_hw_3_6_200, mean(list_jitter_fps_sub_edf_lp_hw_3_6_200), min (list_jitter_fps_sub_edf_lp_hw_3_6_200), max(list_jitter_fps_sub_edf_lp_hw_3_6_200)))



task_low_priority_high_work_7_20_200 = matrix(list(), nrow = index_7_20_200, ncol = 1)
index_lp_hw_7_20_200 = 1
number_jitter_fps_lower_edf_7_20_200 = 0
number_jitter_fps_higher_edf_7_20_200 = 0
list_jitter_fps_sub_edf_7_20_200 = vector()
number_jitter_fps_lower_edf_lp_hw_7_20_200 = 0
number_jitter_fps_higher_edf_lp_hw_7_20_200 = 0
list_jitter_fps_sub_edf_lp_hw_7_20_200 = vector()
for (i in 1:(index_7_20_200-1)){
  if (task_fps_win_7_20_200[[i,1]][2] <= max_priority  &  task_fps_win_7_20_200[[i,1]][13] >= min_utilization) {
    task_low_priority_high_work_7_20_200[[index_lp_hw_7_20_200,1]] <- task_fps_win_7_20_200[[i, 1]]
    index_lp_hw_7_20_200 <- index_lp_hw_7_20_200 + 1
    if (strtoi(task_fps_win_7_20_200[[i,1]][20], base = 0L) < strtoi(task_fps_win_7_20_200[[i,1]][25], base = 0L)){
      number_jitter_fps_lower_edf_lp_hw_7_20_200 <- number_jitter_fps_lower_edf_lp_hw_7_20_200 + 1
    }else{
      number_jitter_fps_higher_edf_lp_hw_7_20_200 <- number_jitter_fps_higher_edf_lp_hw_7_20_200 + 1
    }
    list_jitter_fps_sub_edf_lp_hw_7_20_200 <- append (list_jitter_fps_sub_edf_lp_hw_7_20_200, (strtoi(task_fps_win_7_20_200[[i,1]][25], base = 0L) - strtoi(task_fps_win_7_20_200[[i,1]][20], base = 0L)))
  }
  # }else{
  #   if (task_fps_win_70[[i,1]][13] <= avarage_work_time[2]){
  #     task_low_priority_low_work_70 [[index_lp_lw_70,1]] <- task_fps_win_70[[i, 1]]
  #     index_lp_lw_70 <- index_lp_lw_70 + 1
  #   }else{
  #     task_low_priority_high_work_70 [[index_lp_hw_70,1]] <- task_fps_win_70[[i, 1]]
  #     index_lp_hw_70 <- index_lp_hw_70 + 1
  #   }
  # }
  if (strtoi(task_fps_win_7_20_200[[i,1]][20], base = 0L) < strtoi(task_fps_win_7_20_200[[i,1]][25], base = 0L)){
    number_jitter_fps_lower_edf_7_20_200 <- number_jitter_fps_lower_edf_7_20_200 + 1
  }else{
    number_jitter_fps_higher_edf_7_20_200 <- number_jitter_fps_higher_edf_7_20_200 + 1
  }
  list_jitter_fps_sub_edf_7_20_200 <- append (list_jitter_fps_sub_edf_7_20_200, (strtoi(task_fps_win_7_20_200[[i,1]][25], base = 0L) - strtoi(task_fps_win_7_20_200[[i,1]][20], base = 0L)))
}

cat(sprintf("FPS 7_20_200 low priority high work: %s\n", index_lp_hw_7_20_200-1))
cat(sprintf("FPS avarage jitter for 7_20_200 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_7_20_200, number_jitter_fps_higher_edf_7_20_200, mean(list_jitter_fps_sub_edf_7_20_200), min (list_jitter_fps_sub_edf_7_20_200), max(list_jitter_fps_sub_edf_7_20_200)))
cat(sprintf("FPS avarage jitter for 7_20_200 group with low priority high utilization, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_lp_hw_7_20_200, number_jitter_fps_higher_edf_lp_hw_7_20_200, mean(list_jitter_fps_sub_edf_lp_hw_7_20_200), min (list_jitter_fps_sub_edf_lp_hw_7_20_200), max(list_jitter_fps_sub_edf_lp_hw_7_20_200)))



res <- boxplot (list_jitter_fps_sub_edf_lp_hw_0_2, list_jitter_fps_sub_edf_lp_hw_3_6, list_jitter_fps_sub_edf_lp_hw_7_20, list_jitter_fps_sub_edf_lp_hw_0_2_200, list_jitter_fps_sub_edf_lp_hw_3_6_200, list_jitter_fps_sub_edf_lp_hw_7_20_200, names=c("0..2 armonici 10..100","3..6 armonici 10..100","7..20 armonici 10..100","0..2 armonici 10..200", "3_6 armonici 10..200", "7..20 armonici 10..200"), scipen=20, main="Confronto Jitter medio Task con FPS Preemtpion < EDF Preemption: Priorità 1, Utilizzazione 1", xlab="Task", ylab="Jitter EDF medio - Jitter FPS medio", ylim = c(-500000,500000))
abline(h = 0, col = "red")
res$stats


