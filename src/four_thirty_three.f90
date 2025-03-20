! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2025-03-19
! Last modifications: 2025-03-19

!> A minimalist Forsynth file! And a double tribute to John Cage and Joy Division.
program four_thirty_three
    use forsynth, only: wp
    use wav_file_class, only: WAV_file

    implicit none
    type(WAV_file) :: demo

    ! We create a new WAV file, and define the number of tracks and its duration:
    call demo%create_WAV_file('four_thirty_three.wav', tracks=1, duration=4*60._wp + 33)
    print *, "**** Creating " // demo%get_name() // " ****"

    ! All tracks will be mixed on track 0.
    ! Needed even if there is only one track!
    call demo%mix_tracks()
    call demo%close_WAV_file()

    print *,"You can now play the file ", demo%get_name()
    print *
    print *,'"Listen to the silence, let it ring on"'
end program four_thirty_three
