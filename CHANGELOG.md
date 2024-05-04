# Changelog
All notable changes to the Forsynth project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).


## [Forsynth development version]

### Added
- music module:
  - function `fr()` to compute the frequency of a note, for example "A#3".
  - Several music scales stored in arrays.
- `signals.f90` module:
  - a new fractal `add_weierstrass()` signal.
  - `add_karplus_strong_drum()` signal.
  - `add_karplus_strong_drum_stretched()`.
  - `karplus_strong_stretched()`
- demos module:
  - Added some scales in `demo3()`.
  - `drum_machine.f90` using Karplus Strong drums.
  - `misc_sounds.f90`: creates miscellaneous sounds in WAV files, especially obtained by frequency or phase modulation.
- A `ROADMAP.md` file.

### Changed
- Now under GPL-3.0-or-later license.
- `src/demos.f90` was removed and split into `example/demo1.f90`, 
`example/demo2.f90` and `example/demo3.f90`. They can be run with the
`fpm run --example` command.
    - `example/demo3.f90` was split in two: demo3 (two scales and a blues) and demo4 (signals).
- `demo4.f90` renamed `signals.f90`.

### Removed
- `app/main.f90` was removed. The `test_the_machine()` subroutine is now called by `fpm test`.

### Fixed
- A bug in add_karplus_strong().


## [Forsynth 0.2 "Daft Punk"] 2021-02-23

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


## [Forsynth 0.1 "Stockhausen"] 2021-02-19

### Added
- Initial commit.

### Changed
- Translated from the C version (2014-07-26).
