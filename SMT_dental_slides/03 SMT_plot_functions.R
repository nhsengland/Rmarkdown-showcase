################################################################################
plot_UDA_UOA_delivery_calendar <- function(data = UDA_calendar_data, 
                                           scheduled_data = UDA_scheduled_data,
                                           contractor_cats = contractor_categories,
                                           UDAorUOA = "UDA",
                                           level = "National",
                                           region_STP_name = NULL,
                                           remove_prototypes = T,
                                           regional_lines = F, 
                                           STP_lines = F,
                                           cat_lines = F,
                                           plotChart = T){
  
  data <- data %>%
    mutate(month = as.Date(month))
  
  scheduled_data <- scheduled_data %>%
    mutate(month = as.Date(month)) 
  
  #join in MY categories
  data <- data %>%
    left_join(contractor_cats)
  
  
  #filter for STP or region
  if(level == "Regional"){
    data <- data %>% 
      filter(region_name == region_STP_name )
    subtitle <- region_STP_name
  }else if(level == "STP"){
    data <- data %>% 
      filter(commissioner_name == region_STP_name)
    subtitle <- region_STP_name
  }else{
    subtitle <- "England"
  }
  
  if(UDAorUOA == "UDA"){
    #get data into the right format
    data <- get_delivery_data_calendar(data, scheduled_data, remove_prototypes, UDAorUOA = "UDA", regional_lines, STP_lines, cat_lines)
    title <- "Calendar monthly percentage of usual annual contracted UDAs \ndelivered across all contracts* scaled up to 12 months"
    ylab <- "% of contracted UDAs delivered"
    captionTitle <- "*Excluding prototype contracts and those with annual contracted UDA < 100
                   **This is calendar data which means that data may change as more CoTs are registered"
    lineCol <- "coral"
    septemberTarget <- 60
    decemberTarget <- 65
    marchTarget <- 85
    juneTarget <- 95
  }else{
    
    #get data into the right format
    data <- get_delivery_data_calendar(data, scheduled_data, remove_prototypes, UDAorUOA = "UOA", regional_lines, STP_lines, cat_lines)
    title <- "Calendar monthly percentage of usual annual contracted UOAs \ndelivered across all contracts* scaled up to 12 months"
    ylab <- "% of contracted UOAs delivered"
    captionTitle <- "*Excluding prototype contracts and those with zero annual contracted UOAs
                   **This is calendar data which means that data may change as more CoTs are registered"
    lineCol <- "#009E73"
    septemberTarget <- 80
    decemberTarget <- 85
    marchTarget <- 90
    juneTarget <- 100
  }
  
  
  subtitle_addition <- ""
  
  if(regional_lines){
    g <- 
      ggplot(data) +
      theme_bw() +
      geom_line(aes(x = month, 
                    y = scaled_perc_UDA_UOA_delivered,
                    colour = region_name), 
                size = 1) +
      geom_point(aes(x = month, 
                     y = scaled_perc_UDA_UOA_delivered, 
                     colour = region_name)
      )
    
    legendTitle <- "Region"
    
  }else if(STP_lines){
    g <- 
      ggplot(data) +
      theme_bw() +
      geom_line(aes(x = month, 
                    y = scaled_perc_UDA_UOA_delivered,
                    colour = commissioner_name), 
                size = 1) +
      geom_point(aes(x = month, 
                     y = scaled_perc_UDA_UOA_delivered, 
                     colour = commissioner_name)
      )
    
    legendTitle <- "STP"
    
  }else if(cat_lines){
    data <- data %>%
      filter(!is.na(category_sub_type))
    
    g <- 
      ggplot(data) +
      theme_bw() +
      geom_line(aes(x = month, 
                    y = scaled_perc_UDA_UOA_delivered,
                    colour = category_sub_type), 
                size = 1) +
      geom_point(aes(x = month, 
                     y = scaled_perc_UDA_UOA_delivered, 
                     colour = category_sub_type)
      )
    
    legendTitle <- "MY Category"
    subtitle_addition <- if_else(remove_prototypes, " - *Excluding prototypes and contracts with annual contracted UDA < 100",
                                 " - *Including prototypes and contracts with annual contracted UDA < 100")
    
    captionTitle <- "**This is calendar data which means that data may change as more CoTs are registered"
    
  }else{
    g <- 
      ggplot(data) +
      theme_bw() +
      geom_line(aes(x = month, 
                    y = scaled_perc_UDA_UOA_delivered),
                colour = lineCol, 
                size = 1) +
      geom_point(aes(x = month, 
                     y = scaled_perc_UDA_UOA_delivered), 
                 colour = lineCol
      )+
      annotate(geom = "text", 
               x = data$month, 
               y = data$scaled_perc_UDA_UOA_delivered + 5, 
               label = paste0(round(data$scaled_perc_UDA_UOA_delivered), "%"), 
               size = 3) 
    
  }
  
  g <- g +
    geom_segment(aes(x = as.Date("2021-04-01"), 
                     y = septemberTarget, 
                     xend = as.Date("2021-09-01"), 
                     yend = septemberTarget),
                 colour = "#0072B2",
                 linetype = "dashed") +
    
    geom_segment(aes(x = as.Date("2021-10-01"), 
                     y = decemberTarget, 
                     xend = as.Date("2021-12-01"), 
                     yend = decemberTarget),
                 colour = "#0072B2",
                 linetype = "dashed") +
    
    geom_segment(aes(x = as.Date("2022-01-01"), 
                     y = marchTarget, 
                     xend = as.Date("2022-03-01"), 
                     yend = marchTarget),
                 colour = "#0072B2",
                 linetype = "dashed") +
    
    geom_segment(aes(x = as.Date("2022-04-01"), 
                     y = juneTarget, 
                     xend = as.Date("2022-06-01"), 
                     yend = juneTarget),
                 colour = "#0072B2",
                 linetype = "dashed") +
    
    
    annotate(geom = "text", 
             x = as.Date("2021-04-01") + lubridate::weeks(2), 
             y = septemberTarget - 3, 
             label = "H1 threshold", 
             size = 3,
             colour = "#0072B2") + 
    
    annotate(geom = "text", 
             x = as.Date("2021-10-01") + lubridate::weeks(2), 
             y = decemberTarget - 3, 
             label = "Q3 threshold", 
             size = 3,
             colour = "#0072B2") +
    
    annotate(geom = "text", 
             x = as.Date("2022-01-01") + lubridate::weeks(2), 
             y = marchTarget - 3, 
             label = "Q4 threshold", 
             size = 3,
             colour = "#0072B2") +
    
    annotate(geom = "text", 
             x = as.Date("2022-04-01") + lubridate::weeks(2), 
             y = juneTarget - 3, 
             label = "Q1 threshold", 
             size = 3,
             colour = "#0072B2") +
    
    scale_x_date(date_breaks = "1 month", 
                 date_labels = "%b-%y") +
    scale_y_continuous(limits = c(0, max(c(data$scaled_perc_UDA_UOA_delivered, 90), na.rm = T) + 10),
                       breaks = scales::breaks_pretty()) 
  
  
  if(regional_lines == F & cat_lines == F){
    g <- g +
      labs(title = title, 
           x = "Month",
           y = ylab, 
           subtitle = paste0(subtitle, subtitle_addition),
           caption = captionTitle)
    
  }else{
    g <- g +
      labs(title = title, 
           x = "Month",
           y = ylab, 
           subtitle = paste0(subtitle, subtitle_addition),
           caption = captionTitle,
           colour = legendTitle) 
    
  }
  
  
  if(plotChart){
    g
  }else{
    data
  }
}


################################################################################
get_num_contracts <- function(data = UDA_calendar_data, 
                              remove_prototypes = T,
                              scheduled_data = UDA_scheduled_data,
                              UDAorUOA = "UDA",
                              level = "National",
                              region_STP_name = NULL){
  
  #filter for STP or region
  if(level == "Regional"){
    data <- data %>% 
      filter(region_name == region_STP_name )
  }else if(level == "STP"){
    data <- data %>% 
      filter(commissioner_name == region_STP_name)
    subtitle <- region_STP_name
  }
  
  if(UDAorUOA == "UDA"){
    #get contracted UDAs
    contracted_UDA_UOAs <- scheduled_data %>%
      select(month, contract_number, annual_contracted_UDA)
  }else{
    #get contracted UOAs
    contracted_UDA_UOAs <- scheduled_data %>%
      select(month, contract_number, annual_contracted_UOA)
  }
  
  #join in contracted UDA/UOAs from scheduled data
  data <- data %>%
    left_join(contracted_UDA_UOAs, by = c("month", "contract_number"))
  
  #create not in function
  `%notin%` = Negate(`%in%`)
  
  #remove prototype contracts if specified
  if(remove_prototypes & UDAorUOA == "UDA"){
    data <- data %>%
      filter(contract_number %notin% prototype_contracts$prototype_contract_number)%>%
      filter(annual_contracted_UDA > 100)
  }else if(remove_prototypes & UDAorUOA == "UOA"){
    data <- data %>%
      filter(contract_number %notin% prototype_contracts$prototype_contract_number)%>%
      filter(annual_contracted_UOA > 0)###############
  }
  
  data <- data %>%
    filter(month == max(data$month))
  
  nrow(data)
}

