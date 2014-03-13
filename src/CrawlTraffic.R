require("RCurl")
require("RJSONIO")
require("plyr")

setwd("~/Dropbox/RCode/SGTraffic/src/") #("~/traffic/")


traffic.url <- "http://www.onemap.sg/TrafficQuery/Service1.svc/SERVICEINFO?&incidents=II"


while (1) {
    
    json <- tryCatch(
        {
            getURL(traffic.url)
        },
        error = function(e) {
            message(format(Sys.time(), "%Y-%m-%d %X"), " --- [HTTP Error]: ", e$message)
            Sys.sleep(30)
            return(NA)
        }
    )
        
    if (!is.na(json)) {
        json.filename <- paste("Traffic-", format(Sys.time(), format="%Y-%m-%d"), ".json", sep="")
        write(c(format(Sys.time(), format="%Y-%m-%d-%H-%M"), json), file=json.filename, append=TRUE)
        
        traffic.list <- fromJSON(json)
        if (("SERVICESINFO" %in% names(traffic.list)) && ("INCIDENTSINFO" %in% names(traffic.list$SERVICESINFO[[1]]))) {
            traffic.list2 <- traffic.list$SERVICESINFO[[1]]$INCIDENTSINFO[-1]
            traffic.df <- data.frame(t(sapply(traffic.list2, c)))
            
            traffic.filename <- paste("Traffic-", format(Sys.time(), format="%Y-%m-%d"), ".csv", sep="")
            write.table(traffic.df, file=traffic.filename, sep=",", col.names=FALSE, append=TRUE)
            
            message(format(Sys.time(), "%Y-%m-%d %X"), " --- [Message]: Traffic data [", nrow(traffic.df), "] saved.")
            Sys.sleep(1800)
        } else {
            message(format(Sys.time(), "%Y-%m-%d %X"), " --- [Data Error]: Wrong data feed: ", json)            
            Sys.sleep(15)
        }
        
    }
    
    
}
