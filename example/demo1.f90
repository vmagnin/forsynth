! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-04-20

program demo1
    use forsynth, only: dp, create_WAV_file, DURATION, &
                      & finalize_WAV_file, copy_section, clear_tracks, file_t
    use signals, only: add_karplus_strong
    use music, only: add_major_chord, add_minor_chord, fr
    use audio_effects, only: apply_delay_effect

    implicit none
    type(file_t) :: d1
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

end program demo1
