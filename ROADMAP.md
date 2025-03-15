# Roadmap

The stars in parenthesis are an evaluation of the difficulty.

## ForSynth 0.5

### Development
* [x] Add tests. (**)

### Features
* [x] A function converting dB to linear scale would be useful to set the sound level. (*)
* [x] Synthesis: a bell (**)
* [x] [Compressor/expander effect](https://en.wikipedia.org/wiki/Dynamic_range_compression) (**)
* [ ] Scientific data [sonification](https://en.wikipedia.org/wiki/Sonification): by reading a data file? or by passing an array? (**)

### Examples
* [x] Simulating a radioactive decay, heard with a Geiger counter (a tribute to Kraftwerk). (**)
* [x] An example using bells.

### Documentation
* [x] A first version of a FORD documentation. (**)
    * [x] Transforming comments into FORD comments !>

### Fix
* [x] The problem of the Shepard–Risset glissando. (***)


## ForSynth 0.6
* ?

## Ideas for further developments

### Audio effects
* [ ] Add more [audio effects](https://en.wikipedia.org/wiki/Category:Audio_effects)
    * [ ] [Flanger](https://en.wikipedia.org/wiki/Flanging) (**)
    * [ ] [Phaser](https://en.wikipedia.org/wiki/Phaser_(effect)) (***)
    * [ ] [Chorus](https://en.wikipedia.org/wiki/Chorus_(audio_effect)) (***)
    * [ ] Reverb (***): https://freeverb3-vst.sourceforge.io/
    * [ ] Could Doppler effect be used to obtain a Leslie speaker effect?
* [ ] Improve the compressor/expander `apply_dynamic_effect()` with attack, release, make-up gain, soft knee. (**)

### New examples
* [ ] A Risset rhythm, ever accelerating. (**)

### Sound synthesis
* [ ] Find algorithms for good drums, especially bass drums.
* [ ] Physical modelling (***)
    * [ ] Using https://gitlab.com/certik/stringsim ?
* [ ] Soustractive synthesis: add filters (FFT?) (***)

### Sequencers
* [ ] A drum pattern object to ease programming rhythms, inspired by the pattern system used in `example/drum_machine.f90`. Could be also used by ForMIDI. (***)
* [ ] A note sequencer repeating a pattern. Could be also used by ForMIDI. (***)
* [ ] A sequence object, accepting a string with notes, with methods to obtain one by one their parameters (physical or MIDI). Could be also used by ForMIDI. (***)
    * [ ] The sequence could for example be coded as "A4,Q.,pf;A#4,Q,pf;..." (note, length, intensity).
