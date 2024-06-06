#!/usr/bin/env bash

# Default arguments
default_parallel=4
output_dir="./videos"

# Function to display usage help
usage() {
  echo "Usage: $0 --help"
  echo "       $0 -n <number_of_processes> [-u <'url1 url2 ...'>] [-f <path_to_file>] [-o <output_directory>]"
  echo ""
  echo "Options:"
  echo "  -n    Set the number of parallel processes (default is 4)"
  echo "  -u    Provide the URLs enclosed in quotes and separated by spaces"
  echo "  -f    Provide the path to a file containing one URL per line"
  echo "  -o    Specify the output directory where new directories will be placed (default is ./videos)"
  echo "  -h Show this help message and exit"
  exit 1
}

# Check if yt-dlp is installed
check_ytdlp() {
  if ! command -v yt-dlp &> /dev/null; then
    echo "yt-dlp could not be found."
    read -p "Would you like to install yt-dlp using pip? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      pip install yt-dlp || { echo "Failed to install yt-dlp. Please install it manually."; exit 1; }
    else
      echo "Please install yt-dlp and rerun the script."
      exit 1
    fi
  fi
}

# Parse named arguments
while :; do
  case "$1" in
    -o)
      if [ "$2" ]; then
        output_dir=$2
        shift 2
      else
        echo "Error: -o requires a non-empty argument."
        usage
      fi
      ;;
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
        while IFS= read -r line; do
          file_urls+=("$line")
        done < "$file_path"
        shift 2
      else
        echo "Error: -f requires a file path argument."
        usage
      fi
      ;;
    -h)
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

# Run the yt-dlp check function after arguments parsing
check_ytdlp

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

# Generate video directories and run yt-dlp in parallel processes
for url in "${urls[@]}"; do
  title=$(yt-dlp --get-filename -o "%(title)s" -- "$url")
  dirname="${title//[^a-zA-Z0-9_]/_}" # Replace disallowed characters with underscores
  full_output_path="$output_dir/$dirname"  # Prepend the specified output directory
  mkdir -p "$full_output_path"  # Create directory including the output directory path
  yt-dlp --write-auto-sub --convert-subs srt --remux-video mp4 -o "$full_output_path/%(title)s.%(ext)s" -- "$url" &
  while [ $(jobs -r | wc -l) -ge "$parallel_processes" ]; do
    sleep 1
  done
done

# Wait for all background processes to finish
wait
