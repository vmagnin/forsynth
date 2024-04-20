! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-04-20

program demo3
    use forsynth, only: dp, create_WAV_file, &
                      & finalize_WAV_file, clear_tracks, file_t
    use signals, only: add_sine_wave, add_square_wave, &
                     & add_sawtooth_wave, add_triangle_wave, &
                     & add_karplus_strong, add_noise
    use music, only: fr, MAJOR_SCALE, HEXATONIC_BLUES_SCALE
    use envelopes, only: attack, decay

    implicit none
    type(file_t) :: d3
    real(dp) :: t, delta_t
    real(dp) :: f_A, r
    integer  :: i, k

    print *, "**** Demo 3 ****"
    call d3%create_WAV_file('demo3.wav')
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

    print *, "C Major scale"
    t = t + 6*delta_t
    do i = 1, 7
        call add_karplus_strong(1, t, t + delta_t/3.0_dp, fr(trim(MAJOR_SCALE(i))//'4'), 1.0_dp)
        t = t + delta_t/3.0_dp
    end do
    call add_karplus_strong(1, t, t + delta_t/3.0_dp, fr(trim(MAJOR_SCALE(1))//'5'), 1.0_dp)

    print *, "A blues scale"
    t = t + delta_t
    do i = 1, 6
        call add_karplus_strong(1, t, t + delta_t/3.0_dp, &
                            & fr(trim(HEXATONIC_BLUES_SCALE(i))//'3'), 1.0_dp)
        t = t + delta_t/3.0_dp
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
        r = min(1.0_dp, r+0.25_dp)/3.0_dp
        call add_karplus_strong(1, t, t + delta_t*r, &
                            & fr(trim(HEXATONIC_BLUES_SCALE(k))//'3'), 1.0_dp)
        t = t + delta_t*r
    end do

    print *, "Final mix..."
    call finalize_WAV_file()

end program demo3
