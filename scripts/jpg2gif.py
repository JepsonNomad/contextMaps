import glob
import os
import sys

s = sys.argv[1] # Declare folder of images

os.chdir(s) # Navigate to folder

gif_name = 'Timelapse' # Choose output name
file_list = glob.glob('*.jpg') # Get all the 3d plots
file_list.extend(glob.glob('*.JPG'))
file_list.sort()

print(file_list)

with open('image_list.txt', 'w') as file:
    for item in file_list:
        file.write("%s\n" % item)

os.system('convert -delay 1x4 @image_list.txt {}.gif'.format(gif_name)) # On windows convert is 'magick'



