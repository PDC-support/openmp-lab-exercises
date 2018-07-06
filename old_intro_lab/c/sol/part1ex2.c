printf("\n   ----- Exercise 2 ------\n\n");

/*
    This exercise illustrates some of the data-sharing clauses in
    OpenMP. Run the program, is the output correct? Try to make the
    program print the correct value for n for both  parallel sections
*/

n = 10;
#pragma omp parallel private(n), firstprivate(n)
{
  n += omp_get_thread_num();
  printf("Thread %d : My value of n is %d \n", omp_get_thread_num(), n);
}

j = 100000;
#pragma omp parallel for private(n), lastprivate(n)
for (i = 1; i <= j; i++)
  n = i;

printf("\nAfter %d iterations the value of n is %d \n\n", j, n);
 
printf("\n   ----- End of exercise 2 ------\n\n");
