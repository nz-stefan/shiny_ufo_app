###########################################################
# Process the text component of the UFO data set
# 
# Author: Stefan Schliebs
# Created: 2017-07-30
###########################################################


library(tidyverse)
library(tidytext)
library(SnowballC)
library(hunspell)
library(stringr)


# Load data ---------------------------------------------------------------

# load raw data and turn it into tidy data frame
d.ufo <- read_rds("app/data/ufo-cleaned.rds") %>% 
  select(year, shape, continent, comments)

# add a row ID
d.ufo <- d.ufo %>% 
  mutate(rec_id = row_number()) %>% 
  select(rec_id, everything())


# Clean up comments -------------------------------------------------------

custom_stopwords <- d.ufo_tidytext$shape %>% 
  unique() %>% 
  c("object", "sky", "shape", "white", "bright", "blue", "move") %>% 
  data_frame(word = .)

# turn comments into tidy data
d.ufo_tidytext <- d.ufo %>% 
  unnest_tokens(word, comments) %>%              # split text into word tokens 
  anti_join(stop_words, by = "word") %>%         # remove general stop words
  anti_join(custom_stopwords, by = "word") %>%   # remove custom stop words
  filter(
    hunspell_check(word),                   # remove all mispelled words
    !str_detect(word, "[0-9]+"),            # remove words containing numbers 
    !str_detect(word, ".*\\..*")            # remove words containing punctuation
  ) %>% 
  left_join(get_sentiments("nrc"), by = "word") %>%  # add sentiment
  na.omit()                                 # only retain words with sentiment


# Export to disk ----------------------------------------------------------

write_rds(d.ufo_tidytext, "app/data/ufo-tidytext.rds", compress = "gz")

