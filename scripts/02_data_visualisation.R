#### SETUP ####

### PACKAGES ### --REVIEW PACKAGE MANAGEMENT
if(!require(here)) install.packages("here", repos = "http://cran.us.r-project.org")
if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if(!require(ggplot2)) install.packages("ggplot2", repos = "http://cran.us.r-project.org")
if(!require(RCzechia)) install.packages("RCzechia", repos = "http://cran.us.r-project.org")
if(!require(sf)) install.packages("sf", repos = "http://cran.us.r-project.org")

### DATA ###
# load df
df <- read.csv(here("data_tidy","cz_covax_regions_tidy.csv"),
               encoding = "UTF-8")

# load geo-spatial data
repub <- republika()

regions <- kraje(resolution = "high") %>% 
  select(-c(KOD_KRAJ, NAZ_CZNUTS3))

df <- merge(df, regions, by.x = "X.U.FEFF.region_id", by.y = "KOD_CZNUTS3")

# df → sf object for ggplot2
df <- st_as_sf(df)

#### GGPLOT ####
# load data
ggmap <- ggplot(data = df) +
  
  # read regional geographic data
  geom_sf(aes(fill = vax_per_pop), colour = "black", lwd = 0.3) +
  
  # read geographic data of the country
  geom_sf(data = repub, color = "black", lwd = 0.6, fill = NA) +
  
  # set colour (suitable for visually impaired)
  scale_fill_viridis_c(labels = scales::comma, direction = -1) +
  
  # label plot elements
  labs(
    x = "Latitude",
    y = "Longitude",
    title = "Covid-19-immunised to total region population ratio in the Czech Republic",
    subtitle = "Ratio of fully immunised population (i.e., having received 2 doses of an approved Covid-19 vaccine) to total population per region",
    caption = "Source: IHIS CR & CZSO
    Note: Cases of immunisation of foregin nationals and individuals of unknown region residence excluded",
    fill = "Immunised-to-total region \nresident ratio") +
  
  # suitable theme (reading coords)
  theme_bw() +
  
  # sub/title alignment
  theme(plot.title = element_text(hjust = 0),
        plot.subtitle = element_text(hjust = 0))

# view
ggmap

# save the plot
ggsave(here("figs", "cz_covax_plot.png"), scale = 2, width = 1920, height = 1080, units ="px", dpi = "retina", bg = NULL)
ggsave(here("figs", "cz_covax_plot.svg"), scale = 2, width = 1920, height = 1080, units ="px", dpi = "retina", bg = NULL)
ggsave(here("figs", "cz_covax_plot.pdf"), scale = 2, width = 1920, height = 1080, units ="px", dpi = "retina", bg = NULL)