# Roadmap

The stars in parenthesis are an evaluation of the difficulty.

## ForSynth 0.4

### Development
* [x] More OOP. (***)

### Features
* [x] in `src/envelopes.f90`:
    * [x] The ADSR parameter of the envelope should be passed as arguments (via an object). (**)
    * [x] Add `apply_fade_in()` and `apply_fade_out()` subroutines. (*)
* [x] in `src/audio_effects.f90`:
    * [x] A subroutine `apply_reverse_effect()`. (*)
* [x] In `src/signals.f90`:
    * [x] add an optional envelope to `add_noise()`. (*)
    * [x] use `do concurrent` loops when possible. (*)
* [x] `mix_tracks()` could accept an optional array with panoramic settings. (*)
* [x] Broken chords routine. Would use Karplus-Strong algorithm (*),
    * [x] but that algorithm should be modified to not delete what is already present on the track: the track 0 could be used as an auxilliary track before copying on the track. (*)

### Examples
* [x] More examples. (**)
    * [x] Simulate [Doppler effect](https://en.wikipedia.org/wiki/Doppler_effect) (**)
    * [x] [Shepard–Risset glissando](http://csoundjournal.com/issue21/interp_visual_phenom.html) (***)
    * [x] An example using brokken chords.

### Documentation
* [ ] Add comments in examples to document the usage of the API. (*)


## Ideas for further developments

* [ ] Add more [audio effects](https://en.wikipedia.org/wiki/Category:Audio_effects)
    * [ ] Compressor (**)
    * [ ] Expander (?)
    * [ ] [Flanger](https://en.wikipedia.org/wiki/Flanging) (**)
    * [ ] [Phaser](https://en.wikipedia.org/wiki/Phaser_(effect)) (***)
    * [ ] [Chorus](https://en.wikipedia.org/wiki/Chorus_(audio_effect)) (***)
    * [ ] Reverb (***): https://freeverb3-vst.sourceforge.io/
    * [ ] Could Doppler effect be used to obtain a Leslie speaker effect?

* [ ] Examples
    * [ ] Synthesis: a bell (**)

* [ ] Find algorithms for good drums, especially bass drums.

* [ ] Physical modelling (***)
    * [ ] Using https://gitlab.com/certik/stringsim ?

* [ ] Soustractive synthesis: add filters (FFT?) (***)

* [ ] A drum pattern object to ease programming rhythms, inspired by the pattern system used in `example/drum_machine.f90`. Could be also used by ForMIDI. (***)
* [ ] A note sequencer repeating a pattern. Could be also used by ForMIDI. (***)
* [ ] A sequence object, accepting a string with notes, with methods to obtain one by one their parameters (physical or MIDI). Could be also used by ForMIDI. (***)
    * [ ] The sequence could for example be coded as "A4,Q.,pf;A#4,Q,pf;..." (note, length, intensity).

* [ ] A function converting dB to linear scale would be useful to set the sound level. (*)

* [ ] Scientific data sonification: by reading a data file? or by passing an array? (**)
