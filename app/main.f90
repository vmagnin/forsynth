! Forsynth: a multitracks stereo sound synthesis project
! Copyright (C) Vincent Magnin, 2014-07-26 (C version)
! Fortran translation: 2021-02-16
! Last modification: 2021-02-19

program main
    use forsynth, only: dp, test_the_machine, create_WAV_file, PITCH, SEMITONE,&
                      & finalize_WAV_file
    use signals, only: add_sinusoidal_signal

    implicit none

    call test_the_machine()

    call create_WAV_file('output.wav')

    ! Three sinusoidal waves : C E G (9, 5, and 2 semitones below A)
    call add_sinusoidal_signal(0, 0.0_dp, 10.0_dp, PITCH * SEMITONE**(-9.0_dp), 1.0_dp)
    call add_sinusoidal_signal(1, 1.0_dp, 11.0_dp, PITCH * SEMITONE**(-5.0_dp), 1.0_dp)
    call add_sinusoidal_signal(2, 2.0_dp, 12.0_dp, PITCH * SEMITONE**(-2.0_dp), 1.0_dp)

    call finalize_WAV_file()
end program main
