! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2024-05-19
! Last modifications: 2024-05-26

! Experimental drone music.
program drone_music
    use forsynth, only: wp, dt, RATE, PI
    use wav_file_class, only: WAV_file
    use music, only: SEMITONE
    use envelopes, only: apply_fade_in, apply_fade_out

    implicit none
    type(WAV_file) :: demo
    ! Time in seconds:
    real(wp) :: t, t1, t2, f0, f1, f2
    ! Pulsation (radians/second):
    real(wp) :: omega1, omega2, omegaLFO1, omegaLFO2
    real(wp) :: Amp
    integer  :: i

    ! Fundamental frequency:
    f0 = 80._wp
    ! Low Frequency Oscillators:
    omegaLFO1 = 2*PI * 0.03_wp
    omegaLFO2 = 2*PI * 0.001_wp

    Amp = 1._wp

    print *, "**** Creating drone_music.wav ****"
    t1 = 0._wp
    t2 = 180._wp
    call demo%create_WAV_file('drone_music.wav', tracks=1, duration=t2)

    associate(tape => demo%tape_recorder)

    t = 0._wp
    do i = nint(t1*RATE), nint(t2*RATE)-1
        ! Fundamental:
        f1 = f0 * (1 + 0.01_wp*sin(omegaLFO1 * t))
        omega1 = 2*PI * f1
        tape%left(1, i)  = tape%left(1, i) + Amp * sin(omega1*t)

        ! Perfect fifth (7 semitones higher):
        f2 = f0*(SEMITONE**7) * (1 + 0.01_wp*sin(omegaLFO2 * t))
        omega2 = 2*PI * f2
        tape%left(1, i)  = tape%left(1, i) + Amp * sin(omega2*t)

        tape%right(1, i) = tape%left(1, i)
        t = t + dt
    end do

    call apply_fade_in( tape, track=1, t1=0._wp, t2=3._wp)
    call apply_fade_out(tape, track=1, t1=t2-3,  t2=t2)

    end associate

    call demo%mix_tracks()
    call demo%close_WAV_file()

end program drone_music
