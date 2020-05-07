array_edf_preemptions = vector()
array_fps_preemptions = vector()
array_fps_edf_preemptions = vector()

for (i in 1:10000){
  print(i)
  file_name <- paste("../taskset-experiments/Full_Harmonic/full_harmonic_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  array_edf_preemptions <- append(array_edf_preemptions, file_to_open[21,12])
  array_fps_preemptions <- append(array_fps_preemptions, file_to_open[21,8])
  array_fps_edf_preemptions <- append(array_fps_edf_preemptions, ((strtoi(file_to_open[21,8])-strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8])))
}

avarage_edf_preemptions = mean (array_edf_preemptions)
avarage_fps_preemptions = mean (array_fps_preemptions)
avarage_fps_edf_preemptions = mean (array_fps_edf_preemptions)
min_fps_edf_preemptions = min (array_fps_edf_preemptions)
max_fps_edf_preemptions = max (array_fps_edf_preemptions)


print(avarage_edf_preemptions)
print(avarage_fps_preemptions)
print(avarage_fps_edf_preemptions)
print(min_fps_edf_preemptions)
print(max_fps_edf_preemptions)

####################################################

array_edf_preemptions = vector()
array_fps_preemptions = vector()
array_fps_edf_preemptions = vector()

for (i in 1:1000){
  print(i)
  file_name <- paste("../taskset-experiments/Semi_Harmonic/semi_harmonic_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  array_edf_preemptions <- append(array_edf_preemptions, file_to_open[21,12])  
  array_fps_preemptions <- append(array_fps_preemptions, file_to_open[21,8])  
  array_fps_edf_preemptions <- append(array_fps_edf_preemptions, ((strtoi(file_to_open[21,8])-strtoi(file_to_open[21,12]))/strtoi(file_to_open[21,8])))
}

avarage_edf_preemptions = mean (array_edf_preemptions)
avarage_fps_preemptions = mean (array_fps_preemptions)
avarage_fps_edf_preemptions = mean (array_fps_edf_preemptions)
min_fps_edf_preemptions = min (array_fps_edf_preemptions)
max_fps_edf_preemptions = max (array_fps_edf_preemptions)


print(avarage_edf_preemptions)
print(avarage_fps_preemptions)
print(avarage_fps_edf_preemptions)
print(min_fps_edf_preemptions)
print(max_fps_edf_preemptions)