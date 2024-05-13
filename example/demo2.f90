! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-13

program demo2
    use forsynth, only: dp, mix_tracks, DURATION, &
                      & copy_section, clear_tracks, file_t
    use music_common, only: MAJOR_CHORD
    use music, only: fr, add_chord
    use audio_effects, only: apply_fuzz_effect, apply_tremolo_effect, &
                           & apply_autopan_effect
    use envelopes, only: attack, decay

    implicit none
    type(file_t) :: d2
    integer  :: i
    real(dp) :: t, Dt

    print *, "**** Demo 2 ****"
    call d2%create_WAV_file('demo2.wav')
    call clear_tracks()

    attack = 10.0_dp
    decay  = 40.0_dp

    ! Notes duration in seconds:
    Dt = 1.5_dp

    print *, "Track 1: repeating G D F C chords..."
    t = 0.0_dp
    call add_chord(1, t,        t + Dt,   fr("G3"), 1.0_dp, MAJOR_CHORD)
    call add_chord(1, t + Dt,   t + 2*Dt, fr("D3"), 1.0_dp, MAJOR_CHORD)
    call add_chord(1, t + 2*Dt, t + 3*Dt, fr("F3"), 1.0_dp, MAJOR_CHORD)
    call add_chord(1, t + 3*Dt, t + 4*Dt, fr("C3"), 1.0_dp, MAJOR_CHORD)
    ! Repeat those four chords until the end of the track:
    do i = 1, 19
        call copy_section(1, 1, t, t + 4*Dt, 4 * Dt * i)
    end do

    call apply_fuzz_effect(1, t, DURATION, 0.8_dp)
    call apply_tremolo_effect(1, t, t + 4*Dt, 4.0_dp, 0.3_dp)
    call apply_autopan_effect(1, t + 4*Dt, t + 8*Dt, 0.33_dp, 0.8_dp)

    print *, "Final mix..."
    call mix_tracks()
    call d2%finalize_WAV_file()

end program demo2
