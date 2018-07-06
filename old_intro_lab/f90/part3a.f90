module realtypes
  integer, parameter:: SINGLE=kind(1.0), DOUBLE=kind(1.0d0)
end module realtypes

program prog4
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

!  type(omp_lock_t), allocatable :: locks(:)

  real(DOUBLE) :: dtime
  real(DOUBLE), external :: rtc

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
  do i=2,N
    A(i,1)=A(i-1,1)+A(i,1)
  end do
  print *, "First summation loop took ", rtc() - dtime, "seconds"


!!!-------------------------------------------------------

  dtime=rtc()
  do i=2,N
    A(i,2)=A(i-1,2)+A(i,2)
  end do
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
  
end program prog4
