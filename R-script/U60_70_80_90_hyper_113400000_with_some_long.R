avarage_work_time = vector()
task_fps_win_60 = matrix(list(), nrow = 10000, ncol = 1)
task_fps_win_70 = matrix(list(), nrow = 10000, ncol = 1)
task_fps_win_80 = matrix(list(), nrow = 10000, ncol = 1)
task_fps_win_90 = matrix(list(), nrow = 10000, ncol = 1)
index60 = 1
index70 = 1
index80 = 1
index90 = 1

for (j in 0:3){
  
  array_work = vector()
  
  for (i in 1:500){
    file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/U_", c(60 + j * 10),"_hyper_113400000_with_some_long/U_", c(60 + j * 10),"_hyper_113400000_with_some_long_", c(i), ".csv", sep = "")
  
    file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
    for (l in 1:20){
      array_work <- append(array_work, file_to_open[l,13])  
      if (file_to_open[l,9]<0){
        temp = vector()
        temp <- append (file_to_open[l,], i)
        if (j == 0){
          task_fps_win_60 [[index60,1]] <- temp
          index60 <- index60 + 1
        }
        if (j == 1){
          task_fps_win_70 [[index70,1]] <- temp
          index70 <- index70 + 1
        }
        if (j == 2){
          task_fps_win_80 [[index80,1]] <-  temp
          index80 <- index80 + 1
        }
        if (j == 3){
          task_fps_win_90 [[index90,1]] <- temp
          index90 <- index90 + 1
        }
      }
    }
  }
  
  avarage_work_time = append (avarage_work_time, mean(array_work))
  
}
cat(sprintf("Avarage work for 60: %s, 70: %s, 80: %s, 90: %s\n", avarage_work_time[1], avarage_work_time[2], avarage_work_time[3], avarage_work_time[4]))
cat(sprintf("Total of FPS win for 60: %s, 70: %s, 80: %s, 90: %s\n", index60-1, index70-1, index80-1, index90-1))



task_high_priority_60 = matrix(list(), nrow = index60, ncol = 1)
task_low_priority_low_work_60 = matrix(list(), nrow = index60, ncol = 1)
task_low_priority_high_work_60 = matrix(list(), nrow = index60, ncol = 1)
index_hp_60 = 1
index_lp_lw_60 = 1
index_lp_hw_60 = 1
for (i in 1:(index60-1)){
  if (task_fps_win_60[[i,1]][2] >= 15){
    task_high_priority_60[[index_hp_60,1]] <- task_fps_win_60[[i, 1]]
    index_hp_60 <- index_hp_60 + 1
  }else{
    if (task_fps_win_60[[i,1]][13] <= avarage_work_time[1]){
      task_low_priority_low_work_60 [[index_lp_lw_60,1]] <- task_fps_win_60[[i, 1]]
      index_lp_lw_60 <- index_lp_lw_60 + 1
    }else{
      task_low_priority_high_work_60 [[index_lp_hw_60,1]] <- task_fps_win_60[[i, 1]]
      index_lp_hw_60 <- index_lp_hw_60 + 1
    }
  }
}
cat(sprintf("FPS win for 60 group, high priority: %s, low priority low work: %s, low priority high work: %s\n", index_hp_60-1, index_lp_lw_60-1, index_lp_hw_60-1))



task_high_priority_70 = matrix(list(), nrow = index70, ncol = 1)
task_low_priority_low_work_70 = matrix(list(), nrow = index70, ncol = 1)
task_low_priority_high_work_70 = matrix(list(), nrow = index70, ncol = 1)
index_hp_70 = 1
index_lp_lw_70 = 1
index_lp_hw_70 = 1
for (i in 1:(index70-1)){
  if (task_fps_win_70[[i,1]][2] >= 15){
    task_high_priority_70[[index_hp_70,1]] <- task_fps_win_70[[i, 1]]
    index_hp_70 <- index_hp_70 + 1
  }else{
    if (task_fps_win_70[[i,1]][13] <= avarage_work_time[2]){
      task_low_priority_low_work_70 [[index_lp_lw_70,1]] <- task_fps_win_70[[i, 1]]
      index_lp_lw_70 <- index_lp_lw_70 + 1
    }else{
      task_low_priority_high_work_70 [[index_lp_hw_70,1]] <- task_fps_win_70[[i, 1]]
      index_lp_hw_70 <- index_lp_hw_70 + 1
    }
  }
}
cat(sprintf("FPS win for 70 group, high priority: %s, low priority low work: %s, low priority high work: %s\n", index_hp_70-1, index_lp_lw_70-1, index_lp_hw_70-1))




task_high_priority_80 = matrix(list(), nrow = index80, ncol = 1)
task_low_priority_low_work_80 = matrix(list(), nrow = index80, ncol = 1)
task_low_priority_high_work_80 = matrix(list(), nrow = index80, ncol = 1)
index_hp_80 = 1
index_lp_lw_80 = 1
index_lp_hw_80 = 1
for (i in 1:(index80-1)){
  if (task_fps_win_80[[i,1]][2] >= 15){
    task_high_priority_80[[index_hp_80,1]] <- task_fps_win_80[[i, 1]]
    index_hp_80 <- index_hp_80 + 1
  }else{
    if (task_fps_win_80[[i,1]][13] <= avarage_work_time[3]){
      task_low_priority_low_work_80 [[index_lp_lw_80,1]] <- task_fps_win_80[[i, 1]]
      index_lp_lw_80 <- index_lp_lw_80 + 1
    }else{
      task_low_priority_high_work_80 [[index_lp_hw_80,1]] <- task_fps_win_80[[i, 1]]
      index_lp_hw_80 <- index_lp_hw_80 + 1
    }
  }
}
cat(sprintf("FPS win for 80 group, high priority: %s, low priority low work: %s, low priority high work: %s\n", index_hp_80-1, index_lp_lw_80-1, index_lp_hw_80-1))




task_high_priority_90 = matrix(list(), nrow = index90, ncol = 1)
task_low_priority_low_work_90 = matrix(list(), nrow = index90, ncol = 1)
task_low_priority_high_work_90 = matrix(list(), nrow = index90, ncol = 1)
index_hp_90 = 1
index_lp_lw_90 = 1
index_lp_hw_90 = 1
for (i in 1:(index90-1)){
  if (task_fps_win_90[[i,1]][2] >= 15){
    task_high_priority_90[[index_hp_90,1]] <- task_fps_win_90[[i, 1]]
    index_hp_90 <- index_hp_90 + 1
  }else{
    if (task_fps_win_90[[i,1]][13] <= avarage_work_time[4]){
      task_low_priority_low_work_90 [[index_lp_lw_90,1]] <- task_fps_win_90[[i, 1]]
      index_lp_lw_90 <- index_lp_lw_90 + 1
    }else{
      task_low_priority_high_work_90 [[index_lp_hw_90,1]] <- task_fps_win_90[[i, 1]]
      index_lp_hw_90 <- index_lp_hw_90 + 1
    }
  }
}
cat(sprintf("FPS win for 90 group, high priority: %s, low priority low work: %s, low priority high work: %s\n", index_hp_90, index_lp_lw_90, index_lp_hw_90))

