! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2024-05-24
! Last modifications: 2024-06-03

!> A Shepard-Risset glissando, giving the illusion of an ever increasing pitch.
!> It is the continuous version of the Shepard scale.
!> It is not perfect, as we can hear that globally the whole is getting slowly
!> higher. It is also visible when zooming in the waveform woth audacity.
!> Some kind of beating might occur due to the fact that in the sin(),
!> both omega and t are varying at each step. But as the f() are now redefined
!> regularly, things are unclear for the moment...
!> https://en.wikipedia.org/wiki/Shepard_tone
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
    ! Bandwidth 20-20480 Hz: 10 octaves
    integer, parameter  :: cmax = 10
    real(wp), parameter :: fmin = 20._wp
    real(wp), parameter :: fmax = fmin * 2**cmax
    ! Frequencies of each component:
    real(wp) :: f(cmax)
    ! Gaussian window, central frequency in log scale, with a shift:
    real(wp), parameter :: muf  = ((log10(fmin) + log10(fmax)) / 2) - 0.3
    ! Standard deviation (very important for a good result):
    real(wp), parameter :: sigma = 0.25_wp
    ! Total duration of the WAV:
    real(wp), parameter :: length = 120._wp
    ! Setting the increase rate:
    real(wp), parameter :: d = 16._wp
    real(wp), parameter :: increase = 2**(+1/(d*RATE))
    logical :: restart

    ! Useful for debugging and setting the envelope parameters:
    !call write_amplitude_envelope()

    ! Initializing the components, separated by octaves:
    call initialize_frequencies()
    print *, "Frequencies:", f

    print *, "Log Central frequency:", muf
    print *, "Pitch increase:", increase

    print *, "**** Creating shepard_risset_glissando.wav ****"
    ! We create a new WAV file, and define the number of tracks and its duration:
    call demo%create_WAV_file('shepard_risset_glissando.wav', tracks=1, duration=length)

    associate(tape => demo%tape_recorder)

    do i = 0, nint(length*RATE)-1
        t = i*dt
        ! Computing and adding each component on the track:
        do j = 1, cmax
            omega = 2*PI*f(j)
            ! Amplitude of the signal (gaussian distribution):
            Amp = amplitude(f(j))

            tape%left(1, i)  = tape%left(1, i) + Amp * sin(omega*t)
        end do

        ! Increasing pitch of each component:
        f = f * increase
        restart = .false.
        ! Each component must stay between fmin and fmax:
        if (maxval(f) >= fmax) restart = .true.
        ! Would be useful for a decreasing glissando:
        if (minval(f) <= fmin) restart = .true.

        ! As each component is separated by one octave, we can
        ! redefine all the components as they were at t=0, each time one has
        ! passed the last octave. In that way, we are sure they won't diverge
        ! at all due to numerical problems:
        if (restart) then
            call initialize_frequencies
        end if
    end do

    tape%right = tape%left

    call apply_fade_in( tape, track=1, t1=0._wp,    t2=1._wp)
    call apply_fade_out(tape, track=1, t1=length-1, t2=length)

    end associate

    ! All tracks will be mixed on track 0.
    ! Needed even if there is only one track!
    call demo%mix_tracks()
    call demo%close_WAV_file()

    print *,"You can now play the file ", demo%get_name()

contains

    subroutine initialize_frequencies()
        integer :: j

        do j = 1, cmax
            f(j) = fmin * 2**(j-1)
        end do
    end subroutine

    !> Returns an amplitude rising from 0 to 1, from f1 to f2. And 0 outside.
    real(wp) function linear1(freq, f1, f2)
        real(wp), intent(in) :: freq, f1, f2

        if ((f1 <= freq).and.(freq <= f2)) then
            linear1 = (freq - f1) / (f2 - f1)
        else
            linear1 = 0
        end if
    end function

    !> Returns an amplitude falling from 1 to 0, from f1 to f2. And 0 outside.
    real(wp) function linear2(freq, f1, f2)
        real(wp), intent(in) :: freq, f1, f2

        if ((f1 <= freq).and.(freq <= f2)) then
            linear2 = (freq - f2) / (f1 - f2)
        else
            linear2 = 0
        end if
    end function

    !> Envelope of the glissando. A gaussian, plus linear sections at
    !> the extremities, to reach the 0 level.
    real(wp) function amplitude(freq)
        real(wp), intent(in) :: freq
        real(wp) :: Amp

        if (freq <= 2*fmin) then
            Amp = linear1(freq, fmin, 2*fmin)
        else if (freq >= fmax/2) then
            Amp = linear2(freq, fmax/2, fmax)
        else
            Amp = 1
        end if

        amplitude = Amp * (1/(sqrt(2*PI)*sigma)) * exp(-(log10(freq) - muf)**2 / (2 * sigma**2))
    end function

    !> Useful for debugging and setting the envelope parameters:
    subroutine write_amplitude_envelope()
        real(wp) ::freq
        integer  :: u
        integer, parameter :: points = 500

        print *, muf, " muf = ", 10**muf

        open(newunit=u, file="glissando_envelope.txt", status='replace', action='write')
        do i = 1, points
            freq = fmin + i*(fmax-fmin) / points
            write(u, *) freq, amplitude(freq)
        end do
        close(u)
    end subroutine

end program shepard_risset_glissando
