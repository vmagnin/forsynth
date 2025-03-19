! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2025-03-19

!> This is the basic class, representing a numeric tape recorder with audio tracks.
module tape_recorder_class
    use forsynth, only: wp, RATE

    implicit none

    type tape_recorder
        !> Number of audio tracks (excluding track 0 reserved for the final mix):
        integer  :: tracks
        !> Duration in seconds:
        real(wp) :: duration
        !> Number of samples:
        integer  :: samples
        !> Last sample index:
        integer  :: last
        !> Two arrays stocking the stereo tracks:
        real(wp), dimension(:, :), allocatable :: left, right
    contains
        procedure :: new
        procedure :: clear_tracks
        procedure :: mix_tracks
        procedure :: copy_section
        procedure :: finalize
        final     :: auto_finalize
    end type tape_recorder

    public :: tape_recorder

contains

    subroutine new(self, tracks, duration)
        class(tape_recorder), intent(inout)  :: self
        ! Track 0 excluded:
        integer, intent(in)  :: tracks
        real(wp), intent(in) :: duration

        self%duration = duration
        self%tracks = tracks

        self%samples = nint(duration * RATE)
        self%last = self%samples - 1

        allocate(self%left (0:tracks, 0:self%last))
        allocate(self%right(0:tracks, 0:self%last))

        call self%clear_tracks()
    end subroutine

    !> Erase all tracks on all the channels of the tape.
    subroutine clear_tracks(self)
        class(tape_recorder), intent(inout)  :: self

        self%left  = 0.0_wp
        self%right = 0.0_wp
    end subroutine


    !> Tracks 1 to tracks-1 are mixed on track 0.
    subroutine mix_tracks(self, levels, pan)
        class(tape_recorder), intent(inout)  :: self
        real(wp), dimension(1:self%tracks), intent(in), optional :: levels
        real(wp), dimension(1:self%tracks), intent(in), optional :: pan
        real(wp), dimension(1:self%tracks) :: pano
        real(wp) :: panL, panR
        integer  :: track

        ! As the track 0 can be used as an auxiliary track by some routines,
        ! it is important to clear it before the final mixing:
        self%left( 0, :) = 0.0_wp
        self%right(0, :) = 0.0_wp

        ! Pan is centered on 0 and -1 < pan < +1
        ! Default is 0:
        if (.not.present(pan)) then
            pano = 0._wp
        else
            ! Each element of pan(:) must be in [-1 ; +1]
            pano = max(-1._wp, min(+1._wp, pan))
        end if

        do track = 1, self%tracks
            ! Panoramic factors:
            if (pano(track) > 0._wp) then
                panL = 1._wp - pano(track)
                panR = 1._wp
            else if (pano(track) < 0._wp) then
                panL = 1._wp
                panR = 1._wp + pano(track)
            else
                panL = 1._wp
                panR = 1._wp
            end if

            if (.not.present(levels)) then
                self%left( 0, :) = self%left( 0, :) + panL * self%left( track, :)
                self%right(0, :) = self%right(0, :) + panR * self%right(track, :)
            else
                self%left( 0, :) = self%left( 0, :) + panL * levels(track) * self%left( track, :)
                self%right(0, :) = self%right(0, :) + panR * levels(track) * self%right(track, :)
            end if
        end do
    end subroutine


    !> Copy section t1...t2 at t3, either on the same track or another one.
    !> The content already present at t3 is overwritten.
    !> The code suppose that t1 < t2 < t3.
    subroutine copy_section(self, from_track, to_track, t1, t2, t3)
        class(tape_recorder), intent(inout)  :: self
        integer, intent(in)  :: from_track, to_track
        real(wp), intent(in) :: t1, t2, t3
        integer :: i, i1, i3

        i1 = nint(t1*RATE)
        do i = i1, min(nint(t2*RATE), self%last)
            ! The position of the sample receiving the copy:
            i3 = nint(t3*RATE) + (i-i1)
            ! To avoid pasting beyond the end of the track:
            if (i3 <= self%last) then
                self%left( to_track, i3) = self%left( from_track, i)
                self%right(to_track, i3) = self%right(from_track, i)
            else
                exit
            end if
        end do
    end subroutine

    !> Called by the close_WAV_file() method.
    subroutine finalize(self)
        class(tape_recorder), intent(inout)  :: self

        deallocate(self%left)
        deallocate(self%right)
    end subroutine

    !> An automatic finalizer, by security.
    subroutine auto_finalize(self)
        type(tape_recorder), intent(inout)  :: self

        deallocate(self%left)
        deallocate(self%right)
    end subroutine

end module tape_recorder_class
