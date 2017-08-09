###########################################################
# Define generic filter UI component to be used in the UI
# of various modules of the app
# 
# Author: Stefan Schliebs
# Created: 2017-08-09
###########################################################


make_filter_ui_element <- function(data_set, variable, ui_id, ui_label) {
  # use dplyr's new quotation feature to obtain column name
  variable <- enquo(variable)
  
  # build list of choices for picker element
  choice_list <- data_set %>% 
    count(!!variable, sort = TRUE) %>% 
    na.omit()
  
  # create picker element
  pickerInput(
    inputId = ui_id, 
    label = ui_label, 
    choices = choice_list %>% pull(!!variable), 
    selected = choice_list %>% pull(!!variable),
    choicesOpt = list(subtext = sprintf("(%s records)", format(choice_list$n, big.mark = ","))),
    options = list(
      `actions-box` = TRUE, 
      `live-search` = TRUE, 
      `live-search-placeholder` = "Type to search",
      `selected-text-format` = "count > 5"), 
    multiple = TRUE)
}
