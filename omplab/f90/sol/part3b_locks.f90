!!! This exercise aims at showing the mutual exclusion clauses in
!!! OpenMP. The program generates a graph, represented as an adjacency
!!! list. Is the given program correct? Try to fix it without too much
!!! parallel overhead.

program part3b
 use omp_lib
 implicit none

 integer, parameter :: GRAPH_SIZE = 1000
 integer, parameter :: ADJLIST_SIZE = 4
 double precision :: rand, stime
 real :: r1,r2

 type node_t
   integer, pointer :: adj(:)
   integer top, size
   integer(kind=omp_lock_kind) :: mutex
 end type node_t

 type graph_t
   type(node_t), pointer :: n(:)     
 end type graph_t

 integer i,ii,jj
 type(graph_t) g

 call random_seed()
 call init_graph(g)

 stime = rtc()
!$omp parallel shared(g) private(ii,jj,r1,r2)
!$omp master
 print *, "Inserting nodes using", omp_get_num_threads(), "threads"
!$omp end master
!$omp do
 do i = 1, GRAPH_SIZE**2
   call random_number(r1)
   call random_number(r2)   
   ii=mod(int(r1*(2**15 -1)), GRAPH_SIZE) + 1
   jj=mod(int(r2*(2**15 -1)), GRAPH_SIZE) + 1
   call add(ii,jj,g)
 end do
!$omp end do
!$omp end parallel
 print *, "Done, graph generated in", rtc()-stime, "seconds"
 
 call free_graph(g)

contains
  subroutine init_graph(g)
    integer i
    type(graph_t), intent(inout) :: g

    print *,"Initialize graph data structure..."

    allocate(g%n(GRAPH_SIZE))
 
    do i = 1, GRAPH_SIZE
      allocate(g%n(i)%adj(ADJLIST_SIZE))
      g%n(i)%adj(:) = 0
      g%n(i)%top = 1
      g%n(i)%size = 0
!$ call omp_init_lock(g%n(i)%mutex)
    end do
 
    print *, "Done"

  end subroutine init_graph
 
  subroutine free_graph(g)
    integer i
    type(graph_t), intent(inout) :: g
 
    print *,"Cleaning up..."
 
    do i = 1,GRAPH_SIZE
      deallocate(g%n(i)%adj)       
!$ call omp_destroy_lock(g%n(i)%mutex)
    end do
    deallocate(g%n)

    print *,"Done"

  end subroutine free_graph

!! Push a new node to the adjacency list
  subroutine push(i, n)
    integer, intent(in) :: i
    type(node_t), intent(inout) :: n
    integer, pointer :: tmp(:)

    if (n%top .ge. n%size) then
      n%size = n%size + ADJLIST_SIZE
      allocate(tmp(n%size))
      tmp(1:n%top) = n%adj(:)
      deallocate(n%adj)
      n%adj => tmp
    end if

    n%adj(n%top) = i
    n%top = n%top + 1   
  end subroutine push

!! Add node j as neighbour to node i
  subroutine add(i, j, g)
    integer, intent(in) :: i, j
    type(graph_t), intent(inout) :: g
    integer k

!$ call omp_set_lock(g%n(i)%mutex)
    do k = 1, (g%n(i)%top - 1)
      if (g%n(i)%adj(k) .eq. j) then
!$ call omp_unset_lock(g%n(i)%mutex)
        return
      end if
    end do

    call push(j, g%n(i)) 

!$ call omp_unset_lock(g%n(i)%mutex)
  end subroutine add

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
 
end program part3b
