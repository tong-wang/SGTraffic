
require("plyr")
require("ggplot2")
load(file="traffic.RData")

# count accidents by date
traffic.df$Date <- as.Date(traffic.df$Datetime)

traffic.df$XCoor <- NULL
traffic.df$YCoor <- NULL

date.min <- min(traffic.df$Date)
date.max <- max(traffic.df$Date)



library(shiny)
library(ShinyDash)



shinyServer(function(input, output, session) {
    
    
    #make dynamic radio
    output$outTypes <- renderUI({
        radioButtons("inTypes", "Event type:",
                                list("Accident" = "0",
                                    "Roadworks" = "1",
                                    "Vehicle breakdown" = "3",
                                    "Obstacle" = "5",
                                    "Heavy Traffic" = "8",
                                    "Stationary Vehicle" = "14"                      
                                ))
    })
    
    #make dynamic dates selector
    output$outDates <- renderUI({
        dateRangeInput("inDates", "Date range", start=date.min, end=date.max, min=date.min, max=date.max)
    })

  
    
    data.selected <- reactive({
        traffic.df[(traffic.df$Date >= input$inDates[1]) & (traffic.df$Date <= input$inDates[2]) & (traffic.df$Type == input$inTypes), ]
    })
    
    countByDate <- reactive({
        ddply(data.selected(), .(Date), function(x) {data.frame(count=nrow(x))})
    })
    
    countByRoad <- reactive({
        byRoad <- ddply(data.selected(), .(RoadName), function(x) {data.frame(count=nrow(x))})
    
        byRoad.short <- byRoad[order(byRoad$count, decreasing=TRUE),][1:6,]
        countOthers <- sum(byRoad$count) - sum(byRoad.short$count)
        rbind(byRoad.short, data.frame(RoadName="Others", count=countOthers))
    })
    
  
    
    #lon.str <- "lon" ## for leaflet
    lon.str <- "lng"  ## for google
    
    observe({
        #input$inTypes
     
        out <- data.selected()[,c("lon", "lat")]
        out$lon <- as.numeric(out$lon)
        out$lat <- as.numeric(out$lat)
     
        str <- apply(out, 1, function(x) paste0("{\"", lon.str, "\": ", x[1], ", \"lat\": ", x[2], ", \"count\": 1}"))
        str <- paste0(str, collapse=",")
        json <- paste0("{\"max\": 2, \"data\": [", str, "]}")
         
        session$sendCustomMessage(type = "myCallbackHandler", json)
    })
  

    output$piePlot <- renderPlot(height=240, {
        pie <- ggplot(data=countByRoad(), aes(x=factor(1), y=count, fill = RoadName)) + 
                geom_bar(width = 1, stat="identity") + coord_polar(theta="y") + 
                xlab('') + ylab('') + 
                geom_text(aes(x=1.3, y = count/2 + c(0, cumsum(count)[-length(count)]), label = RoadName), size=3) + 
                guides(fill=FALSE) + theme(axis.ticks.y=element_blank(), axis.text.y=element_blank())
        print(pie)
    })  

    output$countPlot <- renderPlot(height=240, {
        bar <- ggplot(data=countByDate(), aes(x=Date, y=count)) + geom_bar(stat="identity", fill="red") + scale_x_date() + xlab("Date") + ylab("Number of incidents")
        print(bar)
    })  
  
  
})



