! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2025-02-05
! Last modifications: 2025-02-13

!> An example with a lot of bells, either periodic or random.
!> https://en.wikipedia.org/wiki/Campanology
program multiplication_bells
    use forsynth, only: wp
    use wav_file_class, only: WAV_file, tape_recorder
    use music, only: SEMITONE, PITCH
    use signals, only: add_bell

    implicit none
    type(WAV_file) :: demo
    ! Total duration in seconds:
    real(wp), parameter :: t2 = 75._wp
    ! Duration of the basic note:
    real(wp), parameter :: dnote = 3._wp
    ! Semitones for major third, fifth, 7th, octave, major third, fifth:
    integer, parameter :: shift(0:5) = [ 4, 7, 10, 12, 16, 19 ]
    integer, parameter  :: iend = 15    ! Nb of periods for the periodic bells
    integer  :: i               ! Loop counter
    real(wp) :: r1, r2, r3      ! Random numbers

    ! We create a new WAV file, and define the number of tracks and its duration:
    call demo%create_WAV_file('multiplication_bells.wav', tracks=1, duration=t2)
    print *, "**** Creating " // demo%get_name() // " ****"
    print *, "Be patient, it may take up to one minute..."

    associate(tape => demo%tape_recorder)

    ! Intro:
    call add_bell(tape, track=1, t1=0._wp, f=PITCH*SEMITONE**(-7), Amp=2._wp)

    ! Periodic bells:
    do i = 1, iend
        call add_bell(tape, track=1, t1=i*dnote,             f=PITCH*SEMITONE**(-4), Amp=1._wp)
        call add_bell(tape, track=1, t1=i*dnote + dnote/4,   f=PITCH*SEMITONE**(0) , Amp=1._wp)
        call add_bell(tape, track=1, t1=i*dnote + 3*dnote/4, f=PITCH*SEMITONE**(0) , Amp=1._wp)
    end do

    ! Random bells:
    do i = 1, 100
        call random_number(r1)  ! Starting time
        call random_number(r2)  ! Tone
        call random_number(r3)  ! Amplitude
        call add_bell(tape, track=1, t1=4._wp + (iend-2)*dnote*r1, f=PITCH*SEMITONE**(shift(int(r2*6))), Amp=1._wp*r3)
    end do

    ! Outro:
    call add_bell(tape, track=1, t1=(iend+2)*dnote, f=PITCH*SEMITONE**(-7), Amp=2._wp)

    end associate

    ! All tracks will be mixed on track 0.
    ! Needed even if there is only one track!
    call demo%mix_tracks()
    call demo%close_WAV_file()

    print *,"You can now play the file ", demo%get_name()
end program multiplication_bells
