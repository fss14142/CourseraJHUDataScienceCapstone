library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.css")
  ),
  
  # Application title
  titlePanel("Coursera JHU Data Science Specialization"),
  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    
    sidebarPanel(
      
      
      h5("Capstone Project Data Product"),
      h5("Submitted by fss14142"),
      br(),
      h3("Please enter an incomplete sentence to see the prediction for the next word"),
      textInput(inputId = "userSentence", 
                label = "", 
                value = "" # 
      ),
      
      checkboxInput("profFilter", label = "Profanity filter On (use at your own discretion)", value = TRUE),
      
      sliderInput("numPredicted", "Number of words to predict (max. 20):", 
                  min=1, max=20, value=4)
      
      
#       sliderInput("bins",
#                   "Number of bins:",
#                   min = 1,
#                   max = 50,
#                   value = 30)
    ), #SidebarPanel ends
    
    mainPanel(
      tabsetPanel(
        tabPanel(
          "Prediction",
          h4("The predicted word (with highest probability) is:"),
          HTML("<span style='color:red'>"),
          h3(textOutput("predictedWordMain"), align="center"),
          HTML("</span>"),
          br(),
          h4(textOutput("kText")),
          hr(),
          div(dataTableOutput("predictionTable"), style='font-size:150%')        
          ),
        tabPanel("App documentation",
          includeMarkdown("documentation.Rmd")
          )
    )
  ) #mainPanel ends
)
))