
require("plyr")
require("ggplot2")
load(file="traffic.RData")

# count accidents by date
traffic.df$Date <- as.Date(traffic.df$Datetime)

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
        traffic.df[(traffic.df$Date >= input$inDates[1]) & (traffic.df$Date <= input$inDates[2]) & (traffic.df$Type %in% input$inTypes), ]
    })
    
    countByDate <- reactive({
        ddply(data.selected(), .(Date), function(x) {data.frame(count=nrow(x))})
    })
    
    
    # Set the value for the gauge
    # When this reactive expression is assigned to an output object, it is
    # automatically wrapped into an observer (i.e., a reactive endpoint)
    output$live_gauge <- renderGauge({
        round(100*nrow(data.selected())/nrow(traffic.df), 1)
    })
  
    # Output the status text ("OK" vs "Past limit")
    # When this reactive expression is assigned to an output object, it is
    # automatically wrapped into an observer (i.e., a reactive endpoint)
    output$mapData <- renderPrint({
        data.selected()[,c("lon", "lat")]
    })
  
    # observes if value of mydata sent from the client changes.  if yes
    # generate a new random color string and send it back to the client
    # handler function called 'myCallbackHandler'
    
    #lon.str <- "lon" ## for leaflet
    lon.str <- "lng"  ## for google
    
    observe({
        input$inTypes
     
        out <- data.selected()[,c("lon", "lat")]
        out$lon <- as.numeric(out$lon)
        out$lat <- as.numeric(out$lat)
     
        json <- paste0("{\"max\": 5, \"data\": [{\"", lon.str, "\": ", out[1,]$lon, ", \"lat\": ", out[1,]$lat, ", \"count\": 1}")
         
        for (i in 2:nrow(out)) {
            str <- paste0("{\"", lon.str, "\": ", out[i,]$lon, ", \"lat\": ", out[i,]$lat, ", \"count\": 1}")
            json = paste(json, str, sep=", ")
        }
        
        json = paste(json, "]}")
         
         session$sendCustomMessage(type = "myCallbackHandler", json)
    })
  

#    output$piePlot <- renderPlot(height=250, {
#        pie <- ggplot(data=countByDate(), aes(x=Date, y=count)) + geom_bar(stat="identity", fill="red") + scale_x_date() + xlab("Date") + ylab("Number of incidents")
#        print(pie)
#    })  

    output$countPlot <- renderPlot(height=250, {
        gg <- ggplot(data=countByDate(), aes(x=Date, y=count)) + geom_bar(stat="identity", fill="red") + scale_x_date() + xlab("Date") + ylab("Number of incidents")
        print(gg)
    })  
  
  
})

