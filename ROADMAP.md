# Roadmap

The stars in parenthesis are an evaluation of the difficulty.

## ForSynth 0.6

The main objectives would be to find algorithms for drums and to add sequencer 
features to ease composing. See the list of ideas below.


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

### Sonification
* [ ] If the tone is too high, inserting more data by interpolation could be used.
