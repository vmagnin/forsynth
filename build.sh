#!/bin/bash
# Vincent Magnin
# Last modification: 2025-03-02

# For a safer script:
set -eu

# Default compiler can be overrided, for example:
# $ FC='gfortran-8' ./build.sh
# Default:
: ${FC="gfortran"}

# Create (if needed) the build directory:
if [ ! -d build ]; then
    mkdir build
fi

rm -f *.mod

if [ "${FC}" = "ifx" ]; then
  flags="-warn all -Ofast"
else
  # GFortran flags:
  flags="-Wall -Wextra -pedantic -std=f2018 -Ofast -march=native -mtune=native"
fi

# Compiling modules:
"${FC}" ${flags} -c src/forsynth.f90 src/tape_recorder_class.f90 src/wav_file_class.f90 src/envelopes.f90 src/signals.f90 src/music_common.f90 src/music.f90 src/audio_effects.f90 src/morse_code.f90 src/acoustics.f90

# Compiling examples:
for file in "chords_and_melody" "demo_effects" "blues" "all_signals" "drum_machine" "misc_sounds" "drone_music" "shepard_scale" "shepard_risset_glissando" "doppler_effect" "arpeggios" "radioactivity" "multiplication_bells" ; do
  echo "${file}"
  "${FC}" ${flags} acoustics.o morse_code.o audio_effects.o  envelopes.o  forsynth.o  music_common.o  music.o  signals.o  tape_recorder_class.o  wav_file_class.o example/${file}.f90 -o build/${file}.out
done

# Cleanup to avoid any problem with fpm or another compiler:
rm -f *.mod
rm *.o
