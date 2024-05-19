! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2023-05-16

! Subroutines generating envelopes
! https://en.wikipedia.org/wiki/Envelope_(music)
module envelopes
    use forsynth, only: wp, RATE, PI

    implicit none

    ! Default parameters of the ADSR envelope:
    ! A   D S   R
    !    /\
    !   /  \____
    !  /        \
    ! /          \
    real(wp) :: attack  = 30.0_wp      ! duration %
    real(wp) :: decay   = 20.0_wp      ! duration %
    real(wp) :: sustain = 80.0_wp      ! max level %
    real(wp) :: release = 30.0_wp      ! duration %

    private

    public :: ADSR_enveloppe, attack, decay, sustain, release

contains

    ! Returns the level in [0, 1] of an ADSR envelope at time t1 < t < t2
    real(wp) function ADSR_enveloppe(t, t1, t2)
        real(wp), intent(in) :: t, t1, t2
        integer :: i, i1, i2, i3, i4, i5

        i = nint(t * RATE)

        ! First part (Attack):
        i1 = nint(t1 * RATE)
        i2 = nint((t1 + (t2-t1) * attack / 100.0_wp) * RATE)

        if ((i >= i1) .and. (i < i2)) then
            ADSR_enveloppe = (i-i1) / real(i2-i1, wp)
        else
            i3 = nint((t1 + (t2-t1) * (attack+decay) / 100.0_wp) * RATE)
            if ((i >= i2) .and. (i < i3)) then
                ADSR_enveloppe = (100.0_wp - (i-i2)/real(i3-i2, wp) * &
                               & (100.0_wp-sustain)) / 100.0_wp
            else
                i4 = nint((t2 - (t2-t1) * release / 100.0_wp) * RATE)
                if ((i >= i3) .and. (i < i4)) then
                    ADSR_enveloppe = (sustain / 100.0_wp)
                else
                    i5 = nint(t2 * RATE)
                    if ((i >= i4) .and. (i <= i5)) then
                        ADSR_enveloppe = (sustain - (i-i4)/real(i5-i4, wp) * &
                                       & sustain) / 100.0_wp
                    else
                        print *, "ERROR ADSR_envelope: t outside [t1, t2] !"
                        ADSR_enveloppe = 1.0_wp
                    end if
                end if
            end if
        end if
    end function

end module envelopes
