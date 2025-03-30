! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2025-03-22
! Last modification: 2025-03-30

!> A command to sonify a data file.
!> Example: $ fpm run sonify -- -i mydata.txt
!> (supposing the file is in the main directory of ForSynth)
!> You can get help by typing: $ fpm run sonify -- --help
program sonify
    use forsynth, only: RATE
    use sonification, only: sonify_from_file

    implicit none
    integer :: i, nb, status
    character(:), allocatable :: input_file, output_file, arg, str
    ! Default values:
    logical :: output = .false.         ! Is an output filename provided?
    logical :: autocenter = .false.
    integer :: down = 1                 ! Downsampling
    integer :: rep = 1                  ! Repetitions

    nb = command_argument_count()
    if (nb == 0) then
        call print_options()
        call print_copyright()
        stop      ! Nothing to do
    end if

    ! Scan the command line arguments:
    i = 0
    do while (i < nb)
        i = i + 1
        arg = read_argument(i, status)

        select case(trim(arg))
            case("-i", "--input")
                i = i + 1
                input_file = read_argument(i, status)
                if (status /= 0) then
                    print '(A)', "Problem with -i"
                    stop
                end if
            case("-o", "--output")
                i = i + 1
                output_file = read_argument(i, status)
                if (status /= 0) then
                    print '(A)', "Problem with -o"
                    stop
                end if
                output = .true.
            case("-c", "--center")
                autocenter = .true.
            case("-d", "--downsampling")
                i = i + 1
                str = read_argument(i, status)
                read(str, *) down
                if (status /= 0) then
                    print '(A)', "Problem with -d"
                    stop
                end if
            case("-r", "--repetitions")
                i = i + 1
                str = read_argument(i, status)
                read(str, *) rep
                if (status /= 0) then
                    print '(A)', "Problem with -r"
                    stop
                end if
            case("-h", "--help")
                call print_options()
                stop
            case("-v", "--version")
                call print_copyright()
                stop
            case default
                print '(2A)', "Unknown option ignored: ", trim(arg)
        end select
    end do

    if (output) then
        call sonify_from_file(input_file=trim(input_file), output_file=trim(output_file), &
             & autocenter=autocenter, downsampling=down, repetitions=rep)
    else
        call sonify_from_file(input_file=trim(input_file), &
             & autocenter=autocenter, downsampling=down, repetitions=rep)
    end if

contains

    !> Returns the argument number i of the command line.
    function read_argument(i, status)
        integer, intent(in)  :: i
        integer, intent(out) :: status
        character(:), allocatable :: read_argument, arg
        integer :: length

        ! We allocate the string with the needed length before reading it:
        call get_command_argument(i, length=length)
        allocate(character(length) :: arg)
        call get_command_argument(i, value=arg, status=status)

        read_argument = arg
    end function read_argument

    subroutine print_options
        print '(A)'
        print '(A)', "Usage: sonify -i FILE [OPTION]..."
        print '(A)'
        print '(A,I0,A)', "Sonify a data FILE to a WAV file using ", RATE, " samples per second."
        print '(A)'
        print '(A)', "Options :"
        print '(A)', "  -i, --input=FILE          name of the data file"
        print '(A)', "  -o, --output=FILE         name of the WAV file (default: sonification.wav)"
        print '(A)', "  -c, --center              autocenter the signal around zero"
        print '(A)', "  -d, --downsampling=NUM    downsampling factor (integer NUM>=1)"
        print '(A)', "  -r, --repetitions=NUM     repeat the data NUM times"
        print '(A)', "  -h, --help                display this help message"
        print '(A)', "  -v, --version             display copyright and license information"
        print '(A)'
        print '(A)', "Example: sonify -i itot.dat -o itot.wav -c -d 2 -r 5 "
        print '(A)'
        print '(A)', "Homepage: <https://github.com/vmagnin/forsynth>"
        print '(A)'
    end subroutine

    subroutine print_copyright
        print '(A)', "Sonify is part of the Fortran ForSynth project"
        print '(A)', "Copyright (C) 2025 Vincent Magnin"
        print '(A)', "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>"
        print '(A)', "This is free software: you are free to change and redistribute it."
        print '(A)', "There is NO WARRANTY, to the extent permitted by law."
    end subroutine

end program sonify
