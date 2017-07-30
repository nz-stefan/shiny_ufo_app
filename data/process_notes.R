###########################################################
# Process the text component of the UFO data set
# 
# Author: Stefan Schliebs
# Created: 2017-07-30
###########################################################


library(tidyverse)
library(tidytext)
library(SnowballC)


# Load data ---------------------------------------------------------------

# load raw data and turn it into tidy data frame
d.ufo <- read_rds("app/data/ufo-cleaned.rds") %>% 
  select(date, year, month, day_of_week, hour_of_day, shape, comments) %>% 
  unnest_tokens(word, comments)


# Clean up comments -------------------------------------------------------

d.ufo_tidytext <- d.ufo %>% 
  anti_join(stop_words, by = "word") %>%    # remove stop words
  filter(
    hunspell_check(word),                   # remove all mispelled words
    !str_detect(word, "[0-9]+"),            # remove words containing numbers 
    !str_detect(word, ".*\\..*")            # remove words containing punctuation
  ) %>% 
  left_join(get_sentiments("nrc"), by = "word") %>%  # add sentiment
  mutate(word = wordStem(word)) %>%         # apply stemming
  spread(sentiment)


d.ufo_tidytext %>% 
  count(word, sort = T)

d.ufo_tidytext %>% 
  count(sentiment, sort = T)

library(d3wordcloud)


d.cloud <- d.ufo_tidytext %>% 
  filter(sentiment == "sadness") %>% 
  count(word, sort = T) %>% 
  head(100)

d3wordcloud(d.cloud$word, d.cloud$n)


