# mass-youtube-downloader

Download multiple youtube videos and their transcripts simultaneously. 

This script uses [yt-dlp](https://github.com/yt-dlp/yt-dlp) to download multiple YouTube videos simultaneously. It saves each video to .mp4 files, and also downloads the videos' transcripts as .srt files. 

You can give it a list of URLs in the terminal or you can pass it a list of URLs in a text file.

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
