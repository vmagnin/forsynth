# Commands

This directory contains commands associated to the ForSynth library.

## sonify

A command to sonify a data file:

```bash
$ fpm run sonify -- -i mydata.txt
```
By default, the output file is named `sonification.wav`, but it can be changed
with the `-o` option. The `--` separates the fpm command and the options to pass
to the sonify command. The input file is supposed to be in the main directory
of the ForSynth project.

More information about all the options:

```bash
$ fpm run sonify -- --help
```

### Installation

You can install the command and library in your system with:

```bash
$ fpm install
```

In a Unix-like system, it will be typically installed in the `.local/lib` directory
of your `home/`. The command will then be available from any directory:

```bash
$ sonify -i mydata.txt
```
