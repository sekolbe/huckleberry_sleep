# Cleaning and exploration of Huckleberry sleep data
# S. Kolbe
# Updated 2024.09.04

# Set up ----------

library(tidyverse)
library(janitor)

options(scipen = 999)

# Load data ----------
huckle <- read_csv("raw_data/data_export_20240904.csv", na = c("yellow", "")) 

# Prep data ----------
huckle_clean <- huckle |>
  clean_names() |>
  filter(type == "Sleep") |>
  mutate(starttime = hour(start) + minute(start)/60,
         starttime2 = hms::hms(start))

ggplot(huckle_clean, aes(x = starttime, y = duration)) +
  geom_point()