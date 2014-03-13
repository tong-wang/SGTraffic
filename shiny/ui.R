library(shiny)
library(ShinyDash)

shinyUI(bootstrapPage(
    
    h1("Traffic Dashboard"),
  
  
    gridster(tile.width = 240, tile.height = 240,
             
        gridsterItem(col = 1, row = 1, size.x = 1, size.y = 1,
            #display dynamic UI
            uiOutput("outTypes"),

            uiOutput("outDates")
                
        ),
        gridsterItem(col = 1, row = 2, size.x = 1, size.y = 1,
            gaugeOutput("live_gauge", width=250, height=200, units="%", min=0, max=100, title="Percentage")
            #plotOutput("piePlot")
        ),
        gridsterItem(col = 2, row = 1, size.x = 3, size.y = 2,
            htmlWidgetOutput('mapPanel', 
                                tags$iframe(name="mapFrame", id="mapFrame", height=480, width=720, src="heatmap_google.htm"),
                                #verbatimTextOutput("mapData"),
                                # handler to receive data from server
                                tags$script("Shiny.addCustomMessageHandler('myCallbackHandler',
                                    function(mapData) {
                                        var hInput = $('#mapFrame').contents().find('body').find('#hiddenInputBox')[0];
                                        hInput.value = mapData;
                                        hInput.onchange();
                                    });"
                                )
                                  
            )
        ),
        gridsterItem(col = 2, row = 2, size.x = 4, size.y = 1,
            plotOutput("countPlot")
        )
    )
    
))