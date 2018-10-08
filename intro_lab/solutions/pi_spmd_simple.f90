! This program computes pi as
! \pi = 4 arctan(1)
!     = 4 \int _0 ^1 \frac{1} {1 + x^2} dx

program compute_pi

use omp_lib

implicit none

integer(kind=8), parameter :: NSTEPS = 134217728
integer, parameter :: MAXTHREADS = 4

integer(kind=8) :: i
integer nthreads, omp_id

real(kind=8) :: dx, x, full_pi, ref_pi
real(kind=8) start_time, run_time
real(kind=8), dimension(1:MAXTHREADS) :: partial_pi

dx = 1.0D0 / NSTEPS

do nthreads = 1, MAXTHREADS

    call OMP_SET_NUM_THREADS(nthreads)
    start_time = OMP_GET_WTIME()

    !$omp parallel private(omp_id, i, x)

        omp_id = OMP_GET_THREAD_NUM() + 1
        partial_pi(omp_id) = 0.0D0

        if (omp_id == 1) then
            print '("nthreads = ", i0)', nthreads
        endif
           
        do i = omp_id, NSTEPS, nthreads
            x = (i - 0.5D0) * dx
            partial_pi(omp_id) = partial_pi(omp_id) + 1.0D0 / (1.0D0 + x * x)
        enddo

    !$omp end parallel

    full_pi = 0.0
    do omp_id = 1, nthreads
        full_pi = full_pi + partial_pi(omp_id)
    enddo

    full_pi = full_pi * 4.0D0 * dx
    run_time = OMP_GET_WTIME() - start_time
    ref_pi = 4.0D0 * atan(1.0D0)
    print '("pi with ", i0, " steps is ", f16.10, " in ", f12.6, " seconds (error=", e12.6, ")")', NSTEPS, full_pi, run_time, abs(ref_pi - full_pi)

enddo

end program
