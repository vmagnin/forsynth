! Forsynth: a multitracks stereo sound synthesis project
! Copyright (C) Vincent Magnin, 2014-07-26 (C version)
! Fortran translation: 2021-02-16
! Last modification: 2021-02-21

program main
    use forsynth, only: test_the_machine
    use demos, only: demo1, demo2

    implicit none

    call test_the_machine()

    call demo1()
    call demo2()

end program main
