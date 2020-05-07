array_edf_preemptions = vector()
array_fps_preemptions = vector()
array_fps__edf_preemtpions = vector()

for (i in 1:9000){
  file_name <- paste("../taskset-experiments/Buttazzo-First-Preemptions/Buttazzo-First-Preemptions_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  array_edf_preemptions <- append(array_edf_preemptions, file_to_open[5+((i-1)%/%1000)*2,12])  
  array_fps_preemptions <- append(array_fps_preemptions, file_to_open[5+((i-1)%/%1000)*2,8])  
  array_fps__edf_preemtpions <- append(array_fps__edf_preemtpions, strtoi(file_to_open[5+((i-1)%/%1000)*2,8]) - strtoi(file_to_open[5+((i-1)%/%1000)*2,12]))  
}

avarage_edf_preemptions = vector()
avarage_fps_preemptions = vector()
standard_devation_edf_preemptions = vector()
standard_devation_fps_preemptions = vector()

#avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(array_edf_preemptions[1:1000]))
for (i in 0:8){
  avarage_edf_preemptions <- append(avarage_edf_preemptions, mean(array_edf_preemptions[(1+i*1000):(1000+i*1000)]))
  standard_devation_edf_preemptions <- append(standard_devation_edf_preemptions, sd(array_edf_preemptions[(1+i*1000):(1000+i*1000)]))
  avarage_fps_preemptions <- append(avarage_fps_preemptions, mean(array_fps_preemptions[(1+i*1000):(1000+i*1000)]))
  standard_devation_fps_preemptions <- append(standard_devation_fps_preemptions, sd(array_fps_preemptions[(1+i*1000):(1000+i*1000)]))
}

X <- c(4,6,8,10,12,14,16,18,20)

print(avarage_edf_preemptions)
print(standard_devation_edf_preemptions)

plot(X, avarage_edf_preemptions, ylim=range(c(avarage_edf_preemptions-standard_devation_edf_preemptions, avarage_edf_preemptions+standard_devation_edf_preemptions)), xlab="Number of tasks", ylab="Avarage number of preemptions", type="o", col="blue", pch="o", lty=1)
arrows(X, avarage_edf_preemptions-standard_devation_edf_preemptions, X, avarage_edf_preemptions+standard_devation_edf_preemptions, length=0.05, angle=90, code=3, col="blue" )

points(X, avarage_fps_preemptions, col="red", pch="*")
lines(X, avarage_fps_preemptions, col="red",lty=2)
arrows(X, avarage_fps_preemptions-standard_devation_fps_preemptions, X, avarage_fps_preemptions+standard_devation_fps_preemptions, length=0.05, angle=90, code=3, col="red" )

legend("topleft",legend=c("EDF","RM"), col=c("blue","red"), pch=c("o","*"),lty=c(1,2), ncol=1)


plot(array_fps__edf_preemtpions[8001:9000], xlab="taskset", ylab="FPS minus EDF preemptions", type="o", col="blue", pch="o", lty=1)