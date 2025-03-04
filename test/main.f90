! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modification: 2025-03-04

program main
    use, intrinsic :: ieee_arithmetic, only: ieee_is_nan
    use forsynth, only: wp, test_the_machine
    use signals, only: weierstrass
    use morse_code
    use acoustics, only: dB_to_linear
    use envelopes, only: fit_exp, ADSR_envelope
    use music, only: fr

    implicit none

    ! 2.2204460492503131E-016 with real64:
    real(wp), parameter :: tol = 10*epsilon(1._wp)

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
    call assert_reals_equal(dB_to_linear(  0._wp), 1.0_wp,     tolerance=tol)
    call assert_reals_equal(dB_to_linear(-06._wp), 0.50118_wp, tolerance=1e-4_wp)
    call assert_reals_equal(dB_to_linear(-20._wp), 0.1_wp,     tolerance=tol)
    call assert_reals_equal(dB_to_linear(+20._wp), 10._wp,     tolerance=tol)

    !************************************************
    call assert_reals_equal(fit_exp(-1._wp, x1=0._wp, y1=1._wp, x2=1._wp, y2=exp(1._wp)), &
                          & exp(-1._wp), tolerance=tol)
    call assert_reals_equal(fit_exp(0._wp, x1=-1._wp, y1=exp(-1._wp), x2=+1._wp, y2=exp(+1._wp)), &
                          & 1._wp, tolerance=tol)

    !************************************************
    call assert_reals_equal(fr("A4"),  440.0_wp, tolerance=tol)
    call assert_reals_equal(fr("A3"),  220.0_wp, tolerance=tol)
    call assert_reals_equal(fr("A5"),  880.0_wp, tolerance=tol)
    call assert_reals_equal(fr("G4"),  440.0_wp*2**(-2/12._wp), tolerance=tol)
    call assert_reals_equal(fr("F#4"), 440.0_wp*2**(-3/12._wp), tolerance=tol)
    call assert_reals_equal(fr("Fb4"), 440.0_wp*2**(-5/12._wp), tolerance=tol)

    !************************************************
    block
        type(ADSR_envelope) :: env
        call env%new(A=30._wp, D=20._wp, S=80._wp, R=30._wp)
        call assert_reals_equal(env%get_level(t=0._wp,  t1=0._wp, t2=100._wp),  0._wp,  tolerance=tol)
        call assert_reals_equal(env%get_level(t=100._wp,t1=0._wp, t2=100._wp),  0._wp,  tolerance=tol)
        call assert_reals_equal(env%get_level(t=30._wp, t1=0._wp, t2=100._wp),  1._wp,  tolerance=tol)
        call assert_reals_equal(env%get_level(t=15._wp, t1=0._wp, t2=100._wp),  0.5_wp, tolerance=tol)
        call assert_reals_equal(env%get_level(t=40._wp, t1=0._wp, t2=100._wp),  0.9_wp, tolerance=tol)
        call assert_reals_equal(env%get_level(t=60._wp, t1=0._wp, t2=100._wp),  0.8_wp, tolerance=tol)
        call assert_reals_equal(env%get_level(t=85._wp, t1=0._wp, t2=100._wp),  0.4_wp, tolerance=tol)
    end block

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
