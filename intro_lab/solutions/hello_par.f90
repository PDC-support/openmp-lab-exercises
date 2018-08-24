program hello_par

use omp_lib
 
implicit none

integer :: num_threads = 4
integer thread_id

call OMP_SET_NUM_THREADS(num_threads)

!$omp parallel private(thread_id)

    thread_id = OMP_GET_THREAD_NUM()

    print '("Hello World from thread = ", i0, " with ", i0, " threads")', thread_id, num_threads

!$omp end parallel

print '("All done, with hopefully ", i0, " threads")', num_threads

end program
