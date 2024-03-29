#!/usr/bin/env bash

# Default values for directories
source_directory="."
destination_directory="./transcripts"

# Function to display usage help
usage() {
  echo "Usage: $0 [-s <source_directory>] [-d <destination_directory>] [-h]"
  echo ""
  echo "Options:"
  echo "  -s    Specify the source directory to search for .srt files (default is current directory)"
  echo "  -d    Specify the destination directory to store the .txt transcripts (default is ./transcripts)"
  echo "  -h    Show this help message and exit"
  exit 1
}

# Parse options
while getopts ":s:d:h" opt; do
  case $opt in
    s)
      source_directory=$OPTARG
      ;;
    d)
      destination_directory=$OPTARG
      ;;
    h)
      usage
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# Create destination directory if it doesn't exist
mkdir -p "$destination_directory"

# Find and copy .srt files to destination directory as .txt
find "$source_directory" -name "*.srt" -exec sh -c 'cp "$1" "'"$destination_directory"'/$(basename "${1%.srt}.txt")"' _ {} \;

# Reformat the .txt files in destination directory
for file in "$destination_directory"/*.txt; do
  # Remove all empty lines from file
  sed -i '/^$/d' "$file"

  # Remove all milliseconds from timestamps
  sed -i 's/,[0-9]\{3\}//g' "$file"

  # Split the text into an array on lines that only contain a number
  mapfile -t blocks < <(sed -n '/^[0-9]\+$/,$p' "$file")

  # Open file for writing
  exec 3>"$file"

  # In each item in that array, remove newlines
  for block in "${blocks[@]}"; do
    if [[ $block =~ ^[0-9]+$ ]]; then
      # If the line contains only a number, this is the start of a new subtitle block
      if [[ -n $subtitle_block ]]; then
        # Write the accumulated line to the file
        echo "$subtitle_block" >&3
      fi
      # Reset the subtitle block and skip the line with the number
      subtitle_block=""
    else
      # Remove all newlines and append the line to the subtitle block
      subtitle_block+="${block//[$'\t\r\n']}"
    fi
  done

  # Write the last accumulated subtitle block to the file
  if [[ -n $subtitle_block ]]; then
    echo "$subtitle_block" >&3
  fi

  # Close the file descriptor
  exec 3>&-
done
