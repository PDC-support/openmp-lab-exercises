! This program computes pi as
! \pi = 4 arctan(1)
!     = 4 \int _0 ^1 \frac{1} {1 + x^2} dx

program compute_pi

use omp_lib

implicit none

integer(kind=8), parameter :: NSTEPS = 134217728
integer, parameter :: MAXTHREADS = 4

integer(kind=8) :: i
integer :: nthreads
real(kind=8) :: dx, x, pi, ref_pi
real(kind=8) start_time, run_time

dx = 1.0D0 / NSTEPS

do nthreads = 1, MAXTHREADS

    pi = 0.0D0

    call OMP_SET_NUM_THREADS(nthreads)
    start_time = OMP_GET_WTIME()

    !$omp parallel

        !$omp single
            print '("nthreads = ", i0)', nthreads
        !$omp end single
           
        !$omp do private(x) reduction(+:pi)
            do i = 1, NSTEPS
                x = (i - 0.5D0) * dx
                pi = pi + 1.0D0 / (1.0D0 + x * x)
            enddo
        !$omp end do

    !$omp end parallel

    pi = pi * 4.0D0 * dx
    run_time = OMP_GET_WTIME() - start_time
    ref_pi = 4.0D0 * atan(1.0D0)
    print '("pi with ", i0, " steps is ", f16.10, " in ", f12.6, " seconds (error=", e12.6, ")")', NSTEPS, pi, run_time, abs(ref_pi - pi)

enddo

end program
