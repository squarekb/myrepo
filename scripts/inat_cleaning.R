library(tidyverse)
library(dplyr)

#import inaturalist data from csv
raw_inat <- read_csv("iNaturalist_data.csv") 

#cleaning up inaturalist data to select rows of interest and to filter for non-obscured and research grade observations, replacing NA is common_name by scientific_name
clean_inat <- raw_inat %>% 
  select(id, observed_on, quality_grade, coordinates_obscured, latitude, longitude, scientific_name, common_name) %>% 
    filter(quality_grade == "research", coordinates_obscured == "FALSE")%>%
    ## BMB: you might want to use !coordinates_obscured as your filter
    ##  here since coordinates_obscured is a *logical* vector (! means "not")
  mutate(common_name=ifelse(is.na(common_name), scientific_name, common_name))

## BMB: probably want to drop the coordinates_obscured column once you've
##  done your filtering

## most observed species in descending order, Monarch Butterfly is the most observed species
order <- clean_inat %>%
  group_by(common_name)%>%
  summarize(count = n())%>%
  arrange(desc(count))
    
##saveRDS function to save a clean version of my data to an rds file and reading it back into R
saveRDS(clean_inat, "inat.rds")
test <- readRDS("inat.rds")
