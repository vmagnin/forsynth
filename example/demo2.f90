! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-04-20

program demo2
    use forsynth, only: dp, create_WAV_file, DURATION, &
                      & finalize_WAV_file, copy_section, clear_tracks, file_t
    use music, only: add_major_chord, fr
    use audio_effects, only: apply_fuzz_effect, apply_tremolo_effect, &
                           & apply_autopan_effect
    use envelopes, only: attack, decay

    implicit none
    type(file_t) :: d2
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

end program demo2
