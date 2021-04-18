taskset = array (integer(), dim = c(9000,6))

for (i in 1:9000){
  print(i)
  file_name <- paste("/home/aquox/Scrivania/comparison-system-FPS-EDF/taskset-experiments/Buttazzo-First-Preemptions/Buttazzo-First-Preemptions_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  taskset[i,1] <- file_to_open[5+((i-1)%/%1000)*2,8]
  taskset[i,2] <- file_to_open[5+((i-1)%/%1000)*2,12]
  taskset[i,3] <- strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12])
  taskset[i,4] <- 0
  taskset[i,5] <- 0
  taskset[i,6] <- 0
  
  for (j in 1:(4+((i-1)%/%1000)*2)){
    if (strtoi(file_to_open[j,3]) < 30000){
      taskset[i,4] <- taskset[i,4] + 1
    }else{
      if (strtoi(file_to_open[j,3]) < 70000){
        taskset[i,5] <- taskset[i,5] + 1
      }else{
        taskset[i,6] <- taskset[i,6] + 1
      }
    }
  }
}

vecfps = vector()
vecedf = vector()

vecfps <- append(vecfps, taskset[333,1])
vecedf <- append(vecedf, taskset[333,2])

vecfps <- append(vecfps, taskset[1150,1])
vecedf <- append(vecedf, taskset[1150,2])

vecfps <- append(vecfps, taskset[2353,1])
vecedf <- append(vecedf, taskset[2353,2])

vecfps <- append(vecfps, taskset[3010,1])
vecedf <- append(vecedf, taskset[3010,2])

vecfps <- append(vecfps, taskset[4044,1])
vecedf <- append(vecedf, taskset[4044,2])

vecfps <- append(vecfps, taskset[5280,1])
vecedf <- append(vecedf, taskset[5280,2])

vecfps <- append(vecfps, taskset[6240,1])
vecedf <- append(vecedf, taskset[6240,2])

vecfps <- append(vecfps, taskset[7036,1])
vecedf <- append(vecedf, taskset[7036,2])

vecfps <- append(vecfps, taskset[8987,1])
vecedf <- append(vecedf, taskset[8987,2])

X <- c(4,6,8,10,12,14,16,18,20)


plot(X, vecedf, ylim = c(20,152), xlab="Task in Taskset", ylab="Avarage number of preemptions", type="o", col="blue", pch="o", lty=1)

points(X, vecfps, col="red", pch="*")
lines(X, vecfps, col="red",lty=2)

legend("topleft",legend=c("EDF","RM"), col=c("blue","red"), pch=c("o","*"),lty=c(1,2), ncol=1)


i = 8987
file_name <- paste("/home/aquox/Scrivania/comparison-system-FPS-EDF/taskset-experiments/Buttazzo-First-Preemptions/Buttazzo-First-Preemptions_", c(i), ".csv", sep = "")
file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
armo = 0
for (j in 1:19){
  for (l in (j+1):20){
    if ((strtoi(file_to_open[l,3])%%strtoi(file_to_open[j,3]))==0){
      armo = armo+1
      # print(file_to_open[l,3])
      # print(file_to_open[j,3])
    }
  }
}

X1 = vector()
Y1 = vector()
Z1 = vector()

for (i in 1:9000){
  X1 <- append(X1, taskset[i,4])
  Y1 <- append(Y1, taskset[i,5])
  Z1 <- append(Z1, taskset[i,6])
}


X = vector()
Y = vector()
Z = vector()
R = vector()

X <- append(X, taskset[333,4])
Y <- append(Y, taskset[333,5])
Z <- append(Z, taskset[333,6])
R <- append(R, 0)

X <- append(X, taskset[1150,4])
Y <- append(Y, taskset[1150,5])
Z <- append(Z, taskset[1150,6])
R <- append(R, 0)

X <- append(X, taskset[2353,4])
Y <- append(Y, taskset[2353,5])
Z <- append(Z, taskset[2353,6])
R <- append(R, 2)

X <- append(X, taskset[3010,4])
Y <- append(Y, taskset[3010,5])
Z <- append(Z, taskset[3010,6])
R <- append(R, 5)

X <- append(X, taskset[4044,4])
Y <- append(Y, taskset[4044,5])
Z <- append(Z, taskset[4044,6])
R <- append(R, 3)

X <- append(X, taskset[5280,4])
Y <- append(Y, taskset[5280,5])
Z <- append(Z, taskset[5280,6])
R <- append(R, 8)

X <- append(X, taskset[6240,4])
Y <- append(Y, taskset[6240,5])
Z <- append(Z, taskset[6240,6])
R <- append(R, 6)

X <- append(X, taskset[7036,4])
Y <- append(Y, taskset[7036,5])
Z <- append(Z, taskset[7036,6])
R <- append(R, 2)

X <- append(X, taskset[8987,4])
Y <- append(Y, taskset[8987,5])
Z <- append(Z, taskset[8987,6])
R <- append(R, 10)

# library("plot3D")
# scatter3D(X, Y, Z,  col.var = R, pch = 16,ticktype = "detailed", bty = "g",
#           clab = c("Long"))
# text3D(X, Y, Z,  labels = R,
#        add = TRUE, colkey = FALSE, cex = 1.2)

library("plot3D")
scatter3D(X1, Y1, Z1, colvar = NULL, col = "grey", pch = 19, cex = 0.5,ticktype = "detailed")
text3D(X, Y, Z,  labels = R,
       add = TRUE, colkey = FALSE, cex = 1.2)







