avarage_work_time = vector()
task_fps_win_60 = matrix(list(), nrow = 10000, ncol = 1)
task_fps_win_70 = matrix(list(), nrow = 10000, ncol = 1)
task_fps_win_80 = matrix(list(), nrow = 10000, ncol = 1)
task_fps_win_90 = matrix(list(), nrow = 10000, ncol = 1)
index60 = 1
index70 = 1
index80 = 1
index90 = 1

armonic60 = vector()
armonic70 = vector()
armonic80 = vector()
armonic90 = vector()

work70 = vector ()
work80 = vector ()
work90 = vector ()

for (j in 0:2){
  
  array_work = vector()
  
  for (i in 1:500){
    file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/U_", c(70 + j * 10),"_hyper_113400000_with_some_long/U_", c(70 + j * 10),"_hyper_113400000_with_some_long_", c(i), ".csv", sep = "")
  
    file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
    for (l in 1:20){
      array_work <- append(array_work, file_to_open[l,13])  
      if (file_to_open[l,9]<0){
        temp = vector()
        temp <- append (file_to_open[l,], i)
        if (j == 7){
          task_fps_win_60 [[index60,1]] <- temp
          #work70 <- append(work70, file_to_open[l,13]) 
          index60 <- index60 + 1
        }
        if (j == 0){
          task_fps_win_70 [[index70,1]] <- temp
          work70 <- append(work70, file_to_open[l,13]) 
          index70 <- index70 + 1
        }
        if (j == 1){
          task_fps_win_80 [[index80,1]] <-  temp
          work80 <- append(work80, file_to_open[l,13]) 
          index80 <- index80 + 1
        }
        if (j == 2){
          task_fps_win_90 [[index90,1]] <- temp
          work90 <- append(work90, file_to_open[l,13]) 
          index90 <- index90 + 1
        }
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
    if (j == 7){
      armonic60 <- append (armonic60, length(unique(armonic)))
    }
    if (j == 0){
      armonic70 <- append (armonic70, length(unique(armonic)))
    }
    if (j == 1){
      armonic80 <- append (armonic80, length(unique(armonic)))
    }
    if (j == 2){
      armonic90 <- append (armonic90, length(unique(armonic)))
    }
  }
  
  avarage_work_time = append (avarage_work_time, mean(array_work))
  
}

# print(min(armonic60))
# print(mean(armonic60))
# print(median(armonic60))
print(min(armonic70))
print(mean(armonic70))
print(median(armonic70))
print(min(armonic80))
print(mean(armonic80))
print(median(armonic80))
print(min(armonic90))
print(mean(armonic90))
print(median(armonic90))

print(sum (armonic90 < 7))
print(armonic90)

# cat(sprintf("Avarage work for 60: %s, 70: %s, 80: %s, 90: %s\n", avarage_work_time[1], avarage_work_time[2], avarage_work_time[3], avarage_work_time[4]))
# cat(sprintf("Total of FPS win for 60: %s, 70: %s, 80: %s, 90: %s\n", index60-1, index70-1, index80-1, index90-1))
cat(sprintf("Avarage work for 70: %s, 80: %s, 90: %s\n", avarage_work_time[1], avarage_work_time[2], avarage_work_time[3]))
cat(sprintf("Total of FPS win for 70: %s, 80: %s, 90: %s\n", index70-1, index80-1, index90-1))


res <- boxplot (work70, work80, work90)
res

# task_high_priority_60 = matrix(list(), nrow = index60, ncol = 1)
# task_low_priority_low_work_60 = matrix(list(), nrow = index60, ncol = 1)
# task_low_priority_high_work_60 = matrix(list(), nrow = index60, ncol = 1)
# index_hp_60 = 1
# index_lp_lw_60 = 1
# index_lp_hw_60 = 1
# number_jitter_fps_lower_edf_60 = 0
# number_jitter_fps_higher_edf_60 = 0
# list_jitter_fps_sub_edf_60 = vector()
# for (i in 1:(index60-1)){
#   if (task_fps_win_60[[i,1]][2] >= 15){
#     task_high_priority_60[[index_hp_60,1]] <- task_fps_win_60[[i, 1]]
#     index_hp_60 <- index_hp_60 + 1
#   }else{
#     if (task_fps_win_60[[i,1]][13] <= avarage_work_time[1]){
#       task_low_priority_low_work_60 [[index_lp_lw_60,1]] <- task_fps_win_60[[i, 1]]
#       index_lp_lw_60 <- index_lp_lw_60 + 1
#     }else{
#       task_low_priority_high_work_60 [[index_lp_hw_60,1]] <- task_fps_win_60[[i, 1]]
#       index_lp_hw_60 <- index_lp_hw_60 + 1
#     }
#   }
#   if (strtoi(task_fps_win_60[[i,1]][20], base = 0L) < strtoi(task_fps_win_60[[i,1]][25], base = 0L)){
#     number_jitter_fps_lower_edf_60 <- number_jitter_fps_lower_edf_60 + 1
#   }else{
#     number_jitter_fps_higher_edf_60 <- number_jitter_fps_higher_edf_60 + 1
#   }
#   list_jitter_fps_sub_edf_60 <- append (list_jitter_fps_sub_edf_60, (strtoi(task_fps_win_60[[i,1]][25], base = 0L) - strtoi(task_fps_win_60[[i,1]][20], base = 0L)))
# }
# cat(sprintf("FPS win for 60 group, high priority: %s, low priority low work: %s, low priority high work: %s\n", index_hp_60-1, index_lp_lw_60-1, index_lp_hw_60-1))
# cat(sprintf("FPS avarage jitter for 60 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_60, number_jitter_fps_higher_edf_60, mean(list_jitter_fps_sub_edf_60), min (list_jitter_fps_sub_edf_60), max(list_jitter_fps_sub_edf_60)))


task_high_priority_70 = matrix(list(), nrow = index70, ncol = 1)
task_low_priority_low_work_70 = matrix(list(), nrow = index70, ncol = 1)
task_low_priority_high_work_70 = matrix(list(), nrow = index70, ncol = 1)
index_hp_70 = 1
index_lp_lw_70 = 1
index_lp_hw_70 = 1
number_jitter_fps_lower_edf_70 = 0
number_jitter_fps_higher_edf_70 = 0
list_jitter_fps_sub_edf_70 = vector()
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
  if (strtoi(task_fps_win_70[[i,1]][20], base = 0L) < strtoi(task_fps_win_70[[i,1]][25], base = 0L)){
    number_jitter_fps_lower_edf_70 <- number_jitter_fps_lower_edf_70 + 1
  }else{
    number_jitter_fps_higher_edf_70 <- number_jitter_fps_higher_edf_70 + 1
  }
  list_jitter_fps_sub_edf_70 <- append (list_jitter_fps_sub_edf_70, (strtoi(task_fps_win_70[[i,1]][25], base = 0L) - strtoi(task_fps_win_70[[i,1]][20], base = 0L)))
}
cat(sprintf("FPS win for 70 group, high priority: %s, low priority low work: %s, low priority high work: %s\n", index_hp_70-1, index_lp_lw_70-1, index_lp_hw_70-1))
cat(sprintf("FPS avarage jitter for 70 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_70, number_jitter_fps_higher_edf_70, mean(list_jitter_fps_sub_edf_70), min (list_jitter_fps_sub_edf_70), max(list_jitter_fps_sub_edf_70)))




task_high_priority_80 = matrix(list(), nrow = index80, ncol = 1)
task_low_priority_low_work_80 = matrix(list(), nrow = index80, ncol = 1)
task_low_priority_high_work_80 = matrix(list(), nrow = index80, ncol = 1)
index_hp_80 = 1
index_lp_lw_80 = 1
index_lp_hw_80 = 1
number_jitter_fps_lower_edf_80 = 0
number_jitter_fps_higher_edf_80 = 0
list_jitter_fps_sub_edf_80 = vector()
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
  if (strtoi(task_fps_win_80[[i,1]][20], base = 0L) < strtoi(task_fps_win_80[[i,1]][25], base = 0L)){
    number_jitter_fps_lower_edf_80 <- number_jitter_fps_lower_edf_80 + 1
  }else{
    number_jitter_fps_higher_edf_80 <- number_jitter_fps_higher_edf_80 + 1
  }
  list_jitter_fps_sub_edf_80 <- append (list_jitter_fps_sub_edf_80, (strtoi(task_fps_win_80[[i,1]][25], base = 0L) - strtoi(task_fps_win_80[[i,1]][20], base = 0L)))
}
cat(sprintf("FPS win for 80 group, high priority: %s, low priority low work: %s, low priority high work: %s\n", index_hp_80-1, index_lp_lw_80-1, index_lp_hw_80-1))
cat(sprintf("FPS avarage jitter for 80 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_80, number_jitter_fps_higher_edf_80, mean(list_jitter_fps_sub_edf_80), min (list_jitter_fps_sub_edf_80), max(list_jitter_fps_sub_edf_80)))




task_high_priority_90 = matrix(list(), nrow = index90, ncol = 1)
task_low_priority_low_work_90 = matrix(list(), nrow = index90, ncol = 1)
task_low_priority_high_work_90 = matrix(list(), nrow = index90, ncol = 1)
index_hp_90 = 1
index_lp_lw_90 = 1
index_lp_hw_90 = 1
number_jitter_fps_lower_edf_90 = 0
number_jitter_fps_higher_edf_90 = 0
list_jitter_fps_sub_edf_90 = vector()
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
  if (strtoi(task_fps_win_90[[i,1]][20], base = 0L) < strtoi(task_fps_win_90[[i,1]][25], base = 0L)){
    number_jitter_fps_lower_edf_90 <- number_jitter_fps_lower_edf_90 + 1
  }else{
    number_jitter_fps_higher_edf_90 <- number_jitter_fps_higher_edf_90 + 1
  }
  list_jitter_fps_sub_edf_90 <- append (list_jitter_fps_sub_edf_90, (strtoi(task_fps_win_90[[i,1]][25], base = 0L) - strtoi(task_fps_win_90[[i,1]][20], base = 0L)))
}
cat(sprintf("FPS win for 90 group, high priority: %s, low priority low work: %s, low priority high work: %s\n", index_hp_90, index_lp_lw_90, index_lp_hw_90))
cat(sprintf("FPS avarage jitter for 90 group, higher on EDF: %s, higher on FPS: %s, avarage EDF - FPS: %s, min EDF - FPS: %s, max EDF - FPS: %s\n", number_jitter_fps_lower_edf_90, number_jitter_fps_higher_edf_90, mean(list_jitter_fps_sub_edf_90), min (list_jitter_fps_sub_edf_90), max(list_jitter_fps_sub_edf_90)))

