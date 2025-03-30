! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modification: 2025-03-30

program sonification
    use forsynth, only: wp
    use sonification

    implicit none
    integer, parameter :: N = 44100
    real(wp) :: array(N)
    integer :: i

    ! Generating a simple signal:
    array = [(sin(i*0.01_wp)*cos(i*0.1_wp), i = 1, N)]
    call sonify_from_array(signal=array, output_file="test_array_sonification.wav", downsampling=4, repetitions=4)

    call sonify_from_file(input_file="test/signal.dat", output_file="test_signal_sonification.wav", autocenter=.true., repetitions=15)

end program sonification
