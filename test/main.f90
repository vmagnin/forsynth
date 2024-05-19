! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modification: 2024-04-24

program main
    use forsynth, only: wp, test_the_machine
    use signals, only: weierstrass

    implicit none

    ! Test the available KIND:
    call test_the_machine()

    if (weierstrass(0.5_wp, 2.05_wp, 0._wp) /= +2._wp) error stop "ERROR weierstrass() [1]"

end program main
