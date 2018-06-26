printf("\n   ----- Exercise 1 ------\n\n");

/*
    This exercise tries to illustrate a simple parallel OpenMP
    program.  Run it several times. At some occasions the printed
    output is "wrong". Why is that? Correct the program so that it is
    "correct"
*/

#pragma omp parallel private(i, j, tid)
{
  for (i = 0; i < 1000; i++) 
    for (j = 0; j < 1000; j++) 
      tid = omp_get_thread_num();
  
  printf("Thread %d : My value of tid (thread id) is %d\n", omp_get_thread_num(), tid);
}
  

printf("\n   ----- End of exercise 1 ------\n\n");
