# --- PRELIMINARIES -----------------------------------------------------------

# libraries
library(dplyr)
library(tidyr)
library(ggplot2)
library(lme4)
library(lubridate)

# clear environment
rm(list=ls())

# read in data: character means
d = read.csv("./pilot_data_anonymized.csv", fileEncoding = "latin1")[-1] # get rid of column of obs numbers

# prepare data for analysis
d1 = d %>%
  # filter out kids who are < 4 years old
  filter(age >= 4) %>%
  # add binary yes/no response
  mutate(responseBin = ifelse(grepl("no", tolower(response)) == TRUE, 0,
                              ifelse(grepl("yes", tolower(response)) == TRUE, 1,
                                     NA)))

glimpse(d1)

# read in us and indian adult animal ratings
rat_us = read.csv("/Users/kweisman/Documents/Research (Stanford)/Projects/BI2A/bi2a-adults/data/animal_ratings_us_adults.csv", fileEncoding = "latin1")[-1]

rat_india = read.csv("/Users/kweisman/Documents/Research (Stanford)/Projects/BI2A/bi2a-adults/data/animal_ratings_india_adults.csv", fileEncoding = "latin1")[-1]

# --- MEAN RATINGS ------------------------------------------------------------

# summarize by swatch and condition
swatch_summary = d1 %>%
  filter(phase == "study") %>%
  group_by(swatch) %>%
  summarise(childMean = mean(responseBin, na.rm = T),
            childSd = sd(responseBin, na.rm = T),
            childN = length(responseBin))

# add mean child ratings to data
d2 = swatch_summary %>%
  select(swatch, childMean) %>%
  full_join(d1) %>%
  filter(phase != "practice")

glimpse(d2)

# add mean us and indian adult animal ratings to data
d3 = d2 %>%
  full_join(rat_us) %>%
  full_join(rat_india) %>%
  rename(usMean = animal_rating_us,
         indiaMean = animal_rating_ind)

glimpse(d3)

# --- PLOTS -------------------------------------------------------------------

# # look at all ratings
# # ... sorted by child ratings
# ratings1 = d1 %>%
#   ggplot(aes(x = reorder(swatch, animal_rating_us), y = mean, fill = condition)) +
#   facet_wrap(~ condition, ncol = 2) +
#   geom_bar(stat = "identity", position = "identity", width = 0.5) +
#   #   geom_errorbar(aes(ymin = mean - 2*sd/sqrt(n),
#   #                     ymax = mean + 2*sd/sqrt(n),
#   #                     width = 0.1)) +
#   coord_cartesian(ylim = c(-3, 3)) +
#   theme_bw() +
#   theme(text = element_text(size = 20),
#         legend.position = "none",
#         axis.text.x = element_blank()) +
#   #           axis.text.x = element_text(angle = 60,
#   #                                      hjust = 1)) +
#   scale_fill_brewer(palette = "Set2") +
#   labs(title = "Mean ratings by picture (sorted by US animal rating): US\n",
#        x = "Pictures (sorted by US animal rating)")
# ratings_us
