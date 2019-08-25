possiblePeriods <- c()

# hyperperiods 952560000(7,5,4,2), 113400000(6,4,5,1), 567000000(6,4,6,1)
n2 <- 6
n3 <- 4
n5 <- 5
n7 <- 1

for (i in 0:(n2)){
  for (j in 0:(n3)){
    for (l in 0:(n5)){
      for (m in 0:(n7)){
        if ((((2**i)*(3**j)*(5**l)*(7**m)))>=400000 && (((2**i)*(3**j)*(5**l)*(7**m)))<=1000000){
          possiblePeriods <- c(possiblePeriods, (((2**i)*(3**j)*(5**l)*(7**m))))
        }
      }
    }
  }
}

possiblePeriods <- sort(possiblePeriods, decreasing = FALSE)
for (i in 1:length(possiblePeriods)){
  print (possiblePeriods[i])
}

print(length(possiblePeriods))

dataset <- c()
for (l in 1:10){
  alredy_insert <- c()
  for (j in 1:3){
    i <- 1
    while (i <= 10){
      to_insert <- possiblePeriods[floor(runif(1, min=(1), max=(length(possiblePeriods))))]/1000
      if (!is.element(to_insert, alredy_insert)){
        dataset <- c (dataset, to_insert)
        alredy_insert <- c (alredy_insert, to_insert)
        i <- i + 1
      }
    }
  }
}

#a <- table(dataset)
#ds <-  as.data.frame(table(dataset))
hist(possiblePeriods, breaks = 100, main = "Iperperiodo = 567000000", xlab = "Periodi (ms)", ylab = "Frequenza")
#print(ds[1])


library(nortest)
notest <- ks.test(ds[2], pnorm)
print(notest)
