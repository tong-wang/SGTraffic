require("plyr")

setwd("~/Dropbox/RCode/SGTraffic/src") #("~/traffic/")

### read all cleaned traffic data files and merge into a data.frame
files <- dir(path="../data/cleaned/", pattern="Traffic.*\\.csv")
files <- paste("../data/cleaned/", files, sep="")

traffic.df <- ldply(files, read.csv, header=TRUE)
traffic.df$Type <- as.factor(traffic.df$Type)

traffic.df <- traffic.df[!duplicated(traffic.df[c("XCoor", "YCoor", "Type", "Datetime")]), ]
traffic.df <- na.omit(traffic.df)
summary(traffic.df)

save(traffic.df, file="../data/traffic.RData")




### NEED TO FURTHER REFINE DATA TO REMOVE DUPLICATED RECORDS WITH SAME COORDINATES AND SIMILAR BUT DIFFERENT REPORT TIME ###
#accident.df[duplicated(accident.df[c("XCoor", "YCoor")]), ]

# strsplit location string
accLoc <- function (m) {
    m2 <- strsplit(as.character(m), "Accident on ")[[1]][2]
    if (is.na(m2)) m2 <- strsplit(as.character(m), "Accident in ")[[1]][2]
    m2 <- strsplit(as.character(m2), " \\(")[[1]][1]
    m2 <- strsplit(as.character(m2), " near ")[[1]][1]
    return (m2)
}

accident.df$Location <- as.factor(sapply(accident.df$Message, accLoc))





### only look at accidents
accident.df <- traffic.df[traffic.df$Type==0,]

summary(accident.df)
save(accident.df, file="../data/accident.RData")


### plot accidents on map

require(googleVis)
#op <- options(gvis.plot.tag = "chart")  # googleVis option for knitr
accident.df$loc <- paste(accident.df$lat, accident.df$lon, sep=":")    # re-organize coordinates for gvis
G1 <- gvisGeoChart(data=accident.df, locationvar="loc", hovervar="Message",
                   options=list(region="SG", displayMode="Markers", 
                                markerOpacity=0.3, backgroundColor="lightblue"), 
                   chartid="Accident")
plot(G1)

