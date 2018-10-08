! This program computes pi as
! \pi = 4 arctan(1)
!     = 4 \int _0 ^1 \frac{1} {1 + x^2} dx

program compute_pi

use omp_lib

implicit none

integer(kind=8) :: nsteps, i
real(kind=8) :: dx, x, pi, ref_pi
real(kind=8) start_time, run_time

nsteps = 100000000
dx = 1.0D0 / nsteps
pi = 0.0D0

start_time = OMP_GET_WTIME()
       
do i = 1, nsteps
    x = (i - 0.5D0) * dx
    pi = pi + 1.0D0 / (1.0D0 + x * x)
enddo

pi = pi * 4.0D0 * dx

run_time = OMP_GET_WTIME() - start_time
ref_pi = 4.0D0 * atan(1.0D0)
print '("pi with ", i0, " steps is ", f16.10, " in ", f12.6, " seconds (error=", e12.6, ")")', nsteps, pi, run_time, abs(ref_pi - pi)

end program
