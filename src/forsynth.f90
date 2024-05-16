! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-16

module forsynth
    use, intrinsic :: iso_fortran_env, only: INT16, INT32, INT64, REAL64

    implicit none
    ! Double precision reals:
    integer, parameter:: dp = REAL64

    real(dp), parameter :: PI = 4.0_dp * atan(1.0_dp)
    ! Maximum amplitude in a WAV [-32768 ; +32767]:
    integer, parameter  :: MAX_AMPLITUDE = 32767
    ! Duration in seconds:
    real(dp), parameter :: DURATION = 120.0_dp
    ! Sampling frequency and temporal step:
    integer, parameter  :: RATE = 44100
    real(dp), parameter :: dt = 1.0_dp / RATE
    ! Number of samples:
    integer, parameter  :: SAMPLES = nint(DURATION * RATE)
    ! Number of audio tracks (track 0 is reserved for the final mix):
    integer, parameter  :: TRACKS = 8
    ! Concert pitch (A note):
    real(dp), parameter :: PITCH = 440.0_dp

    ! Two arrays stocking the stereo tracks:
    real(dp), dimension(0:TRACKS, 0:SAMPLES) :: left, right

    public :: dp, test_the_machine, PITCH, PI, RATE, dt, TRACKS, &
            & DURATION, MAX_AMPLITUDE, SAMPLES, left, right, copy_section, &
            & clear_tracks, mix_tracks

contains

    subroutine test_the_machine
        ! A WAV file contains 32 bits and 16 bits data, so we need those kinds.

        if ((INT16 < 0) .or. (INT32 < 0)) then
            print *, "INT16 and/or INT32 not supported!"
            error stop 1
        end if
    end subroutine


    subroutine clear_tracks()
        ! Delete all tracks
        left  = 0.0_dp
        right = 0.0_dp
    end subroutine


    ! Tracks 1 to TRACKS-1 are mixed on track 0.
    subroutine mix_tracks(levels)
        real(dp), dimension(1:TRACKS-1), intent(in), optional :: levels
        integer :: track

        do track = 1, TRACKS-1
            if (.not.present(levels)) then
                left(0, :)  = left(0, :)  + left(track, :)
                right(0, :) = right(0, :) + right(track, :)
            else
                left(0, :)  = left(0, :)  + levels(track) * left(track, :)
                right(0, :) = right(0, :) + levels(track) * right(track, :)
            end if
        end do
    end subroutine


    subroutine copy_section(from_track, to_track, t1, t2, t3)
        ! Copy section t1...t2 at t3, either on the same track or another one.
        integer, intent(in)  :: from_track, to_track
        real(dp), intent(in) :: t1, t2, t3
        integer :: i, i0, j

        i0 = nint(t1*RATE)
        do i = i0, nint(t2*RATE)-1
            j = nint(t3*RATE) + (i-i0)
            if (j <= SAMPLES) then
                left(to_track,  j) = left(from_track,  i)
                right(to_track, j) = right(from_track, i)
            else
                exit
            end if
        end do
    end subroutine
end module forsynth
