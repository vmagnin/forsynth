! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2025-03-15

!> All available audio effects are applied sequentially on a chord sequence.
program demo_effects
    use forsynth, only: wp
    use wav_file_class, only: WAV_file
    use music_common, only: MAJOR_CHORD
    use music, only: fr, add_chord
    use audio_effects, only: apply_fuzz_effect, apply_tremolo_effect, &
                           & apply_autopan_effect, apply_delay_effect, &
                           & apply_dynamic_effect
    use envelopes, only: ADSR_envelope

    implicit none
    type(WAV_file) :: demo
    type(ADSR_envelope) :: env
    integer  :: i
    real(wp) :: t, dnote

    print *, "**** Demo of the audio effects ****"
    ! We create a new WAV file, and define the number of tracks and its duration:
    call demo%create_WAV_file('demo_effects.wav', tracks=1, duration=120._wp)
    ! We create an ADSR envelope that will be passed to signals (add_chord):
    call env%new(A=10._wp, D=40._wp, S=80._wp, R=30._wp)

    ! Notes duration in seconds:
    dnote = 1._wp

    associate(tape => demo%tape_recorder)

    print *, "Track 1: repeating G D F C chords..."
    t = 0.0_wp
    call add_chord(tape, track=1, t1=t,         t2=t+dnote,   f=fr("G4"), Amp=1.0_wp, chord=MAJOR_CHORD, envelope=env)
    call add_chord(tape, track=1, t1=t+dnote,   t2=t+2*dnote, f=fr("D4"), Amp=1.0_wp, chord=MAJOR_CHORD, envelope=env)
    call add_chord(tape, track=1, t1=t+2*dnote, t2=t+3*dnote, f=fr("F4"), Amp=1.0_wp, chord=MAJOR_CHORD, envelope=env)
    call add_chord(tape, track=1, t1=t+3*dnote, t2=t+4*dnote, f=fr("C4"), Amp=1.0_wp, chord=MAJOR_CHORD, envelope=env)
    ! Repeat those four chords:
    do i = 1, 1+9
        call demo%copy_section(from_track=1, to_track=1, t1=t, t2=t+4*dnote, t3=4*dnote*i)
    end do

    ! Apply each effect, every four chords, after four chords without effect:
    t = 4*dnote
    call apply_fuzz_effect(   tape, track=1, t1=t, t2=t+4*dnote, level=0.8_wp)
    t = t+ 4*dnote
    call apply_tremolo_effect(tape, track=1, t1=t, t2=t+4*dnote, f=4.0_wp,  AmpLFO=0.3_wp)
    t = t+ 4*dnote
    call apply_autopan_effect(tape, track=1, t1=t, t2=t+4*dnote, f=0.33_wp, AmpLFO=0.8_wp)
    t = t+ 4*dnote
    call apply_delay_effect(  tape, track=1, t1=t, t2=t+4*dnote, delay=0.4_wp,  Amp=0.4_wp)
    ! Downward compression:
    t = t+ 4*dnote
    call apply_dynamic_effect(tape, track=1, t1=t, t2=t+4*dnote, threshold=2._wp,  ratio=2._wp)
    ! Upward expander:
    t = t+ 4*dnote
    call apply_dynamic_effect(tape, track=1, t1=t, t2=t+4*dnote, threshold=2._wp,  ratio=0.5_wp)
    ! Limiter:
    t = t+ 4*dnote
    call apply_dynamic_effect(tape, track=1, t1=t, t2=t+4*dnote, threshold=2._wp,  ratio=20._wp)
    ! Upward compression:
    t = t+ 4*dnote
    call apply_dynamic_effect(tape, track=1, t1=t, t2=t+4*dnote, threshold=0.5_wp, ratio=0.5_wp, below=.true.)
    ! (Downward) expander:
    t = t+ 4*dnote
    call apply_dynamic_effect(tape, track=1, t1=t, t2=t+4*dnote, threshold=0.5_wp, ratio=2._wp,  below=.true.)

    end associate

    print *, "Final mix..."
    ! All tracks will be mixed on track 0.
    ! Needed even if there is only one track!
    call demo%mix_tracks()
    call demo%close_WAV_file()

    print *,"You can now play the file ", demo%get_name()
end program demo_effects
