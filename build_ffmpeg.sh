#!/bin/sh
#
# - Consider using libshine instead of libmp3lame is you need faster, but lower quality, MP3 encoding (especially on architectures without a FPU).
# - I usually don't recommend using `--disable-all`, but the size of the executable seems to be the most important factor for you. Using `--disable-everything`
#  is easier to use because it does not disable the FFmpeg libraries, and is therefore less prone to forgotten components.
# - `--disable-small` optimizes for size instead of speed. It does make a size difference (1 MB vs 1.4 MB in this example), but I'm not sure how much of a 
# speed difference it makes.
# - I did not include any additional options you may need for compiling for or on Android.
# - This may not work for MP3 inputs that contain album art because I did not enable any video options (specifically JPG and PNG related components). 
# - You may get by that by mapping just the audio with the -map option, such as with -map 0:a.
# 
# https://stackoverflow.com/a/48978494/2430555
#

# Download the lastest FFMPEG version on the current directory.
if [ ! -d "libavutil" ]; then
  mkdir ffmpeg
  cd ffmpeg
  git clone https://github.com/FFmpeg/FFmpeg.git .
  cd ..
  cp -r "ffmpeg/"* "."
  rm -rf ffmpeg
fi

# Install or update pkg-config if needed.
if [[ "$OSTYPE" == "darwin"* ]]; then
  brew update
  if brew ls --versions pkg-config > /dev/null; then
    brew upgrade pkg-config
  else
    brew install pkg-config
  fi
fi

# Configure FFMPEG
./configure --disable-everything --prefix=/usr/local --pkg-config-flags=--static --extra-cflags='-I/tmp/ffmpeg_build/include -static' \
--extra-ldflags='-L/tmp/ffmpeg_build/lib -static' --extra-libs='-lpthread -lm' --bindir=/opt/ffmpeg/bin \
--disable-gpl --disable-nonfree --disable-network --enable-pthreads \
--disable-shared --enable-static --disable-debug --disable-ffplay --disable-doc --disable-runtime-cpudetect \
--disable-network --disable-devices --disable-protocols --enable-protocol=file --enable-protocol=pipe --enable-protocol=tee \
--enable-swresample --enable-filter=aresample \
--enable-ffmpeg --enable-libfdk-aac --enable-libmp3lame --enable-libvorbis --enable-libopus \
--enable-parser=aac,mpegaudio,vorbis,opus \
--enable-demuxer=mp3,aac,wav,asf,ogg --enable-muxer=mp3 \
--enable-decoder=mp3,aac,pcm*,wma*,libvorbis,libopus --enable-encoder=libmp3lame \
--enable-small

# Build the project
make