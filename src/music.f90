! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-16

module music
    !---------------------------------------------------------------------------
    ! Contains music theory elements: scales, circle of fifths, chords, etc.
    !---------------------------------------------------------------------------
    use forsynth, only: dp
    use signals, only: add_sine_wave
    ! Music theory elements common to the ForMIDI and ForSynth projects:
    use music_common
    use tape_recorder_class

    implicit none
    public

    ! Equal temperament: https://en.wikipedia.org/wiki/Equal_temperament
    real(dp), parameter :: SEMITONE = 2.0_dp**(1.0_dp/12.0_dp)
    ! Concert pitch (A note):
    real(dp), parameter :: PITCH = 440.0_dp

    public :: SEMITONE, PITCH, add_note, add_chord, fr

contains

    ! A note of fundamental frequency f with harmonics, based on sine waves:
    subroutine add_note(tape, track, t1, t2, f, Amp)
        type(tape_recorder), intent(inout) :: tape
        ! https://en.wikipedia.org/wiki/Harmonic
        integer, intent(in)  :: track
        real(dp), intent(in) :: t1, t2, f, Amp
        integer :: h

        ! Adding harmonics 1f to 40f, with a decreasing amplitude:
        do h = 1, 40
            call add_sine_wave(tape, track, t1, t2, h*f, Amp / h**2)
        end do
    end subroutine

    ! Writes a chord using an array containing the intervals
    ! (see the music_common module)
    subroutine add_chord(tape, track, t1, t2, f, Amp, chord)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(dp), intent(in) :: t1, t2, f, Amp
        integer, dimension(:), intent(in) :: chord
        integer :: i, interval

        do i = 1, size(chord)
            interval = chord(i)
            call add_note(tape, track, t1, t2, f * SEMITONE**interval, Amp)
        end do
    end subroutine add_chord

    ! Returns the frequency of the note.
    ! The note name is composed of two or three characters,
    ! for example "A4", "A#4", "Ab4", where the final character is
    ! the octave.
    real(dp) function fr(note)
        character(*), intent(in) :: note
        ! 0 <= octave <=9
        integer :: octave
        ! Gap relative to PITCH, in semitones:
        integer :: gap
        ! ASCII code of the 0 character:
        integer, parameter :: zero = iachar('0')

        select case (note(1:1))
            case ('C')
                gap = -9
            case ('D')
                gap = -7
            case ('E')
                gap = -5
            case ('F')
                gap = -4
            case ('G')
                gap = -2
            case ('A')
                gap = 0
            case ('B')
                gap = +2
            case default
                print*, "ERROR! Note name unknown..."
                stop
        end select

        ! Treating accidentals (sharp, flat) and computing the octave:
        select case (note(2:2))
            case ('b')
                gap = gap - 1
                octave = iachar(note(3:3)) - zero
            case ('#')
                gap = gap + 1
                octave = iachar(note(3:3)) - zero
            case default
                octave = iachar(note(2:2)) - zero
        end select

        if ((octave >= 0) .and. (octave <= 9)) then
            gap = gap + (octave - 4) * 12
        else
            print *, "ERROR! Octave out of bounds [0; 9]"
            stop
        end if

        ! Computing the frequency of the note:
        fr = PITCH * SEMITONE**(real(gap, dp))
    end function fr
end module music
