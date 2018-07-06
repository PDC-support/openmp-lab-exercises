! This program will numerically compute the integral of
!
!                   4/(1+x*x) 
!   
! from 0 to 1.  The value of this integral is pi -- which 
! is great since it gives us an easy way to check the answer.
!
! The is the original sequential program.  It uses the timer
! from the OpenMP runtime library
!
! History: Written by Tim Mattson, 11/99.

program calc_pi

use omp_lib

implicit none

integer(kind=8) :: num_steps = 100000000
real(kind=8) step

integer i
real(kind=8) x, pi, raw_sum
real(kind=8) start_time, run_time

step = 1.0D0 / num_steps

start_time = OMP_GET_WTIME()

raw_sum = 0.0D0
       
do i = 1, num_steps
    x = (i-0.5D0)*step
    raw_sum = raw_sum + 4.0D0/(1.0D0+x*x)
enddo

pi = step * raw_sum
run_time = OMP_GET_WTIME() - start_time
print '(" pi with ", i0, " steps is ", f12.6, " in ", f12.6, " seconds")', num_steps, pi, run_time

end program
