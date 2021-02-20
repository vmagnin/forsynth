module signals
    ! Subroutines generating different kind of signals

    use forsynth, only: dp, RATE, PI, left, right
    use envelopes, only: ADSR_enveloppe

    implicit none

    private

    public :: add_sinusoidal_signal

contains

    subroutine add_sinusoidal_signal(track, t1, t2, f, Amp)
        integer, intent(in) :: track
        real(kind=dp), intent(in) :: t1, t2, f, Amp
        ! Pulsation (radians/second):
        real(kind=dp) :: omega
        ! Time in seconds:
        real(kind=dp) :: t
        ! Duration of a sample, in seconds:
        real(kind=dp), parameter :: dt = 1.0_dp / RATE
        ! Phase at t=0 s, radians:
        real(kind=dp), parameter :: phi = 0.0_dp
        ! ADSR Envelope value:
        real(kind=dp) :: env
        real(kind=dp) :: signal
        integer :: i

        omega = 2.0_dp * PI * f

        t = 0.0_dp
        do i = int(t1*RATE), int(t2*RATE)-1
            env = ADSR_enveloppe(t1+t, t1, t2)
            signal = Amp * sin(omega*t + phi) * env

            left(track, i)  = left(track, i)  + signal
            right(track, i) = right(track, i) + signal

            t = t + dt
        end do
    end subroutine add_sinusoidal_signal

    !void add_square_wave(int track, double t1, double t2, double f, double Amp) {
    !void add_sawtooth_wave(int track, double t1, double t2, double f, double Amp) {
    !void add_reverse_sawtooth_wave(int track, double t1, double t2, double f, double Amp)
    !void add_triangle_wave(int track, double t1, double t2, double f, double Amp) {
    !void add_noise(int track, double t1, double t2, double Amp) {
    !void add_weird_signal(int track, double t1, double t2, double f, double Amp, unsigned int modulation) {
    !void add_karplus_strong(int track, double t1, double t2, double f, double Amp) {
    !void add_karplus_strong_drum(int track, double t1, double t2, double f, double Amp) {
    !void add_percussion(int track, double t1, double t2, double f, double Amp, unsigned int numero) {
    !void add_weierstrass_signal(int track, double t1, double t2, double f, double Amp) {
end module signals
