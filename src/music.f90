module music
    ! Various audio effects

    use forsynth, only: dp, SEMITONE
    use signals, only: add_sinusoidal_signal

    implicit none

    private

    public :: add_note, add_major_chord, add_minor_chord

contains

    subroutine add_note(track, t1, t2, f, Amp)
        ! https://en.wikipedia.org/wiki/Harmonic
        integer, intent(in) :: track
        real(kind=dp), intent(in) :: t1, t2, f, Amp
        integer :: h

        ! Adding harmonics 1f to 40f, with a decreasing amplitude:
        do h = 1, 40
            call add_sinusoidal_signal(track, t1, t2, h*f, Amp / h**2)
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

end module music
