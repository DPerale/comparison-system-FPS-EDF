array_edf_preemptions = vector()
array_fps_preemptions = vector()
#array_edf_work_jitter = vector()
#array_fps_work_jitter = vector()
#array_edf_release_jitter = vector()
#array_fps_release_jitter = vector()


for (i in 1:500){
  file_name <- paste("/home/aquox/Scrivania/Arm/workspace2/U_90_hyper_113400000/U_90_hyper_113400000_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  array_edf_preemptions <- append(array_edf_preemptions, file_to_open[21,12])  
  array_fps_preemptions <- append(array_fps_preemptions, file_to_open[21,8])  
  #array_edf_work_jitter <-
  #array_fps_work_jitter <-
  #array_edf_release_jitter <-
  #array_fps_release_jitter <-
}

# 4+(i%/%1000)*2

avarage_edf_preemptions = mean(array_edf_preemptions[1:500])
avarage_fps_preemptions = mean(array_fps_preemptions[1:500])
standard_devation_edf_preemptions = sd(array_edf_preemptions[1:500])
standard_devation_fps_preemptions = sd(array_fps_preemptions[1:500])

print (avarage_edf_preemptions)
print (avarage_fps_preemptions)

X <- c(0.9)
plot(X, avarage_edf_preemptions, ylim=range(c(avarage_edf_preemptions-standard_devation_edf_preemptions, avarage_edf_preemptions+standard_devation_edf_preemptions)), xlab="Load", ylab="Avarage number of preemptions", type="o", col="blue", pch="o", lty=1)
arrows(X, avarage_edf_preemptions-standard_devation_edf_preemptions, X, avarage_edf_preemptions+standard_devation_edf_preemptions, length=0.05, angle=90, code=3, col="blue" )
points(X, avarage_fps_preemptions, col="red", pch="*")
lines(X, avarage_fps_preemptions, col="red",lty=2)
arrows(X, avarage_fps_preemptions-standard_devation_fps_preemptions, X, avarage_fps_preemptions+standard_devation_fps_preemptions, length=0.05, angle=90, code=3, col="red" )
legend(1,100,legend=c("EDF","FPS"), col=c("blue","red"), pch=c("o","*"),lty=c(1,2), ncol=1)


dev.off()
X = c(1:500)
plot (X, array_fps_preemptions[1:500] - array_edf_preemptions[1:500], xlab="taskset", ylab="FPS-EDF preemptions", type="o", col="blue", pch="o", lty=1)