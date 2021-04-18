taskset = array (integer(), dim = c(10000,6))

for (i in 1:10000){
  print(i)
  file_name <- paste("../taskset-experiments/Buttazzo-Second-Preemptions/Buttazzo-Second-Preemptions_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  taskset[i,1] <- file_to_open[11,8]
  taskset[i,2] <- file_to_open[11,12]
  taskset[i,3] <- strtoi(file_to_open[11,8]) - strtoi(file_to_open[11,12])
  taskset[i,4] <- 0
  taskset[i,5] <- 0
  taskset[i,6] <- 0
  
  for (j in 1:10){
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

vecfps <- append(vecfps, taskset[327,1])
vecedf <- append(vecedf, taskset[327,2])

vecfps <- append(vecfps, taskset[1615,1])
vecedf <- append(vecedf, taskset[1615,2])

vecfps <- append(vecfps, taskset[2664,1])
vecedf <- append(vecedf, taskset[2664,2])

vecfps <- append(vecfps, taskset[3887,1])
vecedf <- append(vecedf, taskset[3887,2])

vecfps <- append(vecfps, taskset[4515,1])
vecedf <- append(vecedf, taskset[4515,2])

vecfps <- append(vecfps, taskset[5933,1])
vecedf <- append(vecedf, taskset[5933,2])

vecfps <- append(vecfps, taskset[6207,1])
vecedf <- append(vecedf, taskset[6207,2])

vecfps <- append(vecfps, taskset[7129,1])
vecedf <- append(vecedf, taskset[7129,2])

vecfps <- append(vecfps, taskset[8343,1])
vecedf <- append(vecedf, taskset[8343,2])

vecfps <- append(vecfps, taskset[9450,1])
vecedf <- append(vecedf, taskset[9450,2]) 

X <- c(0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95)


plot(X, vecedf, ylim = c(10,132), xlab="Load", ylab="Avarage number of preemptions", type="o", col="blue", pch="o", lty=1)

points(X, vecfps, col="red", pch="*")
lines(X, vecfps, col="red",lty=2)

legend("topleft",legend=c("EDF","RM"), col=c("blue","red"), pch=c("o","*"),lty=c(1,2), ncol=1)


i = 9450
file_name <- paste("../taskset-experiments/Buttazzo-Second-Preemptions/Buttazzo-Second-Preemptions_", c(i), ".csv", sep = "")
file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
armo = 0
for (j in 1:9){
  for (l in (j+1):10){
    if ((strtoi(file_to_open[l,3])%%strtoi(file_to_open[j,3]))==0){
      armo = armo+1
      print(file_to_open[l,3])
      print(file_to_open[j,3])
    }
  }
}

X1 = vector()
Y1 = vector()
Z1 = vector()

for (i in 1:10000){
  X1 <- append(X1, taskset[i,4])
  Y1 <- append(Y1, taskset[i,5])
  Z1 <- append(Z1, taskset[i,6])
}

X = vector()
Y = vector()
Z = vector()
R = vector()

X <- append(X, taskset[327,4])
Y <- append(Y, taskset[327,5])
Z <- append(Z, taskset[327,6])
R <- append(R, 2)

X <- append(X, taskset[1615,4])
Y <- append(Y, taskset[1615,5])
Z <- append(Z, taskset[1615,6])
R <- append(R, 4)

X <- append(X, taskset[2664,4])
Y <- append(Y, taskset[2664,5])
Z <- append(Z, taskset[2664,6])
R <- append(R, 2)

X <- append(X, taskset[3887,4])
Y <- append(Y, taskset[3887,5])
Z <- append(Z, taskset[3887,6])
R <- append(R, 0)

X <- append(X, taskset[4515,4])
Y <- append(Y, taskset[4515,5])
Z <- append(Z, taskset[4515,6])
R <- append(R, 2)

X <- append(X, taskset[5933,4])
Y <- append(Y, taskset[5933,5])
Z <- append(Z, taskset[5933,6])
R <- append(R, 0)

X <- append(X, taskset[6207,4])
Y <- append(Y, taskset[6207,5])
Z <- append(Z, taskset[6207,6])
R <- append(R, 0)

X <- append(X, taskset[7129,4])
Y <- append(Y, taskset[7129,5])
Z <- append(Z, taskset[7129,6])
R <- append(R, 2)

X <- append(X, taskset[8343,4])
Y <- append(Y, taskset[8343,5])
Z <- append(Z, taskset[8343,6])
R <- append(R, 2)

X <- append(X, taskset[9450,4])
Y <- append(Y, taskset[9450,5])
Z <- append(Z, taskset[9450,6])
R <- append(R, 0)

# library("plot3D")
# scatter3D(X, Y, Z,  col.var = R, pch = 16,ticktype = "detailed", bty = "g",
#           clab = c("Long"))
# text3D(X, Y, Z,  labels = R,
#        add = TRUE, colkey = FALSE, cex = 1.2)

library("plot3D")
scatter3D(X1, Y1, Z1, colvar = NULL, col = "grey", pch = 19, cex = 0.5,ticktype = "detailed")
text3D(X, Y, Z,  labels = R,
       add = TRUE, colkey = FALSE, cex = 1.2)
