![](logo/logo_forsynth.svg)

A small Fortran synthesizer to explore sound synthesis, sound effects, electronic music, algorithmic music, etc. But ForSynth can also be used for scientific data *sonification*, for acoustic simulations or for teaching programming in a fun way.

Humbly follow the steps of Stockhausen, Kraftwerk and the Daft Punk (see the [ELECTRONIC_MUSIC_HISTORY.md](./ELECTRONIC_MUSIC_HISTORY.md) file).

## Features

* ForSynth is a semi-analog semi-digital studio: time is discretized (44100 samples/s) but the amplitude is coded as a Fortran real and digitized as a 16 bits signed integer only after the final mixing, when generating the output WAV file.
* You can use as many stereo tracks as you need. The track 0 is used for the final mix and some algorithms also use it as an auxilliary track. Do you know The Beatles used a 8 tracks tape recorder the first time in August 1968 to record *Hey Jude*? The second song was *Dear Prudence*.
* Basic music theory elements (scales, circle of fifths, chords...).
* Various signals, Karplus-Strong algorithms (guitar and drums), bells.
* Envelopes generators: ADSR, fade in, fade out, exponentially decreasing envelope.
* Audio effects: delay, fuzz, tremolo, reverse, autopan, basic dynamic effects (compressor/expander/limiter).
* Data sonification routines and command.
* Morse code support.
* Final mixing with the level and panoramic of each track.
* The API is documented with FORD: https://vmagnin.github.io/forsynth/
* Various examples.
* You just need a modern Fortran compiler and a media player, whatever your OS.
* GPL-3.0-or-later license.

If you are more interested by composing than sound synthesis, you may also be interested by its twin project [ForMIDI](https://github.com/vmagnin/formidi).


## Compilation and execution

You can easily build the project using the Fortran Package Manager fpm (https://github.com/fortran-lang/fpm) at the root of the project directory:
```
$ fpm build
```

Or if you don't have fpm, you can use the `build.sh` script (the examples will be built inside the `build/` directory).

## Installation

You can install the library in your system with:

```bash
$ fpm install
```

In a Unix-like system, it will be typically installed in the `.local/lib` directory
of your `home/`.


### Running the examples
The examples can be found in the `example/` directory. For example, the `chords_and_melody.f90` example can be run with the command:

```bash
$ fpm run --example chords_and_melody
```

But you can also use the optimization flags of your compiler, for example with GFortran:
```shell
$ fpm run --example chords_and_melody --flag "-Ofast -static-libgfortran"
```

A WAV file was generated in the root directory of the project:

```bash
$ file chords_and_melody.wav
chords_and_melody.wav: RIFF (little-endian) data, WAVE audio, Microsoft PCM, 16 bit, stereo 44100 Hz
$ hexdump -C chords_and_melody.wav
00000000  52 49 46 46 a4 ff 42 01  57 41 56 45 66 6d 74 20  |RIFF..B.WAVEfmt |
00000010  10 00 00 00 01 00 02 00  44 ac 00 00 10 b1 02 00  |........D.......|
00000020  04 00 10 00 64 61 74 61  80 ff 42 01 3d 0e 3d 0e  |....data..B.=.=.|
00000030  56 03 56 03 d4 f5 d4 f5  9d 0e 9d 0e 91 f6 91 f6  |V.V.............|
...
```

You can listen to your WAV using any media player, for example the SoX play command (or the ALSA command `aplay`):

```bash
$ play chords_and_melody.wav

chords_and_melody.wav:

 File Size: 21.2M     Bit Rate: 1.41M
  Encoding: Signed PCM
  Channels: 2 @ 16-bit
Samplerate: 44100Hz
Replaygain: off
  Duration: 00:02:00.00

In:2.32% 00:00:02.79 [00:01:57.21] Out:123k  [!=====|=====!] Hd:0.0 Clip:0
```

You can also use [Audacity](https://www.audacityteam.org/) or [Sonic Visualiser](https://sonicvisualiser.org/) to visualise your music, either as a waveform or a spectrogram.


## Contributing

* Post a message in the GitHub *Issues* tab to discuss the function you want to work on.
* Concerning coding conventions, follow the stdlib conventions:
https://github.com/fortran-lang/stdlib/blob/master/STYLE_GUIDE.md
* When ready, make a *Pull Request*.

## Technical information

### Endianness

A WAV comprises a header with metadata then the soundtracks in PCM (https://en.wikipedia.org/wiki/Pulse-code_modulation), written in little endian. This program asserts your machine is little endian. If you are big endian, please use the `-fconvert=big-endian` flag with gfortran, or `-convert big_endian` with ifort. Or contribute to the code to allow an automatic detection of endianness.

* https://fortran-lang.discourse.group/t/writing-a-binary-file-in-little-endian/719/4
* https://en.wikipedia.org/wiki/Endianness

### WAV / RIFF format

* https://en.wikipedia.org/wiki/Resource_Interchange_File_Format
* https://en.wikipedia.org/wiki/WAV
* http://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/WAVE/WAVE.html

### Sound synthesis

* https://sites.google.com/site/learning4synthesizer/home
* https://en.wikipedia.org/wiki/Karplus%E2%80%93Strong_string_synthesis

### Miscellaneous

* https://en.wikipedia.org/wiki/Morse_code


## Bibliography
### English

* Jean-Claude Risset, ["Computer music: why ?"](https://www.posgrado.unam.mx/musica/lecturas/tecnologia/optativasRecomendadas/Risset_ComputerMusic%20why.pdf), 2003.
* Jean-Claude Risset, [*An Introductory Catalogue Of Computer Synthesized Sounds*](https://archive.org/details/an-introductory-catalogue-of-computer-synthesized-sounds/mode/2up), Bell Telephone Laboratories Murray Hill, New Jersey, 1969.
* Dave Benson, *[Music - A Mathematical Offering](https://homepages.abdn.ac.uk/d.j.benson/pages/html/music.pdf)*, 531 pages, 2008.
* Jeffrey Hass, [*Introduction to Computer Music - An Electronic Textbook*](https://cmtext.indiana.edu/index.php), Jacobs School of Music, Indiana University, 2023.
* David A. Jaffe and Julius O. Smith, “Extensions of the Karplus-Strong Plucked-String Algorithm.” *Computer Music Journal* 7, no. 2 (1983): 56. https://doi.org/10.2307/3680063.
* Kevin Karplus and Alex Strong, “Digital Synthesis of Plucked-String and Drum Timbres.” *Computer Music Journal* 7, no. 2 (1983): 43–55. https://doi.org/10.2307/3680062.
* Jarmo Lähdevaara, *Science of Electric Guitars and Guitar Electronics.* Helsinki, Finland: Books On Demand, 2012.
* Diana Deutsch, "The Paradox of Pitch Circularity"’. *Acoustics Today* 6, no. 3 (July 2010): 8–14. https://doi.org/10.1121/1.3488670.
* M.V. Mathews, ["The Digital Computer as a Musical Instrument"](http://www.jstor.org/stable/1712380), *Science* 142, no. 3592 (1963): 553–57.
    * ["The First Computer Musician"](https://archive.nytimes.com/opinionator.blogs.nytimes.com/2011/06/08/the-first-computer-musician/), by R. Luke DuBois, NYT, June 8, 2011.
* M.V. Mathews, F.R. Moore and J.-C. Risset, ["Computers and Future Music"](https://www.jstor.org/stable/1737597), *Science,* New Series, Vol. 183, No. 4122 (Jan. 25, 1974), pp. 263-268.
* Miguel Carvalho, Vincent Debut and Jose Antunes, "Physical Modelling Techniques for the Dynamical Characterization and Sound Synthesis of Historical Bells", *Heritage Science* (2021) 9:157, https://doi.org/10.1186/s40494-021-00620-2.

### French
* Vincent Magnin, ["Format WAV : créez des ondes sonores en C"](https://connect.ed-diamond.com/GNU-Linux-Magazine/GLMF-190/Format-WAV-creez-des-ondes-sonores-en-C), *GNU/Linux Magazine* n°190, février 2016.
* Vincent Magnin, ["Format WAV : des sons de plus en plus complexes"](https://connect.ed-diamond.com/GNU-Linux-Magazine/GLMF-190/Format-WAV-des-sons-de-plus-en-plus-complexes), *GNU/Linux Magazine* n°190, février 2016.
* Some sounds created with the C version of the program: http://magnin.plil.net/spip.php?article131
* Laurent de Wilde, [*Les fous du son - D'Edison à nos jours*](https://www.grasset.fr/livres/les-fous-du-son-9782246859277), Editions Grasset et Fasquelle, 560 pages, 2016, ISBN 9782246859277.
* Laurent Fichet, [*Les théories scientifiques de la musique aux XIXe et XXe siècles*](https://www.vrin.fr/livre/9782711642847/les-theories-scientifiques-de-la-musique), Vrin, 1996, ISBN 978-2-7116-4284-7.
* Guillaume Kosmicki , [*Musiques électroniques - Des avant-gardes aux dance floors*](https://lemotetlereste.com/musiques/musiqueselectroniquesnouvelleedition/), Editions Le mot et le reste, 2nd edition, 2016, 416 p., ISBN 9782360541928.
* Olivier Pernot, [*ELECTRO 100 - Les albums essentiels des musiques électroniques*](https://lemotetlereste.com/musiques/electro100nouvelleedition/), Editions Le mot et le reste, 2016, 240 p., ISBN 978-2-36054-202-4.
* Bibliothèque Tangente n°11, [*Mathématiques et musique - des destinées parallèles*](https://www.lalibrairie.com/livres/mathematiques-et-musique--des-destinees-paralleles--2022_0-9115242_9782848842462.html), Paris : Éditions POLE, septembre 2022, ISBN 9782848842462.
* Blog [Devenir Ingeson](https://deveniringeson.com/public/).
