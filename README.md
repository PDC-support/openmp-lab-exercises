**Instructions and hints on how to run for the OpenMP lab**

# Where to run

The exercises will be run on PDC's CRAY XC-40 system [Beskow](https://www.pdc.kth.se/hpc-services/computing-systems):

```
beskow.pdc.kth.se
```

# How to login

To access PDC's cluster you should use your laptop and the Eduroam or KTH Open wireless networks.

[Instructions on how to connect from various operating systems](https://www.pdc.kth.se/support/documents/login/login.html).


# More about the environment on Beskow

The Cray automatically loads several [modules](https://www.pdc.kth.se/support/documents/run_jobs/job_scheduling.html#accessing-software) at login.

- Heimdal - [Kerberos commands](https://www.pdc.kth.se/support/documents/login/login.html#general-information-about-kerberos)
- OpenAFS - [AFS commands](https://www.pdc.kth.se/support/documents/data_management/afs.html)
- SLURM -  [batch jobs](https://www.pdc.kth.se/support/documents/run_jobs/queueing_jobs.html) and [interactive jobs](https://www.pdc.kth.se/support/documents/run_jobs/run_interactively.html)


# Running MPI programs on Beskow

First it is necessary to book a node for interactive use:

```
salloc -A <allocation-name> -N 1 -t 1:0:0
```

Then the aprun command is used to launch an MPI application:

```
aprun -n 32 ./example.x
```

In this example we will start 32 MPI tasks (there are 32 cores per node on the Beskow nodes).

If you do not use aprun and try to start your program on the login node then you will get an error similar to

```
Fatal error in MPI_Init: Other MPI error, error stack:
MPIR_Init_thread(408): Initialization failed
MPID_Init(123).......: channel initialization failed
MPID_Init(461).......:  PMI2 init failed: 1
```


# OpenMP Exercises

The aim of these exercises is to give an introduction to OpenMP programming. 
All examples are available in both C and Fortran90.

- OpenMP Intro lab: 
  - [Instructions](intro_lab/OpenMPlab-assigment.pdf)]
  - Simple hello world program [in C](intro_lab/hello.c) and in Fortran (TODO: add fortran)
  - Calculate pi [in C](intro_lab/pi.c) and in Fortran (TODO: add fortran)
- OpenMP Advanced Lab: 
  - [Instructions](advanced_lab/ompproj.pdf)
  - In C: [shwater2d.c](advanced_lab/c/shwater2d.c), [vtk_export.c](advanced_lab/c/vtk_export.c) and [Makefile](advanced_lab/c/Makefile)
  - In Fortran[shwater2d.f90](advanced_lab/f90/shwater2d.f90) and [vtk_export.f90](advanced_lab/f90/vtk_export.f90) and [Makefile](advanced_lab/f90/Makefile)





