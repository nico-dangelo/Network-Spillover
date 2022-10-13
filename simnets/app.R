

library(shiny)
source("sim_shiny.R")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Network Simulation Models"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("N",
                        "Network size:",
                        min = 20,
                        max = 100,
                        value  = 20),
        
            sliderInput("phiv",
                      "HIV prevalence",min=0.1,
                      max=1,
                      value=0.1),
            sliderInput("PrEP1",
                      "Control PrEP Coverage",
                      min=0.1,
                      max=1,
                      value=0.1),
        
        sliderInput("PrEP2",
                        "Counterfactual PrEP Coverage",
                        min=0.1,
                        max=1,
                        value=0.2),
        selectInput("model", "Network Generative Model", 
                    choices = c("Erdős–Rényi random graph", "Barabási-Albert scale-free", "Watts-Strogatz small-world")
        ),
        ),
        #model parameter tabs
        tabsetPanel(
          id = "params",
          type = "hidden",
          tabPanel("Erdős–Rényi random graph",
                   sliderInput("eprob", 
                               "edge probability", 
                               min=0.1,
                               max=1,
                               value=0.1)
          ),
          tabPanel("Barabási-Albert scale-free", 
                   sliderInput("pow", 
                               "preferential attachment power", 
                               min=0.1, max=2,
                               value=1)
          ),
          tabPanel("Watts-Strogatz small-world",
                   sliderInput("nb", 
                               "neighborhood size", 
                               value = 5, 
                               min = 5,
                               max=50),
                   
                  sliderInput("rprob",
                              "rewiring probability",
                              min=0.05,
                              max=1, 
                              value=0.05)
                   )
        ),
    ),
        # Show a plot of the generated network
        mainPanel(
           plotOutput("netPlot")
        )
)

# Define server logic required to draw network plot
server <- function(input, output) {
  observeEvent(input$model, {
    updateTabsetPanel(inputId = "params", selected = input$model)
  }) 
  #Generate networks
  sample <- reactive({
    switch(input$model,
           "Erdős–Rényi random graph" = sim_shiny(N=input$N,phiv=input$phiv,PrEP1=input$PrEP1, PrEP2 = input$PrEP2, model="ER",eprob=input$eprob),
           "Barabási-Albert scale-free" = sim_shiny(N=input$N,phiv=input$phiv,PrEP1=input$PrEP1, PrEP2 = input$PrEP2,model="BA",pow=input$pow),
           "Watts-Strogatz small-world" = sim_shiny(N=input$N,phiv=input$phiv,PrEP1=input$PrEP1, PrEP2 = input$PrEP2,model="WS",nb=input$nb,rprob=input$rprob)
    )
  })
    output$netPlot <- renderPlot({sample()
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
