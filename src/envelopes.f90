! Forsynth: a multitracks stereo sound synthesis project
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2023-05-31

! Functions and subroutines generating envelopes
module envelopes
    use forsynth, only: wp, RATE
    use tape_recorder_class

    implicit none

    type ADSR_envelope
        ! A   D S   R
        !    /\
        !   /  \____
        !  /        \
        ! /          \
        ! https://en.wikipedia.org/wiki/Envelope_(music)
        ! Default parameters of the ADSR envelope:
        real(wp) :: attack  = 30.0_wp      ! duration %
        real(wp) :: decay   = 20.0_wp      ! duration %
        real(wp) :: sustain = 80.0_wp      ! max level %
        real(wp) :: release = 30.0_wp      ! duration %
    contains
        procedure :: new => ADSR_new
        procedure :: get_level => ADSR_level
    end type ADSR_envelope

    private

    public :: ADSR_envelope, apply_fade_in, apply_fade_out

contains

    subroutine ADSR_new(self, A, D, S, R)
        class(ADSR_envelope), intent(inout)  :: self
        real(wp), intent(in) :: A, D, S, R

        self%attack  = A
        self%decay   = D
        self%sustain = S
        self%release = R
    end subroutine ADSR_new

    ! Returns the level in [0, 1] of the ADSR envelope at time t1 < t < t2
    pure real(wp) function ADSR_level(self, t, t1, t2)
        class(ADSR_envelope), intent(in)  :: self
        real(wp), intent(in) :: t, t1, t2
        integer :: i, i1, i2, i3, i4, i5

        i = nint(t * RATE)

        ! First part (Attack):
        i1 = nint(t1 * RATE)
        i2 = nint((t1 + (t2-t1) * self%attack / 100.0_wp) * RATE)

        if ((i >= i1) .and. (i < i2)) then
            ADSR_level = (i-i1) / real(i2-i1, wp)
        else
            i3 = nint((t1 + (t2-t1) * (self%attack+self%decay) / 100.0_wp) * RATE)
            if ((i >= i2) .and. (i < i3)) then
                ADSR_level = (100.0_wp - (i-i2)/real(i3-i2, wp) * &
                               & (100.0_wp-self%sustain)) / 100.0_wp
            else
                i4 = nint((t2 - (t2-t1) * self%release / 100.0_wp) * RATE)
                if ((i >= i3) .and. (i < i4)) then
                    ADSR_level = (self%sustain / 100.0_wp)
                else
                    i5 = nint(t2 * RATE)
                    if ((i >= i4) .and. (i <= i5)) then
                        ADSR_level = (self%sustain - (i-i4)/real(i5-i4, wp) * &
                                       & self%sustain) / 100.0_wp
                    else
                        ! ERROR ADSR_level: t outside [t1, t2]
                        ADSR_level = 1.0_wp
                    end if
                end if
            end if
        end if
    end function ADSR_level

    ! A linear fade in, from relative level 0 to 1:
    subroutine apply_fade_in(tape, track, t1, t2)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2
        integer :: i, i1, i2

        i1 = nint(t1 * RATE)
        i2 = nint(t2 * RATE) - 1

        do concurrent(i = i1:i2)
            tape%left( track, i) = tape%left( track, i) * (i-i1) / (i2-i1)
            tape%right(track, i) = tape%right(track, i) * (i-i1) / (i2-i1)
        end do
    end subroutine apply_fade_in

    ! A linear fade out, from relative level 1 to 0:
    subroutine apply_fade_out(tape, track, t1, t2)
        type(tape_recorder), intent(inout) :: tape
        integer, intent(in)  :: track
        real(wp), intent(in) :: t1, t2
        integer :: i, i1, i2

        i1 = nint(t1 * RATE)
        i2 = nint(t2 * RATE) - 1

        do concurrent(i = i1:i2)
            tape%left( track, i) = tape%left( track, i) * ((i-i2) / real(i1-i2, kind=wp))
            tape%right(track, i) = tape%right(track, i) * ((i-i2) / real(i1-i2, kind=wp))
        end do
    end subroutine apply_fade_out

end module envelopes
