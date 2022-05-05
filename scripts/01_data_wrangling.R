### 01 - DATA WRANGLING ###

### PACKAGES ###
if(!require(here)) install.packages("here", repos = "http://cran.us.r-project.org")
if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if(!require(write)) install.packages("write", repos = "http://cran.us.r-project.org")

### DATA IMPORT ###

url_vaccines <- "https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/ockovani-orp.csv"
df <- read.csv(url_vaccines, encoding = "UTF-8")
pop_df <- read.csv(here("data_raw", "2021-01-01_region_population.csv"), encoding = "UTF-8")

### WRANGLING ###

# NA → 0 for subsequent computations
df[is.na(df)] <- 0

# drop redundant columns
df <- df %>% select(-c(
  X.U.FEFF.id,
  ockovaci_latka_kod,
  orp_bydliste_nazev,
  orp_bydliste_kod,
  vekova_kategorie,
  ockovaci_latka_nazev,
  prvni_davka,
  druha_davka,
  posilujici_davka
  )) %>% 

# translate and simplify column names
  rename(
    date = datum,
    region_name = kraj_bydliste_nazev,
    region_id = kraj_bydliste_kod,
    finished_vax = dokoncene_ockovani
) %>% 

# Aggregate date into sums by regions
  group_by(region_name, region_id) %>% 
  summarise(finished_vax = sum(finished_vax))

# merge with population data
df <- merge(df, pop_df, by.x = "region_id", by.y = "X.U.FEFF.region_id") %>% 
  mutate(vax_per_pop = finished_vax / pop_total)

# save tidy data (in UTF-8)
readr::write_excel_csv(df, file = here("data_tidy", "cz_covax_regions_tidy.csv"))
