! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2024-04-25
! Last modifications: 2024-05-18

program drum_machine
    use forsynth, only: dp
    use wav_file_class, only: WAV_file
    use signals, only: add_karplus_strong_drum, add_karplus_strong_drum_stretched

    implicit none
    type(WAV_file) :: demo
    integer  :: i, j
    real(dp) :: t
    real(dp) :: dt = 0.25_dp
    ! Each line is a different drum:
    integer, dimension(3, 16) :: pattern = reshape( [ &
        1,0,0,0, 1,0,0,1, 1,0,0,0, 1,0,0,1,   &
        0,1,0,0, 0,1,1,1, 0,1,0,0, 0,1,0,0,   &
        1,0,1,0, 1,0,1,0, 1,0,1,0, 1,0,1,0 ], &
        shape(pattern), order = [2, 1] )

    print *, "**** Demo Drum Machine****"
    call demo%create_WAV_file('drum_machine.wav', nb_tracks=3, duration=64._dp)

    ! A rhythm following the above pattern:
    t = 0._dp
    do i = 1, 8
        do j = 1, 16
            ! We use one track for each kind of drum:
            if (pattern(1, j) == 1) then
                call add_karplus_strong_drum(          demo%tape_recorder, 1, t, t+2*dt, 150, 1._dp)
            end if
            if (pattern(2, j) == 1) then
                call add_karplus_strong_drum(          demo%tape_recorder, 2, t, t+2*dt, 400, 1._dp)
            end if
            if (pattern(3, j) == 1) then
                call add_karplus_strong_drum_stretched(demo%tape_recorder, 3, t, t+2*dt, 150, 0.5_dp)
            end if
            t = t + dt
        end do
    end do

    print *, "Final mix..."
    call demo%mix_tracks()
    call demo%close_WAV_file()

end program drum_machine
