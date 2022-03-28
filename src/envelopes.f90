module envelopes
    ! Subroutines generating envelopes
    ! https://en.wikipedia.org/wiki/Envelope_(music)

    use forsynth, only: dp, RATE, PI, left, right

    implicit none

    ! Parameters of the ADSR envelope:
    ! A   D S   R
    !    /\
    !   /  \____
    !  /        \
    ! /          \
    real(dp) :: attack  = 30.0_dp      ! duration %
    real(dp) :: decay   = 20.0_dp      ! duration %
    real(dp) :: sustain = 80.0_dp      ! max level %
    real(dp) :: release = 30.0_dp      ! duration %

    private

    public :: ADSR_enveloppe, attack, decay, sustain, release

contains

    real(dp) function ADSR_enveloppe(t, t1, t2)
        ! Returns the level in [0, 1] of an ADSR envelope at time t1 < t < t2

        real(dp), intent(in) :: t, t1, t2
        integer :: i, i1, i2, i3, i4, i5

        i = nint(t * RATE)

        ! First part (Attack):
        i1 = nint(t1 * RATE)
        i2 = nint((t1 + (t2-t1) * attack / 100.0_dp) * RATE)

        if ((i >= i1) .and. (i < i2)) then
            ADSR_enveloppe = (i-i1) / real(i2-i1, dp)
        else
            i3 = nint((t1 + (t2-t1) * (attack+decay) / 100.0_dp) * RATE)
            if ((i >= i2) .and. (i < i3)) then
                ADSR_enveloppe = (100.0_dp - (i-i2)/real(i3-i2, dp) * &
                               & (100.0_dp-sustain)) / 100.0_dp
            else
                i4 = nint((t2 - (t2-t1) * release / 100.0_dp) * RATE)
                if ((i >= i3) .and. (i < i4)) then
                    ADSR_enveloppe = (sustain / 100.0_dp)
                else
                    i5 = nint(t2 * RATE)
                    if ((i >= i4) .and. (i <= i5)) then
                        ADSR_enveloppe = (sustain - (i-i4)/real(i5-i4, dp) * &
                                       & sustain) / 100.0_dp
                    else
                        print *, "ERROR ADSR_envelope: t outside [t1, t2] !"
                        ADSR_enveloppe = 1.0_dp
                    end if
                end if
            end if
        end if
    end function

end module envelopes
