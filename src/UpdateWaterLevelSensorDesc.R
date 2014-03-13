require("RCurl")
require("RJSONIO")
require("plyr")



Sys.setenv(LANG = "en") # set language
setwd("~/Dropbox/RCode/SGTraffic/src") #("~/traffic/")




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



#read in old desc
wl.old <- read.csv("data/WaterLevelSensorDesc.csv", header=TRUE)


#load new desc from web
waterlevel.url <- "http://app.pub.gov.sg/WaterLevel/GetWLInfo.aspx?type=WL"


wl.txt <- tryCatch(
{
    getURL(waterlevel.url)
},
error = function(e) {
    message(format(Sys.time(), "%Y-%m-%d %X"), " --- [HTTP Error]: ", e$message)
    Sys.sleep(30)
    return(NA)
}
)


wl.list <- strsplit(wl.txt, split="\\$@\\$")
wl.list2 <- lapply(wl.list, strsplit, split="\\$#\\$")
wl.df <- ldply(wl.list2[[1]], .fun=c)
wl.df$V5 <- NULL
wl.df$V6 <- NULL
wl.df$V7 <- NULL
names(wl.df) <- c("SensorID", "SensorDesc", "XCoor", "YCoor")

wl.df <- ddply(.data=wl.df, .(XCoor, YCoor), .fun=svy2wgs)


# merge new and old
#wl.merged <- merge(wl.old, wl.df, by=c("SensorID", "SensorDesc"), all=TRUE)

write.csv(wl.df, file="data/WaterLevelSensorDesc.csv")
