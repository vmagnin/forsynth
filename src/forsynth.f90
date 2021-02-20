module forsynth
    use ISO_FORTRAN_ENV, only: INT16, INT32, INT64, REAL64

    implicit none
    integer, parameter:: dp = REAL64
    integer :: status
    ! Output unit:
    integer :: u
    real(kind=dp), parameter :: PI = 4.0_dp * atan(1.0_dp)
    real(kind=dp), parameter :: SEMITONE = 2.0_dp**(1.0_dp/12.0_dp)
    ! Maximum amplitude in a WAV [-32768 ; +32767]:
    integer, parameter :: MAX_AMPLITUDE = 32767
    ! Duration in seconds:
    real(kind=dp), parameter :: DURATION = 120.0_dp
    ! Sampling frequency:
    integer, parameter :: RATE = 44100
    ! Number of samples:
    integer, parameter :: SAMPLES = int(DURATION * RATE)
    ! Number of audio tracks (track 0 is reserved for the final mix):
    integer, parameter :: TRACKS = 8
    ! Concert pitch (A note):
    real(kind=dp), parameter :: PITCH = 440d0

    ! Two arrays stocking the stereo tracks:
    real(kind=dp), dimension(0:TRACKS, 0:SAMPLES) :: left, right

    private :: u, status, write_header, mix_tracks, write_normalized_data, &
             & MAX_AMPLITUDE, SAMPLES

    public :: dp, test_the_machine, PITCH, PI, SEMITONE, RATE, TRACKS, &
            & DURATION, left, right, finalize_WAV_file
contains

    subroutine test_the_machine
        ! A WAV file contains 32 bits and 16 bits data, so we need those kinds.

        if ((INT16 < 0) .or. (INT32 < 0)) then
            print *, "INT16 and/or INT32 not supported!"
            error stop 1
        end if
    end subroutine


    subroutine create_WAV_file(file_name)
        character(len=*), intent(in) :: file_name

        open(unit=u, file=file_name, access='stream', status='replace', &
         action='write', iostat=status)

        call write_header()
    end subroutine


    subroutine write_header()
        ! Creates the WAV header (44 bytes)
        ! and prints some information.

        !****************
        ! WAV parameters:
        !****************
        ! Number of channels: 1 for mono, 2 for stereo, etc.
        integer(INT16), parameter :: CHANNELS = 2
        integer(INT16), parameter :: BITS_PER_SAMPLE = 16
        integer(INT64), parameter :: DATA_BYTES = (BITS_PER_SAMPLE / 8) &
                                   & * CHANNELS * SAMPLES
        integer(INT32) :: file_size, bytes_per_second, data_size
        integer(INT16) :: bytes_per_sample

        print *, "Tracks:", TRACKS
        print *, "RAM:        ", DATA_BYTES * TRACKS, "bytes"
        print *, "File size ~ ", DATA_BYTES, "bytes"

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

        data_size = SAMPLES * CHANNELS * (BITS_PER_SAMPLE / 8)
        write(u, iostat=status) data_size
    end subroutine write_header


    subroutine mix_tracks()
        ! Tracks 1 to TRACKS-1 are mixed on track 0.
        integer :: track

        do track = 1, TRACKS-1
            left(0, :)  = left(0, :)  + left(track, :)
            right(0, :) = right(0, :) + right(track, :)
        end do
    end subroutine


    subroutine write_normalized_data()
        ! This routine normalizes the sound amplitude on track 0, before saving
        ! the left and right channels in the WAV file.
        integer :: i
        real(kind=dp) :: maxi

        ! Looking for the maximum amplitude (must not be zero):
        maxi = max(1e-16_dp, maxval(abs(left(0, :))), maxval(abs(right(0, :))))

        do i = 0 , SAMPLES
            ! Writing the amplitude of left then right channels as 16 bit 
            ! signed integers:
            write(u, iostat=status) int((left(0, i)  / maxi * MAX_AMPLITUDE), kind=INT16)
            write(u, iostat=status) int((right(0, i) / maxi * MAX_AMPLITUDE), kind=INT16)
        end do
    end subroutine


    subroutine finalize_WAV_file()
        call mix_tracks()
        call write_normalized_data()
        close(u, iostat=status)
    end subroutine
end module forsynth
