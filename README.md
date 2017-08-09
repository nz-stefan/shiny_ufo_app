# R Shiny Demo Application

This is a demo web application written in the R Shiny framework. The app demonstrates the use of various UX components commonly seen in data products. In particular the demo showcases:

- Clean and responsive UI that works well on both large and small screens
- Reasonable app performance and visual feedback during re-calculations
- Standard visualisations, like (stacked) area and bar charts
- Maps including clustering of markers
- Wordclouds
- Info tiles
- Various UX components such as multiple pages, pulldown menus, sliders, radio buttons and switches
- Help system
- Modular structure of the app's code


## Data

The dataset contains over 80,000 reports of UFO sightings over the last century. collected by the National UFO Reporting Center (NUFORC). It is publicly available at [GitHub](https://github.com/planetsig/ufo-reports) and [Kaggle](https://www.kaggle.com/donyoe/exploring-ufo-sightings).

The dataset was chosen because of its quirkyness and its mixture of geolocation, time series and textual information which allows various interesting visualisations like maps and wordclouds. It was also easy to enrich this dataset using other data sources such as the country polygons in the rworldmap package to identify the correct country of a particular geolocation or adding sentiment to the textual comments of an UFO sighting using the tidytext package.


## Code

This app is implemented in the R Shiny web application framework. In total, **less than 1,200 lines** of code and CSS were written for this app over a course of **less than 40 hours**. The development time included data preparation and figuring out what to actually develop and how to best present the information.


## Deployment

The app is deployed through RStudio's webservice [shinyapps.io](https://shinyapps.io) which is straightforward to achieve and fairly reasonably priced. However, the app can be easily [containerized](https://www.docker.com) and deployed through a secured VM or a Kubernetes cluster.

Author: Stefan Schliebs

Created: Tue 25 Jul 2017 16:46:43 NZST
