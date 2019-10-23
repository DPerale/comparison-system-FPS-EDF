taskset1 = matrix(list(), nrow = 1000, ncol = 4)
taskset2 = matrix(list(), nrow = 1000, ncol = 4)
taskset3 = matrix(list(), nrow = 1000, ncol = 4)
taskset4 = matrix(list(), nrow = 1000, ncol = 4)
taskset5 = matrix(list(), nrow = 1000, ncol = 4)
taskset6 = matrix(list(), nrow = 1000, ncol = 4)
taskset7 = matrix(list(), nrow = 1000, ncol = 4)
taskset8 = matrix(list(), nrow = 1000, ncol = 4)
taskset9 = matrix(list(), nrow = 1000, ncol = 4)
taskset10 = matrix(list(), nrow = 1000, ncol = 4)

index1 = 1
index2 = 1
index3 = 1
index4 = 1
index5 = 1
index6 = 1
index7 = 1
index8 = 1
index9 = 1
index10 = 1

for (i in 1:10000){
  file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/Buttazzo-Second-Preemptions/Buttazzo-Second-Preemptions_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  
  if (i < 1001) {
    taskset1 [[index1,1]]  <- file_to_open[11,8]
    taskset1 [[index1,2]]  <- file_to_open[11,12]
    taskset1 [[index1,3]]  <- (strtoi(file_to_open[11,8]) - strtoi(file_to_open[11,12]))
    taskset1 [[index1,4]]  <- i
    index1 <- index1 + 1
  }
  if (i >= 1001 & i < 2001) {
    taskset2 [[index2,1]]  <- file_to_open[11,8]
    taskset2 [[index2,2]]  <- file_to_open[11,12]
    taskset2 [[index2,3]]  <- (strtoi(file_to_open[11,8]) - strtoi(file_to_open[11,12]))
    taskset2 [[index2,4]]  <- i
    index2 <- index2 + 1
  }
  if (i >= 2001 & i < 3001) {
    taskset3 [[index3,1]]  <- file_to_open[11,8]
    taskset3 [[index3,2]]  <- file_to_open[11,12]
    taskset3 [[index3,3]]  <- (strtoi(file_to_open[11,8]) - strtoi(file_to_open[11,12]))
    taskset3 [[index3,4]]  <- i
    index3 <- index3 + 1
  }
  if (i >= 3001 & i < 4001) {
    taskset4 [[index4,1]]  <- file_to_open[11,8]
    taskset4 [[index4,2]]  <- file_to_open[11,12]
    taskset4 [[index4,3]]  <- (strtoi(file_to_open[11,8]) - strtoi(file_to_open[11,12]))
    taskset4 [[index4,4]]  <- i
    index4 <- index4 + 1
  }
  if (i >= 4001 & i < 5001) {
    taskset5 [[index5,1]]  <- file_to_open[11,8]
    taskset5 [[index5,2]]  <- file_to_open[11,12]
    taskset5 [[index5,3]]  <- (strtoi(file_to_open[11,8]) - strtoi(file_to_open[11,12]))
    taskset5 [[index5,4]]  <- i
    index5 <- index5 + 1
  }
  if (i >= 5001 & i < 6001) {
    taskset6 [[index6,1]]  <- file_to_open[11,8]
    taskset6 [[index6,2]]  <- file_to_open[11,12]
    taskset6 [[index6,3]]  <- (strtoi(file_to_open[11,8]) - strtoi(file_to_open[11,12]))
    taskset6 [[index6,4]]  <- i
    index6 <- index6 + 1
  }
  if (i >= 6001 & i < 7001) {
    taskset7 [[index7,1]]  <- file_to_open[11,8]
    taskset7 [[index7,2]]  <- file_to_open[11,12]
    taskset7 [[index7,3]]  <- (strtoi(file_to_open[11,8]) - strtoi(file_to_open[11,12]))
    taskset7 [[index7,4]]  <- i
    index7 <- index7 + 1
  }
  if (i >= 7001 & i < 8001) {
    taskset8 [[index8,1]]  <- file_to_open[11,8]
    taskset8 [[index8,2]]  <- file_to_open[11,12]
    taskset8 [[index8,3]]  <- (strtoi(file_to_open[11,8]) - strtoi(file_to_open[11,12]))
    taskset8 [[index8,4]]  <- i
    index8 <- index8 + 1
  }
  if (i >= 8001 & i < 9001) {
    taskset9 [[index9,1]]  <- file_to_open[11,8]
    taskset9 [[index9,2]]  <- file_to_open[11,12]
    taskset9 [[index9,3]]  <- (strtoi(file_to_open[11,8]) - strtoi(file_to_open[11,12]))
    taskset9 [[index9,4]]  <- i
    index9 <- index9 + 1
  }
  if (i >= 9001) {
    taskset10 [[index10,1]]  <- file_to_open[11,8]
    taskset10 [[index10,2]]  <- file_to_open[11,12]
    taskset10 [[index10,3]]  <- (strtoi(file_to_open[11,8]) - strtoi(file_to_open[11,12]))
    taskset10 [[index10,4]]  <- i
    index10 <- index10 + 1
  }
}

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

taskset10.df <- as.data.frame(taskset10)
taskset10.df$V1 <- as.integer(taskset10.df$V1)
taskset10.df$V2 <- as.integer(taskset10.df$V2)
taskset10.df$V3 <- as.integer(taskset10.df$V3)


taskset1.df <- taskset1.df [order(taskset1.df$V3, decreasing = FALSE),]
taskset2.df <- taskset2.df [order(taskset2.df$V3, decreasing = FALSE),]
taskset3.df <- taskset3.df [order(taskset3.df$V3, decreasing = FALSE),]
taskset4.df <- taskset4.df [order(taskset4.df$V3, decreasing = FALSE),]
taskset5.df <- taskset5.df [order(taskset5.df$V3, decreasing = FALSE),]
taskset6.df <- taskset6.df [order(taskset6.df$V3, decreasing = FALSE),]
taskset7.df <- taskset7.df [order(taskset7.df$V3, decreasing = FALSE),]
taskset8.df <- taskset8.df [order(taskset8.df$V3, decreasing = FALSE),]
taskset9.df <- taskset9.df [order(taskset9.df$V3, decreasing = FALSE),]



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

avarage_edf_preemptions_high <- append(avarage_edf_preemptions_high, mean(taskset8.df$V2[701:849]))
standard_devation_edf_preemptions_high <- append(standard_devation_edf_preemptions_high, sd(taskset8.df$V2[701:849]))
avarage_fps_preemptions_high <- append(avarage_fps_preemptions_high, mean(taskset8.df$V1[701:849]))
standard_devation_fps_preemptions_high <- append(standard_devation_fps_preemptions_high, sd(taskset8.df$V1[701:849]))

avarage_edf_preemptions_high <- append(avarage_edf_preemptions_high, mean(taskset9.df$V2[850:950]))
standard_devation_edf_preemptions_high <- append(standard_devation_edf_preemptions_high, sd(taskset9.df$V2[850:950]))
avarage_fps_preemptions_high <- append(avarage_fps_preemptions_high, mean(taskset9.df$V1[850:950]))
standard_devation_fps_preemptions_high <- append(standard_devation_fps_preemptions_high, sd(taskset9.df$V1[850:950]))

avarage_edf_preemptions_high <- append(avarage_edf_preemptions_high, mean(taskset9.df$V2[951:1000]))
standard_devation_edf_preemptions_high <- append(standard_devation_edf_preemptions_high, sd(taskset9.df$V2[901:1000]))
avarage_fps_preemptions_high <- append(avarage_fps_preemptions_high, mean(taskset9.df$V1[951:1000]))
standard_devation_fps_preemptions_high <- append(standard_devation_fps_preemptions_high, sd(taskset9.df$V1[901:1000]))

print(avarage_edf_preemptions_high)
print(avarage_fps_preemptions_high)


X <- c(0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95)

plot(X, avarage_edf_preemptions_high, ylim=range(c(avarage_edf_preemptions_high-standard_devation_edf_preemptions_high, avarage_edf_preemptions_high+standard_devation_edf_preemptions_high)), xlab="Load", ylab="Avarage number of preemptions", type="o", col="blue", pch="o", lty=1)
arrows(X, avarage_edf_preemptions_high-standard_devation_edf_preemptions_high, X, avarage_edf_preemptions_high+standard_devation_edf_preemptions_high, length=0.05, angle=90, code=3, col="blue" )

points(X, avarage_fps_preemptions_high, col="red", pch="*")
lines(X, avarage_fps_preemptions_high, col="red",lty=2)
arrows(X, avarage_fps_preemptions_high-standard_devation_fps_preemptions_high, X, avarage_fps_preemptions_high+standard_devation_fps_preemptions_high, length=0.05, angle=90, code=3, col="red" )

legend(1,100,legend=c("EDF","FPS"), col=c("blue","red"), pch=c("o","*"),lty=c(1,2), ncol=1)



# array_edf_preemptions = vector()
# array_fps_preemptions = vector()
# 
# for (i in 1:10000){
#   file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/Buttazzo-Second-Preemptions/Buttazzo-Second-Preemptions_", c(i), ".csv", sep = "")
#   file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
#   array_edf_preemptions <- append(array_edf_preemptions, file_to_open[11,12])  
#   array_fps_preemptions <- append(array_fps_preemptions, file_to_open[11,8])  
# }

# 4+(i%/%1000)*2

# avarage_edf_preemptions = vector()
# avarage_fps_preemptions = vector()
# standard_devation_edf_preemptions = vector()
# standard_devation_fps_preemptions = vector()

#avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(array_edf_preemptions[1:1000]))
# for (i in 0:9){
#   avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(array_edf_preemptions[(1+i*1000):(1000+i*1000)]))
#   standard_devation_edf_preemptions <- append(standard_devation_edf_preemptions, sd(array_edf_preemptions[(1+i*1000):(1000+i*1000)]))
#   avarage_fps_preemptions <- append(avarage_fps_preemptions, mean(array_fps_preemptions[(1+i*1000):(1000+i*1000)]))
#   standard_devation_fps_preemptions <- append(standard_devation_fps_preemptions, sd(array_fps_preemptions[(1+i*1000):(1000+i*1000)]))
# }
# 
# X <- c(0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95)
# 
# plot(X, avarage_edf_preemptions, ylim=range(c(avarage_edf_preemptions-standard_devation_edf_preemptions, avarage_edf_preemptions+standard_devation_edf_preemptions)), xlab="Load", ylab="Avarage number of preemptions", type="o", col="blue", pch="o", lty=1)
# arrows(X, avarage_edf_preemptions-standard_devation_edf_preemptions, X, avarage_edf_preemptions+standard_devation_edf_preemptions, length=0.05, angle=90, code=3, col="blue" )
# 
# points(X, avarage_fps_preemptions, col="red", pch="*")
# lines(X, avarage_fps_preemptions, col="red",lty=2)
# arrows(X, avarage_fps_preemptions-standard_devation_fps_preemptions, X, avarage_fps_preemptions+standard_devation_fps_preemptions, length=0.05, angle=90, code=3, col="red" )
# 
# legend(1,100,legend=c("EDF","FPS"), col=c("blue","red"), pch=c("o","*"),lty=c(1,2), ncol=1)