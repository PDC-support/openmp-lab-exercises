printf("\n   ----- Exercise 3 ------\n\n");

/*
   This exercise tries to illustrate the usage of rudimentary OpenMP
   synchronization constructs. Try to make all the threads end at the
   same time
*/

#pragma omp parallel private(ts, tid) 
{
  tid = omp_get_thread_num();
  time(&ts;);

  printf("Thread %d spawned at:\t %s", tid, ctime(&ts;));  
  sleep(1); 
  if(tid%2 == 0)
    sleep(5);
#pragma omp barrier
  time(&ts;);
  printf("Thread %d done at:\t %s", tid, ctime(&ts;));
}
printf("\n   ----- End of exercise 3 ------\n\n");
