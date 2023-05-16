! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2021-04-13

module demos
    ! Demonstrations subroutines

    use forsynth, only: dp, create_WAV_file, PITCH, SEMITONE, DURATION, &
                      & finalize_WAV_file, copy_section, clear_tracks, file_t
    use signals, only: add_sine_wave, add_square_wave, &
                     & add_sawtooth_wave, add_triangle_wave, &
                     & add_karplus_strong, add_noise
    use music, only: add_note, add_major_chord, add_minor_chord, fr, &
                   & MAJOR_SCALE, HEXATONIC_BLUES_SCALE
    use audio_effects, only: apply_delay_effect, apply_fuzz_effect, &
                           & apply_tremolo_effect, apply_autopan_effect
    use envelopes, only: attack, decay

    implicit none

    private

    public :: demo1, demo2, demo3

    type(file_t) :: d1, d2, d3

contains

    subroutine demo1()
        integer  :: i
        real(dp) :: t, delta_t, r
        real(dp) :: chosen_note(0:3)

        print *, "**** Demo 1 ****"
        call d1%create_WAV_file('demo1.wav')
        call clear_tracks()

        ! Notes duration in seconds:
        delta_t = 3.0_dp

        print *, "Track 1: repeating Am C G Dm chords..."
        t = 0.0_dp
        call add_minor_chord(1, t,             t + delta_t,   fr("A3"), 1.0_dp)
        call add_major_chord(1, t + delta_t,   t + 2*delta_t, fr("C3"), 1.0_dp)
        call add_major_chord(1, t + 2*delta_t, t + 3*delta_t, fr("G3"), 1.0_dp)
        call add_minor_chord(1, t + 3*delta_t, t + 4*delta_t, fr("D3"), 1.0_dp)
        ! Repeat those four chords until the end of the track:
        do i = 1, 9
            call copy_section(1, 1, t, t + 4*delta_t, 4 * delta_t * i)
        end do

        print *, "Track 2: playing random A C G D notes using plucked strings..."
        delta_t = delta_t / 4
        chosen_note(0) = fr("A3")
        chosen_note(1) = fr("C3")
        chosen_note(2) = fr("G3")
        chosen_note(3) = fr("D3")

        do i = 0, 9*16
            t = delta_t * i
            call random_number(r)
            call add_karplus_strong(2, t, t + delta_t, chosen_note(int(r*4)), 1.0_dp)
        end do

        ! Dotted quavers delay:
        call apply_delay_effect(2, 0.0_dp, DURATION, delta_t*0.75_dp, 0.45_dp)
        ! Plus a quavers delay:
        call apply_delay_effect(2, 0.0_dp, DURATION, delta_t*0.50_dp, 0.30_dp)

        print *, "Final mix..."
        call finalize_WAV_file()
    end subroutine


    subroutine demo2()
        integer  :: i
        real(dp) :: t, delta_t

        print *, "**** Demo 2 ****"
        call d2%create_WAV_file('demo2.wav')
        call clear_tracks()

        attack = 10.0_dp
        decay  = 40.0_dp

        ! Notes duration in seconds:
        delta_t = 1.5_dp

        print *, "Track 1: repeating G D F C chords..."
        t = 0.0_dp
        call add_major_chord(1, t,             t + delta_t,   fr("G3"), 1.0_dp)
        call add_major_chord(1, t + delta_t,   t + 2*delta_t, fr("D3"), 1.0_dp)
        call add_major_chord(1, t + 2*delta_t, t + 3*delta_t, fr("F3"), 1.0_dp)
        call add_major_chord(1, t + 3*delta_t, t + 4*delta_t, fr("C3"), 1.0_dp)
        ! Repeat those four chords until the end of the track:
        do i = 1, 19
            call copy_section(1, 1, t, t + 4*delta_t, 4 * delta_t * i)
        end do

        call apply_fuzz_effect(1, t, DURATION, 0.8_dp)
        call apply_tremolo_effect(1, t, t + 4*delta_t, 4.0_dp, 0.3_dp)
        call apply_autopan_effect(1, t + 4*delta_t, t + 8*delta_t, 0.33_dp, 0.8_dp)

        print *, "Final mix..."
        call finalize_WAV_file()
    end subroutine


    subroutine demo3()
        real(dp) :: t, delta_t
        real(dp) :: f_A, r
        integer :: i, k

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
    end subroutine
end module demos
