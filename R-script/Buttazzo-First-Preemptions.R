taskset1 = matrix(list(), nrow = 1000, ncol = 4)
taskset2 = matrix(list(), nrow = 1000, ncol = 4)
taskset3 = matrix(list(), nrow = 1000, ncol = 4)
taskset4 = matrix(list(), nrow = 1000, ncol = 4)
taskset5 = matrix(list(), nrow = 1000, ncol = 4)
taskset6 = matrix(list(), nrow = 1000, ncol = 4)
taskset7 = matrix(list(), nrow = 1000, ncol = 4)
taskset8 = matrix(list(), nrow = 1000, ncol = 4)
taskset9 = matrix(list(), nrow = 1000, ncol = 4)



taskset = array (numeric(), dim = c(9,3,1000,10))



index1 = 1
index2 = 1
index3 = 1
index4 = 1
index5 = 1
index6 = 1
index7 = 1
index8 = 1
index9 = 1
index8_1 = 1
index8_2 = 1
index8_3 = 1
index9_1 = 1
index9_2 = 1
index9_3 = 1


task_edf_preemptions = vector()
task_fps_preemptions = vector()
armonic_0_2 = vector()

for (i in 1:9000){
  file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/Buttazzo_First_Preemptions/Buttazzo-First-Preemptions_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  
  armonic = vector()
  long = 0
  medium = 0
  short = 0
  sumperiod = 0
  for (l in (4+((i-1)%/%1000)*2):1){
    sumperiod = sumperiod + file_to_open[l,3]
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
  for (l in (4+((i-1)%/%1000)*2):2){
    for (m in 1:(l-1)){
      if ((file_to_open[l,3]%%file_to_open[m,3]) == 0){
        armonic <- append(armonic, file_to_open[l,3])  
        armonic <- append(armonic, file_to_open[m,3])  
      }
    }
  }
 
  # for (l in 1:(4+((i-1)%/%1000)*2)){
  #   task_edf_preemptions <- append(task_edf_preemptions, file_to_open[l,12])  
  #   task_fps_preemptions <- append(task_fps_preemptions, file_to_open[l,8])  
  # }
  
  if (i < 1001) {
    taskset1 [[index1,1]]  <- file_to_open[5+((i-1)%/%1000)*2,8]
    taskset1 [[index1,2]]  <- file_to_open[5+((i-1)%/%1000)*2,12]
    taskset1 [[index1,3]]  <- (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))
    taskset1 [[index1,4]]  <- i
    index1 <- index1 + 1
  }
  if (i >= 1001 & i < 2001) {
    taskset2 [[index2,1]]  <- file_to_open[5+((i-1)%/%1000)*2,8]
    taskset2 [[index2,2]]  <- file_to_open[5+((i-1)%/%1000)*2,12]
    taskset2 [[index2,3]]  <- (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))
    taskset2 [[index2,4]]  <- i
    index2 <- index2 + 1
  }
  if (i >= 2001 & i < 3001) {
    taskset3 [[index3,1]]  <- file_to_open[5+((i-1)%/%1000)*2,8]
    taskset3 [[index3,2]]  <- file_to_open[5+((i-1)%/%1000)*2,12]
    taskset3 [[index3,3]]  <- (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))
    taskset3 [[index3,4]]  <- i
    index3 <- index3 + 1
  }
  if (i >= 3001 & i < 4001) {
    taskset4 [[index4,1]]  <- file_to_open[5+((i-1)%/%1000)*2,8]
    taskset4 [[index4,2]]  <- file_to_open[5+((i-1)%/%1000)*2,12]
    taskset4 [[index4,3]]  <- (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))
    taskset4 [[index4,4]]  <- i
    index4 <- index4 + 1
  }
  if (i >= 4001 & i < 5001) {
    taskset5 [[index5,1]]  <- file_to_open[5+((i-1)%/%1000)*2,8]
    taskset5 [[index5,2]]  <- file_to_open[5+((i-1)%/%1000)*2,12]
    taskset5 [[index5,3]]  <- (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))
    taskset5 [[index5,4]]  <- i
    index5 <- index5 + 1
  }
  if (i >= 5001 & i < 6001) {
    taskset6 [[index6,1]]  <- file_to_open[5+((i-1)%/%1000)*2,8]
    taskset6 [[index6,2]]  <- file_to_open[5+((i-1)%/%1000)*2,12]
    taskset6 [[index6,3]]  <- (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))
    taskset6 [[index6,4]]  <- i
    index6 <- index6 + 1
  }
  if (i >= 6001 & i < 7001) {
    taskset7 [[index7,1]]  <- file_to_open[5+((i-1)%/%1000)*2,8]
    taskset7 [[index7,2]]  <- file_to_open[5+((i-1)%/%1000)*2,12]
    taskset7 [[index7,3]]  <- (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))
    taskset7 [[index7,4]]  <- i
    index7 <- index7 + 1
  }
  if (i >= 7001 & i < 8001) {
    taskset8 [[index8,1]]  <- file_to_open[5+((i-1)%/%1000)*2,8]
    taskset8 [[index8,2]]  <- file_to_open[5+((i-1)%/%1000)*2,12]
    taskset8 [[index8,3]]  <- (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))
    taskset8 [[index8,4]]  <- i
    index8 <- index8 + 1
    
    if (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) < 172){
      taskset [8,1,index8_1,1]  <- file_to_open[5+((i-1)%/%1000)*2,8]
      taskset [8,1,index8_1,2]  <- file_to_open[5+((i-1)%/%1000)*2,12]
      taskset [8,1,index8_1,3]  <- (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))
      taskset [8,1,index8_1,4]  <- i
      taskset [8,1,index8_1,5]  <- length(unique(armonic))
      taskset [8,1,index8_1,6]  <- short
      taskset [8,1,index8_1,7]  <- medium
      taskset [8,1,index8_1,8]  <- long
      index8_1 <- index8_1 + 1
    }
    if (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) >= 172 & strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) <= 253 ){
      taskset [8,2,index8_2,1]  <- file_to_open[5+((i-1)%/%1000)*2,8]
      taskset [8,2,index8_2,2]  <- file_to_open[5+((i-1)%/%1000)*2,12]
      taskset [8,2,index8_2,3]  <- (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))
      taskset [8,2,index8_2,4]  <- i
      taskset [8,2,index8_2,5]  <- length(unique(armonic))
      taskset [8,2,index8_2,6]  <- short
      taskset [8,2,index8_2,7]  <- medium
      taskset [8,2,index8_2,8]  <- long
      index8_2 <- index8_2 + 1
    }
    if (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) > 253){
      taskset [8,3,index8_3,1]  <- file_to_open[5+((i-1)%/%1000)*2,8]
      taskset [8,3,index8_3,2]  <- file_to_open[5+((i-1)%/%1000)*2,12]
      taskset [8,3,index8_3,3]  <- (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))
      taskset [8,3,index8_3,4]  <- i
      taskset [8,3,index8_3,5]  <- length(unique(armonic))
      taskset [8,3,index8_3,6]  <- short
      taskset [8,3,index8_3,7]  <- medium
      taskset [8,3,index8_3,8]  <- long
      index8_3 <- index8_3 + 1
    }
  }
  if (i >= 8001) {
    
    taskset9 [[index9,1]]  <- file_to_open[5+((i-1)%/%1000)*2,8]
    taskset9 [[index9,2]]  <- file_to_open[5+((i-1)%/%1000)*2,12]
    taskset9 [[index9,3]]  <- (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))
    taskset9 [[index9,4]]  <- i
    index9 <- index9 + 1
    
    if (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) < 183){
      taskset [9,1,index9_1,1]  <- file_to_open[5+((i-1)%/%1000)*2,8]
      taskset [9,1,index9_1,2]  <- file_to_open[5+((i-1)%/%1000)*2,12]
      taskset [9,1,index9_1,3]  <- (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))
      taskset [9,1,index9_1,4]  <- i
      taskset [9,1,index9_1,5]  <- length(unique(armonic))
      taskset [9,1,index9_1,6]  <- short
      taskset [9,1,index9_1,7]  <- medium
      taskset [9,1,index9_1,8]  <- long
      taskset [9,1,index9_1,9]  <- sumperiod
      taskset [9,1,index9_1,10]  <- file_to_open[7+((i-1)%/%1000)*2,8]
      index9_1 <- index9_1 + 1
    }
    if (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) >= 183 & strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) <= 258 ){
      taskset [9,2,index9_2,1]  <- file_to_open[5+((i-1)%/%1000)*2,8]
      taskset [9,2,index9_2,2]  <- file_to_open[5+((i-1)%/%1000)*2,12]
      taskset [9,2,index9_2,3]  <- (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))
      taskset [9,2,index9_2,4]  <- i
      taskset [9,2,index9_2,5]  <- length(unique(armonic))
      taskset [9,2,index9_2,6]  <- short
      taskset [9,2,index9_2,7]  <- medium
      taskset [9,2,index9_2,8]  <- long
      taskset [9,2,index9_2,9]  <- sumperiod
      taskset [9,2,index9_2,10]  <- file_to_open[7+((i-1)%/%1000)*2,8]
      index9_2 <- index9_2 + 1
    }
    if (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) > 258){
      taskset [9,3,index9_3,1]  <- file_to_open[5+((i-1)%/%1000)*2,8]
      taskset [9,3,index9_3,2]  <- file_to_open[5+((i-1)%/%1000)*2,12]
      taskset [9,3,index9_3,3]  <- (strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))
      taskset [9,3,index9_3,4]  <- i
      taskset [9,3,index9_3,5]  <- length(unique(armonic))
      taskset [9,3,index9_3,6]  <- short
      taskset [9,3,index9_3,7]  <- medium
      taskset [9,3,index9_3,8]  <- long
      taskset [9,3,index9_3,9]  <- sumperiod
      taskset [9,3,index9_3,10]  <- file_to_open[7+((i-1)%/%1000)*2,8]
      index9_3 <- index9_3 + 1
    }
  }
}
 
# # short mid long
# res <- boxplot (taskset[8,1,,6], taskset[8,1,,7], taskset[8,1,,8], taskset[8,2,,6], taskset[8,2,,7], taskset[8,2,,8], taskset[8,3,,6], taskset[8,3,,7], taskset[8,3,,8], names=c("short g1","medium g1","long g1", "short g2","medium g2","long g2", "short g3","medium g3","long g3"), scipen=5, main="tipo task per gruppo", xlab="Task", ylab="quantità")
# abline(h = 7, col = "red")
# res$stats

# # armonicità
# res <- boxplot (taskset[8,1,,5], taskset[8,2,,5], taskset[8,3,,5], names=c("gruppo 1","gruppo2","gruppo 3"), scipen=5, main="Grado armonicità", xlab="Task", ylab="grado armonicità")
# abline(h = 7, col = "red")
# res$stats

# # fps preemption - edf preemption
# res <- boxplot (taskset[8,1,,3], taskset[8,2,,3], taskset[8,3,,3], names=c("gruppo 1","gruppo 2","gruppo 3"), scipen=5, main="FPS Preemtpion - EDF Preemption", xlab="Task", ylab="Differenza preemption")
# abline(h = 15, col = "red")
# res$stats

# # fps preemption - edf preemption
# res <- boxplot (taskset[9,1,,9], taskset[9,2,,9], taskset[9,3,,9], names=c("gruppo 1","gruppo 2","gruppo 3"), scipen=5, main="Somma periodi", xlab="Task", ylab="Ms")
# abline(h = 500000, col = "red")
# res$stats

# fps preemption - edf preemption %
res <- boxplot (taskset[9,1,,10], taskset[9,2,,10], taskset[9,3,,10], names=c("gruppo 1","gruppo 2","gruppo 3"), scipen=5, main="FPS preemption - EDF preemption (cumulative)", xlab="Taskset", ylab="%")
abline(h = 500000, col = "red")
res$stats



taskset1.df <- as.data.frame(taskset1)

taskset1.df$V1 <- as.integer(taskset1.df$V1)
taskset1.df$V2 <- as.integer(taskset1.df$V2)
taskset1.df$V3 <- as.integer(taskset1.df$V3)

taskset2.df <- as.data.frame(taskset2)
taskset2.df$V1 <- as.integer(taskset2.df$V1)
taskset2.df$V2 <- as.integer(taskset2.df$V2)
taskset2.df$V3 <- as.integer(taskset2.df$V3)


taskset3.df <- as.data.frame(taskset3)
taskset3.df$V1 <- as.integer(taskset3.df$V1)
taskset3.df$V2 <- as.integer(taskset3.df$V2)
taskset3.df$V3 <- as.integer(taskset3.df$V3)


taskset4.df <- as.data.frame(taskset4)
taskset4.df$V1 <- as.integer(taskset4.df$V1)
taskset4.df$V2 <- as.integer(taskset4.df$V2)
taskset4.df$V3 <- as.integer(taskset4.df$V3)


taskset5.df <- as.data.frame(taskset5)
taskset5.df$V1 <- as.integer(taskset5.df$V1)
taskset5.df$V2 <- as.integer(taskset5.df$V2)
taskset5.df$V3 <- as.integer(taskset5.df$V3)



taskset6.df <- as.data.frame(taskset6)
taskset6.df$V1 <- as.integer(taskset6.df$V1)
taskset6.df$V2 <- as.integer(taskset6.df$V2)
taskset6.df$V3 <- as.integer(taskset6.df$V3)


taskset7.df <- as.data.frame(taskset7)
taskset7.df$V1 <- as.integer(taskset7.df$V1)
taskset7.df$V2 <- as.integer(taskset7.df$V2)
taskset7.df$V3 <- as.integer(taskset7.df$V3)


taskset8.df <- as.data.frame(taskset8)
taskset8.df$V1 <- as.integer(taskset8.df$V1)
taskset8.df$V2 <- as.integer(taskset8.df$V2)
taskset8.df$V3 <- as.integer(taskset8.df$V3)

taskset9.df <- as.data.frame(taskset9)
taskset9.df$V1 <- as.integer(taskset9.df$V1)
taskset9.df$V2 <- as.integer(taskset9.df$V2)
taskset9.df$V3 <- as.integer(taskset9.df$V3)

taskset.df <- as.data.frame(taskset[8,,,])
taskset.df <- taskset.df [order(taskset.df$V1, decreasing = TRUE),]


print("ciao2")
taskset1.df <- taskset1.df [order(taskset1.df$V3, decreasing = TRUE),]
taskset2.df <- taskset2.df [order(taskset2.df$V3, decreasing = TRUE),]
taskset3.df <- taskset3.df [order(taskset3.df$V3, decreasing = TRUE),]
taskset4.df <- taskset4.df [order(taskset4.df$V3, decreasing = TRUE),]
taskset5.df <- taskset5.df [order(taskset5.df$V3, decreasing = TRUE),]
taskset6.df <- taskset6.df [order(taskset6.df$V3, decreasing = TRUE),]
taskset7.df <- taskset7.df [order(taskset7.df$V3, decreasing = TRUE),]
taskset8.df <- taskset8.df [order(taskset8.df$V3, decreasing = TRUE),]


print("ciao3")

# avarage_edf_preemptions_low = vector()
# avarage_fps_preemptions_low = vector()
# standard_devation_edf_preemptions_low = vector()
# standard_devation_fps_preemptions_low = vector()
# 
# avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(taskset1.df[1:500][3]))
# standard_devation_edf_preemptions <- append(standard_devation_edf_preemptions, sd(array_edf_preemptions[(1+i*1000):(1000+i*1000)]))
# avarage_fps_preemptions <- append(avarage_fps_preemptions, mean(taskset1.df$V1[1:500]))
# standard_devation_fps_preemptions <- append(standard_devation_fps_preemptions, sd(taskset1.df$V1[1:500]))




avarage_edf_preemptions_high = vector()
avarage_fps_preemptions_high = vector()
standard_devation_edf_preemptions_high = vector()
standard_devation_fps_preemptions_high = vector()

avarage_edf_preemptions_high <- append(avarage_edf_preemptions_high, mean(taskset1.df$V2[1:100]))
standard_devation_edf_preemptions_high <- append(standard_devation_edf_preemptions_high, sd(taskset1.df$V2[1:100]))
avarage_fps_preemptions_high <- append(avarage_fps_preemptions_high, mean(taskset1.df$V1[1:100]))
standard_devation_fps_preemptions_high <- append(standard_devation_fps_preemptions_high, sd(taskset1.df$V1[1:100]))

avarage_edf_preemptions_high <- append(avarage_edf_preemptions_high, mean(taskset2.df$V2[101:200]))
standard_devation_edf_preemptions_high <- append(standard_devation_edf_preemptions_high, sd(taskset2.df$V2[101:200]))
avarage_fps_preemptions_high <- append(avarage_fps_preemptions_high, mean(taskset2.df$V1[101:200]))
standard_devation_fps_preemptions_high <- append(standard_devation_fps_preemptions_high, sd(taskset2.df$V1[101:200]))

avarage_edf_preemptions_high <- append(avarage_edf_preemptions_high, mean(taskset3.df$V2[201:300]))
standard_devation_edf_preemptions_high <- append(standard_devation_edf_preemptions_high, sd(taskset3.df$V2[201:300]))
avarage_fps_preemptions_high <- append(avarage_fps_preemptions_high, mean(taskset3.df$V1[201:300]))
standard_devation_fps_preemptions_high <- append(standard_devation_fps_preemptions_high, sd(taskset3.df$V1[201:300]))

avarage_edf_preemptions_high <- append(avarage_edf_preemptions_high, mean(taskset4.df$V2[301:400]))
standard_devation_edf_preemptions_high <- append(standard_devation_edf_preemptions_high, sd(taskset4.df$V2[301:400]))
avarage_fps_preemptions_high <- append(avarage_fps_preemptions_high, mean(taskset4.df$V1[301:400]))
standard_devation_fps_preemptions_high <- append(standard_devation_fps_preemptions_high, sd(taskset4.df$V1[301:400]))

avarage_edf_preemptions_high <- append(avarage_edf_preemptions_high, mean(taskset5.df$V2[401:500]))
standard_devation_edf_preemptions_high <- append(standard_devation_edf_preemptions_high, sd(taskset5.df$V2[401:500]))
avarage_fps_preemptions_high <- append(avarage_fps_preemptions_high, mean(taskset5.df$V1[401:500]))
standard_devation_fps_preemptions_high <- append(standard_devation_fps_preemptions_high, sd(taskset5.df$V1[401:500]))

avarage_edf_preemptions_high <- append(avarage_edf_preemptions_high, mean(taskset6.df$V2[501:600]))
standard_devation_edf_preemptions_high <- append(standard_devation_edf_preemptions_high, sd(taskset6.df$V2[501:600]))
avarage_fps_preemptions_high <- append(avarage_fps_preemptions_high, mean(taskset6.df$V1[501:600]))
standard_devation_fps_preemptions_high <- append(standard_devation_fps_preemptions_high, sd(taskset6.df$V1[501:600]))

avarage_edf_preemptions_high <- append(avarage_edf_preemptions_high, mean(taskset7.df$V2[601:700]))
standard_devation_edf_preemptions_high <- append(standard_devation_edf_preemptions_high, sd(taskset7.df$V2[601:700]))
avarage_fps_preemptions_high <- append(avarage_fps_preemptions_high, mean(taskset7.df$V1[601:700]))
standard_devation_fps_preemptions_high <- append(standard_devation_fps_preemptions_high, sd(taskset7.df$V1[601:700]))

avarage_edf_preemptions_high <- append(avarage_edf_preemptions_high, mean(taskset8.df$V2[850:950]))
standard_devation_edf_preemptions_high <- append(standard_devation_edf_preemptions_high, sd(taskset8.df$V2[850:950]))
avarage_fps_preemptions_high <- append(avarage_fps_preemptions_high, mean(taskset8.df$V1[850:950]))
standard_devation_fps_preemptions_high <- append(standard_devation_fps_preemptions_high, sd(taskset8.df$V1[850:950]))

avarage_edf_preemptions_high <- append(avarage_edf_preemptions_high, mean(taskset9.df$V2[951:1000]))
standard_devation_edf_preemptions_high <- append(standard_devation_edf_preemptions_high, sd(taskset9.df$V2[901:1000]))
avarage_fps_preemptions_high <- append(avarage_fps_preemptions_high, mean(taskset9.df$V1[951:1000]))
standard_devation_fps_preemptions_high <- append(standard_devation_fps_preemptions_high, sd(taskset9.df$V1[901:1000]))

print(avarage_edf_preemptions_high)
print(avarage_fps_preemptions_high)



avarage_edf_preemptions = vector()
avarage_fps_preemptions = vector()
standard_devation_edf_preemptions = vector()
standard_devation_fps_preemptions = vector()

avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(task_edf_preemptions[1:4000]))
standard_devation_edf_preemptions <- append(standard_devation_edf_preemptions, sd(task_edf_preemptions[1:4000]))
avarage_fps_preemptions <- append(avarage_fps_preemptions, mean(task_fps_preemptions[1:4000]))
standard_devation_fps_preemptions <- append(standard_devation_fps_preemptions, sd(task_fps_preemptions[1:4000]))

avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(task_edf_preemptions[4001:10000]))
standard_devation_edf_preemptions <- append(standard_devation_edf_preemptions, sd(task_edf_preemptions[4001:10000]))
avarage_fps_preemptions <- append(avarage_fps_preemptions, mean(task_fps_preemptions[4001:10000]))
standard_devation_fps_preemptions <- append(standard_devation_fps_preemptions, sd(task_fps_preemptions[4001:10000]))

avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(task_edf_preemptions[10001:18000]))
standard_devation_edf_preemptions <- append(standard_devation_edf_preemptions, sd(task_edf_preemptions[10001:18000]))
avarage_fps_preemptions <- append(avarage_fps_preemptions, mean(task_fps_preemptions[10001:18000]))
standard_devation_fps_preemptions <- append(standard_devation_fps_preemptions, sd(task_fps_preemptions[10001:18000]))

avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(task_edf_preemptions[18001:28000]))
standard_devation_edf_preemptions <- append(standard_devation_edf_preemptions, sd(task_edf_preemptions[18001:28000]))
avarage_fps_preemptions <- append(avarage_fps_preemptions, mean(task_fps_preemptions[18001:28000]))
standard_devation_fps_preemptions <- append(standard_devation_fps_preemptions, sd(task_fps_preemptions[18001:28000]))

avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(task_edf_preemptions[28001:40000]))
standard_devation_edf_preemptions <- append(standard_devation_edf_preemptions, sd(task_edf_preemptions[28001:40000]))
avarage_fps_preemptions <- append(avarage_fps_preemptions, mean(task_fps_preemptions[28001:40000]))
standard_devation_fps_preemptions <- append(standard_devation_fps_preemptions, sd(task_fps_preemptions[28001:40000]))

avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(task_edf_preemptions[40001:54000]))
standard_devation_edf_preemptions <- append(standard_devation_edf_preemptions, sd(task_edf_preemptions[40001:54000]))
avarage_fps_preemptions <- append(avarage_fps_preemptions, mean(task_fps_preemptions[40001:54000]))
standard_devation_fps_preemptions <- append(standard_devation_fps_preemptions, sd(task_fps_preemptions[40001:54000]))

avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(task_edf_preemptions[54001:70000]))
standard_devation_edf_preemptions <- append(standard_devation_edf_preemptions, sd(task_edf_preemptions[54001:70000]))
avarage_fps_preemptions <- append(avarage_fps_preemptions, mean(task_fps_preemptions[54001:70000]))
standard_devation_fps_preemptions <- append(standard_devation_fps_preemptions, sd(task_fps_preemptions[54001:70000]))

avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(task_edf_preemptions[70001:88000]))
standard_devation_edf_preemptions <- append(standard_devation_edf_preemptions, sd(task_edf_preemptions[70001:88000]))
avarage_fps_preemptions <- append(avarage_fps_preemptions, mean(task_fps_preemptions[70001:88000]))
standard_devation_fps_preemptions <- append(standard_devation_fps_preemptions, sd(task_fps_preemptions[70001:88000]))

avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(task_edf_preemptions[88001:108000]))
standard_devation_edf_preemptions <- append(standard_devation_edf_preemptions, sd(task_edf_preemptions[88001:108000]))
avarage_fps_preemptions <- append(avarage_fps_preemptions, mean(task_fps_preemptions[88001:108000]))
standard_devation_fps_preemptions <- append(standard_devation_fps_preemptions, sd(task_fps_preemptions[88001:108000]))

print (avarage_edf_preemptions)
print (avarage_fps_preemptions)


X <- c(4,6,8,10,12,14,16,18,20)

plot(X, avarage_edf_preemptions, ylim=range(c(0, 300)), xlab="Number of tasks", ylab="Avarage number of preemptions", type="o", col="blue", pch="o", lty=1)
arrows(X, avarage_edf_preemptions-standard_devation_edf_preemptions, X, avarage_edf_preemptions+standard_devation_edf_preemptions, length=0.05, angle=90, code=3, col="blue" )
points(X, avarage_fps_preemptions, col="red", pch="*")
lines(X, avarage_fps_preemptions, col="red",lty=2)
arrows(X, avarage_fps_preemptions-standard_devation_fps_preemptions, X, avarage_fps_preemptions+standard_devation_fps_preemptions, length=0.05, angle=90, code=3, col="red" )
legend(1,100,legend=c("EDF","FPS"), col=c("blue","red"), pch=c("o","*"),lty=c(1,2), ncol=1)


ylim=range(c(avarage_edf_preemptions_high-standard_devation_edf_preemptions_high, avarage_edf_preemptions_high+standard_devation_edf_preemptions_high))
plot(X, avarage_edf_preemptions_high, ylim=range(c(0, 370)), xlab="Number of tasks", ylab="Avarage number of preemptions", type="o", col="blue", pch="o", lty=1)
arrows(X, avarage_edf_preemptions_high-standard_devation_edf_preemptions_high, X, avarage_edf_preemptions_high+standard_devation_edf_preemptions_high, length=0.05, angle=90, code=3, col="blue" )
points(X, avarage_fps_preemptions_high, col="red", pch="*")
lines(X, avarage_fps_preemptions_high, col="red",lty=2)
arrows(X, avarage_fps_preemptions_high-standard_devation_fps_preemptions_high, X, avarage_fps_preemptions_high+standard_devation_fps_preemptions_high, length=0.05, angle=90, code=3, col="red" )
legend(1,100,legend=c("EDF","FPS"), col=c("blue","red"), pch=c("o","*"),lty=c(1,2), ncol=1)



# array_edf_preemptions = vector()
# array_fps_preemptions = vector()
# array_fps_minus_edf_preemptions = vector()
# 
# 
# for (i in 1:9000){
#   file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/Buttazzo_First_Preemptions/Buttazzo-First-Preemptions_", c(i), ".csv", sep = "")
#   file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
#   array_edf_preemptions <- append(array_edf_preemptions, file_to_open[5+((i-1)%/%1000)*2,12])  
#   array_fps_preemptions <- append(array_fps_preemptions, file_to_open[5+((i-1)%/%1000)*2,8])  
#   array_fps_minus_edf_preemptions <- append(array_fps_minus_edf_preemptions, (file_to_open[5+((i-1)%/%1000)*2,8] - file_to_open[5+((i-1)%/%1000)*2,12]))
# }




#group1 <- 
#print(group1[[1,1]])




# print (array_fps_minus_edf_preemptions)
# print (min(array_fps_minus_edf_preemptions))
# print (max(array_fps_minus_edf_preemptions))
# 
# # 4+(i%/%1000)*2
# 
# avarage_edf_preemptions = vector()
# avarage_fps_preemptions = vector()
# standard_devation_edf_preemptions = vector()
# standard_devation_fps_preemptions = vector()
# 
# median_fps_minus_edf_preemptions = vector()
# 
# 
# 
# 
# 
# #avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(array_edf_preemptions[1:1000]))
# for (i in 0:8){
#   avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(array_edf_preemptions[(1+i*1000):(1000+i*1000)]))
#   standard_devation_edf_preemptions <- append(standard_devation_edf_preemptions, sd(array_edf_preemptions[(1+i*1000):(1000+i*1000)]))
#   avarage_fps_preemptions <- append(avarage_fps_preemptions, mean(array_fps_preemptions[(1+i*1000):(1000+i*1000)]))
#   standard_devation_fps_preemptions <- append(standard_devation_fps_preemptions, sd(array_fps_preemptions[(1+i*1000):(1000+i*1000)]))
# 
#   median_fps_minus_edf_preemptions <- append (median_fps_minus_edf_preemptions, median(array_fps_minus_edf_preemptions[(1+i*1000):(1000+i*1000)]))
# }
# 
# print(median_fps_minus_edf_preemptions)
# 
# X <- c(4,6,8,10,12,14,16,18,20)
# 
# plot(X, avarage_edf_preemptions, ylim=range(c(avarage_edf_preemptions-standard_devation_edf_preemptions, avarage_edf_preemptions+standard_devation_edf_preemptions)), xlab="Number of tasks", ylab="Avarage number of preemptions", type="o", col="blue", pch="o", lty=1)
# arrows(X, avarage_edf_preemptions-standard_devation_edf_preemptions, X, avarage_edf_preemptions+standard_devation_edf_preemptions, length=0.05, angle=90, code=3, col="blue" )
# 
# points(X, avarage_fps_preemptions, col="red", pch="*")
# lines(X, avarage_fps_preemptions, col="red",lty=2)
# arrows(X, avarage_fps_preemptions-standard_devation_fps_preemptions, X, avarage_fps_preemptions+standard_devation_fps_preemptions, length=0.05, angle=90, code=3, col="red" )
# 
# legend(1,100,legend=c("EDF","FPS"), col=c("blue","red"), pch=c("o","*"),lty=c(1,2), ncol=1)

# 
# # dev.off()
# # 
# # X = c(8001:9000)
# # plot (X, array_fps_preemptions[8001:9000] - array_edf_preemptions[8001:9000], xlab="taskset", ylab="FPS-EDF preemptions", type="o", col="blue", pch="o", lty=1)

