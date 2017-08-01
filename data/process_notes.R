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
  c("object", "sky", "shape", "white", "bright", "blue", "move")
          
# turn comments into tidy data
d.ufo_tidytext <- d.ufo %>% 
  unnest_tokens(word, comments) %>% 
  anti_join(stop_words, by = "word") %>%    # remove general stop words
  filter(
    hunspell_check(word),                   # remove all mispelled words
    !str_detect(word, "[0-9]+"),            # remove words containing numbers 
    !str_detect(word, ".*\\..*")            # remove words containing punctuation
  )
  
# create a table with sentiments per record
d.record_sentiment <- d.ufo_tidytext %>% 
  select(rec_id, word) %>% 
  left_join(get_sentiments("nrc"), by = "word") %>%  # add sentiment
  na.omit() %>% 
  count(rec_id, sentiment) %>% 
  select(rec_id, sentiment)

# create a table of words per UFO record and add tf_idf
d.ufo_notes <- d.ufo_tidytext %>% 
  mutate(word = wordStem(word)) %>%         # apply stemming
  count(rec_id, year, shape, continent, word) %>% 
  bind_tf_idf(word, rec_id, n) %>% 
  # left_join(d.record_sentiment, by = "rec_id") %>% 
  anti_join(data_frame(word = custom_stopwords), by = "word") %>% 
  arrange(rec_id) %>% 
  select(rec_id, year, shape, continent, tf_idf, word) 


# Export to disk ----------------------------------------------------------

write_rds(d.ufo_notes, "app/data/ufo-notes.rds", compress = "gz")
write_rds(d.record_sentiment, "app/data/record-sentiments.rds", compress = "gz")


# Playing below here ------------------------------------------------------

# # count UFO sightings by sentiment
# d.ufo_notes %>%
#   left_join(d.record_sentiment, by = "rec_id") %>% 
#   group_by(sentiment) %>% 
#   summarise(n = n_distinct(rec_id)) %>% 
#   arrange(desc(n))
# 
# # make a wordcloud
# library(d3wordcloud)
# 
# d.cloud <-
#   d.ufo_notes %>%
#   semi_join(d.record_sentiment %>% filter(sentiment == "sadness"), by = "rec_id") %>% 
#   group_by(word) %>% 
#   summarise(tf_idf = mean(tf_idf)) %>% 
#   arrange(desc(tf_idf)) %>% 
#   head(100)
# 
# d3wordcloud(d.cloud$word, d.cloud$tf_idf)
