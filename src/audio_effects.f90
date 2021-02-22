module audio_effects
    ! Various audio effects

    use forsynth, only: dp, RATE, left, right, PI, dt

    implicit none

    private

    public :: apply_delay_effect, apply_fuzz_effect, apply_tremolo_effect, &
            & apply_autopan_effect

contains

    subroutine apply_delay_effect(track, t1, t2, delay, Amp)
        ! Add the sound from "delay" seconds before,
        ! and multiply by Amp<1 for dampening.
        integer, intent(in) :: track
        real(kind=dp), intent(in) :: t1, t2, delay, Amp
        integer  :: i, j
        integer :: id 

        ! Delay as an integer:
        id = nint(delay / dt)

        do i = int(t1*RATE), int(t2*RATE) - 1
            j = i - id
            if (j > 0) then
                left(track,  i) = left(track,  i) + Amp * left(track,  j)
                right(track, i) = right(track, i) + Amp * right(track, j)
            end if
        end do
    end subroutine


    subroutine apply_fuzz_effect(track, t1, t2, level)
        ! Apply distorsion with hard clipping
        ! https://en.wikipedia.org/wiki/Distortion_(music)
        integer, intent(in) :: track
        real(kind=dp), intent(in) :: t1, t2, level
        integer  :: i

        do i = int(t1*RATE), int(t2*RATE) - 1
            if (abs(left(track,  i)) > level) then
                left(track,  i) = sign(level, left(track,  i))
            end if
            if (abs(right(track, i)) > level) then
                right(track, i) = sign(level, right(track, i))
            end if
        end do
    end subroutine


    subroutine apply_tremolo_effect(track, t1, t2, f, AmpLFO)
        ! A sinusoidal modulation of the amplitude of a signal (tremolo) :
        ! f : tremolo frequency (typically a few Hz)
        ! AmpLFO : tremolo amplitude in [0 ; 1]
        ! https://en.wikipedia.org/wiki/Vibrato#Vibrato_and_tremolo/
        integer, intent(in) :: track
        real(kind=dp), intent(in) :: t1, t2, f, AmpLFO
        integer  :: i
        real(dp) :: omegaLFO
        real(dp) :: t

        omegaLFO = 2 * PI * f
        t = 0
        do i = int(t1*RATE), int(t2*RATE)-1
            left(track,  i) = left(track,  i) * (1.0_dp - AmpLFO*sin(omegaLFO*t))
            right(track, i) = right(track, i) * (1.0_dp - AmpLFO*sin(omegaLFO*t))
            t = t + dt
        end do
    end subroutine


    subroutine apply_autopan_effect(track, t1, t2, f, AmpLFO)
        ! Make the sound move from one channel to the other one at a frequency f
        ! and with an amplitude AmpLFO in [0 ; 1].
        integer, intent(in) :: track
        real(kind=dp), intent(in) :: t1, t2, f, AmpLFO
        integer  :: i
        real(dp) :: omegaLFO
        real(dp), parameter :: phi = 0.0_dp
        real(dp) :: t

        omegaLFO = 2 * PI * f
        t = 0
        do i = int(t1*RATE), int(t2*RATE)-1
            left(track,  i) = left(track,  i) * (1.0-AmpLFO*sin(omegaLFO*t+phi))
            right(track, i) = right(track, i) * (1.0-AmpLFO*cos(omegaLFO*t+phi))
            t = t + dt
        end do
    end subroutine

end module audio_effects
