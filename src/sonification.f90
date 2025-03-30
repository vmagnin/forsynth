! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2025-03-22
! Last modification: 2025-03-30

!> A module with routines for data sonification.
module sonification
    use forsynth, only: wp, RATE
    use wav_file_class, only: WAV_file

    implicit none

    private
    public :: sonify_from_array, sonify_from_file

contains

    !> Convert an array of reals to a WAV file, using RATE samples per second
    !> (44,100 by default).
    !> - If your signal is not centered around zero, you can use the autocenter option.
    !> - Downsampling allows to take only each Mth sample and can be used to
    !> make a low tone higher.
    !> - The repetitions argument allows to repeat the signal N times, which can
    !> be interesting if it is too short.
    subroutine sonify_from_array(signal, output_file, autocenter, downsampling, repetitions)
        real(wp), dimension(:), intent(in) :: signal
        character(*), intent(in)      :: output_file
        logical, intent(in), optional :: autocenter
        integer, intent(in), optional :: downsampling
        integer, intent(in), optional :: repetitions        ! Including the original
        integer :: i, step, j, sz
        real(wp) :: length, delta
        type(WAV_file) :: tape

        sz = size(signal)

        delta = 0._wp
        if (present(autocenter)) then
            ! Center the signal on 0 by subtracting its mean value:
            if (autocenter) delta = sum(signal)/sz
        end if

        if (present(downsampling)) then
            ! Downsampling factor must be >=1
            step = max(1, downsampling)
        else
            step = 1
        end if

        length = real(sz, kind=wp) / RATE
        if (present(repetitions)) then
            length = length * repetitions
        end if
        length = length /step + 0.01_wp       ! To avoid rounding problems

        ! We can now create a new WAV file:
        call tape%create_WAV_file(output_file, tracks=1, duration=length)

        j = 0
        ! The signal array index begins at 1:
        do i = 1, sz, step
            j = j + 1
            ! Track 1, sample j-1:
            tape%left (1, j-1) = signal(i) - delta
            tape%right(1, j-1) = signal(i) - delta
        end do

        ! Repeat if needed:
        if (present(repetitions)) then
            if (repetitions >= 2) then
                ! Size after subsampling:
                sz = j
                do i = 2, repetitions
                    tape%left (1, (i-1)*sz:i*sz - 1) = tape%left (1, (i-2)*sz:(i-1)*sz - 1)
                    tape%right(1, (i-1)*sz:i*sz - 1) = tape%right(1, (i-2)*sz:(i-1)*sz - 1)
                end do
            end if
        end if

        ! All tracks will be mixed on track 0.
        ! Needed even if there is only one track!
        call tape%mix_tracks()
        call tape%close_WAV_file()

        print *,"You can now play the file ", tape%get_name()
    end subroutine sonify_from_array

    !> Read a text file containing only one column of reals, without header,
    !> and convert it to a WAV file.
    !> If your file contains several fields (columns), you must extract the field
    !> to sonify. In Unix-like systems, it can be easily done, for example:
    !> $ cut -f 4 -d " " data.txt > column.txt
    !> The file should contain several 100,000 lines as the WAV will use generally
    !> 44,100 samples per second.
    !> - If your signal is not centered around zero, you can use the autocenter option.
    !> - Downsampling allows to take only each Mth sample and can be used to
    !> make a low tone higher.
    !> - The repetitions argument allows to repeat the signal N times, which can
    !> be interesting if it is too short.
    subroutine sonify_from_file(input_file, output_file, autocenter, downsampling, repetitions)
        character(*), intent(in)           :: input_file
        character(*), intent(in), optional :: output_file
        logical, intent(in), optional :: autocenter
        integer, intent(in), optional :: downsampling
        integer, intent(in), optional :: repetitions    ! Including the original
        ! Autocenter, downsampling, repetitions variables:
        logical  :: ac
        integer  :: down, rep
        integer  :: i
        ! For reading the input file:
        logical  :: found
        integer  :: file_unit, ios
        integer  :: n                   ! Number of data lines
        real(wp) :: y                   ! Data to read
        real(wp), dimension(:), allocatable :: array    ! Unknown size
        ! Name of the output file:
        character(:), allocatable :: wav_file

        inquire(file=input_file, exist=found)
        if (found) then
            ! First scan: how many lines n does the file contain?
            n = 0
            open(newunit=file_unit, file=input_file, action="read")
            do
                read(file_unit, *, iostat=ios) y
                if (ios /= 0) exit      ! End of file, if no other problem

                n = n + 1
            end do
            allocate(array(1:n))

            ! Second scan: we can now read the data and put them in the array
            rewind(file_unit)
            do i = 1, n
                read(file_unit, *, iostat=ios) array(i)
                if (ios /= 0) exit
            end do
            close(file_unit)

            ac = .false.
            if (present(autocenter)) then
                if (autocenter) ac = .true.
            end if

            if (present(downsampling)) then
                down = downsampling
            else
                down = 1
            end if

            if (present(repetitions)) then
                rep = repetitions
            else
                rep = 1
            end if

            if (present(output_file)) then
                wav_file = trim(output_file)
            else
                ! Default name:
                wav_file = "sonification.wav"
            end if

            call sonify_from_array(signal=array, output_file=wav_file, &
                 & autocenter=ac, downsampling=down, repetitions=rep)
        else
            error stop "File not found!"
        end if
    end subroutine sonify_from_file

end module sonification
