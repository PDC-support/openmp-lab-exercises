#include 
#include 
#include 
#include time.h>

double gettime(void) {
  struct timeval tv;
  gettimeofday(&tv;,NULL);
  return tv.tv_sec + 1e-6*tv.tv_usec;
}

#define GRAPH_SIZE 1000
#define ADJLIST_SIZE 4

*
  This exercise aims at showing the mutual exclusion clauses in
OpenMP. The program generates a graph, represented as an adjacency
  list. Is the given program correct? Try to fix it without too much
  parallel overhead.
*/


  typedef struct {
    int *adj;
    int top;
    int size;
    omp_lock_t mutex; /* node mutex */
  } node_t;


typedef struct {
  node_t *n;
} graph_t;

void init_graph(graph_t *g) {
  int i;
  
  printf("Initialize graph data structure...");

  /* Allocate space for each node */
  g->n = malloc(GRAPH_SIZE * sizeof(node_t));

  /* Initialize each node's adjacency list */
  for (i = 0; i < GRAPH_SIZE; i++) {
    g->n[i].size = ADJLIST_SIZE;
    g->n[i].top = 0;
    g->n[i].adj = calloc(g->n[i].size ,sizeof(int));
    omp_init_lock(&g-;>n[i].mutex);
  }

  printf("Done\n");
}

void free_graph(graph_t *g){
  int i;

  printf("Cleaning up...");

  for (i = 0; i < GRAPH_SIZE; i++) {
    free(g->n[i].adj);
    omp_destroy_lock(&g-;>n[i].mutex);
  }
  free(g->n);

  printf("Done\n");

}


/* 
 * Push a new node to the adjacency list
 */
void push(int i, node_t *n) {
  int *tmp;
  
  if (n->top >= n->size) {
    n->size += ADJLIST_SIZE;
    tmp = n->adj;
    n->adj = realloc(tmp, n->size * sizeof(int));    
  }
  
  n->adj[(n->top++)] = i;
}

/*
 * Add node j as neighbour to node i
 */
void add(int i, int j, graph_t *g) {
  int k;

  omp_set_lock(&g-;>n[i].mutex);
  for (k = 0; k < g->n[i].top; k++) 
    if (g->n[i].adj[k] == j) {
      omp_unset_lock(&g-;>n[i].mutex);
      return;
    }



  push(j, &g-;>n[i]);

  omp_unset_lock(&g-;>n[i].mutex);
  
}



int main(int argc, char **argv) {
  int i;
  graph_t g;
  double stime;


  init_graph(&g;);

  stime = gettime();
#pragma omp parallel shared(g)
  {
#pragma omp master
    {
      printf("Inserting nodes using %d threads...", omp_get_num_threads());
      fflush(stdout);

    }
    #pragma omp barrier
#pragma omp for 
    for (i = 0; i < (GRAPH_SIZE * GRAPH_SIZE) ; i++) 
      add(random()%GRAPH_SIZE, random()%GRAPH_SIZE, &g;);

  }
  printf("Done\nGraph generated in %.5f seconds\n", gettime() - stime);

  free_graph(&g;);

  return 0;
}
