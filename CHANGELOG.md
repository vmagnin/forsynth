# Changelog
All notable changes to the Forsynth project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [ForSynth dev "Daphne Oram"]

### Added
- A FORD documentation: a project file `ford.yml` and a workflow `.github/workflows/ford.yml` to generate GitHub Pages.
- In `example/README.md`: links to listen the OGG files.
- `example/radioactivity.f90` is a tribute to Kraftwerk. You can hear the simulation of the radioactive decay of a population of atoms heard with a Geiger counter, with chords in a whole tone scale and a Morse code message.
- `src/morse_code.f90` is offering basic Morse code support.
- `src/acoustics.f90` module with the `dB_to_linear(dB)` and `linear_to_dB(amp)` conversion functions.
- `src/audio_effects.f90`: a basic `apply_dynamic_effect()` that can be used for downward/upward compression or expansion, or as a limiter depending on the parameters.
- `src/envelopes.f90`: added `fit_exp(x, x1, y1, x2, y2)` for computing an exponentially decreasing y(x) envelope between (x1,y1) and (x2,y2).
- `src/signals.f90`: added `add_bell()`, based on the [Risset, 1969] bell signal #430 with 11 frequencies.
- `example/multiplication_bells.f90`: a demo using the `add_bell` signal.
- In `test/main.f90`: more tests and a `assert_reals_equal(a, b, tolerance)` function.

### Changed
- `ELECTRONIC_MUSIC_HISTORY.md`: improved layout (hidden URLs).

### Fixed
- `example/shepard_risset_glissando.f90`: obtaining a good glissando was not easy, as you need to understand that each sin(omega * t) is in fact sin(omega(t) * t). Using a common time for all components was causing problems as t was increasing. In this new version, each component has its own time: sin(omega(tj) * tj). Moreover, a downward glissando can also be computed.
- `src/tape_recorder_class.f90`: added a `self%last` variable which is the index of the last sample on the track. In tracks, it must be used instead of `self%samples` which is equal to `self%last+1`, the first sample having a 0 index.
- Replaced `nint(t2*RATE)-1` by `min(nint(t2*RATE), tape%last)` to avoid exceeding the right limit of the tape array.


## [ForSynth 0.4 "Jean-Claude Risset"] 2024-06-03

### Added
- In `src/audio_effects.f90`: an `apply_reverse_effect(tape, track, t1, t2)` subroutine to reverse the order of samples.
- In `src/envelopes.f90`: `apply_fade_in()` and `apply_fade_out()` subroutines.
- In `src/music.f90`: `add_broken_chord()` writes a broken chord using an array containing the intervals. It uses plucked strings (Karplus-Strong).
- An `ADSR_envelope` object can now be passed optionally to `add_sine_wave()`, `add_square_wave()`, `add_triangle_wav()`, `add_sawtooth_wave()`, `add_noise()`, `add_weierstrass()` signals, and `add_note()` and `add_chord()` subroutines.
- In `tape_recorder_class.f90`, the method `mix_tracks()` now accepts an optional array with the panoramic settings of each track.
- In `wav_file_class.f90`, a method `get_name()` that returns the filename.
- In `example/`:
    - `shepard_scale.f90`: a [Shepard scale](https://en.wikipedia.org/wiki/Shepard_tone), giving the illusion of an ever increasing pitch in the first half of the tape and an ever decreasing pitch in the 2nd half.
    - `shepard_risset_glissando.f90`: a Shepard-Risset glissando, giving the illusion of an ever increasing pitch. It is the continuous version of the Shepard scale.
    - `doppler_effect.f90`: a simulation of Doppler effect, with a car passing in front of you.
    - `arpeggios.f90`: arpeggios played in various ways using the circles of fifths.

### Changed
- `src/signals.f90`:
    - the Karplus-Strong algorithms are now using the track 0 as an auxilliary track, to avoid overwriting what is already present on the track of the signal.
    - Signals use `do concurrent` loops when possible.
- `src/audio_effects.f90`: the effects now use `do concurrent` loops (except for delay).
- `example/drone_music.f90` and `example/shepard_risset_glissando.f90`: added fade in and fade out.
- `src/envelopes.f90`: the ADSR envelope is now a class `ADSR_envelope`.

### Fixed
- In `tape_recorder_class.f90`, the routine `mix_tracks()` is now clearing first the track 0, which can be used previously as an auxiliary track by some routines.


## [ForSynth 0.3 "Éliane Radigue"] 2024-05-20

### Added
- music module:
    - A subroutine `add_chord()`, using an array containing the intervals of the chord. Allows chords such as 7th, Sus2, Sus4... using the `music_common` module.
    - A function `fr()` to compute the frequency of a note, for example "A#3".
    - Several music scales stored in arrays.
- `signals.f90` module:
    - a new fractal `add_weierstrass()` signal.
    - `add_karplus_strong_drum()` signal.
    - `add_karplus_strong_drum_stretched()`.
    - `karplus_strong_stretched()`.
- The method `mix_tracks()` now accepts an optional array containing the levels of each track (except track 0) in the mix.
- Demos in `example/`:
    - `drum_machine.f90` using Karplus Strong drums, following a pattern defined in an array.
    - `misc_sounds.f90`: creates miscellaneous sounds in WAV files, especially obtained by frequency or phase modulation.
    - `drone_music.f90`: experimental drone music.
- A `ROADMAP.md` file.
- A `logo`.
- The `example/README.md` file.

### Changed
- `src/forsynth.f90`:
    - the working precision is now `wp` instead of `dp`.
    - The class `file_t` was renamed `WAV_file` and put in a separate file `wav_file_class.f90`. `close_WAV_file()`, `write_header()` and `write_normalized_data()` are now methods of the object.
        - The duration and number of tracks can now be set when we create a new WAV.
    - A class `tape_recorder` was created and moved to `tape_recorder_class.f90`. It contains the arrays and their related parameters, and the methods `clear_tracks`, `mix_tracks`, `copy_section`...
        - `clear_tracks()` is now automatically called when creating a `wav_file` or `tape_recorder` object.
- `src/music.f90` was splitted in two files: `src/music.f90` and `src/music_common.f90` which contain music theory elements common to the ForMIDI and ForSynth projects.
- `src/demos.f90` was removed and split into `example/demo1.f90`, `example/demo2.f90` and `example/demo3.f90`. They can be run with the `fpm run --example` command.
    - `example/demo3.f90` was then split in two: demo3 (two scales and a blues) and demo4 (signals).
        - and demo3 renamed `blues.f90` and improved.
    - `demo1` was renamed `chords_and_melody`.
    - `demo2` was renamed `demo_effects`.
- `demo4.f90` renamed `signals.f90`.
- Examples are now using keyword argument lists to better document how the API must be used.
- The alternative `build.sh` was improved.
- Now under GPL-3.0-or-later license.

### Removed
- `app/main.f90` was removed. The `test_the_machine()` subroutine is now called by `fpm test`.
- The routines `add_major_chord()` and `add_minor_chord()` in the `music` module (replaced by `add_chord()`).

### Fixed
- A bug in `add_karplus_strong()`.


## [ForSynth 0.2 "Daft Punk"] 2021-02-23

### Added
- forsynth module:
  - `copy_section()`
  - `clear_tracks()`
- music module:
  - `add_note()` to generate a note with a sum of harmonics.
  - `add_major_chord()`
  - `add_minor_chord()`
- demos module:
  - `demo1()`
  - `demo2()`
  - `demo3()`
- envelopes module: `ADSR_envelope()` function
- signals module:
  - `add_karplus_strong()` for plucked strings
  - `add_square_wave()`
  - `add_sawtooth_wave()`
  - `add_triangle_wave()`
  - `add_noise()`
- sound_effects module:
  - `apply_delay_effect()`
  - `apply_fuzz_effect()`
  - `apply_tremolo_effect()`
  - `apply_autopan_effect()`

### Changed
- `add_sinusoidal_signal` has been renamed `add_sine_wave`, on the same model
as the other waveforms.


## [ForSynth 0.1 "Stockhausen"] 2021-02-19

### Added
- Initial commit.

### Changed
- Translated from the C version (2014-07-26).
