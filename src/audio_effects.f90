! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2025-03-19

!> Various audio effects
module audio_effects
    use forsynth, only: wp, RATE, PI, dt
    use tape_recorder_class
    use acoustics, only: dB_to_linear, linear_to_db

    implicit none

    private

    public :: apply_delay_effect, apply_fuzz_effect, apply_tremolo_effect, &
            & apply_autopan_effect, apply_reverse_effect, apply_dynamic_effect

contains

    !> Add the sound from "delay" seconds before,
    !> and multiply by Amp<1 for dampening.
    subroutine apply_delay_effect(tape, track, t1, t2, delay, Amp)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, delay, Amp
        integer              :: i, j
        integer              :: id

        ! Delay as an integer:
        id = nint(delay / dt)

        ! Can not be parallelized:
        do i = nint(t1*RATE), min(nint(t2*RATE), tape%last)
            j = i - id
            if (j > 0) then
                tape%left(track,  i) = tape%left(track,  i) + Amp * tape%left(track,  j)
                tape%right(track, i) = tape%right(track, i) + Amp * tape%right(track, j)
            end if
        end do
    end subroutine

    !> Apply distorsion with hard clipping
    !> https://en.wikipedia.org/wiki/Distortion_(music)
    subroutine apply_fuzz_effect(tape, track, t1, t2, level)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, level
        integer              :: i

        do concurrent(i = nint(t1*RATE) : min(nint(t2*RATE), tape%last))
            if (abs(tape%left(track,  i)) > level) then
                tape%left(track,  i) = sign(level, tape%left(track,  i))
            end if
            if (abs(tape%right(track, i)) > level) then
                tape%right(track, i) = sign(level, tape%right(track, i))
            end if
        end do
    end subroutine

    !> A sinusoidal modulation of the amplitude of a signal (tremolo) :
    !> f : tremolo frequency (typically a few Hz)
    !> AmpLFO : tremolo amplitude in [0 ; 1]
    !> https://en.wikipedia.org/wiki/Vibrato#Vibrato_and_tremolo/
    subroutine apply_tremolo_effect(tape, track, t1, t2, f, AmpLFO)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, AmpLFO
        integer  :: i
        real(wp) :: omegaLFO
        real(wp) :: t

        omegaLFO = 2 * PI * f

        do concurrent(i = nint(t1*RATE) : min(nint(t2*RATE), tape%last))
            t = (i - nint(t1*RATE)) * dt
            tape%left(track,  i) = tape%left(track,  i) * (1.0_wp - AmpLFO*sin(omegaLFO*t))
            tape%right(track, i) = tape%right(track, i) * (1.0_wp - AmpLFO*sin(omegaLFO*t))
        end do
    end subroutine

    !> Make the sound move from one channel to the other one at a frequency f
    !> and with an amplitude AmpLFO in [0 ; 1].
    subroutine apply_autopan_effect(tape, track, t1, t2, f, AmpLFO)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, f, AmpLFO
        real(wp), parameter  :: phi = 0.0_wp
        integer  :: i
        real(wp) :: omegaLFO
        real(wp) :: t

        omegaLFO = 2 * PI * f

        do concurrent(i = nint(t1*RATE) : min(nint(t2*RATE), tape%last))
            t = (i - nint(t1*RATE)) * dt
            tape%left(track,  i) = tape%left(track,  i) * (1.0_wp - AmpLFO * sin(omegaLFO*t + phi))
            tape%right(track, i) = tape%right(track, i) * (1.0_wp - AmpLFO * cos(omegaLFO*t + phi))
        end do
    end subroutine

    !> Copy the samples at the same t1 but in reverse order:
    subroutine apply_reverse_effect(tape, track, t1, t2)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2
        integer              :: i, i1, i2

        i1 = nint(t1*RATE)
        i2 = min(nint(t2*RATE), tape%last)

        ! Track 0 is used as an auxiliary track:
        do concurrent(i = i1:i2)
            tape%left(0,  i) = tape%left(track,  i1-i+i2)
            tape%right(0, i) = tape%right(track, i1-i+i2)
        end do
        ! Transfer on the good track:
        tape%left(track,  i1:i2) = tape%left(0,  i1:i2)
        tape%right(track, i1:i2) = tape%right(0, i1:i2)
    end subroutine

    !> A basic dynamic effect with hard knee, and only two parameters :
    !> the threshold > 0 expressed linearly (not in dB) and the ratio.
    !> It is a compressor if the ratio is > 1.
    !> It can also be used as a limiter with a ratio >= 10.
    !> Or an upward expander with a ratio < 1.
    !> By default, the ratio is applied above the threshold, but the "below"
    !> optional parameter can be used to reverse it and obtain:
    !> - an upward compressor with ratio < 1
    !> - a (downward) expander with ratio > 1.
    !> There are no attack and release parameters at this time.
    !> https://en.wikipedia.org/wiki/Dynamic_range_compression
    subroutine apply_dynamic_effect(tape, track, t1, t2, threshold, ratio, below)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2, threshold, ratio
        logical, intent(in), optional :: below
        real(wp)             :: signal, thr_db
        integer              :: i

        thr_db = linear_to_db(threshold)

        do concurrent(i = nint(t1*RATE) : min(nint(t2*RATE), tape%last))
            associate(left => tape%left(track,  i), right => tape%right(track,  i))

            if (present(below)) then
                if (below) then  ! upward compression (ratio < 1) or (downward) expansion (ratio > 1)
                    signal = linear_to_db(left)
                    if (signal < thr_db) then
                        left = sign(dB_to_linear(thr_db - (thr_db - signal) * ratio), left)
                    end if

                    signal = linear_to_db(right)
                    if (signal < thr_db) then
                        right = sign(dB_to_linear(thr_db - (thr_db - signal) * ratio), right)
                    end if

                    cycle
                end if
            end if

            ! Else it is downward compression (ratio>1) or upward expansion (ratio<1)
            signal = linear_to_db(left)
            if (signal > thr_db) then
                left = sign(dB_to_linear(thr_db + (signal - thr_db) / ratio), left)
            end if

            signal = linear_to_db(right)
            if (signal > thr_db) then
                right = sign(dB_to_linear(thr_db + (signal - thr_db) / ratio), right)
            end if

            end associate
        end do
    end subroutine apply_dynamic_effect

end module audio_effects
