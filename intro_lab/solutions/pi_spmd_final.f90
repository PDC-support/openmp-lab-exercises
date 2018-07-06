! NAME:   PI SPMD final version without false sharing
!
! This program will numerically compute the integral of
!
!                   4/(1+x*x) 
!   
! from 0 to 1.  The value of this integral is pi -- which 
! is great since it gives us an easy way to check the answer.
!
! The program was parallelized using OpenMP and an SPMD 
! algorithm.

program calc_pi

use omp_lib

implicit none

integer, parameter :: MAX_THREADS = 4

integer*8 :: num_steps = 100000000

real*8 step

integer i, num_threads
real*8 pi, full_sum, partial_sum
real*8 start_time, run_time

integer thread_id
real*8 x

step = 1.0D0 / num_steps

do num_threads = 1, MAX_THREADS

    call OMP_SET_NUM_THREADS(num_threads)
    start_time = OMP_GET_WTIME()
    full_sum = 0.0

    !$omp parallel private(thread_id, partial_sum, i, x)

        thread_id = OMP_GET_THREAD_NUM()
        partial_sum = 0.0

        !$omp single
            print '(" num_threads = ", i0)', num_threads
        !$omp end single

        do i = thread_id, num_steps, num_threads
            x = (i+0.5)*step
            partial_sum = partial_sum + 4.0/(1.0+x*x)
        enddo

        !$omp critical
            full_sum = full_sum + partial_sum
        !$omp end critical

    !$omp end parallel

    pi = step * full_sum
    run_time = OMP_GET_WTIME() - start_time
    print '(" pi is ", f12.6, " in ", f12.6, " seconds and ", i0, " threads")', pi, run_time, num_threads

enddo

end program
