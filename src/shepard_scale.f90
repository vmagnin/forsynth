! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin, 2024-05-20
! Last modifications: 2025-03-02

!> A Shepard scale, giving the illusion of an ever increasing pitch in the first
!> half of the tape and an ever decreasing pitch in the 2nd half.
!> Shepard, Roger N. "Circularity in Judgments of Relative Pitch",
!> The Journal of the Acoustical Society of America 36, no. 12,
!> (December 1, 1964): 2346–53. https://doi.org/10.1121/1.1919362.
!> https://en.wikipedia.org/wiki/Shepard_tone
program shepard_scale
    use forsynth, only: wp, dt, RATE, PI
    use wav_file_class, only: WAV_file
    use audio_effects, only: apply_reverse_effect
    use acoustics, only: dB_to_linear

    implicit none
    type(WAV_file) :: demo
    ! Time in seconds:
    real(wp) :: ti, ti0
    ! Pulsation (radians/second):
    real(wp) :: omega
    real(wp) :: Amp
    integer  :: i, k
    !--------------------------
    ! Shepard scale parameters:
    !--------------------------
    ! t th tone:
    integer :: t
    integer, parameter :: tmax = 12
    ! Components of each tone:
    integer :: c
    ! The number of components was 10 in the paper, but the bandwidth was
    ! 5 kHz instead of 20 kHz. We have therefore added two octaves:
    integer, parameter  :: cmax = 12
    ! Sound pressure levels in dB for the components:
    real(wp) :: L
    real(wp), parameter :: Lmin = 22._wp
    real(wp), parameter :: Lmax = 56._wp
    ! Frequency of the lowest component of the first tone:
    real(wp), parameter :: fmin = 4.863_wp      ! D#
    ! Duration of a tone and of the following silence:
    real(wp), parameter :: d = 0.125_wp
    real(wp), parameter :: ds = 0.840_wp
    real(wp) :: teta, f
    ! Number of repetitions:
    integer, parameter ::  kmax = 9

    ! We create a new WAV file, and define the number of tracks and its duration:
    call demo%create_WAV_file('shepard_scale.wav', tracks=1, duration=120._wp)
    print *, "**** Creating " // demo%get_name() // " ****"

    associate(tape => demo%tape_recorder)

    ! Repeat the Shepard scale:
    do k = 0, kmax
        ! Tones loop:
        do t = 1, tmax
            ! Components loop:
            do c = 1, cmax
                ! Equations from the Shepard paper:
                f = fmin * 2._wp**(((c-1)*tmax + t -1) / real(tmax, kind=wp))
                omega = 2*PI*f
                teta = (2*PI * (c-1)*tmax + t -1) / (tmax*cmax)
                ! Sound pressure level in dB:
                L = Lmin + (Lmax-Lmin) * (1._wp - cos(teta)) / 2._wp
                Amp = dB_to_linear(L)

                ! Writing a sinusoidal signal at ti0, for a duration d.
                ! We do not write silences (the tape is initially silent).
                ti0 = k*tmax*(d + ds) + t*(d + ds)
                ti = ti0
                do i = nint(ti0*RATE), nint((ti0+d)*RATE)-1
                    tape%left(1, i)  = tape%left(1, i) + Amp * sin(omega*ti)
                    ti = ti + dt
                end do
            end do
        end do
    end do
    tape%right = tape%left
    ! The 2nd half of the track is reversed to obtain an ever decreasing pitch:
    call apply_reverse_effect(tape, track=1, t1=(1+kmax)/2*tmax*(d+ds), t2=(1+kmax)*tmax*(d+ds) + d)
    end associate

    ! All tracks will be mixed on track 0.
    ! Needed even if there is only one track!
    call demo%mix_tracks()
    call demo%close_WAV_file()

    print *,"You can now play the file ", demo%get_name()
end program shepard_scale
