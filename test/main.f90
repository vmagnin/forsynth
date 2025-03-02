! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modification: 2025-03-02

program main
    use, intrinsic :: ieee_arithmetic, only: ieee_is_nan
    use forsynth, only: wp, test_the_machine
    use signals, only: weierstrass
    use morse_code
    use acoustics, only: dB_to_linear

    implicit none

    ! Test the available KIND:
    call test_the_machine()

    !************************************************
    if (weierstrass(0.5_wp, 2.05_wp, 0._wp) /= +2._wp) error stop "ERROR weierstrass() [1]"

    !************************************************
    if (string_to_morse("RADIOACTIVITY") /= ".-. .- -.. .. --- .- -.-. - .. ...- .. - -.--") &
        & error stop "ERROR string_to_morse() [1]"

    if (string_to_morse("DISCOVERED BY MADAME CURIE") /= &
        & "-.. .. ... -.-. --- ...- . .-. . -..  -... -.--  -- .- -.. .- -- .  -.-. ..- .-. .. .") &
        & error stop "ERROR string_to_morse() [2]"

    !************************************************
    call assert_reals_equal(dB_to_linear(  0._wp), 1.0_wp,     tolerance=tiny(1._wp))
    call assert_reals_equal(dB_to_linear(-06._wp), 0.50118_wp, tolerance=1e-4_wp)
    call assert_reals_equal(dB_to_linear(-20._wp), 0.1_wp,     tolerance=tiny(1._wp))
    call assert_reals_equal(dB_to_linear(+20._wp), 10._wp,     tolerance=tiny(1._wp))
    !************************************************

contains

    ! A routine testing if a=b within the given tolerance.
    subroutine assert_reals_equal(a, b, tolerance)
        real(wp), intent(in)        :: a, b, tolerance
        real(wp)                    :: r
        character(len=*), parameter :: FORMATER = '(a,es22.15,a,es22.15,a,es8.1,a)'

        if (b /= 0.0_wp) then
            r = abs((a - b)/b)
        else
            r = abs(a - b)
        end if

        ! Note that the -Ofast compiler option is disabling ieee_is_nan()
        if (ieee_is_nan(a) .or. (r > tolerance)) then
            print FORMATER, "*** bug *** ", b, " /= ", a, " ; r = ", r
            error stop
        end if
    end subroutine assert_reals_equal

end program main
