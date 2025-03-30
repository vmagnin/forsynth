! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2025-03-19

!> Subroutines generating different kind of signals
module signals
    use forsynth, only: wp, RATE, dt, PI
    use envelopes, only: ADSR_envelope, fit_exp
    use tape_recorder_class

    implicit none

    private

    public :: add_sine_wave, add_square_wave, add_sawtooth_wave,&
            & add_triangle_wave, add_karplus_strong, add_karplus_strong_stretched, &
            & add_karplus_strong_drum, add_karplus_strong_drum_stretched, &
            & add_noise, weierstrass, add_weierstrass, add_bell

contains

    !> Adds on the track a sine wave with an ADSR envelope:
    subroutine add_sine_wave(tape, track, t1, t2, f, Amp, envelope)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, Amp
        type(ADSR_envelope), optional, intent(in) :: envelope
        ! Pulsation (radians/second):
        real(wp) :: omega
        ! Time in seconds:
        real(wp) :: t
        ! ADSR Envelope value:
        real(wp) :: env
        real(wp) :: signal
        integer  :: i

        env = 1._wp     ! Default value if no envelope is passed
        omega = 2.0_wp * PI * f

        do concurrent(i = nint(t1*RATE) : min(nint(t2*RATE), tape%last))
            t = (i - nint(t1*RATE)) * dt

            if (present(envelope)) env = envelope%get_level(t1+t, t1, t2)

            signal = Amp * sin(omega*t) * env

            tape%left(track, i)  = tape%left(track, i)  + signal
            tape%right(track, i) = tape%right(track, i) + signal
        end do
    end subroutine add_sine_wave

    !> Adds on the track a square wave with an ADSR envelope:
    subroutine add_square_wave(tape, track, t1, t2, f, Amp, envelope)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, Amp
        type(ADSR_envelope), optional, intent(in) :: envelope
        ! Period in seconds:
        real(wp) :: tau
        ! Time in seconds:
        real(wp) :: t
        real(wp) :: signal
        ! ADSR Envelope value:
        real(wp) :: env
        integer  :: i, n

        env = 1._wp     ! Default value if no envelope is passed
        tau = 1.0_wp / f

        do concurrent(i = nint(t1*RATE) : min(nint(t2*RATE), tape%last))

            if (present(envelope)) env = envelope%get_level(t1+t, t1, t2)

            ! Number of the half-period:
            n = int(t / (tau/2.0_wp))

            ! If n is even, signal is +Amp, if odd -Amp:
            if (mod(n, 2) == 0) then
                signal = +Amp * env
            else
                signal = -Amp * env
            end if

            tape%left(track,  i) = tape%left(track,  i) + signal
            tape%right(track, i) = tape%right(track, i) + signal
        end do
    end subroutine add_square_wave

    !> Adds on the track a sawtooth wave with an ADSR envelope:
    subroutine add_sawtooth_wave(tape, track, t1, t2, f, Amp, envelope)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in) :: track
        real(wp), intent(in) :: t1, t2, f, Amp
        type(ADSR_envelope), optional, intent(in) :: envelope
        ! Period in seconds:
        real(wp) :: tau
        ! Time in seconds:
        real(wp) :: t
        real(wp) :: signal
        ! ADSR Envelope value:
        real(wp) :: env
        integer  :: i

        env = 1._wp     ! Default value if no envelope is passed
        tau = 1.0_wp / f

        do concurrent(i = nint(t1*RATE) : min(nint(t2*RATE), tape%last))
            t = (i - nint(t1*RATE)) * dt

            if (present(envelope)) env = envelope%get_level(t1+t, t1, t2)

            ! We substract 0.5 for the signal to be centered on 0:
            signal = 2 * (((t/tau) - floor(t/tau)) - 0.5_wp) * Amp * env

            tape%left(track,  i) = tape%left(track,  i) + signal
            tape%right(track, i) = tape%right(track, i) + signal
        end do
    end subroutine add_sawtooth_wave

    !> Adds on the track a triangle wave with an ADSR envelope:
    subroutine add_triangle_wave(tape, track, t1, t2, f, Amp, envelope)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, Amp
        type(ADSR_envelope), optional, intent(in) :: envelope
        ! Period in seconds:
        real(wp) :: tau
        ! Time in seconds:
        real(wp) :: t
        real(wp) :: signal
        ! ADSR Envelope value:
        real(wp) :: env
        real(wp) :: a, x
        integer  :: i, n

        env = 1._wp     ! Default value if no envelope is passed
        tau = 1.0_wp / f
        a = (2.0_wp * Amp) / (tau/2.0_wp)

        do concurrent(i = nint(t1*RATE) : min(nint(t2*RATE), tape%last))
            t = (i - nint(t1*RATE)) * dt

            if (present(envelope)) env = envelope%get_level(t1+t, t1, t2)

            ! Number of the half-period:
            n = int(t / (tau/2.0_wp))

            ! Is n even or odd ?
            if (mod(n, 2) == 0) then
                x = t - n*(tau/2.0_wp) ;
                signal = a*x - Amp
            else
                x = t - n*(tau/2.0_wp) + tau/2.0_wp ;
                signal = - a*x + 3.0_wp*Amp
            end if

            tape%left(track,  i) = tape%left(track,  i) + signal * env
            tape%right(track, i) = tape%right(track, i) + signal * env
        end do
    end subroutine add_triangle_wave

    !> Karplus and Strong algorithm (1983), for plucked-string
    !> http://crypto.stanford.edu/~blynn/sound/karplusstrong.html
    !> https://en.wikipedia.org/wiki/Karplus%E2%80%93Strong_string_synthesis
    subroutine add_karplus_strong(tape, track, t1, t2, f, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, Amp
        real(wp) :: signal, r
        integer  :: i, P
        integer  :: i1, i2

        i1 = nint(t1*RATE)
        i2 = min(nint(t2*RATE), tape%last)

        P = nint(RATE / f) - 2

        ! Initial noise:
        do i = i1, i1 + P
            ! 0 <= r < 1
            call random_number(r)
            ! -Amp <= signal < +Amp
            signal = Amp * (2.0_wp*r - 1.0_wp)
            ! Track 0 is used as an auxiliary track:
            tape%left( 0, i) = signal
            tape%right(0, i) = signal
        end do
        ! Delay and decay:
        do i = i1 + P + 1, i2
            tape%left( 0, i) = (tape%left(0, i-P) + tape%left(0, i-P-1)) / 2.0_wp
            tape%right(0, i) = tape%left(0, i)
        end do

        ! Transfer (add) on the good track:
        tape%left( track, i1:i2) = tape%left( track, i1:i2) + tape%left( 0, i1:i2)
        tape%right(track, i1:i2) = tape%right(track, i1:i2) + tape%right(0, i1:i2)
    end subroutine add_karplus_strong

    !> Karplus and Strong stretched algorithm (1983), for plucked-string.
    subroutine add_karplus_strong_stretched(tape, track, t1, t2, f, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, Amp
        integer  :: i1, i2
        real(wp) :: r
        integer  :: i
        integer  :: P
        ! Stretch factor S > 1:
        real(wp), parameter :: S = 4._wp

        i1 = nint(t1*RATE)
        i2 = min(nint(t2*RATE), tape%last)

        P = nint(RATE / f) - 2

        ! Initial noise:
        do i = i1, i1 + P
            ! 0 <= r < 1
            call random_number(r)
            ! Track 0 is used as an auxiliary track:
            tape%left( 0, i) = Amp * (2.0_wp*r - 1.0_wp)
            tape%right(0, i) = tape%left(0, i)
        end do

        ! Delay and decay:
        do i = i1 + P + 1, i2
            call random_number(r)
            if (r < 1/S) then
                tape%left(0, i) = +0.5_wp * (tape%left(0, i-P) + tape%left(0, i-P-1))
            else
                tape%left(0, i) = +tape%left(0, i-P)
            end if
            tape%right(0, i) = tape%left(0, i)
        end do

        ! Transfer (add) on the good track:
        tape%left( track, i1:i2) = tape%left( track, i1:i2) + tape%left( 0, i1:i2)
        tape%right(track, i1:i2) = tape%right(track, i1:i2) + tape%right(0, i1:i2)
    end subroutine add_karplus_strong_stretched


    !> Karplus and Strong (1983) algorithm for obtaining a percussion sound.
    !> Typically, P is taken to be between 150 and 1000.
    !> Caution: this algorithm overwrites what may have existed on the
    !> track at the chosen location.
    !> You may also want to modify the b parameter to make some weird sounds,
    !> somewhere between percussion and guitar...
    !> http://crypto.stanford.edu/~blynn/sound/karplusstrong.html
    !> https://en.wikipedia.org/wiki/Karplus%E2%80%93Strong_string_synthesis
    subroutine add_karplus_strong_drum(tape, track, t1, t2, P, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track, P
        real(wp), intent(in) :: t1, t2, Amp
        integer  :: i1, i2

        real(wp) :: r
        integer  :: i
        ! 0 <= b <= 1 but b = 0.5 is the best value for good drums:
        real(wp), parameter :: b = 0.5_wp
        real(wp) :: the_sign

        i1 = nint(t1*RATE)
        i2 = min(nint(t2*RATE), tape%last)

        ! Track 0 is used as an auxiliary track.

        ! Attack:
        tape%left( 0, i1:i1+P) = Amp
        tape%right(0, i1:i1+P) = Amp

        ! Evolution and decay:
        do i = i1 + P + 1, i2
            ! The sign of the sample is random:
            call random_number(r)
            if (r < b) then
                the_sign = +1._wp
            else
                the_sign = -1._wp
            end if

            ! Mean of samples i-P and i-P-1:
            tape%left( 0, i) = the_sign * 0.5_wp * (tape%left(0, i-P) + tape%left(0, i-P-1))
            tape%right(0, i) = tape%left(0, i)
        end do

        ! Transfer (add) on the good track:
        tape%left( track, i1:i2) = tape%left( track, i1:i2) + tape%left( 0, i1:i2)
        tape%right(track, i1:i2) = tape%right(track, i1:i2) + tape%right(0, i1:i2)
    end subroutine add_karplus_strong_drum

    !> Karplus and Strong (1983) stretched algorithm for obtaining a percussion sound.
    subroutine add_karplus_strong_drum_stretched(tape, track, t1, t2, P, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer,  intent(in) :: track, P
        real(wp), intent(in) :: t1, t2, Amp
        integer  :: i1, i2

        real(wp) :: r
        integer  :: i
        ! 0 <= b <= 1 but b = 0.5 is the best value for good drums:
        real(wp), parameter :: b = 0.5_wp
        ! Stretch factor S > 1:
        real(wp), parameter :: S = 4._wp

        i1 = nint(t1*RATE)
        i2 = min(nint(t2*RATE), tape%last)

        ! Track 0 is used as an auxiliary track.

        ! Attack:
        tape%left( 0, i1:i1+P) = Amp
        tape%right(0, i1:i1+P) = Amp

        ! Evolution and decay:
        do i = i1 + P + 1, i2
            ! The sign of the sample is random:
            call random_number(r)
            if (r < b) then
                call random_number(r)
                if (r < 1/S) then
                    tape%left(0, i) = +0.5_wp * (tape%left(0, i-P) + tape%left(0, i-P-1))
                else
                    tape%left(0, i) = +tape%left(0, i-P)
                end if
            else
                call random_number(r)
                if (r < 1/S) then
                    tape%left(0, i) = -0.5_wp * (tape%left(0, i-P) + tape%left(0, i-P-1))
                else
                    tape%left(0, i) = -tape%left(0, i-P)
                end if
            end if

            tape%right(0, i) = tape%left(0, i)
        end do

        ! Transfer (add) on the good track:
        tape%left( track, i1:i2) = tape%left( track, i1:i2) + tape%left( 0, i1:i2)
        tape%right(track, i1:i2) = tape%right(track, i1:i2) + tape%right(0, i1:i2)
    end subroutine add_karplus_strong_drum_stretched


    !> Add white noise on the track:
    subroutine add_noise(tape, track, t1, t2, Amp, envelope)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, Amp
        type(ADSR_envelope), optional, intent(in) :: envelope
        ! ADSR Envelope value:
        real(wp) :: env
        real(wp) :: r(1:2)
        integer  :: i
        ! Time in seconds:
        real(wp) :: t

        ! Default value:
        env = 1._wp

        t = 0._wp
        do i = nint(t1*RATE), min(nint(t2*RATE), tape%last)
            ! Noise is different in both channels:
            call random_number(r)
            if (present(envelope)) env = envelope%get_level(t1+t, t1, t2)
            tape%left(track,  i) = tape%left(track,  i) + Amp*env*(2.0_wp*r(1) - 1.0_wp)
            tape%right(track, i) = tape%right(track, i) + Amp*env*(2.0_wp*r(2) - 1.0_wp)

            t = t + dt
        end do
    end subroutine

    !> https://en.wikipedia.org/wiki/Weierstrass_function
    pure real(wp) function weierstrass(a, b, x)
        real(wp), intent(in) :: a, b, x
        real(wp) :: w, ww
        integer  :: n

        n = 0
        w = 0._wp
        do
            ww = w
            w = w + a**n * cos(b**n * PI * x)
            if (abs(ww - w) < 1e-16_wp) exit

            n = n + 1
        end do

        weierstrass = w
    end function

    !> Add a fractal signal on the track with an envelope:
    subroutine add_weierstrass(tape, track, t1, t2, f, Amp, envelope)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, Amp
        type(ADSR_envelope), optional, intent(in) :: envelope
        ! Pulsation (radians/second):
        real(wp) :: omega
        ! Time in seconds:
        real(wp) :: t
        ! ADSR Envelope value:
        real(wp) :: env
        real(wp) :: signal
        ! 0 < a < 1.
        real(wp), parameter :: a = 0.975_wp
        ! If a.b > 1 the function is fractal:
        real(wp), parameter :: b = 1._wp/.975_wp + 0.005_wp
        integer  :: i

        env = 1._wp     ! Default value if no envelope is passed
        omega = 2.0_wp * PI * f

        do concurrent(i = nint(t1*RATE) : min(nint(t2*RATE), tape%last))
            t = (i - nint(t1*RATE)) * dt

            if (present(envelope)) env = envelope%get_level(t1+t, t1, t2)
            signal = Amp * weierstrass(a, b, omega*t) * env
            ! It is addd to the already present signal:
            tape%left(track, i)  = tape%left(track, i)  + signal
            tape%right(track, i) = tape%right(track, i) + signal
        end do
    end subroutine add_weierstrass

    !> Adds a Risset bell sound on the track at t1.
    !> Jean-Claude Risset, An Introductory Catalogue Of Computer Synthesized Sounds,
    !> Bell Telephone Laboratories  Murray Hill, New Jersey, 1969.
    subroutine add_bell(tape, track, t1, f, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, f, Amp
        real(wp) :: t, t2
        real(wp) :: ratio, q
        real(wp) :: signal
        integer  :: i

        ratio = f / 368._wp ! [Risset, 1969] gives a bell with a 368 Hz fundamental.
        t2 = t1 + 20._wp    ! The longest partial (hum) is lasting 20 seconds.

        ! The MIN() is used to stay inside the tape arrays.
        do concurrent(i = nint(t1*RATE) : min(nint(t2*RATE), tape%last))
            t = t1 + (i - nint(t1*RATE)) * dt

            q = (2*PI*ratio)*(t-t1)
            ! The eleven frequencies come from [Risset, 1969], sound #430.
            ! x1 and x2 are the start and end of an exponentially decaying envelope
            ! and y1 and y2 are its height at x1 and x2.
            signal = Amp * ( &
                ! Hum (with beating between 224 Hz and 225 Hz):
                 &   fit_exp(t, x1=t1+0._wp, y1=1.5_wp, x2=t1+20._wp, y2=0.001_wp) * sin(q*224.0_wp) &
                 & + fit_exp(t, x1=t1+0._wp, y1=1._wp,  x2=t1+18._wp, y2=0.001_wp) * sin(q*225.0_wp) &
                ! Fundamental (with beating between 368 Hz and 369.7 Hz):
                 & + fit_exp(t, x1=t1+0._wp, y1=1.5_wp, x2=t1+13._wp, y2=0.001_wp) * sin(q*368.0_wp) &
                 & + fit_exp(t, x1=t1+0._wp, y1=2.7_wp, x2=t1+11._wp, y2=0.001_wp) * sin(q*369.7_wp) &
                ! Other partials:
                 & + fit_exp(t, x1=t1+0._wp, y1=4._wp,  x2=t1+6.5_wp, y2=0.001_wp) * sin(q*476.0_wp) &
                 & + fit_exp(t, x1=t1+0._wp, y1=2.5_wp, x2=t1+7._wp,  y2=0.001_wp) * sin(q*680.0_wp) &
                 & + fit_exp(t, x1=t1+0._wp, y1=2.2_wp, x2=t1+5._wp,  y2=0.001_wp) * sin(q*800.0_wp) &
                 & + fit_exp(t, x1=t1+0._wp, y1=2._wp,  x2=t1+4._wp,  y2=0.001_wp) * sin(q*1096._wp) &
                 & + fit_exp(t, x1=t1+0._wp, y1=2._wp,  x2=t1+3._wp,  y2=0.001_wp) * sin(q*1200._wp) &
                 & + fit_exp(t, x1=t1+0._wp, y1=1.5_wp, x2=t1+2._wp,  y2=0.001_wp) * sin(q*1504._wp) &
                 & + fit_exp(t, x1=t1+0._wp, y1=2._wp,  x2=t1+1.5_wp, y2=0.001_wp) * sin(q*1628._wp) )

            tape%left( track, i) = tape%left( track, i) + signal
            tape%right(track, i) = tape%right(track, i) + signal
        end do
    end subroutine add_bell

end module signals
