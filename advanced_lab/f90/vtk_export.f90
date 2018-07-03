module vtk_export
  implicit none

  ! VTK export
  !
  ! This module stores the volumes Q first variable 
  ! as VTK polydata
  !
  
contains
  subroutine save_vtk(Q, x, y, l, m, n, fname, title)
    implicit none
    integer, intent(in) :: l, m, n
    double precision, intent(in), dimension(l, m, n) :: Q
    double precision, intent(in), dimension(n) :: x
    double precision, intent(in), dimension(m) :: y
    character, intent(in) :: fname*(*)
    character, optional :: title*(*)
    integer i,j

    open(1, file=fname)

    !
    ! Write vtk Datafile header
    !
    write(1,fmt='(A)') '# vtk DataFile Version 2.0'
     if(present(title)) then
       write(1,fmt='(A)') title
    else
       write(1,fmt='(A)') 'VTK'
    end if  
    write(1,fmt='(A)') 'ASCII'
    write(1,fmt='(A)') 'DATASET POLYDATA'
    write(1,*)
    
    !
    ! Store water height as polydata
    !
     write(1,fmt='(A,I8,A)') 'POINTS', m*n,' double'
     do j=1,n
        do i=1,m
           write(1,fmt='(F7.5,F15.6,F17.12)') x(i), y(j), Q(1,i,j)
        end do
     end do
     write(1,*)
     
     write(1,fmt='(A,I12,I12,I12)') 'VERTICES',n,n*(m+1)
     do j=1,n
        write(1,fmt='(I12)', advance='no') m
        do i=0,m-1
           write(1,fmt='(I12)', advance='no') i+(j-1)*(m)
        end do
        write(1,*)
     end do

     !
     ! Store lookup table
     !
     write(1,fmt='(A,I12)') 'POINT_DATA',m*n
     write(1,fmt='(A)') 'SCALARS height double 1'
     write(1,fmt='(A)') 'LOOKUP_TABLE default'
     do j=1,n
        do i=1,m
           write(1,fmt='(F15.12)') Q(1,i,j)
        end do
     end do
     write(1,*)
     close(1)
     
   end subroutine save_vtk
end module vtk_export
