! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-31

! A sequence of synth chords is repeated, and the corresponding notes are played
! randomly by plucked strings.
program chords_and_melody
    use forsynth, only: wp
    use wav_file_class, only: WAV_file
    use signals, only: add_karplus_strong
    use music_common, only: MINOR_CHORD, MAJOR_CHORD
    use music, only: add_chord, fr
    use audio_effects, only: apply_delay_effect
    use envelopes, only: ADSR_envelope

    implicit none
    type(WAV_file) :: demo
    type(ADSR_envelope) :: env
    integer  :: i
    real(wp) :: t, Dt, r
    real(wp) :: chosen_note(0:3)

    print *, "**** Demo chords and melody ****"
    call demo%create_WAV_file('chords_and_melody.wav', tracks=2, duration=120._wp)

    call env%new(A=15._wp, D=40._wp, S=80._wp, R=15._wp)

    ! Notes duration in seconds:
    Dt = 3.0_wp

    print *, "Track 1: repeating Am C G Dm chords..."
    t = 0.0_wp
    call add_chord(demo%tape_recorder, track=1, t1=t,      t2=t+Dt,   f=fr("A3"), Amp=1.0_wp, chord=MINOR_CHORD, envelope=env)
    call add_chord(demo%tape_recorder, track=1, t1=t+Dt,   t2=t+2*Dt, f=fr("C3"), Amp=1.0_wp, chord=MAJOR_CHORD, envelope=env)
    call add_chord(demo%tape_recorder, track=1, t1=t+2*Dt, t2=t+3*Dt, f=fr("G3"), Amp=1.0_wp, chord=MAJOR_CHORD, envelope=env)
    call add_chord(demo%tape_recorder, track=1, t1=t+3*Dt, t2=t+4*Dt, f=fr("D3"), Amp=1.0_wp, chord=MINOR_CHORD, envelope=env)
    ! Repeat those four chords until the end of the track:
    do i = 1, 9
        call demo%copy_section(from_track=1, to_track=1, t1=t, t2=t+4*Dt, t3=4*Dt*i)
    end do

    print *, "Track 2: playing random A C G D notes using plucked strings..."
    Dt = Dt / 4
    chosen_note(0) = fr("A3")
    chosen_note(1) = fr("C3")
    chosen_note(2) = fr("G3")
    chosen_note(3) = fr("D3")

    do i = 0, 9*16
        t = Dt * i
        call random_number(r)
        call add_karplus_strong(demo%tape_recorder, track=2, t1=t, t2=t+Dt, f=chosen_note(int(r*4)), Amp=1._wp)
    end do

    ! A double delay inspired by The Edge.
    ! Dotted quavers delay:
    call apply_delay_effect(demo%tape_recorder, track=2, t1=0.0_wp, t2=demo%duration, delay=Dt*0.75_wp, Amp=0.45_wp)
    ! Plus a quavers delay:
    call apply_delay_effect(demo%tape_recorder, track=2, t1=0.0_wp, t2=demo%duration, delay=Dt*0.50_wp, Amp=0.30_wp)

    print *, "Final mix..."
    ! In the mix, chords are rather on the left
    ! and plucked strings on the right (and their level is lowered):
    call demo%mix_tracks(levels=[1._wp, 0.5_wp], pan=[-0.5_wp, +0.5_wp])
    call demo%close_WAV_file()

    print *,"You can now play the file ", demo%get_name()
end program chords_and_melody
