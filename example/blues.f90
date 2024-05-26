! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-26

! A random walk on a blues scale.
program blues
    use forsynth, only: wp
    use wav_file_class, only: WAV_file
    use signals, only: add_karplus_strong
    use music, only: fr
    use music_common, only: HEXATONIC_BLUES_SCALE
    use audio_effects, only: apply_tremolo_effect

    implicit none
    type(WAV_file) :: demo
    real(wp) :: t, Dt
    real(wp) :: r   ! Random number
    integer  :: i, k

    print *, "**** Demo Blues ****"
    call demo%create_WAV_file('blues.wav', tracks=1, duration=35._wp)

    ! Notes duration in seconds:
    Dt = 0.5_wp
    t = 0.0_wp

    print *, "A blues scale"
    t = t + Dt
    do i = 1, 6
        call add_karplus_strong(demo%tape_recorder, track=1, t1=t, t2=t+Dt, &
                            & f=fr(trim(HEXATONIC_BLUES_SCALE(i))//'3'), Amp=1.0_wp)
        t = t + Dt
    end do

    print *, "Random walk on that blues scale"
    k = 1
    do i = 1, 60
        call random_number(r)
        if (r < 0.5_wp) then
            k = k - 1
        else
            k = k + 1
        end if

        if (k < 1) k = 1
        if (k > 6) k = 6

        call random_number(r)
        r = min(1.0_wp, r+0.25_wp)
        call add_karplus_strong(demo%tape_recorder, track=1, t1=t, t2=t+Dt*(r+0.25_wp), &
                            & f=fr(trim(HEXATONIC_BLUES_SCALE(k))//'2'), Amp=1.0_wp)
        t = t + Dt*(r + 0.25_wp)
    end do

    ! A tremolo at 3 Hz and an amplitude of 0.2:
    call apply_tremolo_effect(demo%tape_recorder, track=1, t1=0.0_wp, t2=t, f=3.0_wp, AmpLFO=0.2_wp)

    print *, "Final mix..."
    call demo%mix_tracks()
    call demo%close_WAV_file()

end program blues
