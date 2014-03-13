require("plyr")
require("stringr")

setwd("~/Dropbox/RCode/SGTraffic/src") #("~/traffic/")

### read all cleaned traffic data files and merge into a data.frame
files <- dir(path="../data/cleaned/", pattern="Traffic.*\\.csv")
files <- paste("../data/cleaned/", files, sep="")

traffic.df <- ldply(files, read.csv, header=TRUE)
traffic.df$Type <- as.factor(traffic.df$Type)

traffic.df <- traffic.df[!duplicated(traffic.df[c("XCoor", "YCoor", "Type", "Datetime")]), ]
traffic.df <- na.omit(traffic.df)


# strsplit location string
accLoc <- function (m) {
    m2 <- strsplit(as.character(m), " on ")[[1]][2]
    if (is.na(m2)) m2 <- strsplit(as.character(m), " in ")[[1]][2]
    if (is.na(m2)) m2 <- strsplit(as.character(m), " at ")[[1]][2]
    m2 <- strsplit(as.character(m2), "\\. ")[[1]][1]
    m2 <- strsplit(as.character(m2), " \\(")[[1]][1]
    m2 <- strsplit(as.character(m2), " between")[[1]][1]
    m2 <- strsplit(as.character(m2), " near ")[[1]][1]
    return (m2)
}


# returns string w/o leading or trailing whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

splitMessage <- function (row) {
    #obtain message and split by "on" or "in" or "at"
    m <- strsplit(as.character(row$Message), " on | in | at ")

    #save first component as TypeDesc
    row$TypeDesc <- trim(m[[1]][1])
    
    #further split the second compoenent by ". " or " after " or " before " or " between " or " near ", just keep the first output
    m3 <- strsplit(trim(m[[1]][2]), "\\. | after | before | between | near ")[[1]][1]

    #seach for "(" and ")" and save their positions
    startpos <- str_locate_all(pattern ='\\(', m3)[[1]][1]
    endpos <- str_locate_all(pattern ='\\)', m3)[[1]][1]
    
    if (is.na(startpos)) {
        #if there is no "()", save roadname directly
        row$RoadName <- m3
        row$RoadDirection <- NA
    } else {
        #if there is "()", split into roadname and roaddirection
        row$RoadName <- substr(m3, 1, startpos-2)
        row$RoadDirection <- substr(m3, startpos+1, endpos-1)
    }

    return (row)
}


traffic.df <- ddply(traffic.df, names(traffic.df), splitMessage)
traffic.df$TypeDesc <- as.factor(traffic.df$TypeDesc)
traffic.df$RoadName <- as.factor(traffic.df$RoadName)

head(traffic.df)
summary(traffic.df)
table(traffic.df$RoadDirection)


save(traffic.df, file="../data/traffic.RData")





### only look at accidents
accident.df <- traffic.df[traffic.df$Type==0,]

### NEED TO FURTHER REFINE DATA TO REMOVE DUPLICATED RECORDS WITH SAME COORDINATES AND SIMILAR BUT DIFFERENT REPORT TIME ###
#accident.df[duplicated(accident.df[c("XCoor", "YCoor")]), ]


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

