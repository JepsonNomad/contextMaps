# Generate high-definition contextual maps

This repository contains code for accessing, filtering, and downloading satellite-derived imagery (using Google Earth Engine), and plotting that imagery for contextual maps (using R and the power of ggplot) to be used in publications and presentations. For the instructions below, the data pipeline uses pre-computed Surface Reflectance data. Code is also available for Top of Atmosphere adjusted data.

Imagery can be accessed, trimmed to a Region of Interest (ROI), cleaned of poor-quality data and downloaded via Earth Engine using the contents of the `scripts/getData_SR.txt` scripts in your Earth Engine code editor. For your convenience, the data that are generated through that script are available in the `data/` folder.

Once you've got your data, you can use the `scripts/plotMaps_SR.R` script to generate minimalist maps that provide context to your audience. Below are two examples: the first is an image of Yolo County, California (the `scripts/` folder includes materials to reproduce exactly this image); the second is an image of California with the Sierra Nevada ecoregion highlighted in light grey (challenge: can you reproduce this image on your own?).

<img src="plots/yoloContext_SR.jpg" alt="Map of Yolo County, CA" height="500"/>
<img src="plots/caliRGB_SR.jpg" alt="Map of CA with Sierra Ecoregion" height="500"/>

### Challenge

If you're feeling ambitious, try generating monthly median aggregates in Earth Engine using the code in `scripts/getData_monthlyMed.txt`. You can then use `scripts/plotMonths_SR.R` to iterate the plotting workflow from above across a folder of images. Again, for your convenience, some example data have already been downloaded and can be found in the `data/monthly_SR/` subdirectory. Finally, use `scripts/jpg2gif.py` to combine your 12 monthly aggregates into a gif!

`$ python3 ./scripts/jpg2gif.py ./plots/yoloMonthly_SR/`

<img src="plots/yoloMonthly_SR/Timelapse.gif" alt="Monthly timelapse of Yolo County" height="500"/>






