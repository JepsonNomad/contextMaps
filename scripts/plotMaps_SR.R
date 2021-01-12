## Curious about TOA vs SR? Check out this post for more:
# https://gis.stackexchange.com/questions/304180/what-are-the-min-and-max-values-of-map-addlayer-on-google-earth-engine

#### Import packages ----
library(tidyverse)
library(raster)
library(sf)
library(RStoolbox)
library(cowplot)


#### Import data ----
## Raster
eeImg = raster::stack("data/Yolo_LC08_RGB_2020_SR.tif")
eeImg

## Vector
## Yolo County
ROI = sf::read_sf("data/Yolo_ROI.shp") %>%
  st_union()
ROI

## CA State
CA = USAboundaries::us_states() %>%
  st_as_sf() %>%
  filter(name == "California")
CA


#### Data wrangling ----
## Raster
# Convert to data.frame
# Recall that we set maxPixels in the Earth Engine export to 1e8,
# that's the maximum value you should consider using here as well. 
# If your image is going to be a half the screen, you can use half
# the maxpixels. 
imgFortFull = fortify(eeImg, maxpixels = 1e8)
imgFort = imgFortFull %>%
  rename("R" = vis.red,
         "G" = vis.green,
         "B" = vis.blue) %>%
  filter(R + G + B != 0) %>%
  mutate(Rsc = scales::rescale(R, to = c(0,1), from = c(0,255)),
         Gsc = scales::rescale(G, to = c(0,1), from = c(0,255)),
         Bsc = scales::rescale(B, to = c(0,1), from = c(0,255)))


#### Plots ----
## Vector context plot
vectorPlot = ggplot() +
  geom_sf(data = CA,
          fill = "grey90") +
  geom_sf(data = ROI,
          fill = "grey60") +
  theme_void() +
  theme(panel.background = element_rect(fill = "transparent", 
                                        colour = "transparent"),  
        plot.background = element_rect(fill = "transparent", 
                                       colour = "transparent"))
# vectorPlot


## RGB plot
rgbPlot = ggplot() +
  geom_tile(data = imgFort, 
              aes(x = x, y = y, 
                  fill = rgb(Rsc,Gsc,Bsc)))  +
  scale_fill_identity() +
  geom_sf(data = ROI,
          fill = "transparent",
          lwd = 0.75,
          col = "grey40") +
  theme_void() +
  theme(panel.background = element_rect(fill = "transparent", 
                                        colour = "transparent"),  
        plot.background = element_rect(fill = "transparent", 
                                       colour = "transparent"))
# rgbPlot



#### Combine contextual vector and RGB imagery to a single plot with inset
## Generate a "complete" plot that includes contextual vector data
completePlot = ggdraw() +
  draw_plot(rgbPlot) +
  draw_plot(vectorPlot, 
            x = 0.075, y = 0.075, 
            width = 0.4, height = 0.5)
# completePlot



#### Save plots ----
## Give some thought to the output metadata:
# A 4k display is 3840 x 2160 pixels. Therefore there's really no need to have presentation images be >3840 horizontal pixels or >2160 vertical pixels
# Let's do some math. If a figure is to take up half of a ppt slide, then we can happily take it to 1920 horizontal pixels. If that's the case, we can make final image dimensions 7x7 inches, with a resolution of 300 pixels per inch ("dpi") and lose no more information than we would from 4k viewing anyway (final dimensions 2100 x 2100 pixels).

ggsave(filename = "plots/yoloRGB_SR.jpg",
       rgbPlot, bg = "transparent",
       height = 7, width = 7, units = "in", dpi = 300)
ggsave(filename = "plots/yoloContext_SR.jpg",
       completePlot, bg = "transparent",
       height = 7, width = 7, units = "in", dpi = 300)
