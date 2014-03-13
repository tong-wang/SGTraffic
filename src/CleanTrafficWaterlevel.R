require("RCurl")
require("RJSONIO")
require("plyr")

setwd("~/Dropbox/RCode/SGTraffic/src/") #("~/traffic/")

svy2wgs <- function(x) {
    if (x$XCoor==0 || x$YCoor==0) {
        x$lon <- NA
        x$lat <- NA
    } else {
        url2 <- paste("http://www.onemap.sg/arcgis/rest/services/Utilities/Geometry/GeometryServer/project?f=json&outSR=4326&inSR=3414&geometries=%7B%22geometryType%22%3A%22esriGeometryPoint%22%2C%22geometries%22%3A%5B%7B%22x%22%3A%22", x$XCoor, "%22%2C%22y%22%3A%22%20", x$YCoor, "%22%2C%22spatialReference%22%3A%7B%22wkid%22%3A%223414%22%7D%7D%5D%7D", sep="")
        json2 <- getURL(url2)
        x$lon <- fromJSON(json2)$geometries[[1]]["x"]
        x$lat <- fromJSON(json2)$geometries[[1]]["y"]
    }

    return(x)
}

# clean raw traffic data files
rawFiles <- dir(path="../data/raw/", pattern="Traffic.*\\.csv")

for (rawFile in rawFiles) {
    print(paste("Processing", rawFile, "..."))

    rawFile <- strsplit(rawFile, ".csv")[[1]][1]
    cleanedFile <- paste("../data/cleaned/", rawFile, "-cleaned.csv", sep="")
    
    if (!file.exists(cleanedFile )) {
    
        traffic.df <- read.csv(file=paste("../data/raw/", rawFile, ".csv", sep=""), header=FALSE)
        names(traffic.df) <- c("ID", "XCoor", "YCoor", "Type", "Message", "Time")
        traffic.df <- traffic.df[!duplicated(traffic.df[c("XCoor", "YCoor", "Type", "Time")]), ]
        traffic.df <- ddply(.data=traffic.df, .(XCoor, YCoor), .fun=svy2wgs)
    
        traffic.df <- traffic.df[order(traffic.df$Type, traffic.df$Time),]
        traffic.df$Datetime <- strptime(traffic.df$Time, format="%d %B %Y @ %H:%Mhrs")
        traffic.df$Time <- NULL
        traffic.df$ID <- NULL
    
        write.csv(traffic.df, file=cleanedFile, row.names = FALSE)
        print(paste("Saved to", cleanedFile, "."))
    }
    else
        print(paste(cleanedFile, "already exists."))
}



# clean raw waterlevel data files
rawFilesWL <- dir(path="../data/raw/", pattern="WaterLevel.*\\.csv")

for (rawFileWL in rawFilesWL) {
    print(paste("Processing", rawFileWL, "..."))
    
    rawFileWL <- strsplit(rawFileWL, ".csv")[[1]][1]
    cleanedFileWL <- paste("../data/cleaned/", rawFileWL, "-cleaned.csv", sep="")
    
    if (!file.exists(cleanedFileWL)) {
        
        wl.df <- read.csv(file=paste("../data/raw/", rawFileWL, ".csv", sep=""), header=FALSE)
        names(wl.df) <- c("ID", "SensorID", "WaterLevel", "SensorFlag", "Time")
        wl.df <- wl.df[!duplicated(wl.df[c("SensorID", "WaterLevel", "SensorFlag", "Time")]), ]
        
        wl.df$Datetime <- strptime(wl.df$Time, format="%B %d %Y  %I:%M%p")
        wl.df$Time <- NULL
        wl.df$ID <- NULL
        
        write.csv(wl.df, file=cleanedFileWL, row.names = FALSE)
        print(paste("Saved to", cleanedFileWL, "."))
    }
    else
        print(paste(cleanedFileWL, "already exists."))
}
