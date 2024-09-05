# Cleaning and exploration of Huckleberry sleep data
# S. Kolbe
# Updated 2024.09.04

# Set up ----------

library(tidyverse)
library(janitor)
library(hms)

options(scipen = 999)

# Load data ----------
huckle <- read_csv("raw_data/data_export_20240904.csv", na = c("yellow", "")) 

# Prep data ----------
huckle_clean <- huckle |>
  clean_names() |>
  filter(type == "Sleep") |>
  # limit columns |>
  select(type, start, end, duration) |>
  # limit to 2024 data
  filter(year(start) == 2024) |>
  mutate(starttime = hms::as_hms(start),
         date = as_date(start),
         # Add nap indicator. Sleeps that start between 8am and 4pm are naps.
         nap_ind = ifelse(starttime < hms(hours = 8) | starttime > hms(hours = 16), 0, 1))

# Check nap logic
ggplot(huckle_clean, aes(x = starttime, y = duration, color = factor(nap_ind))) +
  geom_point() + 
  scale_colour_discrete()

naps <- huckle_clean |>
  group_by(date) |>
  summarize(nap_day = max(nap_ind)) |>
  mutate(nap_text = ifelse(nap_day == 1, "Nap day", "Not a nap day"))

huckle_nights <- left_join(huckle_clean, naps, by = "date") |>
  # Focus on night sleep; remove naps
  filter(nap_ind == 0) |>
  # Focus on normal evening bedtimes (between 6pm and 10pm)
  filter(!starttime < hms(hours = 18) & !starttime > hms(hours = 22))

# Visualize data ----------
ggplot(huckle_nights, aes(x = starttime, y = duration, color = nap_text)) +
  geom_point() + 
  geom_smooth(method = "lm") +
  facet_wrap(~nap_text) +
  labs(title = "Sleep start time and duration",
       subtitle = "Disaggregated by presence or absence of nap",
       x = "Sleep start time",
       y = "Sleep duration",
       color = "Nap?") +
  scale_colour_discrete()
ggsave("two-panel.png", width = 12, height = 6)

ggplot(huckle_nights, aes(x = starttime, y = duration, color = nap_text)) +
  geom_point() + 
  geom_smooth(method = "lm") +
  labs(title = "Sleep start time and duration",
       subtitle = "Disaggregated by presence or absence of nap",
       x = "Sleep start time",
       y = "Sleep duration",
       color = "Nap?") +
  scale_colour_discrete()
ggsave("one-panel.png", width = 8, height = 6)
