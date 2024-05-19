! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2023-05-17

module audio_effects
    ! Various audio effects

    use forsynth, only: wp, RATE, PI, dt
    use tape_recorder_class

    implicit none

    private

    public :: apply_delay_effect, apply_fuzz_effect, apply_tremolo_effect, &
            & apply_autopan_effect

contains

    subroutine apply_delay_effect(tape, track, t1, t2, delay, Amp)
        ! Add the sound from "delay" seconds before,
        ! and multiply by Amp<1 for dampening.
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, delay, Amp
        integer              :: i, j
        integer              :: id

        ! Delay as an integer:
        id = nint(delay / dt)

        do i = nint(t1*RATE), nint(t2*RATE) - 1
            j = i - id
            if (j > 0) then
                tape%left(track,  i) = tape%left(track,  i) + Amp * tape%left(track,  j)
                tape%right(track, i) = tape%right(track, i) + Amp * tape%right(track, j)
            end if
        end do
    end subroutine


    subroutine apply_fuzz_effect(tape, track, t1, t2, level)
        ! Apply distorsion with hard clipping
        ! https://en.wikipedia.org/wiki/Distortion_(music)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, level
        integer              :: i

        do i = nint(t1*RATE), nint(t2*RATE) - 1
            if (abs(tape%left(track,  i)) > level) then
                tape%left(track,  i) = sign(level, tape%left(track,  i))
            end if
            if (abs(tape%right(track, i)) > level) then
                tape%right(track, i) = sign(level, tape%right(track, i))
            end if
        end do
    end subroutine


    subroutine apply_tremolo_effect(tape, track, t1, t2, f, AmpLFO)
        ! A sinusoidal modulation of the amplitude of a signal (tremolo) :
        ! f : tremolo frequency (typically a few Hz)
        ! AmpLFO : tremolo amplitude in [0 ; 1]
        ! https://en.wikipedia.org/wiki/Vibrato#Vibrato_and_tremolo/
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, AmpLFO
        integer  :: i
        real(wp) :: omegaLFO
        real(wp) :: t

        omegaLFO = 2 * PI * f
        t = 0
        do i = nint(t1*RATE), nint(t2*RATE)-1
            tape%left(track,  i) = tape%left(track,  i) * (1.0_wp - AmpLFO*sin(omegaLFO*t))
            tape%right(track, i) = tape%right(track, i) * (1.0_wp - AmpLFO*sin(omegaLFO*t))
            t = t + dt
        end do
    end subroutine


    subroutine apply_autopan_effect(tape, track, t1, t2, f, AmpLFO)
        ! Make the sound move from one channel to the other one at a frequency f
        ! and with an amplitude AmpLFO in [0 ; 1].
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, AmpLFO
        real(wp), parameter  :: phi = 0.0_wp
        integer  :: i
        real(wp) :: omegaLFO
        real(wp) :: t

        omegaLFO = 2 * PI * f
        t = 0
        do i = nint(t1*RATE), nint(t2*RATE)-1
            tape%left(track,  i) = tape%left(track,  i) * (1.0_wp - AmpLFO * sin(omegaLFO*t + phi))
            tape%right(track, i) = tape%right(track, i) * (1.0_wp - AmpLFO * cos(omegaLFO*t + phi))
            t = t + dt
        end do
    end subroutine

end module audio_effects
