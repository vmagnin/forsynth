# Changelog
All notable changes to the Forsynth project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).


## [Forsynth development version]

### Added
- music module:
  - function `fr()` to compute the frequency of a note, for example "A#3".
  - Several music scales stored in arrays.
- demos module:
  - Added some scales in `demo3()`.

### Changed
- Now under GNU GPLv3 license.

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
- Translated from C.
