# DPLYR TUTORIAL http://genomicsclass.github.io/book/pages/dplyr_tutorial.html 

# Use this functions:
#1 filter() -> pick observations
#2 arrange() -> reorder rows
#3 select() -> pick columns
#4 mutate() -> add new variables as functions of others
#5 summarise() -> collapse many values to a summary
#6 group by() -> group observations

# Loading libraries ####
library(downloader)
library(dplyr)
# Reading data ####
url <- "https://raw.githubusercontent.com/genomicsclass/dagdata/master/inst/extdata/msleep_ggplot2.csv"
filename <- "msleep_ggplot2.csv"
if (!file.exists(filename)) download(url,filename)
msleep <- read.csv("msleep_ggplot2.csv")

# Select the name column and all columns starting with "sl"
select(msleep, name, starts_with("sl"))

# let's introduce the pipe operator!
msleep %>% 
  select(name, starts_with("sl"))


msleep[,c("name", "sleep_total", "sleep_rem", "sleep_cycle")]
msleep[c("name", "sleep_total", "sleep_rem", "sleep_cycle")] # Same df with base r
# Same df with base r
msleep[ , grepl("sl|name", names(msleep))]


msleep[c("name", "sleep_total")]

# Let's take a look at the average sleep time of the animals according to their eating habits.
# Create a new datafame with two columns: "vore" and "mean_sleep"

vore_sleep <- msleep %>% 
  group_by(vore) %>% 
  summarise(mean_sleep = mean(sleep_total))
vore_sleep

# Build again the same df, but this time we want to exclude animals that sleep less than 2 hours or more than 19
vore_sleep_filter <- msleep %>% 
  filter(sleep_total >= 2, sleep_total <= 19) %>% 
  group_by(vore) %>% 
  summarise(mean_sleep = mean(sleep_total))

msleep %>%
  select(name, sleep_total) %>% 
  filter(sleep_total >= 2 | sleep_total <= 19)

x <- c(1:10)
x[(x>8) | (x<5)]
# yields 1 2 3 4 9 10



# Same df as before, but don't want domesticated animals in our table
msleep$conservation <- as.character(msleep$conservation)
vore_sleep_filter <- msleep %>% 
  filter(sleep_total > 2, sleep_total < 19, !conservation %in% "domesticated")

vore_sleep_filter <- msleep %>% 
  filter(sleep_total > 2, sleep_total < 19, conservation != "domesticated" | is.na(conservation)) %>%
  group_by(vore) %>%
  summarise(mean_sleep = mean(sleep_total))
vore_sleep_filter

# We don't want NAs in vore, and we also don't want domesticated animals
vore_sleep_filter <- msleep %>% 
  filter(sleep_total > 2, sleep_total < 19, !is.na(vore), conservation != "domesticated") %>% # also a good idea: na.omit(vore)
  group_by(vore) %>%
  summarise(mean_sleep = mean(sleep_total))
vore_sleep_filter

# We want to add a column with their brain-to-body mass ratio
vore_sleep_filter_btb <- msleep %>% 
  filter(sleep_total > 2, sleep_total < 19, !is.na(vore), conservation != "domesticated") %>% 
  group_by(vore) %>% 
  mutate(brain_to_body = brainwt / bodywt) %>% 
  summarise(mean_sleep = mean(sleep_total), mean_btb = round(mean(brain_to_body, na.rm = TRUE), 3))
vore_sleep_filter_btb

# We want to add a column with the count for each row
vore_sleep_filter_btb <- msleep %>% 
  filter(sleep_total > 2, sleep_total < 19, !is.na(vore), conservation != "domesticated") %>% 
  group_by(vore) %>% 
  mutate(brain_to_body = brainwt / bodywt) %>% 
  summarise(mean_sleep = mean(sleep_total), mean_btb = round(mean(brain_to_body, na.rm = TRUE), 3), count = n())
vore_sleep_filter_btb

# Order your df by the count column in descending order
vore_sleep_filter_btb <- msleep %>% 
  filter(sleep_total > 2, sleep_total < 19, !is.na(vore), conservation != "domesticated") %>% 
  group_by(vore) %>% 
  mutate(brain_to_body = brainwt / bodywt) %>% 
  summarise(mean_sleep = mean(sleep_total), mean_btb = round(mean(brain_to_body, na.rm = TRUE), 3), count = n()) %>% 
  arrange(desc(count))
vore_sleep_filter_btb
