FROM rocker/shiny-verse:latest

MAINTAINER Brent Schneeman "schneeman@gmail.com"

RUN apt-get update && apt-get install -y \
    libssl-dev \
    libudunits2-dev \
    libv8-3.14-dev

# basic shiny functionality
RUN R -e "install.packages(c('shiny','scales', 'future.apply', 'rmarkdown', 'shinythemes', 'ggthemes', 'shinyjs', 'units', 'ggforce', 'ggraph', 'tidygraph', 'networkD3', 'RColorBrewer', 'plotly', 'V8', 'Rtsne', 'randomcoloR', 'here'), repos='https://cran.rstudio.com/')"

# install devtools related stuff
# RUN R -e "devtools::install_github('sailthru/tidyjson')"


# copy the app to the image
#

EXPOSE 80



