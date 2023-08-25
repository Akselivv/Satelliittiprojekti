##### DEFINE STATIC PARTS OF THE EVALSCRIPT #####

part1 <- '//VERSION=3\n
function setup() {\n
  return {\n
    input: [{\n
      bands: [\n'

part2 <- ']\n
}],\n
output: [\n
{\n
id: \"data\",\n
bands: 1\n
},\n
{\n
id: \"dataMask\",\n
bands: 1\n
}]\n
}\n
}\n
\n
function evaluatePixel(samples) {\n
\n'

part3 <- 'var noWaterMask = 1\n
if (samples.SCL == 6 ){\n
noWaterMask = 0\n
}\n
\n
var noCloudMask = 1\n
if (samples.CLM == 1) {\n
noCloudMask = 0\n
}\n
\n
return {\n
data: [measure],\n 
// Exclude nodata pixels, pixels where ndvi is not defined and water pixels from statistics:\n  
dataMask: [samples.dataMask * noWaterMask * noCloudMask]\n
}\n
}\n'

##### DEFINE MEASURES AND THEIR CORRESPONDING BANDS AND FORMULAS #####

bands_CHL_RE <- c("B05", "B08", "SCL", "CLM", "dataMask")
formula_CHL_RE <- "samples.B08 > 0 ? samples.B05 / samples.B08 : JAVA_DOUBLE_MAX_VAL"

bands_S2REP <- c("B04", "B05", "B06", "B07", "SCL", "CLM", "dataMask")
formula_S2REP <- "((samples.B06 - samples.B05) != 0) ? 705 + 35 * (0.5 * (samples.B07 + samples.B04) - samples.B05) / (samples.B06 - samples.B05) : JAVA_DOUBLE_MAX_VAL"

bands_MTCI <- c("B04", "B05", "B06", "SCL", "CLM", "dataMask")
formula_MTCI <- "((samples.B05 - samples.B04) != 0) ? (samples.B06 - samples.B05) / (samples.B05 - samples.B04) : JAVA_DOUBLE_MAX_VAL"

bands_PSRI <- c("B02", "B04", "B06", "SCL", "CLM", "dataMask")
formula_PSRI <- "(samples.B06 > 0) ? (samples.B04 - samples.B02) / samples.B06 : JAVA_DOUBLE_MAX_VAL"

bands_MCARI <- c("B03", "B04", "B05", "SCL", "CLM", "dataMask")
formula_MCARI <- "1 - (((samples.B05 - samples.B04) != 0) ? 0.2 * (samples.B05 - samples.B03) / (samples.B05 - samples.B04) : JAVA_DOUBLE_MAX_VAL)"

bands_GNDVI <- c("B03", "B08", "SCL", "CLM", "dataMask")
formula_GNDVI <- "index(samples.B08, samples.B03)"

bands_LAI_SAVI <- c("B04", "B08", "SCL", "CLM", "dataMask")
formula_LAI_SAVI <- "-Math.log(0.371 + 1.5 * (samples.B08 - samples.B04) / (samples.B08 + samples.B04 + 0.5)) / 2.4"

bands_NDVI_GREEN <- c("B03", "B04", "B08", "SCL", "CLM", "dataMask")
formula_NDVI_GREEN <- "samples.B03 * index(samples.B08, samples.B04)"

bands_MSAVI2 <- c("B04", "B08", "SCL", "CLM", "dataMask")
formula_MSAVI2 <- "(samples.B08 + 1.0) - 0.5 * Math.sqrt((2.0 * samples.B08 - 1.0) * (2.0 * samples.B08 - 1.0) + 8.0 * samples.B04)"

bands_CRI1 <- c("B02", "B03", "SCL", "CLM", "dataMask")
formula_CRI1 <- "inverse(samples.B02) - inverse(samples.B03)"

bands_CRI2 <- c("B02", "B05", "SCL", "CLM", "dataMask")
formula_CRI2 <- "inverse(samples.B02) - inverse(samples.B05)"

bands_GRVI1 <- c("B03", "B04", "SCL", "CLM", "dataMask")
formula_GRVI1 <- "index(samples.B04, samples.B03)"

bands_PSRI_NIR <- c("B02", "B04", "B08", "SCL", "CLM", "dataMask")
formula_PSRI_NIR <- "(samples.B08 > 0) ? (samples.B04 - samples.B02) / samples.B08 : JAVA_DOUBLE_MAX_VAL"

bands_IRECI <- c("B04", "B05", "B06", "B07", "SCL", "CLM", "dataMask")
formula_IRECI <- "(samples.B05 > 0) ? (samples.B07 - samples.B04) * samples.B06 / samples.B05 : JAVA_DOUBLE_MAX_VAL"

bands_PSSR <- c("B04", "B08", "SCL", "CLM", "dataMask")
formula_PSSR <- "(samples.B04 > 0) ? samples.B08 / samples.B04 : JAVA_DOUBLE_MAX_VAL"

bands_NDSI <- c("B03", "B11", "SCL", "CLM", "dataMask")
formula_NDSI <- "index(samples.B03, samples.B11)"

bands_NDI45 <- c("B04", "B05", "SCL", "CLM", "dataMask")
formula_NDI45 <- "index(samples.B05, samples.B04)"

bands_ARI1 <- c("B03", "B05", "SCL", "CLM", "dataMask")
formula_ARI1 <- "inverse(samples.B03) - inverse(samples.B05)"

bands_ARI2 <- c("B03", "B05", "B08", "SCL", "CLM", "dataMask")
formula_ARI2 <- "(samples.B03 > 0 ? samples.B08 / samples.B03 : JAVA_DOUBLE_MAX_VAL) - (samples.B05 > 0 ? samples.B08 / samples.B05 : JAVA_DOUBLE_MAX_VAL)"

bands_EVI <- c("B02", "B04", "B08", "SCL", "CLM", "dataMask")
formula_EVI <- "2.5 * (samples.B08 - samples.B04) / (samples.B08 + 6 * samples.B04 - 7.5 * samples.B02 + 1)"

bands_EVI2 <- c("B04", "B08", "SCL", "CLM", "dataMask")
formula_EVI2 <- "2.5 * (samples.B08 - samples.B04) / (samples.B08 + 2.4 * samples.B04 + 1)"

bands_NDVI <- c("B04", "B08", "SCL", "CLM", "dataMask")
formula_NDVI <- "index(samples.B08, samples.B04)"

names <- list("CHL_RE", "S2REP", "MTCI", "PSRI", "MCARI", "GNDVI", "LAI_SAVI", "NDVI_GREEN",
              "MSAVI2", "CRI1", "CRI2", "GRVI1", "PSRI_NIR", "IRECI", "PSSR", "NDSI", "NDI45",
              "ARI1", "ARI2", "EVI", "EVI2", "NDVI")

bands_list <- list(bands_CHL_RE, bands_S2REP, bands_MTCI, bands_PSRI,
                   bands_MCARI, bands_GNDVI, bands_LAI_SAVI, bands_NDVI_GREEN,
                   bands_MSAVI2, bands_CRI1, bands_CRI2, bands_GRVI1, bands_PSRI_NIR,
                   bands_IRECI, bands_PSSR, bands_NDSI, bands_NDI45,
                   bands_ARI1, bands_ARI2, bands_EVI, bands_EVI2,
                   bands_NDVI)

formula_list <- list(formula_CHL_RE, formula_S2REP, formula_MTCI, formula_PSRI,
                   formula_MCARI, formula_GNDVI, formula_LAI_SAVI, formula_NDVI_GREEN,
                   formula_MSAVI2, formula_CRI1, formula_CRI2, formula_GRVI1, formula_PSRI_NIR,
                   formula_IRECI, formula_PSSR, formula_NDSI, formula_NDI45,
                   formula_ARI1, formula_ARI2, formula_EVI, formula_EVI2,
                   formula_NDVI)

methods_list <- list(names, bands_list, formula_list)

createBands <- function(bandVector) {
  band <- ""
  for (i in 1:(length(bandVector)-1)) {
    band <- paste0(band,'\"', bandVector[i], '\",\n')
  }
  band <- paste0(band,'\"', bandVector[length(bandVector)], '\"\n')
  
  return(band)
}

createFormula <- function(formula) {
  paste0('let measure = ', formula, '\n')
}

method_index <- function(method) {
  
  switch(method,
         CHL_RE = "1",
         S2REP = "2",
         MTCI = "3",
         PSRI = "4",
         MCARI = "5",
         GNDVI = "6",
         LAI_SAVI = "7",
         NDVI_GREEN = "8",
         MSAVI2 = "9",
         CRI1 = "10",
         CRI2 = "11",
         GRVI1 = "12",
         PSRI_NIR = "13",
         IRECI = "14",
         PSSR = "15",
         NDSI = "16",
         NDI45 = "17",
         ARI1 = "18",
         ARI2 = "19",
         EVI = "20",
         EVI2 = "21",
         NDVI = "22")
  
}

build_evalscript <- function(method) {
  
  bands <- methods_list[[2]][[as.numeric(method_index(method))]]
  formula <- methods_list[[3]][[as.numeric(method_index(method))]]
  
  evalscript <- paste0(part1, createBands(bands), part2, createFormula(formula), part3)
  
  return(evalscript)
}
