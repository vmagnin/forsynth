! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-13

program demo3
    use forsynth, only: dp, create_WAV_file, mix_tracks, &
                      & clear_tracks, file_t
    use signals, only: add_karplus_strong
    use music, only: fr
    use music_common, only: MAJOR_SCALE, HEXATONIC_BLUES_SCALE
    use envelopes, only: attack, decay

    implicit none
    type(file_t) :: d3
    real(dp) :: t, Dt
    real(dp) :: f_A
    real(dp) :: r   ! Random number
    integer  :: i, k

    print *, "**** Demo 3 ****"
    call d3%create_WAV_file('demo3.wav')
    call clear_tracks()

    attack = 30.0_dp
    decay  = 20.0_dp

    ! Notes frequencies:
    f_A = fr("A3")             ! A 220 Hz
    ! Notes duration in seconds:
    Dt = 0.5_dp
    t = 0.0_dp

    print *, "C Major scale"
    do i = 1, 7
        call add_karplus_strong(1, t, t + Dt, fr(trim(MAJOR_SCALE(i))//'4'), 1.0_dp)
        t = t + Dt
    end do
    call add_karplus_strong(1, t, t + Dt, fr(trim(MAJOR_SCALE(1))//'5'), 1.0_dp)

    print *, "A blues scale"
    t = t + Dt
    do i = 1, 6
        call add_karplus_strong(1, t, t + Dt, &
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
        call add_karplus_strong(1, t, t + Dt*r, &
                            & fr(trim(HEXATONIC_BLUES_SCALE(k))//'3'), 1.0_dp)
        t = t + Dt*r
    end do

    print *, "Final mix..."
    call mix_tracks()
    call d3%finalize_WAV_file()

end program demo3
