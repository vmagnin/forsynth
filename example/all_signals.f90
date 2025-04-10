! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2025-03-02

!> Plays sequentially each type of available signal.
program all_signals
    use forsynth, only: wp
    use wav_file_class, only: WAV_file
    use music, only: fr
    use signals, only: add_sine_wave, add_square_wave, &
                     & add_sawtooth_wave, add_triangle_wave, &
                     & add_karplus_strong, add_karplus_strong_stretched, &
                     & add_noise, add_weierstrass, add_bell
    use envelopes, only: ADSR_envelope

    implicit none
    type(WAV_file) :: demo
    type(ADSR_envelope) :: env
    real(wp) :: t, dnote
    real(wp) :: f_A

    print *, "**** Demo of the available signals ****"
    ! We create a new WAV file, and define the number of tracks and its duration:
    call demo%create_WAV_file('all_signals.wav', tracks=1, duration=30._wp)
    ! We create an ADSR envelope that will be passed to signals:
    call env%new(A=30._wp, D=20._wp, S=80._wp, R=30._wp)

    ! Notes frequencies are obtained with the fr() function:
    f_A = fr("A3")             ! A 220 Hz
    ! Notes duration in seconds:
    dnote = 3.0_wp

    t = 0.0_wp

    associate(tape => demo%tape_recorder)

    ! We add each signal on the track between times t1 and t2:
    print *, "Sinusoidal signal"
    call add_sine_wave(tape, track=1, t1=t, t2=t+dnote, f=f_A, Amp=1.0_wp, envelope=env)
    print *, "Square wave"
    call add_square_wave(tape, track=1, t1=t+dnote, t2=t+2*dnote, f=f_A, Amp=1.0_wp, envelope=env)
    print *, "Sawtooth wave"
    call add_sawtooth_wave(tape, track=1, t1=t+2*dnote, t2=t+3*dnote, f=f_A, Amp=1.0_wp, envelope=env)
    print *, "Triangle wave"
    call add_triangle_wave(tape, track=1, t1=t+3*dnote, t2=t+4*dnote, f=f_A, Amp=1.0_wp, envelope=env)
    print *, "Summing the four signals together"
    call add_sine_wave(tape,     track=1, t1=t+4*dnote, t2=t+5*dnote, f=f_A, Amp=0.5_wp, envelope=env)
    call add_square_wave(tape,   track=1, t1=t+4*dnote, t2=t+5*dnote, f=f_A, Amp=0.5_wp, envelope=env)
    call add_sawtooth_wave(tape, track=1, t1=t+4*dnote, t2=t+5*dnote, f=f_A, Amp=0.5_wp, envelope=env)
    call add_triangle_wave(tape, track=1, t1=t+4*dnote, t2=t+5*dnote, f=f_A, Amp=0.5_wp, envelope=env)
    print *, "Noise"
    call add_noise(tape, track=1, t1=t+5*dnote, t2=t+6*dnote, Amp=1.0_wp, envelope=env)
    print *, "Weierstrass"
    call add_weierstrass(tape, track=1, t1=t+6*dnote, t2=t+7*dnote, f=f_A, Amp=1.0_wp, envelope=env)
    print *, "Karplus Strong"
    call add_karplus_strong(tape, track=1, t1=t+7*dnote, t2=t+8*dnote, f=f_A, Amp=1.0_wp)
    print *, "Karplus Strong stretched"
    call add_karplus_strong_stretched(tape, track=1, t1=t+8*dnote, t2=t+9*dnote, f=f_A, Amp=1.0_wp)
    print *, "Bell"
    call add_bell(tape, track=1, t1=t+9*dnote, f=f_A, Amp=1.0_wp)

    end associate

    print *, "Final mix..."
    ! All tracks will be mixed on track 0.
    ! Needed even if there is only one track!
    call demo%mix_tracks()
    call demo%close_WAV_file()

    print *,"You can now play the file ", demo%get_name()
end program all_signals
