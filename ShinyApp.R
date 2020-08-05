require(shiny)
require(tidyr)
require(dplyr)

#> Loading required package: shiny
library(tidyverse)
#> ── Attaching packages ────────────────────────────────────────────────────────── tidyverse 1.2.1 ──
#> ✔ ggplot2 2.2.1.9000     ✔ purrr   0.2.4     
#> ✔ tibble  1.4.1          ✔ dplyr   0.7.4     
#> ✔ tidyr   0.7.2          ✔ stringr 1.2.0     
#> ✔ readr   1.1.1          ✔ forcats 0.2.0
#> ── Conflicts ───────────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
library(rdrop2)
#Define output directory
outputDir <-
  "output"
#Define all variables to be collected
fieldsAll <- c("Restaurant", "Pho", "Steam_Smallcut", "Steam_Bigcut", "Steam_Nocut","Pancit",
               "EggNoodle_Smallcut", "EggNoodle_Bigcut")
#Define all mandatory variables
fieldsMandatory <- c("Restaurant")
#Label mandatory fields
labelMandatory <- function(label) {
  tagList(label,
          span("*", class = "mandatory_star"))
}
#Get current Epoch time
epochTime <- function() {
  return(as.integer(Sys.time()))
}
#Get a formatted string of the timestamp
humanTime <- function() {
  format(Sys.time(), "%Y%m%d-%H%M%OS")
}
#CSS to use in the app
appCSS <-
  ".mandatory_star { color: red; }
.shiny-input-container { margin-top: 25px; }
#thankyou_msg { margin-left: 15px; }
#error { color: red; }
body { background: #fcfcfc; }
#header { background: #fff; border-bottom: 1px solid #ddd; margin: -20px -15px 0; padding: 15px 15px 10px; }
"
#UI
ui <- shinyUI(
  fluidPage(
    shinyjs::useShinyjs(),
    shinyjs::inlineCSS(appCSS),
    
    headerPanel(
      'Purchase order'
    ),
    
    sidebarPanel(
      id = "form",
      textInput("Restaurant", labelMandatory("Restaurant"), value = ""),
      textInput("Pho", labelMandatory("Pho"), value = "0"),
      textInput("Steam_Smallcut", labelMandatory("Steam(Small cut)"), value = "0"),
      textInput("Steam_Bigcut", labelMandatory("Steam(Big cut)"), value = "0"),
      textInput("Steam_Nocut", labelMandatory("Steam(No cut)"), value = "0"),
      textInput("Pancit", labelMandatory("Pancit"), value = "0"),
      textInput("EggNoodle_Smallcut", labelMandatory("EggNoodle(Small cut)"), value = "0"),
      textInput("EggNoodle_Bigcut", labelMandatory("EggNoodle(Big cut)"), value = "0"),
    ),
    mainPanel(
      br(),
      p(
        "After you are happy with your guesses, press submit to send data to the database."
      ),
      br(),
      tableOutput("table"),
      br(),
      actionButton("Submit", "Submit"),
      
      fluidRow(shinyjs::hidden(div(
        id = "thankyou_msg",
        h3("Thanks, your response was submitted successfully!")
      )))
    )
  )
)
#Server
server <- shinyServer(function(input, output, session) {
  # Gather all the form inputs
  formData <- reactive({
    x <- reactiveValuesToList(input)
    data.frame(names = names(x),
               values = unlist(x, use.names = FALSE))
  })
  
  #Save the results to a file
  saveData <- function(data) {
    # Create a unique file name
    fileName <-"test.csv"
    # Write the data to a temporary file locally
    filePath <- file.path('/Users/hdeng/Desktop/Random/ShinyApp/Order', fileName)
    write.csv(data, filePath, row.names = TRUE, quote = TRUE)
    # Upload the file to Dropbox
    #drop_upload(filePath, path = outputDir)
  }
  
  # When the Submit button is clicked, submit the response
  observeEvent(input$Submit, {
    # User-experience stuff
    shinyjs::disable("Submit")
    shinyjs::show("thankyou_msg")
    
    tryCatch({
      #saveData(formData())
      shinyjs::reset("form")
      shinyjs::hide("form")
      shinyjs::show("thankyou_msg")
    })
    #write.csv(create_table(),'submitted.csv')
    saveData(create_table())
  }, ignoreInit = TRUE, once = TRUE, ignoreNULL = T)
  
  #Observe for when all mandatory fields are completed
  observe({
    fields_filled <-
      fieldsMandatory %>%
      sapply(function(x)
        ! is.na(input[[x]]) && input[[x]] != "") %>%
      all
    
    shinyjs::toggleState("Submit", fields_filled)
    
  })
  
  # isolate data input
  values <- reactiveValues()
  
  create_table <- reactive({
    input$addButton
    
    Restaurant <- input$Restaurant
    Pho <- input$Pho
    Steam_Smallcut <- input$Steam_Smallcut
    Steam_Bigcut <- input$Steam_Bigcut
    Steam_Nocut <- input$Steam_Nocut
    Pancit <- input$Pancit
    EggNoodle_Smallcut <- input$EggNoodle_Smallcut
    EggNoodle_Bigcut <- input$EggNoodle_Bigcut
    df <-tibble(Restaurant, Pho, Steam_Smallcut, Steam_Bigcut, Steam_Nocut,Pancit,
                    EggNoodle_Smallcut, EggNoodle_Bigcut)
    
    df
  })
  
  output$table <- renderTable(create_table())
  
})

# Run the application
shinyApp(ui = ui, server = server)