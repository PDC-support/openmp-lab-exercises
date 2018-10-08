#include <stdio.h>
#include <math.h>
#include <omp.h>

#define NSTEPS 134217728
#define MAXTHREADS 4

/*
 * This program computes pi as
 * \pi = 4 arctan(1)
 *     = 4 \int _0 ^1 \frac{1} {1 + x^2} dx
 */
int main(int argc, char** argv)
{
    double dx = 1.0 / NSTEPS;

    int nthreads;
    for (nthreads = 1; nthreads <= MAXTHREADS; nthreads++)
    {
        long i;
        double x, pi = 0.0;

        omp_set_num_threads(nthreads);
        double start_time = omp_get_wtime();

        #pragma omp parallel  
        {
            #pragma omp single
            printf("num_threads = %d,  ", nthreads);

            #pragma omp for private(x) reduction(+:pi)
            for (i = 0; i < NSTEPS; i++)
            {
                x = (i + 0.5) * dx;
                pi += 1.0 / (1.0 + x * x);
            }
        }

        pi *= 4.0 * dx;
        double run_time = omp_get_wtime() - start_time;
        double ref_pi = 4.0 * atan(1.0);
        printf("pi with %ld steps is %.10f in %.6f seconds (error=%e)\n",
               NSTEPS, pi, run_time, fabs(ref_pi - pi));
    }

    return 0;
}
