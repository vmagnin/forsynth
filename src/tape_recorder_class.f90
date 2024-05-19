! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-19

module tape_recorder_class
    use forsynth, only: wp, RATE

    implicit none

    type tape_recorder
        ! Number of audio tracks (excluding track 0 reserved for the final mix):
        integer  :: tracks
        ! Duration in seconds:
        real(wp) :: duration
        ! Number of samples:
        integer  :: samples
        ! Two arrays stocking the stereo tracks:
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

        allocate(self%left (0:tracks, 0:self%samples))
        allocate(self%right(0:tracks, 0:self%samples))

        call self%clear_tracks()
    end subroutine

    ! Erase all tracks on all the channels of the tape.
    subroutine clear_tracks(self)
        class(tape_recorder), intent(inout)  :: self

        self%left  = 0.0_wp
        self%right = 0.0_wp
    end subroutine


    ! Tracks 1 to tracks-1 are mixed on track 0.
    subroutine mix_tracks(self, levels)
        class(tape_recorder), intent(inout)  :: self
        real(wp), dimension(1:self%tracks), intent(in), optional :: levels
        integer :: track

        do track = 1, self%tracks
            if (.not.present(levels)) then
                self%left(0, :)  = self%left(0, :)  + self%left(track, :)
                self%right(0, :) = self%right(0, :) + self%right(track, :)
            else
                self%left(0, :)  = self%left(0, :)  + levels(track) * self%left(track, :)
                self%right(0, :) = self%right(0, :) + levels(track) * self%right(track, :)
            end if
        end do
    end subroutine


    subroutine copy_section(self, from_track, to_track, t1, t2, t3)
        class(tape_recorder), intent(inout)  :: self
        ! Copy section t1...t2 at t3, either on the same track or another one.
        integer, intent(in)  :: from_track, to_track
        real(wp), intent(in) :: t1, t2, t3
        integer :: i, i0, j

        i0 = nint(t1*RATE)
        do i = i0, nint(t2*RATE)-1
            j = nint(t3*RATE) + (i-i0)
            if (j <= self%samples) then
                self%left(to_track,  j) = self%left(from_track,  i)
                self%right(to_track, j) = self%right(from_track, i)
            else
                exit
            end if
        end do
    end subroutine

    ! Called by the close_WAV_file() method.
    subroutine finalize(self)
        class(tape_recorder), intent(inout)  :: self

        deallocate(self%left)
        deallocate(self%right)
    end subroutine

    ! An automatic finalizer, by security.
    subroutine auto_finalize(self)
        type(tape_recorder), intent(inout)  :: self

        deallocate(self%left)
        deallocate(self%right)
    end subroutine

end module tape_recorder_class
