! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-31

! The main class that you will use to create your WAV files.
module wav_file_class
    use forsynth, only: wp, RATE, INT16, INT32, INT64
    use tape_recorder_class

    implicit none
    ! Maximum amplitude in a WAV [-32768 ; +32767]:
    integer, parameter :: MAX_AMPLITUDE = 32767
    integer :: status

    type, extends(tape_recorder)    :: WAV_file
      character(len=:), allocatable :: filename
      integer                       :: fileunit
    contains
      procedure :: create_WAV_file
      procedure :: close_WAV_file
      procedure :: get_name
      procedure, private :: write_header
      procedure, private :: write_normalized_data
    end type WAV_file

    private :: status

    public :: WAV_file

contains

    ! Create a WAV file with a header:
    subroutine create_WAV_file(self, filename, tracks, duration)
        class(WAV_file), intent(inout) :: self
        character(*), intent(in)       :: filename
        integer, intent(in)  :: tracks
        real(wp), intent(in) :: duration

        call self%new(tracks, duration)

        self%filename   = filename
        open(newunit=self%fileunit, file=self%filename, access='stream', status='replace', action='write')
        call self%write_header()
    end subroutine create_WAV_file

    ! Returns the name of the WAV file:
    function get_name(self)
        class(WAV_file), intent(inout) :: self
        character(len(self%filename)) :: get_name

        get_name = self%filename
    end function

    ! Creates the 44 bytes WAV header and prints some information:
    subroutine write_header(self)
        class(WAV_file), intent(inout)  :: self
        !****************
        ! WAV parameters:
        !****************
        ! Number of channels: 1 for mono, 2 for stereo, etc.
        integer(INT16), parameter :: CHANNELS = 2
        integer(INT16), parameter :: BITS_PER_SAMPLE = 16
        integer(INT64) :: DATA_BYTES
        integer(INT32) :: file_size, bytes_per_second, data_size
        integer(INT16) :: bytes_per_sample

        print *, "Nb of tracks, excluding track 0:", self%tracks

        DATA_BYTES = (BITS_PER_SAMPLE / 8) * CHANNELS * self%samples
        print *, "Used RAM:   ", DATA_BYTES * self%tracks, "bytes"
        print *, "File size ~ ", DATA_BYTES, "bytes"

        associate(u => self%fileunit)
            ! RIFF format:
            write(u, iostat=status) "RIFF"
            ! Remaining bytes after this data:
            file_size = 36 + DATA_BYTES
            write(u, iostat=status) file_size

            write(u, iostat=status) "WAVE"

            ! ***** First sub-chunk *****
            ! Don't remove the final space in the string!
            write(u, iostat=status) "fmt "
            ! Remaining bytes in this sub-chunk, 16 for PCM (32 bits integer):
            write(u, iostat=status) 16_INT32
            ! Encoding is 1 for PCM (16 bits integer):
            write(u, iostat=status) 1_INT16

            write(u, iostat=status) int(CHANNELS, kind=INT16)
            ! Sampling frequency:
            write(u, iostat=status) int(RATE, kind=INT32)

            bytes_per_second = RATE * CHANNELS * (BITS_PER_SAMPLE / 8)
            write(u, iostat=status) bytes_per_second

            bytes_per_sample = CHANNELS * (BITS_PER_SAMPLE / 8)
            write(u, iostat=status) bytes_per_sample

            write(u, iostat=status) BITS_PER_SAMPLE

            ! ***** Second sub-chunk *****
            write(u, iostat=status) "data"

            data_size = self%samples * CHANNELS * (BITS_PER_SAMPLE / 8)
            write(u, iostat=status) data_size
        end associate
    end subroutine write_header

    ! This method normalizes the sound amplitude on track 0, before saving
    ! the left and right channels in the WAV file.
    subroutine write_normalized_data(self)
        class(WAV_file), intent(inout)  :: self
        integer  :: i
        real(wp) :: maxi

        ! Looking for the maximum amplitude (must not be zero):
        maxi = max(1e-16_wp, maxval(abs(self%left(0, :))), maxval(abs(self%right(0, :))))

        do i = 0 , self%samples
            ! Writing the amplitude of left then right channels as 16 bit signed integers:
            write(self%fileunit, iostat=status) nint((self%left(0, i)  / maxi * MAX_AMPLITUDE), kind=INT16)
            write(self%fileunit, iostat=status) nint((self%right(0, i) / maxi * MAX_AMPLITUDE), kind=INT16)
        end do
    end subroutine

    ! Must be called at the end. It normalizes the channels, writes them in the
    ! WAV file and closes it. It also deallocate the tape arrays.
    subroutine close_WAV_file(self)
        class(WAV_file), intent(inout)  :: self

        call self%write_normalized_data()
        close(self%fileunit, iostat=status)

        call self%tape_recorder%finalize()
    end subroutine

end module wav_file_class
