# Changelog
All notable changes to the Forsynth project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).


## [Forsynth development version]

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
- envelopes module: `ADSR_envelope()` function
- signals module: 
  - `add_karplus_strong()` for plucked strings
  - `add_square_wave`
- sound_effects module: 
  - `apply_delay_effect()`
  - `apply_fuzz_effect()`
  - `apply_tremolo_effect()`
  - `apply_autopan_effect()`

## [Forsynth 0.1 "Stockhausen"] 2021-02-19

### Added
- Initial commit.

### Changed
- Translated from C.
