# mass-youtube-downloader

Download multiple youtube videos and their transcripts simultaneously. 

This script uses [yt-dlp](https://github.com/yt-dlp/yt-dlp) to download multiple YouTube videos simultaneously. It saves each video to .mp4 files, and also downloads the videos' transcripts as .srt files. 

## Installation

Download/copy the scripts onto your computer and run:

```shell
chmod +x <script-name>.sh
```

This was written on a linux machine but should work on a mac too.

## Usage

### mass-yt-dlp.sh

This script is used to download multiple youtube videos and their transcripts simultaneously. You can give it a list of URLs in the terminal or you can pass it a list of URLs in a text file. It will create a new directory titled "videos" and download the videos and their transcripts to subfolders for each video in that folder. 

If you do pass them directly on the command line, please be sure to put them in quotes as some of the characters in certain youtube video URLs can cause issues if not quoted.

```shell
./mass-yt-dlp.sh -u "https://www.youtube.com/watch?v=Abc123"
```

```shell
./mass-yt-dlp.sh -f "url-list.txt"
```

By default it tries to download 4 videos at once, but you can increase or decrease that:

```shell
./mass-yt-dlp.sh -n 8 -f "url-list.txt"
```

Display a help message using:

```shell
./mas-yt-dlp.sh --help
```

### cleanup-srts.sh

This script converts the SRT files to a more readable format that is easy to feed into a language model or service such as Google's NotebookLM (the reason I wrote this script). 

It collects each srt file from all the directories in the current directory and converts them to text files with the same name as the srt file. It cleans up the transcripts so each timestamp is on a single line and the text is on the same line. 

It outputs the cleaned up transcripts to a directory titled 'transcripts', or you can specify a different directory to output the cleaned up transcripts to.

```plaintext
Usage: ./cleanup-srts.sh [-s <source_directory>] [-d <destination_directory>] [-h]

Options:
  -s    Specify the source directory to search for .srt files (default is current directory)
  -d    Specify the destination directory to store the .txt transcripts (default is ./transcripts)
  -h    Show this help message and exit
```

## Example

Given a file `urls.txt` with the following contents:

```plaintext
https://www.youtube.com/watch?v=Abc123
https://www.youtube.com/watch?v=Def456
https://www.youtube.com/watch?v=Ghi789
```

You can run the following commands:

```shell
./mass-yt-dlp.sh -f "urls.txt"
```

This will create a directory `videos` with the following structure:

```plaintext
videos
├── Abc123
│   ├── Abc123.mp4
│   └── Abc123.srt
├── Def456
│   ├── Def456.mp4
│   └── Def456.srt
└── Ghi789
    ├── Ghi789.mp4
    └── Ghi789.srt
```

You can then run the following command to clean up the transcripts:

```shell
./cleanup-srts.sh
```

This will create a directory `transcripts` with the following structure:

```plaintext
transcripts
├── Abc123.txt
├── Def456.txt
└── Ghi789.txt
```