! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-16

module signals
    ! Subroutines generating different kind of signals

    use forsynth, only: wp, RATE, dt, PI
    use envelopes, only: ADSR_enveloppe
    use tape_recorder_class

    implicit none

    private

    public :: add_sine_wave, add_square_wave, add_sawtooth_wave,&
            & add_triangle_wave, add_karplus_strong, add_karplus_strong_stretched, &
            & add_karplus_strong_drum, add_karplus_strong_drum_stretched, &
            & add_noise, weierstrass, add_weierstrass

contains

    ! Adds on the track a sine wave with an ADSR envelope:
    subroutine add_sine_wave(tape, track, t1, t2, f, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, Amp
        ! Phase at t=0 s, radians:
        real(wp), parameter  :: phi = 0.0_wp
        ! Pulsation (radians/second):
        real(wp) :: omega
        ! Time in seconds:
        real(wp) :: t
        ! ADSR Envelope value:
        real(wp) :: env
        real(wp) :: signal
        integer  :: i

        omega = 2.0_wp * PI * f

        t = 0.0_wp
        do i = nint(t1*RATE), nint(t2*RATE)-1
            env = ADSR_enveloppe(t1+t, t1, t2)
            signal = Amp * sin(omega*t + phi) * env

            tape%left(track, i)  = tape%left(track, i)  + signal
            tape%right(track, i) = tape%right(track, i) + signal

            t = t + dt
        end do
    end subroutine add_sine_wave

    ! Adds on the track a square wave with an ADSR envelope:
    subroutine add_square_wave(tape, track, t1, t2, f, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, Amp
        ! Period in seconds:
        real(wp) :: tau
        ! Time in seconds:
        real(wp) :: t
        real(wp) :: signal
        ! ADSR Envelope value:
        real(wp) :: env
        integer  :: i, n

        tau = 1.0_wp / f
        t = 0.0_wp
        do i = nint(t1*RATE), nint(t2*RATE)-1
            env = ADSR_enveloppe(t1+t, t1, t2)

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

            t = t + dt
        end do
    end subroutine add_square_wave

    ! Adds on the track a sawtooth wave with an ADSR envelope:
    subroutine add_sawtooth_wave(tape, track, t1, t2, f, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in) :: track
        real(wp), intent(in) :: t1, t2, f, Amp
        ! Period in seconds:
        real(wp) :: tau
        ! Time in seconds:
        real(wp) :: t
        real(wp) :: signal
        ! ADSR Envelope value:
        real(wp) :: env
        integer  :: i

        tau = 1.0_wp / f
        t = 0.0_wp
        do i = nint(t1*RATE), nint(t2*RATE)-1
            env = ADSR_enveloppe(t1+t, t1, t2)

            ! We substract 0.5 for the signal to be centered on 0:
            signal = 2 * (((t/tau) - floor(t/tau)) - 0.5_wp) * Amp * env

            tape%left(track,  i) = tape%left(track,  i) + signal
            tape%right(track, i) = tape%right(track, i) + signal

            t = t + dt
        end do
    end subroutine add_sawtooth_wave

    ! Adds on the track a triangle wave with an ADSR envelope:
    subroutine add_triangle_wave(tape, track, t1, t2, f, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, Amp
        ! Period in seconds:
        real(wp) :: tau
        ! Time in seconds:
        real(wp) :: t
        real(wp) :: signal
        ! ADSR Envelope value:
        real(wp) :: env
        real(wp) :: a, x
        integer  :: i, n

        tau = 1.0_wp / f
        t = 0.0_wp

        a = (2.0_wp * Amp) / (tau/2.0_wp)

        do i = nint(t1*RATE), nint(t2*RATE)-1
            env = ADSR_enveloppe(t1+t, t1, t2)

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

            t = t + dt
        end do
    end subroutine add_triangle_wave

    ! Karplus and Strong algorithm (1983), for plucked-string
    ! http://crypto.stanford.edu/~blynn/sound/karplusstrong.html
    ! https://en.wikipedia.org/wiki/Karplus%E2%80%93Strong_string_synthesis
    subroutine add_karplus_strong(tape, track, t1, t2, f, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, Amp
        real(wp) :: signal, r
        integer  :: i, P

        P = nint(RATE / f) - 2

        ! Initial noise:
        do i = nint(t1*RATE), nint(t1*RATE) + P
            ! 0 <= r < 1
            call random_number(r)
            ! -Amp <= signal < +Amp
            signal = Amp * (2.0_wp*r - 1.0_wp)

            tape%left(track, i)  = signal
            tape%right(track, i) = signal
        end do
        ! Delay and decay:
        do i = nint(t1*RATE) + P + 1, nint(t2*RATE) - 1
            tape%left(track, i)  = (tape%left(track, i-P) + tape%left(track, i-P-1)) / 2.0_wp
            tape%right(track, i) = tape%left(track, i)
        end do
    end subroutine add_karplus_strong


    subroutine add_karplus_strong_stretched(tape, track, t1, t2, f, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, Amp

        real(wp) :: r
        integer  :: i
        integer  :: P
        ! Stretch factor S > 1:
        real(wp), parameter :: S = 4._wp

        P = nint(RATE / f) - 2

        ! Initial noise:
        do i = nint(t1*RATE), nint(t1*RATE) + P
            ! 0 <= r < 1
            call random_number(r)
            tape%left(track, i)  = Amp * (2.0_wp*r - 1.0_wp)
            tape%right(track, i) = tape%left(track, i)
        end do

        ! Delay and decay:
        do i = nint(t1*RATE) + P + 1, nint(t2*RATE) - 1
            call random_number(r)
            if (r < 1/S) then
                tape%left(track, i) = +0.5_wp * (tape%left(track, i-P) + tape%left(track, i-P-1))
            else
                tape%left(track, i) = +tape%left(track, i-P)
            end if
            tape%right(track, i) = tape%left(track, i)
        end do
    end subroutine add_karplus_strong_stretched


    ! Karplus and Strong (1983) algorithm for obtaining a percussion sound.
    ! Typically, P is taken to be between 150 and 1000.
    ! Caution: this algorithm overwrites what may have existed on the
    ! track at the chosen location.
    ! You may also want to modify the b parameter to make some weird sounds,
    ! somewhere between percussion and guitar...
    ! http://crypto.stanford.edu/~blynn/sound/karplusstrong.html
    ! https://en.wikipedia.org/wiki/Karplus%E2%80%93Strong_string_synthesis
    subroutine add_karplus_strong_drum(tape, track, t1, t2, P, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track, P
        real(wp), intent(in) :: t1, t2, Amp

        real(wp) :: r
        integer  :: i
        ! 0 <= b <= 1 but b = 0.5 is the best value for good drums:
        real(wp), parameter :: b = 0.5_wp
        real(wp) :: the_sign

        ! Initial noise:
        do i = nint(t1*RATE), nint(t1*RATE) + P
            tape%left(track, i)  = Amp
            tape%right(track, i) = Amp
        end do

        ! Evolution and decay:
        do i = nint(t1*RATE) + P + 1, nint(t2*RATE) - 1
            ! The sign of the sample is random:
            call random_number(r)
            if (r < b) then
                the_sign = +1._wp
            else
                the_sign = -1._wp
            end if

            ! Mean of samples i-P and i-P-1:
            tape%left(track, i)  = the_sign * 0.5_wp * (tape%left(track, i-P) + tape%left(track, i-P-1))
            tape%right(track, i) = tape%left(track, i)
        end do
    end subroutine add_karplus_strong_drum


    subroutine add_karplus_strong_drum_stretched(tape, track, t1, t2, P, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer,  intent(in) :: track, P
        real(wp), intent(in) :: t1, t2, Amp

        real(wp) :: r
        integer  :: i
        ! 0 <= b <= 1 but b = 0.5 is the best value for good drums:
        real(wp), parameter :: b = 0.5_wp
        ! Stretch factor S > 1:
        real(wp), parameter :: S = 4._wp

        ! Initial noise:
        do i = nint(t1*RATE), nint(t1*RATE) + P
            tape%left(track, i)  = Amp
            tape%right(track, i) = Amp
        end do

        ! Evolution and decay:
        do i = nint(t1*RATE) + P + 1, nint(t2*RATE) - 1
            ! The sign of the sample is random:
            call random_number(r)
            if (r < b) then
                call random_number(r)
                if (r < 1/S) then
                    tape%left(track, i) = +0.5_wp * (tape%left(track, i-P) + tape%left(track, i-P-1))
                else
                    tape%left(track, i) = +tape%left(track, i-P)
                end if
            else
                call random_number(r)
                if (r < 1/S) then
                    tape%left(track, i) = -0.5_wp * (tape%left(track, i-P) + tape%left(track, i-P-1))
                else
                    tape%left(track, i) = -tape%left(track, i-P)
                end if
            end if

            tape%right(track, i) = tape%left(track, i)
        end do
    end subroutine add_karplus_strong_drum_stretched

    ! Add white noise on the track:
    subroutine add_noise(tape, track, t1, t2, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, Amp
        real(wp) :: r(1:2)
        integer  :: i

        do i = nint(t1*RATE), nint(t2*RATE)-1
            ! Noise is different in both channels:
            call random_number(r)
            tape%left(track,  i) = tape%left(track,  i) + Amp*(2.0_wp*r(1) - 1.0_wp)
            tape%right(track, i) = tape%right(track, i) + Amp*(2.0_wp*r(2) - 1.0_wp)
        end do
    end subroutine

    ! https://en.wikipedia.org/wiki/Weierstrass_function
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

    ! Add a fractal signal on the track with an envelope:
    subroutine add_weierstrass(tape, track, t1, t2, f, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, Amp
        ! Pulsation (radians/second):
        real(wp) :: omega
        ! Time in seconds:
        real(wp) :: t
        ! Phase at t=0 s, radians:
        real(wp), parameter  :: phi = 0.0_wp
        ! ADSR Envelope value:
        real(wp) :: env
        real(wp) :: signal
        real(wp) :: a, b
        integer  :: i

        ! 0 < a < 1.
        a = 0.975_wp
        ! If a.b > 1 the function is fractal:
        b = 1._wp/.975_wp + 0.005_wp ;

        omega = 2.0_wp * PI * f
        t = 0._wp
        do i = nint(t1*RATE), nint(t2*RATE)-1
            env = ADSR_enveloppe(t1+t, t1, t2)
            signal = Amp * weierstrass(a, b, omega*t + phi) * env
            ! It is addd to the already present signal:
            tape%left(track, i)  = tape%left(track, i)  + signal
            tape%right(track, i) = tape%right(track, i) + signal

            t = t + dt
        end do
    end subroutine add_weierstrass

end module signals
