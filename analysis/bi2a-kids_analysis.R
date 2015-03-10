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

# read in us and indian adult animal ratings
rat_us = read.csv("/Users/kweisman/Documents/Research (Stanford)/Projects/BI2A/bi2a-adults/data/animal_ratings_us_adults.csv", fileEncoding = "latin1")[-1]

rat_india = read.csv("/Users/kweisman/Documents/Research (Stanford)/Projects/BI2A/bi2a-adults/data/animal_ratings_india_adults.csv", fileEncoding = "latin1")[-1]

# --- MEAN RATINGS ------------------------------------------------------------

# -------------> BINARY ANIMAL RESPONSES --------------------------------------

# summarize by swatch and condition
swatch_summary_binary = d1 %>%
  filter(phase == "study") %>%
  group_by(swatch) %>%
  summarise(childMean = mean(responseBin, na.rm = T),
            childSd = sd(responseBin, na.rm = T),
            childN = length(responseBin))

# add mean child ratings, us and indian adult ratings to trial-by-trial data
d2_binary = swatch_summary_binary %>%
  select(swatch, childMean) %>%
  full_join(d1) %>%
  full_join(rat_us) %>%
  full_join(rat_india) %>%
  rename(usMean = animal_rating_us,
         indiaMean = animal_rating_ind) %>%
  mutate(swatch = factor(swatch)) %>%
  filter(phase != "practice")

test_binary = d2_binary %>% filter(phase == "study")
bonus_binary = d2_binary %>% filter(phase == "bonus")

# add mean us and indian adult animal ratings to swatch_summary_binary
d3_binary = swatch_summary_binary %>%
  full_join(rat_us) %>%
  full_join(rat_india) %>%
  rename(usMean = animal_rating_us,
         indiaMean = animal_rating_ind)

# -------------> SCALED ANIMAL RESPONSES --------------------------------------

# summarize by swatch and condition
swatch_summary_scaled = d1 %>%
  filter(phase == "study") %>%
  filter(responseCoded != "NA") %>%
  group_by(swatch) %>%
  summarise(childMean = mean(responseCoded, na.rm = T),
            childSd = sd(responseCoded, na.rm = T),
            childN = length(responseCoded))

# add mean child ratings, us and indian adult ratings to trial-by-trial data
d2_scaled = swatch_summary_scaled %>%
  select(swatch, childMean) %>%
  left_join(d1) %>%
  left_join(rat_us) %>%
  left_join(rat_india) %>%
  rename(usMean = animal_rating_us,
         indiaMean = animal_rating_ind) %>%
  mutate(swatch = factor(swatch)) %>%
  filter(phase != "practice")

test_scaled = d2_scaled %>% filter(phase == "study")
bonus_scaled = d2_scaled %>% filter(phase == "bonus")

# add mean us and indian adult animal ratings to swatch_summary_scaled
d3_scaled = swatch_summary_scaled %>%
  left_join(rat_us) %>%
  left_join(rat_india) %>%
  rename(usMean = animal_rating_us,
         indiaMean = animal_rating_ind)

# --- PLOTS -------------------------------------------------------------------

# -------------> BINARY ANIMAL RESPONSES --------------------------------------

# plot, sorted by child ratings
ratings1_binary = d3_binary %>%
  ggplot(aes(x = reorder(swatch, childMean), y = childMean)) +
  geom_bar(stat = "identity", position = "identity", width = 0.5) +
  geom_errorbar(aes(ymin = childMean - 2*childSd/sqrt(childN),
                    ymax = childMean + 2*childSd/sqrt(childN),
                    width = 0.1)) +
  theme_bw() +
  coord_cartesian(ylim = c(0,1)) +
  theme(text = element_text(size = 20),
        legend.position = "none",
        axis.text.x = element_text(angle = 60,
                                   hjust = 1)) +
  labs(title = "Mean binary responses by picture: Children\n",
       x = "Pictures (sorted by mean child response)")
ratings1_binary

# plot, sorted by US adult ratings
ratings2_binary = d3_binary %>%
  ggplot(aes(x = reorder(swatch, usMean), y = childMean)) +
  geom_bar(stat = "identity", position = "identity", width = 0.5) +
  geom_errorbar(aes(ymin = childMean - 2*childSd/sqrt(childN),
                    ymax = childMean + 2*childSd/sqrt(childN),
                    width = 0.1)) +
  theme_bw() +
  coord_cartesian(ylim = c(0,1)) +
  theme(text = element_text(size = 20),
        legend.position = "none",
        axis.text.x = element_text(angle = 60,
                                   hjust = 1)) +
  labs(title = "Mean binary responses by picture: Children\n",
       x = "Pictures (sorted by mean US adult response)")
ratings2_binary

# -------------> SCALED ANIMAL RESPONSES --------------------------------------

# plot, sorted by child ratings
ratings1_scaled = d3_scaled %>%
  ggplot(aes(x = reorder(swatch, childMean), y = childMean)) +
  geom_bar(stat = "identity", position = "identity", width = 0.5) +
  geom_errorbar(aes(ymin = childMean - 2*childSd/sqrt(childN),
                    ymax = childMean + 2*childSd/sqrt(childN),
                    width = 0.1)) +
  theme_bw() +
  coord_cartesian(ylim = c(0,1)) +
  theme(text = element_text(size = 20),
        legend.position = "none",
        axis.text.x = element_text(angle = 60,
                                   hjust = 1)) +
  labs(title = "Mean scaled responses by picture: Children\n",
       x = "Pictures (sorted by mean child response)")
ratings1_scaled

# plot, sorted by US adult ratings
ratings2_scaled = d3_scaled %>%
  ggplot(aes(x = reorder(swatch, usMean), y = childMean)) +
  geom_bar(stat = "identity", position = "identity", width = 0.5) +
  geom_errorbar(aes(ymin = childMean - 2*childSd/sqrt(childN),
                    ymax = childMean + 2*childSd/sqrt(childN),
                    width = 0.1)) +
  theme_bw() +
  coord_cartesian(ylim = c(0,1)) +
  theme(text = element_text(size = 20),
        legend.position = "none",
        axis.text.x = element_text(angle = 60,
                                   hjust = 1)) +
  labs(title = "Mean scaled responses by picture: Children\n",
       x = "Pictures (sorted by mean US adult response)")
ratings2_scaled


