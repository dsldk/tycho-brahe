#!/bin/bash
#
for file in *.xml; do
  # Extract the filename without the .xml extension
  dir_name="${file%.xml}"

  # Create a directory with the extracted name
  mkdir -p "$dir_name"

  # Move the XML file into the created directory
  mv "$file" "$dir_name/"
done
