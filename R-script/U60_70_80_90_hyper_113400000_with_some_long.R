taskset = array (integer(), dim = c(4,500,2))

for (j in 0:3){
  for (i in 1:500){
    file_name <- paste("../taskset-experiments/U_",c(60+10*j),"_hyper_113400000_with_some_long/U_",c(60+10*j),"_hyper_113400000_with_some_long_", c(i), ".csv", sep = "")
    file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
    taskset [j+1,i,1]  <- file_to_open[21,12]
    taskset [j+1,i,2]  <- file_to_open[21,8]
  }
}

avarage_edf_preemptions = vector()
avarage_fps_preemptions = vector()
standard_devation_edf_preemptions = vector()
standard_devation_fps_preemptions = vector()

#avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(array_edf_preemptions[1:1000]))
for (i in 1:4){
  avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(taskset [i,,1]))
  standard_devation_edf_preemptions <- append(standard_devation_edf_preemptions, sd(taskset [j,,1]))
  avarage_fps_preemptions <- append(avarage_fps_preemptions, mean(taskset [i,,2]))
  standard_devation_fps_preemptions <- append(standard_devation_fps_preemptions, sd(taskset [i,,2]))
}

X <- c(0.6,0.7,0.8,0.9)

plot(X, avarage_edf_preemptions, xlab="Number of tasks", ylim = c(7000,20000), ylab="Avarage number of preemptions", type="o", col="blue", pch="o", lty=1)
arrows(X, avarage_edf_preemptions-standard_devation_edf_preemptions, X, avarage_edf_preemptions+standard_devation_edf_preemptions, length=0.05, angle=90, code=3, col="blue" )

points(X, avarage_fps_preemptions, col="red", pch="*")
lines(X, avarage_fps_preemptions, col="red",lty=2)
arrows(X, avarage_fps_preemptions-standard_devation_fps_preemptions, X, avarage_fps_preemptions+standard_devation_fps_preemptions, length=0.05, angle=90, code=3, col="red" )

legend("topleft",legend=c("EDF","FPS"), col=c("blue","red"), pch=c("o","*"),lty=c(1,2), ncol=1)
