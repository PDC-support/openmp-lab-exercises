! NAME: PI SPMD ... a simple version.
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

integer(kind=8) :: num_steps = 100000000
real(kind=8) step

integer i, num_threads
real(kind=8) pi, full_sum
real(kind=8) start_time, run_time
real(kind=8), dimension(1:MAX_THREADS) :: partial_sum

integer thread_id
real(kind=8) x

step = 1.0D0 / num_steps

do num_threads = 1, MAX_THREADS

    call OMP_SET_NUM_THREADS(num_threads)
    start_time = OMP_GET_WTIME()

    !$omp parallel private(thread_id, i, x)

        thread_id = OMP_GET_THREAD_NUM() + 1
        partial_sum(thread_id) = 0.0D0

        if (thread_id == 1) then
            print '(" num_threads = ", i0)', num_threads
        endif

        do i = thread_id, num_steps, num_threads
            x = (i-0.5D0)*step
            partial_sum(thread_id) = partial_sum(thread_id) + 4.0D0/(1.0D0+x*x)
        enddo

    !$omp end parallel

    full_sum = 0.0
    do thread_id = 1, num_threads
        full_sum = full_sum + partial_sum(thread_id)
    enddo

    pi = step * full_sum
    run_time = OMP_GET_WTIME() - start_time
    print '(" pi is ", f12.6, " in ", f12.6, " seconds and ", i0, " threads. Error = ", e15.6)', &
        pi, run_time, num_threads, abs(3.14159265358979323846D0 - pi)

enddo

end program
