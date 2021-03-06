#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(tidyverse)
library(emojifont)
library(grid)
library(shinythemes)

# Define UI for application that draws a histogram
ui <- navbarPage(
    "Kvis",
    tabPanel("Score",
             fluidPage(
                 
                 
                 # Sidebar with a slider input for number of bins 
                 sidebarLayout(
                            sidebarPanel(
                                tags$head(tags$script
                                                    ('
                                                    $(document).on("shiny:connected", function(e) {
                                                        Shiny.onInputChange("innerWidth", window.innerWidth);
                                                    });
                                                    $(window).resize(function(e) {
                                                        Shiny.onInputChange("innerWidth", window.innerWidth);
                                                    });
                                                    '),
                                          tags$style(HTML('
                                                    .navbar-brand{
                                                    font-family: "Georgia", Times, "Times New Roman", serif;
                                                    font-weight: bold;
                                                    font-size: 24px;
                                                    }'))
                                          ),
                                selectInput(inputId = "algorithm",
                                            label = "Score:",
                                            choices = c("PROCAM")),
                                sliderInput("age",
                                            "Alter:",
                                            min = 35,
                                            max = 65,
                                            value = 50),
                                sliderInput("cholesterin_LDL_mg",
                                            "LDL-Cholesterin (in mg/dl):",
                                            min = 75,
                                            max = 250,
                                            value = 100),
                                sliderInput("cholesterin_HDL_mg",
                                            "HDL-Cholesterin (in mg/dl):",
                                            min = 25,
                                            max = 75,
                                            value = 50),
                                sliderInput("triglycerides",
                                            "Triglyceride (in mg/dl):",
                                            min = 50,
                                            max = 400,
                                            value = 100),
                                sliderInput("RR_sys",
                                            "Systolischer Blutdruck (in mmHg):",
                                            min = 100,
                                            max = 290,
                                            value = 115),
                                radioButtons("smoker",
                                             "Raucher",
                                             choiceValues = c(0, 1),
                                             choiceNames = c("nein", "ja")),
                                radioButtons("diabetes",
                                             "Diabetis mellitus",
                                             choiceValues = c(0, 1),
                                             choiceNames = c("nein", "ja")),
                                radioButtons("MI_family",
                                             "Hatten ein Verwandter 1. Grades (Vater, Mutter, Geschwister, Kind) einen Herzinfarkt vor seinem 60. Lebensjahr erlitten?",
                                             choiceValues = c(0, 1),
                                             choiceNames = c("nein", "ja"))
                                ),
                    mainPanel(
                        fluidRow(h3(textOutput("risk_score")), align = "center"),
                        br(),
                        br(),
                        fluidRow(wellPanel(
                                            style = "width:300px",
                                            checkboxGroupInput("improv",
                                                    "Modifizierbare Risikofaktoren",
                                                    choices = c(
                                                        "Rauchen aufhören" = 1,
                                                        "Diabetes einstellen" = 2,
                                                        "Blutdruck einstellen" = 3
                                                    )
                                ), align = "center"), align = "center"),
                        fluidRow(
                            column(6, h4("Mit aktuellen Risikofaktoren"), align="center"),
                            column(6, h4("Verhaltensänderung"), align="center")
                        ),
                        fluidRow(
                            column(6, plotOutput("pre_Plot"), align="center"),
                            column(6, plotOutput("post_Plot"), align="center")
                        )
                        
                     )
                     
                     

                     
                
                 )
             )
             ),
    tabPanel("Methoden",
             fluidPage(
                 fluidRow(div(HTML("<em>Scores should not be relied upon as the primary basis of the prognostication at the level of the individual patient</em> - Netter's Neurology")), align = "center"),
                 br(),
                 
                      
                 navlistPanel(widths = c(3, 9),
                             "Dashboard",
                             tabPanel("R Code",
                                      fluidRow(
                                          br(),
                                          br(),
                                          br(), 
                                          uiOutput("github_link", align = "center"),
                                          br(),
                                          br(),
                                          img(src = "github_mark.png", height = 90, width = 90), 
                                          align = "center"   
                                      )
                                      ),
                             tabPanel("Shiny"),
                             "Scores",
                             tabPanel("PROCAM",
                                      fluidRow(
                                          br(),
                                          br(),
                                          br(),
                                          uiOutput("procam_link"), 
                                          align = "center"
                                      )
                                      ),
                             tabPanel("SCORE (ESC)",
                                      fluidRow(
                                          br(),
                                          br(),
                                          br(),
                                          uiOutput("score_link"), 
                                          align = "center"
                                      )
                                      ),
                             tabPanel("Framingham"),
                             tabPanel("ARRIBA")
                            )
                 
             )
             ),
    
    tabPanel("Donate"
    )
    
    
)
    
    
    

#scoring function
calculate_score <- function(input, ppval = "pre"){
    if(input$algorithm == "PROCAM"){
        ###PROCAM https://www.ahajournals.org/doi/full/10.1161/hc0302.102575
        label_to_num <- function(fac){
            return(as.numeric(as.character(fac)))
        }
        
        if(ppval == "pre"){
            score_procam <- 0
            
            score_procam = score_procam + label_to_num((cut(input$age, breaks = c(0, 40, 45, 50, 55, 60, 150), right = FALSE, labels = c(0,6,11,16,21,26))))
            score_procam = score_procam + label_to_num(cut(input$cholesterin_LDL_mg, breaks = c(0, 100, 130, 160, 190, 1000), right = FALSE, labels = c(0, 5, 10, 14, 20)))
            score_procam = score_procam + label_to_num(cut(input$cholesterin_HDL_mg, breaks = c(0, 35, 45, 55, Inf), right = FALSE, labels = c(11, 8, 5, 0)))
            score_procam = score_procam + label_to_num(cut(input$triglycerides, breaks = c(0, 100, 150, 200, Inf), right = FALSE, labels = c(0,2,3,4)))
            score_procam = score_procam + ifelse(input$smoker == 1, 8, 0)
            score_procam = score_procam + ifelse(input$diabetes == 1, 6, 0)
            score_procam = score_procam + ifelse(input$MI_family == 1, 4, 0)
            score_procam = score_procam + label_to_num(cut(input$RR_sys, breaks = c(0, 120, 130, 140, 160, Inf), right= FALSE, labels = c(0, 2, 3, 5, 8)))
            
            return(label_to_num(cut(score_procam, breaks = c(0, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, Inf), right = FALSE, labels = c(1, 1.1, 1.2, 1.3, 1.4, 1.6,1.7,1.8,1.9, 2.3,2.4,2.8,2.9,3.3,3.5,4,4.2,4.8,5.1,5.7,6.1,7,7.4,8,8.8,10.2,10.5,10.7,12.8,13.2,15.5,16.8,17.5,19.6,21.7,22.2,23.8,25.1,28,29.4,30))))
            
        }else{
            score_procam <- 0
            score_procam = score_procam + label_to_num((cut(input$age, breaks = c(0, 40, 45, 50, 55, 60, 150), right = FALSE, labels = c(0,6,11,16,21,26))))
            score_procam = score_procam + label_to_num(cut(input$cholesterin_LDL_mg, breaks = c(0, 100, 130, 160, 190, 1000), right = FALSE, labels = c(0, 5, 10, 14, 20)))
            score_procam = score_procam + label_to_num(cut(input$cholesterin_HDL_mg, breaks = c(0, 35, 45, 55, Inf), right = FALSE, labels = c(11, 8, 5, 0)))
            score_procam = score_procam + label_to_num(cut(input$triglycerides, breaks = c(0, 100, 150, 200, Inf), right = FALSE, labels = c(0,2,3,4)))
            score_procam = score_procam + ifelse(sum(input$improv %in% 1), 0, ifelse(input$smoker == 1, 8, 0))
            score_procam = score_procam + ifelse(sum(input$improv %in% 2), 0, ifelse(input$diabetes == 1, 6, 0))
            score_procam = score_procam + ifelse(input$MI_family == 1, 4, 0)
            score_procam = score_procam + ifelse(sum(input$improv %in% 3), 0, label_to_num(cut(input$RR_sys, breaks = c(0, 120, 130, 140, 160, Inf), right= FALSE, labels = c(0, 2, 3, 5, 8))))
            
            return(label_to_num(cut(score_procam, breaks = c(0, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, Inf), right = FALSE, labels = c(1, 1.1, 1.2, 1.3, 1.4, 1.6,1.7,1.8,1.9, 2.3,2.4,2.8,2.9,3.3,3.5,4,4.2,4.8,5.1,5.7,6.1,7,7.4,8,8.8,10.2,10.5,10.7,12.8,13.2,15.5,16.8,17.5,19.6,21.7,22.2,23.8,25.1,28,29.4,30))))
            
        }
        
    }else{
        ###SCORE https://www.medizin.uni-muenster.de/fileadmin/einrichtung/epi/download/aerzteblatt_methoden.pdf
        #x_1 <- input$cholesterin_total #in mmol/l
        x_2 <- input$RR_sys #mmHg systolisch
        x_3 <- input$smoker #1 ja
        c_1 <- 6 #mmol/l
        c_2 <- 120 #mmHg
    }
}


gg_faces <- function(df, ppval = "pre", algo, emo_size = 8){
    df$sel <- ppval
    df$col <- ifelse(df$sel == "pre", df$group,
                     df$group_post)
    df$out_emo <- ifelse(df$sel == "pre", df$emo,
                         df$emo_post)
    plot <- ggplot(df, aes(x = x, y = y, fill = col, label = out_emo, color = col)) + 
        geom_text(family = "OpenSansEmoji", size = emo_size) +
        scale_x_continuous(expand = c(0.08, 0.08)) +
        scale_y_continuous(expand = c(0.08, 0.08), trans = 'reverse') +
        scale_color_manual(values = c("#67a9cf", "#ef8a62", "#053061")) +
        theme_void() +
        theme(legend.position = "none")
    
    grob <- ggplotGrob(plot)
    
    plot.rrg <- roundrectGrob(gp = gpar(fill = "#f5f5f5", col = "#e3e3e3", lwd = 1.5),
                              r = unit(0.02, "npc"))
    plot_panel <- grid.draw(gList(plot.rrg, grob))
    
    return(plot_panel)
}

prep_df <- function(input){
    p <- (round(calculate_score(input), 0)/100)
    nrows <- 10
    ncols <- 10
    pep <- p*nrows*ncols
    
    #pre_plot
    df <- expand.grid(y = 1:nrows, x = 1:ncols)
    df <- df %>% arrange(desc(x)) %>% arrange(desc(y))
    
    df$ind <- 1:nrow(df)
    df$group <- "healthy"
    df$group[1:pep] <- "risk"
    df$emo <- ifelse(df$group == "healthy", emoji('smile'), emoji('disappointed'))
    df$emo_post <- df$emo
    
    #post_plot
    q <- (round(calculate_score(input, ppval = "post")))/100
    pep_mod_risk <- q*nrows*ncols
    pep_diff <- pep - pep_mod_risk
    
    df <- df %>% arrange(desc(group), y, x) 
    df$improv <- FALSE
    
    if (pep_diff>0){
        df$improv[1:pep_diff] <- TRUE
        df$group_post <- paste(df$group, df$improv, sep = "_")
        df$emo_post <- ifelse(df$improv == TRUE, emoji('smile'), df$emo_post)
    }else{
        df$group_post <- df$group
        df$emo_post <- df$emo
    }
    
    return(df)
}


# Define server logic 
server <- function(input, output, session) {
    
    
    output$risk_score <- renderText({
        paste("Ihr Risiko einen Herzinfarkt innerhalb der nächsten 10 Jahre zur erleiden beträgt: ", calculate_score(input), "%", sep = "")
    })
   
    
    #update modifable risk factors
    observe({
        mod_improv <- c(
                        "Rauchen aufhören" = ifelse(input$smoker == 1, 1, 0),
                        "Diabetes einstellen" = ifelse(input$diabetes == 1, 2, 0),
                        "Blutdruck einstellen" = ifelse(input$RR_sys >= 120, 3, 0)
                        )
        mod_improv <- mod_improv[which(mod_improv != 0)]
        updateCheckboxGroupInput(session, "improv", choices = mod_improv)
    })
    

    output$pre_Plot <- renderPlot({
        load.emojifont('OpenSansEmoji.ttf')
        p_df <- prep_df(input)
        gg_faces(p_df, ppval = "pre", algo = input$algorithm, emo_size = ifelse(!is.null(input$innerWidth), input$innerWidth/160, 4))
    },
    height=reactive(ifelse(!is.null(input$innerWidth),input$innerWidth*3/10,0)))
    
    output$post_Plot <- renderPlot({
        load.emojifont('OpenSansEmoji.ttf')
        p_df <- prep_df(input)
        gg_faces(p_df, ppval = "post", algo = input$algorithm, emo_size = ifelse(!is.null(input$innerWidth), input$innerWidth/160, 4))
    },
    height=reactive(ifelse(!is.null(input$innerWidth),input$innerWidth*3/10,0)))
    

    ###Methoden
    #Links
    output$github_link <- renderUI({
        tagList("R Code is available on", a("GitHub", href="https://github.com/Superfl0/Kvir"))
    })
    output$procam_link <- renderUI({
        tagList("Der PROCAM Score wurde in", a("diesem Paper", href="https://doi.org/10.1161/hc0302.102575"), "publiziert.")
    })
    output$score_link <- renderUI({
        tagList(HTML("<strong>S</strong>ystematic <strong>Co</strong>ronary <strong>R</strong>isk <strong>E</strong>valuation (SCORE) ist ein Modell der European Society of Cardiology (ESC) für die Risikoabschätzung tödlicher Herz-Kreislauf-Erkrankungen. Er kombiniert Daten aus 12 Europäische Kohortenstudien mit insgesamt 250.000 PatientInnen. Ausgehend davon wurde ein spezieller Risikoscore für die deutsche Bevölkerung berechnet, der in"), a("diesem Paper", href="https://doi.org/10.1161/hc0302.102575"), "publiziert ist.")
    })
    
}


# Run the application 
shinyApp(ui = ui, server = server)




