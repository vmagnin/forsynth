! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modification: 2024-04-24

program main
    use forsynth, only: dp, test_the_machine
    use signals, only: weierstrass

    implicit none

    ! Test the available KIND:
    call test_the_machine()

    if (weierstrass(0.5_dp, 2.05_dp, 0._dp) /= +2._dp) error stop "ERROR weierstrass() [1]"

end program main
