
#### Import packages ----
library(tidyverse)
library(raster)
library(sf)
library(RStoolbox)
library(cowplot)


#### Define functions ----

#### A function to plot and save an RGB image
##  Inputs:
##  rasPath = filepath to raster that will be mapped
##  monthID = integer indicator of month being mapped (1-12)
##  vecPath = filepath to vector ROI
##  outPath = filepath for map destination. Note that folder must already exist.
plotFunction = function(rasPath,
                        monthID,
                        vecPath,
                        outPath){
  #### Import data ----
  ## Raster
  eeImg = raster::stack(rasPath)
  ## Vector
  ## e.g. Yolo County
  ROI = sf::read_sf(vecPath)
  
  #### Data wrangling ----
  ## Raster
  # Convert to data.frame. There is really no reason to go higher than 10 million pixels
  # if you're using the maps for a presentation (4k screen = 3840*2170 = 8.3e7 pixels).
  # Consider the output dimensions: (3in*300ppi)^2 = 4.4e7 pixels
  imgFortFull = fortify(eeImg, maxpixels = 8e5)
  # Remove useless pixels and scale to (0,1)
  imgFort = imgFortFull %>%
    rename("R" = vis.red,
           "G" = vis.green,
           "B" = vis.blue) %>%
    filter(R + G + B != 0) %>%
    mutate(Rsc = scales::rescale(R, to = c(0,1), from = c(0,255)),
           Gsc = scales::rescale(G, to = c(0,1), from = c(0,255)),
           Bsc = scales::rescale(B, to = c(0,1), from = c(0,255)))
  
  ## Generate time bar indicator
  xtimelen = 0.25*(max(imgFort$x)
                   - min(imgFort$x))
  xtimepos = min(imgFort$x) + xtimelen*((monthID-1)/11)
  ytimetall = 0.015
  
  
  #### Plots ----
  ## RGB plot
  rgbPlot = ggplot() +
    geom_tile(data = imgFort, 
              aes(x = x, y = y, 
                  fill = rgb(Rsc,Gsc,Bsc)))  +
    scale_fill_identity() +
    geom_sf(data = ROI,
            fill = "transparent",
            lwd = 0.25,
            col = "grey40") +
    theme_void() +
    theme(panel.background = element_rect(fill = "transparent", 
                                          colour = "transparent"),  
          plot.background = element_rect(fill = "transparent", 
                                         colour = "transparent")) +
    ## Horizontal time bar
    annotate(geom = "segment",
             x = min(imgFort$x),
             xend = (min(imgFort$x) 
                     + xtimelen),
             y = min(imgFort$y) + 0.02,
             yend = min(imgFort$y) + 0.02) +
    ## Vertical time indicator
    annotate(geom = "segment",
             x = xtimepos,
             xend = xtimepos,
             y = min(imgFort$y) + 0.02,
             yend = min(imgFort$y) + ytimetall + 0.02) +
    annotate(geom = "text",
             label = "Jan",
             x = min(imgFort$x),
             y = min(imgFort$y)) +
    annotate(geom = "text",
             label = "Dec",
             x = min(imgFort$x) + xtimelen,
             y = min(imgFort$y))
  # rgbPlot
  
  
  #### Save plots ----
  ## Give some thought to the output metadata:
  # A 4k display is 3840 x 2160 pixels. Therefore there's really no need to have presentation images be >3840 horizontal pixels or >2160 vertical pixels
  # Let's make final image dimensions 3x3 inches, with a resolution of 300 pixels per inch ("dpi"). This will be a lower-resolution map than what we generated with plotMap but is gif-friendly.
  
  ggsave(filename = outPath,
         rgbPlot, 
         bg = "transparent",
         height = 3, width = 3, units = "in", dpi = 300)
}



#### Define parameters ----

#### rasPath
## Identify input filepaths
rasterFPlist = list.files(path = "data/monthly",
                          full.names = TRUE)
rasterFPbns = basename(rasterFPlist)
rasterFPraws = tools::file_path_sans_ext(rasterFPbns)


#### monthID
mymonths = as.integer(rasterFPraws) + 1

#### vecPath
## Identify region of interest
ROI = "data/Yolo_ROI.shp"

#### outPath
## Design output names based on input filepath minus path + extension
mapRawnames = str_pad(rasterFPraws,
                      pad = "0",
                      side = "left",
                      width = 2)
mapOutnames = paste0("plots/yoloMonthly/",
                     mapRawnames,
                     ".jpg")


#### Iterate function across parameters ----
for(i in 1:length(rasterFPlist)){
  plotFunction(rasPath = rasterFPlist[i],
               monthID = mymonths[i],
               vecPath = ROI,
               outPath = mapOutnames[i])
}


