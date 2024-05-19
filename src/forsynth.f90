! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-19

module forsynth
    use, intrinsic :: iso_fortran_env, only: INT16, INT32, INT64, REAL32, REAL64

    implicit none
    ! The default working precision wp is REAL64.
    ! REAL32 can be set: it will accelerate computations and give good results
    ! most of the time. But in certain situations, for example drone music, it
    ! can introduce artefacts.
    integer, parameter  :: wp = REAL64
    real(wp), parameter :: PI = 4.0_wp * atan(1.0_wp)

    ! Sampling frequency and temporal step:
    integer, parameter  :: RATE = 44100
    real(wp), parameter :: dt = 1.0_wp / RATE

    public :: wp, test_the_machine, PI, RATE, dt

contains

    subroutine test_the_machine
        ! A WAV file contains 32 bits and 16 bits data, so we need those kinds.

        if ((INT16 < 0) .or. (INT32 < 0)) then
            print *, "INT16 and/or INT32 not supported!"
            error stop 1
        end if
    end subroutine

end module forsynth
