! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-18

! A sequence of synth chords is repeated, and the corresponding notes are played
! randomly by plucked strings.
program chords_and_melody
    use forsynth, only: dp
    use wav_file_class, only: WAV_file
    use signals, only: add_karplus_strong
    use music_common, only: MINOR_CHORD, MAJOR_CHORD
    use music, only: add_chord, fr
    use audio_effects, only: apply_delay_effect

    implicit none
    type(WAV_file) :: demo
    integer  :: i
    real(dp) :: t, Dt, r
    real(dp) :: chosen_note(0:3)

    print *, "**** Demo chords and melody ****"
    call demo%create_WAV_file('chords_and_melody.wav', nb_tracks=2, duration=120._dp)

    ! Notes duration in seconds:
    Dt = 3.0_dp

    print *, "Track 1: repeating Am C G Dm chords..."
    t = 0.0_dp
    call add_chord(demo%tape_recorder, 1, t,        t + Dt,   fr("A3"), 1.0_dp, MINOR_CHORD)
    call add_chord(demo%tape_recorder, 1, t + Dt,   t + 2*Dt, fr("C3"), 1.0_dp, MAJOR_CHORD)
    call add_chord(demo%tape_recorder, 1, t + 2*Dt, t + 3*Dt, fr("G3"), 1.0_dp, MAJOR_CHORD)
    call add_chord(demo%tape_recorder, 1, t + 3*Dt, t + 4*Dt, fr("D3"), 1.0_dp, MINOR_CHORD)
    ! Repeat those four chords until the end of the track:
    do i = 1, 9
        call demo%copy_section(1, 1, t, t + 4*Dt, 4 * Dt * i)
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
        call add_karplus_strong(demo%tape_recorder, 2, t, t + Dt, chosen_note(int(r*4)), 1.0_dp)
    end do

    ! A double delay inspired by The Edge.
    ! Dotted quavers delay:
    call apply_delay_effect(demo%tape_recorder, 2, 0.0_dp, demo%DURATION, Dt*0.75_dp, 0.45_dp)
    ! Plus a quavers delay:
    call apply_delay_effect(demo%tape_recorder, 2, 0.0_dp, demo%DURATION, Dt*0.50_dp, 0.30_dp)

    print *, "Final mix..."
    call demo%mix_tracks()
    call demo%close_WAV_file()

end program chords_and_melody
