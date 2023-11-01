#!/bin/bash

# Directory to save the wallpaper
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
META_FILE="$WALLPAPER_DIR/meta.txt"

# Create the directory if it doesn't exist
mkdir -p $WALLPAPER_DIR

# Check if the last downloaded image is from today
if [ -f "$META_FILE" ]; then
  last_date=$(cat $META_FILE)
  today_date=$(date +"%Y-%m-%d")
  if [ "$last_date" == "$today_date" ]; then
    echo "Today's image is already downloaded."
    exit 0
  fi
fi

# Initialize the index for older pictures
idx=0

# List of resolutions to try, starting from 4K
resolutions=("3840x2160" "1920x1080" "1280x720" "1024x768")

while [ $idx -lt 7 ]; do
  # Download the Bing XML file that contains the URL of the image
  wget -q -O bing.xml "http://www.bing.com/HPImageArchive.aspx?format=xml&idx=$idx&n=1&mkt=en-US"

  # Extract the URL of the Bing Wallpaper
  IMG_URL=$(grep -o "<urlBase>.*</urlBase>" bing.xml | sed -e 's/<urlBase>\(.*\)<\/urlBase>/\1/')
  rm bing.xml  # Clean up the XML file

  # If we fail to get an image URL, exit
  if [ -z "$IMG_URL" ]; then
    echo "Failed to extract image URL from Bing XML."
    exit 1
  fi

  # Try each resolution
  for res in "${resolutions[@]}"; do
    # Full URL of the image
    FULL_IMG_URL="http://www.bing.com${IMG_URL}_${res}.jpg"

    # Download the image
    wget -q -O $WALLPAPER_DIR/bing_wallpaper.jpg $FULL_IMG_URL

    # Check if the image was downloaded successfully
    if [ -s "$WALLPAPER_DIR/bing_wallpaper.jpg" ]; then
      echo "Successfully downloaded image with resolution $res."

      # Update the metadata file with today's date
      echo $(date +"%Y-%m-%d") > $META_FILE
      exit 0
    fi
  done

  idx=$((idx + 1))  # Move on to the next older image
done

echo "Failed to download any image."
exit 1
