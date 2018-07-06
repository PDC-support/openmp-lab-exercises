FC = ftn
FFLAGS = -g -O2 -Mpreprocess 
OMPFLAGS = -mp
LIBS = -lm

all: part1 part2 part3

part1: part1ex1 part1ex2 part1ex3 part1ex4
	

part2: part2ex1 part2ex2 part2ex3
	

part3: part3a part3b
	

part1ex1: part1.f90
	$(FC) $(FFLAGS) $(OMPFLAGS) -DEXAMPLE=1 part1.f90 -o $@ $(LIBS)

part1ex2: part1.f90
	$(FC) $(FFLAGS) $(OMPFLAGS) -DEXAMPLE=2 part1.f90 -o $@ $(LIBS)

part1ex3: part1.f90
	$(FC) $(FFLAGS) $(OMPFLAGS) -DEXAMPLE=3 part1.f90 -o $@ $(LIBS)

part1ex4: part1.f90
	$(FC) $(FFLAGS) $(OMPFLAGS) -DEXAMPLE=4 part1.f90 -o $@ $(LIBS)

part2ex1: part2.f90 
	$(FC) $(FFLAGS) $(OMPFLAGS) -DEXAMPLE=1 part2.f90 -o $@ $(LIBS)

part2ex2: part2.f90 
	$(FC) $(FFLAGS) $(OMPFLAGS) -DEXAMPLE=2 part2.f90 -o $@ $(LIBS)

part2ex3: part2.f90
	$(FC) $(FFLAGS) $(OMPFLAGS) -DEXAMPLE=3 part2.f90 -o $@ $(LIBS)

part3a:	part3a.f90 
	$(FC) $(FFLAGS) $(OMPFLAGS) part3a.f90 -o $@ $(LIBS) 

part3b:	part3b.f90 
	$(FC) $(FFLAGS) $(OMPFLAGS) part3b.f90 -o $@ $(LIBS) 

part2serial: part2.f90
	$(FC) $(FFLAGS) -DSERIAL part2.f90 -o $@ $(LIBS)

part3serial: part3a.f90
	$(FC) $(FFLAGS) -DSERIAL part3a.f90 -o $@ $(LIBS)

clean:
	rm -fr part1ex1 part1ex2 part1ex3 part1ex4\
	 part2ex1 part2ex2 part2ex3 part3a part3b *.o 

