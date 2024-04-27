! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-04-27

! Plays each type of available signal
program demo4
    use forsynth, only: dp, create_WAV_file, &
                      & finalize_WAV_file, clear_tracks, file_t
    use music, only: fr
    use signals, only: add_sine_wave, add_square_wave, &
                     & add_sawtooth_wave, add_triangle_wave, &
                     & add_karplus_strong, add_karplus_strong_stretched, &
                     & add_noise, add_weierstrass
    use envelopes, only: attack, decay

    implicit none
    type(file_t) :: d4
    real(dp) :: t, delta_t
    real(dp) :: f_A, r
    integer  :: i, k

    print *, "**** Demo 4 ****"
    call d4%create_WAV_file('demo4.wav')
    call clear_tracks()

    attack = 30.0_dp
    decay  = 20.0_dp

    ! Notes frequencies:
    f_A = fr("A3")             ! A 220 Hz
    ! Notes duration in seconds:
    delta_t = 3.0_dp
    t = 0.0_dp

    print *, "Sinusoidal signal"
    call add_sine_wave(1, t, t + delta_t, f_A, 1.0_dp)
    print *, "Square wave"
    call add_square_wave(1, t + delta_t, t + 2*delta_t, f_A, 1.0_dp)
    print *, "Sawtooth wave"
    call add_sawtooth_wave(1, t + 2*delta_t, t + 3*delta_t, f_A, 1.0_dp)
    print *, "Triangle wave"
    call add_triangle_wave(1, t + 3*delta_t, t + 4*delta_t, f_A, 1.0_dp)
    print *, "Summing the four signals together"
    call add_sine_wave(1, t + 4*delta_t, t + 5*delta_t, f_A, 0.5_dp)
    call add_square_wave(1, t + 4*delta_t, t + 5*delta_t, f_A, 0.5_dp)
    call add_sawtooth_wave(1, t + 4*delta_t, t + 5*delta_t, f_A, 0.5_dp)
    call add_triangle_wave(1, t + 4*delta_t, t + 5*delta_t, f_A, 0.5_dp)
    print *, "Noise"
    call add_noise(1, t + 5*delta_t, t + 6*delta_t, 1.0_dp)
    print *, "Weierstrass"
    call add_weierstrass(1, t + 6*delta_t, t + 7*delta_t, f_A, 1.0_dp)
    print *, "Karplus Strong"
    call add_karplus_strong(1, t + 7*delta_t, t + 8*delta_t,  f_A, 1.0_dp)
    print *, "Karplus Strong stretched"
    call add_karplus_strong_stretched(1, t + 8*delta_t, t + 9*delta_t,  f_A, 1.0_dp)

    print *, "Final mix..."
    call finalize_WAV_file()

end program demo4
