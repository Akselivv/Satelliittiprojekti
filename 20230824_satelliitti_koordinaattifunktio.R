calculateCoordinates <- function(dataName, minMaxHectares, minMaxYears, indices) {
  
  print(dataName)
  print(minMaxHectares)
  print(minMaxYears)
  print(indices)
  
  centroids_E_KA <- read.csv(paste("data", dataName, sep= "/"))
  
  centroids <- centroids_E_KA
  
  centroids$declarationarrivaldate
  
  centroids <- centroids[as.numeric(format(lubridate::ymd(centroids$declarationarrivaldate), "%Y")) >= minMaxYears[1] & 
                           as.numeric(format(lubridate::ymd(centroids$declarationarrivaldate), "%Y")) <= minMaxYears[2],]
  
  centroids$are %<>% as.numeric()
  
  centroids <- centroids[centroids$area > minMaxHectares[1] & 
                           centroids$area < minMaxHectares[2],]
  
#  for (i in 1:20) {
#    print(paste0(as.character(centroids$y[i]), ", ", as.character(centroids$x[i])))
#  }
  
  ## PARAMS ##
  
  i <- indices
  r_earth <- 6362.1 #Maapallon säde kilometreinä 60:llä leveysasteella merenpinnan korkeudella
  
  latitude <- as.numeric(centroids$y[i])
  longitude <- as.numeric(centroids$x[i])
  
  dy <- (sqrt(as.numeric(centroids$area[i]))*50)/1000
  dx <- dy
  
  new_latitude_NE  <- latitude  + (dy / r_earth) * (180 / pi);
  new_longitude_NE <- longitude + (dx / r_earth) * (180 / pi) / cos(latitude * pi/180);
  new_latitude_SW  <- latitude  - (dy / r_earth) * (180 / pi);
  new_longitude_SW <- longitude - (dx / r_earth) * (180 / pi) / cos(latitude * pi/180);
  
  print(as.character(centroids$y[i]))
  print(as.character(centroids$x[i]))
  
  print(paste0(as.character(centroids$y[i]), ", ", as.character(centroids$x[i])))
  print(paste0(as.character(new_latitude_NE), ", ", as.character(new_longitude_NE)))
  print(paste0(as.character(new_latitude_SW), ", ", as.character(new_longitude_SW)))
  print(paste0(as.character(new_latitude_NE*10000), ", ", as.character(new_longitude_NE*10000)))
  print(paste0(as.character(new_latitude_SW*10000), ", ", as.character(new_longitude_SW*10000)))
  
  coordInputList <- list(as.numeric(new_latitude_NE), as.numeric(new_longitude_NE),
                       as.numeric(new_latitude_SW), as.numeric(new_longitude_SW))
  
  arrivalDate <<- centroids$declarationarrivaldate[i]
  
  return(coordInputList)
  
}
