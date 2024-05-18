! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-17

program blues
    use forsynth, only: dp
    use wav_file_class, only: WAV_file
    use signals, only: add_karplus_strong
    use music, only: fr
    use music_common, only: HEXATONIC_BLUES_SCALE
    use envelopes, only: attack, decay
    use audio_effects, only: apply_tremolo_effect

    implicit none
    type(WAV_file) :: demo
    real(dp) :: t, Dt
    real(dp) :: r   ! Random number
    integer  :: i, k

    print *, "**** Demo Blues ****"
    call demo%create_WAV_file('blues.wav', 1, 35._dp)
    call demo%clear_tracks()

    attack = 30.0_dp
    decay  = 20.0_dp

    ! Notes duration in seconds:
    Dt = 0.5_dp
    t = 0.0_dp

    print *, "A blues scale"
    t = t + Dt
    do i = 1, 6
        call add_karplus_strong(demo%tape_recorder, 1, t, t + Dt, &
                            & fr(trim(HEXATONIC_BLUES_SCALE(i))//'3'), 1.0_dp)
        t = t + Dt
    end do

    print *, "Random walk on that blues scale"
    k = 1
    do i = 1, 60
        call random_number(r)
        if (r < 0.5_dp) then
            k = k - 1
        else
            k = k + 1
        end if

        if (k < 1) k = 1
        if (k > 6) k = 6

        call random_number(r)
        r = min(1.0_dp, r+0.25_dp)
        call add_karplus_strong(demo%tape_recorder, 1, t, t + Dt*(r + 0.25_dp), &
                            & fr(trim(HEXATONIC_BLUES_SCALE(k))//'2'), 1.0_dp)
        t = t + Dt*(r + 0.25_dp)
    end do

    ! A tremolo at 3 Hz and an amplitude of 0.2:
    call apply_tremolo_effect(demo%tape_recorder, 1, 0.0_dp, t, 3.0_dp, 0.2_dp)

    print *, "Final mix..."
    call demo%mix_tracks()
    call demo%close_WAV_file()

end program blues
