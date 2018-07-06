!!! This program generates some vectors and matrices
!!! It manipulates them and finally computes some global
!!! things that are printed


program part2
  implicit none
  integer, parameter:: MATSIZE=900
  double precision, dimension(:,:), allocatable :: Mat_A, Mat_B, Mat_C, Mat_D
  double precision :: x, y, scal, Sum_A, Sum_B, Sum_C, Sum_D
  integer :: i, j, k

  double precision :: dtime, dtime2

  allocate(Mat_A(MATSIZE, MATSIZE),Mat_B(MATSIZE, MATSIZE), &
       Mat_C(MATSIZE, MATSIZE), MAT_D(MATSIZE, MATSIZE))

  write(*,"(//a/)") "   ----- Exercise 1 ------"
!!! The code below generates three matrices. Try to think of a way in which
!!! this can be made parallel in any way. Make sure that the printed output
!!! x is correct in your parallel version


  dtime = rtc()
!$omp parallel sections private(i,j) lastprivate(x)
!$omp section
  x=0.35d0
  do j=1,MATSIZE
    do i=1,MATSIZE
      x=1-fraction(sin(x))
      Mat_A(i,j)=x
    end do
  end do

!$omp section
  x=0.68d0
  do j=1,MATSIZE
    do i=1,MATSIZE
      x=1-fraction(sin(x))
      Mat_B(i,j)=x
    end do
  end do
      
!$omp section
  x=0.24d0
  do j=1,MATSIZE
    do i=1,MATSIZE
      x=1-fraction(sin(x))
      Mat_C(i,j)=x
    end do
  end do
!$omp end parallel sections

  dtime = rtc() - dtime
  Sum_A=check_sum(Mat_A)
  Sum_B=check_sum(Mat_B)
  Sum_C=check_sum(Mat_C)

  print *," The check sum of the matrices evaluates to:"
  print 100,"A",Sum_A
  print 100,"B",Sum_B
  print 100,"C",Sum_C
  print 110, dtime

  print 101,"The variable x evaluates to",x
100 format("Sum of matrix ",a,g25.16)
101 format(a,g37.25)
110 format("Time for the exercise: ",f9.5," seconds")
  write(*,"(/a/)") "   ----- End of exercise 1 ------"

#if (EXAMPLE > 1 && EXAMPLE < 3 || SERIAL)

  write(*,"(//a/)") "   ----- Exercise 2 ------"
!!! This code makes a simple attempt at computing a matrix multiply. Try
!!! to parallelize it without changing the results (more than negligible)
!!! In this exercise parallelize the outer-most loop
  
  dtime = rtc()
!$omp parallel do private(j,k) lastprivate(scal)
  do i=1,MATSIZE
    do j=1,MATSIZE
      scal=0.0d0
      do k=1,MATSIZE
        scal=scal+Mat_A(i,k)*Mat_B(k,j)
      end do
      Mat_D(i,j)=scal
    end do
  end do
!$omp end parallel do

  dtime = rtc() - dtime

  Sum_D=check_sum(Mat_D)
  print *," The check sum of the matrices evaluates to:"
  print 100,"D",Sum_D
  print 101,"The value of scal is:",scal
  print 110, dtime  
  write(*,"(/a/)") "   ----- End of exercise 2 ------"
#endif

#if (EXAMPLE > 2 || SERIAL)

  write(*,"(//a/)") "   ----- Exercise 3 ------"
!!! This code makes a simple attempt at computing a matrix multiply. Try
!!! to parallelize it without changing the results (more than negligible)
!!! In this exercise parallelize the second outer-most loop

  dtime = rtc()
  do i=1,MATSIZE
!$omp parallel do private(k) lastprivate(scal)
    do j=1,MATSIZE
      scal=0.0d0
      do k=1,MATSIZE
        scal=scal+Mat_A(i,k)*Mat_B(k,j)
      end do
      Mat_D(i,j)=scal
    end do
!$omp end parallel do
  end do

  dtime = rtc() - dtime

  Sum_D=check_sum(Mat_D)
  print *," The check sum of the matrices evaluates to:"
  print 100,"D",Sum_D
  print 101,"The value of scal is:",scal
  print 110, dtime  
  write(*,"(/a/)") "   ----- End of exercise 3 ------"

#endif

  deallocate(Mat_A, Mat_B, Mat_C, Mat_D)

contains
  function check_sum(Mat)
    implicit none
    double precision :: check_sum
    double precision :: Mat(:,:)
    check_sum=sum(Mat)
  end function check_sum

  function rtc()
    implicit none
    double precision :: rtc
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

end program part2
