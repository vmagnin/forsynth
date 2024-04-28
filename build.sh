#!/bin/bash
# Vincent Magnin
# Last modification: 2024-04-28

# For a safer script:
set -eu

# Default compiler can be overrided, for example:
# $ GFC='gfortran-8' ./build.sh
# Default:
: ${GFC="gfortran"}

# Create (if needed) the build directory:
if [ ! -d build ]; then
    mkdir build
fi

rm -f *.mod

"${GFC}" -Wall -Wextra -pedantic -std=f2018 -O3 src/forsynth.f90 src/envelopes.f90 src/signals.f90 src/music.f90 src/audio_effects.f90 example/demo1.f90 -o build/demo1.out
"${GFC}" -Wall -Wextra -pedantic -std=f2018 -O3 src/forsynth.f90 src/envelopes.f90 src/signals.f90 src/music.f90 src/audio_effects.f90 example/demo2.f90 -o build/demo2.out
"${GFC}" -Wall -Wextra -pedantic -std=f2018 -O3 src/forsynth.f90 src/envelopes.f90 src/signals.f90 src/music.f90 src/audio_effects.f90 example/demo3.f90 -o build/demo3.out
"${GFC}" -Wall -Wextra -pedantic -std=f2018 -O3 src/forsynth.f90 src/envelopes.f90 src/signals.f90 src/music.f90 src/audio_effects.f90 example/signals.f90 -o build/signals.out
"${GFC}" -Wall -Wextra -pedantic -std=f2018 -O3 src/forsynth.f90 src/envelopes.f90 src/signals.f90 src/music.f90 src/audio_effects.f90 example/drum_machine.f90 -o build/drum_machine.out
