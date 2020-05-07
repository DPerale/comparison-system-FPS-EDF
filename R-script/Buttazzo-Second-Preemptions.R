array_edf_preemptions = vector()
array_fps_preemptions = vector()

for (i in 1:10000){
  file_name <- paste("../taskset-experiments/Buttazzo-Second-Preemptions/Buttazzo-Second-Preemptions_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  array_edf_preemptions <- append(array_edf_preemptions, file_to_open[11,12])  
  array_fps_preemptions <- append(array_fps_preemptions, file_to_open[11,8])  
}

avarage_edf_preemptions = vector()
avarage_fps_preemptions = vector()
standard_devation_edf_preemptions = vector()
standard_devation_fps_preemptions = vector()

for (i in 0:9){
  avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(array_edf_preemptions[(1+i*1000):(1000+i*1000)]))
  standard_devation_edf_preemptions <- append(standard_devation_edf_preemptions, sd(array_edf_preemptions[(1+i*1000):(1000+i*1000)]))
  avarage_fps_preemptions <- append(avarage_fps_preemptions, mean(array_fps_preemptions[(1+i*1000):(1000+i*1000)]))
  standard_devation_fps_preemptions <- append(standard_devation_fps_preemptions, sd(array_fps_preemptions[(1+i*1000):(1000+i*1000)]))
}

X <- c(0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95)

plot(X, avarage_edf_preemptions, ylim=range(c(avarage_edf_preemptions-standard_devation_edf_preemptions, avarage_edf_preemptions+standard_devation_edf_preemptions)), xlab="Load", ylab="Avarage number of preemptions", type="o", col="blue", pch="o", lty=1)
arrows(X, avarage_edf_preemptions-standard_devation_edf_preemptions, X, avarage_edf_preemptions+standard_devation_edf_preemptions, length=0.05, angle=90, code=3, col="blue" )

points(X, avarage_fps_preemptions, col="red", pch="*")
lines(X, avarage_fps_preemptions, col="red",lty=2)
arrows(X, avarage_fps_preemptions-standard_devation_fps_preemptions, X, avarage_fps_preemptions+standard_devation_fps_preemptions, length=0.05, angle=90, code=3, col="red" )

legend("topleft",legend=c("EDF","RM"), col=c("blue","red"), pch=c("o","*"),lty=c(1,2), ncol=1)