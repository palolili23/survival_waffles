library(ggwaffle)
library(tidyverse)
library(kableExtra)
library(ggwaffle)


data <- tibble::tribble(
  ~year, ~total, ~dementia, ~died, ~alive, ~dementia_cum, ~died_cum, ~alive_cum,
  0,    20,        0,    0,    20,            0,        0,        20,
  1,    20,        0,    1,    19,            0,        1,        19,
  2,    19,        1,    0,    18,            1,        1,        18,
  3,    18,        1,    2,    15,            2,        3,        15,
  4,    15,        2,    1,    12,            4,        4,        12,
  5,    12,        0,    2,    10,            4,        6,        10,
  6,    10,        3,    0,     7,            7,        6,         7 )

risk_waffle_plot <- function(data, ...) {
  data %>% 
    ggplot() +
    geom_waffle(
      aes(fill = outcome, values = count),
      color = "white",
      n_rows = 4,
      size = .5,
    ) +
    facet_grid(. ~ year_n, switch = "x") +
    ggthemes::scale_fill_tableau(name=NULL) +
    coord_equal() +
    theme_minimal(base_family = "Roboto Condensed") +
    theme_enhance_waffle() +
    theme(plot.caption = element_text(hjust = 0, face= "italic")) +
    theme(legend.position = 'bottom',
          legend.title = element_blank(),
          plot.caption = element_text(hjust = 0))}


# Real data waffle --------------------------------------------------------

data %>% 
  select(year, total, dementia, died, alive) %>% 
  pivot_longer(
    cols = c(3:5),
    names_to = "outcome",
    values_to = "count") %>% 
  mutate(year_n = paste0("Year ", year, "\n n = ", total),
         outcome = str_to_title(outcome)) %>% 
  risk_waffle_plot() +
  labs(
    title = "How data looks like",
    x = "Year",
    y = "Count")


# Cause-specific hazard ---------------------------------------------------

data %>% 
  select(year, total, dementia) %>% 
  mutate(alive = total - dementia,
         hz = paste0(dementia, "/", total)) %>% 
  pivot_longer(
    cols = -c(1,2,5),
    names_to = "outcome",
    values_to = "count") %>% 
  mutate(year_n = paste0("Year ", year, "\n n = ", total,
                         "\n\n ", hz),
         outcome = str_to_title(outcome)) %>% 
  risk_waffle_plot() +
  labs(
    title = "Cause-specific hazard",
    x = "Year",
    y = "Count",
    caption = "\n\n Conditional probability of not having the event or the competing event at the previous time-point"
  ) 

data %>% 
  select(year, total, dementia) %>% 
  mutate(alive = total - dementia,
         hz = paste0(alive, "/", total)) %>% 
  pivot_longer(
    cols = -c(1,2,5),
    names_to = "outcome",
    values_to = "count") %>% 
  mutate(year_n = paste0("Year ", year, "\n n = ", total,
                         "\n\n ", hz),
         outcome = str_to_title(outcome),
         outcome = fct_rev(outcome)) %>% 
  risk_waffle_plot() +
  labs(
    title = "Kaplan-Meier Method",
    x = "Year",
    y = "Count",
    caption = "\n\n Conditional probability of not having the event per year"
  ) 


# Sub-distribution hazard -------------------------------------------------

data %>% 
  select(year, total, dementia, died, alive, dementia_cum) %>% 
  mutate(alive = 20 - (dementia_cum),
         alive = lag(alive, default = 20),
         alive = alive - dementia,
         total = alive + dementia,
         sdhz = paste0(dementia, "/", total)) %>% 
  select(year, total, sdhz, dementia, alive) %>% 
  pivot_longer(
    cols = -c(1:3),
    names_to = "outcome",
    values_to = "count") %>% 
  mutate(year_n = paste0("Year ", year, "\n n = ", total,
                         "\n\n ", sdhz),
         outcome = ifelse(outcome == "alive", "alive or death", outcome),
         outcome = str_to_title(outcome)
  ) %>% 
  risk_waffle_plot() +
  labs(
    title = "Sub-distribution hazard",
    x = "Year",
    y = "Count",
    caption = "\n\n Conditional of not having the event at the previous time-point")



