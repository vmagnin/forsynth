! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-18

! All available audio effects are applied sequentially on a chord sequence.
program demo_effects
    use forsynth, only: dp
    use wav_file_class, only: WAV_file
    use music_common, only: MAJOR_CHORD
    use music, only: fr, add_chord
    use audio_effects, only: apply_fuzz_effect, apply_tremolo_effect, &
                           & apply_autopan_effect, apply_delay_effect
    use envelopes, only: attack, decay

    implicit none
    type(WAV_file) :: demo
    integer  :: i
    real(dp) :: t, Dt

    print *, "**** Demo of the audio effects ****"
    call demo%create_WAV_file('demo_effects.wav', nb_tracks=1, duration=120._dp)

    attack = 10.0_dp
    decay  = 40.0_dp

    ! Notes duration in seconds:
    Dt = 1.5_dp

    print *, "Track 1: repeating G D F C chords..."
    t = 0.0_dp
    call add_chord(demo%tape_recorder, 1, t,        t + Dt,   fr("G3"), 1.0_dp, MAJOR_CHORD)
    call add_chord(demo%tape_recorder, 1, t + Dt,   t + 2*Dt, fr("D3"), 1.0_dp, MAJOR_CHORD)
    call add_chord(demo%tape_recorder, 1, t + 2*Dt, t + 3*Dt, fr("F3"), 1.0_dp, MAJOR_CHORD)
    call add_chord(demo%tape_recorder, 1, t + 3*Dt, t + 4*Dt, fr("C3"), 1.0_dp, MAJOR_CHORD)
    ! Repeat those four chords until the end of the track:
    do i = 1, 19
        call demo%copy_section(1, 1, t, t + 4*Dt, 4 * Dt * i)
    end do

    ! Apply the different effects, every four chords, 
    ! after four chords without effect:
    call apply_fuzz_effect(   demo%tape_recorder, 1, t + 4*Dt,  t + 8*Dt,  0.8_dp)
    call apply_tremolo_effect(demo%tape_recorder, 1, t + 8*Dt,  t + 12*Dt, 4.0_dp,  0.3_dp)
    call apply_autopan_effect(demo%tape_recorder, 1, t + 12*Dt, t + 16*Dt, 0.33_dp, 0.8_dp)
    call apply_delay_effect(  demo%tape_recorder, 1, t + 16*Dt, t + 20*Dt, 0.4_dp,  0.4_dp)

    print *, "Final mix..."
    call demo%mix_tracks()
    call demo%close_WAV_file()

end program demo_effects
