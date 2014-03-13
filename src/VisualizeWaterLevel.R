require("plyr")

Sys.setenv(LANG = "en") # set language
setwd("~/Dropbox/RCode/Traffic") #("~/traffic/")


# clean raw waterlevel data files
filesWL <- dir(path="data/cleaned/", pattern="WaterLevel.*\\.csv")
filesWL <- paste("data/cleaned/", filesWL, sep="")


WL <- ldply(filesWL, read.csv, header=TRUE)

EWS009 <- WL[WL$SensorID=='EWS009',]
plot(EWS009$Datetime, EWS009$WaterLevel, type="l")
