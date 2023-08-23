library(rjson)
library(tidyverse)
library(magrittr)
library(ggplot2)

chowDiscontinuityAlgorithm <- function(data) {
  
  valuevec <- c()

  for (i in 3:(nrow(data)-3)) {
    testresult <- (strucchange::sctest(as.numeric(as.POSIXct(data$to)) ~ as.numeric(data$NDVI_index), type = "Chow", point = i))
    valuevec <- c(valuevec, testresult$statistic)
  }
  
  valuevec %<>% unname()

}

getwd()
filename <- "data30.json"
hakkuuaika <- as.POSIXct("2019-06-15")
rajaaVuoteen <- TRUE
jatkuvuusanalyysi <- TRUE
pivot <- FALSE

if (rajaaVuoteen) {
  title <- "Hakkuun vaikutus normalisoituun kasvillisuusindeksiin: rajaus, vuosi"
} else {
  title <- "Hakkuun vaikutus normalisoituun kasvillisuusindeksiin, ei aikarajausta"
}

data <- fromJSON(file = filename)
data <- data[[1]]
nobs <- length(data)
newdf <- data.frame(#from = numeric(nobs), 
                    to = numeric(nobs), min = numeric(nobs),
                    max = numeric(nobs), mean = numeric(nobs)#, stdev = numeric(nobs)
                    )

data %<>% unlist()

for (i in 1:nobs) {
  #newdf$from[i] <- data[8*(i-1) + 1]
  newdf$to[i] <- data[8*(i-1) + 2]
  newdf$min[i] <- data[8*(i-1) + 3]
  newdf$max[i] <- data[8*(i-1) + 4]
  newdf$mean[i] <- data[8*(i-1) + 5]
  #newdf$stdev[i] <- data[8*(i-1) + 6]
}

print(newdf)
newdf$mean %<>% as.numeric()
newdf$mean[is.infinite(newdf$mean)] <- NA
newdf %<>% na.omit()

if (rajaaVuoteen) {
  
  newdf <- newdf %>%
    filter(to > as.POSIXct(paste(as.character(format(hakkuuaika, format = "%Y")), "01", "01", sep = "-"))) %>%
    filter(to < as.POSIXct(paste(as.character(format(hakkuuaika, format = "%Y")), "12", "31", sep = "-")))
  
} 

if (pivot) {
  newdf <- newdf %>%
    pivot_longer(!to, names_to = "critical_value", values_to = "NDVI_index")
} else if (!pivot) {
  colnames(newdf)[4] <- "NDVI_index"
}

newdf$hakkuu <- numeric(nrow(newdf))

if (!jatkuvuusanalyysi) {
  
  ggplot(newdf, aes(x = as.POSIXct(to), y = as.numeric(NDVI_index), col = hakkuu)) + geom_point()
  
} else if (jatkuvuusanalyysi) {
  
  newdf %>%
    ungroup %>%
    mutate(hakkuu = ifelse(newdf$to > as.POSIXct("2019-06-15"), "hakkuu", "ei hakkuuta")) %>% 
    ggplot(aes(x = as.POSIXct(to), y = as.numeric(NDVI_index), 
               group=hakkuu, color=hakkuu)) +
    geom_point() +
    geom_smooth(method="lm") +
    xlab("Päivämäärä") + 
    ylab("NDVI-indeksi") + 
    ggtitle(title)
  
}

Chowvec <- chowDiscontinuityAlgorithm(newdf)

ggplot(data.frame(Chow_test = Chowvec, index = c(1:length(Chowvec))), aes(x = index, y = Chow_test)) + geom_point()

#timedf <- data.frame(to = as.POSIXct(seq.POSIXt(as.POSIXct("2020-11-27"), as.POSIXct("2022-08-10"), by = "1 week")),
#                     NDVI_index = (sin(0.15*(1:length(seq.POSIXt(as.POSIXct("2020-11-27"), as.POSIXct("2022-08-10"), by = "1 week"))))))

#Chowvec <- chowDiscontinuityAlgorithm(timedf)

#ggplot(data.frame(Chow_test = Chowvec, index = c(1:length(Chowvec))), aes(x = index, y = Chow_test)) + geom_point()
#ggplot(timedf, aes(y = NDVI_index, x = to)) + geom_point()

diff(Chowvec)
plot(diff(Chowvec))

