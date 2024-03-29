#!/usr/bin/env bash

# Default number of parallel processes
default_parallel=4

# Function to display usage help
usage() {
  echo "Usage: $0 --help"
  echo "       $0 -n <number_of_processes> [-u <'url1 url2 ...'>] [-f <path_to_file>]"
  echo ""
  echo "Options:"
  echo "  -n    Set the number of parallel processes (default is 4)"
  echo "  -u    Provide the URLs enclosed in quotes and separated by spaces"
  echo "  -f    Provide the path to a file containing one URL per line"
  echo "  --help Show this help message and exit"
  exit 1
}

# Parse named arguments
while :; do
  case "$1" in
    -n)
      if [ "$2" ]; then
        parallel_processes=$2
        shift 2
      else
        echo "Error: -n requires a numerical argument."
        usage
      fi
      ;;
    -u)
      if [ "$2" ]; then
        IFS=' ' read -r -a urls <<< "$2"
        shift 2
      else
        echo "Error: -u requires a string argument."
        usage
      fi
      ;;
    -f)
      if [ "$2" ]; then
        file_path=$2
        if [ ! -f "$file_path" ]; then
          echo "Error: The file specified does not exist."
          exit 2
        fi
        readarray -t file_urls < "$file_path"
        shift 2
      else
        echo "Error: -f requires a file path argument."
        usage
      fi
      ;;
    --help)
      usage
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      usage
      ;;
    *)
      break
      ;;
  esac
done

# Combine file URLs and command line URLs
if [ "${#file_urls[@]}" -gt 0 ] && [ "${#urls[@]}" -gt 0 ]; then
  urls=("${urls[@]}" "${file_urls[@]}")
elif [ "${#file_urls[@]}" -gt 0 ]; then
  urls=("${file_urls[@]}")
fi

# Check for required arguments
if [ -z "${urls+x}" ]; then
  echo "Error: URLs are required, either through -u or -f option."
  usage
fi

# Set the default number of parallel processes if not provided
if [ -z "${parallel_processes+x}" ]; then
  parallel_processes=$default_parallel
fi

# Use a temporary file to store the video titles and directories
temp_file=$(mktemp)

# Generate video directories and store them in the temp file
for url in "${urls[@]}"; do
  title=$(yt-dlp --get-filename -o "%(title)s" "$url")
  dirname="${title//\//_}" # Replace forward slashes with underscores
  mkdir -p "$dirname"
  echo "$dirname" >> "$temp_file"
done

# Use xargs to run yt-dlp in parallel processes
cat "$temp_file" | xargs -I {} -P "$parallel_processes" -n 1 bash -c 'yt-dlp --write-auto-sub --convert-subs srt --remux-video mp4 -o "$1/%(title)s.%(ext)s" "${@:2}"' _ {} "${urls[@]}"

# Clean up the temporary file
rm "$temp_file"
