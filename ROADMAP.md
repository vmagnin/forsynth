# Roadmap

## ForSynth 0.3

### Features
* [ ] Major and minor brokken chords routines.
* [x] A `music_common` module could gather the common code and parameters of ForMIDI and ForSynth.
* [x] Add other chords: 7th, Sus2, Sus4... using the `music_common` module.

### Examples
* [ ] Improve the artistic quality of some examples.

### Documentation
* [ ] Design a logo.



## Ideas for further developments

* [ ] The method `mix_tracks()` could accept an optional array with the levels of each track (same level by default).
* [ ] Use OOP.
* [ ] A drum pattern object to ease programming rhythms. Could be also used by ForMIDI.
* [ ] A sequence object, accepting a string with notes, with methods to obtain one by one their parameters (physical or MIDI). Could be also used by ForMIDI.
	* [ ] The sequence could for example be coded as "A4,Q.,pf;A#4,Q,pf;..." (note, length, intensity).
* [ ] Scientific data sonification.
