! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2024-04-25
! Last modifications: 2025-02-23

!> A rhythm following a pattern stored in an array.
program drum_machine
    use forsynth, only: wp
    use wav_file_class, only: WAV_file
    use signals, only: add_karplus_strong_drum, add_karplus_strong_drum_stretched

    implicit none
    type(WAV_file) :: demo
    integer  :: i, j
    real(wp) :: t
    real(wp) :: step = 0.25_wp
    ! Each line is a different drum:
    integer, dimension(3, 16) :: pattern = reshape( [ &
        1,0,0,0, 1,0,0,1, 1,0,0,0, 1,0,0,1,   &
        0,1,0,0, 0,1,1,1, 0,1,0,0, 0,1,0,0,   &
        1,0,1,0, 1,0,1,0, 1,0,1,0, 1,0,1,0 ], &
        shape(pattern), order = [2, 1] )

    ! We create a new WAV file, and define the number of tracks and its duration:
    call demo%create_WAV_file('drum_machine.wav', tracks=3, duration=33._wp)
    print *, "**** Creating " // demo%get_name() // " ****"

    associate(tape => demo%tape_recorder)

    ! A rhythm following the above pattern:
    t = 0._wp
    do i = 1, 8
        do j = 1, 16
            ! We use one track for each kind of drum:
            if (pattern(1, j) == 1) then
                call add_karplus_strong_drum(          tape, track=1, t1=t, t2=t+2*step, P=150, Amp=1._wp)
            end if
            if (pattern(2, j) == 1) then
                call add_karplus_strong_drum(          tape, track=2, t1=t, t2=t+2*step, P=400, Amp=1._wp)
            end if
            if (pattern(3, j) == 1) then
                call add_karplus_strong_drum_stretched(tape, track=3, t1=t, t2=t+2*step, P=150, Amp=0.5_wp)
            end if
            t = t + step
        end do
    end do

    end associate

    print *, "Final mix..."
    ! The three drums are positionned on the left, the center and the right:
    call demo%mix_tracks(pan=[-0.5_wp, 0._wp, +0.5_wp])
    call demo%close_WAV_file()

    print *,"You can now play the file ", demo%get_name()
end program drum_machine
