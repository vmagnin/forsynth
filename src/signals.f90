! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-04-28

module signals
    ! Subroutines generating different kind of signals

    use forsynth, only: dp, RATE, dt, PI, left, right
    use envelopes, only: ADSR_enveloppe

    implicit none

    private

    public :: add_sine_wave, add_square_wave, add_sawtooth_wave,&
            & add_triangle_wave, add_karplus_strong, add_karplus_strong_stretched, &
            & add_karplus_strong_drum, add_karplus_strong_drum_stretched, &
            & add_noise, weierstrass, add_weierstrass

contains

    subroutine add_sine_wave(track, t1, t2, f, Amp)
        integer, intent(in)  :: track
        real(dp), intent(in) :: t1, t2, f, Amp
        ! Phase at t=0 s, radians:
        real(dp), parameter  :: phi = 0.0_dp
        ! Pulsation (radians/second):
        real(dp) :: omega
        ! Time in seconds:
        real(dp) :: t
        ! ADSR Envelope value:
        real(dp) :: env
        real(dp) :: signal
        integer  :: i

        omega = 2.0_dp * PI * f

        t = 0.0_dp
        do i = nint(t1*RATE), nint(t2*RATE)-1
            env = ADSR_enveloppe(t1+t, t1, t2)
            signal = Amp * sin(omega*t + phi) * env

            left(track, i)  = left(track, i)  + signal
            right(track, i) = right(track, i) + signal

            t = t + dt
        end do
    end subroutine add_sine_wave


    subroutine add_square_wave(track, t1, t2, f, Amp)
        integer, intent(in)  :: track
        real(dp), intent(in) :: t1, t2, f, Amp
        ! Period in seconds:
        real(dp) :: tau
        ! Time in seconds:
        real(dp) :: t
        real(dp) :: signal
        ! ADSR Envelope value:
        real(dp) :: env
        integer  :: i, n

        tau = 1.0_dp / f
        t = 0.0_dp
        do i = nint(t1*RATE), nint(t2*RATE)-1
            env = ADSR_enveloppe(t1+t, t1, t2)

            ! Number of the half-period:
            n = int(t / (tau/2.0_dp))

            ! If n is even, signal is +Amp, if odd -Amp:
            if (mod(n, 2) == 0) then
                signal = +Amp * env
            else
                signal = -Amp * env
            end if

            left(track,  i) = left(track,  i) + signal
            right(track, i) = right(track, i) + signal

            t = t + dt
        end do
    end subroutine add_square_wave


    subroutine add_sawtooth_wave(track, t1, t2, f, Amp)
        integer, intent(in) :: track
        real(dp), intent(in) :: t1, t2, f, Amp
        ! Period in seconds:
        real(dp) :: tau
        ! Time in seconds:
        real(dp) :: t
        real(dp) :: signal
        ! ADSR Envelope value:
        real(dp) :: env
        integer  :: i

        tau = 1.0_dp / f
        t = 0.0_dp
        do i = nint(t1*RATE), nint(t2*RATE)-1
            env = ADSR_enveloppe(t1+t, t1, t2)

            ! We substract 0.5 for the signal to be centered on 0:
            signal = 2 * (((t/tau) - floor(t/tau)) - 0.5_dp) * Amp * env

            left(track,  i) = left(track,  i) + signal
            right(track, i) = right(track, i) + signal

            t = t + dt
        end do
    end subroutine add_sawtooth_wave


    subroutine add_triangle_wave(track, t1, t2, f, Amp)
        integer, intent(in)  :: track
        real(dp), intent(in) :: t1, t2, f, Amp
        ! Period in seconds:
        real(dp) :: tau
        ! Time in seconds:
        real(dp) :: t
        real(dp) :: signal
        ! ADSR Envelope value:
        real(dp) :: env
        real(dp) :: a, x
        integer  :: i, n

        tau = 1.0_dp / f
        t = 0.0_dp

        a = (2.0_dp * Amp) / (tau/2.0_dp)

        do i = nint(t1*RATE), nint(t2*RATE)-1
            env = ADSR_enveloppe(t1+t, t1, t2)

            ! Number of the half-period:
            n = int(t / (tau/2.0_dp))

            ! Is n even or odd ?
            if (mod(n, 2) == 0) then
                x = t - n*(tau/2.0_dp) ;
                signal = a*x - Amp
            else
                x = t - n*(tau/2.0_dp) + tau/2.0_dp ;
                signal = - a*x + 3.0_dp*Amp
            end if

            left(track,  i) = left(track,  i) + signal * env
            right(track, i) = right(track, i) + signal * env

            t = t + dt
        end do
    end subroutine add_triangle_wave


    subroutine add_karplus_strong(track, t1, t2, f, Amp)
        ! Karplus and Strong algorithm (1983), for plucked-string
        ! http://crypto.stanford.edu/~blynn/sound/karplusstrong.html
        ! https://en.wikipedia.org/wiki/Karplus%E2%80%93Strong_string_synthesis
        integer, intent(in)  :: track
        real(dp), intent(in) :: t1, t2, f, Amp
        real(dp) :: signal, r
        integer  :: i, P

        P = nint(RATE / f) - 2

        ! Initial noise:
        do i = nint(t1*RATE), nint(t1*RATE) + P
            ! 0 <= r < 1
            call random_number(r)
            ! -Amp <= signal < +Amp
            signal = Amp * (2.0_dp*r - 1.0_dp)

            left(track, i)  = signal
            right(track, i) = signal
        end do
        ! Delay and decay:
        do i = nint(t1*RATE) + P + 1, nint(t2*RATE) - 1
            left(track, i)  = (left(track, i-P) + left(track, i-P-1)) / 2.0_dp
            right(track, i) = left(track, i)
        end do
    end subroutine add_karplus_strong


    subroutine add_karplus_strong_stretched(track, t1, t2, f, Amp)
        integer, intent(in)  :: track
        real(dp), intent(in) :: t1, t2, f, Amp

        real(dp) :: r
        integer  :: i
        integer  :: P
        ! Stretch factor S > 1:
        real(dp), parameter :: S = 4._dp

        P = nint(RATE / f) - 2

        ! Initial noise:
        do i = nint(t1*RATE), nint(t1*RATE) + P
            ! 0 <= r < 1
            call random_number(r)
            left(track, i)  = Amp * (2.0_dp*r - 1.0_dp)
            right(track, i) = left(track, i)
        end do

        ! Delay and decay:
        do i = nint(t1*RATE) + P + 1, nint(t2*RATE) - 1
            call random_number(r)
            if (r < 1/S) then
                left(track, i) = +0.5_dp * (left(track, i-P) + left(track, i-P-1))
            else
                left(track, i) = +left(track, i-P)
            end if
            right(track, i) = left(track, i)
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
    subroutine add_karplus_strong_drum(track, t1, t2, P, Amp)
        integer, intent(in)  :: track, P
        real(dp), intent(in) :: t1, t2, Amp

        real(dp) :: r
        integer  :: i
        ! 0 <= b <= 1 but b = 0.5 is the best value for good drums:
        real(dp), parameter :: b = 0.5_dp
        real(dp) :: the_sign

        ! Initial noise:
        do i = nint(t1*RATE), nint(t1*RATE) + P
            left(track, i)  = Amp
            right(track, i) = Amp
        end do

        ! Evolution and decay:
        do i = nint(t1*RATE) + P + 1, nint(t2*RATE) - 1
            ! The sign of the sample is random:
            call random_number(r)
            if (r < b) then
                the_sign = +1._dp
            else
                the_sign = -1._dp
            end if

            ! Mean of samples i-P and i-P-1:
            left(track, i)  = the_sign * 0.5_dp * (left(track, i-P) + left(track, i-P-1))
            right(track, i) = left(track, i)
        end do
    end subroutine add_karplus_strong_drum


    subroutine add_karplus_strong_drum_stretched(track, t1, t2, P, Amp)
        integer,  intent(in) :: track, P
        real(dp), intent(in) :: t1, t2, Amp

        real(dp) :: r
        integer  :: i
        ! 0 <= b <= 1 but b = 0.5 is the best value for good drums:
        real(dp), parameter :: b = 0.5_dp
        ! Stretch factor S > 1:
        real(dp), parameter :: S = 4._dp

        ! Initial noise:
        do i = nint(t1*RATE), nint(t1*RATE) + P
            left(track, i)  = Amp
            right(track, i) = Amp
        end do

        ! Evolution and decay:
        do i = nint(t1*RATE) + P + 1, nint(t2*RATE) - 1
            ! The sign of the sample is random:
            call random_number(r)
            if (r < b) then
                call random_number(r)
                if (r < 1/S) then
                    left(track, i) = +0.5_dp * (left(track, i-P) + left(track, i-P-1))
                else
                    left(track, i) = +left(track, i-P)
                end if
            else
                call random_number(r)
                if (r < 1/S) then
                    left(track, i) = -0.5_dp * (left(track, i-P) + left(track, i-P-1))
                else
                    left(track, i) = -left(track, i-P)
                end if
            end if

            right(track, i) = left(track, i)
        end do
    end subroutine add_karplus_strong_drum_stretched


    subroutine add_noise(track, t1, t2, Amp)
        integer, intent(in)  :: track
        real(dp), intent(in) :: t1, t2, Amp
        real(dp) :: r(1:2)
        integer  :: i

        do i = nint(t1*RATE), nint(t2*RATE)-1
            ! Noise is different in both channels:
            call random_number(r)
            left(track,  i) = left(track,  i) + Amp*(2.0_dp*r(1) - 1.0_dp)
            right(track, i) = right(track, i) + Amp*(2.0_dp*r(2) - 1.0_dp)
        end do
    end subroutine

    ! https://en.wikipedia.org/wiki/Weierstrass_function
    pure real(dp) function weierstrass(a, b, x)
        real(dp), intent(in) :: a, b, x
        real(dp) :: w, ww
        integer  :: n

        n = 0
        w = 0._dp
        do
            ww = w
            w = w + a**n * cos(b**n * PI * x)
            if (abs(ww - w) < 1e-16_dp) exit

            n = n + 1
        end do

        weierstrass = w
    end function

    ! A fractal signal:
    subroutine add_weierstrass(track, t1, t2, f, Amp)
        integer, intent(in)  :: track
        real(dp), intent(in) :: t1, t2, f, Amp
        ! Pulsation (radians/second):
        real(dp) :: omega
        ! Time in seconds:
        real(dp) :: t
        ! Phase at t=0 s, radians:
        real(dp), parameter  :: phi = 0.0_dp
        ! ADSR Envelope value:
        real(dp) :: env
        real(dp) :: signal
        real(dp) :: a, b
        integer  :: i

        ! 0 < a < 1.
        a = 0.975_dp
        ! If a.b > 1 the function is fractal:
        b = 1._dp/.975_dp + 0.005_dp ;

        omega = 2.0_dp * PI * f
        t = 0._dp
        do i = nint(t1*RATE), nint(t2*RATE)-1
            env = ADSR_enveloppe(t1+t, t1, t2)
            signal = Amp * weierstrass(a, b, omega*t + phi) * env
            ! It is addd to the already present signal:
            left(track, i)  = left(track, i)  + signal
            right(track, i) = right(track, i) + signal

            t = t + dt
        end do
    end subroutine add_weierstrass

end module signals
