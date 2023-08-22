library(rjson)
library(tidyverse)
library(magrittr)
library(ggplot2)

getwd()
filename <- "data10.json"
hakkuuaika <- as.POSIXct("2019-06-15")
rajaaVuoteen <- TRUE
jatkuvuusanalyysi <- TRUE

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


if (rajaaVuoteen) {
  
  newdf <- newdf %>%
    filter(to > as.POSIXct(paste(as.character(format(hakkuuaika, format = "%Y")), "01", "01", sep = "-"))) %>%
    filter(to < as.POSIXct(paste(as.character(format(hakkuuaika, format = "%Y")), "12", "31", sep = "-")))
  
} 

newdf <- newdf %>%
  pivot_longer(!to, names_to = "critical_value", values_to = "NDVI_index")

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
    geom_smooth(method="lm") 
  
}