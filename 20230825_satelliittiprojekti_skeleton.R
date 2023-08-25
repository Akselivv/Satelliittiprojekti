# To run the program, only the 'method' part of the code should be changed.
# Methods that seem to respond well to logging activity are PSRI, GNDVI, CRI1, NDVI, and GRVI1
# Methods that respond slightly less well - but nevertheless could be useful - are
# CHL_RE, S2REP, MCARI, NDVI_GREEN, CRI2, PSRI_NIR, IRECI, PSSR, and NDSI
# All methods are ranked on a scale from * to *** (with ' corresponding to half a point)
# On a text file in the project directory.

# Good location indices to test include 211, 391, 631, 681

##### SKELETON SCRIPT #####

setwd(".~/GitHub/Satelliittiprojekti")

library(rjson)
library(tidyverse)
library(magrittr)
library(ggplot2)
library(strucchange)

source("20230824_ChowDiscontinuityAlgorithm.R")

  ## GIVE PARAMETERS ##
  # The list of allowed methods is given below
  # list("CHL_RE", "S2REP", "MTCI", "PSRI", "MCARI", "GNDVI", "LAI_SAVI", "NDVI_GREEN",
          #"MSAVI2", "CRI1", "CRI2, "GRVI1", "PSR_NIR", "IRECI", "PSSR", "NDSI", "NDI45",
          #"ARI1", "ARI2", "EVI", "EVI2", "NDVI")

    method <- "CRI1"
    min_to_max_years <- c(2019, 2023)
    min_to_max_hectares <- c(5, 100)
    index <- 681

    # CALCULATE COORDINATES#

    source("20230824_satelliitti_koordinaattifunktio.R")
    coordInputList <- calculateCoordinates("MKI_Etelä-Karjala_centroids.csv",
                                           min_to_max_hectares, min_to_max_years, index)
  
    # BUILD EVALSCRIPT #
    
    source("20230824_evalscriptBuilder.R")
    evalscript <- build_evalscript(method)
      
  ## SOURCE PYTHON CODE WITH EVALSCRIPT AS INPUT ##
    
  cacheEnv <- new.env()
  options("reticulate.engine.environment" = cacheEnv)
  
  assign("evalScriptFromR", evalscript, envir = cacheEnv)
  assign("coordInputList", coordInputList, envir = cacheEnv)

  reticulate::source_python("20230822_satelliitti_APIcall.py", envir = cacheEnv)
  ## CLEAN DATA ##

  data <- reticulate::py$sh_statistics[1]
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
  
  ## ANALYSIS AND VISUALISATION ##
  
  #getwd()
  #filename <- "data44.json"
  hakkuuaika <- as.POSIXct("2019-06-15")
  rajaaVuoteen <- FALSE
  jatkuvuusanalyysi <- TRUE
  pivot <- FALSE
  
  if (rajaaVuoteen) {
    title <- paste0("Hakkuun vaikutus ", method, "-indeksiin: rajaus, vuosi")
  } else {
    title <- paste0("Hakkuun vaikutus ", method, "-indeksiin")
  }
  
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
  
  newdf$NDVI_index %<>% as.numeric()
  newdf$NDVI_index[is.infinite(newdf$NDVI_index)] <- NA
  newdf$NDVI_index[is.nan(newdf$NDVI_index)] <- NA
  newdf$NDVI_index %<>% as.numeric()
  newdf %<>% na.omit()
  
  newdf$hakkuu <- numeric(nrow(newdf))
  
  # Winsorize data
  for (i in 1:nrow(newdf)) {
    if (newdf$NDVI_index[i] > 10*mean(newdf$NDVI_index[-i], na.rm = TRUE)) {
      newdf$NDVI_index[i] <- NA
    } 
  }
  
  newdf %<>% na.omit()
  
  if (!jatkuvuusanalyysi) {
    
    ggplot(newdf, aes(x = as.POSIXct(to), y = as.numeric(NDVI_index), col = hakkuu)) + geom_point()
    
  } else if (jatkuvuusanalyysi) {
    
    newdf %>%
      ungroup %>%
      mutate(hakkuu = ifelse(newdf$to > as.POSIXct(lubridate::ymd(gsub("/" ,"-", arrivalDate))), "hakkuuilmoitus", "ei hakkuuilmoitusta")) %>% 
      ggplot(aes(x = as.POSIXct(to), y = as.numeric(NDVI_index), 
                 group=hakkuu, color=hakkuu)) +
      geom_point() +
      geom_smooth(method="lm") +
      xlab("Päivämäärä") + 
      ylab(paste(method, "indeksi", sep = "-")) + 
      ggtitle(title) + 
      theme(legend.position="bottom")
    
  }
  
  Chowvec <- chowDiscontinuityAlgorithm(newdf)
  
  ggplot(data.frame(Chow_test = Chowvec, index = c(1:length(Chowvec))), aes(x = index, y = Chow_test)) + geom_point() + 
    stat_smooth()
  
  ggplot(data.frame(Chow_diff = diff(Chowvec), index = c(1:length(diff(Chowvec)))), aes(x = index, y = Chow_diff)) + geom_point() + 
    stat_smooth()
  
  #timedf <- data.frame(to = as.POSIXct(seq.POSIXt(as.POSIXct("2020-11-27"), as.POSIXct("2022-08-10"), by = "1 week")),
  #                     NDVI_index = (sin(0.15*(1:length(seq.POSIXt(as.POSIXct("2020-11-27"), as.POSIXct("2022-08-10"), by = "1 week"))))))
  
  #Chowvec <- chowDiscontinuityAlgorithm(timedf)
  
  #ggplot(data.frame(Chow_test = Chowvec, index = c(1:length(Chowvec))), aes(x = index, y = Chow_test)) + geom_point()
  #ggplot(timedf, aes(y = NDVI_index, x = to)) + geom_point()
  
  Chowdf <- data.frame(Chow_diff = diff(Chowvec), index = c(1:length(diff(Chowvec))))
  
  Chowdf$Chow_diff
  plot(Chowdf$Chow_diff)
  loess <- loess(Chow_diff ~ index, data = Chowdf)
  plot(loess$fitted - Chowdf$Chow_diff)
  
  fs.ndvi <- Fstats(newdf$NDVI_index ~ 1)
  plot(fs.ndvi)
  bp.ndvi <- breakpoints(newdf$NDVI_index ~ 1)
  
  fs.ndvi$Fstats
  
  fm0 <- lm(newdf$NDVI_index ~ 1)
  fm1 <- lm(newdf$NDVI_index ~ breakfactor(bp.ndvi, breaks = 1))
  plot(newdf$NDVI_index)
  lines(ts(fitted(fm0), start = 1), col = 3)
  lines(ts(fitted(fm1), start = 1), col = 4)
  lines(bp.ndvi)
  abline(y= 60)
  
  print(google_coordinates1)
  print(google_coordinates2)
  
