array_edf_preemptions = vector()
array_fps_preemptions = vector()

for (i in 1:500){
  file_name <- paste("../taskset-experiments/U_90_log_uniform/U_90_log_uniform_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  array_edf_preemptions <- append(array_edf_preemptions, file_to_open[21,12])  
  array_fps_preemptions <- append(array_fps_preemptions, file_to_open[21,8])  
}

avarage_edf_preemptions = mean(array_edf_preemptions)
avarage_fps_preemptions = mean(array_fps_preemptions)
standard_devation_edf_preemptions = sd(array_edf_preemptions)
standard_devation_fps_preemptions = sd(array_fps_preemptions)

print(avarage_edf_preemptions)
print(avarage_fps_preemptions)
print(standard_devation_edf_preemptions)
print(standard_devation_fps_preemptions)