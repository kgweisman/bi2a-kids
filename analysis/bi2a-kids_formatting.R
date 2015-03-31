# --- PRELIMINARIES -----------------------------------------------------------

# libraries
library(dplyr)
library(tidyr)
library(ggplot2)
library(lme4)
library(lubridate)
library(scales)

# clear environment
rm(list=ls())

# --- READING IN DATA OBJECTS -------------------------------------------------

# set working directory for india
setwd("/Users/kweisman/Documents/Research (Stanford)/Projects/BI2A/bi2a-kids/data/")

# read in all files and stitch together: pilot
files_pilot <- dir("individual-sessions_pilot/")

d_pilot_raw <- data.frame()

for(i in 1:length(files_pilot)) {
  # gather files
  f = files_pilot[i]
  d_temp = read.csv(paste0("./individual-sessions_pilot/", files_pilot[i]))
  d_pilot_raw = bind_rows(d_pilot_raw, d_temp)
}

glimpse(d_pilot_raw)

# read in all files and stitch together: run01
files_run01 <- dir("individual-sessions_run01/")

d_run01_raw <- data.frame()

for(i in 1:length(files_run01)) {
  # gather files
  f = files_run01[i]
  d_temp = read.csv(paste0("./individual-sessions_run01/", files_run01[i]))
  d_run01_raw = bind_rows(d_run01_raw, d_temp)
}

glimpse(d_run01_raw)

# join pilot and run01 data
# rescale responses for pilot data to 4-point (instead of 6-point)
d_pilot_raw = d_pilot_raw %>%
  mutate(responseCoded = rescale(responseCoded, to = c(-1.5, 1.5)))

d_raw = full_join(d_pilot_raw, d_run01_raw)
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
         gender = ifelse(tolower(substr(gender, 1, 1)) == "m", "male",
                         ifelse(tolower(substr(gender, 1, 1)) == "f", "female", 
                                NA)),
         englishExposure = factor(englishExposure)) %>%
  select(-dateOfBirth, -dateOfTest)

# --- WRITING ANONYMIZED CSV --------------------------------------------------

# write to de-identified csv file
write.csv(d_tidy, "./pilot&run1_data_anonymized.csv")

d = read.csv("./pilot&run1_data_anonymized.csv")[-1] # get rid of column of obs numbers

