! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2024-05-24
! Last modifications: 2024-05-31

! A Shepard-Risset glissando, giving the illusion of an ever increasing pitch.
! It is the continuous version of the Shepard scale.
! https://en.wikipedia.org/wiki/Shepard_tone
program shepard_risset_glissando
    use forsynth, only: wp, dt, RATE, PI
    use wav_file_class, only: WAV_file
    use envelopes, only: apply_fade_in, apply_fade_out

    implicit none
    type(WAV_file) :: demo

    ! Pulsation (radians/second):
    real(wp) :: omega
    real(wp) :: t
    real(wp) :: Amp
    integer  :: i, j
    !--------------------------
    ! Glissando parameters:
    !--------------------------
    ! Duration of each component in seconds:
    real(wp), parameter :: d = 16._wp
    ! 20-10000 kHz: 9 octaves
    ! It seems that going higher could introduce artefacts, probably because
    ! we approach the sampling rate (44100 Hz).
    integer, parameter  :: cmax = 9
    ! Bandwidth:
    real(wp), parameter :: fmin = 20._wp         ! Hz
    real(wp), parameter :: fmax = 10000._wp      ! Hz
    ! Frequencies of each component:
    real(wp) :: f(cmax)
    ! Gaussian window, central frequency in log scale:
    real(wp), parameter :: muf  = (log10(fmin) + log10(fmax)) / 2
    ! Standard deviation (very important for a good result):
    real(wp), parameter :: sigma = 0.25_wp
    ! Total duration of the WAV:
    real(wp), parameter :: length = 120._wp

    ! Initializing the components, separated by octaves:
    do j = 1, cmax
        f(j) = fmin * 2**(j-1)
        print *, j, f(j), "Hz"
    end do

    print *, "**** Creating shepard_risset_glissando.wav ****"
    call demo%create_WAV_file('shepard_risset_glissando.wav', tracks=1, duration=length)

    associate(tape => demo%tape_recorder)

    t = 0._wp
    do i = 0, nint(length*RATE)-1
        ! Computing and adding each component on the track:
        do j = 1, cmax
            omega = 2*PI*f(j)
            ! Amplitude fo the signal (gaussian distribution):
            Amp = 1/(sqrt(2*PI)*sigma) * exp(-(log10(f(j)) - muf)**2 / (2 * sigma**2))

            tape%left(1, i)  = tape%left(1, i) + Amp * sin(omega*t)
        end do

        t = t + dt

        ! Modifying frequencies very progressively before next iteration:
        do j = 1, cmax
            ! Increasing pitch:
            f(j) = f(j) * 2**(+1/(d*RATE))

            ! Each component must stay between fmin and fmax:
            if (f(j) > fmax) then
                f(j) = fmin
            else if (f(j) < fmin) then
                f(j) = fmax
            end if
        end do
    end do

    tape%right = tape%left

    call apply_fade_in( tape, track=1, t1=0._wp,    t2=1._wp)
    call apply_fade_out(tape, track=1, t1=length-1, t2=length)

    end associate

    call demo%mix_tracks()
    call demo%close_WAV_file()

    print *,"You can now play the file ", demo%get_name()
end program shepard_risset_glissando
