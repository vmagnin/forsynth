! ForMIDI: a small Fortran MIDI sequencer for composing music, exploring
!          algorithmic music and music theory
! License GPL-3.0-or-later
! Vincent Magnin, 2024-05-09
! Last modifications: 2024-05-09

module music_common
    !---------------------------------------------------------------------------
    ! Contains music theory elements: scales, circle of fifths, chords, etc.
    !
    ! This file will be kept identical in the ForMIDI and ForSynth projects.
    ! It could be put in a separate fpm repository and used as a dependency,
    ! but for the time being, synchronizing it by hand is sufficient.
    !---------------------------------------------------------------------------

    implicit none
    public

    ! We define some scales, excluding the octave of the first note.
    ! Always use the trim() function to remove trailing spaces.
    ! https://en.wikipedia.org/wiki/Scale_(music)
    character(2), dimension(1:12), parameter :: CHROMATIC_SCALE = &
                 & ['C ','C#','D ','D#','E ','F ','F#','G ','G#','A ','A#','B ']
    ! https://en.wikipedia.org/wiki/Major_scale
    character(1), dimension(1:7),  parameter :: MAJOR_SCALE = &
                                                 & ['C','D','E','F','G','A','B']
    ! https://en.wikipedia.org/wiki/Minor_scale#Harmonic_minor_scale
    character(2), dimension(1:7),  parameter :: HARMONIC_MINOR_SCALE = &
                                          & ['A ','B ','C ','D ','E ','F ','G#']
    ! https://en.wikipedia.org/wiki/Pentatonic_scale#Major_pentatonic_scale
    character(1), dimension(1:5),  parameter :: MAJOR_PENTATONIC_SCALE = &
                                                         & ['C','D','E','G','A']
    ! https://en.wikipedia.org/wiki/Hexatonic_scale#Blues_scale
    character(2), dimension(1:6),  parameter :: HEXATONIC_BLUES_SCALE = &
                                               & ['C ','Eb','F ','Gb','G ','Bb']
    ! https://en.wikipedia.org/wiki/Whole_tone_scale
    character(2), dimension(1:6),  parameter :: WHOLE_TONE_SCALE = &
                                               & ['C ','D ','E ','F#','G#','A#']

    ! https://en.wikipedia.org/wiki/Circle_of_fifths
    ! Always use the trim() function to remove trailing spaces.
    character(2), dimension(1:12) :: CIRCLE_OF_FIFTHS_MAJOR = &
                 & ['C ','G ','D ','A ','E ','B ','Gb','Db','Ab','Eb','Bb','F ']
    character(2), dimension(1:12) :: CIRCLE_OF_FIFTHS_MINOR = &
                 & ['A ','E ','B ','F#','C#','G#','Eb','Bb','F ','C ','G ','D ']

    ! Some frequent chords.
    ! These arrays can be passed to the write_chord() subroutine.
    ! https://en.wikipedia.org/wiki/Chord_(music)
    integer, parameter :: MAJOR_CHORD(1:3) = [ 0, 4, 7 ]
    integer, parameter :: MINOR_CHORD(1:3) = [ 0, 3, 7 ]
    integer, parameter :: DOMINANT_7TH_CHORD(1:4) = [ 0, 4, 7, 10 ]
    integer, parameter :: SUS2_CHORD(1:3) = [ 0, 2, 7 ]
    integer, parameter :: SUS4_CHORD(1:3) = [ 0, 5, 7 ]
    integer, parameter :: POWER_CHORD(1:3) = [ 0, 7, 12 ]
    integer, private   :: j    ! Needed for the following implied do loop:
    integer, parameter :: CLUSTER_CHORD(1:12) = [(j, j=0, 11)]

contains

end module music_common
