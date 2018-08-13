!-----------------------------------------------------------------------
!
! shwater2d.f90 solves the two dimensional shallow water equations 
! using the Lax-Friedrich's scheme
!
!-----------------------------------------------------------------------

module types
  integer, parameter :: dp = kind(0.0d0)
  integer, parameter :: sp = kind(0.0)
end module types

!-----------------------------------------------------------------------

program shwater2d
  use types
  use omp_lib
  use vtk_export
  implicit none
  
  ! This is the main routine of the program, which allocates memory 
  ! and setup all parameters for the problem.
  !
  ! You don't need to parallelize anything here!
  !
  ! However, it might be useful to change the m and n parameters 
  ! during debugging
  !
   
  integer, parameter :: cell_size = 3  
  real(kind=dp) xstart, xend, ystart, yend
  parameter (xstart = 0.0d0, ystart = 0.0d0, xend = 4d0, yend = 4d0)

  real(kind=dp), dimension(:,:,:), allocatable :: Q
  real(kind=dp), dimension(:), allocatable :: x, y
  integer i, j, ifail, m, n
  real(kind=dp) dx, dt, epsi, delta, dy, tend, tmp
  real stime
  real, external :: rtc
  external fx,fy


  !
  ! Use m volumes in the x-direction and n volumes in the y-direction
  !
  m = 1000
  n = 1000
  

  ! epsi      Parameter used for initial condition
  ! delta     Parameter used for initial condition
  ! dx        Distance between two volumes (x-direction)
  ! dy        Distance between two volumes (y-direction)
  ! dt        Time step
  ! tend      End time
  epsi = 2d0
  delta = 0.5
  dx = (xend - xstart) / m
  dy = (yend - ystart) / n
  dt = dx / sqrt( 9.81d0 * 5d0) 
  tend = 0.1

  !
  ! Add two ghost volumes at each side of the domain
  !
  m = m + 2
  n = n + 2

  !
  ! Allocate memory for the domain
  !
  allocate(Q(cell_size, m, n), x(m), y(n), stat = ifail)

  if(ifail .ne. 0) then
     deallocate(Q, x, y)
     write(*,*) 'Memory exhausted'
     stop
  else
     tmp = -dx/2 + xstart
     do i=1,m
        x(i) = tmp
        tmp = tmp + dx
     end do

     tmp = -dy/2 + ystart
     do i=1,n
        y(i) = tmp
        tmp = tmp + dy
     end do     
  end if

  !
  ! Set initial Gauss hump
  !
  Q(2,:,:) = 0
  Q(3,:,:) = 0
  Q(1,:,:) = 4
  do j=2,n-1
     do i=2,m-1
        Q(1,i,j) =  4 + epsi * exp(-((x(i) - xend / 4d0)**2 + &
             (y(j) - yend / 4d0)**2)/delta**2)
     end do
  end do

  !
  ! Start solver
  !
  stime = rtc()
  call solver(Q, cell_size, m, n, tend, dx, dy, dt, fx, fy)
  write(*,*) 'Solver took',rtc()-stime,'sec'

  !
  ! Uncomment this line if you want visualize the result in ParaView
  !
  call save_vtk(Q, x, y, cell_size, m, n, 'result.vtk')

  deallocate(Q, x, y)

end program shwater2d

!-----------------------------------------------------------------------

subroutine solver(Q, l, m, n, tend, dx, dy, dt, fx, fy)
  use types
  implicit none

  !
  ! This is the main solver routine, parallelize this. 
  ! But don't forget the subroutine laxf_scheme_2d
  !

  integer, intent(in) :: l, m, n
  real(kind=dp), intent(inout), dimension(l, m, n) :: Q
  real(kind=dp), dimension(l, n, m) :: Qt  
  real(kind=dp), intent(in) :: dx, dy, dt
  real(kind=dp), dimension(l) :: bc_mask
  real(kind=dp), intent(in) :: tend
  real(kind=dp)  :: time
  external fx, fy
  integer i, j, steps



  bc_mask(1) = 1d0
  bc_mask(2:l) = -1d0

  steps = tend / dt
  time = 0d0
  !
  ! This is the main time stepping loop
  !
!$omp parallel  private(i, j), firstprivate(time)
  do i=1,steps
     
     !
     ! Apply boundary condition
     !
     !$omp sections
     !$omp section
     do j  = 2, n - 1
        Q(:, 1, j) = bc_mask * Q(:, 2, j)
        Qt(:, j, 1) = Q(:, 1, j)

        Q(:, m, j) = bc_mask * Q(:, m-1, j)
        Qt(:, j, m) = Q(:, m, j)
     end do
     !$omp section
     do j  = 1, m
        Q(:, j, 1) = bc_mask *  Q(:, j , 2)
        Qt(:, 1, j) = Q(:, j, 1)

        Q(:, j, n) = bc_mask *  Q(:, j, n-1)
        Qt(:, n, j) = Q(:, j, n)
     end do
     !$omp end sections
     !
     ! Update all volumes with the Lax-Friedrich's scheme
     !
     call laxf_scheme_2d(Q, Qt, l, m, n, dx, dy, dt, fx, fy)
     time = time + dt

  end do
!$omp end parallel
end subroutine solver

!-----------------------------------------------------------------------

subroutine laxf_scheme_2d(Q, Qt, l, m, n, dx, dy, dt, fx, fy)
  use types
  implicit none 

  !
  ! This is the Lax-Friedrich's scheme for updating volumes
  ! Try to parallelize it in an efficient way!
  ! 

  integer, intent(in) :: l, m, n
  real(kind=dp), intent(inout), dimension(l, m, n) :: Q
  real(kind=dp), intent(inout), dimension(l, m, n) :: Qt
  real(kind=dp), dimension(l, m) :: ffx, nFx
  real(kind=dp), dimension(l, n) :: ffy, nFy
  real(kind=dp), intent(in) :: dx, dy, dt
  external fx, fy
  integer i,j

  !
  ! Calculate and update fluxes in the x-direction
  !
  !$omp do
  do i=2,n
     call fx(Q(:,:,i), ffx, l, m)
     do j=2,m
        nFx(:,j) = 0.5  * ((ffx(:,j-1) + ffx(:,j)) - &
             dx/dt * (Q(:,j,i) - Q(:,j-1,i)))
     end do     
     do j=2,m-1
        Qt(:,i, j) = Q(:,j,i) -  dt/dx * ((nFx(:,j+1)  -  nFx(:,j)))
     end do
  end do
  !$omp end do
  !
  ! Calculate and update fluxes in the y-direction
  !
  !$omp do
  do i=2,m
     call fy(Qt(:,:,i), ffy, l, n)
     do j=2,n
        nFy(:,j) = 0.5  * ((ffy(:,j-1) + ffy(:,j)) - &
             dy/dt * (Qt(:,j,i) - Qt(:,j-1,i)))
     end do
     do j=2,n-1
        Q(:,i,j) = Qt(:,j,i) -  dt/dy * ((nFy(:,j+1)  -  nFy(:,j)))
     end do     
  end do
  !$omp end do
end subroutine laxf_scheme_2d

!-----------------------------------------------------------------------
!
! The rest of the file contains auxiliary functions, which you don't
! need to parallelize.
!
! fx              flux function in the x-direction
! fy              flux function in the y-direction
! rtc             timing function
!
!-----------------------------------------------------------------------

subroutine fx(q, fq, m, n)
  use types 
  implicit none 

  real(kind=dp) ,intent(in),dimension(m,n) :: q
  real(kind=dp) ,intent(out),dimension(m,n) :: fq
  integer ,intent(in) :: m,n
  real(kind=dp) ,parameter :: g = 9.81

  fq(1,:) = q(2,:)
  fq(2,:) = (q(2,:)**2 / q(1,:)) + (g * q(1,:)**2) / 2
  fq(3,:) = (q(2,:) * q(3,:)) / q(1,:)
  
end subroutine fx

!-----------------------------------------------------------------------

subroutine fy(q, fq, m, n)
  use types
  implicit none 

  real(kind=dp) ,intent(in),dimension(m,n) :: q
  real(kind=dp) ,intent(out),dimension(m,n) :: fq
  integer ,intent(in) :: m,n
  real(kind=dp) ,parameter :: g = 9.81

  fq(1,:) = q(3,:)
  fq(2,:) = (q(2,:) * q(3,:)) / q(1,:) 
  fq(3,:) = (q(3,:)**2 / q(1,:) ) + (g * q(1,:)**2) / 2
  
end subroutine fy

!-----------------------------------------------------------------------

real function rtc()
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

!-----------------------------------------------------------------------
