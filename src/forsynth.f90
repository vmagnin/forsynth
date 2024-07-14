! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-07-14

!> This module contains a few parameters, especially the sampling frequency and
!> the temporal step.
module forsynth
    use, intrinsic :: iso_fortran_env, only: INT16, INT32, INT64, REAL32, REAL64

    implicit none
    private
    !> The default working precision wp is REAL64.
    !> REAL32 can be set: it will accelerate computations and give good results
    !> most of the time. But in certain situations, for example drone music, it
    !> can introduce artefacts.
    integer, parameter  :: wp = REAL64
    real(wp), parameter :: PI = 4.0_wp * atan(1.0_wp)

    ! Sampling frequency and temporal step:
    integer, parameter  :: RATE = 44100
    real(wp), parameter :: dt = 1.0_wp / RATE

    public :: wp, test_the_machine, PI, RATE, dt

contains

    !> A WAV file contains 64, 32 and 16 bits data or metadata,
    !> so we need those kinds.
    subroutine test_the_machine
        if ((INT16 < 0) .or. (INT32 < 0) .or. (INT64 < 0)) then
            print *, "Some INT types are not supported!"
            print *, "INT16: ", INT16
            print *, "INT32: ", INT32
            print *, "INT64: ", INT64
            error stop 1
        end if
    end subroutine

end module forsynth
