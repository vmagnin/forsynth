module demos
    ! Demonstrations subroutines

    use forsynth, only: dp, create_WAV_file, PITCH, SEMITONE, DURATION, &
                      & finalize_WAV_file, copy_section, clear_tracks
    use signals, only: add_sinusoidal_signal, add_square_wave, &
                     & add_sawtooth_wave, add_triangle_wave, &
                     & add_karplus_strong, add_noise
    use music, only: add_note, add_major_chord, add_minor_chord
    use audio_effects, only: apply_delay_effect, apply_fuzz_effect, &
                           & apply_tremolo_effect, apply_autopan_effect
    use envelopes, only: attack, decay

    implicit none

    private

    public :: demo1, demo2, demo3

contains

    subroutine demo1()
        integer  :: i
        real(dp) :: t, delta_t, r
        real(dp) :: f_A, f_C, f_G, f_D
        real(dp) :: chosen_note(0:3)

        print *, "**** Demo 1 ****"
        call create_WAV_file('demo1.wav')
        call clear_tracks()

        ! Notes frequencies:
        f_A = PITCH / 2
        f_C = f_A * SEMITONE**(-9)
        f_G = f_A * SEMITONE**(-2)
        f_D = f_C * SEMITONE**(+2)

        ! Notes duration in seconds:
        delta_t = 3.0_dp

        print *, "Track 1: repeating Am C G Dm chords..."
        t = 0.0_dp
        call add_minor_chord(1, t,             t + delta_t,   f_A, 1.0_dp)
        call add_major_chord(1, t + delta_t,   t + 2*delta_t, f_C, 1.0_dp)
        call add_major_chord(1, t + 2*delta_t, t + 3*delta_t, f_G, 1.0_dp)
        call add_minor_chord(1, t + 3*delta_t, t + 4*delta_t, f_D, 1.0_dp)
        ! Repeat those four chords until the end of the track:
        do i = 1, 9
            call copy_section(1, 1, t, t + 4*delta_t, 4 * delta_t * i)
        end do

        print *, "Track 2: playing random A C G D notes using plucked strings..."
        delta_t = delta_t / 4
        chosen_note(0) = f_A
        chosen_note(1) = f_C
        chosen_note(2) = f_G
        chosen_note(3) = f_D

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
        real(dp) :: f_A, f_G, f_D, f_F, f_C

        print *, "**** Demo 2 ****"
        call create_WAV_file('demo2.wav')
        call clear_tracks()

        attack = 10.0_dp
        decay  = 40.0_dp

        ! Notes frequencies:
        f_A = PITCH / 2             ! A 220 Hz
        f_C = f_A * SEMITONE**(-9)
        f_G = f_A * SEMITONE**(-2)
        f_F = f_G * SEMITONE**(-2)
        f_D = f_C * SEMITONE**(+2)

        ! Notes duration in seconds:
        delta_t = 1.5_dp

        print *, "Track 1: repeating G D F C chords..."
        t = 0.0_dp
        call add_major_chord(1, t,             t + delta_t,   f_G, 1.0_dp)
        call add_major_chord(1, t + delta_t,   t + 2*delta_t, f_D, 1.0_dp)
        call add_major_chord(1, t + 2*delta_t, t + 3*delta_t, f_F, 1.0_dp)
        call add_major_chord(1, t + 3*delta_t, t + 4*delta_t, f_C, 1.0_dp)
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
        real(dp) :: f_A

        print *, "**** Demo 3 ****"
        call create_WAV_file('demo3.wav')
        call clear_tracks()

        attack = 30.0_dp
        decay  = 20.0_dp

        ! Notes frequencies:
        f_A = PITCH / 2             ! A 220 Hz
        ! Notes duration in seconds:
        delta_t = 3.0_dp
        t = 0.0_dp

        print *, "Sinusoidal signal"
        call add_sinusoidal_signal(1, t, t + delta_t, f_A, 1.0_dp)
        print *, "Square wave"
        call add_square_wave(1, t + delta_t, t + 2*delta_t, f_A, 1.0_dp)
        print *, "Sawtooth wave"
        call add_sawtooth_wave(1, t + 2*delta_t, t + 3*delta_t, f_A, 1.0_dp)
        print *, "Triangle wave"
        call add_triangle_wave(1, t + 3*delta_t, t + 4*delta_t, f_A, 1.0_dp)
        print *, "Summing the four signals together"
        call add_sinusoidal_signal(1, t + 4*delta_t, t + 5*delta_t, f_A, 0.5_dp)
        call add_square_wave(1, t + 4*delta_t, t + 5*delta_t, f_A, 0.5_dp)
        call add_sawtooth_wave(1, t + 4*delta_t, t + 5*delta_t, f_A, 0.5_dp)
        call add_triangle_wave(1, t + 4*delta_t, t + 5*delta_t, f_A, 0.5_dp)
        print *, "Noise"
        call add_noise(1, t + 5*delta_t, t + 6*delta_t, 1.0_dp)

        print *, "Final mix..."
        call finalize_WAV_file()
    end subroutine
end module demos
