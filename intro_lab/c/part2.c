#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <omp.h>
#include <sys/time.h>

#define MATSIZE 900

double gettime(void) {
  struct timeval tv;
  gettimeofday(&tv,NULL);
  return tv.tv_sec + 1e-6*tv.tv_usec;
}

double check_sum(double **mat) {
  int i, j;
  double sum = 0.0;

  for(i = 0; i < MATSIZE; i++) 
    for(j = 0; j < MATSIZE; j++) 
      sum += mat[i][j];
  return sum;
}

/*
  This program generates some vectors and matrices
  It manipulates them and finally computes some global
  things that are printed
*/

int main(int argc, char **argv) {

  int i,j, k, iptr;
  double **mat_a, **mat_b, **mat_c, **mat_d;
  double  x, scal;
  double dtime;

  
  mat_a = (double **) malloc(MATSIZE * sizeof(double *));
  mat_b = (double **) malloc(MATSIZE * sizeof(double *));
  mat_c = (double **) malloc(MATSIZE * sizeof(double *));
  mat_d = (double **) malloc(MATSIZE * sizeof(double *));
  
  mat_a[0] = (double *) malloc(MATSIZE * MATSIZE * sizeof(double));
  mat_b[0] = (double *) malloc(MATSIZE * MATSIZE * sizeof(double));
  mat_c[0] = (double *) malloc(MATSIZE * MATSIZE * sizeof(double));
  mat_d[0] = (double *) malloc(MATSIZE * MATSIZE * sizeof(double));

  for (i = 0; i < MATSIZE; i++) {
    mat_a[i] = mat_a[0] + i*MATSIZE;
    mat_b[i] = mat_b[0] + i*MATSIZE;
    mat_c[i] = mat_c[0] + i*MATSIZE;
    mat_d[i] = mat_d[0] + i*MATSIZE;
  }
  
  /*--------------------------------------------------------------------------*/

  printf("\n   ----- Exercise 1 ------\n\n");

  /*
    The code below generates three matrices. Try to think of a way in which
    this can be made parallel in any way. Make sure that the printed output
    x is correct in your parallel version
  */


  dtime = gettime();
  x = 0.35;
  for (j = 0; j < MATSIZE; j++) {
    for (i = 0; i < MATSIZE; i++) {
      x = 1 - frexp(sin(x), &iptr);
      mat_a[i][j] = x;
    }
  }

  x = 0.68;
    for (j = 0; j < MATSIZE; j++) {
      for (i = 0; i < MATSIZE; i++) {	
      x = 1 - frexp(sin(x), &iptr);
      mat_b[i][j] = x;
    }
  }

  x = 0.24;
  for (j = 0; j < MATSIZE; j++) {      
    for (i = 0; i < MATSIZE; i++) {
      x = 1 - frexp(sin(x), &iptr);
      mat_c[i][j] = x;
    }
  }
  dtime = gettime() - dtime;
  printf("The sum of the matrices evaluates to:\n"
	 "Matrix A:%12.4f\t Matrix B:%12.4f\t Matrix C:%12.4f \n",
	 check_sum(mat_a), check_sum(mat_b), check_sum(mat_c));
  printf("Time for the exercise: %9.5f seconds\n", dtime);

  printf("\n   ----- End of exercise 1 ------\n\n");

  /*--------------------------------------------------------------------------*/

#if (EXAMPLE > 1 && EXAMPLE < 3 || SERIAL)

  printf("\n   ----- Exercise 2 ------\n\n");

  /*
    This code makes a simple attempt at computing a matrix multiply. Try
    to parallelize it without changing the results (more than negligible)
    In this exercise parallelize the outer-most loop
  */

  dtime = gettime();
  for (i = 0; i < MATSIZE; i++) {
    for (j = 0; j < MATSIZE; j++) {
      scal = 0.0;
      for (k = 0; k < MATSIZE; k++) {
	scal += mat_a[i][k] * mat_b[k][j];
      }
      mat_d[i][j] = scal;
    }
  }
  dtime = gettime() - dtime;
  printf("The sum of matrix D evaluates to: %12.4f\n", check_sum(mat_d));
  printf("The value of scal is: %f\n", scal);
  printf("Time for the exercise: %9.5f seconds\n", dtime);

  printf("\n   ----- End of exercise 2 ------\n\n");

#endif

  /*--------------------------------------------------------------------------*/

#if (EXAMPLE > 2 || SERIAL)

  printf("\n   ----- Exercise 3 ------\n\n");

  /*
    This code makes a simple attempt at computing a matrix multiply. Try
    to parallelize it without changing the results (more than negligible)
    In this exercise parallelize the second outer-most loop
  */

  dtime = gettime();

  for (i = 0; i < MATSIZE; i++) {
    for (j = 0; j < MATSIZE; j++) {
      scal = 0.0;
      for (k = 0; k < MATSIZE; k++) {
	scal += mat_a[i][k] * mat_b[k][j];
      }
      mat_d[i][j] = scal;
    }
  }

  dtime = gettime() - dtime;

  printf("The sum of matrix D evaluates to: %12.4f\n", check_sum(mat_d));
  printf("The value of scal is: %f\n", scal);
  printf("Time for the exercise: %9.5f seconds\n", dtime);

  printf("\n   ----- End of exercise 3 ------\n\n");
#endif  

  /*--------------------------------------------------------------------------*/


  free(mat_d[0]); 
  free(mat_c[0]); 
  free(mat_b[0]);
  free(mat_a[0]);

  free(mat_d);
  free(mat_c);
  free(mat_b);
  free(mat_a);
  

  return 0;
}
