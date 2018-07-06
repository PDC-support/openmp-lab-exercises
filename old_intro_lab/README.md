# About this exercise

The aim of this exercise is to give an introduction to OpenMP programming. The test examples are all written in both C and Fortran90.

The exercise consists of three parts. The goal of the first part is to give you some familiarity to the OpenMP syntax by successively adding directives to a small test program. In the second part there is a small dummy program that you will parallelize in a guided manner. Finally, in the third part there are two programs to parallelize. Both are dealing with the issue of race conditions and the parallelization is of a more non-trivial nature.

## Location of the examples

A Makefile for the Cray nodes is to be found together with the source codes. You should copy this tarfile to a work directory of your own choice. The command below will untar the exercises into a directory omplab in your working directory.

```bash
$ tar xvf omplab.tar 
```

## Answers to the exercises

All exercises have suggestions to how they can be solved. Compare your solution to ours. What are the good things and bad things for the different solutions? If you were not able to solve the exercise, make sure you understand how our suggested solution work. The answers will appear below towards the end of the exercise session.

If you'd like to try our suggested solution, it is probably most easy to use the "Save As..." function in your web browser. Save the frame with the solution in "Text" mode to make sure that only the program is saved and not any information about font types etc. The solutions have the relevant changes made to the original program marked in bold face.

# The first set of exercises

You will start with the file part1.(c/f90) and make changes to it in this exercise. There are four different sections in the code you will work on. Do your changes to your copy of the file without changing its name. You can then recompile it using the make utility after each change you make.

## part1ex1 -- Controlling a parallel section

Thus exercise tries to illustrate a simple parallel OpenMP program.

Compile the exercise by executing the command

```bash
$ make part1ex1
```

Run the resulting program:

```bash
aprun -n 1 -d number of threads ./part1ex1
```

Remember that on the Cray you need to set the environment variable OMP_NUM_THREADS to the number of threads as described in the general instructions.
Execute the program several times. Sometimes the output is incorrect. What is, and why? Fix the parallelization directive so that the program always prints the expected output.

## part1ex2 -- Data-sharing

The default storage type in OpenMP is shared. In many instances it is very useful to add the clause default(none) to the directives. If you take this as a habit you will always be reminded of what variables are in use and not forget to decide if a variable is to be shared or private. Furthermore, in OpenMP private data is also undefined on entry to a parallel section. Hence, this causes problems with pre-initialized private variable upon entry/exit to the parallel section.

Compile the next example:

```bash
make part1ex2
```

The resulting program is named part1ex2. Run the program (using aprun as described above), is the output correct? Try to make the program print the correct value of n for both parallel sections.
Hint: Look at the OpenMP standard subroutines and functions. A copy of the standard document is available if you open http://www.openmp.org/mp-documents/spec30.pdf in your web browser

## part1ex3 -- Rudimentary synchronization

This exercise tries to illustrate the usage of rudimentary OpenMP synchronization constructs. Compile make part1ex3 and run the example part1ex3. Try to make all the threads end at the same time.

## Prog1Ex4 -- Scheduling
The workload distribution for a loop can be controlled by a scheduling clause in OpenMP. It can be controlled either by a directive or by an environment variable. In this exercise we will use the later approach to control the scheduling of a simple loop. The scheduling policy is controlled by:

```bash
$ export OMP_SCHEDULE=type,chunk_size
```

where type can be any of static,dynamic,guided and chunk_size is an optional argument controlling the granularity of the workload distribution. The program stores the workload distribution to a file such that it can be visualized later.
Compile the program with make part1ex4. Run the program with OMP_SCHEDULE=static. After it has completed, execute gnuplot schedule.gp, and look at the result with xview schedule.png (Require X-forwarding).

The x-axis of the plot corresponds to loop iterations, and the y-axis represents the threads. Can you figure out what the static scheduling does? Experiment with different values of OMP_SCHEDULE and try to figure out what static, dynamic, guided does. Also, try to change the chunk_size, for example OMP_SCHEDULE=static,2 and observe what happens.

# The second set of exercises

We will in this section go through a guided parallelization of a simulated application. The application first creates three matrices according to a recursive secret formula. The program then multiplies the matrices with each other a few times. First compile a serial version of the program that you can use to check your results against:

```bash
$ make part2serial
```

Run the serial program (part2Serial) and save the results in a file so that you can compare your parallel program to this.

## part2ex1 -- Parallel matrix generation

Look at the section in the code marked Exercise 1. Three matrices are generated. Try to think of a way to parallelize this. Implement this parallelization. Compile your program with the command:

```bash
$ make part2ex1
```

Does it produce the same check sums for the matrices and the same output for x? If not, try again. Hint: The parallelization I think of will not scale beyond three threads.

## part2ex2 -- Parallelizing a do loop

Compile the second example make part2ex2. This loop makes a matrix multiplication. Parallelize the outer-most loop. Make sure the output is correct when you are done. Run your program several times to try to verify it is correct. Compare your solution to ours (there are several correct ways to do this exercise).

## part2ex3 -- Parallelizing a do loop

Continue to the section of the code marked Exercise 3. This time try to parallelize the second outer-most loop (the j-loop). Make sure the output is not changed from the output in the serial version.  

If this had been a real application, which parallelization would you prefer? part2ex2 or part2ex3? Why?

# Non-trivial parallelization

Reality is usually less attractive than lab exercises. Now that you have become familiar with the directives in OpenMP, you might feel up to a slightly more challenging task.

## part3a -- Cumulative sum

In the example program part3a.(c/f90) a cumulative sum is computed. Compile the serial version of the program using the command make part3serial. Run the program part3serial and save the results in a file so that you can compare your parallel program to this.

The core in this program consists of the loop:

```fortran
do i=2,N 
  A(i,1)=A(i-1,1)+A(i,1)
end do
```

In this example N is a large number so parallelizing it should be beneficial. Try to make this loop parallel. Run it several times to make sure the result is the same each time you run and that it is the same as for the serial program. You can compile the OpenMP version of the same program using the command make part3a.

The suggested solution contains two slightly different ways to accomplish the task, but uses the same parallelization. Both have about the same performance. The first one is the most appealing since it is most straight forward. The second solution is not the preferred way of accomplishing the task in a real application, but is a good exercise in some of the less often used functions in OpenMP.

## part3b -- Generating graphs

In this example part3b.(c/f90) a graph is generated, represented as an adjacency list. Compile the program using the command make part3b and run the program part3b. Is the given program correct? Does it crash? And if so why?

*Hint*: Look at the push subroutine, what happens if several threads modify the adjacency list concurrently?
There are several solutions for this problem, each with various amounts of synchronization overhead. Try to fix the program without too much overhead.

# Solutions
The solutions can be found here towards the end of the lab session.
