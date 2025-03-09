! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2024-04-29
! Last modifications: 2025-03-04

!> Miscellaneous signals, especially obtained by frequency or phase modulation.
!> A WAV file is created for each sound.
program misc_sounds
    use forsynth, only: wp, dt, RATE, PI
    use wav_file_class, only: WAV_file
    use tape_recorder_class
    use music, only: fr

    implicit none
    type(WAV_file) :: demo
    integer      :: i
    character(2) :: number

    print *, "**** Creating misc_sounds WAV files ****"
    do i = 0, 23
        print *, i
        write(number, '(I0)') i
        ! We create a new WAV file, and define the number of tracks and its duration:
        call demo%create_WAV_file('misc_sounds'//trim(number)//'.wav', tracks=1, duration=30._wp)
        ! We call the subroutine for signal i:
        call add_misc_signal(demo%tape_recorder, track=1, t1=0._wp, t2=30._wp, f=fr("A4"), Amp=1._wp, choice=i)
        ! All tracks will be mixed on track 0.
        ! Needed even if there is only one track!
        call demo%mix_tracks()
        call demo%close_WAV_file()
    end do

    print *,"You can now play the file ", demo%get_name()

contains

    !> Add on the track a signal choosen by its number:
    subroutine add_misc_signal(tape, track, t1, t2, f, Amp, choice)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track, choice
        real(wp), intent(in) :: t1, t2, f, Amp

        ! Pulsation (radians/second):
        real(wp) :: omega
        ! Time in seconds:
        real(wp) :: t
        real(wp) :: signal
        integer  :: i, j

        omega = 2 * PI * f
        t = 0._wp
        do i = nint(t1*RATE), nint(t2*RATE)-1
            select case (choice)
                case (0) ! Pure sinus
                    signal = + Amp * sin(omega*t)
                case (1) ! Science fiction signal...
                    signal = + Amp * sin(omega*t + cos(75*t)/(1+log(t/100+0.01_wp)))
                case (2) ! Hummmmmmmmmm...
                    signal = + Amp * sin(omega*t + sin(omega*0.2_wp*t))
                case (3) ! UFO or siren?
                    signal = + Amp * sin(omega*t + cos(25*t))
                case (4) ! Noisy science fiction
                    signal = + Amp * sin(omega*(1._wp + 0.2_wp*sin(t*50)) * t)
                case (5) ! Whistling, slower and slower...
                    signal = + Amp * sin(omega*(1._wp + 0.2_wp*sin(sqrt(t)*50)) * t)
                case (6) ! Similar
                    signal = + Amp * sin(omega*(1._wp + 0.2_wp*sin(log(t)*50)) * t)
                case (7) ! Dudududududu...
                    signal = + Amp * sin(t*30) * sin(omega * t)
                case (8) ! Duuuuuuuuuuuuuuuuuuu
                    signal = + Amp * sin(omega*t + 0.5_wp+0.5_wp*sin(t*500))
                case (9) ! A higher duuuuuuuuuuuuuuuuuuu
                    signal = + Amp/2 * sin(omega*t) + Amp/2 * sin(omega*1.1892_wp*t)
                case (10) ! Higher and higher...
                    signal = + Amp * sin((omega*(1+t/10)) * t)
                case (11) ! Dampening slowly
                    do j=1, 7
                        signal = + Amp/(j*(1+t**j))*sin(j*omega*t)
                    end do
                case (12) ! Vibrato
                    signal = + Amp * sin(omega*t + 1._wp + 0.5_wp*sin(2*PI*4*t))
                case (13) ! A mix
                    signal = + Amp * sin(t) * sin(omega*t) &
                           & + Amp * cos(2.5_wp*t) * sin(1.5_wp*omega*t) + Amp * sin(3*t) * sin(2*omega*t)
                case (14) ! Tremolo
                    signal = + Amp * sin(omega*t) + Amp * sin(1.001_wp*omega*t) &
                           & + Amp * sin(0.999_wp*omega*t)
                case (15) ! Poke... (a short percussion based on the Sinc function)
                    if (omega*t /= 0._wp) then
                        signal = + Amp * sin(omega*t) / (omega*t)
                    else
                        signal = + Amp
                    end if
                case (16) ! Science fiction, becoming higher and noisy
                    signal = + Amp * sin(omega*(1._wp + 0.001_wp*sin(t*500)) * t)
                case (17) ! Dissonant
                    signal = + Amp*sin(omega*t + 4*sin(omega/10 * t))
                case (18) ! Dampening
                    signal = + Amp*(1/(1+t**3))*sin(omega*t + 2*sin(omega*t+3*sin(omega*t)))
                case (19) ! Science-fiction, becoming higher and noisy
                    signal = + Amp &
                           & * sin(omega*(1._wp + 0.001_wp*sin(t*500*(1._wp + 0.0002_wp*cos(t*50)))) * t)
                case (20) ! Another dampening sound
                    signal = + Amp*(exp(-t)*sin(omega*t) + 0.5_wp*exp(-t**2)*sin(2*omega*t) &
                           & + 0.25_wp*exp(-t**3)*sin(3*omega*t) + 0.12_wp*exp(-t**4)*sin(4*omega*t))
                case (21) ! Dampening slowly
                    do j=1, 14
                        signal = + Amp/(j**2 * (1+t**j))*sin(j*omega*t)
                    end do
                case (22) ! Clarinet
                    do j=1, 11, +2
                        signal = + Amp/j**0.7_wp * sin(j*omega*t)
                    end do
                case (23) ! Bessel function of the first kind J1: pong...
                    signal = + Amp * bessel_jn(1, omega*t)
                case (24) ! Bessel functions of the first kind: ping (far shorter)
                    signal = + Amp * bessel_jn(1, omega*t) * bessel_jn(2, omega*t)
            end select
            tape%left (track, i) = signal
            tape%right(track, i) = signal
            t = t + dt
        end do
    end subroutine add_misc_signal

end program misc_sounds
