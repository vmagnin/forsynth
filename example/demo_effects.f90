! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-26

! All available audio effects are applied sequentially on a chord sequence.
program demo_effects
    use forsynth, only: wp
    use wav_file_class, only: WAV_file
    use music_common, only: MAJOR_CHORD
    use music, only: fr, add_chord
    use audio_effects, only: apply_fuzz_effect, apply_tremolo_effect, &
                           & apply_autopan_effect, apply_delay_effect
    use envelopes, only: ADSR_envelope

    implicit none
    type(WAV_file) :: demo
    type(ADSR_envelope) :: env
    integer  :: i
    real(wp) :: t, Dt

    print *, "**** Demo of the audio effects ****"
    call demo%create_WAV_file('demo_effects.wav', tracks=1, duration=120._wp)

    call env%new(A=10._wp, D=40._wp, S=80._wp, R=30._wp)

    ! Notes duration in seconds:
    Dt = 1.5_wp

    print *, "Track 1: repeating G D F C chords..."
    t = 0.0_wp
    call add_chord(demo%tape_recorder, track=1, t1=t,      t2=t+Dt,   f=fr("G3"), Amp=1.0_wp, chord=MAJOR_CHORD, envelope=env)
    call add_chord(demo%tape_recorder, track=1, t1=t+Dt,   t2=t+2*Dt, f=fr("D3"), Amp=1.0_wp, chord=MAJOR_CHORD, envelope=env)
    call add_chord(demo%tape_recorder, track=1, t1=t+2*Dt, t2=t+3*Dt, f=fr("F3"), Amp=1.0_wp, chord=MAJOR_CHORD, envelope=env)
    call add_chord(demo%tape_recorder, track=1, t1=t+3*Dt, t2=t+4*Dt, f=fr("C3"), Amp=1.0_wp, chord=MAJOR_CHORD, envelope=env)
    ! Repeat those four chords until the end of the track:
    do i = 1, 19
        call demo%copy_section(from_track=1, to_track=1, t1=t, t2=t+4*Dt, t3=4*Dt*i)
    end do

    ! Apply the different effects, every four chords, 
    ! after four chords without effect:
    call apply_fuzz_effect(   demo%tape_recorder, track=1, t1=t+4*Dt,  t2=t+8*Dt,  level=0.8_wp)
    call apply_tremolo_effect(demo%tape_recorder, track=1, t1=t+8*Dt,  t2=t+12*Dt, f=4.0_wp,  AmpLFO=0.3_wp)
    call apply_autopan_effect(demo%tape_recorder, track=1, t1=t+12*Dt, t2=t+16*Dt, f=0.33_wp, AmpLFO=0.8_wp)
    call apply_delay_effect(  demo%tape_recorder, track=1, t1=t+16*Dt, t2=t+20*Dt, delay=0.4_wp,  Amp=0.4_wp)

    print *, "Final mix..."
    call demo%mix_tracks()
    call demo%close_WAV_file()

end program demo_effects
