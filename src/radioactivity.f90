! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2025-01-29
! Last modifications: 2025-02-04

!> Radioactive decay of a population of atoms. A tribute to Kraftwerk.
!> Chords are played on a 2nd track and Morse code on a third track.
program radioactivity
    use forsynth, only: wp, dt, RATE, PI
    use wav_file_class, only: WAV_file
    use tape_recorder_class
    use music, only: fr, add_chord
    use music_common, only: WHOLE_TONE_SCALE, MAJOR_CHORD
    use envelopes, only: ADSR_envelope
    use morse_code, only: string_to_morse, add_morse_code

    implicit none
    type(WAV_file) :: demo
    type(ADSR_envelope) :: env
    integer, parameter :: N0 = 5000     ! Number of atoms
    integer  :: N = N0                  ! Number of remaining radioactive atoms
    integer  :: atom(N0) = 1            ! The population of atoms, in state 1
    real(wp) :: t = 0                   ! Time in seconds
    real(wp) :: t_end                   ! Position of the end of the first track
    real(wp) :: d_note                  ! Duration of each chord
    real(wp), parameter :: duration = 120._wp    ! Duration of the WAV file
    real(wp), parameter :: tau = 8._wp           ! Half-life in seconds
    real(wp), parameter :: delta_t = tau/10000   ! Time step of the simulation
    ! Decay probability during delta_t:
    real(wp), parameter :: p = 1 - exp(-log(2._wp) * delta_t/tau)
    real(wp) :: r           ! Pseudo-random number
    integer  :: i, j, note, nb_notes
    ! Melody of the chords on track 2:
    integer, parameter :: notes(1:40) = [ 6,5,6,5,6,4,5,4,5,3,4,3,4,2,3,2,3,1,2, &
                                        & 1,2,1,3,2,3,2,4,3,4,3,5,4,5,4,6,5,6,5,6,6 ]

    print *, "It may take a few minutes to compute..."

    ! We create a new WAV file, and define the number of tracks and its duration:
    call demo%create_WAV_file('radioactivity.wav', tracks=3, duration=duration)

    ! We create an ADSR envelope that will be passed to signals (add_chord):
    call env%new(A=15._wp, D=15._wp, S=70._wp, R=45._wp)

    do
        ! Scanning the whole population:
        do i = 1, N0
            ! Is this atom still in its original state?
            if (atom(i) /= 0) then
                ! Monte Carlo event:
                call random_number(r)
                if (r < p) then   ! Radioactive decay
                    atom(i) = 0
                    N = N - 1
                    if (t+5._wp < duration) then
                        call add_geiger_ping(demo%tape_recorder, track=1, t1=t, t2=t+5._wp, &
                                           & f=440._wp, Amp=1._wp)
                    end if
                end if
            end if
        end do

        t = t + delta_t

        if (N == 0) exit      ! No more radioactive atoms
    end do

    ! Track 2: synth chords
    t_end = t
    nb_notes = 2*40
    d_note = t_end / nb_notes

    do j = 1, nb_notes
        ! The same sequence is played twice:
        if (j <= 40) then
            note = notes(j)
        else
            note = notes(j-40)
        end if

        call add_chord(demo%tape_recorder, track=2, t1=(j-1)*d_note, t2=j*d_note, &
                     & f=fr(trim(WHOLE_TONE_SCALE(note)) // "3"), &
                     & Amp=0.1_wp, chord=MAJOR_CHORD, envelope=env)
    end do

    ! Track 3: Morse code
    call add_morse_code(demo%tape_recorder, track=3, t1=2._wp,  f=880._wp, &
                      & Amp=0.3_wp, string=string_to_morse("RADIOACTIVITY"))
    call add_morse_code(demo%tape_recorder, track=3, t1=35._wp, f=880._wp, &
                      & Amp=0.3_wp, string=string_to_morse("DISCOVERED BY MADAME CURIE"))
    call add_morse_code(demo%tape_recorder, track=3, t1=75._wp, f=880._wp, &
                      & Amp=0.3_wp, string=string_to_morse("IS IN THE AIR FOR YOU AND ME"))

    ! All tracks will be mixed on track 0.
    ! Needed even if there is only one track!
    call demo%mix_tracks()
    call demo%close_WAV_file()

    print *,"You can now play the file ", demo%get_name()

contains

    !> Adds the signal of a radioactive decay heard with a Geiger counter.
    subroutine add_geiger_ping(tape, track, t1, t2, f, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, Amp
        real(wp) :: b

        ! Pulsation (radians/second):
        real(wp) :: omega
        ! Time in seconds:
        real(wp) :: t
        integer  :: i

        omega = 2 * PI * f
        t = 0._wp
        do i = nint(t1*RATE), nint(t2*RATE)-1
            ! Bessel functions of the first kind: a short ping
            b = Amp * bessel_jn(1, omega*t) * bessel_jn(2, omega*t)
            tape%left( track, i) = tape%left( track, i) + b
            tape%right(track, i) = tape%right(track, i) + b

            t = t + dt
        end do
    end subroutine add_geiger_ping

end program radioactivity
