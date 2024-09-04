# Cleaning and exploration of Huckleberry sleep data
# S. Kolbe
# Updated 2024.09.04

# Set up ----------

library(tidyverse)
library(sf)

options(scipen = 999)

# Load data ----------
huckle <- read.csv("raw_data/data_export_20240904.csv") %>%
  filter(., Type == "Sleep")
