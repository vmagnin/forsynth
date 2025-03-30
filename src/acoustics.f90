! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2025-03-02
! Last modification: 2025-03-13

!> A module with routines for acoustics.
module acoustics
    use forsynth, only: wp

    implicit none

    private
    public :: dB_to_linear, linear_to_dB

contains

    !> This function converts dB to an amplitude.
    !> At 0 dB, our amplitude reference value is 1.
    !> -6 dB is approximately 1/2 (~0.50118...).
    !> -20 dB is 1/10.
    !>  https://en.wikipedia.org/wiki/Decibel
    real(wp) pure function dB_to_linear(dB)
        real(wp), intent(in) :: dB

        ! dB = 20 * Log(amplitude / 1) implies:
        dB_to_linear = 10._wp ** (dB / 20._wp)
    end function

    !> This function converts an amplitude (>=0) to dB.
    !>  https://en.wikipedia.org/wiki/Decibel
    real(wp) pure function linear_to_dB(amp)
        real(wp), intent(in) :: amp

        if (amp /= 0._wp) then
            linear_to_dB = 20 * log10(abs(amp) / 1)
        else
            linear_to_dB = 20 * log10(epsilon(1._wp))
        end if
    end function

end module acoustics
