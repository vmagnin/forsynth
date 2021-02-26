module music
    ! Various audio effects

    use forsynth, only: dp, PITCH, SEMITONE
    use signals, only: add_sine_wave

    implicit none

    ! We define some scales. We don't include the octave of the first note.
    ! Always use the trim() function to remove trailing spaces.
    ! https://en.wikipedia.org/wiki/Scale_(music)
    character(2), dimension(1:12) :: CHROMATIC_SCALE = &
               & (/'C ','C#','D ','D#','E ','F ','F#','G ','G#','A ','A#','B '/)
    ! https://en.wikipedia.org/wiki/Major_scale
    character(1), dimension(1:7) :: MAJOR_SCALE = (/'C','D','E','F','G','A','B'/)
    ! https://en.wikipedia.org/wiki/Minor_scale#Harmonic_minor_scale
    character(2), dimension(1:7) :: HARMONIC_MINOR_SCALE = &
                                    & (/'A ','B ','C ','D ','E ','F ','G#'/)
    ! https://en.wikipedia.org/wiki/Pentatonic_scale#Major_pentatonic_scale
    character(1), dimension(1:5) :: MAJOR_PENTATONIC_SCALE = (/'C','D','E','G','A'/)
    ! https://en.wikipedia.org/wiki/Hexatonic_scale#Blues_scale
    character(2), dimension(1:6) :: HEXATONIC_BLUES_SCALE = &
                                    & (/'C ','Eb','F ','Gb','G ','Bb'/)
    ! https://en.wikipedia.org/wiki/Whole_tone_scale
    character(2), dimension(1:6) :: WHOLE_TONE_SCALE = &
                                    & (/'C ','D ','E ','F#','G#','A#'/)

    private

    public :: add_note, add_major_chord, add_minor_chord, fr, CHROMATIC_SCALE, &
            & MAJOR_SCALE, MAJOR_PENTATONIC_SCALE, WHOLE_TONE_SCALE, &
            & HEXATONIC_BLUES_SCALE, HARMONIC_MINOR_SCALE

contains

    subroutine add_note(track, t1, t2, f, Amp)
        ! https://en.wikipedia.org/wiki/Harmonic
        integer, intent(in) :: track
        real(kind=dp), intent(in) :: t1, t2, f, Amp
        integer :: h

        ! Adding harmonics 1f to 40f, with a decreasing amplitude:
        do h = 1, 40
            call add_sine_wave(track, t1, t2, h*f, Amp / h**2)
        end do
    end subroutine

    subroutine add_major_chord(track, t1, t2, f, Amp)
        ! https://en.wikipedia.org/wiki/Major_chord
        integer, intent(in) :: track
        real(kind=dp), intent(in) :: t1, t2, f, Amp

        ! Root, major third and perfect fifth:
        call add_note(track, t1, t2, f, Amp)
        call add_note(track, t1, t2, f * SEMITONE**4, Amp)
        call add_note(track, t1, t2, f * SEMITONE**7, Amp)
    end subroutine

    subroutine add_minor_chord(track, t1, t2, f, Amp)
        ! https://en.wikipedia.org/wiki/Minor_chord
        integer, intent(in) :: track
        real(kind=dp), intent(in) :: t1, t2, f, Amp

        ! Root, minor third and perfect fifth:
        call add_note(track, t1, t2, f, Amp)
        call add_note(track, t1, t2, f * SEMITONE**3, Amp)
        call add_note(track, t1, t2, f * SEMITONE**7, Amp)
    end subroutine


    real(dp) function fr(note)
        ! Returns the frequency of the note.
        ! The note name is composed of two or three characters, 
        ! for example "A4", "A#4", "Ab4", where the final character is 
        ! the octave.
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
