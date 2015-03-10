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
                                     NA))) %>%
  # make sensible "other" questions
  mutate(question = ifelse(grepl("animal", tolower(question)) == TRUE, "animal",
                           ifelse(grepl("can think", tolower(question)) == TRUE, "think",
                                  ifelse(grepl("feelings", tolower(question)) == TRUE, "feelings",
                                         ifelse(grepl("happy", tolower(question)) == TRUE, "happy",
                                                ifelse(grepl("sad", tolower(question)) == TRUE, "sad",
                                                       ifelse(grepl("hungry", tolower(question)) == TRUE, "hungry",
                                                              ifelse(grepl("pain", tolower(question)) == TRUE, "pain",
                                                                     ifelse(grepl("hurt", tolower(question)) == TRUE, "hurt",
                                                                            ifelse(grepl("sense", tolower(question)) == TRUE, "sense",
                                                                                   ifelse(grepl("can see", tolower(question)) == TRUE, "see",
                                                                                          "other"))))))))))) %>%
  mutate(question = factor(question))

# read in us and indian adult animal ratings
rat_us = read.csv("/Users/kweisman/Documents/Research (Stanford)/Projects/BI2A/bi2a-adults/data/animal_ratings_us_adults.csv", fileEncoding = "latin1")[-1]

rat_india = read.csv("/Users/kweisman/Documents/Research (Stanford)/Projects/BI2A/bi2a-adults/data/animal_ratings_india_adults.csv", fileEncoding = "latin1")[-1]

# --- MEAN RATINGS ------------------------------------------------------------

# -------------> ANIMAL: BINARY RESPONSES -------------------------------------

# summarize by swatch and condition
swatch_summary_animal_binary = d1 %>%
  filter(phase == "study") %>%
  group_by(swatch) %>%
  summarise(childMean = mean(responseBin, na.rm = T),
            childSd = sd(responseBin, na.rm = T),
            childN = length(responseBin))

# add mean child ratings, us and indian adult ratings to trial-by-trial data
d2_animal_binary = swatch_summary_animal_binary %>%
  select(swatch, childMean) %>%
  full_join(d1) %>%
  full_join(rat_us) %>%
  full_join(rat_india) %>%
  rename(usMean = animal_rating_us,
         indiaMean = animal_rating_ind) %>%
  mutate(swatch = factor(swatch)) %>%
  filter(phase != "practice")

test_animal_binary = d2_animal_binary %>% filter(phase == "study")
bonus_animal_binary = d2_animal_binary %>% filter(phase == "bonus")

# add mean us and indian adult animal ratings to swatch_summary_animal_binary
d3_animal_binary = swatch_summary_animal_binary %>%
  full_join(rat_us) %>%
  full_join(rat_india) %>%
  rename(usMean = animal_rating_us,
         indiaMean = animal_rating_ind)

# -------------> ANIMAL: SCALED RESPONSES -------------------------------------

# summarize by swatch and condition
swatch_summary_animal_scaled = d1 %>%
  filter(phase == "study") %>%
  filter(responseCoded != "NA") %>%
  group_by(swatch) %>%
  summarise(childMean = mean(responseCoded, na.rm = T),
            childSd = sd(responseCoded, na.rm = T),
            childN = length(responseCoded))

# add mean child ratings, us and indian adult ratings to trial-by-trial data
d2_animal_scaled = swatch_summary_animal_scaled %>%
  select(swatch, childMean) %>%
  left_join(d1) %>%
  left_join(rat_us) %>%
  left_join(rat_india) %>%
  rename(usMean = animal_rating_us,
         indiaMean = animal_rating_ind) %>%
  mutate(swatch = factor(swatch)) %>%
  filter(phase != "practice")

test_animal_scaled = d2_animal_scaled %>% filter(phase == "study")
bonus_animal_scaled = d2_animal_scaled %>% filter(phase == "bonus")

# add mean us and indian adult animal ratings to swatch_summary_animal_scaled
d3_animal_scaled = swatch_summary_animal_scaled %>%
  left_join(rat_us) %>%
  left_join(rat_india) %>%
  rename(usMean = animal_rating_us,
         indiaMean = animal_rating_ind)

# -------------> OTHER: BINARY RESPONSES --------------------------------------

# summarize by swatch and condition
swatch_summary_other_binary = d1 %>%
  filter(phase == "bonus") %>%
  group_by(question, swatch) %>%
  summarise(childMean = mean(responseBin, na.rm = T),
            childSd = sd(responseBin, na.rm = T),
            childN = length(responseBin))

# add mean child ratings, us and indian adult ratings to trial-by-trial data
d2_other_binary = swatch_summary_other_binary %>%
  select(question, swatch, childMean) %>%
  spread(question, childMean) %>%
  full_join(d1) %>%
  full_join(rat_us) %>%
  full_join(rat_india) %>%
  rename(usMean = animal_rating_us,
         indiaMean = animal_rating_ind) %>%
  mutate(swatch = factor(swatch)) %>%
  filter(phase != "practice")

test_other_binary = d2_other_binary %>% filter(phase == "study")
bonus_other_binary = d2_other_binary %>% filter(phase == "bonus")

# add mean us and indian adult animal ratings to swatch_summary_other_binary
d3_other_binary = swatch_summary_other_binary %>%
  full_join(rat_us) %>%
  full_join(rat_india) %>%
  rename(usMean = animal_rating_us,
         indiaMean = animal_rating_ind)

# -------------> OTHER: SCALED RESPONSES --------------------------------------

# summarize by swatch and condition
swatch_summary_other_scaled = d1 %>%
  filter(phase == "study") %>%
  filter(responseCoded != "NA") %>%
  group_by(question, swatch) %>%
  summarise(childMean = mean(responseCoded, na.rm = T),
            childSd = sd(responseCoded, na.rm = T),
            childN = length(responseCoded))

# add mean child ratings, us and indian adult ratings to trial-by-trial data
d2_other_scaled = swatch_summary_other_scaled %>%
  select(question, swatch, childMean) %>%
  spread(question, childMean) %>%
  left_join(d1) %>%
  left_join(rat_us) %>%
  left_join(rat_india) %>%
  rename(usMean = animal_rating_us,
         indiaMean = animal_rating_ind) %>%
  mutate(swatch = factor(swatch)) %>%
  filter(phase != "practice")

test_other_scaled = d2_other_scaled %>% filter(phase == "study")
bonus_other_scaled = d2_other_scaled %>% filter(phase == "bonus")

# add mean us and indian adult animal ratings to swatch_summary_other_scaled
d3_other_scaled = swatch_summary_other_scaled %>%
  left_join(rat_us) %>%
  left_join(rat_india) %>%
  rename(usMean = animal_rating_us,
         indiaMean = animal_rating_ind)

# --- PLOTS -------------------------------------------------------------------

# -------------> ANIMAL: BINARY RESPONSES -------------------------------------

# plot, sorted by child ratings
ratings1_animal_binary = d3_animal_binary %>%
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
  labs(title = "Mean binary responses to ANIMAL, by picture: Children\n",
       x = "Pictures (sorted by mean child response)")
ratings1_animal_binary

# plot, sorted by US adult ratings
ratings2_animal_binary = d3_animal_binary %>%
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
  labs(title = "Mean binary responses to ANIMAL, by picture: Children\n",
       x = "Pictures (sorted by mean US adult response)")
ratings2_animal_binary

# -------------> ANIMAL: SCALED RESPONSES -------------------------------------

# plot, sorted by child ratings
ratings1_animal_scaled = d3_animal_scaled %>%
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
  labs(title = "Mean scaled responses to ANIMAL, by picture: Children\n",
       x = "Pictures (sorted by mean child response)")
ratings1_animal_scaled

# plot, sorted by US adult ratings
ratings2_animal_scaled = d3_animal_scaled %>%
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
  labs(title = "Mean scaled responses to ANIMAL, by picture: Children\n",
       x = "Pictures (sorted by mean US adult response)")
ratings2_animal_scaled

# -------------> OTHER: BINARY RESPONSES -------------------------------------

# NOTE: might need to add other questions as they get more populated

# plot, sorted by US adult ANIMAL ratings
# ... feelings
ratings2_feelings_binary = d3_other_binary %>%
  filter(question == "feelings") %>%
  filter(childMean != "NaN") %>%
  ggplot(aes(x = reorder(swatch, usMean), y = childMean)) +
  #   facet_wrap(~ question) +
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
  labs(title = "Mean binary responses to FEELINGS, by picture: Children\n",
       x = "Pictures (sorted by mean US adult response to animal)")
ratings2_feelings_binary

# ... happy
ratings2_happy_binary = d3_other_binary %>%
  filter(question == "happy") %>%
  filter(childMean != "NaN") %>%
  ggplot(aes(x = reorder(swatch, usMean), y = childMean)) +
  #   facet_wrap(~ question) +
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
  labs(title = "Mean binary responses to HAPPY, by picture: Children\n",
       x = "Pictures (sorted by mean US adult response to animal)")
ratings2_happy_binary

# ... think
ratings2_think_binary = d3_other_binary %>%
  filter(question == "think") %>%
  filter(childMean != "NaN") %>%
  ggplot(aes(x = reorder(swatch, usMean), y = childMean)) +
  #   facet_wrap(~ question) +
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
  labs(title = "Mean binary responses to THINK, by picture: Children\n",
       x = "Pictures (sorted by mean US adult response to animal)")
ratings2_think_binary

# ... sense
ratings2_sense_binary = d3_other_binary %>%
  filter(question == "sense") %>%
  filter(childMean != "NaN") %>%
  ggplot(aes(x = reorder(swatch, usMean), y = childMean)) +
  #   facet_wrap(~ question) +
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
  labs(title = "Mean binary responses to SENSE, by picture: Children\n",
       x = "Pictures (sorted by mean US adult response to animal)")
ratings2_sense_binary

# ... hungry
ratings2_hungry_binary = d3_other_binary %>%
  filter(question == "hungry") %>%
  filter(childMean != "NaN") %>%
  ggplot(aes(x = reorder(swatch, usMean), y = childMean)) +
  #   facet_wrap(~ question) +
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
  labs(title = "Mean binary responses to HUNGRY, by picture: Children\n",
       x = "Pictures (sorted by mean US adult response to animal)")
ratings2_hungry_binary

# ... pain
ratings2_pain_binary = d3_other_binary %>%
  filter(question == "pain") %>%
  filter(childMean != "NaN") %>%
  ggplot(aes(x = reorder(swatch, usMean), y = childMean)) +
  #   facet_wrap(~ question) +
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
  labs(title = "Mean binary responses to PAIN, by picture: Children\n",
       x = "Pictures (sorted by mean US adult response to animal)")
ratings2_pain_binary

# -------------> OTHER: SCALED RESPONSES -------------------------------------

# NOTE: not currently populated

# # plot, sorted by US adult ANIMAL ratings
# # ... feelings
# ratings2_feelings_scaled = d3_other_scaled %>%
#   filter(question == "feelings") %>%
#   filter(childMean != "NaN") %>%
#   ggplot(aes(x = reorder(swatch, usMean), y = childMean)) +
#   #   facet_wrap(~ question) +
#   geom_bar(stat = "identity", position = "identity", width = 0.5) +
#   geom_errorbar(aes(ymin = childMean - 2*childSd/sqrt(childN),
#                     ymax = childMean + 2*childSd/sqrt(childN),
#                     width = 0.1)) +
#   theme_bw() +
#   coord_cartesian(ylim = c(0,1)) +
#   theme(text = element_text(size = 20),
#         legend.position = "none",
#         axis.text.x = element_text(angle = 60,
#                                    hjust = 1)) +
#   labs(title = "Mean scaled responses to FEELINGS, by picture: Children\n",
#        x = "Pictures (sorted by mean US adult response to animal)")
# ratings2_feelings_scaled
# 
# # ... happy
# ratings2_happy_scaled = d3_other_scaled %>%
#   filter(question == "happy") %>%
#   filter(childMean != "NaN") %>%
#   ggplot(aes(x = reorder(swatch, usMean), y = childMean)) +
#   #   facet_wrap(~ question) +
#   geom_bar(stat = "identity", position = "identity", width = 0.5) +
#   geom_errorbar(aes(ymin = childMean - 2*childSd/sqrt(childN),
#                     ymax = childMean + 2*childSd/sqrt(childN),
#                     width = 0.1)) +
#   theme_bw() +
#   coord_cartesian(ylim = c(0,1)) +
#   theme(text = element_text(size = 20),
#         legend.position = "none",
#         axis.text.x = element_text(angle = 60,
#                                    hjust = 1)) +
#   labs(title = "Mean scaled responses to HAPPY, by picture: Children\n",
#        x = "Pictures (sorted by mean US adult response to animal)")
# ratings2_happy_scaled
# 
# # ... think
# ratings2_think_scaled = d3_other_scaled %>%
#   filter(question == "think") %>%
#   filter(childMean != "NaN") %>%
#   ggplot(aes(x = reorder(swatch, usMean), y = childMean)) +
#   #   facet_wrap(~ question) +
#   geom_bar(stat = "identity", position = "identity", width = 0.5) +
#   geom_errorbar(aes(ymin = childMean - 2*childSd/sqrt(childN),
#                     ymax = childMean + 2*childSd/sqrt(childN),
#                     width = 0.1)) +
#   theme_bw() +
#   coord_cartesian(ylim = c(0,1)) +
#   theme(text = element_text(size = 20),
#         legend.position = "none",
#         axis.text.x = element_text(angle = 60,
#                                    hjust = 1)) +
#   labs(title = "Mean scaled responses to THINK, by picture: Children\n",
#        x = "Pictures (sorted by mean US adult response to animal)")
# ratings2_think_scaled
# 
# # ... sense
# ratings2_sense_scaled = d3_other_scaled %>%
#   filter(question == "sense") %>%
#   filter(childMean != "NaN") %>%
#   ggplot(aes(x = reorder(swatch, usMean), y = childMean)) +
#   #   facet_wrap(~ question) +
#   geom_bar(stat = "identity", position = "identity", width = 0.5) +
#   geom_errorbar(aes(ymin = childMean - 2*childSd/sqrt(childN),
#                     ymax = childMean + 2*childSd/sqrt(childN),
#                     width = 0.1)) +
#   theme_bw() +
#   coord_cartesian(ylim = c(0,1)) +
#   theme(text = element_text(size = 20),
#         legend.position = "none",
#         axis.text.x = element_text(angle = 60,
#                                    hjust = 1)) +
#   labs(title = "Mean scaled responses to SENSE, by picture: Children\n",
#        x = "Pictures (sorted by mean US adult response to animal)")
# ratings2_sense_scaled
# 
# # ... hungry
# ratings2_hungry_scaled = d3_other_scaled %>%
#   filter(question == "hungry") %>%
#   filter(childMean != "NaN") %>%
#   ggplot(aes(x = reorder(swatch, usMean), y = childMean)) +
#   #   facet_wrap(~ question) +
#   geom_bar(stat = "identity", position = "identity", width = 0.5) +
#   geom_errorbar(aes(ymin = childMean - 2*childSd/sqrt(childN),
#                     ymax = childMean + 2*childSd/sqrt(childN),
#                     width = 0.1)) +
#   theme_bw() +
#   coord_cartesian(ylim = c(0,1)) +
#   theme(text = element_text(size = 20),
#         legend.position = "none",
#         axis.text.x = element_text(angle = 60,
#                                    hjust = 1)) +
#   labs(title = "Mean scaled responses to HUNGRY, by picture: Children\n",
#        x = "Pictures (sorted by mean US adult response to animal)")
# ratings2_hungry_scaled
# 
# # ... pain
# ratings2_pain_scaled = d3_other_scaled %>%
#   filter(question == "pain") %>%
#   filter(childMean != "NaN") %>%
#   ggplot(aes(x = reorder(swatch, usMean), y = childMean)) +
#   #   facet_wrap(~ question) +
#   geom_bar(stat = "identity", position = "identity", width = 0.5) +
#   geom_errorbar(aes(ymin = childMean - 2*childSd/sqrt(childN),
#                     ymax = childMean + 2*childSd/sqrt(childN),
#                     width = 0.1)) +
#   theme_bw() +
#   coord_cartesian(ylim = c(0,1)) +
#   theme(text = element_text(size = 20),
#         legend.position = "none",
#         axis.text.x = element_text(angle = 60,
#                                    hjust = 1)) +
#   labs(title = "Mean scaled responses to PAIN, by picture: Children\n",
#        x = "Pictures (sorted by mean US adult response to animal)")
# ratings2_pain_scaled

