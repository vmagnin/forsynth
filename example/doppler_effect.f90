! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2024-05-28
! Last modifications: 2024-05-29

! A simulation of Doppler effect, with a car passing in front of you.
! https://fr.wikipedia.org/wiki/Effet_Doppler
program doppler_effect
    use forsynth, only: wp, dt, RATE, PI
    use wav_file_class, only: WAV_file

    implicit none
    type(WAV_file) :: demo
    real(wp) :: panL, panR
    ! Pulsation (radians/second):
    real(wp) :: omega
    real(wp) :: t, tobs
    real(wp) :: Amp
    integer  :: i, j
    real(wp) :: x0, x, y
    real(wp), parameter :: duration = 7._wp   ! Duration in seconds
    real(wp), parameter :: y0 = 10            ! m
    real(wp), parameter :: v = 130000._wp / 3600  ! 130 km/h (car velocity)
    ! https://en.wikipedia.org/wiki/Speed_of_sound
    real(wp), parameter :: c = 343   ! m/s at 20°C in air
    real(wp), parameter :: f = 50    ! Hz

    print *, "**** Creating doppler_effect.wav ****"
    call demo%create_WAV_file('doppler_effect.wav', tracks=1, duration=duration)

    associate(tape => demo%tape_recorder)

! The Observer is static at the origin,
! the car is Moving along x at a constant velocity v
!                        ^ y
!                        |
!      ****M*************y0**************>
!                        |
! ----x0-----------------O-------------------> x
!                        |

    omega = 2*PI*f
    x0 = -v * duration/2
    ! y is constant:
    y  = y0

    print '(3A8, A10, 2A8)', "tobs", "t", "x", "Amp", "panL", "panR"

    tobs = 0
    do i = 0, nint(duration*RATE) - 1
        ! The frequency perceived by the observer (Doppler effect)
        ! is fobs = f / (1 - vr/c) but we don't need to compute it.
        ! The signal heard by the observer at tobs was emitted earlier by the
        ! car at t, from a distance r(t):
        ! tobs = t + r(t) / c
        ! By developing r(t) we can finally obtain a quadratic equation:
        ! (c**2-v**2) * t**2 - (2*tobs*c**2 + 2*x0*v) *t + (tobs**2 * c**2 - x0**2 - y**2) = 0
        ! The time t is the unique physical solution of that equation:
        t = the_solution(a=c**2-v**2, b=-(2*tobs*c**2 + 2*x0*v), c=(tobs**2 * c**2 - x0**2 - y**2), tobs=tobs)
        ! The position of the car at t was:
        x = x0 + v * t
        ! The amplitude of the observed signal is decreasing in r**2:
        Amp = 1 / (x**2 + y**2)

        ! We simulate a stereo effect by using this arbitrary law:
        ! (note that x0<0 and at tobs=0 x<x0)
        panR = abs((max(x, x0) - x0) / (2*x0))
        panL = 1 - panR

        tape%left( 1, i) = panL * Amp * sin(omega*t)
        tape%right(1, i) = panR * Amp * sin(omega*t)
        ! A signal with only even harmonics, to sound like a motor:
        do j = 2, 40, +2
            tape%left( 1, i) = tape%left( 1, i) + panL * Amp/j**1.3_wp * sin(j*omega*t)
            tape%right(1, i) = tape%right(1, i) + panR * Amp/j**1.3_wp * sin(j*omega*t)
        end do

        if (mod(i, RATE/4) == 0) print '(3F8.2, ES10.2, 2F8.3)', tobs, t, x, Amp, panL, panR

        tobs = tobs + dt
    end do

    end associate

    call demo%mix_tracks()
    call demo%close_WAV_file()

contains

    ! We solve the Quadratic equation,
    ! but physically one and only one solution can exist:
    ! we know the sound was emitted before we hear it!
    real(wp) function the_solution(a, b, c, tobs)
        real(wp), intent(in) :: a, b, c, tobs
        real(wp) :: delta, t1, t2

        delta = b**2 - 4*a*c

        if (delta >= 0) then
            t1 = (-b + sqrt(delta)) / (2*a)
            t2 = (-b - sqrt(delta)) / (2*a)

            if (t1 <= tobs) then
                if (t2 <= tobs) then
                    error stop "ERROR: two solutions, physically impossible"
                else
                    the_solution = t1
                end if
            else if (t2 <= tobs) then
                the_solution = t2
            else
                error stop "ERROR: no solution (1)"
            end if
        else
            error stop "ERROR: no solution, delta<0 (2)"
        end if
    end function

end program doppler_effect
