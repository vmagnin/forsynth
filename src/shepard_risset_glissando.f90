! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2024-05-24
! Last modifications: 2025-03-09

!> A Shepard-Risset glissando, giving the illusion of an ever increasing
!> or decreasing pitch. It is the continuous version of the Shepard scale.
!> Obtaining a good glissando is not easy, as you need to understand that
!> each sin(omega * t) is in fact sin(omega(t) * t). Using a common time for all
!> causes problems as t increases. In this version, each new component has its
!> own time: sin(omega(tj) * tj).
!> https://en.wikipedia.org/wiki/Shepard_tone
program shepard_risset_glissando
    use forsynth, only: wp, dt, RATE, PI
    use wav_file_class, only: WAV_file
    use envelopes, only: apply_fade_in, apply_fade_out

    implicit none
    type(WAV_file) :: demo
    !--------------------------
    ! Glissando parameters:
    !--------------------------
    logical, parameter :: upward = .true.
    ! Bandwidth 20-20480 Hz: 10 octaves
    integer, parameter  :: cmax = 10
    real(wp), parameter :: fmin = 20._wp
    real(wp), parameter :: fmax = fmin * 2**cmax
    ! Proper times of each component:
    real(wp) :: t(cmax)
    ! Frequencies of each component:
    real(wp) :: f(cmax)
    ! Gaussian window, central frequency in log scale, with a shift:
    real(wp), parameter :: muf  = ((log10(fmin) + log10(fmax)) / 2) - 0.6
    ! Standard deviation of the gaussian window:
    real(wp), parameter :: sigma = 0.27_wp
    ! Total duration of the WAV:
    real(wp), parameter :: length = 120._wp
    ! Time in seconds between two new components:
    real(wp), parameter :: d = 5._wp
    ! Setting the frequency increase/decrease rate at each step:
    real(wp), parameter :: increase = 2**(+1/(d*RATE))
    !--------------------------
    ! Pulsation (radians/second):
    real(wp) :: omega
    ! Amplitude of a sinusoid:
    real(wp) :: Amp
    ! Loop counters:
    integer  :: i, j

    ! Useful for debugging and setting the envelope parameters:
    call write_amplitude_envelope()

    ! Initializing the components, separated by octaves:
    if (upward) then
        f = [(fmin * 2**(j-1), j = 1, cmax)]
    else
        f = [(fmax / 2**(j-1), j = 1, cmax)]
    end if
    print *, "Frequencies:", f
    print *, "Log Central frequency:", muf

    print *, "Pitch multiplication factor by time step:", increase

    ! We create a new WAV file, and define the number of tracks and its duration:
    if (upward) then
        call demo%create_WAV_file('shepard_risset_glissando_upward.wav', tracks=1, duration=length)
    else
        call demo%create_WAV_file('shepard_risset_glissando_downward.wav', tracks=1, duration=length)
    end if
    print *, "**** Creating " // demo%get_name() // " ****"

    associate(tape => demo%tape_recorder)

    ! Initializing the proper time of each component:
    do j = 1, cmax
        t(j) = (j-1) * d
    end do

    do i = 0, nint(length*RATE)-1
        ! Computing and adding each component on the track:
        do j = 1, cmax
            ! Amplitude of the signal (gaussian distribution):
            Amp = amplitude(f(j))

            ! Note that omega is not a constant: omega(t)
            ! That is the reason for using a different time for each component.
            omega = 2*PI*f(j)
            tape%left(1, i)  = tape%left(1, i) + Amp * sin(omega*t(j))
        end do

        ! Incrementing all proper times:
        t = t + dt
        ! Pitch variation of each component for next step:
        if (upward) then
            f = f * increase
        else
            f = f / increase
        end if

        ! Each component must stay between fmin and fmax:
        do j = 1, cmax
            if (f(j) > fmax) then           ! For upward glissando
                ! This component must restart from the bottom of the spectrum:
                f(j) = fmin
                ! Its proper time must be also restarted:
                t(j) = 0
            else if (f(j) < fmin) then      ! For downward glissando
                ! This component must restart from the top of the spectrum:
                f(j) = fmax
                ! Its proper time must be also restarted:
                t(j) = 0
            end if
        end do
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

    !> Returns an amplitude rising from 0 to 1, from f1 to f2. And 0 outside.
    pure real(wp) function linear1(freq, f1, f2)
        real(wp), intent(in) :: freq, f1, f2

        if ((f1 <= freq).and.(freq <= f2)) then
            linear1 = (freq - f1) / (f2 - f1)
        else
            linear1 = 0
        end if
    end function

    !> Returns an amplitude falling from 1 to 0, from f1 to f2. And 0 outside.
    pure real(wp) function linear2(freq, f1, f2)
        real(wp), intent(in) :: freq, f1, f2

        if ((f1 <= freq).and.(freq <= f2)) then
            linear2 = (freq - f2) / (f1 - f2)
        else
            linear2 = 0
        end if
    end function

    !> Envelope of the glissando. A gaussian, plus linear sections at
    !> the extremities, to reach the 0 level.
    pure real(wp) function amplitude(freq)
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
        integer, parameter  :: points = 500
        real(wp), parameter :: increase = 2**(+10._wp/points)

        print *, muf, " muf = ", 10**muf

        open(newunit=u, file="glissando_envelope.txt", status='replace', action='write')
        freq = 20._wp
        do i = 1, points
            freq = freq * increase
            write(u, *) freq, amplitude(freq)
        end do
        close(u)
    end subroutine

end program shepard_risset_glissando
