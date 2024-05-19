! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-19

! Plays sequentially each type of available signal.
program all_signals
    use forsynth, only: wp
    use wav_file_class, only: WAV_file
    use music, only: fr
    use signals, only: add_sine_wave, add_square_wave, &
                     & add_sawtooth_wave, add_triangle_wave, &
                     & add_karplus_strong, add_karplus_strong_stretched, &
                     & add_noise, add_weierstrass
    use envelopes, only: attack, decay

    implicit none
    type(WAV_file) :: demo
    real(wp) :: t, Dt
    real(wp) :: f_A

    print *, "**** Demo of the available signals ****"
    call demo%create_WAV_file('all_signals.wav', tracks=1, duration=30._wp)

    attack = 30.0_wp
    decay  = 20.0_wp

    ! Notes frequencies:
    f_A = fr("A3")             ! A 220 Hz
    ! Notes duration in seconds:
    Dt = 3.0_wp

    t = 0.0_wp
    print *, "Sinusoidal signal"
    call add_sine_wave(demo%tape_recorder, track=1, t1=t, t2=t+Dt, f=f_A, Amp=1.0_wp)
    print *, "Square wave"
    call add_square_wave(demo%tape_recorder, track=1, t1=t+Dt, t2=t+2*Dt, f=f_A, Amp=1.0_wp)
    print *, "Sawtooth wave"
    call add_sawtooth_wave(demo%tape_recorder, track=1, t1=t+2*Dt, t2=t+3*Dt, f=f_A, Amp=1.0_wp)
    print *, "Triangle wave"
    call add_triangle_wave(demo%tape_recorder, track=1, t1=t+3*Dt, t2=t+4*Dt, f=f_A, Amp=1.0_wp)
    print *, "Summing the four signals together"
    call add_sine_wave(demo%tape_recorder,     track=1, t1=t+4*Dt, t2=t+5*Dt, f=f_A, Amp=0.5_wp)
    call add_square_wave(demo%tape_recorder,   track=1, t1=t+4*Dt, t2=t+5*Dt, f=f_A, Amp=0.5_wp)
    call add_sawtooth_wave(demo%tape_recorder, track=1, t1=t+4*Dt, t2=t+5*Dt, f=f_A, Amp=0.5_wp)
    call add_triangle_wave(demo%tape_recorder, track=1, t1=t+4*Dt, t2=t+5*Dt, f=f_A, Amp=0.5_wp)
    print *, "Noise"
    call add_noise(demo%tape_recorder, track=1, t1=t+5*Dt, t2=t+6*Dt, Amp=1.0_wp)
    print *, "Weierstrass"
    call add_weierstrass(demo%tape_recorder, track=1, t1=t+6*Dt, t2=t+7*Dt, f=f_A, Amp=1.0_wp)
    print *, "Karplus Strong"
    call add_karplus_strong(demo%tape_recorder, track=1, t1=t+7*Dt, t2=t+8*Dt, f=f_A, Amp=1.0_wp)
    print *, "Karplus Strong stretched"
    call add_karplus_strong_stretched(demo%tape_recorder, track=1, t1=t+8*Dt, t2=t+9*Dt, f=f_A, Amp=1.0_wp)

    print *, "Final mix..."
    call demo%mix_tracks()
    call demo%close_WAV_file()

end program all_signals
