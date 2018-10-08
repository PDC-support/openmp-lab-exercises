#include <stdio.h>
#include <math.h>
#include <omp.h>

/*
 * This program computes pi as
 * \pi = 4 arctan(1)
 *     = 4 \int _0 ^1 \frac{1} {1 + x^2} dx
 */
int main(int argc, char** argv)
{
    unsigned long nsteps = 1<<27; /* around 10^8 steps */
    double dx = 1.0 / nsteps;

    double pi = 0.0;
    double start_time = omp_get_wtime();

    unsigned long i;
    for (i = 0; i < nsteps; i++)
    {
        double x = (i + 0.5) * dx;
        pi += 1.0 / (1.0 + x * x);
    }
    pi *= 4.0 * dx;

    double run_time = omp_get_wtime() - start_time;
    double ref_pi = 4.0 * atan(1.0);
    printf("\npi with %ld steps is %.10f in %.6f seconds (error=%e)\n",
           nsteps, pi, run_time, fabs(ref_pi - pi));

    return 0;
}
