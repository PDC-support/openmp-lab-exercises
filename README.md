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


# Running OpenMP programs on Beskow

First it is necessary to book a node for interactive use:

```
salloc -A <allocation-name> -N 1 -t 1:0:0
```

Then the aprun command is used to launch an OpenMP application:

```
aprun -n 1 -d <number of threads> -cc none ./example.x
```

In this example we will start one task with 32 threads (there are 32 cores per node on the Beskow nodes).

It is important to use the `aprun` command since otherwise the job will run on the Beskow login node.

# OpenMP Exercises

The aim of these exercises is to give an introduction to OpenMP programming. 
All examples are available in both C and Fortran90.

- OpenMP Intro lab: 
  - [Instructions](intro_lab/README.md)
  - Simple hello world program [in C](intro_lab/hello.c) and [in Fortran](intro_lab/hello.f90)
  - Calculate pi [in C](intro_lab/pi.c) and [in Fortran](intro_lab/pi.f90)
  - Solutions will be made available later during the lab
- OpenMP Advanced Lab: 
  - [Instructions](advanced_lab/README.md)
  - In C: [shwater2d.c](advanced_lab/c/shwater2d.c), [vtk_export.c](advanced_lab/c/vtk_export.c) and [Makefile](advanced_lab/c/Makefile)
  - In Fortran: [shwater2d.f90](advanced_lab/f90/shwater2d.f90), [vtk_export.f90](advanced_lab/f90/vtk_export.f90) and [Makefile](advanced_lab/f90/Makefile)
  - Solutions will be made available later during the lab

