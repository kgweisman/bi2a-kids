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
d = read.csv("./pilot_data_anonymized.csv")[-1] # get rid of column of obs numbers

glimpse(d)

