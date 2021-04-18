high_utilization = 0.045
low_priority = 15
taskset = array (integer(), dim = c(11,500,20))

array_edf_preemptions = vector()
array_fps_preemptions = vector()
array_fps_edf_preemptions = vector()

for (i in 1:500){
  file_name <- paste("../taskset-experiments/U_100_hyper_113400000_10_100_full/U_100_hyper_113400000_10_100_full_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  #print(i)
  
  array_edf_preemptions <- append(array_edf_preemptions, file_to_open[21,12])
  array_fps_preemptions <- append(array_fps_preemptions, file_to_open[21,8])
  array_fps_edf_preemptions <- append(array_fps_edf_preemptions, ((strtoi(file_to_open[21,8])-strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8])))
  
  periods = array(integer(), dim = c(20))
  for (j in 1:20){
    periods[j] <- file_to_open[j,3]
  }
  lcm = 1
  for (j in 1:20){
    lcm = pracma::Lcm(lcm,periods[j])
  }
  
  for (j in 1:20){
    # DM FPS
    taskset [1,i,j]  <- file_to_open[j,6]
    # DM EDF
    taskset [2,i,j]  <- file_to_open[j,10]
    # executions EDF
    taskset [3,i,j]  <- file_to_open[j,11]
    # preemptions EDF
    taskset [4,i,j]  <- file_to_open[j,12]
    # DM/executions EDF
    taskset [5,i,j]  <- (strtoi(file_to_open[j,10]) / strtoi(file_to_open[j,11]))
    # preemptions/executions EDF
    taskset [6,i,j]  <- (strtoi(file_to_open[j,12]) / strtoi(file_to_open[j,11]))
    # FPS Preemption
    taskset [7,i,j]  <- file_to_open[j,8]
    # FPS Executions
    taskset [8,i,j]  <- file_to_open[j,7]
    # DM/executions EDF
    taskset [9,i,j]  <- (strtoi(file_to_open[j,6]) / strtoi(file_to_open[j,7]))
    # preemptions/executions EDF
    taskset [10,i,j]  <- (strtoi(file_to_open[j,8]) / strtoi(file_to_open[j,7]))
    #
    taskset [11,i,j]  <- floor(strtoi(file_to_open[21,3]) / periods[j])
  }
 
}


library(ggplot2)


avg_1 = vector()
avg_2 = vector()
avg_3 = vector()
avg_4 = vector()
avg_5 = vector()
avg_6 = vector()
avg_7 = vector()
avg_8 = vector()
avg_9 = vector()
avg_10 = vector()
avg_11 = vector()
for (i in 1:20){
  avg_1 <- append(avg_1, mean(taskset[1,,i]))
  avg_2 <- append(avg_2, mean(taskset[2,,i]))
  avg_3 <- append(avg_3, mean(taskset[3,,i]))
  avg_4 <- append(avg_4, mean(taskset[4,,i]))
  avg_5 <- append(avg_5, mean(taskset[5,,i]))
  avg_6 <- append(avg_6, mean(taskset[6,,i]))
  avg_7 <- append(avg_7, mean(taskset[7,,i],na.rm=TRUE))
  avg_8 <- append(avg_8, mean(taskset[8,,i],na.rm=TRUE))
  avg_9 <- append(avg_9, mean(taskset[9,,i],na.rm=TRUE))
  avg_10 <- append(avg_10, mean(taskset[10,,i],na.rm=TRUE))
  avg_11 <- append(avg_11, mean(taskset[11,,i],na.rm=TRUE))
}


# assoluti EDF
tasks <- c(rep("01" , 3) , rep("02" , 3) ,rep("03" , 3) ,rep("04" , 3) ,rep("05" , 3) ,rep("06" , 3) ,rep("07" , 3) ,rep("08" , 3) ,rep("09" , 3) ,rep("10" , 3) ,rep("11" , 3) ,rep("12" , 3) ,rep("13" , 3) ,rep("14" , 3) ,rep("15" , 3) ,rep("16" , 3) ,rep("17" , 3) ,rep("18" , 3) ,rep("19" , 3) ,rep("20" , 3) )
type <- rep(c("2Preemptions",  "1Deadline Miss", "0Regular Completions"   ) , 20)
value = vector()
for (i in 1:20) {
  value <- append (value, avg_2[i])
  value <- append (value, avg_4[i])
  value <- append (value, avg_3[i])
}
data <- data.frame(tasks,type,value)
#print(ggplot(data, aes(fill=type, y=value, x=tasks)) + geom_bar(position="dodge", stat="identity"))
p <- (ggplot(data, aes(fill=type, y=value, x=tasks)) + geom_bar(position="dodge", stat="identity"))
print (p + labs(y="Cumulative count across runs", x = "Tasks in taskset \n(increasing rate)", fill = "Event Type") + theme_linedraw() + theme_light())

# normalizzati EDF
tasks <- c(rep("01" , 3) , rep("02" , 3) ,rep("03" , 3) ,rep("04" , 3) ,rep("05" , 3) ,rep("06" , 3) ,rep("07" , 3) ,rep("08" , 3) ,rep("09" , 3) ,rep("10" , 3) ,rep("11" , 3) ,rep("12" , 3) ,rep("13" , 3) ,rep("14" , 3) ,rep("15" , 3) ,rep("16" , 3) ,rep("17" , 3) ,rep("18" , 3) ,rep("19" , 3) ,rep("20" , 3) )
type <- rep(c("0Regular completions (RC)/RC" , "1Deadline miss/RC" , "2Preemptions/RC") , 20)
value = vector()
for (i in 1:20) {
  value <- append (value, 1)
  value <- append (value, avg_6[i])
  value <- append (value, avg_5[i])
}
data <- data.frame(tasks,type,value)
#print(ggplot(data, aes(fill=type, y=value, x=tasks)) + geom_bar(position="dodge", stat="identity"))
p <- (ggplot(data, aes(fill=type, y=value, x=tasks)) + geom_bar(position="dodge", stat="identity"))
print (p + labs(y="Cumulative count across runs normalized", x = "Tasks in taskset \n(increasing rate)", fill = "Event Type") + theme_linedraw() + theme_light())


# assoluti FPS
tasks <- c(rep("01" , 4) , rep("02" , 4) ,rep("03" , 4) ,rep("04" , 4) ,rep("05" , 4) ,rep("06" , 4) ,rep("07" , 4) ,rep("08" , 4) ,rep("09" , 4) ,rep("10" , 4) ,rep("11" , 4) ,rep("12" , 4) ,rep("13" , 4) ,rep("14" , 4) ,rep("15" , 4) ,rep("16" , 4) ,rep("17" , 4) ,rep("18" , 4) ,rep("19" , 4) ,rep("20" , 4) )
type <- rep(c("0Total Releases", "1Regular Completions" ,"2Deadline Miss" , "3Preemptions") , 20)
value = vector()
for (i in 1:20) {
  value <- append (value, avg_11[i])
  value <- append (value, avg_8[i])
  value <- append (value, avg_1[i])
  value <- append (value, avg_7[i])
}
data <- data.frame(tasks,type,value)
#print(ggplot(data, aes(fill=type, y=value, x=tasks)) + geom_bar(position="dodge", stat="identity"))
p <- (ggplot(data, aes(fill=type, y=value, x=tasks)) + geom_bar(position="dodge", stat="identity"))
print (p + labs(y="Cumulative count across runs", x = "Tasks in taskset \n(increasing rate)", fill = "Event Type") + theme_linedraw() + theme_light())

# normalizzati FPS
tasks <- c(rep("01" , 4) , rep("02" , 4) ,rep("03" , 4) ,rep("04" , 4) ,rep("05" , 4) ,rep("06" , 4) ,rep("07" , 4) ,rep("08" , 4) ,rep("09" , 4) ,rep("10" , 4) ,rep("11" , 4) ,rep("12" , 4) ,rep("13" , 4) ,rep("14" , 4) ,rep("15" , 4) ,rep("16" , 4) ,rep("17" , 4) ,rep("18" , 4) ,rep("19" , 4) ,rep("20" , 4) )
type <- rep(c("0Total Releases/RC", "1Regular completions (RC)/RC" , "2Deadline Miss/RC" , "3Preempionts/RC") , 20)
value = vector()
for (i in 1:20) {
  value <- append (value, avg_11[i]/avg_8[i])
  value <- append (value, 1)
  value <- append (value, avg_9[i])
  value <- append (value, avg_10[i])
}
data <- data.frame(tasks,type,value)
p <- (ggplot(data, aes(fill=type, y=value, x=tasks)) + geom_bar(position="dodge", stat="identity"))
print (p + labs(y="Cumulative count across runs normalized", x = "Tasks in taskset \n(increasing rate)", fill = "Event Type") + theme_linedraw() + theme_light())

# X <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20)
# barplot(avg_1, names.arg=X, xlab="Tasks", ylab="FPS Deadline Miss", ylim=c(0,max(avg_1)))
# 
# barplot(avg_2, names.arg=X, xlab="Tasks", ylab="EDF Deadline Miss", ylim=c(0,max(avg_2)))
# 
# barplot(avg_3, names.arg=X, xlab="Tasks", ylab="EDF Regular Completions", ylim=c(0,max(avg_3)))
# 
# barplot(avg_4, names.arg=X, xlab="Tasks", ylab="EDF Preemptions", ylim=c(0,max(avg_4)))
# 
# barplot(avg_5, names.arg=X, xlab="Tasks", ylab="EDF DM / EDF RC", ylim=c(0,max(avg_5)))
# 
# barplot(avg_6, names.arg=X, xlab="Tasks", ylab="EDF P / EDF RC", ylim=c(0,max(avg_6)))

################################




# for (j in 1:1){
#   
#   taskset_2 = vector()
#   taskset_3 = vector()
#   taskset_4 = vector()
#   taskset_5 = vector()
#   taskset_6 = vector()
#   
#   for (i in 1:20){
#     taskset_2 <- append(taskset_2, taskset[2,j,i])
#     taskset_3 <- append(taskset_3, taskset[3,j,i])
#     taskset_4 <- append(taskset_4, taskset[4,j,i])
#     taskset_5 <- append(taskset_5, taskset[5,j,i])
#     taskset_6 <- append(taskset_6, taskset[6,j,i])
#   }
  
  
  # barplot(taskset_2, names.arg=X, xlab="Tasks", ylab="EDF Deadline Miss", ylim=c(0,max(taskset_2)))
  # 
  # barplot(taskset_3, names.arg=X, xlab="Tasks", ylab="EDF Regular Completions", ylim=c(0,max(taskset_3)))
  # 
  # barplot(taskset_4, names.arg=X, xlab="Tasks", ylab="EDF Preemptions", ylim=c(0,max(taskset_4)))
  # 
  # 
  # barplot(taskset_5, names.arg=X, xlab="Tasks", ylab="EDF DM / EDF RC", ylim=c(0,max(taskset_5)))
  # 
  # barplot(taskset_6, names.arg=X, xlab="Tasks", ylab="EDF P / EDF RC", ylim=c(0,max(taskset_6)))
  
  
  # Grouped Bar Plot
  # counts <- table(taskset_5, taskset_6, unos)
  # barplot(counts, xlab="Number of Gears", col=c("grey","blue","red"), beside=TRUE)
  # legend("topleft",legend=c("DM","P","RC"), col=c("grey","blue","red"), lty=c(1,2), ncol=1)
  
  # assoluti
#   tasks <- c(rep("01" , 3) , rep("02" , 3) ,rep("03" , 3) ,rep("04" , 3) ,rep("05" , 3) ,rep("06" , 3) ,rep("07" , 3) ,rep("08" , 3) ,rep("09" , 3) ,rep("10" , 3) ,rep("11" , 3) ,rep("12" , 3) ,rep("13" , 3) ,rep("14" , 3) ,rep("15" , 3) ,rep("16" , 3) ,rep("17" , 3) ,rep("18" , 3) ,rep("19" , 3) ,rep("20" , 3) )
#   type <- rep(c("DM" , "P" , "RC") , 20)
#   value = vector()
#   for (i in 1:20) {
#     value <- append (value, taskset_2[i])
#     value <- append (value, taskset_4[i])
#     value <- append (value, taskset_3[i])
#   }
#   data <- data.frame(tasks,type,value)
#   print(ggplot(data, aes(fill=type, y=value, x=tasks)) + geom_bar(position="dodge", stat="identity"))
#   
#   # normalizzati
#   tasks <- c(rep("01" , 3) , rep("02" , 3) ,rep("03" , 3) ,rep("04" , 3) ,rep("05" , 3) ,rep("06" , 3) ,rep("07" , 3) ,rep("08" , 3) ,rep("09" , 3) ,rep("10" , 3) ,rep("11" , 3) ,rep("12" , 3) ,rep("13" , 3) ,rep("14" , 3) ,rep("15" , 3) ,rep("16" , 3) ,rep("17" , 3) ,rep("18" , 3) ,rep("19" , 3) ,rep("20" , 3) )
#   type <- rep(c("DM/RC" , "P/RC" , "RC/RC") , 20)
#   value = vector()
#   for (i in 1:20) {
#     value <- append (value, taskset_5[i])
#     value <- append (value, taskset_6[i])
#     value <- append (value, 1)
#   }
#   data <- data.frame(tasks,type,value)
#   print(ggplot(data, aes(fill=type, y=value, x=tasks)) + geom_bar(position="dodge", stat="identity"))
# }





