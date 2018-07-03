module realtypes
  integer, parameter:: SINGLE=kind(1.0), DOUBLE=kind(1.0d0)
end module realtypes

program prog3a
  use realtypes
  use omp_lib
  implicit none

  integer, parameter:: N=12123123
  real(DOUBLE), parameter :: PI=3.141592653589793238462643383279506d0
  integer :: i,j,dN,tid
  real(DOUBLE), allocatable, dimension(:,:) :: A
  real(DOUBLE), allocatable, dimension(:) :: blocksum
  real(DOUBLE) :: dw, fprt, locsum
  integer :: Nthrds,start,end,MaxNthrds

  integer(kind=omp_lock_kind) , allocatable :: locks(:)

  real(DOUBLE) :: dtime

  MaxNthrds=1
  !$ MaxNthrds=omp_get_max_threads()

  allocate(A(N,2),blocksum(0:MaxNthrds-1))

  dw=PI/real(N,kind=DOUBLE)
  
  do i=1,N
    A(i,1)=i*dw
  end do

  do i=1,N
    A(i,2)=A(i,1)
  end do

  dtime=rtc()
  !$omp parallel default(none) &
  !$omp  shared(blocksum,A), private(locsum,i,start,end,Nthrds,tid,dN)
  
  start=1 ; end=N ; tid=0 ; Nthrds=1  ! Defaults for non-OpenMP
  !!! OpenMP task work division
  !$ Nthrds=omp_get_num_threads()
  !$ dN=ceiling(real(N)/Nthrds) ; tid=omp_get_thread_num()
  !$ start=1+tid*dN ; end=min((tid+1)*dN,N)
  
  locsum=A(start,1)  !!! Compute sum of my local elements
  do i=start+1,end
     locsum=locsum+A(i,1)
     A(i,1)=A(i-1,1)+A(i,1)
  end do
  blocksum(tid)=locsum !!! Store the sum in shared variable
  
  !$omp barrier   !!! Wait for all sums to be ready and flushed
  
  locsum=0.0      !!! Find out what to add to my local values
  do i=tid-1,0,-1
     locsum=locsum+blocksum(i)
  end do
  
  do i=start,end  !!! Add this to my values
     A(i,1)=A(i,1)+locsum
  end do
  
  !$omp end parallel
  print *, "First summation loop took ", rtc() - dtime, "seconds"
  

!!!-------------------------------------------------------

  !$ allocate(locks(0:MaxNthrds-1))
  !$ do tid=0,MaxNthrds-1
  !$   call omp_init_lock(locks(tid))
  !$ end do
  
  dtime=rtc()
  !$omp parallel default(none) &
  !$omp  shared(blocksum,A,locks), private(locsum,i,start,end,Nthrds,tid,dN)
  start=1 ; end=N ; tid=0 ; Nthrds=omp_get_num_threads()
  
  !$ dN=ceiling(real(N)/Nthrds) ; tid=omp_get_thread_num()
  !$ start=1+tid*dN ; end=min((tid+1)*dN,N)
  !$ call omp_set_lock(locks(tid))  ! Protect my local sum with a lock
  
  locsum=A(start,2)
  do i=start+1,end
     locsum=locsum+A(i,2)
     A(i,2)=A(i-1,2)+A(i,2)
  end do
  blocksum(tid)=locsum
  
  !$ call omp_unset_lock(locks(tid)) ! Allow for others to read my value
  
  locsum=0.0
  do i=tid-1,0,-1
     !$ call omp_set_lock(locks(i))  ! Make sure the value is available for reading
     !$ call omp_unset_lock(locks(i))
     locsum=locsum+blocksum(i)
  end do
  
  do i=start,end
     A(i,2)=A(i,2)+locsum
  end do
  
  !$omp end parallel
  print *,"Second summation loop took",rtc() - dtime,"seconds"
  
  print *,A(N,1),A(N,2)
  
contains

  double precision function rtc()
    implicit none
    integer:: icnt,irate
    real, save:: scaling
    logical, save:: scale = .true.
    
    call system_clock(icnt,irate)
    
    if(scale)then
       scaling=1.0/real(irate)
       scale=.false.
    end if
    
    rtc = icnt * scaling
    
  end function rtc
  
end program prog3a
