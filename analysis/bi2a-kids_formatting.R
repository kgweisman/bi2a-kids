# --- PRELIMINARIES -----------------------------------------------------------

# libraries
library(dplyr)
library(tidyr)
library(ggplot2)
library(lme4)
library(lubridate)

# clear environment
rm(list=ls())

# --- READING IN DATA OBJECTS -------------------------------------------------

# set working directory for india
setwd("/Users/kweisman/Documents/Research (Stanford)/Projects/BI2A/bi2a-kids/data/")

# read in all files and stitch together
files <- dir("individual_sessions/")

d_raw <- data.frame()

for(i in 1:length(files)) {
  # gather files
  f = files[i]
  d_temp = read.csv(paste0("./individual_sessions/", files[i]))
  d_raw = bind_rows(d_raw, d_temp)
}

glimpse(d_raw)

# clean up variables
d_tidy = d_raw %>%
  mutate(phase = factor(phase),
         question = factor(question),
         swatch = factor(swatch),
         response = factor(response),
         subid = factor(subid),
         dateOfBirth = parse_date_time(dateOfBirth, orders = "mdy"),
         dateOfTest = parse_date_time(dateOfTest, orders = "mdy"),
         ageCalc = as.period(dateOfTest - dateOfBirth, unit = "years"),
         condition = factor(condition),
         gender = factor(gender),
         englishExposure = factor(englishExposure)) %>%
  select(-dateOfBirth, -dateOfTest)

# --- WRITING ANONYMIZED CSV --------------------------------------------------

# write to de-identified csv file
write.csv(d_tidy, "./pilot&day1_data_anonymized.csv")

d = read.csv("./pilot&day1_data_anonymized.csv")[-1] # get rid of column of obs numbers
