! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modification: 2025-02-02

program main
    use forsynth, only: wp, test_the_machine
    use signals, only: weierstrass
    use morse_code

    implicit none

    ! Test the available KIND:
    call test_the_machine()

    if (weierstrass(0.5_wp, 2.05_wp, 0._wp) /= +2._wp) error stop "ERROR weierstrass() [1]"

    if (string_to_morse("RADIOACTIVITY") /= ".-. .- -.. .. --- .- -.-. - .. ...- .. - -.--") &
        & error stop "ERROR string_to_morse() [1]"

    print *, string_to_morse("RADIOACTIVITY")
    print *, string_to_morse("DISCOVERED BY MADAME CURIE")

    if (string_to_morse("DISCOVERED BY MADAME CURIE") /= &
        & "-.. .. ... -.-. --- ...- . .-. . -..  -... -.--  -- .- -.. .- -- .  -.-. ..- .-. .. .") &
        & error stop "ERROR string_to_morse() [2]"
end program main
