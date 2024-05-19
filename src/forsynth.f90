! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-19

module forsynth
    use, intrinsic :: iso_fortran_env, only: INT16, INT32, INT64, REAL64

    implicit none
    ! Double precision reals:
    integer, parameter:: dp = REAL64
    real(dp), parameter :: PI = 4.0_dp * atan(1.0_dp)
    ! Maximum amplitude in a WAV [-32768 ; +32767]:
    integer, parameter  :: MAX_AMPLITUDE = 32767
    ! Sampling frequency and temporal step:
    integer, parameter  :: RATE = 44100
    real(dp), parameter :: dt = 1.0_dp / RATE

    public :: dp, test_the_machine, PI, RATE, dt, MAX_AMPLITUDE

contains

    subroutine test_the_machine
        ! A WAV file contains 32 bits and 16 bits data, so we need those kinds.

        if ((INT16 < 0) .or. (INT32 < 0)) then
            print *, "INT16 and/or INT32 not supported!"
            error stop 1
        end if
    end subroutine

end module forsynth
