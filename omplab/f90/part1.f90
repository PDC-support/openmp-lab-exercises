

!!! This set of exercises aims at showing some basic OpenMP directives and how
!!! they affect the order (and correctness) of execution

program part1
  use omp_lib
  use, intrinsic :: iso_c_binding
  implicit none
  integer :: i, j, tid, n, ts
  integer, dimension(:), allocatable :: buffer
  double precision rand
  integer*8 time
  character*20 ctime 
  external time
  external ctime

  interface
     subroutine usleep(u) bind(c)
       use, intrinsic :: iso_c_binding
       integer(kind=c_long), value :: u
     end subroutine usleep     
  end interface


#if (EXAMPLE == 1)
  write(*,"(//a/)") "   ----- Exercise 1 ------"

!!! This exercise tries to illustrate a simple parallel OpenMP
!!! program.  Run it several times. At some occasions the printed
!!! output is "wrong". Why is that? Correct the program so that it is
!!! "correct"


!$omp parallel private(i, j)

  do i = 1, 1000
     do j = 1, 1000
        tid = omp_get_thread_num()
     end do
  end do

  print *," Thread ", omp_get_thread_num(),": My value of tid (thread id) is ", tid

!$omp end parallel

  write(*,"(/a/)") "   ----- End of exercise 1 ------"
#endif

#if (EXAMPLE == 2)
  write(*,"(//a/)") "   ----- Exercise 2 ------"

!!! This exercise illustrates some of the data-sharing clauses in
!!! OpenMP. Run the program, is the output correct? Try to make the
!!! program print the correct value for n for both  parallel sections
  
n = 10;

!$omp parallel private(n)

n = n + omp_get_thread_num()
print *,"Thread ", omp_get_thread_num(), ": My value of n is ", n

!$omp end parallel

j = 100000
!$omp parallel do private(n)
do i = 1,j
   n = i
end do
!$omp end parallel do
print *, "After ", j, "iterations the value of n is ", n

  write(*,"(/a/)") "   ----- End of exercise 2 ------"
#endif

#if (EXAMPLE == 3)
  write(*,"(//a/)") "   ----- Exercise 3 ------"

!!! This exercise tries to illustrate the usage of rudimentary OpenMP
!!! synchronization constructs. Try to make all the threads end at the
!!! same time

!$omp parallel private(ts, tid)

tid = omp_get_thread_num()
ts = time()

print *, "Thread", tid, " spawned at: ", ctime(ts)
call sleep(1)

if (mod(tid,2) .eq. 0) then
   call sleep(5)
end if

ts = time()
print *, "Thread", tid, " done at: ", ctime(ts)

!$omp end parallel

  write(*,"(/a/)") "   ----- End of exercise 3 ------"
#endif

#if (EXAMPLE == 4)
  write(*,"(//a/)") "   ----- Exercise 4 ------"

  n = 1000
  allocate(buffer(n))
  
  print *, "Computing..."
  
!$omp parallel do schedule(runtime)
  do i = 1,n
     buffer(i) = omp_get_thread_num()
     call usleep(int(rand(buffer(i))*2000, kind=c_long))
  end do
!$omp end parallel do

  print *, "Done"
  open(1, file="schedule.dat")
  
  do i = 1, n
     write(1, *) i, buffer(i)
  end do
  close(1)

  print *, "Now, run 'gnuplot schedule.gp' to visualize the scheduling policy"

  deallocate(buffer)

  write(*,"(/a/)") "   ----- End of exercise 4 ------"
#endif
end program part1
