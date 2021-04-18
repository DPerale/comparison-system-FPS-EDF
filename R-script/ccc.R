 file_name <- paste("../taskset-generated/prova2.csv", sep = "")
 file_to_open <- read.csv(file = file_name, header = TRUE, sep = ",", dec = ".")
 taskset = array (integer(), dim = c(10000))
 print(file_to_open[1,6])
 for (i in 1:10000){
   taskset[i] <- file_to_open[i,6]
 }
 
 
 for (j in 0:9){
   print(table(taskset[(1+j*1000):(1000+j*1000)]))
 }
 
 library(ggplot2)
 
 ok = vector()
 notok = vector()
 
 ok <- append(ok, (1000/1000))
 ok <- append(ok, (1000/1000))
 ok <- append(ok, (1000/1000))
 ok <- append(ok, (1000/1000))
 ok <- append(ok, (1000/1000))
 ok <- append(ok, (1000/1000))
 ok <- append(ok, (972/1000))
 ok <- append(ok, (643/1000))
 ok <- append(ok, (205/1000))
 ok <- append(ok, (13/1000))
 
 notok <- append(notok, (0))
 notok <- append(notok, (0))
 notok <- append(notok, (0))
 notok <- append(notok, (0))
 notok <- append(notok, (0))
 notok <- append(notok, (0))
 notok <- append(notok, (28/1000))
 notok <- append(notok, (357/1000))
 notok <- append(notok, (795/1000))
 notok <- append(notok, (986/1000))
 
 
utilization <- c( rep("0.50" , 2), rep("0.55" , 2) , rep("0.60" , 2) ,rep("0.65" , 2) ,rep("0.70" , 2) ,rep("0.75" , 2) ,rep("0.80" , 2) ,rep("0.85" , 2) ,rep("0.90" , 2) ,rep("0.95" , 2))
type <- rep(c("% Feasible FPS" , "% Not Feasible FPS") , 10)
percentage = vector()
for(i in 0:10){
  percentage <- append (percentage, ok[i])
  percentage <- append (percentage, notok[i])
}

data <- data.frame(utilization,type,percentage)
print(ggplot(data, aes(fill=type, y=percentage, x=utilization)) + geom_bar(position="dodge", stat="identity"))




ok = vector()
notok = vector()
numberok = 0
numbernotok = 0
okedf = vector()
notokedf = vector()
numberokedf = 0
numbernotokedf = 0

for (i in 6001:10000){
 
  
  yes = TRUE
  yesedf = TRUE
  file_name <- paste("../taskset-experiments/Buttazzo-Second-Preemptions/Buttazzo-Second-Preemptions_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  for (j in 1:10){
    if ((strtoi(file_to_open[j,6]) > 0)){
      yes = FALSE
    }
    if ((strtoi(file_to_open[j,10]) > 0)){
      yesedf = FALSE
    }
  }
  if (yes == TRUE) {
    numberok = numberok + 1
  }else{
    numbernotok = numbernotok + 1
  }
  
  if (yesedf == TRUE) {
    numberokedf = numberokedf + 1
  }else{
    numbernotokedf = numbernotokedf + 1
  }
  
  if(i%%1000 == 0){
    print("dentro")
    ok <- append(ok, (numberok/1000))
    notok <- append(notok, (numbernotok/1000))
    numberok = 0
    numbernotok = 0
    okedf <- append(okedf, (numberokedf/1000))
    notokedf <- append(notokedf, (numbernotokedf/1000))
    numberokedf = 0
    numbernotokedf = 0
  }
}




for (i in 1:1000){
  
  
  yes = TRUE
  yesedf = TRUE
  file_name <- paste("../taskset-experiments/Buttazzo-Second-Preemptions-over/Buttazzo-Second-Preemptions-over_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  for (j in 1:10){
    if ((strtoi(file_to_open[j,6]) > 0)){
      yes = FALSE
    }
    if ((strtoi(file_to_open[j,10]) > 0)){
      yesedf = FALSE
    }
  }
  if (yes == TRUE) {
    numberok = numberok + 1
  }else{
    numbernotok = numbernotok + 1
  }
  
  if (yesedf == TRUE) {
    numberokedf = numberokedf + 1
  }else{
    numbernotokedf = numbernotokedf + 1
  }
  
  if(i%%1000 == 0){
    print("dentro")
    ok <- append(ok, (numberok/1000))
    notok <- append(notok, (numbernotok/1000))
    numberok = 0
    numbernotok = 0
    okedf <- append(okedf, (numberokedf/1000))
    notokedf <- append(notokedf, (numbernotokedf/1000))
    numberokedf = 0
    numbernotokedf = 0
  }
}

for (i in 1:1000){
  
  
  yes = TRUE
  yesedf = TRUE
  file_name <- paste("../taskset-experiments/Buttazzo-Second-Preemptions-over2/Buttazzo-Second-Preemptions-over2_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  for (j in 1:10){
    if ((strtoi(file_to_open[j,6]) > 0)){
      yes = FALSE
    }
    if ((strtoi(file_to_open[j,10]) > 0)){
      yesedf = FALSE
    }
  }
  if (yes == TRUE) {
    numberok = numberok + 1
  }else{
    numbernotok = numbernotok + 1
  }
  
  if (yesedf == TRUE) {
    numberokedf = numberokedf + 1
  }else{
    numbernotokedf = numbernotokedf + 1
  }
  
  if(i%%1000 == 0){
    print("dentro")
    ok <- append(ok, (numberok/1000))
    notok <- append(notok, (numbernotok/1000))
    numberok = 0
    numbernotok = 0
    okedf <- append(okedf, (numberokedf/1000))
    notokedf <- append(notokedf, (numbernotokedf/1000))
    numberokedf = 0
    numbernotokedf = 0
  }
}






library(ggplot2)

utilization <- c(rep("0.80" , 4) ,rep("0.85" , 4) ,rep("0.90" , 4) ,rep("0.95" , 4),rep("0.98" , 4) ,rep("0.99" , 4))
type <- rep(c("% no DM over runs (RMS)" , "% DM over runs (RMS)", "% no DM over runs (EDF)" , "% DM over runs (EDF)") , 6)
percentage = vector()
for(i in 0:6){
  percentage <- append (percentage, ok[i])
  percentage <- append (percentage, notok[i])
  percentage <- append (percentage, okedf[i])
  percentage <- append (percentage, notokedf[i])
}

data <- data.frame(utilization,type,percentage)
p <- (ggplot(data, aes(fill=type, y=percentage, x=utilization)) + geom_bar(position="dodge", stat="identity"))

print (p + labs(y="Percentage", x = "Utilization", fill = "Event Type") + theme_linedraw() + theme_light())








armo = vector()

for (i in 6001:10000){
  print (i)
  file_name <- paste("../taskset-experiments/Buttazzo-Second-Preemptions/Buttazzo-Second-Preemptions_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  armonicity = vector()
  armonum = 0
  for (j in 1:9){
    for (l in (j+1):10){
      if (((strtoi(file_to_open[j,3])) %% (strtoi(file_to_open[l,3]))) == 0){
        armonicity <- append (armonicity, strtoi(file_to_open[j,3]))
        armonicity <- append (armonicity, strtoi(file_to_open[l,3]))
      }
      if (((strtoi(file_to_open[j,3])) == (strtoi(file_to_open[l,3])))){
        armonum = armonum + 1
      }
    }
  }
  armonum = armonum + length(unique(armonicity))
  armo <- append (armo, armonum)
}




for (i in 1:1000){
  file_name <- paste("../taskset-experiments/Buttazzo-Second-Preemptions-over/Buttazzo-Second-Preemptions-over_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  armonicity = vector()
  armonum = 0
  for (j in 1:9){
    for (l in (j+1):10){
      if (((strtoi(file_to_open[j,3])) %% (strtoi(file_to_open[l,3]))) == 0){
        armonicity <- append (armonicity, strtoi(file_to_open[j,3]))
        armonicity <- append (armonicity, strtoi(file_to_open[l,3]))
      }
      if (((strtoi(file_to_open[j,3])) == (strtoi(file_to_open[l,3])))){
        armonum = armonum + 1
      }
    }
  }
  armonum = armonum + length(unique(armonicity))
  armo <- append (armo, armonum)
}

for (i in 1:1000){
  
  file_name <- paste("../taskset-experiments/Buttazzo-Second-Preemptions-over2/Buttazzo-Second-Preemptions-over2_", c(i), ".csv", sep = "")
  file_to_open <- read.csv(file = file_name, header = TRUE, sep = ";", dec = ".")
  armonicity = vector()
  armonum = 0
  for (j in 1:9){
    for (l in (j+1):10){
      if (((strtoi(file_to_open[j,3])) %% (strtoi(file_to_open[l,3]))) == 0){
        armonicity <- append (armonicity, strtoi(file_to_open[j,3]))
        armonicity <- append (armonicity, strtoi(file_to_open[l,3]))
      }
      if (((strtoi(file_to_open[j,3])) == (strtoi(file_to_open[l,3])))){
        armonum = armonum + 1
      }
    }
  }
  armonum = armonum + length(unique(armonicity))
  armo <- append (armo, armonum)
}


