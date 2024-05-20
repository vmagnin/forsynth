# Roadmap

The stars in parenthesis are an evaluation of the difficulty.

## ForSynth 0.3 "Éliane Radigue"

### Development
* [x] Start an OOP approach.

### Features
* [x] A `music_common` module could gather the common code and parameters of ForMIDI and ForSynth.
* [x] Add other chords: 7th, Sus2, Sus4... using the `music_common` module.
* [x] The duration (120 seconds by default) and number of tracks should be set when we create a new WAV, instead of being hard-set.
* [x] The method `mix_tracks()` could accept an optional array with the final levels of each track.

### Examples
* [x] Improve the artistic quality of some examples.
* [x] A drone music example.

### Documentation
* [x] Design a logo.


## ForSynth 0.4 "?????"

### Development
* [ ] More OOP. (***)

### Features
* [ ] in `src/envelopes.f90`:
    * [ ] The ADSR parameter of the envelope should be passed as arguments. (*)
    * [ ] Add `fade_in()` and `fade_out()` functions or subroutines. (*)
* [ ] in `src/audio_effects.f90`:
    * [ ] A function reverse() (or backward) (*)
* [ ] `mix_tracks()` could accept an optional array with panoramic settings. (*)
* [ ] Major and minor brokken chords routines. Would use Karplus-Strong algorithm (*), 
    * [ ] but that algorithm should be modified to not delete what is already present on the track: the track 0 could be used as an auxilliary track before copying on the track. (*)

### Examples
* [ ] More examples. (**)
    * [ ] Simulate Doppler effect (*)
        * [ ] Could be used to obtain a Leslie speaker effect?

### Documentation
* [ ] Add comments in examples to document the usage of the API. (*)


## Ideas for further developments

* [ ] Add more [audio effects](https://en.wikipedia.org/wiki/Category:Audio_effects)
    * [ ] Compressor (**)
    * [ ] Expander (?)
    * [ ] [Flanger](https://en.wikipedia.org/wiki/Flanging) (**)
    * [ ] [Phaser](https://en.wikipedia.org/wiki/Phaser_(effect)) (***)
    * [ ] [Chorus](https://en.wikipedia.org/wiki/Chorus_(audio_effect)) (***)
    * [ ] Reverb (***)

* [ ] Examples
    * [ ] Synthesis: a bell (**)
    * [ ] [Shepard–Risset glissando](http://csoundjournal.com/issue21/interp_visual_phenom.html) (***)

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
