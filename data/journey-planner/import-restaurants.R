setwd('~/Projets/katossky.github.io/data/journey-planner')

library(rvest)
library(plyr)
library(dplyr)
library(tidyr)
library(stringr)
library(jsonlite)
library(data.table)

# SCRAPING ---------------------------------------------------------------------

get_michelin_restaurants <- function(top, bottom, left, right){
  url         <- paste0(
    'http://www.viamichelin.com/web/Recherche_Restaurants?',
    'geoboundaries=', bottom, ',', left,':',top,',', right
  )
  michelin         <- read_html(url)
  page_tabs        <- michelin %>% html_nodes('.pagination-container a')
  nb_pages         <- page_tabs %>% html_text() %>% as.integer %>% max
  Restaurants      <- vector(mode='list', length=nb_pages)
  Restaurants[[1]] <- michelin %>% html_nodes('li.poi-item')
  for(page in 2:nb_pages){
    sleep <- runif(1, min = 0, max = 1) %>% round(2)
    Sys.sleep(sleep)
    cat('Slept', sleep, 'seconds. Treating page', page, 'of', nb_pages, fill=TRUE)
    michelin    <- read_html(paste0(url, '&page=', page))
    Restaurants[[page]] <- michelin %>% html_nodes('li.poi-item')
  }
  return(Restaurants)
}

Restaurants <- c(
  get_michelin_restaurants(70, 50,  0, 20), # Scandinavia + Germany + North France
  get_michelin_restaurants(50, 40,-10, 10)  # France + North Spain
)

Restaurants <- do.call(c, Restaurants)
class(Restaurants) <- 'xml_nodeset'

# FORMATTING -------------------------------------------------------------------

prices <- Restaurants %>% html_nodes(css='.poi-item-price em') %>% html_text %>%
  unlist %>% str_extract('^[0-9]+') %>% as.integer %>%
  matrix(ncol=2, byrow=TRUE)

RESTAURANTS <- data.table(
  name       = Restaurants %>% html_nodes(css='.poi-item-name') %>% html_text,
  url        = Restaurants %>% html_nodes(css='.poi-item-name a') %>%
    xml_attr('href') %>% paste0('http://www.viamichelin.com', .),
  price_from        = prices[,1],
  price_to          = prices[,2],
  stars             = Restaurants %>% html_nodes(css='.poi-item-stars') %>%
    as.character %>% str_extract_all('="star"') %>% lengths,
  bib_gourmand      = Restaurants %>% html_nodes(css='.poi-item-stars') %>%
    as.character %>% str_extract_all('="bib-gourmand"') %>%
    lengths %>% as.logical,
  assiette_michelin = Restaurants %>% html_nodes(css='.poi-item-stars') %>%
    as.character %>% str_extract_all('="assiette"') %>%
    lengths %>% as.logical
)

# guide year is only 2016...
# Restaurants %>% html_nodes(css='.poi-item-stars') %>% html_text %>%
#  str_extract('[0123456789]{4}') %>% table

# SCRAPING MORE INFORMATION ----------------------------------------------------

n <- nrow(RESTAURANTS)
Restaurants <- vector(mode='list', length=n)

r <- 1
r <- 6510
r <- 9633
while(r <= nrow(RESTAURANTS)){
  Sys.sleep(sleep <- runif(1, min = 0, max = 1))
  cat(
    'Slept', round(sleep, 2), 'seconds.',
    'Treating restaurant', r, 'of', n, ':', RESTAURANTS$name[r], '.', fill=TRUE
  )
  Restaurants[[r]] <- read_html(RESTAURANTS$url[r]) %>% html_nodes('body')
  r <- r+1
}

save(Restaurants, file=paste0(Sys.Date(),'michelin-detailed-restaurants.RData'))

Restaurants2 <- do.call(c, Restaurants)
class(Restaurants2) <- 'xml_nodeset'

# FORMATTING -------------------------------------------------------------------

# cuisine type
RESTAURANTS$cuisine <- Restaurants2 %>%
  html_nodes(css='.datasheet-cooking-type') %>%
  html_text(trim=TRUE)

# citation
RESTAURANTS$citation <- Restaurants2 %>%
  html_nodes(css='.datasheet') %>% as.character %>%
  str_extract_all('<blockquote>[\\s\\S]*</blockquote>') %>%
  laply(function(v) if(length(v)==0) NA else v) %>%
  str_sub(17,-19)

# standard
RESTAURANTS$standard_code <- Restaurants2 %>%
  html_nodes(css='.datasheet-quotation') %>% as.character %>%
  str_extract('standing-[0123456789]{2}') %>% str_sub(10,-1) %>% as.factor
RESTAURANTS$standard <- RESTAURANTS$standard_code %>% revalue(replace=c(
  `12`='simple',
  `13`='good',
  `14`='very good',
  `15`='excellent',
  `16`='exceptionnal',
  `17`='simple',
  `18`='good',
  `19`='very good',
  `20`='excellent',
  `21`='exceptionnal'
))
RESTAURANTS$best_addresses <- RESTAURANTS$standard_code %in% 17:21

# twenty_or_less
RESTAURANTS$twenty_or_less <- Restaurants2 %>%
  html_nodes(css='.datasheet-quotation') %>% as.character %>%
  str_detect('good-value-menu')

# address
RESTAURANTS$address <- Restaurants2 %>%
  html_nodes(css=paste(
    '.datasheet',
    '.datasheet-item:not(.datasheet-name):not(.datasheet-description-container)'
  )) %>% html_text

# phone
RESTAURANTS$phone <- Restaurants2 %>%
  html_nodes(css='.datasheet .datasheet-more-info:last-child') %>% as.character %>%
  str_extract_all('href="tel:.*?"') %>% # lengths %>% table
  laply(function(v) if(length(v)==0) NA else v) %>%
  str_sub(11,-2)

# mail
RESTAURANTS$mail <- Restaurants2 %>%
  html_nodes(css='.datasheet .datasheet-more-info:last-child') %>% as.character %>%
  str_extract_all('href="mailto:.*?"') %>% # lengths %>% table
  laply(function(v) if(length(v)==0) NA else v) %>%
  str_sub(14,-2)

# website
RESTAURANTS$website <- Restaurants2 %>%
  html_nodes(css='.datasheet .datasheet-more-info:last-child') %>% as.character %>%
  str_extract_all('href="http://.*?"') %>%
  laply(function(v) if(length(v)==0) NA else v) %>%
  str_sub(7,-2)

# other information

# reading
RESTAURANTS$good_to_know <- Restaurants %>%
  lapply(html_nodes, xpath="//p[text()='Good to know']/../ul/li/text()") %>%
  lapply(as.character) %>%
  laply(function(v) if(length(v)==0) NA else v)
RESTAURANTS$additional_information <- Restaurants %>%
  lapply(html_nodes, xpath="//p[normalize-space(text())='Additional information']/../ul/li/text()") %>%
  lapply(as.character)

# extracting variables 1
RESTAURANTS <- rbind(
  RESTAURANTS %>%
  unnest(additional_information) %>% 
  mutate(place_holder=TRUE) %>%
  spread(additional_information, place_holder, fill=FALSE),
  RESTAURANTS %>%
  filter(lengths(additional_information)==0) %>%
  select(-additional_information),
  fill=TRUE
)

# extracting variables 2
NA_to_F <- function(vect){vect[is.na(vect)]<- FALSE;vect}
RESTAURANTS$dinner_only <- NA_to_F(str_detect(RESTAURANTS$good_to_know, 'dinner only'))
RESTAURANTS$booking     <- ifelse(
  NA_to_F(str_detect(RESTAURANTS$good_to_know, 'booking advisable')),
  yes='advisable',
  no=ifelse(NA_to_F(str_detect(RESTAURANTS$good_to_know, 'booking essential')),
    yes='essential',
    no ='not required'
  )
)

# coordinates
RESTAURANTS <- Restaurants2 %>%
  html_nodes('div.poi_view') %>%
  xml_attr('data-fetch_summary') %>%
  lapply(function(item) fromJSON(item)$restaurants$id %>% str_match(
    '^(-?[0-9]+\\.[0-9]+)\\|(-?[0-9]+\\.[0-9]+)'
  ) %>% `colnames<-`(c('match','lat','lon')) %>% as.data.table) %>%
  rbind_all %>%
  select(-match) %>%
  mutate_each('as.numeric') %>%
  cbind(RESTAURANTS)

save(RESTAURANTS, file=paste0(Sys.Date(),'-michelin-restaurants.RData'))
write.csv(RESTAURANTS, file=paste0(Sys.Date(),'-michelin-restaurants.csv'))
save(RESTAURANTS, file=paste0(Sys.Date(),'-michelin-restaurants2.RData'))