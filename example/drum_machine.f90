! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2024-04-25
! Last modifications: 2024-05-13

program drum_machine
    use forsynth, only: dp, create_WAV_file, mix_tracks, &
                      & clear_tracks, file_t
    use signals, only: add_karplus_strong_drum, add_karplus_strong_drum_stretched

    implicit none
    type(file_t) :: demo
    integer  :: i
    real(dp) :: dt

    print *, "**** Demo Drum Machine****"
    call demo%create_WAV_file('drum_machine.wav')
    call clear_tracks()

    ! A binary rhythm:
    dt = 0.5_dp
    do i = 1, 40
       ! We use tracks 1 and 2 for the two drums:
       call add_karplus_strong_drum(          1, i*dt + 0._dp, i*dt + 1._dp, 250, 1._dp)
       call add_karplus_strong_drum_stretched(2, i*dt + dt/2 , i*dt + dt   , 300, 0.5_dp)
    end do

    print *, "Final mix..."
    call mix_tracks()
    call demo%finalize_WAV_file()

end program drum_machine
