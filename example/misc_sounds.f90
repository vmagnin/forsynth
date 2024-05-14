! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2024-04-29
! Last modifications: 2024-05-14

! Miscellaneous signals, especially obtained by frequency or phase modulation
program misc_sounds
    use forsynth, only: dp, mix_tracks, &
                      & clear_tracks, RATE, PI, left, right
    use wav_file_class, only: WAV_file
    use music, only: fr

    implicit none
    type(WAV_file) :: demo
    integer      :: i
    character(2) :: number

    print *, "**** Creating misc_sounds WAV files ****"
    do i = 0, 23
        print *, i
        write(number, '(I0)') i
        call demo%create_WAV_file('misc_sounds'//trim(number)//'.wav')
        call clear_tracks()
        call add_misc_signal(1, 0._dp, 100._dp, fr("A4"), 1._dp, i)
        call mix_tracks()
        call demo%finalize_WAV_file()
    end do

contains

    ! Add on the track a signal choosen by its number:
    subroutine add_misc_signal(track, t1, t2, f, Amp, choice)
        integer, intent(in)  :: track, choice
        real(dp), intent(in) :: t1, t2, f, Amp

        ! Pulsation (radians/second):
        real(dp) :: omega
        ! Time in seconds:
        real(dp) :: t
        real(dp), parameter :: dt = 1._dp / RATE
        real(dp), parameter :: phi = -3 * PI     ! Phase in radians at t=0
        integer  :: i, j

        omega = 2 * PI * f
        t = 0._dp
        do i = nint(t1*RATE), nint(t2*RATE)-1
            select case (choice)
                case (0) ! Pure sinus
                    left(track, i) = left(track, i) + Amp * sin(omega*t + phi)
                case (1) ! Science fiction signal...
                    left(track, i) = left(track, i) + Amp * sin(omega*t + phi*cos(75*t)/(1+log(t/100+0.01_dp)))
                case (2) ! Hummmmmmmmmm...
                    left(track, i) = left(track, i) + Amp * sin(omega*t + phi*sin(omega*0.2_dp*t))
                case (3) ! UFO or siren?
                    left(track, i) = left(track, i) + Amp * sin(omega*t + phi*cos(25*t))
                case (4) ! Noisy science fiction
                    left(track, i) = left(track, i) + Amp * sin(omega*(1._dp + 0.2_dp*sin(t*50)) * t + phi)
                case (5) ! Whistling, slower and slower...
                    left(track, i) = left(track, i) + Amp * sin(omega*(1._dp + 0.2_dp*sin(sqrt(t)*50)) * t + phi)
                case (6) ! Similar
                    left(track, i) = left(track, i) + Amp * sin(omega*(1._dp + 0.2_dp*sin(log(t)*50)) * t + phi)
                case (7) ! Dudududududu...
                    left(track, i) = left(track, i) + Amp * sin(t*30) * sin(omega * t + phi)
                case (8) ! Duuuuuuuuuuuuuuuuuuu
                    left(track, i) = left(track, i) + Amp * sin(omega*t + phi*(0.5_dp+0.5_dp*sin(t*500)))
                case (9) ! A higher duuuuuuuuuuuuuuuuuuu
                    left(track, i) = left(track, i) + Amp/2 * sin(omega*t + phi) + Amp/2 * sin(omega*1.1892_dp*t + phi)
                case (10) ! Higher and higher...
                    left(track, i) = left(track, i) + Amp * sin((omega*(1+t/10)) * t + phi)
                case (11) ! Dampening slowly
                    do j=1, 7
                        left(track, i) = left(track, i) + Amp/(j*(1+t**j))*sin(j*omega*t)
                    end do
                case (12) ! Vibrato
                    left(track, i) = left(track, i) + Amp * sin(omega*t + phi*(1._dp + 0.5_dp*sin(2*PI*4*t)))
                case (13) ! A mix
                    left(track, i) = left(track, i) + Amp * sin(t) * sin(omega*t + phi) &
                                   & + Amp * cos(2.5_dp*t) * sin(1.5_dp*omega*t + phi) + Amp * sin(3*t) * sin(2*omega*t + phi)
                case (14) ! Tremolo
                    left(track, i) = left(track, i) + Amp * sin(omega*t + phi) + Amp * sin(1.001_dp*omega*t + phi) &
                                   & + Amp * sin(0.999_dp*omega*t + phi)
                case (15) ! Poke... (a short percussion based on the Sinc function)
                    if (omega*t+phi /= 0._dp) then
                        left(track, i) = left(track, i) + Amp * sin(omega*t + phi) / (omega*t+phi)
                    else
                        left(track, i) = left(track, i) + Amp
                    end if
                case (16) ! Science fiction, becoming higher and noisy
                    left(track, i) = left(track, i) + Amp * sin(omega*(1._dp + 0.001_dp*sin(t*500)) * t + phi)
                case (17) ! Dissonant
                    left(track, i) = left(track, i) + Amp*sin(omega*t + 4*sin(omega/10 * t))
                case (18) ! Dampening
                    left(track, i) = left(track, i) + Amp*(1/(1+t**3))*sin(omega*t + 2*sin(omega*t+3*sin(omega*t)))
                case (19) ! Science-fiction, becoming higher and noisy
                    left(track, i) = left(track, i) + Amp * &
                                   & sin(omega*(1._dp + 0.001_dp*sin(t*500*(1._dp + 0.0002_dp*cos(t*50)))) * t + phi)
                case (20) ! Another dampening sound
                    left(track, i) = left(track, i) + Amp*(exp(-t)*sin(omega*t) + 0.5_dp*exp(-t**2)*sin(2*omega*t) &
                                   & + 0.25_dp*exp(-t**3)*sin(3*omega*t) + 0.12_dp*exp(-t**4)*sin(4*omega*t))
                case (21) ! Dampening slowly
                    do j=1, 14
                        left(track, i) = left(track, i) + Amp/(j**2 * (1+t**j))*sin(j*omega*t)
                    end do
                case (22) ! Clarinet
                    do j=1, 11, +2
                        left(track, i) = left(track, i) + Amp/j**0.7_dp * sin(j*omega*t)
                    end do
                case (23) ! Bessel function of the first kind J1: pong...
                    left(track, i) = left(track, i) + Amp * bessel_jn(1, omega*t)
                case (24) ! Bessel functions of the first kind: ping (far shorter)
                    left(track, i) = left(track, i) + Amp * bessel_jn(1, omega*t) * bessel_jn(2, omega*t)
            end select
            right(track, i) = left(track, i)
            t = t + dt
        end do
    end subroutine add_misc_signal

end program misc_sounds
