F90 = ftn
FFLAGS = -O2 -homp
SRC = vtk_export.f90 shwater2d.f90
OBJS = ${SRC:.f90=.o}
DEST = shwater2d

all: $(DEST)

$(DEST): $(OBJS)
	$(F90) $(FFLAGS) $(OBJS) -o $@	

clean:
	rm -f $(DEST) *.mod *.MOD *.o

%.o: %.f90
	$(F90) $(FFLAGS) -c $<

