chowDiscontinuityAlgorithm <- function(data) {
  
  valuevec <- c()
  
  for (i in 3:(nrow(data)-3)) {
    testresult <- (strucchange::sctest(as.numeric(as.POSIXct(data$to)) ~ as.numeric(data$NDVI_index), type = "Chow", point = i))
    valuevec <- c(valuevec, testresult$statistic)
  }
  
  valuevec %<>% unname()
  
}