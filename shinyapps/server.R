#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
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

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    output$distPlot <- renderPlot({
        
        # generate bins based on input$bins from ui.R
        x <- filter(df,((df$viewCount >= input$slider_input[1])&(df$viewCount <= input$slider_input[2])))
        
        x <- filter(x,((x$date >= input$date_input[1])&(x$date <= input$date_input[2])))
        #print(nrow(x))
        
        if(!is.null(input$dom_select)){
            x <- filter(x,x$dom %in% input$dom_select)
        }
        
        if(!is.null(input$dow_select)){
            x <- filter(x,x$dow %in% input$dow_select)
        }
        
        if(!is.null(input$month_select)){
            x <- filter(x,x$month %in% input$month_select)
        }
        #print(x$viewCount)
        validate(need(length(x$viewCount)>1,'¡El número total de videos con estos filtros es menor que 2!'))  
        
        bins <- seq(min(x$viewCount, na.rm = TRUE), max(x$viewCount, na.rm = TRUE), length.out = 30)
        
        hist(x$viewCount, breaks = bins, col = 'darkgray', border = 'white', xlab = "Total de vistas", main = "Histograma de visitas", ylab = "Frecuencias")
        
    })
    
    output$distPlot_likes <- renderPlot({
        
        # generate bins based on input$bins from ui.R
        x <- filter(df,((df$viewCount >= input$slider_input[1])&(df$viewCount <= input$slider_input[2])))
        
        x <- filter(x,((x$date >= input$date_input[1])&(x$date <= input$date_input[2])))
        #print(nrow(x))
        
        if(!is.null(input$dom_select)){
            x <- filter(x,x$dom %in% input$dom_select)
        }
        
        if(!is.null(input$dow_select)){
            x <- filter(x,x$dow %in% input$dow_select)
        }
        
        if(!is.null(input$month_select)){
            x <- filter(x,x$month %in% input$month_select)
        }
        validate(need(length(x$viewCount)>1,'¡El número total de videos con estos filtros es menor que 2!'))  
        
        bins <- seq(min(x$likeCount, na.rm = TRUE), max(x$likeCount, na.rm = TRUE), length.out = 30)
        
        hist(x$likeCount, breaks = bins, col = 'darkgray', border = 'white', xlab = "Total de likes", main = "Histograma de likes", ylab = "Frecuencias")
        
    })
    
    output$distPlot_comment <- renderPlot({
        
        # generate bins based on input$bins from ui.R
        x <- filter(df,((df$viewCount >= input$slider_input[1])&(df$viewCount <= input$slider_input[2])))
        
        x <- filter(x,((x$date >= input$date_input[1])&(x$date <= input$date_input[2])))
        #print(nrow(x))
        
        if(!is.null(input$dom_select)){
            x <- filter(x,x$dom %in% input$dom_select)
        }
        
        if(!is.null(input$dow_select)){
            x <- filter(x,x$dow %in% input$dow_select)
        }
        
        if(!is.null(input$month_select)){
            x <- filter(x,x$month %in% input$month_select)
        }
        validate(need(length(x$viewCount)>1,'¡El número total de videos con estos filtros es menor que 2!'))  
        
        bins <- seq(min(x$commentCount, na.rm = TRUE), max(x$commentCount, na.rm = TRUE), length.out = 30)
        
        hist(x$commentCount, breaks = bins, col = 'darkgray', border = 'white', xlab = "Total de comentarios", main = "Histograma de comentarios", ylab = "Frecuencia")
        
    })
    
    
    output$distPlot_dislike <- renderPlot({
        
        # generate bins based on input$bins from ui.R
        x <- filter(df,((df$viewCount >= input$slider_input[1])&(df$viewCount <= input$slider_input[2])))
        
        x <- filter(x,((x$date >= input$date_input[1])&(x$date <= input$date_input[2])))
        #print(nrow(x))
        
        if(!is.null(input$dom_select)){
            x <- filter(x,x$dom %in% input$dom_select)
        }
        
        if(!is.null(input$dow_select)){
            x <- filter(x,x$dow %in% input$dow_select)
        }
        
        if(!is.null(input$month_select)){
            x <- filter(x,x$month %in% input$month_select)
        }
        validate(need(length(x$viewCount)>1,'¡El número total de videos con estos filtros es menor que 2!'))  
        
        bins <- seq(min(x$dislikeCount, na.rm = TRUE), max(x$dislikeCount, na.rm = TRUE), length.out = 30)
        
        hist(x$dislikeCount, breaks = bins, col = 'darkgray', border = 'white', xlab = "Total de dislikes", main = "Histograma de dislikes", ylab = "Frecuencia")
        
    })
    
    
    
    output$DT_table <- renderDT({
        # generate bins based on input$bins from ui.R
        x <- filter(df,((df$viewCount >= input$slider_input2[1])&(df$viewCount <= input$slider_input2[2])))
        
        x <- filter(x,((x$date >= input$date_input2[1])&(x$date <= input$date_input2[2])))
        
        if(!is.null(input$dom_select2)){
            x <- filter(x,x$dom %in% input$dom_select2)
        }
        
        if(!is.null(input$dow_select2)){
            x <- filter(x,x$dow %in% input$dow_select2)
        }
        
        if(!is.null(input$month_select2)){
            x <- filter(x,x$month %in% input$month_select2)
        }
        validate(need((nrow(x))>0,'¡El número total de videos con estos filtros es 0!'))  
        
        x %>%
            select(id, title, date, viewCount, likeCount, dislikeCount, commentCount, length_description, length_title)
    })
    
    
    output$views_vs_descr <- renderPlot({
        # generate bins based on input$bins from ui.R
        x <- filter(df,((df$viewCount >= input$slider_input3[1])&(df$viewCount <= input$slider_input3[2])))
        
        x <- filter(x,((x$date >= input$date_input3[1])&(x$date <= input$date_input3[2])))
        
        if(!is.null(input$dom_select3)){
            x <- filter(x,x$dom %in% input$dom_select3)
        }
        
        if(!is.null(input$dow_select3)){
            x <- filter(x,x$dow %in% input$dow_select3)
        }
        
        if(!is.null(input$month_select3)){
            x <- filter(x,x$month %in% input$month_select3)
        }
        validate(need(((length(x$length_description)>0)&(length(x$viewCount)>0)),'¡El número total de videos con estos filtros es 0!'))  
        
        ggplot(x, aes(x = length_description, y = viewCount)) + geom_point() +
            ggtitle("Longitud de la descripción vs. Total de vistas") + xlab('Longitud de la descripción') + ylab('Total de vistas')
    })
    
    
    output$views_vs_title <- renderPlot({
        # generate bins based on input$bins from ui.R
        x <- filter(df,((df$viewCount >= input$slider_input3[1])&(df$viewCount <= input$slider_input3[2])))
        
        x <- filter(x,((x$date >= input$date_input3[1])&(x$date <= input$date_input3[2])))
        
        if(!is.null(input$dom_select3)){
            x <- filter(x,x$dom %in% input$dom_select3)
        }
        
        if(!is.null(input$dow_select3)){
            x <- filter(x,x$dow %in% input$dow_select3)
        }
        
        if(!is.null(input$month_select3)){
            x <- filter(x,x$month %in% input$month_select3)
        }
        validate(need(((length(x$length_title)>0)&(length(x$viewCount)>0)),'¡El número total de videos con estos filtros es 0!'))  
        
        ggplot(x, aes(x = as.factor(length_title), y = viewCount)) + geom_boxplot() +
            ggtitle("Longitud del título vs. Total de vistas") + xlab('Longitud de la descripción') + ylab('Total de vistas')
    })
    
    output$DT_table_viewTop <- renderDT({
        x <- filter(df,((df$viewCount >= input$slider_input4[1])&(df$viewCount <= input$slider_input4[2])))
        
        x <- filter(x,((x$date >= input$date_input4[1])&(x$date <= input$date_input4[2])))
        
        if(!is.null(input$dom_select4)){
            x <- filter(x,x$dom %in% input$dom_select4)
        }
        
        if(!is.null(input$dow_select4)){
            x <- filter(x,x$dow %in% input$dow_select4)
        }
        
        if(!is.null(input$month_select4)){
            x <- filter(x,x$month %in% input$month_select4)
        }
        validate(need((nrow(x))>0,'¡El número total de videos con estos filtros es 0!'))  
        
        x %>% mutate(Título = title, 'Cantidad de Vistas' = viewCount) %>% arrange(desc(viewCount)) %>% select(Título,'Cantidad de Vistas') %>% top_n(3)
        # select(id, title, date, viewCount, likeCount, dislikeCount, commentCount, length_description, length_title)
        
    })
    
    output$DT_table_likeTop <- renderDT({
        x <- filter(df,((df$viewCount >= input$slider_input4[1])&(df$viewCount <= input$slider_input4[2])))
        
        x <- filter(x,((x$date >= input$date_input4[1])&(x$date <= input$date_input4[2])))
        
        if(!is.null(input$dom_select4)){
            x <- filter(x,x$dom %in% input$dom_select4)
        }
        
        if(!is.null(input$dow_select4)){
            x <- filter(x,x$dow %in% input$dow_select4)
        }
        
        if(!is.null(input$month_select4)){
            x <- filter(x,x$month %in% input$month_select4)
        }
        validate(need((nrow(x))>0,'¡El número total de videos con estos filtros es 0!'))  
        
        x %>% mutate(Título = title, 'Cantidad de likes' = likeCount) %>% arrange(desc(likeCount)) %>% select(Título,'Cantidad de likes') %>% top_n(3)
        # select(id, title, date, viewCount, likeCount, dislikeCount, commentCount, length_description, length_title)
        
    })
    
    output$DT_table_dislikeTop <- renderDT({
        x <- filter(df,((df$viewCount >= input$slider_input4[1])&(df$viewCount <= input$slider_input4[2])))
        
        x <- filter(x,((x$date >= input$date_input4[1])&(x$date <= input$date_input4[2])))
        
        if(!is.null(input$dom_select4)){
            x <- filter(x,x$dom %in% input$dom_select4)
        }
        
        if(!is.null(input$dow_select4)){
            x <- filter(x,x$dow %in% input$dow_select4)
        }
        
        if(!is.null(input$month_select4)){
            x <- filter(x,x$month %in% input$month_select4)
        }
        validate(need((nrow(x))>0,'¡El número total de videos con estos filtros es 0!'))  
        
        x %>% mutate(Título = title, 'Cantidad de dislikes' = dislikeCount) %>% arrange(desc(dislikeCount)) %>% select(Título,'Cantidad de dislikes') %>% top_n(3)
        # select(id, title, date, viewCount, likeCount, dislikeCount, commentCount, length_description, length_title)
        
    })
    
    output$DT_table_comentsTop <- renderDT({
        x <- filter(df,((df$viewCount >= input$slider_input4[1])&(df$viewCount <= input$slider_input4[2])))
        
        x <- filter(x,((x$date >= input$date_input4[1])&(x$date <= input$date_input4[2])))
        
        if(!is.null(input$dom_select4)){
            x <- filter(x,x$dom %in% input$dom_select4)
        }
        
        if(!is.null(input$dow_select4)){
            x <- filter(x,x$dow %in% input$dow_select4)
        }
        
        if(!is.null(input$month_select4)){
            x <- filter(x,x$month %in% input$month_select4)
        }
        validate(need((nrow(x))>0,'¡El número total de videos con estos filtros es 0!'))  
        
        x %>% mutate(Título = title, 'Cantidad de comentarios' = commentCount) %>% arrange(desc(commentCount)) %>% select(Título,'Cantidad de comentarios') %>% top_n(3)
        # select(id, title, date, viewCount, likeCount, dislikeCount, commentCount, length_description, length_title)
        
    })
    
    output$DT_No_Exists <- renderDT({
        x <- filter(df,((df$viewCount >= input$slider_input4[1])&(df$viewCount <= input$slider_input4[2])))
        
        x <- filter(x,((x$date >= input$date_input4[1])&(x$date <= input$date_input4[2])))
        
        if(!is.null(input$dom_select4)){
            x <- filter(x,x$dom %in% input$dom_select4)
        }
        
        if(!is.null(input$dow_select4)){
            x <- filter(x,x$dow %in% input$dow_select4)
        }
        
        if(!is.null(input$month_select4)){
            x <- filter(x,x$month %in% input$month_select4)
        }
        validate(need((nrow(x))>0,'¡El número total de videos con estos filtros es 0!'))  
        
        x %>% mutate(Título = title, 'Cantidad de dislikes' = dislikeCount) %>% arrange(desc(dislikeCount)) %>% select(Título,'Cantidad de dislikes') %>% top_n(0)
        # select(id, title, date, viewCount, likeCount, dislikeCount, commentCount, length_description, length_title)
        
    })
    
})
