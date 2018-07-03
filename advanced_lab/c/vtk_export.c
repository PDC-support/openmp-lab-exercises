
#include <stdlib.h>
#include <stdio.h>

#define Q(i, j, k) Q[((k) + (n) * ((j) + (m) * (i)))]



void save_vtk(double *Q, double *x, double *y, int m, int n) {
  
  int i, j;
  FILE *fp = fopen("result.vtk", "w");
  
  /* Write vtk Datafile header */
  fprintf(fp, "# vtk DataFile Version 2.0\n");
  fprintf(fp, "VTK\nASCII\nDATASET POLYDATA\n");

  /* Store water height as polydata */
  fprintf(fp, "\nPOINTS %d double\n", m*n);
  
  for (j = 0; j < n; j++) 
    for (i = 0; i < m; i++)
      fprintf(fp, "%e %e %e\n", x[i], y[j], Q(0, i, j));

  fprintf(fp,"\nVERTICES %d %d\n", n, n *(m+1));
  for (j = 0; j < n; j++)  {
    fprintf(fp, "%d ", m);
    for (i = 0; i < m; i++) 
      fprintf(fp, "%d ", i+j*m);
    fprintf(fp,"\n");
  }

  /* Store lookup table */
  fprintf(fp,
	  "POINT_DATA %d\nSCALARS height double 1\nLOOKUP_TABLE default\n",m*n);
  for (j = 0; j < n; j++)
    for (i = 0; i < m; i++)
      fprintf(fp, "%e\n", Q(0, i, j));
  fclose(fp);     
}
