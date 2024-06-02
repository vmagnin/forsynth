! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2024-05-30
! Last modifications: 2024-05-31

! Arpeggios played in various ways using the circles of fifths
! https://en.wikipedia.org/wiki/Arpeggio
program arpeggios
    use forsynth, only: wp
    use wav_file_class, only: WAV_file
    use music_common, only: MINOR_CHORD, MAJOR_CHORD, &
                          & CIRCLE_OF_FIFTHS_MAJOR, CIRCLE_OF_FIFTHS_MINOR
    use music, only: add_chord, add_broken_chord, fr, SEMITONE
    use signals, only: add_karplus_strong
    use envelopes, only: apply_fade_out

    implicit none
    type(WAV_file) :: demo
    integer  :: i
    real(wp) :: t, dur
    character(3) :: name

    print *, "**** Demo arpeggios ****"
    ! We create a new WAV file, and define the number of tracks and its duration:
    call demo%create_WAV_file('arpeggios.wav', tracks=2, duration=40._wp)

    associate(tape => demo%tape_recorder)

    ! Chord duration in seconds:
    dur = 0.75_wp

    print *, "Track 1: the circle of fifths major (left channel, octave 2)"
    t = 0.0_wp
    do i = 1, size(CIRCLE_OF_FIFTHS_MAJOR)
        name = trim(CIRCLE_OF_FIFTHS_MAJOR(i)) // "2"
        print *, i, name, fr(name)
        call add_broken_chord(tape, track=1, t1=t, t2=t+dur, f=fr(name), Amp=1.0_wp, chord=MAJOR_CHORD)
        t = t + dur
    end do

    print *, "The same, but the notes of each chord are played in an inverted order"
    do i = 1, size(CIRCLE_OF_FIFTHS_MAJOR)
        name = trim(CIRCLE_OF_FIFTHS_MAJOR(i)) // "2"
        print *, i, name, fr(name)
        call add_broken_chord(tape, track=1, t1=t, t2=t+dur, f=fr(name), Amp=1.0_wp, chord=MAJOR_CHORD(3:1:-1))
        t = t + dur
    end do

    print *, "Counterclockwise, the circle of fourths"
    do i = size(CIRCLE_OF_FIFTHS_MAJOR), 1, -1
        name = trim(CIRCLE_OF_FIFTHS_MAJOR(i)) // "2"
        call add_broken_chord(tape, track=1, t1=t, t2=t+dur, f=fr(name), Amp=1.0_wp, chord=MAJOR_CHORD)
        t = t + dur
    end do

    print *, "Once again, half the circle, slower and slower, with inverted arpeggios"
    do i = size(CIRCLE_OF_FIFTHS_MAJOR)/2, 1, -1
        name = trim(CIRCLE_OF_FIFTHS_MAJOR(i)) // "2"
        call add_broken_chord(tape, track=1, t1=t, t2=t+dur, f=fr(name), Amp=1.0_wp, chord=MAJOR_CHORD(3:1:-1))
        t = t + dur
        dur = dur * 1.1_wp
    end do

    print *, "We repeat the final chord"
    call add_broken_chord(tape, track=1, t1=t, t2=t+dur, f=fr(name), Amp=1.0_wp, chord=MAJOR_CHORD(3:1:-1))
    call add_karplus_strong(tape, track=1, t1=t+dur, t2=t+5*dur, f=fr(name)*SEMITONE**MAJOR_CHORD(3), Amp=1.0_wp)

    print *, "Track 2: the circle of fifths minor (right channel, octave 3)"
    dur = 0.75_wp
    t = 0.0_wp
    do i = 1, size(CIRCLE_OF_FIFTHS_MINOR)
        name = trim(CIRCLE_OF_FIFTHS_MINOR(i)) // "3"
        call add_broken_chord(tape, track=2, t1=t, t2=t+dur, f=fr(name), Amp=1.0_wp, chord=MINOR_CHORD)
        t = t + dur
    end do

    print *, "The same, but the notes of each chord are played in an inverted order"
    do i = 1, size(CIRCLE_OF_FIFTHS_MINOR)
        name = trim(CIRCLE_OF_FIFTHS_MINOR(i)) // "3"
        call add_broken_chord(tape, track=2, t1=t, t2=t+dur, f=fr(name), Amp=1.0_wp, chord=MINOR_CHORD(3:1:-1))
        t = t + dur
    end do

    print *, "Counterclockwise, the circle of fourths"
    do i = size(CIRCLE_OF_FIFTHS_MINOR), 1, -1
        name = trim(CIRCLE_OF_FIFTHS_MINOR(i)) // "3"
        call add_broken_chord(tape, track=2, t1=t, t2=t+dur, f=fr(name), Amp=1.0_wp, chord=MINOR_CHORD)
        t = t + dur
    end do

    print *, "Once again, half the circle, slower and slower, with inverted arpeggios"
    do i = size(CIRCLE_OF_FIFTHS_MINOR)/2, 1, -1
        name = trim(CIRCLE_OF_FIFTHS_MINOR(i)) // "3"
        call add_broken_chord(tape, track=2, t1=t, t2=t+dur, f=fr(name), Amp=1.0_wp, chord=MINOR_CHORD(3:1:-1))
        t = t + dur
        dur = dur * 1.1_wp
    end do

    print *, "We repeat the final chord and the final note"
    call add_broken_chord(tape, track=2, t1=t, t2=t+dur, f=fr(name), Amp=1.0_wp, chord=MINOR_CHORD(3:1:-1))
    call add_karplus_strong(tape, track=2, t1=t+dur, t2=t+5*dur, f=fr(name)*SEMITONE**MINOR_CHORD(3), Amp=1.0_wp)

    print *, "Final fade out"
    call apply_fade_out(tape, track=1, t1=t+dur,  t2=t+5*dur)
    call apply_fade_out(tape, track=2, t1=t+dur,  t2=t+5*dur)

    end associate

    print *, "Final mix..."
    ! In the mix, chords are rather on the left
    ! and plucked strings on the right (and their level is lowered):
    call demo%mix_tracks(levels=[1._wp, 1.2_wp], pan=[-0.5_wp, +0.5_wp])
    call demo%close_WAV_file()

    print *,"You can now play the file ", demo%get_name()
end program arpeggios
