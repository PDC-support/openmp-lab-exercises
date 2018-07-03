#include <math.h>
#include <omp.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>

/* Row-major order macro */
#define RM(row,col) ((row) + ((2)*(col)))
/* MIN macro */
#define MIN(x, y) (((x) < (y)) ? (x) : (y))

double gettime(void) {
  struct timeval tv;
  gettimeofday(&tv,NULL);
  return tv.tv_sec + 1e-6*tv.tv_usec;
}

int main(int argc, char **argv) {
  
  int i, j, dN, tid, Nthrds, start, end, MaxNthrds;
  double dw, fprt, locsum, dtime;
  double *A;
  double *blocksum;
  int N = 12123123;
  
  omp_lock_t *locks;
  
#ifdef _OPENMP
  MaxNthrds = omp_get_max_threads();
#else
  MaxNthrds = 1;
#endif
  
  A = calloc(2 * N, sizeof(double));
  blocksum = calloc(MaxNthrds, sizeof(double));
  
  dw = M_PI / (double) N;
  
  for (i = 0; i < N; i++)
    A[ RM(0, i) ] = i * dw;
  
  for (i = 0; i < N; i++)
    A[ RM(1, i) ] = A[ RM(0, i) ];
  
  dtime = gettime();
#pragma omp parallel shared(blocksum,A), private(locsum,i,start,end,Nthrds,tid,dN)
  {
#ifdef _OPENMP
    Nthrds = omp_get_num_threads();
    dN=ceil((double) N/Nthrds); tid = omp_get_thread_num();
    start = tid*dN; end = MIN((tid+1)*dN,N);
#else
    start=0; end=N; tid=0; Nthrds=1;
#endif
    locsum = A[ RM(0,start) ];
    for (i = start+1; i < end; i++) {
      locsum += A[ RM(0, i)];
      A[ RM(0, i) ] += A[ RM(0, i - 1) ];
    }
    blocksum[tid] = locsum;
    
#pragma omp barrier
    locsum = 0;
    for(i = 0; i < tid; i++)
      locsum += blocksum[i];
    
    for (i = start; i < end; i++)
      A[ RM(0,i) ] += locsum;
  }
  printf("First summation loop took  %9.5f seconds\n", gettime() - dtime);
  
  /*--------------------------------------------------------------------------*/
#ifdef _OPENMP
  locks = calloc(MaxNthrds, sizeof(omp_lock_t));
  for (tid=0; tid<MaxNthrds; tid++)
    omp_init_lock(&(locks[tid]));
#endif
  
  dtime = gettime();
#pragma omp parallel shared(blocksum, A, locks), private(locsum,i,start,end,Nthrds,tid,dN)
  {
#ifdef _OPENMP
    Nthrds = omp_get_num_threads();
    dN=ceil((double) N/Nthrds); tid = omp_get_thread_num();
    start = tid*dN; end = MIN((tid+1)*dN,N);
    omp_set_lock(&locks[tid]); /* protect my local sum with a lock */
#else
    start=0; end=N; tid=0; Nthrds=1;
#endif
    
    locsum=A[ RM(1,start) ];
    
    for(i=start+1;i<end;i++) {
      locsum+=A[ RM(1,i) ];
      A[ RM(1,i) ] += A[ RM(1,i-1) ];
    }
    blocksum[tid]=locsum;
    
#ifdef _OPENMP
    omp_unset_lock(&locks[tid]); /* Allow others to read my value */
#endif
    
    locsum=0;
    for (i=tid-1;i>=0;i--){
#ifdef _OPENMP
      omp_set_lock(&locks[i]); /* Make sure the value is available for reading */
      omp_unset_lock(&locks[i]);
#endif
      locsum+=blocksum[i];
    }
    
    for(i=start;i<end;i++) {
      A[ RM(1,i) ]+=locsum;
    }
    
    
  }
  printf("Second summation loop took %9.5f seconds\n", gettime() - dtime);
  
  printf("%e %e\n", A[RM(0, N - 1)], A[ RM(1, N -1 )] );
  
  free(blocksum);
  free(A);
  
  return 0;
}
