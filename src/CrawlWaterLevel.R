require("RCurl")
require("plyr")

setwd("~/Dropbox/RCode/SGTraffic/src/") #("~/traffic/")

waterlevel.url <- "http://app.pub.gov.sg/WaterLevel/GetWLInfo.aspx?type=WL"



while (1) {
        
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
    
    if (!is.na(wl.txt)) {
        txt.filename <- paste("WaterLevel-", format(Sys.time(), format="%Y-%m-%d"), ".txt", sep="")
        write(wl.txt, file=txt.filename, append=TRUE)

        wl.list <- strsplit(wl.txt, split="\\$@\\$")
        wl.list2 <- lapply(wl.list, strsplit, split="\\$#\\$")
        wl.df <- ldply(wl.list2[[1]], .fun=c)
        wl.df$V2 <- NULL
        wl.df$V3 <- NULL
        wl.df$V4 <- NULL
    
        if (ncol(wl.df)==4) {
            df.filename <- paste("WaterLevel-", format(Sys.time(), format="%Y-%m-%d"), ".csv", sep="")
            write.table(wl.df, file=df.filename, sep=",", col.names=FALSE, append=TRUE)

            message(format(Sys.time(), "%Y-%m-%d %X"), " --- [Message]: Water Level data [", nrow(wl.df), "] saved.")
            Sys.sleep(600)
        } else {
            message(format(Sys.time(), "%Y-%m-%d %X"), " --- [Data Error]: Wrong data feed: (", nrow(wl.df), ", ", ncol(wl.df), ") ", wl.txt)            
            Sys.sleep(15)
        }
        
    }
}

