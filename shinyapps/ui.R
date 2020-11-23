#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(readr)
library(DT)
library(RMySQL)
library(lubridate)

drv = dbDriver("MySQL")
db = dbConnect(drv,user='root',password = 'root123',host = 'uno_parte1_db_1',dbname = 'Parcial1')

academatica_video_stats = dbGetQuery(db,statement = ('SELECT * FROM academatica_video_stats;'))
academatica_videos = dbGetQuery(db,statement = ('SELECT * FROM academatica_videos;'))
academatica_videos_metadata = dbGetQuery(db,statement = ('SELECT * FROM academatica_videos_metadata;'))



df = merge(academatica_videos,academatica_video_stats,by.x = "contentDetails.videoId",by.y = "id")
df = merge(df,academatica_videos_metadata,by.x = "contentDetails.videoId",by.y = "video_id")

df$date <- as.Date(df$contentDetails.videoPublishedA)
df$year <- year(df$date)
df$month <- month(df$date)
df$dom <- mday(df$date)
df$dow <- wday(df$date)
df$length_title <- sapply(df$title,nchar)
df$like_ratio <- df$likeCount/df$viewCount
df$comment_ratio <- df$commentCount/df$viewCount
df$dislike_ratio <- df$dislikeCount/df$viewCount
df$length_description <- sapply(df$description,nchar)

cols <- names(df)

for(i in seq_along(cols)){
    
    if(!is.character(df[, cols[[i]]])) next
    
    Encoding(df[, cols[[i]]]) <- "UTF-8"
    
}

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    # Application title
    titlePanel("Videos de Academática"),
    
    h4("Parcial 1 Product Development"),
    h6("Juan Pablo Carranza Hurtado"),
    h6("José Alberto Ligorría Taracena"),
    
    
    # Sidebar with a slider input for number of bins
    
    tabsetPanel(
        tabPanel("Histogramas",
                 sidebarLayout(
                     sidebarPanel(
                         h4(strong("Selecciona los filtros que desees")),
                         dateRangeInput(inputId = "date_input", 
                                        label = "Filtra por un rango de fechas",
                                        start = min(df$date),
                                        end = max(df$date),
                                        min = min(df$date), 
                                        max = max(df$date)),
                         selectInput(inputId = "month_select",
                                     label = "Filtra por un número de mes",
                                     choices = c(NULL,1:12),
                                     selected = NULL,
                                     multiple = TRUE),
                         selectInput(inputId = "dom_select",
                                     label = "Filtra por un día del mes",
                                     choices = c(NULL, 1:31),
                                     selected = NULL,
                                     multiple = TRUE),
                         selectInput(inputId = "dow_select",
                                     label = "Filtra por un día de la semana",
                                     choices = c(NULL,1:7),
                                     selected = NULL,
                                     multiple = TRUE),
                         sliderInput(inputId = "slider_input",
                                     label = "Filtra por número de vistas",
                                     min = min(df$viewCount, na.rm = TRUE),
                                     max = max(df$viewCount, na.rm = TRUE),
                                     value = c(min(df$viewCount, na.rm = TRUE), max(df$viewCount, na.rm = TRUE)))
                     ),
                     
                     # Show a plot of the generated distribution
                     mainPanel(
                         h4(strong("Histogramas de la popularidad de los videos")),
                         
                         fluidRow(
                             column(6, 
                                    plotOutput(outputId = "distPlot")),
                             column(6,
                                    plotOutput(outputId = "distPlot_likes"))),
                         fluidRow(
                             column(6, 
                                    plotOutput(outputId = "distPlot_comment")),
                             column(6,
                                    plotOutput(outputId = "distPlot_dislike")))
                     )
                 )
                 
                 
        ),
        tabPanel("Vista tabular",
                 sidebarLayout(
                     sidebarPanel(
                         h4(strong("Selecciona los filtros que desees")),
                         dateRangeInput(inputId = "date_input2", 
                                        label = "Filtra por un rango de fechas",
                                        start = min(df$date),
                                        end = max(df$date),
                                        min = min(df$date), 
                                        max = max(df$date)),
                         selectInput(inputId = "month_select2",
                                     label = "Filtra por un número de mes",
                                     choices = c(NULL,1:12),
                                     selected = NULL,
                                     multiple = TRUE),
                         selectInput(inputId = "dom_select2",
                                     label = "Filtra por un día del mes",
                                     choices = c(NULL, 1:31),
                                     selected = NULL,
                                     multiple = TRUE),
                         selectInput(inputId = "dow_select2",
                                     label = "Filtra por un día de la semana",
                                     choices = c(NULL,1:7),
                                     selected = NULL,
                                     multiple = TRUE),
                         sliderInput(inputId = "slider_input2",
                                     label = "Filtra por número de vistas",
                                     min = min(df$viewCount, na.rm = TRUE),
                                     max = max(df$viewCount, na.rm = TRUE),
                                     value = c(min(df$viewCount, na.rm = TRUE), max(df$viewCount, na.rm = TRUE)))
                         
                     ),
                     
                     mainPanel(
                         
                         h4(strong("Vista tabular de los videos")),
                         
                         DT::DTOutput('DT_table')
                         
                     )
                 )
                 
                 
        ),
        tabPanel("Cruce de variables",
                 sidebarLayout(
                     sidebarPanel(
                         h4(strong("Selecciona los filtros que desees")),
                         dateRangeInput(inputId = "date_input3", 
                                        label = "Filtra por un rango de fechas",
                                        start = min(df$date),
                                        end = max(df$date),
                                        min = min(df$date), 
                                        max = max(df$date)),
                         selectInput(inputId = "month_select3",
                                     label = "Filtra por un número de mes",
                                     choices = c(NULL,1:12),
                                     selected = NULL,
                                     multiple = TRUE),
                         selectInput(inputId = "dom_select3",
                                     label = "Filtra por un día del mes",
                                     choices = c(NULL, 1:31),
                                     selected = NULL,
                                     multiple = TRUE),
                         selectInput(inputId = "dow_select3",
                                     label = "Filtra por un día de la semana",
                                     choices = c(NULL,1:7),
                                     selected = NULL,
                                     multiple = TRUE),
                         sliderInput(inputId = "slider_input3",
                                     label = "Filtra por número de vistas",
                                     min = min(df$viewCount, na.rm = TRUE),
                                     max = max(df$viewCount, na.rm = TRUE),
                                     value = c(min(df$viewCount, na.rm = TRUE), max(df$viewCount, na.rm = TRUE)))
                         
                     ),
                     
                     
                     mainPanel(
                         plotOutput('views_vs_descr'),
                         plotOutput('views_vs_title')
                     )
                 )
                 
                 
        ),
        tabPanel("Top Videos",
                 sidebarLayout(
                     sidebarPanel(
                         h4(strong("Selecciona los filtros que desees")),
                         dateRangeInput(inputId = "date_input4", 
                                        label = "Filtra por un rango de fechas",
                                        start = min(df$date),
                                        end = max(df$date),
                                        min = min(df$date), 
                                        max = max(df$date)),
                         selectInput(inputId = "month_select4",
                                     label = "Filtra por un número de mes",
                                     choices = c(NULL,1:12),
                                     selected = NULL,
                                     multiple = TRUE),
                         selectInput(inputId = "dom_select4",
                                     label = "Filtra por un día del mes",
                                     choices = c(NULL, 1:31),
                                     selected = NULL,
                                     multiple = TRUE),
                         selectInput(inputId = "dow_select4",
                                     label = "Filtra por un día de la semana",
                                     choices = c(NULL,1:7),
                                     selected = NULL,
                                     multiple = TRUE),
                         sliderInput(inputId = "slider_input4",
                                     label = "Filtra por número de vistas",
                                     min = min(df$viewCount, na.rm = TRUE),
                                     max = max(df$viewCount, na.rm = TRUE),
                                     value = c(min(df$viewCount, na.rm = TRUE), max(df$viewCount, na.rm = TRUE)))
                         
                     ),
                     
                     
                     mainPanel(
                         fluidRow(
                             column(6,DT::DTOutput('DT_table_viewTop')),
                             column(6,DT::DTOutput('DT_table_likeTop'))),
                         h1('a', style = "color:white"),
                         fluidRow(
                             column(6,DT::DTOutput('DT_table_dislikeTop')),
                             column(6,DT::DTOutput('DT_table_comentsTop'))
                         )
                         
                     )
                 )
                 
                 
        )
        
    )
    
    
))
