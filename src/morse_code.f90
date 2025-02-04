! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2025-02-01
! Last modification: 2025-02-03

!> Basic Morse code support.
!> https://en.wikipedia.org/wiki/Morse_code

module morse_code
    use tape_recorder_class
    use signals, only: add_sine_wave

    implicit none

    private
    public :: string_to_morse, add_morse_code

    ! Alphabet (26) and numbers (10):
    character(len=5), parameter :: morse_table(36) = [  &
        '.-   ', '-... ', '-.-. ', '-..  ', '.    ', '..-. ', '--.  ', '.... ', '..   ', '.--- ', &
        '-.-  ', '.-.. ', '--   ', '-.   ', '---  ', '.--. ', '--.- ', '.-.  ', '...  ', '-    ', &
        '..-  ', '...- ', '.--  ', '-..- ', '-.-- ', '--.. ', &
        '-----', '.----', '..---', '...--', '....-', '.....', '-....', '--...', '---..', '----.' ]

contains

    !> This function receives a string and returns its Morse code translation.
    !> The input string can contain only alphabetic characters in upper or lower case,
    !> digits 0..9 and spaces. All other characters will be considered as spaces.
    !> Characters inside words are separated by one space, and words by two spaces.
    function string_to_morse(string) result(morse)
        character(len=*), intent(in)  :: string
        character(len=:), allocatable :: morse
        character(len=1) :: c
        integer :: i, k

        morse = ""
        do i = 1, len_trim(string)
            c = string(i:i)
            select case (c)
                case ('A':'Z')
                    k = iachar(c) - iachar('A') + 1
                case ('a':'z')
                    k = iachar(c) - iachar('a') + 1
                case ('0':'9')
                    k = iachar(c) - iachar('0') + 27
                case default
                    k = 0     ! A space
            end select

            if (k /= 0) then
                morse = morse // trim(morse_table(k)) // ' '
            else
                morse = morse // ' '
            end if
        end do

        morse = trim(morse)
    end function string_to_morse

    !> Adds on the specified track a Morse code translation of the string, starting at
    !> time t1. The frequency f must correspond to a high tone, for example 880 Hz.
    subroutine add_morse_code(tape, track, t1, f, Amp, string)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, f, Amp
        character(len=*), intent(in)  :: string

        character(len=1) :: c
        real(wp) :: t               ! Time in seconds
        real(wp) :: dot = 0.050_wp  ! The fundamental duration in seconds
        integer  :: i

        t = t1
        do i = 1, len_trim(string)
            c = string(i:i)
            select case (c)
                case ('.')
                    call add_sine_wave(tape, track, t, t+1*dot, f, Amp)
                    t = t + 1*dot
                case ('-')  ! A dash last three times longer than a dot
                    call add_sine_wave(tape, track, t, t+3*dot, f, Amp)
                    t = t + 3*dot
                case (' ')
                    t = t + (3-1)*dot   ! Silence between letters of a word,
                                        ! taking into account the silence added after END SELECT
                    ! A double space means we are between two words, and the
                    ! total silence must last 7 dots:
                    if (string(i+1:i+1) == ' ') then
                        t = t + 4*dot
                    end if
            end select

            t = t + dot     ! A silence between dots and dashes in a character
        end do
    end subroutine add_morse_code

end module morse_code
